using System.Text.RegularExpressions;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ÖLÇÜ VE BOYUT BEYAZ LİSTESİ (686).
///
/// Döküm tanımı "fn" adı yazar, SQL'i bu tablo verir; tarih kesmesi de öyle.
/// İstekten SQL parçası GELMEZ - bilinmeyen fn/kesme 400 ile düşer.
/// </summary>
public static class OlcuKatalogu
{
    /// <summary>fn → (şablon, sayı alanı ister mi, başlık eki, biçim). {x} alan SQL'i, {y} bölen.</summary>
    public sealed record OlcuTanimi(string Sablon, bool SayiIster, bool AlanIster, string BaslikEki, string Bicim);

    private static readonly Dictionary<string, OlcuTanimi> Fnler = new(StringComparer.Ordinal)
    {
        // BaslikEki bir KALIP: {b} alan başlığı, {y} bölen başlığı.
        ["adet"]     = new("count(*)",                                   false, false, "Adet",        "#,##0"),
        ["tekil"]    = new("count(distinct {x})",                         false, true,  "Tekil {b}",   "#,##0"),
        ["toplam"]   = new("coalesce(sum({x}), 0)",                       true,  true,  "Σ {b}",       "#,##0.00"),
        ["ortalama"] = new("avg({x})",                                    true,  true,  "Ort. {b}",    "#,##0.00"),
        ["min"]      = new("min({x})",                                    true,  true,  "En az {b}",   "#,##0.00"),
        ["max"]      = new("max({x})",                                    true,  true,  "En çok {b}",  "#,##0.00"),
        ["medyan"]   = new("percentile_cont(0.5) within group (order by {x})", true, true, "Medyan {b}", "#,##0.00"),
        ["p90"]      = new("percentile_cont(0.9) within group (order by {x})", true, true, "P90 {b}",   "#,##0.00"),
        // Oran: pay/payda toplamı - satır satır oranların ortalaması DEĞİL
        //   (tahsilat ÷ ciro böyle anlamlı).
        ["oran"]     = new("case when coalesce(sum({y}), 0) = 0 then null else sum({x}) / sum({y}) end",
                                                                          true,  true,  "{b} / {y}",   "%"),
    };

    public static OlcuTanimi? Fn(string ad) => Fnler.TryGetValue(ad ?? "", out var t) ? t : null;
    public static IReadOnlyCollection<string> FnAdlari => Fnler.Keys;

    /// <summary>Tarih kesmeleri: "alan:ay" → date_trunc / extract. Anahtar boşsa günün kendisi.</summary>
    private static readonly Dictionary<string, (string Sablon, string Baslik)> Kesmeler = new(StringComparer.Ordinal)
    {
        ["gun"]       = ("date_trunc('day', {x})::date",             "Gün"),
        ["hafta"]     = ("date_trunc('week', {x})::date",            "Hafta"),
        ["ay"]        = ("to_char(date_trunc('month', {x}), 'YYYY-MM')", "Ay"),
        ["ceyrek"]    = ("to_char({x}, 'YYYY') || '-Ç' || to_char({x}, 'Q')", "Çeyrek"),
        ["yil"]       = ("to_char({x}, 'YYYY')",                     "Yıl"),
        ["haftaGunu"] = ("extract(isodow from {x})::int",            "Haftanın Günü"),
        ["saat"]      = ("extract(hour from {x})::int",              "Saat"),
    };

    public static bool KesmeVar(string ad) => Kesmeler.ContainsKey(ad);
    public static IReadOnlyCollection<string> KesmeAdlari => Kesmeler.Keys;

    /// <summary>"belgeTarihi:ay" → ("belgeTarihi", "ay"); kesme yoksa ("belgeTarihi", "").</summary>
    public static (string Alan, string Kesme) BoyutCoz(string boyut)
    {
        var i = boyut.IndexOf(':');
        return i < 0 ? (boyut, "") : (boyut[..i], boyut[(i + 1)..]);
    }

    public static string BoyutSql(KolonTanimi kolon, string kesme)
        => kesme.Length == 0 ? kolon.Sql : Kesmeler[kesme].Sablon.Replace("{x}", kolon.Sql);

    public static string BoyutBasligi(KolonTanimi kolon, string kesme)
        => kesme.Length == 0 ? kolon.Baslik : $"{kolon.Baslik} · {Kesmeler[kesme].Baslik}";

    /// <summary>
    /// GİZLİ BOYUT: kişiyi tek başına tanımlayan alanlar istatistikte boyut
    /// olamaz (hasta adı, kimlik no, telefon…). Katalogda tek tek işaretlemek
    /// yerine ad kalıbıyla - yeni eklenen bir kimlik kolonu unutulmasın.
    /// </summary>
    private static readonly Regex Gizli = new(
        "hasta(adi|unvan|ad)|unvan$|^ad$|kimlik|tckn|vkno|telefon|ceptel|gsm|eposta|adres|dogum",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);

    /// <summary>
    /// Kolon boyut olabilir mi: kod/metin/tarih/mantık, filtrelenebilir, kimlik
    /// kalıbına uymaz. Para ve sayı ölçüdür, boyut değil.
    /// </summary>
    public static bool Gruplanabilir(KolonTanimi k)
        => k.Filtrelenebilir
           && k.Tip is "kod" or "metin" or "tarih" or "mantik"
           && !Gizli.IsMatch(k.Ad);

    /// <summary>Kolon ölçü alanı olabilir mi (sayısal fonksiyonlar için).</summary>
    public static bool Olculebilir(KolonTanimi k)
        => k.Tip == "para"
           || (k.Tip == "sayi" && k.Ad != "id" && !k.Ad.EndsWith("Id", StringComparison.Ordinal));
}
