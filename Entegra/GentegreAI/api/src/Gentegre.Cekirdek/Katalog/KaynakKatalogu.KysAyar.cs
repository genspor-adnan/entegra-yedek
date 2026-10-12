namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1048/1049) — AYAR listeleri: birim kalite sorumluları ve
/// komiteler. Mockup Ekranlar/Kalite/kalite_ayarlar.html (Birimler &amp; Sorumlular,
/// Komiteler sekmeleri); Kalite Ayarları sayfası bu kartlara bağlanır.
///
/// Kalite dokümanları için AYRI KAYNAK YOK: Kalite menüsündeki liste doküman
/// kaynağını ("dokuman") kategori yoluna süzer, kart doküman kartıdır.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Birim (departman) başına kalite sorumlusu / yedeği / kontrol eden.</summary>
    private static KaynakTanimi KysBirimSorumlu() => new(
        Ad: "kys-birim-sorumlu",
        YetkiKodu: "kys.ayar",
        Kaynak: "public.v_kalite_birim_sorumlu s",
        // Şube 0 = tüm şubeler (1048 varsayılanı).
        SubeKosulu: "(s.sube_id = 0 or s.sube_id = {sube})",
        VarsayilanSirala: "s.departman_adi, s.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",             "s.id",               "sayi",  "Id", Varsayilan: false),
            new("departmanAdi",   "s.departman_adi",    "metin", "Birim", Genislik: 220),
            new("departmanKodu",  "s.departman_kodu",   "metin", "Birim Kodu", Hizalama: "orta", Genislik: 90, Varsayilan: false),
            new("sorumluAdi",     "s.sorumlu_adi",      "metin", "Kalite Sorumlusu", Genislik: 190),
            new("yedekAdi",       "s.yedek_adi",        "metin", "Yedek", Genislik: 170),
            new("kontrolEdenAdi", "s.kontrol_eden_adi", "metin", "Kontrol Eden (Birim Yön.)", Genislik: 190),
            new("aciklama",       "s.aciklama",         "metin", "Açıklama", Genislik: 220),
            new("aktifAdi",       "s.aktif_adi",        "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 90, Filtrelenebilir: false),
            new("aktif",          "s.aktif",            "mantik", "Aktif", Varsayilan: false),
            new("sorumluYok",     "case when s.sorumlu_id is null then 1 else 0 end", "mantik", "Sorumlusuz", Varsayilan: false),
            new("departmanId",    "s.departman_id",     "sayi",  "Birim Id", Varsayilan: false),
        });

    /// <summary>Komiteler (Hasta Güvenliği, Çalışan Güvenliği, Enfeksiyon Kontrol, Tesis Güvenliği...).</summary>
    private static KaynakTanimi KysKomite() => new(
        Ad: "kys-komite",
        YetkiKodu: "kys.ayar",
        Kaynak: "public.v_kalite_komite k",
        SubeKosulu: "(k.sube_id = 0 or k.sube_id = {sube})",
        VarsayilanSirala: "k.sira, k.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",                "k.id",                  "sayi",  "Id", Varsayilan: false),
            new("kod",               "k.kod",                 "metin", "Kod", Hizalama: "orta", Genislik: 70),
            new("ad",                "k.ad",                  "metin", "Komite", Genislik: 230),
            new("baskanAdi",         "k.baskan_adi",          "metin", "Başkan", Genislik: 170),
            new("sekreterAdi",       "k.sekreter_adi",        "metin", "Sekreter", Genislik: 170),
            new("uyeSayisi",         "k.uye_sayisi",          "sayi",  "Üye", Hizalama: "orta", Genislik: 70),
            new("toplantiPeriyotAy", "k.toplanti_periyot_ay", "sayi",  "Toplantı (ay)", Hizalama: "orta", Genislik: 100),
            new("gorevAlani",        "k.gorev_alani",         "metin", "Görev Alanı", Genislik: 320),
            new("aktifAdi",          "k.aktif_adi",           "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 90, Filtrelenebilir: false),
            new("aktif",             "k.aktif",               "mantik", "Aktif", Varsayilan: false),
            new("sira",              "k.sira",                "sayi",  "Sıra", Varsayilan: false),
        });
}
