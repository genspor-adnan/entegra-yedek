using System.Text;

namespace Gentegre.Api.Servisler.EFatura;

/// <summary>
/// Tutarı Türkçe yazıyla (Delphi TutarYaziya - {PaymentTotalAsText} notu):
/// 1250.50 TRY -> "BinİkiYüzElliTL ElliKr".
/// </summary>
public static class TutarYazi
{
    private static readonly string[] Birler = ["", "Bir", "İki", "Üç", "Dört", "Beş", "Altı", "Yedi", "Sekiz", "Dokuz"];
    private static readonly string[] Onlar = ["", "On", "Yirmi", "Otuz", "Kırk", "Elli", "Altmış", "Yetmiş", "Seksen", "Doksan"];
    private static readonly string[] Basamak = ["", "Bin", "Milyon", "Milyar", "Trilyon"];

    public static string Yaz(decimal tutar, string para)
    {
        tutar = Math.Round(Math.Abs(tutar), 2, MidpointRounding.AwayFromZero);
        var tam = (long)Math.Truncate(tutar);
        var kurus = (int)((tutar - tam) * 100);
        var (buyuk, kucuk) = para switch
        {
            "USD" => ("Dolar", "Sent"), "EUR" => ("Euro", "Sent"), "GBP" => ("Sterlin", "Peni"),
            "TRY" => ("TL", "Kr"), _ => (para, ""),
        };
        var s = (tam == 0 ? "Sıfır" : Sayi(tam)) + buyuk;
        if (kurus > 0 && kucuk.Length > 0) s += " " + Sayi(kurus) + kucuk;
        return s;
    }

    private static string Sayi(long n)
    {
        var sb = new StringBuilder();
        var parcalar = new List<int>();
        while (n > 0) { parcalar.Add((int)(n % 1000)); n /= 1000; }
        for (var i = parcalar.Count - 1; i >= 0; i--)
        {
            var p = parcalar[i];
            if (p == 0) continue;
            if (!(i == 1 && p == 1)) sb.Append(Yuzluk(p));   // "Bin", "BirBin" değil
            sb.Append(Basamak[i]);
        }
        return sb.ToString();
    }

    private static string Yuzluk(int n)
    {
        var y = n / 100; var o = n / 10 % 10; var b = n % 10;
        return (y == 0 ? "" : (y == 1 ? "" : Birler[y]) + "Yüz") + Onlar[o] + Birler[b];
    }
}
