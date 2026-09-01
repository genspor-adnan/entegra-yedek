namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// RADYOLOJİ İSTEM KARTI (283).
///
/// İstem hem klinik hem operasyonel kayıttır: üstte kimlik (hasta, tetkik,
/// öncelik, durum), sonra istem bilgisi (isteyen hekim, ön tanı, klinik bilgi),
/// sonra çekim (cihaz, tekniker, kontrast, doz) ve PACS eşleşmesi.
///
/// ÜCRET BURADA YOK: fiyat ve ödeyen kurum belgede durur (274 zinciri). Kart
/// yalnız `belgeId`/`belgeSatirId` bağını taşır - iki yerde fiyat tutmak, biri
/// güncellenip öteki unutulduğunda hangisinin doğru olduğu sorusunu doğurur.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi RadyolojiIstem() => new(
        Ad: "radyoloji-istem",
        YetkiKodu: "radyoloji",
        Tablo: "public.radyoloji_istem",
        LogTabloId: 940,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,        // Bekliyor
            ["oncelik"] = (short)1,      // Normal
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            // Hasta ve tetkik binlerce kayıt: combo değil ARAMA EKRANI (260).
            new("hastaId",   "hasta_id",   "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Kimlik"),
            // Tetkik listesi YALNIZ radyoloji hizmetleri (286): başka hizmete
            //   açılan istem worklist'e klinik karşılığı olmayan satır düşürür.
            new("hizmetId",  "hizmet_id",  "kod", Zorunlu: true,
                KodTablosu: "public.v_rad_tetkik_lookup",
                Baslik: "Tetkik", Grup: "Kimlik"),
            new("oncelik",   "oncelik",    "kod", KodListesi: "rad.oncelik",
                Baslik: "Öncelik", Grup: "Kimlik"),
            // Accession istem oluşurken üretilir (fn_radyoloji_accession) ve
            //   PACS eşleşmesinin anahtarıdır - elle değiştirilemez.
            new("accessionNo", "accession_no", "metin", Yazilabilir: false,
                EnFazlaUzunluk: 24, Baslik: "Accession No", Grup: "Kimlik"),
            new("durum",     "durum",      "kod", KodListesi: "rad.istem_durum",
                Baslik: "Durum", Grup: "Kimlik"),

            // ----------------------------------------------- istem bilgisi ---
            new("istekHekimId", "istek_hekim_id", "kod",
                KodTablosu: "public.v_rad_hekim_lookup",
                Baslik: "İsteyen Hekim", Grup: "İstem Bilgisi"),
            // Dış hastada hekim kayıtlı olmayabilir; kimlik SGK/sigorta
            //   faturasında istendiği için ad yine de yazılır.
            new("disHekimAd", "dis_hekim_ad", "metin", EnFazlaUzunluk: 120,
                Baslik: "Dış Hekim (kayıtsız)", Grup: "İstem Bilgisi"),
            // KABUL SONRASI (311): kabul masasinin istekleri - MWL/SMS
            //   entegrasyonu gelene kadar niyet kaydi, sonradan da
            //   isaretlenebilir (or. hasta CD istedi).
            new("mwlIstendi",      "mwl_istendi",      "mantik",
                Baslik: "Cihaz listesine (MWL) gönder", Grup: "Çekim"),
            new("smsIstendi",      "sms_istendi",      "mantik",
                Baslik: "Randevu SMS'i", Grup: "Çekim"),
            new("hazirlikVerildi", "hazirlik_verildi", "mantik",
                Baslik: "Hazırlık talimatı verildi", Grup: "Çekim"),
            new("cdIstendi",       "cd_istendi",       "mantik",
                Baslik: "Sonuç CD'si hazırlanacak", Grup: "Çekim"),
            new("istekKurumId", "istek_kurum_id", "kod",
                KodTablosu: "public.v_cari_lookup",
                Baslik: "İsteyen Kurum", Grup: "İstem Bilgisi"),
            new("onTani",    "on_tani",    "metin", EnFazlaUzunluk: 20,
                Baslik: "Ön Tanı (ICD-10)", Grup: "İstem Bilgisi"),
            // Rapordaki "Klinik Bilgi" bölümü buradan doldurulur; boş istem
            //   radyologa "neden çekildi" sorusunu bırakır.
            new("klinikBilgi", "klinik_bilgi", "metin", EnFazlaUzunluk: 600,
                Baslik: "Klinik Bilgi", Grup: "İstem Bilgisi"),
            new("modalite",  "modalite",   "kod", KodListesi: "rad.modalite",
                Baslik: "Modalite", Grup: "İstem Bilgisi"),

            // ------------------------------------------------------ çekim ----
            new("cihazId",   "cihaz_id",   "kod", KodTablosu: "public.v_rad_cihaz_lookup",
                Baslik: "Cihaz", Grup: "Çekim"),
            new("teknikerId", "tekniker_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Tekniker", Grup: "Çekim"),
            new("cekimTarihi", "cekim_tarihi", "zaman", Baslik: "Çekim Zamanı", Grup: "Çekim"),
            new("kontrast",  "kontrast",   "kod", KodListesi: "rad.kontrast",
                Baslik: "Kontrast", Grup: "Çekim"),
            new("kontrastMl", "kontrast_ml", "para", Baslik: "Kontrast (ml)", Grup: "Çekim"),
            // Doz BT/skopide hasta dozimetrisi için takip edilir.
            new("dlp",       "dlp",        "para", Baslik: "DLP (mGy·cm)", Grup: "Çekim"),
            new("ctdi",      "ctdi",       "para", Baslik: "CTDIvol (mGy)", Grup: "Çekim"),
            // Kritik bulgu: işaretliyse bildirim kaydı olmadan rapor
            //   onaylanamaz (284, fn_radyoloji_rapor_onaylanabilir).
            new("kritik",    "kritik",     "mantik", Baslik: "Kritik Bulgu", Grup: "Çekim"),

            // ------------------------------------------------------- PACS ----
            new("studyUid",  "study_uid",  "metin", EnFazlaUzunluk: 64,
                Baslik: "Study UID", Grup: "PACS"),
            new("seriSayisi", "seri_sayisi", "sayi", Baslik: "Seri Sayısı", Grup: "PACS"),
            new("goruntuSayisi", "goruntu_sayisi", "sayi", Baslik: "Görüntü Sayısı", Grup: "PACS"),

            new("aciklama",  "aciklama",   "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "PACS"),

            // ------------------------------------------------- gizli bağlar --
            // Ücret bağı ve randevu: ekranda gösterilmez, kayıtta korunur.
            new("belgeId",      "belge_id",       "kod", Gizli: true),
            new("belgeSatirId", "belge_satir_id", "kod", Gizli: true),
            new("randevuId",    "randevu_id",     "kod", Gizli: true),
            new("subeId",       "sube_id",        "kod", Gizli: true),
        });

    /// <summary>
    /// RAPOR SABLONU (283/284). Sablon TETKIKE baglanir: rapor ekrani acilinca
    /// o tetkikin varsayilani kendiliginden yuklenir. Uc detay:
    ///   BOLUMLER - raporun iskeleti (sira + zorunlu + yazdir bayragi),
    ///   MAKROLAR - hekimin sik yazdigi ifadeler (kisayolla eklenir),
    ///   SKOR ALANLARI - BI-RADS/TI-RADS gibi yapilandirilmis degerler.
    /// SURUM: sablon degisince gecmis raporlar degismemeli - rapor kendi
    /// surumunu saklar, bu yuzden sablonu duzenleyen surumu artirmali.
    /// </summary>
    /// <summary>
    /// CİHAZ KARTI (283/315). Üç öbek: kimlik, DICOM/yerleşim, randevu ayarları.
    /// Randevu alan adları randevu_bolum_ayar ile AYNI - slot üretimi ortak.
    /// Kapatma/bakım satırları detay gridinde: takvimde "kapalı" olarak çizilir.
    /// </summary>
    private static KartTanimi RadyolojiCihaz() => new(
        Ad: "radyoloji-cihaz",
        YetkiKodu: "radyoloji",
        Tablo: "public.radyoloji_cihaz",
        LogTabloId: 944,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1, ["randevu_verilir"] = (short)1,
            ["slot_dk"] = 15, ["varsayilan_sure"] = 15, ["eszaman"] = 1,
            ["baslangic_saat"] = "08:00", ["bitis_saat"] = "18:00",
            ["calisma_gunleri"] = "1,2,3,4,5",
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod",      "kod",      "metin", EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Cihaz Adı", Grup: "Kimlik"),
            new("modalite", "modalite", "kod", Zorunlu: true, KodListesi: "rad.modalite",
                Baslik: "Modalite", Grup: "Kimlik"),
            new("durum",    "durum",    "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // AE Title DICOM kimligi: MWL dogru cihaza ancak bununla iner.
            new("aeTitle",  "ae_title", "metin", EnFazlaUzunluk: 32,
                Baslik: "AE Title", Grup: "Yerleşim / DICOM"),
            new("oda",      "oda",      "metin", EnFazlaUzunluk: 60,
                Baslik: "Oda / Kat", Grup: "Yerleşim / DICOM"),
            new("sorumluId", "sorumlu_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Cihaz Sorumlusu", Grup: "Yerleşim / DICOM"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Yerleşim / DICOM"),
            // RANDEVU: kapaliysa cihaz "walk-in" calisir, takvimde sutunu cikmaz.
            new("randevuVerilir", "randevu_verilir", "mantik",
                Baslik: "Randevu Verilir", Grup: "Randevu"),
            new("baslangicSaat", "baslangic_saat", "metin", EnFazlaUzunluk: 5,
                Baslik: "Mesai Başlangıç", Grup: "Randevu"),
            new("bitisSaat",     "bitis_saat",     "metin", EnFazlaUzunluk: 5,
                Baslik: "Mesai Bitiş", Grup: "Randevu"),
            new("ogleBaslangic", "ogle_baslangic", "metin", EnFazlaUzunluk: 5,
                Baslik: "Öğle Başlangıç", Grup: "Randevu"),
            new("ogleBitis",     "ogle_bitis",     "metin", EnFazlaUzunluk: 5,
                Baslik: "Öğle Bitiş", Grup: "Randevu"),
            new("slotDk",        "slot_dk",        "sayi", Baslik: "Slot (dk)", Grup: "Randevu"),
            // Randevu SURESI oncelikle cekim protokolunden (314) gelir; bu alan
            //   protokolu olmayan tetkikler icin yedektir.
            new("varsayilanSure", "varsayilan_sure", "sayi",
                Baslik: "Varsayılan Süre (dk)", Grup: "Randevu"),
            new("eszaman",   "eszaman",   "sayi", Baslik: "Aynı Anda (hasta)", Grup: "Randevu"),
            new("acilSlot",  "acil_slot", "sayi", Baslik: "Acil için Ayrılan Slot", Grup: "Randevu"),
            new("calismaGunleri", "calisma_gunleri", "metin", EnFazlaUzunluk: 20,
                Baslik: "Çalışma Günleri", Grup: "Randevu"),
            new("subeId",    "sube_id",   "kod", Gizli: true),
        },
        Detaylar: new DetayTanimi[]
        {
            // BAKIM / ARIZA / TATIL: takvimde "kapalı" cizilir, randevu verilemez.
            new("kapatmalar", "public.radyoloji_cihaz_kapatma", "cihaz_id", new KartAlani[]
            {
                new("id",        "id",        "sayi", Yazilabilir: false),
                new("baslangic", "baslangic", "tarih", Zorunlu: true, Baslik: "Başlangıç"),
                new("bitis",     "bitis",     "tarih", Zorunlu: true, Baslik: "Bitiş"),
                new("nedenTur",  "neden_tur", "kod", KodListesi: "rad.kapatma", Baslik: "Neden"),
                new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
            }, SubeKolonu: null, Baslik: "Kapatma / Bakım", LogTabloId: 944),
        });

    /// <summary>
    /// ÇEKİM PROTOKOLÜ KARTI (314). Bir tetkikin TEK protokolü olur
    /// (ux_radyoloji_protokol_hizmet) - kart tetkiği seçtirir, tekrar seçilirse
    /// benzersizlik kısıtı iş kuralı mesajıyla uyarır.
    /// </summary>
    private static KartTanimi RadyolojiProtokol() => new(
        Ad: "radyoloji-protokol",
        YetkiKodu: "radyoloji",
        Tablo: "public.radyoloji_protokol",
        LogTabloId: 943,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["sure_dk"] = 15, ["kontrast"] = (short)0,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // Tetkik binlerce hizmet arasindan JENERIK ARAMA ile secilir.
            new("hizmetId", "hizmet_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_rad_tetkik_lookup", AramaKaynagi: "hizmet",
                Baslik: "Tetkik", Grup: "Kimlik"),
            // Bos birakilirsa hizmetin kendi modalitesi gecerlidir.
            new("modalite", "modalite", "kod", KodListesi: "rad.modalite",
                Baslik: "Modalite", Grup: "Kimlik"),
            new("sureDk",   "sure_dk",  "sayi", Baslik: "Çekim Süresi (dk)", Grup: "Kimlik"),
            new("kontrast", "kontrast", "kod", KodListesi: "rad.kontrast",
                Baslik: "Varsayılan Kontrast", Grup: "Kimlik"),
            new("seriTarifi", "seri_tarifi", "metin", EnFazlaUzunluk: 400,
                Baslik: "Seri / Pozisyon Tarifi", Grup: "Çekim"),
            // HASTAYA verilen metin: kabul ekraninda "Hazırlık talimatı ver"
            //   isaretliyken bu metin gosterilir (311 modalite varsayilanini ezer).
            new("hazirlikMetni", "hazirlik_metni", "metin", EnFazlaUzunluk: 600,
                Baslik: "Hazırlık Talimatı", Grup: "Çekim"),
            // PERSONELE uyari: gebelik, metal, kreatinin gibi cekim oncesi kontrol.
            new("ozelUyari", "ozel_uyari", "metin", EnFazlaUzunluk: 400,
                Baslik: "Özel Uyarı", Grup: "Çekim"),
        },
        Detaylar: new DetayTanimi[]
        {
            // SARF LISTESI (320): tetkikin stok karsiligi. Cekim tamamlaninca
            //   dusum penceresi bu satirlari ONERIR - miktar VARSAYILANDIR,
            //   gercek kullanimi teknisyen onaylar.
            new DetayTanimi("malzeme", "public.radyoloji_protokol_malzeme", "protokol_id",
                new KartAlani[]
                {
                    // ID SART: yoksa kayitli satir "yeni" sanilip cogalir.
                    new("id", "id", "sayi", Yazilabilir: false),
                    new("stokId", "stok_id", "kod", Zorunlu: true,
                        KodTablosu: "public.v_stok_lookup", AramaKaynagi: "stok",
                        Baslik: "Stok / Malzeme"),
                    new("miktar", "miktar", "sayi", Baslik: "Miktar"),
                    new("dusumTipi", "dusum_tipi", "kod", KodListesi: "rad.dusum_tipi",
                        Baslik: "Düşüm"),
                    // Hesap YAPILMAZ: teknisyene gosterilen not ("1,5 mL/kg").
                    new("kural", "kural", "metin", EnFazlaUzunluk: 200,
                        Baslik: "Kural / Not"),
                    new("sira", "sira", "sayi", Baslik: "Sıra"),
                },
                SubeKolonu: null, Baslik: "Malzeme / Sarf", LogTabloId: 943),
        });

    private static KartTanimi RadyolojiSablon() => new(
        Ad: "radyoloji-sablon",
        YetkiKodu: "radyoloji",
        Tablo: "public.radyoloji_sablon",
        LogTabloId: 942,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1, ["surum"] = 1, ["varsayilan"] = (short)0,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod",       "kod",       "metin", EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",        "ad",        "metin", Zorunlu: true, EnFazlaUzunluk: 150,
                Baslik: "Sablon Adi", Grup: "Kimlik"),
            new("modalite",  "modalite",  "kod", KodListesi: "rad.modalite",
                Baslik: "Modalite", Grup: "Kimlik"),
            // Bos birakilirsa sablon o modalitenin GENEL sablonu olur; tetkike
            //   bagliysa rapor ekraninda ilk sirada gelir.
            new("hizmetId",  "hizmet_id", "kod", KodTablosu: "public.v_rad_tetkik_lookup",
                Baslik: "Bagli Tetkik", Grup: "Kimlik"),
            new("varsayilan", "varsayilan", "mantik", Baslik: "Varsayilan", Grup: "Kimlik"),
            new("durum",     "durum",     "mantik", Baslik: "Aktif", Grup: "Kimlik"),
            new("bolum",     "bolum",     "metin", EnFazlaUzunluk: 60,
                Baslik: "Bolum", Grup: "Genel"),
            new("surum",     "surum",     "sayi",  Baslik: "Surum", Grup: "Genel"),
            new("kullanim",  "kullanim",  "sayi",  Yazilabilir: false,
                Baslik: "Kullanim", Grup: "Genel"),
            new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 300,
                Baslik: "Aciklama", Grup: "Genel"),
            new("subeId",    "sube_id",   "kod", Gizli: true),
        },
        Detaylar: new DetayTanimi[]
        {
            new("bolumler", "public.radyoloji_sablon_bolum", "sablon_id", new KartAlani[]
            {
                new("id",   "id",   "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sira"),
                new("baslik", "baslik", "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                    Baslik: "Baslik"),
                new("varsayilanMetin", "varsayilan_metin", "metin", Baslik: "Varsayilan Metin"),
                new("zorunlu", "zorunlu", "mantik", Baslik: "Zorunlu"),
                // Kapaliysa bolum ekranda gorunur ama hasta ciktisina basilmaz.
                new("yazdir",  "yazdir",  "mantik", Baslik: "Yazdir"),
            }, SubeKolonu: null, Baslik: "Bolumler", LogTabloId: 942),

            new("makrolar", "public.radyoloji_sablon_makro", "sablon_id", new KartAlani[]
            {
                new("id",      "id",      "sayi", Yazilabilir: false),
                new("kisayol", "kisayol", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                    Baslik: "Kisayol"),
                new("ad",      "ad",      "metin", EnFazlaUzunluk: 80, Baslik: "Ad"),
                new("metin",   "metin",   "metin", Baslik: "Metin"),
                new("hedefBolum", "hedef_bolum", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Hedef Bolum"),
            }, SubeKolonu: null, Baslik: "Makrolar", LogTabloId: 942),

            new("skorlar", "public.radyoloji_sablon_alan", "sablon_id", new KartAlani[]
            {
                new("id",       "id",       "sayi", Yazilabilir: false),
                new("sira",     "sira",     "sayi", Baslik: "Sira"),
                new("alanKod",  "alan_kod", "metin", Zorunlu: true, EnFazlaUzunluk: 40,
                    Baslik: "Alan Kodu"),
                new("alanAd",   "alan_ad",  "metin", Zorunlu: true, EnFazlaUzunluk: 80,
                    Baslik: "Alan Adi"),
                // Secenekler "|" ile ayrilir: serbest metin birakilirsa
                //   "BIRADS 4" ile "Bi-Rads IV" iki ayri deger olur.
                new("secenekler", "secenekler", "metin", EnFazlaUzunluk: 400,
                    Baslik: "Secenekler (| ile)"),
                new("zorunlu",  "zorunlu",  "mantik", Baslik: "Zorunlu"),
                new("raporaBas", "rapora_bas", "mantik", Baslik: "Rapora Bas"),
            }, SubeKolonu: null, Baslik: "Skor Alanlari", LogTabloId: 942),
        });
}
