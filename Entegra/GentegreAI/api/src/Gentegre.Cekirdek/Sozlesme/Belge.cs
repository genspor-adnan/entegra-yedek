using System.Text.Json;

namespace Gentegre.Cekirdek.Sozlesme;

/// <summary>API §4 - belge kaydetme istegi.</summary>
public sealed class BelgeYazmaIstegi
{
    public string? Surum { get; set; }
    public Dictionary<string, JsonElement>? Belge { get; set; }
    public List<Dictionary<string, JsonElement>>? Satirlar { get; set; }
    public BelgeSecenekleri Secenekler { get; set; } = new();
}

public sealed class BelgeSecenekleri
{
    /// <summary>Taslakta belge NUMARASI TUKETILMEZ - numara yalnizca kesinlestirmede alinir.</summary>
    public bool Taslak { get; set; }
    public bool StokKontrolu { get; set; } = true;
}

public sealed class BelgeYaniti
{
    public IDictionary<string, object?> Belge { get; set; } = new Dictionary<string, object?>();
    public IReadOnlyList<IDictionary<string, object?>> Satirlar { get; set; }
        = Array.Empty<IDictionary<string, object?>>();
    public IReadOnlyList<DipToplamSatiri> DipToplam { get; set; } = Array.Empty<DipToplamSatiri>();
    public IReadOnlyList<string> Uyarilar { get; set; } = Array.Empty<string>();
    public string IzlemeNo { get; set; } = "";
}

/// <summary>
/// Dip toplam satiri (fn_belge_diptoplam). tur: 1 Toplam, 2 OTV, 3 Iskonto,
/// 4 Ara Toplam, 5 KDV, 6 Beyan, 7 Tevkifat, 8 Ek Vergi, 9 Stopaj,
/// 15 KDV Toplam, 20 Genel Toplam.
/// </summary>
public sealed record DipToplamSatiri(
    int Tur,
    string Aciklama,
    decimal Deger,
    decimal DovizTutari,
    string Kur,
    string BelgeDovizi);

public static class DipToplamTuru
{
    public const int Toplam      = 1;
    public const int Otv         = 2;
    public const int Iskonto     = 3;
    public const int AraToplam   = 4;
    public const int Kdv         = 5;
    public const int Beyan       = 6;
    public const int Tevkifat    = 7;
    public const int EkVergi     = 8;
    public const int Stopaj      = 9;
    public const int KdvToplam   = 15;
    public const int GenelToplam = 20;
}
