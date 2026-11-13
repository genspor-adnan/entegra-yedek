using System.Text.RegularExpressions;

namespace Gentegre.Api.Servisler.EFatura;

/// <summary>
/// XSLT 2.0 ŞABLONLARINI .NET'İN 1.0 DÖNÜŞTÜRÜCÜSÜNE UYDURMA (kullanıcı 13.11.2026, MEDX: "efatura xslt ekledim ama
/// düzgün göstermedi").
///
/// Entegratörlerin dağıttığı GİB şablonları <c>version="2.0"</c> taşır; <see cref="System.Xml.Xsl.XslCompiledTransform"/>
/// bunları ileri-uyumlu kipte YÜKLER ama XPath 2.0'a özgü bir ifadeye dönüşüm anında takılır (MEDX şablonunda
/// <c>@schemeID=('VKN', 'TCKN')</c> dizi karşılaştırması: "')' bekleniyordu, ',' bulundu"). Hata yutulup sade tabloya
/// düşülüyordu; kullanıcı şablonun neden uygulanmadığını göremiyordu.
///
/// Burada yalnız sahada görülen ve 1.0'da birebir karşılığı olan kalıplar çevrilir; şablonun GİB'e giden aslı
/// (UBL içine gömülen kopya) DEĞİŞTİRİLMEZ - alıcı taraf 2.0 işleyebilir. Çevrilemeyen bir kalıp kalırsa dönüşüm
/// yine hata verir; o zaman görünüm sade tabloya düşer ve uyarı sebebi gösterir (EFaturaServisi.HtmlAsync).
/// </summary>
public static partial class XsltUyum
{
    // yol = ('a', 'b', ...)  →  (yol = 'a' or yol = 'b' ...)
    //   yol: ad/eksen/öznitelik karakterleri (cbc:ID/@schemeID, @x, ../cbc:Y); köşeli ayraçlı yol bilerek dışarıda.
    //   Tırnak: XML özniteliği içinde ' ya da &apos; (şablon "..." ile sınırlanır).
    [GeneratedRegex(@"(?<yol>[\w:.@/\-]+)\s*=\s*\(\s*(?<ilk>'[^']*'|&apos;[^&]*&apos;)(?<kalan>(?:\s*,\s*(?:'[^']*'|&apos;[^&]*&apos;))+)\s*\)")]
    private static partial Regex DiziKarsilastirma();

    [GeneratedRegex(@"'[^']*'|&apos;[^&]*&apos;")]
    private static partial Regex Dizgi();

    /// <summary>Şablon metnini .NET XSLT 1.0 işleyicisinin çalıştırabileceği biçime çevirir; değişiklik yoksa aynı metin döner.</summary>
    public static string Xslt10Uyumlu(string xslt)
    {
        if (string.IsNullOrEmpty(xslt) || !xslt.Contains("=(") && !xslt.Contains("= (")) return xslt;
        return DiziKarsilastirma().Replace(xslt, e =>
        {
            var yol = e.Groups["yol"].Value;
            var degerler = Dizgi().Matches(e.Groups["ilk"].Value + e.Groups["kalan"].Value).Select(m => m.Value);
            return "(" + string.Join(" or ", degerler.Select(d => yol + "=" + d)) + ")";
        });
    }
}
