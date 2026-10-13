using System.Net;
using System.Text;
using System.Text.Json.Nodes;
using Microsoft.Extensions.Logging;

namespace Gentegre.Aktarim.Ajan;

/// <summary>Sunucu reddetti (4xx): tekrar denemek düzeltmez - ajan durur, günlüğe yazar.</summary>
public sealed class SunucuReddi(HttpStatusCode durum, string govde)
    : Exception($"Sunucu {(int)durum} döndü: {(govde.Length > 500 ? govde[..500] : govde)}")
{
    public HttpStatusCode Durum { get; } = durum;
}

/// <summary>
/// /api/aktarim uçları (sözleşme §9.19). Ağ hatası ve 5xx aynı paketle (aynı paket
/// kimliği) üstel beklemeyle yeniden denenir - sunucu tamamlanan kimliği ikinci kez
/// uygulamaz.
/// </summary>
public sealed class ApiIstemci : IDisposable
{
    private readonly HttpClient _h;
    private readonly ILogger _gunluk;

    public ApiIstemci(Ayarlar a, ILogger gunluk)
    {
        _gunluk = gunluk;
        _h = new HttpClient { BaseAddress = new Uri(a.ApiAdres), Timeout = TimeSpan.FromMinutes(15) };
        _h.DefaultRequestHeaders.Add("X-Aktarim-Anahtar", a.GercekAnahtar);
        _h.DefaultRequestHeaders.Add("X-Aktarim-Surum", typeof(ApiIstemci).Assembly.GetName().Version?.ToString(3) ?? "0");
    }

    public async Task<JsonObject> DurumAsync(CancellationToken iptal)
        => await GonderAsync(() => new HttpRequestMessage(HttpMethod.Get, "api/aktarim/durum"), iptal);

    public async Task<JsonObject> UstAsync(JsonObject altlar, CancellationToken iptal)
    {
        var govde = altlar.ToJsonString();
        return await GonderAsync(() => Post("api/aktarim/ust", govde), iptal);
    }

    public async Task<JsonObject> PaketAsync(string govde, CancellationToken iptal)
        => await GonderAsync(() => Post("api/aktarim/paket", govde), iptal);

    private static HttpRequestMessage Post(string yol, string govde)
        => new(HttpMethod.Post, yol) { Content = new StringContent(govde, Encoding.UTF8, "application/json") };

    private async Task<JsonObject> GonderAsync(Func<HttpRequestMessage> istek, CancellationToken iptal)
    {
        var bekle = TimeSpan.FromSeconds(2);
        for (var deneme = 1; ; deneme++)
        {
            try
            {
                using var y = await _h.SendAsync(istek(), iptal);
                var metin = await y.Content.ReadAsStringAsync(iptal);
                if (y.IsSuccessStatusCode)
                    return JsonNode.Parse(metin) as JsonObject ?? [];
                if ((int)y.StatusCode < 500) throw new SunucuReddi(y.StatusCode, metin);
                if (deneme >= 5) throw new HttpRequestException($"Sunucu {(int)y.StatusCode}: {metin}");
                _gunluk.LogWarning("Sunucu {Durum} döndü, {Sn} sn sonra yeniden ({Deneme}/5)", (int)y.StatusCode, bekle.TotalSeconds, deneme);
            }
            catch (Exception e) when (e is HttpRequestException or TaskCanceledException && !iptal.IsCancellationRequested && deneme < 5)
            {
                _gunluk.LogWarning("Sunucuya ulaşılamadı ({Hata}), {Sn} sn sonra yeniden ({Deneme}/5)", e.Message, bekle.TotalSeconds, deneme);
            }
            await Task.Delay(bekle, iptal);
            bekle *= 2;
        }
    }

    public void Dispose() => _h.Dispose();
}
