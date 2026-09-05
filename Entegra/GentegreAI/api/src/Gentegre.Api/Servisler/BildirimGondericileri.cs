using System.Net.Http.Headers;
using System.Net.Mail;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// Bir entegrasyon hesabının bildirim ayarları (<c>entegrasyon_hesap</c>).
/// Kimlik/URL orada durur; buradaki alanlar <c>ayarlar</c> jsonb'sinden okunur.
/// </summary>
public sealed record BildirimHesabi(
    int Id, string Kod, string Ad, bool TestMi, string KullaniciAdi, string Sifre,
    string Url, string TestUrl, JsonElement Ayarlar)
{
    public string EtkinUrl => TestMi && !string.IsNullOrWhiteSpace(TestUrl) ? TestUrl : Url;

    public string Ayar(string ad, string varsayilan = "")
        => Ayarlar.ValueKind == JsonValueKind.Object
           && Ayarlar.TryGetProperty(ad, out var d)
           && d.ValueKind is JsonValueKind.String or JsonValueKind.Number
            ? (d.ValueKind == JsonValueKind.String ? d.GetString() ?? varsayilan : d.ToString())
            : varsayilan;
}

/// <summary>
/// Bildirim hesaplarını okur ve önbellekler (kanal başına varsayılan hesap).
///
/// Hangi hesabın hangi kanala baktığı <c>ayarlar.bildirim_kanal</c> ile
/// belirlenir (1 SMS · 2 e-posta). Hesap yoksa kanal KAYIT MODUNDA çalışır -
/// kuyruk yine işler, gönderim "sağlayıcı tanımlı değil" diye günlüğe yazılır.
/// </summary>
public sealed class BildirimHesaplari
{
    private readonly VeriKaynagi _veri;
    public BildirimHesaplari(VeriKaynagi veri) => _veri = veri;

    public async Task<BildirimHesabi?> BulAsync(BildirimKanali kanal, int? hesapId,
                                                CancellationToken iptal)
    {
        var sql = hesapId is not null
            ? """
              select id, kod, ad, test_mi, kullanici_adi, coalesce(sifre, ''), url, test_url,
                     coalesce(ayarlar, '{}'::jsonb)::text
                from public.entegrasyon_hesap where id = @p0 and aktif = 1
              """
            : """
              select id, kod, ad, test_mi, kullanici_adi, coalesce(sifre, ''), url, test_url,
                     coalesce(ayarlar, '{}'::jsonb)::text
                from public.entegrasyon_hesap
               where aktif = 1
                 and coalesce(ayarlar ->> 'bildirim_kanal', '') = @p0::text
               order by id limit 1
              """;

        object? par = hesapId is not null ? hesapId : ((short)kanal).ToString();
        return await _veri.TekAsync(sql, new[] { par }, o => new BildirimHesabi(
            o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetInt16(3) == 1,
            o.GetString(4), o.GetString(5), o.GetString(6), o.GetString(7),
            JsonDocument.Parse(o.GetString(8)).RootElement), iptal);
    }
}

/// <summary>
/// SAĞLAYICI SEÇİLMEDİĞİNDE (Faz 0 kapısı henüz kapanmadı): gönderim
/// YAPILMAZ, kuyruk satırı "hata" ile kapanır ve günlüğe sebep yazılır.
///
/// Sessizce "gönderildi" demek en kötü seçenekti: randevu hatırlatması
/// gitmediği hâlde sistem gitmiş görünürdü. Geliştirmede metni görmek için
/// <c>Bildirim:KayitModu=true</c> yapılır - o zaman gönderilmiş SAYILIR ama
/// gövde günlüğe yazılır.
/// </summary>
public sealed class KayitGonderici : IBildirimGonderici
{
    private readonly ILogger<KayitGonderici> _gunluk;
    private readonly bool _kayitModu;

    public KayitGonderici(BildirimKanali kanal, ILogger<KayitGonderici> gunluk, bool kayitModu)
    {
        Kanal = kanal;
        _gunluk = gunluk;
        _kayitModu = kayitModu;
    }

    public BildirimKanali Kanal { get; }

    public Task<GonderimSonucu> GonderAsync(BildirimKaydi kayit, CancellationToken iptal)
    {
        if (!_kayitModu)
            return Task.FromResult(new GonderimSonucu(false,
                Hata: $"{Kanal} sağlayıcısı tanımlı değil (entegrasyon hesabı yok)."));

        _gunluk.LogInformation("BILDIRIM (kayıt modu) #{Id} {Kanal} → {Alici}: {Govde}",
            kayit.Id, Kanal, kayit.Alici, kayit.Govde);
        return Task.FromResult(new GonderimSonucu(true, SaglayiciRef: "kayit-modu"));
    }
}

/// <summary>
/// SMTP E-POSTA GÖNDERİCİ — sağlayıcıdan bağımsız: her kurum kendi SMTP
/// hesabını verir (entegrasyon hesabı: url = sunucu, kullanici_adi/sifre,
/// ayarlar.port / ayarlar.ssl / ayarlar.gonderen).
/// </summary>
public sealed class SmtpGonderici : IBildirimGonderici
{
    private readonly BildirimHesabi _hesap;
    public SmtpGonderici(BildirimHesabi hesap) => _hesap = hesap;

    public BildirimKanali Kanal => BildirimKanali.Eposta;

    public async Task<GonderimSonucu> GonderAsync(BildirimKaydi kayit, CancellationToken iptal)
    {
        try
        {
            var port = int.TryParse(_hesap.Ayar("port", "587"), out var p) ? p : 587;
            var gonderen = _hesap.Ayar("gonderen", _hesap.KullaniciAdi);
            using var istemci = new SmtpClient(_hesap.EtkinUrl, port)
            {
                EnableSsl = _hesap.Ayar("ssl", "1") != "0",
                Credentials = new System.Net.NetworkCredential(_hesap.KullaniciAdi, _hesap.Sifre),
            };
            using var posta = new MailMessage(gonderen, kayit.Alici,
                string.IsNullOrWhiteSpace(kayit.Konu) ? "Bildirim" : kayit.Konu, kayit.Govde);
            await istemci.SendMailAsync(posta, iptal);
            return new GonderimSonucu(true);
        }
        catch (Exception h)
        {
            return new GonderimSonucu(false, Hata: h.Message);
        }
    }
}

/// <summary>
/// ŞABLONLU HTTP SMS GÖNDERİCİ — Türkiye'deki SMS sağlayıcılarının çoğu basit
/// bir POST kabul eder; hangi alan adını beklediği sağlayıcıya göre değişir.
/// Bu yüzden gövde de sağlayıcının kendisi gibi AYARDAN gelir:
///
///   ayarlar.govde   : gönderilecek istek gövdesi, {{alici}} {{mesaj}}
///                     {{kullanici}} {{sifre}} {{baslik}} yer tutucularıyla
///   ayarlar.tip     : "json" (varsayılan) · "form"
///   ayarlar.basarili: yanıtta ARANACAK metin (yoksa yalnız HTTP 2xx bakılır)
///   ayarlar.baslik  : SMS başlığı (originator)
///
/// Böylece yeni sağlayıcı bağlamak KOD DEĞİL AYAR işidir; sağlayıcı gerçekten
/// farklı bir protokol istiyorsa (SOAP, imzalı) kendi sınıfı yazılır.
/// </summary>
public sealed class HttpSmsGonderici : IBildirimGonderici
{
    private readonly BildirimHesabi _hesap;
    private readonly HttpClient _istemci;

    public HttpSmsGonderici(BildirimHesabi hesap, HttpClient istemci)
    {
        _hesap = hesap;
        _istemci = istemci;
    }

    public BildirimKanali Kanal => BildirimKanali.Sms;

    public async Task<GonderimSonucu> GonderAsync(BildirimKaydi kayit, CancellationToken iptal)
    {
        var sablon = _hesap.Ayar("govde");
        if (string.IsNullOrWhiteSpace(_hesap.EtkinUrl) || string.IsNullOrWhiteSpace(sablon))
            return new GonderimSonucu(false,
                Hata: "SMS hesabında url / ayarlar.govde tanımlı değil.");

        var govde = BildirimSablonu.Doldur(sablon, new Dictionary<string, string>
        {
            ["alici"] = kayit.Alici,
            ["mesaj"] = KacisliMetin(kayit.Govde, _hesap.Ayar("tip", "json")),
            ["kullanici"] = _hesap.KullaniciAdi,
            ["sifre"] = _hesap.Sifre,
            ["baslik"] = _hesap.Ayar("baslik"),
        });

        try
        {
            using var istek = new HttpRequestMessage(HttpMethod.Post, _hesap.EtkinUrl);
            istek.Content = _hesap.Ayar("tip", "json") == "form"
                ? new StringContent(govde, Encoding.UTF8, "application/x-www-form-urlencoded")
                : new StringContent(govde, Encoding.UTF8, "application/json");

            var jeton = _hesap.Ayar("yetki_basligi");
            if (!string.IsNullOrWhiteSpace(jeton))
                istek.Headers.TryAddWithoutValidation("Authorization", jeton);

            using var yanit = await _istemci.SendAsync(istek, iptal);
            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            var aranan = _hesap.Ayar("basarili");
            var basarili = yanit.IsSuccessStatusCode
                           && (aranan.Length == 0 || metin.Contains(aranan, StringComparison.OrdinalIgnoreCase));

            return new GonderimSonucu(basarili,
                SaglayiciRef: basarili ? Kirp(metin, 80) : "",
                Hata: basarili ? "" : $"HTTP {(int)yanit.StatusCode}: {Kirp(metin, 300)}",
                HttpDurum: (int)yanit.StatusCode,
                HamYanit: JsonSerializer.Serialize(new { yanit = Kirp(metin, 2000) }));
        }
        catch (Exception h)
        {
            return new GonderimSonucu(false, Hata: h.Message);
        }
    }

    /// <summary>JSON gövdeye metin gömülüyorsa tırnak/satır sonu kaçışlanmalı.</summary>
    private static string KacisliMetin(string metin, string tip)
        => tip == "form"
            ? Uri.EscapeDataString(metin)
            : JsonEncodedText.Encode(metin).ToString();

    private static string Kirp(string m, int n) => m.Length <= n ? m : m[..n];
}

/// <summary>Kanala göre doğru göndericiyi kurar (hesap varsa gerçek, yoksa kayıt modu).</summary>
public sealed class BildirimGondericiFabrikasi
{
    private readonly BildirimHesaplari _hesaplar;
    private readonly IHttpClientFactory _http;
    private readonly ILoggerFactory _gunlukFab;
    private readonly bool _kayitModu;

    public BildirimGondericiFabrikasi(BildirimHesaplari hesaplar, IHttpClientFactory http,
                                      ILoggerFactory gunlukFab, IConfiguration ayar)
    {
        _hesaplar = hesaplar;
        _http = http;
        _gunlukFab = gunlukFab;
        _kayitModu = ayar.GetValue("Bildirim:KayitModu", false);
    }

    public async Task<IBildirimGonderici> KurAsync(BildirimKaydi kayit, CancellationToken iptal)
    {
        var hesap = await _hesaplar.BulAsync(kayit.Kanal, kayit.HesapId, iptal);
        if (hesap is null)
            return new KayitGonderici(kayit.Kanal, _gunlukFab.CreateLogger<KayitGonderici>(), _kayitModu);

        return kayit.Kanal switch
        {
            BildirimKanali.Eposta => new SmtpGonderici(hesap),
            BildirimKanali.Sms    => new HttpSmsGonderici(hesap, _http.CreateClient("bildirim")),
            // Push / WhatsApp sağlayıcıları seçilmedi - kayıt modu.
            _ => new KayitGonderici(kayit.Kanal, _gunlukFab.CreateLogger<KayitGonderici>(), _kayitModu),
        };
    }
}
