namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — RİSK kartı (1052, sade). Skor GENERATED kolon
/// (olasılık × şiddet), kartta salt okunur. Log 1431.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysRisk = 1431;

    private static readonly Dictionary<string, string> KysRiskDurum = new()
    {
        ["1"] = "Açık", ["2"] = "Önlem uygulanıyor", ["3"] = "Kabul edildi", ["4"] = "Kapandı",
    };
    private static readonly Dictionary<string, string> KysRiskBesli = new()
    {
        ["1"] = "1 - Çok düşük", ["2"] = "2 - Düşük", ["3"] = "3 - Orta", ["4"] = "4 - Yüksek", ["5"] = "5 - Çok yüksek",
    };

    private static KartTanimi KysRiskKarti() => new(
        Ad: "kys-risk",
        YetkiKodu: "kys.risk",
        Tablo: "public.kalite_risk",
        LogTabloId: LogKysRisk,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["olasilik"] = (short)3, ["siddet"] = (short)3, ["durum"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",             "sayi",  Yazilabilir: false),
            new("no",            "no",             "metin", Yazilabilir: false, Baslik: "Risk No", Grup: "Risk"),
            new("surec",         "surec",          "metin", EnFazlaUzunluk: 120, Baslik: "Süreç", Grup: "Risk"),
            new("departmanId",   "departman_id",   "kod",   KodTablosu: "public.v_departman_lookup", Baslik: "Birim", Grup: "Risk"),
            new("tanim",         "tanim",          "metin", Zorunlu: true, EnFazlaUzunluk: 1000, Baslik: "Tehlike / risk", Grup: "Risk"),
            new("olasilik",      "olasilik",       "kod",   Zorunlu: true, SabitKodlar: KysRiskBesli, Baslik: "Olasılık (O)", Grup: "Risk"),
            new("siddet",        "siddet",         "kod",   Zorunlu: true, SabitKodlar: KysRiskBesli, Baslik: "Şiddet (Ş)", Grup: "Risk"),
            new("skor",          "skor",           "sayi",  Yazilabilir: false, Baslik: "Skor (O × Ş)", Grup: "Risk"),
            new("kontrolOnlem",  "kontrol_onlem",  "metin", EnFazlaUzunluk: 1000, Baslik: "Kontrol / önlem", Grup: "Risk"),
            new("sahipId",       "sahip_id",       "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Risk sahibi", Grup: "Risk"),
            new("gozdenGecirme", "gozden_gecirme", "tarih", Baslik: "Gözden geçirme tarihi", Grup: "Risk"),
            new("durum",         "durum",          "kod",   Zorunlu: true, SabitKodlar: KysRiskDurum, Baslik: "Durum", Grup: "Risk"),
        });
}
