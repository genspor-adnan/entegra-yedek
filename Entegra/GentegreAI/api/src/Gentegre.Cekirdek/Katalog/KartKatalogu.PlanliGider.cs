namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PLANLI GİDER KATEGORİSİ (1177): kategori seçilince planlı gider kartının BOŞ alanlarını dolduran
/// öntanımlar (masraf kalemi, tutar türü, tatil kuralı, hatırlatma - karar 25.10.2026). Sekiz
/// kategori kurulumla gelir; kurum ekleyebilir. Tanımın kendisi özel uçta (/api/planli-gider).
/// </summary>
public static partial class KartKatalogu
{
    internal static readonly Dictionary<string, string> PlanliGiderTutarTurleri = new()
    {
        ["1"] = "Sabit", ["2"] = "Son N dönem ortalaması", ["3"] = "Geçen yıl aynı ay",
        ["4"] = "Hesaplanan (KDV / SGK)", ["5"] = "Elle (her dönem)",
    };

    internal static readonly Dictionary<string, string> PlanliGiderTatilKurallari = new()
    {
        ["2"] = "Sonraki iş günü", ["1"] = "Önceki iş günü", ["0"] = "Kaydırma",
    };

    private static KartTanimi PlanliGiderKategori() => new(
        Ad: "planliGiderKategori",
        YetkiKodu: "finans.planli_gider_kategori",
        Tablo: "public.planli_gider_kategori",
        LogTabloId: 1723,
        SubeKolonu: null,
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.planli_gider", "kategori_id",
                "Bu kategori planlı gider tanımlarında kullanılıyor; silmek yerine pasif yapın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 30, Baslik: "Kod", Grup: "Kategori"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Ad", Grup: "Kategori"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Kategori"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kategori"),
            new("masrafId", "masraf_id", "kod", KodTablosu: "public.v_masraf_lookup",
                Baslik: "Masraf kalemi", Grup: "Öntanımlar"),
            new("tutarTur", "tutar_tur", "kod", Baslik: "Tutar türü", Grup: "Öntanımlar",
                SabitKodlar: PlanliGiderTutarTurleri),
            new("hesapKaynak", "hesap_kaynak", "kod", Baslik: "Hesaplanan kaynak", Grup: "Öntanımlar",
                SabitKodlar: new Dictionary<string, string> { ["kdv"] = "KDV İcmali (ödenecek)", ["sgk"] = "SGK (son 3 ödeme ort.)" }),
            new("tatilKural", "tatil_kural", "kod", Baslik: "Tatile denk gelirse", Grup: "Öntanımlar",
                SabitKodlar: PlanliGiderTatilKurallari),
            new("hatirlatmaGun", "hatirlatma_gun", "sayi", Baslik: "Hatırlatma (gün önce · 0 = yok)", Grup: "Öntanımlar"),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = 1, ["tutar_tur"] = 1, ["hesap_kaynak"] = "", ["tatil_kural"] = 2, ["hatirlatma_gun"] = 0, ["sira"] = 100,
        });
}
