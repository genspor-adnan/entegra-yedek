using System.Text;
using System.Text.Json;

namespace Gentegre.Api.Servisler;

/// <summary>
/// DİL MODELİ AYARLARI (`Ai` bölümü).
///
/// <b>API anahtarı depoya ve müşteri veritabanına GİRMEZ.</b> Anahtar
/// satıcının (bizim) hesabımızdır; müşteri kontör öder. Bu yüzden anahtar
/// yalnız çalıştığı sunucudan okunur - önce <c>ANTHROPIC_API_KEY</c> ortam
/// değişkeni, sonra <c>Ai:ApiAnahtar</c>, en son dosya (<see cref="AnahtarDosyasi"/>).
/// Dosya seçeneği konteyneri yeniden kurmadan anahtar vermeyi sağlar;
/// yayın betiği <c>api/</c> klasörünü değiştirir, <c>gizli/</c> dokunulmadan
/// kalır.
///
/// <b>Anahtar yoksa asistan kapanmaz</b>: katalog rehberi (Faz 1-3) aynen
/// çalışır, yalnız serbest metin cevabı üretilmez.
/// </summary>
public sealed class ModelSecenekleri
{
    /// <summary>Kurumsal kapatma anahtarı (ayarla kapatılabilsin).</summary>
    public bool Aktif { get; set; } = true;

    /// <summary>
    /// Rehber için Haiku yeter: cevap kısa, bağlam katalogdan hazır geliyor -
    /// pahalı model burada doğruluk değil yalnız üslup katardı.
    /// </summary>
    public string Model { get; set; } = "claude-haiku-4-5-20251001";

    public string Uc { get; set; } = "https://api.anthropic.com/v1/messages";
    public string Surum { get; set; } = "2023-06-01";

    /// <summary>Cevap kısa olacak: "uzun makale değil, adım adım kısa rehber".</summary>
    public int AzamiCikisJeton { get; set; } = 700;

    /// <summary>Rehberde yaratıcılık istemiyoruz; kararlı cevap iyidir.</summary>
    public decimal Sicaklik { get; set; } = 0.2m;

    public int ZamanAsimiSn { get; set; } = 20;

    /// <summary>Config'ten anahtar (geliştirme kolaylığı; üretimde ortam/dosya).</summary>
    public string ApiAnahtar { get; set; } = "";

    /// <summary>
    /// Anahtar dosyası. Boşsa içerik kökünün altında ve bir üstünde
    /// <c>gizli/ai-anahtar.txt</c> aranır.
    /// </summary>
    public string AnahtarDosyasi { get; set; } = "";
}

/// <summary>Modele gidecek istek: sistem yönergesi + kullanıcı bağlamı.</summary>
public sealed record ModelIstegi(string Sistem, string Kullanici);

/// <summary>Modelden dönen ham metin ve jeton sayaçları (kontör için).</summary>
public sealed record ModelYaniti(string Metin, int GirisJeton, int CikisJeton, string Model);

/// <summary>
/// Dil modeli sağlayıcısı. Arayüz test için değil <b>gerçek</b> bir sınır:
/// rehber servisi modele değil bu sözleşmeye bağlıdır, sağlayıcı değişse de
/// (başka model, kendi sunucumuz) yetki/kontör/doğrulama katmanı aynı kalır.
/// </summary>
public interface IModelSaglayici
{
    /// <summary>Anahtar var ve ayar açık mı?</summary>
    bool Hazir { get; }

    /// <summary>Kullanılan model adı (günlüğe yazılır).</summary>
    string Ad { get; }

    /// <summary>Cevap üretir; sağlayıcı hata verirse <c>null</c> döner.</summary>
    Task<ModelYaniti?> IsteAsync(ModelIstegi istek, CancellationToken iptal);
}

/// <summary>
/// ANTHROPIC MESSAGES API adapteri (Haiku).
///
/// <b>Modele giden bağlam güvenli metadata'dır</b>: ekran/konu/aksiyon
/// kataloğu ve kullanıcının çözülmüş yetkileri. Hasta, cari, belge verisi bu
/// katmana hiç girmez - bkz. <see cref="RehberModeli"/>.
///
/// Hata durumunda <c>null</c> döner ve <b>kontör düşülmez</b>: ödemediğimiz
/// bir çağrı için müşteriden kontör almak savunulamaz.
/// </summary>
public sealed class AnthropicSaglayici : IModelSaglayici
{
    private readonly IHttpClientFactory _http;
    private readonly ModelSecenekleri _ayar;
    private readonly ILogger<AnthropicSaglayici> _gunluk;
    private readonly string _anahtar;

    public AnthropicSaglayici(IHttpClientFactory http, ModelSecenekleri ayar,
                              IHostEnvironment ortam, ILogger<AnthropicSaglayici> gunluk)
    {
        _http = http;
        _ayar = ayar;
        _gunluk = gunluk;
        _anahtar = AnahtarBul(ayar, ortam.ContentRootPath);
        if (_anahtar.Length == 0)
            gunluk.LogInformation("AI: model anahtarı yok - katalog rehberi çalışıyor, "
                                + "serbest metin cevabı üretilmeyecek.");
    }

    public bool Hazir => _ayar.Aktif && _anahtar.Length > 0;
    public string Ad => _ayar.Model;

    /// <summary>
    /// Anahtar sırası: ortam değişkeni → config → dosya. Ortam değişkeni
    /// başta çünkü sunucuda anahtar oraya konur; config yalnız geliştirme
    /// kolaylığı, dosya ise konteyneri yeniden kurmadan anahtar vermek için.
    /// </summary>
    private static string AnahtarBul(ModelSecenekleri ayar, string icerikKok)
    {
        var ortam = Environment.GetEnvironmentVariable("ANTHROPIC_API_KEY");
        if (!string.IsNullOrWhiteSpace(ortam)) return ortam.Trim();
        if (!string.IsNullOrWhiteSpace(ayar.ApiAnahtar)) return ayar.ApiAnahtar.Trim();

        var adaylar = string.IsNullOrWhiteSpace(ayar.AnahtarDosyasi)
            ? new[]
              {
                  Path.Combine(icerikKok, "gizli", "ai-anahtar.txt"),
                  Path.Combine(icerikKok, "..", "gizli", "ai-anahtar.txt"),
              }
            : [ayar.AnahtarDosyasi];
        foreach (var yol in adaylar)
        {
            try
            {
                if (File.Exists(yol)) return File.ReadAllText(yol).Trim();
            }
            catch (IOException) { /* okunamayan dosya = anahtar yok */ }
        }
        return "";
    }

    public async Task<ModelYaniti?> IsteAsync(ModelIstegi istek, CancellationToken iptal)
    {
        if (!Hazir) return null;

        var govde = JsonSerializer.Serialize(new
        {
            model = _ayar.Model,
            max_tokens = _ayar.AzamiCikisJeton,
            temperature = (double)_ayar.Sicaklik,
            system = istek.Sistem,
            messages = new[] { new { role = "user", content = istek.Kullanici } },
        });

        try
        {
            var istemci = _http.CreateClient("ai");
            istemci.Timeout = TimeSpan.FromSeconds(_ayar.ZamanAsimiSn);

            using var mesaj = new HttpRequestMessage(HttpMethod.Post, _ayar.Uc)
            {
                Content = new StringContent(govde, Encoding.UTF8, "application/json"),
            };
            mesaj.Headers.Add("x-api-key", _anahtar);
            mesaj.Headers.Add("anthropic-version", _ayar.Surum);

            using var yanit = await istemci.SendAsync(mesaj, iptal);
            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            if (!yanit.IsSuccessStatusCode)
            {
                // Anahtar/kota hatası kullanıcıya yansımaz: katalog cevabı
                //   zaten hazır. Günlüğe KISALTILMIŞ yazılır - hata gövdesi
                //   isteğin kendisini geri yankılayabilir.
                _gunluk.LogWarning("AI model çağrısı başarısız ({Kod}): {Ozet}",
                                   (int)yanit.StatusCode,
                                   metin.Length > 300 ? metin[..300] : metin);
                return null;
            }

            using var belge = JsonDocument.Parse(metin);
            var kok = belge.RootElement;
            var yazi = new StringBuilder();
            if (kok.TryGetProperty("content", out var icerik))
                foreach (var parca in icerik.EnumerateArray())
                    if (parca.TryGetProperty("text", out var t))
                        yazi.Append(t.GetString());

            var giris = 0;
            var cikis = 0;
            if (kok.TryGetProperty("usage", out var kullanim))
            {
                if (kullanim.TryGetProperty("input_tokens", out var g)) giris = g.GetInt32();
                if (kullanim.TryGetProperty("output_tokens", out var c)) cikis = c.GetInt32();
            }

            var ad = kok.TryGetProperty("model", out var mv) ? mv.GetString() ?? _ayar.Model
                                                            : _ayar.Model;
            var sonuc = yazi.ToString().Trim();
            return sonuc.Length == 0 ? null : new ModelYaniti(sonuc, giris, cikis, ad);
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException
                                       or JsonException)
        {
            _gunluk.LogWarning(h, "AI model çağrısı yapılamadı");
            return null;   // katalog cevabına düşülür
        }
    }
}
