namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1053) — toplantılar (komite boş = YGG) ve Karar Takibi.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysToplanti() => new(
        Ad: "kys-toplanti",
        YetkiKodu: "kys.toplanti",
        Kaynak: "public.v_kalite_toplanti t",
        SubeKolonu: null,
        VarsayilanSirala: "t.tarih desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "t.id",           "sayi",  "Id", Varsayilan: false),
            new("tarih",       "t.tarih",        "tarih", "Tarih"),
            new("kurulAdi",    "t.kurul_adi",    "metin", "Komite / YGG", Genislik: 220),
            new("yer",         "t.yer",          "metin", "Yer", Genislik: 140),
            new("gundem",      "t.gundem",       "metin", "Gündem", Genislik: 280),
            new("kararSayisi", "t.karar_sayisi", "sayi",  "Karar", Hizalama: "orta"),
            new("acikKarar",   "t.acik_karar",   "sayi",  "Açık karar", Hizalama: "orta"),
            new("komiteId",    "t.komite_id",    "sayi",  "Komite Id", Varsayilan: false),
        });

    private static KaynakTanimi KysKarar() => new(
        Ad: "kys-karar",
        YetkiKodu: "kys.karar",
        Kaynak: "public.v_kalite_karar k",
        SubeKolonu: null,
        VarsayilanSirala: "k.durum, k.termin nulls last, k.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",             "k.id",              "sayi",  "Id", Varsayilan: false),
            new("toplantiTarihi", "k.toplanti_tarihi", "tarih", "Toplantı"),
            new("kurulAdi",       "k.kurul_adi",       "metin", "Komite / YGG", Genislik: 180),
            new("karar",          "k.karar",           "metin", "Karar", Genislik: 320),
            new("sorumluAdi",     "k.sorumlu_adi",     "metin", "Sorumlu", Genislik: 150),
            new("termin",         "k.termin",          "tarih", "Termin"),
            new("kalanGun",       "k.kalan_gun",       "sayi",  "Kalan gün", Hizalama: "orta"),
            new("durumAdi",       "k.durum_adi",       "metin", "Durum", Genislik: 80, Bicim: "rozet"),
            new("toplantiId",     "k.toplanti_id",     "sayi",  "Toplantı Id", Varsayilan: false),
            new("durum",          "k.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
        });
}
