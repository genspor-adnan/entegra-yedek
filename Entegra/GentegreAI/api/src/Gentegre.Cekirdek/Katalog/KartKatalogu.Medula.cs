namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MEDULA KARTLARI (707) — rapor (etken madde satırlı), kesinti, dönem, fatura.
/// Takip / hizmet kaydı / kuyruk kartı yok: onlar özel sayfalarda okunur;
/// generic kartla değiştirilebilir alan da yok (Medula'nın verdiği numaralar
/// elle düzeltilmez).
/// </summary>
public static partial class KartKatalogu
{
    private const int LogMedulaFatura  = 1151;
    private const int LogMedulaDonem   = 1152;
    private const int LogMedulaRapor   = 1153;
    private const int LogMedulaKesinti = 1154;

    private static readonly Dictionary<string, string> MedulaRaporDurumKodlari =
        new() { ["1"] = "Taslak", ["2"] = "İmzalı", ["3"] = "Medula kabul", ["4"] = "İptal", ["5"] = "Hata" };

    private static KartTanimi MedulaRaporKarti() => new(
        Ad: "medula-rapor",
        YetkiKodu: "medula.recete",
        Tablo: "public.medula_rapor",
        LogTabloId: LogMedulaRapor,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["raporTuru"] = (short)1, ["durum"] = (short)1 },
        AcilistaTarafSecimi: "hastaId",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true, KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta", Baslik: "Hasta", Grup: "Rapor"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_hekim_lookup", Baslik: "Hekim", Grup: "Rapor"),
            new("raporTuru", "rapor_turu", "kod", KodListesi: "medula.rapor_turu", Baslik: "Rapor Türü", Grup: "Rapor"),
            new("raporNo", "rapor_no", "metin", Yazilabilir: false, Baslik: "Rapor No (Medula)", Grup: "Rapor"),
            new("icdKod", "icd_kod", "kod", Zorunlu: true, AramaKaynagi: "icd", KodTablosu: "public.v_icd_lookup", Baslik: "Tanı (ICD-10)", Grup: "Rapor"),
            new("tani", "tani", "metin", EnFazlaUzunluk: 200, Baslik: "Tanı Açıklaması", Grup: "Rapor"),
            new("baslangic", "baslangic", "tarih", Zorunlu: true, Baslik: "Başlangıç", Grup: "Rapor"),
            new("bitis", "bitis", "tarih", Baslik: "Bitiş", Grup: "Rapor"),
            new("heyet", "heyet", "mantik", Baslik: "Heyet raporu", Grup: "Rapor"),
            new("muayeneId", "muayene_id", "sayi", Baslik: "Muayene", Grup: "Rapor"),
            new("belgeId", "belge_id", "sayi", Baslik: "Başvuru", Grup: "Rapor"),
            new("durum", "durum", "kod", SabitKodlar: MedulaRaporDurumKodlari, Yazilabilir: false, Baslik: "Durum", Grup: "Rapor"),
            new("medulaSonuc", "medula_sonuc", "metin", Yazilabilir: false, Baslik: "Medula Sonucu", Grup: "Rapor"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Rapor"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("satirlar", "public.medula_rapor_satir", "rapor_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("etkenMadde", "etken_madde", "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Etken Madde"),
                new("form", "form", "metin", EnFazlaUzunluk: 60, Baslik: "Form"),
                new("doz", "doz", "metin", EnFazlaUzunluk: 40, Baslik: "Doz"),
                new("gunluk", "gunluk", "metin", EnFazlaUzunluk: 20, Baslik: "Günlük"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
            }, Sirala: "id", LogTabloId: LogMedulaRapor, Baslik: "Etken Maddeler"),
        });

    private static KartTanimi MedulaKesintiKarti() => new(
        Ad: "medula-kesinti",
        YetkiKodu: "medula.fatura",
        Tablo: "public.medula_kesinti",
        LogTabloId: LogMedulaKesinti,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("medulaFaturaId", "medula_fatura_id", "kod", Zorunlu: true, KodTablosu: "public.v_medula_fatura_lookup", Baslik: "Fatura"),
            new("sutKodu", "sut_kodu", "metin", EnFazlaUzunluk: 12, Baslik: "SUT Kodu"),
            new("kesintiKodu", "kesinti_kodu", "metin", EnFazlaUzunluk: 10, Baslik: "Kesinti Kodu"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
            new("tutar", "tutar", "para", Zorunlu: true, Baslik: "Kesinti Tutarı"),
            new("itirazDurum", "itiraz_durum", "kod", KodListesi: "medula.itiraz_durum", Baslik: "İtiraz"),
            new("itirazZaman", "itiraz_zaman", "zaman", Yazilabilir: false, Baslik: "İtiraz Zamanı"),
            new("itirazMetni", "itiraz_metni", "metin", EnFazlaUzunluk: 600, Baslik: "İtiraz Metni"),
            new("sonucZaman", "sonuc_zaman", "zaman", Yazilabilir: false, Baslik: "Sonuç Zamanı"),
            new("iadeTutar", "iade_tutar", "para", Baslik: "İade"),
        });

    private static KartTanimi MedulaDonemKarti() => new(
        Ad: "medula-donem",
        YetkiKodu: "medula.fatura",
        Tablo: "public.medula_donem",
        LogTabloId: LogMedulaDonem,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("yil", "yil", "sayi", Yazilabilir: false, Baslik: "Yıl"),
            new("ay", "ay", "sayi", Yazilabilir: false, Baslik: "Ay"),
            new("faturaSayisi", "fatura_sayisi", "sayi", Yazilabilir: false, Baslik: "Fatura"),
            new("toplam", "toplam", "para", Yazilabilir: false, Baslik: "Tutar"),
            new("kesinti", "kesinti", "para", Yazilabilir: false, Baslik: "Kesinti"),
            new("odenen", "odenen", "para", Baslik: "Ödenen"),
            new("odemeTarihi", "odeme_tarihi", "tarih", Baslik: "Ödeme Tarihi"),
            new("sonlandirma", "sonlandirma", "zaman", Yazilabilir: false, Baslik: "Sonlandırma"),
            new("icmalNo", "icmal_no", "metin", Yazilabilir: false, Baslik: "İcmal No"),
            new("evrakGonderim", "evrak_gonderim", "zaman", Baslik: "Evrak / e-Fatura Gönderimi"),
            new("durum", "durum", "kod", KodListesi: "medula.donem_durum", Baslik: "Durum"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
        });

    private static KartTanimi MedulaFaturaKarti() => new(
        Ad: "medula-fatura",
        YetkiKodu: "medula.fatura",
        Tablo: "public.medula_fatura",
        LogTabloId: LogMedulaFatura,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("belgeId", "belge_id", "sayi", Yazilabilir: false, Baslik: "Başvuru"),
            new("hastaId", "hasta_id", "kod", Yazilabilir: false, KodTablosu: "public.v_hasta_lookup", Baslik: "Hasta"),
            new("takipNo", "takip_no", "metin", Yazilabilir: false, Baslik: "Takip No"),
            new("faturaTuru", "fatura_turu", "kod", KodListesi: "medula.fatura_turu", Baslik: "Fatura Türü"),
            new("medulaFaturaNo", "medula_fatura_no", "metin", Yazilabilir: false, Baslik: "Medula Fatura No"),
            new("faturaTarihi", "fatura_tarihi", "tarih", Baslik: "Tarih"),
            new("yerelTutar", "yerel_tutar", "para", Yazilabilir: false, Baslik: "Yerel Tutar"),
            new("medulaTutar", "medula_tutar", "para", Yazilabilir: false, Baslik: "Medula Tutarı"),
            new("hastaKatilim", "hasta_katilim", "para", Yazilabilir: false, Baslik: "Hasta Katılım"),
            new("sgkTutar", "sgk_tutar", "para", Yazilabilir: false, Baslik: "SGK Tutarı"),
            new("durum", "durum", "kod", KodListesi: "medula.fatura_durum", Yazilabilir: false, Baslik: "Durum"),
            new("sonucMesaj", "sonuc_mesaj", "metin", Yazilabilir: false, Baslik: "Sonuç"),
            new("kayitZaman", "kayit_zaman", "zaman", Yazilabilir: false, Baslik: "Kayıt Zamanı"),
        });
}
