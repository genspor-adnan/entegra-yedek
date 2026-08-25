namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kasa-banka alt sistemi kartlari: hesap, banka, cek/senet, proje, gorev, firsat, masraf merkezi, hesap plani.
/// </summary>
public static partial class KartKatalogu
{
    // --------------------------------------------------------------- hesap ----
    // Tur-ozel alanlar (Banka / POS-Kart) AltGrup ile ayrilir; GenForm bunlari
    //   ayri kutularda cizer. Bos kalmalari normaldir (kasa hesabinda IBAN yok).
    private static KartTanimi Hesap() => new(
        Ad: "hesap",
        YetkiKodu: "hesap",
        Tablo: "public.hesap",
        LogTabloId: 909,
        SubeKolonu: "sube_id",                // K11: her hesap tek subeye ait
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["dovizCinsi"] = "TL", ["tur"] = "K" },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",                "sayi",  Yazilabilir: false),
            new("tur",             "tur",               "kod",   Zorunlu: true, SabitKodlar: HesapTuruKodlari, Baslik: "Hesap Türü", Grup: "Kimlik"),
            new("kod",             "kod",               "metin", EnFazlaUzunluk: 40,  Baslik: "Kod",  Grup: "Kimlik"),
            new("ad",              "ad",                "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Ad", Grup: "Kimlik"),
            new("dovizCinsi",      "doviz_cinsi",       "kod",   Zorunlu: true, SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Kimlik"),
            new("durum",           "durum",             "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // --- Genel
            new("sorumluId",       "sorumlu_id",        "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Tanımlama"),
            new("bagliHesapId",    "bagli_hesap_id",    "kod",   KodTablosu: "public.v_hesap_lookup", Baslik: "Bağlı Hesap", Grup: "Genel", AltGrup: "Tanımlama"),
            new("altTur",          "alt_tur",           "kod",   KodListesi: "hesap.alt_tur", Baslik: "Alt Tür", Grup: "Genel", AltGrup: "Tanımlama"),
            new("aciklama",        "aciklama",          "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Tanımlama"),
            // Banka ve sube artik TANIM tablosundan secilir (109): elle yazilinca ayni
            //   banka uc farkli yazimla kaydediliyordu ("Ziraat", "T.C. Ziraat...").
            new("bankaId",         "banka_id",          "kod",   KodTablosu: "public.v_banka_lookup", Baslik: "Banka", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("bankaSubeId",     "banka_sube_id",     "kod",   KodTablosu: "public.v_banka_sube_lookup", BagliAlan: "bankaId", Baslik: "Şube", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("hesapNo",         "hesap_no",          "metin", EnFazlaUzunluk: 30, Baslik: "Hesap No", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("iban",            "iban",              "metin", EnFazlaUzunluk: 34, Baslik: "IBAN", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("komisyonOrani",   "komisyon_orani",    "para",  Baslik: "Komisyon %", Grup: "Genel", AltGrup: "POS / Kart"),
            new("komisyonMasrafId","komisyon_masraf_id","kod",   KodTablosu: "public.v_masraf_lookup", Baslik: "Komisyon Gider Kalemi", Grup: "Genel", AltGrup: "POS / Kart"),
            new("komisyonZamani",  "komisyon_zamani",   "kod",   SabitKodlar: KomisyonZamaniKodlari, Baslik: "Komisyon Kesimi", Grup: "Genel", AltGrup: "POS / Kart"),
            new("valorGun",        "valor_gun",         "sayi",  Baslik: "Valör (gün)", Grup: "Genel", AltGrup: "POS / Kart"),
            new("hesapKesimGunu",  "hesap_kesim_gunu",  "sayi",  Baslik: "Hesap Kesim Günü", Grup: "Genel", AltGrup: "POS / Kart"),
            new("sonOdemeGunu",    "son_odeme_gunu",    "sayi",  Baslik: "Son Ödeme Günü", Grup: "Genel", AltGrup: "POS / Kart"),
            new("limitTutar",      "limit_tutar",       "para",  Baslik: "Limit", Grup: "Genel", AltGrup: "POS / Kart"),
            new("acilisBakiye",    "acilis_bakiye",     "para",  Baslik: "Açılış Bakiyesi", Grup: "Genel", AltGrup: "Muhasebe"),
            new("acilisTarihi",    "acilis_tarihi",     "tarih", Baslik: "Açılış Tarihi", Grup: "Genel", AltGrup: "Muhasebe"),
            new("muhHesapId",      "muh_hesap_id",      "kod",   KodTablosu: "public.v_hesap_plani_lookup", Baslik: "Muhasebe Hesabı", Grup: "Genel", AltGrup: "Muhasebe"),
            new("subeId",          "sube_id",           "sayi",  Yazilabilir: false, Baslik: "Şube"),
            new("eklemeTarihi",    "ekleme_tarihi",     "tarih", Yazilabilir: false)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.mali_hareket", "hesap_id", "Bu hesabin hareketi var, silinemez."),
            new SilmeEngeli("public.kasa_islem",   "hesap_id", "Bu hesaba ait kasa islemi var, silinemez.")
        });


    /// <summary>
    /// Kartlarda kullanilan para birimleri. doviz_kur tablosundaki kodlarla ayni
    /// (TL yerel, digerleri kur tablosundan okunur) - elle metin girilince
    /// "TRY"/"tl" gibi varyantlar olusup kur eslesmesi kaciyordu.
    /// </summary>

    // --------------------------------------------------------------- banka ----
    /// <summary>
    /// Banka tanimi ve SUBELERI (109). Subeler ayri bir ekran degil, bankanin
    /// detay tablosu: sube tek basina anlamsizdir, hep bir bankaya aittir.
    /// </summary>
    private static KartTanimi Banka() => new(
        Ad: "banka",
        YetkiKodu: "hesap",                   // banka tanimi kasa/banka ekibinin isi
        Tablo: "public.banka",
        LogTabloId: 919,
        SubeKolonu: null,                     // ana veri - subeler arasi ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",      "id",      "sayi",  Yazilabilir: false),
            new("kod",     "kod",     "metin", EnFazlaUzunluk: 10, Baslik: "EFT Kodu", Grup: "Kimlik"),
            new("ad",      "ad",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Banka Adı", Grup: "Kimlik"),
            new("kisaAd",  "kisa_ad", "metin", EnFazlaUzunluk: 40, Baslik: "Kısa Ad", Grup: "Kimlik"),
            new("aktif",   "aktif",   "mantik", Baslik: "Aktif", Grup: "Kimlik"),
            new("swift",   "swift",   "metin", EnFazlaUzunluk: 15, Baslik: "SWIFT / BIC", Grup: "Genel"),
            new("sira",    "sira",    "sayi",  Baslik: "Sıra", Grup: "Genel"),
        },
        Detaylar: new[]
        {
            new DetayTanimi("subeler", "public.banka_sube", "banka_id", new KartAlani[]
            {
                new("id",      "id",      "sayi",  Yazilabilir: false),
                new("kod",     "kod",     "metin", EnFazlaUzunluk: 10, Baslik: "Kod"),
                new("ad",      "ad",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Şube Adı"),
                new("il",      "il",      "metin", EnFazlaUzunluk: 60, Baslik: "İl"),
                new("ilce",    "ilce",    "metin", EnFazlaUzunluk: 60, Baslik: "İlçe"),
                new("telefon", "telefon", "metin", EnFazlaUzunluk: 30, Baslik: "Telefon"),
                new("aktif",   "aktif",   "mantik", Baslik: "Aktif"),
            }, Sirala: "ad", SubeKolonu: null, LogTabloId: 920, Baslik: "Şubeler")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.hesap",     "banka_id", "Bu bankaya bagli hesap var, silinemez."),
            new SilmeEngeli("public.cek_senet", "banka_id", "Bu bankaya bagli cek/senet var, silinemez."),
        });

    // --------------------------------------------------------------- proje ----

    // ------------------------------------------------------------ cek/senet ----
    // durum Yazilabilir:false - portfoy durumu ELLE degil, yalnizca aksiyonlarla
    //   (tahsil / ciro / bozdur / iade) degisir; her degisim cek_senet_hareket'e
    //   iz birakir. Elle degistirilebilse defter ile durum tutarsizlasirdi.
    private static KartTanimi CekSenet() => new(
        Ad: "cek-senet",
        YetkiKodu: "cek_senet",
        Tablo: "public.cek_senet",
        LogTabloId: 910,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)10, ["tur"] = (short)1, ["yon"] = (short)1,
              ["dovizCinsi"] = "TL", ["dovizKuru"] = 1m },
        // Yeni cek/senette ilk is kimin kagidi oldugunu secmektir.
        AcilistaTarafSecimi: "tarafId",
        // TL disi bir para birimi secilirse kur cek tarihinin kurundan gelir ve
        //   yerel karsilik (yerelTutar) hesaplanir - portfoy toplami tek para
        //   biriminde okunabilsin diye.
        Doviz: new DovizKurali("dovizCinsi", "dovizKuru", "tutar", "yerelTutar", "tarih"),
        Alanlar: new KartAlani[]
        {
            new("id",            "id",              "sayi",  Yazilabilir: false),
            // TUR kimlik seridinde DEGIL (kullanici karari): kagidin cek mi senet mi
            //   oldugu zaten hangi listeden gelindigiyle belli - seride kimin
            //   kagidi oldugu (CARI) daha degerli. Alan yine var, "Genel"de.
            new("tarafId",       "taraf_id",        "kod",   KodTablosu: "public.v_cari_lookup", Baslik: "Cari", Grup: "Kimlik"),
            new("yon",           "yon",             "kod",   Zorunlu: true, SabitKodlar: CekSenetYonKodlari, Baslik: "Yön", Grup: "Kimlik"),
            new("seriNo",        "seri_no",         "metin", EnFazlaUzunluk: 30, Baslik: "Seri No", Grup: "Kimlik"),
            new("durum",         "durum",           "kod",   Yazilabilir: false, SabitKodlar: CekSenetDurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // Tür ARKA PLANDA: hangi listeden gelindiyse o deger yazilir (Cek/Senet
            //   listesi varsayilani), ekranda hic gorunmez.
            new("tur",           "tur",             "kod",   Zorunlu: true, SabitKodlar: CekSenetTurKodlari, Baslik: "Tür", Gizli: true),
            new("kesideci",      "kesideci",        "metin", EnFazlaUzunluk: 150, Baslik: "Keşideci", Grup: "Genel", AltGrup: "Taraf"),
            new("ciroTarafId",   "ciro_taraf_id",   "kod",   Yazilabilir: false, KodTablosu: "public.v_cari_lookup", Baslik: "Ciro Edilen", Grup: "Genel", AltGrup: "Taraf"),
            new("tarih",         "tarih",           "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("vade",          "vade",            "tarih", Zorunlu: true, Baslik: "Vade", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("tutar",         "tutar",           "para",  Zorunlu: true, Baslik: "Tutar", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("dovizCinsi",    "doviz_cinsi",     "kod",   SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("dovizKuru",     "doviz_kuru",      "para",  Baslik: "Kur", Grup: "Genel", AltGrup: "Tutar / Vade"),
            // Yerel karsilik SUNUCUDA hesaplanir (tutar x kur) - kullanici
            //   yazamaz; yoksa kurla tutarsiz bir yerel tutar kaydedilebilirdi.
            new("yerelTutar",    "yerel_tutar",     "para",  Yazilabilir: false, Baslik: "Yerel Tutar", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("bankaId",       "banka_id",        "kod",   KodTablosu: "public.v_banka_lookup", Baslik: "Banka", Grup: "Genel", AltGrup: "Banka"),
            new("bankaSubeId",   "banka_sube_id",   "kod",   KodTablosu: "public.v_banka_sube_lookup", BagliAlan: "bankaId", Baslik: "Şube", Grup: "Genel", AltGrup: "Banka"),
            new("hesapNo",       "hesap_no",        "metin", EnFazlaUzunluk: 30, Baslik: "Hesap No", Grup: "Genel", AltGrup: "Banka"),
            new("hesapId",       "hesap_id",        "kod",   Yazilabilir: false, KodTablosu: "public.v_hesap_lookup", Baslik: "Bulunduğu Hesap", Grup: "Genel", AltGrup: "Banka"),
            new("projeId",       "proje_id",        "kod",   KodTablosu: "public.v_proje_lookup", Baslik: "Proje", Grup: "Genel", AltGrup: "Diğer"),
            new("makbuzNo",      "makbuz_no",       "metin", EnFazlaUzunluk: 30, Baslik: "Makbuz No", Grup: "Genel", AltGrup: "Diğer"),
            new("aciklama",      "aciklama",        "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Diğer"),
            new("subeId",        "sube_id",         "sayi",  Yazilabilir: false, Baslik: "Şube"),
            new("eklemeTarihi",  "ekleme_tarihi",   "tarih", Yazilabilir: false)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.mali_hareket", "cek_senet_id", "Bu cek/senedin hareketi var, silinemez.")
        });

    // --------------------------------------------------------------- proje ----
    private static KartTanimi Proje() => new(
        Ad: "proje",
        YetkiKodu: "proje",
        Tablo: "public.proje",
        LogTabloId: 913,
        SubeKolonu: null,                     // ana veri - subeler arasi ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["butceDovizi"] = "TL" },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("kod",         "kod",          "metin", EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik"),
            new("ad",          "ad",           "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Proje Adı", Grup: "Kimlik"),
            new("durum",       "durum",        "kod",   SabitKodlar: ProjeDurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            new("ustId",       "ust_id",       "kod",   KodTablosu: "public.v_proje_lookup", Baslik: "Üst Proje", Grup: "Genel", AltGrup: "Tanımlama"),
            new("tarafId",     "taraf_id",     "kod",   KodTablosu: "public.v_cari_lookup", Baslik: "Müşteri", Grup: "Genel", AltGrup: "Tanımlama"),
            new("sorumluId",   "sorumlu_id",   "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Tanımlama"),
            new("baslangic",   "baslangic",    "tarih", Baslik: "Başlangıç", Grup: "Genel", AltGrup: "Süre"),
            new("bitis",       "bitis",        "tarih", Baslik: "Bitiş", Grup: "Genel", AltGrup: "Süre"),
            new("butceTutar",  "butce_tutar",  "para",  Baslik: "Bütçe", Grup: "Genel", AltGrup: "Bütçe"),
            new("butceDovizi", "butce_dovizi", "metin", EnFazlaUzunluk: 6, Baslik: "Bütçe Dövizi", Grup: "Genel", AltGrup: "Bütçe"),
            new("aciklama",    "aciklama",     "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Bütçe"),
            new("eklemeTarihi","ekleme_tarihi","tarih", Yazilabilir: false)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.kasa_islem",   "proje_id", "Bu projeye ait kasa islemi var, silinemez."),
            new SilmeEngeli("public.mali_hareket", "proje_id", "Bu projeye ait hareket var, silinemez."),
            new SilmeEngeli("public.belge",        "proje_id", "Bu projeye ait belge var, silinemez.")
        });

    // ------------------------------------------------------ masraf merkezi ----

    /// <summary>
    /// Gorev / hatirlatma / takvim karti (108). Mockup: gorev_karti.html -
    /// Konu, Tur, Kategori, Oncelik, Durum, Ilerleme, Sorumlu, Baslangic,
    /// Termin, Hatirlatma, Ilgili Cari / Proje.
    /// </summary>
    private static KartTanimi Gorev() => new(
        Ad: "gorev",
        YetkiKodu: "gorev",
        Tablo: "public.gorev",
        LogTabloId: 918,                      // yeni tablo - eski karsiligi yok
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["tur"] = (short)1, ["durum"] = (short)0, ["oncelik"] = (short)2 },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",         "sayi",  Yazilabilir: false),
            new("gorevNo",    "gorev_no",   "metin", EnFazlaUzunluk: 20, Baslik: "Görev No",
                                            Yazilabilir: false, Grup: "Kimlik"),
            new("konu",       "konu",       "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                                            Baslik: "Konu", Grup: "Kimlik"),
            new("oncelik",    "oncelik",    "kod",   SabitKodlar: GorevOncelikKodlari,
                                            Baslik: "Öncelik", Grup: "Kimlik"),
            new("durum",      "durum",      "kod",   SabitKodlar: GorevDurumKodlari,
                                            Baslik: "Durum", Grup: "Kimlik"),

            new("tur",        "tur",        "kod",   SabitKodlar: GorevTurKodlari,
                                            Baslik: "Tür", Grup: "Genel", AltGrup: "Görev Bilgileri"),
            new("kategori",   "kategori",   "kod",   SabitKodlar: GorevKategoriKodlari,
                                            Baslik: "Kategori", Grup: "Genel", AltGrup: "Görev Bilgileri"),
            new("sorumluId",  "sorumlu_id", "kod",   KodTablosu: "public.v_personel_lookup",
                                            Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Görev Bilgileri"),
            new("ilerleme",   "ilerleme",   "sayi",  Baslik: "İlerleme %",
                                            Grup: "Genel", AltGrup: "Görev Bilgileri"),

            new("baslangic",  "baslangic",  "tarih", Baslik: "Başlangıç",
                                            Grup: "Genel", AltGrup: "Zaman"),
            new("termin",     "termin",     "tarih", Baslik: "Termin",
                                            Grup: "Genel", AltGrup: "Zaman"),
            new("hatirlatma", "hatirlatma", "tarih", Baslik: "Hatırlatma",
                                            Grup: "Genel", AltGrup: "Zaman"),
            new("tumGun",     "tum_gun",    "mantik", Baslik: "Tüm Gün",
                                            Grup: "Genel", AltGrup: "Zaman"),

            new("tarafId",    "taraf_id",   "kod",   KodTablosu: "public.v_cari_lookup",
                                            Baslik: "İlgili Cari", Grup: "Genel", AltGrup: "İlgili Kayıt"),
            new("projeId",    "proje_id",   "kod",   KodTablosu: "public.v_proje_lookup",
                                            Baslik: "İlgili Proje", Grup: "Genel", AltGrup: "İlgili Kayıt"),
            new("aciklama",   "aciklama",   "metin", EnFazlaUzunluk: 4000, Baslik: "Açıklama",
                                            Grup: "Genel", AltGrup: "İlgili Kayıt"),

            new("tamamlanma", "tamamlanma", "tarih", Yazilabilir: false),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false)
        });


    // --------------------------------------------------------------- banka ----
    /// <summary>
    /// Banka tanimi ve SUBELERI (109). Subeler ayri bir ekran degil, bankanin
    /// detay tablosu: sube tek basina anlamsizdir, hep bir bankaya aittir.
    /// </summary>

    // --------------------------------------------------------------- firsat ----
    // CRM satis firsati karti (121, mockup firsat_karti.html). Kimlik seridi
    //   mockup'takiyle ayni: Fırsat No · Konu · Aşama · Durum.
    //
    // FIRSAT NO kullanici bos birakirsa DB tetigi uretir (FRS.<yil>-<id>) -
    //   sayac tablosuna gerek yok, numara id'den turedigi icin mukerrer olmaz.
    // AGIRLIKLI TUTAR kartta YOK: listede hesaplanan bir kolon, kartta ikinci
    //   kez gostermek "girilebilir" izlenimi verirdi.
    private static KartTanimi Firsat() => new(
        Ad: "firsat",
        YetkiKodu: "firsat",
        Tablo: "public.firsat",
        LogTabloId: 918,
        SubeKolonu: "sube_id",
        KapsamKolonu: "taraf_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["asama"] = (short)1, ["oncelik"] = (short)2,
              ["dovizCinsi"] = "TL", ["dovizKuru"] = 1m, ["olasilik"] = (short)10 },
        // Yeni firsatta ilk is MUSTERIYI/ADAYI secmektir (cek-senet deseni).
        AcilistaTarafSecimi: "tarafId",
        Doviz: new DovizKurali("dovizCinsi", "dovizKuru", "tahminiTutar", "", "beklenenKapanis"),
        Alanlar: new KartAlani[]
        {
            new("id",               "id",                "sayi",  Yazilabilir: false),
            new("firsatNo",         "firsat_no",         "metin", EnFazlaUzunluk: 30, Baslik: "Fırsat No", Grup: "Kimlik"),
            new("konu",             "konu",              "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Konu", Grup: "Kimlik"),
            new("asama",            "asama",             "kod",   Zorunlu: true, KodListesi: "firsat.asama", Baslik: "Aşama", Grup: "Kimlik"),
            new("durum",            "durum",             "kod",   Zorunlu: true, KodListesi: "firsat.durum", Baslik: "Durum", Grup: "Kimlik"),

            new("tarafId",          "taraf_id",          "kod",   Zorunlu: true, KodTablosu: "public.v_cari_lookup", Baslik: "Müşteri / Aday", Grup: "Genel", AltGrup: "Fırsat"),
            new("kaynak",           "kaynak",            "kod",   KodListesi: "firsat.kaynak", Baslik: "Kaynak", Grup: "Genel", AltGrup: "Fırsat"),
            new("tur",              "tur",               "kod",   KodListesi: "firsat.tur", Baslik: "Tür", Grup: "Genel", AltGrup: "Fırsat"),
            new("oncelik",          "oncelik",           "kod",   KodListesi: "firsat.oncelik", Baslik: "Öncelik", Grup: "Genel", AltGrup: "Fırsat"),
            new("sorumluId",        "sorumlu_id",        "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Fırsat"),

            new("tahminiTutar",     "tahmini_tutar",     "para",  Baslik: "Tahmini Tutar", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("dovizCinsi",       "doviz_cinsi",       "kod",   SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("dovizKuru",        "doviz_kuru",        "para",  Baslik: "Kur", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("olasilik",         "olasilik",          "sayi",  Baslik: "Olasılık %", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("beklenenKapanis",  "beklenen_kapanis",  "tarih", Baslik: "Beklenen Kapanış", Grup: "Genel", AltGrup: "Tutar / Tahmin"),

            new("sonTemas",         "son_temas",         "tarih", Baslik: "Son Temas", Grup: "Genel", AltGrup: "Takip"),
            new("sonrakiAksiyon",   "sonraki_aksiyon",   "metin", EnFazlaUzunluk: 200, Baslik: "Sonraki Aksiyon", Grup: "Genel", AltGrup: "Takip"),
            new("kapanisTarihi",    "kapanis_tarihi",    "tarih", Baslik: "Kapanış Tarihi", Grup: "Genel", AltGrup: "Takip"),
            new("kayipNedeni",      "kayip_nedeni",      "metin", EnFazlaUzunluk: 200, Baslik: "Kayıp Nedeni", Grup: "Genel", AltGrup: "Takip"),
            new("aciklama",         "aciklama",          "metin", Baslik: "Açıklama", Grup: "Genel", AltGrup: "Notlar"),

            new("subeId",           "sube_id",           "sayi",  Yazilabilir: false, Baslik: "Şube"),
            new("eklemeTarihi",     "ekleme_tarihi",     "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // "Ürünler": talep edilen kalemler - TAHMIN, belge degil (stok/cari
            //   etkilemez). Firsat kazanilinca teklif/siparise donusturulur.
            new DetayTanimi("urunler", "public.firsat_urun", "firsat_id", new KartAlani[]
            {
                new("id",          "id",          "sayi",  Yazilabilir: false),
                new("sira",        "sira",        "sayi",  Baslik: "Sıra"),
                new("stokId",      "stok_id",     "kod",   KodTablosu: "public.v_stok_lookup", Baslik: "Stok"),
                new("aciklama",    "aciklama",    "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
                new("miktar",      "miktar",      "para",  Baslik: "Miktar"),
                new("birimFiyat",  "birim_fiyat", "para",  Baslik: "Birim Fiyat"),
                new("tutar",       "tutar",       "para",  Baslik: "Tutar")
            }, Sirala: "sira, id", SubeKolonu: null, LogTabloId: 919, Baslik: "Ürünler"),

            // "Aktiviteler": firsata bagli gorusme/toplanti/hatirlatma. Ayri
            //   tablo YOK - gorev (108) tablosundaki firsat_id ile baglanir.
            new DetayTanimi("aktiviteler", "public.gorev", "firsat_id", new KartAlani[]
            {
                new("id",         "id",         "sayi",  Yazilabilir: false),
                new("tur",        "tur",        "kod",   KodListesi: "gorev.tur", Baslik: "Tür"),
                new("konu",       "konu",       "metin", EnFazlaUzunluk: 200, Baslik: "Konu"),
                new("sorumluId",  "sorumlu_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu"),
                new("baslangic",  "baslangic",  "tarih", Baslik: "Başlangıç"),
                new("termin",     "termin",     "tarih", Baslik: "Termin"),
                new("durum",      "durum",      "kod",   KodListesi: "gorev.durum", Baslik: "Durum")
            }, Sirala: "coalesce(baslangic, ekleme_tarihi) desc, id desc", LogTabloId: 108, Baslik: "Aktiviteler")
        },
        SilmeEngelleri: Array.Empty<SilmeEngeli>());

    // ------------------------------------------------------------ cek/senet ----
    // durum Yazilabilir:false - portfoy durumu ELLE degil, yalnizca aksiyonlarla
    //   (tahsil / ciro / bozdur / iade) degisir; her degisim cek_senet_hareket'e
    //   iz birakir. Elle degistirilebilse defter ile durum tutarsizlasirdi.

    // ------------------------------------------------------ masraf merkezi ----
    private static KartTanimi MasrafMerkezi() => new(
        Ad: "masraf-merkezi",
        YetkiKodu: "masraf_merkezi",
        Tablo: "public.masraf_merkezi",
        LogTabloId: 915,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",    "id",     "sayi",  Yazilabilir: false),
            new("kod",   "kod",    "metin", EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik"),
            new("ad",    "ad",     "metin", Zorunlu: true, EnFazlaUzunluk: 100, Baslik: "Ad", Grup: "Kimlik"),
            new("ustId", "ust_id", "kod",   KodTablosu: "public.v_masraf_merkezi_lookup", Baslik: "Üst Merkez", Grup: "Kimlik"),
            new("durum", "durum",  "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.mali_hareket", "merkez_id", "Bu merkeze ait hareket var, silinemez.")
        });

    // ----------------------------------------------------------------- depo ----
    // Stok Ayarlari ekraninin "Depolar" sekmesi. Varsayilan depo TEKTIR
    //   (ux_depo_varsayilan); ikinci bir depo varsayilan yapilinca eskisini
    //   trg_depo_varsayilan_tek (db/090) birakir - kart ozel kod tasimaz.

    // ---------------------------------------------------------- hesap plani ----
    private static KartTanimi HesapPlani() => new(
        Ad: "hesap-plani",
        YetkiKodu: "hesap_plani",
        Tablo: "public.hesap_plani",
        LogTabloId: 914,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["dovizCinsi"] = "TL", ["calisirMi"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",             "sayi",  Yazilabilir: false),
            new("kod",          "kod",            "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Hesap Kodu", Grup: "Kimlik"),
            new("ad",           "ad",             "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Hesap Adı", Grup: "Kimlik"),
            new("sinif",        "sinif",          "kod",   SabitKodlar: HesapSinifKodlari, Baslik: "Sınıf", Grup: "Kimlik"),
            new("durum",        "durum",          "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            new("ustId",        "ust_id",         "kod",   KodTablosu: "public.v_hesap_plani_lookup", Baslik: "Üst Hesap", Grup: "Genel"),
            new("seviye",       "seviye",         "sayi",  Baslik: "Seviye", Grup: "Genel"),
            // calisir_mi: yalniz YAPRAK hesaplar fis satiri alabilir (ara hesaba kayit yasak)
            new("calisirMi",    "calisir_mi",     "mantik", Baslik: "Fiş satırı alabilir", Grup: "Genel"),
            new("cariAltHesap", "cari_alt_hesap", "mantik", Baslik: "Cari alt hesabı açılsın", Grup: "Genel"),
            new("dovizCinsi",   "doviz_cinsi",    "kod",   SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Genel")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.muhasebe_fis_satir", "hesap_plani_id", "Bu hesaba fis satiri yazilmis, silinemez.")
        });

    // --------------------------------------------------------------- firsat ----
    // CRM satis firsati karti (121, mockup firsat_karti.html). Kimlik seridi
    //   mockup'takiyle ayni: Fırsat No · Konu · Aşama · Durum.
    //
    // FIRSAT NO kullanici bos birakirsa DB tetigi uretir (FRS.<yil>-<id>) -
    //   sayac tablosuna gerek yok, numara id'den turedigi icin mukerrer olmaz.
    // AGIRLIKLI TUTAR kartta YOK: listede hesaplanan bir kolon, kartta ikinci
    //   kez gostermek "girilebilir" izlenimi verirdi.
}
