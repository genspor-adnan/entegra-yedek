namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MİKROBİYOLOJİ KARTLARI (436) — besiyeri, organizma, antibiyotik.
///
/// Kültürün KENDİSİNİN kartı yok: kültür bir kayıt değil bir süreçtir
/// (ekim → okuma → izolat → antibiyogram → onay) ve adımları uçlardan
/// yürür. Serbest düzenlenebilir bir kart, "48. saatte okundu" kaydını
/// geriye dönük değiştirilebilir kılardı.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> BesiyeriTurKodlari = new()
    {
        ["1"] = "Katı (agar)", ["2"] = "Sıvı (buyyon)",
        ["3"] = "Kan kültür şişesi", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> AtmosferKodlari = new()
    {
        ["1"] = "Aerob", ["2"] = "Anaerob", ["3"] = "%5 CO₂", ["4"] = "Mikroaerofil",
    };

    private static readonly Dictionary<string, string> OrganizmaTurKodlari = new()
    {
        ["1"] = "Bakteri", ["2"] = "Mantar", ["3"] = "Virüs", ["4"] = "Parazit",
        ["9"] = "Durum satırı (üreme yok / flora)",
    };

    private static readonly Dictionary<string, string> GramKodlari = new()
        { ["0"] = "Uygulanmaz", ["1"] = "Gram pozitif", ["2"] = "Gram negatif" };

    private static readonly Dictionary<string, string> MorfolojiKodlari = new()
    {
        ["0"] = "—", ["1"] = "Kok", ["2"] = "Basil", ["3"] = "Kokobasil",
        ["4"] = "Maya", ["5"] = "Küf", ["9"] = "Diğer",
    };

    // KADEMELİ BİLDİRİM BASAMAĞI: raporun neyi gösterip neyi gizleyeceğini
    //   belirler. Yanlış basamak, klinisyeni gereksiz yere karbapeneme
    //   yönlendirir - bu yüzden kartta açık açık yazılı.
    private static readonly Dictionary<string, string> AntibiyotikBasamakKodlari = new()
    {
        ["1"] = "1 · Dar spektrum (her zaman raporlanır)",
        ["2"] = "2 · Alternatif (1. basamakta duyarlı yoksa)",
        ["3"] = "3 · Kısıtlı / geniş spektrum (1 ve 2'de duyarlı yoksa)",
    };

    private static readonly Dictionary<string, string> UygulamaKodlari = new()
        { ["1"] = "Oral", ["2"] = "Parenteral", ["3"] = "Oral / parenteral" };

    private static KartTanimi LabBesiyeriKarti() => new(
        Ad: "lab-besiyeri",
        YetkiKodu: "lab.mikro",
        Tablo: "public.lab_besiyeri",
        LogTabloId: 1015,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,
            ["sicaklik"] = (short)37,
            ["atmosfer"] = (short)1,
            ["ilkOkumaSaat"] = (short)24,
            ["sonOkumaSaat"] = (short)48,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_kultur_besiyeri", "besiyeri_id",
                "Bu besiyeri kültürlerde kullanılmış - silinemez, pasife alın."),
            new("public.lab_tetkik_besiyeri", "besiyeri_id",
                "Bu besiyeri bir tetkiğin varsayılan setinde."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Besiyeri"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Besiyeri Adı", Grup: "Besiyeri"),
            new("tur", "tur", "kod", SabitKodlar: BesiyeriTurKodlari,
                Baslik: "Tür", Grup: "Besiyeri"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Besiyeri"),

            // OKUMA PLANI buradan kurulur: 24 saatlik plakayı 48. saatte
            //   okumak negatif raporu güvenilmez yapar.
            new("sicaklik", "sicaklik", "sayi", Baslik: "İnkübasyon (°C)",
                Grup: "İnkübasyon"),
            new("atmosfer", "atmosfer", "kod", SabitKodlar: AtmosferKodlari,
                Baslik: "Atmosfer", Grup: "İnkübasyon"),
            new("ilkOkumaSaat", "ilk_okuma_saat", "sayi",
                Baslik: "İlk Okuma (saat)", Grup: "İnkübasyon"),
            new("sonOkumaSaat", "son_okuma_saat", "sayi",
                Baslik: "Son Okuma (saat)", Grup: "İnkübasyon"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "İnkübasyon"),
        });

    private static KartTanimi LabOrganizmaKarti() => new(
        Ad: "lab-organizma",
        YetkiKodu: "lab.mikro",
        Tablo: "public.lab_organizma",
        LogTabloId: 1016,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,
            ["gram"] = (short)0,
            ["morfoloji"] = (short)0,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_kultur_ureme", "organizma_id",
                "Bu organizma kültür sonuçlarında kullanılmış."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Organizma"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 160,
                Baslik: "Adı (latin)", Grup: "Organizma"),
            new("kisaAd", "kisa_ad", "metin", EnFazlaUzunluk: 60,
                Baslik: "Kısa Ad (rapor)", Grup: "Organizma"),
            new("tur", "tur", "kod", SabitKodlar: OrganizmaTurKodlari,
                Baslik: "Tür", Grup: "Organizma"),
            new("gram", "gram", "kod", SabitKodlar: GramKodlari,
                Baslik: "Gram", Grup: "Organizma"),
            new("morfoloji", "morfoloji", "kod", SabitKodlar: MorfolojiKodlari,
                Baslik: "Morfoloji", Grup: "Organizma"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Organizma"),

            // "Üreme yok" ve "normal flora" da birer SONUÇTUR: izolat satırı
            //   olmadan kültür kapatılamaz.
            new("sonucSatiri", "sonuc_satiri", "mantik",
                Baslik: "Durum satırı (üreme yok / flora)", Grup: "Bildirim"),
            new("bildirimiZorunlu", "bildirimi_zorunlu", "mantik",
                Baslik: "Bildirimi zorunlu etken", Grup: "Bildirim"),
            new("snomed", "snomed", "metin", EnFazlaUzunluk: 20,
                Baslik: "SNOMED", Grup: "Bildirim"),
            new("skrsKod", "skrs_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "SKRS Kodu", Grup: "Bildirim"),
        });

    private static KartTanimi LabAntibiyotikKarti() => new(
        Ad: "lab-antibiyotik",
        YetkiKodu: "lab.mikro",
        Tablo: "public.lab_antibiyotik",
        LogTabloId: 1017,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["basamak"] = (short)1,
            ["uygulama"] = (short)3,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_antibiyogram", "antibiyotik_id",
                "Bu antibiyotik antibiyogramlarda kullanılmış."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Antibiyotik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Adı", Grup: "Antibiyotik"),
            new("grup", "grup", "metin", EnFazlaUzunluk: 60,
                Baslik: "Grup (beta-laktam, kinolon…)", Grup: "Antibiyotik"),
            new("atc", "atc", "metin", EnFazlaUzunluk: 12,
                Baslik: "ATC", Grup: "Antibiyotik"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Antibiyotik"),

            new("basamak", "basamak", "kod", SabitKodlar: AntibiyotikBasamakKodlari,
                Baslik: "Kademeli Bildirim Basamağı", Grup: "Bildirim"),
            new("uygulama", "uygulama", "kod", SabitKodlar: UygulamaKodlari,
                Baslik: "Uygulama Yolu", Grup: "Bildirim"),
            // Nitrofurantoin/fosfomisin yalnız idrarda anlamlı: kan izolatında
            //   raporlanması tedaviyi yanlış yönlendirir.
            new("yalnizUriner", "yalniz_uriner", "mantik",
                Baslik: "Yalnız idrar kültüründe raporla", Grup: "Bildirim"),
        });
}
