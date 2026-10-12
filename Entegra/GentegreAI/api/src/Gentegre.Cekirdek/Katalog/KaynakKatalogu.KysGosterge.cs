namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1053) — göstergeler listesi: son dönem değeri ve hedefte /
/// hedef dışı durumu. Klinik Kalite göstergeleri (711) ayrı modüldür.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysGosterge() => new(
        Ad: "kys-gosterge",
        YetkiKodu: "kys.gosterge",
        Kaynak: "public.v_kalite_gosterge g",
        SubeKolonu: null,
        VarsayilanSirala: "g.aktif desc, g.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "g.id",          "sayi",    "Id", Varsayilan: false),
            new("kod",         "g.kod",         "metin",   "Kod", Genislik: 90),
            new("ad",          "g.ad",          "metin",   "Gösterge", Genislik: 260),
            new("birimAdi",    "g.birim_adi",   "metin",   "Birim", Genislik: 150),
            new("periyotAdi",  "g.periyot_adi", "metin",   "Periyot", Genislik: 70),
            new("periyotAy",   "g.periyot_ay",  "sayi",    "Periyot (ay)", Varsayilan: false),
            new("hedefMetin",  "g.hedef_metin", "metin",   "Hedef", Hizalama: "sag", Genislik: 70),
            new("sonDonem",    "g.son_donem",   "tarih",   "Son dönem"),
            new("sonDeger",    "g.son_deger",   "ondalik", "Son değer", Hizalama: "sag"),
            new("durumAdi",    "g.durum_adi",   "metin",   "Durum", Genislik: 90, Bicim: "rozet"),
            new("sorumluAdi",  "g.sorumlu_adi", "metin",   "Sorumlu", Genislik: 140, Varsayilan: false),
            // Hedefler sekmesi (1063, mockup Kalite2/hedefler.html): ölçü + son üç ay.
            new("olcu",        "g.olcu",        "metin",   "Ölçü", Genislik: 80, Varsayilan: false),
            new("m1",          "g.m1",          "ondalik", "3 ay önce", Hizalama: "sag", Varsayilan: false),
            new("m2",          "g.m2",          "ondalik", "2 ay önce", Hizalama: "sag", Varsayilan: false),
            new("m3",          "g.m3",          "ondalik", "Geçen ay", Hizalama: "sag", Varsayilan: false),
            new("sorumluId",   "g.sorumlu_id",  "sayi",    "Sorumlu Id", Varsayilan: false),
            new("formul",      "g.formul",      "metin",   "Formül", Genislik: 220, Varsayilan: false),
            new("aktif",       "g.aktif",       "sayi",    "Aktif", Varsayilan: false),
            // "DÖF aç" (1059) birimi bundan doldurur.
            new("departmanId", "g.departman_id", "sayi",   "Birim Id", Varsayilan: false),
            new("hedef",       "g.hedef",       "ondalik", "Hedef değer", Varsayilan: false),
        });
}
