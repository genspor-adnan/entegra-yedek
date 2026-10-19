using Gentegre.Api.Servisler;
using Xunit;

namespace Gentegre.Testler;

/// <summary>MERNİS / KPS (19.10.2026): T.C. kimlik no algoritması ve benzetim kişisi.</summary>
public class MernisTestleri
{
    [Theory]
    [InlineData("10000000146", true)]
    [InlineData("11111111110", true)]
    [InlineData("10000000147", false)]   // 11. hane yanlış
    [InlineData("10000000156", false)]   // 10. hane yanlış
    [InlineData("01234567890", false)]   // ilk hane 0
    [InlineData("1000000014", false)]    // 10 hane
    [InlineData("1000000014a", false)]
    [InlineData("", false)]
    [InlineData(null, false)]
    public void TcAlgoritmasi(string? tc, bool beklenen) => Assert.Equal(beklenen, MernisServisi.TcGecerli(tc));

    [Fact]
    public void Benzetim_ayni_kimlige_ayni_kisi_ve_isaretli()
    {
        var a = MernisServisi.Simulasyon("10000000146");
        var b = MernisServisi.Simulasyon("10000000146");
        Assert.Equal(a, b);
        Assert.True(a.Simulasyon);
        Assert.False(string.IsNullOrWhiteSpace(a.Ad));
        Assert.Contains(a.Cinsiyet, new[] { "E", "K" });
        Assert.NotNull(a.DogumTarihi);
    }
}
