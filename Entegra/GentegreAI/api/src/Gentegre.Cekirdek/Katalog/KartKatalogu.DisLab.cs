namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DIŞ LABORATUVAR KARTLARI (445) — dış lab tanımı ve anlaşmalı test listesi.
///
/// GÖNDERİMİN KARTI YOK: gönderim bir süreçtir (hazırla → yolda → teslim →
/// sonuç) ve adımları uçlardan yürür. Serbest düzenlenebilir bir kart,
/// "teslim edildi" zamanını geriye dönük değiştirilebilir kılardı - oysa
/// numunenin binadan çıktığı an, kayıp tartışmasında tek dayanaktır.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> DisLabKanalKodlari = new()
    {
        ["1"] = "PDF / e-posta", ["2"] = "HL7", ["3"] = "Portal", ["4"] = "Elden",
    };

    private static readonly Dictionary<string, string> DisLabEvetHayir = new() { ["1"] = "Evet", ["0"] = "Hayır" };
    private static readonly Dictionary<string, string> DisLabBaglantiKodlari = new()
    {
        ["1"] = "API (REST/JSON)", ["2"] = "HL7 v2", ["3"] = "FHIR", ["4"] = "Portal (dış kurum)", ["5"] = "Elle (basılı form)",
    };
    private static readonly Dictionary<string, string> DisLabEkOnayKodlari = new()
    {
        ["1"] = "Sözleşmedekiler otomatik, gerisi onay ister", ["2"] = "Hepsi onay ister", ["3"] = "Hepsi otomatik",
    };

    private static KartTanimi LabDisLabKarti() => new(
        Ad: "lab-dis-lab",
        YetkiKodu: "lab.dislab",
        Tablo: "public.lab_dis_lab",
        LogTabloId: 1028,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["sonucKanali"] = (short)1,
            ["sozlesmeTatGun"] = (short)3,
            ["durum"] = (short)0,
            ["biyokimya"] = (short)1, ["patoloji"] = (short)0, ["baglantiTuru"] = (short)5,
            ["patTatGun"] = (short)3, ["patEkOnay"] = (short)1,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.pat_gonderim", "dis_lab_id", "Bu laboratuvara patoloji gönderimi yapılmış - silinemez, pasife alın."),
            new("public.lab_dis_gonderim", "dis_lab_id",
                "Bu laboratuvara gönderim yapılmış - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Laboratuvar"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Adı", Grup: "Laboratuvar"),
            // CARİ BAĞI ZORUNLU: dış lab hizmeti satın alınan bir hizmettir;
            //   alış faturası bu cariye kesilir ve gönderimle eşleştirilir.
            new("tarafId", "taraf_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_cari_lookup", AramaKaynagi: "cari",
                Baslik: "Cari (tedarikçi)", Grup: "Laboratuvar"),
            new("sonucKanali", "sonuc_kanali", "kod", SabitKodlar: DisLabKanalKodlari,
                Baslik: "Sonuç Kanalı", Grup: "Laboratuvar"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Laboratuvar"),

            // SÖZLEŞME TAT'ı gecikme hesabının dayanağı: aşıldığında gönderim
            //   "geciken" listesine düşer ve dış laboratuvar aranır.
            new("sozlesmeTatGun", "sozlesme_tat_gun", "sayi",
                Baslik: "Sözleşme TAT (gün)", Grup: "İletişim"),
            new("kuryeFirma", "kurye_firma", "metin", EnFazlaUzunluk: 120,
                Baslik: "Kurye Firması", Grup: "İletişim"),
            new("yetkili", "yetkili", "metin", EnFazlaUzunluk: 120,
                Baslik: "Yetkili", Grup: "İletişim"),
            new("telefon", "telefon", "metin", EnFazlaUzunluk: 30,
                Baslik: "Telefon", Grup: "İletişim"),
            new("eposta", "eposta", "metin", EnFazlaUzunluk: 120,
                Baslik: "E-posta", Grup: "İletişim"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400,
                Baslik: "Açıklama", Grup: "İletişim"),

            // PATOLOJİ (1104): aynı lab hem biyokimya hem patoloji yapabilir - kart tek,
            //   hizmet alanları ayrı. Bağlantı türü istemin laba nasıl gittiğini belirler.
            new("biyokimya", "biyokimya", "kod", SabitKodlar: DisLabEvetHayir, Baslik: "Biyokimya / Lab Hizmeti", Grup: "Patoloji"),
            new("patoloji", "patoloji", "kod", SabitKodlar: DisLabEvetHayir, Baslik: "Patoloji Hizmeti", Grup: "Patoloji"),
            new("baglantiTuru", "baglanti_turu", "kod", SabitKodlar: DisLabBaglantiKodlari, Baslik: "Bağlantı Türü", Grup: "Patoloji"),
            new("kurumKodu", "kurum_kodu", "metin", EnFazlaUzunluk: 40, Baslik: "Kurum Kodu (labdaki)", Grup: "Patoloji"),
            new("patTatGun", "pat_tat_gun", "sayi", Baslik: "Patoloji TAT (iş günü)", Grup: "Patoloji"),
            new("patEkOnay", "pat_ek_onay", "kod", SabitKodlar: DisLabEkOnayKodlari, Baslik: "Ek İnceleme (İHK) Onayı", Grup: "Patoloji"),
        },
        Detaylar: new DetayTanimi[]
        {
            // ANLAŞMALI TESTLER: dış labın KENDİ kodu burada eşlenir - sonuç
            //   onların koduyla geldiği için eşleme olmadan hangi tetkiğe
            //   yazılacağı belirsiz kalır (cihaz eşlemesiyle aynı desen).
            new("testler", "public.lab_dis_test", "dis_lab_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tetkikId", "tetkik_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_lab_tetkik_lookup", Baslik: "Tetkik"),
                new("disKod", "dis_kod", "metin", EnFazlaUzunluk: 40,
                    Baslik: "Dış Lab Kodu"),
                new("disAd", "dis_ad", "metin", EnFazlaUzunluk: 200,
                    Baslik: "Dış Lab Test Adı"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                // Anlaşma fiyatı: alış faturası eşleştirmesinde beklenen tutar.
                new("birimFiyat", "birim_fiyat", "para", Baslik: "Anlaşma Fiyatı"),
                new("tatGun", "tat_gun", "sayi", Baslik: "TAT (gün)"),
                new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                    Baslik: "Durum"),
            }, SubeKolonu: null, Sirala: "tetkik_id", Baslik: "Anlaşmalı Testler",
               LogTabloId: 1029),
            PatolojiDisKodDetayi(),
        });
}
