namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// İŞYERİ HEKİMLİĞİ (741) kartları: firma (+ bölümler), çalışan (+ aşılar;
/// özel modal ayrıca), Ek-2 muayene (kanaat elle de yazılabilir), ziyaret,
/// olay. Log tablo kodları 1200 bloğu.
/// </summary>
public static partial class KartKatalogu
{
    // 1300-1303 (757): ISG modulu (741) eczanenin 1200-1206 blogunun
    //   ustune oturmustu - ayni numarayi iki modul paylasiyordu.
    private const int LogIsgFirma   = 1300;
    private const int LogIsgBolum   = 1301;
    private const int LogIsgCalisan = 1310;
    private const int LogIsgAsi     = 1302;
    // 1299 (757): 1204 eczane imhasinin.
    private const int LogIsgMuayene = 1299;
    private const int LogIsgZiyaret = 1311;
    private const int LogIsgOlay    = 1303;

    private static readonly Dictionary<string, string> IsgAktifKodlari = new() { ["1"] = "Aktif", ["0"] = "Pasif" };
    private static readonly Dictionary<string, string> IsgCalisanDurum = new() { ["1"] = "Aktif", ["0"] = "Ayrıldı" };
    private static readonly Dictionary<string, string> IsgMuayeneDurum = new() { ["1"] = "Açık", ["2"] = "Tamamlandı", ["3"] = "İptal" };
    private static readonly Dictionary<string, string> IsgOlayDurum = new() { ["1"] = "Açık", ["2"] = "Kapandı" };

    private static KartTanimi IsgFirmaKarti() => new(
        Ad: "isg-firma",
        YetkiKodu: "isg.firma",
        Tablo: "public.isg_firma",
        LogTabloId: LogIsgFirma,
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.isg_calisan", "firma_id", "Firmanın çalışanı var; önce çalışanları ayırın ya da firmayı pasife alın."),
            new("public.isg_ziyaret", "firma_id", "Firmanın ziyaret kaydı var; silinemez, pasife alın."),
            new("public.isg_olay", "firma_id", "Firmanın olay kaydı var; silinemez, pasife alın."),
        },
        AcilistaTarafSecimi: "tarafId",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tehlike"] = (short)2, ["calisma"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",             "id",              "sayi",  Yazilabilir: false),
            new("tarafId",        "taraf_id",        "kod",   Zorunlu: true, KodTablosu: "public.v_isg_isveren_lookup", AramaKaynagi: "kurum", Baslik: "İşveren (anlaşmalı kurum)", Grup: "Firma"),
            new("sgkSicil",       "sgk_sicil",       "metin", EnFazlaUzunluk: 30, Baslik: "SGK işyeri sicil", Grup: "Firma"),
            new("nace",           "nace",            "metin", EnFazlaUzunluk: 12, Baslik: "NACE kodu", Grup: "Firma"),
            new("naceAd",         "nace_ad",         "metin", EnFazlaUzunluk: 150, Baslik: "NACE açıklaması", Grup: "Firma"),
            new("tehlike",        "tehlike",         "kod",   Zorunlu: true, KodListesi: "isg.tehlike", Baslik: "Tehlike sınıfı", Grup: "Firma"),
            new("calisanSayisi",  "calisan_sayisi",  "sayi",  Baslik: "Çalışan sayısı (beyan)", Grup: "Firma"),
            new("calisma",        "calisma",         "kod",   KodListesi: "isg.calisma", Baslik: "Çalışma şekli", Grup: "Firma"),
            new("geceCalisan",    "gece_calisan",    "sayi",  Baslik: "Gece çalışanı sayısı", Grup: "Firma"),
            new("isgKurulu",      "isg_kurulu",      "mantik", Baslik: "İSG kurulu var (50+)", Grup: "Firma"),
            new("durum",          "durum",           "kod",   SabitKodlar: IsgAktifKodlari, Baslik: "Durum", Grup: "Firma"),
            new("hekimId",        "hekim_id",        "kod",   KodTablosu: "public.v_hekim_lookup", Baslik: "İşyeri hekimi", Grup: "Atama & Sözleşme"),
            new("isgUzmanId",     "isg_uzman_id",    "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "İSG uzmanı", Grup: "Atama & Sözleşme"),
            new("dspId",          "dsp_id",          "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Diğer sağlık personeli (DSP)", Grup: "Atama & Sözleşme"),
            new("aylikDk",        "aylik_dk",        "sayi",  Baslik: "Sözleşme dakikası / ay (0 = çalışan × katsayı)", Grup: "Atama & Sözleşme"),
            new("sozlesmeBas",    "sozlesme_bas",    "tarih", Baslik: "Sözleşme başlangıç", Grup: "Atama & Sözleşme"),
            new("sozlesmeBit",    "sozlesme_bit",    "tarih", Baslik: "Sözleşme bitiş", Grup: "Atama & Sözleşme"),
            new("ziyaretSikligi", "ziyaret_sikligi", "metin", EnFazlaUzunluk: 80, Baslik: "Ziyaret sıklığı", Grup: "Atama & Sözleşme"),
            new("yetkili",        "yetkili",         "metin", EnFazlaUzunluk: 120, Baslik: "İşveren yetkilisi", Grup: "İletişim"),
            new("yetkiliTel",     "yetkili_tel",     "metin", EnFazlaUzunluk: 30, Baslik: "Yetkili telefon", Grup: "İletişim"),
            new("adres",          "adres",           "metin", EnFazlaUzunluk: 300, Baslik: "İşyeri adresi", Grup: "İletişim"),
            new("aciklama",       "aciklama",        "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "İletişim"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("bolumler", "public.isg_firma_bolum", "firma_id", new KartAlani[]
            {
                new("id",            "id",             "sayi",  Yazilabilir: false),
                new("ad",            "ad",             "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Bölüm"),
                new("calisanSayisi", "calisan_sayisi", "sayi",  Baslik: "Çalışan"),
                new("maruziyet",     "maruziyet",      "json",  EnFazlaUzunluk: 200, Baslik: "Maruziyet kodları (JSON dizi, isg.maruziyet)"),
                new("tetkikPaketi",  "tetkik_paketi",  "metin", EnFazlaUzunluk: 300, Baslik: "Tetkik paketi"),
                new("periyotAy",     "periyot_ay",     "sayi",  Baslik: "Periyot (ay, 0 = sınıf)"),
                new("aciklama",      "aciklama",       "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
            }, Sirala: "ad", Baslik: "Bölümler ve maruziyetler", LogTabloId: LogIsgBolum),
        });

    private static KartTanimi IsgCalisanKarti() => new(
        Ad: "isg-calisan",
        YetkiKodu: "isg.calisan",
        Tablo: "public.isg_calisan",
        LogTabloId: LogIsgCalisan,
        SubeKolonu: "sube_id",
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.isg_muayene", "calisan_id", "Çalışanın muayene kaydı var; silinmez - 'Ayrıldı' yapın (sağlık gözetimi dosyası 15 yıl saklanır)."),
            new("public.isg_olay", "calisan_id", "Çalışanın olay kaydı var; silinmez."),
        },
        AcilistaTarafSecimi: "hastaId",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["calisma"] = (short)1, ["durum"] = (short)1, ["iseGiris"] = "@simdi" },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",            "sayi",  Yazilabilir: false),
            new("hastaId",      "hasta_id",      "kod",   Zorunlu: true, KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Çalışan (hasta kaydı)", Grup: "Kimlik"),
            new("firmaId",      "firma_id",      "kod",   Zorunlu: true, KodTablosu: "public.v_isg_firma_lookup", Baslik: "Firma", Grup: "Kimlik"),
            new("bolumId",      "bolum_id",      "kod",   KodTablosu: "public.v_isg_bolum_lookup", BagliAlan: "firmaId", Baslik: "Bölüm", Grup: "Kimlik"),
            new("gorev",        "gorev",         "metin", EnFazlaUzunluk: 80, Baslik: "Görev", Grup: "Kimlik"),
            new("iseGiris",     "ise_giris",     "tarih", Baslik: "İşe giriş", Grup: "Kimlik"),
            new("istenAyrilis", "isten_ayrilis", "tarih", Baslik: "İşten ayrılış", Grup: "Kimlik"),
            new("calisma",      "calisma",       "kod",   KodListesi: "isg.calisma", Baslik: "Çalışma şekli", Grup: "Kimlik"),
            new("durum",        "durum",         "kod",   SabitKodlar: IsgCalisanDurum, Baslik: "Durum", Grup: "Kimlik"),
            new("maruziyet",    "maruziyet",     "json",  EnFazlaUzunluk: 200, Baslik: "Kişiye özel maruziyet (JSON dizi, isg.maruziyet)", Grup: "Maruziyet"),
            new("kkd",          "kkd",           "metin", EnFazlaUzunluk: 200, Baslik: "Kullanılan KKD", Grup: "Maruziyet"),
            new("periyotAy",    "periyot_ay",    "sayi",  Baslik: "Periyot kısaltması (ay, 0 = kural)", Grup: "Maruziyet"),
            new("meslekOykusu", "meslek_oykusu", "metin", EnFazlaUzunluk: 600, Baslik: "Meslek öyküsü (önceki işyerleri, maruziyet)", Grup: "Öykü"),
            new("egitim",       "egitim",        "metin", EnFazlaUzunluk: 40, Baslik: "Eğitim", Grup: "Öykü"),
            new("rizaTarihi",   "riza_tarihi",   "tarih", Baslik: "KVKK açık rıza tarihi", Grup: "Öykü"),
            new("aciklama",     "aciklama",      "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Öykü"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("asilar", "public.isg_asi", "calisan_id", new KartAlani[]
            {
                new("id",       "id",       "sayi",  Yazilabilir: false),
                new("asi",      "asi",      "kod",   Zorunlu: true, KodListesi: "isg.asi", Baslik: "Aşı"),
                new("doz",      "doz",      "metin", EnFazlaUzunluk: 20, Baslik: "Doz"),
                new("tarih",    "tarih",    "tarih", Zorunlu: true, Baslik: "Tarih"),
                new("sonraki",  "sonraki",  "tarih", Baslik: "Sonraki doz"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, Sirala: "tarih desc", Baslik: "Aşılar", LogTabloId: LogIsgAsi),
        });

    private static KartTanimi IsgMuayeneKarti() => new(
        Ad: "isg-muayene",
        YetkiKodu: "isg.muayene",
        Tablo: "public.isg_muayene",
        LogTabloId: LogIsgMuayene,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)2, ["tarih"] = "@simdi", ["durum"] = (short)1, ["sureDk"] = (short)15 },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",               "sayi",  Yazilabilir: false),
            new("calisanId",       "calisan_id",       "kod",   Zorunlu: true, KodTablosu: "public.v_isg_calisan_lookup", Baslik: "Çalışan", Grup: "Muayene"),
            new("tur",             "tur",              "kod",   Zorunlu: true, KodListesi: "isg.muayene_tur", Baslik: "Muayene türü", Grup: "Muayene"),
            new("tarih",           "tarih",            "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Muayene"),
            new("hekimId",         "hekim_id",         "kod",   KodTablosu: "public.v_hekim_lookup", Baslik: "İşyeri hekimi", Grup: "Muayene"),
            new("sureDk",          "sure_dk",          "sayi",  Baslik: "Süre (dk, İSG-KATİP)", Grup: "Muayene"),
            new("formIstekId",     "form_istek_id",    "sayi",  Yazilabilir: false, Baslik: "Ek-2 form isteği", Grup: "Muayene"),
            new("durum",           "durum",            "kod",   SabitKodlar: IsgMuayeneDurum, Baslik: "Durum", Grup: "Muayene"),
            new("kanaat",          "kanaat",           "kod",   KodListesi: "isg.kanaat", Baslik: "Kanaat", Grup: "Kanaat"),
            new("kosul",           "kosul",            "metin", EnFazlaUzunluk: 400, Baslik: "Koşul / öneri", Grup: "Kanaat"),
            new("tani",            "tani",             "metin", EnFazlaUzunluk: 200, Baslik: "Tanı (ICD)", Grup: "Kanaat"),
            new("sevk",            "sevk",             "mantik", Baslik: "SGK sağlık kurulu sevki", Grup: "Kanaat"),
            new("sonrakiTarih",    "sonraki_tarih",    "tarih", Baslik: "Sonraki muayene", Grup: "Kanaat"),
            new("isverenBildirim", "isveren_bildirim", "tarih", Baslik: "İşverene yazılı bildirim", Grup: "Kanaat"),
            new("tetkikOzet",      "tetkik_ozet",      "metin", EnFazlaUzunluk: 400, Baslik: "Tetkik özeti", Grup: "Kanaat"),
            new("aciklama",        "aciklama",         "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Kanaat"),
        });

    private static KartTanimi IsgZiyaretKarti() => new(
        Ad: "isg-ziyaret",
        YetkiKodu: "isg.ziyaret",
        Tablo: "public.isg_ziyaret",
        LogTabloId: LogIsgZiyaret,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["tarih"] = "@simdi" },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",              "sayi",  Yazilabilir: false),
            new("firmaId",         "firma_id",        "kod",   Zorunlu: true, KodTablosu: "public.v_isg_firma_lookup", Baslik: "Firma", Grup: "Ziyaret"),
            new("tarih",           "tarih",           "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Ziyaret"),
            new("saatBas",         "saat_bas",        "metin", EnFazlaUzunluk: 5, Baslik: "Başlangıç (HH:MM)", Grup: "Ziyaret"),
            new("saatBit",         "saat_bit",        "metin", EnFazlaUzunluk: 5, Baslik: "Bitiş (HH:MM)", Grup: "Ziyaret"),
            new("sureDk",          "sure_dk",         "sayi",  Baslik: "Süre (dk) → İSG-KATİP", Grup: "Ziyaret"),
            new("tur",             "tur",             "kod",   Zorunlu: true, KodListesi: "isg.ziyaret_tur", Baslik: "Tür", Grup: "Ziyaret"),
            new("hekimId",         "hekim_id",        "kod",   KodTablosu: "public.v_hekim_lookup", Baslik: "İşyeri hekimi", Grup: "Ziyaret"),
            new("katilanlar",      "katilanlar",      "metin", EnFazlaUzunluk: 300, Baslik: "Katılanlar", Grup: "Ziyaret"),
            new("bolumler",        "bolumler",        "metin", EnFazlaUzunluk: 300, Baslik: "Gezilen bölümler", Grup: "Ziyaret"),
            new("gozlem",          "gozlem",          "metin", EnFazlaUzunluk: 2000, Baslik: "Gözlemler", Grup: "Tespit & Öneri"),
            new("oneri",           "oneri",           "metin", EnFazlaUzunluk: 2000, Baslik: "Öneriler (onaylı deftere yazılan)", Grup: "Tespit & Öneri"),
            new("termin",          "termin",          "tarih", Baslik: "Termin", Grup: "Tespit & Öneri"),
            new("sorumlu",         "sorumlu",         "metin", EnFazlaUzunluk: 120, Baslik: "Sorumlu", Grup: "Tespit & Öneri"),
            new("egitim",          "egitim",          "metin", EnFazlaUzunluk: 200, Baslik: "Verilen eğitim (konu · kişi · dk)", Grup: "Tespit & Öneri"),
            new("defterSayfa",     "defter_sayfa",    "metin", EnFazlaUzunluk: 20, Baslik: "Onaylı defter sayfa no", Grup: "İmza"),
            new("imzaHekim",       "imza_hekim",      "mantik", Baslik: "İşyeri hekimi imzaladı", Grup: "İmza"),
            new("imzaUzman",       "imza_uzman",      "mantik", Baslik: "İSG uzmanı imzaladı", Grup: "İmza"),
            new("imzaIsveren",     "imza_isveren",    "mantik", Baslik: "İşveren vekili imzaladı", Grup: "İmza"),
            new("sonrakiZiyaret",  "sonraki_ziyaret", "tarih", Baslik: "Sonraki ziyaret", Grup: "İmza"),
            new("aciklama",        "aciklama",        "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "İmza"),
        });

    private static KartTanimi IsgOlayKarti() => new(
        Ad: "isg-olay",
        YetkiKodu: "isg.olay",
        Tablo: "public.isg_olay",
        LogTabloId: LogIsgOlay,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["tarih"] = "@simdi", ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",                 "id",                   "sayi",  Yazilabilir: false),
            new("firmaId",            "firma_id",             "kod",   Zorunlu: true, KodTablosu: "public.v_isg_firma_lookup", Baslik: "Firma", Grup: "Olay"),
            new("calisanId",          "calisan_id",           "kod",   KodTablosu: "public.v_isg_calisan_lookup", BagliAlan: "firmaId", Baslik: "Çalışan", Grup: "Olay"),
            new("tur",                "tur",                  "kod",   Zorunlu: true, KodListesi: "isg.olay_tur", Baslik: "Olay türü", Grup: "Olay"),
            new("tarih",              "tarih",                "zaman", Zorunlu: true, Baslik: "Tarih / saat", Grup: "Olay"),
            new("yer",                "yer",                  "metin", EnFazlaUzunluk: 120, Baslik: "Yer", Grup: "Olay"),
            new("aciklama",           "aciklama",             "metin", EnFazlaUzunluk: 1000, Baslik: "Olayın tanımı", Grup: "Olay"),
            new("yaralanma",          "yaralanma",            "metin", EnFazlaUzunluk: 200, Baslik: "Yaralanma / bulgu", Grup: "Olay"),
            new("ilkMudahale",        "ilk_mudahale",         "metin", EnFazlaUzunluk: 300, Baslik: "İlk müdahale / sevk", Grup: "Olay"),
            new("gunKaybi",           "gun_kaybi",            "sayi",  Baslik: "Gün kaybı (rapor)", Grup: "Olay"),
            new("taniklar",           "taniklar",             "metin", EnFazlaUzunluk: 200, Baslik: "Tanıklar", Grup: "Olay"),
            new("sgkBildirim",        "sgk_bildirim",         "tarih", Baslik: "SGK bildirim tarihi (3 iş günü)", Grup: "Bildirim & Kök neden"),
            new("kokNeden",           "kok_neden",            "metin", EnFazlaUzunluk: 600, Baslik: "Kök neden (hekim görüşü)", Grup: "Bildirim & Kök neden"),
            new("duzeltici",          "duzeltici",            "metin", EnFazlaUzunluk: 600, Baslik: "Düzeltici faaliyet", Grup: "Bildirim & Kök neden"),
            new("iseDonusMuayeneId",  "ise_donus_muayene_id", "sayi",  Yazilabilir: false, Baslik: "İşe dönüş muayenesi", Grup: "Bildirim & Kök neden"),
            new("durum",              "durum",                "kod",   SabitKodlar: IsgOlayDurum, Baslik: "Durum", Grup: "Bildirim & Kök neden"),
        });
}
