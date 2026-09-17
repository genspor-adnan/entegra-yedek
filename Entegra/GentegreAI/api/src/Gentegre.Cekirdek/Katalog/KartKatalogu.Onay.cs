namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ONAY KARTLARI (741/742) — akış tanımı ve vekâlet.
///
/// AKIŞ BİR KART, BASAMAKLAR ONUN DETAYI. Kurallar 738'de veriye taşındı ama
/// düzenleyecek ekran yoktu: kurum eşiği değiştirmek istediğinde göç dosyası
/// yazmak gerekiyordu - yani kural yine koda gömülüydü, yalnız adı değişmişti.
///
/// KAYNAK TÜRÜ SERBEST METİN DEĞİL: akış bir kayıt türüne bağlanır ve o
/// türün "onaylandı ne demek" eşlemesi UÇTA yazılıdır (`OnayUclari`). Listeye
/// yalnız motorun gerçekten yürütebildiği türleri koyuyoruz - olmayan bir
/// türe akış tanımlatmak, ilk kararda "kayıt durumu eşlemesi tanımlı değil"
/// ile duran bir zincir üretirdi.
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>
    /// Motorun yürütebildiği kayıt türleri (`islem_log.tablo_id`).
    /// Yeni tür eklemek = `OnayUclari.KayitDurumYazAsync`e bir dal + buraya
    /// bir satır. İkisi birlikte gider; biri eksikse akış yarım kalır.
    /// </summary>
    private static readonly Dictionary<string, string> OnKaynakTuruKodlari = new()
    {
        ["1241"] = "Satınalma Talebi",
        ["904"] = "Personel İzni",
        ["1224"] = "Demirbaş İş Emri",
        // 1257 (755): 907 DEĞİL - o numara Hasta Bilgisi'nin, 753'te
        //   yanlışlıkla alınmıştı.
        ["1257"] = "Personel Avansı",
        ["1256"] = "İskonto Talebi",
    };

    /// <summary>onay_akis_adim.sahip_turu</summary>
    private static readonly Dictionary<string, string> OnSahipTuruKodlari = new()
    {
        ["1"] = "Rol", ["2"] = "Kullanıcı", ["3"] = "Âmir (henüz yok)",
    };

    /// <summary>
    /// Basamak rolleri - `satinalma_onay.rol` ile AYNI dil (724). Karar
    /// ucundaki yetki eşlemesi bu kodlara bakar.
    /// </summary>
    private static readonly Dictionary<string, string> OnRolKodlari = new()
    {
        // ROL KODU AKIŞIN KENDİ DİLİ: 6 izin akışında İK, onarımda teknik
        //   müdürdür. Tek bir küresel harita kursaydık iki modül birbirinin
        //   imza düzenini belirlerdi - adlar bu yüzden eğik yazılı.
        ["1"] = "Birim sorumlusu", ["2"] = "Satınalma", ["3"] = "Başhekim / Müdür",
        ["4"] = "Mali işler", ["5"] = "Üst yönetim",
        ["6"] = "İK / Teknik müdür (akışa göre)", ["0"] = "Kişiye atanır",
    };

    /// <summary>onay_akis_adim.karar_turu</summary>
    private static readonly Dictionary<string, string> OnKararTuruKodlari = new()
    {
        ["0"] = "Onay / ret", ["1"] = "Yalnız bilgilendirme",
    };

    // --------------------------------------------------- onay akışı ----
    private static KartTanimi OnayAkis() => new(
        Ad: "onayAkis",
        // YETKİ KULLANICI YÖNETİMİYLE AYNI: akış, kurumun imza düzenidir.
        //   "Onayı olan herkes akışı düzenlesin" deseydik, imzalayan kişi
        //   kendi basamağını kaldırabilirdi.
        YetkiKodu: "kullanici",
        Tablo: "public.onay_akis",
        LogTabloId: 1295,
        // KURUM GENELİ (bkz. liste kaynağı): şube damgası konsaydı tanım
        //   yalnız damgalandığı şubede görünür olurdu.
        SubeKolonu: null,
        Alanlar: new KartAlani[]
        {
            new("kod", "kod", "metin", Zorunlu: true, Baslik: "Akış Kodu", Grup: "Akış",
                EnFazlaUzunluk: 40),
            new("ad", "ad", "metin", Zorunlu: true, Baslik: "Adı", Grup: "Akış",
                EnFazlaUzunluk: 120),
            new("kaynakTur", "kaynak_tur", "kod", Zorunlu: true, Baslik: "Hangi Kayıt",
                Grup: "Akış", SabitKodlar: OnKaynakTuruKodlari),
            // ÖLÇÜ ADI ekranda görünür: aynı sayı tutar da olabilir gün de.
            //   Tek "Tutar" başlığı koysaydık izin akışında "14 TL" yazardı.
            new("olcuAdi", "olcu_adi", "metin", Baslik: "Karar Ölçüsü", Grup: "Akış",
                EnFazlaUzunluk: 40),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Akış"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Akış",
                EnFazlaUzunluk: 400),
        },
        Detaylar: new DetayTanimi[]
        {
            // BASAMAKLAR YAZILABİLİR: akışın kendisi budur. Yürüyen zincirin
            //   basamağı (`onay_adim`) ise SALT OKUNUR - tanımı değiştirmek
            //   gelecekteki zincirleri etkiler, atılmış imzaları değil.
            new("adimlar", "public.onay_akis_adim", "akis_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Zorunlu: true, Baslik: "Sıra"),
                new("ad", "ad", "metin", Zorunlu: true, Baslik: "Basamak Adı",
                    EnFazlaUzunluk: 60),
                new("sahipTuru", "sahip_turu", "kod", Baslik: "Kime Düşer",
                    SabitKodlar: OnSahipTuruKodlari),
                new("rol", "rol", "kod", Baslik: "Rol", SabitKodlar: OnRolKodlari),
                new("kullaniciId", "kullanici_id", "sayi", Baslik: "Kullanıcı",
                    KodTablosu: "public.v_kullanici_lookup"),
                // EŞİK BOŞ = HER KAYITTA. Sıfır yazmak "sıfır ve üstü" demektir
                //   ve pratikte aynı sonucu verir ama niyeti gizler: boş bırakmak
                //   "bu basamak koşulsuz" demenin yoludur.
                new("esikAlt", "esik_alt", "ondalik", Baslik: "Eşik (≥)"),
                new("bayrak", "bayrak", "metin", Baslik: "Bayrak Koşulu",
                    EnFazlaUzunluk: 40),
                new("kararTuru", "karar_turu", "kod", Baslik: "Karar Türü",
                    SabitKodlar: OnKararTuruKodlari),
                // SÜRE KİMSEYİ ONAYLAMAZ: dolunca basamak "gecikmiş" görünür
                //   ve hatırlatma gider. Sessiz onay, onayın kendisini ortadan
                //   kaldırırdı.
                new("sureGun", "sure_gun", "sayi", Baslik: "Süre (gün)"),
                new("eImzaZorunlu", "e_imza_zorunlu", "mantik", Baslik: "e-İmza"),
                new("aktif", "aktif", "mantik", Baslik: "Aktif"),
            }, Sirala: "sira, id", Baslik: "Basamaklar",
               SubeKolonu: null, LogTabloId: 1296,
               YeniSatirVarsayilanlari: new Dictionary<string, object?>
               {
                   ["sahip_turu"] = 1, ["rol"] = 1, ["karar_turu"] = 0,
                   ["sure_gun"] = 3, ["e_imza_zorunlu"] = 0, ["aktif"] = 1,
               }),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = 1,
        });

    // ------------------------------------------------------- vekâlet ----
    private static KartTanimi OnayVekalet() => new(
        Ad: "onayVekalet",
        // YETKİ: vekâlet imza yetkisinin devridir - kullanıcı yönetimiyle
        //   aynı ağırlıkta. "Onayı olan herkes kendi vekâletini tanımlasın"
        //   deseydik, imza zinciri kişinin kendi kararına kalırdı.
        YetkiKodu: "kullanici",
        Tablo: "public.onay_vekalet",
        LogTabloId: 1294,
        SubeKolonu: null,
        Alanlar: new KartAlani[]
        {
            // KULLANICI HESABI, PERSONEL DEĞİL: imzayı hesap atar. İkisi çoğu
            //   kurumda aynı kişidir ama aynı kayıt değildir.
            new("devredenId", "devreden_id", "sayi", Zorunlu: true, Baslik: "Devreden",
                Grup: "Vekâlet", KodTablosu: "public.v_kullanici_lookup"),
            new("devralanId", "devralan_id", "sayi", Zorunlu: true, Baslik: "Vekil",
                Grup: "Vekâlet", KodTablosu: "public.v_kullanici_lookup"),
            // TARİH ARALIĞI ZORUNLU: süresiz vekâlet, imza yetkisinin kalıcı
            //   devri demektir - o bir vekâlet değil, rol değişikliğidir.
            new("baslangic", "baslangic", "tarih", Zorunlu: true, Baslik: "Başlangıç",
                Grup: "Vekâlet"),
            new("bitis", "bitis", "tarih", Zorunlu: true, Baslik: "Bitiş", Grup: "Vekâlet"),
            // AKIŞ BOŞSA TÜM AKIŞLAR: izindeki müdürün yerine bakan kişi
            //   genellikle her şeye bakar; yalnız satınalmaya vekâlet vermek
            //   istisnadır ve o zaman seçilir.
            new("akisId", "akis_id", "sayi", Baslik: "Yalnız Bu Akış", Grup: "Vekâlet",
                KodTablosu: "public.v_onay_akis_lookup"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Vekâlet"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Vekâlet",
                EnFazlaUzunluk: 200),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = 1,
            // BUGÜNDEN BAŞLAR: vekâlet çoğu zaman "yarın izne çıkıyorum"
            //   anında tanımlanır; boş tarih her kayıtta doğrulama hatası
            //   verirdi.
            ["baslangic"] = "@simdi",
        });
}
