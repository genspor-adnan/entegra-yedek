using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;
using static Gentegre.Veri.JsonDeger;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Belge basligi / satirlari / toplamlari / numarasi ve cari hareketin YAZILMASI. Cagiran akis (KaydetIcAsync) ana dosyada; burasi tek tek INSERT/UPDATE adimlaridir.
/// </summary>
public sealed partial class BelgeDeposu
{
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
        // Belgenin fiyat listesi (205): uc whitelist'inde vardi ama bu sozlukte
        //   eksikti - istek kabul edilip alan SESSIZCE atlaniyordu.
        ["fiyatListesiId"] = "fiyat_listesi_id",
        // Belgeye ISLEYEN KAMPANYA (274). Liste ile birlikte durur, yerine
        //   gecmez: liste bazi, kampanya indirimi verir. Belgeye yazilir -
        //   kurum sonradan kampanya degistirse eski belge sabit kalir.
        ["kampanyaId"] = "kampanya_id",
        // Teklif durumu (218): Hazirlaniyor/Sunuldu/Kabul/Red/Iptal.
        ["teklifDurum"] = "teklif_durum",
        ["revizeNo"] = "revize_no", ["teklifKonusu"] = "teklif_konusu",
        ["teklifTeslim"] = "teklif_teslim",
        ["kdvDurum"] = "kdv_durum", ["belgeDovizi"] = "belge_dovizi",
        ["dovizCinsi"] = "doviz_cinsi", ["dovizKuru"] = "doviz_kuru", ["kur"] = "kur",
        ["raporDovizi"] = "rapor_dovizi", ["ekstreDovizi"] = "ekstre_dovizi",
        ["vadeGun"] = "vade_gun", ["durum"] = "durum",
        // BASVURUDA (249) vade yerine ODEYEN KURUM: hizmeti kim odeyecek
        //   (anlasmali kurum / sigorta). Belgeye yazilir - hastanin polices
        //   sonradan degisse de gecmis basvurunun odeyeni sabit kalir.
        ["odeyenKurumId"] = "odeyen_kurum_id",
        ["aciklama"] = "aciklama", ["ozelKod"] = "ozel_kod", ["senaryo"] = "senaryo",
        ["gondericiUnvan"] = "gonderici_unvan", ["gondericiVkno"] = "gonderici_vkno",
        ["gondericiAlias"] = "gonderici_alias", ["saticiId"] = "satici_id",
        ["merkezId"] = "merkez_id"
    };

    /// <summary>
    /// SEVKIYAT alanlari 177'de `belge_sevkiyat` (1:1) tablosuna tasindi -
    /// istek sozlesmesi AYNI kaldi, yalniz nereye yazildiklari degisti.
    /// </summary>
    private static readonly Dictionary<string, string> SevkiyatKolonlari = new(StringComparer.Ordinal)
    {
        ["teslimSekli"] = "teslim_sekli",
        // e-Irsaliye UBL: plaka + sofor (ad ve TCKN) zorunlu.
        ["aracPlaka"] = "arac_plaka", ["soforAd"] = "sofor_ad", ["soforTckn"] = "sofor_tckn",
        ["tasiyiciId"] = "tasiyici_id", ["teslimEdenId"] = "teslim_eden_id",
        ["teslimAlanId"] = "teslim_alan_id"
    };

    /// <summary>
    /// Sevkiyat satirini yazar (upsert). SATIR YALNIZ DOLU BILGI VARSA acilir:
    /// bos satir "sevkiyat girilmis" izlenimi verir ve irsaliye olmayan her
    /// belge icin gereksiz kayit olusurdu. Duzenlemede bilgi tamamen
    /// silinmisse satir da silinir.
    /// </summary>
    private async Task SevkiyatYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, IDictionary<string, object?> belge, YazmaBaglami baglam,
        CancellationToken iptal)
    {
        var kolonlar = new List<string>();
        var degerler = new List<object?>();
        var doluVar = false;

        foreach (var (ad, kolon) in SevkiyatKolonlari)
        {
            if (!belge.TryGetValue(ad, out var deger)) continue;
            kolonlar.Add(kolon);
            degerler.Add(deger);
            doluVar |= deger switch
            {
                null => false,
                string m => m.Trim().Length > 0,
                _ => Convert.ToDecimal(deger, CultureInfo.InvariantCulture) != 0,
            };
        }

        if (kolonlar.Count == 0) return;               // istekte sevkiyat alani yok

        if (!doluVar)
        {
            // Tum alanlar bosaltilmis: kaydi birak.
            await using var sil = baglanti.Komut(
                "delete from public.belge_sevkiyat where id = @p0", islem,
                belgeId);
            await sil.ExecuteNonQueryAsync(iptal);
            return;
        }

        var parametreler = new List<object?> { belgeId };
        parametreler.AddRange(degerler);
        var yerTutucular = Enumerable.Range(1, kolonlar.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture)).ToList();
        var guncelle = kolonlar.Select((k, i) => $"{k} = {yerTutucular[i]}").ToList();

        parametreler.Add(baglam.KullaniciId);
        var kullanici = "@p" + (parametreler.Count - 1).ToString(CultureInfo.InvariantCulture);

        var sql = $"""
            insert into public.belge_sevkiyat (id, {string.Join(", ", kolonlar)}, ekleyen)
            values (@p0, {string.Join(", ", yerTutucular)}, {kullanici})
            on conflict (id) do update
               set {string.Join(", ", guncelle)},
                   degistiren = {kullanici},
                   degistirme_tarihi = now()::timestamp
            """;

        await using var komut = Komut(baglanti, islem, sql, parametreler);
        await komut.ExecuteNonQueryAsync(iptal);
    }

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

    /// <summary>
    /// DUZENLEMEDE (135) mevcut belge basligini yeniden yazar. Kolon listesi
    /// eklemeyle AYNI beyaz listeden gelir; id, numara ve seri korunur.
    /// </summary>
    private async Task<int> BelgeGuncelleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, IDictionary<string, object?> belge, YazmaBaglami baglam,
        CancellationToken iptal)
    {
        var atamalar = new List<string>();
        var parametreler = new List<object?> { belgeId };

        foreach (var (ad, deger) in belge)
        {
            if (ad is "id" or "belgeNo" or "belgeSeri") continue;   // korunur
            if (!BelgeKolonlari.TryGetValue(ad, out var kolon)) continue;
            parametreler.Add(deger);
            atamalar.Add($"{kolon} = @p{parametreler.Count - 1}");
        }
        parametreler.Add(baglam.KullaniciId);
        atamalar.Add($"degistiren = @p{parametreler.Count - 1}");
        atamalar.Add("degistirme_tarihi = now()::timestamp");

        await using var komut = Komut(baglanti, islem,
            $"update public.belge set {string.Join(", ", atamalar)} where id = @p0",
            parametreler);
        await komut.ExecuteNonQueryAsync(iptal);
        return belgeId;
    }

    private async Task SatirEkleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int sira, Dictionary<string, JsonElement> satir,
        IDictionary<string, object?> belge, YazmaBaglami baglam, bool turStokEtkiler,
        List<string> uyarilar, CancellationToken iptal)
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

        // AMBALAJ BIRIMI (143): kullanici "2 kutu" girer, stok ANA BIRIMDE
        //   (24 adet) hareket eder. Carpan satirda SAKLANIR - stok kartindaki
        //   tanim sonradan degisse bile eski belge kendi carpaniyla okunur.
        //   Carpan gelmezse 1: birimsiz/ambalajsiz satir eskisi gibi calisir.
        var birimCarpan = JsonOndalik(satir, "birimCarpan", 1);
        if (birimCarpan <= 0) birimCarpan = 1;
        // `miktar` acikca gonderildiyse ona dokunulmaz (donusum kaynaktan
        //   kopyalar); yoksa girilen adetten ANA BIRIME cevrilir.
        var miktar     = JsonOndalik(satir, "miktar", adet * birimCarpan);
        var iskonto    = JsonOndalik(satir, "iskonto", 0);
        var iskonto2   = JsonOndalik(satir, "iskonto2", 0);
        var kdv        = (int)JsonSayi(satir, "kdv", 0);

        // SATIR BAZLI DOVIZ: bir kalem 100 USD, otekisi 100 TL olabilir.
        var dovizCinsi = JsonMetin(satir, "dovizCinsi");
        if (dovizCinsi.Length == 0) dovizCinsi = Metin(belge, "belgeDovizi");
        if (dovizCinsi.Length == 0) dovizCinsi = "TL";

        // Kur: satirin kuru yoksa belgeninki. Satir BELGE PARA BIRIMINDE ise
        //   kur HER ZAMAN 1 - belgenin rapor kuru buraya sizarsa yerel fiyat
        //   bolunup sacma bir "doviz" fiyati uretiliyordu (100 TL -> 2,08).
        var belgeDovizi = Metin(belge, "belgeDovizi");
        var kur = JsonOndalik(satir, "dovizKuru", 0);
        if (kur <= 0) kur = Ondalik(belge, "dovizKuru");
        if (kur <= 0) kur = 1m;
        if (belgeDovizi.Length > 0
            && dovizCinsi.Equals(belgeDovizi, StringComparison.OrdinalIgnoreCase))
            kur = 1m;

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

        // ODEME PAYLASIMI (289): odeyen kurum varsa satir tutari KURUM ve HASTA
        //   payina bolunur. Istemci acikca tutar gonderdiyse ona dokunulmaz
        //   (sigorta bazen orana degil SABIT TUTARA onay verir); yalniz oran
        //   verilmisse ya da kurumun varsayilan orani varsa hesaplanir.
        var karsilama   = JsonOndalik(satir, "karsilama", 0);
        var kurumTutar  = JsonOndalik(satir, "kurumTutar", -1);
        var hastaTutar  = JsonOndalik(satir, "hastaTutar", -1);
        var odeyenKurum = SayiNull(belge, "odeyenKurumId");

        if (kurumTutar < 0 || hastaTutar < 0)
        {
            if (odeyenKurum is { } kid && kid > 0)
            {
                // KATILIM PAYI (291): SGK modunda paylastirma orana degil
                //   satirin KATKI TUTARINA gore yapilir - istemci fiyatla
                //   birlikte gelen katkiyi gonderir.
                await using var pay = Komut(baglanti, islem,
                    "select kurum_tutar, hasta_tutar, karsilama " +
                    "  from public.fn_belge_satir_paylastir(@p0, @p1, @p2, @p3)",
                    [tutar, karsilama, kid, JsonOndalik(satir, "katkiTutar", 0)]);
                await using var o = await pay.ExecuteReaderAsync(iptal);
                if (await o.ReadAsync(iptal))
                {
                    if (kurumTutar < 0) kurumTutar = o.GetDecimal(0);
                    if (hastaTutar < 0) hastaTutar = o.GetDecimal(1);
                    if (karsilama == 0) karsilama = o.GetDecimal(2);
                }
            }
            else
            {
                // Odeyen kurum yok: tamami hastanindir (kendi oder).
                if (kurumTutar < 0) kurumTutar = 0m;
                if (hastaTutar < 0) hastaTutar = tutar;
            }
        }
        if (kurumTutar < 0) kurumTutar = 0m;
        if (hastaTutar < 0) hastaTutar = 0m;

        var kolonlar = new List<string>
        {
            "belge_id", "sira", "tur", "stok_id", "hizmet_id", "masraf_id", "aciklama",
            "adet", "miktar", "birim", "birim_carpan", "birim_fiyat", "iskonto", "iskonto2", "kdv",
            "otv_yuzde", "otv_miktar", "kdv_muafiyeti", "tutar",
            "doviz_cinsi", "doviz_birim_fiyat", "doviz_tutari", "doviz_kuru",
            "giris_depo_id", "cikis_depo_id", "izleme", "izleme_kodu", "stok_durum_degis",
            // Donusum bagi (F8): kaynak_tur=30 -> kaynak belge_satir. Kapatma
            //   sayacini bu iki alan uzerinden DB trigger'i surer.
            "kaynak_tur", "kaynak_id", "proje_id",
            // Satir bazli TESLIM TARIHI (140) - siparis termini. Bos gecilebilir.
            "teslim_tarihi",
            // Kalemi HANGI kampanya kurali fiyatladi (274) - denetim izi.
            //   Kampanya satiri sonradan degisse de belgede kanit kalir.
            "kampanya_satir_id",
            // ODEME PAYLASIMI (289): tutarin kurum/hasta payi ve hedef satirda
            //   hangi payi kapattigi.
            "kurum_tutar", "hasta_tutar", "karsilama", "provizyon_no", "pay",
            "sube_id", "ekleyen"
        };
        var parametreler = new List<object?>
        {
            belgeId, sira, tur, stokId, hizmetId, masrafId, JsonMetin(satir, "aciklama"),
            adet, miktar, (int)JsonSayi(satir, "birim", 0), birimCarpan,
            birimFiyat, iskonto, iskonto2, (short)kdv,
            (short)JsonSayi(satir, "otvYuzde", 0), JsonOndalik(satir, "otvMiktar", 0),
            (short)JsonSayi(satir, "kdvMuafiyeti", 0), tutar,
            dovizCinsi, dovizBirimFiyat, dovizTutar, kur,
            JsonSayiNull(satir, "girisDepoId") ?? SayiNull(belge, "girisDepoId"),
            JsonSayiNull(satir, "cikisDepoId") ?? SayiNull(belge, "cikisDepoId"),
            (short)JsonSayi(satir, "izleme", 0), JsonMetin(satir, "izlemeKodu"),
            (short)(turStokEtkiler ? JsonSayi(satir, "stokDurumDegis", 1) : 0),
            (int)JsonSayi(satir, "kaynakTur", 0), JsonSayi(satir, "kaynakId", 0),
            JsonSayiNull(satir, "projeId") ?? SayiNull(belge, "projeId"),
            JsonTarih(satir, "teslimTarihi"),
            JsonSayiNull(satir, "kampanyaSatirId"),
            kurumTutar, hastaTutar, karsilama, JsonMetin(satir, "provizyonNo"),
            (short)JsonSayi(satir, "pay", 0),
            (short)baglam.SubeZorunlu(), baglam.KullaniciId
        };

        var yerTutucular = Enumerable.Range(0, parametreler.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));
        var sql = $"insert into public.belge_satir ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)}) returning id";

        int satirId;
        await using (var komut = Komut(baglanti, islem, sql, parametreler))
            satirId = Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));

        // Lot / seri izlemi: stok izlemliyse satirin miktari lotlara dagitilir.
        //   ANA BIRIM miktari (`miktar`) verilir - lot bakiyesi de stok bakiyesi
        //   gibi ana birimde tutulur; "2 kutu" degil "24 adet" dagitilir (143).
        if (stokId is { } sid)
            await IzlemYazAsync(baglanti, islem, belgeId, satirId, sid, sira,
                                Sayi(belge, "tur"), miktar, satir, belge, turStokEtkiler,
                                uyarilar, iptal);
    }

    // ============================================================ lot / seri ====
    /// <summary>
    /// Satirin LOT/SERI dagilimini yazar (stok_seri_lot + stok_izleme).
    ///
    /// Kural stok kartindan gelir (stok.izleme): 0 izlemsiz, 1 Seri No, 2 Lot No,
    /// 3 SKT, 4 Karekod, 5 Lot No + SKT, 6 Seri No + Lot No. Izlemli bir stokta
    /// GIRIS belgesinde lot bilgisi ZORUNLUDUR - girilmezse mal hangi lottan
    /// geldigi bilinmeden depoya girer ve geri izlenemez (gida/ilac/medikal
    /// tarafinda tek sebeple: geri cagirma).
    ///
    /// Bir kalem 1:n lot tasiyabilir; lot miktarlarinin toplami satir miktarina
    /// ESIT olmali - eksik/fazla dagitim depo miktariyla lot toplamini ayirir.
    ///
    /// CIKIS belgelerinde bu yol henuz calismaz: cikista lot SECILIR (mevcut
    /// stoktan, kalan miktarina gore) - ayri ekran, ayri kural.
    /// </summary>

    private async Task ToplamlariYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, CancellationToken iptal)
    {
        var dip = await DipToplamAsync(baglanti, islem, belgeId, iptal);

        decimal Topla(int tur) => dip.Where(d => d.Tur == tur).Sum(d => d.Deger);

        var matrah = Topla(DipToplamTuru.AraToplam);
        var kdv    = Topla(DipToplamTuru.KdvToplam);
        var ek     = Topla(DipToplamTuru.EkVergi) + Topla(DipToplamTuru.Stopaj);
        var genel  = Topla(DipToplamTuru.GenelToplam);
        // DOVIZ KARSILIGI (134): tutarlar YEREL parada tutulur; rapor dovizi
        //   yerel paradan farkliysa karsilik genel toplamin KURA BOLUNMESIDIR.
        var dovizGenel = dip.Where(d => d.Tur == DipToplamTuru.GenelToplam).Sum(d => d.DovizTutari);
        await using (var kurKomut = new NpgsqlCommand(
            "select coalesce(nullif(btrim(rapor_dovizi), ''), ''), " +
            "coalesce(nullif(btrim(belge_dovizi), ''), ''), coalesce(doviz_kuru, 1) " +
            "from public.belge where id = @p0", baglanti, islem))
        {
            kurKomut.Parameters.AddWithValue("p0", belgeId);
            await using var o = await kurKomut.ExecuteReaderAsync(iptal);
            if (await o.ReadAsync(iptal))
            {
                var rapor = o.GetString(0);
                var belgeDoviz = o.GetString(1);
                var kur = o.GetDecimal(2);
                if (rapor.Length > 0
                    && !rapor.Equals(belgeDoviz, StringComparison.OrdinalIgnoreCase) && kur > 0)
                    dovizGenel = Math.Round(genel / kur, 2, MidpointRounding.ToEven);
            }
        }

        await using var komut = baglanti.Komut("""
            update public.belge
               set matrah = @p1, kdv_tutari = @p2, ek_vergi = @p3, genel_toplam = @p4,
                   doviz_tutari = @p5
             where id = @p0
            """, islem,
            belgeId, matrah, kdv, ek, genel, dovizGenel);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task MaliHareketYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, int tipi, int tarafId, YazmaBaglami baglam, CancellationToken iptal)
    {
        // Bacak duzeni (080 gocu ile gelen K2 kurali):
        //   doviz_cinsi = bacagin KENDI para birimi (belgenin dovizi)
        //   borc/alacak = O DOVIZDE tutar  (TL belgede zaten TL)
        //   yerel_borc / yerel_alacak = TL karsiligi (genel_toplam)
        //   doviz_kuru  = belgedeki kur
        // Eski "kur" ve "doviz_tutari" kolonlari 080'de DUSURULDU.
        // hesap_turu 'C' (cari) - eskiden yanlislikla '1' yaziliyordu; sema
        //   yorumu (012_sema_belge.sql:212) ve tum ekstre gorunumleri 'C' bekler.
        await using var komut = baglanti.Komut("""
            insert into public.mali_hareket
                (tur, hesap_turu, taraf_id, belge_id, belge_no, islem_tarihi,
                 borc, alacak, yerel_borc, yerel_alacak,
                 doviz_cinsi, doviz_kuru, aciklama, sube_id, ekleyen)
            select @p0, 'C', b.taraf_id, b.id, b.belge_no, b.belge_tarihi,
                   case when @p1 then d.tutar else 0 end,
                   case when @p1 then 0 else d.tutar end,
                   case when @p1 then b.genel_toplam else 0 end,
                   case when @p1 then 0 else b.genel_toplam end,
                   d.cins, d.kur,
                   b.taraf_unvan, b.sube_id, @p2
              from public.belge b
              cross join lateral (
                  -- EKSTRE DOVIZI (134): cari hesaba hangi dovizde islenecek.
                  --   TUTAR ILE CINS AYNI DOVIZDE OLMALI: `doviz_tutari` RAPOR
                  --   dovizinde hesaplanir; ekstre dovizi ondan farkliysa (or.
                  --   rapor EUR, ekstre TL) tutar EUR kalip etiketi TL oluyordu
                  --   ve ekstrede "480 TL" gorunuyordu (gercek vaka).
                  select ekstre.cins,
                         case when ekstre.cins = rapor.cins and coalesce(b.doviz_tutari, 0) > 0
                              then b.doviz_tutari else b.genel_toplam end as tutar,
                         case when ekstre.cins = rapor.cins and coalesce(b.doviz_kuru, 0) > 0
                              then b.doviz_kuru else 1 end as kur
                    from (select coalesce(nullif(btrim(b.ekstre_dovizi), ''),
                                          nullif(btrim(b.rapor_dovizi), ''),
                                          nullif(btrim(b.belge_dovizi), ''), 'TL') as cins) ekstre,
                         (select coalesce(nullif(btrim(b.rapor_dovizi), ''),
                                          nullif(btrim(b.belge_dovizi), ''), 'TL') as cins) rapor
              ) d
             where b.id = @p3
            """, islem,
            (short)tur);
        // IADEDE YON TERS: satis iadesi cariyi ALACAKLANDIRIR (132).
        komut.Parameters.AddWithValue("p1", BelgeTuru.CikisMi(tur, tipi));
        komut.Parameters.AddWithValue("p2", baglam.KullaniciId);
        komut.Parameters.AddWithValue("p3", belgeId);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private async Task NumaraVerAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, int tur, string seri, int? subeId, CancellationToken iptal)
    {
        // Numara sablonu (152) BELGE TARIHINE gore secilir: "1 Eylul'den itibaren
        //   B- serisi" denince Agustos tarihli belge eski seriyi korumali. Tarih
        //   belgenin kendisinden okunur - cagiran ayrica tasimasin.
        await using var komut = baglanti.Komut("""
            update public.belge
               set belge_no = public.fn_belge_no_uret(@p1, @p2, @p3, 9, belge_tarihi::date)
             where id = @p0 and coalesce(belge_no, '') = ''
            """, islem,
            belgeId, tur, seri ?? "", subeId ?? 0);
        await komut.ExecuteNonQueryAsync(iptal);

        // Numara belgeye yazildi; mali_hareket satirindaki kopyasi da guncellenir.
        await using var komut2 = baglanti.Komut("""
            update public.mali_hareket m
               set belge_no = b.belge_no
              from public.belge b
             where b.id = m.belge_id and m.belge_id = @p0
            """, islem,
            belgeId);
        await komut2.ExecuteNonQueryAsync(iptal);
    }

    // ================================================================ yardimci ====
}
