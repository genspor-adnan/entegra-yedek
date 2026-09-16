namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DİŞ KLİNİĞİ KARTLARI (706) — mockuplar <c>Ekranlar/Dis Klinigi/*.html</c>.
///
/// <para><b>Tedavi planı kartı</b> = başlık + satır detayı (faz · diş · yüzey ·
/// işlem · seans · fiyat). Satır fiyatı hizmetin fiyat listesi değerinden
/// gelir; onaylı planda satır fiyatı değişmez (dis_sureci: "onaylı satır
/// fiyatı değişmez"), o kural uçta.</para>
///
/// <para><b>Seans kartı</b> = ünitte geçen oturum: uygulanan işlemler (plan
/// satırı bağlı), sarf ve anestezi. "Seansı bitir" aksiyonu ücret satırını
/// doğurur - kartın kendisi para yazmaz.</para>
///
/// <para><b>Lab iş emri</b> aşama detayıyla: "ölçü → gönderildi → tasarım →
/// üretim → geldi → prova → teslim" her adımı zaman damgalı satırdır, tek bir
/// aşama kolonu geçmişi kaybederdi.</para>
/// </summary>
public static partial class KartKatalogu
{
    // ISLEMLOG tablo kodları — 1130 bloğu dişe ayrıldı (göz 1100, yatan 1120).
    private const int LogDisPlan        = 1130;
    private const int LogDisPlanSatir   = 1131;
    private const int LogDisSeans       = 1132;
    private const int LogDisSeansDetay  = 1133;
    private const int LogDisLabIsemri   = 1134;
    private const int LogDisLabAsama    = 1135;
    private const int LogDisUnit        = 1136;
    private const int LogDisLab         = 1137;
    private const int LogDisOdemePlani  = 1138;
    private const int LogDisOdemeTaksit = 1139;

    private static readonly Dictionary<string, string> DisVaryantKodlari =
        new() { ["A"] = "A (ana plan)", ["B"] = "B (alternatif)" };

    private static readonly Dictionary<string, string> DisSarfKaynakKodlari =
        new() { ["1"] = "İşlem seti", ["2"] = "Elle", ["3"] = "Barkod" };

    private static readonly Dictionary<string, string> DisTaksitDurumKodlari =
        new() { ["1"] = "Bekliyor", ["2"] = "Ödendi", ["3"] = "Gecikti" };

    private static readonly Dictionary<string, string> DisOdemeDurumKodlari =
        new() { ["1"] = "Açık", ["2"] = "Tamamlandı", ["3"] = "İptal" };

    // ======================================================== tedavi planı ====
    private static KartTanimi DisPlanKarti() => new(
        Ad: "dis-plan",
        // Sil arac cubugunda (kullanici): seansi / odeme plani olan plan silinmez, iptal edilir; yapilmis satir DB tetiginde (720).
        SilmeEngelleri: new SilmeEngeli[] { new("public.dis_seans", "plan_id", "Plana bağlı seans var; plan silinmez, \"İptal\" ile kapatın."), new("public.dis_odeme_plani", "plan_id", "Planın ödeme planı var; önce onu silin.") },
        YetkiKodu: "dis.plan",
        Tablo: "public.dis_tedavi_plani",
        LogTabloId: LogDisPlan,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["varyant"] = "A",
            ["durum"] = (short)1,
        },
        AcilistaTarafSecimi: "hastaId",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // Plan numarası SUNUCUDA üretilir (fn_dis_no_uret): iki masadan
            //   aynı anda açılan iki plan aynı numarayı almasın.
            new("planNo", "plan_no", "metin", Yazilabilir: false, Baslik: "Plan No", Grup: "Genel"),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Genel"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Hekim", Grup: "Genel"),
            new("muayeneId", "muayene_id", "sayi", Baslik: "Muayene", Grup: "Genel"),
            new("varyant", "varyant", "kod", SabitKodlar: DisVaryantKodlari, Baslik: "Varyant", Grup: "Genel"),
            new("anaPlanId", "ana_plan_id", "kod", KodTablosu: "public.v_dis_plan_lookup",
                Baslik: "Ana Plan (B için)", Grup: "Genel"),
            new("durum", "durum", "kod", KodListesi: "dis.plan_durum", Baslik: "Durum", Grup: "Genel"),
            new("fiyatListesiId", "fiyat_listesi_id", "kod", KodTablosu: "public.v_fiyat_listesi_lookup",
                Baslik: "Fiyat Listesi", Grup: "Fiyat & Onay"),
            new("odeyenKurumId", "odeyen_kurum_id", "kod", KodTablosu: "public.v_kurum_lookup",
                Baslik: "Ödeyen Kurum", Grup: "Fiyat & Onay"),
            // Toplamlar satırlardan türetilir (fn_dis_plan_toplam_tazele).
            new("toplam", "toplam", "para", Yazilabilir: false, Baslik: "Toplam", Grup: "Fiyat & Onay"),
            new("indirim", "indirim", "para", Yazilabilir: false, Baslik: "İndirim", Grup: "Fiyat & Onay"),
            new("net", "net", "para", Yazilabilir: false, Baslik: "Net", Grup: "Fiyat & Onay"),
            new("odemeSecenegi", "odeme_secenegi", "metin", EnFazlaUzunluk: 120,
                Baslik: "Ödeme Seçeneği", Grup: "Fiyat & Onay"),
            new("taksitSayisi", "taksit_sayisi", "sayi", Baslik: "Taksit", Grup: "Fiyat & Onay"),
            new("proformaNo", "proforma_no", "metin", EnFazlaUzunluk: 30, Baslik: "Proforma No", Grup: "Fiyat & Onay"),
            new("gecerlilikBitis", "gecerlilik_bitis", "tarih", Baslik: "Geçerlilik", Grup: "Fiyat & Onay"),
            new("hastaOnayZamani", "hasta_onay_zamani", "zaman", Yazilabilir: false,
                Baslik: "Hasta Onayı", Grup: "Fiyat & Onay"),
            new("onayYontemi", "onay_yontemi", "metin", EnFazlaUzunluk: 20, Yazilabilir: false,
                Baslik: "Onay Yöntemi", Grup: "Fiyat & Onay"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Genel"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("satirlar", "public.dis_tedavi_plani_satir", "plan_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("faz", "faz", "kod", KodListesi: "dis.faz", Baslik: "Faz"),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("disNo", "dis_no", "sayi", Baslik: "Diş"),
                new("disNolar", "dis_nolar", "metin", EnFazlaUzunluk: 120, Baslik: "Dişler (köprü)"),
                new("yuzeyler", "yuzeyler", "metin", EnFazlaUzunluk: 8, Baslik: "Yüzey"),
                new("hizmetId", "hizmet_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_dis_islem_lookup", Baslik: "İşlem"),
                new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup", Baslik: "Hekim"),
                new("seansSayisi", "seans_sayisi", "sayi", Baslik: "Seans"),
                new("yapilanSeans", "yapilan_seans", "sayi", Yazilabilir: false, Baslik: "Yapılan"),
                new("listeFiyat", "liste_fiyat", "para", Baslik: "Liste"),
                new("iskonto", "iskonto", "para", Baslik: "İnd."),
                new("net", "net", "para", Baslik: "Net"),
                new("ucretKurali", "ucret_kurali", "kod", KodListesi: "dis.ucret_kurali", Baslik: "Ücretlendirme"),
                new("labGerekir", "lab_gerekir", "mantik", Baslik: "Lab"),
                new("onamTur", "onam_tur", "kod", KodListesi: "dis.onam_tur", Baslik: "Onam"),
                new("durum", "durum", "kod", KodListesi: "dis.satir_durum", Baslik: "Durum"),
                new("tamamlanma", "tamamlanma", "zaman", Yazilabilir: false, Baslik: "Tamamlanma"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            }, Sirala: "faz, sira, id", LogTabloId: LogDisPlanSatir, Baslik: "Plan Satırları"),
        });

    // =============================================================== seans ====
    private static KartTanimi DisSeansKarti() => new(
        Ad: "dis-seans",
        YetkiKodu: "dis.seans",
        Tablo: "public.dis_seans",
        LogTabloId: LogDisSeans,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        AcilistaTarafSecimi: "hastaId",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Seans"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup", Baslik: "Hekim", Grup: "Seans"),
            new("asistanId", "asistan_id", "kod", KodTablosu: "public.v_personel_lookup", Baslik: "Asistan", Grup: "Seans"),
            new("unitId", "unit_id", "kod", KodTablosu: "public.v_dis_unit_lookup", Baslik: "Ünit", Grup: "Seans"),
            new("planId", "plan_id", "kod", KodTablosu: "public.v_dis_plan_lookup", Baslik: "Tedavi Planı", Grup: "Seans"),
            new("randevuId", "randevu_id", "sayi", Baslik: "Randevu", Grup: "Seans"),
            new("belgeId", "belge_id", "sayi", Baslik: "Başvuru", Grup: "Seans"),
            new("baslangic", "baslangic", "zaman", Baslik: "Başlangıç", Grup: "Seans"),
            new("bitis", "bitis", "zaman", Baslik: "Bitiş", Grup: "Seans"),
            new("sureDk", "sure_dk", "sayi", Baslik: "Süre (dk)", Grup: "Seans"),
            new("durum", "durum", "kod", KodListesi: "dis.seans_durum", Baslik: "Durum", Grup: "Seans"),
            new("sterilizasyonPaket", "sterilizasyon_paket", "metin", EnFazlaUzunluk: 30,
                Baslik: "Sterilizasyon Paketi", Grup: "Seans"),

            new("uygulamaNotu", "uygulama_notu", "metin", EnFazlaUzunluk: 1000, Baslik: "Uygulama Notu", Grup: "Uygulama"),
            new("komplikasyon", "komplikasyon", "metin", EnFazlaUzunluk: 300, Baslik: "Komplikasyon", Grup: "Uygulama"),
            new("hastayaTalimat", "hastaya_talimat", "metin", EnFazlaUzunluk: 400, Baslik: "Hastaya Talimat", Grup: "Uygulama"),
            new("sonrakiPlan", "sonraki_plan", "metin", EnFazlaUzunluk: 300, Baslik: "Sonraki Seans Planı", Grup: "Uygulama"),

            new("anesteziTur", "anestezi_tur", "metin", EnFazlaUzunluk: 60, Baslik: "Anestezi Türü", Grup: "Anestezi"),
            new("anesteziIlac", "anestezi_ilac", "metin", EnFazlaUzunluk: 80, Baslik: "İlaç", Grup: "Anestezi"),
            new("anesteziDoz", "anestezi_doz", "metin", EnFazlaUzunluk: 40, Baslik: "Doz", Grup: "Anestezi"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("islemler", "public.dis_seans_islem", "seans_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("hizmetId", "hizmet_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_dis_islem_lookup", Baslik: "İşlem"),
                new("planSatirId", "plan_satir_id", "sayi", Baslik: "Plan Satırı"),
                new("disNo", "dis_no", "sayi", Baslik: "Diş"),
                new("yuzeyler", "yuzeyler", "metin", EnFazlaUzunluk: 8, Baslik: "Yüzey"),
                new("seansNo", "seans_no", "sayi", Baslik: "Seans No"),
                new("tamamlandi", "tamamlandi", "mantik", Baslik: "Bu seansta tamamlandı"),
                new("notMetin", "not_metin", "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            }, Sirala: "id", LogTabloId: LogDisSeansDetay, Baslik: "Yapılan İşlemler"),

            new("sarf", "public.dis_seans_sarf", "seans_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "kod", Zorunlu: true, KodTablosu: "public.v_stok_lookup",
                    AramaKaynagi: "stok", Baslik: "Malzeme"),
                new("miktar", "miktar", "ondalik", Baslik: "Miktar"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                new("kaynak", "kaynak", "kod", SabitKodlar: DisSarfKaynakKodlari, Baslik: "Kaynak"),
                new("maliyet", "maliyet", "para", Baslik: "Maliyet"),
            }, Sirala: "id", LogTabloId: LogDisSeansDetay, Baslik: "Malzeme & Sarf"),
        });

    // ======================================================== lab iş emri ====
    private static KartTanimi DisLabIsemriKarti() => new(
        Ad: "dis-lab-isemri",
        YetkiKodu: "dis.lab",
        Tablo: "public.dis_lab_isemri",
        LogTabloId: LogDisLabIsemri,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["asama"] = (short)1, ["isTuru"] = (short)1, ["olcuTipi"] = (short)1,
        },
        AcilistaTarafSecimi: "hastaId",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("isemriNo", "isemri_no", "metin", Yazilabilir: false, Baslik: "İş Emri No", Grup: "İş"),
            new("labId", "lab_id", "kod", Zorunlu: true, KodTablosu: "public.v_dis_lab_lookup",
                Baslik: "Laboratuvar", Grup: "İş"),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta", Grup: "İş"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup", Baslik: "Hekim", Grup: "İş"),
            new("planSatirId", "plan_satir_id", "sayi", Baslik: "Plan Satırı", Grup: "İş"),
            new("isTuru", "is_turu", "kod", KodListesi: "dis.lab_is_turu", Baslik: "İş Türü", Grup: "İş"),
            new("disNolar", "dis_nolar", "metin", EnFazlaUzunluk: 120, Baslik: "Diş / Üye", Grup: "İş"),
            new("malzeme", "malzeme", "metin", EnFazlaUzunluk: 80, Baslik: "Malzeme", Grup: "İş"),
            new("renk", "renk", "metin", EnFazlaUzunluk: 20, Baslik: "Renk (Vita)", Grup: "İş"),
            new("olcuTipi", "olcu_tipi", "kod", KodListesi: "dis.olcu_tipi", Baslik: "Ölçü Tipi", Grup: "İş"),
            new("ekIstek", "ek_istek", "metin", EnFazlaUzunluk: 400, Baslik: "Ek İstekler", Grup: "İş"),

            new("asama", "asama", "kod", KodListesi: "dis.lab_asama", Baslik: "Aşama", Grup: "Takip"),
            new("gonderimTarihi", "gonderim_tarihi", "tarih", Baslik: "Gönderim", Grup: "Takip"),
            new("beklenenTarih", "beklenen_tarih", "tarih", Baslik: "Beklenen", Grup: "Takip"),
            new("teslimTarihi", "teslim_tarihi", "tarih", Baslik: "Teslim", Grup: "Takip"),
            new("kaliteKontrol", "kalite_kontrol", "mantik", Baslik: "Kalite Kontrol", Grup: "Takip"),
            new("garantiBitis", "garanti_bitis", "tarih", Baslik: "Garanti Bitişi", Grup: "Takip"),

            new("labFiyat", "lab_fiyat", "para", Baslik: "Lab Fiyatı", Grup: "Maliyet"),
            new("hastaFiyat", "hasta_fiyat", "para", Baslik: "Hastaya Yansıyan", Grup: "Maliyet"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Maliyet"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("asamalar", "public.dis_lab_isemri_asama", "isemri_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("asama", "asama", "kod", KodListesi: "dis.lab_asama", Baslik: "Aşama"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("notMetin", "not_metin", "metin", EnFazlaUzunluk: 300, Baslik: "Not"),
            }, Sirala: "zaman, id", LogTabloId: LogDisLabAsama, Baslik: "Aşama Geçmişi"),
        });

    // ================================================================ ünit ====
    private static KartTanimi DisUnitKarti() => new(
        Ad: "dis-unit",
        SilmeEngelleri: new SilmeEngeli[] { new("public.dis_seans", "unit_id", "Ünitte seans geçmişi var; silinmez, pasife alın.") },
        YetkiKodu: "dis.unit",
        Tablo: "public.dis_unit",
        LogTabloId: LogDisUnit,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kod"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Ad"),
            new("tur", "tur", "kod", KodListesi: "dis.unit_tur", Baslik: "Tür"),
            new("varsayilanHekimId", "varsayilan_hekim_id", "kod", KodTablosu: "public.v_hekim_lookup",
                Baslik: "Varsayılan Hekim"),
            new("depoId", "depo_id", "kod", KodTablosu: "public.v_depo_lookup", Baslik: "Sarf Deposu"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif"),
        });

    // ============================================================ laboratuvar ====
    private static KartTanimi DisLabKarti() => new(
        Ad: "dis-lab",
        SilmeEngelleri: new SilmeEngeli[] { new("public.dis_lab_isemri", "lab_id", "Laboratuvarın iş emirleri var; silinmez, pasife alın.") },
        YetkiKodu: "dis.unit",
        Tablo: "public.dis_lab",
        LogTabloId: LogDisLab,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["slaGun"] = (short)7, ["aktif"] = (short)1 },
        AcilistaTarafSecimi: "tarafId",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Laboratuvar Adı"),
            new("tarafId", "taraf_id", "kod", Zorunlu: true, KodTablosu: "public.v_cari_lookup",
                AramaKaynagi: "cari", Baslik: "Tedarikçi Cari"),
            new("dijital", "dijital", "mantik", Baslik: "Dijital (STL) alır"),
            new("portalAdres", "portal_adres", "metin", EnFazlaUzunluk: 200, Baslik: "Portal Adresi"),
            new("slaGun", "sla_gun", "sayi", Baslik: "SLA (iş günü)"),
            new("fiyatListesiId", "fiyat_listesi_id", "kod", KodTablosu: "public.v_fiyat_listesi_lookup",
                Baslik: "Lab Fiyat Listesi"),
            new("kuryeGunleri", "kurye_gunleri", "metin", EnFazlaUzunluk: 40, Baslik: "Kurye Günleri"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif"),
        });

    // ========================================================== ödeme planı ====
    private static KartTanimi DisOdemePlaniKarti() => new(
        Ad: "dis-odeme-plani",
        YetkiKodu: "dis.odeme",
        Tablo: "public.dis_odeme_plani",
        LogTabloId: LogDisOdemePlani,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["taksitSayisi"] = (short)1, ["odemeYontemi"] = (short)1, ["durum"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("planId", "plan_id", "kod", Zorunlu: true, KodTablosu: "public.v_dis_plan_lookup",
                Baslik: "Tedavi Planı"),
            new("toplam", "toplam", "para", Baslik: "Toplam"),
            new("pesinat", "pesinat", "para", Baslik: "Peşinat"),
            new("taksitSayisi", "taksit_sayisi", "sayi", Baslik: "Taksit Sayısı"),
            new("taksitTutar", "taksit_tutar", "para", Baslik: "Taksit Tutarı"),
            new("ilkVade", "ilk_vade", "tarih", Baslik: "İlk Vade"),
            new("odemeYontemi", "odeme_yontemi", "kod", KodListesi: "dis.odeme_yontemi", Baslik: "Ödeme Yöntemi"),
            new("durum", "durum", "kod", SabitKodlar: DisOdemeDurumKodlari, Baslik: "Durum"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("taksitler", "public.dis_odeme_taksit", "odeme_plani_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Taksit"),
                new("vade", "vade", "tarih", Zorunlu: true, Baslik: "Vade"),
                new("tutar", "tutar", "para", Baslik: "Tutar"),
                new("odenen", "odenen", "para", Baslik: "Ödenen"),
                new("odemeTarihi", "odeme_tarihi", "tarih", Baslik: "Ödeme Tarihi"),
                new("durum", "durum", "kod", SabitKodlar: DisTaksitDurumKodlari, Baslik: "Durum"),
            }, Sirala: "sira, id", LogTabloId: LogDisOdemeTaksit, Baslik: "Taksitler"),
        });
}
