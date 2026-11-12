using System.Net;
using System.Net.Sockets;
using System.Xml.Linq;
using Gentegre.Veri;
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
public sealed class MirthIzleme(IOptions<MirthAyarlari> ayar, ILogger<MirthIzleme> gunluk, VeriKaynagi? veri = null)
{
    private CookieContainer _cerez = new();
    private readonly SemaphoreSlim _kilit = new(1, 1);
    private HttpClient? _http;
    private bool _oturumVar;
    private MirthAyarlari _etkin = ayar.Value;
    private string _anahtar = "";
    private string _kaynak = "dosya";

    /// <summary>
    /// ETKİN AYAR (1317): Ayarlar › Entegrasyon'daki aktif MIRTH hesabı (kurum geneli önce; adres = url, kullanıcı,
    /// şifre ŞİFRELİ alanda, ayarlar.sertifikaDogrula / zamanAsimiSn). Hesapta parola boşsa ortam değişkeni
    /// (Mirth__Parola). Hesap yoksa dosya (Mirth bölümü) - eski kurulum bozulmaz. Ayar değişince oturum sıfırlanır.
    /// </summary>
    private async Task<MirthAyarlari> EtkinAsync(CancellationToken iptal)
    {
        var dosya = ayar.Value;
        MirthAyarlari a = dosya; var kaynak = "dosya";
        if (veri is not null)
        {
            try
            {
                var s = await veri.TekAsync($"""
                    select {HesapSutunlari}, ad
                      from public.entegrasyon_hesap
                     where kod = 'MIRTH' and aktif = 1 and btrim(coalesce(url, '')) <> ''
                     order by (sube_id is null) desc, test_mi, id limit 1
                    """, null, o => new[] { o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3), o.GetString(4), o.GetString(5) }, iptal);
                if (s is not null)
                {
                    a = HesaptanAyar(s, dosya);
                    kaynak = $"hesap: {s[5]}" + (GizliMetin.Coz(s[2]).Length > 0 ? "" : " (parola ortamdan)");
                }
            }
            catch (Exception h) when (h is not OperationCanceledException) { gunluk.LogWarning(h, "MIRTH hesabı okunamadı; dosyadaki ayar kullanılıyor."); }
        }
        var anahtar = $"{a.Url}|{a.Kullanici}|{a.Parola.GetHashCode()}|{a.SertifikaDogrula}|{a.ZamanAsimiSn}";
        if (anahtar != _anahtar)
        {
            await _kilit.WaitAsync(iptal);
            // Eski istemci KAPATILMAZ (1323): başka bir çağrı onu hâlâ kullanıyor olabilir - ObjectDisposedException ve
            //   yanlış "ulaşılamadı" doğuruyordu. Ayar değişimi seyrek; eski istemciyi GC toplar.
            try { _http = null; _cerez = new(); _oturumVar = false; _anahtar = anahtar; _etkin = a; }
            finally { _kilit.Release(); }
        }
        _kaynak = kaynak;
        return a;
    }

    /// <summary>entegrasyon_hesap'tan Mirth ayarı için okunan sütunlar (url, kullanıcı, şifreli parola, sertifika, zaman aşımı).</summary>
    public const string HesapSutunlari =
        "coalesce(url, ''), coalesce(kullanici_adi, ''), coalesce(sifre, ''), coalesce(ayarlar ->> 'sertifikaDogrula', ''), coalesce(ayarlar ->> 'zamanAsimiSn', '')";

    /// <summary>Hesap satırı (<see cref="HesapSutunlari"/> sırasıyla) → ayar; boş kullanıcı / parola / zaman aşımı dosyadan.</summary>
    public static MirthAyarlari HesaptanAyar(IReadOnlyList<string> s, MirthAyarlari dosya)
    {
        var parola = GizliMetin.Coz(s[2]);
        return new MirthAyarlari
        {
            Url = s[0].Trim(), Kullanici = s[1].Length > 0 ? s[1] : dosya.Kullanici,
            Parola = parola.Length > 0 ? parola : dosya.Parola,
            SertifikaDogrula = s[3] is "true" or "1",
            ZamanAsimiSn = int.TryParse(s[4], out var z) && z > 0 ? z : dosya.ZamanAsimiSn,
        };
    }

    /// <summary>Mirth REST istemcisi (çerezli oturum). Sertifika doğrulanmıyorsa istisna YALNIZ yapılandırılmış Mirth sunucusuna.</summary>
    private static HttpClient IstemciKur(MirthAyarlari a, CookieContainer cerez)
    {
        var isleyici = new HttpClientHandler { CookieContainer = cerez, UseCookies = true };
        if (!a.SertifikaDogrula && Uri.TryCreate(a.Url, UriKind.Absolute, out var kok))
            isleyici.ServerCertificateCustomValidationCallback = (istek, _, _, hata) =>
                hata == System.Net.Security.SslPolicyErrors.None
                || string.Equals(istek.RequestUri?.Host, kok.Host, StringComparison.OrdinalIgnoreCase);
        var http = new HttpClient(isleyici) { Timeout = TimeSpan.FromSeconds(Math.Max(3, a.ZamanAsimiSn)) };
        http.DefaultRequestHeaders.Add("X-Requested-With", "OpenAPI");
        return http;
    }

    private HttpClient Http() => _http ??= IstemciKur(_etkin, _cerez);

    private string Kok => _etkin.Url.TrimEnd('/');

    private async Task GirisAsync(CancellationToken iptal)
    {
        var a = _etkin;
        using var govde = new FormUrlEncodedContent([new("username", a.Kullanici), new("password", a.Parola)]);
        using var y = await Http().PostAsync($"{Kok}/users/_login", govde, iptal);
        if (!y.IsSuccessStatusCode)
            throw new InvalidOperationException($"Mirth girişi başarısız ({(int)y.StatusCode}) - kullanıcı / parola ({_kaynak}).");
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
        var a = await EtkinAsync(iptal);
        if (string.IsNullOrWhiteSpace(a.Url)) return new(false, false, "Mirth bağlantısı tanımlı değil (Ayarlar › Entegrasyon › Mirth).", "", []);
        if (string.IsNullOrEmpty(a.Parola)) return new(true, false, "Mirth parolası tanımlı değil (Mirth hesabının şifresi ya da ortam değişkeni Mirth__Parola).", "", []);
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

    /// <summary>
    /// TEK SEFERLİK DENEME (1323): verilen ayarla (entegrasyon kartında SINANAN hesap) giriş + sürüm + kanal sayısı. Panonun
    /// paylaşılan oturumuna dokunmaz - etkin hesap başkaysa onu denemek yanlış sonucu sınanan satıra yazardı.
    /// </summary>
    public static async Task<MirthPanoSonucu> DeneAsync(MirthAyarlari a, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(a.Url)) return new(false, false, "Mirth adresi boş.", "", []);
        if (string.IsNullOrEmpty(a.Parola)) return new(true, false, "Mirth parolası boş (hesabın şifresi ya da Mirth__Parola).", "", []);
        using var http = IstemciKur(a, new CookieContainer());
        var url = a.Url.TrimEnd('/');
        try
        {
            using (var govde = new FormUrlEncodedContent([new("username", a.Kullanici), new("password", a.Parola)]))
            using (var y = await http.PostAsync($"{url}/users/_login", govde, iptal))
                if (!y.IsSuccessStatusCode) return new(true, false, $"Mirth girişi başarısız ({(int)y.StatusCode}) - kullanıcı / parola.", "", []);
            var surum = "";
            using (var ist = new HttpRequestMessage(HttpMethod.Get, $"{url}/server/version"))
            {
                ist.Headers.Accept.ParseAdd("text/plain");
                using var y = await http.SendAsync(ist, iptal);
                if (y.IsSuccessStatusCode) surum = (await y.Content.ReadAsStringAsync(iptal)).Trim();
            }
            using var ist2 = new HttpRequestMessage(HttpMethod.Get, $"{url}/channels/statuses?includeUndeployed=true");
            ist2.Headers.Accept.ParseAdd("application/xml");
            using var y2 = await http.SendAsync(ist2, iptal);
            y2.EnsureSuccessStatusCode();
            var x = XDocument.Parse(await y2.Content.ReadAsStringAsync(iptal));
            return new(true, true, "", surum, x.Root?.Elements("dashboardStatus").Select(Kanal).ToList() ?? []);
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException or System.Xml.XmlException)
        {
            return new(true, false, h is TaskCanceledException ? "Mirth yanıt vermedi (zaman aşımı)." : h.Message, "", []);
        }
    }

    /// <summary>Panoda / ayar ekranında gösterilecek bağlantı bilgisi - parola DEĞİL, yalnız tanımlı mı.</summary>
    public async Task<(string Url, string Kullanici, bool ParolaTanimli, bool SertifikaDogrula, string Kaynak)> OzetAsync(CancellationToken iptal)
    {
        var a = await EtkinAsync(iptal);
        return (a.Url, a.Kullanici, !string.IsNullOrEmpty(a.Parola), a.SertifikaDogrula, _kaynak);
    }

    /// <summary>TCP bağlantı denemesi (mesaj göndermez): Teletıp HL7 hedefi (Mirth K1) ya da HTTP kanalının dinleyicisi.</summary>
    public static async Task<(bool Acik, string Hata, int SureMs)> TcpDeneAsync(string adres, CancellationToken iptal)
    {
        var (sunucu, port) = MllpIstemci.AdresCoz(adres);   // host:port ya da http://host:port/yol
        if (port == 0) return (false, "adres çözülemedi", 0);
        var sw = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            using var c = new TcpClient();
            using var zaman = CancellationTokenSource.CreateLinkedTokenSource(iptal);
            zaman.CancelAfter(TimeSpan.FromSeconds(5));
            await c.ConnectAsync(sunucu, port, zaman.Token);
            return (true, "", (int)sw.ElapsedMilliseconds);
        }
        catch (Exception h) { return (false, h is OperationCanceledException ? "Zaman aşımı (5 sn)." : h.Message, (int)sw.ElapsedMilliseconds); }
    }
}
