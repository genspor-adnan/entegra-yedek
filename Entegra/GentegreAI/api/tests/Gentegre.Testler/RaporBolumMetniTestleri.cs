using Gentegre.Api.Servisler;

namespace Gentegre.Testler;

/// <summary>
/// RAPOR BÖLÜMÜ TEK KAYNAK (kullanıcı 13.11.2026): biçimli metin (HTML) asıldır; doluysa düz metin her zaman ondan
/// türetilir ve istemcinin gönderdiği düz metin yok sayılır - çıktıyla Bakanlık (OBX-5) / e-Nabız aynı metni görür.
/// </summary>
public sealed class RaporBolumMetniTestleri
{
    [Fact]
    public void Html_varsa_duz_metin_ondan_turetilir_istemcininki_yok_sayilir()
    {
        var (html, duz) = RaporHtml.BolumMetni("ESKİ düz metin", "<p><b>Karaciğer</b> normal.</p><p>Dalak normal.</p>");
        Assert.Equal("<p><b>Karaciğer</b> normal.</p><p>Dalak normal.</p>", html);
        Assert.Equal("Karaciğer normal.\nDalak normal.", duz);
    }

    [Fact]
    public void Html_yoksa_ya_da_temizlikten_bos_cikarsa_gelen_duz_metin()
    {
        Assert.Equal(("", "Düz giriş."), RaporHtml.BolumMetni("Düz giriş.", null));
        Assert.Equal(("", "Düz giriş."), RaporHtml.BolumMetni("Düz giriş.", ""));
        Assert.Equal(("", "Düz giriş."), RaporHtml.BolumMetni("Düz giriş.", "<script>x()</script>"));
        Assert.Equal(("", ""), RaporHtml.BolumMetni(null, null));
    }

    [Fact]
    public void Tablo_hucreleri_sekme_satirlar_satir_sonu()
    {
        var (_, duz) = RaporHtml.BolumMetni("", "<table><tbody><tr><td>BPD</td><td>45 mm</td></tr><tr><td>FL</td><td>30 mm</td></tr></tbody></table>");
        Assert.Equal("BPD\t45 mm\nFL\t30 mm", duz);
    }
}
