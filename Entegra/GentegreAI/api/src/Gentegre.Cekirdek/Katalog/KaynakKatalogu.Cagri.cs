namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ÇAĞRI MERKEZİ (839) listeleri — mockup <c>Ekranlar/CagriMerkezi/*.html</c>.
/// Çağrı kayıtları, kampanya ve kişileri, kalite; ayar listeleri konu / kuyruk /
/// agent. Operatör panosu, giden arama ve süpervizör özel sayfa.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi Cagri() => new(
        Ad: "cagri",
        YetkiKodu: "cagri.kayit",
        Kaynak: "public.v_cagri c",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.baslama desc, c.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "c.id",             "sayi",  "Id", Varsayilan: false),
            new("baslama",       "c.baslama",        "zaman", "Zaman", Genislik: 130),
            new("kanalAdi",      "c.kanal_adi",      "metin", "Kanal", Genislik: 80, Bicim: "rozet"),
            new("yonAdi",        "c.yon_adi",        "metin", "Yön", Genislik: 60),
            new("arayanNo",      "c.arayan_no",      "metin", "Numara", Genislik: 120),
            new("tarafAdi",      "c.taraf_adi",      "metin", "Kişi", Genislik: 180),
            new("kuyrukAdi",     "c.kuyruk_adi",     "metin", "Kuyruk", Genislik: 100),
            new("agentAdi",      "c.agent_adi",      "metin", "Agent", Genislik: 120),
            new("konuAdi",       "c.konu_adi",       "metin", "Konu", Genislik: 110, Bicim: "rozet"),
            new("altKonuAdi",    "c.alt_konu_adi",   "metin", "Alt konu", Genislik: 110),
            new("sonucAdi",      "c.sonuc_adi",      "metin", "Sonuç", Genislik: 120, Bicim: "rozet"),
            new("beklemeSn",     "c.bekleme_sn",     "sayi",  "Bekleme (sn)", Hizalama: "sag"),
            new("sureSn",        "c.sure_sn",        "sayi",  "Süre (sn)", Hizalama: "sag"),
            new("slaIcinde",     "c.sla_icinde",     "mantik", "SLA", Hizalama: "orta"),
            new("durumAdi",      "c.durum_adi",      "metin", "Durum", Genislik: 100, Bicim: "rozet"),
            new("geriArama",     "c.geri_arama",     "zaman", "Geri arama", Varsayilan: false),
            new("memnuniyet",    "c.memnuniyet",     "sayi",  "Memnuniyet", Hizalama: "orta", Varsayilan: false),
            new("kalitePuan",    "c.kalite_puan",    "sayi",  "Kalite", Hizalama: "orta", Varsayilan: false),
            new("kampanyaAdi",   "c.kampanya_adi",   "metin", "Kampanya", Genislik: 140, Varsayilan: false),
            new("notu",          "c.notu",           "metin", "Not", Genislik: 260, Varsayilan: false),
            new("tarafId",       "c.taraf_id",       "sayi",  "Taraf Id", Varsayilan: false),
            new("agentId",       "c.agent_id",       "sayi",  "Agent Id", Varsayilan: false),
            new("kanal",         "c.kanal",          "sayi",  "Kanal Kodu", Varsayilan: false),
            new("yon",           "c.yon",            "sayi",  "Yön Kodu", Varsayilan: false),
            new("sonuc",         "c.sonuc",          "sayi",  "Sonuç Kodu", Varsayilan: false),
            new("durum",         "c.durum",          "sayi",  "Durum Kodu", Varsayilan: false),
            new("geriAramaTamam","c.geri_arama_tamam","sayi", "Geri arama tamam", Varsayilan: false),
            new("gorevId",       "c.gorev_id",       "sayi",  "Görev Id", Varsayilan: false),
        });

    private static KaynakTanimi CagriKonu() => new(
        Ad: "cagri-konu",
        YetkiKodu: "cagri.ayar",
        Kaynak: "public.v_cagri_konu k",
        SubeKolonu: null,
        VarsayilanSirala: "coalesce(k.ust_id, k.id), k.ust_id nulls first, k.sira, k.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "k.id",             "sayi",  "Id", Varsayilan: false),
            new("tamAd",         "k.tam_ad",         "metin", "Konu › Alt konu", Genislik: 220),
            new("slaDk",         "k.sla_dk",         "sayi",  "SLA (dk, 0 = çağrıda)", Hizalama: "sag"),
            new("hizliIslemAdi", "k.hizli_islem_adi","metin", "Hızlı işlem", Genislik: 120),
            new("sonuclar",      "k.sonuclar",       "metin", "Sonuçlar", Genislik: 240),
            new("altSayisi",     "k.alt_sayisi",     "sayi",  "Alt konu", Hizalama: "orta"),
            new("cagri30g",      "k.cagri_30g",      "sayi",  "Çağrı (30 g)", Hizalama: "orta"),
            new("aktifAdi",      "k.aktif_adi",      "metin", "Durum", Genislik: 70, Bicim: "rozet"),
            new("ustId",         "k.ust_id",         "sayi",  "Üst Id", Varsayilan: false),
            new("aktif",         "k.aktif",          "sayi",  "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi CagriKuyruk() => new(
        Ad: "cagri-kuyruk",
        YetkiKodu: "cagri.ayar",
        Kaynak: "public.v_cagri_kuyruk q",
        SubeKolonu: null,
        VarsayilanSirala: "q.sira, q.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "q.id",               "sayi",  "Id", Varsayilan: false),
            new("ad",            "q.ad",               "metin", "Kuyruk", Genislik: 140),
            new("santralKodu",   "q.santral_kodu",     "metin", "Santral kodu", Genislik: 90),
            new("kanalAdi",      "q.kanal_adi",        "metin", "Kanal", Genislik: 80, Bicim: "rozet"),
            new("beceri",        "q.beceri",           "metin", "Beceri", Genislik: 90),
            new("agentSayisi",   "q.agent_sayisi",     "sayi",  "Agent", Hizalama: "orta"),
            new("hazirAgent",    "q.hazir_agent",      "sayi",  "Hazır", Hizalama: "orta"),
            new("bekleyen",      "q.bekleyen",         "sayi",  "Bekleyen", Hizalama: "orta"),
            new("slaSn",         "q.sla_sn",           "sayi",  "SLA (sn)", Hizalama: "sag"),
            new("slaHedef",      "q.sla_hedef",        "sayi",  "Hedef %", Hizalama: "sag"),
            new("maxBeklemeSn",  "q.max_bekleme_sn",   "sayi",  "Max bekleme (sn)", Hizalama: "sag"),
            new("tasmaAdi",      "q.tasma_adi",        "metin", "Taşma", Genislik: 110),
            new("cevaplananBugun","q.cevaplanan_bugun","sayi",  "Cevaplanan (bugün)", Hizalama: "orta"),
            new("kacanBugun",    "q.kacan_bugun",      "sayi",  "Kaçan (bugün)", Hizalama: "orta"),
            new("aktifAdi",      "q.aktif_adi",        "metin", "Durum", Genislik: 70, Bicim: "rozet"),
            new("aktif",         "q.aktif",            "sayi",  "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi CagriAgent() => new(
        Ad: "cagri-agent",
        YetkiKodu: "cagri.ayar",
        Kaynak: "public.v_cagri_agent a",
        SubeKolonu: null,
        VarsayilanSirala: "a.dahili, a.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "a.id",              "sayi",  "Id", Varsayilan: false),
            new("dahili",        "a.dahili",          "metin", "Dahili", Genislik: 70),
            new("agentAdi",      "a.agent_adi",       "metin", "Kullanıcı", Genislik: 160),
            new("kuyrukAdlari",  "a.kuyruk_adlari",   "metin", "Kuyruklar", Genislik: 200),
            new("softphoneAdi",  "a.softphone_adi",   "metin", "Softphone", Genislik: 90),
            new("durumAdi",      "a.durum_adi",       "metin", "Durum", Genislik: 100, Bicim: "rozet"),
            new("durumSn",       "a.durum_sn",        "sayi",  "Durum (sn)", Hizalama: "sag", Varsayilan: false),
            new("cagriBugun",    "a.cagri_bugun",     "sayi",  "Çağrı (bugün)", Hizalama: "orta"),
            new("ortSureSn",     "a.ort_sure_sn",     "sayi",  "Ort. süre (sn)", Hizalama: "sag"),
            new("aktifAdi",      "a.aktif_adi",       "metin", "Aktif", Genislik: 70, Bicim: "rozet"),
            new("kullaniciId",   "a.kullanici_id",    "sayi",  "Kullanıcı Id", Varsayilan: false),
            new("durum",         "a.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
            new("aktif",         "a.aktif",           "sayi",  "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi CagriKampanya() => new(
        Ad: "cagri-kampanya",
        YetkiKodu: "cagri.kampanya",
        Kaynak: "public.v_cagri_kampanya p",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.durum, p.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "p.id",              "sayi",  "Id", Varsayilan: false),
            new("ad",            "p.ad",              "metin", "Kampanya", Genislik: 220),
            new("turAdi",        "p.tur_adi",         "metin", "Tür", Genislik: 130, Bicim: "rozet"),
            new("kaynak",        "p.kaynak",          "metin", "Kaynak listesi", Genislik: 110),
            new("sablonKodu",    "p.sablon_kodu",     "metin", "1. adım (şablon)", Genislik: 160),
            new("kuyrukAdi",     "p.kuyruk_adi",      "metin", "2. adım (kuyruk)", Genislik: 110),
            new("hedef",         "p.hedef",           "sayi",  "Hedef", Hizalama: "orta"),
            new("ulasilan",      "p.ulasilan",        "sayi",  "Ulaşılan", Hizalama: "orta"),
            new("basarili",      "p.basarili",        "sayi",  "Başarılı", Hizalama: "orta"),
            new("bekleyen",      "p.bekleyen",        "sayi",  "Bekleyen", Hizalama: "orta"),
            new("zamanlama",     "p.zamanlama",       "metin", "Zamanlama", Genislik: 110, Varsayilan: false),
            new("baslama",       "p.baslama",         "tarih", "Başlama", Varsayilan: false),
            new("bitis",         "p.bitis",           "tarih", "Bitiş", Varsayilan: false),
            new("durumAdi",      "p.durum_adi",       "metin", "Durum", Genislik: 90, Bicim: "rozet"),
            new("tur",           "p.tur",             "sayi",  "Tür Kodu", Varsayilan: false),
            new("durum",         "p.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi CagriKampanyaKisi() => new(
        Ad: "cagri-kampanya-kisi",
        YetkiKodu: "cagri.kampanya",
        Kaynak: "public.v_cagri_kampanya_kisi x",
        SubeKolonu: "x.sube_id",
        VarsayilanSirala: "x.durum, x.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "x.id",              "sayi",  "Id", Varsayilan: false),
            new("kampanyaAdi",   "x.kampanya_adi",    "metin", "Kampanya", Genislik: 180),
            new("ad",            "x.ad",              "metin", "Kişi", Genislik: 170),
            new("telefon",       "x.telefon",         "metin", "Telefon", Genislik: 120),
            new("ozet",          "x.ozet",            "metin", "Özet", Genislik: 220),
            new("durumAdi",      "x.durum_adi",       "metin", "Durum", Genislik: 110, Bicim: "rozet"),
            new("deneme",        "x.deneme",          "sayi",  "Deneme", Hizalama: "orta"),
            new("sonDeneme",     "x.son_deneme",      "zaman", "Son deneme"),
            new("aranacak",      "x.aranacak",        "mantik", "Aranacak", Hizalama: "orta"),
            new("sonuc",         "x.sonuc",           "metin", "Sonuç", Genislik: 180),
            new("kampanyaId",    "x.kampanya_id",     "sayi",  "Kampanya Id", Varsayilan: false),
            new("tarafId",       "x.taraf_id",        "sayi",  "Taraf Id", Varsayilan: false),
            new("cagriId",       "x.cagri_id",        "sayi",  "Çağrı Id", Varsayilan: false),
            new("durum",         "x.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi CagriKalite() => new(
        Ad: "cagri-kalite",
        YetkiKodu: "cagri.kalite",
        Kaynak: "public.v_cagri_kalite k",
        SubeKolonu: null,
        VarsayilanSirala: "k.ekleme_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",              "k.id",               "sayi",  "Id", Varsayilan: false),
            new("baslama",         "k.baslama",          "zaman", "Çağrı", Genislik: 130),
            new("agentAdi",        "k.agent_adi",        "metin", "Agent", Genislik: 130),
            new("tarafAdi",        "k.taraf_adi",        "metin", "Kişi", Genislik: 160),
            new("konuAdi",         "k.konu_adi",         "metin", "Konu", Genislik: 110),
            new("puan",            "k.puan",             "sayi",  "Puan", Hizalama: "orta"),
            new("degerlendirenAdi","k.degerlendiren_adi","metin", "Değerlendiren", Genislik: 130),
            new("notu",            "k.notu",             "metin", "Not", Genislik: 240),
            new("ekleme_tarihi",   "k.ekleme_tarihi",    "zaman", "Tarih", Varsayilan: false),
            new("cagriId",         "k.cagri_id",         "sayi",  "Çağrı Id", Varsayilan: false),
        });
}
