namespace Gentegre.Cekirdek.Katalog;

public static partial class KaynakKatalogu
{
    /// <summary>
    /// ARIZA / TALEP (hizmet masası, 911) — demirbaş-bağımsız arıza bildirimi.
    /// Kategori → ekip yönlendirmeli; ekip devralır, çözer, kapatır.
    /// Liste yetkisi <c>ariza</c> (ekip); self-servis açış ayrı uçtan (ariza.talep).
    /// </summary>
    private static KaynakTanimi ArizaTalep() => new(
        Ad: "ariza-talep",
        YetkiKodu: "ariza",
        Kaynak: "public.v_ariza_talep t",
        SubeKolonu: "t.sube_id",
        VarsayilanSirala: "t.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "t.id",             "sayi",  "Id", Varsayilan: false),
            new("talepNo",      "t.talep_no",       "metin", "Talep No", Genislik: 100),
            new("ekleme",       "t.ekleme_tarihi",  "zaman", "Açılış", Genislik: 130),
            new("kategoriAdi",  "t.kategori_adi",   "metin", "Kategori", Genislik: 130, Bicim: "rozet"),
            new("ekipAdi",      "t.ekip_adi",       "metin", "Ekip", Genislik: 120, Bicim: "rozet"),
            new("oncelikAdi",   "t.oncelik_adi",    "metin", "Öncelik", Genislik: 80, Bicim: "rozet"),
            new("konum",        "t.konum",          "metin", "Konum", Genislik: 160),
            new("aciklama",     "t.aciklama",       "metin", "Açıklama", Genislik: 260),
            new("demirbasAdi",  "t.demirbas_adi",   "metin", "Demirbaş", Genislik: 160),
            new("talepEdenAdi", "t.talep_eden_adi", "metin", "Talep Eden", Genislik: 150),
            new("sorumluAdi",   "t.sorumlu_adi",    "metin", "Sorumlu", Genislik: 150),
            new("durumAdi",     "t.durum_adi",      "metin", "Durum", Genislik: 100, Bicim: "rozet"),
            // Ham kod kolonları (filtre/aksiyon için, gridde gizli).
            new("kategori",     "t.kategori",       "sayi",  "Kategori Kodu", Varsayilan: false),
            new("ekip",         "t.ekip",           "sayi",  "Ekip Kodu", Varsayilan: false),
            new("durum",        "t.durum",          "sayi",  "Durum Kodu", Varsayilan: false),
            new("oncelik",      "t.oncelik",        "sayi",  "Öncelik Kodu", Varsayilan: false),
        });
}
