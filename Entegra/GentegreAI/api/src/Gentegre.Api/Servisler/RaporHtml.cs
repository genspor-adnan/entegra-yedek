using System.Net;
using System.Text;
using System.Text.RegularExpressions;

namespace Gentegre.Api.Servisler;

/// <summary>
/// BİÇİMLİ RAPOR METNİ TEMİZLİĞİ (1195, kullanıcı 27.10.2026: "serbest bölümü formatlı yap.. font punto renk vb").
/// Rapor editörünün HTML'i DB'ye yazılmadan BEYAZ LİSTEYLE temizlenir - çıktı onu olduğu gibi basar.
/// Kalan: biçim etiketleri (b, i, u, s, sub, sup, br, p, div, span, font, ul, ol, li, h1-h3, blockquote) ve
/// yalnız şu stiller: font-family, font-size, color, background-color, font-weight, font-style,
/// text-decoration, text-align (+ font etiketinin color / size / face'i). Script, olay öznitelikleri,
/// url(...), bağlantı, resim ve başka her şey düşer; metin parçaları yeniden kodlanır.
/// </summary>
public static partial class RaporHtml
{
    private static readonly HashSet<string> IzinliEtiket =
        ["b", "strong", "i", "em", "u", "s", "strike", "sub", "sup", "br", "p", "div", "span", "font",
         "ul", "ol", "li", "h1", "h2", "h3", "blockquote"];
    private static readonly HashSet<string> IzinliStil =
        ["font-family", "font-size", "color", "background-color", "font-weight", "font-style", "text-decoration", "text-align"];

    [GeneratedRegex(@"<(script|style|iframe|object|embed|template)\b[\s\S]*?</\1\s*>|<!--[\s\S]*?-->", RegexOptions.IgnoreCase)]
    private static partial Regex TehlikeliBlok();
    [GeneratedRegex(@"<(/?)([a-zA-Z][a-zA-Z0-9]*)([^>]*)>")]
    private static partial Regex Etiket();
    [GeneratedRegex(@"([a-zA-Z-]+)\s*=\s*(""([^""]*)""|'([^']*)'|([^\s>]+))")]
    private static partial Regex Oznitelik();
    /// <summary>Stil değeri: renk, punto, font adı, hizalama - parantezli yalnız rgb()/rgba().</summary>
    [GeneratedRegex(@"^(rgba?\([0-9.,\s%]+\)|[#a-zA-Z0-9 ,.%'""\-]+)$")]
    private static partial Regex StilDegeri();

    public static string Temizle(string? html)
    {
        if (string.IsNullOrWhiteSpace(html)) return "";
        html = TehlikeliBlok().Replace(html, "");
        var sb = new StringBuilder();
        var son = 0;
        foreach (Match m in Etiket().Matches(html))
        {
            sb.Append(Kodla(html[son..m.Index]));
            son = m.Index + m.Length;
            var kapanis = m.Groups[1].Value == "/";
            var ad = m.Groups[2].Value.ToLowerInvariant();
            if (ad == "strike") ad = "s";
            if (!IzinliEtiket.Contains(ad)) continue;
            if (ad == "br") { if (!kapanis) sb.Append("<br>"); continue; }
            if (kapanis) { sb.Append("</").Append(ad).Append('>'); continue; }
            sb.Append('<').Append(ad).Append(Oznitelikler(ad, m.Groups[3].Value)).Append('>');
        }
        sb.Append(Kodla(html[son..]));
        return sb.ToString();
    }

    private static string Oznitelikler(string etiket, string ham)
    {
        var sb = new StringBuilder();
        foreach (Match o in Oznitelik().Matches(ham))
        {
            var ad = o.Groups[1].Value.ToLowerInvariant();
            var deger = WebUtility.HtmlDecode(o.Groups[3].Success && o.Groups[3].Length > 0 ? o.Groups[3].Value
                      : o.Groups[4].Success && o.Groups[4].Length > 0 ? o.Groups[4].Value : o.Groups[5].Value).Trim();
            if (ad == "style")
            {
                var stil = string.Join("; ", deger.Split(';')
                    .Select(p => p.Split(':', 2))
                    .Where(p => p.Length == 2)
                    .Select(p => (Ad: p[0].Trim().ToLowerInvariant(), Deger: p[1].Trim()))
                    .Where(p => IzinliStil.Contains(p.Ad) && p.Deger.Length <= 80 && StilDegeri().IsMatch(p.Deger)
                                && !p.Deger.Contains("expression", StringComparison.OrdinalIgnoreCase))
                    .Select(p => $"{p.Ad}: {p.Deger}"));
                if (stil != "") sb.Append(" style=\"").Append(Kodla(stil)).Append('"');
            }
            else if (etiket == "font" && ad is "color" or "face" && deger.Length <= 60 && StilDegeri().IsMatch(deger))
                sb.Append(' ').Append(ad).Append("=\"").Append(Kodla(deger)).Append('"');
            else if (etiket == "font" && ad == "size" && deger is "1" or "2" or "3" or "4" or "5" or "6" or "7")
                sb.Append(" size=\"").Append(deger).Append('"');
            else if (ad == "align" && etiket is "p" or "div" && deger.ToLowerInvariant() is "left" or "center" or "right" or "justify")
                sb.Append(" align=\"").Append(deger.ToLowerInvariant()).Append('"');
        }
        return sb.ToString();
    }

    /// <summary>Yalnız HTML'e özel karakterler - Türkçe harfler kodlanmaz.</summary>
    private static string Kodla(string metin) => WebUtility.HtmlDecode(metin)
        .Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");

    /// <summary>Biçimli metnin düz hali (istemci göndermediyse): satır sonları korunur.</summary>
    public static string DuzMetin(string html)
    {
        var s = Regex.Replace(html, @"<br\s*/?>|</(p|div|li|h1|h2|h3)>", "\n", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, "<[^>]+>", "");
        return WebUtility.HtmlDecode(s).Trim();
    }
}
