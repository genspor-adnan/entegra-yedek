namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TEKNİK SERVİS KARTLARI (773).
///
/// İŞ EMRİ KARTI BURADA YOK: `demirbasIsEmri` (Biyomedikal) aynı tabloyu
/// yazar ve 773'te yalnız genişletildi - ikinci bir kart, aynı satırın iki
/// ayrı doğrulama kümesiyle düzenlenmesi demekti.
///
/// Çağrı, ziyaret ve emanet kartları SALT OKUNUR alanlarla doludur: durumu
/// ve zaman damgalarını uçlar yazar (`/api/servis/...`). Karttan serbest
/// yazılabilseydi "imzasız ziyaret kapanmaz" ve "açık emanetle teslim
/// edilemez" kuralları kartın arkasından dolanılabilirdi.
/// </summary>
public static partial class KartKatalogu
{
    // ------------------------------------------------------------ çağrı ----
    private static KartTanimi ServisCagri() => new(
        Ad: "servisCagri",
        YetkiKodu: "servis",
        Tablo: "public.servis_cagri",
        LogTabloId: 1316,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("cagriNo", "cagri_no", "metin", Yazilabilir: false,
                Baslik: "Çağrı No", Grup: "Çağrı", EnFazlaUzunluk: 30),
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Müşteri",
                Grup: "Çağrı", KodTablosu: "public.v_cari_lookup"),
            new("tarafCihazId", "taraf_cihaz_id", "sayi", Baslik: "Cihaz (park)",
                Grup: "Çağrı"),
            // PARKTA YOKSA BEYAN: ilk çağrıda cihaz çoğu zaman kayıtlı değildir;
            //   kaydı zorunlu tutmak, telefondaki müşteriyi bekletirdi.
            new("cihazMetni", "cihaz_metni", "metin", Baslik: "Cihaz (beyan)",
                Grup: "Çağrı", EnFazlaUzunluk: 200),
            new("sikayet", "sikayet", "metin", Zorunlu: true,
                Baslik: "Şikâyet", Grup: "Çağrı", EnFazlaUzunluk: 600),
            new("kapsamTur", "kapsam_tur", "kod", Baslik: "Kapsam", Grup: "Çağrı",
                SabitKodlar: KaynakKatalogu.ServisKapsamKodlari),
            new("oncelik", "oncelik", "kod", Baslik: "Öncelik", Grup: "Çağrı",
                SabitKodlar: KaynakKatalogu.DbOncelikKodlari),
            new("bildiren", "bildiren", "metin", Baslik: "Bildiren",
                Grup: "Çağrı", EnFazlaUzunluk: 120),
            new("telefon", "telefon", "metin", Baslik: "Telefon", Grup: "Çağrı",
                EnFazlaUzunluk: 30),
            // SÖZLEŞME VE SLA UÇTA ÇÖZÜLÜR: cihazın sözleşmesi, yoksa carinin
            //   yürürlükteki sözleşmesi bulunur ve SLA ondan hesaplanır.
            //   Elle yazılabilseydi taahhüt sözleşmeden kopardı.
            new("sozlesmeId", "sozlesme_id", "sayi", Yazilabilir: false,
                Baslik: "Sözleşme", Grup: "Taahhüt"),
            new("slaBitis", "sla_bitis", "zaman", Yazilabilir: false,
                Baslik: "SLA Bitişi", Grup: "Taahhüt"),
            new("ilkYanit", "ilk_yanit", "zaman", Yazilabilir: false,
                Baslik: "İlk Yanıt", Grup: "Taahhüt"),
            new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                Grup: "Taahhüt", SabitKodlar: KaynakKatalogu.ServisCagriDurumu),
            new("kapanis", "kapanis", "zaman", Yazilabilir: false,
                Baslik: "Kapanış", Grup: "Taahhüt"),
            new("sonuc", "sonuc", "metin", Baslik: "Sonuç", Grup: "Taahhüt",
                EnFazlaUzunluk: 400),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama",
                Grup: "Taahhüt", EnFazlaUzunluk: 300),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0, ["kapsam_tur"] = 1, ["oncelik"] = 3,
        });

    // --------------------------------------------------------- ziyaret ----
    private static KartTanimi ServisZiyaret() => new(
        Ad: "servisZiyaret",
        YetkiKodu: "servis",
        Tablo: "public.servis_ziyaret",
        LogTabloId: 1317,
        SubeKolonu: null,
        Alanlar: new KartAlani[]
        {
            new("isEmriId", "is_emri_id", "sayi", Zorunlu: true,
                Baslik: "İş Emri", Grup: "Ziyaret"),
            new("sira", "sira", "sayi", Yazilabilir: false, Baslik: "Sıra",
                Grup: "Ziyaret"),
            new("teknisyenId", "teknisyen_id", "sayi", Baslik: "Teknisyen",
                Grup: "Ziyaret", KodTablosu: "public.v_personel_lookup"),
            new("planZamani", "plan_zamani", "zaman", Baslik: "Planlanan",
                Grup: "Ziyaret"),
            new("arac", "arac", "metin", Baslik: "Araç", Grup: "Ziyaret",
                EnFazlaUzunluk: 40),
            new("varis", "varis", "zaman", Yazilabilir: false, Baslik: "Varış",
                Grup: "Ziyaret"),
            new("ayrilis", "ayrilis", "zaman", Yazilabilir: false,
                Baslik: "Ayrılış", Grup: "Ziyaret"),
            new("yolKm", "yol_km", "sayi", Baslik: "Yol (km)", Grup: "Ziyaret"),
            new("mesaiDisi", "mesai_disi", "mantik", Baslik: "Mesai dışı",
                Grup: "Ziyaret"),
            new("yapilan", "yapilan", "metin", Baslik: "Yapılan İş",
                Grup: "Sonuç", EnFazlaUzunluk: 600),
            // SONUÇ VE İMZA UÇTAN YAZILIR (`/ziyaret/{id}/kapat`): imzasız
            //   kapanış oradaki kuralla engelleniyor, kart onu atlatmasın.
            new("sonuc", "sonuc", "kod", Yazilabilir: false, Baslik: "Sonuç",
                Grup: "Sonuç", SabitKodlar: KaynakKatalogu.ZiyaretSonucKodlari),
            new("sonucMetni", "sonuc_metni", "metin", Yazilabilir: false,
                Baslik: "Sonuç Notu", Grup: "Sonuç", EnFazlaUzunluk: 400),
            new("imzaAlindi", "imza_alindi", "mantik", Yazilabilir: false,
                Baslik: "Müşteri imzası", Grup: "Sonuç"),
            new("imzaNotu", "imza_notu", "metin", Yazilabilir: false,
                Baslik: "İmza Notu", Grup: "Sonuç", EnFazlaUzunluk: 200),
            new("iscilikSaat", "iscilik_saat", "sayi", Baslik: "İşçilik (sa)",
                Grup: "Sonuç"),
            new("tutar", "tutar", "para", Baslik: "Tutar", Grup: "Sonuç"),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["sonuc"] = 0, ["sira"] = 1,
        });

    // ---------------------------------------------------------- emanet ----
    private static KartTanimi ServisEmanet() => new(
        Ad: "servisEmanet",
        YetkiKodu: "servis",
        Tablo: "public.servis_emanet",
        LogTabloId: 1318,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("emanetNo", "emanet_no", "metin", Yazilabilir: false,
                Baslik: "Emanet No", Grup: "Emanet", EnFazlaUzunluk: 30),
            new("isEmriId", "is_emri_id", "sayi", Baslik: "İş Emri",
                Grup: "Emanet"),
            new("tarafId", "taraf_id", "sayi", Baslik: "Kimde", Grup: "Emanet",
                KodTablosu: "public.v_cari_lookup"),
            // İÇ İŞTE YEDEK CİHAZ DEMİRBAŞTIR, dışta emanet havuzundan çıkar
            //   ve demirbaş olmayabilir - ikisi de aynı kayıtta izlenir.
            new("demirbasId", "demirbas_id", "sayi", Baslik: "Demirbaş (iç iş)",
                Grup: "Emanet"),
            new("cihazMetni", "cihaz_metni", "metin", Baslik: "Cihaz",
                Grup: "Emanet", EnFazlaUzunluk: 200),
            new("veris", "veris", "zaman", Yazilabilir: false, Baslik: "Veriliş",
                Grup: "Emanet"),
            new("iade", "iade", "zaman", Yazilabilir: false, Baslik: "İade",
                Grup: "Emanet"),
            new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                Grup: "Emanet", SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Dışarıda", ["2"] = "İade alındı" }),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama",
                Grup: "Emanet", EnFazlaUzunluk: 300),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = 1 });

    // ----------------------------------------------------- cihaz parkı ----
    /// <summary>
    /// Müşteri cihazı bizim demirbaşımız DEĞİLDİR; bu yüzden ayrı kart.
    /// Bizim satmadığımız cihaz da girer - servisini veriyorsak kaydı bizde
    /// olmalı, `satisBelgeId` boş kalır.
    /// </summary>
    private static KartTanimi TarafCihaz() => new(
        Ad: "tarafCihaz",
        YetkiKodu: "servis.cihaz",
        Tablo: "public.taraf_cihaz",
        LogTabloId: 1319,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Müşteri",
                Grup: "Cihaz", KodTablosu: "public.v_cari_lookup"),
            new("ad", "ad", "metin", Zorunlu: true, Baslik: "Cihaz / Ürün",
                Grup: "Cihaz", EnFazlaUzunluk: 150),
            new("marka", "marka", "metin", Baslik: "Marka", Grup: "Cihaz",
                EnFazlaUzunluk: 80),
            new("model", "model", "metin", Baslik: "Model", Grup: "Cihaz",
                EnFazlaUzunluk: 80),
            new("seriNo", "seri_no", "metin", Baslik: "Seri No", Grup: "Cihaz",
                EnFazlaUzunluk: 60),
            new("stokId", "stok_id", "sayi", Baslik: "Ürün kartı (varsa)",
                Grup: "Cihaz"),
            new("kurulumTarihi", "kurulum_tarihi", "tarih", Baslik: "Kurulum",
                Grup: "Garanti"),
            new("garantiBitis", "garanti_bitis", "tarih", Baslik: "Garanti Bitişi",
                Grup: "Garanti"),
            new("satisBelgeId", "satis_belge_id", "sayi",
                Baslik: "Satış Belgesi (bizden alındıysa)", Grup: "Garanti"),
            new("sozlesmeId", "sozlesme_id", "sayi", Baslik: "Bakım Sözleşmesi",
                Grup: "Garanti"),
            new("bolge", "bolge", "metin", Baslik: "Bölge", Grup: "Yer",
                EnFazlaUzunluk: 60),
            new("adres", "adres", "metin", Baslik: "Adres", Grup: "Yer",
                EnFazlaUzunluk: 300),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Yer",
                SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Kullanımda", ["0"] = "Pasif" }),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Yer",
                EnFazlaUzunluk: 300),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = 1 });

    // -------------------------------------------------------- sözleşme ----
    private static KartTanimi ServisSozlesme() => new(
        Ad: "servisSozlesme",
        YetkiKodu: "servis.sozlesme",
        Tablo: "public.servis_sozlesme",
        LogTabloId: 1320,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("sozlesmeNo", "sozlesme_no", "metin", Baslik: "Sözleşme No",
                Grup: "Sözleşme", EnFazlaUzunluk: 30),
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Müşteri",
                Grup: "Sözleşme", KodTablosu: "public.v_cari_lookup"),
            new("baslangic", "baslangic", "tarih", Zorunlu: true,
                Baslik: "Başlangıç", Grup: "Sözleşme"),
            new("bitis", "bitis", "tarih", Zorunlu: true, Baslik: "Bitiş",
                Grup: "Sözleşme"),
            new("kapsam", "kapsam", "kod", Baslik: "Kapsam", Grup: "Sözleşme",
                SabitKodlar: new Dictionary<string, string>
                {
                    ["1"] = "İşçilik", ["2"] = "İşçilik + yol",
                    ["3"] = "Tam kapsam (parça dahil)",
                }),
            // SLA SÖZLEŞMENİN ALANIDIR: aynı arıza 4 saatlik sözleşmede acil,
            //   24 saatlikte normaldir. Çağrının önceliğiyle karıştırılmamalı.
            new("slaSaat", "sla_saat", "sayi", Baslik: "SLA (saat)",
                Grup: "Taahhüt"),
            new("periyotAy", "periyot_ay", "sayi",
                Baslik: "Periyodik bakım (ay · 0 = yok)", Grup: "Taahhüt"),
            new("yillikBedel", "yillik_bedel", "para", Baslik: "Yıllık Bedel",
                Grup: "Taahhüt"),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Taahhüt",
                SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Yürürlükte", ["0"] = "Pasif" }),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama",
                Grup: "Taahhüt", EnFazlaUzunluk: 300),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 1, ["kapsam"] = 1, ["sla_saat"] = 24, ["periyot_ay"] = 0,
        });
}
