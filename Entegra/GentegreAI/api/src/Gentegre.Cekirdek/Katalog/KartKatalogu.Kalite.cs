namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KALİTE KONTROL KARTLARI (442) — kontrol lotu (+ hedefler), Westgard
/// kuralı, dış kalite sonucu ve cihaz olayı.
///
/// KK ÖLÇÜMÜNÜN KARTI YOK: ölçüm serbest düzenlenebilir olsaydı, z skoru
/// ve kural değerlendirmesi elle ezilebilirdi - kalite kaydının değeri
/// tam da değiştirilememesinden gelir. Ölçüm uçtan girilir, düzeltici
/// faaliyet ayrı bir aksiyondur.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> KkKuralDavranisKodlari = new()
    {
        ["0"] = "Kapalı", ["1"] = "Uyarı", ["2"] = "RET (sonuç verilemez)",
    };

    private static readonly Dictionary<string, string> DkkDegerlendirmeKodlari = new()
    {
        ["1"] = "Kabul (|SDI| ≤ 2)", ["2"] = "Uyarı (2 < |SDI| ≤ 3)",
        ["3"] = "Kabul edilemez (|SDI| > 3)",
    };

    private static readonly Dictionary<string, string> CihazOlayKodlari = new()
    {
        ["1"] = "Kalibrasyon", ["2"] = "Bakım", ["3"] = "Reaktif lot değişimi",
        ["4"] = "Arıza", ["5"] = "KK ret sonrası tekrar", ["9"] = "Diğer",
    };

    /// <summary>
    /// KONTROL LOTU + test bazlı hedefleri.
    ///
    /// Hedef/SD LOT BAŞINADIR: yeni lotta değerler değişir. Üretici değeri
    /// başlangıçtır; laboratuvar 20 ölçümden sonra kendi kümülatifini
    /// kullanır (kümülatif alanlar hesap sonucudur, yazılamaz).
    /// </summary>
    private static KartTanimi LabKkLotKarti() => new(
        Ad: "lab-kk-lot",
        YetkiKodu: "lab.kk",
        Tablo: "public.lab_kk_lot",
        LogTabloId: 1022,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["seviyeSayisi"] = (short)2,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_kk_olcum", "lot_id",
                "Bu lotla yapılmış KK ölçümü var - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 30,
                Baslik: "Lot Kodu (kontrol barkodu)", Grup: "Lot"),
            new("materyalAd", "materyal_ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Kontrol Materyali", Grup: "Lot"),
            new("lot", "lot", "metin", Zorunlu: true, EnFazlaUzunluk: 40,
                Baslik: "Lot No", Grup: "Lot"),
            new("uretici", "uretici", "metin", EnFazlaUzunluk: 120,
                Baslik: "Üretici", Grup: "Lot"),
            // SKT GEÇMİŞ LOTLA KONTROL YAPILAMAZ: tarih kartta zorunlu değil
            //   ama listede kalan gün olarak görünür.
            new("skt", "skt", "tarih", Baslik: "Son Kullanma Tarihi", Grup: "Lot"),
            new("acilisTarihi", "acilis_tarihi", "tarih",
                Baslik: "Açılış Tarihi", Grup: "Lot"),
            new("seviyeSayisi", "seviye_sayisi", "sayi",
                Baslik: "Seviye Sayısı", Grup: "Lot"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Lot"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Lot"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("hedefler", "public.lab_kk_hedef", "lot_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tetkikId", "tetkik_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_lab_tetkik_lookup", Baslik: "Tetkik"),
                new("seviye", "seviye", "sayi", Baslik: "Seviye"),
                new("ureticiHedef", "uretici_hedef", "sayi", Baslik: "Üretici Hedef"),
                new("ureticiSd", "uretici_sd", "sayi", Baslik: "Üretici SD"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                new("esikN", "esik_n", "sayi", Baslik: "Kümülatif Eşik (n)"),
                // KÜMÜLATİF ALANLAR HESAP SONUCUDUR (fn_lab_kk_kumulatif):
                //   elle girilebilseydi "hangi hedef geçerli" belirsiz kalırdı.
                new("kumulatifN", "kumulatif_n", "sayi", Yazilabilir: false,
                    Baslik: "Kümülatif n"),
                new("kumulatifOrt", "kumulatif_ort", "sayi", Yazilabilir: false,
                    Baslik: "Kümülatif Ortalama"),
                new("kumulatifSd", "kumulatif_sd", "sayi", Yazilabilir: false,
                    Baslik: "Kümülatif SD"),
                new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                    Baslik: "Durum"),
            }, SubeKolonu: null, Sirala: "tetkik_id, seviye",
               Baslik: "Hedef Değerler (test · seviye)", LogTabloId: 1023),
        });

    private static KartTanimi LabKkKuralKarti() => new(
        Ad: "lab-kk-kural",
        YetkiKodu: "lab.kk",
        Tablo: "public.lab_kk_kural",
        LogTabloId: 1024,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["davranis"] = (short)2,
            ["sira"] = (short)10,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            // TETKİK BOŞSA VARSAYILAN SET: bir HbA1c ile bir troponinin
            //   tolere ettiği sapma aynı değildir, ama her test için ayrı
            //   set zorunlu tutmak kurulumda yüz satır elle giriş demekti.
            new("tetkikId", "tetkik_id", "kod",
                KodTablosu: "public.v_lab_tetkik_lookup",
                Baslik: "Tetkik (boş = varsayılan set)", Grup: "Kural"),
            new("kural", "kural", "metin", Zorunlu: true, EnFazlaUzunluk: 12,
                Baslik: "Kural (1_3s · 2_2s · R_4s · 4_1s · 10x · 1_2s)", Grup: "Kural"),
            new("davranis", "davranis", "kod", SabitKodlar: KkKuralDavranisKodlari,
                Baslik: "Davranış", Grup: "Kural"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Kural"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Kural"),
        });

    private static KartTanimi LabDkkKarti() => new(
        Ad: "lab-dkk",
        YetkiKodu: "lab.kk",
        Tablo: "public.lab_dkk_sonuc",
        LogTabloId: 1025,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["degerlendirme"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("program", "program", "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Program (KBUDEK · RIQAS…)", Grup: "Dönem"),
            new("donem", "donem", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Dönem (2026-08)", Grup: "Dönem"),
            new("tetkikId", "tetkik_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_lab_tetkik_lookup", Baslik: "Tetkik",
                Grup: "Dönem"),
            new("numuneKodu", "numune_kodu", "metin", EnFazlaUzunluk: 30,
                Baslik: "Numune Kodu", Grup: "Dönem"),
            new("raporTarihi", "rapor_tarihi", "tarih",
                Baslik: "Program Rapor Tarihi", Grup: "Dönem"),

            new("sonucumuz", "sonucumuz", "sayi", Baslik: "Sonucumuz", Grup: "Sonuç"),
            new("hedef", "hedef", "sayi", Baslik: "Hedef (grup ortalaması)",
                Grup: "Sonuç"),
            new("grupSd", "grup_sd", "sayi", Baslik: "Grup SD", Grup: "Sonuç"),
            new("grupN", "grup_n", "sayi", Baslik: "Grup n", Grup: "Sonuç"),
            new("yontem", "yontem", "metin", EnFazlaUzunluk: 120,
                Baslik: "Yöntem / Peer Grup", Grup: "Sonuç"),
            // SDI HESAP SONUCUDUR: (bizim − hedef) / grup SD. Elle
            //   girilebilseydi kabul/ret kararı keyfîleşirdi.
            new("sdi", "sdi", "sayi", Yazilabilir: false, Baslik: "SDI", Grup: "Sonuç"),
            new("degerlendirme", "degerlendirme", "kod",
                SabitKodlar: DkkDegerlendirmeKodlari, Baslik: "Değerlendirme",
                Grup: "Sonuç"),
            new("aksiyon", "aksiyon", "metin", EnFazlaUzunluk: 600,
                Baslik: "Düzeltici Faaliyet", Grup: "Sonuç"),
        });

    private static KartTanimi LabCihazOlayKarti() => new(
        Ad: "lab-cihaz-olay",
        YetkiKodu: "lab.kk",
        Tablo: "public.lab_cihaz_olay",
        LogTabloId: 1026,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["olay"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("cihazId", "cihaz_id", "kod", KodTablosu: "public.v_cihaz_lookup",
                Baslik: "Cihaz", Grup: "Olay"),
            new("tetkikId", "tetkik_id", "kod", KodTablosu: "public.v_lab_tetkik_lookup",
                Baslik: "Tetkik (boş = tüm testler)", Grup: "Olay"),
            new("olay", "olay", "kod", SabitKodlar: CihazOlayKodlari,
                Baslik: "Olay", Grup: "Olay"),
            new("zaman", "zaman", "tarih", Baslik: "Zaman", Grup: "Olay"),
            new("lot", "lot", "metin", EnFazlaUzunluk: 40,
                Baslik: "Reaktif / Kit Lot", Grup: "Olay"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 600,
                Baslik: "Açıklama", Grup: "Olay"),
        });
}
