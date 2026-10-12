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
    // Mockup Kalite2/risk_listesi.html (1062): "4 — Sık", "5 — Çok ciddi".
    private static readonly Dictionary<string, string> KysRiskOlasilik = new()
    {
        ["1"] = "1 — Çok nadir", ["2"] = "2 — Nadir", ["3"] = "3 — Ara sıra", ["4"] = "4 — Sık", ["5"] = "5 — Çok sık",
    };
    private static readonly Dictionary<string, string> KysRiskSiddet = new()
    {
        ["1"] = "1 — Önemsiz", ["2"] = "2 — Hafif", ["3"] = "3 — Orta", ["4"] = "4 — Ciddi", ["5"] = "5 — Çok ciddi",
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
            new("departmanId",   "departman_id",   "kod",   KodTablosu: "public.v_departman_lookup", Baslik: "Birim / süreç", Grup: "Risk"),
            new("tanim",         "tanim",          "metin", Zorunlu: true, EnFazlaUzunluk: 1000, Baslik: "Risk", Grup: "Risk"),
            new("olasilik",      "olasilik",       "kod",   Zorunlu: true, SabitKodlar: KysRiskOlasilik, Baslik: "Olasılık (1–5)", Grup: "Risk"),
            new("siddet",        "siddet",         "kod",   Zorunlu: true, SabitKodlar: KysRiskSiddet, Baslik: "Şiddet (1–5)", Grup: "Risk"),
            new("skor",          "skor",           "sayi",  Yazilabilir: false, Baslik: "Skor (O × Ş)", Grup: "Risk"),
            new("kontrolOnlem",  "kontrol_onlem",  "metin", EnFazlaUzunluk: 1000, Baslik: "Alınan / alınacak önlem", Grup: "Risk"),
            new("sahipId",       "sahip_id",       "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Risk sahibi", Grup: "Risk"),
            new("gozdenGecirme", "gozden_gecirme", "tarih", Baslik: "Gözden geçirme", Grup: "Risk"),
            new("durum",         "durum",          "kod",   Zorunlu: true, SabitKodlar: KysRiskDurum, Baslik: "Durum", Grup: "Risk"),
        });
}
