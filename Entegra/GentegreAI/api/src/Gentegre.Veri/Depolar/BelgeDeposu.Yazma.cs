using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

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
        ["kdvDurum"] = "kdv_durum", ["belgeDovizi"] = "belge_dovizi",
        ["dovizCinsi"] = "doviz_cinsi", ["dovizKuru"] = "doviz_kuru", ["kur"] = "kur",
        ["raporDovizi"] = "rapor_dovizi", ["ekstreDovizi"] = "ekstre_dovizi",
        ["vadeGun"] = "vade_gun", ["durum"] = "durum",
        ["aciklama"] = "aciklama", ["ozelKod"] = "ozel_kod", ["senaryo"] = "senaryo",
        ["gondericiUnvan"] = "gonderici_unvan", ["gondericiVkno"] = "gonderici_vkno",
        ["gondericiAlias"] = "gonderici_alias", ["saticiId"] = "satici_id",
        // Irsaliye karti (088): sevk bilgileri
        ["teslimSekli"] = "teslim_sekli", ["merkezId"] = "merkez_id",
        // 089 sevkiyat alanlari (e-Irsaliye UBL: plaka + sofor zorunlu)
        ["aracPlaka"] = "arac_plaka", ["soforAd"] = "sofor_ad", ["soforTckn"] = "sofor_tckn",
        ["tasiyiciId"] = "tasiyici_id", ["teslimEdenId"] = "teslim_eden_id",
        ["teslimAlanId"] = "teslim_alan_id"
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
            // Donusum bagi (F8): kaynak_tur=30 -> kaynak belge_satir. Kapatma
            //   sayacini bu iki alan uzerinden DB trigger'i surer.
            "kaynak_tur", "kaynak_id", "proje_id",
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
            (short)(turStokEtkiler ? JsonSayi(satir, "stokDurumDegis", 1) : 0),
            (int)JsonSayi(satir, "kaynakTur", 0), JsonSayi(satir, "kaynakId", 0),
            JsonSayiNull(satir, "projeId") ?? SayiNull(belge, "projeId"),
            (short)(baglam.SubeId ?? 0), baglam.KullaniciId
        };

        var yerTutucular = Enumerable.Range(0, parametreler.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));
        var sql = $"insert into public.belge_satir ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)}) returning id";

        int satirId;
        await using (var komut = Komut(baglanti, islem, sql, parametreler))
            satirId = Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));

        // Lot / seri izlemi: stok izlemliyse satirin miktari lotlara dagitilir.
        if (stokId is { } sid)
            await IzlemYazAsync(baglanti, islem, belgeId, satirId, sid, sira,
                                Sayi(belge, "tur"), adet, satir, belge, turStokEtkiler,
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
        await using var komut = new NpgsqlCommand("""
            insert into public.mali_hareket
                (tur, hesap_turu, taraf_id, belge_id, belge_no, islem_tarihi,
                 borc, alacak, yerel_borc, yerel_alacak,
                 doviz_cinsi, doviz_kuru, aciklama, sube_id, ekleyen)
            select @p0, 'C', b.taraf_id, b.id, b.belge_no, b.belge_tarihi,
                   case when @p1 then coalesce(nullif(b.doviz_tutari, 0), b.genel_toplam) else 0 end,
                   case when @p1 then 0 else coalesce(nullif(b.doviz_tutari, 0), b.genel_toplam) end,
                   case when @p1 then b.genel_toplam else 0 end,
                   case when @p1 then 0 else b.genel_toplam end,
                   -- EKSTRE DOVIZI (134): cari hesaba hangi dovizde islenecek.
                   --   Bos ise belgenin kendi dovizi kullanilir.
                   coalesce(nullif(btrim(b.ekstre_dovizi), ''),
                            nullif(btrim(b.belge_dovizi), ''), 'TL'),
                   case when coalesce(b.doviz_kuru, 0) > 0 then b.doviz_kuru else 1 end,
                   b.taraf_unvan, b.sube_id, @p2
              from public.belge b where b.id = @p3
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", (short)tur);
        // IADEDE YON TERS: satis iadesi cariyi ALACAKLANDIRIR (132).
        komut.Parameters.AddWithValue("p1", BelgeTuru.CikisMi(tur, tipi));
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
}
