using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GARANTİ BBVA OAuth jetonu (client_credentials) - hareket çekimi (BankaHareketServisi) ve entegrasyon
/// sınaması (EntegrasyonUclari) aynı çağrıyı kullanır.
/// <para><b>Scope</b> uygulamaya göre değişir (kullanıcı 27.10.2026, FETA: <c>scope=oob</c> ile
/// "invalid_scope - No registered scope value for this client has been requested"): önce entegrasyon
/// satırının ayarlarındaki <c>scope</c> (boşsa <c>oob</c>), banka invalid_scope derse scope'suz yeniden
/// istenir - sunucu o zaman uygulamanın kayıtlı scope'larını verir.</para>
/// </summary>
public static class GarantiJeton
{
    /// <summary>Jeton (yoksa null), son HTTP kodu, son yanıt gövdesi ve jetonu veren scope ("" = scope gönderilmedi).</summary>
    /// <remarks><paramref name="scope"/> null: önce <c>oob</c>, olmazsa scope'suz; "": yalnız scope'suz; dolu: önce o,
    /// olmazsa scope'suz. Dönen <see cref="Sonuc.Scope"/> sonraki çağrıya verilirse deneme tekrarlanmaz.</remarks>
    public sealed record Sonuc(string? Jeton, int Kod, string Govde, string Scope);

    public static async Task<Sonuc> AlAsync(HttpClient istemci, string kok, string clientId, string secret, string? scope,
                                            CancellationToken iptal)
    {
        clientId = clientId.Trim(); secret = secret.Trim();
        var adaylar = (scope == null ? ["oob", ""] : new[] { scope.Trim(), "" }).Distinct();
        Sonuc son = new(null, 0, "", "");
        foreach (var s in adaylar)
        {
            using var istek = new HttpRequestMessage(HttpMethod.Post, kok.TrimEnd('/') + "/auth/oauth/v2/token");
            istek.Headers.Authorization = new AuthenticationHeaderValue("Basic",
                Convert.ToBase64String(Encoding.UTF8.GetBytes($"{clientId}:{secret}")));
            var form = new Dictionary<string, string>
            {
                ["grant_type"] = "client_credentials", ["client_id"] = clientId, ["client_secret"] = secret,
            };
            if (s != "") { form["scope"] = s; form["redirect_uri"] = "oob"; }
            istek.Content = new FormUrlEncodedContent(form);
            using var yanit = await istemci.SendAsync(istek, iptal);
            var govde = await yanit.Content.ReadAsStringAsync(iptal);
            string? jeton = null;
            if (yanit.IsSuccessStatusCode)
                try
                {
                    using var j = JsonDocument.Parse(govde);
                    if (j.RootElement.TryGetProperty("access_token", out var a)) jeton = a.GetString();
                }
                catch (JsonException) { }
            son = new Sonuc(string.IsNullOrEmpty(jeton) ? null : jeton, (int)yanit.StatusCode, govde, s);
            if (son.Jeton != null || !govde.Contains("invalid_scope")) break;
        }
        return son;
    }
}
