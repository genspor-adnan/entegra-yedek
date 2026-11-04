using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// Aktarım testlerinin ortak yardımcıları. Aynı üç satır yedi test dosyasında kopyaydı (04.11.2026 refaktor);
/// sınıflar <c>using static Gentegre.Testler.AktarimTestYardimcisi;</c> ile alır.
/// </summary>
internal static class AktarimTestYardimcisi
{
    /// <summary>Paket alan aktarım fonksiyonu: <c>select public.fn(@p0::jsonb)</c> → sonuç JSON nesnesi.</summary>
    public static async Task<JsonObject> AktarAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    /// <summary>Parametresiz fonksiyon: <c>select public.fn()</c> → sonuç JSON nesnesi.</summary>
    public static async Task<JsonObject> CalistirAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}()::text", t, [], CancellationToken.None) ?? "{}")!;

    /// <summary>Sonuç JSON'undaki sayaç; alan yoksa 0.</summary>
    public static int Sayi(JsonObject o, string k) => o[k]?.GetValue<int>() ?? 0;
}
