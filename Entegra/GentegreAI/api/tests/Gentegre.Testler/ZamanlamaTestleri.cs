using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Zamanlama;

namespace Gentegre.Testler;

/// <summary>
/// ZAMANLI İŞ HESABI (405) ve BİLDİRİM ŞABLONU (399).
///
/// İkisi de "yanlış olduğu ancak günler sonra fark edilen" cinsten: haftalık
/// iş yanlış güne kayarsa kimse hemen görmez, şablon değişkeni boş giderse
/// SMS gitmiş ama anlamsız olur.
/// </summary>
public class ZamanlamaTestleri
{
    // 2026-09-05 Cumartesi 18:00
    private static readonly DateTime Cumartesi = new(2026, 9, 5, 18, 0, 0);

    [Fact]
    public void Haftalik_PazartesiSabahiBulunur()
    {
        // Cumartesi 18:00 → sıradaki Pazartesi 04:00 = 7 Eylül.
        var s = ZamanlamaHesabi.Haftalik(Cumartesi, gun: 1, saat: 4, dakika: 0);
        Assert.Equal(new DateTime(2026, 9, 7, 4, 0, 0), s);
    }

    [Fact]
    public void Haftalik_AYNI_GUN_saatiGectiyseGelecekHafta()
    {
        // Cumartesi 18:00'de "Cumartesi 04:00" istenirse HAFTAYA - aynı gün
        //   geçmiş bir saate iş konmaz (yoksa açılışta hemen tetiklenirdi).
        var s = ZamanlamaHesabi.Haftalik(Cumartesi, gun: 6, saat: 4, dakika: 0);
        Assert.Equal(new DateTime(2026, 9, 12, 4, 0, 0), s);
    }

    [Fact]
    public void Haftalik_AYNI_GUN_saatiGelmediyseBugun()
    {
        var s = ZamanlamaHesabi.Haftalik(Cumartesi, gun: 6, saat: 23, dakika: 30);
        Assert.Equal(new DateTime(2026, 9, 5, 23, 30, 0), s);
    }

    [Fact]
    public void Haftalik_PazarISO7dir()
    {
        // Pazar = 7 (DayOfWeek'te 0); yanlış eşleme işi bir gün kaydırırdı.
        var pazar = new DateTime(2026, 9, 6, 12, 0, 0);
        Assert.Equal(new DateTime(2026, 9, 6, 20, 0, 0),
                     ZamanlamaHesabi.Haftalik(pazar, gun: 7, saat: 20, dakika: 0));
    }

    [Fact]
    public void Gunluk_SaatGectiyseYarin()
    {
        Assert.Equal(new DateTime(2026, 9, 6, 4, 0, 0),
                     ZamanlamaHesabi.Gunluk(Cumartesi, 4, 0));
        Assert.Equal(new DateTime(2026, 9, 5, 22, 15, 0),
                     ZamanlamaHesabi.Gunluk(Cumartesi, 22, 15));
    }

    [Fact]
    public void Aylik_AyinGunu28eKirpilir()
    {
        // 31 verilse Şubat'ta hiç çalışmazdı; kırpma bu yüzden var.
        var s = ZamanlamaHesabi.Sonraki(Cumartesi, periyot: 4, gun: 31, saat: 3, dakika: 0);
        Assert.Equal(28, s.Day);
    }

    [Fact]
    public void Saatlik_BirSaatSonra()
        => Assert.Equal(Cumartesi.AddHours(1),
                        ZamanlamaHesabi.Sonraki(Cumartesi, periyot: 1, gun: 0, saat: 0, dakika: 0));

    // ------------------------------------------------------------- şablon ----
    [Fact]
    public void Sablon_DegiskenleriDoldurur()
    {
        var metin = BildirimSablonu.Doldur(
            "Sayın {{hasta_ad}}, {{tarih}} randevunuz var.",
            new Dictionary<string, string> { ["hasta_ad"] = "ADEM DERE", ["tarih"] = "08.09.2026" });
        Assert.Equal("Sayın ADEM DERE, 08.09.2026 randevunuz var.", metin);
    }

    [Fact]
    public void Sablon_BilinmeyenDegiskenOLDUGUGIBIKALIR()
    {
        // Silinmez: gönderilmiş SMS'te "{{bolum}}" görülürse hata bellidir;
        //   boş bırakılsa mesaj sessizce eksik giderdi.
        var metin = BildirimSablonu.Doldur("{{bolum}} bölümü",
            new Dictionary<string, string> { ["hasta_ad"] = "X" });
        Assert.Equal("{{bolum}} bölümü", metin);
    }

    [Fact]
    public void Sablon_BosDegerlerdeMetinBozulmaz()
    {
        Assert.Equal("sabit", BildirimSablonu.Doldur("sabit", null));
        Assert.Equal("", BildirimSablonu.Doldur("", new Dictionary<string, string>()));
    }
}
