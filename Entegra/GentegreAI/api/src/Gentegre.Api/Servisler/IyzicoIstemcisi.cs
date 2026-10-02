using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace Gentegre.Api.Servisler;

/// <summary>
/// iyzico ayarları (<c>Odeme:Iyzico</c>). ANAHTARLAR BURAYA YAZILMAZ:
/// <c>IYZICO_API_KEY</c> / <c>IYZICO_SECRET_KEY</c> ortam değişkenleri ya da
/// <c>gizli/iyzico-anahtar.txt</c> (1. satır API anahtarı, 2. satır gizli
/// anahtar; git dışı).
/// </summary>
public sealed class IyzicoSecenekleri
{
    /// <summary>Sandbox: https://sandbox-api.iyzipay.com · Canlı: https://api.iyzipay.com</summary>
    public string Adres { get; set; } = "https://sandbox-api.iyzipay.com";

    /// <summary>iyzico'nun tarayıcıyı POST ile döndüreceği API adresi (…/api/ai/kontor/iyzico/donus).</summary>
    public string GeriCagriAdresi { get; set; } = "http://localhost:5180/api/ai/kontor/iyzico/donus";

    /// <summary>Ödeme sonrası kullanıcının döneceği ekran (sipariş no sorguya eklenir).</summary>
    public string EkranAdresi { get; set; } = "http://localhost:5173/yz-kontor";

    public int ZamanAsimiSn { get; set; } = 30;
    public string AnahtarDosyasi { get; set; } = "";
}

/// <summary>Ödeme formu başlatma sonucu.</summary>
public sealed record IyzicoBaslatma(bool Basarili, string Token, string OdemeSayfasi, string Hata);

/// <summary>Ödeme sorgu sonucu (sunucudan sunucuya, tarayıcıya güvenilmez).</summary>
public sealed record IyzicoSorgu(bool Basarili, string OdemeDurumu, string OdemeNo, decimal OdenenTutar,
                                 string SepetNo, string KonusmaNo, string KartSon4, string KartMarka,
                                 int FraudDurumu, string Hata);

/// <summary>
/// iyzico ÖDEME FORMU (Checkout Form) istemcisi - SDK yok, iki uç:
/// <c>/payment/iyzipos/checkoutform/initialize/auth/ecom</c> (form başlat) ve
/// <c>/payment/iyzipos/checkoutform/auth/ecom/detail</c> (sonucu sorgula).
///
/// <b>Kimlik doğrulama IYZWSv2:</b> rastgele anahtar + URI yolu + istek gövdesi
/// gizli anahtarla HMAC-SHA256; "apiKey:..&amp;randomKey:..&amp;signature:.."
/// base64 → <c>Authorization: IYZWSv2 …</c>. İmza, GÖNDERİLEN gövdenin aynısı
/// üzerinden alınır - gövde bir kez serileştirilir.
///
/// Kart verisi bu sınıftan geçmez: kart iyzico'nun sayfasında girilir.
/// </summary>
public sealed class IyzicoIstemcisi
{
    private readonly IHttpClientFactory _http;
    private readonly IyzicoSecenekleri _ayar;
    private readonly ILogger<IyzicoIstemcisi> _gunluk;
    private readonly string _apiAnahtar;
    private readonly string _gizliAnahtar;

    public IyzicoIstemcisi(IHttpClientFactory http, IyzicoSecenekleri ayar, IHostEnvironment ortam,
                           ILogger<IyzicoIstemcisi> gunluk)
    {
        _http = http;
        _ayar = ayar;
        _gunluk = gunluk;
        (_apiAnahtar, _gizliAnahtar) = AnahtarBul(ayar, ortam.ContentRootPath);
    }

    public bool Hazir => _apiAnahtar.Length > 0 && _gizliAnahtar.Length > 0;
    public IyzicoSecenekleri Ayar => _ayar;

    private static (string, string) AnahtarBul(IyzicoSecenekleri ayar, string kok)
    {
        var a = Environment.GetEnvironmentVariable("IYZICO_API_KEY")?.Trim() ?? "";
        var g = Environment.GetEnvironmentVariable("IYZICO_SECRET_KEY")?.Trim() ?? "";
        if (a.Length > 0 && g.Length > 0) return (a, g);
        var yol = string.IsNullOrWhiteSpace(ayar.AnahtarDosyasi)
            ? Path.Combine(kok, "gizli", "iyzico-anahtar.txt") : ayar.AnahtarDosyasi;
        try
        {
            if (File.Exists(yol))
            {
                var s = File.ReadAllLines(yol).Select(x => x.Trim()).Where(x => x.Length > 0).ToArray();
                if (s.Length >= 2) return (s[0], s[1]);
            }
        }
        catch (IOException) { /* okunamayan dosya = anahtar yok */ }
        return ("", "");
    }

    /// <summary>
    /// IYZWSv2 yetki başlığı değeri. Saf fonksiyon (test edilebilir):
    /// imza = hex(HMACSHA256(gizli, rastgele + uriYolu + govde)).
    /// </summary>
    public static string YetkiBasligi(string apiAnahtar, string gizliAnahtar, string rastgele, string uriYolu, string govde)
    {
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(gizliAnahtar));
        var imza = Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes(rastgele + uriYolu + govde))).ToLowerInvariant();
        var ham = $"apiKey:{apiAnahtar}&randomKey:{rastgele}&signature:{imza}";
        return "IYZWSv2 " + Convert.ToBase64String(Encoding.UTF8.GetBytes(ham));
    }

    /// <summary>iyzico tutar biçimi: nokta ondalık, gereksiz sıfırsız ("2988.0" / "2988.8").</summary>
    public static string Tutar(decimal t)
    {
        var s = t.ToString("0.0#", CultureInfo.InvariantCulture);
        return s;
    }

    private async Task<JsonNode?> GonderAsync(string uriYolu, JsonObject govdeNesnesi, CancellationToken iptal)
    {
        var govde = govdeNesnesi.ToJsonString();
        var rastgele = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString(CultureInfo.InvariantCulture)
                       + RandomNumberGenerator.GetInt32(100000, 999999).ToString(CultureInfo.InvariantCulture);
        var istemci = _http.CreateClient("odeme");
        istemci.Timeout = TimeSpan.FromSeconds(_ayar.ZamanAsimiSn);
        using var mesaj = new HttpRequestMessage(HttpMethod.Post, _ayar.Adres.TrimEnd('/') + uriYolu)
        {
            Content = new StringContent(govde, Encoding.UTF8, "application/json"),
        };
        mesaj.Headers.TryAddWithoutValidation("Authorization", YetkiBasligi(_apiAnahtar, _gizliAnahtar, rastgele, uriYolu, govde));
        mesaj.Headers.TryAddWithoutValidation("x-iyzi-rnd", rastgele);
        mesaj.Headers.TryAddWithoutValidation("x-iyzi-client-version", "gentegre-ai-1.0");
        using var yanit = await istemci.SendAsync(mesaj, iptal);
        var metin = await yanit.Content.ReadAsStringAsync(iptal);
        try { return JsonNode.Parse(metin); }
        catch (JsonException)
        {
            _gunluk.LogWarning("iyzico yanıtı JSON değil ({Kod}): {Ozet}", (int)yanit.StatusCode, metin.Length > 200 ? metin[..200] : metin);
            return null;
        }
    }

    private static string S(JsonNode? n, string ad) => n?[ad]?.ToString() ?? "";

    /// <summary>Alıcı / adres bilgisi (iyzico zorunlu alanları). Kart YOK.</summary>
    public sealed record Alici(string Id, string Ad, string Soyad, string KimlikNo, string Eposta, string Adres,
                               string Il, string Ip, string FaturaUnvani);

    /// <summary>
    /// ÖDEME FORMUNU BAŞLATIR. <paramref name="siparisId"/> iyzico'da
    /// conversationId ve sepet no olur; dönüşte ikisi de eşleşmeli.
    /// Tutar KDV DAHİL gönderilir (iyzico KDV ayrımı yapmaz).
    /// </summary>
    public async Task<IyzicoBaslatma> BaslatAsync(long siparisId, decimal toplam, string urunAdi, Alici alici,
        int[] taksitler, CancellationToken iptal)
    {
        if (!Hazir) return new(false, "", "", "iyzico anahtarları tanımlı değil.");
        var tutar = Tutar(toplam);
        var adres = new JsonObject
        {
            ["contactName"] = alici.FaturaUnvani, ["city"] = alici.Il, ["country"] = "Turkey", ["address"] = alici.Adres,
        };
        var govde = new JsonObject
        {
            ["locale"] = "tr",
            ["conversationId"] = siparisId.ToString(CultureInfo.InvariantCulture),
            ["price"] = tutar,
            ["paidPrice"] = tutar,
            ["currency"] = "TRY",
            ["basketId"] = "GYZ-" + siparisId.ToString(CultureInfo.InvariantCulture),
            ["paymentGroup"] = "PRODUCT",
            ["callbackUrl"] = _ayar.GeriCagriAdresi,
            ["enabledInstallments"] = new JsonArray(taksitler.Select(t => (JsonNode)JsonValue.Create(t)!).ToArray()),
            ["buyer"] = new JsonObject
            {
                ["id"] = alici.Id, ["name"] = alici.Ad, ["surname"] = alici.Soyad,
                ["identityNumber"] = alici.KimlikNo, ["email"] = alici.Eposta,
                ["registrationAddress"] = alici.Adres, ["city"] = alici.Il, ["country"] = "Turkey", ["ip"] = alici.Ip,
            },
            ["shippingAddress"] = adres.DeepClone(),
            ["billingAddress"] = adres,
            ["basketItems"] = new JsonArray(new JsonObject
            {
                ["id"] = "GYZ-" + siparisId.ToString(CultureInfo.InvariantCulture),
                ["name"] = urunAdi, ["category1"] = "Yazılım", ["category2"] = "YZ Kontör",
                ["itemType"] = "VIRTUAL", ["price"] = tutar,
            }),
        };
        try
        {
            var y = await GonderAsync("/payment/iyzipos/checkoutform/initialize/auth/ecom", govde, iptal);
            if (S(y, "status") != "success")
                return new(false, "", "", S(y, "errorMessage") is { Length: > 0 } h ? h : "iyzico ödeme formu açılamadı.");
            return new(true, S(y, "token"), S(y, "paymentPageUrl"), "");
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException)
        {
            _gunluk.LogWarning(h, "iyzico başlatma çağrısı yapılamadı");
            return new(false, "", "", "iyzico'ya ulaşılamadı; tekrar deneyin.");
        }
    }

    /// <summary>Ödeme sonucunu iyzico'ya SORAR (tarayıcıdan gelen bilgiye güvenilmez).</summary>
    public async Task<IyzicoSorgu> SorgulaAsync(string token, string konusmaNo, CancellationToken iptal)
    {
        if (!Hazir) return new(false, "", "", 0, "", "", "", "", 0, "iyzico anahtarları tanımlı değil.");
        var govde = new JsonObject { ["locale"] = "tr", ["conversationId"] = konusmaNo, ["token"] = token };
        try
        {
            var y = await GonderAsync("/payment/iyzipos/checkoutform/auth/ecom/detail", govde, iptal);
            var ok = S(y, "status") == "success";
            _ = decimal.TryParse(S(y, "paidPrice"), NumberStyles.Number, CultureInfo.InvariantCulture, out var odenen);
            _ = int.TryParse(S(y, "fraudStatus"), out var fraud);
            return new(ok, S(y, "paymentStatus"), S(y, "paymentId"), odenen, S(y, "basketId"), S(y, "conversationId"),
                       S(y, "lastFourDigits"), S(y, "cardAssociation"), fraud,
                       S(y, "errorMessage"));
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException)
        {
            _gunluk.LogWarning(h, "iyzico sorgu çağrısı yapılamadı");
            return new(false, "", "", 0, "", "", "", "", 0, "iyzico'ya ulaşılamadı.");
        }
    }

    /// <summary>
    /// Sorgu sonucu SİPARİŞLE tutarlı ve ödenmiş mi? Saf karar (test edilebilir):
    /// durum success + paymentStatus SUCCESS + fraud onaylı (1) + sepet/konuşma
    /// no sipariş + ödenen tutar sipariş toplamı (kuruş toleransı).
    /// </summary>
    public static (bool Odendi, string Sebep) Dogrula(IyzicoSorgu s, long siparisId, decimal toplam)
    {
        var no = siparisId.ToString(CultureInfo.InvariantCulture);
        if (!s.Basarili) return (false, s.Hata.Length > 0 ? s.Hata : "iyzico sorgusu başarısız.");
        if (!string.Equals(s.OdemeDurumu, "SUCCESS", StringComparison.OrdinalIgnoreCase))
            return (false, s.Hata.Length > 0 ? s.Hata : "Ödeme tamamlanmadı.");
        if (s.KonusmaNo != no || s.SepetNo != "GYZ-" + no) return (false, "Ödeme bu siparişe ait değil.");
        if (Math.Abs(s.OdenenTutar - toplam) > 0.01m) return (false, "Ödenen tutar sipariş tutarıyla uyuşmuyor.");
        if (s.FraudDurumu != 1) return (false, "Ödeme iyzico risk incelemesinde; onaylanınca yüklenecek.");
        return (true, "");
    }
}
