namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MUAYENE ve LABORATUVAR ISTEM kartlari (360).
///
/// UCRET BURADA YOK: fiyat ve odeyen kurum BASVURU belgesinde durur (274/289
/// zinciri) - kart yalniz `belgeId` bagini tasir. Iki yerde fiyat tutmak, biri
/// guncellenip oteki unutuldugunda hangisinin dogru oldugu sorusunu dogurur
/// (radyoloji isteminde de ayni kural).
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>Muayene turu (360): ilk / kontrol / konsultasyon.</summary>
    private static readonly Dictionary<string, string> MuayeneTuruKodlari = new()
    {
        ["1"] = "İlk Muayene", ["2"] = "Kontrol", ["3"] = "Konsültasyon"
    };

    /// <summary>Muayene durumu: acik (devam eden) / tamamlandi / iptal.</summary>
    private static readonly Dictionary<string, string> MuayeneDurumKodlari = new()
    {
        ["1"] = "Açık", ["2"] = "Tamamlandı", ["3"] = "İptal"
    };

    /// <summary>Lab bolumu (360).</summary>
    private static readonly Dictionary<string, string> LabBolumKodlari = new()
    {
        ["1"] = "Biyokimya", ["2"] = "Mikrobiyoloji", ["3"] = "Genetik",
        ["4"] = "Patoloji",  ["9"] = "Diğer"
    };

    /// <summary>Lab istem durumu: numune ve calisma akisini izler.</summary>
    private static readonly Dictionary<string, string> LabDurumKodlari = new()
    {
        ["1"] = "İstendi", ["2"] = "Numune Alındı", ["3"] = "Çalışılıyor",
        ["4"] = "Sonuçlandı", ["5"] = "Onaylandı", ["9"] = "İptal"
    };

    /// <summary>Test sonucunun degerlendirmesi - sonuc formunda rozet olur.</summary>
    private static readonly Dictionary<string, string> LabIsaretKodlari = new()
    {
        ["0"] = "Normal", ["1"] = "Düşük", ["2"] = "Yüksek", ["3"] = "Panik"
    };

    private static KartTanimi MuayeneKarti() => new(
        Ad: "muayene",
        YetkiKodu: "muayene",
        Tablo: "public.muayene",
        LogTabloId: 960,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,             // İlk muayene
            ["durum"] = (short)1,           // Açık
            ["muayeneTarihi"] = "@simdi",
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            // Hasta binlerce kayit: combo degil ARAMA EKRANI (260).
            new("tarafId", "taraf_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Kimlik"),
            // Basvuru BOS birakilabilir: kontrol muayenesi yeni basvuru
            //   acmadan da yazilabilsin (ucretsiz kontrol).
            new("belgeId", "belge_id", "sayi",
                Baslik: "Başvuru (Protokol Id)", Grup: "Kimlik"),
            new("muayeneNo", "muayene_no", "metin", EnFazlaUzunluk: 30,
                Baslik: "Muayene No", Grup: "Kimlik"),
            new("muayeneTarihi", "muayene_tarihi", "tarih", Zorunlu: true,
                Baslik: "Tarih / Saat", Grup: "Kimlik"),
            new("tur", "tur", "kod", SabitKodlar: MuayeneTuruKodlari,
                Baslik: "Tür", Grup: "Kimlik"),
            new("bolumId", "bolum_id", "kod", KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm", Grup: "Kimlik"),
            new("personelId", "personel_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Hekim", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: MuayeneDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // --------------------------------------------------- klinik ----
            new("sikayet", "sikayet", "metin", Baslik: "Şikayet", Grup: "Klinik"),
            new("oyku", "oyku", "metin", Baslik: "Öykü", Grup: "Klinik"),
            new("bulgu", "bulgu", "metin", Baslik: "Muayene Bulguları", Grup: "Klinik"),

            // ------------------------------------------------ tani/tedavi ----
            // ICD kodlari virgullu metin: kod tablosu (SKRS) baglanana kadar
            //   hekim yazabilsin - bos alan birakip beklemek muayeneyi durdururdu.
            new("taniKodlari", "tani_kodlari", "metin", EnFazlaUzunluk: 200,
                Baslik: "ICD Kodları", Grup: "Tanı / Tedavi"),
            new("tani", "tani", "metin", EnFazlaUzunluk: 300,
                Baslik: "Tanı", Grup: "Tanı / Tedavi"),
            new("tedavi", "tedavi", "metin", Baslik: "Tedavi", Grup: "Tanı / Tedavi"),
            new("oneri", "oneri", "metin", Baslik: "Öneri", Grup: "Tanı / Tedavi")
        });

    private static KartTanimi LabIstemKarti() => new(
        Ad: "lab-istem",
        YetkiKodu: "lab",
        Tablo: "public.lab_istem",
        LogTabloId: 961,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["bolum"] = (short)1,           // Biyokimya
            ["durum"] = (short)1,           // İstendi
            ["istemTarihi"] = "@simdi",
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            new("tarafId", "taraf_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "İstem"),
            new("belgeId", "belge_id", "sayi",
                Baslik: "Başvuru (Protokol Id)", Grup: "İstem"),
            new("istemNo", "istem_no", "metin", EnFazlaUzunluk: 30,
                Baslik: "İstem No", Grup: "İstem"),
            new("istemTarihi", "istem_tarihi", "tarih", Zorunlu: true,
                Baslik: "İstem Tarihi", Grup: "İstem"),
            new("bolum", "bolum", "kod", SabitKodlar: LabBolumKodlari,
                Baslik: "Bölüm", Grup: "İstem"),
            new("personelId", "personel_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "İsteyen Hekim", Grup: "İstem"),
            new("durum", "durum", "kod", SabitKodlar: LabDurumKodlari,
                Baslik: "Durum", Grup: "İstem"),

            // Numune ve sonuc zamanlari AYRI: "ne zaman alindi / ne zaman cikti"
            //   laboratuvarin temel performans sorusudur.
            new("numuneTarihi", "numune_tarihi", "tarih",
                Baslik: "Numune Alma", Grup: "Süreç"),
            new("sonucTarihi", "sonuc_tarihi", "tarih",
                Baslik: "Sonuç", Grup: "Süreç"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Süreç")
        },
        Detaylar: new DetayTanimi[]
        {
            // TESTLER: istemin satirlari. Sonuc girisi de burada - ayri bir
            //   "sonuc girisi" ekrani, teknisyeni ayni kaydin iki yuzu arasinda
            //   gezdirirdi.
            new("testler", "public.lab_istem_test", "istem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "kod", KodTablosu: "public.v_hizmet_lookup",
                    AramaKaynagi: "hizmet", Baslik: "Test (Hizmet)"),
                new("kod", "kod", "metin", EnFazlaUzunluk: 30, Baslik: "Kod"),
                new("ad", "ad", "metin", EnFazlaUzunluk: 200, Baslik: "Test Adı"),
                new("sonuc", "sonuc", "metin", EnFazlaUzunluk: 100, Baslik: "Sonuç"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                new("referans", "referans", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Referans Aralığı"),
                new("isaret", "isaret", "kod", SabitKodlar: LabIsaretKodlari,
                    Baslik: "Değerlendirme"),
                new("cihaz", "cihaz", "metin", EnFazlaUzunluk: 60, Baslik: "Cihaz"),
                new("sonucTarihi", "sonuc_tarihi", "tarih", Baslik: "Sonuç Zamanı"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama")
            }, SubeKolonu: null, Sirala: "id", Baslik: "Testler", LogTabloId: 962)
        });
}
