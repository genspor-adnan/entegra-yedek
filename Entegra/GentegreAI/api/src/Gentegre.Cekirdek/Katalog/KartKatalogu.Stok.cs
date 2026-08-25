namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Stok ve depo kartlari (fiyat / barkod / ÜTS / paket detaylari dahil).
/// </summary>
public static partial class KartKatalogu
{
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
            new("tipi",          "tipi",            "kod",   Zorunlu: true, KodListesi: "stok.tipi", Baslik: "Tur", Grup: "Kimlik"),
            // mockup "Genel" sekmesi 3 alt-bolume ayrilir: Tanım / Sınıflandırma · Vergi & Ana Birim · Resim
            //   (Resim - IMAJ→DOSYA - hic acilmadi, alan yok). Ayri Mali/Diger SEKMESI YOK -
            //   mockup'ta da yok, KDV/OTV/Min Stok buraya katlandi (eskiden ayri sekmelerdi).
            new("kategori",      "kategori",        "kod",   Zorunlu: true, KodTablosu: "public.kategori", Baslik: "Kategori", AltGrup: "Tanım / Sınıflandırma"),
            new("marka",         "marka",           "kod",   KodListesi: "stok.marka",     Baslik: "Marka",     AltGrup: "Tanım / Sınıflandırma"),
            new("model",         "model",           "metin", EnFazlaUzunluk: 60, AltGrup: "Tanım / Sınıflandırma"),
            new("grup",          "grubu",           "kod",   KodListesi: "stok.grubu",     Baslik: "Grup",      AltGrup: "Tanım / Sınıflandırma"),
            new("izleme",        "izleme",          "kod",   KodListesi: "stok.izleme", Baslik: "Izleme",       AltGrup: "Tanım / Sınıflandırma"),
            new("bildirim",      "bildirim",        "kod",   SabitKodlar: BildirimKodlari, Baslik: "Bildirim",  AltGrup: "Tanım / Sınıflandırma"),
            new("urunNo",        "urun_no",         "metin", EnFazlaUzunluk: 60, Baslik: "Urun No",             AltGrup: "Vergi & Ana Birim"),
            new("gtipKodu",      "gtip_kodu",       "metin", EnFazlaUzunluk: 30, Baslik: "GTIP Kodu",           AltGrup: "Vergi & Ana Birim"),
            new("anaBirim",      "ana_birim",       "kod",   KodListesi: "stok.ana_birim",  Baslik: "Ana Birim",AltGrup: "Vergi & Ana Birim"),
            new("kdv",           "kdv",             "kod",   Zorunlu: true, SabitKodlar: KdvKodlari, Baslik: "KDV %", AltGrup: "Vergi & Ana Birim"),
            new("otvYuzde",      "otv_yuzde",       "para", Baslik: "OTV %",  AltGrup: "Vergi & Ana Birim"),
            // FATURADAKI AD vergi bolumunun EN ALTINDA (kullanici): belgeye
            //   basilacak ad vergi/birim bilgileriyle birlikte okunuyor.
            new("faturaStokAdi", "fatura_stok_adi", "metin", EnFazlaUzunluk: 200,
                                                     Baslik: "Faturadaki Ad", AltGrup: "Vergi & Ana Birim"),
            // SATILIR / ALINIR (141) "Diğer" bolumunun EN USTUNDE (kullanici):
            //   stogun hangi belge yonunde ARANABILECEGINI belirler - kendi
            //   urettigimiz mamul alis siparisinde, satin alinan ambalaj satis
            //   faturasinda listelenmesin. Ikisi de varsayilan ISARETLI.
            new("satilan",       "satilan",         "mantik", Baslik: "Satılan", AltGrup: "Diğer",
                                                     EslesAlan: "alinan"),
            new("alinan",        "alinan",          "mantik", Baslik: "Alınan", AltGrup: "Diğer"),
            // Kiralik/demirbas gibi geri donup TEKRAR cikabilen kiymet; normal
            //   ticari mal tuketilir, o yuzden varsayilan isaretsiz.
            new("yenidenKullanilir", "yeniden_kullanilir", "mantik",
                                                     Baslik: "Yeniden Kullanılabilir", AltGrup: "Diğer"),
            new("internetSatis", "internet_satis",  "mantik", Baslik: "İnternet Satış", AltGrup: "Diğer",
                                                     EslesAlan: "paket"),
            // PAKET (124): isaretlenince kartta "Paket" sekmesi acilir, icerik
            //   orada tanimlanir. Internet Satis'in SAGINDA (ayni satirda).
            new("paket",         "paket",           "mantik", Baslik: "Paket", AltGrup: "Diğer"),
            // Mockup'ta 3. kutu "Resim" - bu alanlarin orada karsiligi yok, ust-satirin
            //   ALTINDA adsiz/duz bolum olarak kalsinlar (kasira'nin 2 kutusunu bozmasin).
            new("rafKonum",      "raf_konum",       "metin", EnFazlaUzunluk: 30, Baslik: "Raf / Konum",         AltGrup: "Diğer"),
            new("rafOmruSure",   "raf_omru_sure",   "sayi",  Baslik: "Raf Ömrü", AltGrup: "Diğer", EslesAlan: "rafOmruBirim"),
            new("rafOmruBirim",  "raf_omru_birim",  "kod",   SabitKodlar: RafOmruBirimKodlari, AltGrup: "Diğer"),
            // MINIMUM STOK karttan KALDIRILDI (kullanici karari): esik DEPO
            //   BAZINDA tutulur (stok_durum.min_stok, Stok Durumu sekmesi) -
            //   ayni urunun ana depodaki ve konsinye depodaki esigi ayni olmaz.
            //   Kolon veri olarak duruyor; eski degerler panel kritik listesinde
            //   depo esigi tanimlanmamis stoklar icin yedek olarak kullanilir.
            new("ozelKod",       "ozel_kod",        "metin", EnFazlaUzunluk: 20, AltGrup: "Diğer"),
            new("durum",         "durum",           "kod",   Zorunlu: true, SabitKodlar: DurumKodlari, Grup: "Kimlik"),
            new("subeId",        "sube_id",         "sayi",  Yazilabilir: false),
            new("eklemeTarihi",  "ekleme_tarihi",   "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // "BIRIM / BARKOD" SEKMESI KALKTI (kullanici, 144): ayni seyi iki
            //   yerde anlatiyordu. Barkod zaten BIRIME aittir - kutunun barkodu
            //   ile adedin barkodu farklidir - dolayisiyla dogru yeri ambalaj
            //   birimi satiridir. Eski kayitlar (1419 barkod) oraya tasindi;
            //   `stok_barkod` tablosu veri olarak duruyor, karttan kalkti.

            // AMBALAJ BIRIMLERI (143): "1 kutu = 12 adet". Bakiye ANA BIRIMDE
            //   tutulur; buradaki carpan yalnizca belgeye giris bicimidir -
            //   kullanici "2 kutu" yazar, stok 24 adet duser.
            new DetayTanimi("birimler", "public.stok_birim", "stok_id", new KartAlani[]
            {
                new("id",              "id",               "sayi", Yazilabilir: false),
                new("birim",           "birim",            "kod", Zorunlu: true,
                    KodListesi: "stok.ana_birim", Baslik: "Birim"),
                // 1 <birim> kac ANA BIRIM eder. Ana birimin kendisi eklenmez -
                //   o zaten kartta secili ve carpani 1'dir.
                new("carpan",          "carpan",           "para", Zorunlu: true,
                    Baslik: "Ana Birim Karşılığı"),
                new("barkod",          "barkod",           "metin", EnFazlaUzunluk: 30),
                new("varsayilanAlis",  "varsayilan_alis",  "mantik", Baslik: "Alışta Varsayılan"),
                new("varsayilanSatis", "varsayilan_satis", "mantik", Baslik: "Satışta Varsayılan"),
                new("durum",           "durum",            "kod", SabitKodlar: DurumKodlari)
            }, Sirala: "carpan, id", SubeKolonu: null, LogTabloId: 347, Baslik: "Ambalaj Birimleri"),

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

            // PAKET ICERIGI (124) - yalniz paket isaretliyse acilir. Kod
            //   secilir, ad otomatik gorunur; birim ve adet elle girilir.
            new DetayTanimi("paket", "public.stok_paket", "paket_stok_id", new KartAlani[]
            {
                new("id",            "id",             "sayi",  Yazilabilir: false),
                // SIRA alani kullaniciya SORULMAZ: pakette satir sirasi anlam
                //   tasimiyor, bos birakilinca da NOT NULL kolonu patlatiyordu.
                //   Gosterim sirasi ekleme sirasidir (id).
                new("icerikStokId",  "icerik_stok_id", "kod",   Zorunlu: true,
                    KodTablosu: "public.v_stok_lookup", Baslik: "Stok"),
                // Kod ve ad SALT OKUNUR: stok kartindan gelir, burada
                //   kopyalanmaz (stok adi degisirse bayatlardi).
                new("kod",           "(select s.kod from public.stok s where s.id = stok_paket.icerik_stok_id)",
                                                       "metin", Yazilabilir: false, Baslik: "Kod"),
                // Ad SALT OKUNUR: kod secilince kendi gelir, iki yerde ad
                //   tutmanin anlami yok (stok adi degisirse burasi bayatlardi).
                new("ad",            "(select s.ad from public.stok s where s.id = stok_paket.icerik_stok_id)",
                                                       "metin", Yazilabilir: false, Baslik: "Ad"),
                new("birim",         "birim",          "kod",   KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("adet",          "adet",           "para",  Zorunlu: true, Baslik: "Adet"),
                // Birim fiyat + doviz (125): paketin bedelinin icerige nasil
                //   dagildigi kart uzerinde okunsun. Belgeye paket eklenirken
                //   KULLANILMAZ (tutar paket satirinda durur).
                new("birimFiyat",    "birim_fiyat",    "para",  Baslik: "Birim Fiyat"),
                new("dovizCinsi",    "doviz_cinsi",    "kod",   SabitKodlar: DovizKodlari, Baslik: "Döviz")
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 920,
               Baslik: "Paket", KosulAlani: "paket"),

            // ÜTS / medikal bilgileri (119) - stok_uts 1:1 uzanti. Tek satirlik
            //   form olarak cizilir (grid degil): bir stokun BIR ÜTS kaydi olur.
            //   Alan sirasi mockup'takiyle (stok_karti.html "ÜTS Bilgileri" =
            //   Delphi UStokWizard.TabSheetUTS) ayni.
            new DetayTanimi("uts", "public.stok_uts", "stok_id", new KartAlani[]
            {
                new("id",            "id",             "sayi",  Yazilabilir: false),
                new("sutKodu",       "sut_kodu",       "metin", EnFazlaUzunluk: 50,  Baslik: "SUT Kodu"),
                new("bransKodu",     "brans_kodu",     "metin", EnFazlaUzunluk: 100, Baslik: "Branş Kodu"),
                new("utsRef",        "uts_ref",        "metin", EnFazlaUzunluk: 100, Baslik: "ÜTS REF (Katalog No)"),
                new("ftn",           "ftn",            "metin", EnFazlaUzunluk: 100, Baslik: "FTN"),
                new("gmdn",          "gmdn",           "metin", EnFazlaUzunluk: 100, Baslik: "GMDN"),
                new("gmdnAdi",       "gmdn_adi",       "metin", EnFazlaUzunluk: 300, Baslik: "GMDN Adı"),
                new("digerUrunAdi",  "diger_urun_adi", "metin", EnFazlaUzunluk: 300, Baslik: "Diğer Ürün Adı"),
                new("medikalSinif",  "medikal_sinif",  "kod",   KodListesi: "stok.medikal_sinif", Baslik: "Sınıf"),
                new("ithalImal",     "ithal_imal",     "kod",   KodListesi: "stok.ithal_imal", Baslik: "İthal / İmal"),
                new("menseiUlke",    "mensei_ulke",    "kod",   KodTablosu: "public.v_ulke_lookup", Baslik: "Menşei Ülke"),
                new("ihaleSiraNo",   "ihale_sira_no",  "metin", EnFazlaUzunluk: 100, Baslik: "İhale Sıra No"),
                new("dmoKodu",       "dmo_kodu",       "metin", EnFazlaUzunluk: 40,  Baslik: "DMO Şartname Kodu"),
                new("smKodu",        "sm_kodu",        "metin", EnFazlaUzunluk: 40,  Baslik: "SM Kodu")
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 903, Baslik: "ÜTS Bilgileri"),

            // "Seri / Lot" AYRI SEKME DEGIL (kullanici karari, 115): lot dokumu
            //   artik Stok Durumu sekmesinde DEPO BAZINDA, master-detail olarak.
            //   Ayri sekme lotlari depodan bagimsiz tek liste halinde gosteriyordu
            //   ve "hangi depoda hangi lottan ne kadar var" sorusunu
            //   cevaplamiyordu. Lotlar belge kaydiyla olusur, elle acilmaz.
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge_satir", "stok_id", "Bu stok belgelerde kullanilmis, silinemez."),
            new SilmeEngeli("public.stok_izleme", "stok_id", "Bu stokun hareket kaydi var, silinemez.")
        });

    // ======================================================== KASA ANA VERI ====

    // hesap.tur - tek tabloda kasa/banka/POS/kredi karti/kredi/kupon (K1, 071).
    //   Harfler mali_hareket.hesap_turu ile AYNI kod uzayindan gelir.

    // ----------------------------------------------------------------- depo ----
    // Stok Ayarlari ekraninin "Depolar" sekmesi. Varsayilan depo TEKTIR
    //   (ux_depo_varsayilan); ikinci bir depo varsayilan yapilinca eskisini
    //   trg_depo_varsayilan_tek (db/090) birakir - kart ozel kod tasimaz.
    private static KartTanimi Depo() => new(
        Ad: "depo",
        YetkiKodu: "stok",
        Tablo: "public.depo",
        LogTabloId: 918,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["maliyetiEtkilesin"] = (short)1, ["varsayilan"] = (short)0,
              ["tip"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            // Alan sirasi = GRID kolon sirasi (kullanici istegi): ekranda gorulen
            //   duzenle karta girince degismesin.
            new("id",                 "id",                 "sayi",  Yazilabilir: false),
            new("ad",                 "ad",                 "metin", Zorunlu: true, EnFazlaUzunluk: 50,
                Baslik: "Depo Adı", Grup: "Genel"),
            new("tip",                "tip",                "kod",   Zorunlu: true, KodListesi: "depo.tip",
                Baslik: "Tipi", Grup: "Genel"),
            new("durum",              "durum",              "kod",   Zorunlu: true, SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Genel"),
            new("maliyetiEtkilesin",  "maliyeti_etkilesin", "mantik", Baslik: "Maliyeti Etkilesin", Grup: "Genel"),
            new("varsayilan",         "varsayilan",         "mantik", Baslik: "Varsayılan Depo", Grup: "Genel")
            // son_sayim_tarihi kartta YOK: sayim modulu henuz olmadigi icin hep bos
            //   duruyordu; kolon tabloda kaliyor, sayim gelince geri eklenir.
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.stok_durum",  "depo_id",        "Bu depoda stok bakiyesi var, silinemez."),
            new SilmeEngeli("public.belge",       "cikis_depo_id",  "Bu depodan cikisli belge var, silinemez."),
            new SilmeEngeli("public.belge",       "giris_depo_id",  "Bu depoya girisli belge var, silinemez."),
            new SilmeEngeli("public.belge_satir", "cikis_depo_id",  "Bu depodan cikisli belge satiri var, silinemez."),
            new SilmeEngeli("public.belge_satir", "giris_depo_id",  "Bu depoya girisli belge satiri var, silinemez.")
        });

    // ---------------------------------------------------------- hesap plani ----
}
