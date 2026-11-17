using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Xml;
using Gentegre.Api.Servisler;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME 17.11.2026 düzeltmeleri:
///  * e-İmza "radyolog adına": imza kriptografik doğrulanır, TCKN imzayı DOĞRULAYAN sertifikanın konu SERIALNUMBER'ından
///    okunur (EImzaServisi.ImzaKimliginiDogrula) - uç bunu seçilen radyoloğun kimlik numarasıyla karşılaştırır.
///  * KVKK onay günü (1362): devredilen onay ilk alındığı günü taşır, süre her gelişte yeniden başlamaz; değişmeyen kayıt
///    günü korur, ret bugünü alır, onay boşalınca gün de boşalır.
/// </summary>
public sealed class KvkkVeImzaKimligiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static X509Certificate2 Sertifika(string konu, RSA anahtar)
    {
        var istek = new CertificateRequest(konu, anahtar, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        return istek.CreateSelfSigned(DateTimeOffset.Now.AddDays(-1), DateTimeOffset.Now.AddDays(1));
    }

    /// <summary>Enveloping XMLDSig (GenSigner biçimi): belge ds:Object içinde, KeyInfo'da sertifika.</summary>
    private static byte[] Imzala(string belge, RSA imzaAnahtari, X509Certificate2 keyInfoSertifikasi)
    {
        var xml = new XmlDocument { PreserveWhitespace = true };
        var sx = new SignedXml(xml) { SigningKey = imzaAnahtari };
        var nesne = new DataObject { Id = "belge", Data = new XmlDocument { InnerXml = $"<icerik>{belge}</icerik>" }.ChildNodes };
        sx.AddObject(nesne);
        sx.AddReference(new Reference("#belge") { DigestMethod = SignedXml.XmlDsigSHA256Url });
        sx.SignedInfo!.SignatureMethod = SignedXml.XmlDsigRSASHA256Url;
        var ki = new KeyInfo();
        ki.AddClause(new KeyInfoX509Data(keyInfoSertifikasi));
        sx.KeyInfo = ki;
        sx.ComputeSignature();
        return Encoding.UTF8.GetBytes(sx.GetXml().OuterXml);
    }

    [Fact]
    public void Imza_kriptografik_dogrulanir_TCKN_imzalayan_sertifikadan_okunur()
    {
        using var anahtar = RSA.Create(2048);
        using var sertifika = Sertifika("CN=Ayşe Kaya, SERIALNUMBER=12345678901, C=TR", anahtar);
        var imzali = Imzala("rapor metni", anahtar, sertifika);

        var k = EImzaServisi.ImzaKimliginiDogrula(imzali);
        Assert.True(k.Gecerli, k.Hata);
        Assert.Equal("12345678901", k.Tckn);

        // Belge sonradan değiştirildi: özet tutmaz.
        var bozuk = Encoding.UTF8.GetBytes(Encoding.UTF8.GetString(imzali).Replace("rapor metni", "rapor metnı"));
        Assert.False(EImzaServisi.ImzaKimliginiDogrula(bozuk).Gecerli);

        // SAHTE KİMLİK: kendi anahtarıyla imzalayıp radyoloğun sertifikasını KeyInfo'ya koymak işe yaramaz.
        using var baskaAnahtar = RSA.Create(2048);
        var sahte = Imzala("rapor metni", baskaAnahtar, sertifika);
        var s = EImzaServisi.ImzaKimliginiDogrula(sahte);
        Assert.False(s.Gecerli);
        Assert.Null(s.Tckn);

        // TCKN taşımayan sertifika: imza geçerli, kimlik yok (adına imza reddedilir).
        using var anahtar2 = RSA.Create(2048);
        using var tcknsiz = Sertifika("CN=Ayşe Kaya, C=TR", anahtar2);
        var k2 = EImzaServisi.ImzaKimliginiDogrula(Imzala("x", anahtar2, tcknsiz));
        Assert.True(k2.Gecerli, k2.Hata);
        Assert.Null(k2.Tckn);

        Assert.False(EImzaServisi.ImzaKimliginiDogrula(Encoding.UTF8.GetBytes("<bozuk")).Gecerli);
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
