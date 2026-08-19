using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Belge kaydetme (API §4) - Faz 1'in kalbi. HEPSI YA DA HICBIRI: numara,
/// satirlar, stok durumu, cari hareket ve islem_log TEK TRANSACTION icinde yazilir.
///
/// Sira onemli - belge NUMARASI EN SON alinir: numara alan transaction rollback
/// olursa o numara BOSLUGA DUSER (e-Belge boslukluk kabul etmez). Once her sey
/// dogrulanir ve yazilir, numara en sonda satir kilidi altinda uretilir.
/// </summary>
public sealed class BelgeDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    // ISLEMLOG tablo kodlari (GENINI -11110): 30 = Fatbaslik
    private const int LogTabloBelge = 30;

    public BelgeDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    /// <summary>Satis belgeleri (giden): cari BORCLANIR. Alis (gelen): cari ALACAKLANIR.</summary>
    private static bool SatisMi(int tur) => tur is 14 or 15 or 16 or 119 or 29 or 105 or 133;

    public async Task<(int Id, List<string> Uyarilar)> KaydetAsync(
        IDictionary<string, object?> belge,
        List<Dictionary<string, JsonElement>> satirlar,
        BelgeSecenekleri secenekler,
        YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        var uyarilar = new List<string>();

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var tur = Sayi(belge, "tur");
        var tarafId = Sayi(belge, "tarafId");
        if (tarafId <= 0)
            throw GentegreHatasi.Dogrulama("Cari secilmeli.", new AlanHatasi("tarafId", "Zorunlu."));
        if (satirlar.Count == 0)
            throw GentegreHatasi.Dogrulama("Belgede en az bir satir olmali.",
                new AlanHatasi("satirlar", "Bos birakilamaz."));

        // ---------------------------------------------- 1) taraf bilgisini DONDUR ----
        // Belge, kartin O ANDAKI halini tasir: kart sonradan degisse de belge degismez.
        //   tarafUnvan <- fatura_unvan (bos ise unvan). Istekte acikca gonderildiyse
        //   kullanicinin yazdigi deger kabul edilir (sozlesme §4/2).
        await using (var komut = new NpgsqlCommand("""
            select t.unvan, t.fatura_unvan, t.vkno, t.vd
              from public.taraf t where t.id = @p0
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", tarafId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.Bulunamadi("Cari kayit bulunamadi.");

            var unvan = okuyucu.Metin("unvan");
            var faturaUnvan = okuyucu.Metin("fatura_unvan");
            Varsayilan(belge, "tarafUnvan", faturaUnvan.Length > 0 ? faturaUnvan : unvan);
            Varsayilan(belge, "tarafVkno", okuyucu.Metin("vkno"));
            Varsayilan(belge, "tarafVd", okuyucu.Metin("vd"));
        }

        var adresId = Sayi(belge, "tarafAdresId");
        if (adresId > 0)
        {
            await using var komut = new NpgsqlCommand("""
                select adres, ilce, il from public.taraf_adres where id = @p0 and taraf_id = @p1
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", adresId);
            komut.Parameters.AddWithValue("p1", tarafId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (await okuyucu.ReadAsync(iptal))
            {
                Varsayilan(belge, "tarafAdres", okuyucu.Metin("adres"));
                Varsayilan(belge, "tarafIlce", okuyucu.Metin("ilce"));
                Varsayilan(belge, "tarafIl", okuyucu.Metin("il"));
            }
        }

        // -------------------------------------- 2) gonderici (sube) kimligini DONDUR ----
        // 022 karari: her subenin kendi VKN/VD'si olabilir, belge o kimlikle gider.
        if (baglam.SubeId is { } subeId)
        {
            await using var komut = new NpgsqlCommand("""
                select coalesce(nullif(unvan, ''), ad) as unvan, vkno, efatura_alias, ebelge_seri
                  from public.sube where id = @p0
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", subeId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (await okuyucu.ReadAsync(iptal))
            {
                Varsayilan(belge, "gondericiUnvan", okuyucu.Metin("unvan"));
                Varsayilan(belge, "gondericiVkno", okuyucu.Metin("vkno"));
                Varsayilan(belge, "gondericiAlias", okuyucu.Metin("efatura_alias"));
                if (Metin(belge, "belgeSeri").Length == 0)
                    Varsayilan(belge, "belgeSeri", okuyucu.Metin("ebelge_seri"));
            }
            belge["subeId"] = subeId;
        }

        // Doviz: TL islemde de dolu (026 karari)
        var belgeDovizi = Metin(belge, "belgeDovizi");
        if (belgeDovizi.Length == 0) { belgeDovizi = "TL"; belge["belgeDovizi"] = belgeDovizi; }
        var kur = Ondalik(belge, "dovizKuru");
        if (kur <= 0) { kur = 1m; belge["dovizKuru"] = kur; }
        if (Metin(belge, "kur").Length == 0) belge["kur"] = belgeDovizi;
        if (Metin(belge, "raporDovizi").Length == 0) belge["raporDovizi"] = belgeDovizi;
        if (Metin(belge, "kdvDurum").Length == 0) belge["kdvDurum"] = "Hariç";

        // -------------------------------------------------- 3) belge basligi INSERT ----
        // Numara TASLAKTA alinmaz, kesinlestirmede de EN SON alinir (asagida).
        belge["belgeNo"] = "";
        belge["durum"] = secenekler.Taslak ? 1 : 0;
        var belgeId = await BelgeEkleAsync(baglanti, islem, belge, baglam, iptal);

        // ------------------------------------------------------ 4) satirlar INSERT ----
        var sira = 0;
        foreach (var satir in satirlar)
        {
            sira++;
            await SatirEkleAsync(baglanti, islem, belgeId, sira, satir, belge, baglam, uyarilar, iptal);
        }

        // ------------------------------------------------------------ 5) toplamlar ----
        // Tutarlar dip toplam formulunden gelir - Delphi ile birebir dogrulanmis
        //   fonksiyon (024). Toplami burada yeniden hesaplamak iki ayri dogruluk
        //   kaynagi yaratir; tek kaynak fn_belge_diptoplam'dir.
        await ToplamlariYazAsync(baglanti, islem, belgeId, iptal);

        // ----------------------------------------------- 6) stok durumu + hareket ----
        if (!secenekler.Taslak)
        {
            await StokDurumGuncelleAsync(baglanti, islem, belgeId, tur, secenekler.StokKontrolu, uyarilar, iptal);
            await MaliHareketYazAsync(baglanti, islem, belgeId, tur, tarafId, baglam, iptal);

            // ------------------------------------------------------- 7) belge NUMARASI ----
            // EN SON: buraya kadar her sey basarili. Satir kilidi altinda, BOSLUKSUZ.
            await NumaraVerAsync(baglanti, islem, belgeId, tur, Metin(belge, "belgeSeri"), baglam.SubeId, iptal);
        }

        // ------------------------------------------------------------------ 8) log ----
        await _log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["tur"] = tur.ToString(CultureInfo.InvariantCulture),
                ["tarafId"] = tarafId.ToString(CultureInfo.InvariantCulture),
                ["satirAdedi"] = satirlar.Count.ToString(CultureInfo.InvariantCulture),
                ["taslak"] = secenekler.Taslak ? "1" : "0"
            },
            tarafId: tarafId, iptal: iptal);

        await islem.CommitAsync(iptal);
        return (belgeId, uyarilar);
    }

    // ================================================================== okuma ====
    public async Task<(IDictionary<string, object?> Belge, List<IDictionary<string, object?>> Satirlar,
                       List<DipToplamSatiri> DipToplam)?> OkuAsync(int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        IDictionary<string, object?>? belge = null;
        await using (var komut = new NpgsqlCommand("""
            select b.id, b.tur, b.tipi, b.belge_seri as "belgeSeri", b.belge_no as "belgeNo",
                   b.belge_tarihi as "belgeTarihi", b.taraf_id as "tarafId",
                   b.taraf_unvan as "tarafUnvan", b.taraf_vkno as "tarafVkno",
                   b.gonderici_unvan as "gondericiUnvan", b.gonderici_vkno as "gondericiVkno",
                   b.matrah, b.kdv_tutari as "kdvTutari", b.ek_vergi as "ekVergi",
                   b.genel_toplam as "genelToplam", b.belge_dovizi as "belgeDovizi",
                   b.doviz_tutari as "dovizTutari", b.doviz_kuru as "dovizKuru",
                   b.kdv_durum as "kdvDurum", b.durum, b.sube_id as "subeId",
                   b.xmin::text as surum
              from public.belge b where b.id = @p0
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal)) return null;
            belge = Satir(okuyucu);
        }

        var satirlar = new List<IDictionary<string, object?>>();
        await using (var komut = new NpgsqlCommand("""
            select s.id, s.sira, s.tur, s.stok_id as "stokId", s.hizmet_id as "hizmetId",
                   s.masraf_id as "masrafId", s.aciklama, s.adet, s.miktar, s.birim,
                   s.birim_fiyat as "birimFiyat", s.iskonto, s.iskonto2, s.kdv,
                   s.otv_yuzde as "otvYuzde", s.otv_miktar as "otvMiktar", s.tutar,
                   s.doviz_cinsi as "dovizCinsi", s.doviz_birim_fiyat as "dovizBirimFiyat",
                   s.doviz_tutari as "dovizTutari", s.doviz_kuru as "dovizKuru",
                   s.giris_depo_id as "girisDepoId", s.cikis_depo_id as "cikisDepoId",
                   s.izleme_kodu as "izlemeKodu"
              from public.belge_satir s where s.belge_id = @p0 order by s.sira, s.id
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            while (await okuyucu.ReadAsync(iptal)) satirlar.Add(Satir(okuyucu));
        }

        var dip = await DipToplamAsync(baglanti, null, belgeId, iptal);
        return (belge!, satirlar, dip);
    }

    public async Task<List<DipToplamSatiri>> DipToplamAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int belgeId, CancellationToken iptal)
    {
        var sonuc = new List<DipToplamSatiri>();
        await using var komut = new NpgsqlCommand(
            "select * from public.fn_belge_diptoplam(@p0) order by d_tur", baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
        {
            sonuc.Add(new DipToplamSatiri(
                (int)okuyucu.GetDouble(okuyucu.GetOrdinal("d_tur")),
                okuyucu.Metin("d_aciklama"),
                (decimal)okuyucu.GetDouble(okuyucu.GetOrdinal("d_deger")),
                okuyucu.IsDBNull(okuyucu.GetOrdinal("d_doviz_tutari"))
                    ? 0 : (decimal)okuyucu.GetDouble(okuyucu.GetOrdinal("d_doviz_tutari")),
                okuyucu.Metin("d_kur"),
                okuyucu.Metin("d_belge_dovizi")));
        }
        return sonuc;
    }

    // ================================================================ ic adimlar ====
    private static readonly Dictionary<string, string> BelgeKolonlari = new(StringComparer.Ordinal)
    {
        ["tur"] = "tur", ["tipi"] = "tipi", ["tarafId"] = "taraf_id",
        ["tarafAdresId"] = "taraf_adres_id", ["tarafUnvan"] = "taraf_unvan",
        ["tarafVkno"] = "taraf_vkno", ["tarafVd"] = "taraf_vd", ["tarafAdres"] = "taraf_adres",
        ["tarafIlce"] = "taraf_ilce", ["tarafIl"] = "taraf_il",
        ["belgeSeri"] = "belge_seri", ["belgeNo"] = "belge_no", ["kocanNo"] = "kocan_no",
        ["belgeTarihi"] = "belge_tarihi", ["irsaliyeNo"] = "irsaliye_no",
        ["irsaliyeTarihi"] = "irsaliye_tarihi", ["girisDepoId"] = "giris_depo_id",
        ["cikisDepoId"] = "cikis_depo_id", ["subeId"] = "sube_id", ["projeId"] = "proje_id",
        ["kdvDurum"] = "kdv_durum", ["belgeDovizi"] = "belge_dovizi",
        ["dovizCinsi"] = "doviz_cinsi", ["dovizKuru"] = "doviz_kuru", ["kur"] = "kur",
        ["raporDovizi"] = "rapor_dovizi", ["vadeGun"] = "vade_gun", ["durum"] = "durum",
        ["aciklama"] = "aciklama", ["ozelKod"] = "ozel_kod", ["senaryo"] = "senaryo",
        ["gondericiUnvan"] = "gonderici_unvan", ["gondericiVkno"] = "gonderici_vkno",
        ["gondericiAlias"] = "gonderici_alias", ["saticiId"] = "satici_id"
    };

    private async Task<int> BelgeEkleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        IDictionary<string, object?> belge, YazmaBaglami baglam, CancellationToken iptal)
    {
        var kolonlar = new List<string>();
        var parametreler = new List<object?>();

        foreach (var (ad, deger) in belge)
        {
            if (!BelgeKolonlari.TryGetValue(ad, out var kolon)) continue;
            kolonlar.Add(kolon);
            parametreler.Add(deger);
        }

        kolonlar.Add("ekleyen");
        parametreler.Add(baglam.KullaniciId);

        var yerTutucular = Enumerable.Range(0, parametreler.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));

        var sql = $"insert into public.belge ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)}) returning id";

        await using var komut = Komut(baglanti, islem, sql, parametreler);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));
    }

    private async Task SatirEkleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int sira, Dictionary<string, JsonElement> satir,
        IDictionary<string, object?> belge, YazmaBaglami baglam, List<string> uyarilar,
        CancellationToken iptal)
    {
        var tur = (int)JsonSayi(satir, "tur", 1);
        var stokId   = JsonSayiNull(satir, "stokId");
        var hizmetId = JsonSayiNull(satir, "hizmetId");
        var masrafId = JsonSayiNull(satir, "masrafId");

        // §4/3: uc bagdan yalniz BIRI dolu olabilir (veritabani check ile de zorlar).
        var bagAdedi = (stokId is not null ? 1 : 0) + (hizmetId is not null ? 1 : 0) +
                       (masrafId is not null ? 1 : 0);
        if (bagAdedi > 1)
            throw GentegreHatasi.Dogrulama($"{sira}. satirda birden fazla urun bagi var.",
                new AlanHatasi($"satirlar[{sira - 1}]", "stokId / hizmetId / masrafId birlikte olamaz."));

        var beklenen = tur switch { 1 => stokId, 2 => hizmetId, 3 => masrafId, _ => null };
        if (bagAdedi == 1 && beklenen is null)
            throw GentegreHatasi.Dogrulama($"{sira}. satirda tur ile urun bagi uyusmuyor.",
                new AlanHatasi($"satirlar[{sira - 1}].tur", "tur=1 stok, 2 hizmet, 3 masraf."));

        var adet       = JsonOndalik(satir, "adet", JsonOndalik(satir, "miktar", 0));
        var miktar     = JsonOndalik(satir, "miktar", adet);
        var iskonto    = JsonOndalik(satir, "iskonto", 0);
        var iskonto2   = JsonOndalik(satir, "iskonto2", 0);
        var kdv        = (int)JsonSayi(satir, "kdv", 0);

        // Doviz: satirin kuru yoksa belgenin kuru. TL islemde de kur = 1 (026).
        var kur = JsonOndalik(satir, "dovizKuru", 0);
        if (kur <= 0) kur = Ondalik(belge, "dovizKuru");
        if (kur <= 0) kur = 1m;
        var dovizCinsi = JsonMetin(satir, "dovizCinsi");
        if (dovizCinsi.Length == 0) dovizCinsi = Metin(belge, "belgeDovizi");
        if (dovizCinsi.Length == 0) dovizCinsi = "TL";

        // Birim fiyat doviz uzerinden verildiyse yerel karsiligi turetilir
        //   (Delphi: BIRIMFIYAT = DOVIZ_BIRIMFIYAT * DOVIZKURDEGERI).
        var dovizBirimFiyat = JsonOndalik(satir, "dovizBirimFiyat", 0);
        var birimFiyat = JsonOndalik(satir, "birimFiyat", 0);
        if (birimFiyat == 0 && dovizBirimFiyat != 0)
            birimFiyat = BelgeHesap.YerelBirimFiyat(dovizBirimFiyat, kur);
        if (dovizBirimFiyat == 0 && birimFiyat != 0)
            dovizBirimFiyat = BelgeHesap.DovizKarsiligi(birimFiyat, kur, 6);

        // TUTAR: Delphi formulu birebir (ic yuvarlama + carpimsal iskonto + banker's).
        var tutar      = BelgeHesap.SatirTutari(adet, birimFiyat, iskonto, iskonto2);
        var dovizTutar = BelgeHesap.SatirTutari(adet, dovizBirimFiyat, iskonto, iskonto2);

        var kolonlar = new List<string>
        {
            "belge_id", "sira", "tur", "stok_id", "hizmet_id", "masraf_id", "aciklama",
            "adet", "miktar", "birim", "birim_fiyat", "iskonto", "iskonto2", "kdv",
            "otv_yuzde", "otv_miktar", "kdv_muafiyeti", "tutar",
            "doviz_cinsi", "doviz_birim_fiyat", "doviz_tutari", "doviz_kuru",
            "giris_depo_id", "cikis_depo_id", "izleme", "izleme_kodu", "stok_durum_degis",
            "sube_id", "ekleyen"
        };
        var parametreler = new List<object?>
        {
            belgeId, sira, tur, stokId, hizmetId, masrafId, JsonMetin(satir, "aciklama"),
            adet, miktar, (int)JsonSayi(satir, "birim", 0), birimFiyat, iskonto, iskonto2, (short)kdv,
            (short)JsonSayi(satir, "otvYuzde", 0), JsonOndalik(satir, "otvMiktar", 0),
            (short)JsonSayi(satir, "kdvMuafiyeti", 0), tutar,
            dovizCinsi, dovizBirimFiyat, dovizTutar, kur,
            JsonSayiNull(satir, "girisDepoId") ?? SayiNull(belge, "girisDepoId"),
            JsonSayiNull(satir, "cikisDepoId") ?? SayiNull(belge, "cikisDepoId"),
            (short)JsonSayi(satir, "izleme", 0), JsonMetin(satir, "izlemeKodu"),
            (short)JsonSayi(satir, "stokDurumDegis", 1),
            (short)(baglam.SubeId ?? 0), baglam.KullaniciId
        };

        var yerTutucular = Enumerable.Range(0, parametreler.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));
        var sql = $"insert into public.belge_satir ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)})";

        await using var komut = Komut(baglanti, islem, sql, parametreler);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task ToplamlariYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, CancellationToken iptal)
    {
        var dip = await DipToplamAsync(baglanti, islem, belgeId, iptal);

        decimal Topla(int tur) => dip.Where(d => d.Tur == tur).Sum(d => d.Deger);

        var matrah = Topla(DipToplamTuru.AraToplam);
        var kdv    = Topla(DipToplamTuru.KdvToplam);
        var ek     = Topla(DipToplamTuru.EkVergi) + Topla(DipToplamTuru.Stopaj);
        var genel  = Topla(DipToplamTuru.GenelToplam);
        var dovizGenel = dip.Where(d => d.Tur == DipToplamTuru.GenelToplam).Sum(d => d.DovizTutari);

        await using var komut = new NpgsqlCommand("""
            update public.belge
               set matrah = @p1, kdv_tutari = @p2, ek_vergi = @p3, genel_toplam = @p4,
                   doviz_tutari = @p5
             where id = @p0
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        komut.Parameters.AddWithValue("p1", matrah);
        komut.Parameters.AddWithValue("p2", kdv);
        komut.Parameters.AddWithValue("p3", ek);
        komut.Parameters.AddWithValue("p4", genel);
        komut.Parameters.AddWithValue("p5", dovizGenel);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task StokDurumGuncelleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, bool stokKontrolu, List<string> uyarilar, CancellationToken iptal)
    {
        var satis = SatisMi(tur);

        // stok_durum_degis = 0 olan satirlar stok bakiyesini ETKILEMEZ.
        await using var oku = new NpgsqlCommand("""
            select s.stok_id, s.miktar, s.adet,
                   coalesce(s.cikis_depo_id, s.giris_depo_id) as depo_id
              from public.belge_satir s
             where s.belge_id = @p0 and s.tur = 1 and s.stok_id is not null
               and s.stok_durum_degis = 1
            """, baglanti, islem);
        oku.Parameters.AddWithValue("p0", belgeId);

        var hareketler = new List<(int StokId, decimal Miktar, int? DepoId)>();
        await using (var okuyucu = await oku.ExecuteReaderAsync(iptal))
            while (await okuyucu.ReadAsync(iptal))
            {
                var miktar = okuyucu.GetDecimal(okuyucu.GetOrdinal("miktar"));
                if (miktar == 0) miktar = okuyucu.GetDecimal(okuyucu.GetOrdinal("adet"));
                hareketler.Add((okuyucu.Sayi("stok_id"), miktar, okuyucu.SayiNull("depo_id")));
            }

        foreach (var (stokId, miktar, depoId) in hareketler)
        {
            if (depoId is null) continue;

            await using var komut = new NpgsqlCommand("""
                insert into public.stok_durum (stok_id, depo_id, giren, cikan, kalan)
                values (@p0, @p1, @p2, @p3, @p2 - @p3)
                on conflict (stok_id, depo_id) do update
                   set giren = stok_durum.giren + excluded.giren,
                       cikan = stok_durum.cikan + excluded.cikan,
                       kalan = stok_durum.kalan + excluded.giren - excluded.cikan
                returning kalan
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", stokId);
            komut.Parameters.AddWithValue("p1", depoId.Value);
            komut.Parameters.AddWithValue("p2", satis ? 0m : miktar);   // giren
            komut.Parameters.AddWithValue("p3", satis ? miktar : 0m);   // cikan

            var kalan = Convert.ToDecimal(await komut.ExecuteScalarAsync(iptal) ?? 0m);
            if (stokKontrolu && kalan < 0)
                uyarilar.Add($"Stok {stokId} deposunda bakiye negatife dustu ({kalan}).");
        }
    }

    private async Task MaliHareketYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, int tarafId, YazmaBaglami baglam, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            insert into public.mali_hareket
                (tur, hesap_turu, taraf_id, belge_id, belge_no, islem_tarihi,
                 borc, alacak, doviz_cinsi, doviz_tutari, doviz_kuru, kur,
                 aciklama, sube_id, ekleyen)
            select @p0, 1, b.taraf_id, b.id, b.belge_no, b.belge_tarihi,
                   case when @p1 then b.genel_toplam else 0 end,
                   case when @p1 then 0 else b.genel_toplam end,
                   b.belge_dovizi, b.doviz_tutari, b.doviz_kuru, b.kur,
                   b.taraf_unvan, b.sube_id, @p2
              from public.belge b where b.id = @p3
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", (short)tur);
        komut.Parameters.AddWithValue("p1", SatisMi(tur));
        komut.Parameters.AddWithValue("p2", baglam.KullaniciId);
        komut.Parameters.AddWithValue("p3", belgeId);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task NumaraVerAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, string seri, int? subeId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            update public.belge
               set belge_no = public.fn_belge_no_uret(@p1, @p2, @p3)
             where id = @p0 and coalesce(belge_no, '') = ''
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        komut.Parameters.AddWithValue("p1", tur);
        komut.Parameters.AddWithValue("p2", seri ?? "");
        komut.Parameters.AddWithValue("p3", subeId ?? 0);
        await komut.ExecuteNonQueryAsync(iptal);

        // Numara belgeye yazildi; mali_hareket satirindaki kopyasi da guncellenir.
        await using var komut2 = new NpgsqlCommand("""
            update public.mali_hareket m
               set belge_no = b.belge_no
              from public.belge b
             where b.id = m.belge_id and m.belge_id = @p0
            """, baglanti, islem);
        komut2.Parameters.AddWithValue("p0", belgeId);
        await komut2.ExecuteNonQueryAsync(iptal);
    }

    // ================================================================ yardimci ====
    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }

    private static void Varsayilan(IDictionary<string, object?> hedef, string ad, string deger)
    {
        if (!hedef.TryGetValue(ad, out var mevcut) || mevcut is null ||
            (mevcut is string s && s.Length == 0))
            hedef[ad] = deger;
    }

    private static int Sayi(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt32(v) : 0;

    private static int? SayiNull(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt32(v) : null;

    private static decimal Ondalik(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToDecimal(v) : 0m;

    private static string Metin(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? v.ToString() ?? "" : "";

    private static long JsonSayi(Dictionary<string, JsonElement> d, string ad, long varsayilan)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.Number && e.TryGetInt64(out var l)
           ? l : varsayilan;

    private static int? JsonSayiNull(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.Number && e.TryGetInt32(out var i)
           ? i : null;

    private static decimal JsonOndalik(Dictionary<string, JsonElement> d, string ad, decimal varsayilan)
    {
        if (!d.TryGetValue(ad, out var e)) return varsayilan;
        return e.ValueKind switch
        {
            JsonValueKind.Number => e.GetDecimal(),
            JsonValueKind.String => decimal.TryParse(e.GetString(), NumberStyles.Number,
                                        CultureInfo.InvariantCulture, out var m) ? m : varsayilan,
            _ => varsayilan
        };
    }

    private static string JsonMetin(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var e) && e.ValueKind == JsonValueKind.String
           ? e.GetString() ?? "" : "";

    private NpgsqlCommand Komut(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        string sql, IReadOnlyList<object?> parametreler)
    {
        var komut = new NpgsqlCommand(sql, baglanti, islem);
        for (var i = 0; i < parametreler.Count; i++)
            komut.Parameters.AddWithValue("p" + i.ToString(CultureInfo.InvariantCulture),
                parametreler[i] ?? DBNull.Value);
        return komut;
    }
}
