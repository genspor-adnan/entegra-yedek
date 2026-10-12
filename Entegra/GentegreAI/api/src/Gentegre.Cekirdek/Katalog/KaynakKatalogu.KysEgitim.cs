namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1056) — Eğitim &amp; Yetkinlik (sade, ISO 9001 7.2).
/// Mockup Ekranlar/Kalite2/egitim.html.
///
/// Eğitimler AYRI TABLODA DEĞİL: İK'nın personel_egitim satırları (kişi başı)
/// eğitim bazında gruplanır (v_kalite_egitim, id = grubun en küçük satırı).
/// Kayıt / düzenleme özel kartta (KysEgitimUclari) - generic kart kişi başı
/// satırı açardı, katılımcı listesini değil.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysEgitim() => new(
        Ad: "kys-egitim",
        YetkiKodu: "kys.egitim",
        Kaynak: "public.v_kalite_egitim e",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.tarih desc nulls last, e.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",           "sayi",  "Id", Varsayilan: false),
            new("tarih",        "e.tarih",        "tarih", "Tarih"),
            new("ad",           "e.ad",           "metin", "Eğitim", Genislik: 260),
            new("zorunluAdi",   "e.zorunlu_adi",  "metin", "Zorunlu", Hizalama: "orta", Bicim: "rozet", Genislik: 100),
            new("egitmen",      "e.egitmen",      "metin", "Eğitmen / Kurum", Genislik: 170),
            new("katilimci",    "e.katilimci",    "sayi",  "Katılımcı", Hizalama: "orta"),
            new("katilimcilar", "e.katilimcilar", "metin", "Katılımcılar", Genislik: 280, Varsayilan: false),
            new("turAdi",       "e.tur_adi",      "metin", "Tür", Genislik: 90, Varsayilan: false),
            new("gecerlilik",   "e.gecerlilik",   "metin", "Geçerlilik", Genislik: 110, Varsayilan: false),
            new("tarihMetin",   "e.tarih_metin",  "metin", "Tarih (girilen)", Varsayilan: false),
            new("zorunlu",      "e.zorunlu",      "mantik", "Zorunlu mu", Varsayilan: false),
            // Mockup "Belge" kolonu (1065): katılım listesi / sertifika eki sayısı.
            new("belgeSayisi",  "e.belge_sayisi", "sayi",  "Belge", Hizalama: "orta"),
        });

    /// <summary>Eksik zorunlu eğitim: hiç almamış, süresi geçmiş ya da 60 gün içinde dolacak.</summary>
    private static KaynakTanimi KysEgitimEksik() => new(
        Ad: "kys-egitim-eksik",
        YetkiKodu: "kys.egitim",
        Kaynak: "public.v_kalite_egitim_eksik x",
        SubeKolonu: null,
        VarsayilanSirala: "x.birim, x.ad, x.eksik_egitim",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "x.id",            "sayi",  "Id", Varsayilan: false),
            new("ad",           "x.ad",            "metin", "Personel", Genislik: 190),
            new("birim",        "x.birim",         "metin", "Birim", Genislik: 180),
            new("eksikEgitim",  "x.eksik_egitim",  "metin", "Eksik eğitim", Genislik: 240),
            new("sonAlis",      "x.son_alis",      "tarih", "Son aldığı"),
            new("sonTarih",     "x.son_tarih",     "tarih", "Son tarih"),
            new("durumAdi",     "x.durum_adi",     "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 110),
            new("personelId",   "x.personel_id",   "sayi",  "Personel Id", Varsayilan: false),
            new("departmanId",  "x.departman_id",  "sayi",  "Birim Id", Varsayilan: false),
        });

    /// <summary>Zorunlu eğitim tanımları (birim boş = herkes, periyot boş = bir kez).</summary>
    private static KaynakTanimi KysZorunluEgitim() => new(
        Ad: "kys-zorunlu-egitim",
        YetkiKodu: "kys.egitim",
        Kaynak: "public.v_kalite_zorunlu_egitim z",
        // Şube 0 = kurum geneli (tanımlar şube damgalanmaz).
        SubeKosulu: "(z.sube_id = 0 or z.sube_id = {sube})",
        VarsayilanSirala: "z.egitim_adi, z.birim",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "z.id",          "sayi",  "Id", Varsayilan: false),
            new("egitimAdi",   "z.egitim_adi",  "metin", "Eğitim", Genislik: 260),
            new("birim",       "z.birim",       "metin", "Birim", Genislik: 180),
            new("periyotAdi",  "z.periyot_adi", "metin", "Periyot", Genislik: 110),
            new("eksik",       "z.eksik",       "sayi",  "Eksik kişi", Hizalama: "orta"),
            new("aktifAdi",    "z.aktif_adi",   "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 80, Filtrelenebilir: false),
            new("aciklama",    "z.aciklama",    "metin", "Açıklama", Genislik: 200, Varsayilan: false),
            new("aktif",       "z.aktif",       "mantik", "Aktif", Varsayilan: false),
            new("departmanId", "z.departman_id", "sayi", "Birim Id", Varsayilan: false),
        });
}
