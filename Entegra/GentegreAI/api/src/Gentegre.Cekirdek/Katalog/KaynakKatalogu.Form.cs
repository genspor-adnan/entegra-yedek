namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FORM MOTORU (740) listeleri — mockup <c>Ekranlar/Formlar/formlar.html</c>.
/// Şablonlar (kurumun kendi kopyaları; resmî kütüphane özel sayfa), doldurulan
/// formlar (istekler) ve tetikleyici kurallar.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi FormSablon() => new(
        Ad: "form-sablon",
        YetkiKodu: "form.sablon",
        Kaynak: "public.v_form_sablon s",
        SubeKolonu: null,
        VarsayilanSirala: "s.aile, s.ad",
        // Kurumun kendi şablonları; resmî kütüphane kopyaları ayrı sayfada.
        SabitKosul: "s.resmi = 0",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "s.id",            "sayi",   "Id", Varsayilan: false),
            new("kod",           "s.kod",           "metin",  "Kod", Genislik: 130),
            new("ad",            "s.ad",            "metin",  "Ad", Genislik: 260),
            new("aileAdi",       "s.aile_adi",      "metin",  "Aile", Genislik: 110, Bicim: "rozet"),
            new("baglamAdi",     "s.baglam_adi",    "metin",  "Bağlam", Genislik: 100),
            new("kanalAdi",      "s.kanal_adi",     "metin",  "Kanal", Genislik: 100),
            new("kaynak",        "s.kaynak",        "metin",  "Kaynak", Genislik: 130),
            new("kaynakKod",     "s.kaynak_kod",    "metin",  "SKS Kodu", Genislik: 100, Varsayilan: false),
            new("surum",         "s.surum",         "sayi",   "Sürüm", Hizalama: "orta"),
            new("resmiSurum",    "s.resmi_surum",   "sayi",   "Resmî sürüm", Hizalama: "orta", Varsayilan: false),
            new("tekrarSaat",    "s.tekrar_saat",   "sayi",   "Tekrar (saat)", Hizalama: "orta", Varsayilan: false),
            new("asamali",       "s.asamali",       "mantik", "Aşamalı", Hizalama: "orta", Varsayilan: false),
            new("kullanim",      "s.kullanim",      "sayi",   "Doldurulan", Hizalama: "orta"),
            new("bekleyen",      "s.bekleyen",      "sayi",   "Bekleyen", Hizalama: "orta"),
            new("durumAdi",      "s.durum_adi",     "metin",  "Durum", Genislik: 80, Bicim: "rozet"),
            new("aile",          "s.aile",          "sayi",   "Aile Kodu", Varsayilan: false),
            new("durum",         "s.durum",         "sayi",   "Durum Kodu", Varsayilan: false),
            new("ustSablonId",   "s.ust_sablon_id", "sayi",   "Resmî Kaynak Id", Varsayilan: false),
            new("degistirmeTarihi", "s.degistirme_tarihi", "tarih", "Değişme", Varsayilan: false),
        });

    private static KaynakTanimi FormIstek() => new(
        Ad: "form-istek",
        YetkiKodu: "form.istek",
        Kaynak: "public.v_form_istek i",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.ekleme_tarihi desc, i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "i.id",            "sayi",   "Id", Varsayilan: false),
            new("eklemeTarihi",  "i.ekleme_tarihi", "tarih", "Tarih"),
            new("hastaAdi",      "i.hasta_adi",     "metin",  "Hasta", Genislik: 170),
            new("sablonAdi",     "i.sablon_adi",    "metin",  "Form", Genislik: 220),
            new("aileAdi",       "i.aile_adi",      "metin",  "Aile", Genislik: 100, Bicim: "rozet", Varsayilan: false),
            new("kaynakAdi",     "i.kaynak_adi",    "metin",  "Bağlam", Genislik: 90),
            new("kanalAdi",      "i.kanal_adi",     "metin",  "Kanal", Genislik: 90),
            new("gonderenAdi",   "i.gonderen_adi",  "metin",  "Gönderen", Genislik: 120, Varsayilan: false),
            new("dolduranAdi",   "i.dolduran_adi",  "metin",  "Dolduran", Genislik: 120),
            new("acilis",        "i.acilis",        "tarih", "Açıldı", Varsayilan: false),
            new("tamamlanma",    "i.tamamlanma",    "tarih", "Dolduruldu"),
            new("imzaSayisi",    "i.imza_sayisi",   "sayi",   "İmza", Hizalama: "orta"),
            new("skor",          "i.skor",          "sayi",   "Skor", Hizalama: "orta"),
            new("sonuc",         "i.sonuc",         "metin",  "Sonuç", Genislik: 160),
            new("durumAdi",      "i.durum_adi",     "metin",  "Durum", Genislik: 100, Bicim: "rozet"),
            new("sonGecerlilik", "i.son_gecerlilik","tarih", "Son Geçerlilik", Varsayilan: false),
            new("suresiGecti",   "i.suresi_gecti",  "mantik", "Süresi Geçti", Hizalama: "orta", Varsayilan: false),
            new("aktarimZamani", "i.aktarim_zamani","tarih", "Aktarıldı", Varsayilan: false),
            new("hastaId",       "i.hasta_id",      "sayi",   "Hasta Id", Varsayilan: false),
            new("sablonId",      "i.sablon_id",     "sayi",   "Şablon Id", Varsayilan: false),
            new("sablonKod",     "i.sablon_kod",    "metin",  "Şablon Kodu", Varsayilan: false),
            new("kaynakTur",     "i.kaynak_tur",    "sayi",   "Bağlam Kodu", Varsayilan: false),
            new("kaynakId",      "i.kaynak_id",     "sayi",   "Bağlam Kayıt", Varsayilan: false),
            new("durum",         "i.durum",         "sayi",   "Durum Kodu", Varsayilan: false),
            new("aile",          "i.aile",          "sayi",   "Aile Kodu", Varsayilan: false),
        });

    private static KaynakTanimi FormKural() => new(
        Ad: "form-kural",
        YetkiKodu: "form.kural",
        Kaynak: "public.v_form_kural k",
        SubeKolonu: null,
        VarsayilanSirala: "k.olay, k.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "k.id",           "sayi",   "Id", Varsayilan: false),
            new("olayAdi",     "k.olay_adi",     "metin",  "Tetikleyici", Genislik: 170),
            new("sablonAdi",   "k.sablon_adi",   "metin",  "Şablon", Genislik: 240),
            new("kanalAdi",    "k.kanal_adi",    "metin",  "Kanal", Genislik: 100),
            new("gecikmeSaat", "k.gecikme_saat", "sayi",   "Gecikme (saat)", Hizalama: "orta"),
            new("kilit",       "k.kilit",        "metin",  "Kilit", Genislik: 140),
            new("zorunlu",     "k.zorunlu",      "mantik", "Zorunlu", Hizalama: "orta"),
            new("aktif",       "k.aktif",        "mantik", "Aktif", Hizalama: "orta"),
            new("aciklama",    "k.aciklama",     "metin",  "Açıklama", Genislik: 240),
            new("olay",        "k.olay",         "sayi",   "Olay Kodu", Varsayilan: false),
            new("sablonId",    "k.sablon_id",    "sayi",   "Şablon Id", Varsayilan: false),
        });
}
