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
            new("vkno",        "vkno",         "metin", EnFazlaUzunluk: 20,  Baslik: "VKN / TCKN",     Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
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
            new("randevuVerilebilir", "randevu_verilebilir", "mantik",
                Baslik: "Randevu Verilebilir"),
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
            new("vkno",      "vkno",       "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "T.C. Kimlik No"),
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
                new("yakinlik",   "yakinlik",    "metin", EnFazlaUzunluk: 60,  Baslik: "Yakınlık"),
                new("telefon",    "telefon",     "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon"),
                new("eposta",     "eposta",      "metin", EnFazlaUzunluk: 120, Baslik: "e-Posta")
            }, Sirala: "varsayilan desc, sira, id", LogTabloId: 906, Baslik: "Acil Durumda Aranacak Kişiler"),
            // Ozluk - taraf_personel 1:1 (id = taraf.id). Kisi'nin TekAdres'i gibi TEK SATIR gosterilir
            //   (TekOzluk.tsx) - satir ekle/sil YOK, tek satir hep var/yok.
            new DetayTanimi("ozluk", "public.taraf_personel", "id", new KartAlani[]
            {
                new("id",                 "id",                  "sayi",  Yazilabilir: false),
                new("dogumTarihi",        "dogum_tarihi",        "tarih", Zorunlu: true, Baslik: "Doğum Tarihi"),
                new("dogumYeri",          "dogum_yeri",          "metin", EnFazlaUzunluk: 60, Baslik: "Doğum Yeri"),
                new("cinsiyet",           "cinsiyet",            "kod",   SabitKodlar: CinsiyetKodlari, Baslik: "Cinsiyet"),
                new("iseGirisTarihi",     "ise_giris_tarihi",    "tarih", Zorunlu: true, Baslik: "İşe Giriş Tarihi"),
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
            }, SubeKolonu: null, LogTabloId: 912, Baslik: "Randevu Ayarları",
               KosulAlani: "randevuVerilebilir")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.taraf_kullanici", "id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

    // ---------------------------------------------------------- kategori ----
    /// <summary>
    /// KATEGORI karti (270, kullanici: "kategori istedigimiz kadar alt seviyeli
    /// olmali", "kodu ve adi olmali"). Stok VE hizmet ayni agaci kullanir (269);
    /// kampanya satiri "su kategoriden %20" derken bu agactan secer.
    /// Ust kategori dongusu DB tetiginde engellenir.
    /// </summary>
    private static KartTanimi Kategori() => new(
        Ad: "kategori",
        YetkiKodu: "stok",
        Tablo: "public.kategori",
        LogTabloId: 916,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["aktif"] = (short)1, ["tur"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",     "id",     "sayi",  Yazilabilir: false),
            new("kod",    "kod",    "metin", EnFazlaUzunluk: 20, Baslik: "Kod", Grup: "Kimlik"),
            new("ad",     "ad",     "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                Baslik: "Kategori", Grup: "Kimlik"),
            // TUR (345/346) ARKA PLAN ALANI (kullanici: "karta girince tur
            //   gorunmesine gerek yok, girilen gride gore belli"): kart hangi
            //   bolmeden acildiysa deger oradan gelir ve kayitla birlikte
            //   gonderilir - ekranda yer kaplamasi gereksiz, yanlis secim
            //   kapisi da acardi.
            new("tur",    "tur",    "kod",   SabitKodlar: KategoriTurKodlari,
                Baslik: "Tür", Grup: "Kimlik", Gizli: true),
            // Bos ise KOK kategori; secilirse altina gecer (sinirsiz derinlik).
            new("ustId",  "ust_id", "kod",   KodTablosu: "public.v_kategori_lookup",
                Baslik: "Üst Kategori", Grup: "Kimlik"),
            new("aktif",  "aktif",  "mantik", Baslik: "Durum", Grup: "Kimlik"),
            new("subeId", "sube_id", "kod",  Gizli: true),
        });

    // ---------------------------------------------------------- departman ----
    /// <summary>
    /// Departman karti (251) - personel departmani ve randevu bolumu AYNI
    /// tablodur; `randevuVerilebilir` isaretlenirse randevu kartinin Bölüm
    /// listesinde cikar.
    /// </summary>
    private static KartTanimi Departman() => new(
        Ad: "departman",
        YetkiKodu: "personel",
        Tablo: "public.departman",
        LogTabloId: 911,
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",                 "id",                  "sayi",  Yazilabilir: false),
            // Kod bos birakilabilir (254): 41 eski departmanda kod yok, zorunlu
            //   yapmak hepsini elle kodlamayi gerektirirdi.
            new("kod",                "kod",                 "metin", EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",                 "ad",                  "metin", Zorunlu: true,
                EnFazlaUzunluk: 100, Baslik: "Bölüm", Grup: "Kimlik"),
            // Ust birim (257): secilirse departman digerinin ALTINA gecer.
            //   Bos = kok departman. Dongu (kendi altina alma) DB tetiginde.
            new("ustbirimId",         "ustbirim_id",         "kod",
                KodTablosu: "public.v_departman_lookup", Baslik: "Üst Birim", Grup: "Kimlik"),
            new("randevuVerilebilir", "randevu_verilebilir", "mantik",
                Baslik: "Randevu Bölümü", Grup: "Kimlik"),
            // Kolon adi `durum` (256, kullanici) - taraf.durum / fiyat_listesi.durum ile ayni.
            new("durum",              "durum",               "mantik", Baslik: "Durum", Grup: "Kimlik"),
            new("sira",               "sira",                "sayi",  Baslik: "Sıra", Grup: "Kimlik"),
        });

    // ------------------------------------------------------------- gorev ----
    /// <summary>
    /// Personel gorevi (255). Departmana BAGLANABILIR ama zorunlu degil:
    /// departman_id = 0 birakilirsa gorev bagimsizdir, her departmanda secilir.
    /// </summary>
    private static KartTanimi PersonelGorev() => new(
        // "gorev" adi CRM gorevlerinde kullaniliyor (Kasa.cs) - bu personelin
        //   POZISYONU, ayri kaynak adi.
        Ad: "personel-gorev",
        YetkiKodu: "personel",
        Tablo: "public.personel_gorev",
        LogTabloId: 913,
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["departmanId"] = 0,
        },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("ad",          "ad",           "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                Baslik: "Görev", Grup: "Kimlik"),
            // Bos birakilirsa (0) bagimsiz gorev - her departmanda listelenir.
            new("departmanId", "departman_id", "kod",   KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm", Grup: "Kimlik"),
            new("durum",       "durum",        "mantik", Baslik: "Durum", Grup: "Kimlik"),
            new("sira",        "sira",         "sayi",  Baslik: "Sıra", Grup: "Kimlik"),
        });

    // -------------------------------------------------------- aday hasta ----
    /// <summary>
    /// ADAY HASTA karti (266, kullanici: "sade basit bir Aday Hasta karti...
    /// zorunlu alanlar ad, soyad, cep; digerleri eposta, tcno, kurum, cinsiyet,
    /// dogum tarihi, il, ilce; dosya no olarak cep numarasini versin").
    ///
    /// Randevu verirken hasta bulunamayinca aciliyor: tam hasta kartinin
    /// (sekmeler, ozluk, fatura bilgileri) yerine tek ekranlik hizli giris.
    /// Ayni TABLO (taraf + taraf_hasta) - sonradan tam kartla tamamlanir.
    /// </summary>
    /// <summary>
    /// DIS DOKTOR KARTI (305) - goruntuleme merkezine hasta GONDEREN, kurum
    /// disindaki hekim.
    ///
    /// Personel kartinin kardesi: ayni taraf + taraf_personel ikilisini
    /// kullanir, ayirt eden taraf_personel.dis_hekim = 1. Ayri tablo acmak
    /// ad/telefon/adres alanlarini ikinci kez tanimlamak olurdu; ustelik ayni
    /// kisi hem kurumda calisip hem baska merkezden sevk edebiliyor.
    ///
    /// Personelden FARKI: sicil no, departman, gorev, ise giris gibi OZLUK
    /// alanlari yok - onun yerine brans, calistigi kurum ve tescil no var.
    /// </summary>
    private static KartTanimi DisHekim() => new(
        Ad: "dis-hekim",
        YetkiKodu: "personel",
        Tablo: "public.taraf",
        LogTabloId: 73,
        // taraf.sube_id NOT NULL: kayit oturumun subesiyle yazilsin diye sube
        //   kolonu ACIKCA verilir (KartTanimi varsayilani null'dur). Dis hekim
        //   subeye ait degil ama kolon dolmali - kullanicidan sorulmaz.
        SubeKolonu: "sube_id",
        // Kart YALNIZ dis hekimleri acar: kurum personeli bu ekrandan
        //   duzenlenmemeli (orada departman/gorev zorunlu).
        SabitKosul: "personel = 1 and exists (select 1 from public.taraf_personel p "
                  + "where p.id = taraf.id and p.dis_hekim = 1)",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["personel"] = (short)1,
            ["durum"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",       "id",       "sayi",  Yazilabilir: false),
            new("personel", "personel", "mantik", Gizli: true),
            // Unvan ad+soyaddan turetilir (personel kartiyla ayni kural).
            new("unvan",    "unvan",    "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Unvan", Gizli: true),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 50,
                Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",    "soyad",    "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Soyad", Grup: "Kimlik"),
            // Kod ZORUNLU DEGIL: dis hekimin bizde sicili yok - bos birakilirsa
            //   sunucu numara vermez, ad soyad yeter.
            new("kod",      "kod",      "metin", EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Kimlik"),
            new("durum",    "durum",    "kod",   SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // TEMSILCI = BIZIM personelimiz (kullanici): bu hekimle ilgilenen,
            //   iliskiyi yuruten kisi - hekimin kendi kurumundaki biri degil.
            new("temsilci", "temsilci", "kod",   KodTablosu: "public.v_personel_lookup",
                Baslik: "Temsilci", Grup: "Kimlik"),
            // BOLUM (367, kullanici: "seçtim ama bölüm dolmadı"): gonderen
            //   hekimin hastayi HANGI BOLUME gonderdigi. Basvuruda hekim
            //   secilince Bölüm alani bundan doldurulur - memur ayni bilgiyi
            //   ikinci kez secmesin. Bos birakilabilir (o zaman bolum elle).
            new("departman", "departman", "kod", KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm", Grup: "Kimlik"),
            new("cepTel",   "cep_tel",  "metin", EnFazlaUzunluk: 30, Baslik: "Cep"),
            new("telefon",  "telefon",  "metin", EnFazlaUzunluk: 30, Baslik: "Telefon"),
            new("eposta",   "eposta",   "metin", EnFazlaUzunluk: 200, Baslik: "E-posta"),
            // CALISTIGI KURUM (309): personel uzantisinda DEGIL tarafin kendi
            //   bag_id'sinde - "Bağlı Kurum" bagi kisi/cari ekranlariyla ortak,
            //   ayni bilgiyi ikinci bir kolonda tutmak gerekmiyor. Yalniz
            //   KAYITLI cari (308): kayitli degilse arama ekranindaki "+ Yeni".
            //   Combo degil JENERIK ARAMA: cari listesi binlerce kayit olabilir;
            //   KodTablosu secili kaydin ADINI cozmek icin durur.
            //   Grup "Hekim Bilgisi": sekme olarak DEGIL, Genel sekmesindeki
            //   Hekim Bilgisi kutusunun icinde cizilir (KartGrupSekmesi).
            new("kurumId",  "bag_id",   "kod",   KodTablosu: "public.v_cari_lookup",
                AramaKaynagi: "cari", Baslik: "Kurum", Grup: "Hekim Bilgisi"),
            // TC No YOK (kullanici): dis hekimin kimlik numarasini biz tutmuyoruz -
            //   sevk eden hekim icin gerekli olan iletisim ve tescil bilgisidir.
            // taraf'ta serbest not kolonu "notlar" (aciklama YOK).
            new("notlar",   "notlar",   "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            // subeId ALAN OLARAK YOK: dis hekim subeye ait degil ama taraf.sube_id
            //   NOT NULL - kart tanimindaki SubeKolonu sayesinde oturumun subesi
            //   kayit sirasinda yazilir. Personel kartinda alan VAR cunku orada
            //   "calistigi sube" gercek bir bilgi; burada degil.
        },
        Detaylar: new[]
        {
            new DetayTanimi("hekim", "public.taraf_personel", "id", new KartAlani[]
            {
                new("id",       "id",        "sayi", Yazilabilir: false),
                new("brans",    "brans",     "kod", KodListesi: "hekim.brans",
                    Baslik: "Branş"),
                new("tescilNo", "tescil_no", "metin", EnFazlaUzunluk: 30,
                    Baslik: "Diploma / Tescil No"),
                // taraf_personel'de ZATEN VAR - dis hekimde "kadrolu / part-time /
                //   serbest" ayrimini tasir, yeni kolon gerekmedi.
                new("calismaSekli", "calisma_sekli", "kod",
                    SabitKodlar: CalismaSekliKodlari, Baslik: "Çalışma Şekli"),
            // SubeKolonu VARSAYILAN: taraf_personel.sube_id NOT NULL - detay
            //   satiri oturumun subesiyle yazilir (null verilirse insert
            //   "subeId bos birakilamaz" ile patlar).
            }, Baslik: "Hekim Bilgisi", LogTabloId: 906, TekSatir: true,
               // Kaydi DIS hekim yapan bayrak KULLANICIDAN ISTENMEZ (305):
               //   hangi karttan girildigiyle belli. Kutu isaretlettirmek, ayni
               //   tabloyu paylasan iki kart arasindaki farki kullanicinin
               //   sorumluluguna atmak olurdu.
               YeniSatirVarsayilanlari: new Dictionary<string, object?>
               {
                   ["dis_hekim"] = (short)1,
               }),

            // ADRES (kullanici: "alta grid olarak da adres gelsin"): bir hekimin
            //   MUAYENEHANESI ve calistigi HASTANE(ler) ayri satirlardir - tek
            //   adres yetmez. Tablo cari/personel ile ayni, degisen yalniz tip
            //   listesi: burada "ev/is" degil "muayenehane/hastane" sorulur.
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: HekimAdresTurKodlari,
                    Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik"),
            }, Sirala: "varsayilan desc, id", LogTabloId: 901, Baslik: "Adres"),

            // GONDERIM GECMISI KATALOGDA DEGIL (305, kullanici: "frame kaldir
            //   ve gridi readonly gengrid yap"): detay tanimi kart formunun
            //   duzenlenebilir satir gridini cizerdi - burada gosterilen sey
            //   BASKA BIR EKRANIN kayitlari (radyoloji istemleri), duzenlenmez.
            //   Kartin "Gönderim Geçmişi" sekmesini KartGrupSekmesi ciziyor:
            //   liste ekranlarindaki GenGrid, salt okunur, hekim filtresiyle.
        });

    private static KartTanimi HastaAday() => new(
        Ad: "hasta-aday",
        YetkiKodu: "personel",
        Tablo: "public.taraf",
        LogTabloId: 71,
        SubeKolonu: null,
        SabitKosul: "hasta = 1",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["grup"] = (short)101,
            ["hasta"] = (short)1,
            ["musteri"] = (short)1,
            ["durum"] = (short)2,          // ADAY
        },
        Alanlar: new KartAlani[]
        {
            new("id",       "id",       "sayi",  Yazilabilir: false),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 50,
                Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",    "soyad",    "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Soyad", Grup: "Kimlik"),
            new("cepTel",   "cep_tel",  "metin", Zorunlu: true, EnFazlaUzunluk: 30,
                Baslik: "Cep", Grup: "Kimlik"),
            // Durum kimlik seridinde DEGIL arac cubugunda ROZET (kullanici):
            //   aday kaydinda degistirilecek bir alan degil, bir DURUM bilgisi.
            new("durum",    "durum",    "kod",   SabitKodlar: HastaDurumKodlari,
                Baslik: "Durum", Gizli: true),
            new("eposta",   "eposta",   "metin", EnFazlaUzunluk: 200, Baslik: "E-posta"),
            new("vkno",     "vkno",     "metin", EnFazlaUzunluk: 20, Baslik: "TC No"),
            // Dosya no (kod) CEP NUMARASINDAN uretilir - ekranda gosterilmez.
            new("kod",      "kod",      "metin", EnFazlaUzunluk: 20, Gizli: true),
            new("unvan",    "unvan",    "metin", EnFazlaUzunluk: 120, Gizli: true),
            // taraf.sube_id NOT NULL: alan GIZLI ama var - kart acilirken
            //   oturumun subesiyle dolar (GenForm yeni kayit varsayilani).
            new("subeId",   "sube_id",  "kod",   Gizli: true),
            new("grup",     "grup",     "kod",   Gizli: true),
            new("hasta",    "hasta",    "mantik", Gizli: true),
            new("musteri",  "musteri",  "mantik", Gizli: true),
        },
        Detaylar: new[]
        {
            // Hasta bilgisi (1:1): aday kartinda yalniz cinsiyet, dogum tarihi
            //   ve kurum - digerleri tam hasta kartinda.
            new DetayTanimi("ozluk", "public.taraf_hasta", "id", new KartAlani[]
            {
                new("id",          "id",           "sayi",  Yazilabilir: false),
                new("cinsiyet",    "cinsiyet",     "kod",   SabitKodlar: CinsiyetKodlari,
                    Baslik: "Cinsiyet"),
                new("dogumTarihi", "dogum_tarihi", "tarih", Baslik: "Doğum Tarihi"),
                // Kurum KIMLIK SERIDINDE cizilir (266) - burada yalniz veri
                //   tasiyicisi olarak duruyor, ekranda tekrar gosterilmez.
                new("kurumId",     "kurum_id",     "kod",   KodTablosu: "public.v_kurum_lookup",
                    Baslik: "Kurum", Gizli: true),
            }, SubeKolonu: null, Baslik: "Hasta Bilgisi", LogTabloId: 907, TekSatir: true),
            // IL / ILCE taraf'ta degil ADRES tablosunda (taraf_adres): aday
            //   kartinda tek adres satiri yeter, tam kartta adres listesi var.
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",   "id",   "sayi",  Yazilabilir: false),
                new("il",   "il",   "metin", EnFazlaUzunluk: 60, Baslik: "İl"),
                new("ilce", "ilce", "metin", EnFazlaUzunluk: 60, Baslik: "İlçe"),
            }, LogTabloId: 901, Baslik: "Adres", TekSatir: true),
        });

    // -------------------------------------------------------------- kurum ----
    /// <summary>
    /// ANLASMALI KURUM karti (249, kullanici: "hastanenin sozlesme yaptigi
    /// kurumlarin listesi... bunlar da bir nevi musteri, hastanin odemesini
    /// yapacak"). Cari kartinin turevi - kurum da fatura edilen, tahsilat
    /// yapilan bir caridir; ayri bir kart tipi acmak ayni alanlari ikinci kez
    /// tanimlamak olurdu. Farki: iki sekme (sozlesme basligi + fiyat politikasi
    /// satirlari) ve `kurum = 1` rol bayragi.
    /// </summary>
    private static KartTanimi Kurum()
    {
        var c = Cari();
        var alanlar = c.Alanlar.Select(a => a.Ad switch
        {
            "kod"   => a with { Baslik = "Kurum Kodu" },
            "unvan" => a with { Baslik = "Kurum Adı" },
            // CARI KAMPANYASI KURUMDA GIZLI (kullanici): kurumun fiyat kurali
            //   SOZLESMEDEN gelir (taraf_kurum.kampanya_id). Ayni kartta iki
            //   kampanya alani gorunmesi "hangisi gecerli" sorusunu doguruyordu -
            //   cozum sirasi zaten sozlesme > cari > genel (fn_taraf_kampanya),
            //   yani kurumda cari alani hicbir zaman kazanmaz.
            "kampanyaId" => a with { Gizli = true },
            _ => a
        }).ToList();
        alanlar.Add(new KartAlani("kurum", "kurum", "mantik", Baslik: "Kurum", Gizli: true));

        var detaylar = (c.Detaylar ?? Array.Empty<DetayTanimi>()).ToList();
        // SOZLESME BASLIGI - 1:1 (kurumun kendisi zaten sozlesmenin tarafi).
        detaylar.Add(new DetayTanimi("sozlesme", "public.taraf_kurum", "id", new KartAlani[]
        {
            new("id",             "id",               "sayi",  Yazilabilir: false),
            new("tur",            "tur",              "kod",   Zorunlu: true,
                KodListesi: "taraf.kurum_turu", Baslik: "Kurum Türü"),
            new("sozlesmeNo",     "sozlesme_no",      "metin", EnFazlaUzunluk: 40, Baslik: "Sözleşme No"),
            new("baslangic",      "baslangic",        "tarih", Baslik: "Başlama"),
            new("bitis",          "bitis",            "tarih", Baslik: "Bitiş"),
            new("durum",          "durum",            "mantik", Baslik: "Aktif"),
            // SOZLESME FIYAT LISTESI (302, kullanici: "kampanya soluna fiyat
            //   listesi ekle"). Kampanya yalniz INDIRIM tasiyabilir; anlasmanin
            //   BAZ listesi burada aciktan yazilir. Cozum sirasi:
            //   kampanya listesi > sozlesme listesi > kurumun cari listesi >
            //   hastanin listesi (fn_belge_varsayilan_liste).
            //   Yalniz SATIS yonlu listeler: kuruma hizmet SATILIYOR, alis
            //   listesi burada anlamsiz olurdu.
            new("fiyatListesiId", "fiyat_listesi_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_satis_lookup", Baslik: "Fiyat Listesi"),
            // Anlasma kosulu artik KAMPANYA (268): kampanyanin kendi fiyat
            //   listesi ve indirim satirlari var - ikisini ayri secmek ayni
            //   bilgiyi iki yere yazmak olurdu.
            new("kampanyaId",     "kampanya_id",      "kod",
                KodTablosu: "public.v_kampanya_lookup", Baslik: "Kampanya"),
            // ODEME PAYLASIMI (289): kurum payi NASIL faturalanir - SGK donem
            //   icmali ister, sigorta sirketleri cogunlukla vaka bazli fatura.
            new("faturalamaModu", "faturalama_modu",  "kod",
                KodListesi: "kurum.faturalama_modu", Baslik: "Faturalama"),
            // PAY HESAPLAMA MODU (291): sigorta sirketleri ORAN, SGK sabit
            //   KATILIM PAYI ile calisir - satir tutari buna gore bolunur.
            new("paylasimModu",   "paylasim_modu",    "kod",
                KodListesi: "kurum.paylasim_modu", Baslik: "Pay Hesabı"),
            // Provizyon girilmediginde uygulanacak karsilama orani (%).
            new("varsayilanKarsilama", "varsayilan_karsilama", "para",
                Baslik: "Varsayılan Karşılama %"),
            new("aciklama",       "aciklama",         "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
        }, SubeKolonu: null, Baslik: "Sözleşme", LogTabloId: 909, TekSatir: true));


        return c with
        {
            Ad = "kurum",
            YetkiKodu = "kurum",
            SabitKosul = "kurum = 1",
            YeniKayitVarsayilanlari = new Dictionary<string, object?>
            {
                ["kurum"] = (short)1,
                // Kurum AYNI ZAMANDA MUSTERI: basvuru/faturada cari olarak
                //   secilebilsin, cari hesabi ve ekstresi calissin.
                ["musteri"] = (short)1,
                ["durum"] = (short)1
            },
            Alanlar = alanlar.ToArray(),
            Detaylar = detaylar.ToArray()
        };
    }

    private static KartTanimi Hasta()
    {
        var p = Personel();
        var alanlar = p.Alanlar.Select(a => a.Ad switch
        {
            "personel" => new KartAlani("hasta", "hasta", "mantik", Baslik: "Hasta"),
            // 358: numara_sablonu (tur 900) otomatikse bos birakilabilir - DB
            //   trigger'i numarayi verir; elle modda ayni trigger bos birakmayi
            //   reddeder. Kart tarafinda zorunluluk kalkti ki otomatik modda
            //   kullanici gereksiz yere numara uydurmasin.
            "kod" => a with { Baslik = "Dosya No", Zorunlu = false },
            "vkno" => a with { Baslik = "TC No", Grup = "Kimlik", AltGrup = null },
            // Hastada zorunluluklar GEVSEK: gorev/e-posta personel alanlaridir,
            //   hasta kaydi acilirken istenmez (kayit kabul hizli olmali).
            "cepTel" => a with { Baslik = "Telefon", Zorunlu = false },
            "eposta" => a with { Zorunlu = false },
            "gorevId" => a with { Zorunlu = false, Gizli = true },
            "subeId" => a with { Baslik = "Şube" },
            // Hasta durumu dort degerli (266): Aktif / Pasif / Aday / Vefat.
            "durum" => a with { SabitKodlar = HastaDurumKodlari },
            _ => a
        }).Where(a => a.Ad is not ("departman" or "telefon" or "epostaWeb")).ToList();
        var durum = alanlar.FirstOrDefault(a => a.Ad == "durum");
        if (durum is not null)
        {
            alanlar.Remove(durum);
            var vknoIndex = alanlar.FindIndex(a => a.Ad == "vkno");
            alanlar.Insert(vknoIndex >= 0 ? vknoIndex + 1 : alanlar.Count, durum);
        }
        alanlar.AddRange(new[]
        {
            new KartAlani("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new KartAlani("vd", "vd", "metin", EnFazlaUzunluk: 60, Baslik: "Vergi Dairesi", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new KartAlani("efatura", "efatura", "mantik", Baslik: "e-Fatura mukellefi", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            new KartAlani("aliasEposta", "alias_eposta", "metin", EnFazlaUzunluk: 200, Baslik: "Alias / e-Posta", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            // YeniKayitVarsayilanlari'ndaki grup=101 kayda yazılsın; UI'da gizlenir.
            new KartAlani("grup", "grup", "kod", Baslik: "Grup")
        });

        var detaylar = p.Detaylar?.Select(d => d.Ad == "ozluk"
            ? new DetayTanimi("ozluk", "public.taraf_hasta", "id", new KartAlani[]
            {
                new("id",          "id",           "sayi",  Yazilabilir: false),
                new("dogumTarihi", "dogum_tarihi", "tarih", Baslik: "Dogum Tarihi"),
                new("dogumYeri",   "dogum_yeri",   "metin", EnFazlaUzunluk: 60, Baslik: "Dogum Yeri"),
                new("cinsiyet",    "cinsiyet",     "kod",   SabitKodlar: CinsiyetKodlari, Baslik: "Cinsiyet"),
                new("uyruk",       "uyruk",        "metin", EnFazlaUzunluk: 60, Baslik: "Uyrugu"),
                new("kanGrubu",    "kan_grubu",    "kod",   KodListesi: "taraf.kan_grubu", Baslik: "Kan Grubu"),
                new("meslek",      "meslek",       "kod",   SabitKodlar: HastaMeslekKodlari, Baslik: "Meslek"),
                // Odeyen kurum (266) hastanin kendisinde: cok policeli izleme
                //   ayri sekmede (taraf_hasta_kurum), burada tek alan yeter.
                new("kurumId",     "kurum_id",     "kod",   KodTablosu: "public.v_kurum_lookup",
                    Baslik: "Kurum / Ödeyen"),
                // 335 (Genotıp alan gereksinimleri): SKRS/eNabız icin gereken
                //   kimlik alanlari. Kod listelerinin DEGERI dogrudan SKRS
                //   kodudur - ayri eslestirme tablosu yok (kullanici karari).
                new("pasaportNo",  "pasaport_no",  "metin", EnFazlaUzunluk: 20,
                    Baslik: "Pasaport No"),
                new("medeniHal",   "medeni_hal",   "kod",   KodListesi: "hasta.medeni_hal",
                    Baslik: "Medeni Hal"),
                new("anaAdi",      "ana_adi",      "metin", EnFazlaUzunluk: 60, Baslik: "Ana Adı"),
                new("babaAdi",     "baba_adi",     "metin", EnFazlaUzunluk: 60, Baslik: "Baba Adı"),
                new("anneTckn",    "anne_tckn",    "metin", EnFazlaUzunluk: 11,
                    Baslik: "Anne T.C. No"),
                new("babaTckn",    "baba_tckn",    "metin", EnFazlaUzunluk: 11,
                    Baslik: "Baba T.C. No"),
                // Kimligi belirsiz hasta: TCKN olmadan kayit acilir.
                new("kimliksiz",   "kimliksiz",    "mantik", Baslik: "Kimliksiz Hasta"),
                new("yabanciHastaTuru", "yabanci_hasta_turu", "kod",
                    KodListesi: "hasta.yabanci_turu", Baslik: "Yabancı Hasta Türü"),
                new("ulkeyeGirisTarihi", "ulkeye_giris_tarihi", "tarih",
                    Baslik: "Ülkeye Giriş Tarihi"),
                new("vefat",       "vefat",        "mantik", Baslik: "Vefat"),
                new("vefatTarihi", "vefat_tarihi", "tarih", Baslik: "Vefat Tarihi"),
                // Dosya acilirken gosterilecek uyari - KLINIK nottan ayri.
                new("mahremiyetNotu", "mahremiyet_notu", "metin", EnFazlaUzunluk: 500,
                    Baslik: "Mahremiyet Notu")
            }, SubeKolonu: null, Baslik: "Hasta Bilgisi", LogTabloId: 907)
            : d)
            // PRIM ROLLERI HASTADA YOK (kullanici): rol "bu kisi hangi isten
            //   prim alir" demektir - isteyen/yapan/uygulayan hep PERSONELDIR.
            //   Sekme yalnizca personel kartindan mirasla geliyordu; hasta
            //   kartinda anlamsiz ve yanlis veri kapisi (hastaya prim rolu
            //   isaretlenirse basvuru hekim combosuna dusebilirdi).
            //   Dis hekimde de yok - orada rol "Çalışma Şekli" ile veriliyor.
            .Where(d => d.Ad != "primRolleri").ToList();

        // KURUM / ÖDEYEN (248, kullanici): hastanin sponsoru - Özel (kendi),
        //   ÖSS (sigorta sirketi) ya da SGK. 1:N: police ZAMANLA DEGISIR, her
        //   basvuruda guncel poliçe girilir, eskisi tarihçe olarak kalir.
        //   "Sonuncusu aktif" kurali DB tetiginde (tg_taraf_hasta_kurum_tek_aktif) -
        //   yeni satir eklenince oncekiler kendiliginden pasife duser.
        // HASTA YAKINI (335): ayri tanim EKLENMEZ - hasta karti personel
        //   kartindan turuyor ve "acilKisiler" detayini ZATEN miras aliyor.
        //   Tablo artik ortak (taraf_acil_kisi), yani hastanin yakini ile
        //   personelin acil kisisi ayni yere yaziliyor.

        detaylar?.Add(new DetayTanimi("kurum", "public.taraf_hasta_kurum", "hasta_id",
        new KartAlani[]
        {
            new("id",         "id",         "sayi",  Yazilabilir: false),
            new("tur",        "tur",        "kod",   Zorunlu: true,
                KodListesi: "taraf.kurum_turu", Baslik: "Kurum Türü"),
            // Anlasmali kurumlar (249) - tum cariler DEGIL: odeyen ancak
            //   sozlesmesi olan bir kurum olabilir.
            new("kurumId",    "kurum_id",   "kod",   KodTablosu: "public.v_kurum_lookup",
                Baslik: "Kurum / Sigorta"),
            new("policeNo",   "police_no",  "metin", EnFazlaUzunluk: 40, Baslik: "Poliçe No"),
            new("gecerlilik", "gecerlilik", "tarih", Baslik: "Geçerlilik"),
            new("kapsam",     "kapsam",     "metin", EnFazlaUzunluk: 200, Baslik: "Kapsam"),
            new("aciklama",   "aciklama",   "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
            // Yazilabilir: eski bir poliçeyi tekrar aktif etmek istenirse tetik
            //   digerlerini pasife ceker. Varsayilan 1 - son giren aktif olur.
            new("aktif",      "aktif",      "mantik", Baslik: "Aktif"),
        }, SubeKolonu: null, Sirala: "aktif desc, id desc",
           Baslik: "Kurum / Ödeyen", LogTabloId: 908));

        return p with
        {
            Ad = "hasta",
            // Ayrı hasta yetkisi seed edilmediği için personel yetkisiyle yönetilir.
            YetkiKodu = "personel",
            LogTabloId = 71,
            SabitKosul = "grup = 101",
            YeniKayitVarsayilanlari = new Dictionary<string, object?>
            {
                ["grup"] = (short)101,
                ["hasta"] = (short)1,
                // Hasta AYNI ZAMANDA MUSTERI: basvuru/fatura cari tarafinda
                //   secilebilsin (HBYS'de hastaya fatura kesilir).
                ["musteri"] = (short)1,
                ["durum"] = (short)1
            },
            Alanlar = alanlar.ToArray(),
            Detaylar = detaylar?.ToArray()
        };
    }

    // ----------------------------------------------------------------- rol ----
    // Kullanici: "eski sistemde rol tablosu ve buna bagli kullanici/personel vardi..
    //   role verdigimiz yetki dogrultusunda menuleri Gorme/Ekleme/Duzeltme/Silme islem
    //   yapabilirdi". Alt mekanizma (rol/yetki/rol_yetki/rol_alan_yetki, backend
    //   dogrulamasi, frontend menu/toolbar gate'i) ZATEN VARDI - eksik olan YONETIM
    //   EKRANIYDI. Bu kart + Yetki Matrisi sekmesi (RolYetkiMatrisi.tsx, ozel bilesen -
    //   generic Detay mekanizmasina UYMAZ, sabit "yetki" satirlari x Gor/Ekle/Degistir/
    //   Sil sutunlu matris; ayri RolYetkiUclari.cs/RolYetkiDeposu.cs).

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
            // Kod teknik alan: bos birakilirsa ADDAN uretilir, girilirse slug'a
            //   cevrilir (ck_rol_kod dar alfabe istiyor - "Satış Müdürü" patliyordu).
            new("kod",       "kod",        "metin", EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik",
                SlugKaynak: "ad"),
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
}
