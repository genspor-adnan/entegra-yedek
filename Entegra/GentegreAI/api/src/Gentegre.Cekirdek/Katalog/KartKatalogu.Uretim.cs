namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ÜRETİM KARTLARI (429) — ürün ağacı, üretim emri, iş merkezi.
///
/// Mockuplar: Ekranlar/Uretim/urun_agaci_karti.html, uretim_emri_karti.html.
///
/// <para><b>Ağaç emre kopyalanır.</b> Üretim emri kartındaki malzeme ve
/// operasyon satırları emrin KENDİ satırlarıdır; ağaç sonradan değişse açık
/// emir etkilenmez. Bu yüzden emirde de tam bir bileşen/operasyon düzenleme
/// yüzeyi var - "ağaca git, orada düzelt" demek, üretimdeki emri geçmişe
/// dönük değiştirmek olurdu.</para>
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> AgacTurKodlari = new()
        { ["1"] = "Mamul", ["2"] = "Yarı Mamul", ["3"] = "Paket / Set" };

    private static readonly Dictionary<string, string> AgacDurumKodlari = new()
        { ["0"] = "Aktif", ["1"] = "Pasif (eski sürüm)" };

    private static readonly Dictionary<string, string> BilesenTurKodlari = new()
        { ["1"] = "Hammadde", ["2"] = "Sarf", ["3"] = "Ambalaj", ["4"] = "Yarı Mamul" };

    private static readonly Dictionary<string, string> EmirTurKodlari = new()
    {
        ["1"] = "Siparişe üretim", ["2"] = "Stoğa üretim",
        ["3"] = "Fason", ["4"] = "Alt emir",
    };

    // DURUM AKISI SABIT: adi degisebilir, SIRASI degisemez - maliyet kapanisi
    //   ve stok hareketleri bu siraya bagli (bkz. db/429 basligi).
    private static readonly Dictionary<string, string> EmirDurumKodlari = new()
    {
        ["0"] = "İptal", ["1"] = "Taslak", ["2"] = "Onaylı", ["3"] = "Planlandı",
        ["4"] = "Üretimde", ["5"] = "Kısmi tamamlandı", ["6"] = "Tamamlandı",
        ["7"] = "Kapatıldı",
    };

    private static readonly Dictionary<string, string> EmirOncelikKodlari = new()
        { ["0"] = "Normal", ["1"] = "Yüksek", ["2"] = "Acil" };

    private static readonly Dictionary<string, string> SarfModuKodlari = new()
    {
        ["1"] = "Tek seferde (Başlat'ta)",
        ["2"] = "Geri-yıkama (operasyon bildirimiyle)",
    };

    private static readonly Dictionary<string, string> EmirSatirDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Rezerve", ["2"] = "Kısmi sarf", ["3"] = "Sarf edildi",
    };

    private static readonly Dictionary<string, string> OperasyonDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Devam", ["2"] = "Duraklatıldı",
        ["3"] = "Kalite kontrol", ["4"] = "Bitti",
    };

    private static readonly Dictionary<string, string> ZamanTurKodlari = new()
        { ["1"] = "Üretim", ["2"] = "Duruş", ["3"] = "Hazırlık" };

    /// <summary>
    /// ÜRÜN AĞACI (BOM) KARTI.
    ///
    /// Maliyet alanları YAZILAMAZ: hesap sonucudur (fn_urun_agaci_maliyet).
    /// Elle girilebilseydi "hesapla" düğmesi ile elle girilen değer arasında
    /// hangisinin geçerli olduğu belirsiz kalırdı.
    /// </summary>
    private static KartTanimi UrunAgaciKarti() => new(
        Ad: "urun-agaci",
        YetkiKodu: "uretim",
        Tablo: "public.urun_agaci",
        LogTabloId: 990,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,
            ["surum"] = (short)1,
            ["ciktiMiktar"] = 1m,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            // Emirde kullanılan ağaç silinemez: emir kendi satırlarını taşısa
            //   da agac_id izini kaybetmek "bu emir hangi tariften çıktı"
            //   sorusunu cevapsız bırakır.
            new("public.uretim_emri", "agac_id", "Bu ağaçtan açılmış üretim emri var."),
            new("public.urun_agaci_satir", "alt_agac_id",
                "Bu ağaç başka bir ağaçta yarı mamul olarak kullanılıyor."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 25,
                Baslik: "Ağaç Kodu", Grup: "Kimlik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 150,
                Baslik: "Ağaç Adı", Grup: "Kimlik"),
            new("stokId", "stok_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_stok_lookup", AramaKaynagi: "stok",
                Baslik: "Mamul (Stok)", Grup: "Kimlik"),
            new("tur", "tur", "kod", SabitKodlar: AgacTurKodlari,
                Baslik: "Tür", Grup: "Kimlik"),
            new("ciktiMiktar", "cikti_miktar", "sayi",
                Baslik: "Çıktı Miktarı", Grup: "Kimlik"),
            new("surum", "surum", "sayi", Baslik: "Sürüm", Grup: "Kimlik"),
            new("varsayilan", "varsayilan", "mantik",
                Baslik: "Varsayılan", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: AgacDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // ---------------------------------------------------------- tanım
            new("alternatifAd", "alternatif_ad", "metin", EnFazlaUzunluk: 100,
                Baslik: "Alternatif Adı", Grup: "Tanım"),
            new("gecerliBas", "gecerli_bas", "tarih",
                Baslik: "Geçerlilik Başlangıç", Grup: "Tanım"),
            new("gecerliBit", "gecerli_bit", "tarih",
                Baslik: "Geçerlilik Bitiş", Grup: "Tanım"),
            new("sarfDepoId", "sarf_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Sarf Deposu (bileşen çıkış)", Grup: "Tanım"),
            new("mamulDepoId", "mamul_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Mamul Deposu (üretim giriş)", Grup: "Tanım"),
            new("fireDepoId", "fire_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Fire Deposu", Grup: "Tanım"),
            new("tavsiyeSatisKatsayi", "tavsiye_satis_katsayi", "sayi",
                Baslik: "Tavsiye Satış Katsayısı", Grup: "Tanım"),
            new("notlar", "notlar", "metin", EnFazlaUzunluk: 500,
                Baslik: "Not", Grup: "Tanım"),

            // -------------------------------------------------------- maliyet
            new("maliyetMalzeme", "maliyet_malzeme", "para", Yazilabilir: false,
                Baslik: "Malzeme", Grup: "Maliyet"),
            new("maliyetIscilik", "maliyet_iscilik", "para", Yazilabilir: false,
                Baslik: "İşçilik", Grup: "Maliyet"),
            new("maliyetGug", "maliyet_gug", "para", Yazilabilir: false,
                Baslik: "Genel Üretim Gideri", Grup: "Maliyet"),
            new("maliyetToplam", "maliyet_toplam", "para", Yazilabilir: false,
                Baslik: "Toplam Birim Maliyet", Grup: "Maliyet"),
            new("maliyetTarih", "maliyet_tarih", "tarih", Yazilabilir: false,
                Baslik: "Son Hesap", Grup: "Maliyet"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("bilesenler", "public.urun_agaci_satir", "agac_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("bilesenStokId", "bilesen_stok_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_stok_lookup", AramaKaynagi: "stok",
                    Baslik: "Bileşen"),
                new("tur", "tur", "kod", SabitKodlar: BilesenTurKodlari, Baslik: "Tip"),
                new("miktar", "miktar", "sayi", Baslik: "Miktar"),
                new("fireYuzde", "fire_yuzde", "sayi", Baslik: "Fire %"),
                // Yarı mamulün KENDİ ağacı: emirde ya stoktan karşılanır ya da
                //   alt emir açılır. Boşsa satır sıradan bir stok kalemidir.
                new("altAgacId", "alt_agac_id", "kod",
                    KodTablosu: "public.v_urun_agaci_lookup", Baslik: "Alt Ağaç"),
                new("operasyonSira", "operasyon_sira", "sayi", Baslik: "Opr."),
                new("depoId", "depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                    Baslik: "Depo"),
                new("alternatifGrup", "alternatif_grup", "metin", EnFazlaUzunluk: 20,
                    Baslik: "Alternatif Grup"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Bileşenler",
               LogTabloId: 991),

            new("operasyonlar", "public.urun_agaci_operasyon", "agac_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                    Baslik: "Operasyon"),
                new("isMerkeziId", "is_merkezi_id", "kod",
                    KodTablosu: "public.v_is_merkezi_lookup", Baslik: "İş Merkezi"),
                new("hazirlikDk", "hazirlik_dk", "sayi", Baslik: "Hazırlık (dk)"),
                new("birimSureDk", "birim_sure_dk", "sayi", Baslik: "Birim Süre (dk)"),
                // Boş (0) bırakılırsa iş merkezinin ücreti kullanılır - ücreti
                //   iki yerde tutmamak için satıra kopyalanmaz.
                new("saatUcreti", "saat_ucreti", "para", Baslik: "Saat Ücreti"),
                new("kaliteKontrol", "kalite_kontrol", "mantik", Baslik: "KK"),
                new("fason", "fason", "mantik", Baslik: "Fason"),
                new("fasonTarafId", "fason_taraf_id", "kod",
                    KodTablosu: "public.v_cari_lookup", AramaKaynagi: "cari",
                    Baslik: "Fason Tedarikçi"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Operasyonlar / Rota",
               LogTabloId: 992),
        });

    /// <summary>
    /// ÜRETİM EMRİ KARTI.
    ///
    /// <para><b>Gerçek maliyet yazılamaz.</b> gercek_* alanları sarf fişleri ve
    /// zaman kayıtlarından toplanır; elle girilebilseydi "61.400 nereden geldi"
    /// sorusunun cevabı kalmazdı.</para>
    /// </summary>
    private static KartTanimi UretimEmriKarti() => new(
        Ad: "uretim-emri",
        YetkiKodu: "uretim",
        Tablo: "public.uretim_emri",
        LogTabloId: 993,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)2,          // stoğa
            ["durum"] = (short)1,        // taslak
            ["sarfModu"] = (short)1,     // tek seferde
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // EMİR NO SUNUCUDA ÜRETİLİR (fn_uretim_emri_no): elle yazılabilseydi
            //   iki emir aynı numarayı alabilirdi.
            new("no", "no", "metin", Yazilabilir: false, EnFazlaUzunluk: 30,
                Baslik: "Emir No", Grup: "Kimlik"),
            new("stokId", "stok_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_stok_lookup", AramaKaynagi: "stok",
                Baslik: "Mamul", Grup: "Kimlik"),
            new("agacId", "agac_id", "kod", KodTablosu: "public.v_urun_agaci_lookup",
                Baslik: "Ürün Ağacı", Grup: "Kimlik"),
            new("agacSurum", "agac_surum", "sayi", Yazilabilir: false,
                Baslik: "Sürüm", Grup: "Kimlik"),
            new("adet", "adet", "sayi", Zorunlu: true,
                Baslik: "Emir Adedi", Grup: "Kimlik"),
            new("uretilenAdet", "uretilen_adet", "sayi", Yazilabilir: false,
                Baslik: "Üretilen", Grup: "Kimlik"),
            new("durum", "durum", "kod", Yazilabilir: false,
                SabitKodlar: EmirDurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            new("termin", "termin", "tarih", Baslik: "Termin", Grup: "Kimlik"),

            // ----------------------------------------------------------- plan
            new("tur", "tur", "kod", SabitKodlar: EmirTurKodlari,
                Baslik: "Tür", Grup: "Plan"),
            new("oncelik", "oncelik", "kod", SabitKodlar: EmirOncelikKodlari,
                Baslik: "Öncelik", Grup: "Plan"),
            new("planBas", "plan_bas", "tarih",
                Baslik: "Planlanan Başlangıç", Grup: "Plan"),
            new("gercekBas", "gercek_bas", "tarih", Yazilabilir: false,
                Baslik: "Gerçek Başlangıç", Grup: "Plan"),
            new("gercekBit", "gercek_bit", "tarih", Yazilabilir: false,
                Baslik: "Gerçek Bitiş", Grup: "Plan"),
            new("sarfDepoId", "sarf_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Sarf Deposu", Grup: "Plan"),
            new("mamulDepoId", "mamul_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Mamul Deposu", Grup: "Plan"),
            new("fireDepoId", "fire_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Fire Deposu", Grup: "Plan"),
            new("sarfModu", "sarf_modu", "kod", SabitKodlar: SarfModuKodlari,
                Baslik: "Sarf Modu", Grup: "Plan"),
            new("mamulLot", "mamul_lot", "metin", EnFazlaUzunluk: 40,
                Baslik: "Mamul Lot / Seri", Grup: "Plan"),
            new("sorumluId", "sorumlu_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Sorumlu", Grup: "Plan"),
            new("talepEdenId", "talep_eden_id", "kod",
                KodTablosu: "public.v_personel_lookup",
                Baslik: "Talep Eden", Grup: "Plan"),

            // --------------------------------------------------------- kaynak
            new("kaynakBelgeId", "kaynak_belge_id", "sayi",
                Baslik: "Kaynak Belge (Id)", Grup: "Kaynak"),
            new("kaynakSatirId", "kaynak_satir_id", "sayi",
                Baslik: "Kaynak Satır (Id)", Grup: "Kaynak"),
            new("ustEmirId", "ust_emir_id", "kod",
                KodTablosu: "public.v_uretim_emri_lookup",
                Baslik: "Üst Emir", Grup: "Kaynak"),
            new("projeId", "proje_id", "kod", KodTablosu: "public.v_proje_lookup",
                Baslik: "Proje", Grup: "Kaynak"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 500,
                Baslik: "Üretim Notu (iş emri formunda basılır)", Grup: "Kaynak"),
            new("dahiliNot", "dahili_not", "metin", EnFazlaUzunluk: 500,
                Baslik: "Dahili Not", Grup: "Kaynak"),
            new("iptalNeden", "iptal_neden", "metin", Yazilabilir: false,
                EnFazlaUzunluk: 300, Baslik: "İptal Nedeni", Grup: "Kaynak"),

            // -------------------------------------------------------- maliyet
            new("planMalzeme", "plan_malzeme", "para", Yazilabilir: false,
                Baslik: "Plan Malzeme", Grup: "Maliyet"),
            new("planIscilik", "plan_iscilik", "para", Yazilabilir: false,
                Baslik: "Plan İşçilik", Grup: "Maliyet"),
            new("planToplam", "plan_toplam", "para", Yazilabilir: false,
                Baslik: "Plan Toplam", Grup: "Maliyet"),
            new("gercekMalzeme", "gercek_malzeme", "para", Yazilabilir: false,
                Baslik: "Gerçek Malzeme", Grup: "Maliyet"),
            new("gercekIscilik", "gercek_iscilik", "para", Yazilabilir: false,
                Baslik: "Gerçek İşçilik", Grup: "Maliyet"),
            new("gercekToplam", "gercek_toplam", "para", Yazilabilir: false,
                Baslik: "Gerçek Toplam", Grup: "Maliyet"),
            new("fireAdet", "fire_adet", "sayi", Yazilabilir: false,
                Baslik: "Fire Adedi", Grup: "Maliyet"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("malzeme", "public.uretim_emri_satir", "emir_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("bilesenStokId", "bilesen_stok_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_stok_lookup", AramaKaynagi: "stok",
                    Baslik: "Bileşen"),
                new("tur", "tur", "kod", SabitKodlar: BilesenTurKodlari, Baslik: "Tip"),
                new("operasyonSira", "operasyon_sira", "sayi", Baslik: "Opr."),
                new("birimIhtiyac", "birim_ihtiyac", "sayi", Baslik: "Birim İhtiyaç"),
                new("fireYuzde", "fire_yuzde", "sayi", Baslik: "Fire %"),
                new("gerekli", "gerekli", "sayi", Baslik: "Gerekli"),
                // Rezerve ve sarf SUNUCUDA hesaplanır (rezerv/sarf uçları):
                //   elle yazılabilseydi stok_durum.rezerve ile emir satırı
                //   birbirini tutmazdı.
                new("rezerve", "rezerve", "sayi", Yazilabilir: false, Baslik: "Rezerve"),
                new("sarfEdilen", "sarf_edilen", "sayi", Yazilabilir: false,
                    Baslik: "Sarf Edilen"),
                new("depoId", "depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                    Baslik: "Depo"),
                new("birimMaliyet", "birim_maliyet", "para", Yazilabilir: false,
                    Baslik: "Birim Maliyet"),
                new("tutar", "tutar", "para", Yazilabilir: false, Baslik: "Tutar"),
                new("altEmirId", "alt_emir_id", "kod",
                    KodTablosu: "public.v_uretim_emri_lookup", Yazilabilir: false,
                    Baslik: "Alt Emir"),
                new("durum", "durum", "kod", Yazilabilir: false,
                    SabitKodlar: EmirSatirDurumKodlari, Baslik: "Durum"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Malzeme",
               LogTabloId: 994),

            new("operasyonlar", "public.uretim_operasyon", "emir_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                    Baslik: "Operasyon"),
                new("isMerkeziId", "is_merkezi_id", "kod",
                    KodTablosu: "public.v_is_merkezi_lookup", Baslik: "İş Merkezi"),
                new("planSaat", "plan_saat", "sayi", Baslik: "Plan (saat)"),
                new("gercekSaat", "gercek_saat", "sayi", Yazilabilir: false,
                    Baslik: "Gerçek (saat)"),
                new("saatUcreti", "saat_ucreti", "para", Baslik: "Saat Ücreti"),
                new("tamamlanan", "tamamlanan", "sayi", Baslik: "Tamamlanan"),
                new("ret", "ret", "sayi", Baslik: "Ret / Fire"),
                new("kkGerekli", "kk_gerekli", "mantik", Baslik: "KK"),
                new("fason", "fason", "mantik", Baslik: "Fason"),
                new("bas", "bas", "tarih", Baslik: "Başlangıç"),
                new("bit", "bit", "tarih", Baslik: "Bitiş"),
                new("durum", "durum", "kod", SabitKodlar: OperasyonDurumKodlari,
                    Baslik: "Durum"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Operasyonlar",
               LogTabloId: 995),

            // İŞÇİLİK MALİYETİNİN KAYNAĞI. Tutar sunucuda süre × ücret olarak
            //   yazılır (UretimUclari); elle girilirse maliyet ile zaman kaydı
            //   ayrışır.
            new("zaman", "public.uretim_zaman", "emir_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tarafId", "taraf_id", "kod",
                    KodTablosu: "public.v_personel_lookup", Baslik: "Personel"),
                new("operasyonId", "operasyon_id", "sayi", Baslik: "Operasyon (Id)"),
                new("bas", "bas", "tarih", Baslik: "Başlangıç"),
                new("bit", "bit", "tarih", Baslik: "Bitiş"),
                new("sureSaat", "sure_saat", "sayi", Baslik: "Süre (saat)"),
                new("adet", "adet", "sayi", Baslik: "Adet"),
                new("tur", "tur", "kod", SabitKodlar: ZamanTurKodlari, Baslik: "Tür"),
                new("durusKodu", "durus_kodu", "metin", EnFazlaUzunluk: 20,
                    Baslik: "Duruş Kodu"),
                new("saatUcreti", "saat_ucreti", "para", Baslik: "Saat Ücreti"),
                new("tutar", "tutar", "para", Yazilabilir: false, Baslik: "Tutar"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "bas, id", Baslik: "Personel / Zaman",
               LogTabloId: 996),

            // STOK HAREKETLERİ: emrin ürettiği belgeler. SALT OKUNUR - belge
            //   kendi ekranından düzenlenir; üretim emrinden bir irsaliyeyi
            //   değiştirmek, stok hareketini iki yerden yönetmek olurdu.
            new("hareketler", "public.v_uretim_hareket", "emir_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("belgeTarihi", "belge_tarihi", "tarih", Yazilabilir: false,
                    Baslik: "Tarih"),
                new("belgeNo", "belge_no", "metin", Yazilabilir: false, Baslik: "Belge"),
                new("turAdi", "tur_adi", "metin", Yazilabilir: false, Baslik: "Tür"),
                new("depoAdi", "depo_adi", "metin", Yazilabilir: false, Baslik: "Depo"),
                new("satirSayisi", "satir_sayisi", "sayi", Yazilabilir: false,
                    Baslik: "Satır"),
                new("miktar", "miktar", "sayi", Yazilabilir: false, Baslik: "Miktar"),
                new("tutar", "tutar", "para", Yazilabilir: false, Baslik: "Tutar"),
                new("aciklama", "aciklama", "metin", Yazilabilir: false,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "belge_tarihi, id", Baslik: "Stok Hareketleri",
               SaltOkunur: true),

            new("maliyetKapanis", "public.uretim_maliyet", "emir_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("kapanisTarih", "kapanis_tarih", "tarih", Yazilabilir: false,
                    Baslik: "Kapanış"),
                new("malzeme", "malzeme", "para", Yazilabilir: false, Baslik: "Malzeme"),
                new("iscilik", "iscilik", "para", Yazilabilir: false, Baslik: "İşçilik"),
                new("gug", "gug", "para", Yazilabilir: false, Baslik: "GÜG"),
                new("fason", "fason", "para", Yazilabilir: false, Baslik: "Fason"),
                new("fire", "fire", "para", Yazilabilir: false, Baslik: "Fire"),
                new("toplam", "toplam", "para", Yazilabilir: false, Baslik: "Toplam"),
                new("uretilenAdet", "uretilen_adet", "sayi", Yazilabilir: false,
                    Baslik: "Üretilen"),
                new("birim", "birim", "para", Yazilabilir: false, Baslik: "Birim"),
                new("planBirim", "plan_birim", "para", Yazilabilir: false,
                    Baslik: "Plan Birim"),
                new("farkYuzde", "fark_yuzde", "sayi", Yazilabilir: false,
                    Baslik: "Fark %"),
            }, SubeKolonu: null, Sirala: "kapanis_tarih desc, id desc",
               Baslik: "Maliyet Kapanışı", SaltOkunur: true),
        });

    /// <summary>İŞ MERKEZİ KARTI — kapasite ve saat ücreti.</summary>
    private static KartTanimi IsMerkeziKarti() => new(
        Ad: "is-merkezi",
        YetkiKodu: "uretim",
        Tablo: "public.is_merkezi",
        LogTabloId: 997,
        SubeKolonu: "sube_id",
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.urun_agaci_operasyon", "is_merkezi_id",
                "Bu iş merkezi bir ürün ağacı operasyonunda kullanılıyor."),
            new("public.uretim_operasyon", "is_merkezi_id",
                "Bu iş merkezi bir üretim emri operasyonunda kullanılıyor."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 25,
                Baslik: "Kod", Grup: "Kimlik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                Baslik: "İş Merkezi", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: AgacDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            new("lokasyon", "lokasyon", "metin", EnFazlaUzunluk: 100,
                Baslik: "Lokasyon", Grup: "Tanım"),
            new("gunlukKapasiteSaat", "gunluk_kapasite_saat", "sayi",
                Baslik: "Günlük Kapasite (saat)", Grup: "Tanım"),
            new("saatUcreti", "saat_ucreti", "para",
                Baslik: "Saat Ücreti", Grup: "Tanım"),
            new("fason", "fason", "mantik", Baslik: "Fason", Grup: "Tanım"),
            new("fasonTarafId", "fason_taraf_id", "kod",
                KodTablosu: "public.v_cari_lookup", AramaKaynagi: "cari",
                Baslik: "Fason Tedarikçi", Grup: "Tanım"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Tanım"),
        });
}
