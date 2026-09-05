namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// İLAÇ LİSTESİ ÇÖZÜMLEME KURALLARI (SGK Ek-4/A · 406/407).
///
/// Yükleyicinin (Api) içinde değil BURADA: kurallar dış bağımlılığı olmayan
/// saf metin çözümlemesi ve ikisi de canlı veride sessizce kırıldı -
/// birim testten görülebilmeleri gerekiyor.
/// </summary>
public static class IlacListeCozumleme
{
    /// <summary>Kademeli iskonto: depocuya satış fiyatı aralığı ve oranı.</summary>
    public sealed record Kademe(decimal? Alt, decimal? Ust, decimal Oran);

    /// <summary>
    /// "0,4" · "0.4" · "%40" → 0,4. Çözülemeyen değer 0.
    ///
    /// ARALIK ile ÜSTEL GÖSTERİM aynı '-' işaretini taşır: Excel iskontoyu
    /// "7.0000000000000007E-2" diye yazabiliyor, eczacı iskontosu ise
    /// "0-2,5%" gibi bir aralık. Önce düz çözüm denenir - üstel biçim böyle
    /// doğru okunur; çözülemezse aralığın ÜST sınırı alınır.
    /// </summary>
    public static decimal Ondalik(string? metin)
    {
        var t = (metin ?? "").Replace("%", "").Replace(',', '.').Trim();
        const System.Globalization.NumberStyles Bicim = System.Globalization.NumberStyles.Any;
        var kultur = System.Globalization.CultureInfo.InvariantCulture;
        if (decimal.TryParse(t, Bicim, kultur, out var d)) return d;
        if (t.Contains('-') && decimal.TryParse(t.Split('-')[^1], Bicim, kultur, out var ust))
            return ust;
        return 0m;
    }

    /// <summary>
    /// Kademeli iskontoları başlıkla birlikte çözer.
    ///
    /// Sınırlar BAŞLIK METNİNDE yazıyor ("151,25 TL ve üzeri ise",
    /// "100,38 TL (dahil) - 151,24 TL (dahil) arasında ise"). Koda gömmek
    /// bir sonraki yayında sessizce yanlış kademe uygulardı; bu yüzden
    /// başlıktaki sayılar okunur: iki sayı = aralık, tek sayı = "üzeri"
    /// ya da "altında" (başlıktaki kelime karar verir).
    /// </summary>
    public static List<Kademe> Kademeler(IReadOnlyDictionary<string, string> satir)
    {
        var liste = new List<Kademe>();
        foreach (var (baslik, deger) in satir)
        {
            if (!baslik.Contains("DEPOCUYA", StringComparison.Ordinal)) continue;
            var oran = Ondalik(deger);
            var sayilar = System.Text.RegularExpressions.Regex
                .Matches(baslik, @"\d+[.,]\d+")
                .Select(m => Ondalik(m.Value)).ToList();

            liste.Add(sayilar.Count >= 2
                ? new Kademe(Math.Min(sayilar[0], sayilar[1]), Math.Max(sayilar[0], sayilar[1]), oran)
                : sayilar.Count == 1
                    ? baslik.Contains("ALTINDA", StringComparison.Ordinal)
                        ? new Kademe(null, sayilar[0], oran)
                        : new Kademe(sayilar[0], null, oran)
                    : new Kademe(null, null, oran));
        }
        return liste;
    }

    /// <summary>Kademeleri jsonb metnine çevirir (ondalık ayırıcı NOKTA).</summary>
    public static string KademeJson(IEnumerable<Kademe> kademeler)
        => "[" + string.Join(",", kademeler.Select(k =>
               $$"""{"alt":{{Sayi(k.Alt)}},"ust":{{Sayi(k.Ust)}},"oran":{{Sayi(k.Oran)}}}""")) + "]";

    private static string Sayi(decimal? d)
        => d is null ? "null" : d.Value.ToString(System.Globalization.CultureInfo.InvariantCulture);
}
