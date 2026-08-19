using System.Text.Json;
using Npgsql;

namespace Gentegre.Veri.Depolar;

public static class LogIslemi
{
    public const short Sil      = 0;
    public const short Ekle     = 1;
    public const short Degistir = 2;
}

/// <summary>
/// GENDEPO.ISLEMLOG'un karsiligi (public.islem_log, tarihe gore bolumlenmis).
///
/// Delphi'den tasinan kurallar (Ortak/ULog.pas):
///   - SILME logu DELETE'ten ONCE yazilir; satirin TAM HALI bilgi alaninda durur
///     ("Geri Al" bunu kullanir).
///   - DEGISIKLIK logu alan bazlidir: {"alan": "eski -> yeni"}. Degismeyen alan yazilmaz;
///     hicbir alan degismediyse log satiri ACILMAZ (bos "degisiklik" kaydi olmaz).
/// </summary>
public sealed class LogDeposu
{
    public async Task YazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        short islemTipi, int tabloId, long kayitId, int kullaniciId, int? subeId,
        string ip, object? bilgi, int ustTabloId = 0, long ustKayitId = 0,
        int? tarafId = null, int? stokId = null, CancellationToken iptal = default)
    {
        var bilgiJson = bilgi is null ? null : JsonSerializer.Serialize(bilgi);

        await using var komut = new NpgsqlCommand("""
            insert into public.islem_log
                (kullanici_id, sube_id, ip, islem_tipi, ust_tablo_id, ust_kayit_id,
                 tablo_id, kayit_id, taraf_id, stok_id, bilgi)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10::jsonb)
            """, baglanti, islem);

        komut.Parameters.AddWithValue("p0", kullaniciId);
        komut.Parameters.AddWithValue("p1", (short)(subeId ?? 0));
        komut.Parameters.AddWithValue("p2", ip ?? "");
        komut.Parameters.AddWithValue("p3", islemTipi);
        komut.Parameters.AddWithValue("p4", ustTabloId);
        komut.Parameters.AddWithValue("p5", ustKayitId);
        komut.Parameters.AddWithValue("p6", tabloId);
        komut.Parameters.AddWithValue("p7", kayitId);
        komut.Parameters.AddWithValue("p8", (object?)tarafId ?? DBNull.Value);
        komut.Parameters.AddWithValue("p9", (object?)stokId ?? DBNull.Value);
        komut.Parameters.AddWithValue("p10", (object?)bilgiJson ?? DBNull.Value);

        await komut.ExecuteNonQueryAsync(iptal);
    }

    /// <summary>
    /// Alan bazli fark: {"unvan": "Eski A.S. -> Yeni A.S."}. Degisen alan yoksa null doner
    /// ve cagiran log satirini HIC acmaz.
    /// </summary>
    public static Dictionary<string, string>? Fark(
        IDictionary<string, object?> eski, IDictionary<string, object?> yeni)
    {
        var fark = new Dictionary<string, string>(StringComparer.Ordinal);

        foreach (var (alan, yeniDeger) in yeni)
        {
            eski.TryGetValue(alan, out var eskiDeger);
            var e = Metin(eskiDeger);
            var y = Metin(yeniDeger);
            if (!string.Equals(e, y, StringComparison.Ordinal))
                fark[alan] = e + " -> " + y;
        }

        return fark.Count == 0 ? null : fark;
    }

    /// <summary>
    /// Log metni KULTURDEN BAGIMSIZ yazilir. Turkce kulturde "1250,50" yazilirsa
    /// "Geri Al" bunu geri okurken bozulur (Delphi tarafinda da ayni tuzaga dusulmustu).
    /// </summary>
    public static string Metin(object? d) => d switch
    {
        null => "",
        DateTime t => t.ToString("yyyy-MM-dd HH:mm:ss", System.Globalization.CultureInfo.InvariantCulture),
        decimal m => m.ToString(System.Globalization.CultureInfo.InvariantCulture),
        double f => f.ToString(System.Globalization.CultureInfo.InvariantCulture),
        float f => f.ToString(System.Globalization.CultureInfo.InvariantCulture),
        IFormattable bicimlenebilir => bicimlenebilir.ToString(null, System.Globalization.CultureInfo.InvariantCulture),
        _ => d.ToString() ?? ""
    };
}
