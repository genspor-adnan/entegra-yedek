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
        // Liste ile AYNI yetki (796): kart serbest kalirsa liste suzmesi
        //   anlamsizlasir.
        YetkiKodu: "radyoloji-istem",
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
            // KONTRAST AYRINTISI (811): Bakanlik OBX-17 `yol^etkin madde^
            //   konsantrasyon` istiyor ve TICARI ISMI YASAKLIYOR. ml MIKTARDIR,
            //   konsantrasyon ayri sayidir (300 mg/ml'den 80 ml verilebilir).
            new("kontrastYol", "kontrast_yol", "kod",
                KodTablosu: "public.v_rad_kontrast_yol_lookup",
                Baslik: "Kontrast Yolu", Grup: "Çekim"),
            new("kontrastMadde", "kontrast_madde", "metin", EnFazlaUzunluk: 80,
                Baslik: "Etkin Madde", Grup: "Çekim"),
            new("kontrastKonsantrasyon", "kontrast_konsantrasyon", "para",
                Baslik: "Konsantrasyon (mg/ml)", Grup: "Çekim"),
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
    /// CİHAZ KARTI (283/315 · sekmeli 967, mockup Ekranlar/Radyoloji/radyoloji_cihaz_karti_v2.html).
    /// Kimlik şeridi: kod, ad, modalite, oda, sorumlu, durum rozeti. Sekmeler:
    /// Genel (tanım + DICOM) · Randevu ayarları · Protokoller · Kapatma / bakım ·
    /// Kalite kontrol; Doz / Kullanım / Belgeler ekranın ek sekmeleri.
    /// Randevu alan adları randevu_bolum_ayar ile AYNI - slot üretimi ortak.
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
            ["calisma_gunleri"] = "1,2,3,4,5", ["mwl"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // ---- KİMLİK ŞERİDİ ----
            new("kod",      "kod",      "metin", EnFazlaUzunluk: 20, Baslik: "Kod", Grup: "Kimlik"),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Cihaz adı", Grup: "Kimlik"),
            new("modalite", "modalite", "kod", Zorunlu: true, KodListesi: "rad.modalite", Baslik: "Modalite", Grup: "Kimlik"),
            new("oda",      "oda",      "metin", EnFazlaUzunluk: 60, Baslik: "Oda / kat", Grup: "Kimlik"),
            new("sorumluId", "sorumlu_id", "kod", KodTablosu: "public.v_personel_lookup", Baslik: "Cihaz sorumlusu", Grup: "Kimlik"),
            new("durum",    "durum",    "kod", SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // ---- GENEL ----
            new("marka",   "marka",   "metin", EnFazlaUzunluk: 60, Baslik: "Marka", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("model",   "model",   "metin", EnFazlaUzunluk: 80, Baslik: "Model", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("seriNo",  "seri_no", "metin", EnFazlaUzunluk: 60, Baslik: "Seri no", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("uretimYili", "uretim_yili", "sayi", Baslik: "Üretim yılı", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("kurulumTarihi", "kurulum_tarihi", "tarih", Baslik: "Kurulum tarihi", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("garantiBitis", "garanti_bitis", "tarih", Baslik: "Garanti bitiş", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("servisFirma", "servis_firma", "metin", EnFazlaUzunluk: 150, Baslik: "Servis firması / sözleşme", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("servisBitis", "servis_bitis", "tarih", Baslik: "Servis sözleşmesi bitiş", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("utsNo",   "uts_no",   "metin", EnFazlaUzunluk: 30, Baslik: "ÜTS ürün numarası", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("demirbasNo", "demirbas_no", "metin", EnFazlaUzunluk: 30, Baslik: "Demirbaş no", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Cihaz tanımı"),
            // AE Title DICOM kimligi: MWL dogru cihaza ancak bununla iner.
            new("aeTitle",  "ae_title", "metin", EnFazlaUzunluk: 32, Baslik: "AE Title", Grup: "Genel", AltGrup: "DICOM / bağlantı"),
            new("ip",       "ip",       "metin", EnFazlaUzunluk: 60, Baslik: "IP", Grup: "Genel", AltGrup: "DICOM / bağlantı"),
            new("port",     "port",     "sayi",  Baslik: "Port", Grup: "Genel", AltGrup: "DICOM / bağlantı"),
            new("mwl",      "mwl",      "mantik", Baslik: "MWL (iş listesi)", Grup: "Genel", AltGrup: "DICOM / bağlantı"),
            new("mpps",     "mpps",     "mantik", Baslik: "MPPS (çekim bildirimi)", Grup: "Genel", AltGrup: "DICOM / bağlantı"),
            new("pacsHedef", "pacs_hedef", "metin", EnFazlaUzunluk: 100, Baslik: "PACS hedefi", Grup: "Genel", AltGrup: "DICOM / bağlantı"),
            // ---- RANDEVU ----
            // RANDEVU: kapaliysa cihaz "walk-in" calisir, takvimde sutunu cikmaz.
            new("randevuVerilir", "randevu_verilir", "mantik", Baslik: "Randevu verilir", Grup: "Randevu ayarları"),
            new("onlineRandevu", "online_randevu", "mantik", Baslik: "Online randevu", Grup: "Randevu ayarları"),
            new("baslangicSaat", "baslangic_saat", "metin", EnFazlaUzunluk: 5, Baslik: "Mesai başlangıç", Grup: "Randevu ayarları"),
            new("bitisSaat",     "bitis_saat",     "metin", EnFazlaUzunluk: 5, Baslik: "Mesai bitiş", Grup: "Randevu ayarları"),
            new("ogleBaslangic", "ogle_baslangic", "metin", EnFazlaUzunluk: 5, Baslik: "Öğle başlangıç", Grup: "Randevu ayarları"),
            new("ogleBitis",     "ogle_bitis",     "metin", EnFazlaUzunluk: 5, Baslik: "Öğle bitiş", Grup: "Randevu ayarları"),
            new("slotDk",        "slot_dk",        "sayi", Baslik: "Slot (dk)", Grup: "Randevu ayarları"),
            // Randevu SURESI oncelikle cekim protokolunden (314) gelir; bu alan
            //   protokolu olmayan tetkikler icin yedektir.
            new("varsayilanSure", "varsayilan_sure", "sayi", Baslik: "Varsayılan süre (dk)", Grup: "Randevu ayarları"),
            new("eszaman",   "eszaman",   "sayi", Baslik: "Aynı anda (hasta)", Grup: "Randevu ayarları"),
            new("acilSlot",  "acil_slot", "sayi", Baslik: "Acil için ayrılan slot", Grup: "Randevu ayarları"),
            new("calismaGunleri", "calisma_gunleri", "metin", EnFazlaUzunluk: 20, Baslik: "Çalışma günleri (1=Pzt … 7=Paz)", Grup: "Randevu ayarları"),
            new("subeId",    "sube_id",   "kod", Gizli: true),
        },
        Detaylar: new DetayTanimi[]
        {
            // BU CİHAZDA ÇEKİLEN PROTOKOLLER: protokol kartının "Cihazlar" sekmesiyle aynı tablo.
            new("protokoller", "public.radyoloji_protokol_cihaz", "cihaz_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("protokolId", "protokol_id", "kod", Zorunlu: true, KodTablosu: "public.v_rad_protokol_lookup", Baslik: "Protokol (tetkik)"),
                // MOCKUP 5 KOLON (kullanıcı): kontrast ve genel süre protokolden, salt okunur.
                new("kontrastAdi",
                    "(select case p.kontrast when 1 then 'İV' when 2 then 'Oral' when 3 then 'İV + Oral' when 4 then 'Rektal' else 'Yok' end " +
                    "   from public.radyoloji_protokol p where p.id = radyoloji_protokol_cihaz.protokol_id)",
                    "metin", Yazilabilir: false, Baslik: "Kontrast"),
                new("genelSure",
                    "(select p.sure_dk from public.radyoloji_protokol p where p.id = radyoloji_protokol_cihaz.protokol_id)",
                    "sayi", Yazilabilir: false, Baslik: "Süre (genel, dk)"),
                new("sureDk", "sure_dk", "sayi", Baslik: "Süre (bu cihazda, dk)"),
                new("cihazProtokolAdi", "cihaz_protokol_adi", "metin", EnFazlaUzunluk: 80, Baslik: "Cihaz protokol adı (MWL)"),
            }, SubeKolonu: null, Baslik: "Protokoller", LogTabloId: 1379),
            // BAKIM / ARIZA / TATIL: takvimde "kapalı" cizilir, randevu verilemez.
            new("kapatmalar", "public.radyoloji_cihaz_kapatma", "cihaz_id", new KartAlani[]
            {
                new("id",        "id",        "sayi", Yazilabilir: false),
                new("baslangic", "baslangic", "tarih", Zorunlu: true, Baslik: "Başlangıç"),
                new("bitis",     "bitis",     "tarih", Zorunlu: true, Baslik: "Bitiş"),
                new("nedenTur",  "neden_tur", "kod", KodListesi: "rad.kapatma", Baslik: "Neden"),
                new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
                // MOCKUP 6 KOLON (kullanıcı): etkilenen randevu + durum, salt okunur.
                new("etkilenen",
                    "(select count(*) from public.randevu r where r.cihaz_id = radyoloji_cihaz_kapatma.cihaz_id and r.durum <> 4 " +
                    "   and r.baslangic >= radyoloji_cihaz_kapatma.baslangic and r.baslangic < radyoloji_cihaz_kapatma.bitis)",
                    "sayi", Yazilabilir: false, Baslik: "Etkilenen randevu"),
                new("durumAdi",
                    "case when now() < radyoloji_cihaz_kapatma.baslangic then 'Planlandı' " +
                    "     when now() < radyoloji_cihaz_kapatma.bitis then 'Sürüyor' else 'Kapandı' end",
                    "metin", Yazilabilir: false, Baslik: "Durum"),
            }, Sirala: "baslangic desc", SubeKolonu: null, Baslik: "Kapatma / bakım", LogTabloId: 1282),
            // KALİTE KONTROL / LİSANS: periyot + son yapılış; sonraki = son + periyot.
            new("qa", "public.radyoloji_cihaz_qa", "cihaz_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "#"),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 100, Baslik: "Test / belge"),
                new("periyotGun", "periyot_gun", "sayi", Baslik: "Periyot (gün)"),
                new("sonTarih", "son_tarih", "tarih", Baslik: "Son yapılış"),
                new("sonuc", "sonuc", "kod", KodListesi: "rad.qa_sonuc", Baslik: "Sonuç"),
                new("notu", "notu", "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, Sirala: "sira, id", SubeKolonu: null, Baslik: "Kalite kontrol", LogTabloId: 1380),
        });

    /// <summary>
    /// ÇEKİM PROTOKOLÜ KARTI (314 · sekmeli 965, mockup Ekranlar/Radyoloji/radyoloji_protokol_karti.html).
    /// Bir tetkikin TEK protokolü olur (ux_radyoloji_protokol_hizmet). Sekmeler:
    /// Genel · Seriler · Kontrast · Hasta hazırlığı · Uyarılar / kontrol ·
    /// Malzeme / sarf · Cihazlar. Kimlik şeridi: tetkik, modalite, süre,
    /// kontrast, seri kodu, durum.
    /// </summary>
    private static KartTanimi RadyolojiProtokol() => new(
        Ad: "radyoloji-protokol",
        YetkiKodu: "radyoloji",
        Tablo: "public.radyoloji_protokol",
        LogTabloId: 1280,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["sure_dk"] = 15, ["kontrast"] = (short)0, ["durum"] = (short)1, ["sms_ekle"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // ---- KİMLİK ŞERİDİ ----
            new("hizmetId", "hizmet_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_rad_tetkik_lookup", AramaKaynagi: "hizmet",
                Baslik: "Tetkik (hizmet)", Grup: "Kimlik"),
            // Bos birakilirsa hizmetin kendi modalitesi gecerlidir.
            new("modalite", "modalite", "kod", KodListesi: "rad.modalite", Baslik: "Modalite", Grup: "Kimlik"),
            new("sureDk",   "sure_dk",  "sayi", Zorunlu: true, Baslik: "Süre (dk)", Grup: "Kimlik"),
            new("kontrast", "kontrast", "kod", KodListesi: "rad.kontrast", Baslik: "Kontrast", Grup: "Kimlik"),
            // SERİ TİPİ kod listesinden (515): seri / pozisyon notu tetikle bundan dolar.
            new("seriKodu", "seri_kodu", "kod", KodListesi: "rad.seri", Baslik: "Seri tipi", Grup: "Kimlik"),
            // Ekranda Aktif / Pasif ROZETİ (kartAlanCizim DURUM_ROZETLI).
            new("durum",    "durum",    "mantik", Baslik: "Durum", Grup: "Kimlik"),
            // ---- GENEL ----
            new("bolge", "bolge", "kod", KodListesi: "rad.bolge", Baslik: "Bölge", Grup: "Genel", AltGrup: "Protokol"),
            new("hazirlikOnceDk", "hazirlik_once_dk", "sayi", Baslik: "Hasta önce gelsin (dk)", Grup: "Genel", AltGrup: "Protokol"),
            new("sablonId", "sablon_id", "kod", KodTablosu: "public.v_rad_sablon_lookup",
                Baslik: "Varsayılan rapor şablonu", Grup: "Genel", AltGrup: "Protokol"),
            new("yetkinlik", "yetkinlik", "metin", EnFazlaUzunluk: 150, Baslik: "Teknisyen yetkinliği", Grup: "Genel", AltGrup: "Protokol"),
            new("endikasyon", "endikasyon", "metin", EnFazlaUzunluk: 600, Baslik: "Endikasyon notu", Grup: "Genel", AltGrup: "Protokol"),
            new("seriTarifi", "seri_tarifi", "metin", EnFazlaUzunluk: 400, Baslik: "Seri / pozisyon notu", Grup: "Genel", AltGrup: "Protokol"),
            new("ctdiHedef", "ctdi_hedef", "ondalik", Baslik: "Hedef CTDIvol (mGy)", Grup: "Genel", AltGrup: "Doz (radyasyon)"),
            new("dlpHedef",  "dlp_hedef",  "ondalik", Baslik: "Hedef DLP (mGy·cm)", Grup: "Genel", AltGrup: "Doz (radyasyon)"),
            new("drl",       "drl",        "ondalik", Baslik: "Ulusal referans (DRL)", Grup: "Genel", AltGrup: "Doz (radyasyon)"),
            new("cocukNotu", "cocuk_notu", "metin", EnFazlaUzunluk: 200, Baslik: "Çocuk", Grup: "Genel", AltGrup: "Doz (radyasyon)"),
            // ---- KONTRAST ----
            new("kontrastAjan", "kontrast_ajan", "metin", EnFazlaUzunluk: 100, Baslik: "IV ajan", Grup: "Kontrast"),
            new("kontrastDoz",  "kontrast_doz",  "metin", EnFazlaUzunluk: 60, Baslik: "Doz (ör. 1,5 ml/kg)", Grup: "Kontrast"),
            new("kontrastEnCok", "kontrast_en_cok", "ondalik", Baslik: "En çok (ml)", Grup: "Kontrast"),
            new("kontrastHiz",  "kontrast_hiz",  "metin", EnFazlaUzunluk: 40, Baslik: "Hız", Grup: "Kontrast"),
            new("kontrastTakip", "kontrast_takip", "metin", EnFazlaUzunluk: 60, Baslik: "Serum fizyolojik takip", Grup: "Kontrast"),
            new("damarYolu",    "damar_yolu",    "metin", EnFazlaUzunluk: 100, Baslik: "Damar yolu", Grup: "Kontrast"),
            new("oralTarif",    "oral_tarif",    "metin", EnFazlaUzunluk: 300, Baslik: "Oral kontrast tarifi", Grup: "Kontrast"),
            new("kontrendikasyon", "kontrendikasyon", "metin", EnFazlaUzunluk: 400, Baslik: "Kontrendikasyon", Grup: "Kontrast"),
            // ---- HASTA HAZIRLIĞI ----
            // HASTAYA verilen metin: randevu SMS'i ve hazırlık kartı bundan (311 modalite varsayılanını ezer).
            new("hazirlikKodu",  "hazirlik_kodu",  "kod", KodListesi: "rad.hazirlik", Baslik: "Hazır talimat", Grup: "Hasta hazırlığı"),
            new("smsEkle",       "sms_ekle",       "mantik", Baslik: "Randevu SMS'ine ekle", Grup: "Hasta hazırlığı"),
            new("hatirlat",      "hatirlat",       "mantik", Baslik: "1 gün önce hatırlat", Grup: "Hasta hazırlığı"),
            new("hazirlikMetni", "hazirlik_metni", "metin", EnFazlaUzunluk: 600, Baslik: "Hastaya metin", Grup: "Hasta hazırlığı"),
            new("personelNotu",  "personel_notu",  "metin", EnFazlaUzunluk: 600, Baslik: "Personele not", Grup: "Hasta hazırlığı"),
            // ---- UYARILAR ----
            new("uyariKodu", "uyari_kodu", "kod", KodListesi: "rad.uyari", Baslik: "Hazır uyarı", Grup: "Uyarılar / kontrol"),
            new("ozelUyari", "ozel_uyari", "metin", EnFazlaUzunluk: 400, Baslik: "Özel uyarı (teknisyen ekranında üstte)", Grup: "Uyarılar / kontrol"),
        },
        Detaylar: new DetayTanimi[]
        {
            new DetayTanimi("seriler", "public.radyoloji_protokol_seri", "protokol_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "#"),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Seri"),
                new("faz", "faz", "metin", EnFazlaUzunluk: 80, Baslik: "Faz / gecikme"),
                new("kesit", "kesit", "metin", EnFazlaUzunluk: 40, Baslik: "Kesit / aralık"),
                new("kvMas", "kv_mas", "metin", EnFazlaUzunluk: 40, Baslik: "kV / mAs"),
                new("rekon", "rekon", "metin", EnFazlaUzunluk: 120, Baslik: "Rekonstrüksiyon"),
                new("notu", "notu", "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, Sirala: "sira, id", SubeKolonu: null, Baslik: "Seriler", LogTabloId: 1375),
            new DetayTanimi("kontroller", "public.radyoloji_protokol_kontrol", "protokol_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "#"),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Kontrol"),
                new("kural", "kural", "metin", EnFazlaUzunluk: 200, Baslik: "Kural"),
                new("kaynak", "kaynak", "kod", KodListesi: "rad.kontrol_kaynak", Baslik: "Kaynak"),
                new("engel", "engel", "mantik", Baslik: "Engel (değilse uyarı)"),
            }, Sirala: "sira, id", SubeKolonu: null, Baslik: "Çekim öncesi kontrol", LogTabloId: 1376),
            // SARF LISTESI (320): tetkikin stok karsiligi. Cekim tamamlaninca
            //   dusum penceresi bu satirlari ONERIR - miktar VARSAYILANDIR.
            new DetayTanimi("malzeme", "public.radyoloji_protokol_malzeme", "protokol_id",
                new KartAlani[]
                {
                    new("id", "id", "sayi", Yazilabilir: false),
                    new("stokId", "stok_id", "kod", Zorunlu: true,
                        KodTablosu: "public.v_stok_lookup", AramaKaynagi: "stok", Baslik: "Stok / malzeme"),
                    new("miktar", "miktar", "sayi", Baslik: "Miktar"),
                    new("dusumTipi", "dusum_tipi", "kod", KodListesi: "rad.dusum_tipi", Baslik: "Düşüm"),
                    // Hesap YAPILMAZ: teknisyene gosterilen not ("1,5 mL/kg").
                    new("kural", "kural", "metin", EnFazlaUzunluk: 200, Baslik: "Kural / not"),
                    new("sira", "sira", "sayi", Baslik: "Sıra"),
                },
                SubeKolonu: null, Baslik: "Malzeme / sarf", LogTabloId: 1281),
            new DetayTanimi("cihazlar", "public.radyoloji_protokol_cihaz", "protokol_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("cihazId", "cihaz_id", "kod", Zorunlu: true, KodTablosu: "public.v_radyoloji_cihaz_lookup", Baslik: "Cihaz"),
                new("sureDk", "sure_dk", "sayi", Baslik: "Süre (bu cihazda, dk)"),
                new("cihazProtokolAdi", "cihaz_protokol_adi", "metin", EnFazlaUzunluk: 80, Baslik: "Cihaz protokol adı (MWL)"),
            }, SubeKolonu: null, Baslik: "Cihazlar", LogTabloId: 1377),
        });

    /// <summary>
    /// RAPOR ŞABLONU KARTI (283 · sekmeli 965, mockup Ekranlar/Radyoloji/radyoloji_sablon_karti_v2.html).
    /// Sekmeler: Genel (+ ek bağlı hizmetler) · Bölümler · Yapılandırılmış
    /// alanlar · Makrolar; Önizleme / Sürümler / Kullanım ekranın ek sekmeleri.
    /// </summary>
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
            // ---- KİMLİK ŞERİDİ ----
            new("kod",      "kod",      "metin", EnFazlaUzunluk: 20, Baslik: "Kod", Grup: "Kimlik"),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Şablon adı", Grup: "Kimlik"),
            new("modalite", "modalite", "kod", Zorunlu: true, KodListesi: "rad.modalite", Baslik: "Modalite", Grup: "Kimlik"),
            new("bolge",    "bolge",    "kod", KodListesi: "rad.bolge", Baslik: "Bölge", Grup: "Kimlik"),
            // SÜRÜM elle yazılmaz: "Yeni sürüm" düğmesi içeriği saklayıp artırır.
            // AD "surum" DEĞİL: kart yanıtındaki "surum" eşzamanlılık damgasıdır (xmin) ve onu ezerdi.
            new("sablonSurum", "surum", "sayi", Yazilabilir: false, Baslik: "Sürüm", Grup: "Kimlik"),
            new("durum",    "durum",    "mantik", Baslik: "Durum", Grup: "Kimlik"),
            // ---- GENEL ----
            // Bos birakilirsa sablon o modalitenin GENEL sablonu olur; tetkike
            //   bagliysa rapor ekraninda ilk sirada gelir. Ek tetkikler "Bağlı hizmetler" tablosunda.
            new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_rad_tetkik_lookup", AramaKaynagi: "hizmet",
                Baslik: "Ana bağlı tetkik", Grup: "Genel", AltGrup: "Kimlik"),
            new("varsayilan", "varsayilan", "mantik", Baslik: "Varsayılan (bağlı tetkiklerde ilk gelen)", Grup: "Genel", AltGrup: "Kimlik"),
            new("sahipId", "sahip_id", "kod", KodTablosu: "public.v_rad_hekim_lookup",
                Baslik: "Sahibi (boş = kurum şablonu)", Grup: "Genel", AltGrup: "Kimlik"),
            new("raporBasligi", "rapor_basligi", "metin", EnFazlaUzunluk: 150, Baslik: "Rapor başlığı (yazdırmada)", Grup: "Genel", AltGrup: "Kimlik"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Kimlik"),
            new("kullanim", "kullanim", "sayi", Yazilabilir: false, Baslik: "Kullanım", Grup: "Genel", AltGrup: "Kimlik"),
            new("istemBilgi", "istem_bilgi", "mantik", Baslik: "Klinik bilgi istemden dolsun", Grup: "Genel", AltGrup: "Davranış"),
            new("karsilastirma", "karsilastirma", "mantik", Baslik: "Önceki aynı bölge tetkiki karşılaştırmaya önerilsin", Grup: "Genel", AltGrup: "Davranış"),
            new("kritikSor", "kritik_sor", "mantik", Baslik: "Sonuçta kritik ifade geçerse kritik bulgu bildirimi sor", Grup: "Genel", AltGrup: "Davranış"),
            new("eimzaZorunlu", "eimza_zorunlu", "mantik", Baslik: "Onayda e-imza zorunlu", Grup: "Genel", AltGrup: "Davranış"),
            new("subeId",   "sube_id",  "kod", Gizli: true),
        },
        Detaylar: new DetayTanimi[]
        {
            new("hizmetler", "public.radyoloji_sablon_hizmet", "sablon_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("hizmetId", "hizmet_id", "kod", Zorunlu: true, KodTablosu: "public.v_rad_tetkik_lookup",
                    AramaKaynagi: "hizmet", Baslik: "Ek bağlı tetkik"),
            }, SubeKolonu: null, Baslik: "Bağlı hizmetler", LogTabloId: 1378),

            new("bolumler", "public.radyoloji_sablon_bolum", "sablon_id", new KartAlani[]
            {
                new("id",   "id",   "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "#"),
                new("baslik", "baslik", "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Başlık"),
                // Yer tutucular: {istem.on_tani} {istem.sikayet} {hasta.yas} {hasta.cinsiyet}
                new("varsayilanMetin", "varsayilan_metin", "metin", Baslik: "Varsayılan metin"),
                new("zorunlu", "zorunlu", "mantik", Baslik: "Zorunlu"),
                // Kapaliysa bolum ekranda gorunur ama hasta ciktisina basilmaz.
                new("yazdir",  "yazdir",  "mantik", Baslik: "Yazdır"),
                new("bakanlikParca", "bakanlik_parca", "kod", KodListesi: "rad.bakanlik_parca", Baslik: "Bakanlık rapor parçası"),
            }, Sirala: "sira, id", SubeKolonu: null, Baslik: "Bölümler", LogTabloId: 1278),

            new("skorlar", "public.radyoloji_sablon_alan", "sablon_id", new KartAlani[]
            {
                new("id",       "id",       "sayi", Yazilabilir: false),
                new("sira",     "sira",     "sayi", Baslik: "#"),
                new("alanKod",  "alan_kod", "metin", Zorunlu: true, EnFazlaUzunluk: 40, Baslik: "Kod"),
                new("alanAd",   "alan_ad",  "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Alan"),
                new("tip",      "tip",      "kod", KodListesi: "rad.alan_tip", Baslik: "Tip"),
                // Secenekler "|" ile ayrilir: serbest metin birakilirsa
                //   "BIRADS 4" ile "Bi-Rads IV" iki ayri deger olur.
                new("secenekler", "secenekler", "metin", EnFazlaUzunluk: 400, Baslik: "Seçenekler (| ile)"),
                new("birim",    "birim",    "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                new("altSinir", "alt_sinir", "ondalik", Baslik: "Alt"),
                new("ustSinir", "ust_sinir", "ondalik", Baslik: "Üst"),
                new("hedefBolum", "hedef_bolum", "metin", EnFazlaUzunluk: 60, Baslik: "Bölüm"),
                new("kalip",    "kalip",    "metin", EnFazlaUzunluk: 300, Baslik: "Metne yazılış ({değer})"),
                new("sifirKalip", "sifir_kalip", "metin", EnFazlaUzunluk: 300, Baslik: "0 / yok ise"),
                new("zorunlu",  "zorunlu",  "mantik", Baslik: "Zorunlu"),
                new("raporaBas", "rapora_bas", "mantik", Baslik: "Rapora bas"),
            }, Sirala: "sira, id", SubeKolonu: null, Baslik: "Yapılandırılmış alanlar", LogTabloId: 1277),

            new("makrolar", "public.radyoloji_sablon_makro", "sablon_id", new KartAlani[]
            {
                new("id",      "id",      "sayi", Yazilabilir: false),
                new("kisayol", "kisayol", "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kısayol"),
                new("ad",      "ad",      "metin", EnFazlaUzunluk: 80, Baslik: "Ad"),
                new("metin",   "metin",   "metin", Baslik: "Metin"),
                new("hedefBolum", "hedef_bolum", "metin", EnFazlaUzunluk: 60, Baslik: "Hedef bölüm"),
            }, SubeKolonu: null, Baslik: "Makrolar", LogTabloId: 1279),
        });
}
