using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// PARA MATEMATİĞİ (BelgeHesap) — ürünün en pahalı hataları burada doğar.
///
/// Kural Delphi'den birebir taşındı: satır tutarı önce <c>adet × fiyat</c>
/// olarak YUVARLANIR, iskontolar sonra uygulanır ve iki iskonto ÇARPIMSALDIR
/// (toplanmaz). Sıra değişirse fatura ile fişin toplamı tutmaz — bu testler
/// o sırayı sabitler.
/// </summary>
public class ParaHesabiTestleri
{
    [Fact]
    public void SatirTutari_IskontosuzTutariYuvarlar()
    {
        // 3 × 10,005 = 30,015 → kuruşa yuvarlanır.
        Assert.Equal(30.02m, BelgeHesap.SatirTutari(3m, 10.005m, 0m, 0m));
    }

    [Fact]
    public void SatirTutari_TekIskonto()
    {
        // 1.000,00 üzerinden %10 → 900,00
        Assert.Equal(900m, BelgeHesap.SatirTutari(1m, 1000m, 10m, 0m));
    }

    [Fact]
    public void IkiIskonto_CarpimsaldirToplamsalDegil()
    {
        // %10 + %10 = %19 (0,9 × 0,9), %20 DEĞİL.
        var tutar = BelgeHesap.SatirTutari(1m, 1000m, 10m, 10m);
        Assert.Equal(810m, tutar);
        Assert.NotEqual(800m, tutar);
    }

    [Fact]
    public void Yuvarlama_BANKER_kuralidir()
    {
        // MidpointRounding.ToEven: tam ortadaki değer ÇİFT haneye gider.
        //   0,005 → 0,00 (0 çift) · 0,015 → 0,02 (2 çift). Delphi tarafı da
        //   böyle yuvarlıyor; iki üründe farklı kural olsa aynı fatura iki
        //   sistemde bir kuruş ayrışırdı.
        Assert.Equal(0.00m, BelgeHesap.Yuvarla(0.005m));
        Assert.Equal(0.02m, BelgeHesap.Yuvarla(0.015m));
    }

    [Fact]
    public void DovizKarsiligi_YerelTutariKuraBOLER()
    {
        // 1.000 TL, kur 34,1234 → 29,31 USD. (Çarpma değil BÖLME: alan
        //   "yerel tutarın döviz karşılığı".)
        Assert.Equal(29.31m, BelgeHesap.DovizKarsiligi(1000m, 34.1234m, 2));
        // Kur 0/eksi ise tutar aynen döner - sıfıra bölme yok.
        Assert.Equal(1000m, BelgeHesap.DovizKarsiligi(1000m, 0m, 2));
    }

    [Fact]
    public void YerelBirimFiyat_DovizFiyatiKurlaCARPAR()
    {
        Assert.Equal(3412.34m, BelgeHesap.YerelBirimFiyat(100m, 34.1234m, 2));
    }

    [Theory]
    // adet, fiyat, iskonto1, iskonto2, beklenen
    [InlineData(2, 49.99, 0, 0, 99.98)]
    [InlineData(1, 1234.567, 0, 0, 1234.57)]
    [InlineData(5, 19.99, 5, 0, 94.95)]
    public void SatirTutari_OrnekKumesi(double adet, double fiyat, double isk1, double isk2,
                                        double beklenen)
    {
        var sonuc = BelgeHesap.SatirTutari((decimal)adet, (decimal)fiyat,
                                           (decimal)isk1, (decimal)isk2);
        Assert.Equal((decimal)beklenen, sonuc);
    }
}
