namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — RİSK KAYDI (1052), mockup
/// <c>Ekranlar/Kalite/kalite_risk_yonetimi.html</c> (sade: liste + kart).
/// Skor ve düzey görünümde (eşikler kys.risk_esik_*, fn_kys_risk_seviye).
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysRisk() => new(
        Ad: "kys-risk",
        YetkiKodu: "kys.risk",
        Kaynak: "public.v_kalite_risk r",
        SubeKolonu: "r.sube_id",
        VarsayilanSirala: "r.durum, r.skor desc, r.no",
        PortalKosullari: PortalKapsam.Kur(disDoktor: "false", disKurum: "false", hasta: "false"),
        Kolonlar: new KolonTanimi[]
        {
            new("id",                 "r.id",                   "sayi",  "Id", Varsayilan: false),
            new("no",                 "r.no",                   "metin", "Risk No", Genislik: 110),
            new("surec",              "r.surec",                "metin", "Süreç", Genislik: 140),
            new("birimAdi",           "r.birim_adi",            "metin", "Birim", Genislik: 140),
            new("tanim",              "r.tanim",                "metin", "Tehlike / Risk", Genislik: 300),
            new("olasilik",           "r.olasilik",             "sayi",  "O", Hizalama: "orta"),
            new("siddet",             "r.siddet",               "sayi",  "Ş", Hizalama: "orta"),
            new("skor",               "r.skor",                 "sayi",  "Skor", Hizalama: "orta"),
            new("seviyeAdi",          "r.seviye_adi",           "metin", "Düzey", Genislik: 100, Bicim: "rozet"),
            new("kontrolOnlem",       "r.kontrol_onlem",        "metin", "Kontrol / önlem", Genislik: 220, Varsayilan: false),
            new("sahipAdi",           "r.sahip_adi",            "metin", "Sahibi", Genislik: 140),
            new("gozdenGecirme",      "r.gozden_gecirme",       "tarih", "Gözden geçirme"),
            new("durumAdi",           "r.durum_adi",            "metin", "Durum", Genislik: 120, Bicim: "rozet"),
            new("seviye",             "r.seviye",               "sayi",  "Düzey Kodu", Varsayilan: false),
            new("gozdenGecirmeGecti", "r.gozden_gecirme_gecti", "sayi",  "Gözden geçirme geçti", Varsayilan: false),
            new("departmanId",        "r.departman_id",         "sayi",  "Birim Id", Varsayilan: false),
            new("dofId",              "r.dof_id",               "sayi",  "DÖF Id", Varsayilan: false),
            new("durum",              "r.durum",                "sayi",  "Durum Kodu", Varsayilan: false),
        });
}
