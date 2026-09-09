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
    /// <summary>
    /// Laboratuvar bolumleri. TEK KAYNAK (492): kart metasi da, liste
    /// seridindeki bolum suzgeci de (KaynakKatalogu.Lab) bu haritayi okur.
    /// </summary>
    internal static readonly Dictionary<string, string> LabTetkikBolumKodlari = new()
    {
        ["1"] = "Biyokimya", ["2"] = "Hematoloji", ["3"] = "Hormon",
        ["4"] = "Mikrobiyoloji", ["5"] = "Seroloji", ["6"] = "Koagülasyon",
        ["7"] = "İdrar", ["9"] = "Diğer",
    };

    /// <summary>
    /// ÇALIŞMA DÜZENİ (486). Laboratuvarda her tetkik her an çalışmaz: hormon
    /// paneli haftada üç gün seri hâlinde, tam kan sayımı sürekli çalışır.
    /// Sonuç saati bu yüzden "kabul + TAT" değil "SIRADAKİ ÇALIŞMA + TAT"tır.
    /// </summary>
    private static readonly Dictionary<string, string> LabCalismaDuzeniKodlari = new()
    {
        ["0"] = "Sürekli (7/24)",
        ["1"] = "Mesai içi",
        ["2"] = "Belirli günlerde (seri)",
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
            // SERIT DORT ALAN (mockup lab_tetkik_karti.html): Kod · Ad ·
            //   Kisa Ad · Durum. Bolum/tur/hizmet KARARDIR, kimlik degil -
            //   Genel sekmesindeki Tanim kutusunda.
            new("bolum", "bolum", "kod", SabitKodlar: LabTetkikBolumKodlari,
                Baslik: "Bölüm", Grup: "Genel", AltGrup: "Tanım"),
            new("tur", "tur", "kod", SabitKodlar: LabTetkikTurKodlari,
                Baslik: "Sonuç Türü", Grup: "Genel", AltGrup: "Tanım"),
            // Hizmet 1:1: faturalama ve fiyat hizmet kartından gelir.
            new("hizmetId", "hizmet_id", "kod", KodTablosu: "public.v_hizmet_lookup",
                Baslik: "Hizmet (fiyat/fatura)", Grup: "Genel", AltGrup: "Tanım"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // ---------------------------------------------------------- numune
            new("numuneTipi", "numune_tipi", "kod", SabitKodlar: LabNumuneTipiKodlari,
                Baslik: "Numune Tipi", Grup: "Genel", AltGrup: "Numune"),
            new("tupTipi", "tup_tipi", "kod", SabitKodlar: LabTupTipiKodlari,
                Baslik: "Tüp", Grup: "Genel", AltGrup: "Numune"),
            new("numuneHacimMl", "numune_hacim_ml", "sayi",
                Baslik: "Hacim (mL)", Grup: "Genel", AltGrup: "Numune"),
            new("hazirlikNotu", "hazirlik_notu", "metin", EnFazlaUzunluk: 400,
                Baslik: "Hasta Hazırlığı (açlık vb.)", Grup: "Genel", AltGrup: "Numune"),

            // ----------------------------------------------------------- sonuç
            new("birim", "birim", "metin", EnFazlaUzunluk: 20,
                Baslik: "Birim", Grup: "Genel", AltGrup: "Sonuç ve Birim"),
            new("ondalik", "ondalik", "sayi", Baslik: "Ondalık Basamak", Grup: "Genel", AltGrup: "Sonuç ve Birim"),
            new("yontem", "yontem", "metin", EnFazlaUzunluk: 100,
                Baslik: "Yöntem", Grup: "Genel", AltGrup: "Tanım"),
            new("olculebilirAlt", "olculebilir_alt", "sayi",
                Baslik: "Ölçülebilir Alt Sınır", Grup: "Genel", AltGrup: "Sonuç ve Birim"),
            new("olculebilirUst", "olculebilir_ust", "sayi",
                Baslik: "Ölçülebilir Üst Sınır", Grup: "Genel", AltGrup: "Sonuç ve Birim"),
            new("loinc", "loinc", "metin", EnFazlaUzunluk: 12,
                Baslik: "LOINC", Grup: "Genel", AltGrup: "Tanım"),
            new("skrsTetkikKod", "skrs_tetkik_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "SKRS Kodu (e-Nabız)", Grup: "Genel", AltGrup: "Tanım"),

            // ------------------------------------------------------ kural/süre
            new("hedefTatDk", "hedef_tat_dk", "sayi",
                Baslik: "Hedef TAT (dk)", Grup: "Genel", AltGrup: "Süre ve Onay"),
            new("acilTatDk", "acil_tat_dk", "sayi",
                Baslik: "Acil TAT (dk)", Grup: "Genel", AltGrup: "Süre ve Onay"),
            new("panikAlt", "panik_alt", "sayi", Baslik: "Panik Alt", Grup: "Genel", AltGrup: "Sonuç ve Birim"),
            new("panikUst", "panik_ust", "sayi", Baslik: "Panik Üst", Grup: "Genel", AltGrup: "Sonuç ve Birim"),
            // DELTA: aynı hastanın önceki ONAYLI sonucuyla fark yüzdesi. Gün
            //   sıfırsa delta hiç çalışmaz - eski bir sonuçla kıyaslamak yanlış
            //   uyarı üretirdi.
            new("deltaYuzde", "delta_yuzde", "sayi",
                Baslik: "Delta Uyarı %", Grup: "Genel", AltGrup: "Süre ve Onay"),
            new("deltaGun", "delta_gun", "sayi",
                Baslik: "Delta Geçerlilik (gün)", Grup: "Genel", AltGrup: "Süre ve Onay"),
            new("otoOnay", "oto_onay", "mantik",
                Baslik: "Oto Onay (temiz sonuçta)", Grup: "Genel", AltGrup: "Süre ve Onay"),
            new("varsayilanCihazId", "varsayilan_cihaz_id", "kod",
                KodTablosu: "public.v_cihaz_lookup",
                Baslik: "Varsayılan Cihaz", Grup: "Genel", AltGrup: "Süre ve Onay"),
            new("disLabId", "dis_lab_id", "kod", KodTablosu: "public.v_cari_lookup",
                AramaKaynagi: "cari", Baslik: "Dış Laboratuvar", Grup: "Dış Laboratuvar"),

            // ------------------------------------------------- çalışma zamanı
            // 486 (kullanici: "istem yapildiginda tum sonuclar ne zaman cikacak
            //   belli olsun"). Katalogta yalniz TAT vardi - "kac dakikada
            //   biter". Ama numune kabul son saatini bir dakika gecen tup bir
            //   sonraki seriye kalir ve hastaya soylenen saat o an degisir.
            //   Sonuc zamani `fn_lab_tetkik_sonuc_zamani` ile SUNUCUDA hesaplanir.
            new("calismaDuzeni", "calisma_duzeni", "kod",
                SabitKodlar: LabCalismaDuzeniKodlari,
                Baslik: "Çalışma Düzeni", Grup: "Çalışma Zamanları"),
            // GUNLER BIT MASKESI: 1 Pzt · 2 Sal · 4 Çar · 8 Per · 16 Cum ·
            //   32 Cmt · 64 Paz. Tek kolonda cunku "hangi gunler" tek sorudur;
            //   yedi ayri mantik kolonu ayni soruyu yedi kez sorardi.
            new("calismaGunleri", "calisma_gunleri", "sayi",
                Baslik: "Çalışma Günleri", Grup: "Çalışma Zamanları"),
            new("calismaSaatleri", "calisma_saatleri", "metin", EnFazlaUzunluk: 100,
                Baslik: "Çalışma Saatleri", Grup: "Çalışma Zamanları"),
            new("kabulSonDk", "kabul_son_dk", "sayi",
                // Birim ETIKETTE degil DEGERIN YANINDA (kullanici): baslik
                //   iki satira kiriliyordu, okunan sey "30 dk önce" cumlesidir.
                Baslik: "Son Kabul", Grup: "Çalışma Zamanları"),
            new("enAzSeri", "en_az_seri", "sayi",
                Baslik: "En Az Seri Sayısı", Grup: "Çalışma Zamanları"),
            new("tatilCalisir", "tatil_calisir", "mantik",
                Baslik: "Resmî Tatilde Çalışılır", Grup: "Çalışma Zamanları"),
            new("acilBeklemez", "acil_beklemez", "mantik",
                Baslik: "Acil İstem Düzeni Beklemez", Grup: "Çalışma Zamanları"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("referanslar", "public.lab_tetkik_referans", "tetkik_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                // KİME (488, kullanici: "referans yas araligi da birimli
                //   anlasilir olsun"). Gun cinsinden saklanan aralik ekranda
                //   "6570 — 54750" diye iki sayiydi: sayi dogru, cevap degil.
                //   Yas + cinsiyet + gebelik TEK metinde - kural bir butundur,
                //   uc hucre birden okunarak anlasilmamali. SALT OKUNUR:
                //   turetilmis alan, duzenleme asagidaki alanlardan yapilir.
                new("kime",
                    "public.fn_lab_referans_kime(cinsiyet, yas_alt_gun, yas_ust_gun, gebelik)",
                    "metin", Yazilabilir: false, Baslik: "Kime"),
                new("cinsiyet", "cinsiyet", "kod", SabitKodlar: LabCinsiyetKodlari,
                    Baslik: "Cinsiyet"),
                // Yaş GÜN cinsinden: yenidoğan aralıkları gün/hafta ölçeğinde.
                //   Yıl tutulsaydı 0-28 günlük bebek tek kovaya düşerdi.
                new("yasAltGun", "yas_alt_gun", "sayi", Baslik: "Yaş Aralığı"),
                new("yasUstGun", "yas_ust_gun", "sayi", Baslik: "Yaş Üst"),
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

            // CIHAZ ESLEME (mockup): tetkigin hangi cihazda hangi kodla
            //   calistigi. Cihaz FARKLI BIRIMDE calisiyorsa carpan burada
            //   verilir ve sonuc KARTIN birimine cevrilerek saklanir - cevrim
            //   sonucta yapilsaydi cihaz degisince eski sonuclar okunamaz olurdu.
            new("cihazlar", "public.lab_cihaz_test_esleme", "tetkik_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("cihazId", "cihaz_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_cihaz_lookup", Baslik: "Cihaz"),
                new("cihazTestKodu", "cihaz_test_kodu", "metin", Zorunlu: true,
                    EnFazlaUzunluk: 40, Baslik: "Cihaz Test Kodu"),
                new("cihazBirim", "cihaz_birim", "metin", EnFazlaUzunluk: 20,
                    Baslik: "Cihaz Birimi"),
                new("carpan", "carpan", "sayi", Baslik: "Çarpan"),
                new("ofset", "ofset", "sayi", Baslik: "Ofset"),
                new("altKod", "alt_kod", "metin", EnFazlaUzunluk: 40, Baslik: "Alt Kod"),
                new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                    Baslik: "Durum"),
            }, Sirala: "id", Baslik: "Cihaz Eşleme", LogTabloId: 1016),

            // PANELLER - SALT OKUNUR (mockup "bu tetkik nerede geciyor").
            //   Silmeden once okunacak yerdir: katalogtan tetkik silmek onu
            //   iceren panelleri sahipsiz birakir. Panelden cikarmak PANEL
            //   kartinin isi - buradan satir eklenip silinmez.
            new("paneller", "public.lab_panel_satir", "tetkik_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("panelId", "panel_id", "kod", Yazilabilir: false,
                    KodTablosu: "public.v_lab_panel_lookup", Baslik: "Panel"),
                new("sira", "sira", "sayi", Yazilabilir: false, Baslik: "Sıra"),
            }, SubeKolonu: null, Sirala: "id", Baslik: "Paneller",
               LogTabloId: 1013, SaltOkunur: true),
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
