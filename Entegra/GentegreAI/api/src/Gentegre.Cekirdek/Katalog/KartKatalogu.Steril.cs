namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// STERİLİZASYON (868) kartları: cihaz, program, set tanımı (alet listesi detay),
/// birim (fiziksel set / döner alet), bakım kaydı. Döngü / paket / kullanım
/// kayıtları özel uçlardan (SterilUclari) yazılır; listede salt okunur açılır.
/// Log tablo kodları 1340 bloğu.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogSterilCihaz     = 1340;
    private const int LogSterilProgram   = 1341;
    private const int LogSterilSet       = 1342;
    private const int LogSterilSetAlet   = 1343;
    private const int LogSterilBirim     = 1344;
    private const int LogSterilDongu     = 1345;
    private const int LogSterilPaket     = 1346;
    private const int LogSterilKullanim  = 1347;
    private const int LogSterilBakim     = 1348;
    private const int LogSterilGeriCagirma = 1349;

    private static readonly Dictionary<string, string> SterilAktifKodlari = new() { ["1"] = "Aktif", ["0"] = "Pasif" };
    private static readonly Dictionary<string, string> SterilCihazDurum = new() { ["1"] = "Aktif", ["2"] = "Bakım gerekli", ["0"] = "Pasif" };
    private static readonly Dictionary<string, string> SterilVeriBaglanti = new() { [""] = "Yok (elle)", ["usb"] = "USB / CF kart", ["rs232"] = "RS-232", ["ethernet"] = "Ethernet" };
    private static readonly Dictionary<string, string> SterilEvetHayir = new() { ["1"] = "Evet", ["0"] = "Hayır" };

    private static KartTanimi SterilCihazKarti() => new(
        Ad: "steril-cihaz",
        YetkiKodu: "steril.ayar",
        Tablo: "public.steril_cihaz",
        LogTabloId: LogSterilCihaz,
        SubeKolonu: "sube_id",
        SilmeEngelleri: new SilmeEngeli[] { new("public.steril_dongu", "cihaz_id", "Cihazın döngü kaydı var; silinemez, pasife alın.") },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["sinif"] = (short)1, ["durum"] = (short)1, ["bakimAy"] = (short)6, ["veriBaglanti"] = "" },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",             "sayi",  Yazilabilir: false),
            new("ad",            "ad",             "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Cihaz", Grup: "Cihaz"),
            new("tur",           "tur",            "kod",   Zorunlu: true, KodListesi: "steril.cihaz_tur", Baslik: "Tür", Grup: "Cihaz"),
            new("markaModel",    "marka_model",    "metin", EnFazlaUzunluk: 120, Baslik: "Marka / model", Grup: "Cihaz"),
            new("seriNo",        "seri_no",        "metin", EnFazlaUzunluk: 60, Baslik: "Seri no", Grup: "Cihaz"),
            new("sinif",         "sinif",          "kod",   KodListesi: "steril.otoklav_sinif", Baslik: "Otoklav sınıfı", Grup: "Cihaz"),
            new("kapasite",      "kapasite",       "metin", EnFazlaUzunluk: 40, Baslik: "Kapasite", Grup: "Cihaz"),
            new("veriBaglanti",  "veri_baglanti",  "kod",   SabitKodlar: SterilVeriBaglanti, Baslik: "Veri bağlantısı", Grup: "Cihaz"),
            new("konum",         "konum",          "metin", EnFazlaUzunluk: 80, Baslik: "Konum", Grup: "Cihaz"),
            new("sorumluId",     "sorumlu_id",     "kod",   KodTablosu: "public.v_personel_lookup", AramaKaynagi: "personel", Baslik: "Sorumlu", Grup: "Cihaz"),
            new("durum",         "durum",          "kod",   SabitKodlar: SterilCihazDurum, Baslik: "Durum", Grup: "Cihaz"),
            new("sayac",         "sayac",          "sayi",  Baslik: "Döngü sayacı", Grup: "Bakım"),
            new("bakimAy",       "bakim_ay",       "sayi",  Baslik: "Bakım periyodu (ay)", Grup: "Bakım"),
            new("sonBakim",      "son_bakim",      "tarih", Baslik: "Son bakım", Grup: "Bakım"),
            new("sonValidasyon", "son_validasyon", "tarih", Baslik: "Son validasyon / kalibrasyon", Grup: "Bakım"),
            new("aciklama",      "aciklama",       "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Bakım"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("bakimlar", "public.steril_bakim", "cihaz_id", new KartAlani[]
            {
                new("id",           "id",            "sayi",  Yazilabilir: false),
                new("tarih",        "tarih",         "tarih", Zorunlu: true, Baslik: "Tarih"),
                new("tur",          "tur",           "kod",   Zorunlu: true, KodListesi: "steril.bakim_tur", Baslik: "İşlem"),
                new("yapan",        "yapan",         "metin", EnFazlaUzunluk: 80, Baslik: "Yapan"),
                new("sonuc",        "sonuc",         "metin", EnFazlaUzunluk: 200, Baslik: "Sonuç"),
                new("sonrakiTarih", "sonraki_tarih", "tarih", Baslik: "Sonraki"),
                new("belgeNo",      "belge_no",      "metin", EnFazlaUzunluk: 40, Baslik: "Belge no"),
            }, Sirala: "tarih desc, id desc", Baslik: "Bakım / kalibrasyon / validasyon", LogTabloId: LogSterilBakim, SubeKolonu: null),
        });

    private static KartTanimi SterilProgramKarti() => new(
        Ad: "steril-program",
        YetkiKodu: "steril.ayar",
        Tablo: "public.steril_program",
        LogTabloId: LogSterilProgram,
        SilmeEngelleri: new SilmeEngeli[] { new("public.steril_dongu", "program_id", "Programla çalışmış döngü var; silinemez, pasife alın.") },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["sicaklik"] = 134m, ["platoDk"] = 4m, ["kurutmaDk"] = 12m, ["test"] = (short)0, ["varsayilan"] = (short)0, ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",          "sayi",  Yazilabilir: false),
            new("ad",         "ad",          "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Program", Grup: "Program"),
            new("cihazId",    "cihaz_id",    "kod",   KodTablosu: "public.v_steril_cihaz_lookup", Baslik: "Cihaz (boş = tüm otoklavlar)", Grup: "Program"),
            new("sicaklik",   "sicaklik",    "sayi",  Zorunlu: true, Baslik: "Sıcaklık (°C)", Grup: "Program"),
            new("platoDk",    "plato_dk",    "sayi",  Zorunlu: true, Baslik: "Plato süresi (dk)", Grup: "Program"),
            new("kurutmaDk",  "kurutma_dk",  "sayi",  Baslik: "Kurutma (dk)", Grup: "Program"),
            new("uygunYuk",   "uygun_yuk",   "metin", EnFazlaUzunluk: 120, Baslik: "Uygun yük", Grup: "Program"),
            new("test",       "test",        "kod",   SabitKodlar: SterilEvetHayir, Baslik: "Test programı (Bowie-Dick / vakum)", Grup: "Program"),
            new("varsayilan", "varsayilan",  "kod",   SabitKodlar: SterilEvetHayir, Baslik: "Varsayılan", Grup: "Program"),
            new("aktif",      "aktif",       "kod",   SabitKodlar: SterilAktifKodlari, Baslik: "Durum", Grup: "Program"),
        });

    private static KartTanimi SterilSetKarti() => new(
        Ad: "steril-set",
        YetkiKodu: "steril.birim",
        Tablo: "public.steril_set",
        LogTabloId: LogSterilSet,
        SilmeEngelleri: new SilmeEngeli[] { new("public.steril_birim", "set_id", "Set tanımına bağlı fiziksel set var; silinemez, pasife alın.") },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["paketTur"] = (short)1, ["rafOmruAy"] = (short)6, ["minStok"] = (short)0, ["donguEsigi"] = 400, ["implant"] = (short)0, ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",           "sayi",  Yazilabilir: false),
            new("kod",        "kod",          "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kod", Grup: "Set"),
            new("ad",         "ad",           "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Set", Grup: "Set"),
            new("paketTur",   "paket_tur",    "kod",   KodListesi: "steril.paket_tur", Baslik: "Paket türü", Grup: "Set"),
            new("rafOmruAy",  "raf_omru_ay",  "sayi",  Baslik: "Raf ömrü (ay)", Grup: "Set"),
            new("minStok",    "min_stok",     "sayi",  Baslik: "Min. steril stok", Grup: "Set"),
            new("donguEsigi", "dongu_esigi",  "sayi",  Baslik: "Gözden geçirme eşiği (döngü)", Grup: "Set"),
            new("implant",    "implant",      "kod",   SabitKodlar: SterilEvetHayir, Baslik: "İmplant kiti (biyolojik zorunlu)", Grup: "Set"),
            new("aktif",      "aktif",        "kod",   SabitKodlar: SterilAktifKodlari, Baslik: "Durum", Grup: "Set"),
            new("aciklama",   "aciklama",     "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Set"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("aletler", "public.steril_set_alet", "set_id", new KartAlani[]
            {
                new("id",              "id",              "sayi",  Yazilabilir: false),
                new("sira",            "sira",            "sayi",  Baslik: "Sıra"),
                new("ad",              "ad",              "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Alet"),
                new("adet",            "adet",            "sayi",  Baslik: "Adet"),
                new("tekKullanimlik",  "tek_kullanimlik", "kod",   SabitKodlar: SterilEvetHayir, Baslik: "Tek kullanımlık"),
                new("kritik",          "kritik",          "kod",   SabitKodlar: SterilEvetHayir, Baslik: "Kritik"),
                new("notu",            "notu",            "metin", EnFazlaUzunluk: 120, Baslik: "Not"),
            }, Sirala: "sira, id", Baslik: "Set içeriği", LogTabloId: LogSterilSetAlet, SubeKolonu: null),
        });

    private static KartTanimi SterilBirimKarti() => new(
        Ad: "steril-birim",
        YetkiKodu: "steril.birim",
        Tablo: "public.steril_birim",
        LogTabloId: LogSterilBirim,
        SubeKolonu: "sube_id",
        SilmeEngelleri: new SilmeEngeli[] { new("public.steril_paket", "birim_id", "Birimin paket / döngü geçmişi var; silinemez, pasife alın.") },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["durum"] = (short)7, ["aktif"] = (short)1, ["yaglamaGerekli"] = (short)0, ["ureticiEsigi"] = 0 },
        Alanlar: new KartAlani[]
        {
            new("id",             "id",              "sayi",  Yazilabilir: false),
            new("barkod",         "barkod",          "metin", Zorunlu: true, EnFazlaUzunluk: 30, Baslik: "Barkod", Grup: "Birim"),
            new("ad",             "ad",              "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Ad", Grup: "Birim"),
            new("tur",            "tur",             "kod",   Zorunlu: true, KodListesi: "steril.birim_tur", Baslik: "Tür", Grup: "Birim"),
            new("setId",          "set_id",          "kod",   KodTablosu: "public.v_steril_set_lookup", Baslik: "Set tanımı", Grup: "Birim"),
            new("konum",          "konum",           "metin", EnFazlaUzunluk: 40, Baslik: "Raf / konum", Grup: "Birim"),
            new("aktif",          "aktif",           "kod",   SabitKodlar: SterilAktifKodlari, Baslik: "Aktif", Grup: "Birim"),
            new("yaglamaGerekli", "yaglama_gerekli", "kod",   SabitKodlar: SterilEvetHayir, Baslik: "Döner alet: her kullanımda yağlama", Grup: "Bakım"),
            new("ureticiEsigi",   "uretici_esigi",   "sayi",  Baslik: "Üretici bakım eşiği (döngü)", Grup: "Bakım"),
            new("durum",          "durum",           "kod",   KodListesi: "steril.birim_durum", Yazilabilir: false, Baslik: "Durum", Grup: "Durum"),
            new("donguSayisi",    "dongu_sayisi",    "sayi",  Yazilabilir: false, Baslik: "Döngü sayısı", Grup: "Durum"),
            new("yaglamaSayisi",  "yaglama_sayisi",  "sayi",  Yazilabilir: false, Baslik: "Yağlama sayısı", Grup: "Durum"),
            new("sonYaglama",     "son_yaglama",     "zaman", Yazilabilir: false, Baslik: "Son yağlama", Grup: "Durum"),
            new("sonKullanim",    "son_kullanim",    "zaman", Yazilabilir: false, Baslik: "Son kullanım", Grup: "Durum"),
            new("aciklama",       "aciklama",        "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Durum"),
        });

    private static KartTanimi SterilBakimKarti() => new(
        Ad: "steril-bakim",
        YetkiKodu: "steril.ayar",
        Tablo: "public.steril_bakim",
        LogTabloId: LogSterilBakim,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["tarih"] = "@bugun" },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",            "sayi",  Yazilabilir: false),
            new("cihazId",      "cihaz_id",      "kod",   Zorunlu: true, KodTablosu: "public.v_steril_cihaz_lookup", Baslik: "Cihaz", Grup: "Bakım"),
            new("tur",          "tur",           "kod",   Zorunlu: true, KodListesi: "steril.bakim_tur", Baslik: "İşlem", Grup: "Bakım"),
            new("tarih",        "tarih",         "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Bakım"),
            new("yapan",        "yapan",         "metin", EnFazlaUzunluk: 80, Baslik: "Yapan (servis / kişi)", Grup: "Bakım"),
            new("sonuc",        "sonuc",         "metin", EnFazlaUzunluk: 200, Baslik: "Sonuç", Grup: "Bakım"),
            new("sonrakiTarih", "sonraki_tarih", "tarih", Baslik: "Sonraki tarih", Grup: "Bakım"),
            new("belgeNo",      "belge_no",      "metin", EnFazlaUzunluk: 40, Baslik: "Belge / sertifika no", Grup: "Bakım"),
            new("aciklama",     "aciklama",      "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Bakım"),
        });
}
