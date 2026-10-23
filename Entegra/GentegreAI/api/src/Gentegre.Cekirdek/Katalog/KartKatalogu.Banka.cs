namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BANKA HAREKETİ ÖNERİ KURALI kartı (1157). Sistem kuralları (IBAN / VKN / fatura no / kendi hesabı)
/// kapatılabilir, koşulu değiştirilemez; kullanıcı kuralı "açıklama içerir" ile yazılır.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> BankaKosulKodlari = new()
    {
        ["aciklama"] = "Açıklama içerir", ["iban"] = "Karşı IBAN carinin listesinde",
        ["vkn"] = "Karşı VKN / TCKN cari kaydında", ["fatura"] = "Açıklamada açık fatura no",
        ["kendi_hesap"] = "Karşı IBAN kendi hesabımız",
    };
    private static readonly Dictionary<string, string> BankaSonucKodlari = new()
    {
        ["cari"] = "Cariye tahsilat / tediye", ["masraf"] = "Masraf", ["pos"] = "POS'tan bankaya aktarım",
        ["virman"] = "Virman (kendi hesap)", ["yoksay"] = "Yoksay", ["tahsilat_tediye"] = "Tahsilat / Tediye (eşleşen cari)",
    };

    private static KartTanimi BankaKural() => new(
        Ad: "banka-kural",
        YetkiKodu: "banka.kural",
        Tablo: "public.banka_kural",
        LogTabloId: 1387,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["aktif"] = (short)1, ["sira"] = (short)100, ["kosulTur"] = "aciklama", ["yon"] = (short)0, ["sonuc"] = "cari" },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",              "sayi",   Yazilabilir: false),
            new("ad",            "ad",              "metin",  Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Kural Adı", Grup: "Kimlik"),
            new("sira",          "sira",            "sayi",   Baslik: "Sıra", Grup: "Kimlik"),
            new("aktif",         "aktif",           "mantik", Baslik: "Aktif", Grup: "Kimlik"),
            new("kosulTur",      "kosul_tur",       "kod",    Zorunlu: true, SabitKodlar: BankaKosulKodlari, Baslik: "Koşul", Grup: "Genel", AltGrup: "Koşul"),
            new("kosulMetin",    "kosul_metin",     "metin",  EnFazlaUzunluk: 120, Baslik: "Açıklamada geçen metin", Grup: "Genel", AltGrup: "Koşul"),
            new("yon",           "yon",             "kod",    SabitKodlar: new Dictionary<string, string> { ["0"] = "Gelen ve giden", ["1"] = "Yalnız gelen", ["-1"] = "Yalnız giden" },
                                                              Baslik: "Yön", Grup: "Genel", AltGrup: "Koşul"),
            new("hesapId",       "hesap_id",        "kod",    KodTablosu: "public.v_hesap_lookup", Baslik: "Yalnız bu banka hesabı (boş = hepsi)", Grup: "Genel", AltGrup: "Koşul"),
            new("sonuc",         "sonuc",           "kod",    Zorunlu: true, SabitKodlar: BankaSonucKodlari, Baslik: "Sonuç", Grup: "Genel", AltGrup: "Sonuç"),
            new("hedefTarafId",  "hedef_taraf_id",  "kod",    KodTablosu: "public.v_cari_lookup", Baslik: "Cari", Grup: "Genel", AltGrup: "Sonuç"),
            new("hedefHesapId",  "hedef_hesap_id",  "kod",    KodTablosu: "public.v_hesap_lookup", Baslik: "Karşı hesap (virman / POS)", Grup: "Genel", AltGrup: "Sonuç"),
            new("hedefMasrafId", "hedef_masraf_id", "kod",    KodTablosu: "public.v_masraf_lookup", Baslik: "Masraf kalemi", Grup: "Genel", AltGrup: "Sonuç"),
            new("sistem",        "sistem",          "mantik", Yazilabilir: false, Baslik: "Sistem kuralı"),
        });
}
