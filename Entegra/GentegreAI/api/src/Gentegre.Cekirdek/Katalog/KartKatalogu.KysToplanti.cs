namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1053) — toplantı kartı (komite boş = YGG; gündem ve
/// katılımcılar metin) + kararlar detayı; karar kartı Karar Takibi için.
/// Log tablo kodları 1443-1444.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysToplanti = 1443;
    private const int LogKysKarar    = 1444;

    private static readonly Dictionary<string, string> KysKararDurum = new() { ["1"] = "Devam", ["2"] = "Tamam", ["3"] = "İptal" };

    private static KartTanimi KysToplantiKarti() => new(
        Ad: "kys-toplanti",
        YetkiKodu: "kys.toplanti",
        Tablo: "public.kalite_toplanti",
        LogTabloId: LogKysToplanti,
        SubeKolonu: "sube_id",
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.kalite_karar", "toplanti_id", "Toplantının kararı var; önce kararları silin."),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tarih"] = "@simdi" },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",           "sayi",  Yazilabilir: false),
            // Mockup Kalite2/toplanti_kararlar.html (1064): ad + tarih + komite + yer şeritte,
            //   altında katılımcılar, gündem ve Kararlar (tek sayfa).
            new("baslik",       "baslik",       "metin", EnFazlaUzunluk: 120, Baslik: "Toplantı (YGG 2026/1...)", Grup: "Kimlik"),
            new("tarih",        "tarih",        "zaman", Zorunlu: true, Baslik: "Tarih / saat", Grup: "Kimlik"),
            new("komiteId",     "komite_id",    "kod",   KodTablosu: "public.v_kalite_komite_lookup", Baslik: "Komite (boş = YGG)", Grup: "Kimlik"),
            new("yer",          "yer",          "metin", EnFazlaUzunluk: 120, Baslik: "Yer", Grup: "Kimlik"),
            new("katilimcilar", "katilimcilar", "metin", EnFazlaUzunluk: 2000, Baslik: "Katılımcılar", Grup: "Toplantı"),
            new("gundem",       "gundem",       "metin", EnFazlaUzunluk: 4000, Baslik: "Gündem", Grup: "Toplantı"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("kararlar", "public.kalite_karar", "toplanti_id", new KartAlani[]
            {
                new("id",        "id",         "sayi",  Yazilabilir: false),
                new("karar",     "karar",      "metin", Zorunlu: true, EnFazlaUzunluk: 1000, Baslik: "Karar"),
                new("sorumluId", "sorumlu_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu"),
                new("termin",    "termin",     "tarih", Baslik: "Termin"),
                new("durum",     "durum",      "kod",   SabitKodlar: KysKararDurum, Baslik: "Durum"),
            }, Sirala: "id", Baslik: "Kararlar", LogTabloId: LogKysKarar),
        });

    private static KartTanimi KysKararKarti() => new(
        Ad: "kys-karar",
        YetkiKodu: "kys.toplanti",
        Tablo: "public.kalite_karar",
        LogTabloId: LogKysKarar,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",          "sayi",  Yazilabilir: false),
            new("toplantiId", "toplanti_id", "kod",   Zorunlu: true, KodTablosu: "public.v_kalite_toplanti_lookup", Baslik: "Toplantı", Grup: "Karar"),
            new("karar",      "karar",       "metin", Zorunlu: true, EnFazlaUzunluk: 1000, Baslik: "Karar", Grup: "Karar"),
            new("sorumluId",  "sorumlu_id",  "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Karar"),
            new("termin",     "termin",      "tarih", Baslik: "Termin", Grup: "Karar"),
            new("durum",      "durum",       "kod",   SabitKodlar: KysKararDurum, Baslik: "Durum", Grup: "Karar"),
        });
}
