namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AMELİYATHANE KARTLARI (715).
///
/// `ameliyat` kartı altı detay taşır: işlemler · ekip · güvenli cerrahi ·
/// sarf · sayım · komplikasyon, bir de 1:1 ameliyat notu.
///
/// SAYIM `uyumlu` ALANI YAZILAMAZ: veritabanı tetiği hesaplar
/// (fn_ameliyat_sayim_uyum). Elle yazılabilseydi "sayım tamam" işaretlenip
/// kapanış açılır, sayım uyuşmazlığının tek güvencesi kalkardı.
///
/// KONTROL LİSTESİ MADDE METNİ YAZILAMAZ: işaret satırına tanımdan kopyalanır.
/// Düzenlenebilseydi imzalanan madde ile saklanan metin ayrışırdı.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi Ameliyat() => new(
        Ad: "ameliyat",
        YetkiKodu: "ameliyathane.ameliyat",
        Tablo: "public.ameliyat",
        LogTabloId: 1150,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("ameliyatNo", "ameliyat_no", "metin", Yazilabilir: false,
                Baslik: "Ameliyat No", Grup: "Ameliyat"),
            new("hastaId", "hasta_id", "sayi", Zorunlu: true, Baslik: "Hasta",
                Grup: "Ameliyat", AramaKaynagi: "hasta", KodTablosu: "public.v_hasta_lookup"),
            new("salonId", "salon_id", "sayi", Baslik: "Salon", Grup: "Ameliyat",
                KodTablosu: "public.v_ameliyat_salon_lookup"),
            new("cerrahId", "cerrah_id", "sayi", Baslik: "Cerrah", Grup: "Ameliyat",
                KodTablosu: "public.v_hekim_lookup"),
            new("anesteziId", "anestezi_id", "sayi", Baslik: "Anestezi Uzmanı",
                Grup: "Ameliyat", KodTablosu: "public.v_hekim_lookup"),
            new("anesteziTipi", "anestezi_tipi", "kod", Baslik: "Anestezi Tipi",
                Grup: "Ameliyat", SabitKodlar: AmKartAnesteziKodlari),
            new("asaSkoru", "asa_skoru", "sayi", Baslik: "ASA Skoru", Grup: "Ameliyat"),
            new("mallampati", "mallampati", "sayi", Baslik: "Mallampati", Grup: "Ameliyat"),

            new("planBaslangic", "plan_baslangic", "zaman", Baslik: "Planlanan Başlangıç",
                Grup: "Plan"),
            new("planSureDk", "plan_sure_dk", "sayi", Baslik: "Planlanan Süre (dk)",
                Grup: "Plan"),
            new("planDisi", "plan_disi", "mantik", Baslik: "Plan Dışı (acil eklendi)",
                Grup: "Plan"),

            // ZAMAN DAMGALARI ayrı ayrı - masa süresi ile cerrahi süre farklı
            //   sorular (bkz 715 başlığı).
            new("salonaAlma", "salona_alma", "zaman", Baslik: "Salona Alındı", Grup: "Zaman"),
            new("anesteziBas", "anestezi_bas", "zaman", Baslik: "Anestezi Başlangıcı",
                Grup: "Zaman"),
            new("kesiZamani", "kesi_zamani", "zaman", Baslik: "Kesi (bıçak) Zamanı",
                Grup: "Zaman"),
            new("kapanisBas", "kapanis_bas", "zaman", Baslik: "Kapanış Başlangıcı",
                Grup: "Zaman"),
            new("bitisZamani", "bitis_zamani", "zaman", Baslik: "Ameliyat Bitişi",
                Grup: "Zaman"),
            new("salondanCikis", "salondan_cikis", "zaman", Baslik: "Salondan Çıkış",
                Grup: "Zaman"),

            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Durum",
                SabitKodlar: AmKartDurumKodlari),
            new("kanamaMl", "kanama_ml", "sayi", Baslik: "Kanama (mL)", Grup: "Durum"),
            new("gecikmeNeden", "gecikme_neden", "metin", Baslik: "Gecikme Nedeni",
                Grup: "Durum", EnFazlaUzunluk: 200),
            new("iptalNeden", "iptal_neden", "metin", Baslik: "İptal Nedeni",
                Grup: "Durum", EnFazlaUzunluk: 200),
        },
        Detaylar: new DetayTanimi[]
        {
            new("islemler", "public.ameliyat_islem", "ameliyat_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("hizmetId", "hizmet_id", "sayi", Zorunlu: true, Baslik: "İşlem",
                    AramaKaynagi: "hizmet", KodTablosu: "public.v_hizmet_lookup"),
                new("tur", "tur", "kod", Baslik: "Tür", SabitKodlar: AmKartIslemTurKodlari),
                // TARAF işlem satırında: iki taraflı ameliyatta hangi işlemin
                //   hangi tarafa yapıldığı başlıkta kaybolurdu.
                new("taraf", "taraf", "kod", Baslik: "Taraf", SabitKodlar: AmKartTarafKodlari),
                new("cerrahId", "cerrah_id", "sayi", Baslik: "Cerrah",
                    KodTablosu: "public.v_hekim_lookup"),
                new("aciklama", "aciklama", "metin", Baslik: "Açıklama", EnFazlaUzunluk: 300),
            }, Sirala: "sira, id", Baslik: "İşlemler", LogTabloId: 1151),

            new("ekip", "public.ameliyat_ekip", "ameliyat_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("personelId", "personel_id", "sayi", Zorunlu: true, Baslik: "Kişi",
                    KodTablosu: "public.v_personel_lookup"),
                new("rol", "rol", "kod", Zorunlu: true, Baslik: "Rol",
                    SabitKodlar: AmKartRolKodlari),
                new("giris", "giris", "zaman", Baslik: "Giriş"),
                new("cikis", "cikis", "zaman", Baslik: "Çıkış"),
                new("sorumlu", "sorumlu", "mantik", Baslik: "Sorumlu"),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 200),
            }, Sirala: "rol, id", Baslik: "Ekip", LogTabloId: 1152),

            new("kontrol", "public.ameliyat_kontrol", "ameliyat_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("asama", "asama", "kod", Yazilabilir: false, Baslik: "Aşama",
                    SabitKodlar: AmKartAsamaKodlari),
                new("sira", "sira", "sayi", Yazilabilir: false, Baslik: "Sıra"),
                // Metin TANIMDAN kopyalanır, düzenlenmez (bkz sınıf başlığı).
                new("maddeMetin", "madde_metin", "metin", Yazilabilir: false, Baslik: "Madde"),
                new("isaretli", "isaretli", "mantik", Baslik: "İşaretli"),
                new("isaretleyen", "isaretleyen", "sayi", Baslik: "İşaretleyen",
                    KodTablosu: "public.v_personel_lookup"),
                new("isaretZamani", "isaret_zamani", "zaman", Baslik: "Zaman"),
                new("notMetni", "not_metni", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "asama, sira", Baslik: "Güvenli Cerrahi", SaltOkunur: true,
               LogTabloId: 1153),

            new("sarf", "public.ameliyat_sarf", "ameliyat_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "sayi", Baslik: "Malzeme", KodTablosu: "public.v_stok_lookup"),
                new("barkod", "barkod", "metin", Baslik: "Barkod", EnFazlaUzunluk: 50),
                new("ad", "ad", "metin", Baslik: "Ad", EnFazlaUzunluk: 200),
                new("miktar", "miktar", "ondalik", Baslik: "Miktar"),
                new("lot", "lot", "metin", Baslik: "Lot", EnFazlaUzunluk: 50),
                new("seriNo", "seri_no", "metin", Baslik: "Seri No", EnFazlaUzunluk: 50),
                new("skt", "skt", "tarih", Baslik: "SKT"),
                new("implant", "implant", "mantik", Baslik: "İmplant"),
                new("utsDurum", "uts_durum", "kod", Baslik: "ÜTS", SabitKodlar: AmKartUtsKodlari),
                // Pakete dahil malzeme ayrıca faturalanmaz; işaretlenmezse
                //   hastadan çift ücret alınır.
                new("faturaya", "faturaya", "mantik", Baslik: "Faturaya"),
            }, Sirala: "id", Baslik: "Sarf & İmplant", LogTabloId: 1154),

            new("sayim", "public.ameliyat_sayim", "ameliyat_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("kalem", "kalem", "metin", Zorunlu: true, Baslik: "Sayılan",
                    EnFazlaUzunluk: 100),
                new("baslangic", "baslangic", "sayi", Baslik: "Başlangıç"),
                new("eklenen", "eklenen", "sayi", Baslik: "Eklenen"),
                new("kapanis", "kapanis", "sayi", Baslik: "Kapanışta"),
                // Tetik yazar - elle işaretlenirse sayım güvencesi kalkar.
                new("uyumlu", "uyumlu", "kod", Yazilabilir: false, Baslik: "Uyum",
                    SabitKodlar: AmKartUyumKodlari),
                // İKİ SAYAN: sayım iki kişi tarafından ayrı ayrı yapılır.
                new("sayan1Id", "sayan1_id", "sayi", Baslik: "1. Sayan",
                    KodTablosu: "public.v_personel_lookup"),
                new("sayan2Id", "sayan2_id", "sayi", Baslik: "2. Sayan",
                    KodTablosu: "public.v_personel_lookup"),
                new("sayimZamani", "sayim_zamani", "zaman", Baslik: "Zaman"),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 200),
            }, Sirala: "id", Baslik: "Sayım", LogTabloId: 1155),

            new("komplikasyon", "public.ameliyat_komplikasyon", "ameliyat_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tarih", "tarih", "zaman", Zorunlu: true, Baslik: "Tarih"),
                // ICD-10 ZORUNLU: serbest metin klinik kalite göstergesine
                //   dönüşemez (DP.G6 / KP.G1 tanı kodundan hesaplanır).
                new("icdKod", "icd_kod", "metin", Zorunlu: true, Baslik: "ICD-10",
                    EnFazlaUzunluk: 20),
                new("aciklama", "aciklama", "metin", Baslik: "Açıklama", EnFazlaUzunluk: 300),
                new("sinif", "sinif", "kod", Baslik: "Clavien-Dindo",
                    SabitKodlar: AmKartSinifKodlari),
                new("bildirenId", "bildiren_id", "sayi", Baslik: "Bildiren",
                    KodTablosu: "public.v_personel_lookup"),
            }, Sirala: "tarih desc", Baslik: "Komplikasyon", LogTabloId: 1156),

            // 1:1 uzantı (UstKolon = "id"): ikinci not satırı yazılamaz.
            new("not", "public.ameliyat_not", "ameliyat_id", new KartAlani[]
            {
                new("ameliyatId", "ameliyat_id", "sayi", Yazilabilir: false),
                new("oncekiTani", "onceki_tani", "metin", Baslik: "Ameliyat Öncesi Tanı",
                    EnFazlaUzunluk: 20),
                new("sonrakiTani", "sonraki_tani", "metin", Baslik: "Ameliyat Sonrası Tanı",
                    EnFazlaUzunluk: 20),
                new("bulgu", "bulgu", "metin", Baslik: "Bulgular"),
                new("islemMetni", "islem_metni", "metin", Baslik: "Uygulanan İşlem"),
                new("dren", "dren", "metin", Baslik: "Dren", EnFazlaUzunluk: 200),
                new("patoloji", "patoloji", "metin", Baslik: "Patoloji Materyali",
                    EnFazlaUzunluk: 300),
                new("ekNot", "ek_not", "metin", Baslik: "Ek Not"),
                // İmza alanları salt okunur: imzalama ayrı aksiyon, kart
                //   üzerinden tarih yazılarak imzalanmış sayılamaz.
                new("imzalayanId", "imzalayan_id", "sayi", Yazilabilir: false,
                    Baslik: "İmzalayan", KodTablosu: "public.v_personel_lookup"),
                new("imzaZamani", "imza_zamani", "zaman", Yazilabilir: false,
                    Baslik: "İmza Zamanı"),
            }, IdKolonu: "ameliyat_id", Sirala: "ameliyat_id", Baslik: "Ameliyat Notu",
               SubeKolonu: null, LogTabloId: 1157),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0,
            ["planSureDk"] = 60,
        });

    private static KartTanimi AmeliyatTalep() => new(
        Ad: "ameliyatTalep",
        YetkiKodu: "ameliyathane.talep",
        Tablo: "public.ameliyat_talep",
        LogTabloId: 1158,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("talepNo", "talep_no", "metin", Yazilabilir: false, Baslik: "Talep No",
                Grup: "Talep"),
            new("hastaId", "hasta_id", "sayi", Zorunlu: true, Baslik: "Hasta",
                Grup: "Talep", AramaKaynagi: "hasta", KodTablosu: "public.v_hasta_lookup"),
            new("isteyenId", "isteyen_id", "sayi", Baslik: "İsteyen Hekim", Grup: "Talep",
                KodTablosu: "public.v_hekim_lookup"),
            new("hizmetId", "hizmet_id", "sayi", Zorunlu: true, Baslik: "İşlem",
                Grup: "Talep", AramaKaynagi: "hizmet", KodTablosu: "public.v_hizmet_lookup"),
            new("taraf", "taraf", "kod", Baslik: "Taraf", Grup: "Talep",
                SabitKodlar: AmKartTarafKodlari),
            new("oncelik", "oncelik", "kod", Baslik: "Öncelik", Grup: "Talep",
                SabitKodlar: AmKartOncelikKodlari),
            new("tahminiSureDk", "tahmini_sure_dk", "sayi", Baslik: "Tahmini Süre (dk)",
                Grup: "Talep"),
            new("anesteziTipi", "anestezi_tipi", "kod", Baslik: "Anestezi Tipi",
                Grup: "Talep", SabitKodlar: AmKartAnesteziKodlari),
            new("istenenTarih", "istenen_tarih", "tarih", Baslik: "İstenen Tarih",
                Grup: "Talep"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Talep"),

            // ÖN HAZIRLIK ayrı bayraklar: eksik olanın NE olduğu listede
            //   yazmazsa kullanıcı her talebi tek tek açmak zorunda kalır.
            new("anesteziOnay", "anestezi_onay", "mantik", Baslik: "Anestezi Onayı",
                Grup: "Ön Hazırlık"),
            new("tetkikTamam", "tetkik_tamam", "mantik", Baslik: "Tetkikler Tamam",
                Grup: "Ön Hazırlık"),
            new("kanHazir", "kan_hazir", "mantik", Baslik: "Kan Hazırlığı",
                Grup: "Ön Hazırlık"),
            new("onamAlindi", "onam_alindi", "mantik", Baslik: "Onam Alındı",
                Grup: "Ön Hazırlık"),

            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Durum",
                SabitKodlar: AmKartTalepDurumKodlari),
            new("iptalNeden", "iptal_neden", "metin", Baslik: "İptal Nedeni", Grup: "Durum",
                EnFazlaUzunluk: 200),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["oncelik"] = 1,
            ["durum"] = 0,
        });

    private static KartTanimi AmeliyatSalon() => new(
        Ad: "ameliyatSalon",
        YetkiKodu: "ameliyathane.salon",
        Tablo: "public.ameliyat_salon",
        LogTabloId: 1159,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("kod", "kod", "metin", Zorunlu: true, Baslik: "Kod", EnFazlaUzunluk: 20),
            new("ad", "ad", "metin", Zorunlu: true, Baslik: "Salon Adı", EnFazlaUzunluk: 100),
            new("ozellik", "ozellik", "metin", Baslik: "Donanım", EnFazlaUzunluk: 200),
            new("departmanId", "departman_id", "sayi", Baslik: "Bölüm",
                KodTablosu: "public.v_departman_lookup"),
            new("acilAyrilmis", "acil_ayrilmis", "mantik", Baslik: "Acile Ayrılmış"),
            new("sira", "sira", "sayi", Baslik: "Sıra"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif"),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = 1 });

    private static readonly Dictionary<string, string> AmKartDurumKodlari = new()
    {
        ["0"] = "Planlandı", ["1"] = "Hazırlık", ["2"] = "Sürüyor",
        ["3"] = "Kapanışta", ["4"] = "Bitti", ["8"] = "İptal",
    };

    private static readonly Dictionary<string, string> AmKartAnesteziKodlari = new()
    {
        ["1"] = "Genel", ["2"] = "Spinal", ["3"] = "Epidural",
        ["4"] = "Bölgesel", ["5"] = "Lokal", ["6"] = "Sedasyon",
    };

    private static readonly Dictionary<string, string> AmKartTarafKodlari = new()
    {
        ["0"] = "—", ["1"] = "Sağ", ["2"] = "Sol", ["3"] = "Bilateral",
    };

    private static readonly Dictionary<string, string> AmKartIslemTurKodlari = new()
    {
        ["1"] = "Ana işlem", ["2"] = "Ek işlem",
    };

    private static readonly Dictionary<string, string> AmKartRolKodlari = new()
    {
        ["1"] = "Cerrah", ["2"] = "Asistan", ["3"] = "Anestezi uzmanı",
        ["4"] = "Anestezi teknikeri", ["5"] = "Scrub hemşire",
        ["6"] = "Sirküle hemşire", ["7"] = "Görüntüleme", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> AmKartAsamaKodlari = new()
    {
        ["1"] = "1 · Salona girişte (sign in)", ["2"] = "2 · Kesi öncesi (time out)",
        ["3"] = "3 · Çıkmadan (sign out)",
    };

    private static readonly Dictionary<string, string> AmKartUtsKodlari = new()
    {
        ["0"] = "Gerekmiyor", ["1"] = "Bekliyor", ["2"] = "Bildirildi", ["3"] = "Hata",
    };

    private static readonly Dictionary<string, string> AmKartUyumKodlari = new()
    {
        ["1"] = "Uyuyor", ["0"] = "UYUŞMUYOR",
    };

    private static readonly Dictionary<string, string> AmKartSinifKodlari = new()
    {
        ["1"] = "I", ["2"] = "II", ["3"] = "III", ["4"] = "IV", ["5"] = "V (ölüm)",
    };

    private static readonly Dictionary<string, string> AmKartOncelikKodlari = new()
    {
        ["1"] = "Normal", ["2"] = "Tarihli", ["3"] = "Onkolojik", ["4"] = "Acil",
    };

    private static readonly Dictionary<string, string> AmKartTalepDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Planlandı", ["2"] = "Yapıldı",
        ["8"] = "İptal", ["9"] = "Vazgeçildi",
    };
}
