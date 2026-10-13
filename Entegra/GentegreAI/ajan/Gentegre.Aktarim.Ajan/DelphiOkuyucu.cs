using System.Data;
using System.Globalization;
using System.Text.Json.Nodes;
using Microsoft.Data.SqlClient;

namespace Gentegre.Aktarim.Ajan;

/// <summary>Change Tracking satırı: işlem (I / U / D) + birincil anahtar değerleri.</summary>
public sealed record Degisiklik(char Islem, object[] Anahtar);

/// <summary>
/// Delphi MSSQL'den SALT OKUR. Satırlar sunucunun stg şemasının tanıdığı kolonlarla,
/// küçük harf anahtarla JSON'a çevrilir (bit 0/1, tarih saat dilimsiz ISO, ikili
/// "\x.." onaltılık, metindeki 0x00 atılır - PG kabul etmez).
/// Kimlik listeleri SAYI olarak metne gömülür (parametre sınırı 2100); bileşik / sayı
/// olmayan anahtar parametreyle gider.
/// </summary>
public sealed class DelphiOkuyucu(string baglanti)
{
    private const int InParcasi = 1000;
    private readonly Dictionary<string, string[]> _pk = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, Dictionary<string, string>> _kolon = new(StringComparer.OrdinalIgnoreCase);

    /// <summary>
    /// Bağlantı açılışı geçici hatada yeniden denenir (1 sn, 2 sn, 4 sn, 8 sn). Dayanıklılık
    /// testinde (500 bin satırlık tam yükleme) SQL Browser örnek adını bir kez çözemedi
    /// (error 26) ve tur baştan başladı - tam yüklemede bu, dakikalarca işin kaybı demek.
    /// </summary>
    private async Task<SqlConnection> AcAsync(CancellationToken iptal)
    {
        for (var deneme = 1; ; deneme++)
        {
            var b = new SqlConnection(baglanti);
            try
            {
                await b.OpenAsync(iptal);
                return b;
            }
            catch (SqlException) when (deneme < 5 && !iptal.IsCancellationRequested)
            {
                await b.DisposeAsync();
                SqlConnection.ClearPool(b);
                await Task.Delay(TimeSpan.FromSeconds(1 << (deneme - 1)), iptal);
            }
        }
    }

    private static SqlCommand Komut(SqlConnection b, string sql, params SqlParameter[] p)
    {
        var k = new SqlCommand(sql, b) { CommandTimeout = 600 };
        k.Parameters.AddRange(p);
        return k;
    }

    public async Task<long> GuncelVersiyonAsync(CancellationToken iptal)
    {
        await using var b = await AcAsync(iptal);
        await using var k = Komut(b, "SELECT CHANGE_TRACKING_CURRENT_VERSION()");
        return await k.ExecuteScalarAsync(iptal) is long v ? v
             : throw new InvalidOperationException("Veritabanında Change Tracking kapalı (sp_Aktarim_Hazirla @Ac=1).");
    }

    /// <summary>Bu versiyondan eskisinden değişiklik okunamaz (saklama süresi doldu) -> tam eşitleme.</summary>
    public async Task<long> EnAzVersiyonAsync(string tablo, CancellationToken iptal)
    {
        await using var b = await AcAsync(iptal);
        await using var k = Komut(b, "SELECT CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID(@t))", new SqlParameter("@t", "dbo." + tablo));
        return await k.ExecuteScalarAsync(iptal) is long v ? v
             : throw new InvalidOperationException($"{tablo} tablosunda Change Tracking kapalı.");
    }

    public async Task<string[]> AnahtarAsync(string tablo, CancellationToken iptal)
    {
        if (_pk.TryGetValue(tablo, out var v)) return v;
        await using var b = await AcAsync(iptal);
        await using var k = Komut(b, """
            SELECT c.name FROM sys.indexes i
              JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
              JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
             WHERE i.object_id = OBJECT_ID(@t) AND i.is_primary_key = 1 ORDER BY ic.key_ordinal
            """, new SqlParameter("@t", "dbo." + tablo));
        var l = new List<string>();
        await using (var r = await k.ExecuteReaderAsync(iptal))
            while (await r.ReadAsync(iptal)) l.Add(r.GetString(0));
        if (l.Count == 0) throw new InvalidOperationException($"{tablo} tablosunun birincil anahtarı yok.");
        return _pk[tablo] = [.. l];
    }

    /// <summary>Sunucunun istediği kolonların Delphi'deki gerçek adları (küçük harf -> ad).</summary>
    public async Task<Dictionary<string, string>> KolonlarAsync(string tablo, IEnumerable<string> istenen, CancellationToken iptal)
    {
        if (_kolon.TryGetValue(tablo, out var v)) return v;
        await using var b = await AcAsync(iptal);
        await using var k = Komut(b, "SELECT name FROM sys.columns WHERE object_id = OBJECT_ID(@t)", new SqlParameter("@t", "dbo." + tablo));
        var var = new Dictionary<string, string>(StringComparer.Ordinal);
        await using (var r = await k.ExecuteReaderAsync(iptal))
            while (await r.ReadAsync(iptal)) var[r.GetString(0).ToLowerInvariant()] = r.GetString(0);
        var sonuc = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var s in istenen)
            if (var.TryGetValue(s, out var ad)) sonuc[s] = ad;
        return _kolon[tablo] = sonuc;
    }

    public async Task<List<Degisiklik>> DegisikliklerAsync(string tablo, long versiyon, CancellationToken iptal)
    {
        var pk = await AnahtarAsync(tablo, iptal);
        await using var b = await AcAsync(iptal);
        await using var k = Komut(b,
            $"SELECT CT.SYS_CHANGE_OPERATION, {string.Join(", ", pk.Select(p => "CT.[" + p + "]"))} " +
            $"FROM CHANGETABLE(CHANGES dbo.[{tablo}], @v) CT", new SqlParameter("@v", versiyon));
        var l = new List<Degisiklik>();
        await using var r = await k.ExecuteReaderAsync(iptal);
        while (await r.ReadAsync(iptal))
        {
            var a = new object[pk.Length];
            for (var i = 0; i < pk.Length; i++) a[i] = r.GetValue(i + 1);
            l.Add(new Degisiklik(r.GetString(0)[0], a));
        }
        return l;
    }

    /// <summary>
    /// Cari başına TL bakiye, Delphi ekstre kuralıyla (1096 - 1085 eşdeğerlik testindeki kural):
    /// KASA cari satırı ve carisi olan hesap satırı olduğu gibi (döviz satırında TL karşılığı),
    /// faturalar TUR 15/16/17 borç, 8/11/12/13 alacak, iade (TIPI 2) ters, DURUM 6 hariç.
    /// <paramref name="disi"/>: web'de bakiyeye girmeyen kasa türleri (sunucudan, sayı).
    /// </summary>
    public async Task<List<(long Id, decimal Tutar)>> CariBakiyeleriAsync(DateTime bas, IReadOnlyCollection<int> disi, CancellationToken iptal)
    {
        var haric = disi.Count == 0 ? "" : $" AND K.TUR NOT IN ({string.Join(",", disi.Select(x => x.ToString(CultureInfo.InvariantCulture)))})";
        await using var b = await AcAsync(iptal);
        await using var k = Komut(b, $"""
            SELECT x.REHBERID, CAST(SUM(x.t) AS decimal(19, 2)) FROM (
              SELECT K.REHBERID, CASE WHEN ISNULL(K.KUR, 'TL') IN ('TL', '') THEN K.BORC - K.ALACAK
                                      WHEN K.BORC <> 0 THEN K.DOVIZ_TUTARI ELSE -K.DOVIZ_TUTARI END t
                FROM dbo.KASA K
               WHERE K.ISLEMTARIHI >= @bas{haric}
                 AND (K.REHBERID > 0 OR (K.REHBERID = 0 AND ISNULL(K.HESAPTURU, '') IN ('', '1', 'C')))
              UNION ALL
              SELECT F.REHBERID, CASE WHEN F.TUR IN (15, 16, 17) THEN 1 ELSE -1 END
                               * CASE WHEN F.TIPI = 2 THEN -1 ELSE 1 END * F.FATURA_TUTARI
                FROM dbo.FATBASLIK F
               WHERE F.FATURATARIH >= @bas AND F.TUR IN (8, 11, 12, 13, 15, 16, 17)
                 AND ISNULL(F.DURUM, 0) <> 6 AND F.REHBERID >= 0) x
            GROUP BY x.REHBERID
            """, new SqlParameter("@bas", bas));
        var l = new List<(long, decimal)>();
        await using var r = await k.ExecuteReaderAsync(iptal);
        while (await r.ReadAsync(iptal))
            if (!r.IsDBNull(0)) l.Add((Convert.ToInt64(r.GetValue(0), CultureInfo.InvariantCulture), r.IsDBNull(1) ? 0 : r.GetDecimal(1)));
        return l;
    }

    /// <summary>Kök tam yükleme: kimlikler (süzgeç + sıra).</summary>
    public async Task<List<long>> KimliklerAsync(string tablo, string? nerede, string? sira, SqlParameter[] p, CancellationToken iptal)
    {
        await using var b = await AcAsync(iptal);
        await using var k = Komut(b, $"SELECT [ID] FROM dbo.[{tablo}]" + (nerede is null ? "" : " WHERE " + nerede) +
                                     " ORDER BY " + (sira ?? "[ID]"), p);
        var l = new List<long>();
        await using var r = await k.ExecuteReaderAsync(iptal);
        while (await r.ReadAsync(iptal)) l.Add(Convert.ToInt64(r.GetValue(0), CultureInfo.InvariantCulture));
        return l;
    }

    /// <summary>Alt satır kimliklerinden kök kimlikleri (Toplamlar.UstSorgu).</summary>
    public async Task<HashSet<long>> UstlerAsync(string sorgu, IReadOnlyCollection<long> idler, CancellationToken iptal)
    {
        var s = new HashSet<long>();
        await using var b = await AcAsync(iptal);
        foreach (var parca in idler.Chunk(InParcasi))
        {
            await using var k = Komut(b, string.Format(CultureInfo.InvariantCulture, sorgu, Liste(parca)));
            await using var r = await k.ExecuteReaderAsync(iptal);
            while (await r.ReadAsync(iptal))
                if (!r.IsDBNull(0)) s.Add(Convert.ToInt64(r.GetValue(0), CultureInfo.InvariantCulture));
        }
        return s;
    }

    /// <summary>WHERE şablonu ({0} = kimlik listesi) ile satırlar, kimlikler parça parça.</summary>
    public async Task<List<JsonObject>> SatirlarAsync(string tablo, Dictionary<string, string> kolonlar, string filtre,
                                                      IReadOnlyCollection<long> idler, CancellationToken iptal)
    {
        var l = new List<JsonObject>();
        if (idler.Count == 0) return l;
        await using var b = await AcAsync(iptal);
        foreach (var parca in idler.Chunk(InParcasi))
            await OkuAsync(b, Secim(tablo, kolonlar) + " WHERE " + string.Format(CultureInfo.InvariantCulture, filtre, Liste(parca)),
                           kolonlar, l, [], iptal);
        return l;
    }

    /// <summary>Bütün tablo (tekil tablonun tam yüklemesi), isteğe bağlı süzgeçle.</summary>
    public async Task<List<JsonObject>> TumuAsync(string tablo, Dictionary<string, string> kolonlar, string? nerede,
                                                  SqlParameter[] p, CancellationToken iptal)
    {
        var l = new List<JsonObject>();
        await using var b = await AcAsync(iptal);
        await OkuAsync(b, Secim(tablo, kolonlar) + (nerede is null ? "" : " WHERE " + nerede), kolonlar, l, p, iptal);
        return l;
    }

    /// <summary>Anahtar değerleriyle satırlar (tek sayısal anahtar -> IN, yoksa VALUES + parametre).</summary>
    public async Task<List<JsonObject>> AnahtarlaAsync(string tablo, Dictionary<string, string> kolonlar,
                                                       IReadOnlyList<object[]> anahtarlar, CancellationToken iptal)
    {
        var pk = await AnahtarAsync(tablo, iptal);
        var l = new List<JsonObject>();
        if (anahtarlar.Count == 0) return l;
        await using var b = await AcAsync(iptal);
        if (pk.Length == 1 && anahtarlar.All(a => Sayisal(a[0])))
        {
            foreach (var parca in anahtarlar.Select(a => Convert.ToInt64(a[0], CultureInfo.InvariantCulture)).Chunk(InParcasi))
                await OkuAsync(b, Secim(tablo, kolonlar) + $" WHERE t.[{pk[0]}] IN ({Liste(parca)})", kolonlar, l, [], iptal);
            return l;
        }
        foreach (var parca in anahtarlar.Chunk(Math.Max(1, 2000 / pk.Length)))
        {
            var p = new List<SqlParameter>();
            var satirlar = parca.Select(a => "(" + string.Join(", ", a.Select(d =>
            {
                var ad = "@k" + p.Count;
                p.Add(new SqlParameter(ad, d));
                return ad;
            })) + ")");
            var sql = Secim(tablo, kolonlar) +
                      $" JOIN (VALUES {string.Join(", ", satirlar)}) k({string.Join(", ", pk.Select((_, i) => "k" + i))})" +
                      $" ON {string.Join(" AND ", pk.Select((c, i) => $"t.[{c}] = k.k{i}"))}";
            await OkuAsync(b, sql, kolonlar, l, [.. p], iptal);
        }
        return l;
    }

    private static string Secim(string tablo, Dictionary<string, string> kolonlar)
        => $"SELECT {string.Join(", ", kolonlar.Values.Select(c => "t.[" + c + "]"))} FROM dbo.[{tablo}] t";

    private static string Liste(IEnumerable<long> idler) => string.Join(",", idler.Select(i => i.ToString(CultureInfo.InvariantCulture)));

    private static bool Sayisal(object o) => o is int or long or short or byte or decimal;

    private static async Task OkuAsync(SqlConnection b, string sql, Dictionary<string, string> kolonlar, List<JsonObject> hedef,
                                       SqlParameter[] p, CancellationToken iptal)
    {
        // Parametre nesnesi tek komuta bağlanır: her çağrıda kopya.
        await using var k = Komut(b, sql, [.. p.Select(x => (SqlParameter)((ICloneable)x).Clone())]);
        await using var r = await k.ExecuteReaderAsync(CommandBehavior.SequentialAccess, iptal);
        var adlar = kolonlar.Keys.ToArray();
        while (await r.ReadAsync(iptal))
        {
            var o = new JsonObject();
            for (var i = 0; i < adlar.Length; i++) o[adlar[i]] = Deger(r.GetValue(i));
            hedef.Add(o);
        }
    }

    public static JsonNode? Deger(object v) => v switch
    {
        DBNull or null => null,
        bool x => JsonValue.Create(x ? 1 : 0),
        byte x => JsonValue.Create(x),
        short x => JsonValue.Create(x),
        int x => JsonValue.Create(x),
        long x => JsonValue.Create(x),
        decimal x => JsonValue.Create(x),
        double x => double.IsFinite(x) ? JsonValue.Create(x) : null,
        float x => float.IsFinite(x) ? JsonValue.Create(x) : null,
        DateTime x => JsonValue.Create(x.ToString("yyyy-MM-dd'T'HH:mm:ss.fff", CultureInfo.InvariantCulture)),
        DateTimeOffset x => JsonValue.Create(x.ToString("O", CultureInfo.InvariantCulture)),
        TimeSpan x => JsonValue.Create(x.ToString("c", CultureInfo.InvariantCulture)),
        byte[] x => JsonValue.Create("\\x" + Convert.ToHexString(x)),
        Guid x => JsonValue.Create(x.ToString()),
        string x => JsonValue.Create(x.Contains('\0') ? x.Replace("\0", "") : x),
        _ => JsonValue.Create(Convert.ToString(v, CultureInfo.InvariantCulture)),
    };
}
