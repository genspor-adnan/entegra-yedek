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
}
