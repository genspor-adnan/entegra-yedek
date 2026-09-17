namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FORM MOTORU (740) kartları: şablon (tanım jsonb) ve tetikleyici kural.
/// Doldurulan form (istek) kartı YOK - doldurma özel sayfadır (FormDoldur),
/// içerik jsonb; liste + özel sayfa yeter.
/// </summary>
public static partial class KartKatalogu
{
    // ISLEMLOG tablo kodları — 1190 bloğu form motoruna ayrıldı.
    private const int LogFormSablon = 1190;
    private const int LogFormIstek  = 1191;
    private const int LogFormKural  = 1192;

    private static readonly Dictionary<string, string> FormAileKodlari = new()
    {
        ["1"] = "Onam", ["2"] = "Değerlendirme", ["3"] = "Kontrol listesi", ["4"] = "Beyan", ["5"] = "Anket",
    };
    private static readonly Dictionary<string, string> FormDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Aktif", ["2"] = "Pasif",
    };

    private static KartTanimi FormSablonKarti() => new(
        Ad: "form-sablon",
        YetkiKodu: "form.sablon",
        Tablo: "public.form_sablon",
        LogTabloId: LogFormSablon,
        // Resmî (kütüphane) kopyası buradan düzenlenmez: kart yalnız kurum kopyası.
        SabitKosul: "resmi = 0",
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.form_istek", "sablon_id", "Bu şablonla doldurulmuş form var; şablonu silmek yerine pasife alın."),
            new("public.form_kural", "sablon_id", "Bu şablona bağlı tetikleyici kural var; önce kuralı silin."),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aile"] = (short)2, ["baglam"] = (short)1, ["kanal"] = (short)1, ["surum"] = (short)1, ["durum"] = (short)1,
            ["gecerlilikSaat"] = (short)72, ["saklamaYil"] = (short)15,
            ["tanim"] = "{\"bolumler\":[{\"kod\":\"b1\",\"ad\":\"Bölüm 1\",\"sahip\":\"hasta\",\"alanlar\":[]}]}",
        },
        Alanlar: new KartAlani[]
        {
            new("id",             "id",              "sayi",   Yazilabilir: false),
            new("kod",            "kod",             "metin",  Zorunlu: true, EnFazlaUzunluk: 40, Baslik: "Kod", Grup: "Kimlik"),
            new("ad",             "ad",              "metin",  Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Ad", Grup: "Kimlik"),
            new("aile",           "aile",            "kod",    Zorunlu: true, KodListesi: "form.aile", SabitKodlar: FormAileKodlari, Baslik: "Aile", Grup: "Kimlik"),
            new("baglam",         "baglam",          "kod",    Zorunlu: true, KodListesi: "form.baglam", Baslik: "Bağlam", Grup: "Kimlik"),
            new("kanal",          "kanal",           "kod",    Zorunlu: true, KodListesi: "form.kanal", Baslik: "Varsayılan kanal", Grup: "Kimlik"),
            new("imzaYontem",     "imza_yontem",     "kod",    KodListesi: "form.imza_yontem", Baslik: "İmza yöntemi", Grup: "Kimlik"),
            new("durum",          "durum",           "kod",    SabitKodlar: FormDurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            new("surum",          "surum",           "sayi",   Baslik: "Sürüm", Grup: "Kimlik"),
            new("kaynak",         "kaynak",          "metin",  EnFazlaUzunluk: 60, Baslik: "Kaynak (SKS / kurum)", Grup: "Kaynak"),
            new("kaynakKod",      "kaynak_kod",      "metin",  EnFazlaUzunluk: 30, Baslik: "Kaynak kodu", Grup: "Kaynak"),
            new("kurumTipleri",   "kurum_tipleri",   "metin",  EnFazlaUzunluk: 200, Baslik: "Kurum tipleri (virgüllü, boş = hepsi)", Grup: "Kaynak"),
            new("ustSablonId",    "ust_sablon_id",   "sayi",   Yazilabilir: false, Baslik: "Resmî kaynak (kütüphane) Id", Grup: "Kaynak"),
            new("gecerlilikSaat", "gecerlilik_saat", "sayi",   Baslik: "Bağlantı geçerliliği (saat)", Grup: "Kurallar"),
            new("saklamaYil",     "saklama_yil",     "sayi",   Baslik: "Saklama (yıl)", Grup: "Kurallar"),
            new("tekrarSaat",     "tekrar_saat",     "sayi",   Baslik: "Tekrar süresi (saat, 0 = tek)", Grup: "Kurallar"),
            new("asamali",        "asamali",         "mantik", Baslik: "Aşamalı (bölümler sırayla açılır)", Grup: "Kurallar"),
            new("aciklama",       "aciklama",        "metin",  EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Kurallar"),
            // TANIM: bölümler / alanlar / hesap / imzalar. Editör (web) bu alanı
            //   görsel olarak düzenler; generic kartta ham JSON metin alanı.
            new("tanim",          "tanim",           "json",   EnFazlaUzunluk: 60000, Baslik: "Tanım (JSON)", Grup: "Tanım"),
        });

    private static KartTanimi FormKuralKarti() => new(
        Ad: "form-kural",
        YetkiKodu: "form.kural",
        Tablo: "public.form_kural",
        LogTabloId: LogFormKural,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["kanal"] = (short)1, ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",   Yazilabilir: false),
            new("olay",        "olay",         "kod",    Zorunlu: true, KodListesi: "form.olay", Baslik: "Tetikleyici olay"),
            new("sablonId",    "sablon_id",    "kod",    Zorunlu: true, KodTablosu: "public.v_form_sablon_lookup", Baslik: "Şablon"),
            new("kanal",       "kanal",        "kod",    Zorunlu: true, KodListesi: "form.kanal", Baslik: "Kanal"),
            new("gecikmeSaat", "gecikme_saat", "sayi",   Baslik: "Gecikme (saat; eksi = olaydan önce)"),
            new("kilit",       "kilit",        "metin",  EnFazlaUzunluk: 40, Baslik: "Kilit anahtarı (ör. ameliyat.basla)"),
            new("zorunlu",     "zorunlu",      "mantik", Baslik: "Zorunlu (eksikse rozet / kilit)"),
            new("aktif",       "aktif",        "mantik", Baslik: "Aktif"),
            new("aciklama",    "aciklama",     "metin",  EnFazlaUzunluk: 300, Baslik: "Açıklama"),
        });
}
