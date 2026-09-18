namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// NÖBET ve ATAMA KURALI KARTLARI (801).
///
/// Kullanıcı: *"nöbet çizelgesi ve atama kurallarıyla devam et"*.
///
/// <b>Çizelge kim/ne zaman, kural hangi iş kime.</b> İkisi de otomatik
/// dağıtımın girdisidir: `fn_telerad_radyolog_oner` önce kuralları sıraya
/// göre okur, hedefi "o anki nöbetçi" olan kural çizelgeye bakar.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> TeleradKartNobetTur = new()
    {
        ["1"] = "Gündüz", ["2"] = "Gece", ["3"] = "Hafta sonu",
        ["4"] = "Yedek (asıl nöbetçi doluysa)",
    };

    private static readonly Dictionary<string, string> TeleradKartHedef = new()
    {
        ["1"] = "O anki nöbetçi", ["2"] = "Belirli radyolog",
        ["3"] = "En az yüklü radyolog",
    };

    private static readonly Dictionary<string, string> TeleradKartKuralOncelik = new()
        { ["0"] = "Tümü", ["1"] = "Rutin", ["2"] = "Öncelikli", ["3"] = "ACİL" };

    private static readonly Dictionary<string, string> TeleradKartKuralModalite = new()
    {
        ["0"] = "Tümü", ["1"] = "BT", ["2"] = "MR", ["3"] = "USG", ["4"] = "Röntgen",
        ["5"] = "Mamografi", ["6"] = "DEXA", ["7"] = "Anjiyo", ["8"] = "Skopi",
    };

    private static KartTanimi TeleradNobet() => new(
        Ad: "telerad-nobet",
        YetkiKodu: "teleradyoloji.nobet",
        Tablo: "public.telerad_nobet",
        LogTabloId: 1323,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,          // gündüz
            ["aktif"] = (short)1,
            ["baslangic"] = "@simdi",
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            new("radyologId", "radyolog_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_rad_hekim_lookup",
                Baslik: "Radyolog", Grup: "Kimlik"),
            new("tur", "tur", "kod", SabitKodlar: TeleradKartNobetTur,
                Baslik: "Vardiya", Grup: "Kimlik"),
            // ZAMAN ARALIĞI TAM TARİH-SAAT: nöbet gece yarısını geçer
            //   ("20:00 - 08:00"). Sadece saat saklamak, geceyi iki satıra
            //   bölmek ya da "bitiş başlangıçtan küçük" istisnası uydurmak
            //   demekti (db/801).
            new("baslangic", "baslangic", "zaman", Zorunlu: true,
                Baslik: "Başlangıç", Grup: "Kimlik"),
            new("bitis", "bitis", "zaman", Zorunlu: true,
                Baslik: "Bitiş", Grup: "Kimlik"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            // ----------------------------------------------------- kapsam ---
            // KAPSAM BOŞ = HER İŞ. Kuruma ya da modaliteye bağlı nöbet,
            //   "gece yalnız BT okuyan radyolog" gibi gerçek bir düzeni
            //   anlatır; boş bırakmak en yaygın hâldir.
            new("kurumId", "kurum_id", "kod",
                KodTablosu: "public.v_telerad_kurum_lookup",
                Baslik: "Kurum", Grup: "Kapsam"),
            new("modalite", "modalite", "kod", SabitKodlar: TeleradKartKuralModalite,
                Baslik: "Modalite", Grup: "Kapsam"),
            // AZAMI İŞ: otomatik dağıtım bir kişiyi boğmasın. 0 = sınırsız.
            new("azamiIs", "azami_is", "sayi",
                Baslik: "Azami Açık İş", Grup: "Kapsam"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Kapsam"),
        });

    private static KartTanimi TeleradKural() => new(
        Ad: "telerad-kural",
        YetkiKodu: "teleradyoloji.kural",
        Tablo: "public.telerad_atama_kurali",
        LogTabloId: 1324,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["sira"] = 10,
            ["hedefTur"] = (short)1,     // o anki nöbetçi
            ["modalite"] = (short)0,     // tümü
            ["oncelik"] = (short)0,      // tümü
            ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Kural Adı", Grup: "Kimlik"),
            // SIRA KARAR SIRASIDIR: ilk uyan kural kazanır. "Acil BT önce
            //   Dr. X'e" kuralı "her iş nöbetçiye" kuralının ÜSTÜNDE durmalı.
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Kimlik"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            // ----------------------------------------------------- koşul ----
            // BOŞ/TÜMÜ = AYIRT ETME. Kural yalnız doldurulan alanlarla daralır.
            new("kurumId", "kurum_id", "kod",
                KodTablosu: "public.v_telerad_kurum_lookup",
                Baslik: "Kurum", Grup: "Koşul"),
            new("modalite", "modalite", "kod", SabitKodlar: TeleradKartKuralModalite,
                Baslik: "Modalite", Grup: "Koşul"),
            new("oncelik", "oncelik", "kod", SabitKodlar: TeleradKartKuralOncelik,
                Baslik: "Öncelik", Grup: "Koşul"),
            // SAAT / GÜN çalışma planıyla (718) AYNI biçim: 'HH:MM' ve
            //   "1,2,3" (1 Pzt … 7 Paz). Pencere gece yarısını geçebilir.
            new("gunler", "gunler", "metin", EnFazlaUzunluk: 20,
                Baslik: "Günler", Grup: "Koşul"),
            new("saatBas", "saat_bas", "metin", EnFazlaUzunluk: 5,
                Baslik: "Saat Baş", Grup: "Koşul"),
            new("saatBit", "saat_bit", "metin", EnFazlaUzunluk: 5,
                Baslik: "Saat Bitiş", Grup: "Koşul"),

            // ----------------------------------------------------- hedef ----
            new("hedefTur", "hedef_tur", "kod", SabitKodlar: TeleradKartHedef,
                Baslik: "Hedef", Grup: "Hedef"),
            // "Belirli radyolog" seçildiyse kim olduğu YAZILMALI - veritabanı
            //   da bunu zorluyor (`ck_telerad_kural_radyolog`): kimi
            //   olmayan kural sessizce hiçbir zaman eşleşmezdi.
            new("hedefRadyologId", "hedef_radyolog_id", "kod",
                KodTablosu: "public.v_rad_hekim_lookup",
                Baslik: "Radyolog", Grup: "Hedef"),
            new("azamiIs", "azami_is", "sayi",
                Baslik: "Azami Açık İş", Grup: "Hedef"),
        });
}
