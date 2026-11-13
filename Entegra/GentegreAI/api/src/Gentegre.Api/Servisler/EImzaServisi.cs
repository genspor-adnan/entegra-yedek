using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Xml;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-İMZA (1337, kullanıcı 13.11.2026): GenSigner (Sign-Server) ile XAdES-BASELINE-B ENVELOPING imza.
///
/// GenSigner (Entegra/Sign-Server, Quarkus + DSS + PKCS#11) iki uç verir:
///   GET  /api/sign/certificates  → takılı kartlardaki sertifikalar (libraryAlias, slotId, serial, cn, ...)
///   POST /api/sign/document      → {libraryAlias, slotId, serial, pin, mimeType, bytesBase64Encoded} → {success, data}
///                                  data = imzalı XML'in base64'ü; belgenin aslı XML içinde ds:Object olarak base64 durur.
/// Her istek X-Api-Key başlığı ister (entegrasyon_hesap.sifre).
///
/// KİP (entegrasyon_hesap kod EIMZA, ayarlar.kip):
///   istemci → kart hekimin bilgisayarında; TARAYICI localhost GenSigner'a gider, API yalnız imzalı XML'i alır ve
///             doğrular (PIN sunucuya gelmez). API bu kipte yalnız ayarı (adres + anahtar) verir.
///   sunucu  → kart sunucuda (sabit USB); hekim PIN'i girer, API GenSigner'a iletir. PIN loglanmaz, saklanmaz.
/// </summary>
public sealed class EImzaServisi(VeriKaynagi veri, IHttpClientFactory istemciUretici)
{
    public const string Kod = "EIMZA";
    public const string KipIstemci = "istemci";
    public const string KipSunucu = "sunucu";

    public sealed record Ayar(bool Aktif, string Kip, string Url, string ApiKey)
    {
        public static readonly Ayar Kapali = new(false, KipIstemci, "", "");
    }

    /// <summary>GenSigner sertifika satırı (CertificateObject) - alan adları aracın JSON'uyla birebir.</summary>
    public sealed record Sertifika(
        [property: JsonPropertyName("libraryAlias")] string LibraryAlias,
        [property: JsonPropertyName("slotId")] long SlotId,
        [property: JsonPropertyName("serial")] string Serial,
        [property: JsonPropertyName("serialNumber")] string? SerialNumber,
        [property: JsonPropertyName("cn")] string? Cn,
        [property: JsonPropertyName("subject")] string? Subject,
        [property: JsonPropertyName("issuer")] string? Issuer,
        [property: JsonPropertyName("keyUsageSign")] bool KeyUsageSign,
        [property: JsonPropertyName("dateValid")] bool DateValid,
        [property: JsonPropertyName("notAfter")] JsonElement? NotAfter);

    /// <summary>İmza isteğinde kartı seçen alanlar (sertifika listesinden).</summary>
    public sealed record KartSecimi(string LibraryAlias, long SlotId, string Serial, string? Cn);

    private sealed record HesapSatiri(string Url, string Anahtar, string Kip);
    private sealed record SertifikaYaniti(bool Success, List<Sertifika>? Data, string? Message);
    private sealed record ImzaYaniti(bool Success, string? Data, string? Message);

    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    /// <summary>Aktif EIMZA hesabı: şubenin kendi satırı önce, yoksa kurum geneli (sube_id null). Yoksa Kapali.</summary>
    public async Task<Ayar> AyarAsync(int? subeId, CancellationToken iptal)
    {
        var satir = await veri.TekAsync("""
            select coalesce(url, ''), coalesce(sifre, ''), coalesce(ayarlar ->> 'kip', '')
              from public.entegrasyon_hesap
             where kod = @p0 and aktif = 1 and (sube_id is null or sube_id = @p1)
             order by case when sube_id = @p1 then 0 else 1 end, test_mi, id
             limit 1
            """, [Kod, subeId ?? 0],
            o => new HesapSatiri(o.GetString(0), o.GetString(1), o.GetString(2)), iptal);
        if (satir is null) return Ayar.Kapali;
        var kip = satir.Kip.Trim().ToLowerInvariant() == KipSunucu ? KipSunucu : KipIstemci;
        var url = satir.Url.Trim().TrimEnd('/');
        if (url.Length == 0) url = "http://localhost:51919";
        // sifre kolonu dinlenirken şifreli (GizliMetin enc1:) - entegrasyon kartı öyle yazar, ham SQL ile girilmiş
        //   düz değeri de Coz olduğu gibi döner.
        return new Ayar(true, kip, url, GizliMetin.Coz(satir.Anahtar).Trim());
    }

    /// <summary>Sunucu kipinde GenSigner'daki kartları listeler.</summary>
    public async Task<List<Sertifika>> SertifikalarAsync(Ayar ayar, CancellationToken iptal)
    {
        using var istek = new HttpRequestMessage(HttpMethod.Get, ayar.Url + "/api/sign/certificates");
        istek.Headers.TryAddWithoutValidation("X-Api-Key", ayar.ApiKey);
        using var yanit = await Istemci().SendAsync(istek, iptal);
        var govde = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali($"GenSigner sertifika listesi alınamadı ({(int)yanit.StatusCode}): {Kisa(govde)}");
        var y = JsonSerializer.Deserialize<SertifikaYaniti>(govde, Json);
        if (y is null || !y.Success)
            throw GentegreHatasi.IsKurali("GenSigner sertifika listesi alınamadı: " + (y?.Message ?? Kisa(govde)));
        return y.Data ?? [];
    }

    /// <summary>Sunucu kipinde belgeyi GenSigner'a imzalatır; imzalı XML'in baytlarını döner. PIN yalnız bu çağrıda kullanılır.</summary>
    public async Task<byte[]> ImzalaAsync(Ayar ayar, byte[] belge, string mimeType, KartSecimi kart, string pin, CancellationToken iptal)
    {
        var govdeJson = JsonSerializer.Serialize(new
        {
            libraryAlias = kart.LibraryAlias, slotId = kart.SlotId, serial = kart.Serial, pin,
            mimeType, bytesBase64Encoded = Convert.ToBase64String(belge), acceptExpiredCerts = false,
        });
        using var istek = new HttpRequestMessage(HttpMethod.Post, ayar.Url + "/api/sign/document")
        {
            Content = new StringContent(govdeJson, Encoding.UTF8, "application/json"),
        };
        istek.Headers.TryAddWithoutValidation("X-Api-Key", ayar.ApiKey);
        using var yanit = await Istemci().SendAsync(istek, iptal);
        var govde = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali($"GenSigner imzalamadı ({(int)yanit.StatusCode}): {Kisa(govde)}");
        var y = JsonSerializer.Deserialize<ImzaYaniti>(govde, Json);
        if (y is null || !y.Success || string.IsNullOrWhiteSpace(y.Data))
            throw GentegreHatasi.IsKurali("GenSigner imzalamadı: " + (y?.Message ?? Kisa(govde)));
        try { return Convert.FromBase64String(y.Data); }
        catch (FormatException) { throw GentegreHatasi.IsKurali("GenSigner yanıtı base64 değil."); }
    }

    /// <summary>
    /// İmzalı XML'in biçimsel doğrulaması: XML parse edilir, bir ds:Signature taşır ve enveloping ds:Object içinde
    /// belgenin base64'ü aynen bulunur. Kriptografik doğrulama (sertifika zinciri) burada YAPILMAZ - GenSigner
    /// imzayı attı, kart hekimin elinde; buradaki amaç yanlış/boş/başka belgenin imzasının kayda girmemesi.
    /// Hata metni döner; boş = geçerli.
    /// </summary>
    public static string Dogrula(byte[] imzaXml, byte[] belge)
    {
        if (imzaXml.Length == 0) return "İmzalı XML boş.";
        var xml = new XmlDocument();
        try
        {
            using var okuyucu = XmlReader.Create(new MemoryStream(imzaXml), new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit });
            xml.Load(okuyucu);
        }
        catch (XmlException h) { return "İmzalı XML okunamadı: " + h.Message; }
        var ad = new XmlNamespaceManager(xml.NameTable);
        ad.AddNamespace("ds", "http://www.w3.org/2000/09/xmldsig#");
        if (xml.SelectSingleNode("//ds:Signature", ad) is null) return "XML'de ds:Signature yok.";
        if (xml.SelectSingleNode("//ds:SignatureValue", ad)?.InnerText.Trim() is not { Length: > 0 }) return "İmza değeri boş.";
        var beklenen = Convert.ToBase64String(belge);
        var nesneler = xml.SelectNodes("//ds:Object", ad);
        if (nesneler is null || nesneler.Count == 0) return "Enveloping imza değil (ds:Object yok).";
        foreach (XmlNode n in nesneler)
        {
            var icerik = new string(n.InnerText.Where(c => !char.IsWhiteSpace(c)).ToArray());
            if (icerik == beklenen) return "";
        }
        return "İmzalı XML'in içindeki belge, imzalanması istenen rapor değil.";
    }

    /// <summary>Hekimin önceden hazırlanmış imzasını (istemci kipi) da aynı yoldan doğrular.</summary>
    public static byte[] Base64Coz(string? imzaBase64)
    {
        if (string.IsNullOrWhiteSpace(imzaBase64))
            throw GentegreHatasi.Dogrulama("İmzalı belge gelmedi.", new AlanHatasi("imzaBase64", "Zorunlu."));
        try { return Convert.FromBase64String(imzaBase64); }
        catch (FormatException) { throw GentegreHatasi.Dogrulama("İmzalı belge base64 değil.", new AlanHatasi("imzaBase64", "Geçersiz.")); }
    }

    private HttpClient Istemci() => istemciUretici.CreateClient("eimza");

    private static string Kisa(string s) => s.Length > 300 ? s[..300] : s;
}
