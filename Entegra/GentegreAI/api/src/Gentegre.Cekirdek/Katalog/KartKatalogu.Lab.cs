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

    // KARAR SINIRI YÖNÜ (896): eşiğin hangi tarafı "hedef".
    private static readonly Dictionary<string, string> LabKararYonKodlari = new()
        { ["1"] = "Bu değerin ALTINDA olmalı", ["2"] = "Bu değerin ÜSTÜNDE olmalı" };

    private static readonly Dictionary<string, string> LabCiftOnayKodlari = new()
        { ["0"] = "Kurum ayarını izle", ["1"] = "Teknik onay zorunlu",
          ["2"] = "Muaf (tek aşama)" };

    private static readonly Dictionary<string, string> LabArsivKonumTuru = new()
        { ["1"] = "Ünite (dolap / derin dondurucu)", ["2"] = "Raf", ["3"] = "Kutu" };

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
            // SONUÇ DOĞRULAMA (893, KTS L1). ÜÇ SINIR KARIŞTIRILMAMALI:
            //   panik = gerçek ama hayati değer (bildirilir), ölçülebilir =
            //   cihazın aralığı (dışı UYARI), mantık = fizyolojik olarak
            //   imkânsız (ENGEL - bu bir ölçüm değil, yazım hatasıdır).
            new("mantikAlt", "mantik_alt", "sayi",
                Baslik: "İmkânsız Alt Sınır (engel)", Grup: "Genel",
                AltGrup: "Sonuç ve Birim"),
            new("mantikUst", "mantik_ust", "sayi",
                Baslik: "İmkânsız Üst Sınır (engel)", Grup: "Genel",
                AltGrup: "Sonuç ve Birim"),
            // Metin/seçenek tetkiklerde kabul edilen değerler; boş = serbest.
            new("degerDeseni", "deger_deseni", "metin", EnFazlaUzunluk: 200,
                Baslik: "Kabul Edilen Değerler (^(Negatif|Pozitif)$)", Grup: "Genel",
                AltGrup: "Sonuç ve Birim"),
            new("bosSonucEngel", "bos_sonuc_engel", "mantik",
                Baslik: "Boş sonuç girilemesin", Grup: "Genel", AltGrup: "Sonuç ve Birim"),
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
            // İKİ SEVİYELİ ONAY (895, KTS L4): kurum ayarı genel kuraldır,
            //   tetkik onu ezebilir - kan grubu/patoloji ile idrar pH aynı
            //   özeni gerektirmiyor. Zorunluysa OTO-ONAY DA DEVRE DIŞI
            //   kalır: oto-onay tek aşamalı yayındır.
            new("ciftOnay", "cift_onay", "kod", SabitKodlar: LabCiftOnayKodlari,
                Baslik: "İki Seviyeli Onay", Grup: "Genel", AltGrup: "Süre ve Onay"),
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
                // CİHAZ / YÖNTEM (888, KTS L3): aynı tetkikin aralığı ölçüm
                //   yöntemine göre değişir. BOŞ = tüm cihazlar; dolu satır
                //   genel satırı ezer, çünkü yöntem farkı yaş bandından daha
                //   belirleyicidir. İki cihazlı laboratuvar tek aralık
                //   kullanırsa bir cihazın sonuçları sistematik yanlış
                //   bayraklanır.
                new("cihazId", "cihaz_id", "kod", KodTablosu: "public.v_cihaz_lookup",
                    Baslik: "Cihaz (boş = tümü)"),
                new("yontem", "yontem", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Yöntem / Kit"),
            }, SubeKolonu: null, Sirala: "cinsiyet, yas_alt_gun, id",
               Baslik: "Referans Aralıkları", LogTabloId: 1011),

            // KLİNİK KARAR SINIRLARI (896, KTS L15).
            //   REFERANS ARALIĞI DEĞİLDİR: referans sağlıklı popülasyonun
            //   dağılımı, karar sınırı kılavuzun eşiğidir. LDL 115 mg/dL
            //   referans aralığında "normal" görünür ama hedefin üstündedir;
            //   ikisi ayrı satırlarda tanımlanır ve rapor ikisini de yazar.
            new("kararSinirlari", "public.lab_karar_siniri", "tetkik_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 80,
                    Baslik: "Sınır Adı"),
                new("yon", "yon", "kod", Zorunlu: true, SabitKodlar: LabKararYonKodlari,
                    Baslik: "Yön"),
                new("deger", "deger", "sayi", Zorunlu: true, Baslik: "Eşik"),
                new("cinsiyet", "cinsiyet", "kod", SabitKodlar: LabCinsiyetKodlari,
                    Baslik: "Cinsiyet"),
                new("yasAltGun", "yas_alt_gun", "sayi", Baslik: "Yaş Alt (gün)"),
                new("yasUstGun", "yas_ust_gun", "sayi", Baslik: "Yaş Üst (gün)"),
                new("dayanak", "dayanak", "metin", EnFazlaUzunluk: 120,
                    Baslik: "Dayanak (kılavuz)"),
                new("mesaj", "mesaj", "metin", EnFazlaUzunluk: 200,
                    Baslik: "Özel Metin (boşsa üretilir)"),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("aktif", "aktif", "mantik", Baslik: "Aktif"),
            }, SubeKolonu: null, Sirala: "sira, id",
               Baslik: "Klinik Karar Sınırları", LogTabloId: 1033),

            // TEST SEVİYESİNDE YETKİ KISITI (889, KTS L7).
            //   Yetki modül seviyesindeydi: `lab.sonuc` yetkisi olan herkes
            //   HER tetkiki isteyip görebiliyordu. HIV, adli toksikoloji,
            //   genetik gibi testlerde sonucu görmesi gereken kişi ile
            //   laboratuvarın tamamını gören kişi aynı değildir.
            //
            //   SATIR YOKSA TETKİK HERKESE AÇIK. Bir satır eklendiği anda
            //   tetkik KAPANIR ve yalnız listelenen roller kalır - "kısıt
            //   tanımlanana kadar her şey kapalı" kurulu sistemi durdururdu.
            //   Üç işlem ayrı: bir rol testi isteyebilir ama sonucunu
            //   göremeyebilir (isteyen hekim ile yorumlayan uzman ayrı).
            new("kisitlar", "public.lab_tetkik_kisit", "tetkik_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("rolId", "rol_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_rol_lookup", Baslik: "Rol"),
                new("iste", "iste", "mantik", Baslik: "İsteyebilir"),
                new("gor", "gor", "mantik", Baslik: "Sonucu Görebilir"),
                new("onayla", "onayla", "mantik", Baslik: "Onaylayabilir"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                    Baslik: "Açıklama"),
                new("aktif", "aktif", "mantik", Baslik: "Aktif"),
            }, SubeKolonu: null, Sirala: "rol_id, id",
               Baslik: "Yetki Kısıtları", LogTabloId: 1032),

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
            }, Sirala: "id", Baslik: "Cihaz Eşleme", LogTabloId: 1293),

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
        LogTabloId: 1293,
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

    /// <summary>AKILCI TEST İSTEM KURALI kartı (873). SUT kodu ve hizmet bağı kurulumdan gelir; kurum süre/branş/basamak/aktif düzeltir.</summary>
    private static KartTanimi LabAkilciKuralKarti() => new(
        Ad: "lab-akilci-kural",
        YetkiKodu: "lab.tetkik",
        Tablo: "public.lab_akilci_kural",
        LogTabloId: 1351,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["sureGun"] = 0, ["tumBranslar"] = (short)1, ["basamak"] = (short)2, ["aktif"] = (short)1, ["kaynakSurum"] = "kurum" },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("sutKodu",     "sut_kodu",     "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "SUT Kodu", Grup: "Kural"),
            new("ad",          "ad",           "metin", EnFazlaUzunluk: 200, Baslik: "Test", Grup: "Kural"),
            new("hizmetId",    "hizmet_id",    "kod",   KodTablosu: "public.v_hizmet_lookup", Baslik: "Hizmet (katalog)", Grup: "Kural"),
            new("aktif",       "aktif",        "mantik", Baslik: "Aktif", Grup: "Kural"),
            new("sureGun",     "sure_gun",     "sayi",  Baslik: "Tekrar aralığı (gün, 0 = yok)", Grup: "Süre"),
            new("sureNotu",    "sure_notu",    "metin", EnFazlaUzunluk: 300, Baslik: "Süre notu (Bakanlık metni)", Grup: "Süre"),
            new("bayraklar",   "bayraklar",    "metin", EnFazlaUzunluk: 120, Baslik: "Bayraklar", Grup: "Süre", Yazilabilir: false),
            new("tumBranslar", "tum_branslar", "mantik", Baslik: "Tüm branşlar isteyebilir", Grup: "Branş"),
            new("bransKodlari","brans_kodlari","metin", EnFazlaUzunluk: 400, Baslik: "Yetkili branş kodları (SKRS klinik, virgülle)", Grup: "Branş"),
            new("bransHam",    "brans_ham",    "metin", EnFazlaUzunluk: 600, Baslik: "Bakanlık listesindeki branş metni", Grup: "Branş", Yazilabilir: false),
            new("refleks",     "refleks",      "mantik", Baslik: "Refleks test (lab uzmanı ister)", Grup: "Branş"),
            new("basamak",     "basamak",      "kod",   SabitKodlar: new Dictionary<string, string> { ["0"] = "Kapsam dışı", ["2"] = "2. ve 3. basamak", ["3"] = "Yalnız 3. basamak" }, Baslik: "Basamak", Grup: "Tesis"),
            new("kapali",      "kapali",       "mantik", Baslik: "İsteme kapalı", Grup: "Tesis"),
            new("aciklama",    "aciklama",     "metin", EnFazlaUzunluk: 600, Baslik: "Not", Grup: "Tesis"),
            new("kaynakSurum", "kaynak_surum", "metin", EnFazlaUzunluk: 40, Baslik: "Kaynak sürümü", Grup: "Tesis", Yazilabilir: false),
        });

    /// <summary>
    /// BZBH HASTALIK kartı (882). ICD öneki benzersiz: aynı önek iki kez
    /// tanımlanırsa hangi kuralın geçerli olduğu belirsizleşirdi.
    /// </summary>
    private static KartTanimi BzbhHastalikKarti() => new(
        Ad: "bzbh-hastalik",
        YetkiKodu: "bzbh.hastalik",
        Tablo: "public.bzbh_hastalik",
        LogTabloId: 1354,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["grup"] = (short)1, ["sureSaat"] = (short)24, ["dogrulandi"] = (short)1,
            ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",        "sayi",  Yazilabilir: false),
            new("ad",        "ad",        "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Hastalık", Grup: "Tanım"),
            new("icdOnek",   "icd_onek",  "metin", Zorunlu: true, EnFazlaUzunluk: 10,
                Baslik: "ICD-10 öneki (A15 → tüm alt kodlar)", Grup: "Tanım"),
            new("grup",      "grup",      "kod",
                SabitKodlar: new Dictionary<string, string>
                {
                    ["1"] = "Grup A - ivedi bildirim", ["2"] = "Grup B",
                    ["3"] = "Grup C", ["4"] = "Grup D - laboratuvar bildirimi",
                },
                Baslik: "Bildirim grubu", Grup: "Tanım"),
            new("sureSaat",  "sure_saat", "sayi",  Baslik: "Bildirim süresi (saat)", Grup: "Tanım"),
            new("dogrulandi","dogrulandi","mantik",
                Baslik: "Bakanlık tebliğine göre doğrulandı", Grup: "Tanım"),
            new("aktif",     "aktif",     "mantik", Baslik: "Aktif", Grup: "Tanım"),
            new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Tanım"),
        });

    /// <summary>
    /// NUMUNE RET KRİTERİ kartı (879, KTS L6): laboratuvar kendi kabul/ret
    /// ölçütlerini tanımlar. KOD DEĞİŞTİRİLEBİLİR DEĞİL - geçmiş numunelerin
    /// ret sebebi o koda bağlı; kodu değiştirmek eski kayıtların anlamını
    /// sessizce değiştirirdi.
    /// </summary>
    private static KartTanimi LabRetNedeniKarti() => new(
        Ad: "lab-ret-nedeni",
        YetkiKodu: "lab.ret_nedeni",
        Tablo: "public.lab_ret_nedeni",
        LogTabloId: 1353,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["kabuldeSecilebilir"] = (short)0, ["hastaBilgilendir"] = (short)0,
            ["aktif"] = (short)1, ["sira"] = 0,
        },
        Alanlar: new KartAlani[]
        {
            new("id",       "id",       "sayi",  Yazilabilir: false),
            new("kod",      "kod",      "sayi",  Zorunlu: true, Baslik: "Kod", Grup: "Kriter"),
            new("ad",       "ad",       "metin", Zorunlu: true, EnFazlaUzunluk: 80,
                Baslik: "Ret kriteri", Grup: "Kriter"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Kriter"),
            new("sira",     "sira",     "sayi",  Baslik: "Sıra", Grup: "Kriter"),
            new("aktif",    "aktif",    "mantik", Baslik: "Aktif", Grup: "Kriter"),
            new("kabuldeSecilebilir", "kabulde_secilebilir", "mantik",
                Baslik: "Numune kabul edilirken de seçilebilir", Grup: "Davranış"),
            new("hastaBilgilendir", "hasta_bilgilendir", "mantik",
                Baslik: "Bu nedenle reddedilince hastaya e-Nabız mesajı yaz", Grup: "Davranış"),
            new("mesajSablonu", "mesaj_sablonu", "metin", EnFazlaUzunluk: 300,
                Baslik: "Mesaj metni (boşsa genel metin kullanılır)", Grup: "Davranış"),
        });

    /// <summary>
    /// ARŞİV KONUMU kartı (890, KTS L13): ünite > raf > kutu.
    ///
    /// Izgara (satır × sütun) YALNIZ KUTUDA anlamlı - `ck_lab_arsiv_konum_izgara`
    /// bunu veritabanında da tutuyor: gözü olmayan "kutu" tanımlanamaz, çünkü
    /// içine tüp yerleştirilemez.
    /// </summary>
    private static KartTanimi LabArsivKonumKarti() => new(
        Ad: "lab-arsiv-konum",
        YetkiKodu: "lab.arsiv_konum",
        Tablo: "public.lab_arsiv_konum",
        LogTabloId: 1355,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)3, ["satir"] = 9, ["sutun"] = 9, ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",  "id",  "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Konum"),
            new("ad",  "ad",  "metin", Zorunlu: true, EnFazlaUzunluk: 80,
                Baslik: "Ad", Grup: "Konum"),
            new("tur", "tur", "kod", Zorunlu: true, SabitKodlar: LabArsivKonumTuru,
                Baslik: "Tür", Grup: "Konum"),
            new("ustId", "ust_id", "kod", KodTablosu: "public.v_lab_arsiv_konum_lookup",
                Baslik: "Bağlı olduğu konum", Grup: "Konum"),
            new("sicaklik", "sicaklik", "sayi", Baslik: "Hedef sıcaklık (°C)",
                Grup: "Konum"),
            new("satir", "satir", "sayi", Baslik: "Izgara satır sayısı (kutu)",
                Grup: "Izgara"),
            new("sutun", "sutun", "sayi", Baslik: "Izgara sütun sayısı (kutu)",
                Grup: "Izgara"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Konum"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Konum"),
        });

    /// <summary>
    /// SAKLAMA SÜRESİ kartı (890): tetkike özel kural genel kuralı ezer.
    ///
    /// Süre boş bırakılamaz ama POLİTİKA HİÇ TANIMLANMAYABİLİR - o zaman
    /// numuneye imha hedefi yazılmaz. Uydurulmuş bir süre, saklanması gereken
    /// numuneyi erken imha ettirirdi.
    /// </summary>
    private static KartTanimi LabSaklamaPolitikaKarti() => new(
        Ad: "lab-saklama-politika",
        YetkiKodu: "lab.saklama_politika",
        Tablo: "public.lab_saklama_politika",
        LogTabloId: 1356,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["gun"] = 7, ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("tetkikId", "tetkik_id", "kod", KodTablosu: "public.v_lab_tetkik_lookup",
                Baslik: "Tetkik (boş = tümü)", Grup: "Kapsam"),
            new("numuneTipi", "numune_tipi", "sayi",
                Baslik: "Numune tipi (boş = tümü)", Grup: "Kapsam"),
            new("gun", "gun", "sayi", Zorunlu: true, Baslik: "Saklama süresi (gün)",
                Grup: "Süre"),
            new("sicaklik", "sicaklik", "sayi", Baslik: "Saklama sıcaklığı (°C)",
                Grup: "Süre"),
            new("dayanak", "dayanak", "metin", EnFazlaUzunluk: 120,
                Baslik: "Dayanak (SKS/ISO maddesi, kurum kararı)", Grup: "Süre"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Süre"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Süre"),
        });

    /// <summary>
    /// AŞI KARTI (898, KTS H10): katalog tanımı.
    ///
    /// <b>SKRS kodu olmadan aşı e-Nabız'a gönderilemez</b> - alan zorunlu
    /// değil (kurum önce kendi listesini kurar), ama uygulama ekranı ve
    /// `v_asi_skrs_eksik` görünümü eksiği söyler. Kodu uydurmak, Bakanlığın
    /// listesiyle uyuşmayan ikinci bir liste üretirdi.
    /// </summary>
    private static KartTanimi AsiKarti() => new(
        Ad: "asi",
        YetkiKodu: "asi.katalog",
        Tablo: "public.asi",
        LogTabloId: 1357,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["dozSayisi"] = 1, ["aktif"] = (short)1, ["sira"] = 0,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Tanım"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 160,
                Baslik: "Aşı Adı", Grup: "Tanım"),
            new("skrsKod", "skrs_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "SKRS Kodu (e-Nabız için zorunlu)", Grup: "Tanım"),
            // 0 = tek doz ya da şemasız (seyahat aşısı, kuduz profilaksisi
            //   kendi akışında yürür).
            new("dozSayisi", "doz_sayisi", "sayi",
                Baslik: "Şemadaki Doz Sayısı (0 = şemasız)", Grup: "Tanım"),
            new("uygulamaSekli", "uygulama_sekli", "sayi",
                Baslik: "Varsayılan Uygulama Şekli (SKRS)", Grup: "Uygulama"),
            new("uygulamaYeri", "uygulama_yeri", "sayi",
                Baslik: "Varsayılan Uygulama Yeri (SKRS)", Grup: "Uygulama"),
            new("stokId", "stok_id", "kod", KodTablosu: "public.v_stok_lookup",
                AramaKaynagi: "stok", Baslik: "Stok Kartı (lot/karekod)",
                Grup: "Uygulama"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Tanım"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Tanım"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Tanım"),
        });

    /// <summary>REFLEKS TEST KURALI kartı (873 §6).</summary>
    private static KartTanimi LabRefleksKuralKarti() => new(
        Ad: "lab-refleks-kural",
        YetkiKodu: "lab.tetkik",
        Tablo: "public.lab_refleks_kural",
        LogTabloId: 1352,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["kosul"] = ">", ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",              "sayi",  Yazilabilir: false),
            new("tetkikId",      "tetkik_id",       "kod",   Zorunlu: true, KodTablosu: "public.v_lab_tetkik_lookup", Baslik: "Kaynak tetkik", Grup: "Kural"),
            new("kosul",         "kosul",           "kod",   Zorunlu: true, SabitKodlar: new Dictionary<string, string> { [">"] = "> eşik", [">="] = ">= eşik", ["<"] = "< eşik", ["<="] = "<= eşik", ["yuksek"] = "Yüksek bayrak (H)", ["dusuk"] = "Düşük bayrak (L)", ["anormal"] = "Anormal (H/L)", ["pozitif"] = "Pozitif" }, Baslik: "Koşul", Grup: "Kural"),
            new("esik",          "esik",            "ondalik", Baslik: "Eşik değer", Grup: "Kural"),
            new("hedefTetkikId", "hedef_tetkik_id", "kod",   Zorunlu: true, KodTablosu: "public.v_lab_tetkik_lookup", Baslik: "Eklenecek tetkik", Grup: "Kural"),
            new("aciklama",      "aciklama",        "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama (rehber / dayanak)", Grup: "Kural"),
            new("aktif",         "aktif",           "mantik", Baslik: "Aktif", Grup: "Kural"),
        });
}
