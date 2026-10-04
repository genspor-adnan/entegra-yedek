using Gentegre.Api.Uclar;
using Xunit;

namespace Gentegre.Testler;

/// <summary>
/// DUYURU METNİ herkesin ekranında HTML olarak çizilir (957) - temizleyici
/// betiği, olay özniteliğini ve tehlikeli bağlantıyı düşürmeli, biçimi korumalı.
/// </summary>
public class DuyuruHtmlTestleri
{
    [Fact]
    public void Bicim_etiketleri_kalir()
        => Assert.Equal("<p>Merhaba <b>dünya</b><br><i>x</i></p>",
                        DuyuruUclari.HtmlTemizle("<p>Merhaba <b>dünya</b><br/><i>x</i></p>"));

    [Fact]
    public void Script_ve_style_icerigiyle_duser()
        => Assert.Equal("ab", DuyuruUclari.HtmlTemizle("a<script>alert(1)</script><style>p{}</style>b"));

    [Fact]
    public void Olay_oznitelikleri_duser()
        => Assert.Equal("<b>x</b>", DuyuruUclari.HtmlTemizle("<b onclick=\"alert(1)\" style=\"x\">x</b>"));

    [Fact]
    public void Izinsiz_etiket_duser_metni_kalir()
        => Assert.Equal("x", DuyuruUclari.HtmlTemizle("<img src=x onerror=alert(1)><iframe src=y></iframe>x"));

    [Fact]
    public void Javascript_baglantisi_hrefsiz_kalir()
        => Assert.Equal("<a>t</a>", DuyuruUclari.HtmlTemizle("<a href=\"javascript:alert(1)\">t</a>"));

    [Fact]
    public void Https_baglantisi_yeni_sekmede()
        => Assert.Equal("<a href=\"https://ornek.com/a?b=1&amp;c=2\" target=\"_blank\" rel=\"noopener noreferrer\">t</a>",
                        DuyuruUclari.HtmlTemizle("<a href='https://ornek.com/a?b=1&amp;c=2' onmouseover=x>t</a>"));

    [Fact]
    public void Kacak_aci_parantez_kodlanir()
        => Assert.Equal("1 &lt; 2 &amp; 3", DuyuruUclari.HtmlTemizle("1 < 2 & 3"));

    [Fact]
    public void Duz_metin_satir_sonlu()
        => Assert.Equal("a\nb", DuyuruUclari.DuzMetin("<p>a</p><p>b</p>"));
}
