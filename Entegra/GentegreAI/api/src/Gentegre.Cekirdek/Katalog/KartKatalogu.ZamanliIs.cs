namespace Gentegre.Cekirdek.Katalog;

public static partial class KartKatalogu
{
    /// <summary>
    /// ZAMANLI İŞ KARTI (405) — yalnız ZAMANLAMA düzenlenir.
    ///
    /// Kod ve ad yazılamaz: iş kodda tanımlı (ZamanliIsler kayıt defteri),
    /// tablodaki satır onun zamanıdır. Kod değiştirilebilseydi satır kodda
    /// karşılığı olmayan bir işe dönüşür, sessizce hiç çalışmazdı.
    /// </summary>
    private static KartTanimi ZamanliIsKarti() => new(
        Ad: "zamanli-is",
        YetkiKodu: "zamanli_is",
        Tablo: "public.zamanli_is",
        IdKolonu: "kod",
        LogTabloId: 962,
        SubeKolonu: null,
        Alanlar: new KartAlani[]
        {
            new("kod", "kod", "metin", Yazilabilir: false, Baslik: "Kod", Grup: "İş"),
            new("ad",  "ad",  "metin", Yazilabilir: false, Baslik: "İş", Grup: "İş"),
            new("aktif", "aktif", "mantik", Baslik: "Çalışsın", Grup: "İş"),
            new("periyot", "periyot", "kod", Zorunlu: true, SabitKodlar: PeriyotKodlari,
                Baslik: "Periyot", Grup: "Zamanlama"),
            // GUN yalniz haftalik/aylikta anlamli; ekranda hep gorunur ama
            //   periyot saatlik/gunlukse yok sayilir (sunucu da oyle okuyor).
            new("gun", "gun", "sayi", Baslik: "Gün (haftalık 1-7 · aylık 1-28)",
                Grup: "Zamanlama"),
            new("saat", "saat", "sayi", Baslik: "Saat (0-23)", Grup: "Zamanlama"),
            new("dakika", "dakika", "sayi", Baslik: "Dakika", Grup: "Zamanlama"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Zamanlama"),
            // Salt okunur durum alanlari: kartta da gorunsun (listeye donmeden).
            new("sonraki", "sonraki", "tarih", Yazilabilir: false,
                Baslik: "Sıradaki Çalışma", Grup: "Durum"),
            new("sonCalisma", "son_calisma", "tarih", Yazilabilir: false,
                Baslik: "Son Çalışma", Grup: "Durum"),
            new("sonSonuc", "son_sonuc", "metin", Yazilabilir: false,
                Baslik: "Son Sonuç", Grup: "Durum"),
        });

    private static readonly Dictionary<string, string> PeriyotKodlari = new()
    {
        ["1"] = "Saatlik", ["2"] = "Günlük", ["3"] = "Haftalık", ["4"] = "Aylık",
    };
}
