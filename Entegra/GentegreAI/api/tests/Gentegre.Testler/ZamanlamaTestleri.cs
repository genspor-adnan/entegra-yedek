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

    // ------------------------------------------------- kurum saati (1079) ----
    private static readonly TimeZoneInfo Istanbul = Gentegre.Cekirdek.Saat.Dilim("Europe/Istanbul");
    private static DateTime Utc(int ay, int gun, int saat, int dakika = 0)
        => new(2026, ay, gun, saat, dakika, 0, DateTimeKind.Utc);

    [Fact]
    public void SonrakiAn_saat_KURUMUN_DUVAR_SAATI()
    {
        // 13.10 06:00 UTC = 09:00 İstanbul. "Günlük 07:30" bugün geçti ->
        //   yarın 07:30 İstanbul = 04:30 UTC. Eskiden 07:30 UTC (yerel 10:30).
        var s = ZamanlamaHesabi.SonrakiAn(Utc(10, 13, 6), Istanbul, 2, 1, 7, 30);
        Assert.Equal(Utc(10, 14, 4, 30), s);
        Assert.Equal(DateTimeKind.Utc, s.Kind);
    }

    [Fact]
    public void SonrakiAn_GUN_yerel_gune_gore()
    {
        // 13.10 22:00 UTC = 14.10 01:00 İstanbul: yerelde gün DÖNMÜŞ. "Günlük
        //   04:00" aynı yerel gün 04:00 = 14.10 01:00 UTC. UTC'de hesaplansa
        //   14.10 04:00 UTC (yerel 07:00) çıkardı.
        Assert.Equal(Utc(10, 14, 1),
                     ZamanlamaHesabi.SonrakiAn(Utc(10, 13, 22), Istanbul, 2, 1, 4, 0));
    }

    [Fact]
    public void SonrakiAn_haftalik_YEREL_pazartesi()
    {
        // 11.10 Pazar 21:30 UTC = 12.10 Pazartesi 00:30 İstanbul. "Pazartesi
        //   04:00" -> aynı gece 04:00 yerel = 12.10 01:00 UTC (UTC'ye göre
        //   hâlâ Pazar olduğu için eskiden gün kayardı).
        Assert.Equal(Utc(10, 12, 1),
                     ZamanlamaHesabi.SonrakiAn(Utc(10, 11, 21, 30), Istanbul, 3, 1, 4, 0));
    }

    [Fact]
    public void SonrakiAn_saatlik_dilimden_bagimsiz()
        => Assert.Equal(Utc(10, 13, 7),
                        ZamanlamaHesabi.SonrakiAn(Utc(10, 13, 6), Istanbul, 1, 0, 0, 0));

    [Fact]
    public void SonrakiAn_yaz_saati_OLMAYAN_saat_atlanmaz()
    {
        // Berlin 29.03.2026 02:00 -> 03:00 (02:30 yok). "Günlük 02:30" o gün
        //   03:30 yerel = 01:30 UTC'ye kayar, gün atlanmaz.
        var berlin = Gentegre.Cekirdek.Saat.Dilim("Europe/Berlin");
        Assert.Equal(new DateTime(2026, 3, 29, 1, 30, 0, DateTimeKind.Utc),
                     ZamanlamaHesabi.SonrakiAn(new DateTime(2026, 3, 28, 23, 0, 0, DateTimeKind.Utc),
                                               berlin, 2, 1, 2, 30));
    }

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
