using System.Globalization;
using System.Text.Json;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// RAPOR TİPOGRAFİSİ (1344, mockup Ekranlar/Radyoloji/radyoloji_rapor_tipografi.html).
///
/// Üç katman, tek çözüm noktası:
///   kurum   → referans 'radyoloji.tipografi' (json; yoksa <see cref="Varsayilan"/>)
///   şablon  → radyoloji_sablon.tipografi_kaynak: 1 kurum · 2 özel (tip_* kolonları, boş alan kurumdan) · 3 özgün
///   rapor   → radyoloji_rapor.tipografi DAMGA (onayda yazılır); varsa her şeyi ezer. Ek rapor ana raporun damgasını
///             devralır (tek belge, tek görünüm).
/// Web tarafı aynı kuralı şablon değişiminde canlı uygular (sayfalar/radyoloji/tipografi.ts); çıktı ve onay buradan.
/// </summary>
public static class RaporTipografisi
{
    public sealed record Tipografi(string Font, decimal Punto, decimal Satir, int Paragraf, string Hiza, int Kenar,
                                   decimal BaslikPunto, string Kaynak);

    public static readonly string[] Fontlar = ["arial", "calibri", "times", "segoe", "trebuchet"];

    /// <summary>Dünya pratiği: Arial 10,5 · 1,3 · 6 pt · iki yana · A4 18 mm · başlık 13 pt.</summary>
    public static readonly Tipografi Varsayilan = new("arial", 10.5m, 1.3m, 6, "iki", 18, 13m, "kurum");

    /// <summary>Bugüne kadarki görünüm (uygulama fontu Trebuchet 13 px ≈ 9,75 pt · 1,65) - eski onaylı raporlar ve "şablonun kendi biçimi".</summary>
    public static readonly Tipografi Ozgun = new("trebuchet", 9.75m, 1.65m, 0, "sol", 14, 12m, "ozgun");

    private static readonly JsonSerializerOptions JsonAyar = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public static string Json(Tipografi t) => JsonSerializer.Serialize(t, JsonAyar);

    /// <summary>JSON'u güvenle okur: bilinmeyen / sınır dışı değer yedeğe düşer (ayar elle bozulsa çıktı çökmez).</summary>
    public static Tipografi Coz(string? json, Tipografi yedek, string? kaynak = null)
    {
        if (string.IsNullOrWhiteSpace(json)) return yedek with { Kaynak = kaynak ?? yedek.Kaynak };
        try
        {
            using var d = JsonDocument.Parse(json);
            var k = d.RootElement;
            string Metin(string ad, string v) => k.TryGetProperty(ad, out var e) && e.ValueKind == JsonValueKind.String ? e.GetString() ?? v : v;
            decimal Sayi(string ad, decimal v) => k.TryGetProperty(ad, out var e) && e.ValueKind == JsonValueKind.Number ? e.GetDecimal() : v;
            var font = Metin("font", yedek.Font).ToLowerInvariant();
            return Sinirla(new Tipografi(
                Fontlar.Contains(font) ? font : yedek.Font,
                Sayi("punto", yedek.Punto), Sayi("satir", yedek.Satir), (int)Sayi("paragraf", yedek.Paragraf),
                Metin("hiza", yedek.Hiza) == "sol" ? "sol" : "iki", (int)Sayi("kenar", yedek.Kenar),
                Sayi("baslikPunto", yedek.BaslikPunto), kaynak ?? Metin("kaynak", yedek.Kaynak)));
        }
        catch (JsonException) { return yedek with { Kaynak = kaynak ?? yedek.Kaynak }; }
    }

    /// <summary>Okunabilirlik sınırları (mockup karar notu 6): 9-12 pt, satır 1,0-2,0, paragraf 0-12 pt, kenar 10-25 mm, başlık 11-16 pt.</summary>
    public static Tipografi Sinirla(Tipografi t) => t with
    {
        Punto = Math.Clamp(Math.Round(t.Punto, 1), 9m, 12m),
        Satir = Math.Clamp(Math.Round(t.Satir, 2), 1.0m, 2.0m),
        Paragraf = Math.Clamp(t.Paragraf, 0, 12),
        Kenar = Math.Clamp(t.Kenar, 10, 25),
        BaslikPunto = Math.Clamp(Math.Round(t.BaslikPunto, 1), 11m, 16m),
    };

    public static async Task<Tipografi> KurumAsync(NpgsqlConnection b, NpgsqlTransaction? tx, CancellationToken iptal)
        => Coz(await AyarDeposu.MetinAsync(b, tx, "radyoloji.tipografi", "", iptal), Varsayilan, "kurum");

    /// <summary>Şablonun etkin tipografisi (kaynak 1 kurum · 2 özel · 3 özgün). Şablon yoksa kurum.</summary>
    public static async Task<Tipografi> SablonAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int? sablonId,
                                                    Tipografi kurum, CancellationToken iptal)
    {
        if (sablonId is not > 0) return kurum;
        var s = await b.TekAsync("""
            select tipografi_kaynak as kaynak, tip_font as font, tip_punto as punto, tip_satir as satir,
                   tip_paragraf as paragraf, tip_hiza as hiza
              from public.radyoloji_sablon where id = @p0
            """, tx, [sablonId.Value], OkuyucuGenisletmeleri.Sozluk, iptal);
        return SablondanTuret(s, kurum);
    }

    /// <summary>Şablon satırından (kart / liste sözlüğü) türetme - web ile aynı kural.</summary>
    public static Tipografi SablondanTuret(IDictionary<string, object?>? s, Tipografi kurum)
    {
        if (s is null) return kurum;
        var kaynak = Convert.ToInt32(s["kaynak"] ?? 1);
        if (kaynak == 3) return Ozgun;
        if (kaynak != 2) return kurum;
        var font = (s["font"]?.ToString() ?? "").ToLowerInvariant();
        return Sinirla(new Tipografi(
            Fontlar.Contains(font) ? font : kurum.Font,
            s["punto"] is decimal p ? p : kurum.Punto,
            s["satir"] is decimal sa ? sa : kurum.Satir,
            s["paragraf"] is null ? kurum.Paragraf : Convert.ToInt32(s["paragraf"]),
            s["hiza"] is null ? kurum.Hiza : Convert.ToInt32(s["hiza"]) == 1 ? "sol" : "iki",
            kurum.Kenar, kurum.BaslikPunto, "sablon"));
    }

    /// <summary>
    /// Raporun etkin tipografisi: damga varsa damga (ek raporda ana raporun damgası), yoksa şablon / kurum.
    /// İkinci değer: damgalı mı (onaylı rapor; çıktı buna göre "onay damgası" rozeti gösterir).
    /// </summary>
    public static async Task<(Tipografi Tipografi, bool Damgali)> RaporAsync(NpgsqlConnection b, NpgsqlTransaction? tx,
                                                                              int raporId, Tipografi kurum, CancellationToken iptal)
    {
        var r = await b.TekAsync("""
            select r.sablon_id as "sablonId", r.tipografi::text as damga,
                   (select u.tipografi::text from public.radyoloji_rapor u where u.id = r.ust_rapor_id) as "ustDamga"
              from public.radyoloji_rapor r where r.id = @p0
            """, tx, [raporId], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (r is null) return (kurum, false);
        var damga = r["damga"]?.ToString();
        if (string.IsNullOrEmpty(damga)) damga = r["ustDamga"]?.ToString();
        if (!string.IsNullOrEmpty(damga)) return (Coz(damga, Ozgun), true);
        var sablonId = r["sablonId"] is null ? (int?)null : Convert.ToInt32(r["sablonId"]);
        return (await SablonAsync(b, tx, sablonId, kurum, iptal), false);
    }

    /// <summary>
    /// ONAY DAMGASI: onay / e-imza anında geçerli tipografi rapora yazılır; zaten damgalıysa dokunulmaz
    /// (yeniden onay, imza-hazirla sonrası onay). Onaylı raporun her yeniden çıktısı bununla çizilir.
    /// </summary>
    public static async Task DamgalaAsync(NpgsqlConnection b, NpgsqlTransaction tx, int raporId, CancellationToken iptal)
    {
        var kurum = await KurumAsync(b, tx, iptal);
        var (t, damgali) = await RaporAsync(b, tx, raporId, kurum, iptal);
        if (damgali) return;
        await b.CalistirAsync("""
            update public.radyoloji_rapor set tipografi = @p1::jsonb where id = @p0 and tipografi is null
            """, tx, [raporId, Json(t)], iptal);
    }

    /// <summary>Kısa özet ("Arial 10,5 · 1,3") - log ve rozet için.</summary>
    public static string Ozet(Tipografi t)
        => $"{FontAdi(t.Font)} {t.Punto.ToString("0.#", CultureInfo.GetCultureInfo("tr-TR"))} · {t.Satir.ToString("0.##", CultureInfo.GetCultureInfo("tr-TR"))}";

    public static string FontAdi(string font) => font switch
    {
        "arial" => "Arial", "calibri" => "Calibri", "times" => "Times New Roman", "segoe" => "Segoe UI",
        "trebuchet" => "Trebuchet MS", _ => font,
    };
}
