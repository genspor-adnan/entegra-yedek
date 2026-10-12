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
            // Mockup Kalite2/risk_listesi.html (1062): No · Risk · Birim · O · Ş ·
            //   Skor (seviye renginde kutu) · Sahibi.
            new("no",                 "r.no",                   "metin", "No", Genislik: 125),
            new("tanim",              "r.tanim",                "metin", "Risk", Genislik: 300),
            new("birimAdi",           "r.birim_adi",            "metin", "Birim", Genislik: 120),
            new("olasilik",           "r.olasilik",             "sayi",  "O", Hizalama: "orta"),
            new("siddet",             "r.siddet",               "sayi",  "Ş", Hizalama: "orta"),
            new("skorRozet",          "r.skor_rozet",           "metin", "Skor", Hizalama: "orta", Bicim: "riskSkor"),
            new("sahipAdi",           "r.sahip_adi",            "metin", "Sahibi", Genislik: 140),
            new("surec",              "r.surec",                "metin", "Süreç", Genislik: 140, Varsayilan: false),
            new("skor",               "r.skor",                 "sayi",  "Skor (sayı)", Hizalama: "orta", Varsayilan: false),
            new("seviyeAdi",          "r.seviye_adi",           "metin", "Düzey", Genislik: 100, Bicim: "rozet", Varsayilan: false),
            new("kontrolOnlem",       "r.kontrol_onlem",        "metin", "Önlem", Genislik: 220, Varsayilan: false),
            new("gozdenGecirme",      "r.gozden_gecirme",       "tarih", "Gözden geçirme", Varsayilan: false),
            new("durumAdi",           "r.durum_adi",            "metin", "Durum", Genislik: 120, Bicim: "rozet", Varsayilan: false),
            new("sahipId",            "r.sahip_id",             "sayi",  "Sahip Id", Varsayilan: false),
            new("seviye",             "r.seviye",               "sayi",  "Düzey Kodu", Varsayilan: false),
            new("gozdenGecirmeGecti", "r.gozden_gecirme_gecti", "sayi",  "Gözden geçirme geçti", Varsayilan: false),
            new("departmanId",        "r.departman_id",         "sayi",  "Birim Id", Varsayilan: false),
            new("dofId",              "r.dof_id",               "sayi",  "DÖF Id", Varsayilan: false),
            new("durum",              "r.durum",                "sayi",  "Durum Kodu", Varsayilan: false),
        });
}
