namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kart alani. Yazilabilir olmayan alanlar istek govdesinde gelse bile YOK SAYILMAZ -
/// hata verilir (API §3.2: sessizce yok saymak yok).
/// </summary>
public sealed record KartAlani(
    string Ad,                     // API adi: "faturaUnvan"
    string Kolon,                  // db kolonu: "fatura_unvan"
    string Tip,                    // metin | sayi | para | tarih | kod | mantik
    bool Yazilabilir = true,
    bool Zorunlu = false,
    int? EnFazlaUzunluk = null,
    string? KodListesi = null,     // kod_liste.kod - kodAd sozlugu bundan cozulur
    IReadOnlyDictionary<string, string>? SabitKodlar = null,  // kod listesi DB'de yoksa
    // Kendi tablosu olan (kod_liste/kod_deger'e uymayan) secim kaynagi: "public.kategori".
    //   Tam secenek listesi VeriDeposu.KodTablosuBeyazListe'de whitelist'li tablolardan
    //   "select id, ad from <tablo> where aktif = 1 order by ad" ile cekilir.
    string? KodTablosu = null,
    string? Baslik = null,         // form etiketi; bos ise Ad'dan uretilir
    string? Grup = null,           // form bolumu / SEKME: "Kimlik", "Iletisim", "Mali"
    // Sekme DEGIL - ayni sekme icinde mockup'taki gibi kucuk alt-baslik
    //   (or. Genel sekmesinde "Tanım / Sınıflandırma" / "Vergi & Ana Birim").
    string? AltGrup = null,
    // Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
    //   Baska bir alanin Ad'ini gosterir; o alan kendi SATIRINI almaz, buraya eklenir.
    string? EslesAlan = null
)
{
    /// <summary>Etiket verilmediyse camelCase addan uretilir: faturaUnvan -> "Fatura Unvan".</summary>
    public string Etiket => Baslik ?? AddanEtiket(Ad);

    private static string AddanEtiket(string ad)
    {
        var sonuc = new System.Text.StringBuilder(ad.Length + 4);
        for (var i = 0; i < ad.Length; i++)
        {
            if (i > 0 && char.IsUpper(ad[i])) sonuc.Append(' ');
            sonuc.Append(i == 0 ? char.ToUpperInvariant(ad[i]) : ad[i]);
        }
        return sonuc.ToString();
    }
}

public sealed record DetayTanimi(
    string Ad,                     // "adresler"
    string Tablo,                  // "public.taraf_adres"
    string UstKolon,               // "taraf_id"
    IReadOnlyList<KartAlani> Alanlar,
    string IdKolonu = "id",
    string Sirala = "id",
    // 019'da tum sube_id kolonlari NOT NULL yapildi; detay eklerken oturumun
    //   subesi yazilir. Tabloda sube_id yoksa null verilir.
    string? SubeKolonu = "sube_id",
    // islem_log.tablo_id. 0 ise kartin tablo kodu kullanilir. Detay satirinin
    //   logu ust_tablo_id / ust_kayit_id ile karta baglanir.
    int LogTabloId = 0,
    string? Baslik = null,         // sekme basligi; bos ise Ad'dan uretilir
    bool SaltOkunur = false        // satir ekle/sil hic gosterilmez (or. hesaplanmis/derlenmis veri)
)
{
    public string Etiket => Baslik ?? (Ad.Length > 0 ? char.ToUpperInvariant(Ad[0]) + Ad[1..] : Ad);
}

/// <summary>Silmeyi engelleyen bag. Adet > 0 ise 422 IS_KURALI doner (API §3.3).</summary>
public sealed record SilmeEngeli(string Tablo, string Kolon, string Aciklama);

public sealed record KartTanimi(
    string Ad,                     // yol parcasi: "cari"
    string YetkiKodu,
    string Tablo,                  // "public.taraf"
    IReadOnlyList<KartAlani> Alanlar,
    int LogTabloId,                // ISLEMLOG.TABLOID (eski GENINI -11110 listesi)
    IReadOnlyList<DetayTanimi>? Detaylar = null,
    IReadOnlyList<SilmeEngeli>? SilmeEngelleri = null,
    string IdKolonu = "id",
    string? SabitKosul = null,
    string? SubeKolonu = null,
    string? KapsamKolonu = null,
    IReadOnlyDictionary<string, object?>? YeniKayitVarsayilanlari = null
)
{
    private Dictionary<string, KartAlani>? _dizin;

    public KartAlani? Alan(string ad)
    {
        _dizin ??= Alanlar.ToDictionary(a => a.Ad, StringComparer.Ordinal);
        return _dizin.TryGetValue(ad, out var a) ? a : null;
    }

    public DetayTanimi? Detay(string ad)
        => Detaylar?.FirstOrDefault(d => d.Ad.Equals(ad, StringComparison.Ordinal));
}

public static class KartKatalogu
{
    private static readonly Dictionary<string, KartTanimi> Kartlar =
        new(StringComparer.OrdinalIgnoreCase);

    public static KartTanimi? Bul(string ad) => Kartlar.TryGetValue(ad, out var k) ? k : null;
    public static IEnumerable<KartTanimi> Tumu => Kartlar.Values;

    static KartKatalogu()
    {
        Ekle(Cari());
        Ekle(Kisi());
        Ekle(Personel());
        Ekle(Rol());
        Ekle(Stok());
        // Belge KARTI degil, ayri sozlesme (§4 belge kaydetme) - burada yer almaz.
    }

    private static void Ekle(KartTanimi k) => Kartlar[k.Ad] = k;

    // GENINI kod listelerinde (BOLUM -2708 / -2201) 1 = Aktif, 0 = Pasif.
    //   Sema yorumu tersini soyluyordu; verinin 2.487'si 1, 229'u 0 - yani 1 aktif.
    private static readonly Dictionary<string, string> DurumKodlari =
        new() { ["1"] = "Aktif", ["0"] = "Pasif" };

    // STOKLAR.BILDIRIM - GENINI kod listesi degil, sabit 2 secenek (BILIM verisi: 0=3614, 2=1468, 1=1 stray).
    private static readonly Dictionary<string, string> BildirimKodlari =
        new() { ["0"] = "Yok", ["2"] = "ÜTS" };

    // STOKLAR.RAFOMRU_BIRIM - GENINI degil, sabit 3 secenek (mockup: Gun/Ay/Yil, varsayilan Yil).
    private static readonly Dictionary<string, string> RafOmruBirimKodlari =
        new() { ["0"] = "—", ["1"] = "Gün", ["2"] = "Ay", ["3"] = "Yıl" };

    // STOKLAR.KDV - GENINI BOLUM -2790'daki 6 secenek (kod_liste.DEGER bir SIRA numarasi,
    //   stok.kdv kolonu ise DOGRUDAN ORANI tutuyor - kod_liste.AD burada). O yuzden
    //   KodListesi mekanizmasi (deger<->deger eslesir varsayar) DEGIL, GENINI'den elle
    //   alinmis sabit liste kullanildi (deger = etiket = oranin kendisi).
    private static readonly Dictionary<string, string> KdvKodlari =
        new() { ["0"] = "0", ["1"] = "1", ["8"] = "8", ["10"] = "10", ["18"] = "18", ["20"] = "20" };

    // STOKBARKOD.BARKOD_TIPI - GENINI degil, Delphi'de sabit 2 secenek + BARKODAYARLAR
    //   (kullanici tanimli, migrate edilmedi - bkz. Utablo.pas:14136).
    private static readonly Dictionary<string, string> BarkodTipiKodlari =
        new() { ["0"] = "Kullanıcı", ["100"] = "Karekod" };

    // TARAF_ADRES.TUR - yeni tablo (GENINI karsiligi yok), 001_sema_taraf.sql check kisitindan.
    private static readonly Dictionary<string, string> AdresTurKodlari =
        new() { ["1"] = "Fatura", ["2"] = "Sevkiyat", ["3"] = "Merkez", ["4"] = "Şube/Depo", ["9"] = "Diğer" };

    // Kisi'nin adres tipi Cari'den FARKLI anlam tasir (ayni tur kolonu, ayni check kisiti
    //   1/2/3/4/9 - hangi liste gecerli, o satirin sahibi taraf.kisi'ye gore belirlenir).
    //   Kullanici: "kişi de adres tipleri sadece Ev/İş olabilir".
    private static readonly Dictionary<string, string> KisiAdresTurKodlari =
        new() { ["1"] = "Ev", ["2"] = "İş" };

    // TARAF.ROL (kisi_karti.html/kisi_listesi.html "KARAR/ETKİ/MUHS/KULL/TEKN") - GENINI
    //   karsiligi yok, mockup'a ozel sabit liste (040_kisi_rol.sql).
    private static readonly Dictionary<string, string> KisiRolKodlari =
        new() { ["1"] = "Karar Verici", ["2"] = "Etkileyen", ["3"] = "Kullanıcı", ["4"] = "Mali/Muhasebe", ["5"] = "Teknik" };

    // PERSONEL_OZLUK.CINSIYET - GENINI karsiligi yok, yeni tablo (046_personel_kart.sql).
    private static readonly Dictionary<string, string> CinsiyetKodlari =
        new() { ["1"] = "Erkek", ["2"] = "Kadın" };

    // PERSONEL_OZLUK.CALISMA_SEKLI - GENINI karsiligi yok (047_personel_ozluk_ogrenim.sql).
    private static readonly Dictionary<string, string> CalismaSekliKodlari =
        new() { ["1"] = "Tam Zamanlı", ["2"] = "Yarı Zamanlı" };

    // PERSONEL_OZLUK.VARDIYA_TURU - GENINI karsiligi yok (048_personel_ozluk_uyruk_vardiya_sgk.sql).
    private static readonly Dictionary<string, string> VardiyaTuruKodlari =
        new() { ["1"] = "Gündüz", ["2"] = "Gece", ["3"] = "Vardiyalı" };

    // PERSONEL_OZLUK.MEDENI_HAL - GENINI karsiligi yok (049_personel_ozluk_medeni_kan.sql).
    private static readonly Dictionary<string, string> MedeniHalKodlari =
        new() { ["1"] = "Bekar", ["2"] = "Evli", ["3"] = "Boşanmış", ["4"] = "Dul" };

    // PERSONEL_OZLUK.SOZLESME_TURU - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).
    private static readonly Dictionary<string, string> SozlesmeTuruKodlari =
        new() {
            ["1"] = "Belirsiz Süreli", ["2"] = "Belirli Süreli", ["3"] = "Deneme Süreli",
            ["4"] = "Stajyer/Çırak", ["5"] = "Mevsimlik",
        };

    // PERSONEL_OZLUK.DENEME_SURESI - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).
    private static readonly Dictionary<string, string> DenemeSuresiKodlari =
        new() { ["0"] = "Yok", ["1"] = "1 Ay", ["2"] = "2 Ay", ["3"] = "3 Ay", ["4"] = "4 Ay" };

    // PERSONEL_IZIN.TUR/DURUM - ik_karti.html mockup ("Yıllık İzin/Mazeret/...", "Onaylı/
    //   Bekliyor/Reddedildi") - GENINI karsiligi yok (052_personel_izin.sql).
    private static readonly Dictionary<string, string> IzinTuruKodlari =
        new() { ["1"] = "Yıllık İzin", ["2"] = "Mazeret", ["3"] = "Rapor", ["4"] = "Ücretsiz İzin", ["9"] = "Diğer" };
    private static readonly Dictionary<string, string> IzinDurumuKodlari =
        new() { ["1"] = "Bekliyor", ["2"] = "Onaylı", ["3"] = "Reddedildi" };

    // PERSONEL_EGITIM.TUR - ik_karti.html mockup ("Diploma/Sertifika/Eğitim") - GENINI
    //   karsiligi yok (053_personel_egitim.sql).
    private static readonly Dictionary<string, string> EgitimTuruKodlari =
        new() { ["1"] = "Diploma", ["2"] = "Sertifika", ["3"] = "Eğitim" };

    // --------------------------------------------------------------- cari ----
    private static KartTanimi Cari() => new(
        Ad: "cari",
        YetkiKodu: "cari",
        Tablo: "public.taraf",
        LogTabloId: 71,                       // GENINI -11110: 71 = Cari
        SabitKosul: "(musteri = 1 or tedarikci = 1)",
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK (019 modeli)
        KapsamKolonu: "id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["musteri"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("kod",         "kod",          "metin", EnFazlaUzunluk: 20,  Baslik: "Kod",            Grup: "Kimlik"),
            new("unvan",       "unvan",        "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan",  Grup: "Kimlik"),
            // idstrip'ten kaldirildi (mockup'ta da yok, sadece Unvan var) - Fatura Bilgileri'ne dustu.
            new("ad",          "ad",           "metin", EnFazlaUzunluk: 50,  Baslik: "Ad"),
            new("soyad",       "soyad",        "metin", EnFazlaUzunluk: 60,  Baslik: "Soyad"),
            // Roller SEKMESI KALDIRILDI (mockup'ta yok) - Musteri/Tedarikci toolbar'a tasindi
            //   (bkz. GenForm.tsx kaynak==='cari'), Kisi Genel sekmesinde kaldi.
            new("musteri",     "musteri",      "mantik", Baslik: "Musteri"),
            new("tedarikci",   "tedarikci",    "mantik", Baslik: "Tedarikci"),
            new("kisi",        "kisi",         "mantik", Baslik: "Kisi"),
            // "Mali" -> "Fatura Bilgileri" (mockup adi birebir; AltGrup ile mockup'un iki
            //   kutusuna ayrildi: Fatura / Vergi Kimligi + e-Belge Ayarlari. Mockup'taki XSLT/
            //   Alias alanlari (E-Fatura XSLT, E-Irsaliye XSLT, E-Arsiv XSLT, Alias/e-Posta)
            //   backend'de kolon karsiligi yok (taraf tablosunda yok) - eklenmedi.
            new("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani", Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new("vkno",        "vkno",         "metin", EnFazlaUzunluk: 20,  Baslik: "VKN / TCKN",     Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new("vd",          "vd",           "metin", EnFazlaUzunluk: 60,  Baslik: "Vergi Dairesi",  Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new("efatura",     "efatura",      "mantik", Baslik: "e-Fatura mukellefi", Grup: "Fatura Bilgileri", AltGrup: "e-Belge Ayarlari"),
            new("aliasEposta", "alias_eposta", "metin", EnFazlaUzunluk: 200, Baslik: "Alias / e-Posta", Grup: "Fatura Bilgileri", AltGrup: "e-Belge Ayarlari"),
            // "Iletisim"/"Siniflandirma"/"Diger" SEKME DEGIL - mockup'ta Genel'in alt-kutulari
            //   (Kart Bilgileri / İletişim / Notlar). Grup kaldirildi, AltGrup ile Genel'e katlandi.
            new("telefon",     "telefon",      "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon",        AltGrup: "İletişim"),
            new("cepTel",      "cep_tel",      "metin", EnFazlaUzunluk: 30,  Baslik: "Cep Telefonu",   AltGrup: "İletişim"),
            new("eposta",      "eposta",       "metin", EnFazlaUzunluk: 120, Baslik: "E-posta",        AltGrup: "İletişim"),
            new("epostaWeb",   "eposta_web",   "metin", EnFazlaUzunluk: 200, Baslik: "Web", AltGrup: "İletişim"),
            // "Grup" YERINE Kategori/İlk Temas + Sektor/Alt Sektor + Sinif/Bolge (kullanici)
            //   - GenForm.tsx bu ciftleri AYNI SATIRDA yan yana render eder, sirayla:
            //   Kategori/İlk Temas, Sektör/Alt Sektör, Sınıf/Bölge, Temsilci/Özel Kod.
            new("kategori",    "kategori",     "kod",   KodListesi: "taraf.kategori",   Baslik: "Kategori",   AltGrup: "Tanımlama"),
            new("ilkTemas",    "ilk_temas",    "kod",   KodListesi: "taraf.ilk_temas",  Baslik: "İlk Temas",  AltGrup: "Tanımlama"),
            new("sektor",      "sektor",       "kod",   KodListesi: "taraf.sektor",     Baslik: "Sektör",     AltGrup: "Tanımlama"),
            new("altSektor",   "alt_sektor",   "kod",   KodListesi: "taraf.alt_sektor", Baslik: "Alt Sektör", AltGrup: "Tanımlama"),
            new("sinif",       "sinif",        "kod",   KodListesi: "taraf.sinif",      Baslik: "Sınıf",      AltGrup: "Tanımlama"),
            new("bolge",       "bolge",        "kod",   KodListesi: "taraf.bolge",      Baslik: "Bölge",      AltGrup: "Tanımlama"),
            new("temsilci",    "temsilci",     "kod",   Baslik: "Temsilci",  AltGrup: "Tanımlama"),
            new("ozelKod",     "ozel_kod",     "metin", EnFazlaUzunluk: 20,  Baslik: "Ozel Kod",       AltGrup: "Tanımlama"),
            new("notlar",      "notlar",       "metin", EnFazlaUzunluk: 1000, Baslik: "Notlar",        AltGrup: "Notlar"),
            new("durum",       "durum",        "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum",    Grup: "Kimlik"),
            new("subeId",      "sube_id",      "sayi",  Yazilabilir: false),
            new("eklemeTarihi","ekleme_tarihi","tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: AdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                // Il ONCE, Ilce SONRA (kullanici: "İl önce ... İlçe sonra") - Ilce'nin
                //   secimi zaten Il'e bagli (cascading), sira da mantiksal olarak boyle.
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901)   // yeni tablo - eski karsiligi yok
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge",        "taraf_id", "Bu cariye ait belge var, silinemez."),
            new SilmeEngeli("public.mali_hareket", "taraf_id", "Bu cariye ait kasa/banka hareketi var, silinemez."),
            new SilmeEngeli("public.kullanici",    "taraf_id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

    // --------------------------------------------------------------- kisi ----
    // kisi_karti.html mockup - kapsam kullaniciyla netlestirildi: TEMEL kimlik/iletisim.
    // Rol/yetki seviyesi/raporladigi kisi/dogum-cinsiyet-medeni durum/dil/iliski skoru/
    // etiket/foto/iletisim gecmisi/ilgili kayitlar/KVKK-izin/notlar-ekler EKLENMEDI -
    // DB'de hicbirinin karsiligi yoktu, tam kapsamli ayri, cok daha buyuk bir is olurdu.
    // Ayni taraf tablosu (kisi=1, bag_id ile sirkete bagli) - unvan (Ad Soyad gorunen adi)
    // 037_kisi_karti.sql'deki trigger ile ad+soyad'dan OTOMATIK uretiliyor, alanda YOK.
    private static KartTanimi Kisi() => new(
        Ad: "kisi",
        YetkiKodu: "cari",                    // ayri yetki kodu yok - cari yetkisiyle yonetiliyor
        Tablo: "public.taraf",
        LogTabloId: 71,                       // ayni fiziksel tablo - cari ile ayni GENINI kodu
        SabitKosul: "kisi = 1",
        KapsamKolonu: "bag_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["kisi"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            // Ad/Soyad DEGIL, Cari ile ayni desen: "Unvan" tek goruntulenen alan. Ad/Soyad
            //   ayrimi BILEREK yapilmadi - kullanici bunu ileride IK (personel) ve hasta
            //   kartlarina sakladi, kisi kartinda degil (038_kisi_karti_unvan_geri_al.sql).
            // idstrip sirasi kullanici tarafindan belirlendi: Kod, Unvan, Departman, Gorev.
            //   Durum idstrip'ten CIKARILDI (kullanici sonradan Durum'suz istedi) - Is
            //   Bilgileri kutusuna tasindi (Bagli Cari ile birlikte).
            new("id",        "id",         "sayi",  Yazilabilir: false),
            // YeniKayitVarsayilanlari'ndaki "kisi"=1 buraya yazilabilsin diye (alan
            //   tanimsizsa EkleAsync kolonu atlar, DB varsayilanina - 0/false - duser,
            //   sonra SabitKosul "kisi = 1" yeni kaydi bulamaz -> "Nullable ... value" hatasi).
            //   UI'da gorunmez (gizli Set, GenForm.tsx).
            new("kisi",      "kisi",       "mantik", Baslik: "Kisi"),
            new("kod",       "kod",        "metin", EnFazlaUzunluk: 20, Baslik: "Kisi Kodu", Grup: "Kimlik"),
            new("unvan",     "unvan",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan", Grup: "Kimlik"),
            new("departman", "departman",  "kod",   KodListesi: "taraf.departman", Baslik: "Departman", Grup: "Kimlik"),
            new("gorev",     "gorev",      "metin", EnFazlaUzunluk: 100, Baslik: "Gorev", Grup: "Kimlik"),
            // "Is Bilgileri" kutu basligi IPTAL edildi (kullanici) - Bagli Cari/Rol/Durum
            //   AltGrup'suz (adsiz) duz alan olarak kaliyor, idstrip'in hemen altinda.
            new("bagId",     "bag_id",     "kod",   KodTablosu: "public.v_cari_lookup", Baslik: "Bagli Cari"),
            new("rol",       "rol",        "kod",   SabitKodlar: KisiRolKodlari, Baslik: "Rol"),
            new("durum",     "durum",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum"),
            new("telefon",   "telefon",    "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon",         AltGrup: "İletişim"),
            new("cepTel",    "cep_tel",    "metin", EnFazlaUzunluk: 30,  Baslik: "Cep Telefonu",    AltGrup: "İletişim"),
            new("eposta",    "eposta",     "metin", EnFazlaUzunluk: 120, Baslik: "E-posta",         AltGrup: "İletişim"),
            new("epostaWeb", "eposta_web", "metin", EnFazlaUzunluk: 200, Baslik: "2. E-posta",      AltGrup: "İletişim"),
            new("subeId",        "sube_id",       "sayi",  Yazilabilir: false),
            new("eklemeTarihi",  "ekleme_tarihi", "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // kisi_karti.html mockup'taki "Adres" kutusu - Cari ile AYNI taraf_adres tablosu
            //   (taraf_id = bu kisi satirinin id'si, kişi de bir taraf). Ayni LogTabloId (901).
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: KisiAdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901),
            // "Geçmiş" sekmesi (kullanici) - SALT OKUNUR, elle satir eklenmez/silinmez;
            //   KisiDeposu.BaglaAsync/KoparAsync yonetir (041_taraf_gecmis.sql).
            new DetayTanimi("gecmis", "public.taraf_gecmis", "kisi_id", new KartAlani[]
            {
                new("id",             "id",              "sayi", Yazilabilir: false),
                new("cariId",         "cari_id",         "kod",  KodTablosu: "public.v_cari_lookup", Baslik: "Cari"),
                new("baslamaTarihi",  "baslama_tarihi",  "tarih", Baslik: "Başlama"),
                new("bitisTarihi",    "bitis_tarihi",    "tarih", Baslik: "Bitiş")
            }, Sirala: "bitis_tarihi desc nulls first, baslama_tarihi desc", SubeKolonu: null,
               Baslik: "Geçmiş", SaltOkunur: true)
        });

    // ----------------------------------------------------------- personel ----
    // Kisi'den FARKLI: Ad/Soyad KULLANILIYOR (kullanici bunu bilerek IK/hasta kartlarina
    //   saklamisti - 038_kisi_karti_unvan_geri_al.sql yorumu). "unvan" kolonu (taraf'ta
    //   NOT NULL) UI'da hic gorunmez - GenForm.tsx Kaydet'te ad+soyad'dan birlestirilip
    //   gonderilir (KişI'deki gibi bir DB trigger DEGIL - Kişi'de trigger user'in elle
    //   yazdigi Unvan'i sessizce ezme riski tasiyordu; burada unvan zaten hic gosterilip
    //   duzenlenmedigi icin risk yok, DB seviyesinde tetikleyici gerekmiyor).
    private static KartTanimi Personel() => new(
        Ad: "personel",
        YetkiKodu: "personel",
        Tablo: "public.taraf",
        LogTabloId: 73,                       // eski GENINI TABLOID: IK = 73 (bkz. silme-geri-al-tuzaklari)
        SabitKosul: "personel = 1",
        SubeKolonu: null,                     // Kisi liste kaynagiyla tutarli - ana veri, ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["personel"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",         "sayi",  Yazilabilir: false),
            // Kisi'deki "kisi" alani ile ayni sebep: YeniKayitVarsayilanlari'ndaki
            //   "personel"=1 buraya yazilabilsin diye tanimli, UI'da gizli (GenForm.tsx).
            new("personel",  "personel",   "mantik", Baslik: "Personel"),
            // "unvan" da UI'da GIZLI (gizli Set, GenForm.tsx) - ad+soyad'dan turetilir,
            //   ayrica DUZENLENMEZ, sadece DB NOT NULL kisitini karsilamak icin gonderilir.
            new("unvan",     "unvan",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan"),
            new("kod",       "kod",        "metin", EnFazlaUzunluk: 20, Baslik: "Sicil No", Grup: "Kimlik"),
            new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 50, Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",     "soyad",      "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Soyad", Grup: "Kimlik"),
            new("departman", "departman",  "kod",   KodListesi: "taraf.departman", Baslik: "Departman", Grup: "Kimlik"),
            new("durum",     "durum",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // ik_karti.html mockup'ta idstrip'te DEGIL - Görev "Pozisyon" adiyla Genel
            //   sekmesinin "Özet" kutusunda (PersonelKimlikOzet.tsx). TCKN de "Kimlik
            //   Bilgileri" kutusunda - ikisi de adsiz (Grup yok), gizli Set (GenForm.tsx)
            //   ile genel/duz render'dan cikarilip ozel bilesene props olarak geciyor.
            new("gorev",     "gorev",      "metin", EnFazlaUzunluk: 100, Baslik: "Pozisyon"),
            new("vkno",      "vkno",       "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "T.C. Kimlik No"),
            // ik_karti.html mockup'ta İletişim AYRI SEKME (Genel'e gomulu AltGrup DEGIL) -
            //   Grup:"İletişim" bu yuzden AltGrup degil.
            new("telefon",   "telefon",    "metin", EnFazlaUzunluk: 30,  Baslik: "Ev Telefonu",         Grup: "İletişim"),
            new("cepTel",    "cep_tel",    "metin", EnFazlaUzunluk: 30,  Baslik: "Cep",                 Grup: "İletişim"),
            new("eposta",    "eposta",     "metin", EnFazlaUzunluk: 120, Baslik: "E-posta (İş)",        Grup: "İletişim"),
            new("epostaWeb", "eposta_web", "metin", EnFazlaUzunluk: 200, Baslik: "E-posta (Kişisel)",   Grup: "İletişim"),
            // Diger kartlarda subeId salt-okunur/gizli meta alan - Personel'de kullanici
            //   isteğiyle GERCEK VERI: "Çalıştığı Şube" (kullanici: "taraf subeid de
            //   personelin Çalıştığı Şube yi tut"). Yazilabilir + KodTablosu ile secilebilir;
            //   bos birakilirsa oturumun subesi otomatik yazilir (KartDeposu.EkleAsync).
            new("subeId",        "sube_id",       "kod",   KodTablosu: "public.sube", Baslik: "Çalıştığı Şube"),
            new("eklemeTarihi",  "ekleme_tarihi", "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // Kisi ile AYNI taraf_adres tablosu, AYNI Ev/İş tur listesi (kisisel adres).
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: KisiAdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901),
            // Ozluk - personel_ozluk 1:1 (taraf_id UNIQUE, 046_personel_kart.sql'de
            //   synthetic id eklendi). Kisi'nin TekAdres'i gibi TEK SATIR gosterilir
            //   (TekOzluk.tsx) - satir ekle/sil YOK, tek satir hep var/yok.
            new DetayTanimi("ozluk", "public.personel_ozluk", "taraf_id", new KartAlani[]
            {
                new("id",                 "id",                  "sayi",  Yazilabilir: false),
                new("dogumTarihi",        "dogum_tarihi",        "tarih", Zorunlu: true, Baslik: "Doğum Tarihi"),
                new("dogumYeri",          "dogum_yeri",          "metin", EnFazlaUzunluk: 60, Baslik: "Doğum Yeri"),
                new("cinsiyet",           "cinsiyet",            "kod",   SabitKodlar: CinsiyetKodlari, Baslik: "Cinsiyet"),
                new("iseGirisTarihi",     "ise_giris_tarihi",    "tarih", Baslik: "İşe Giriş Tarihi"),
                new("istenCikisTarihi",   "isten_cikis_tarihi",  "tarih", Baslik: "İşten Çıkış Tarihi"),
                new("calismaSekli",       "calisma_sekli",       "kod",   SabitKodlar: CalismaSekliKodlari, Baslik: "Çalışma Şekli"),
                // Uyruk (ulke) - TekOzluk.tsx'te TekAdres'teki Ulke ile AYNI mekanizma
                //   (yerlerHook.useYerler, serbest SabitKodlar DEGIL - ulke.ad metin olarak
                //   yazilir), varsayilan TC (yerlerHook.VARSAYILAN_ULKE).
                new("uyruk",              "uyruk",               "metin", EnFazlaUzunluk: 60, Baslik: "Uyruğu"),
                new("vardiyaTuru",        "vardiya_turu",        "kod",   SabitKodlar: VardiyaTuruKodlari, Baslik: "Vardiya Türü"),
                new("sgkBaslamaTarihi",   "sgk_baslama_tarihi",  "tarih", Baslik: "SGK Başlama Tarihi"),
                new("medeniHal",          "medeni_hal",          "kod",   SabitKodlar: MedeniHalKodlari, Baslik: "Medeni Hal"),
                // taraf.kan_grubu ile AYNI kod_liste (hasta hazirligi icin bosti, 8 standart
                //   kan grubuyla dolduruldu, 049) - ileride Hasta karti da bunu kullanacak.
                new("kanGrubu",           "kan_grubu",           "kod",   KodListesi: "taraf.kan_grubu", Baslik: "Kan Grubu"),
                new("sozlesmeTuru",       "sozlesme_turu",       "kod",   SabitKodlar: SozlesmeTuruKodlari, Baslik: "Sözleşme Türü"),
                new("denemeSuresi",       "deneme_suresi",       "kod",   SabitKodlar: DenemeSuresiKodlari, Baslik: "Deneme Süresi"),
                // ik_karti.html mockup uyum turu (054): SGK Sicil No/Meslek Kodu/Yonetici.
                new("sgkSicilNo",         "sgk_sicil_no",        "metin", EnFazlaUzunluk: 30, Baslik: "SGK Sicil No"),
                new("meslekKodu",         "meslek_kodu",         "metin", EnFazlaUzunluk: 60, Baslik: "Meslek Kodu"),
                new("yoneticiId",         "yonetici_taraf_id",   "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Yönetici")
            }, Baslik: "Özlük"),
            // ik_karti.html mockup "İzinler" sekmesi (IZIN 1:N) - GERCEK COKLU-SATIR grid,
            //   generic GenDetayTablo (satir ekle/sil) yeterli, ozel bilesen gerekmiyor.
            new DetayTanimi("izinler", "public.personel_izin", "taraf_id", new KartAlani[]
            {
                new("id",               "id",                "sayi",  Yazilabilir: false),
                new("tur",              "tur",               "kod",   SabitKodlar: IzinTuruKodlari, Baslik: "Tür", Zorunlu: true),
                new("baslangicTarihi",  "baslangic_tarihi",  "tarih", Baslik: "Başlangıç"),
                new("bitisTarihi",      "bitis_tarihi",      "tarih", Baslik: "Bitiş"),
                new("gun",              "gun",               "sayi",  Baslik: "Gün"),
                new("aciklama",         "aciklama",          "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
                new("durum",            "durum",             "kod",   SabitKodlar: IzinDurumuKodlari, Baslik: "Durum")
            }, Sirala: "baslangic_tarihi desc, id desc", LogTabloId: 904, Baslik: "İzinler"),
            // ik_karti.html mockup "Eğitim / Sertifika" sekmesi (PERSONELEGITIM 1:N).
            new DetayTanimi("egitimler", "public.personel_egitim", "taraf_id", new KartAlani[]
            {
                new("id",          "id",          "sayi",  Yazilabilir: false),
                new("tur",         "tur",         "kod",   SabitKodlar: EgitimTuruKodlari, Baslik: "Tür", Zorunlu: true),
                new("ad",          "ad",          "metin", EnFazlaUzunluk: 200, Baslik: "Ad", Zorunlu: true),
                new("kurum",       "kurum",       "metin", EnFazlaUzunluk: 150, Baslik: "Kurum"),
                // Yalnız yıl (2024) veya normal tarih metni (2024-06-15 / 15.06.2024)
                // tutulabilir; DB kolonu 055 ile varchar(10) yapıldı.
                new("tarih",       "tarih",       "metin", EnFazlaUzunluk: 10, Baslik: "Tarih/Yıl"),
                new("gecerlilik",  "gecerlilik",  "metin", EnFazlaUzunluk: 60, Baslik: "Geçerlilik")
            }, Sirala: "tarih desc nulls last, id desc", LogTabloId: 905, Baslik: "Eğitim / Sertifika")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.kullanici", "taraf_id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

    // ----------------------------------------------------------------- rol ----
    // Kullanici: "eski sistemde rol tablosu ve buna bagli kullanici/personel vardi..
    //   role verdigimiz yetki dogrultusunda menuleri Gorme/Ekleme/Duzeltme/Silme islem
    //   yapabilirdi". Alt mekanizma (rol/yetki/rol_yetki/rol_alan_yetki, backend
    //   dogrulamasi, frontend menu/toolbar gate'i) ZATEN VARDI - eksik olan YONETIM
    //   EKRANIYDI. Bu kart + Yetki Matrisi sekmesi (RolYetkiMatrisi.tsx, ozel bilesen -
    //   generic Detay mekanizmasina UYMAZ, sabit "yetki" satirlari x Gor/Ekle/Degistir/
    //   Sil sutunlu matris; ayri RolYetkiUclari.cs/RolYetkiDeposu.cs).
    private static KartTanimi Rol() => new(
        Ad: "rol",
        YetkiKodu: "rol",                     // zaten seed'liydi (yetki.id=15, sira 62)
        Tablo: "public.rol",
        LogTabloId: 903,                      // yeni tablo - eski karsiligi yok (bkz. taraf_adres: 901)
        SubeKolonu: null,                     // ana tanim verisi - subeler arasi ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",         "sayi",  Yazilabilir: false),
            new("kod",       "kod",        "metin", Zorunlu: true, EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik"),
            new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 100, Baslik: "Ad",  Grup: "Kimlik"),
            new("ustRolId",  "ust_rol_id", "kod",   KodTablosu: "public.rol", Baslik: "Üst Rol", Grup: "Kimlik"),
            new("aktif",     "aktif",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Aktif", Grup: "Kimlik"),
            // Sistem rolleri (Yonetici/Salt okuyucu) - kod/ad degistirilemez/silinemez
            //   hale getirmek ayri bir is (SilmeEngeli + Yazilabilir kontrolu); simdilik
            //   sadece salt-okunur GORUNUR, kullanici "sistem" rolu oldugunu bilsin.
            new("sistem",    "sistem",     "mantik", Yazilabilir: false, Baslik: "Sistem Rolü"),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false)
        });

    // --------------------------------------------------------------- stok ----
    private static KartTanimi Stok() => new(
        Ad: "stok",
        YetkiKodu: "stok",
        Tablo: "public.stok",
        LogTabloId: 88,                       // GENINI -11110: 88 = Stoklar
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",              "sayi",  Yazilabilir: false),
            new("kod",           "kod",             "metin", Zorunlu: true, EnFazlaUzunluk: 30, Baslik: "Stok Kodu", Grup: "Kimlik"),
            new("ad",            "ad",              "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Stok Adi", Grup: "Kimlik"),
            // mockup idstrip: Stok Kodu / Stok Adi / Tur / Durum - Tur (STOKLAR.TIPI) daha once hic acilmamisti.
            new("tipi",          "tipi",            "kod",   KodListesi: "stok.tipi", Baslik: "Tur", Grup: "Kimlik"),
            // mockup "Genel" sekmesi 3 alt-bolume ayrilir: Tanım / Sınıflandırma · Vergi & Ana Birim · Resim
            //   (Resim - IMAJ→DOSYA - hic acilmadi, alan yok). Ayri Mali/Diger SEKMESI YOK -
            //   mockup'ta da yok, KDV/OTV/Min Stok buraya katlandi (eskiden ayri sekmelerdi).
            new("kategori",      "kategori",        "kod",   KodTablosu: "public.kategori", Baslik: "Kategori", AltGrup: "Tanım / Sınıflandırma"),
            new("marka",         "marka",           "kod",   KodListesi: "stok.marka",     Baslik: "Marka",     AltGrup: "Tanım / Sınıflandırma"),
            new("model",         "model",           "metin", EnFazlaUzunluk: 60, AltGrup: "Tanım / Sınıflandırma"),
            new("grup",          "grubu",           "kod",   KodListesi: "stok.grubu",     Baslik: "Grup",      AltGrup: "Tanım / Sınıflandırma"),
            new("izleme",        "izleme",          "kod",   KodListesi: "stok.izleme", Baslik: "Izleme",       AltGrup: "Tanım / Sınıflandırma"),
            new("bildirim",      "bildirim",        "kod",   SabitKodlar: BildirimKodlari, Baslik: "Bildirim",  AltGrup: "Tanım / Sınıflandırma"),
            new("urunNo",        "urun_no",         "metin", EnFazlaUzunluk: 60, Baslik: "Urun No",             AltGrup: "Vergi & Ana Birim"),
            new("gtipKodu",      "gtip_kodu",       "metin", EnFazlaUzunluk: 30, Baslik: "GTIP Kodu",           AltGrup: "Vergi & Ana Birim"),
            new("anaBirim",      "ana_birim",       "kod",   KodListesi: "stok.ana_birim",  Baslik: "Ana Birim",AltGrup: "Vergi & Ana Birim"),
            new("kdv",           "kdv",             "kod",   SabitKodlar: KdvKodlari, Baslik: "KDV %", AltGrup: "Vergi & Ana Birim"),
            new("otvYuzde",      "otv_yuzde",       "para", Baslik: "OTV %",  AltGrup: "Vergi & Ana Birim"),
            new("internetSatis", "internet_satis",  "mantik", AltGrup: "Vergi & Ana Birim"),
            // Mockup'ta 3. kutu "Resim" - bu alanlarin orada karsiligi yok, ust-satirin
            //   ALTINDA adsiz/duz bolum olarak kalsinlar (kasira'nin 2 kutusunu bozmasin).
            new("rafKonum",      "raf_konum",       "metin", EnFazlaUzunluk: 30, Baslik: "Raf / Konum",         AltGrup: "Diğer"),
            new("rafOmruSure",   "raf_omru_sure",   "sayi",  Baslik: "Raf Ömrü", AltGrup: "Diğer", EslesAlan: "rafOmruBirim"),
            new("rafOmruBirim",  "raf_omru_birim",  "kod",   SabitKodlar: RafOmruBirimKodlari, AltGrup: "Diğer"),
            new("minStok",       "min_stok",        "para", Baslik: "Minimum Stok", AltGrup: "Diğer"),
            new("ozelKod",       "ozel_kod",        "metin", EnFazlaUzunluk: 20, AltGrup: "Diğer"),
            new("faturaStokAdi", "fatura_stok_adi", "metin", EnFazlaUzunluk: 200, Baslik: "Faturadaki Ad", AltGrup: "Diğer"),
            new("durum",         "durum",           "kod",   SabitKodlar: DurumKodlari, Grup: "Kimlik"),
            new("subeId",        "sube_id",         "sayi",  Yazilabilir: false),
            new("eklemeTarihi",  "ekleme_tarihi",   "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            new DetayTanimi("barkodlar", "public.stok_barkod", "stok_id", new KartAlani[]
            {
                new("id",           "id",             "sayi", Yazilabilir: false),
                new("barkod",       "barkod",         "metin", Zorunlu: true, EnFazlaUzunluk: 50),
                // GENINI degil - Delphi kaynaginda BILE yorumlu ("tipleri programa gomdum"),
                //   asil kaynak BARKODAYARLAR (kullanici tanimli, bize hic migrate edilmedi,
                //   BILIM'de de bos) + 2 sabit secenek. O ikisi kondu, kullanici-tanimli
                //   tipler (nadir - 1419 satirin 1'i) EKLENMEDI.
                new("barkodTipi",   "barkod_tipi",    "kod", SabitKodlar: BarkodTipiKodlari, Baslik: "Barkod Tipi"),
                // Ayri GENINI bolumu yok - barkod_birimi/stok_fiyat.birim stok.ana_birim ile
                //   AYNI birim listesini paylasiyor (veride dogrulandi: 12=Gun,51=Adet,57=Kg...).
                new("barkodBirimi", "barkod_birimi",  "kod", KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("varsayilan",   "varsayilan",     "mantik")
            }, Sirala: "varsayilan desc, id", SubeKolonu: null, LogTabloId: 340,   // stok_barkodta sube_id YOK
                                                                                   // (GENINI -11110: Stok Barkod)
               Baslik: "Birim / Barkod"),                                         // mockup: "Birim / Barkod" sekmesi

            new DetayTanimi("fiyatlar", "public.stok_fiyat", "stok_id", new KartAlani[]
            {
                new("id",          "id",           "sayi", Yazilabilir: false),
                new("fiyatAdi",    "fiyat_adi",    "kod"),
                new("birim",       "birim",        "kod", KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("fiyat",       "fiyat",        "para", Zorunlu: true),
                new("dovizCinsi",  "doviz_cinsi",  "kod"),
                new("satis",       "satis",        "mantik")
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 346),  // stok_fiyatta sube_id YOK
                                                                   // (GENINI -11110: Stok Fiyat)

            // mockup "Seri / Lot" sekmesi - gercek tablo (011_sema_stok.sql), id kolonu var,
            //   duzenlenebilir DetayTanimi'ne birebir uyuyor.
            new DetayTanimi("seriLot", "public.stok_seri_lot", "stok_id", new KartAlani[]
            {
                new("id",                 "id",                   "sayi",  Yazilabilir: false),
                new("lotNo",               "lot_no",               "metin", EnFazlaUzunluk: 30, Baslik: "Lot No"),
                new("lotNoEx",             "lot_no_ex",            "metin", EnFazlaUzunluk: 30, Baslik: "Lot No (Ek)"),
                new("seriNo",              "seri_no",              "metin", EnFazlaUzunluk: 30, Baslik: "Seri No"),
                new("uretimTarihi",        "uretim_tarihi",        "tarih", Baslik: "Uretim Tarihi"),
                new("sonKullanmaTarihi",   "son_kullanma_tarihi",  "tarih", Baslik: "Son Kullanma Tarihi")
            }, Sirala: "id desc", SubeKolonu: null, LogTabloId: 902, Baslik: "Seri / Lot")  // yeni tablo - eski karsiligi yok (bkz. taraf_adres: 901)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge_satir", "stok_id", "Bu stok belgelerde kullanilmis, silinemez."),
            new SilmeEngeli("public.stok_izleme", "stok_id", "Bu stokun hareket kaydi var, silinemez.")
        });
}
