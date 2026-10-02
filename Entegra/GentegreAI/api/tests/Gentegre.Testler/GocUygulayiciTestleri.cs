using System.Diagnostics;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// GÖÇ UYGULAYICI (denetim 28.09.2026 #10) — yerel (db/araclar/goc_uygula.ps1)
/// ve sunucu (yayin/goc_uygula.sh) uygulayıcıları AYNI senaryolarla, GERÇEK
/// süreç olarak çalıştırılır; her test kendi geçici veritabanını açıp siler.
///
/// <para>Uygulayıcılar PostgreSQL'e docker konteyneri üzerinden bağlanır:
/// <c>GENTEGRE_TEST_PG_KAP</c> (varsayılan <c>gentegre-pg18</c>). Veritabanı
/// testi olarak <see cref="VtFactAttribute"/> ile işaretlidir.</para>
/// </summary>
public sealed class GocUygulayiciTestleri : IAsyncLifetime
{
    private static readonly string Kok = KokBul();
    private static string Kap => Environment.GetEnvironmentVariable("GENTEGRE_TEST_PG_KAP") is { Length: > 0 } k
        ? k : "gentegre-pg18";

    private readonly string _db = "gentegre_goc_test_" + Guid.NewGuid().ToString("N")[..8];
    private readonly string _dizin = Path.Combine(Path.GetTempPath(), "goc_test_" + Guid.NewGuid().ToString("N")[..8]);
    private VeriKaynagi? _yonetim;
    private VeriKaynagi? _veri;

    private static string KokBul()
    {
        var d = new DirectoryInfo(AppContext.BaseDirectory);
        while (d is not null && !Directory.Exists(Path.Combine(d.FullName, "db", "araclar"))) d = d.Parent;
        return d?.FullName ?? throw new DirectoryNotFoundException("GentegreAI kök dizini bulunamadı");
    }

    public async Task InitializeAsync()
    {
        if (TestVeritabani.Dizge is not { } dizge) return;
        _yonetim = new VeriKaynagi(dizge);
        await _yonetim.CalistirAsync($"create database {_db}", null);
        var b = new NpgsqlConnectionStringBuilder(dizge) { Database = _db };
        _veri = new VeriKaynagi(b.ConnectionString);
        Directory.CreateDirectory(Path.Combine(_dizin, "db"));
        Directory.CreateDirectory(Path.Combine(_dizin, "kurulum"));
        // Sunucu uygulayıcısı paket dizininden okur: kurulum listeleri kopyalanır.
        foreach (var f in Directory.GetFiles(Path.Combine(Kok, "db", "kurulum")))
            File.Copy(f, Path.Combine(_dizin, "kurulum", Path.GetFileName(f)));
    }

    public async Task DisposeAsync()
    {
        if (_veri is not null) await _veri.DisposeAsync();
        if (_yonetim is not null)
        {
            NpgsqlConnection.ClearAllPools();
            try { await _yonetim.CalistirAsync($"drop database if exists {_db} with (force)", null); } catch { }
            await _yonetim.DisposeAsync();
        }
        try { Directory.Delete(_dizin, true); } catch { }
    }

    private void Goc(string ad, string sql) =>
        File.WriteAllText(Path.Combine(_dizin, "db", ad), sql.Replace("\r\n", "\n"));

    public static TheoryData<string> Uygulayicilar => new() { "ps", "sh" };

    private async Task<(int Kod, string Cikti)> CalistirAsync(string tur)
    {
        ProcessStartInfo b;
        if (tur == "ps")
        {
            b = new ProcessStartInfo("powershell",
                $"-ExecutionPolicy Bypass -File \"{Path.Combine(Kok, "db", "araclar", "goc_uygula.ps1")}\" " +
                $"-Kap {Kap} -Db {_db} -Dizin \"{Path.Combine(_dizin, "db")}\"");
        }
        else
        {
            var bash = Environment.GetEnvironmentVariable("GENTEGRE_TEST_BASH") is { Length: > 0 } eb ? eb
                : OperatingSystem.IsWindows() ? @"C:\Program Files\Git\bin\bash.exe" : "bash";
            b = new ProcessStartInfo(bash, $"\"{Path.Combine(Kok, "yayin", "goc_uygula.sh").Replace('\\', '/')}\" \"{_dizin.Replace('\\', '/')}\"");
            b.Environment["DB"] = _db;
            b.Environment["PG"] = Kap;
            b.Environment["MSYS_NO_PATHCONV"] = "1";
        }
        b.RedirectStandardOutput = true;
        b.RedirectStandardError = true;
        b.UseShellExecute = false;
        using var p = Process.Start(b)!;
        var cikti = p.StandardOutput.ReadToEndAsync();
        var hata = p.StandardError.ReadToEndAsync();
        await p.WaitForExitAsync();
        return (p.ExitCode, await cikti + await hata);
    }

    private Task<long> SayAsync(string sql) => _veri!.TekDegerAsync<long>(sql, null);

    [VtTheory]
    [MemberData(nameof(Uygulayicilar))]
    public async Task Ortada_patlayan_goc_onceki_ifadeleri_ve_defter_kaydini_geri_alir(string tur)
    {
        Goc("001_tamam.sql", "create table public.t_bir (x int);\n");
        Goc("002_yarim.sql", "create table public.t_iki (x int);\ninsert into public.t_iki values (1);\nselect 1/0;\n");

        var (kod, cikti) = await CalistirAsync(tur);
        Assert.True(kod == 1, cikti);
        Assert.Equal(1L, await SayAsync("select count(*) from pg_tables where tablename = 't_bir'"));
        Assert.Equal(0L, await SayAsync("select count(*) from pg_tables where tablename = 't_iki'"));
        Assert.Equal(1L, await SayAsync("select count(*) from public.goc_gecmisi where yontem is distinct from 'tohum'"));
        Assert.Equal(0L, await SayAsync("select count(*) from public.goc_gecmisi where dosya = '002_yarim.sql'"));
    }

    /// <summary>
    /// TEKRAR DENETİM #2: PL/pgSQL gövdesindeki `end;`, `case … end;` ve
    /// yorumdaki `$$` dosyayı "kendi işlemini yöneten" SANDIRMAMALI. Eski
    /// sınıflandırıcıda bu dosya işlem DIŞINDA çalışıyor, hata sonrası tablo ve
    /// satır kalıyordu (denetimin yeniden ürettiği senaryo).
    /// </summary>
    [VtTheory]
    [MemberData(nameof(Uygulayicilar))]
    public async Task PLpgSQL_govdeli_dosya_ortada_patlarsa_hic_iz_birakmaz(string tur)
    {
        Goc("001_govdeli.sql", """
            -- yorumda $$ ve begin; gecse de ifade degildir
            create table public.__govde_yarim (id integer);
            insert into public.__govde_yarim values (1);
            do $$
            begin
                perform 1;
            end;
            $$;
            create function public.__govde_fn() returns int language plpgsql as $fn$
            begin
                return case when 1 = 1 then 1 else 0
                end;
            end;
            $fn$;
            update public.__govde_yarim set id = case when id = 1 then 2
                                                    else id end;
            select 1 / 0;
            """);

        var (kod, cikti) = await CalistirAsync(tur);
        Assert.True(kod == 1, cikti);
        Assert.DoesNotContain("ISLEM DISI", cikti);
        Assert.Equal(0L, await SayAsync("select count(*) from pg_tables where tablename = '__govde_yarim'"));
        Assert.Equal(0L, await SayAsync("select count(*) from pg_proc where proname = '__govde_fn'"));
        Assert.Equal(0L, await SayAsync("select count(*) from public.goc_gecmisi where yontem is distinct from 'tohum'"));
    }

    /// <summary>Gerçekten kendi işlemini yöneten dosya hâlâ ayrılır (üst düzey BEGIN/COMMIT).</summary>
    [VtTheory]
    [MemberData(nameof(Uygulayicilar))]
    public async Task Ust_duzey_BEGIN_COMMIT_dosyasi_islem_disi_isaretlenir(string tur)
    {
        Goc("001_acik_islem.sql", """
            begin;
            do $$ begin perform 1; end $$;
            create table public.__acik_islem (id integer);
            commit;
            """);
        var (kod, cikti) = await CalistirAsync(tur);
        Assert.True(kod == 0, cikti);
        Assert.Equal("islem_disi", await _veri!.TekDegerAsync<string>(
            "select yontem from public.goc_gecmisi where dosya = '001_acik_islem.sql'", null));
    }

    [VtTheory]
    [MemberData(nameof(Uygulayicilar))]
    public async Task Basari_tek_defter_kaydi_birakir_tekrar_calistirma_ayni_degisikligi_uygulamaz(string tur)
    {
        Goc("001_tablo.sql", "create table public.sayac (x int);\n");
        // Kasten idempotent DEGIL: ikinci kez calisirsa satir sayisi artar.
        Goc("002_ekle.sql", "insert into public.sayac values (1);\n");
        Goc("003_kendi_islemi.sql", "begin;\ninsert into public.sayac values (2);\ncommit;\n");

        Assert.Equal(0, (await CalistirAsync(tur)).Kod);
        var (kod, cikti) = await CalistirAsync(tur);
        Assert.True(kod == 0, cikti);

        Assert.Equal(2L, await SayAsync("select count(*) from public.sayac"));
        Assert.Equal(3L, await SayAsync("select count(*) from public.goc_gecmisi where yontem is distinct from 'tohum'"));
        Assert.Equal("islem_disi", await _veri!.TekDegerAsync<string>(
            "select yontem from public.goc_gecmisi where dosya = '003_kendi_islemi.sql'", null));
        Assert.Equal(64L, await SayAsync(
            "select min(length(ozet)) from public.goc_gecmisi where dosya like '00%'"));
    }

    [VtTheory]
    [MemberData(nameof(Uygulayicilar))]
    public async Task Eszamanli_iki_guncelleyici_ayni_dosyayi_bir_kez_uygular(string tur)
    {
        Goc("001_tablo.sql", "create table public.sayac (x int);\n");
        Goc("002_yavas.sql", "select pg_sleep(3);\ninsert into public.sayac values (1);\n");

        var sonuc = await Task.WhenAll(CalistirAsync(tur), CalistirAsync(tur));
        Assert.All(sonuc, s => Assert.True(s.Kod == 0, s.Cikti));
        Assert.Equal(1L, await SayAsync("select count(*) from public.sayac"));
        Assert.Equal(1L, await SayAsync("select count(*) from public.goc_gecmisi where dosya = '002_yavas.sql'"));
    }

    [VtTheory]
    [MemberData(nameof(Uygulayicilar))]
    public async Task Dis_veri_on_kosulu_2_ile_cikar_ve_kaldigi_yerden_devam_eder(string tur)
    {
        // Liste db/kurulum/dis_veri_onkosullari.txt'den: 521 SKRS ambari ister.
        Goc("001_tablo.sql", "create table public.ambar (x int);\n");
        Goc("521_skrs_katalog_kurulum.sql",
            "do $$ begin if not exists (select 1 from public.ambar) then raise exception 'ambar bos'; end if; end $$;\n");

        var (kod, cikti) = await CalistirAsync(tur);
        Assert.True(kod == 2, cikti);
        Assert.Contains("DIS VERI", cikti);

        await _veri!.CalistirAsync("insert into public.ambar values (1)", null);
        (kod, cikti) = await CalistirAsync(tur);
        Assert.True(kod == 0, cikti);
        Assert.Equal(2L, await SayAsync("select count(*) from public.goc_gecmisi where yontem is distinct from 'tohum'"));
    }
}
