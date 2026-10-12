namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1048/1049) — AYAR kartları: birim kalite sorumlusu ve
/// komite (+ üyeler). Log tablo kodları 1400 bloğu (1400-1409 ayarlar).
///
/// ŞUBE: ikisi de KURUM GENELİ (sube_id 0) - kart şube damgalamaz. Komite
/// tohumları (1048) 0 ile geldi; şube damgalı kart onları açamazdı.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysBirimSorumlu = 1400;
    private const int LogKysKomite       = 1401;
    private const int LogKysKomiteUye    = 1402;

    private static readonly Dictionary<string, string> KysAktifKodlari = new() { ["1"] = "Aktif", ["0"] = "Pasif" };

    private static KartTanimi KysBirimSorumluKarti() => new(
        Ad: "kys-birim-sorumlu",
        YetkiKodu: "kys.ayar",
        Tablo: "public.kalite_birim_sorumlu",
        LogTabloId: LogKysBirimSorumlu,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",              "sayi",  Yazilabilir: false),
            new("departmanId",   "departman_id",    "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Birim", Grup: "Birim"),
            new("sorumluId",     "sorumlu_id",      "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Kalite sorumlusu", Grup: "Birim"),
            new("yedekId",       "yedek_id",        "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Yedek sorumlu", Grup: "Birim"),
            new("kontrolEdenId", "kontrol_eden_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Kontrol eden (birim yöneticisi)", Grup: "Birim"),
            new("aktif",         "aktif",           "kod",   SabitKodlar: KysAktifKodlari, Baslik: "Durum", Grup: "Birim"),
            new("aciklama",      "aciklama",        "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Birim"),
        });

    private static KartTanimi KysKomiteKarti() => new(
        Ad: "kys-komite",
        YetkiKodu: "kys.ayar",
        Tablo: "public.kalite_komite",
        LogTabloId: LogKysKomite,
        // Komite toplantı / olay / DÖF kayıtlarında geçer (diğer kalite ekranları):
        //   silinmez, pasife alınır - kayıtlardaki komite adı boşa düşmesin.
        SilmeYok: true,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1, ["toplantiPeriyotAy"] = (short)3 },
        Alanlar: new KartAlani[]
        {
            new("id",                "id",                  "sayi",  Yazilabilir: false),
            new("kod",               "kod",                 "metin", EnFazlaUzunluk: 20, Baslik: "Kod (HGK, EKK...)", Grup: "Komite"),
            new("ad",                "ad",                  "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Komite", Grup: "Komite"),
            new("baskanId",          "baskan_id",           "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Başkan", Grup: "Komite"),
            new("sekreterId",        "sekreter_id",         "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sekreter", Grup: "Komite"),
            new("toplantiPeriyotAy", "toplanti_periyot_ay", "sayi",  Baslik: "Toplantı periyodu (ay)", Grup: "Komite"),
            new("sira",              "sira",                "sayi",  Baslik: "Sıra", Grup: "Komite"),
            new("aktif",             "aktif",               "kod",   SabitKodlar: KysAktifKodlari, Baslik: "Durum", Grup: "Komite"),
            new("gorevAlani",        "gorev_alani",         "metin", EnFazlaUzunluk: 1000, Baslik: "Görev alanı", Grup: "Görev"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("uyeler", "public.kalite_komite_uye", "komite_id", new KartAlani[]
            {
                new("id",      "id",       "sayi",  Yazilabilir: false),
                new("tarafId", "taraf_id", "kod",   Zorunlu: true, KodTablosu: "public.v_personel_lookup", Baslik: "Üye"),
                new("gorev",   "gorev",    "metin", EnFazlaUzunluk: 60, Baslik: "Görev (Üye, Raportör...)"),
            }, Sirala: "id", SubeKolonu: null, Baslik: "Üyeler", LogTabloId: LogKysKomiteUye),
        });
}
