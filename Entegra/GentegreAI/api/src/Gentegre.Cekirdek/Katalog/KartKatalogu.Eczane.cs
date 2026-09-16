namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ECZANE KARTLARI (722).
///
/// ORDER KARTI YOK: yatan hasta orderı kendi kartında (695) düzenlenir.
/// Buradaki `eczaneKontrol` kartı eczacının KARARINI taşır - order satırını
/// değiştirmez. Eczacı önerisi hekimi bağlamaz; karar hekimin, kayıt ikisinin.
///
/// KONTROLLÜ İLAÇ DEFTERİ SALT OKUNUR KART DEĞİL, hiç kart değil: satır
/// silinemez (722 tetiği) ve düzeltme ayrı satırla yapılır. Generic kartın
/// "düzenle/sil" modeli bu tabloya uymaz - defter yalnız listede okunur,
/// yazma işi kendi ucundan geçer.
/// </summary>
public static partial class KartKatalogu
{
    // ------------------------------------------------- eczacı kontrolü ----
    private static KartTanimi EczaneKontrol() => new(
        Ad: "eczaneKontrol",
        YetkiKodu: "eczane.order",
        Tablo: "public.eczane_kontrol",
        LogTabloId: 1200,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            // YAZILABİLİR ama sonradan DEĞİŞTİRİLMEMELİ: uyarı hangi order
            //   satırı için verildiyse ona bağlıdır. Çerçevede "bir kez
            //   yazılır" diye bir kip yok; salt okunur yapsaydık zorunlu ama
            //   asla doldurulamayan bir alan olurdu - kart hiç kaydedilemezdi.
            new("orderId", "order_id", "sayi", Zorunlu: true,
                Baslik: "Order Satırı", Grup: "Uyarı"),
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "Uyarı Türü", Grup: "Uyarı",
                SabitKodlar: KaynakKatalogu.EcKontrolTurKodlari),
            new("duzey", "duzey", "kod", Zorunlu: true, Baslik: "Düzey", Grup: "Uyarı",
                SabitKodlar: KaynakKatalogu.EcDuzeyKodlari),
            new("bulgu", "bulgu", "metin", Zorunlu: true, Baslik: "Bulgu", Grup: "Uyarı",
                EnFazlaUzunluk: 400),
            // DAYANAK ZORUNLU DEĞİL ama boş bırakılırsa uyarı "birisi öyle
            //   dedi"ye döner: hangi kayıt tetikledi yazılmalı.
            new("kaynak", "kaynak", "metin", Baslik: "Dayanak", Grup: "Uyarı",
                EnFazlaUzunluk: 200),

            new("karar", "karar", "kod", Baslik: "Eczacı Kararı", Grup: "Karar",
                SabitKodlar: KaynakKatalogu.EcKararKodlari),
            new("oneri", "oneri", "metin", Baslik: "Öneri", Grup: "Karar",
                EnFazlaUzunluk: 400),
            new("eczaciId", "eczaci_id", "sayi", Baslik: "Eczacı", Grup: "Karar",
                KodTablosu: "public.v_personel_lookup"),
            new("kararZamani", "karar_zamani", "zaman", Baslik: "Karar Saati", Grup: "Karar"),
            // ÖNLENEN HATA kalite göstergesidir: sayısı raporlanır, kişiye
            //   yazılan bir suç değil.
            new("onlenenHata", "onlenen_hata", "mantik", Baslik: "Önlenen İlaç Hatası",
                Grup: "Karar"),

            new("hekimId", "hekim_id", "sayi", Baslik: "Bildirilen Hekim", Grup: "Hekim",
                KodTablosu: "public.v_hekim_lookup"),
            new("bildirimZamani", "bildirim_zamani", "zaman", Baslik: "Bildirim",
                Grup: "Hekim"),
            new("okunduZamani", "okundu_zamani", "zaman", Baslik: "Okundu", Grup: "Hekim"),
            new("hekimYaniti", "hekim_yaniti", "metin", Baslik: "Hekim Yanıtı",
                Grup: "Hekim", EnFazlaUzunluk: 400),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = 99, ["duzey"] = 2, ["karar"] = 0, ["onlenenHata"] = 0,
        });

    // ---------------------------------------------------- hazırlama ----
    private static KartTanimi EczaneHazirlama() => new(
        Ad: "eczaneHazirlama",
        YetkiKodu: "eczane.hazirlama",
        Tablo: "public.eczane_hazirlama",
        LogTabloId: 1201,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("hazirlamaNo", "hazirlama_no", "metin", Yazilabilir: false,
                Baslik: "Hazırlama No", Grup: "Hazırlama"),
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "Tür", Grup: "Hazırlama",
                SabitKodlar: KaynakKatalogu.EcHazirlamaTurKodlari),
            new("hastaId", "hasta_id", "sayi", Zorunlu: true, Baslik: "Hasta",
                Grup: "Hazırlama", AramaKaynagi: "hasta",
                KodTablosu: "public.v_hasta_lookup"),
            new("yatisId", "yatis_id", "sayi", Baslik: "Yatış", Grup: "Hazırlama"),
            new("protokol", "protokol", "metin", Baslik: "Protokol", Grup: "Hazırlama",
                EnFazlaUzunluk: 200),
            new("kurNo", "kur_no", "sayi", Baslik: "Kür No", Grup: "Hazırlama"),
            new("kurToplam", "kur_toplam", "sayi", Baslik: "Toplam Kür", Grup: "Hazırlama"),
            new("planlanan", "planlanan", "zaman", Baslik: "Planlanan", Grup: "Hazırlama"),

            // DOZ HESABININ GİRDİLERİ: boy/kilo kürler arasında değişir, doz
            //   onunla değişir. Sonradan "bu doz nasıl çıktı" sorusu ancak
            //   girdilerle yanıtlanır.
            new("boyCm", "boy_cm", "ondalik", Baslik: "Boy (cm)", Grup: "Doz Girdileri"),
            new("kiloKg", "kilo_kg", "ondalik", Baslik: "Kilo (kg)", Grup: "Doz Girdileri"),
            new("vyaM2", "vya_m2", "ondalik", Baslik: "VYA (m²)", Grup: "Doz Girdileri"),
            new("krkl", "krkl", "ondalik", Baslik: "KrKl (mL/dk)", Grup: "Doz Girdileri"),

            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Akış",
                SabitKodlar: KaynakKatalogu.EcHazirlamaDurumKodlari),
            // HASTA GELMEDEN HAZIRLANMAZ: hazırlanıp iptal edilen kemoterapi
            //   çöpe gider - damgası kartta durur.
            new("hastaGeldiZamani", "hasta_geldi_zamani", "zaman",
                Baslik: "Hasta Geldi", Grup: "Akış"),
            new("hazirlayanId", "hazirlayan_id", "sayi", Baslik: "Hazırlayan", Grup: "Akış",
                KodTablosu: "public.v_personel_lookup"),
            new("hazirlamaZamani", "hazirlama_zamani", "zaman", Baslik: "Hazırlama",
                Grup: "Akış"),
            // İKİNCİ ECZACI: kemoterapide yanlış doz geri alınamaz.
            new("dogrulayanId", "dogrulayan_id", "sayi", Baslik: "Doğrulayan (2. eczacı)",
                Grup: "Akış", KodTablosu: "public.v_personel_lookup"),
            new("dogrulamaZamani", "dogrulama_zamani", "zaman", Baslik: "Doğrulama",
                Grup: "Akış"),
            new("kabinKod", "kabin_kod", "metin", Baslik: "Kabin", Grup: "Akış",
                EnFazlaUzunluk: 30),
            // SON KULLANIM HAZIRLAMA ANINDAN sayılır, kutu miadından değil.
            new("sonKullanim", "son_kullanim", "zaman", Baslik: "Son Kullanım", Grup: "Akış"),
            new("saklama", "saklama", "metin", Baslik: "Saklama Koşulu", Grup: "Akış",
                EnFazlaUzunluk: 80),
            new("teslimZamani", "teslim_zamani", "zaman", Baslik: "Teslim", Grup: "Akış"),
            new("teslimAlanId", "teslim_alan_id", "sayi", Baslik: "Teslim Alan", Grup: "Akış",
                KodTablosu: "public.v_personel_lookup"),
            new("iptalNeden", "iptal_neden", "metin", Baslik: "İptal Nedeni", Grup: "Akış",
                EnFazlaUzunluk: 200),
        },
        Detaylar: new DetayTanimi[]
        {
            new("kalemler", "public.eczane_hazirlama_kalem", "hazirlama_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("tur", "tur", "kod", Baslik: "Tür", SabitKodlar: EcKartKalemTurKodlari),
                new("ad", "ad", "metin", Baslik: "İlaç", EnFazlaUzunluk: 200),
                new("stokId", "stok_id", "sayi", Baslik: "Stok",
                    AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
                new("protokolDoz", "protokol_doz", "metin", Baslik: "Protokol Dozu",
                    EnFazlaUzunluk: 40),
                // HESAPLANAN ve UYGULANAN ayrı: yuvarlama flakon büyüklüğüne
                //   göre yapılır, "neden 870 değil 875" sorusu buradan yanıtlanır.
                new("hesaplanan", "hesaplanan", "ondalik", Baslik: "Hesaplanan"),
                new("uygulananDoz", "uygulanan_doz", "ondalik", Baslik: "Uygulanan"),
                new("birim", "birim", "metin", Baslik: "Birim", EnFazlaUzunluk: 20),
                new("sulandirici", "sulandirici", "metin", Baslik: "Sulandırıcı",
                    EnFazlaUzunluk: 80),
                new("sonHacimMl", "son_hacim_ml", "ondalik", Baslik: "Son Hacim (mL)"),
                new("sureDk", "sure_dk", "sayi", Baslik: "Süre (dk)"),
                new("kumulatif", "kumulatif", "ondalik", Baslik: "Kümülatif"),
                new("kumulatifSinir", "kumulatif_sinir", "ondalik", Baslik: "Kümülatif Sınır"),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "sira, id", Baslik: "Kalemler", SubeKolonu: null, LogTabloId: 1202),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = 1, ["durum"] = 0,
        });

    // --------------------------------------------------------- iade ----
    private static KartTanimi EczaneIade() => new(
        Ad: "eczaneIade",
        YetkiKodu: "eczane.iade",
        Tablo: "public.eczane_iade",
        LogTabloId: 1203,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("departmanId", "departman_id", "sayi", Baslik: "İade Eden Servis",
                Grup: "İade", KodTablosu: "public.v_departman_lookup"),
            new("stokId", "stok_id", "sayi", Baslik: "İlaç", Grup: "İade",
                AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
            new("ad", "ad", "metin", Baslik: "Ad", Grup: "İade", EnFazlaUzunluk: 200),
            new("miktar", "miktar", "ondalik", Zorunlu: true, Baslik: "Miktar", Grup: "İade"),
            new("seriLotId", "seri_lot_id", "sayi", Baslik: "Lot", Grup: "İade"),
            new("iadeNeden", "iade_neden", "metin", Zorunlu: true, Baslik: "İade Nedeni",
                Grup: "İade", EnFazlaUzunluk: 300),

            // ÜÇ SORU: üçü de "hayır" ise stoğa döner. Kararı eczacı verir ama
            //   ölçütler kayda geçer - "neden imha edildi" sonradan sorulur.
            new("ambalajAcik", "ambalaj_acik", "mantik", Baslik: "Ambalaj açıldı",
                Grup: "Değerlendirme"),
            new("sulandirildi", "sulandirildi", "mantik", Baslik: "Sulandırıldı",
                Grup: "Değerlendirme"),
            new("sogukZincirBozuk", "soguk_zincir_bozuk", "mantik",
                Baslik: "Soğuk zincir bozuldu", Grup: "Değerlendirme"),

            new("karar", "karar", "kod", Baslik: "Karar", Grup: "Karar",
                SabitKodlar: KaynakKatalogu.EcIadeKararKodlari),
            new("kararVerenId", "karar_veren_id", "sayi", Baslik: "Karar Veren",
                Grup: "Karar", KodTablosu: "public.v_personel_lookup"),
            new("kararZamani", "karar_zamani", "zaman", Baslik: "Karar Saati", Grup: "Karar"),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["karar"] = 0, ["ambalajAcik"] = 0, ["sulandirildi"] = 0,
            ["sogukZincirBozuk"] = 0,
        });

    // --------------------------------------------------------- imha ----
    private static KartTanimi EczaneImha() => new(
        Ad: "eczaneImha",
        YetkiKodu: "eczane.imha",
        Tablo: "public.eczane_imha",
        LogTabloId: 1204,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("tutanakNo", "tutanak_no", "metin", Yazilabilir: false,
                Baslik: "Tutanak No", Grup: "Tutanak"),
            new("tarih", "tarih", "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Tutanak"),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Tutanak",
                SabitKodlar: KaynakKatalogu.EcImhaDurumKodlari),
            // KOMİSYON: imha tek kişinin işi değil.
            new("komisyon", "komisyon", "metin", Baslik: "Komisyon Üyeleri", Grup: "Tutanak",
                EnFazlaUzunluk: 300),
            new("atikTeslimNo", "atik_teslim_no", "metin", Baslik: "Atık Teslim No",
                Grup: "Tutanak", EnFazlaUzunluk: 60),
            // İMHA STOK DÜŞÜMÜ DEĞİLDİR: çıkış fişi ayrı belgedir, bağı burada.
            new("belgeId", "belge_id", "sayi", Yazilabilir: false, Baslik: "Çıkış Fişi",
                Grup: "Tutanak"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Tutanak"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("satirlar", "public.eczane_imha_satir", "imha_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "sayi", Baslik: "İlaç",
                    AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
                new("ad", "ad", "metin", Baslik: "Ad", EnFazlaUzunluk: 200),
                new("seriLotId", "seri_lot_id", "sayi", Baslik: "Lot"),
                new("miktar", "miktar", "ondalik", Zorunlu: true, Baslik: "Miktar"),
                new("tutar", "tutar", "para", Baslik: "Değer"),
                new("neden", "neden", "kod", Zorunlu: true, Baslik: "İmha Nedeni",
                    SabitKodlar: EcKartImhaNedenKodlari),
                // SİTOTOKSİK ATIK tıbbi atıktan AYRI toplanır - kap ve taşıma farklı.
                new("atikSinifi", "atik_sinifi", "kod", Zorunlu: true, Baslik: "Atık Sınıfı",
                    SabitKodlar: EcKartAtikKodlari),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "id", Baslik: "İmha Edilenler", SubeKolonu: null, LogTabloId: 1205),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0,
        });

    // ---------------------------------------------------- ünite doz ----
    // DOZ KARTI DÜZELTME İÇİNDİR, üretim için değil: dozlar order
    //   uygulamasından toplu üretilir. Barkod okunmayan, elle kapatılan ya da
    //   yanlış lot yazılan tek satırı burada düzeltiriz - toplu üretimi kartla
    //   yapmak günde yüzlerce satır demek olurdu.
    private static KartTanimi EczaneDoz() => new(
        Ad: "eczaneDoz",
        YetkiKodu: "eczane.doz",
        Tablo: "public.eczane_doz",
        LogTabloId: 1206,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            // Bkz. eczaneKontrol.orderId - zorunlu + salt okunur bir alan,
            //   hiç kaydedilemeyen bir kart demektir.
            new("uygulamaId", "uygulama_id", "sayi", Zorunlu: true,
                Baslik: "Order Uygulaması", Grup: "Doz"),
            new("dozBarkod", "doz_barkod", "metin", Baslik: "Doz Barkodu", Grup: "Doz",
                EnFazlaUzunluk: 40),
            new("stokId", "stok_id", "sayi", Baslik: "İlaç", Grup: "Doz",
                AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
            new("seriLotId", "seri_lot_id", "sayi", Baslik: "Lot", Grup: "Doz"),
            new("miktar", "miktar", "ondalik", Zorunlu: true, Baslik: "Miktar", Grup: "Doz"),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Doz",
                SabitKodlar: KaynakKatalogu.EcDozDurumKodlari),

            new("hazirlayanId", "hazirlayan_id", "sayi", Baslik: "Hazırlayan", Grup: "İzlem",
                KodTablosu: "public.v_personel_lookup"),
            new("hazirlamaZamani", "hazirlama_zamani", "zaman", Baslik: "Hazırlama",
                Grup: "İzlem"),
            // KONTROL EDEN ayrı kişi olmalı - ünite doz sisteminin tek koruması bu.
            new("kontrolEdenId", "kontrol_eden_id", "sayi", Baslik: "Kontrol Eden",
                Grup: "İzlem", KodTablosu: "public.v_personel_lookup"),
            new("kontrolZamani", "kontrol_zamani", "zaman", Baslik: "Kontrol", Grup: "İzlem"),
            new("teslimZamani", "teslim_zamani", "zaman", Baslik: "Teslim", Grup: "İzlem"),
            new("teslimAlanId", "teslim_alan_id", "sayi", Baslik: "Teslim Alan", Grup: "İzlem",
                KodTablosu: "public.v_personel_lookup"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "İzlem",
                EnFazlaUzunluk: 300),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0,
        });

    // ----------------------------------------- kontrollü ilaç sayımı ----
    // SAYIM KARTI VAR, DEFTER KARTI YOK: defter satırı silinemez (722 tetiği)
    //   ve düzeltme ayrı satırla yapılır - generic kartın "düzenle/sil" modeli
    //   oraya uymaz. Sayım ise bir tutanak: iki kişi sayar, uyum tetikle
    //   hesaplanır (`uyumlu` yazılamaz), fark DÜZELTİLMEZ - açıklanır.
    private static KartTanimi KontrolluSayim() => new(
        Ad: "kontrolluSayim",
        YetkiKodu: "eczane.kontrollu",
        Tablo: "public.kontrollu_sayim",
        LogTabloId: 1207,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("tarih", "tarih", "tarih", Zorunlu: true, Baslik: "Sayım Tarihi",
                Grup: "Sayım"),
            // İKİ SAYICI: birbirini görmeden sayar. Aynı kişi seçilirse sayım
            //   çift kontrol olmaktan çıkar - ekran uyarır, kural insandadır.
            new("sayan1Id", "sayan1_id", "sayi", Zorunlu: true, Baslik: "1. Sayan",
                Grup: "Sayım", KodTablosu: "public.v_personel_lookup"),
            new("sayan2Id", "sayan2_id", "sayi", Zorunlu: true, Baslik: "2. Sayan",
                Grup: "Sayım", KodTablosu: "public.v_personel_lookup"),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Sayım",
                SabitKodlar: EcKartSayimDurumKodlari),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Sayım",
                EnFazlaUzunluk: 400),
        },
        Detaylar: new DetayTanimi[]
        {
            new("satirlar", "public.kontrollu_sayim_satir", "sayim_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "sayi", Baslik: "İlaç",
                    AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
                new("ad", "ad", "metin", Baslik: "Ad", EnFazlaUzunluk: 200),
                new("defter", "defter", "ondalik", Baslik: "Defter"),
                new("sayan1", "sayan1", "ondalik", Baslik: "1. Sayım"),
                new("sayan2", "sayan2", "ondalik", Baslik: "2. Sayım"),
                // UYUM TETİKLE HESAPLANIR (722): elle "uyumlu" işaretlemek,
                //   sayımın kendisini geçersiz kılardı.
                new("uyumlu", "uyumlu", "mantik", Yazilabilir: false, Baslik: "Uyumlu"),
                new("aciklama", "aciklama", "metin", Baslik: "Fark Açıklaması",
                    EnFazlaUzunluk: 300),
            }, Sirala: "id", Baslik: "Sayım Satırları", SubeKolonu: null, LogTabloId: 1208),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0,
        });


    private static readonly Dictionary<string, string> EcKartSayimDurumKodlari = new()
    {
        ["0"] = "Açık", ["1"] = "Uyumlu kapandı", ["2"] = "Farklı (tutanak açıldı)",
    };






    private static readonly Dictionary<string, string> EcKartKalemTurKodlari = new()
    {
        ["1"] = "Ana ilaç", ["2"] = "Premedikasyon", ["3"] = "Sulandırıcı",
        ["4"] = "Elektrolit / katkı",
    };



    private static readonly Dictionary<string, string> EcKartImhaNedenKodlari = new()
    {
        ["1"] = "Miadı geçti", ["2"] = "Hasar / kırık", ["3"] = "Soğuk zincir",
        ["4"] = "Hazırlanmış, kullanılmadı", ["5"] = "Geri çağırma", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> EcKartAtikKodlari = new()
    {
        ["1"] = "Tıbbi atık", ["2"] = "Sitotoksik atık", ["3"] = "Tehlikeli atık",
    };
}
