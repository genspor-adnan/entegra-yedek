using System.Data;
using Npgsql;

namespace Gentegre.Veri;

/// <summary>
/// Tek NpgsqlDataSource - baglanti havuzu uygulama omru boyunca yasar.
/// Her sorgu @p0, @p1 ... sirali parametrelerle calisir; SQL metni kod icinde
/// ya da SorguUretici tarafindan katalogdan uretilir, istekten gelmez.
/// </summary>
public sealed class VeriKaynagi : IAsyncDisposable
{
    private readonly NpgsqlDataSource _kaynak;

    public VeriKaynagi(string baglantiDizesi)
    {
        var kurucu = new NpgsqlDataSourceBuilder(baglantiDizesi);
        _kaynak = kurucu.Build();
    }

    public NpgsqlConnection Baglanti() => _kaynak.CreateConnection();

    public async Task<NpgsqlConnection> AcAsync(CancellationToken iptal = default)
        => await _kaynak.OpenConnectionAsync(iptal);

    // ------------------------------------------------------------- yardimcilar ----
    public NpgsqlCommand Komut(NpgsqlConnection baglanti, string sql, IReadOnlyList<object?>? par)
    {
        var komut = new NpgsqlCommand(sql, baglanti);
        if (par is not null)
        {
            for (var i = 0; i < par.Count; i++)
                komut.Parameters.AddWithValue("p" + i, par[i] ?? DBNull.Value);
        }
        return komut;
    }

    public async Task<T?> TekDegerAsync<T>(string sql, IReadOnlyList<object?>? par = null,
                                           CancellationToken iptal = default)
    {
        await using var baglanti = await AcAsync(iptal);
        await using var komut = Komut(baglanti, sql, par);
        var sonuc = await komut.ExecuteScalarAsync(iptal);
        return sonuc is null or DBNull ? default : (T)Convert.ChangeType(sonuc, typeof(T));
    }

    public async Task<int> CalistirAsync(string sql, IReadOnlyList<object?>? par = null,
                                         CancellationToken iptal = default)
    {
        await using var baglanti = await AcAsync(iptal);
        await using var komut = Komut(baglanti, sql, par);
        return await komut.ExecuteNonQueryAsync(iptal);
    }

    public async Task<List<T>> ListeAsync<T>(string sql, IReadOnlyList<object?>? par,
                                             Func<NpgsqlDataReader, T> cevir,
                                             CancellationToken iptal = default)
    {
        var sonuc = new List<T>();
        await using var baglanti = await AcAsync(iptal);
        await using var komut = Komut(baglanti, sql, par);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal)) sonuc.Add(cevir(okuyucu));
        return sonuc;
    }

    public async Task<T?> TekAsync<T>(string sql, IReadOnlyList<object?>? par,
                                      Func<NpgsqlDataReader, T> cevir,
                                      CancellationToken iptal = default) where T : class
    {
        await using var baglanti = await AcAsync(iptal);
        await using var komut = Komut(baglanti, sql, par);
        await using var okuyucu = await komut.ExecuteReaderAsync(CommandBehavior.SingleRow, iptal);
        return await okuyucu.ReadAsync(iptal) ? cevir(okuyucu) : null;
    }

    public ValueTask DisposeAsync() => _kaynak.DisposeAsync();
}

public static class OkuyucuGenisletmeleri
{
    public static string Metin(this NpgsqlDataReader o, string alan)
    {
        var i = o.GetOrdinal(alan);
        return o.IsDBNull(i) ? "" : o.GetString(i);
    }

    public static int Sayi(this NpgsqlDataReader o, string alan)
    {
        var i = o.GetOrdinal(alan);
        return o.IsDBNull(i) ? 0 : Convert.ToInt32(o.GetValue(i));
    }

    public static int? SayiNull(this NpgsqlDataReader o, string alan)
    {
        var i = o.GetOrdinal(alan);
        return o.IsDBNull(i) ? null : Convert.ToInt32(o.GetValue(i));
    }

    public static long Uzun(this NpgsqlDataReader o, string alan)
    {
        var i = o.GetOrdinal(alan);
        return o.IsDBNull(i) ? 0 : Convert.ToInt64(o.GetValue(i));
    }

    /// <summary>PG'de mantik alanlari SMALLINT'tir (MSSQL bit karsiligi) - 1 = dogru.</summary>
    public static bool Bayrak(this NpgsqlDataReader o, string alan)
    {
        var i = o.GetOrdinal(alan);
        if (o.IsDBNull(i)) return false;
        var d = o.GetValue(i);
        return d is bool b ? b : Convert.ToInt32(d) == 1;
    }

    public static DateTime? Tarih(this NpgsqlDataReader o, string alan)
    {
        var i = o.GetOrdinal(alan);
        return o.IsDBNull(i) ? null : o.GetDateTime(i);
    }
}
