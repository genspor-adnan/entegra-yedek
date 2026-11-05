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
        ["0"] = "İptal", ["1"] = "Taslak", ["2"] = "Onaylı", ["3"] = "Serbest bırakıldı",
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
            ["agacSurum"] = (short)1,
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
            // AD "agacSurum" (1258): kart yanıtının eşzamanlılık damgası da `surum` - aynı adla ekranda sürüm kutusu
            //   xmin'i gösteriyordu ("1322679"). Yeni sürüm ucu numarayı kendisi verir; kartta salt okunur.
            new("agacSurum", "surum", "sayi", Yazilabilir: false, Baslik: "Sürüm", Grup: "Kimlik"),
            new("varsayilan", "varsayilan", "mantik",
                Baslik: "Varsayılan", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: AgacDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // ---------------------------------------------------------- tanım
            // KİMLİK ŞERİDİNDE (1259, mockup urun_agaci_karti_v2.html): mockup'ta "Tanım" sekmesi yok - geçerlilik,
            //   depolar, katsayı ve not başlık ızgarasında; sekmeler Bileşenler'den başlar. Basit seviyede web gizler.
            new("gecerliBas", "gecerli_bas", "tarih",
                Baslik: "Geçerlilik Başlangıç", Grup: "Kimlik"),
            new("gecerliBit", "gecerli_bit", "tarih",
                Baslik: "Geçerlilik Bitiş", Grup: "Kimlik"),
            new("sarfDepoId", "sarf_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Sarf Deposu (bileşen çıkış)", Grup: "Kimlik"),
            new("mamulDepoId", "mamul_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Mamul Deposu (üretim giriş)", Grup: "Kimlik"),
            new("fireDepoId", "fire_depo_id", "kod", KodTablosu: "public.v_depo_lookup",
                Baslik: "Fire Deposu", Grup: "Kimlik"),
            new("tavsiyeSatisKatsayi", "tavsiye_satis_katsayi", "sayi",
                Baslik: "Tavsiye Satış Katsayısı", Grup: "Kimlik"),
            // ONAY AKIŞI (1257/1258, denetimli - mockup urun_agaci_karti_v2.html): uçlardan yazılır, kartta salt okunur.
            //   Web basit / standartta gizler (uretimListeSeviye kartAlanlari).
            new("onayDurum", "onay_durum", "kod", Yazilabilir: false, Baslik: "Onay",
                SabitKodlar: new Dictionary<string, string>
                { ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylı", ["3"] = "Kilitli" }, Grup: "Kimlik"),
            new("ecnNo", "ecn_no", "metin", Yazilabilir: false, EnFazlaUzunluk: 30, Baslik: "ECN No", Grup: "Kimlik"),
            new("yururluk", "yururluk", "tarih", Yazilabilir: false, Baslik: "Yürürlük", Grup: "Kimlik"),
            new("partiBuyuklugu", "parti_buyuklugu", "sayi", Baslik: "Parti Büyüklüğü (std.)", Grup: "Kimlik",
                Ipucu: "Standart parti adedi - kalite örneklemi ve planlama bu adede göre."),
            new("rafOmruAy", "raf_omru_ay", "sayi", Baslik: "Raf Ömrü (ay)", Grup: "Kimlik"),
            new("alternatifAd", "alternatif_ad", "metin", EnFazlaUzunluk: 100,
                Baslik: "Alternatif Adı", Grup: "Kimlik"),
            new("pasifNeden", "pasif_neden", "metin", Yazilabilir: false, EnFazlaUzunluk: 300, Baslik: "Pasife Alma Nedeni", Grup: "Kimlik"),
            // TEK SATIR (kullanıcı 04.11.2026 "notlar alanı tek satır yükseklikte olsun"): 400 ve üstü uzunluk web'de
            //   çok satırlı kutu çizer; reçete notu kısa - 300 (kolon 500 kalır).
            new("notlar", "notlar", "metin", EnFazlaUzunluk: 300,
                Baslik: "Not", Grup: "Kimlik"),

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
                // GÖRÜNEN KOD · AD · BİRİM (1259, mockup "HM-0101 · Ceviz Kereste 40x60 · Metre"): stok lookup'ı büyük,
                //   grid kimliği çözemiyordu ("4297"). Web gridde kimliği gizler, bu üçünü gösterir.
                new("bilesenKod", "(select x.kod from public.stok x where x.id = urun_agaci_satir.bilesen_stok_id)",
                    "metin", Yazilabilir: false, Baslik: "Kod"),
                new("bilesenAd", "(select x.ad from public.stok x where x.id = urun_agaci_satir.bilesen_stok_id)",
                    "metin", Yazilabilir: false, Baslik: "Bileşen Adı"),
                new("birimAdi", "(select kd.ad from public.stok x join public.kod_liste kl on kl.kod = 'stok.ana_birim' "
                                + "join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = x.ana_birim and kd.dil = 0 "
                                + "where x.id = urun_agaci_satir.bilesen_stok_id limit 1)",
                    "metin", Yazilabilir: false, Baslik: "Birim"),
                new("tur", "tur", "kod", SabitKodlar: BilesenTurKodlari, Baslik: "Tip"),
                new("miktar", "miktar", "sayi", Baslik: "Miktar"),
                new("fireYuzde", "fire_yuzde", "sayi", Baslik: "Fire %"),
                // HESAP KOLONLARI (1259, mockup bileşen satırı): net gerekli, stoktaki (sarf deposu, yoksa hepsi),
                //   birim maliyet (son / ortalama - fn_uretim_stok_son_maliyeti) ve tutar. Salt okunur, kayda gitmez.
                new("netGerekli", "round(urun_agaci_satir.miktar * (1 + coalesce(urun_agaci_satir.fire_yuzde, 0) / 100), 4)",
                    "sayi", Yazilabilir: false, Baslik: "Net Gerekli"),
                new("stokta", "(select coalesce(sum(d.kalan - coalesce(d.rezerve, 0)), 0) from public.stok_durum d "
                              + "where d.stok_id = urun_agaci_satir.bilesen_stok_id and (urun_agaci_satir.depo_id is null or d.depo_id = urun_agaci_satir.depo_id))",
                    "sayi", Yazilabilir: false, Baslik: "Stokta"),
                new("birimMaliyet", "coalesce(public.fn_uretim_stok_son_maliyeti(urun_agaci_satir.bilesen_stok_id), 0)",
                    "para", Yazilabilir: false, Baslik: "Birim Maliyet"),
                new("tutar", "round(urun_agaci_satir.miktar * (1 + coalesce(urun_agaci_satir.fire_yuzde, 0) / 100) "
                             + "* coalesce(public.fn_uretim_stok_son_maliyeti(urun_agaci_satir.bilesen_stok_id), 0), 2)",
                    "para", Yazilabilir: false, Baslik: "Tutar"),
                // KRİTİK (1259, denetimli): lot / kalite takibi zorunlu bileşen.
                new("kritik", "kritik", "mantik", Baslik: "Kritik"),
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
                // İŞÇİLİK / ADET (1259, mockup): birim süre × saat ücreti (ücret boşsa iş merkezinin ücreti).
                new("iscilikAdet", "round(coalesce(urun_agaci_operasyon.birim_sure_dk, 0) / 60.0 * coalesce(nullif(urun_agaci_operasyon.saat_ucreti, 0), "
                                   + "(select im.saat_ucreti from public.is_merkezi im where im.id = urun_agaci_operasyon.is_merkezi_id), 0), 2)",
                    "para", Yazilabilir: false, Baslik: "İşçilik / adet"),
                new("kaliteKontrol", "kalite_kontrol", "mantik", Baslik: "KK"),
                new("fason", "fason", "mantik", Baslik: "Fason"),
                new("fasonTarafId", "fason_taraf_id", "kod",
                    KodTablosu: "public.v_cari_lookup", AramaKaynagi: "cari",
                    Baslik: "Fason Tedarikçi"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                    Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Operasyonlar / Rota",
               LogTabloId: 992),

            // KONTROL LİSTESİ (1258, denetimli): tür 1 ön kontrol (emir serbest bırakma öncesi), 2 kalite kontrolü
            //   (fiş karantina → serbest). Emir / fişe kopyalanır. Basit / standart sekmeyi gizler (web).
            new("kontroller", "public.urun_agaci_kontrol", "agac_id", new KartAlani[]
            {
                new("id",       "id",        "sayi",  Yazilabilir: false),
                new("tur",      "tur",       "kod",   Zorunlu: true, Baslik: "Tür",
                    SabitKodlar: new Dictionary<string, string> { ["1"] = "Ön kontrol (emir)", ["2"] = "Kalite (fiş)" }),
                new("sira",     "sira",      "sayi",  Baslik: "Sıra"),
                new("ad",       "ad",        "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Kontrol"),
                new("olcut",    "olcut",     "metin", EnFazlaUzunluk: 300, Baslik: "Ölçüt / nasıl doğrulanır"),
                new("orneklem", "orneklem",  "metin", EnFazlaUzunluk: 40, Baslik: "Örneklem"),
                new("zorunlu",  "zorunlu",   "mantik", Baslik: "Zorunlu"),
                new("otomatik", "otomatik",  "kod",   Baslik: "Otomatik",
                    SabitKodlar: new Dictionary<string, string>
                    { [""] = "Elle", ["malzeme"] = "Malzeme hazırlığı", ["agac"] = "Reçete onaylı", ["rota"] = "Rota / iş merkezi",
                      ["kapasite"] = "Kapasite", ["ekipman"] = "Ekipman kalibrasyonu", ["personel"] = "Personel yetkinliği", ["ortam"] = "Ortam" }),
                new("retIslem", "ret_islem", "metin", EnFazlaUzunluk: 150, Baslik: "Ret halinde"),
                new("aciklama", "aciklama",  "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
            }, SubeKolonu: null, Sirala: "tur, sira, id", Baslik: "Kontrol Listesi", LogTabloId: 998),
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
                // GÖRÜNEN KOD · AD · BİRİM (1259, mockup "HM-0101 · Ceviz Kereste 40x60 · Metre"): stok lookup'ı büyük,
                //   grid kimliği çözemiyordu ("4297"). Web gridde kimliği gizler, bu üçünü gösterir.
                new("bilesenKod", "(select x.kod from public.stok x where x.id = uretim_emri_satir.bilesen_stok_id)",
                    "metin", Yazilabilir: false, Baslik: "Kod"),
                new("bilesenAd", "(select x.ad from public.stok x where x.id = uretim_emri_satir.bilesen_stok_id)",
                    "metin", Yazilabilir: false, Baslik: "Bileşen Adı"),
                new("birimAdi", "(select kd.ad from public.stok x join public.kod_liste kl on kl.kod = 'stok.ana_birim' "
                                + "join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = x.ana_birim and kd.dil = 0 "
                                + "where x.id = uretim_emri_satir.bilesen_stok_id limit 1)",
                    "metin", Yazilabilir: false, Baslik: "Birim"),
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
                // OPERASYON SEÇİCİ (1264): ham kimlik yerine emrin operasyonları. ust_id = emir;
                //   UstBilgisi haritayı açar, kart `ustSuzgec` ile kendi emrine daraltır
                //   (kartEklentileri 'uretim-emri'). Satırda emir alanı yok, bu yüzden BagliAlan değil.
                new("operasyonId", "operasyon_id", "kod",
                    KodTablosu: "public.v_uretim_operasyon_lookup", UstBilgisi: true,
                    Baslik: "Operasyon"),
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
        YetkiKodu: "uretim.is_merkezi",   // 1004 aşama 2: kendi kodu
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
