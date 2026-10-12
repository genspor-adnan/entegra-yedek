namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — ÖLÇÜM CİHAZLARI &amp; KALİBRASYON (1058, sade), mockup
/// <c>Ekranlar/Kalite2/kalibrasyon.html</c>. Satır = kalibrasyona tâbi
/// demirbaş (ayrı envanter yok); durum / sonraki tarih görünümde
/// (v_kalite_kalibrasyon). Sabit Varlıklar › Kalibrasyon ekranı ayrı kodla durur.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysKalibrasyon() => new(
        Ad: "kys-kalibrasyon",
        YetkiKodu: "kys.kalibrasyon",
        Kaynak: "public.v_kalite_kalibrasyon c",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.durum desc, c.sonraki nulls first, c.no",
        PortalKosullari: PortalKapsam.Kur(disDoktor: "false", disKurum: "false", hasta: "false"),
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "c.id",             "sayi",   "Id", Varsayilan: false),
            new("no",            "c.no",             "metin",  "No", Genislik: 100),
            new("ad",            "c.ad",             "metin",  "Cihaz", Genislik: 240),
            new("seriNo",        "c.seri_no",        "metin",  "Seri No", Varsayilan: false),
            new("birimAdi",      "c.birim_adi",      "metin",  "Birim", Genislik: 150),
            // Mockup Kalite2/kalibrasyon.html (1067): Periyot "12 ay", Sonuç = durum, Sertifika 📎.
            new("periyotAdi",    "c.periyot_adi",    "metin",  "Periyot", Genislik: 80),
            new("periyotAy",     "c.periyot_ay",     "sayi",   "Periyot (ay)", Hizalama: "orta", Varsayilan: false),
            new("sonKalibrasyon","c.son_kalibrasyon","tarih",  "Son kalibrasyon"),
            new("sonraki",       "c.sonraki",        "tarih",  "Sonraki"),
            new("kalanGun",      "c.kalan_gun",      "sayi",   "Kalan gün", Hizalama: "sag", Varsayilan: false),
            new("durumAdi",      "c.durum_adi",      "metin",  "Sonuç", Genislik: 120, Bicim: "rozet"),
            new("sonSonucAdi",   "c.son_sonuc_adi",  "metin",  "Son kalibrasyon sonucu", Genislik: 110, Varsayilan: false),
            new("firmaAdi",      "c.firma_adi",      "metin",  "Kalibrasyon firması", Varsayilan: false),
            new("sertifikaSayisi","c.sertifika_sayisi","sayi", "Sertifika", Hizalama: "orta", Genislik: 80, Bicim: "atac"),
            new("sertifika",     "c.sertifika",      "mantik", "Sertifika var", Hizalama: "orta", Varsayilan: false),
            // 1 uygun · 2 yaklaşıyor · 3 süresi geçti (çip "30 gün içinde" = durum >= 2).
            new("durum",         "c.durum",          "sayi",   "Durum Kodu", Varsayilan: false),
            new("departmanId",   "c.departman_id",   "sayi",   "Birim Id", Varsayilan: false),
        });
}
