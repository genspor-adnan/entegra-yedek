namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// YATAN HASTA KARTLARI (695) — mockuplar <c>Ekranlar/Yatan/*.html</c>.
///
/// <para><b>Yatış kartı modülün merkezi</b> (<c>yatis_karti.html</c>): tek
/// yatışın tamamı. Order, izlem, sıvı, risk ve yatak hareketleri onun
/// detaylarıdır — ayrı kartlara bölünseydi "bu hastada ne oluyor" sorusu beş
/// ekrana dağılırdı.</para>
///
/// <para>Epikriz de yatışın 1:1 uzantısıdır (<c>TekSatir</c>): çıkış özeti
/// yatış boyunca birikir, taburcu ekranı onu tamamlar - sıfırdan yazmaz.</para>
/// </summary>
public static partial class KartKatalogu
{
    private const int LogYatis      = 1120;
    private const int LogYatisDetay = 1121;
    private const int LogYatak      = 1122;
    private const int LogOda        = 1123;
    private const int LogYatisOrder = 1124;

    /// <summary>Order/uygulama/izlem satırlarında tekrar eden kod sözlükleri.</summary>
    private static readonly Dictionary<string, string> YatanSiviYonu =
        new() { ["1"] = "Aldığı", ["2"] = "Çıkardığı" };

    // ================================================================ yatış ==
    private static KartTanimi YatisKarti() => new(
        // KATALOG ADI LİSTE KAYNAĞIYLA AYNI olmalı: kart, listenin `kaynak`
        //   adıyla aranır (ListeKarti). "yatis" yazılınca kart 404 dönüyordu -
        //   liste `yatan`, tablo `public.yatis`; ikisi aynı şey olmak zorunda
        //   değil ama KATALOG ANAHTARI listeninkiyle eşleşmeli.
        Ad: "yatan",
        YetkiKodu: "yatan",
        Tablo: "public.yatis",
        LogTabloId: LogYatis,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,        // Yatış kabul
            ["yatisTuru"] = (short)1,    // Normal yatış
            ["gelisSekli"] = (short)1,   // Poliklinikten
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("dosyaNo", "dosya_no", "metin", EnFazlaUzunluk: 20,
                Baslik: "Dosya No", Grup: "Genel"),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Genel"),
            // AĞAÇ SEÇİMİ `ust_id` TAŞIYAN görünüm ister: düz lookup ağaç
            //   çizemez ve sunucu "column ust_id does not exist" ile 500
            //   dönüyordu (kart hiç açılmıyordu).
            new("departmanId", "departman_id", "kod",
                KodTablosu: "public.v_departman_agac_lookup",
                Agac: true, Baslik: "Klinik / Servis", Grup: "Genel"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Sorumlu Hekim", Grup: "Genel"),
            // YATAK BİR KAYNAKTIR: seçim burada yapılır ama doluluk yatağın
            //   kendi durumudur - aynı yatağa ikinci aktif yatış veritabanında
            //   da engellenir (ux_yatis_yatak_aktif).
            new("yatakId", "yatak_id", "kod", KodTablosu: "public.v_yatak_lookup",
                Baslik: "Yatak", Grup: "Genel"),
            new("durum", "durum", "kod", KodListesi: "yatan.yatis_durum",
                Baslik: "Durum", Grup: "Genel"),

            new("yatisTuru", "yatis_turu", "kod", KodListesi: "yatan.yatis_tur",
                Baslik: "Yatış Türü", Grup: "Yatış"),
            new("gelisSekli", "gelis_sekli", "kod", KodListesi: "yatan.gelis_sekli",
                Baslik: "Geliş Şekli", Grup: "Yatış"),
            new("girisTarihi", "giris_tarihi", "zaman", Baslik: "Giriş", Grup: "Yatış"),
            new("yatisTaniKodu", "yatis_tani_kodu", "metin", EnFazlaUzunluk: 10,
                Baslik: "Yatış Tanısı (ICD)", Grup: "Yatış"),
            // TAHMİNİ ÇIKIŞ yatak planlamasının girdisidir: panodaki "bugün
            //   boşalacak" sayısı buradan gelir. Boş bırakılırsa yatak, hasta
            //   çıkana kadar dolu sayılır ve kabul boşuna yer arar.
            new("tahminiCikis", "tahmini_cikis", "tarih",
                Baslik: "Tahmini Çıkış", Grup: "Yatış"),
            new("belgeId", "belge_id", "sayi", Yazilabilir: false,
                Baslik: "Başvuru", Grup: "Yatış"),

            new("odeyenKurumId", "odeyen_kurum_id", "kod", KodTablosu: "public.v_kurum_lookup",
                Baslik: "Ödeyen Kurum", Grup: "Ödeyen & Refakat"),
            // PROVİZYON YATIŞI KİLİTLEMEZ: acil vakada hastayı kapıda
            //   bekletmek, mali riskten büyük bir risktir. Eksik provizyon
            //   listede rozetle taşınır ve fatura kapanmadan çözülür.
            new("provizyonNo", "provizyon_no", "metin", EnFazlaUzunluk: 40,
                Baslik: "Provizyon / Takip No", Grup: "Ödeyen & Refakat"),
            new("provizyonTarihi", "provizyon_tarihi", "zaman",
                Baslik: "Provizyon Tarihi", Grup: "Ödeyen & Refakat"),
            // Refakatçi "var/yok" kutusu değil KİŞİ kaydı: gece kalan kişinin
            //   kim olduğu hastane güvenliğinin de sorusudur ve ücret doğurur.
            new("refakatciAd", "refakatci_ad", "metin", EnFazlaUzunluk: 120,
                Baslik: "Refakatçi", Grup: "Ödeyen & Refakat"),
            new("refakatciTckn", "refakatci_tckn", "metin", EnFazlaUzunluk: 11,
                Baslik: "Refakatçi TCKN", Grup: "Ödeyen & Refakat",
                Dogrulama: KimlikDogrulama.TcknTuru),

            new("cikisTarihi", "cikis_tarihi", "zaman", Baslik: "Çıkış", Grup: "Çıkış"),
            // ÇIKIŞ ŞEKLİ KODLUDUR: "taburcu" yazan tek alan ölüm vakasını da
            //   taburcu gösterirdi; e-Nabız, Medula ve kurum istatistiği bu
            //   ayrımı ister.
            new("cikisSekli", "cikis_sekli", "kod", KodListesi: "yatan.cikis_sekli",
                Baslik: "Çıkış Şekli", Grup: "Çıkış"),
            new("cikisTaniKodu", "cikis_tani_kodu", "metin", EnFazlaUzunluk: 10,
                Baslik: "Çıkış Tanısı (ICD)", Grup: "Çıkış"),
            new("enabizYatis", "enabiz_yatis", "mantik", Yazilabilir: false,
                Baslik: "e-Nabız yatış bildirimi", Grup: "Çıkış"),
            new("enabizTaburcu", "enabiz_taburcu", "mantik", Yazilabilir: false,
                Baslik: "e-Nabız taburcu bildirimi", Grup: "Çıkış"),
        },
        Detaylar: new DetayTanimi[]
        {
            // ORDER: bütün türler tek listede - hekim vizitte tek yere bakar.
            //   İlaçlar eczanede, tetkikler labda, diyet mutfakta ayrı ayrı
            //   dursaydı "bu hastaya ne söylenmiş" sorusunun tek cevabı olmazdı.
            new("orderlar", "public.yatis_order", "yatis_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tur", "tur", "kod", Zorunlu: true, KodListesi: "yatan.order_tur",
                    Baslik: "Tür"),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Order"),
                new("doz", "doz", "ondalik", Baslik: "Doz"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                new("yol", "yol", "kod", KodListesi: "yatan.order_yol", Baslik: "Yol"),
                new("siklik", "siklik", "metin", EnFazlaUzunluk: 40, Baslik: "Sıklık"),
                new("baslangic", "baslangic", "zaman", Baslik: "Başlangıç"),
                // BİTİŞİ OLMAYAN ORDER YOK: süresiz talimat unutulur ve
                //   antibiyotik on günü geçer.
                new("bitis", "bitis", "zaman", Baslik: "Bitiş"),
                new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                    Baslik: "Hekim"),
                new("sozelOrder", "sozel_order", "mantik", Baslik: "Sözel order"),
                new("onayTarihi", "onay_tarihi", "zaman", Yazilabilir: false, Baslik: "İmza"),
                new("durum", "durum", "kod", KodListesi: "yatan.order_durum", Baslik: "Durum"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama"),
            }, SubeKolonu: "sube_id", Sirala: "durum, baslangic desc",
               LogTabloId: LogYatisOrder, Baslik: "Order"),

            // VİTAL: yatan hastada tek ölçüm değil EĞRİDİR - satırlar zaman
            //   sırasında durur ve erken uyarı skoru satırda hesaplanır.
            new("izlem", "public.yatis_izlem", "yatis_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("sistolik", "sistolik", "sayi", Baslik: "Sistolik"),
                new("diyastolik", "diyastolik", "sayi", Baslik: "Diyastolik"),
                new("nabiz", "nabiz", "sayi", Baslik: "Nabız"),
                new("ates", "ates", "ondalik", Baslik: "Ateş °C"),
                new("spo2", "spo2", "sayi", Baslik: "SpO₂ %"),
                new("solunum", "solunum", "sayi", Baslik: "Solunum"),
                new("agriVas", "agri_vas", "sayi", Baslik: "Ağrı (0-10)"),
                new("gks", "gks", "sayi", Baslik: "GKS"),
                new("erkenUyari", "erken_uyari", "sayi", Baslik: "Erken Uyarı"),
                new("notMetin", "not_metin", "metin", EnFazlaUzunluk: 600, Baslik: "Gözlem"),
            }, SubeKolonu: null, Sirala: "zaman desc", LogTabloId: LogYatisDetay,
               Baslik: "İzlem"),

            // SIVI DENGESİ HESAPLIDIR: hemşire toplamı elle yazsaydı, gün
            //   ortasında eklenen bir serum toplamı sessizce bozardı.
            new("sivi", "public.yatis_sivi", "yatis_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("yon", "yon", "kod", Zorunlu: true, SabitKodlar: YatanSiviYonu, Baslik: "Yön"),
                new("tur", "tur", "kod", Zorunlu: true, KodListesi: "yatan.sivi_tur", Baslik: "Tür"),
                new("miktarMl", "miktar_ml", "ondalik", Baslik: "Miktar (mL)"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 120, Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "zaman desc", LogTabloId: LogYatisDetay,
               Baslik: "Sıvı Takibi"),

            new("risk", "public.yatis_risk", "yatis_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("olcek", "olcek", "kod", Zorunlu: true, KodListesi: "yatan.risk_olcek",
                    Baslik: "Ölçek"),
                new("puan", "puan", "sayi", Baslik: "Puan"),
                new("riskDuzeyi", "risk_duzeyi", "kod", KodListesi: "yatan.risk_duzey",
                    Baslik: "Risk"),
                // ÖNLEM DE SATIRDA: "yüksek risk" yazıp önlem yazmamak
                //   denetimde de klinikte de boş bir kayıttır.
                new("onlem", "onlem", "metin", EnFazlaUzunluk: 400, Baslik: "Alınan Önlem"),
            }, SubeKolonu: null, Sirala: "zaman desc", LogTabloId: LogYatisDetay,
               Baslik: "Risk Ölçekleri"),

            // YATAK HAREKETİ FATURANIN DAYANAĞI: iki gün yoğun bakım, iki gün
            //   çift kişilik, iki gün tek kişilik = üç ayrı ücret.
            new("yatakHareketi", "public.yatis_yatak", "yatis_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("yatakId", "yatak_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_yatak_lookup", Baslik: "Yatak"),
                new("baslangic", "baslangic", "zaman", Baslik: "Başlangıç"),
                new("bitis", "bitis", "zaman", Baslik: "Bitiş"),
                new("neden", "neden", "kod", KodListesi: "yatan.nakil_neden", Baslik: "Neden"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "baslangic desc", LogTabloId: LogYatisDetay,
               Baslik: "Yatak Hareketleri"),

            // EPİKRİZ YATIŞ BOYUNCA BİRİKİR, çıkış saatinde sıfırdan yazılmaz:
            //   altı günlük seyri son anda hatırlamak, epikrizi "yatırıldı,
            //   tedavi edildi, taburcu edildi" cümlesine indirger.
            new("epikriz", "public.epikriz", "yatis_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sikayet", "sikayet", "metin", EnFazlaUzunluk: 2000, Baslik: "Şikâyet"),
                new("hikaye", "hikaye", "metin", EnFazlaUzunluk: 2000, Baslik: "Hikâye"),
                new("bulgular", "bulgular", "metin", EnFazlaUzunluk: 2000, Baslik: "Bulgular"),
                new("tetkikOzet", "tetkik_ozet", "metin", EnFazlaUzunluk: 2000,
                    Baslik: "Tetkik Özeti (derlenmiş)"),
                new("tedavi", "tedavi", "metin", EnFazlaUzunluk: 2000, Baslik: "Tedavi"),
                new("seyir", "seyir", "metin", EnFazlaUzunluk: 2000, Baslik: "Klinik Seyir"),
                new("oneriler", "oneriler", "metin", EnFazlaUzunluk: 2000, Baslik: "Öneriler"),
                new("kontrolTarihi", "kontrol_tarihi", "tarih", Baslik: "Kontrol Tarihi"),
                new("kontrolBolumId", "kontrol_bolum_id", "kod",
                    KodTablosu: "public.v_departman_lookup", Baslik: "Kontrol Bölümü"),
                new("imzaDurum", "imza_durum", "mantik", Baslik: "İmzalandı"),
            }, SubeKolonu: "sube_id", LogTabloId: LogYatisDetay, Baslik: "Epikriz",
               TekSatir: true),
        });

    // ================================================================ yatak ==
    private static KartTanimi YatakKarti() => new(
        Ad: "yatak",
        YetkiKodu: "yatan.yatak",
        Tablo: "public.yatak",
        LogTabloId: LogYatak,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1,
            ["durum"] = (short)1,   // Boş
            ["tip"] = (short)1,     // Standart
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("odaId", "oda_id", "kod", Zorunlu: true, KodTablosu: "public.v_oda_lookup",
                Baslik: "Oda", Grup: "Genel"),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Yatak Kodu", Grup: "Genel"),
            new("tip", "tip", "kod", KodListesi: "yatan.yatak_tip", Baslik: "Tip", Grup: "Genel"),
            // DURUM YATAĞIN KENDİ HÂLİ: temizlik ayrı bir durumdur - taburcu
            //   olan yatak anında "boş" sayılsaydı, kabul hastayı yapılmamış
            //   yatağa gönderirdi.
            new("durum", "durum", "kod", KodListesi: "yatan.yatak_durum",
                Baslik: "Durum", Grup: "Genel"),
            new("durumNotu", "durum_notu", "metin", EnFazlaUzunluk: 200,
                Baslik: "Durum Notu (arıza / kapatma sebebi)", Grup: "Genel"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Genel"),
        });

    // ================================================================== oda ==
    private static KartTanimi OdaKarti() => new(
        Ad: "oda",
        YetkiKodu: "yatan.yatak",
        Tablo: "public.oda",
        LogTabloId: LogOda,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1,
            ["tur"] = (short)2,              // Çift kişilik
            ["refakatciAlir"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Oda Kodu", Grup: "Genel"),
            new("ad", "ad", "metin", EnFazlaUzunluk: 80, Baslik: "Adı", Grup: "Genel"),
            new("departmanId", "departman_id", "kod",
                KodTablosu: "public.v_departman_agac_lookup",
                Agac: true, Baslik: "Servis / Klinik", Grup: "Genel"),
            new("bina", "bina", "metin", EnFazlaUzunluk: 40, Baslik: "Bina", Grup: "Genel"),
            new("kat", "kat", "metin", EnFazlaUzunluk: 20, Baslik: "Kat", Grup: "Genel"),
            new("tur", "tur", "kod", KodListesi: "yatan.oda_tur", Baslik: "Oda Türü", Grup: "Genel"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Genel"),

            // KURAL ODANIN: boş yatağın VERİLEBİLİR olup olmadığını oda
            //   belirler - kadın odasındaki boş yatak, erkek hasta için boş
            //   değildir.
            new("cinsiyetKurali", "cinsiyet_kurali", "kod", KodListesi: "yatan.cinsiyet_kural",
                Baslik: "Cinsiyet Kuralı", Grup: "Kurallar & Ücret"),
            new("izolasyon", "izolasyon", "kod", KodListesi: "yatan.izolasyon",
                Baslik: "İzolasyon", Grup: "Kurallar & Ücret"),
            new("refakatciAlir", "refakatci_alir", "mantik",
                Baslik: "Refakatçi kalabilir", Grup: "Kurallar & Ücret"),
            // Yatak ücreti ODANIN türünden gelir: fiyat hizmet kartında durur,
            //   burada yalnız hangi hizmet olduğu seçilir.
            new("ucretHizmetId", "ucret_hizmet_id", "kod", AramaKaynagi: "hizmet",
                KodTablosu: "public.v_hizmet_lookup",
                Baslik: "Yatak Ücreti (hizmet)", Grup: "Kurallar & Ücret"),
        });

    // ============================================================== order ==
    /// <summary>
    /// ORDER KARTI — tek talimatın tamamı + planlanan dozları.
    ///
    /// <para>Uygulama satırları DETAYDIR ve order kaydedilirken üretilir: plan
    /// görünmeden takip olmaz, sonradan üretilen satır da atlanmış dozu
    /// gizler.</para>
    /// </summary>
    private static KartTanimi YatisOrderKarti() => new(
        Ad: "yatis-order",
        YetkiKodu: "yatan.order",
        Tablo: "public.yatis_order",
        LogTabloId: LogYatisOrder,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["tur"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("yatisId", "yatis_id", "sayi", Zorunlu: true, Baslik: "Yatış", Grup: "Order"),
            new("tur", "tur", "kod", Zorunlu: true, KodListesi: "yatan.order_tur",
                Baslik: "Tür", Grup: "Order"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Order", Grup: "Order"),
            new("doz", "doz", "ondalik", Baslik: "Doz", Grup: "Order"),
            new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim", Grup: "Order"),
            new("yol", "yol", "kod", KodListesi: "yatan.order_yol", Baslik: "Yol", Grup: "Order"),
            new("siklik", "siklik", "metin", EnFazlaUzunluk: 40, Baslik: "Sıklık", Grup: "Order"),
            // Uygulama satırları BU SAATLERDEN üretilir.
            new("saatler", "saatler", "json", EnFazlaUzunluk: 600,
                Baslik: "Saatler (JSON)", Grup: "Order"),

            new("baslangic", "baslangic", "zaman", Baslik: "Başlangıç", Grup: "Süre & İmza"),
            new("bitis", "bitis", "zaman", Baslik: "Bitiş", Grup: "Süre & İmza"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Hekim", Grup: "Süre & İmza"),
            // SÖZEL ORDER uygulanır ama imzasız kalmaz.
            new("sozelOrder", "sozel_order", "mantik", Baslik: "Sözel order", Grup: "Süre & İmza"),
            new("onayHekimId", "onay_hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "İmzalayan", Grup: "Süre & İmza"),
            new("onayTarihi", "onay_tarihi", "zaman", Baslik: "İmza Zamanı", Grup: "Süre & İmza"),
            new("durum", "durum", "kod", KodListesi: "yatan.order_durum",
                Baslik: "Durum", Grup: "Süre & İmza"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400,
                Baslik: "Açıklama", Grup: "Süre & İmza"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("dozlar", "public.order_uygulama", "order_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("planlanan", "planlanan", "zaman", Zorunlu: true, Baslik: "Planlanan"),
                new("uygulanan", "uygulanan", "zaman", Baslik: "Uygulanan"),
                new("uygulayanId", "uygulayan_id", "kod", KodTablosu: "public.v_personel_lookup",
                    Baslik: "Uygulayan"),
                new("durum", "durum", "kod", KodListesi: "yatan.uygulama_durum", Baslik: "Durum"),
                // ATLANAN DOZ SEBEPSİZ OLMAZ.
                new("atlamaNedeni", "atlama_nedeni", "metin", EnFazlaUzunluk: 200,
                    Baslik: "Atlama Nedeni"),
                new("gecikmeNedeni", "gecikme_nedeni", "metin", EnFazlaUzunluk: 200,
                    Baslik: "Gecikme Nedeni"),
                new("miktar", "miktar", "ondalik", Baslik: "Miktar"),
                new("barkod", "barkod", "metin", EnFazlaUzunluk: 60, Baslik: "Karekod"),
                new("elleDogrulandi", "elle_dogrulandi", "mantik", Baslik: "Elle doğrulandı"),
            }, SubeKolonu: null, Sirala: "planlanan", LogTabloId: LogYatisOrder,
               Baslik: "Dozlar"),
        });
}
