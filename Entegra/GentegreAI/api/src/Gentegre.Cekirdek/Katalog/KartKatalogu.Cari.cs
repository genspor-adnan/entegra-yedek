namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Cari, kisi, personel, hasta ve rol kartlari.
/// </summary>
public static partial class KartKatalogu
{
    // --------------------------------------------------------------- cari ----
    /// <summary>
    /// Aday musteri karti - cari kartinin AYNISI, yalniz YETKI KODU farkli
    /// ('aday'): satici rolu adaylari yonetebilsin ama cari kartlarini
    /// acamasin (kullanici: "sadece crm gelsin").
    /// </summary>
    private static KartTanimi Aday() => Cari() with { Ad = "aday", YetkiKodu = "aday" };

    /// <summary>
    /// DIS HEKIM adres tipleri (305): hekimin bizi ilgilendiren adresleri
    /// muayenehanesi ve calistigi hastanedir - "ev/is" ayrimi burada anlamsiz.
    /// </summary>
    private static readonly Dictionary<string, string> HekimAdresTurKodlari = new()
    {
        ["1"] = "Muayenehane",
        ["2"] = "Hastane",
        ["9"] = "Diğer",
    };

    private static KartTanimi Cari() => new(
        Ad: "cari",
        YetkiKodu: "cari",
        Tablo: "public.taraf",
        LogTabloId: 71,                       // GENINI -11110: 71 = Cari
        // ADAY (122) da bu kartla acilir: sabit kosul adayi disarida birakirsa
        //   kayit yazilir ama geri OKUNAMAZ ("Nullable object must have a
        //   value") - kisi kartinda ayni tuzak yasanmisti.
        SabitKosul: "(musteri = 1 or tedarikci = 1 or aday = 1)",
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
            // ADAY (122): henuz musteri olmayan firma. Anlasma saglaninca
            //   musteri=1 / aday=0 olur - AYNI kayit, gecmisi (firsat, gorev,
            //   adres, ilgili kisi) yerinde kalir.
            // ADAY kutusu kartta CIZILMEZ (kullanici): adaylik durumu listeden
            //   ("Müşteriye Dönüştür" aksiyonu) yonetilir, kartta elle
            //   isaretlenecek bir sey degil. Alan SILINMEDI, GIZLI: Aday
            //   Musteriler listesi yeni kayitta aday=true gonderiyor ve alan
            //   metadan cikarsa o deger hic yazilmaz - yeni aday, aday
            //   listesinde gorunmezdi.
            new("aday",        "aday",         "mantik", Baslik: "Aday", Gizli: true),
            new("kisi",        "kisi",         "mantik", Baslik: "Kisi"),
            // "Mali" -> "Adres / Fatura Bilgisi" (kullanici: adres de bu sekmede duruyor; AltGrup ile
            //   kutusuna ayrildi: Fatura / Vergi Kimligi + e-Belge Ayarlari. Mockup'taki XSLT/
            //   Alias alanlari (E-Fatura XSLT, E-Irsaliye XSLT, E-Arsiv XSLT, Alias/e-Posta)
            //   backend'de kolon karsiligi yok (taraf tablosunda yok) - eklenmedi.
            new("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new("vkno",        "vkno",         "metin", EnFazlaUzunluk: 20,  Baslik: "Vergi / Kimlik No",     Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new("vd",          "vd",           "metin", EnFazlaUzunluk: 60,  Baslik: "Vergi Dairesi",  Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            // ÜTS verme bildiriminde KUN buradan okunur (225).
            new("utsKurumNo",  "uts_kurum_no", "metin", EnFazlaUzunluk: 30,  Baslik: "ÜTS Kurum No",   Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new("efatura",     "efatura",      "mantik", Baslik: "e-Fatura mukellefi", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            new("aliasEposta", "alias_eposta", "metin", EnFazlaUzunluk: 200, Baslik: "Alias / e-Posta", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            // FIYAT LISTESI (204). IKI AYRI ALAN: bir cari hem musteri hem
            //   tedarikci olabiliyor; tek alan olsaydi ayni cariye satarken de
            //   alirken de ayni liste uygulanirdi. Bos ise yonun VARSAYILAN
            //   listesi gecerli - her cariye tek tek atamak gerekmez.
            new("satisFiyatListesiId", "satis_fiyat_listesi_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_satis_lookup",
                Baslik: "Satış Fiyat Listesi", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fiyatlandırma"),
            new("alisFiyatListesiId",  "alis_fiyat_listesi_id",  "kod",
                KodTablosu: "public.v_fiyat_listesi_alis_lookup",
                Baslik: "Alış Fiyat Listesi", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fiyatlandırma"),
            // KAMPANYA (274): listenin YERINE gecmez, USTUNE isler - liste baz
            //   fiyati, kampanya indirimi verir. Bos ise genel kampanya (varsa)
            //   gecerli olur; anlasmali kurumda kampanya sozlesmeden gelir ve
            //   bunu ezer (fn_taraf_kampanya).
            new("kampanyaId", "kampanya_id", "kod",
                KodTablosu: "public.v_kampanya_lookup",
                Baslik: "Kampanya", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fiyatlandırma"),
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
            // TEMSILCI kimlik seridinde (Unvan'in saginda): "bu cari kimin"
            //   sorusu kartin en ustunde cevaplanmali. Deger PERSONEL taraf
            //   id'sidir - eskiden kod listesi bagli degildi ve ekranda ham
            //   sayi goruluyordu.
            new("temsilci",    "temsilci",     "kod",   KodTablosu: "public.v_personel_lookup",
                                                        Baslik: "Temsilci", Grup: "Kimlik"),
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
            new SilmeEngeli("public.taraf_kullanici",    "id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

    // --------------------------------------------------------------- kisi ----
    // kisi_karti.html mockup - kapsam kullaniciyla netlestirildi: TEMEL kimlik/iletisim.
    // Rol/yetki seviyesi/raporladigi kisi/dogum-cinsiyet-medeni durum/dil/iliski skoru/
    // etiket/foto/iletisim gecmisi/ilgili kayitlar/KVKK-izin/notlar-ekler EKLENMEDI -
    // DB'de hicbirinin karsiligi yoktu, tam kapsamli ayri, cok daha buyuk bir is olurdu.
    // Ayni taraf tablosu (kisi=1, bag_id ile sirkete bagli) - unvan (Ad Soyad gorunen adi)
    // 037_kisi_karti.sql'deki trigger ile ad+soyad'dan OTOMATIK uretiliyor, alanda YOK.

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
            new("departman", "departman",  "kod",   KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm", Grup: "Kimlik"),
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
            new("kod",       "kod",        "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Sicil No", Grup: "Kimlik"),
            new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 50, Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",     "soyad",      "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Soyad", Grup: "Kimlik"),
            // Departman kod listesi degil TABLO (251): bolum/hekim iliskisi de
            //   buradan kuruluyor - randevu bolumu bir departmandir.
            new("departman", "departman",  "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm", Grup: "Kimlik"),
            // RANDEVU VERILEBILIR (252, kullanici: "randevu verilen bolumle
            //   randevu verilen personel bulusmus olur") - departman tarafinda
            //   da ayni bayrak var (251); ikisi kesisince "hekim" cikar.
            // Grup VERILMEZ: "Kimlik" grubu kartin UST SERIDINI besliyor, alan
            //   orada degil İş Bilgileri kutusunda cizilir (252, kullanici).
            // "randevuVerilebilir" KALKTI (711): hekim randevu alir mi = calisma
            //   plani var mi (Randevu › Çalışma Planları). Kolon DB'de duruyor.
            new("durum",     "durum",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // ik_karti.html mockup'ta idstrip'te DEGIL - Görev "Pozisyon" adiyla Genel
            //   sekmesinin "Özet" kutusunda (PersonelKimlikOzet.tsx). TCKN de "Kimlik
            //   Bilgileri" kutusunda - ikisi de adsiz (Grup yok), gizli Set (GenForm.tsx)
            //   ile genel/duz render'dan cikarilip ozel bilesene props olarak geciyor.
            // Pozisyon KOD (236, kullanici: "combo ve ID olarak olsun") - eski
            //   serbest metin kolonu (taraf.gorev) veri olarak duruyor.
            // Gorev artik kod listesi degil TABLO (255) ve DEPARTMANA BAGLI:
            //   secilen departmanin gorevleri + bagimsiz gorevler listelenir
            //   (kullanici: "personel kartinda departmana gore bu gorev listesi
            //   gelecek ve secilecek").
            new("gorevId",   "gorev_id",   "kod",   Zorunlu: true,
                KodTablosu: "public.v_gorev_lookup", BagliAlan: "departman",
                Baslik: "Görev"),
            new("vkno",      "vkno",       "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kimlik No"),
            // ik_karti.html mockup'ta İletişim AYRI SEKME (Genel'e gomulu AltGrup DEGIL) -
            //   Grup:"İletişim" bu yuzden AltGrup degil.
            new("telefon",   "telefon",    "metin", EnFazlaUzunluk: 30,  Baslik: "Ev Telefonu",         Grup: "İletişim"),
            new("cepTel",    "cep_tel",    "metin", Zorunlu: true, EnFazlaUzunluk: 30,  Baslik: "Cep",        Grup: "İletişim"),
            new("eposta",    "eposta",     "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "E-posta (İş)", Grup: "İletişim"),
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
            // PRIM ROLLERI (361): kisi hangi rolde prim alabilir. Bir kisi hem
            //   isteyen hem yapan hem uygulayan olabilir - o yuzden GRID, tek
            //   secim degil. DIS HEKIM yalniz "Gonderen" alabilir; kurali DB
            //   dogrular (tg_taraf_prim_rol_dogrula).
            new DetayTanimi("primRolleri", "public.taraf_prim_rol", "taraf_id", new KartAlani[]
            {
                // ID SART (387): cerceve detay satirlarini `id` ile adresler
                //   (insert'te returning id). Tabloda kolon YOKTU ve grid
                //   "column id does not exist" ile 500 veriyordu.
                new("id", "id", "sayi", Yazilabilir: false),
                new("rol", "rol", "kod", Zorunlu: true, KodListesi: "prim.rol",
                    Baslik: "Prim Rolü"),
                // Onerilen: basvuru hekim combosu ve prim rol modali once
                //   isaretlileri gosterir (uzun listede aranan kisi ustte olsun).
                new("varsayilan", "varsayilan", "mantik", Baslik: "Önerilen"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama")
            }, SubeKolonu: null, Sirala: "rol", Baslik: "Prim Rolleri", LogTabloId: 963,
               // SEKME YALNIZ "PRIMLI" PERSONELDE (kullanici): prim almayan
               //   kadrolu personelde bos bir rol gridi gostermek, doldurulacak
               //   bir sey varmis izlenimi veriyordu. Isaret ozluk (1:1
               //   taraf_personel) satirinda oldugu icin kosul DETAY ALANINA
               //   bakar - "ozluk.calismaSekli=3".
               KosulAlani: "ozluk.calismaSekli=3"),
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
            // ik_karti.html İletişim sekmesi: "Acil Durumda Aranacak Kişiler"
            // REHBERILETISIM (1:N) mockup karsiligi. Ayrı sekme degil, İletişim
            // sekmesinde Ev Adresi'nin altina gomulu grid olarak render edilir.
            // 335: tablo ORTAK (taraf_acil_kisi) - personelin acil kisisi ile
            //   hastanin yakini ayni bilgidir, iki karttan da ayni tabloya yazilir.
            new DetayTanimi("acilKisiler", "public.taraf_acil_kisi", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("varsayilan", "varsayilan",  "mantik", Baslik: "★"),
                new("adSoyad",    "ad_soyad",    "metin", EnFazlaUzunluk: 120, Baslik: "Ad Soyad", Zorunlu: true),
                new("yakinlik",   "yakinlik",    "kod",   SabitKodlar: YakinlikKodlari, Baslik: "Yakınlık"),
                new("telefon",    "telefon",     "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon"),
                new("eposta",     "eposta",      "metin", EnFazlaUzunluk: 120, Baslik: "e-Posta"),
                // 374: TC kimlik ya da yabanci kimlik/pasaport - metin, 11 hane
                //   zorunlulugu yok (yakin yabanci olabilir).
                new("kimlikNo",   "kimlik_no",   "metin", EnFazlaUzunluk: 20,  Baslik: "Kimlik No")
            }, Sirala: "varsayilan desc, sira, id", LogTabloId: 906, Baslik: "Acil Durumda Aranacak Kişiler"),
            // Ozluk - taraf_personel 1:1 (id = taraf.id). Kisi'nin TekAdres'i gibi TEK SATIR gosterilir
            //   (TekOzluk.tsx) - satir ekle/sil YOK, tek satir hep var/yok.
            new DetayTanimi("ozluk", "public.taraf_personel", "id", new KartAlani[]
            {
                new("id",                 "id",                  "sayi",  Yazilabilir: false),
                new("dogumTarihi",        "dogum_tarihi",        "tarih", Zorunlu: true, Baslik: "Doğum Tarihi"),
                new("dogumYeri",          "dogum_yeri",          "metin", EnFazlaUzunluk: 60, Baslik: "Doğum Yeri"),
                // Cinsiyet/medeni hal/uyruk KOD LISTESINDEN (609): listelerin
                //   icerigi SKRS'den birebir cekildi, kodda elle yazilmis
                //   kisaltilmis kopya tutmuyoruz. Elle yazilan liste iki
                //   secenekti (Erkek/Kadin); SKRS'de dort - "belirtilmedi"
                //   ve "belirsiz" de gecerli kayit degerleri.
                new("cinsiyet",           "cinsiyet",            "kod",   KodListesi: "hasta.cinsiyet", Baslik: "Cinsiyet"),
                new("iseGirisTarihi",     "ise_giris_tarihi",    "tarih", Zorunlu: true, Baslik: "İşe Giriş Tarihi"),
                new("istenCikisTarihi",   "isten_cikis_tarihi",  "tarih", Baslik: "İşten Çıkış Tarihi"),
                new("calismaSekli",       "calisma_sekli",       "kod",   SabitKodlar: CalismaSekliKodlari, Baslik: "Çalışma Şekli"),
                // Uyruk artik SKRS ULKE KODLARI'ndan secilir (614/615): alan
                //   metin degil kod, degeri MERNIS kodudur ve e-Nabiz'a
                //   ceviri olmadan gider. Serbest metinken "TC", "TR",
                //   "Türkiye" hepsi ayni seyi yaziyordu ve hicbiri USS'nin
                //   kabul ettigi kod degildi.
                new("uyruk",              "uyruk",               "kod",   KodTablosu: "public.v_skrs_ulke_lookup", Baslik: "Uyruğu"),
                new("vardiyaTuru",        "vardiya_turu",        "kod",   SabitKodlar: VardiyaTuruKodlari, Baslik: "Vardiya Türü"),
                new("sgkBaslamaTarihi",   "sgk_baslama_tarihi",  "tarih", Baslik: "SGK Başlama Tarihi"),
                new("medeniHal",          "medeni_hal",          "kod",   KodListesi: "hasta.medeni_hal", Baslik: "Medeni Hal"),
                // taraf.kan_grubu ile AYNI kod_liste (hasta hazirligi icin bosti, 8 standart
                //   kan grubuyla dolduruldu, 049) - ileride Hasta karti da bunu kullanacak.
                new("kanGrubu",           "kan_grubu",           "kod",   KodListesi: "taraf.kan_grubu", Baslik: "Kan Grubu"),
                new("sozlesmeTuru",       "sozlesme_turu",       "kod",   SabitKodlar: SozlesmeTuruKodlari, Baslik: "Sözleşme Türü"),
                new("denemeSuresi",       "deneme_suresi",       "kod",   SabitKodlar: DenemeSuresiKodlari, Baslik: "Deneme Süresi"),
                // ik_karti.html mockup uyum turu (054): SGK Sicil No/Meslek Kodu/Yonetici.
                new("sgkSicilNo",         "sgk_sicil_no",        "metin", EnFazlaUzunluk: 30, Baslik: "SGK Sicil No"),
                new("meslekKodu",         "meslek_kodu",         "kod",   KodTablosu: "public.v_skrs_meslek_lookup", Baslik: "Meslek Kodu"),
                new("yoneticiId",         "yonetici_taraf_id",   "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Yönetici")
            }, Baslik: "Özlük"),
            // ik_karti.html mockup "İzinler" sekmesi (IZIN 1:N) - GERCEK COKLU-SATIR grid,
            //   generic GenDetayTablo (satir ekle/sil) yeterli, ozel bilesen gerekmiyor.
            new DetayTanimi("izinler", "public.personel_izin", "taraf_id", new KartAlani[]
            {
                new("id",               "id",                "sayi",  Yazilabilir: false),
                new("tur",              "tur",               "kod",   SabitKodlar: IzinTuruKodlari, Baslik: "Tür", Zorunlu: true),
                new("baslangicTarihi",  "baslangic_tarihi",  "tarih", Zorunlu: true, Baslik: "Başlama"),
                new("bitisTarihi",      "bitis_tarihi",      "tarih", Zorunlu: true, Baslik: "Bitiş"),
                // Gün elle girilmez: baslangic/bitis'ten hesaplanir (iki uc dahil).
                new("gun",              "gun",               "sayi",  Yazilabilir: false, Baslik: "Gün"),
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
            }, Sirala: "tarih desc nulls last, id desc", LogTabloId: 905, Baslik: "Eğitim / Sertifika"),
            // HEKIMIN RANDEVU DUZENI (252, kullanici: "personelde Randevu
            //   Verilebilir seciliyse Randevu sekmesi olusur ve bu personele
            //   ait randevu ayarlari gorunur, istenirse duzenlenebilir").
            //   Randevu Ayarlari > Bölümler ekranindaki AYNI satir - iki yerden
            //   de duzenlenebilir, veri tek yerde (randevu_bolum_ayar).
            //   Bos birakilan alan bolumden, o da Genel Ayarlar'dan devralinir.
            new DetayTanimi("randevuAyar", "public.randevu_bolum_ayar", "hekim_id",
            new KartAlani[]
            {
                new("id",              "id",              "sayi",  Yazilabilir: false),
                new("departmanId",     "departman_id",    "kod",   Zorunlu: true,
                    KodTablosu: "public.v_randevu_bolum_lookup", Baslik: "Bölüm"),
                new("baslangicSaat",   "baslangic_saat",  "metin", EnFazlaUzunluk: 5,
                    Baslik: "Başlama"),
                new("bitisSaat",       "bitis_saat",      "metin", EnFazlaUzunluk: 5, Baslik: "Bitiş"),
                new("ogleBaslangic",   "ogle_baslangic",  "metin", EnFazlaUzunluk: 5,
                    Baslik: "Öğle Başl."),
                new("ogleBitis",       "ogle_bitis",      "metin", EnFazlaUzunluk: 5,
                    Baslik: "Öğle Bitiş"),
                new("slotDk",          "slot_dk",         "sayi",  Baslik: "Aralık (dk)"),
                new("varsayilanSure",  "varsayilan_sure", "sayi",  Baslik: "Süre (dk)"),
                new("calismaGunleri",  "calisma_gunleri", "metin", EnFazlaUzunluk: 20,
                    Baslik: "Günler (1 Pzt … 7 Paz)"),
                new("aktif",           "aktif",           "mantik", Baslik: "Randevuya Açık"),
                new("aciklama",        "aciklama",        "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, LogTabloId: 912, Baslik: "Randevu Ayarları")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.taraf_kullanici", "id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

}
