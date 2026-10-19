using System.Globalization;
using System.Net.Http.Headers;
using System.Security;
using System.Text;
using System.Xml.Linq;

namespace Gentegre.Api.Servisler;

/// <summary>
/// MERNİS / KPS (kullanıcı 19.10.2026: "yeni hasta kartı bilgilerini MERNİS'ten getirebilmemiz lazım";
/// kanal kararı: "KPS + doğrulama"). MERNİS, NVİ'nin nüfus veritabanı; KPS (Kimlik Paylaşım Sistemi)
/// kurumlara açılan servisi. İki iş:
///
///   1) <b>Getir</b> (KPS): kimlik no ile ad, soyad, doğum tarihi / yeri, cinsiyet, anne / baba adı.
///      Kurumun NVİ protokolü ve KPS kullanıcısı gerekir. Kip kurum ayarında:
///        kapali     - sorgu yapılmaz;
///        simulasyon - geliştirme / demo: kimlik nodan TÜRETİLMİŞ sahte kişi, "SİMÜLASYON" işaretli;
///        canli      - KPS servisi (kurum kullanıcısı ile).
///   2) <b>Doğrula</b> (NVİ herkese açık KPSPublic): kimlik no + ad + soyad + doğum yılı DOĞRU MU - bilgi
///      getirmez, kullanıcı / şifre gerekmez. Elle girilen kaydın denetimi.
///
/// Her sorgu çağıran uçta işlem loguna yazılır (KPS kullanım şartı: kim, ne zaman, hangi kimlik no).
/// </summary>
public sealed class MernisServisi(IHttpClientFactory http, ILogger<MernisServisi> log)
{
    public sealed record KisiBilgisi(
        string KimlikNo, string Ad, string Soyad, DateOnly? DogumTarihi, string Cinsiyet,
        string BabaAdi, string AnneAdi, string DogumYeri, bool Simulasyon);

    /// <summary>T.C. kimlik no algoritması (11 hane, ilk hane 0 değil, 10. ve 11. hane denetimi).</summary>
    public static bool TcGecerli(string? tc)
    {
        if (tc is null || tc.Length != 11 || !tc.All(char.IsAsciiDigit) || tc[0] == '0') return false;
        var r = tc.Select(c => c - '0').ToArray();
        var tek = r[0] + r[2] + r[4] + r[6] + r[8];
        var cift = r[1] + r[3] + r[5] + r[7];
        if (((tek * 7 - cift) % 10 + 10) % 10 != r[9]) return false;
        return r.Take(10).Sum() % 10 == r[10];
    }

    /// <summary>
    /// SİMÜLASYON: kimlik nodan türetilmiş, her seferinde AYNI sahte kişi (gerçek kişi değildir; ekranda
    /// "SİMÜLASYON" yazar). Geliştirme ve demo kurulumlarında akışı uçtan uca denemek için.
    /// </summary>
    public static KisiBilgisi Simulasyon(string tc)
    {
        string[] erkek = ["Ahmet", "Mehmet", "Mustafa", "Ali", "Hüseyin", "Hasan", "İbrahim", "Murat"];
        string[] kadin = ["Ayşe", "Fatma", "Emine", "Hatice", "Zeynep", "Elif", "Meryem", "Şerife"];
        string[] soyad = ["Yılmaz", "Kaya", "Demir", "Şahin", "Çelik", "Yıldız", "Aydın", "Öztürk"];
        string[] il = ["Ankara", "İstanbul", "İzmir", "Bursa", "Konya", "Adana", "Trabzon", "Erzurum"];
        var h = tc.Select(c => c - '0').ToArray();
        var kadinMi = h[9] % 2 == 1;
        var yil = 1950 + (h[1] * 10 + h[2]) % 60;
        var dogum = new DateOnly(yil, 1 + h[3] % 12, 1 + (h[4] * 10 + h[5]) % 28);
        return new KisiBilgisi(tc,
            (kadinMi ? kadin : erkek)[h[6] % 8], soyad[h[7] % 8], dogum, kadinMi ? "K" : "E",
            erkek[(h[8] + 3) % 8], kadin[(h[8] + 5) % 8], il[h[2] % 8], Simulasyon: true);
    }

    /// <summary>
    /// NVİ HERKESE AÇIK DOĞRULAMA (KPSPublic TCKimlikNoDogrula, SOAP 1.2). Ad / soyad Türkçe büyük harfe
    /// çevrilir (servis öyle bekler). Ulaşılamazsa null - doğrulanamadı, "yanlış" demek değildir.
    /// </summary>
    public async Task<bool?> NviDogrulaAsync(string tc, string ad, string soyad, int dogumYili, CancellationToken iptal)
    {
        var tr = CultureInfo.GetCultureInfo("tr-TR");
        var govde = $"""
            <?xml version="1.0" encoding="utf-8"?>
            <soap12:Envelope xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
              <soap12:Body>
                <TCKimlikNoDogrula xmlns="http://tckimlik.nvi.gov.tr/WS">
                  <TCKimlikNo>{SecurityElement.Escape(tc)}</TCKimlikNo>
                  <Ad>{SecurityElement.Escape(ad.Trim().ToUpper(tr))}</Ad>
                  <Soyad>{SecurityElement.Escape(soyad.Trim().ToUpper(tr))}</Soyad>
                  <DogumYili>{dogumYili}</DogumYili>
                </TCKimlikNoDogrula>
              </soap12:Body>
            </soap12:Envelope>
            """;
        try
        {
            using var istek = new HttpRequestMessage(HttpMethod.Post, "https://tckimlik.nvi.gov.tr/Service/KPSPublic.asmx")
            {
                Content = new StringContent(govde, Encoding.UTF8),
            };
            istek.Content.Headers.ContentType = MediaTypeHeaderValue.Parse(
                "application/soap+xml; charset=utf-8; action=\"http://tckimlik.nvi.gov.tr/WS/TCKimlikNoDogrula\"");
            using var yanit = await http.CreateClient("mernis").SendAsync(istek, iptal);
            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            if (!yanit.IsSuccessStatusCode) { log.LogWarning("NVİ doğrulama {Durum}", (int)yanit.StatusCode); return null; }
            var sonuc = XDocument.Parse(metin).Descendants().FirstOrDefault(e => e.Name.LocalName == "TCKimlikNoDogrulaResult");
            return sonuc is null ? null : string.Equals(sonuc.Value, "true", StringComparison.OrdinalIgnoreCase);
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException or System.Xml.XmlException)
        {
            log.LogWarning(h, "NVİ doğrulama servisine ulaşılamadı");
            return null;
        }
    }
}
