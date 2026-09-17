namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KATEGORİ, DEPARTMAN ve PERSONEL GÖREVİ kartları — kurumun yapı taşları.
///
/// KartKatalogu.Cari.cs dosyasindan ayrildi: tek dosyada 1140 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KartKatalogu
{
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
            //
            // e-NABIZ (455/619): bu kod AYNI ZAMANDA USS paketlerindeki
            //   KLINIK kodudur ve SKRS "KLİNİKLER" listesinden gelir.
            //   AYRI KOLON YOK (kullanici): bir kod iki yerde tutulmaz.
            //
            //   619'a kadar buradaki degerler yanlis listeden - SKRS
            //   PERSONEL BRANS - geliyordu ve her e-Nabiz paketi yanlis
            //   klinigi bildiriyordu ("Acil" bolumunun kodu 102,
            //   KLINIKLER'de 102 = ADLI TIP). Goc kodlari duzeltti;
            //   karsiligi bulunamayan 52 bolumun kodu BOSALDI ve buradan
            //   secilmeyi bekliyor.
            //
            //   Alan LOOKUP: serbest metinken SKRS'de olmayan bir sayi
            //   yazmak mumkundu ve o sayi pakete yanlis klinik olarak
            //   giderdi. Liste v_skrs_klinik_lookup (615).
            new("kod",                "kod",                 "kod",
                KodTablosu: "public.v_skrs_klinik_lookup",
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad",                 "ad",                  "metin", Zorunlu: true,
                EnFazlaUzunluk: 100, Baslik: "Bölüm", Grup: "Kimlik"),
            // Ust birim (257): secilirse departman digerinin ALTINA gecer.
            //   Bos = kok departman. Dongu (kendi altina alma) DB tetiginde.
            new("ustbirimId",         "ustbirim_id",         "kod",
                KodTablosu: "public.v_departman_lookup", Baslik: "Üst Birim", Grup: "Kimlik"),
            // "randevuVerilebilir" KALKTI (711): bolum randevu bolumu mu = planli hekimi
            //   var mi; randevusuz kabul (acil/lab) ayri bayrak.
            new("randevusuzKabul", "randevusuz_kabul", "mantik",
                Baslik: "Randevusuz Kabul (acil / lab)", Grup: "Kimlik"),
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
        LogTabloId: 1266,
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["departmanId"] = 0,
        },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            // SKRS BRANS KODU (559/560) - kod eslemesi yerine kodun kendisi.
            //   Bos birakilabilir: kuruma ozel gorevin SKRS karsiligi olmayabilir.
            new("kod",         "kod",          "metin", EnFazlaUzunluk: 20,
                Baslik: "SKRS Kodu", Grup: "Kimlik"),
            new("ad",          "ad",           "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                Baslik: "Görev", Grup: "Kimlik"),
            // UST GOREV (570): agac dugumu. `departmanId` ile KARISTIRILMAMALI -
            //   o "gorev hangi bolumde gecerli" sorusudur, bu ise listedeki yeri.
            new("ustId",       "ust_id",       "kod",   KodTablosu: "public.v_gorev_agac_lookup",
                Agac: true, Baslik: "Üst Görev", Grup: "Kimlik"),
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
}
