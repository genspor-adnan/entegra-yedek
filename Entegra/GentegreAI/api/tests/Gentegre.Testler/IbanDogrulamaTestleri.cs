using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// CARİ BANKA / IBAN (1153) — ISO 13616 mod-97 doğrulaması. Web'deki ibanGecerliMi ile AYNI
/// örnekler (web/src/test/iban.test.ts): iki taraf ayrışırsa ekran kabul edip sunucu reddeder.
/// </summary>
public sealed class IbanDogrulamaTestleri
{
    [Theory]
    [InlineData("TR330006100519786457841326")]
    [InlineData("TR33 0006 1005 1978 6457 8413 26")]
    [InlineData("DE89370400440532013000")]
    [InlineData("")]
    [InlineData(null)]
    public void Gecerli_iban_kabul_edilir(string? iban) => Assert.True(KimlikDogrulama.IbanGecerli(iban));

    [Theory]
    [InlineData("TR330006100519786457841327")]   // kontrol hanesi tutmuyor
    [InlineData("TR33000610051978645784132")]    // TR 25 karakter
    [InlineData("1234")]
    [InlineData("TR33-0006-1005")]
    public void Bozuk_iban_reddedilir(string iban) => Assert.False(KimlikDogrulama.IbanGecerli(iban));

    [Fact]
    public void Hata_metni_yalniz_gecersizde()
    {
        Assert.Null(KimlikDogrulama.IbanHata("TR330006100519786457841326"));
        Assert.Contains("IBAN geçersiz", KimlikDogrulama.IbanHata("TR000006100519786457841326"));
    }
}
