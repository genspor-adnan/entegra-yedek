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
