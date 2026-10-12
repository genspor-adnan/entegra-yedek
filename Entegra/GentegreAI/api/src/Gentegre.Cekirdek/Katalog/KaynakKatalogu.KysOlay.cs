namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — OLAY BİLDİRİMLERİ (1052), mockup
/// <c>Ekranlar/Kalite/kalite_olay_bildirim.html</c> (sade: liste + kart).
/// Anonim kayıtta bildiren "Anonim" - görünüm kişiyi hiç birleştirmez.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysOlay() => new(
        Ad: "kys-olay",
        YetkiKodu: "kys.olay",
        Kaynak: "public.v_kalite_olay o",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.durum, o.tarih desc",
        // PORTALA KAPALI: olay kaydı hasta ve çalışan güvenliği ayrıntısı taşır.
        PortalKosullari: PortalKapsam.Kur(disDoktor: "false", disKurum: "false", hasta: "false"),
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "o.id",          "sayi",  "Id", Varsayilan: false),
            new("no",          "o.no",          "metin", "Olay No", Genislik: 120),
            new("tarih",       "o.tarih",       "zaman", "Tarih", Hizalama: "orta"),
            new("turAdi",      "o.tur_adi",     "metin", "Tür", Genislik: 150, Bicim: "rozet"),
            new("birimAdi",    "o.birim_adi",   "metin", "Birim", Genislik: 160),
            new("zararAdi",    "o.zarar_adi",   "metin", "Zarar Düzeyi", Genislik: 110, Bicim: "rozet"),
            new("bildirenAdi", "o.bildiren_adi","metin", "Bildiren", Genislik: 140),
            new("komiteAdi",   "o.komite_adi",  "metin", "Komite", Genislik: 170),
            new("durumAdi",    "o.durum_adi",   "metin", "Durum", Genislik: 110, Bicim: "rozet"),
            new("tur",         "o.tur",         "sayi",  "Tür Kodu", Varsayilan: false),
            new("zarar",       "o.zarar",       "sayi",  "Zarar Kodu", Varsayilan: false),
            new("anonim",      "o.anonim",      "mantik","Anonim", Hizalama: "orta", Varsayilan: false),
            new("departmanId", "o.departman_id","sayi",  "Birim Id", Varsayilan: false),
            new("dofId",       "o.dof_id",      "sayi",  "DÖF Id", Varsayilan: false),
            new("durum",       "o.durum",       "sayi",  "Durum Kodu", Varsayilan: false),
        });
}
