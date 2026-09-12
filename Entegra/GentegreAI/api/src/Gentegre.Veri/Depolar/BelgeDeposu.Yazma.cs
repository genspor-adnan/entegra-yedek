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
        ["aciklama"] = "aciklama", ["ozelKod"] = "ozel_kod", ["senaryo"] = "senaryo",
        ["gondericiUnvan"] = "gonderici_unvan", ["gondericiVkno"] = "gonderici_vkno",
        ["gondericiAlias"] = "gonderici_alias", ["saticiId"] = "satici_id",
        ["merkezId"] = "merkez_id",
        // KAYNAK BAGI (429): belgeyi ureten kaydi gosterir (uretim emri icin
        //   kaynak_tur = 60, kaynak_id = emir). SUNUCU ICI cagrilar icindir -
        //   belge ucunun kendi beyaz listesinde (BelgeUclari.BaslikTipi) YOK,
        //   yani istemci bu alanlari gonderemez; gonderse "bilinmeyen belge
        //   alani" ile reddedilir. Donusum bagi (kaynak_tur = 30) yine
        //   donusum kodunda yazilir, buradan gelmez.
        ["kaynakTur"] = "kaynak_tur", ["kaynakId"] = "kaynak_id"
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
    /// BASVURU UZANTISI (296) alanlari - belge_basvuru 1:1. Basvuruya ozgu
    /// alanlar ana belge tablosunu sismesin diye burada; liste ZAMANLA
    /// BUYUYECEK (kullanici), yeni alan eklemek icin tek satir yeter.
    /// </summary>
    private static readonly Dictionary<string, string> BasvuruKolonlari = new(StringComparer.Ordinal)
    {
        ["bolumId"] = "bolum_id", ["personelId"] = "personel_id",
        // Odeyen kurum (289) da basvuruya ozgu - 296 ile buraya tasindi.
        ["odeyenKurumId"] = "odeyen_kurum_id",
        // SOZLESME / ALT KURUM / SGK KATKISI (469): odeme rotasini bunlar
        //   belirler. Tek sozlesme varsa DB tetigi kendisi atar; birden
        //   fazlaysa secilmeden kayit kabul edilmez.
        ["sozlesmeId"] = "sozlesme_id", ["altKurum"] = "alt_kurum",
        ["sgkKullan"] = "sgk_kullan",
        // EMEKLI (590): SGK katilim payi emekliden alinmaz - maasindan
        //   kesiliyor. Basvurunun kendi bilgisi: ayni hasta bir basvuruda
        //   emekli, oncekinde calisan olabilir.
        ["emekli"] = "emekli",
        // Basvuru sekmesi (298): kayit kabulun doldurdugu alanlar.
        ["basvuruTuru"] = "basvuru_turu", ["gelisSekli"] = "gelis_sekli",
        ["gelisNedeni"] = "gelis_nedeni", ["oda"] = "oda", ["siraNo"] = "sira_no",
        ["refakatci"] = "refakatci",
        // Ambulans (300): 112 kayit no + acilde takilan bileklik no. Odeyiciye
        // degil HASTAYA ait bilgi oldugu icin provizyonda degil burada.
        ["ambulansHastaNo"] = "ambulans_hasta_no",
        ["ambulansBileklikNo"] = "ambulans_bileklik_no",
        // KENDI ISTEGI (370): gonderen hekim YOK ama bu bir eksiklik degil,
        //   bir SECIM - zorunluluk "personelId dolu VEYA kendiIstegi = 1"
        //   ile karsilanir.
        ["kendiIstegi"] = "kendi_istegi"
    };

    /// <summary>
    /// 1:1 UZANTI SATIRI yazar (upsert). Belge basliginin yanindaki uzantilar
    /// - sevkiyat (177), basvuru (296), provizyon (299) - ayni kurali paylasir:
    ///
    ///   * Istekte o gruba ait HIC alan yoksa dokunulmaz (kismi guncelleme).
    ///   * Butun alanlar bosaltilmissa satir SILINIR - bos uzanti "bilgi
    ///     girilmis" izlenimi verir ve her belge icin gereksiz kayit yaratirdi.
    ///   * Aksi halde insert ... on conflict (id) do update.
    ///
    /// Uc ayri kopya yerine tek yer: yeni bir uzanti eklemek artik sozluk +
    /// tablo adi vermekten ibaret.
    /// </summary>
    private async Task UzantiYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        string tablo, IReadOnlyDictionary<string, string> alanlar,
        int belgeId, IDictionary<string, object?> belge, YazmaBaglami baglam,
        CancellationToken iptal)
    {
        var kolonlar = new List<string>();
        var degerler = new List<object?>();
        var doluVar = false;

        foreach (var (ad, kolon) in alanlar)
        {
            if (!belge.TryGetValue(ad, out var deger)) continue;
            kolonlar.Add(kolon);
            degerler.Add(deger);
            // "Bu gruba ait dolu alan var mi" - hepsi bossa uzanti satiri
            //   SILINIR. Kontrol sayisal alanlar icin 0'i bos sayar.
            //   TARIH ve MANTIK degerleri sayiya CEVRILEMEZ: `Convert.ToDecimal`
            //   bir DateTime gorunce "Invalid cast from 'DateTime' to 'Decimal'"
            //   atiyordu - provizyon tarihi girilen her ÖSS/SGK basvurusu 500
            //   veriyordu (gercek vaka). Boyle bir deger VARSA doludur.
            doluVar |= deger switch
            {
                null => false,
                string m => m.Trim().Length > 0,
                DateTime or DateTimeOffset or bool => true,
                _ => Convert.ToDecimal(deger, CultureInfo.InvariantCulture) != 0,
            };
        }

        if (kolonlar.Count == 0) return;               // istekte bu gruba ait alan yok

        if (!doluVar)
        {
            await using var sil = baglanti.Komut(
                $"delete from {tablo} where id = @p0", islem, belgeId);
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

        var sql = $"insert into {tablo} (id, {string.Join(", ", kolonlar)}, ekleyen) "
                + $"values (@p0, {string.Join(", ", yerTutucular)}, {kullanici}) "
                + "on conflict (id) do update "
                + $"   set {string.Join(", ", guncelle)}, "
                + $"       degistiren = {kullanici}, "
                + "       degistirme_tarihi = now()::timestamp";

        await using var komut = Komut(baglanti, islem, sql, parametreler);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    /// <summary>
    /// PROVIZYON (299) alanlari - belge_provizyon 1:1. SGK ve ozel sigorta
    /// AYNI ANDA alinabilir (hasta hem SGK'li hem tamamlayici policeli
    /// olabilir), o yuzden iki ayri alan takimi: sgk_* ve oss_*.
    ///
    /// Provizyon/takip TARIHLERI elle girilebilir: MEDULA baglanana kadar
    /// kayit kabul bunlari kendisi yazar, servis geldiginde uzerine yazacak.
    /// Yalnizca mustehaklik SORGU zamani (servis damgasi) istekten gelmez.
    /// </summary>
    private static readonly Dictionary<string, string> ProvizyonKolonlari = new(StringComparer.Ordinal)
    {
        // SGK / MEDULA
        ["sgkDurum"] = "sgk_durum", ["sgkProvizyonNo"] = "sgk_provizyon_no",
        ["sgkProvizyonTipi"] = "sgk_provizyon_tipi",
        ["sgkProvizyonTarihi"] = "sgk_provizyon_tarihi",
        ["sgkGecerlilik"] = "sgk_gecerlilik",
        ["sgkKarsilama"] = "sgk_karsilama", ["sgkTutar"] = "sgk_tutar",
        ["sgkRedNedeni"] = "sgk_red_nedeni", ["sgkSigortaTuru"] = "sgk_sigorta_turu",
        // Basvuru (muracaat) no ile takip no FARKLI numaralardir; faturalama
        // takip numarasi uzerinden yapilir (300).
        ["sgkBasvuruNo"] = "sgk_basvuru_no",
        ["sgkTakipNo"] = "sgk_takip_no", ["sgkTakipTarihi"] = "sgk_takip_tarihi",
        ["sgkTakipTuru"] = "sgk_takip_turu",
        ["sgkTesisKodu"] = "sgk_tesis_kodu", ["sgkMustehaklik"] = "sgk_mustehaklik",
        ["sgkSevkli"] = "sgk_sevkli", ["sgkSevkKurum"] = "sgk_sevk_kurum",
        // Ozel / tamamlayici saglik sigortasi
        ["ossKurumId"] = "oss_kurum_id", ["ossDurum"] = "oss_durum",
        ["ossProvizyonNo"] = "oss_provizyon_no",
        ["ossProvizyonTarihi"] = "oss_provizyon_tarihi",
        ["ossGecerlilik"] = "oss_gecerlilik",
        ["ossKarsilama"] = "oss_karsilama", ["ossTutar"] = "oss_tutar",
        ["ossRedNedeni"] = "oss_red_nedeni", ["ossPoliceNo"] = "oss_police_no",
        ["ossHasarNo"] = "oss_hasar_no", ["ossBrans"] = "oss_brans",
        ["provizyonAciklama"] = "aciklama"
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

        // KDV DAHIL BIRIM FIYAT (371). HBYS'de fiyat HEP KDV DAHIL konusulur
        //   (hastaya soylenen rakam odur), muhasebe MATRAH ister. Ikisi
        //   arasinda her seferinde gidip gelmek KAYIPLI - 100,00 brut / %18
        //   matraha inip geri cikinca 100,0050 oluyor. Bu yuzden brut de
        //   SAKLANIR ve GIRIS DEGERI odur:
        //     brut verildiyse  -> matrah ONDAN turetilir (tek yon, kayipsiz)
        //     brut verilmediyse-> matrahtan bir kez uretilir (ERP akisi)
        //   Boylece iki kolon her zaman ayni parayi soyler; DB kisiti da
        //   (ck_belge_satir_kdvli_tutarli) bunu bir kurus icinde tutar.
        var kdvCarpani = 1m + kdv / 100m;
        var birimFiyatKdvli = JsonOndalik(satir, "birimFiyatKdvli", 0);
        if (birimFiyatKdvli > 0)
            birimFiyat = Math.Round(birimFiyatKdvli / kdvCarpani, 4,
                                    MidpointRounding.AwayFromZero);
        else if (birimFiyat != 0)
            birimFiyatKdvli = Math.Round(birimFiyat * kdvCarpani, 4,
                                         MidpointRounding.AwayFromZero);

        // TUTAR: Delphi formulu birebir (ic yuvarlama + carpimsal iskonto + banker's).
        var tutar      = BelgeHesap.SatirTutari(adet, birimFiyat, iskonto, iskonto2);
        var dovizTutar = BelgeHesap.SatirTutari(adet, dovizBirimFiyat, iskonto, iskonto2);
        // BRUT SATIR TUTARI (372) matrahla AYNI formulden gecer: dip toplam
        //   KDV'yi "brut tutar - matrah tutar" olarak aliyor, iki tarafin da
        //   ayni yuvarlamayi gormesi gerek.
        var tutarKdvli = birimFiyatKdvli > 0
            ? BelgeHesap.SatirTutari(adet, birimFiyatKdvli, iskonto, iskonto2) : 0m;

        // ODEME DAGILIMI ARTIK AYRI TABLODA (470/478): satir yazildiktan
        //   sonra `DagilimYazAsync` calisir - istemci acik kova gonderdiyse
        //   elle sabitlenir, aksi halde sozlesmenin listelerinden hesaplanir.
        //   `belge_satir` uzerindeki kurum/hasta payi kolonlari DUSTU.

        var kolonlar = new List<string>
        {
            "belge_id", "sira", "tur", "stok_id", "hizmet_id", "masraf_id", "aciklama",
            "adet", "miktar", "birim", "birim_carpan", "birim_fiyat",
            // KDV DAHIL birim fiyat (371) - ekranda gosterilen ve hastaya
            //   soylenen rakam; matrah bundan turetilir.
            "birim_fiyat_kdvli", "iskonto", "iskonto2", "kdv",
            "otv_yuzde", "otv_miktar", "kdv_muafiyeti", "tutar",
            // KDV dahil satir tutari (372) - belge toplaminin dayanagi.
            "tutar_kdvli",
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
            // Hedef satirda hangi kovayi kapattigi (470) + provizyon numarasi.
            "provizyon_no", "pay",
            // CINSIYET/YAS KURALI GEREKCEYLE asildiysa sebebi (482): bos ise
            //   kural uygulanmistir. Yetki kontrolu ucda, iz burada.
            "uygunluk_notu",
            "sube_id", "ekleyen"
        };
        var parametreler = new List<object?>
        {
            belgeId, sira, tur, stokId, hizmetId, masrafId, JsonMetin(satir, "aciklama"),
            adet, miktar, (int)JsonSayi(satir, "birim", 0), birimCarpan,
            birimFiyat, birimFiyatKdvli, iskonto, iskonto2, (short)kdv,
            (short)JsonSayi(satir, "otvYuzde", 0), JsonOndalik(satir, "otvMiktar", 0),
            (short)JsonSayi(satir, "kdvMuafiyeti", 0), tutar, tutarKdvli,
            dovizCinsi, dovizBirimFiyat, dovizTutar, kur,
            JsonSayiNull(satir, "girisDepoId") ?? SayiNull(belge, "girisDepoId"),
            JsonSayiNull(satir, "cikisDepoId") ?? SayiNull(belge, "cikisDepoId"),
            (short)JsonSayi(satir, "izleme", 0), JsonMetin(satir, "izlemeKodu"),
            (short)(turStokEtkiler ? JsonSayi(satir, "stokDurumDegis", 1) : 0),
            (int)JsonSayi(satir, "kaynakTur", 0), JsonSayi(satir, "kaynakId", 0),
            JsonSayiNull(satir, "projeId") ?? SayiNull(belge, "projeId"),
            JsonTarih(satir, "teslimTarihi"),
            JsonSayiNull(satir, "kampanyaSatirId"),
            JsonMetin(satir, "provizyonNo"), (short)JsonSayi(satir, "pay", 0),
            JsonMetin(satir, "uygunlukNotu"),
            (short)baglam.SubeZorunlu(), baglam.KullaniciId
        };

        var yerTutucular = Enumerable.Range(0, parametreler.Count)
            .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));
        var sql = $"insert into public.belge_satir ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yerTutucular)}) returning id";

        int satirId;
        await using (var komut = Komut(baglanti, islem, sql, parametreler))
            satirId = Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));

        // ODEME DAGILIMI (470/472): bes kova ayri tabloda. Kural SUNUCUDA -
        //   istemci acik kova gondermediyse dagilim sozlesmenin listelerinden
        //   yeniden hesaplanir.
        await DagilimYazAsync(baglanti, islem, satirId, satir,
                              (short)JsonSayi(satir, "pay", 0), tutar, iptal);

        // Lot / seri izlemi: stok izlemliyse satirin miktari lotlara dagitilir.
        //   ANA BIRIM miktari (`miktar`) verilir - lot bakiyesi de stok bakiyesi
        //   gibi ana birimde tutulur; "2 kutu" degil "24 adet" dagitilir (143).
        if (stokId is { } sid)
            await IzlemYazAsync(baglanti, islem, belgeId, satirId, sid, sira,
                                Sayi(belge, "tur"), miktar, satir, belge, turStokEtkiler,
                                uyarilar, iptal);
    }

    /// <summary>
    /// Satirin ODEME DAGILIMI (470): bes kova.
    ///
    /// UC YOL, tek kural:
    ///  1. DONUSUM HEDEFI (pay > 0): satir zaten TEK payin belgesidir - tutarin
    ///     tamami o kovaya yazilir. Yeniden dagitmak, tahakkuku kendi kaynagina
    ///     gore ikinci kez bolerdi.
    ///  2. ISTEMCI ACIK KOVA GONDERDI: elle sabitlenir (`elle = 1`); fiyat
    ///     listesi degisse de dokunulmaz - kullanici bilerek yazmistir.
    ///  3. Aksi halde SUNUCU HESAPLAR: rota + sozlesmenin SUT/TTB listeleri.
    /// </summary>
    private async Task DagilimYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int satirId, Dictionary<string, JsonElement> satir, short pay, decimal tutar,
        CancellationToken iptal)
    {
        decimal? Kova(string ad)
        {
            var v = JsonOndalik(satir, ad, -1);
            return v < 0 ? null : v;
        }

        var sgk    = Kova("sgk");
        var oss    = Kova("oss");
        var hProv  = Kova("hastaProvizyon");
        var hEk    = Kova("hastaEkKatki");
        var katkı  = Kova("sgkKatilimPayi");
        var elleGeldi = sgk is not null || oss is not null || hProv is not null
                     || hEk is not null || katkı is not null;

        if (pay is >= 1 and <= 5)
        {
            // Hedef satir tek kovadir: hangi kova oldugunu `pay` soyler.
            sgk   = pay == 2 ? tutar : 0m;
            oss   = pay == 3 ? tutar : 0m;
            hProv = pay == 1 ? tutar : 0m;
            hEk   = pay == 4 ? tutar : 0m;
            katkı = pay == 5 ? tutar : (katkı ?? 0m);
            elleGeldi = true;
        }

        if (!elleGeldi)
        {
            // SUT / TARIFE BEDELI EKRANDAN (483): sozlesmenin listesi bos
            //   kalabiliyor - TSS'de "SUT 2026" listesinde satir yoksa SGK payi
            //   sessizce 0 cikiyor ve tutarin tamami sigortaya yaziliyordu.
            //   Kullanici bedeli ucret penceresinde girerse BURADAN gecer;
            //   kovalari yine rota kurali boler, istemci hesap yapmaz.
            var sgkListe = Kova("sgkListe");
            var huvListe = Kova("huvListe");
            // KATKI (KATILIM PAYI) EKRANDAN (586): ucret penceresindeki "Katkı
            //   Fiyatı" kutusu BIRIM basina tutar gonderir; miktar ve iskonto
            //   sunucuda islenir. TTB/SUT tarifesinde iskontonun tabani budur -
            //   kurumun odedigi SUT/tarife bedeli indirimden etkilenmez.
            var katki = Kova("katkiTutar");
            await using var tazele = Komut(baglanti, islem,
                "select public.fn_belge_satir_dagilim_tazele(@p0, null, null, @p1, @p2, @p3)",
                [satirId, sgkListe, huvListe, katki]);
            await tazele.ExecuteNonQueryAsync(iptal);
            return;
        }

        // Acik gelen kovalarin toplami satir tutarini tutmali: eksigi hasta ek
        //   katkisina yazmak, dengeyi bozmadan "artan hastanindir" kuralini
        //   uygular (DB tetigi zaten toplami dogruluyor).
        var toplam = (sgk ?? 0) + (oss ?? 0) + (hProv ?? 0) + (hEk ?? 0);
        if (Math.Abs(toplam - tutar) > 0.005m) hEk = (hEk ?? 0) + (tutar - toplam);

        await using var komut = Komut(baglanti, islem,
            "insert into public.belge_satir_dagilim " +
            "       (belge_satir_id, rota, sgk, oss, hasta_provizyon, hasta_ek_katki, " +
            "        sgk_katilim_payi, sgk_provizyon_no, elle, ekleyen) " +
            "values (@p0, coalesce((select public.fn_dagilim_rota(k.tur, bb.alt_kurum, " +
            "                              bb.sgk_kullan) " +
            "                         from public.belge_satir bs " +
            "                         join public.belge_basvuru bb on bb.id = bs.belge_id " +
            "                         join public.taraf_kurum k on k.id = bb.odeyen_kurum_id " +
            "                        where bs.id = @p0), 1), " +
            "        @p1, @p2, @p3, @p4, @p5, @p6, 1, @p7) " +
            "on conflict (belge_satir_id) do update " +
            "   set sgk = excluded.sgk, oss = excluded.oss, " +
            "       hasta_provizyon = excluded.hasta_provizyon, " +
            "       hasta_ek_katki = excluded.hasta_ek_katki, " +
            "       sgk_katilim_payi = excluded.sgk_katilim_payi, " +
            "       sgk_provizyon_no = excluded.sgk_provizyon_no, " +
            "       elle = 1, degistirme_tarihi = now()",
            [satirId, sgk ?? 0m, oss ?? 0m, hProv ?? 0m, hEk ?? 0m, katkı ?? 0m,
             JsonMetin(satir, "provizyonNo"), 0]);
        await komut.ExecuteNonQueryAsync(iptal);
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
                else
                    // RAPOR DOVIZI YEREL: ayri bir "doviz karsiligi" YOKTUR.
                    //   Dip toplamin doviz sutunu satirlarin doviz fiyatindan
                    //   hesaplanir; bir satirin doviz fiyati bayat kalirsa
                    //   (or. pay donusumu) buraya yanlis tutar sizip
                    //   mali_hareket.borc'u bozuyordu.
                    dovizGenel = 0m;
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
