using System.Net;
using System.Net.Sockets;
using System.Xml.Linq;
using Microsoft.Extensions.Options;

namespace Gentegre.Api.Servisler;

/// <summary>
/// Mirth Connect REST bağlantısı (Teletıp panosu). Parola KODDA ve DEPODA durmaz: ortam değişkeni
/// <c>Mirth__Parola</c> (yayin/mirth/gizli/mirth.env → MIRTH_IZLEME_PAROLA). Url boşsa pano Mirth bölümünü "tanımsız" gösterir.
/// </summary>
public sealed class MirthAyarlari
{
    /// <summary>REST kökü, ör. https://localhost:8443/api.</summary>
    public string Url { get; set; } = "";
    /// <summary>Panoya özel Mirth kullanıcısı (mirth-baslat.ps1 açar). Mirth 4.5.2 açık sürümünde rol ayrımı yok - ayrı
    /// kullanıcı, parolası ayrı değiştirilebilsin / kapatılabilsin diye.</summary>
    public string Kullanici { get; set; } = "gentegre_izleme";
    public string Parola { get; set; } = "";
    /// <summary>Mirth kendinden imzalı sertifikayla gelir. false: yalnız <see cref="Url"/> sunucusu için sertifika
    /// doğrulanmaz (yerel ağ). Üretimde kurumun sertifikası kurulup true yapılmalı.</summary>
    public bool SertifikaDogrula { get; set; }
    public int ZamanAsimiSn { get; set; } = 10;
}

/// <summary>Bir Mirth kanalının pano satırı.</summary>
public sealed record MirthKanalDurumu(string Id, string Ad, string Durum, long Alinan, long Suzulen, long Kuyruk,
                                      long Gonderilen, long Hatali);

public sealed record MirthPanoSonucu(bool Tanimli, bool Erisilebilir, string Hata, string Surum, List<MirthKanalDurumu> Kanallar);

/// <summary>
/// MIRTH İZLEME (kullanıcı 11.11.2026: "Mirth panosunu yap"; mockup teletip_mirth.html §2). Oturum çerezi saklanır,
/// 401'de bir kez yeniden giriş yapılır. Kanal istatistikleri <c>GET /channels/statuses</c> (XML) - yalnız okunur,
/// pano kanalı durdurmaz / başlatmaz (Mirth Administrator'ın işi).
/// </summary>
public sealed class MirthIzleme(IOptions<MirthAyarlari> ayar, ILogger<MirthIzleme> gunluk)
{
    private readonly CookieContainer _cerez = new();
    private readonly SemaphoreSlim _kilit = new(1, 1);
    private HttpClient? _http;
    private bool _oturumVar;

    private HttpClient Http()
    {
        if (_http is not null) return _http;
        var a = ayar.Value;
        var isleyici = new HttpClientHandler { CookieContainer = _cerez, UseCookies = true };
        if (!a.SertifikaDogrula && Uri.TryCreate(a.Url, UriKind.Absolute, out var kok))
            // Yalnız yapılandırılmış Mirth sunucusu için - başka bir ana bilgisayara bu istisna uygulanmaz.
            isleyici.ServerCertificateCustomValidationCallback = (istek, _, _, hata) =>
                hata == System.Net.Security.SslPolicyErrors.None
                || string.Equals(istek.RequestUri?.Host, kok.Host, StringComparison.OrdinalIgnoreCase);
        _http = new HttpClient(isleyici) { Timeout = TimeSpan.FromSeconds(Math.Max(3, a.ZamanAsimiSn)) };
        _http.DefaultRequestHeaders.Add("X-Requested-With", "OpenAPI");
        return _http;
    }

    private string Kok => ayar.Value.Url.TrimEnd('/');

    private async Task GirisAsync(CancellationToken iptal)
    {
        var a = ayar.Value;
        using var govde = new FormUrlEncodedContent([new("username", a.Kullanici), new("password", a.Parola)]);
        using var y = await Http().PostAsync($"{Kok}/users/_login", govde, iptal);
        if (!y.IsSuccessStatusCode)
            throw new InvalidOperationException($"Mirth girişi başarısız ({(int)y.StatusCode}) - kullanıcı / parola (Mirth__Parola).");
        _oturumVar = true;
    }

    private async Task<string> GetXmlAsync(string yol, CancellationToken iptal, string kabul = "application/xml")
    {
        await _kilit.WaitAsync(iptal);
        try
        {
            if (!_oturumVar) await GirisAsync(iptal);
            for (var deneme = 0; ; deneme++)
            {
                using var istek = new HttpRequestMessage(HttpMethod.Get, $"{Kok}{yol}");
                istek.Headers.Accept.ParseAdd(kabul);
                using var y = await Http().SendAsync(istek, iptal);
                if (y.StatusCode == HttpStatusCode.Unauthorized && deneme == 0) { await GirisAsync(iptal); continue; }
                y.EnsureSuccessStatusCode();
                return await y.Content.ReadAsStringAsync(iptal);
            }
        }
        finally { _kilit.Release(); }
    }

    /// <summary>Kanal durumları. Mirth tanımsız / erişilemez ise hata metniyle boş liste (pano yine açılır).</summary>
    public async Task<MirthPanoSonucu> DurumAsync(CancellationToken iptal)
    {
        var a = ayar.Value;
        if (string.IsNullOrWhiteSpace(a.Url)) return new(false, false, "Mirth adresi tanımlı değil (Mirth:Url).", "", []);
        if (string.IsNullOrEmpty(a.Parola)) return new(true, false, "Mirth parolası tanımlı değil (ortam değişkeni Mirth__Parola).", "", []);
        try
        {
            var surum = "";
            // /server/version düz metin döner ("4.5.2"); XML istenirse 406.
            try { surum = (await GetXmlAsync("/server/version", iptal, "text/plain")).Trim(); }
            catch { /* sürüm opsiyonel */ }
            var x = XDocument.Parse(await GetXmlAsync("/channels/statuses?includeUndeployed=true", iptal));
            var kanallar = x.Root?.Elements("dashboardStatus").Select(Kanal).OrderBy(k => k.Ad).ToList() ?? [];
            return new(true, true, "", surum, kanallar);
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException or InvalidOperationException or System.Xml.XmlException)
        {
            _oturumVar = false;
            gunluk.LogWarning("Mirth durumu alınamadı: {Hata}", h.Message);
            return new(true, false, h is TaskCanceledException ? "Mirth yanıt vermedi (zaman aşımı)." : h.Message, "", []);
        }
    }

    private static MirthKanalDurumu Kanal(XElement d)
    {
        long S(string ad) => d.Element("statistics")?.Elements("entry")
            .Where(e => e.Elements().FirstOrDefault()?.Value == ad)
            .Select(e => long.TryParse(e.Element("long")?.Value, out var n) ? n : 0).FirstOrDefault() ?? 0;
        return new(d.Element("channelId")?.Value ?? "", d.Element("name")?.Value ?? "", d.Element("state")?.Value ?? "",
                   S("RECEIVED"), S("FILTERED"), long.TryParse(d.Element("queued")?.Value, out var q) ? q : 0,
                   S("SENT"), S("ERROR"));
    }

    /// <summary>Panoda / ayar ekranında gösterilecek bağlantı bilgisi - parola DEĞİL, yalnız tanımlı mı.</summary>
    public (string Url, string Kullanici, bool ParolaTanimli, bool SertifikaDogrula) Ozet() =>
        (ayar.Value.Url, ayar.Value.Kullanici, !string.IsNullOrEmpty(ayar.Value.Parola), ayar.Value.SertifikaDogrula);

    /// <summary>Mirth configuration map'ten "teletip_" ile başlayan anahtarlar (K1 hedefi vb.) - yalnız okunur.
    /// Mirth erişilemezse boş sözlük.</summary>
    public async Task<Dictionary<string, string>> TeletipHaritasiAsync(CancellationToken iptal)
    {
        var sonuc = new Dictionary<string, string>();
        if (string.IsNullOrWhiteSpace(ayar.Value.Url) || string.IsNullOrEmpty(ayar.Value.Parola)) return sonuc;
        try
        {
            var x = XDocument.Parse(await GetXmlAsync("/server/configurationMap", iptal));
            foreach (var e in x.Root?.Elements("entry") ?? [])
            {
                var anahtar = e.Element("string")?.Value ?? "";
                if (anahtar.StartsWith("teletip_", StringComparison.Ordinal))
                    sonuc[anahtar] = e.Descendants("value").FirstOrDefault()?.Value ?? "";
            }
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException or InvalidOperationException or System.Xml.XmlException)
        {
            _oturumVar = false;
            gunluk.LogWarning("Mirth configuration map okunamadı: {Hata}", h.Message);
        }
        return sonuc;
    }

    /// <summary>host:port'a TCP bağlantı denemesi (Teletıp HL7 hedefi = Mirth K1 dinleyicisi).</summary>
    public static async Task<(bool Acik, string Hata, int SureMs)> TcpDeneAsync(string adres, CancellationToken iptal)
    {
        var p = adres.Split(':');
        if (p.Length != 2 || !int.TryParse(p[1], out var port)) return (false, "Adres host:port biçiminde değil.", 0);
        var sw = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            using var c = new TcpClient();
            using var zaman = CancellationTokenSource.CreateLinkedTokenSource(iptal);
            zaman.CancelAfter(TimeSpan.FromSeconds(5));
            await c.ConnectAsync(p[0], port, zaman.Token);
            return (true, "", (int)sw.ElapsedMilliseconds);
        }
        catch (Exception h) { return (false, h is OperationCanceledException ? "Zaman aşımı (5 sn)." : h.Message, (int)sw.ElapsedMilliseconds); }
    }
}
