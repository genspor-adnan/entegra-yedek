using System.Diagnostics;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Net.Sockets;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// GERÇEK API SÜRECİ + İZOLE TEST VERİTABANI (denetim 28.09.2026).
///
/// <para>Güvenlik kararları (şube kapısı, oturum kapısı, yazma aksiyonu, kayıt
/// kapsamı, refresh atomikliği) uç, ara katman ve veritabanının BİRLİKTE
/// verdiği kararlardır; tek sınıfı çağırmak "istek gerçekten reddediliyor mu"
/// sorusunu cevaplamaz. Bu olgu derlenmiş <c>Gentegre.Api.dll</c>'i ayrı bir
/// süreçte, <c>GENTEGRE_TEST_DB</c>'ye bağlı ve <b>arka plan işçileri
/// kapalı</b> (<c>ArkaPlan:Kapali</c> - SMS/e-posta/cihaz dinleyicisi yok)
/// başlatır; testler gerçek HTTP isteği atar.</para>
///
/// <para>Sunucu 127.0.0.1'de dinler. Loopback güvenilen proxy sayıldığı için
/// testler anonim parola denemelerinde benzersiz <c>X-Forwarded-For</c>
/// adresi gönderir: IP sınırı testleri birbirinin sayacını doldurmaz.</para>
/// </summary>
public sealed class ApiSunucuOlgusu : IAsyncLifetime
{
    private Process? _surec;
    private readonly System.Text.StringBuilder _cikti = new();

    public VeriKaynagi Veri { get; private set; } = default!;
    public Uri Taban { get; private set; } = default!;
    public bool Hazir { get; private set; }

    public async Task InitializeAsync()
    {
        // Değişken yoksa testler zaten [VtFact] ile ATLANMIŞTIR; zorunlu kipte hata.
        if (TestVeritabani.Dizge is not { } dizge)
        {
            if (TestVeritabani.Zorunlu)
                throw new InvalidOperationException("GENTEGRE_TEST_ZORUNLU=1 ama GENTEGRE_TEST_DB tanımlı değil.");
            return;
        }

        Veri = new VeriKaynagi(dizge);
        var ad = await Veri.TekDegerAsync<string>("select current_database()", null) ?? "";
        if (!ad.Contains("test", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException($"GENTEGRE_TEST_DB test veritabanı değil: {ad}");

        var port = BosPort();
        Taban = new Uri($"http://127.0.0.1:{port}");
        // GENTEGRE_TEST_API_DLL: ayni testleri BASKA bir derlemeye karsi
        //   kosturmak icin (or. duzeltme oncesi surum - testlerin eski acigi
        //   gercekten yakaladigini gostermek). Verilmezse bu derlemenin API'si.
        var dll = Environment.GetEnvironmentVariable("GENTEGRE_TEST_API_DLL") is { Length: > 0 } baska
            ? baska : Path.Combine(AppContext.BaseDirectory, "Gentegre.Api.dll");
        var bilgi = new ProcessStartInfo("dotnet", $"\"{dll}\" --urls {Taban}")
        {
            WorkingDirectory = Path.GetDirectoryName(dll)!,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
        };
        bilgi.Environment["ConnectionStrings__Gentegre"] = dizge;
        bilgi.Environment["ArkaPlan__Kapali"] = "true";
        bilgi.Environment["Ai__Aktif"] = "false";
        bilgi.Environment["ASPNETCORE_ENVIRONMENT"] = "Test";
        bilgi.Environment["Guvenlik__ImzaAnahtari"] = "butunlesme-testi-imza-anahtari-en-az-32-karakter-uzun";

        _surec = Process.Start(bilgi) ?? throw new InvalidOperationException("API süreci başlatılamadı.");
        _surec.OutputDataReceived += (_, e) => { lock (_cikti) _cikti.AppendLine(e.Data); };
        _surec.ErrorDataReceived += (_, e) => { lock (_cikti) _cikti.AppendLine(e.Data); };
        _surec.BeginOutputReadLine();
        _surec.BeginErrorReadLine();

        using var http = new HttpClient { BaseAddress = Taban, Timeout = TimeSpan.FromSeconds(5) };
        var bitis = DateTime.UtcNow.AddSeconds(90);
        while (DateTime.UtcNow < bitis)
        {
            if (_surec.HasExited)
                throw new InvalidOperationException("API süreci kapandı:\n" + Cikti());
            try
            {
                var y = await http.GetAsync("/api/saglik");
                if (y.IsSuccessStatusCode) { Hazir = true; return; }
            }
            catch (HttpRequestException) { }
            catch (TaskCanceledException) { }
            await Task.Delay(500);
        }
        throw new TimeoutException("API 90 sn'de ayağa kalkmadı:\n" + Cikti());
    }

    public Task DisposeAsync()
    {
        try { if (_surec is { HasExited: false }) _surec.Kill(entireProcessTree: true); }
        catch { /* zaten kapandı */ }
        _surec?.Dispose();
        return Task.CompletedTask;
    }

    public string Cikti() { lock (_cikti) return _cikti.ToString(); }

    public HttpClient Istemci(string? access = null, int? subeId = null, string? ip = null)
    {
        var h = new HttpClient { BaseAddress = Taban, Timeout = TimeSpan.FromSeconds(60) };
        if (access is not null) h.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", access);
        if (subeId is not null) h.DefaultRequestHeaders.Add("X-Sube-Id", subeId.Value.ToString());
        if (ip is not null) h.DefaultRequestHeaders.Add("X-Forwarded-For", ip);
        return h;
    }

    /// <summary>Giriş: (access, refresh). Başarısızsa durum koduyla hata.</summary>
    public async Task<(string Access, string Refresh)> GirisAsync(string kod, string parola, int? subeId = null)
    {
        using var h = Istemci();
        var y = await h.PostAsJsonAsync("/api/kimlik/giris", new { kod, parola, subeId });
        Assert.True(y.IsSuccessStatusCode, $"giriş {(int)y.StatusCode}: {await y.Content.ReadAsStringAsync()}");
        var j = await y.Content.ReadFromJsonAsync<JsonElement>();
        return (j.GetProperty("accessToken").GetString()!, j.GetProperty("refreshToken").GetString()!);
    }

    public static async Task<string> HataKoduAsync(HttpResponseMessage y)
    {
        try
        {
            var j = await y.Content.ReadFromJsonAsync<JsonElement>();
            return j.TryGetProperty("hata", out var h) ? h.GetProperty("kod").GetString() ?? "" : "";
        }
        catch { return ""; }
    }

    private static int BosPort()
    {
        var l = new TcpListener(IPAddress.Loopback, 0);
        l.Start();
        var p = ((IPEndPoint)l.LocalEndpoint).Port;
        l.Stop();
        return p;
    }
}

[CollectionDefinition(Ad)]
public sealed class ApiKoleksiyonu : ICollectionFixture<ApiSunucuOlgusu>
{
    public const string Ad = "Api süreci";
}

/// <summary>
/// TEST DÜNYASI YARDIMCISI: kendi rolünü, kullanıcısını ve şube bağını açar,
/// <see cref="DisposeAsync"/>'de hepsini siler. Her test benzersiz önekle
/// çalışır; paylaşılan satırlara dokunmaz.
/// </summary>
public sealed class TestDunyasi(VeriKaynagi veri) : IAsyncDisposable
{
    public const string Parola = "Test.Parola.2026!";
    private static readonly string ParolaHash = BCrypt.Net.BCrypt.HashPassword(Parola, workFactor: 4);

    private readonly List<int> _roller = [];
    private readonly List<int> _taraflar = [];
    private readonly List<int> _subeler = [];
    private readonly List<string> _temizlik = [];
    public string Onek { get; } = "tz" + Guid.NewGuid().ToString("N")[..8];

    /// <summary>Aktif olmayan, yalnız "çalıştığı şube" olarak kullanılacak şube.</summary>
    public async Task<int> PasifSubeAsync()
    {
        var id = await veri.TekDegerAsync<int>(
            "insert into public.sube (id, ad, aktif) " +
            "select coalesce(max(id), 0) + 1, @p0, 0 from public.sube returning id", [Onek + " pasif"]);
        _subeler.Add(id);
        return id;
    }

    /// <summary>Rol + yetkiler. Kaynak yetkisi (tür 0) "kod:gedk", aksiyon (tür 1) yalnız kod.</summary>
    public async Task<int> RolAsync(string ad, params string[] yetkiler)
    {
        var id = await veri.TekDegerAsync<int>(
            "insert into public.rol (kod, ad) values (@p0, @p1) returning id",
            [(Onek + "_" + ad).ToLowerInvariant(), Onek + " " + ad]);
        _roller.Add(id);
        foreach (var y in yetkiler)
        {
            var (kod, islem) = y.Contains(':') ? (y[..y.IndexOf(':')], y[(y.IndexOf(':') + 1)..]) : (y, "g");
            var eklenen = await veri.CalistirAsync("""
                insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
                select @p0, y.id, 1, @p2, @p3, @p4 from public.yetki y where y.kod = @p1
                """, [id, kod, (short)(islem.Contains('e') ? 1 : 0),
                      (short)(islem.Contains('d') ? 1 : 0), (short)(islem.Contains('k') ? 1 : 0)]);
            Assert.True(eklenen == 1, $"yetki bulunamadı: {kod}");
        }
        return id;
    }

    /// <summary>Kullanıcı: taraf + hesap. <paramref name="calistigiSube"/> = taraf.sube_id.</summary>
    public async Task<(int Id, string Kod)> KullaniciAsync(int rolId, int calistigiSube,
        string? parolaHash = null, bool parolaDegismeli = false, string vkno = "", string cepTel = "",
        bool hasta = false)
    {
        var kod = (Onek + _taraflar.Count).ToLowerInvariant();
        var id = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, personel, hasta, sube_id, vkno, cep_tel)
            values (@p0, @p1, @p2, @p3, @p4, @p5) returning id
            """, [kod, (short)(hasta ? 0 : 1), (short)(hasta ? 1 : 0), calistigiSube, vkno, cepTel]);
        _taraflar.Add(id);
        await veri.CalistirAsync("""
            insert into public.taraf_kullanici (id, kod, parola_hash, parola_degismeli, rol_id)
            values (@p0, @p1, @p2, @p3, @p4)
            """, [id, kod, parolaHash ?? ParolaHash, (short)(parolaDegismeli ? 1 : 0), rolId]);
        return (id, kod);
    }

    public Task SubeVerAsync(int kullaniciId, int subeId, bool yazma, bool varsayilan = false)
        => veri.CalistirAsync("""
            insert into public.kullanici_sube (taraf_id, sube_id, yazma, varsayilan)
            values (@p0, @p1, @p2, @p3)
            on conflict (taraf_id, sube_id) do update set yazma = excluded.yazma
            """, [kullaniciId, subeId, (short)(yazma ? 1 : 0), (short)(varsayilan ? 1 : 0)]);

    public Task<int> SubeAlAsync(int kullaniciId, int subeId)
        => veri.CalistirAsync("delete from public.kullanici_sube where taraf_id = @p0 and sube_id = @p1",
                              [kullaniciId, subeId]);

    /// <summary>Test sonunda çalışacak ek temizlik SQL'i (parametresiz).</summary>
    public void Temizle(string sql) => _temizlik.Add(sql);

    public async ValueTask DisposeAsync()
    {
        foreach (var sql in Enumerable.Reverse(_temizlik))
            try { await veri.CalistirAsync(sql, null); } catch { /* en iyi çaba */ }
        foreach (var t in _taraflar)
        {
            foreach (var sql in new[]
            {
                "delete from public.parola_sifirlama where kullanici_id = @p0",
                "delete from public.bildirim where kullanici_id = @p0 or taraf_id = @p0",
                "delete from public.oturum where kullanici_id = @p0",
                "delete from public.kullanici_rol where kullanici_id = @p0",
                "delete from public.kullanici_sube where taraf_id = @p0",
                "delete from public.taraf_kullanici where id = @p0",
                "delete from public.taraf where id = @p0",
            })
                try { await veri.CalistirAsync(sql, [t]); } catch { /* bağlı satır: bırak */ }
        }
        foreach (var r in _roller)
            foreach (var sql in new[]
            {
                "delete from public.lab_tetkik_kisit where rol_id = @p0",
                "delete from public.rol_yetki where rol_id = @p0",
                "delete from public.rol_sube where rol_id = @p0",
                "delete from public.rol where id = @p0",
            })
                try { await veri.CalistirAsync(sql, [r]); } catch { }
        foreach (var s in _subeler)
            try { await veri.CalistirAsync("delete from public.sube where id = @p0", [s]); } catch { }
    }
}
