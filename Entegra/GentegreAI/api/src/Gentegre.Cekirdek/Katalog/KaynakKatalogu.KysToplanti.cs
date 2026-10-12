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
            // Mockup Kalite2/toplanti_kararlar.html (1064): Tarih · Toplantı · Katılımcılar · Karar · Açık.
            new("toplantiAdi", "t.toplanti_adi", "metin", "Toplantı", Genislik: 220),
            new("katilimcilar","t.katilimcilar", "metin", "Katılımcılar", Genislik: 300),
            new("kurulAdi",    "t.kurul_adi",    "metin", "Komite / YGG", Genislik: 220, Varsayilan: false),
            new("yer",         "t.yer",          "metin", "Yer", Genislik: 140, Varsayilan: false),
            new("gundem",      "t.gundem",       "metin", "Gündem", Genislik: 280, Varsayilan: false),
            new("kararSayisi", "t.karar_sayisi", "sayi",  "Karar", Hizalama: "orta"),
            new("acikKarar",   "t.acik_karar",   "sayi",  "Açık", Hizalama: "orta"),
            new("komiteId",    "t.komite_id",    "sayi",  "Komite Id", Varsayilan: false),
        });

    private static KaynakTanimi KysKarar() => new(
        Ad: "kys-karar",
        YetkiKodu: "kys.toplanti",
        Kaynak: "public.v_kalite_karar k",
        SubeKolonu: null,
        VarsayilanSirala: "k.durum, k.termin nulls last, k.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",             "k.id",              "sayi",  "Id", Varsayilan: false),
            // Açık Kararlar sekmesi (1064): Toplantı · Karar · Sorumlu · Termin · Durum.
            new("toplantiAdi",    "k.toplanti_adi",    "metin", "Toplantı", Genislik: 180),
            new("toplantiTarihi", "k.toplanti_tarihi", "tarih", "Toplantı tarihi", Varsayilan: false),
            new("kurulAdi",       "k.kurul_adi",       "metin", "Komite / YGG", Genislik: 180, Varsayilan: false),
            new("karar",          "k.karar",           "metin", "Karar", Genislik: 320),
            new("sorumluAdi",     "k.sorumlu_adi",     "metin", "Sorumlu", Genislik: 150),
            new("termin",         "k.termin",          "tarih", "Termin"),
            new("kalanGun",       "k.kalan_gun",       "sayi",  "Kalan gün", Hizalama: "orta", Varsayilan: false),
            new("durumAdi",       "k.durum_adi",       "metin", "Durum", Genislik: 80, Bicim: "rozet"),
            new("toplantiId",     "k.toplanti_id",     "sayi",  "Toplantı Id", Varsayilan: false),
            new("durum",          "k.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
        });
}
