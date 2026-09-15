using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DÖKÜM PARAMETRELERİ (686): tanımdaki koşul ağacına çalıştırma değerlerini
/// yazar; tarih KURALINI ("gecenAy") somut aralığa çevirir; kıyas dönemi için
/// aralığı kaydırır.
///
/// Ağaç KOPYALANIR - tanım nesnesi değişmez (aynı tanım aynı istekte önce
/// asıl, sonra kıyas dönemi için iki kez çözülür).
/// </summary>
public static class ParametreCozucu
{
    public static readonly IReadOnlyList<string> Kurallar =
        ["bugun", "dun", "buHafta", "gecenHafta", "buAy", "gecenAy", "buCeyrek", "buYil", "son7", "son30"];

    /// <summary>Kuralı [başlangıç, bitiş] gün çiftine çevirir (bitiş dahil).</summary>
    public static (DateTime Bas, DateTime Bit)? KuralAraligi(string kural, DateTime bugun)
    {
        var g = bugun.Date;
        switch (kural)
        {
            case "bugun":      return (g, g);
            case "dun":        return (g.AddDays(-1), g.AddDays(-1));
            case "buHafta":
            {
                var pzt = g.AddDays(-(((int)g.DayOfWeek + 6) % 7));
                return (pzt, pzt.AddDays(6));
            }
            case "gecenHafta":
            {
                var pzt = g.AddDays(-(((int)g.DayOfWeek + 6) % 7)).AddDays(-7);
                return (pzt, pzt.AddDays(6));
            }
            case "buAy":       return (new DateTime(g.Year, g.Month, 1), new DateTime(g.Year, g.Month, 1).AddMonths(1).AddDays(-1));
            case "gecenAy":
            {
                var bas = new DateTime(g.Year, g.Month, 1).AddMonths(-1);
                return (bas, bas.AddMonths(1).AddDays(-1));
            }
            case "buCeyrek":
            {
                var ay = ((g.Month - 1) / 3) * 3 + 1;
                var bas = new DateTime(g.Year, ay, 1);
                return (bas, bas.AddMonths(3).AddDays(-1));
            }
            case "buYil":      return (new DateTime(g.Year, 1, 1), new DateTime(g.Year, 12, 31));
            case "son7":       return (g.AddDays(-6), g);
            case "son30":      return (g.AddDays(-29), g);
            default:           return null;
        }
    }

    private static string Gun(DateTime d) => d.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    /// <summary>
    /// Ağacı kopyalar; `parametreler` içinde alanı geçen yaprağın değerini
    /// değiştirir. Tanımda kuralı olan ama isteğe değer gelmeyen alan kuraldan
    /// çözülür. Diğer yapraklar aynen kalır.
    /// </summary>
    public static Kosul? Uygula(Kosul? filtre, DokumTanimi tanim,
                                IReadOnlyDictionary<string, object?>? parametreler, DateTime bugun)
    {
        if (filtre is null) return null;
        return Kopyala(filtre, alan =>
        {
            if (parametreler is not null && parametreler.TryGetValue(alan, out var v) && DegerDolu(v))
                return (true, v);
            if (tanim.Parametreler is not null && tanim.Parametreler.TryGetValue(alan, out var p)
                && p.Kural.Length > 0 && KuralAraligi(p.Kural, bugun) is { } ar)
                return (true, new List<object?> { Gun(ar.Bas), Gun(ar.Bit) });
            return (false, null);
        });
    }

    private static bool DegerDolu(object? v) => v switch
    {
        null => false,
        JsonElement je => je.ValueKind is not (JsonValueKind.Null or JsonValueKind.Undefined)
                          && !(je.ValueKind == JsonValueKind.Array && je.GetArrayLength() == 0)
                          && !(je.ValueKind == JsonValueKind.String && string.IsNullOrWhiteSpace(je.GetString())),
        string s => !string.IsNullOrWhiteSpace(s),
        System.Collections.ICollection c => c.Count > 0,
        _ => true,
    };

    private static Kosul Kopyala(Kosul k, Func<string, (bool, object?)> degistir)
    {
        if (k.DalMi)
            return new Kosul { Op = k.Op, Kosullar = k.Kosullar!.Select(x => Kopyala(x, degistir)).ToList() };
        var (var_, deger) = string.IsNullOrEmpty(k.Alan) ? (false, null) : degistir(k.Alan!);
        return new Kosul { Alan = k.Alan, Op = k.Op, Deger = var_ ? deger : k.Deger };
    }

    /// <summary>
    /// KIYAS DÖNEMİ: ağaçtaki ilk `arasinda` tarih yaprağını bulur, aralığı
    /// kaydırılmış bir kopya döner. Tarih yaprağı yoksa null - kıyas
    /// anlamsız, istemciye sessizce boş döner.
    /// </summary>
    public static (Kosul Filtre, string Aralik)? Kiyas(Kosul? filtre, KaynakTanimi kaynak, string kiyas)
    {
        if (filtre is null || kiyas is not ("oncekiDonem" or "oncekiYil")) return null;
        var yaprak = TarihYapragi(filtre, kaynak);
        if (yaprak is null) return null;
        var liste = Degerler(yaprak.Deger);
        if (liste.Count != 2) return null;
        if (!DateTime.TryParse(liste[0], CultureInfo.InvariantCulture, DateTimeStyles.None, out var bas)
            || !DateTime.TryParse(liste[1], CultureInfo.InvariantCulture, DateTimeStyles.None, out var bit))
            return null;

        DateTime yeniBas, yeniBit;
        if (kiyas == "oncekiYil") { yeniBas = bas.AddYears(-1); yeniBit = bit.AddYears(-1); }
        else
        {
            var uzunluk = (bit.Date - bas.Date).Days + 1;
            yeniBit = bas.Date.AddDays(-1); yeniBas = yeniBit.AddDays(-(uzunluk - 1));
        }
        var yeni = new List<object?> { Gun(yeniBas), Gun(yeniBit) };
        var kopya = Kopyala(filtre, alan => alan == yaprak.Alan ? (true, yeni) : (false, null));
        return (kopya, $"{yeniBas:dd.MM.yyyy} – {yeniBit:dd.MM.yyyy}");
    }

    private static Kosul? TarihYapragi(Kosul k, KaynakTanimi kaynak)
    {
        if (k.DalMi)
            return k.Kosullar!.Select(x => TarihYapragi(x, kaynak)).FirstOrDefault(x => x is not null);
        if (k.Op != KosulOperatoru.Arasinda || string.IsNullOrEmpty(k.Alan)) return null;
        return kaynak.Kolon(k.Alan!)?.Tip == "tarih" ? k : null;
    }

    private static List<string> Degerler(object? d)
    {
        var s = new List<string>();
        if (d is JsonElement je && je.ValueKind == JsonValueKind.Array)
            foreach (var e in je.EnumerateArray()) s.Add(e.ToString());
        else if (d is System.Collections.IEnumerable dizi and not string)
            foreach (var e in dizi) s.Add(e?.ToString() ?? "");
        else if (d is not null) s.Add(d.ToString() ?? "");
        return s;
    }
}
