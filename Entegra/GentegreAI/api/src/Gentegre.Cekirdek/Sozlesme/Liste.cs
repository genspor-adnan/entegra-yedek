namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>API sozlesmesi §2 - liste istegi.</summary>
public sealed class ListeIstegi
{
    public int Sayfa { get; set; } = 1;
    public int Boyut { get; set; } = 100;
    public List<Siralama>? Sirala { get; set; }
    public Kosul? Filtre { get; set; }
    public List<string>? Grup { get; set; }
    public List<string>? Toplam { get; set; }
    public string? Gorunum { get; set; }

    /// <summary>Sozlesme geregi ust sinir 500.</summary>
    public const int EnBuyukBoyut = 500;
}

public sealed class Siralama
{
    public string Alan { get; set; } = "";
    public string Yon { get; set; } = "asc";     // asc | desc
}

/// <summary>
/// Tekil kosul ya da dal. Dal ise Op = "and" | "or" ve Kosullar dolu;
/// yaprak ise Alan + Op + Deger dolu.
/// </summary>
public sealed class Kosul
{
    public string? Alan { get; set; }
    public string Op { get; set; } = "and";
    public object? Deger { get; set; }
    public List<Kosul>? Kosullar { get; set; }

    public bool DalMi => Kosullar is { Count: > 0 };
}

public static class KosulOperatoru
{
    public const string Esit       = "esit";
    public const string EsitDegil  = "esitDegil";
    public const string Icerir     = "icerir";
    public const string Baslar     = "baslar";
    public const string Biter      = "biter";
    public const string Buyuk      = "buyuk";
    public const string BuyukEsit  = "buyukEsit";
    public const string Kucuk      = "kucuk";
    public const string KucukEsit  = "kucukEsit";
    public const string Arasinda   = "arasinda";
    public const string Bos        = "bos";
    public const string BosDegil   = "bosDegil";
    public const string Icinde     = "icinde";

    private static readonly HashSet<string> Gecerli = new(StringComparer.Ordinal)
    {
        Esit, EsitDegil, Icerir, Baslar, Biter, Buyuk, BuyukEsit,
        Kucuk, KucukEsit, Arasinda, Bos, BosDegil, Icinde
    };

    public static bool Gecerlidir(string op) => Gecerli.Contains(op);
}

public sealed class ListeYaniti
{
    public IReadOnlyList<IDictionary<string, object?>> Satirlar { get; set; }
        = Array.Empty<IDictionary<string, object?>>();
    public long ToplamKayit { get; set; }
    public IDictionary<string, object?>? Toplamlar { get; set; }
    public IReadOnlyList<GrupOzeti>? Gruplar { get; set; }
    public long SureMs { get; set; }
    public string IzlemeNo { get; set; } = "";
}

public sealed record GrupOzeti(string Anahtar, string Ad, long Adet);

/// <summary>§2.4 kolon meta ucu. Yetkisiz kolon bu listede de DONMEZ.</summary>
public sealed record KolonMeta(
    string Ad,
    string Baslik,
    string Tip,
    string Hizalama,
    string? Bicim,
    bool Varsayilan,
    bool Siralanabilir,
    bool Filtrelenebilir,
    int? Genislik = null);
