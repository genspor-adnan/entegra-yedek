namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — TEDARİKÇİ DEĞERLENDİRME (1057), mockup
/// <c>Ekranlar/Kalite2/tedarikci.html</c> (sade, ISO 9001 md. 8.4).
/// Satır = değerlendirilmiş tedarikçinin SON değerlendirmesi (onaylı tedarikçi
/// listesi); puan / sonuç tabloda GENERATED. Uygunsuzluk = tedarikçi kaynaklı
/// DÖF (kaynak_tur 8) sayısı. Tedarikçi mevcut taraf kartıdır.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysTedarikci() => new(
        Ad: "kys-tedarikci",
        YetkiKodu: "kys.tedarikci",
        Kaynak: "public.v_kalite_tedarikci d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.tedarikci_adi",
        PortalKosullari: PortalKapsam.Kur(disDoktor: "false", disKurum: "false", hasta: "false"),
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "d.id",            "sayi",    "Id", Varsayilan: false),
            new("tedarikciAdi", "d.tedarikci_adi", "metin",   "Tedarikçi", Genislik: 220),
            new("neAliniyor",   "d.ne_aliniyor",   "metin",   "Ne alıyoruz", Genislik: 170),
            new("kalite",       "d.kalite",        "sayi",    "Kalite", Hizalama: "orta"),
            new("teslim",       "d.teslim",        "sayi",    "Teslim", Hizalama: "orta"),
            new("fiyat",        "d.fiyat",         "sayi",    "Fiyat", Hizalama: "orta"),
            new("puan",         "d.puan",          "sayi",    "Puan", Hizalama: "orta", Bicim: "#,##0.0"),
            new("sonucAdi",     "d.sonuc_adi",     "metin",   "Sonuç", Genislik: 90, Bicim: "rozet"),
            new("tarih",        "d.tarih",         "tarih",   "Son değerlendirme"),
            // Mockup (1066): uygunsuzluk tek kolonda "3 · DÖF-2026-018", yoksa "—".
            new("uygunsuzlukMetin", "d.uygunsuzluk_metin", "metin", "Uygunsuzluk", Genislik: 150),
            new("uygunsuzluk",  "d.uygunsuzluk",   "sayi",    "Uygunsuzluk sayısı", Hizalama: "orta", Varsayilan: false),
            new("sonDofNo",     "d.son_dof_no",    "metin",   "Son DÖF", Genislik: 120, Varsayilan: false),
            new("aciklama",     "d.aciklama",      "metin",   "Açıklama", Genislik: 220, Varsayilan: false),
            new("sonuc",        "d.sonuc",         "sayi",    "Sonuç Kodu", Varsayilan: false),
            new("vakti",        "d.vakti",         "sayi",    "Değerlendirme vakti", Varsayilan: false),
            new("tarafId",      "d.taraf_id",      "sayi",    "Tedarikçi Id", Varsayilan: false),
        });
}
