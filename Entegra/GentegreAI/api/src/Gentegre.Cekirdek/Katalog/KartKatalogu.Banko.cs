namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BANKO kartı (985, Ekranlar/Kayıt Kabul/banko_tanimi_v2.html).
///
/// Banko bir FİZİKSEL NOKTADIR: kasası, POS'u ve donanımı vardır,
/// <b>personeli yoktur</b> (kullanıcı 08.10.2026: "banko tanımında kullanıcı
/// olmaz"). Kim çalışacağı oturum açılışında belirlenir - tanıma personel
/// listesi koymak her vardiya ve her izinde tanımı düzenlemek olurdu; kimin
/// tahsilat yapabileceği <b>rolden</b> gelir (Banko Görevlisi / Banko
/// Sorumlusu / Banko Kasiyeri).
///
/// KASASIZ BANKO OLABİLİR (tür 2 "Danışma"): karşılama bankosu yönlendirir,
/// tahsilat yapmaz. Bu yüzden hesap alanı zorunlu DEĞİL - her bankoya kasa
/// şart koşmak danışmayı tanımlanamaz hale getirirdi.
///
/// POS BANKOYA BAĞLIDIR (kullanıcı: "banko tanımı yaparken oraya bağlı POS
/// listesi de girilebilmeli") ve tahsilat ekranı yalnız bu listeden seçtirir -
/// kurumdaki bütün terminaller değil. Yan bankonun terminaline çekilen kart o
/// bankonun gün sonunu tutturmaz.
///
/// Oturum/vardiya ve gün içi hareket sekmeleri İLERİDE: oturum altyapısı
/// (açılış, devir, gün sonu teslimi) ayrı iştir - mockup'ta tasarlandı,
/// burada yer tutucu bile açılmadı; boş sekme doldurulacak bir şey varmış
/// izlenimi verir.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi Banko() => new(
        Ad: "banko",
        YetkiKodu: "banko",
        Tablo: "public.banko",
        LogTabloId: 1382,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,
            ["aktif"] = (short)1,
            ["fis_zorunlu"] = (short)1,
            ["tahsilatsiz_basvuru"] = (short)1,
            ["iade_onay"] = (short)1,
            ["kupur_dokumu"] = (short)1,
            // ONAY VARSAYILANI: açılış serbest, gün sonu imzaya bağlı
            //   (kullanıcı: "opsiyonel olarak banko sorumlusu onay verince
            //   banko açılabilir"). Yaygın tercih bu; her sabah onay
            //   beklemek bankoyu durdurur, farkın imzasız kapanması ise
            //   denetimi bırakır.
            ["acilis_onay"] = (short)0,
            ["gun_sonu_onay"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // BAŞLIK ŞERİDİ her sekmede sabit: Kod / Ad / Durum.
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Banko Kodu", Grup: "Kimlik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Banko Adı", Grup: "Kimlik"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            new("tur", "tur", "kod", Zorunlu: true, SabitKodlar: BankoTuruKodlari,
                Baslik: "Banko Türü", Grup: "Tanım", AltGrup: "Genel",
                Ipucu: "Danışma türünde kasa, POS ve oturum beklenmez"),
            new("subeId", "sube_id", "kod", KodTablosu: "public.v_sube_lookup",
                Baslik: "Şube", Grup: "Tanım", AltGrup: "Genel"),
            new("konum", "konum", "metin", EnFazlaUzunluk: 160,
                Baslik: "Konum", Grup: "Tanım", AltGrup: "Genel"),
            new("dahili", "dahili", "metin", EnFazlaUzunluk: 20,
                Baslik: "Dahili Telefon", Grup: "Tanım", AltGrup: "Genel"),

            // KASA HESABI gün içindeki fişlerin yazıldığı yerdir; açık
            //   oturumda değiştirmek mutabakatı bozar - oturum altyapısı
            //   geldiğinde kilit oraya eklenecek.
            new("hesapId", "hesap_id", "kod", KodTablosu: "public.v_hesap_lookup",
                Baslik: "Kasa Hesabı", Grup: "Tanım", AltGrup: "Kasa",
                Ipucu: "Danışma bankosunda boş kalır"),
            new("devirTutar", "devir_tutar", "para",
                Baslik: "Kasada Bırakılacak (devir)", Grup: "Tanım", AltGrup: "Kasa"),
            new("dovizKabul", "doviz_kabul", "mantik",
                Baslik: "Döviz kabul edilir", Grup: "Tanım", AltGrup: "Kasa"),
            new("gunSonuSaat", "gun_sonu_saat", "metin", EnFazlaUzunluk: 5,
                Baslik: "Gün Sonu Saati", Grup: "Tanım", AltGrup: "Kasa",
                Ipucu: "SS:DD"),

            new("fiyatListesiId", "fiyat_listesi_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_satis_lookup",
                Baslik: "Fiyat Listesi", Grup: "Tanım", AltGrup: "Varsayılanlar"),
            new("varsayilanOdeme", "varsayilan_odeme", "kod",
                KodTablosu: "public.v_tahsilat_turu_lookup",
                Baslik: "Varsayılan Ödeme", Grup: "Tanım", AltGrup: "Varsayılanlar"),
            new("fisYazici", "fis_yazici", "metin", EnFazlaUzunluk: 80,
                Baslik: "Fiş Yazıcısı", Grup: "Tanım", AltGrup: "Varsayılanlar"),

            // SINIRLAR UYARIR, ENGELLEMEZ: hastayı kasada bekletmek yerine
            //   sorumluya haber verilip ara teslim yapılır. 0 = sınır yok.
            new("nakitUstSinir", "nakit_ust_sinir", "para",
                Baslik: "Kasa Nakit Üst Sınırı", Grup: "Ayarlar", AltGrup: "Sınırlar",
                Ipucu: "0 = sınır yok; aşılınca uyarır, engellemez"),
            new("tekIslemUstSinir", "tek_islem_ust_sinir", "para",
                Baslik: "Tek İşlemde Nakit Sınırı", Grup: "Ayarlar", AltGrup: "Sınırlar"),
            new("paraUstuKasasi", "para_ustu_kasasi", "para",
                Baslik: "Para Üstü Kasası", Grup: "Ayarlar", AltGrup: "Sınırlar"),

            new("acilisOnay", "acilis_onay", "mantik",
                Baslik: "Açılış için sorumlu onayı", Grup: "Ayarlar",
                AltGrup: "Onay ve Kurallar",
                Ipucu: "Kapalıysa görevli devri sayıp bankoyu doğrudan açar"),
            new("gunSonuOnay", "gun_sonu_onay", "mantik",
                Baslik: "Gün sonu teslimi için sorumlu onayı", Grup: "Ayarlar",
                AltGrup: "Onay ve Kurallar"),
            new("fisZorunlu", "fis_zorunlu", "mantik",
                Baslik: "Fiş yazdırma zorunlu", Grup: "Ayarlar",
                AltGrup: "Onay ve Kurallar"),
            new("tahsilatsizBasvuru", "tahsilatsiz_basvuru", "mantik",
                Baslik: "Tahsilatsız başvuru açılabilir (SGK)", Grup: "Ayarlar",
                AltGrup: "Onay ve Kurallar"),
            new("kismiTahsilat", "kismi_tahsilat", "mantik",
                Baslik: "Kısmi tahsilat yapılabilir", Grup: "Ayarlar",
                AltGrup: "Onay ve Kurallar",
                Ipucu: "Acil bankosunda açık, poliklinikte kapalı olabilir"),
            new("iadeOnay", "iade_onay", "mantik",
                Baslik: "İade için sorumlu onayı", Grup: "Ayarlar",
                AltGrup: "Onay ve Kurallar"),
            // KUPUR DOKUMU AYARI KALDIRILDI (kullanici 08.10.2026: "oturum
            //   acma/kapatmada kupur kaldir, yerine devir olsun"): sayim tek
            //   devir tutari olarak giriliyor, banknot dokumu istenmiyor.
            //   `kupur_dokumu` kolonu ve banko_oturum_kupur tablosu DB'de
            //   duruyor - eski oturumlarin dokumu kaybolmasin.

            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400,
                Baslik: "Açıklama", Grup: "Ayarlar"),
        },
        // SILME ENGELLERI (kullanici 08.10.2026: "acik ya da gecmis oturum
        //   kaydi varsa banko silinemez"): oturum paranin sorumluluk
        //   zinciridir - devir, tahsilat, sayim farki ve teslim tutanagi ona
        //   bagli. Bankoyu silmek o zinciri sahipsiz birakirdi; kullanimdan
        //   cikarmanin yolu `Aktif` alanini kapatmak (pasif banko yeni oturum
        //   acamaz, gecmisi durur).
        //
        //   KAPANMIS OTURUM DA ENGELLER: "artik kullanilmiyor" bir silme
        //   gerekcesi degil, denetim kaydi oradan okunuyor.
        //
        //   POS ve cihaz satirlari engel DEGIL: onlar bankonun kendi
        //   detaylari, kartla birlikte gider.
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.banko_oturum", "banko_id",
                "Bu bankoda oturum kaydı var (açık ya da kapanmış); banko silinemez. "
                + "Kullanımdan çıkarmak için \"Aktif\" alanını kapatın."),
            new("public.kasa_islem", "banko_pos_id",
                "Bu bankonun POS'undan tahsilat geçmiş; banko silinemez. "
                + "Kullanımdan çıkarmak için \"Aktif\" alanını kapatın."),
        },
        Detaylar: new DetayTanimi[]
        {
            // ----------------------------------------------- POS cihazları ----
            new("pos", "public.banko_pos", "banko_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                // TEK VARSAYILAN (banko_pos_varsayilan_tek): ikinci varsayılan
                //   işaretlenirse tahsilat ekranı hangisini seçili getireceğini
                //   bilemezdi - veritabanı reddeder.
                new("varsayilan", "varsayilan", "mantik", Baslik: "Varsayılan"),
                // TAHSILAT HESABI, BANKA ALANININ YERINE (992, kullanici:
                //   "banka sutunu kaldir onun yerine tahsilat hesabi ni
                //   getir, bu hesap listesinde sadece pos listesi olsun").
                //   POS tahsilati kasaya nakit girmez; kendi POS hesabina
                //   yazilir ve gun sonu mutabakati o hesabin ekstresiyle
                //   yapilir. Bankayi ayrica sormak ayni bilgiyi iki kez
                //   istemekti - ustelik iki alan tutarsiz kalabiliyordu
                //   ("Ziraat" secip hesabi Garanti POS'u gostermek mumkundu).
                //   `banka_id` kolonu DB'de duruyor (eski kayitlar), kartta
                //   gorunmuyor ve hicbir yerde okunmuyor.
                new("hesapId", "hesap_id", "kod", KodTablosu: "public.v_pos_hesap_lookup",
                    Zorunlu: true, Baslik: "Tahsilat Hesabı",
                    Ipucu: "Yalnız POS hesapları listelenir; gün sonu mutabakatı bu hesabın ekstresiyle yapılır"),
                new("terminalNo", "terminal_no", "metin", Zorunlu: true,
                    EnFazlaUzunluk: 30, Baslik: "Terminal No"),
                new("baglantiTur", "baglanti_tur", "kod", SabitKodlar: PosBaglantiKodlari,
                    Baslik: "Bağlantı"),
                new("adres", "adres", "metin", EnFazlaUzunluk: 60, Baslik: "Adres / IP"),
                new("port", "port", "sayi", Baslik: "Port"),
                new("yabanciKart", "yabanci_kart", "mantik", Baslik: "Yabancı kart"),
                // GRIDDEN KALDIRILAN ALANLAR (kullanici 08.10.2026): Uye
                //   Isyeri No, Seri No, Taksit (en az/en cok), Komisyon,
                //   Valor. Kolonlar DB'de duruyor; komisyon ve valor zaten
                //   HESAP tablosunda tanimli (hesap.komisyon_orani,
                //   hesap.valor_gun) - POS satirinda ikinci kez tutmak iki
                //   degerin ayrismasi demekti. Cihaz kunyesi (uye isyeri,
                //   seri no) gunluk iste kullanilmiyor.
                new("durum", "durum", "kod", SabitKodlar: PosDurumKodlari, Baslik: "Durum",
                    Ipucu: "Çalışmayan POS tahsilat ekranında listelenmez"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            }, Sirala: "varsayilan desc, id", Baslik: "POS Cihazları",
               SubeKolonu: null, LogTabloId: 1383),

            // ------------------------------------------- yazıcı ve donanım ----
            // Bakım, arıza ve garanti DEMİRBAŞ kartında izlenir; burada yalnız
            //   "hangi cihaz bu bankoda" durur - iki yerde cihaz geçmişi tutmak
            //   ikisini de güvenilmez yapardı.
            new("cihazlar", "public.banko_cihaz", "banko_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tur", "tur", "kod", Zorunlu: true, SabitKodlar: BankoCihazKodlari,
                    Baslik: "Cihaz Türü"),
                new("ad", "ad", "metin", EnFazlaUzunluk: 80, Baslik: "Ad / Etiket"),
                new("model", "model", "metin", EnFazlaUzunluk: 120, Baslik: "Model"),
                new("baglanti", "baglanti", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Bağlantı"),
                new("demirbasId", "demirbas_id", "sayi", Baslik: "Demirbaş",
                    Ipucu: "Bakım ve garanti demirbaş kartında izlenir"),
                new("durum", "durum", "kod", SabitKodlar: PosDurumKodlari, Baslik: "Durum"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            }, Sirala: "tur, id", Baslik: "Yazıcı & Donanım",
               SubeKolonu: null, LogTabloId: 1384),

            // ----------------------------------------------- oturumlar ----
            // SALT OKUMA: oturum karttan açılmaz/kapanmaz - akış ekranının
            //   (banko-oturum) işi. Burada yalnız geçmiş görünür: fark
            //   eğilimi bu listeden okunur, aynı görevlide tekrarlayan
            //   noksan eğitim ya da denetim konusudur.
            new("oturumlar", "public.banko_oturum", "banko_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false, Baslik: "Oturum"),
                new("durum", "durum", "kod", Yazilabilir: false,
                    SabitKodlar: OturumDurumKodlari, Baslik: "Durum"),
                new("acilisTs", "acilis_ts", "zaman", Yazilabilir: false, Baslik: "Açılış"),
                new("kapanisTs", "kapanis_ts", "zaman", Yazilabilir: false, Baslik: "Kapanış"),
                new("vardiya", "vardiya", "metin", Yazilabilir: false, Baslik: "Vardiya"),
                new("devirTutar", "devir_tutar", "para", Yazilabilir: false, Baslik: "Devir"),
                new("acilisFark", "acilis_fark", "para", Yazilabilir: false, Baslik: "Açılış Farkı"),
                new("kapanisSayim", "kapanis_sayim", "para", Yazilabilir: false, Baslik: "Sayım"),
                new("kapanisFark", "kapanis_fark", "para", Yazilabilir: false, Baslik: "Fark"),
                new("kasadaBirakilan", "kasada_birakilan", "para", Yazilabilir: false,
                    Baslik: "Bırakılan"),
                new("teslimEdilen", "teslim_edilen", "para", Yazilabilir: false, Baslik: "Teslim"),
                new("tutanakNo", "tutanak_no", "metin", Yazilabilir: false, Baslik: "Tutanak"),
                new("farkAciklama", "fark_aciklama", "metin", Yazilabilir: false, Baslik: "Fark Notu"),
            }, Sirala: "id desc", Baslik: "Oturumlar", SubeKolonu: null,
               SaltOkunur: true, LogTabloId: 1385),
        });

    internal static readonly Dictionary<string, string> OturumDurumKodlari = new()
    {
        ["1"] = "Açılış onayı bekliyor", ["2"] = "Açık",
        ["3"] = "Teslime gönderildi", ["4"] = "Kapandı", ["5"] = "Reddedildi",
    };

    internal static readonly Dictionary<string, string> BankoTuruKodlari = new()
    {
        ["1"] = "Kayıt kabul + kasa",
        ["2"] = "Danışma (kasasız)",
        ["3"] = "Numune kabul + kasa",
        ["4"] = "Yalnız kasa",
    };

    private static readonly Dictionary<string, string> PosBaglantiKodlari = new()
    {
        ["1"] = "Ethernet", ["2"] = "USB", ["3"] = "Seri port",
        ["4"] = "Entegre değil (manuel)",
    };

    internal static readonly Dictionary<string, string> PosDurumKodlari = new()
    {
        ["1"] = "Çalışıyor", ["2"] = "Ulaşılamıyor / arıza", ["3"] = "Pasif",
    };

    private static readonly Dictionary<string, string> BankoCihazKodlari = new()
    {
        ["1"] = "Fiş yazıcısı", ["2"] = "Kimlik okuyucu", ["3"] = "Barkod okuyucu",
        ["4"] = "Kart okuyucu", ["5"] = "El terminali", ["99"] = "Diğer",
    };
}
