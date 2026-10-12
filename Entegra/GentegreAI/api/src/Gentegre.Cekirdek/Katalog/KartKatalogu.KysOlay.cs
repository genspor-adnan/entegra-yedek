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
            // Mockup Kalite2/olay_bildirim.html (1060): künye kimlik şeridinde,
            //   altında üç metin. Komite yok (sade - kolon durur, ekranda yok).
            new("no",                "no",                 "metin", Yazilabilir: false, Baslik: "No", Grup: "Kimlik"),
            new("tarih",             "tarih",              "zaman", Zorunlu: true, Baslik: "Tarih", Grup: "Kimlik"),
            new("tur",               "tur",                "kod",   Zorunlu: true, KodListesi: "kys.olay_tur", Baslik: "Tür", Grup: "Kimlik"),
            new("departmanId",       "departman_id",       "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Birim", Grup: "Kimlik"),
            new("zarar",             "zarar",              "kod",   Zorunlu: true, KodListesi: "kys.olay_zarar", Baslik: "Etki", Grup: "Kimlik"),
            new("durum",             "durum",              "kod",   Zorunlu: true, SabitKodlar: KysOlayDurum, Baslik: "Durum", Grup: "Kimlik"),
            new("anonim",            "anonim",             "mantik", Baslik: "Anonim (bildiren gösterilmez)", Grup: "Kimlik"),
            new("aciklama",          "aciklama",           "metin", Zorunlu: true, EnFazlaUzunluk: 2000, Baslik: "Ne oldu?", Grup: "Olay"),
            new("anlikMudahale",     "anlik_mudahale",     "metin", EnFazlaUzunluk: 1000, Baslik: "Hemen ne yapıldı?", Grup: "Olay"),
            new("degerlendirmeNotu", "degerlendirme_notu", "metin", EnFazlaUzunluk: 2000, Baslik: "Değerlendirme (kalite sorumlusu)", Grup: "Olay"),
        });
}
