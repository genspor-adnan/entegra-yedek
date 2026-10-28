using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>Uygulama rolü testi: <c>GENTEGRE_TEST_API_DB</c> yoksa AÇIKÇA atlanır (yayın kalite kapısı verir).</summary>
public sealed class UygulamaRoluFactAttribute : FactAttribute
{
    public UygulamaRoluFactAttribute()
    {
        if (TestVeritabani.ApiDizge is null)
            Skip = "GENTEGRE_TEST_API_DB tanımlı değil - uygulama rolü testleri atlandı (yayinla.ps1 kalite kapısı verir).";
    }
}

/// <summary>
/// KOD İNCELEME RAPORU 28.10.2026 — B07: API veritabanına sınırlı uygulama rolüyle bağlanır
/// (<c>yayin/uygulama-rolu.sql</c>). Kabul: rol tablo / rol / veritabanı oluşturamaz, kalıcı nesne silemez,
/// sunucu dosyasına ve programına uzanamaz, göç defterini değiştiremez; normal veri işleri (okuma, yazma,
/// geçici tablo, sequence) çalışır. Normal API işlemlerinin çalıştığını öteki bütün API testleri gösterir
/// (aynı rolle koşan API sürecine istek atarlar).
/// </summary>
public sealed class UygulamaRoluTestleri
{
    private static async Task<string?> HataAsync(string sql)
    {
        await using var b = new NpgsqlConnection(TestVeritabani.ApiDizge);
        await b.OpenAsync();
        try { await using var k = new NpgsqlCommand(sql, b); await k.ExecuteNonQueryAsync(); return null; }
        catch (PostgresException h) { return h.SqlState; }
    }

    [UygulamaRoluFact]
    public async Task Rol_super_kullanici_degil_ve_kalici_nesneye_dokunamaz()
    {
        var veri = new VeriKaynagi(TestVeritabani.ApiDizge!);
        Assert.False(await veri.TekDegerAsync<bool>("select rolsuper from pg_roles where rolname = current_user"));

        // 42501 = insufficient_privilege
        foreach (var sql in new[]
        {
            "create table public.b07_kotu (a int)",
            "create role b07_kotu",
            "create database b07_kotu",
            "drop table public.taraf",
            "alter table public.taraf add column b07 int",
            "truncate public.oturum",
            "copy (select 1) to program 'id'",
            "select pg_read_file('/etc/passwd')",
            "delete from public.goc_gecmisi where false",
            "create schema b07_kotu",
        })
            Assert.True(await HataAsync(sql) == "42501", sql);
    }

    [UygulamaRoluFact]
    public async Task Veri_isleri_calisir()
    {
        Assert.Null(await HataAsync("select count(*) from public.taraf"));
        Assert.Null(await HataAsync("update public.taraf set unvan = unvan where false"));
        Assert.Null(await HataAsync("create temp table _b07 (a int); truncate _b07; drop table _b07"));
        Assert.Null(await HataAsync("select nextval(pg_get_serial_sequence('public.oturum', 'id')) is not null"));
    }
}
