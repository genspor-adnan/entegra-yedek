using System.Text;
using System.Xml.Linq;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-NABIZ PORTAL SERVİSİ (NabizHBYS.svc) — ORTAK İSTEMCİ (877/878).
///
/// <para>İki özellik aynı uca gider: hekimin hastanın kayıtlarına erişimi
/// (<c>DoktorEHRErisimi</c>, H6) ve hastaya mesaj (H7). Zarf, kimlik
/// doğrulama ve hesap okuma ikisinde de aynı; ayrı yazılsaydı Bakanlık
/// kimlik doğrulamayı değiştirdiğinde iki yerin biri sessizce eski kalırdı.</para>
///
/// <para><b>Kimlik zarfın WS-Security başlığındadır</b> (UsernameToken +
/// PasswordText) - kılavuzdaki örnek istekle birebir. Basic auth
/// EKLENMEZ: 877'deki USS servisinde de kimlik yalnız başlıkta taşınıyor,
/// ikinci bir yerde taşımak sızma yüzeyini büyütmekten başka işe yaramaz.</para>
/// </summary>
public sealed class EnabizPortalIstemcisi
{
    private readonly IHttpClientFactory _http;

    public EnabizPortalIstemcisi(IHttpClientFactory http) => _http = http;

    /// <summary>Portal hesabı - 877'de kurulan <c>ENABIZ_HBYS</c> satırı.</summary>
    public sealed record Hesap(string Url, string Kullanici, string Sifre, string KurumKodu);

    public const string TempuriAdAlani = "http://tempuri.org/";
    public const string VeriSozlesmesiAdAlani = "http://schemas.datacontract.org/2004/07/NabizHBYS";

    private const string WsseAd =
        "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd";
    private const string SifreTipi =
        "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText";

    /// <summary>
    /// Hesabı okur. Hesap yoksa, pasifse ya da adresi boşsa <c>null</c> -
    /// çağıran kendi diliyle "kapı kapalı" der.
    /// </summary>
    public static async Task<Hesap?> HesapAlAsync(NpgsqlConnection baglanti, CancellationToken iptal)
        => await baglanti.TekAsync("""
            select coalesce(nullif(case when e.test_mi = 1 then e.test_url else e.url end, ''), ''),
                   coalesce(e.kullanici_adi, ''), coalesce(e.sifre, ''), coalesce(e.kurum_kodu, '')
              from public.entegrasyon_hesap e
             where e.kod = 'ENABIZ_HBYS' and e.aktif = 1
             limit 1
            """, null, [],
            o => o.GetString(0).Length == 0 ? null
               : new Hesap(o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3)),
            iptal);

    /// <summary>
    /// Metodu çağırır ve yanıt zarfını ham döndürür.
    ///
    /// <para><paramref name="govdeAlanlari"/> veri sözleşmesi ad alanında
    /// (<c>NabizHBYS</c>) yazılır - kılavuzdaki <c>DoktorErisimTalep</c>
    /// örneğinin aynısı.</para>
    /// </summary>
    public async Task<(bool HttpTamam, int HttpKod, string Zarf)> CagirAsync(
        Hesap hesap, string metot, IEnumerable<(string Ad, string Deger)> govdeAlanlari,
        CancellationToken iptal)
    {
        var istemci = _http.CreateClient("enabiz");
        istemci.Timeout = TimeSpan.FromSeconds(60);

        using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Url)
        {
            Content = new StringContent(Zarfla(hesap, metot, govdeAlanlari), Encoding.UTF8, "text/xml"),
        };
        // WCF SOAP 1.1: eylem HTTP başlığında, tırnak içinde.
        istek.Headers.TryAddWithoutValidation("SOAPAction", $"\"{TempuriAdAlani}{metot}\"");

        using var yanit = await istemci.SendAsync(istek, iptal);
        var zarf = await yanit.Content.ReadAsStringAsync(iptal);
        return (yanit.IsSuccessStatusCode, (int)yanit.StatusCode, zarf);
    }

    public static string Zarfla(Hesap hesap, string metot,
                                IEnumerable<(string Ad, string Deger)> govdeAlanlari)
    {
        XNamespace s = "http://schemas.xmlsoap.org/soap/envelope/";
        XNamespace tem = TempuriAdAlani;
        XNamespace nab = VeriSozlesmesiAdAlani;
        XNamespace wsse = WsseAd;

        var zarf = new XElement(s + "Envelope",
            new XAttribute(XNamespace.Xmlns + "soapenv", s.NamespaceName),
            new XAttribute(XNamespace.Xmlns + "tem", tem.NamespaceName),
            new XElement(s + "Header",
                new XElement(wsse + "Security",
                    new XAttribute(XNamespace.Xmlns + "wsse", WsseAd),
                    new XElement(wsse + "UsernameToken",
                        new XElement(wsse + "Username", hesap.Kullanici),
                        new XElement(wsse + "Password",
                            new XAttribute("Type", SifreTipi), hesap.Sifre)))),
            new XElement(s + "Body",
                new XElement(tem + metot,
                    new XElement(tem + "input",
                        new XAttribute(XNamespace.Xmlns + "nab", nab.NamespaceName),
                        govdeAlanlari.Select(a => new XElement(nab + a.Ad, a.Deger))))));

        return new XDocument(new XDeclaration("1.0", "utf-8", null), zarf).ToString();
    }

    /// <summary>
    /// Yanıttan bir elemanın değerini alır (ad alanına bakmadan, yerel adla).
    /// WCF yanıtları <c>a:</c> önekiyle geliyor; ön eke bağlanmak, servis
    /// önekini değiştirdiğinde çözümlemeyi sessizce boşa düşürürdü.
    /// </summary>
    public static string? Eleman(string zarf, string yerelAd)
    {
        try
        {
            return XDocument.Parse(zarf).Descendants()
                .FirstOrDefault(e => e.Name.LocalName == yerelAd)?.Value;
        }
        catch { return null; }
    }

    /// <summary>SOAP Fault varsa metnini döner.</summary>
    public static string? Fault(string zarf) => Eleman(zarf, "faultstring");

    public static string Kirp(string? metin, int uzunluk)
        => (metin ?? "").Length <= uzunluk ? metin ?? "" : metin![..uzunluk];
}
