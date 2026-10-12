namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — TEDARİKÇİ DEĞERLENDİRME kartı (1057, sade). Üç kriter
/// 1-5; puan (ortalama) ve sonuç (≥ 3,5 onaylı · ≥ 2,5 şartlı · altı red)
/// tabloda GENERATED, kartta salt okunur. Log 1470.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysTedarikci = 1470;

    private static readonly Dictionary<string, string> KysTedarikciBesli = new()
    {
        ["1"] = "1 - Çok kötü", ["2"] = "2 - Kötü", ["3"] = "3 - Orta", ["4"] = "4 - İyi", ["5"] = "5 - Çok iyi",
    };
    private static readonly Dictionary<string, string> KysTedarikciSonuc = new()
    {
        ["1"] = "Onaylı", ["2"] = "Şartlı", ["3"] = "Red",
    };

    private static KartTanimi KysTedarikciKarti() => new(
        Ad: "kys-tedarikci",
        YetkiKodu: "kys.tedarikci",
        Tablo: "public.kalite_tedarikci_deg",
        LogTabloId: LogKysTedarikci,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["kalite"] = (short)3, ["teslim"] = (short)3, ["fiyat"] = (short)3,
        },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",          "sayi",    Yazilabilir: false),
            new("tarafId",    "taraf_id",    "kod",     Zorunlu: true, KodTablosu: "public.v_cari_lookup", Baslik: "Tedarikçi", Grup: "Değerlendirme"),
            new("tarih",      "tarih",       "tarih",   Zorunlu: true, Baslik: "Değerlendirme tarihi", Grup: "Değerlendirme"),
            new("neAliniyor", "ne_aliniyor", "metin",   EnFazlaUzunluk: 200, Baslik: "Ne alıyoruz", Grup: "Değerlendirme"),
            new("kalite",     "kalite",      "kod",     Zorunlu: true, SabitKodlar: KysTedarikciBesli, Baslik: "Kalite", Grup: "Değerlendirme"),
            new("teslim",     "teslim",      "kod",     Zorunlu: true, SabitKodlar: KysTedarikciBesli, Baslik: "Teslim", Grup: "Değerlendirme"),
            new("fiyat",      "fiyat",       "kod",     Zorunlu: true, SabitKodlar: KysTedarikciBesli, Baslik: "Fiyat", Grup: "Değerlendirme"),
            new("puan",       "puan",        "ondalik", Yazilabilir: false, Baslik: "Puan (ortalama)", Grup: "Değerlendirme"),
            new("sonuc",      "sonuc",       "kod",     Yazilabilir: false, SabitKodlar: KysTedarikciSonuc, Baslik: "Sonuç", Grup: "Değerlendirme"),
            new("aciklama",   "aciklama",    "metin",   EnFazlaUzunluk: 1000, Baslik: "Açıklama", Grup: "Değerlendirme"),
        });
}
