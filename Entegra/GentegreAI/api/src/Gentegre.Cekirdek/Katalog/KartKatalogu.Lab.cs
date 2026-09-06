namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// LABORATUVAR KARTLARI (433/434) — tetkik kataloğu, panel, cihaz eşlemesi.
///
/// <para><b>Tetkik ile hizmet AYRI kartlar.</b> Hizmet kartı fiyat ve
/// faturalamayı, tetkik kartı laboratuvar davranışını (numune, tüp, TAT,
/// panik, delta, oto-onay) taşır. Tek kartta birleştirmek, muhasebe alanı
/// değiştiren birinin panik sınırını da düzenleyebilmesi demekti.</para>
///
/// <para><b>Referans aralıkları tetkiğin DETAYI.</b> Yaş/cinsiyet kırılımı
/// olmadan bayrak üretilemez; ayrı ekrana taşımak, tetkik açan kişinin
/// referansı hiç girmemesine yol açardı.</para>
/// </summary>
public static partial class KartKatalogu
{
    // 360'taki LabBolumKodlari lab ISTEMININ bolumu (5 deger); tetkik
    //   katalogu daha ince kirilim ister (hormon/koagulasyon ayri calisir).
    private static readonly Dictionary<string, string> LabTetkikBolumKodlari = new()
    {
        ["1"] = "Biyokimya", ["2"] = "Hematoloji", ["3"] = "Hormon",
        ["4"] = "Mikrobiyoloji", ["5"] = "Seroloji", ["6"] = "Koagülasyon",
        ["7"] = "İdrar", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> LabTetkikTurKodlari = new()
        { ["1"] = "Sayısal", ["2"] = "Metin", ["3"] = "Seçenek", ["4"] = "Kültür" };

    private static readonly Dictionary<string, string> LabNumuneTipiKodlari = new()
    {
        ["1"] = "Serum", ["2"] = "Plazma", ["3"] = "Tam Kan", ["4"] = "İdrar",
        ["5"] = "Gaita", ["6"] = "BOS", ["7"] = "Swab", ["9"] = "Diğer",
    };

    // TUP RENGI KATKI MADDESINI ANLATIR: numune plani bu koda gore tup
    //   birlestirir - ayni tupten iki kez kan almamak icin.
    private static readonly Dictionary<string, string> LabTupTipiKodlari = new()
    {
        ["1"] = "Sarı (Jelli / Biyokimya)", ["2"] = "Mor (EDTA / Hemogram)",
        ["3"] = "Mavi (Sitrat / Koagülasyon)", ["4"] = "Gri (Florür / Glukoz)",
        ["5"] = "Yeşil (Heparin)", ["6"] = "İdrar Kabı", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> LabKayitDurumKodlari = new()
        { ["0"] = "Aktif", ["1"] = "Pasif" };

    private static readonly Dictionary<string, string> LabCinsiyetKodlari = new()
        { ["0"] = "Farketmez", ["1"] = "Erkek", ["2"] = "Kadın" };

    /// <summary>
    /// TETKİK KARTI + referans aralıkları.
    ///
    /// Panik sınırı tetkikte, referansta ise yaşa/cinsiyete özel sınır var:
    /// referans satırındaki panik BOŞSA tetkiğinki geçerlidir (yenidoğan
    /// bilirubini gibi istisnalar için).
    /// </summary>
    private static KartTanimi LabTetkikKarti() => new(
        Ad: "lab-tetkik",
        YetkiKodu: "lab.tetkik",
        Tablo: "public.lab_tetkik",
        LogTabloId: 1010,
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["bolum"] = (short)1,
            ["tur"] = (short)1,
            ["numuneTipi"] = (short)1,
            ["tupTipi"] = (short)1,
            ["ondalik"] = (short)2,
            ["hedefTatDk"] = 120,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_istem_satir", "tetkik_id",
                "Bu tetkik istemlerde kullanılmış - silinemez, pasife alın."),
            new("public.lab_panel_satir", "tetkik_id",
                "Bu tetkik bir panelde kullanılıyor."),
            new("public.lab_cihaz_test_esleme", "tetkik_id",
                "Bu tetkiğin cihaz eşlemesi var."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Tetkik Kodu", Grup: "Kimlik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Tetkik Adı", Grup: "Kimlik"),
            new("kisaAd", "kisa_ad", "metin", EnFazlaUzunluk: 60,
                Baslik: "Kısa Ad (rapor)", Grup: "Kimlik"),
            new("bolum", "bolum", "kod", SabitKodlar: LabTetkikBolumKodlari,
                Baslik: "Bölüm", Grup: "Kimlik"),
            new("tur", "tur", "kod", SabitKodlar: LabTetkikTurKodlari,
                Baslik: "Sonuç Türü", Grup: "Kimlik"),
            // Hizmet 1:1: faturalama ve fiyat hizmet kartından gelir.
            new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_hizmet_lookup",
                Baslik: "Hizmet (fiyat/fatura)", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // ---------------------------------------------------------- numune
            new("numuneTipi", "numune_tipi", "kod", SabitKodlar: LabNumuneTipiKodlari,
                Baslik: "Numune Tipi", Grup: "Numune"),
            new("tupTipi", "tup_tipi", "kod", SabitKodlar: LabTupTipiKodlari,
                Baslik: "Tüp", Grup: "Numune"),
            new("numuneHacimMl", "numune_hacim_ml", "sayi",
                Baslik: "Hacim (mL)", Grup: "Numune"),
            new("hazirlikNotu", "hazirlik_notu", "metin", EnFazlaUzunluk: 400,
                Baslik: "Hasta Hazırlığı (açlık vb.)", Grup: "Numune"),

            // ----------------------------------------------------------- sonuç
            new("birim", "birim", "metin", EnFazlaUzunluk: 20,
                Baslik: "Birim", Grup: "Sonuç"),
            new("ondalik", "ondalik", "sayi", Baslik: "Ondalık Basamak", Grup: "Sonuç"),
            new("yontem", "yontem", "metin", EnFazlaUzunluk: 100,
                Baslik: "Yöntem", Grup: "Sonuç"),
            new("olculebilirAlt", "olculebilir_alt", "sayi",
                Baslik: "Ölçülebilir Alt Sınır", Grup: "Sonuç"),
            new("olculebilirUst", "olculebilir_ust", "sayi",
                Baslik: "Ölçülebilir Üst Sınır", Grup: "Sonuç"),
            new("loinc", "loinc", "metin", EnFazlaUzunluk: 12,
                Baslik: "LOINC", Grup: "Sonuç"),
            new("skrsTetkikKod", "skrs_tetkik_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "SKRS Kodu (e-Nabız)", Grup: "Sonuç"),

            // ------------------------------------------------------ kural/süre
            new("hedefTatDk", "hedef_tat_dk", "sayi",
                Baslik: "Hedef TAT (dk)", Grup: "Kural"),
            new("acilTatDk", "acil_tat_dk", "sayi",
                Baslik: "Acil TAT (dk)", Grup: "Kural"),
            new("panikAlt", "panik_alt", "sayi", Baslik: "Panik Alt", Grup: "Kural"),
            new("panikUst", "panik_ust", "sayi", Baslik: "Panik Üst", Grup: "Kural"),
            // DELTA: aynı hastanın önceki ONAYLI sonucuyla fark yüzdesi. Gün
            //   sıfırsa delta hiç çalışmaz - eski bir sonuçla kıyaslamak yanlış
            //   uyarı üretirdi.
            new("deltaYuzde", "delta_yuzde", "sayi",
                Baslik: "Delta Uyarı %", Grup: "Kural"),
            new("deltaGun", "delta_gun", "sayi",
                Baslik: "Delta Geçerlilik (gün)", Grup: "Kural"),
            new("otoOnay", "oto_onay", "mantik",
                Baslik: "Oto Onay (temiz sonuçta)", Grup: "Kural"),
            new("varsayilanCihazId", "varsayilan_cihaz_id", "kod",
                KodTablosu: "public.v_cihaz_lookup",
                Baslik: "Varsayılan Cihaz", Grup: "Kural"),
            new("disLabId", "dis_lab_id", "kod", KodTablosu: "public.v_cari_lookup",
                AramaKaynagi: "cari", Baslik: "Dış Laboratuvar", Grup: "Kural"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("referanslar", "public.lab_tetkik_referans", "tetkik_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("cinsiyet", "cinsiyet", "kod", SabitKodlar: LabCinsiyetKodlari,
                    Baslik: "Cinsiyet"),
                // Yaş GÜN cinsinden: yenidoğan aralıkları gün/hafta ölçeğinde.
                //   Yıl tutulsaydı 0-28 günlük bebek tek kovaya düşerdi.
                new("yasAltGun", "yas_alt_gun", "sayi", Baslik: "Yaş Alt (gün)"),
                new("yasUstGun", "yas_ust_gun", "sayi", Baslik: "Yaş Üst (gün)"),
                new("gebelik", "gebelik", "mantik", Baslik: "Gebelik"),
                new("alt", "alt", "sayi", Baslik: "Alt Sınır"),
                new("ust", "ust", "sayi", Baslik: "Üst Sınır"),
                new("metin", "metin", "metin", EnFazlaUzunluk: 100,
                    Baslik: "Metin Referans"),
                new("panikAlt", "panik_alt", "sayi", Baslik: "Panik Alt"),
                new("panikUst", "panik_ust", "sayi", Baslik: "Panik Üst"),
                new("kaynak", "kaynak", "metin", EnFazlaUzunluk: 100, Baslik: "Kaynak"),
                new("gecerliBas", "gecerli_bas", "tarih", Baslik: "Geçerlilik"),
            }, SubeKolonu: null, Sirala: "cinsiyet, yas_alt_gun, id",
               Baslik: "Referans Aralıkları", LogTabloId: 1011),

            // KÜLTÜR TETKİĞİNİN VARSAYILAN BESİYERİ SETİ (436): ekim
            //   açılırken buradan kopyalanır. Kopyalanır çünkü katalog
            //   sonradan değişse geçmiş kültürün hangi besiyerine ekildiği
            //   değişmemeli.
            new("besiyeriler", "public.lab_tetkik_besiyeri", "tetkik_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("besiyeriId", "besiyeri_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_lab_besiyeri_lookup", Baslik: "Besiyeri"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Besiyeri Seti (kültür)",
               LogTabloId: 1018),
        });

    /// <summary>PANEL KARTI — istemde tek kalemde açılan tetkik grubu.</summary>
    private static KartTanimi LabPanelKarti() => new(
        Ad: "lab-panel",
        YetkiKodu: "lab.tetkik",
        Tablo: "public.lab_panel",
        LogTabloId: 1012,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)0 },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_istem_satir", "panel_id",
                "Bu panel istemlerde kullanılmış - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Panel Kodu", Grup: "Kimlik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Panel Adı", Grup: "Kimlik"),
            new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_hizmet_lookup",
                Baslik: "Hizmet (paket fiyat)", Grup: "Kimlik"),
            new("bolum", "bolum", "kod", SabitKodlar: LabTetkikBolumKodlari,
                Baslik: "Bölüm", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // aciklama kolonu 433'te yoktu, 435'te eklendi: kartta tanimli
            //   olmasi SELECT'i "column aciklama does not exist" ile
            //   dusuruyor ve panel karti HIC ACILMIYORDU.
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Kimlik"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("tetkikler", "public.lab_panel_satir", "panel_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("tetkikId", "tetkik_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_lab_tetkik_lookup", Baslik: "Tetkik"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Panel Tetkikleri",
               LogTabloId: 1013),
        });

    /// <summary>
    /// CİHAZ TEST EŞLEME KARTI (434).
    ///
    /// Kayıt YALNIZ istisna için: cihaz kodu tetkik koduyla aynıysa eşleme
    /// gerekmez. Her cihaz için tüm testleri elle girdirmek kurulumu haftalara
    /// yayardı.
    /// </summary>
    private static KartTanimi LabCihazEslemeKarti() => new(
        Ad: "lab-cihaz-esleme",
        YetkiKodu: "lab.cihaz",
        Tablo: "public.lab_cihaz_test_esleme",
        LogTabloId: 1014,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["carpan"] = 1m,
            ["ofset"] = 0m,
            ["durum"] = (short)0,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("cihazId", "cihaz_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_cihaz_lookup", Baslik: "Cihaz", Grup: "Eşleme"),
            new("cihazTestKodu", "cihaz_test_kodu", "metin", Zorunlu: true,
                EnFazlaUzunluk: 30, Baslik: "Cihazın Test Kodu", Grup: "Eşleme"),
            new("altKod", "alt_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "Alt Kod", Grup: "Eşleme"),
            new("tetkikId", "tetkik_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_lab_tetkik_lookup", Baslik: "Tetkik",
                Grup: "Eşleme"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Eşleme"),

            // Cihaz mg/dL verip laboratuvar mmol/L raporluyorsa: yeni = ham *
            //   çarpan + ofset. Ham değer sonuçta ayrıca saklanır.
            new("cihazBirim", "cihaz_birim", "metin", EnFazlaUzunluk: 20,
                Baslik: "Cihaz Birimi", Grup: "Çevrim"),
            new("carpan", "carpan", "sayi", Baslik: "Çarpan", Grup: "Çevrim"),
            new("ofset", "ofset", "sayi", Baslik: "Ofset", Grup: "Çevrim"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Çevrim"),
        });
}
