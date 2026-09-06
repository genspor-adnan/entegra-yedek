namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// GENETİK KARTLARI (439) — gen ve panel katalogları.
///
/// Vakanın ve varyantın kartı YOK: ikisi de süreç kaydıdır (onam →
/// izolasyon → run → varyant → doğrulama → onay) ve uçlardan yürür.
/// Serbest düzenlenebilir bir varyant kartı, ACMG kanıtından türetilen
/// sınıfı sessizce ezilebilir kılardı.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> GenKalitimKodlari = new()
    {
        ["1"] = "Otozomal dominant", ["2"] = "Otozomal resesif",
        ["3"] = "X'e bağlı", ["4"] = "Mitokondriyal", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> GenetikYontemKodlari = new()
    {
        ["1"] = "NGS panel", ["2"] = "WES (tüm ekzom)", ["3"] = "WGS (tüm genom)",
        ["4"] = "PCR / RT-PCR", ["5"] = "Sanger", ["6"] = "Karyotip",
        ["7"] = "MLPA", ["8"] = "Mikroarray",
    };

    // Somatik testte ACMG yerine AMP/ASCO/CAP tier kullanılır ve VAF eşiği
    //   ile tümör yüzdesi ayrı değerlendirilir - kaynak tipi bu yüzden
    //   panelin kimlik alanı.
    private static readonly Dictionary<string, string> GenetikKaynakKodlari = new()
        { ["1"] = "Germline (kalıtsal)", ["2"] = "Somatik (tümör)" };

    private static KartTanimi LabGenKarti() => new(
        Ad: "lab-gen",
        YetkiKodu: "lab.gen",
        Tablo: "public.lab_gen",
        LogTabloId: 1019,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["kalitim"] = (short)1,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_genetik_panel_gen", "gen_id",
                "Bu gen bir panelde kullanılıyor."),
            new("public.lab_varyant", "gen_id",
                "Bu gende raporlanmış varyant var - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("sembol", "sembol", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "HGNC Sembolü", Grup: "Gen"),
            new("ad", "ad", "metin", EnFazlaUzunluk: 200, Baslik: "Adı", Grup: "Gen"),
            // TRANSKRİPT: HGVS gösterimi transkripte göredir; transkriptsiz
            //   "c.1504C>T" başka bir aminoasit değişimi anlamına gelebilir.
            new("transkript", "transkript", "metin", EnFazlaUzunluk: 30,
                Baslik: "Referans Transkript (NM_…)", Grup: "Gen"),
            new("kalitim", "kalitim", "kod", SabitKodlar: GenKalitimKodlari,
                Baslik: "Kalıtım", Grup: "Gen"),
            new("hastalik", "hastalik", "metin", EnFazlaUzunluk: 200,
                Baslik: "İlişkili Hastalık", Grup: "Gen"),
            new("omim", "omim", "metin", EnFazlaUzunluk: 20, Baslik: "OMIM", Grup: "Gen"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Gen"),
        });

    private static KartTanimi LabGenetikPanelKarti() => new(
        Ad: "lab-genetik-panel",
        YetkiKodu: "lab.gen",
        Tablo: "public.lab_genetik_panel",
        LogTabloId: 1020,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["yontem"] = (short)1,
            ["kaynakTipi"] = (short)1,
            ["referansGenom"] = "GRCh38",
            ["hedefTatGun"] = 21,
            ["durum"] = (short)0,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.lab_genetik_vaka", "panel_id",
                "Bu panelle açılmış vaka var - silinemez, pasife alın."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Panel Kodu", Grup: "Panel"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Panel Adı", Grup: "Panel"),
            new("yontem", "yontem", "kod", SabitKodlar: GenetikYontemKodlari,
                Baslik: "Yöntem", Grup: "Panel"),
            new("kaynakTipi", "kaynak_tipi", "kod", SabitKodlar: GenetikKaynakKodlari,
                Baslik: "Kaynak Tipi", Grup: "Panel"),
            new("durum", "durum", "kod", SabitKodlar: LabKayitDurumKodlari,
                Baslik: "Durum", Grup: "Panel"),

            // RAPOR ZORUNLULUĞU: referans genom ve pipeline sürümü raporda
            //   yazmak zorunda - başka bir sürümle üretilmiş sonuç aynı
            //   koordinatta farklı varyant gösterebilir.
            new("referansGenom", "referans_genom", "metin", EnFazlaUzunluk: 20,
                Baslik: "Referans Genom", Grup: "Yöntem"),
            new("pipeline", "pipeline", "metin", EnFazlaUzunluk: 60,
                Baslik: "Biyoinformatik Hattı", Grup: "Yöntem"),
            new("hedefTatGun", "hedef_tat_gun", "sayi",
                Baslik: "Hedef TAT (gün)", Grup: "Yöntem"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400,
                Baslik: "Kapsam / Açıklama", Grup: "Yöntem"),
        },
        Detaylar: new DetayTanimi[]
        {
            // GEN LİSTESİ RAPORUN EKİDİR: hasta "hangi genlere bakıldı"
            //   sorusunun cevabını rapordan görmeli; panel dışı gen negatif
            //   sonucu geçersiz kılmaz ama sınırlılıktır.
            new("genler", "public.lab_genetik_panel_gen", "panel_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("genId", "gen_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_lab_gen_lookup", Baslik: "Gen"),
            }, SubeKolonu: null, Sirala: "sira, id", Baslik: "Panel Genleri",
               LogTabloId: 1021),
        });
}
