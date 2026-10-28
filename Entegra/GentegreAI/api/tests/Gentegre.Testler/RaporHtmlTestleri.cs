using Gentegre.Api.Servisler;

namespace Gentegre.Testler;

/// <summary>
/// BİÇİMLİ RAPOR METNİ (1195): çıktı DB'deki HTML'i olduğu gibi bastığı için beyaz liste burada sınanır -
/// biçim (font / punto / renk / hizalama) kalır, script / olay özniteliği / url / bağlantı düşer.
/// </summary>
public class RaporHtmlTestleri
{
    [Fact]
    public void Bicim_etiketleri_ve_izinli_stiller_kalir()
    {
        var h = RaporHtml.Temizle(
            "<p style=\"text-align: center\"><span style=\"font-size: 14pt; color: #c00000; font-family: Arial\">"
            + "<b>BULGULAR</b></span></p><font color=\"red\" size=\"5\" face=\"Times New Roman\">Ç ş</font><br>");
        Assert.Equal(
            "<p style=\"text-align: center\"><span style=\"font-size: 14pt; color: #c00000; font-family: Arial\">"
            + "<b>BULGULAR</b></span></p><font color=\"red\" size=\"5\" face=\"Times New Roman\">Ç ş</font><br>", h);
    }

    [Fact]
    public void Script_olay_url_ve_baglanti_duser()
    {
        var h = RaporHtml.Temizle(
            "<script>alert(1)</script><span onclick=\"x()\" style=\"background-image: url(http://x); color: blue\">a</span>"
            + "<a href=\"javascript:x\">b</a><img src=x onerror=y><div style=\"width: expression(1)\">c</div>");
        Assert.Equal("<span style=\"color: blue\">a</span>b<div>c</div>", h);
    }

    [Fact]
    public void Metin_kodlanir_ve_duz_hali_satirli()
    {
        Assert.Equal("a &lt; b &amp; c", RaporHtml.Temizle("a < b & c"));
        Assert.Equal("BULGULAR\nsatır 1\nsatır 2", RaporHtml.DuzMetin("<div><b>BULGULAR</b></div><div>satır 1<br>satır 2</div>"));
    }
}
