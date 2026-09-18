using System.Security.Cryptography;
using System.Text;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// PORTAL DAVETİ (822).
///
/// Kullanıcı: *"hasta davetini de yap"*.
///
/// Davet bağlantısı, o hesaba giriş hakkıdır. Testin koruduğu sınırlar:
/// jeton depoda DÜZ DURMAZ, süresi dolan davet geçmez, tek kullanımlıktır ve
/// aynı kişiye ikinci davet eskisini kapatır.
/// </summary>
public sealed class PortalDavetiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    /// <summary>Uçtaki ile AYNI özet: SHA-256, hex, küçük harf.</summary>
    private static string Ozet(string jeton)
        => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(jeton))).ToLowerInvariant();

    private static async Task<int> HastaAsync(NpgsqlConnection b, NpgsqlTransaction t)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        return await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, kod, kisi, hasta, vkno, sube_id, grup)
            values ('DAVET TEST HASTA', @p1, 1, 1, @p2, @p0, 101) returning id
            """, t, [sube, $"DVT{Guid.NewGuid().ToString("N")[..8]}",
                     Guid.NewGuid().ToString("N")[..11]], Iptal);
    }

    private static Task<long> DavetAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int tarafId, string jeton, int saat = 48, short durum = 1)
        => b.TekDegerAsync<long>("""
            insert into public.portal_davet
                   (taraf_id, kanal, alici, jeton_ozet, durum, gecerlilik)
            values (@p0, 1, '905000000000', @p1, @p2,
                    (now() + make_interval(hours => @p3))::timestamp)
            returning id
            """, t, [tarafId, Ozet(jeton), durum, saat], Iptal);

    /// <summary>Uçtaki "geçerli davet" sorgusunun aynısı.</summary>
    private static Task<long?> BulAsync(NpgsqlConnection b, NpgsqlTransaction t, string jeton)
        => b.TekDegerAsync<long?>("""
            select d.id from public.portal_davet d
             where d.jeton_ozet = @p0 and d.durum = 1
               and d.gecerlilik >= now()::timestamp
            """, t, [Ozet(jeton)], Iptal);

    [Fact]
    public async Task Jeton_duz_saklanmaz()
    {
        if (!_olgu.Baglandi(nameof(Jeton_duz_saklanmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var jeton = "ORNEK-JETON-" + Guid.NewGuid().ToString("N");
        var id = await DavetAsync(b, t, await HastaAsync(b, t), jeton);

        // Veritabanını (ya da yedeğini) okuyan biri, kayıttan çalışan bir
        //   bağlantı üretememeli.
        var saklanan = await b.TekDegerAsync<string>(
            "select jeton_ozet from public.portal_davet where id = @p0", t, [id], Iptal);
        Assert.NotEqual(jeton, saklanan);
        Assert.Equal(64, saklanan!.Length);
        Assert.Equal(Ozet(jeton), saklanan);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Gecerli_davet_bulunur()
    {
        if (!_olgu.Baglandi(nameof(Gecerli_davet_bulunur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var jeton = Guid.NewGuid().ToString("N");
        var id = await DavetAsync(b, t, await HastaAsync(b, t), jeton);
        Assert.Equal(id, await BulAsync(b, t, jeton));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Suresi_dolan_davet_gecmez()
    {
        if (!_olgu.Baglandi(nameof(Suresi_dolan_davet_gecmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Süresiz bağlantı, telefonda sonsuza kadar duran bir anahtardır.
        var jeton = Guid.NewGuid().ToString("N");
        await DavetAsync(b, t, await HastaAsync(b, t), jeton, saat: -1);
        Assert.Null(await BulAsync(b, t, jeton));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Kullanilan_davet_ikinci_kez_gecmez()
    {
        if (!_olgu.Baglandi(nameof(Kullanilan_davet_ikinci_kez_gecmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var jeton = Guid.NewGuid().ToString("N");
        var id = await DavetAsync(b, t, await HastaAsync(b, t), jeton);
        await b.CalistirAsync(
            "update public.portal_davet set durum = 2, kullanim_zamani = now()::timestamp "
            + "where id = @p0", t, [id], Iptal);

        Assert.Null(await BulAsync(b, t, jeton));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Ikinci_davet_eskisini_kapatir()
    {
        if (!_olgu.Baglandi(nameof(Ikinci_davet_eskisini_kapatir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // İki geçerli bağlantı dolaşması "hangisi geçerli" sorusunu doğurur;
        //   iptal edilen biri hâlâ çalışıyor olurdu.
        var hasta = await HastaAsync(b, t);
        var eski = Guid.NewGuid().ToString("N");
        await DavetAsync(b, t, hasta, eski);
        var yeni = Guid.NewGuid().ToString("N");
        await DavetAsync(b, t, hasta, yeni);

        Assert.Null(await BulAsync(b, t, eski));
        Assert.NotNull(await BulAsync(b, t, yeni));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Ayni_jeton_iki_kez_yazilamaz()
    {
        if (!_olgu.Baglandi(nameof(Ayni_jeton_iki_kez_yazilamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var jeton = Guid.NewGuid().ToString("N");
        await DavetAsync(b, t, await HastaAsync(b, t), jeton);

        var ikinciHasta = await HastaAsync(b, t);
        await b.CalistirAsync("savepoint sp", t, [], Iptal);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => DavetAsync(b, t, ikinciHasta, jeton));
        Assert.Equal("23505", h.SqlState);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Davet_sablonlari_tanimli()
    {
        if (!_olgu.Baglandi(nameof(Davet_sablonlari_tanimli))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Metin ŞABLONDA durur (740 deseni): kurum imzasını değiştirebilmeli.
        var sayi = await b.TekDegerAsync<int>(
            "select count(*) from public.bildirim_sablon "
            + "where kod in ('portal.davet', 'portal.davet.eposta') and durum = 1",
            null, [], Iptal);
        Assert.Equal(2, sayi);
    }
}
