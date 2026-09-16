namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FTR MODÜLÜ (719) kartları. Program ve seans kartı özel modaldır
/// (<c>ozelKart</c>); generic kartlar yine tanımlıdır - detay gridleri
/// (uygulama, egzersiz, EHA) ve "Geri Al" onlardan çalışır.
/// </summary>
public static partial class KartKatalogu
{
    // ISLEMLOG tablo kodları — 1180 bloğu FTR'ye ayrıldı.
    private const int LogFtrDegerlendirme = 1180;
    private const int LogFtrEha           = 1181;
    private const int LogFtrProgram       = 1182;
    private const int LogFtrProgramUyg    = 1183;
    private const int LogFtrProgramEgz    = 1184;
    private const int LogFtrSeans         = 1185;
    private const int LogFtrSeansUyg      = 1186;
    private const int LogFtrOlcek         = 1187;
    private const int LogFtrUnite         = 1188;
    private const int LogFtrKabin         = 1189;

    private static KartTanimi FtrDegerlendirmeKarti() => new(
        Ad: "ftr-degerlendirme",
        YetkiKodu: "ftr.degerlendirme",
        Tablo: "public.ftr_degerlendirme",
        LogTabloId: LogFtrDegerlendirme,
        SubeKolonu: "sube_id",
        SilmeEngelleri: new SilmeEngeli[] { new("public.ftr_program", "degerlendirme_id", "Bu değerlendirmeye bağlı tedavi programı var; önce programı silin ya da bağını kaldırın.") },
        AcilistaTarafSecimi: "hastaId",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tarih"] = "@simdi", ["bolge"] = (short)3 },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",             "sayi",  Yazilabilir: false),
            new("hastaId",       "hasta_id",       "kod",   Zorunlu: true, KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta", Grup: "Kimlik"),
            new("tarih",         "tarih",          "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Kimlik"),
            new("hekimId",       "hekim_id",       "kod",   KodTablosu: "public.v_hekim_lookup", Baslik: "FTR Uzmanı", Grup: "Kimlik"),
            new("bolge",         "bolge",          "kod",   Zorunlu: true, KodListesi: "ftr.bolge", Baslik: "Bölge", Grup: "Kimlik"),
            new("tarafYon",      "taraf_yon",      "metin", EnFazlaUzunluk: 10, Baslik: "Taraf (sağ/sol/bilateral)", Grup: "Kimlik"),
            new("icdKod",        "icd_kod",        "metin", EnFazlaUzunluk: 10, Baslik: "ICD", Grup: "Kimlik"),
            new("taniAd",        "tani_ad",        "metin", EnFazlaUzunluk: 200, Baslik: "Tanı", Grup: "Kimlik"),
            new("sevkKaynak",    "sevk_kaynak",    "metin", EnFazlaUzunluk: 120, Baslik: "Sevk / kaynak", Grup: "Kimlik"),
            new("raporNo",       "rapor_no",       "metin", EnFazlaUzunluk: 30, Baslik: "FTR e-Rapor No", Grup: "Kimlik"),
            new("raporSeans",    "rapor_seans",    "sayi",  Baslik: "Rapor seans hakkı", Grup: "Kimlik"),
            new("sikayet",       "sikayet",        "metin", EnFazlaUzunluk: 1000, Baslik: "Şikayet", Grup: "Anamnez"),
            new("sikayetSuresi", "sikayet_suresi", "metin", EnFazlaUzunluk: 40, Baslik: "Şikayet süresi", Grup: "Anamnez"),
            new("agriKarakteri", "agri_karakteri", "metin", EnFazlaUzunluk: 60, Baslik: "Ağrı karakteri", Grup: "Anamnez"),
            new("geceAgrisi",    "gece_agrisi",    "mantik", Baslik: "Gece ağrısı", Grup: "Anamnez"),
            new("kirmiziBayrak", "kirmizi_bayrak", "mantik", Baslik: "Kırmızı bayrak", Grup: "Anamnez"),
            new("kirmiziBayrakNot", "kirmizi_bayrak_not", "metin", EnFazlaUzunluk: 300, Baslik: "Kırmızı bayrak notu", Grup: "Anamnez"),
            new("oncekiTedavi",  "onceki_tedavi",  "metin", EnFazlaUzunluk: 300, Baslik: "Önceki tedavi", Grup: "Anamnez"),
            new("meslekAktivite","meslek_aktivite","metin", EnFazlaUzunluk: 200, Baslik: "Meslek / aktivite", Grup: "Anamnez"),
            new("komorbidite",   "komorbidite",    "metin", EnFazlaUzunluk: 300, Baslik: "Komorbidite (kalp pili, gebelik, malignite…)", Grup: "Anamnez"),
            new("vasIstirahat",  "vas_istirahat",  "sayi",  Baslik: "VAS istirahat (0-10)", Grup: "Ağrı & Nörolojik"),
            new("vasAktivite",   "vas_aktivite",   "sayi",  Baslik: "VAS aktivite (0-10)", Grup: "Ağrı & Nörolojik"),
            new("vasGece",       "vas_gece",       "sayi",  Baslik: "VAS gece (0-10)", Grup: "Ağrı & Nörolojik"),
            new("norolojikDuyu", "norolojik_duyu", "metin", EnFazlaUzunluk: 200, Baslik: "Duyu", Grup: "Ağrı & Nörolojik"),
            new("norolojikRefleks", "norolojik_refleks", "metin", EnFazlaUzunluk: 200, Baslik: "Refleks", Grup: "Ağrı & Nörolojik"),
            new("norolojikMotor","norolojik_motor","metin", EnFazlaUzunluk: 200, Baslik: "Motor", Grup: "Ağrı & Nörolojik"),
            new("postur",        "postur",         "metin", EnFazlaUzunluk: 200, Baslik: "Postür", Grup: "Ağrı & Nörolojik"),
            new("yuruyus",       "yuruyus",        "metin", EnFazlaUzunluk: 200, Baslik: "Yürüyüş / denge", Grup: "Ağrı & Nörolojik"),
            new("ozelTestler",   "ozel_testler",   "metin", EnFazlaUzunluk: 600, Baslik: "Özel testler (SLR, FABER, Schober…)", Grup: "Ağrı & Nörolojik"),
            new("hedefKisa",     "hedef_kisa",     "metin", EnFazlaUzunluk: 300, Baslik: "Kısa vadeli hedef", Grup: "Hedef & Plan"),
            new("hedefOrta",     "hedef_orta",     "metin", EnFazlaUzunluk: 300, Baslik: "Orta vadeli hedef", Grup: "Hedef & Plan"),
            new("hedefUzun",     "hedef_uzun",     "metin", EnFazlaUzunluk: 300, Baslik: "Uzun vadeli hedef", Grup: "Hedef & Plan"),
            new("programOnerisi","program_onerisi","metin", EnFazlaUzunluk: 400, Baslik: "Program önerisi", Grup: "Hedef & Plan"),
            new("aciklama",      "aciklama",       "metin", EnFazlaUzunluk: 600, Baslik: "Açıklama", Grup: "Hedef & Plan"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("eha", "public.ftr_eha", "degerlendirme_id", new KartAlani[]
            {
                new("id",          "id",           "sayi",  Yazilabilir: false),
                new("hareket",     "hareket",      "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Hareket"),
                new("tarafYon",    "taraf_yon",    "metin", EnFazlaUzunluk: 10, Baslik: "Taraf"),
                new("aktifDerece", "aktif_derece", "sayi",  Baslik: "Aktif °"),
                new("pasifDerece", "pasif_derece", "sayi",  Baslik: "Pasif °"),
                new("normDerece",  "norm_derece",  "sayi",  Baslik: "Norm °"),
                new("kasGucu",     "kas_gucu",     "sayi",  Baslik: "Kas gücü (0-5)"),
                new("notMetin",    "not_metin",    "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, Sirala: "id", Baslik: "EHA (ROM) & Kas Gücü", LogTabloId: LogFtrEha),
            new("olcekler", "public.ftr_olcek", "degerlendirme_id", new KartAlani[]
            {
                new("id",       "id",        "sayi",  Yazilabilir: false),
                new("hastaId",  "hasta_id",  "kod",   KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta"),
                new("tarih",    "tarih",     "tarih", Baslik: "Tarih"),
                new("olcek",    "olcek",     "kod",   KodListesi: "ftr.olcek", Baslik: "Ölçek"),
                new("asama",    "asama",     "kod",   KodListesi: "ftr.olcek_asama", Baslik: "Aşama"),
                new("skor",     "skor",      "sayi",  Baslik: "Skor"),
                new("hedef",    "hedef",     "sayi",  Baslik: "Hedef"),
                new("notMetin", "not_metin", "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            }, Sirala: "tarih, id", Baslik: "Ölçekler", LogTabloId: LogFtrOlcek),
        });

    private static KartTanimi FtrProgramKarti() => new(
        Ad: "ftr-program",
        YetkiKodu: "ftr.program",
        Tablo: "public.ftr_program",
        LogTabloId: LogFtrProgram,
        SubeKolonu: "sube_id",
        // Seansı olan program silinmez (yapılmış seans ve uygulama izi kaybolurdu); sonlandırılır.
        SilmeEngelleri: new SilmeEngeli[] { new("public.ftr_seans", "program_id", "Programın seansları var; silinmez, \"Sonlandır\" ile kapatın."), new("public.ftr_olcek", "program_id", "Programa bağlı ölçek kayıtları var; önce onları silin.") },
        AcilistaTarafSecimi: "hastaId",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["baslangic"] = "@simdi", ["bolge"] = (short)3, ["seansSayisi"] = (short)20, ["siklikHaftalik"] = (short)5,
            ["seansSureDk"] = (short)45, ["saat"] = "10:00", ["araDegerlendirmeSeans"] = (short)10, ["durum"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",               "id",                "sayi",  Yazilabilir: false),
            new("programNo",        "program_no",        "metin", Yazilabilir: false, Baslik: "Program No", Grup: "Kimlik"),
            new("hastaId",          "hasta_id",          "kod",   Zorunlu: true, KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta", Grup: "Kimlik"),
            new("degerlendirmeId",  "degerlendirme_id",  "kod",   KodTablosu: "public.v_ftr_degerlendirme_lookup", Baslik: "Değerlendirme", Grup: "Kimlik"),
            new("hekimId",          "hekim_id",          "kod",   KodTablosu: "public.v_hekim_lookup", Baslik: "FTR Uzmanı", Grup: "Kimlik"),
            new("fizyoterapistId",  "fizyoterapist_id",  "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Fizyoterapist", Grup: "Kimlik"),
            new("bolge",            "bolge",             "kod",   Zorunlu: true, KodListesi: "ftr.bolge", Baslik: "Bölge", Grup: "Kimlik"),
            new("icdKod",           "icd_kod",           "metin", EnFazlaUzunluk: 10, Baslik: "ICD", Grup: "Kimlik"),
            new("taniAd",           "tani_ad",           "metin", EnFazlaUzunluk: 200, Baslik: "Tanı", Grup: "Kimlik"),
            new("durum",            "durum",             "kod",   KodListesi: "ftr.program_durum", Baslik: "Durum", Grup: "Kimlik"),
            new("seansSayisi",      "seans_sayisi",      "sayi",  Zorunlu: true, Baslik: "Seans sayısı", Grup: "Program"),
            new("siklikHaftalik",   "siklik_haftalik",   "sayi",  Zorunlu: true, Baslik: "Haftada seans", Grup: "Program"),
            new("seansSureDk",      "seans_sure_dk",     "sayi",  Baslik: "Seans süresi (dk)", Grup: "Program"),
            new("saat",             "saat",              "metin", EnFazlaUzunluk: 5, Baslik: "Seans saati", Grup: "Program"),
            new("baslangic",        "baslangic",         "tarih", Zorunlu: true, Baslik: "Başlangıç", Grup: "Program"),
            new("bitisTahmini",     "bitis_tahmini",     "tarih", Baslik: "Tahmini bitiş", Grup: "Program"),
            new("uniteId",          "unite_id",          "kod",   KodTablosu: "public.v_ftr_unite_lookup", Baslik: "Ünite", Grup: "Program"),
            new("kabinId",          "kabin_id",          "kod",   KodTablosu: "public.v_ftr_kabin_lookup", Baslik: "Kabin", Grup: "Program"),
            new("araDegerlendirmeSeans", "ara_degerlendirme_seans", "sayi", Baslik: "Ara değerlendirme seansı", Grup: "Program"),
            new("raporNo",          "rapor_no",          "metin", EnFazlaUzunluk: 30, Baslik: "FTR e-Rapor No", Grup: "Ödeyen & Rapor"),
            new("raporSeansHakki",  "rapor_seans_hakki", "sayi",  Baslik: "Rapor seans hakkı", Grup: "Ödeyen & Rapor"),
            new("kalanHak",         "kalan_hak",         "sayi",  Baslik: "Kalan yıllık hak", Grup: "Ödeyen & Rapor"),
            new("odeyenKurumId",    "odeyen_kurum_id",   "kod",   KodTablosu: "public.v_kurum_lookup", Baslik: "Ödeyen kurum", Grup: "Ödeyen & Rapor"),
            new("belgeId",          "belge_id",          "sayi",  Yazilabilir: false, Baslik: "Başvuru", Grup: "Ödeyen & Rapor"),
            new("yapilanSeans",     "yapilan_seans",     "sayi",  Yazilabilir: false, Baslik: "Yapılan seans", Grup: "Sonuç"),
            new("devamsiz",         "devamsiz",          "sayi",  Yazilabilir: false, Baslik: "Devamsız", Grup: "Sonuç"),
            new("yanit",            "yanit",             "kod",   KodListesi: "ftr.yanit", Baslik: "Tedavi yanıtı", Grup: "Sonuç"),
            new("sonucNotu",        "sonuc_notu",        "metin", EnFazlaUzunluk: 1000, Baslik: "Kür sonu notu", Grup: "Sonuç"),
            new("bitis",            "bitis",             "tarih", Baslik: "Bitiş", Grup: "Sonuç"),
            new("aciklama",         "aciklama",          "metin", EnFazlaUzunluk: 600, Baslik: "Açıklama", Grup: "Sonuç"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("uygulamalar", "public.ftr_program_uygulama", "program_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("sira",       "sira",        "sayi",  Baslik: "#"),
                new("hizmetId",   "hizmet_id",   "kod",   KodTablosu: "public.v_ftr_hizmet_lookup", Baslik: "Uygulama (SUT)"),
                new("ad",         "ad",          "metin", EnFazlaUzunluk: 120, Baslik: "Ad"),
                new("bolgeMetin", "bolge_metin", "metin", EnFazlaUzunluk: 80, Baslik: "Bölge"),
                new("sureDk",     "sure_dk",     "sayi",  Baslik: "Süre (dk)"),
                new("parametre",  "parametre",   "metin", EnFazlaUzunluk: 200, Baslik: "Parametre"),
                new("cihazAd",    "cihaz_ad",    "metin", EnFazlaUzunluk: 60, Baslik: "Cihaz"),
                new("seansBas",   "seans_bas",   "sayi",  Baslik: "Seans (baş)"),
                new("seansBit",   "seans_bit",   "sayi",  Baslik: "Seans (bit)"),
                new("notMetin",   "not_metin",   "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, Sirala: "sira, id", Baslik: "Uygulamalar (SUT)", LogTabloId: LogFtrProgramUyg),
            new("egzersizler", "public.ftr_program_egzersiz", "program_id", new KartAlani[]
            {
                new("id",        "id",         "sayi",  Yazilabilir: false),
                new("sira",      "sira",       "sayi",  Baslik: "#"),
                new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Egzersiz"),
                new("setTekrar", "set_tekrar", "metin", EnFazlaUzunluk: 30, Baslik: "Set × tekrar"),
                new("yer",       "yer",        "kod",   KodListesi: "ftr.egzersiz_yer", Baslik: "Yer"),
                new("asamaBas",  "asama_bas",  "sayi",  Baslik: "Aşama (baş)"),
                new("asamaBit",  "asama_bit",  "sayi",  Baslik: "Aşama (bit)"),
                new("notMetin",  "not_metin",  "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, Sirala: "sira, id", Baslik: "Egzersiz Programı", LogTabloId: LogFtrProgramEgz),
        });

    private static KartTanimi FtrSeansKarti() => new(
        Ad: "ftr-seans",
        YetkiKodu: "ftr.seans",
        Tablo: "public.ftr_seans",
        LogTabloId: LogFtrSeans,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tarih"] = "@simdi", ["durum"] = (short)1, ["sira"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",               "sayi",  Yazilabilir: false),
            new("programId",       "program_id",       "kod",   Zorunlu: true, KodTablosu: "public.v_ftr_program_lookup", Baslik: "Program", Grup: "Seans"),
            new("sira",            "sira",             "sayi",  Zorunlu: true, Baslik: "Seans no", Grup: "Seans"),
            new("tarih",           "tarih",            "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Seans"),
            new("saat",            "saat",             "metin", EnFazlaUzunluk: 5, Baslik: "Saat", Grup: "Seans"),
            new("fizyoterapistId", "fizyoterapist_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Fizyoterapist", Grup: "Seans"),
            new("kabinId",         "kabin_id",         "kod",   KodTablosu: "public.v_ftr_kabin_lookup", Baslik: "Kabin", Grup: "Seans"),
            new("durum",           "durum",            "kod",   KodListesi: "ftr.seans_durum", Baslik: "Durum", Grup: "Seans"),
            new("vasOnce",         "vas_once",         "sayi",  Baslik: "VAS önce", Grup: "Uygulama"),
            new("vasSonra",        "vas_sonra",        "sayi",  Baslik: "VAS sonra", Grup: "Uygulama"),
            new("evUyum",          "ev_uyum",          "metin", EnFazlaUzunluk: 40, Baslik: "Ev programı uyumu", Grup: "Uygulama"),
            new("uygulamaNotu",    "uygulama_notu",    "metin", EnFazlaUzunluk: 1000, Baslik: "Uygulama notu", Grup: "Uygulama"),
            new("komplikasyon",    "komplikasyon",     "metin", EnFazlaUzunluk: 300, Baslik: "Komplikasyon", Grup: "Uygulama"),
            new("hastayaTalimat",  "hastaya_talimat",  "metin", EnFazlaUzunluk: 300, Baslik: "Hastaya talimat", Grup: "Uygulama"),
            new("yarimNeden",      "yarim_neden",      "metin", EnFazlaUzunluk: 200, Baslik: "Yarım bırakma nedeni", Grup: "Uygulama"),
            new("imza",            "imza",             "mantik", Baslik: "Hasta imzası", Grup: "Uygulama"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("uygulamalar", "public.ftr_seans_uygulama", "seans_id", new KartAlani[]
            {
                new("id",        "id",        "sayi",   Yazilabilir: false),
                new("ad",        "ad",        "metin",  EnFazlaUzunluk: 120, Baslik: "Uygulama"),
                new("sureDk",    "sure_dk",   "sayi",   Baslik: "Süre (dk)"),
                new("parametre", "parametre", "metin",  EnFazlaUzunluk: 200, Baslik: "Parametre"),
                new("cihazAd",   "cihaz_ad",  "metin",  EnFazlaUzunluk: 60, Baslik: "Cihaz"),
                new("yapildi",   "yapildi",   "mantik", Baslik: "Yapıldı"),
                new("neden",     "neden",     "metin",  EnFazlaUzunluk: 200, Baslik: "Yapılmadıysa neden"),
            }, Sirala: "id", Baslik: "Uygulamalar", LogTabloId: LogFtrSeansUyg),
        });

    private static KartTanimi FtrOlcekKarti() => new(
        Ad: "ftr-olcek",
        YetkiKodu: "ftr.olcek",
        Tablo: "public.ftr_olcek",
        LogTabloId: LogFtrOlcek,
        SubeKolonu: "sube_id",
        AcilistaTarafSecimi: "hastaId",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tarih"] = "@simdi", ["olcek"] = (short)2, ["asama"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",               "sayi",  Yazilabilir: false),
            new("hastaId",         "hasta_id",         "kod",   Zorunlu: true, KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta"),
            new("programId",       "program_id",       "kod",   KodTablosu: "public.v_ftr_program_lookup", Baslik: "Program"),
            new("degerlendirmeId", "degerlendirme_id", "kod",   KodTablosu: "public.v_ftr_degerlendirme_lookup", Baslik: "Değerlendirme"),
            new("tarih",           "tarih",            "tarih", Zorunlu: true, Baslik: "Tarih"),
            new("olcek",           "olcek",            "kod",   Zorunlu: true, KodListesi: "ftr.olcek", Baslik: "Ölçek"),
            new("asama",           "asama",            "kod",   KodListesi: "ftr.olcek_asama", Baslik: "Aşama"),
            new("skor",            "skor",             "sayi",  Zorunlu: true, Baslik: "Skor"),
            new("hedef",           "hedef",            "sayi",  Baslik: "Hedef"),
            new("notMetin",        "not_metin",        "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
        });

    private static KartTanimi FtrUniteKarti() => new(
        Ad: "ftr-unite",
        YetkiKodu: "ftr.unite",
        Tablo: "public.ftr_unite",
        LogTabloId: LogFtrUnite,
        SubeKolonu: "sube_id",
        SilmeEngelleri: new SilmeEngeli[] { new("public.ftr_program", "unite_id", "Ünitede tedavi programı var; silinmez, pasife alın.") },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",         "sayi",   Yazilabilir: false),
            new("kod",       "kod",        "metin",  Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kod"),
            new("ad",        "ad",         "metin",  Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Ünite"),
            new("sorumluId", "sorumlu_id", "kod",    KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu"),
            new("aktif",     "aktif",      "mantik", Baslik: "Aktif"),
            new("aciklama",  "aciklama",   "metin",  EnFazlaUzunluk: 300, Baslik: "Açıklama"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("kabinler", "public.ftr_kabin", "unite_id", new KartAlani[]
            {
                new("id",       "id",       "sayi",   Yazilabilir: false),
                new("kod",      "kod",      "metin",  Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kod"),
                new("ad",       "ad",       "metin",  Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Kabin"),
                new("tur",      "tur",      "kod",    KodListesi: "ftr.kabin_tur", Baslik: "Tür"),
                new("kapasite", "kapasite", "sayi",   Baslik: "Kapasite"),
                new("cihazlar", "cihazlar", "metin",  EnFazlaUzunluk: 300, Baslik: "Cihazlar"),
                new("aktif",    "aktif",    "mantik", Baslik: "Aktif"),
            }, Sirala: "kod, id", Baslik: "Kabinler", LogTabloId: LogFtrKabin),
        });
}
