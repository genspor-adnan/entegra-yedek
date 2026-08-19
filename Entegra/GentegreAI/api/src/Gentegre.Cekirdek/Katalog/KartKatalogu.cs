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
            new("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani (bos ise Unvan kullanilir)", Grup: "Kimlik"),
            new("ad",          "ad",           "metin", EnFazlaUzunluk: 50,  Baslik: "Ad",              Grup: "Kimlik"),
            new("soyad",       "soyad",        "metin", EnFazlaUzunluk: 60,  Baslik: "Soyad",           Grup: "Kimlik"),
            new("musteri",     "musteri",      "mantik", Baslik: "Musteri",   Grup: "Roller"),
            new("tedarikci",   "tedarikci",    "mantik", Baslik: "Tedarikci", Grup: "Roller"),
            new("kisi",        "kisi",         "mantik", Baslik: "Kisi",      Grup: "Roller"),
            new("vkno",        "vkno",         "metin", EnFazlaUzunluk: 20,  Baslik: "VKN / TCKN",     Grup: "Mali"),
            new("vd",          "vd",           "metin", EnFazlaUzunluk: 60,  Baslik: "Vergi Dairesi",  Grup: "Mali"),
            new("telefon",     "telefon",      "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon",        Grup: "Iletisim"),
            new("cepTel",      "cep_tel",      "metin", EnFazlaUzunluk: 30,  Baslik: "Cep Telefonu",   Grup: "Iletisim"),
            new("eposta",      "eposta",       "metin", EnFazlaUzunluk: 120, Baslik: "E-posta",        Grup: "Iletisim"),
            new("epostaWeb",   "eposta_web",   "metin", EnFazlaUzunluk: 200, Baslik: "Web / 2. E-posta", Grup: "Iletisim"),
            new("efatura",     "efatura",      "mantik", Baslik: "e-Fatura mukellefi", Grup: "Mali"),
            new("grup",        "grup",         "kod",   Baslik: "Grup",      Grup: "Siniflandirma"),
            new("kategori",    "kategori",     "kod",   Baslik: "Kategori",  Grup: "Siniflandirma"),
            new("statu",       "statu",        "kod",   Baslik: "Statu",     Grup: "Siniflandirma"),
            new("temsilci",    "temsilci",     "kod",   Baslik: "Temsilci",  Grup: "Siniflandirma"),
            new("notlar",      "notlar",       "metin", EnFazlaUzunluk: 1000, Baslik: "Notlar",        Grup: "Diger"),
            new("ozelKod",     "ozel_kod",     "metin", EnFazlaUzunluk: 20,  Baslik: "Ozel Kod",       Grup: "Diger"),
            new("durum",       "durum",        "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum",    Grup: "Diger"),
            new("subeId",      "sube_id",      "sayi",  Yazilabilir: false),
            new("eklemeTarihi","ekleme_tarihi","tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod"),
                new("baslik",     "baslik",      "metin", EnFazlaUzunluk: 60),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("yetkili",    "yetkili",     "metin", EnFazlaUzunluk: 60),
                new("telefon",    "telefon",     "metin", EnFazlaUzunluk: 30),
                new("eposta",     "eposta",      "metin", EnFazlaUzunluk: 120),
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
