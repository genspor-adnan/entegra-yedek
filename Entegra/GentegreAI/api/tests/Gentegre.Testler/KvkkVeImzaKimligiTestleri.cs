using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using Gentegre.Api.Servisler;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME 17.11.2026 düzeltmeleri:
///  * e-İmza "radyolog adına": imzalayanın TCKN'si sertifikanın konu SERIALNUMBER'ından okunur (EImzaServisi.ImzalayanTckn)
///    - uç bunu seçilen radyoloğun kimlik numarasıyla karşılaştırır.
///  * KVKK onay günü (1362): devredilen onay ilk alındığı günü taşır, süre her gelişte yeniden başlamaz; değişmeyen kayıt
///    günü korur, ret bugünü alır, onay boşalınca gün de boşalır.
/// </summary>
public sealed class KvkkVeImzaKimligiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static byte[] ImzaliXml(string konu)
    {
        using var rsa = RSA.Create(2048);
        var istek = new CertificateRequest(konu, rsa, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        using var sertifika = istek.CreateSelfSigned(DateTimeOffset.Now.AddDays(-1), DateTimeOffset.Now.AddDays(1));
        var b64 = Convert.ToBase64String(sertifika.Export(X509ContentType.Cert));
        return Encoding.UTF8.GetBytes($"""
            <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:SignatureValue>AA==</ds:SignatureValue>
            <ds:KeyInfo><ds:X509Data><ds:X509Certificate>{b64}</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature>
            """);
    }

    [Fact]
    public void Imzalayan_TCKN_sertifika_konusunun_seri_numarasindan_okunur()
    {
        Assert.Equal("12345678901", EImzaServisi.ImzalayanTckn(ImzaliXml("CN=Ayşe Kaya, SERIALNUMBER=12345678901, C=TR")));
        // Seri numarası yoksa ya da TCKN değilse: null (adına imza reddedilir).
        Assert.Null(EImzaServisi.ImzalayanTckn(ImzaliXml("CN=Ayşe Kaya, C=TR")));
        Assert.Null(EImzaServisi.ImzalayanTckn(ImzaliXml("CN=Ayşe Kaya, SERIALNUMBER=ABC123, C=TR")));
        Assert.Null(EImzaServisi.ImzalayanTckn(Encoding.UTF8.GetBytes("<bozuk")));
    }

    [VtFact]
    public async Task Devredilen_KVKK_onayi_ilk_alindigi_gunu_tasir()
    {
        if (!olgu.Baglandi(nameof(Devredilen_KVKK_onayi_ilk_alindigi_gunu_tasir))) return;
        var veri = olgu.Gerekli();
        await using var b = await veri.AcAsync();
        await using var tx = await b.BeginTransactionAsync();   // her şey geri alınır
        var hasta = await b.TekDegerAsync<int>("select min(id) from public.taraf where hasta = 1", tx, []);
        Assert.True(hasta > 0, "Test veritabanında hasta yok.");
        var ilk = await b.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no)
            values (19, 30, 0, date '2025-01-10', @p0, 1, 'KVKKT1') returning id
            """, tx, [hasta]);
        var ikinci = await b.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no)
            values (19, 30, 0, date '2025-12-01', @p0, 1, 'KVKKT2') returning id
            """, tx, [hasta]);
        await b.CalistirAsync("insert into public.belge_basvuru (id, kvkk_onay, etk_onay) values (@p0, 3, 3)", tx, [ilk]);
        // İlk onayın alındığı gün geçmişte (tetik bugünü yazdı; testte geriye çekilir).
        await b.CalistirAsync("update public.belge_basvuru set kvkk_onay_tarihi = date '2025-01-10' where id = @p0", tx, [ilk]);
        // İkinci başvuruya onay DEVREDİLDİ (kodsuz 3): gün ilkinin günü.
        await b.CalistirAsync("insert into public.belge_basvuru (id, kvkk_onay) values (@p0, 3)", tx, [ikinci]);
        Task<DateTime?> Gun() => b.TekDegerAsync<DateTime?>(
            "select kvkk_onay_tarihi::timestamp from public.belge_basvuru where id = @p0", tx, [ikinci]);
        Assert.Equal(new DateTime(2025, 1, 10), await Gun());
        // Onay değişmeden kayıt: gün korunur.
        await b.CalistirAsync("update public.belge_basvuru set kvkk_onay = 3, etk_onay = 3 where id = @p0", tx, [ikinci]);
        Assert.Equal(new DateTime(2025, 1, 10), await Gun());
        // Ret: bugün. Boşalınca: boş.
        await b.CalistirAsync("update public.belge_basvuru set kvkk_onay = 1 where id = @p0", tx, [ikinci]);
        Assert.Equal(DateTime.Today, await Gun());
        await b.CalistirAsync("update public.belge_basvuru set kvkk_onay = null where id = @p0", tx, [ikinci]);
        Assert.Null(await Gun());
        await tx.RollbackAsync();
    }
}
