namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — OLAY kartı (1052, sade). Kayıt silinmez: bildirim
/// kurumsal kayıttır, yanlışsa "Kapandı" + değerlendirme notu. Log 1430.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysOlay = 1430;

    private static readonly Dictionary<string, string> KysOlayDurum = new()
    {
        ["1"] = "Yeni", ["2"] = "Değerlendirmede", ["3"] = "Kapandı",
    };

    private static KartTanimi KysOlayKarti() => new(
        Ad: "kys-olay",
        YetkiKodu: "kys.olay",
        Tablo: "public.kalite_olay",
        LogTabloId: LogKysOlay,
        SubeKolonu: "sube_id",
        SilmeYok: true,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tarih"] = "@simdi", ["tur"] = (short)1, ["zarar"] = (short)2, ["durum"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",                "id",                 "sayi",  Yazilabilir: false),
            new("no",                "no",                 "metin", Yazilabilir: false, Baslik: "Olay No", Grup: "Olay"),
            new("tarih",             "tarih",              "zaman", Zorunlu: true, Baslik: "Tarih / saat", Grup: "Olay"),
            new("tur",               "tur",                "kod",   Zorunlu: true, KodListesi: "kys.olay_tur", Baslik: "Olay türü", Grup: "Olay"),
            new("departmanId",       "departman_id",       "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Birim", Grup: "Olay"),
            new("zarar",             "zarar",              "kod",   Zorunlu: true, KodListesi: "kys.olay_zarar", Baslik: "Zarar düzeyi", Grup: "Olay"),
            new("anonim",            "anonim",             "mantik", Baslik: "Anonim (bildiren gösterilmez)", Grup: "Olay"),
            new("aciklama",          "aciklama",           "metin", Zorunlu: true, EnFazlaUzunluk: 2000, Baslik: "Açıklama", Grup: "Olay"),
            new("anlikMudahale",     "anlik_mudahale",     "metin", EnFazlaUzunluk: 1000, Baslik: "Anlık müdahale", Grup: "Olay"),
            new("komiteId",          "komite_id",          "kod",   KodTablosu: "public.v_kalite_komite_lookup", Baslik: "Sorumlu komite", Grup: "Değerlendirme"),
            new("degerlendirmeNotu", "degerlendirme_notu", "metin", EnFazlaUzunluk: 2000, Baslik: "Değerlendirme notu", Grup: "Değerlendirme"),
            new("durum",             "durum",              "kod",   Zorunlu: true, SabitKodlar: KysOlayDurum, Baslik: "Durum", Grup: "Değerlendirme"),
        });
}
