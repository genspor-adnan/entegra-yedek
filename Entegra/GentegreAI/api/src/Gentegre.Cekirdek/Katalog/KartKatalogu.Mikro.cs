namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MİKROBİYOLOJİ KARTLARI (436) — besiyeri, organizma, antibiyotik.
///
/// Kültürün KENDİSİNİN kartı yok: kültür bir kayıt değil bir süreçtir
/// (ekim → okuma → izolat → antibiyogram → onay) ve adımları uçlardan
/// yürür. Serbest düzenlenebilir bir kart, "48. saatte okundu" kaydını
/// geriye dönük değiştirilebilir kılardı.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> BesiyeriTurKodlari = new()
    {
        ["1"] = "Katı (agar)", ["2"] = "Sıvı (buyyon)",
        ["3"] = "Kan kültür şişesi", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> AtmosferKodlari = new()
    {
        ["1"] = "Aerob", ["2"] = "Anaerob", ["3"] = "%5 CO₂", ["4"] = "Mikroaerofil",
    };

    private static readonly Dictionary<string, string> OrganizmaTurKodlari = new()
    {
        ["1"] = "Bakteri", ["2"] = "Mantar", ["3"] = "Virüs", ["4"] = "Parazit",
        ["9"] = "Durum satırı (üreme yok / flora)",
    };

    private static readonly Dictionary<string, string> GramKodlari = new()
        { ["0"] = "Uygulanmaz", ["1"] = "Gram pozitif", ["2"] = "Gram negatif" };

    private static readonly Dictionary<string, string> MorfolojiKodlari = new()
    {
        ["0"] = "—", ["1"] = "Kok", ["2"] = "Basil", ["3"] = "Kokobasil",
        ["4"] = "Maya", ["5"] = "Küf", ["9"] = "Diğer",
    };

    // KADEMELİ BİLDİRİM BASAMAĞI: raporun neyi gösterip neyi gizleyeceğini
    //   belirler. Yanlış basamak, klinisyeni gereksiz yere karbapeneme
    //   yönlendirir - bu yüzden kartta açık açık yazılı.
    private static readonly Dictionary<string, string> AntibiyotikBasamakKodlari = new()
    {
        ["1"] = "1 · Dar spektrum (her zaman raporlanır)",
        ["2"] = "2 · Alternatif (1. basamakta duyarlı yoksa)",
        ["3"] = "3 · Kısıtlı / geniş spektrum (1 ve 2'de duyarlı yoksa)",
    };

    /// <summary>Besiyerinin ekildigi numune tipleri - lab tetkik kartiyla AYNI kodlar.</summary>
    private static readonly Dictionary<string, string> BesiyeriNumuneKodlari = new()
    {
        ["1"] = "Serum", ["2"] = "Plazma", ["3"] = "Tam Kan", ["4"] = "İdrar",
        ["5"] = "Gaita", ["6"] = "BOS", ["7"] = "Swab", ["9"] = "Diğer",
    };

    /// <summary>KK susunun calisilma sikligi (509).</summary>
    private static readonly Dictionary<string, string> KkPeriyotKodlari = new()
        { ["1"] = "Her yeni lot", ["2"] = "Haftalık", ["3"] = "Aylık" };

    private static readonly Dictionary<string, string> UygulamaKodlari = new()
        { ["1"] = "Oral", ["2"] = "Parenteral", ["3"] = "Oral / parenteral" };

    private static KartTanimi LabBesiyeriKarti() => new(
        Ad: "lab-besiyeri",
        YetkiKodu: "lab.mikro",
        Tablo: "public.lab_besiyeri",
        LogTabloId: 1015,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,
            ["sicaklik"] = (short)37,
            ["atmosfer"] = (short)1,
            ["ilkOkumaSaat"] = (short)24,
            ["sonOkumaSaat"] = (short)48,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_kultur_besiyeri", "besiyeri_id",
                "Bu besiyeri kültürlerde kullanılmış - silinemez, pasife alın."),
            new("public.lab_tetkik_besiyeri", "besiyeri_id",
                "Bu besiyeri bir tetkiğin varsayılan setinde."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Besiyeri"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Besiyeri Adı", Grup: "Besiyeri"),
            new("tur", "tur", "kod", SabitKodlar: BesiyeriTurKodlari,
                Baslik: "Tür", Grup: "Besiyeri"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Besiyeri"),

            // OKUMA PLANI buradan kurulur: 24 saatlik plakayı 48. saatte
            //   okumak negatif raporu güvenilmez yapar.
            new("sicaklik", "sicaklik", "sayi", Baslik: "İnkübasyon (°C)",
                Grup: "İnkübasyon"),
            new("atmosfer", "atmosfer", "kod", SabitKodlar: AtmosferKodlari,
                Baslik: "Atmosfer", Grup: "İnkübasyon"),
            new("ilkOkumaSaat", "ilk_okuma_saat", "sayi",
                Baslik: "İlk Okuma (saat)", Grup: "İnkübasyon"),
            new("sonOkumaSaat", "son_okuma_saat", "sayi",
                Baslik: "Son Okuma (saat)", Grup: "İnkübasyon"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "İnkübasyon"),

            // EKIM HACMI ve SAYIM CARPANI (509): 1 µL kalibre ozeyle sayilan
            //   koloni x1000 ile CFU/mL'ye cevrilir. Carpan kartta yoksa
            //   koloni sayimi RAPORLANAMAZ - idrar kulturunde "anlamli ureme"
            //   karari buna bagli (fn_lab_cfu).
            new("ekimHacmiUl", "ekim_hacmi_ul", "ondalik",
                Baslik: "Ekim Hacmi (µL)", Grup: "Sayım"),
            new("sayimCarpani", "sayim_carpani", "sayi",
                Baslik: "Sayım Çarpanı", Grup: "Sayım"),
            // BESIYERI BIR SARFTIR: lot ve miat stoktan okunur; miadi gecmis
            //   lotla calisilan kultur gecersizdir.
            new("stokId", "stok_id", "kod", KodTablosu: "public.v_stok_lookup",
                Baslik: "Stok Kartı", Grup: "Sayım"),
            new("kkSusu", "kk_susu", "metin", EnFazlaUzunluk: 120,
                Baslik: "KK Suşu (ATCC)", Grup: "Sayım"),
            new("kkPeriyot", "kk_periyot", "kod", SabitKodlar: KkPeriyotKodlari,
                Baslik: "KK Periyodu", Grup: "Sayım"),
        },
        Detaylar: new[]
        {
            // HANGI NUMUNEDE EKILIR (509): kultur acilirken varsayilan besiyeri
            //   seti buradan gelir - teknisyen her seferinde elle secmez.
            new DetayTanimi("numuneler", "public.lab_besiyeri_numune", "besiyeri_id",
            new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("numuneTipi", "numune_tipi", "kod", Zorunlu: true,
                    SabitKodlar: BesiyeriNumuneKodlari, Baslik: "Numune"),
                new("ekimSekli", "ekim_sekli", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Ekim Şekli"),
                new("amac", "amac", "metin", EnFazlaUzunluk: 200, Baslik: "Amaç"),
            }, SubeKolonu: null, Sirala: "numune_tipi", Baslik: "Numune Tipleri"),
        });

    private static KartTanimi LabOrganizmaKarti() => new(
        Ad: "lab-organizma",
        YetkiKodu: "lab.mikro",
        Tablo: "public.lab_organizma",
        LogTabloId: 1016,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,
            ["gram"] = (short)0,
            ["morfoloji"] = (short)0,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_kultur_ureme", "organizma_id",
                "Bu organizma kültür sonuçlarında kullanılmış."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Organizma"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 160,
                Baslik: "Adı (latin)", Grup: "Organizma"),
            new("kisaAd", "kisa_ad", "metin", EnFazlaUzunluk: 60,
                Baslik: "Kısa Ad (rapor)", Grup: "Organizma"),
            new("tur", "tur", "kod", SabitKodlar: OrganizmaTurKodlari,
                Baslik: "Tür", Grup: "Organizma"),
            new("gram", "gram", "kod", SabitKodlar: GramKodlari,
                Baslik: "Gram", Grup: "Organizma"),
            new("morfoloji", "morfoloji", "kod", SabitKodlar: MorfolojiKodlari,
                Baslik: "Morfoloji", Grup: "Organizma"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Organizma"),

            // "Üreme yok" ve "normal flora" da birer SONUÇTUR: izolat satırı
            //   olmadan kültür kapatılamaz.
            new("sonucSatiri", "sonuc_satiri", "mantik",
                Baslik: "Durum satırı (üreme yok / flora)", Grup: "Bildirim"),
            new("bildirimiZorunlu", "bildirimi_zorunlu", "mantik",
                Baslik: "Bildirimi zorunlu etken", Grup: "Bildirim"),
            new("snomed", "snomed", "metin", EnFazlaUzunluk: 20,
                Baslik: "SNOMED", Grup: "Bildirim"),
            new("skrsKod", "skrs_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "SKRS Kodu", Grup: "Bildirim"),

            // UREME ESIGI (509): idrar kulturunde 10^5 CFU/mL altindaki ureme
            //   "anlamli degil" diye raporlanir. Esik KARTTA durur - teknisyenin
            //   ezberinde degil; besiyerinin sayim carpaniyla birlikte calisir.
            new("uremeEsigi", "ureme_esigi", "sayi",
                Baslik: "Anlamlı Üreme Eşiği", Grup: "Bildirim", EslesAlan: "esikBirimi"),
            new("esikBirimi", "esik_birimi", "metin", EnFazlaUzunluk: 20,
                Baslik: "Eşik Birimi", Grup: "Bildirim"),
            new("panelNotu", "panel_notu", "metin", EnFazlaUzunluk: 300,
                Baslik: "Panel Notu", Grup: "Bildirim"),
        },
        Detaylar: new[]
        {
            // DOGAL (INTRINSIK) DIRENC (509): bu antibiyotik bu organizmada
            //   RAPORLANMAZ. Gram negatif izolatta vankomisin sonucu basmak
            //   yanlis tedaviye yol acar - antibiyogram ekrani bu listeyi
            //   gorunce o antibiyotigi hic sormaz (fn_lab_antibiyogram_paneli).
            new DetayTanimi("direnc", "public.lab_organizma_direnc", "organizma_id",
            new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("antibiyotikId", "antibiyotik_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_lab_antibiyotik_lookup", Baslik: "Antibiyotik"),
                new("sebep", "sebep", "metin", EnFazlaUzunluk: 200, Baslik: "Neden"),
            }, SubeKolonu: null, Sirala: "id", Baslik: "Doğal Direnç"),

            // ORGANIZMAYA OZEL PANEL: genel basamagi (lab_antibiyotik.basamak)
            //   ezer. Panel TANIMLIYSA yalniz o panel calisilir.
            new DetayTanimi("panel", "public.lab_organizma_panel", "organizma_id",
            new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("antibiyotikId", "antibiyotik_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_lab_antibiyotik_lookup", Baslik: "Antibiyotik"),
                new("basamak", "basamak", "kod", SabitKodlar: AntibiyotikBasamakKodlari,
                    Baslik: "Basamak"),
                new("notMetni", "not_metni", "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Antibiyogram Paneli"),
        });

    private static KartTanimi LabAntibiyotikKarti() => new(
        Ad: "lab-antibiyotik",
        YetkiKodu: "lab.mikro",
        Tablo: "public.lab_antibiyotik",
        LogTabloId: 1017,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["basamak"] = (short)1,
            ["uygulama"] = (short)3,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_antibiyogram", "antibiyotik_id",
                "Bu antibiyotik antibiyogramlarda kullanılmış."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kod", Grup: "Antibiyotik"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Adı", Grup: "Antibiyotik"),
            new("grup", "grup", "metin", EnFazlaUzunluk: 60,
                Baslik: "Grup (beta-laktam, kinolon…)", Grup: "Antibiyotik"),
            new("atc", "atc", "metin", EnFazlaUzunluk: 12,
                Baslik: "ATC", Grup: "Antibiyotik"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Antibiyotik"),

            new("basamak", "basamak", "kod", SabitKodlar: AntibiyotikBasamakKodlari,
                Baslik: "Kademeli Bildirim Basamağı", Grup: "Bildirim"),
            new("uygulama", "uygulama", "kod", SabitKodlar: UygulamaKodlari,
                Baslik: "Uygulama Yolu", Grup: "Bildirim"),
            // Nitrofurantoin/fosfomisin yalnız idrarda anlamlı: kan izolatında
            //   raporlanması tedaviyi yanlış yönlendirir.
            new("yalnizUriner", "yalniz_uriner", "mantik",
                Baslik: "Yalnız idrar kültüründe raporla", Grup: "Bildirim"),
        });
}
