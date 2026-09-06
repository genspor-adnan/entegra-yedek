using Gentegre.Cekirdek.Its;

namespace Gentegre.Testler;

/// <summary>
/// İLAÇ KAREKODU ÇÖZÜMLEME (İTS v1).
///
/// Bu kuralların hepsi sahada okuyucudan okuyucuya değişiyor ve yanlış
/// çözümlenen bir karekod İTS tarafından REDDEDİLİR — hata bildirimi
/// gönderildikten sonra, kutu hastaya verilmişken geri gelir. Bu yüzden
/// çözümleme saf bir fonksiyon ve testli.
/// </summary>
public class KarekodTestleri
{
    private const char GS = (char)0x1D;

    [Fact]
    public void Ayiricili_kod_dort_alani_da_cozer()
    {
        var k = KarekodCozumleme.Coz($"0108699591090266{GS}21ABC123{GS}17271231{GS}10LOT7");

        Assert.True(k.Gecerli);
        Assert.Equal("08699591090266", k.Gtin);
        Assert.Equal("ABC123", k.SeriNo);
        Assert.Equal("LOT7", k.PartiNo);
        Assert.Equal(new DateOnly(2027, 12, 31), k.SonKullanma);
    }

    [Fact]
    public void AYIRICISIZ_kodda_seri_SKT_ile_BIRLESMEZ()
    {
        // Bazı okuyucular FNC1 göndermiyor. Sınırı bir sonraki AI'dan bulmayan
        //   çözümleyici seriyi "ABC12317271231..." diye okur ve bildirim reddedilir.
        var k = KarekodCozumleme.Coz("010869959109026621ABC12317271231");

        Assert.True(k.Gecerli);
        Assert.Equal("ABC123", k.SeriNo);
        Assert.Equal(new DateOnly(2027, 12, 31), k.SonKullanma);
    }

    [Fact]
    public void Parantezli_gosterim_de_okunur()
    {
        var k = KarekodCozumleme.Coz("(01)08699591090266(21)SER-9(17)280630(10)L-22");

        Assert.True(k.Gecerli);
        Assert.Equal("SER-9", k.SeriNo);
        Assert.Equal("L-22", k.PartiNo);
        Assert.Equal(new DateOnly(2028, 6, 30), k.SonKullanma);
    }

    [Fact]
    public void Alan_SIRASI_degisebilir()
    {
        // Üretici (01)(17)(10)(21) da yazabilir - sıraya değil AI'ya bakılır.
        var k = KarekodCozumleme.Coz($"010869959109026617261130{GS}10PARTI1{GS}21S-77");

        Assert.True(k.Gecerli);
        Assert.Equal("S-77", k.SeriNo);
        Assert.Equal("PARTI1", k.PartiNo);
    }

    [Fact]
    public void Gun_00_ayin_SON_gunudur()
    {
        // GS1: gün 00 = "ay sonu". 1'ine çevirmek ilacı 27 gün erken
        //   miadı dolmuş gösterirdi.
        var k = KarekodCozumleme.Coz($"0108699591090266{GS}1726 0200".Replace(" ", ""));

        Assert.True(k.Gecerli);
        Assert.Equal(new DateOnly(2026, 2, 28), k.SonKullanma);
    }

    [Theory]
    [InlineData("", "Karekod boş.")]
    [InlineData("2100ABC", "GTIN")]                       // GTIN yok
    [InlineData("010869959109026617991331", "Son kullanma")]  // ay 99
    public void Gecersiz_kod_SEBEBIYLE_reddedilir(string kod, string sebepParcasi)
    {
        var k = KarekodCozumleme.Coz(kod);

        Assert.False(k.Gecerli);
        Assert.Contains(sebepParcasi, k.Hata);
    }

    [Fact]
    public void Gtin_barkoda_cevrilir()
    {
        // İTS GTIN'i 14 hane, ilaç kataloğu EAN-13: baştaki sıfır atılır,
        //   yoksa katalogla eşleşme hiç tutmaz.
        Assert.Equal("8699591090266", KarekodCozumleme.GtinBarkod("08699591090266"));
        Assert.Equal("18699591090266", KarekodCozumleme.GtinBarkod("18699591090266"));
    }
}
