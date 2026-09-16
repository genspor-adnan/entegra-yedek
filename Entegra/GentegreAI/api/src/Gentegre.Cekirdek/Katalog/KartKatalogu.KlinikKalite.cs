namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KLİNİK KALİTE KARTLARI (711).
///
/// `klinikGosterge` — rehberin kartı. Kod, ad, tanım, hesaplama yöntemi, teknik
///   not ve rehber hedefi SALT OKUNUR: hepsi Bakanlığın metni ve değiştirilirse
///   kurumun ürettiği sayı Bakanlığın hesabıyla tutmaz. Kurumun yazabildiği tek
///   şey KENDİ hedefi (`kurumHedefYon` / `kurumHedefDeger`).
///
/// `klinikGostergeDonem` — ölçüm. Otomatik hesaplanan göstergede motor yazar;
///   kod listesi olmayan 15 gösterge için kullanıcı elle girer.
///
/// SONUÇ ALANI YAZILAMAZ: `sonuc` tetiğin yazdığı kolondur
/// (fn_klinik_gosterge_sonuc). Elle yazılabilseydi pay/payda ile sonucun
/// birbirini tutmadığı satırlar doğar, göstergenin denetlenebilirliği biterdi.
///
/// KOD LİSTESİNİN KARTI YOK: `klinik_gosterge_kod` rehberden gelir ve kurum
/// düzenlemez; düzenlenebilir bir kart açmak, kıyaslamayı bozmanın en kısa yolu
/// olurdu. Kod havuzu yalnız LİSTE olarak sunulur (KaynakKatalogu).
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi KlinikGosterge() => new(
        Ad: "klinikGosterge",
        YetkiKodu: "klinik_kalite.olgu",
        Tablo: "public.klinik_gosterge",
        LogTabloId: 1030,
        Alanlar: new KartAlani[]
        {
            // ---- Rehberden gelen kimlik: salt okunur ----
            new("kod",   "kod",   "metin", Yazilabilir: false, Baslik: "Gösterge Kodu",
                Grup: "Gösterge"),
            new("olguId", "olgu_id", "sayi", Yazilabilir: false, Baslik: "Sağlık Olgusu",
                Grup: "Gösterge", KodTablosu: "public.v_klinik_olgu_lookup"),
            new("ad",    "ad",    "metin", Yazilabilir: false, Baslik: "Gösterge Adı",
                Grup: "Gösterge"),
            new("izlem", "izlem", "metin", Yazilabilir: false, Baslik: "İzlem Düzeyi",
                Grup: "Gösterge"),
            new("rehberSurum", "rehber_surum", "metin", Yazilabilir: false,
                Baslik: "Rehber Sürümü", Grup: "Gösterge"),
            new("aktif", "aktif", "kod", Yazilabilir: false, Baslik: "Durum",
                Grup: "Gösterge", SabitKodlar: KkKartAktifKodlari),

            new("tanim",         "tanim",          "metin", Yazilabilir: false,
                Baslik: "Tanım", Grup: "Gösterge Kartı"),
            new("standartMetin", "standart_metin", "metin", Yazilabilir: false,
                Baslik: "Bağlı Standart", Grup: "Gösterge Kartı"),
            new("hesaplama",     "hesaplama",      "metin", Yazilabilir: false,
                Baslik: "Hesaplama Yöntemi", Grup: "Gösterge Kartı"),
            new("hedefGrup",     "hedef_grup",     "metin", Yazilabilir: false,
                Baslik: "Hedef Grup", Grup: "Gösterge Kartı"),
            new("haric",         "haric",          "metin", Yazilabilir: false,
                Baslik: "Hariç Tutulacaklar", Grup: "Gösterge Kartı"),
            new("teknikNot",     "teknik_not",     "metin", Yazilabilir: false,
                Baslik: "Teknik Notlar", Grup: "Gösterge Kartı"),

            // ---- Hedef: rehberinki okunur, kurumunki yazılır ----
            new("hedefMetin",  "hedef_metin",  "metin",   Yazilabilir: false,
                Baslik: "Rehber Hedefi", Grup: "Hedef"),
            new("hedefYon",    "hedef_yon",    "kod",     Yazilabilir: false,
                Baslik: "Rehber Yönü", Grup: "Hedef", SabitKodlar: KkKartYonKodlari),
            new("hedefDeger",  "hedef_deger",  "ondalik", Yazilabilir: false,
                Baslik: "Rehber Değeri", Grup: "Hedef"),
            new("hedefBirim",  "hedef_birim",  "metin",   Yazilabilir: false,
                Baslik: "Birim", Grup: "Hedef"),
            new("kurumHedefYon",   "kurum_hedef_yon",   "kod", Baslik: "Kurum Hedefi Yönü",
                Grup: "Hedef", SabitKodlar: KkKartYonKodlari, EnFazlaUzunluk: 2),
            new("kurumHedefDeger", "kurum_hedef_deger", "ondalik",
                Baslik: "Kurum Hedefi", Grup: "Hedef"),

            new("periyotMetin", "periyot_metin", "metin", Yazilabilir: false,
                Baslik: "Veri Analiz Periyodu", Grup: "Ölçüm"),
            new("periyot",  "periyot",  "kod", Yazilabilir: false, Baslik: "Periyot",
                Grup: "Ölçüm", SabitKodlar: KkKartPeriyotKodlari),
            new("otomatik", "otomatik", "kod", Yazilabilir: false, Baslik: "Veri Kaynağı",
                Grup: "Ölçüm", SabitKodlar: KkKartOtomatikKodlari),
        });

    private static KartTanimi KlinikGostergeDonem() => new(
        Ad: "klinikGostergeDonem",
        YetkiKodu: "klinik_kalite.donem",
        Tablo: "public.klinik_gosterge_donem",
        LogTabloId: 1031,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("gostergeId", "gosterge_id", "sayi", Zorunlu: true, Baslik: "Gösterge",
                Grup: "Dönem", KodTablosu: "public.v_klinik_gosterge_lookup"),
            new("donemYil", "donem_yil", "sayi", Zorunlu: true, Baslik: "Yıl", Grup: "Dönem"),
            new("donemNo",  "donem_no",  "sayi", Zorunlu: true, Baslik: "Dönem No",
                Grup: "Dönem"),
            new("periyot",  "periyot",   "kod",  Zorunlu: true, Baslik: "Periyot",
                Grup: "Dönem", SabitKodlar: KkKartPeriyotKodlari),

            new("pay",   "pay",   "ondalik", Baslik: "Pay",   Grup: "Ölçüm"),
            new("payda", "payda", "ondalik", Baslik: "Payda", Grup: "Ölçüm"),
            // Tetik yazar - formda görünür, yazılamaz.
            new("sonuc", "sonuc", "ondalik", Yazilabilir: false, Baslik: "Sonuç",
                Grup: "Ölçüm"),
            // Ölçüm anındaki hedef DONDURULUR: rehber hedefi sonradan değişirse
            //   geçmiş dönemin "hedefte miydi" yargısı değişmemeli.
            new("hedefYon",   "hedef_yon",   "kod",     Baslik: "Hedef Yönü", Grup: "Ölçüm",
                SabitKodlar: KkKartYonKodlari, EnFazlaUzunluk: 2),
            new("hedefDeger", "hedef_deger", "ondalik", Baslik: "Hedef Değeri", Grup: "Ölçüm"),

            new("durum",  "durum",  "kod", Baslik: "Kayıt Durumu", Grup: "Ölçüm",
                SabitKodlar: KkKartDonemDurumKodlari),
            new("kaynak", "kaynak", "kod", Baslik: "Ölçüm Kaynağı", Grup: "Ölçüm",
                SabitKodlar: KkKartOlcumKaynakKodlari),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Ölçüm"),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["periyot"] = 6,
            ["durum"]   = 0,
            ["kaynak"]  = 1,       // kart uzerinden acilan olcum ELLE girilmistir
        });

    private static readonly Dictionary<string, string> KkKartPeriyotKodlari = new()
    {
        ["3"] = "3 aylık", ["6"] = "6 aylık", ["12"] = "Yıllık",
    };

    private static readonly Dictionary<string, string> KkKartYonKodlari = new()
    {
        [">="] = "≥ (en az)", ["<="] = "≤ (en çok)", [">"] = "> (büyük)", ["<"] = "< (küçük)",
    };

    private static readonly Dictionary<string, string> KkKartOtomatikKodlari = new()
    {
        ["1"] = "Otomatik (kod listesi var)", ["0"] = "Elle giriş",
    };

    private static readonly Dictionary<string, string> KkKartAktifKodlari = new()
    {
        ["1"] = "Yürürlükte", ["0"] = "Kaldırıldı",
    };

    private static readonly Dictionary<string, string> KkKartDonemDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Kesinleşti",
    };

    private static readonly Dictionary<string, string> KkKartOlcumKaynakKodlari = new()
    {
        ["0"] = "Otomatik", ["1"] = "Elle",
    };
}
