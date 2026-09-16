namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FTR MODÜLÜ (719) listeleri — mockup <c>Ekranlar/FTR/*.html</c>. İş
/// birimi tedavi programı (kür): değerlendirme → program → seans → ölçek.
/// Ünite panosu ve program/seans kartları özel sayfa; listeler burada.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi FtrDegerlendirme() => new(
        Ad: "ftr-degerlendirme",
        YetkiKodu: "ftr.degerlendirme",
        Kaynak: "public.v_ftr_degerlendirme d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.tarih desc, d.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "d.id",           "sayi",  "Id", Varsayilan: false),
            new("tarih",       "d.tarih",        "tarih", "Tarih"),
            new("hastaAdi",    "d.hasta_adi",    "metin", "Hasta", Genislik: 170),
            new("bolgeAdi",    "d.bolge_adi",    "metin", "Bölge", Genislik: 110, Bicim: "rozet"),
            new("tarafYon",    "d.taraf_yon",    "metin", "Taraf", Hizalama: "orta", Genislik: 60),
            new("icdKod",      "d.icd_kod",      "metin", "ICD", Genislik: 70),
            new("taniAd",      "d.tani_ad",      "metin", "Tanı", Genislik: 200),
            new("hekimAdi",    "d.hekim_adi",    "metin", "Uzman", Genislik: 140),
            new("vasAktivite", "d.vas_aktivite", "sayi",  "VAS", Hizalama: "orta"),
            new("kirmiziBayrak", "d.kirmizi_bayrak", "mantik", "Kırmızı bayrak", Hizalama: "orta"),
            new("raporNo",     "d.rapor_no",     "metin", "FTR Rapor", Genislik: 110),
            new("programNo",   "d.program_no",   "metin", "Program", Genislik: 110),
            new("olcekSayisi", "d.olcek_sayisi", "sayi",  "Ölçek", Hizalama: "orta", Varsayilan: false),
            new("hastaId",     "d.hasta_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("bolge",       "d.bolge",        "sayi",  "Bölge Kodu", Varsayilan: false),
        });

    private static KaynakTanimi FtrProgram() => new(
        Ad: "ftr-program",
        YetkiKodu: "ftr.program",
        Kaynak: "public.v_ftr_program p",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.durum, p.baslangic desc, p.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",               "p.id",               "sayi",  "Id", Varsayilan: false),
            new("programNo",        "p.program_no",       "metin", "Program", Genislik: 110),
            new("hastaAdi",         "p.hasta_adi",        "metin", "Hasta", Genislik: 170),
            new("bolgeAdi",         "p.bolge_adi",        "metin", "Bölge", Genislik: 100, Bicim: "rozet"),
            new("taniAd",           "p.tani_ad",          "metin", "Tanı", Genislik: 160, Varsayilan: false),
            new("hekimAdi",         "p.hekim_adi",        "metin", "Uzman", Genislik: 130),
            new("fizyoterapistAdi", "p.fizyoterapist_adi","metin", "Fizyoterapist", Genislik: 130),
            new("uniteAdi",         "p.unite_adi",        "metin", "Ünite", Genislik: 90, Varsayilan: false),
            new("kabinAdi",         "p.kabin_adi",        "metin", "Kabin", Genislik: 90),
            new("seansSayisi",      "p.seans_sayisi",     "sayi",  "Seans", Hizalama: "orta"),
            new("yapilanSeans",     "p.yapilan_seans",    "sayi",  "Yapılan", Hizalama: "orta"),
            new("devamsiz",         "p.devamsiz",         "sayi",  "Devamsız", Hizalama: "orta"),
            new("baslangic",        "p.baslangic",        "tarih", "Başlangıç"),
            new("bitisTahmini",     "p.bitis_tahmini",    "tarih", "Tahmini Bitiş"),
            new("sonrakiSeans",     "p.sonraki_seans",    "tarih", "Sonraki Seans"),
            new("vasIlk",           "p.vas_ilk",          "sayi",  "VAS ilk", Hizalama: "orta", Varsayilan: false),
            new("vasSon",           "p.vas_son",          "sayi",  "VAS son", Hizalama: "orta"),
            new("raporNo",          "p.rapor_no",         "metin", "FTR Rapor", Genislik: 110, Varsayilan: false),
            new("kalanHak",         "p.kalan_hak",        "sayi",  "Kalan Hak", Hizalama: "orta", Varsayilan: false),
            new("odeyenAdi",        "p.odeyen_adi",       "metin", "Ödeyen", Genislik: 120, Varsayilan: false),
            new("durumAdi",         "p.durum_adi",        "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Filtrelenebilir: false),
            new("durum",            "p.durum",            "sayi",  "Durum Kodu", Varsayilan: false),
            new("hastaId",          "p.hasta_id",         "sayi",  "Hasta Id", Varsayilan: false),
            new("fizyoterapistId",  "p.fizyoterapist_id", "sayi",  "Fzt Id", Varsayilan: false),
        });

    private static KaynakTanimi FtrSeans() => new(
        Ad: "ftr-seans",
        YetkiKodu: "ftr.seans",
        Kaynak: "public.v_ftr_seans s",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "s.tarih desc, s.saat, s.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",               "s.id",               "sayi",  "Id", Varsayilan: false),
            new("tarih",            "s.tarih",            "tarih", "Tarih"),
            new("saat",             "s.saat",             "metin", "Saat", Hizalama: "orta", Genislik: 60),
            new("hastaAdi",         "s.hasta_adi",        "metin", "Hasta", Genislik: 170),
            new("programNo",        "s.program_no",       "metin", "Program", Genislik: 100),
            new("bolgeAdi",         "s.bolge_adi",        "metin", "Bölge", Genislik: 90, Bicim: "rozet"),
            new("seans",            "s.sira || '/' || s.seans_sayisi", "metin", "Seans", Hizalama: "orta", Genislik: 60, Siralanabilir: false, Filtrelenebilir: false),
            new("fizyoterapistAdi", "s.fizyoterapist_adi","metin", "Fizyoterapist", Genislik: 130),
            new("kabinAdi",         "s.kabin_adi",        "metin", "Kabin", Genislik: 90),
            new("uygulama",         "s.yapilan_uygulama || '/' || s.uygulama_sayisi", "metin", "Uygulama", Hizalama: "orta", Genislik: 70, Siralanabilir: false, Filtrelenebilir: false),
            new("vasOnce",          "s.vas_once",         "sayi",  "VAS önce", Hizalama: "orta"),
            new("vasSonra",         "s.vas_sonra",        "sayi",  "VAS sonra", Hizalama: "orta"),
            new("sureDk",           "s.sure_dk",          "sayi",  "Süre (dk)", Hizalama: "orta"),
            new("durumAdi",         "s.durum_adi",        "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Filtrelenebilir: false),
            new("durum",            "s.durum",            "sayi",  "Durum Kodu", Varsayilan: false),
            new("programId",        "s.program_id",       "sayi",  "Program Id", Varsayilan: false),
            new("hastaId",          "s.hasta_id",         "sayi",  "Hasta Id", Varsayilan: false),
        });

    private static KaynakTanimi FtrOlcek() => new(
        Ad: "ftr-olcek",
        YetkiKodu: "ftr.olcek",
        Kaynak: "public.v_ftr_olcek o",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.tarih desc, o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "o.id",         "sayi",  "Id", Varsayilan: false),
            new("tarih",     "o.tarih",      "tarih", "Tarih"),
            new("hastaAdi",  "o.hasta_adi",  "metin", "Hasta", Genislik: 170),
            new("programNo", "o.program_no", "metin", "Program", Genislik: 100),
            new("olcekAdi",  "o.olcek_adi",  "metin", "Ölçek", Genislik: 140),
            new("asamaAdi",  "o.asama_adi",  "metin", "Aşama", Hizalama: "orta", Bicim: "rozet", Filtrelenebilir: false),
            new("skor",      "o.skor",       "sayi",  "Skor", Hizalama: "sag", Bicim: "#,##0.##"),
            new("hedef",     "o.hedef",      "sayi",  "Hedef", Hizalama: "sag", Bicim: "#,##0.##"),
            new("notMetin",  "o.not_metin",  "metin", "Not", Genislik: 200, Varsayilan: false),
            new("hastaId",   "o.hasta_id",   "sayi",  "Hasta Id", Varsayilan: false),
            new("programId", "o.program_id", "sayi",  "Program Id", Varsayilan: false),
        });

    private static KaynakTanimi FtrUnite() => new(
        Ad: "ftr-unite",
        YetkiKodu: "ftr.unite",
        Kaynak: "public.v_ftr_unite u",
        SubeKolonu: "u.sube_id",
        VarsayilanSirala: "u.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "u.id",           "sayi",   "Id", Varsayilan: false),
            new("kod",         "u.kod",          "metin",  "Kod", Genislik: 70),
            new("ad",          "u.ad",           "metin",  "Ünite", Genislik: 160),
            new("sorumluAdi",  "u.sorumlu_adi",  "metin",  "Sorumlu", Genislik: 150),
            new("kabinSayisi", "u.kabin_sayisi", "sayi",   "Kabin", Hizalama: "orta"),
            new("aktif",       "u.aktif",        "mantik", "Aktif", Hizalama: "orta"),
            new("aciklama",    "u.aciklama",     "metin",  "Açıklama", Genislik: 200, Varsayilan: false),
        });
}
