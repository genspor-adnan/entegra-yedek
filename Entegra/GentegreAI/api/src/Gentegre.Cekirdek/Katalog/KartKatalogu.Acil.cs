namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ACİL SERVİS KARTLARI (716).
///
/// `acilBasvuru` üç detay taşır: zaman kritik protokol adımları, çağrılar ve
/// zorunlu bildirimler. Muayene/tanı/reçete BU KARTTA YOK - onlar mevcut
/// `muayene` kartının işi; acile kopyalasaydık hastanın tıbbi geçmişi ikiye
/// bölünürdü (bkz 716 başlığı).
///
/// TRİYAJ GEÇMİŞİ KART DETAYI DEĞİL: tetiğin yazdığı denetim izidir, elle
/// düzenlenebilir bir sekme olsaydı izin değeri kalmazdı. Geçmiş, listede ve
/// işlem günlüğünde okunur.
///
/// ÇIKIŞ TANISI ZORUNLU ALAN DEĞİL, veritabanı kuralıdır: boş bırakılabilir
/// (dosya açıkken), ama çıkış şekli girildiği anda tetik reddeder. Kartta
/// zorunlu işaretleseydik daha ilk kayıtta tanı istenirdi.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi AcilBasvuru() => new(
        Ad: "acilBasvuru",
        YetkiKodu: "acil.basvuru",
        Tablo: "public.acil_basvuru",
        LogTabloId: 1160,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("protokolNo", "protokol_no", "metin", Yazilabilir: false,
                Baslik: "Protokol No", Grup: "Başvuru"),
            // Hasta ZORUNLU DEĞİL: kimliksiz hasta kabul edilir (716 kararı).
            new("hastaId", "hasta_id", "sayi", Baslik: "Hasta", Grup: "Başvuru",
                AramaKaynagi: "hasta", KodTablosu: "public.v_hasta_lookup"),
            new("kimliksiz", "kimliksiz", "mantik", Baslik: "Kimliksiz", Grup: "Başvuru"),
            new("geciciAd", "gecici_ad", "metin", Baslik: "Geçici Ad", Grup: "Başvuru",
                EnFazlaUzunluk: 120),
            new("girisZamani", "giris_zamani", "zaman", Zorunlu: true,
                Baslik: "Geliş (kapı) Saati", Grup: "Başvuru"),
            new("gelisSekli", "gelis_sekli", "kod", Baslik: "Geliş Şekli", Grup: "Başvuru",
                SabitKodlar: AcKartGelisKodlari),
            new("gelisNotu", "gelis_notu", "metin", Baslik: "Geliş Notu", Grup: "Başvuru",
                EnFazlaUzunluk: 200),
            new("sikayet", "sikayet", "metin", Baslik: "Şikâyet", Grup: "Başvuru"),

            new("triyaj", "triyaj", "kod", Baslik: "Triyaj Düzeyi", Grup: "Triyaj",
                SabitKodlar: AcKartTriyajKodlari),
            new("triyajZamani", "triyaj_zamani", "zaman", Baslik: "Triyaj Saati",
                Grup: "Triyaj"),
            new("triyajYapanId", "triyaj_yapan_id", "sayi", Baslik: "Triyajı Yapan",
                Grup: "Triyaj", KodTablosu: "public.v_personel_lookup"),
            new("yatakId", "yatak_id", "sayi", Baslik: "Yatak", Grup: "Triyaj",
                KodTablosu: "public.v_acil_yatak_lookup"),

            new("hekimId", "hekim_id", "sayi", Baslik: "Hekim", Grup: "Tedavi",
                KodTablosu: "public.v_hekim_lookup"),
            // Kapı-hekim süresinin ikinci ucu; süre hesabı v_acil_sure'de.
            new("hekimGorme", "hekim_gorme", "zaman", Baslik: "Hekimin Gördüğü An",
                Grup: "Tedavi"),
            new("adliVaka", "adli_vaka", "mantik", Baslik: "Adli Vaka", Grup: "Tedavi"),

            new("cikisSekli", "cikis_sekli", "kod", Baslik: "Çıkış Şekli", Grup: "Çıkış",
                SabitKodlar: AcKartCikisKodlari),
            new("cikisZamani", "cikis_zamani", "zaman", Baslik: "Çıkış Saati", Grup: "Çıkış"),
            // Zorunluluğu veritabanı kuralı taşıyor (bkz sınıf başlığı).
            new("cikisTani", "cikis_tani", "metin", Baslik: "Çıkış Tanısı (ICD-10)",
                Grup: "Çıkış", EnFazlaUzunluk: 20),
            new("hedefBolumId", "hedef_bolum_id", "sayi", Baslik: "Hedef Bölüm",
                Grup: "Çıkış", KodTablosu: "public.v_departman_lookup"),
            new("cikisNotu", "cikis_notu", "metin", Baslik: "Çıkış Notu / Öneriler",
                Grup: "Çıkış"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("cagrilar", "public.acil_cagri", "basvuru_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tur", "tur", "kod", Zorunlu: true, Baslik: "Çağrı Türü",
                    SabitKodlar: AcKartCagriTurKodlari),
                new("hedefBolumId", "hedef_bolum_id", "sayi", Baslik: "Hedef Bölüm",
                    KodTablosu: "public.v_departman_lookup"),
                new("hedefKisiId", "hedef_kisi_id", "sayi", Baslik: "Hedef Kişi",
                    KodTablosu: "public.v_personel_lookup"),
                new("cagriZamani", "cagri_zamani", "zaman", Zorunlu: true, Baslik: "Çağrı"),
                // YANIT zamanı çağrının asıl ölçüsü: "çağırdık" ile "geldi"
                //   arasındaki fark ölçülmedikçe bekleme kimsenin sorunu olmuyor.
                new("yanitZamani", "yanit_zamani", "zaman", Baslik: "Yanıt"),
                new("kapanisZamani", "kapanis_zamani", "zaman", Baslik: "Kapanış"),
                new("yanitlayanId", "yanitlayan_id", "sayi", Baslik: "Yanıtlayan",
                    KodTablosu: "public.v_personel_lookup"),
                new("durum", "durum", "kod", Baslik: "Durum",
                    SabitKodlar: AcKartCagriDurumKodlari),
                new("tekrarSayi", "tekrar_sayi", "sayi", Baslik: "Tekrar"),
                new("notMetni", "not_metni", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "cagri_zamani desc", Baslik: "Çağrılar", LogTabloId: 1161),

            new("bildirimler", "public.acil_bildirim", "basvuru_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tur", "tur", "kod", Zorunlu: true, Baslik: "Bildirim",
                    SabitKodlar: AcKartBildirimTurKodlari),
                new("durum", "durum", "kod", Baslik: "Durum",
                    SabitKodlar: AcKartBildirimDurumKodlari),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("referans", "referans", "metin", Baslik: "Referans No",
                    EnFazlaUzunluk: 80),
                new("notMetni", "not_metni", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "tur", Baslik: "Bildirimler", SubeKolonu: null, LogTabloId: 1162),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["gelisSekli"] = 1,
            ["triyaj"] = 0,
            ["cikisSekli"] = 0,
        });

    private static KartTanimi AcilYatak() => new(
        Ad: "acilYatak",
        YetkiKodu: "acil.yatak",
        Tablo: "public.acil_yatak",
        LogTabloId: 1163,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("kod", "kod", "metin", Zorunlu: true, Baslik: "Yatak Kodu", EnFazlaUzunluk: 20),
            new("ad", "ad", "metin", Baslik: "Ad", EnFazlaUzunluk: 80),
            new("alan", "alan", "kod", Zorunlu: true, Baslik: "Alan",
                SabitKodlar: AcKartAlanKodlari),
            new("durum", "durum", "kod", Baslik: "Durum", SabitKodlar: AcKartYatakDurumKodlari),
            new("sira", "sira", "sayi", Baslik: "Sıra"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif"),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["alan"] = 2, ["durum"] = 0, ["aktif"] = 1,
        });

    private static readonly Dictionary<string, string> AcKartTriyajKodlari = new()
    {
        ["0"] = "Triyaj bekliyor", ["1"] = "1 · Kırmızı (resüsitasyon)",
        ["2"] = "2 · Turuncu (acil)", ["3"] = "3 · Sarı (acele)",
        ["4"] = "4 · Yeşil (az acil)", ["5"] = "5 · Mavi (acil değil)",
    };

    private static readonly Dictionary<string, string> AcKartGelisKodlari = new()
    {
        ["1"] = "Kendi imkânı", ["2"] = "112 ambulans", ["3"] = "Özel ambulans",
        ["4"] = "Polis/Jandarma", ["5"] = "Başka kurumdan sevk", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> AcKartCikisKodlari = new()
    {
        ["0"] = "(açık)", ["1"] = "Taburcu", ["2"] = "Servise yatış",
        ["3"] = "Yoğun bakım", ["4"] = "Sevk", ["5"] = "Ölüm",
        ["6"] = "Kendi isteğiyle", ["7"] = "Ameliyathane",
    };

    private static readonly Dictionary<string, string> AcKartCagriTurKodlari = new()
    {
        ["1"] = "Konsültasyon", ["2"] = "Mavi Kod", ["3"] = "Beyaz Kod",
        ["4"] = "Pembe Kod", ["5"] = "Kateter Lab", ["6"] = "Ameliyathane",
        ["7"] = "Yoğun Bakım",
    };

    private static readonly Dictionary<string, string> AcKartCagriDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Yanıtlandı", ["2"] = "Kapandı", ["3"] = "Yanıt yok",
    };

    private static readonly Dictionary<string, string> AcKartBildirimTurKodlari = new()
    {
        ["1"] = "Adli vaka", ["2"] = "Bulaşıcı hastalık", ["3"] = "e-Nabız",
        ["4"] = "SGK provizyon", ["5"] = "Çocuk izlem", ["6"] = "İş kazası",
    };

    private static readonly Dictionary<string, string> AcKartBildirimDurumKodlari = new()
    {
        ["0"] = "Gerekmiyor", ["1"] = "Bekliyor", ["2"] = "Yapıldı", ["3"] = "Hata",
    };

    private static readonly Dictionary<string, string> AcKartAlanKodlari = new()
    {
        ["1"] = "Resüsitasyon", ["2"] = "Müşahede", ["3"] = "Yeşil alan",
        ["4"] = "İzolasyon", ["5"] = "Travma",
    };

    private static readonly Dictionary<string, string> AcKartYatakDurumKodlari = new()
    {
        ["0"] = "Boş", ["1"] = "Dolu", ["2"] = "Temizlikte", ["3"] = "Arızalı",
    };
}
