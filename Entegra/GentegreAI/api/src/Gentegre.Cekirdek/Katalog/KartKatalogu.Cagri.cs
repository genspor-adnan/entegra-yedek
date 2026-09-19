namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ÇAĞRI MERKEZİ (839) kartları: çağrı kaydı (konu / sonuç / not; ilgili
/// kayıtlar ve olaylar salt okunur), konu (alt konular detay), kuyruk, agent,
/// kampanya (kişiler detay). Log tablo kodları 1330 bloğu.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogCagri            = 1330;
    private const int LogCagriIlgili      = 1331;
    private const int LogCagriOlay        = 1332;
    private const int LogCagriKonu        = 1333;
    private const int LogCagriKuyruk      = 1334;
    private const int LogCagriAgent       = 1335;
    private const int LogCagriKampanya    = 1336;
    private const int LogCagriKampanyaKisi = 1337;
    private const int LogCagriKalite      = 1338;

    private static readonly Dictionary<string, string> CagriAktifKodlari = new() { ["1"] = "Aktif", ["0"] = "Pasif" };
    private static readonly Dictionary<string, string> CagriSoftphone = new() { ["1"] = "Masaüstü telefon", ["2"] = "WebRTC (tarayıcı)" };
    private static readonly Dictionary<string, string> CagriKampanyaDurum = new() { ["0"] = "Taslak", ["1"] = "Çalışıyor", ["2"] = "Durdu", ["3"] = "Bitti" };
    private static readonly Dictionary<string, string> CagriKaynaklar = new()
    {
        ["randevu_yarin"] = "Yarınki randevular (planlı)", ["sonuc_hazir"] = "Sonucu hazır, 7 gündür alınmamış", ["taburcu_anket"] = "Son 3 gün taburcu",
        ["vadesi_gecen"] = "Vadesi geçen bakiye (parametre: tutar eşiği)", ["isg_periyodik"] = "İSG periyodik muayene (30 gün)", ["serbest"] = "Serbest liste (elle eklenir)",
    };

    private static KartTanimi CagriKarti() => new(
        Ad: "cagri",
        YetkiKodu: "cagri.kayit",
        Tablo: "public.cagri",
        LogTabloId: LogCagri,
        SubeKolonu: "sube_id",
        AcilistaTarafSecimi: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["kanal"] = (short)1, ["yon"] = (short)2, ["durum"] = (short)4, ["oncelik"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",          "sayi",  Yazilabilir: false),
            new("kanal",      "kanal",       "kod",   Zorunlu: true, KodListesi: "cagri.kanal", Baslik: "Kanal", Grup: "Çağrı"),
            new("yon",        "yon",         "kod",   Zorunlu: true, KodListesi: "cagri.yon", Baslik: "Yön", Grup: "Çağrı"),
            new("arayanNo",   "arayan_no",   "metin", EnFazlaUzunluk: 30, Baslik: "Arayan numara", Grup: "Çağrı"),
            new("tarafId",    "taraf_id",    "kod",   KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Kişi (hasta / cari)", Grup: "Çağrı"),
            new("kuyrukId",   "kuyruk_id",   "kod",   KodTablosu: "public.v_cagri_kuyruk_lookup", Baslik: "Kuyruk", Grup: "Çağrı"),
            new("agentId",    "agent_id",    "kod",   KodTablosu: "public.v_kullanici_lookup", Baslik: "Agent", Grup: "Çağrı"),
            new("durum",      "durum",       "kod",   KodListesi: "cagri.durum", Baslik: "Durum", Grup: "Çağrı"),
            new("oncelik",    "oncelik",     "kod",   KodListesi: "cagri.oncelik", Baslik: "Öncelik", Grup: "Çağrı"),
            new("konuId",     "konu_id",     "kod",   KodTablosu: "public.v_cagri_konu_lookup", Baslik: "Konu", Grup: "Kayıt"),
            new("altKonuId",  "alt_konu_id", "kod",   KodTablosu: "public.v_cagri_altkonu_lookup", BagliAlan: "konuId", Baslik: "Alt konu", Grup: "Kayıt"),
            new("sonuc",      "sonuc",       "kod",   KodListesi: "cagri.sonuc", Baslik: "Sonuç", Grup: "Kayıt"),
            new("notu",       "notu",        "metin", EnFazlaUzunluk: 1200, Baslik: "Not", Grup: "Kayıt"),
            new("memnuniyet", "memnuniyet",  "sayi",  Baslik: "Memnuniyet (1-5)", Grup: "Kayıt"),
            new("kayitUrl",   "kayit_url",   "metin", EnFazlaUzunluk: 300, Baslik: "Ses kaydı bağlantısı", Grup: "Kayıt"),
            new("beklemeSn",  "bekleme_sn",  "sayi",  Yazilabilir: false, Baslik: "Bekleme (sn)", Grup: "Süre"),
            new("sureSn",     "sure_sn",     "sayi",  Yazilabilir: false, Baslik: "Konuşma (sn)", Grup: "Süre"),
            new("baslama",    "baslama",     "zaman", Yazilabilir: false, Baslik: "Başlama", Grup: "Süre"),
            new("bitis",      "bitis",       "zaman", Yazilabilir: false, Baslik: "Bitiş", Grup: "Süre"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("ilgili", "public.cagri_ilgili", "cagri_id", new KartAlani[]
            {
                new("id",         "id",         "sayi",  Yazilabilir: false),
                new("kaynakTur",  "kaynak_tur", "metin", Zorunlu: true, EnFazlaUzunluk: 30, Baslik: "Kaynak"),
                new("kaynakId",   "kaynak_id",  "sayi",  Zorunlu: true, Baslik: "Kayıt no"),
                new("aciklama",   "aciklama",   "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
            }, Sirala: "id", Baslik: "Bu çağrıda açılanlar", LogTabloId: LogCagriIlgili, SubeKolonu: null),
            new("olaylar", "public.cagri_olay", "cagri_id", new KartAlani[]
            {
                new("id",       "id",       "sayi",  Yazilabilir: false),
                new("zaman",    "zaman",    "zaman", Yazilabilir: false, Baslik: "Zaman"),
                new("tur",      "tur",      "kod",   KodListesi: "cagri.olay_tur", Yazilabilir: false, Baslik: "Olay"),
                new("aciklama", "aciklama", "metin", Yazilabilir: false, Baslik: "Açıklama"),
            }, Sirala: "zaman", Baslik: "Zaman çizelgesi", LogTabloId: LogCagriOlay, SubeKolonu: null, SaltOkunur: true),
        });

    private static KartTanimi CagriKonuKarti() => new(
        Ad: "cagri-konu",
        YetkiKodu: "cagri.ayar",
        Tablo: "public.cagri_konu",
        LogTabloId: LogCagriKonu,
        SabitKosul: "ust_id is null",
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.cagri", "konu_id", "Konuya bağlı çağrı kaydı var; silinemez, pasife alın."),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1, ["slaDk"] = 0, ["hizliIslem"] = (short)0 },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",          "sayi",  Yazilabilir: false),
            new("ad",         "ad",          "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Konu", Grup: "Konu"),
            new("slaDk",      "sla_dk",      "sayi",  Baslik: "SLA (dk; 0 = çağrıda çözüm)", Grup: "Konu"),
            new("hizliIslem", "hizli_islem", "kod",   KodListesi: "cagri.hizli_islem", Baslik: "Hızlı işlem (kart)", Grup: "Konu"),
            new("sira",       "sira",        "sayi",  Baslik: "Sıra", Grup: "Konu"),
            new("aktif",      "aktif",       "kod",   SabitKodlar: CagriAktifKodlari, Baslik: "Durum", Grup: "Konu"),
            new("sonuclar",   "sonuclar",    "metin", EnFazlaUzunluk: 300, Baslik: "Sonuç seçenekleri (virgülle)", Grup: "Betik"),
            new("betik",      "betik",       "metin", EnFazlaUzunluk: 1200, Baslik: "Operatör betiği", Grup: "Betik"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("altKonular", "public.cagri_konu", "ust_id", new KartAlani[]
            {
                new("id",     "id",     "sayi",  Yazilabilir: false),
                new("ad",     "ad",     "metin", Zorunlu: true, EnFazlaUzunluk: 80, Baslik: "Alt konu"),
                new("sira",   "sira",   "sayi",  Baslik: "Sıra"),
                new("aktif",  "aktif",  "kod",   SabitKodlar: CagriAktifKodlari, Baslik: "Durum"),
            }, Sirala: "sira, id", Baslik: "Alt konular", LogTabloId: LogCagriKonu, SubeKolonu: null),
        });

    private static KartTanimi CagriKuyrukKarti() => new(
        Ad: "cagri-kuyruk",
        YetkiKodu: "cagri.ayar",
        Tablo: "public.cagri_kuyruk",
        LogTabloId: LogCagriKuyruk,
        SilmeEngelleri: new SilmeEngeli[] { new("public.cagri", "kuyruk_id", "Kuyruğun çağrı kaydı var; silinemez, pasife alın.") },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1, ["kanal"] = (short)1, ["slaSn"] = 20, ["slaHedef"] = (short)90, ["maxBeklemeSn"] = 180 },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",               "sayi",  Yazilabilir: false),
            new("ad",            "ad",               "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Kuyruk", Grup: "Kuyruk"),
            new("santralKodu",   "santral_kodu",     "metin", EnFazlaUzunluk: 30, Baslik: "Santral kuyruk kodu", Grup: "Kuyruk"),
            new("kanal",         "kanal",            "kod",   KodListesi: "cagri.kanal", Baslik: "Kanal", Grup: "Kuyruk"),
            new("beceri",        "beceri",           "metin", EnFazlaUzunluk: 40, Baslik: "Beceri", Grup: "Kuyruk"),
            new("sira",          "sira",             "sayi",  Baslik: "Sıra", Grup: "Kuyruk"),
            new("aktif",         "aktif",            "kod",   SabitKodlar: CagriAktifKodlari, Baslik: "Durum", Grup: "Kuyruk"),
            new("slaSn",         "sla_sn",           "sayi",  Baslik: "SLA cevap süresi (sn)", Grup: "Hedef"),
            new("slaHedef",      "sla_hedef",        "sayi",  Baslik: "SLA hedefi (%)", Grup: "Hedef"),
            new("maxBeklemeSn",  "max_bekleme_sn",   "sayi",  Baslik: "En fazla bekleme (sn)", Grup: "Hedef"),
            new("tasmaKuyrukId", "tasma_kuyruk_id",  "kod",   KodTablosu: "public.v_cagri_kuyruk_lookup", Baslik: "Taşma kuyruğu", Grup: "Hedef"),
            new("beklemeMesaji", "bekleme_mesaji",   "metin", EnFazlaUzunluk: 200, Baslik: "Bekleme mesajı", Grup: "Hedef"),
        });

    private static KartTanimi CagriAgentKarti() => new(
        Ad: "cagri-agent",
        YetkiKodu: "cagri.ayar",
        Tablo: "public.cagri_agent",
        LogTabloId: LogCagriAgent,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1, ["softphone"] = (short)1, ["durum"] = (short)5, ["kuyruklar"] = "[]" },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("kullaniciId", "kullanici_id", "kod",   Zorunlu: true, KodTablosu: "public.v_kullanici_lookup", Baslik: "Kullanıcı", Grup: "Agent"),
            new("dahili",      "dahili",       "metin", EnFazlaUzunluk: 10, Baslik: "Dahili", Grup: "Agent"),
            new("softphone",   "softphone",    "kod",   SabitKodlar: CagriSoftphone, Baslik: "Softphone", Grup: "Agent"),
            new("kuyruklar",   "kuyruklar",    "json",  EnFazlaUzunluk: 200, Baslik: "Kuyruklar (JSON dizi: kuyruk id)", Grup: "Agent"),
            new("aktif",       "aktif",        "kod",   SabitKodlar: CagriAktifKodlari, Baslik: "Aktif", Grup: "Agent"),
            new("durum",       "durum",        "kod",   KodListesi: "cagri.agent_durum", Yazilabilir: false, Baslik: "Anlık durum", Grup: "Durum"),
            new("durumZaman",  "durum_zaman",  "zaman", Yazilabilir: false, Baslik: "Durum zamanı", Grup: "Durum"),
        });

    private static KartTanimi CagriKampanyaKarti() => new(
        Ad: "cagri-kampanya",
        YetkiKodu: "cagri.kampanya",
        Tablo: "public.cagri_kampanya",
        LogTabloId: LogCagriKampanya,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["kaynak"] = "randevu_yarin", ["durum"] = (short)0, ["ikinciAdimDk"] = 120, ["deneme"] = (short)3, ["denemeAraDk"] = 120, ["baslama"] = "@simdi" },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",             "sayi",  Yazilabilir: false),
            new("ad",           "ad",             "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Kampanya", Grup: "Kampanya"),
            new("tur",          "tur",            "kod",   Zorunlu: true, KodListesi: "cagri.kampanya_tur", Baslik: "Tür", Grup: "Kampanya"),
            new("kaynak",       "kaynak",         "kod",   Zorunlu: true, SabitKodlar: CagriKaynaklar, Baslik: "Kaynak listesi", Grup: "Kampanya"),
            new("parametre",    "parametre",      "metin", EnFazlaUzunluk: 200, Baslik: "Parametre (tutar eşiği / gün)", Grup: "Kampanya"),
            new("durum",        "durum",          "kod",   SabitKodlar: CagriKampanyaDurum, Baslik: "Durum", Grup: "Kampanya"),
            new("baslama",      "baslama",        "tarih", Baslik: "Başlama", Grup: "Kampanya"),
            new("bitis",        "bitis",          "tarih", Baslik: "Bitiş", Grup: "Kampanya"),
            new("sablonKodu",   "sablon_kodu",    "metin", EnFazlaUzunluk: 60, Baslik: "1. adım: bildirim şablonu kodu (boş = doğrudan arama)", Grup: "Adımlar"),
            new("kuyrukId",     "kuyruk_id",      "kod",   KodTablosu: "public.v_cagri_kuyruk_lookup", Baslik: "2. adım: arama kuyruğu", Grup: "Adımlar"),
            new("ikinciAdimDk", "ikinci_adim_dk", "sayi",  Baslik: "Mesaja cevap yoksa kaç dk sonra aranır", Grup: "Adımlar"),
            new("deneme",       "deneme",         "sayi",  Baslik: "Kişi başı deneme", Grup: "Adımlar"),
            new("denemeAraDk",  "deneme_ara_dk",  "sayi",  Baslik: "Denemeler arası (dk)", Grup: "Adımlar"),
            new("zamanlama",    "zamanlama",      "metin", EnFazlaUzunluk: 60, Baslik: "Zamanlama (bilgi)", Grup: "Adımlar"),
            new("aciklama",     "aciklama",       "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Adımlar"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("kisiler", "public.cagri_kampanya_kisi", "kampanya_id", new KartAlani[]
            {
                new("id",       "id",       "sayi",  Yazilabilir: false),
                new("ad",       "ad",       "metin", EnFazlaUzunluk: 150, Baslik: "Kişi"),
                new("telefon",  "telefon",  "metin", Zorunlu: true, EnFazlaUzunluk: 30, Baslik: "Telefon"),
                new("tarafId",  "taraf_id", "kod",   KodTablosu: "public.v_hasta_lookup", Baslik: "Taraf"),
                new("ozet",     "ozet",     "metin", EnFazlaUzunluk: 200, Baslik: "Özet"),
                new("durum",    "durum",    "kod",   KodListesi: "cagri.kisi_durum", Baslik: "Durum"),
                new("sonuc",    "sonuc",    "metin", EnFazlaUzunluk: 200, Baslik: "Sonuç"),
            }, Sirala: "durum, id", Baslik: "Kişiler", LogTabloId: LogCagriKampanyaKisi),
        });

    private static KartTanimi CagriKaliteKarti() => new(
        Ad: "cagri-kalite",
        YetkiKodu: "cagri.kalite",
        Tablo: "public.cagri_kalite",
        LogTabloId: LogCagriKalite,
        Alanlar: new KartAlani[]
        {
            new("id",            "id",             "sayi",  Yazilabilir: false),
            new("cagriId",       "cagri_id",       "sayi",  Zorunlu: true, Baslik: "Çağrı no", Grup: "Değerlendirme"),
            new("degerlendiren", "degerlendiren",  "kod",   KodTablosu: "public.v_kullanici_lookup", Baslik: "Değerlendiren", Grup: "Değerlendirme"),
            new("puan",          "puan",           "sayi",  Baslik: "Puan (0-100)", Grup: "Değerlendirme"),
            new("olcutler",      "olcutler",       "json",  EnFazlaUzunluk: 1000, Baslik: "Ölçütler (JSON)", Grup: "Değerlendirme"),
            new("notu",          "notu",           "metin", EnFazlaUzunluk: 600, Baslik: "Not", Grup: "Değerlendirme"),
            new("ozetAi",        "ozet_ai",        "metin", EnFazlaUzunluk: 1500, Baslik: "AI özet", Grup: "Kayıt"),
            new("transkript",    "transkript",     "metin", Baslik: "Transkript", Grup: "Kayıt"),
        });
}
