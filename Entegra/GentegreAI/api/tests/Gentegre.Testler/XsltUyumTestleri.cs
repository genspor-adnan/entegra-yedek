using System.Text;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;
using Gentegre.Api.Servisler.EFatura;
using Xunit;

namespace Gentegre.Testler;

/// <summary>
/// XSLT 2.0 → 1.0 UYUM KATMANI (13.11.2026, MEDX "efatura xslt ekledim ama düzgün göstermedi"): entegratör
/// şablonundaki <c>@schemeID=('VKN', 'TCKN')</c> dizi karşılaştırması .NET XslCompiledTransform'da dönüşüm anında
/// patlıyor ve görünüm sessizce sade tabloya düşüyordu. Veritabanı gerekmez.
/// </summary>
public class XsltUyumTestleri
{
    private const string MedxIfadesi =
        "n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeID=('VKN', 'TCKN')][1]/cbc:ID";

    [Fact]
    public void Dizi_karsilastirmasi_or_zincirine_cevrilir_ve_xpath10_derlenir()
    {
        var sonuc = XsltUyum.Xslt10Uyumlu($"<xsl:variable name=\"vkn\" select=\"{MedxIfadesi}\"/>");
        Assert.Contains("[(cbc:ID/@schemeID='VKN' or cbc:ID/@schemeID='TCKN')][1]", sonuc);
        Assert.DoesNotContain("=(", sonuc);
        // Çevrilen ifade XPath 1.0 derleyicisinden geçer (önceden: "')' bekleniyordu, ',' bulundu").
        var ifade = sonuc[(sonuc.IndexOf("select=\"", StringComparison.Ordinal) + 8)..sonuc.LastIndexOf('"')];
        XPathExpression.Compile(ifade);
    }

    [Fact]
    public void Apos_kacisli_ve_uc_elemanli_dizi_de_cevrilir()
    {
        var s = XsltUyum.Xslt10Uyumlu("test=\"@x = (&apos;A&apos;, &apos;B&apos;,&apos;C&apos;)\"");
        Assert.Equal("test=\"(@x=&apos;A&apos; or @x=&apos;B&apos; or @x=&apos;C&apos;)\"", s);
    }

    [Fact]
    public void Kalip_yoksa_metin_aynen_doner()
    {
        const string x = "<xsl:value-of select=\"format-number(cbc:Amount, '#.##0,00', 'tr')\"/>";
        Assert.Same(x, XsltUyum.Xslt10Uyumlu(x));
        // Tek elemanlı parantez ('a') dizi değil, dokunulmaz.
        const string y = "test=\"@x = ('A')\"";
        Assert.Equal(y, XsltUyum.Xslt10Uyumlu(y));
    }

    [Fact]
    public void Ucdan_uca_version20_sablonu_net_donusturucude_calisir()
    {
        const string sablon = """
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:n1="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
                xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
                xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
              <xsl:output method="html"/>
              <xsl:template match="/">
                <xsl:variable name="vkn" select="n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeID=('VKN', 'TCKN')][1]/cbc:ID"/>
                <b><xsl:value-of select="$vkn"/></b>
              </xsl:template>
            </xsl:stylesheet>
            """;
        const string ubl = """
            <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
                xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
                xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
              <cac:AccountingSupplierParty><cac:Party>
                <cac:PartyIdentification><cbc:ID schemeID="MERSISNO">0123</cbc:ID></cac:PartyIdentification>
                <cac:PartyIdentification><cbc:ID schemeID="VKN">4840847211</cbc:ID></cac:PartyIdentification>
              </cac:Party></cac:AccountingSupplierParty>
            </Invoice>
            """;
        var ayar = new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit };
        var donusum = new XslCompiledTransform();
        using (var xr = XmlReader.Create(new StringReader(XsltUyum.Xslt10Uyumlu(sablon)), ayar))
            donusum.Load(xr, new XsltSettings(enableDocumentFunction: false, enableScript: false), null);
        using var ur = XmlReader.Create(new StringReader(ubl), ayar);
        var sb = new StringBuilder();
        using (var w = XmlWriter.Create(sb, donusum.OutputSettings)) donusum.Transform(ur, w);
        // Literal sonuç elemanı şablonun ad-alanı bildirimlerini taşır (<b xmlns:n1=...>); içeriğe bakılır.
        Assert.Contains(">4840847211</b>", sb.ToString());

        // Çevrilmemiş hâli gerçekten patlıyor - uyum katmanı boşuna değil.
        var ham = new XslCompiledTransform();
        using (var xr = XmlReader.Create(new StringReader(sablon), ayar))
            ham.Load(xr, new XsltSettings(enableDocumentFunction: false, enableScript: false), null);
        using var ur2 = XmlReader.Create(new StringReader(ubl), ayar);
        Assert.ThrowsAny<XsltException>(() => { using var w = XmlWriter.Create(new StringBuilder()); ham.Transform(ur2, w); });
    }
}
