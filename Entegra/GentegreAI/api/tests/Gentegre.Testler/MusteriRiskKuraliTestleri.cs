using Gentegre.Veri.Depolar;
using static Gentegre.Veri.Depolar.MusteriRiskKurali;

namespace Gentegre.Testler;

/// <summary>
/// MÜŞTERİ RİSKİ (1178) - satış belgesi kaydındaki limit / bloke kararı, A–D skoru ve sevk blokesi önerisi.
/// VERİTABANI GEREKTİRMEZ: kararlar saf fonksiyon (MusteriRiskKurali); risk tutarını sorgu verir, kararı bu sınıf.
/// Ayar `satis.limit_davranis` AyarDeposu'nda büyük harfe çevrilir ("ENGELLE") - kip büyük/küçük harf duyarsız,
/// boş / tanınmayan değer "uyar".
/// </summary>
public class MusteriRiskKuraliTestleri
{
    [Theory]
    [InlineData(null, false)]
    [InlineData("", false)]
    [InlineData("uyar", false)]
    [InlineData("UYAR", false)]
    [InlineData("engelle", true)]
    [InlineData("ENGELLE", true)]
    [InlineData(" Engelle ", true)]
    [InlineData("abc", false)]
    public void KipBuyukKucukHarfDuyarsiz(string? ayar, bool engel) => Assert.Equal(engel, EngelKipi(ayar));

    [Fact]
    public void LimitIcindeVeBlokesizSorunYok()
        => Assert.Equal(Sonuc.Yok, LimitKarari("ENGELLE", false, "", 1000m, "TL", 1000m, 1000m, false).Sonuc);

    [Fact]
    public void LimitTanimsizLimitsizDegilAmaKontrolEdilmez()
        => Assert.Equal(Sonuc.Yok, LimitKarari("ENGELLE", false, "", null, "TL", null, 1_000_000m, false).Sonuc);

    [Fact]
    public void UyarKipindeAsimUyariDoner()
    {
        var k = LimitKarari("UYAR", false, "", 1000m, "TL", 1000m, 1200m, false);
        Assert.Equal(Sonuc.Uyari, k.Sonuc);
        Assert.Contains("aşılıyor", k.Mesaj);
    }

    [Fact]
    public void EngelKipindeAsimEngeller()
        => Assert.Equal(Sonuc.Engel, LimitKarari("ENGELLE", false, "", 1000m, "TL", 1000m, 1000.01m, false).Sonuc);

    [Fact]
    public void EngelKipindeYetkiliUyariylaGecer()
        => Assert.Equal(Sonuc.Uyari, LimitKarari("ENGELLE", false, "", 1000m, "TL", 1000m, 5000m, true).Sonuc);

    [Fact]
    public void SevkBlokesiLimitsizMusterideDeIsler()
    {
        Assert.Equal(Sonuc.Engel, LimitKarari("ENGELLE", true, "vadesi geçen", null, "TL", null, 0m, false).Sonuc);
        var u = LimitKarari(null, true, "vadesi geçen", null, "TL", null, 0m, false);
        Assert.Equal(Sonuc.Uyari, u.Sonuc);
        Assert.Contains("sevk blokesinde", u.Mesaj);
    }

    [Fact]
    public void DovizliLimitTlKarsiligiylaKarsilastirilir()
    {
        // 10.000 USD × 40 = 400.000 TL; risk 410.000 TL aşar, 390.000 TL aşmaz.
        Assert.Equal(Sonuc.Engel, LimitKarari("ENGELLE", false, "", 10_000m, "USD", 400_000m, 410_000m, false).Sonuc);
        Assert.Equal(Sonuc.Yok, LimitKarari("ENGELLE", false, "", 10_000m, "USD", 400_000m, 390_000m, false).Sonuc);
    }

    [Fact]
    public void KurYoksaEngelYokYalnizUyari()
        => Assert.Equal(Sonuc.Uyari, LimitKarari("ENGELLE", false, "", 10_000m, "USD", null, 9_999_999m, false).Sonuc);

    [Fact]
    public void OdemeGecmisiYoksaSkorYok() => Assert.Null(SkorHesapla(null, null, 0, 50));

    [Theory]
    [InlineData(100.0, 0.0, 0, 50.0, "A")]      // kusursuz ödeyen
    [InlineData(88.0, 4.0, 0, 91.0, "A")]       // mockup: DENTA KLİNİK
    [InlineData(34.0, 41.0, 1, 152.0, "D")]     // mockup: GÜLÜMSE - geç öder, karşılıksız, limit üstü
    [InlineData(70.0, 15.0, 0, null, "B")]    // limit tanımsız: limit payı düşer
    public void SabitAgirlikliSkor(double zamaninda, double gecikme, int karsiliksiz, double? kullanim, string harf)
        => Assert.Equal(harf, SkorHesapla((decimal)zamaninda, (decimal)gecikme, karsiliksiz, (decimal?)kullanim)!.Harf);

    [Fact]
    public void BlokeOnerisiKurallari()
    {
        // Limit %152, 90+ vadesi geçen, karşılıksız → blokele.
        Assert.Equal("blokele", BlokeOnerisi(false, 152, 156_200, 0, 22_200, 1, 20, 296_700)!.Kod);
        // Limit %141 ama teminat aşımı karşılıyor → uyarıyla sat.
        Assert.Equal("uyar", BlokeOnerisi(false, 141, 61_400, 100_000, 0, 0, 10, 100_000)!.Kod);
        // Hafif aşım, ağır işaret yok → uyarıyla sat.
        Assert.Equal("uyar", BlokeOnerisi(false, 109, 12_900, 0, 0, 0, 10, 100_000)!.Kod);
        // Blokeli, 90+ gecikme ve 6 aydır tahsilat yok → blokede kalsın.
        Assert.Equal("kalsin", BlokeOnerisi(true, null, 0, 0, 18_900, 0, 200, 18_900)!.Kod);
        // Blokeli ama temiz → kaldırılabilir.
        Assert.Equal("kaldir", BlokeOnerisi(true, 40, 0, 0, 0, 0, 5, 10_000)!.Kod);
        // Blokesiz, limit içinde, gecikmesiz → listede yok.
        Assert.Null(BlokeOnerisi(false, 60, 0, 0, 0, 0, 5, 10_000));
    }

    [Theory]
    [InlineData(19, 0, true)]
    [InlineData(19, 30, false)]    // başvuru
    [InlineData(14, 0, true)]
    [InlineData(15, 1, true)]
    [InlineData(15, 2, false)]     // iade faturası riski azaltır
    [InlineData(16, 0, false)]     // fiş / tahsilat kontrol dışı
    [InlineData(11, 0, false)]     // alış
    public void KontrolluBelgeTurleri(int tur, int tipi, bool beklenen)
        => Assert.Equal(beklenen, MusteriRiskDeposu.KontrolluBelge(tur, tipi));
}
