using Gentegre.Cekirdek;

namespace Gentegre.Testler;

/// <summary>
/// METİN KISALTMA (refaktör 20.11.2026, A4): ~30 dosyadaki özel `Kirp` / `Kisalt` kopyası tek sınıfa taşındı. Üç
/// davranış kopyalarda neyse o: yalnız kes · önce kırp sonra kes · kes ve "…" koy. Üçü de null için "" döner.
/// </summary>
public sealed class MetinAraciTestleri
{
    [Theory]
    [InlineData(null, 5, "")]
    [InlineData("", 5, "")]
    [InlineData("abc", 5, "abc")]
    [InlineData("abcde", 5, "abcde")]
    [InlineData("abcdef", 5, "abcde")]
    [InlineData("  ab  ", 4, "  ab")]            // boşluk kırpılmaz
    public void Kes_oldugu_gibi_keser(string? girdi, int azami, string beklenen)
        => Assert.Equal(beklenen, MetinAraci.Kes(girdi, azami));

    [Theory]
    [InlineData(null, 5, "")]
    [InlineData("   ", 5, "")]
    [InlineData("  ab  ", 4, "ab")]
    [InlineData("  abcdef  ", 4, "abcd")]
    public void KirpKes_once_kirpar(string? girdi, int azami, string beklenen)
        => Assert.Equal(beklenen, MetinAraci.KirpKes(girdi, azami));

    [Theory]
    [InlineData(null, 5, "")]
    [InlineData("abcde", 5, "abcde")]
    [InlineData("abcdef", 5, "abcde…")]         // sonuç sınırdan bir karakter uzun: kolon sınırı için değil
    public void KesUc_kesildiyse_uc_nokta(string? girdi, int azami, string beklenen)
        => Assert.Equal(beklenen, MetinAraci.KesUc(girdi, azami));
}
