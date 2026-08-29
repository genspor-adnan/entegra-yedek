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

    public async Task<NpgsqlConnection> AcAsync(CancellationToken iptal = default)
        => await _kaynak.OpenConnectionAsync(iptal);

    // NOT (islem/transaction sarmalayicisi): 32 cagri yerinin hepsi
    //   `await using var islem = ... BeginTransactionAsync` + acik `CommitAsync`
    //   deseniyle yazilmis ve HEPSI dengeli - commit'i unutan yer yok, `await
    //   using` de hata halinde zaten Rollback ediyor. Sarmalayici kazanci iki
    //   satirla sinirli kalacagi icin 32 metot govdesi lambdaya cevrilmedi.

    // ------------------------------------------------------------- yardimcilar ----
    public NpgsqlCommand Komut(NpgsqlConnection baglanti, string sql, IReadOnlyList<object?>? par)
    {
        var komut = new NpgsqlCommand(sql, baglanti);
        // NULL parametreler TIPLI gonderilir (Parametre.Ekle): tipsiz NULL'i
        //   PostgreSQL cikaramadigi baglamlarda 42P08 ile reddediyor.
        if (par is not null) Parametre.Ekle(komut, par);
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

/// <summary>
/// ACIK BAGLANTI uzerinde sorgu yardimcilari.
///
/// <see cref="VeriKaynagi"/>'nin yardimcilari her cagride YENI baglanti aciyor;
/// bir islemin (transaction) icinde ya da ardisik sorgularda kullanilamiyorlardi.
/// Sonuc: depolarin cogu <c>new NpgsqlCommand(...)</c> + <c>AddWithValue</c> +
/// <c>ExecuteReaderAsync</c> uclusunu elle yaziyordu (87 yerde, ~430 parametre
/// eklemesi). Bu genisletmeler ayni isi tek satirda yapar.
///
/// Parametreler SIRALI verilir ve SQL'de @p0, @p1 ... olarak gecer. NULL'lar
/// <see cref="Parametre"/> uzerinden TIPLI gonderilir - <c>AddWithValue(ad,
/// DBNull.Value)</c> tipsiz NULL uretir ve PostgreSQL bunu bazi baglamlarda
/// "42P08 could not determine data type" ile reddeder.
/// </summary>
public static class BaglantiGenisletmeleri
{
    /// <remarks>
    /// DIKKAT: parametrelerin TAMAMI tek bir dizi degerinden ibaretse
    /// <c>(object?)</c> ile kapatin - <c>params</c> diziyi ACAR ve her ogesi ayri
    /// parametre olur. Dizinin baska parametrelerle birlikte verildigi durumda
    /// sorun yok (derleyici hepsini sarar).
    /// </remarks>
    public static NpgsqlCommand Komut(this NpgsqlConnection baglanti, string sql,
                                      NpgsqlTransaction? islem, params object?[] par)
    {
        var komut = new NpgsqlCommand(sql, baglanti, islem);
        if (par.Length > 0) Parametre.Ekle(komut, par);
        return komut;
    }

    /// <summary>INSERT/UPDATE/DELETE - etkilenen satir sayisi.</summary>
    public static async Task<int> CalistirAsync(this NpgsqlConnection baglanti, string sql,
        NpgsqlTransaction? islem, object?[] par, CancellationToken iptal = default)
    {
        await using var komut = baglanti.Komut(sql, islem, par);
        return await komut.ExecuteNonQueryAsync(iptal);
    }

    /// <summary>
    /// Tek hucre; satir yoksa ya da NULL ise <c>default</c>.
    /// T NULLABLE olabilir (<c>int?</c>): Convert.ChangeType Nullable&lt;T&gt;'yi
    /// ceviremedigi icin alttaki tip kullanilir - eskiden cagri yerlerinin
    /// "TekDegerAsync&lt;int?&gt; KULLANMA" notuyla dolasmasi gerekiyordu.
    /// </summary>
    public static async Task<T?> TekDegerAsync<T>(this NpgsqlConnection baglanti, string sql,
        NpgsqlTransaction? islem, object?[] par, CancellationToken iptal = default)
    {
        await using var komut = baglanti.Komut(sql, islem, par);
        var sonuc = await komut.ExecuteScalarAsync(iptal);
        if (sonuc is null or DBNull) return default;
        var tip = Nullable.GetUnderlyingType(typeof(T)) ?? typeof(T);
        return (T)Convert.ChangeType(sonuc, tip);
    }

    /// <summary>Satirlari <paramref name="cevir"/> ile nesneye donusturur.</summary>
    public static async Task<List<T>> ListeAsync<T>(this NpgsqlConnection baglanti, string sql,
        NpgsqlTransaction? islem, object?[] par, Func<NpgsqlDataReader, T> cevir,
        CancellationToken iptal = default)
    {
        var sonuc = new List<T>();
        await using var komut = baglanti.Komut(sql, islem, par);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal)) sonuc.Add(cevir(okuyucu));
        return sonuc;
    }

    /// <summary>Ilk satir; satir yoksa null.</summary>
    public static async Task<T?> TekAsync<T>(this NpgsqlConnection baglanti, string sql,
        NpgsqlTransaction? islem, object?[] par, Func<NpgsqlDataReader, T> cevir,
        CancellationToken iptal = default) where T : class
    {
        await using var komut = baglanti.Komut(sql, islem, par);
        await using var okuyucu = await komut.ExecuteReaderAsync(CommandBehavior.SingleRow, iptal);
        return await okuyucu.ReadAsync(iptal) ? cevir(okuyucu) : null;
    }
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
