using Gentegre.Veri.Depolar;

namespace Gentegre.Testler;

/// <summary>
/// İCMAL EŞİKLERİ (1176): Genel Ayarlar etiketleri Türkçe yazar ("1,5", "5.000", "%15"). Önceden
/// her uç kendi ayrıştırıcısını yazıyordu ve Üretim İcmali "1,5"i sessizce varsayılana düşürüyordu;
/// hepsi artık AyarDeposu.OndalikCoz'dan geçer.
/// </summary>
public class AyarOndalikTestleri
{
    [Theory]
    [InlineData("15", 15)]
    [InlineData("%15", 15)]
    [InlineData(" 12,5 ", 12.5)]
    [InlineData("12.5", 12.5)]
    [InlineData("1,5", 1.5)]
    [InlineData("5.000", 5000)]
    [InlineData("1.250.000", 1250000)]
    [InlineData("5.000,50", 5000.5)]
    [InlineData("5,000.50", 5000.5)]
    [InlineData("30", 30)]
    public void TurkceVeInvariantYazimCozulur(string metin, double beklenen)
        => Assert.Equal((decimal)beklenen, AyarDeposu.OndalikCoz(metin));

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("  ")]
    [InlineData("abc")]
    [InlineData("1,2,3")]
    public void BosYaDaBozukDegerNull(string? metin)
        => Assert.Null(AyarDeposu.OndalikCoz(metin));
}
