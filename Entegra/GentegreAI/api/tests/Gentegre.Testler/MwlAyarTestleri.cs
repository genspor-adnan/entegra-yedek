using Gentegre.Api.Servisler;
using Xunit;

namespace Gentegre.Testler;

/// <summary>
/// 1329: MWL satırı çözümü (port / AE / ayarlar) ve gelen bağlantının satıra yönlendirilmesi (çağrılan AE ile).
/// Şubeler aynı portu paylaşıp AE adıyla ayrılır; AE'si boş satır "her AE" yedeğidir.
/// </summary>
public class MwlAyarTestleri
{
    [Fact]
    public void Satir_cozulur_varsayilanlar_ve_sinirlar()
    {
        var d = MwlAyar.Coz(7, 3, " gentegre_kdk ", " 11112 ", """{"karakterSeti":"ISO_IR 192","bilinmeyenAe":1,"pencereGun":"2"}""", out var h);
        Assert.Null(h);
        Assert.NotNull(d);
        Assert.Equal((7, 3, 11112, "GENTEGRE_KDK", "ISO_IR 192", true, 2),
                     (d!.Id, d.Sube, d.Port, d.Ae, d.KarakterSeti, d.BilinmeyenAe, d.PencereGun));

        var v = MwlAyar.Coz(1, 0, "X", "104", "", out _)!;
        Assert.Equal(("ISO_IR 148", false, 0), (v.KarakterSeti, v.BilinmeyenAe, v.PencereGun));
        Assert.Equal(30, MwlAyar.Coz(1, 0, "X", "104", """{"pencereGun":99}""", out _)!.PencereGun);
        Assert.NotNull(MwlAyar.Coz(1, 0, "X", "104", "{bozuk", out _));          // bozuk JSON: varsayılanlar
    }

    [Theory]
    [InlineData("", "ABC")]
    [InlineData("0", "ABC")]
    [InlineData("70000", "ABC")]
    [InlineData("11112", "AE_ADI_ON_ALTIDAN_UZUN")]
    public void Gecersiz_satir_hata_verir(string port, string ae)
    {
        Assert.Null(MwlAyar.Coz(1, 0, ae, port, "{}", out var h));
        Assert.False(string.IsNullOrEmpty(h));
    }

    [Fact]
    public void Baglanti_cagrilan_AE_ile_subeye_yonlenir()
    {
        var mrk = new MwlDinleyici(1, 1, 11112, "GENTEGRE_MRK", "ISO_IR 148", false, 0);
        var kdk = new MwlDinleyici(2, 2, 11112, "GENTEGRE_KDK", "ISO_IR 148", false, 0);
        Assert.Same(kdk, MwlAyar.Sec([mrk, kdk], "gentegre_kdk "));
        Assert.Same(mrk, MwlAyar.Sec([mrk, kdk], "GENTEGRE_MRK"));
        Assert.Null(MwlAyar.Sec([mrk, kdk], "BASKA"));                     // tanımsız AE: reddedilir

        var herAe = new MwlDinleyici(3, 0, 11112, "", "ISO_IR 148", false, 0);
        Assert.Same(herAe, MwlAyar.Sec([mrk, herAe], "BASKA"));           // boş AE satırı yedek
        Assert.Same(mrk, MwlAyar.Sec([herAe, mrk], "GENTEGRE_MRK"));      // tam eşleşme önce
    }
}
