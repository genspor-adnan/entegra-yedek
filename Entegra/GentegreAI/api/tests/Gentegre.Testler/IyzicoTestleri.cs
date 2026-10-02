using System.Security.Cryptography;
using System.Text;
using Gentegre.Api.Servisler;

namespace Gentegre.Testler;

/// <summary>
/// iyzico Ödeme Formu (934) - ağ olmadan:
/// · IYZWSv2 başlığı: base64("apiKey:..&amp;randomKey:..&amp;signature:hex(HMACSHA256(gizli, rnd+uri+govde))").
/// · Tutar biçimi nokta ondalık ("1068.0", "778.8").
/// · Kontör YALNIZ ödeme sonucu siparişle tutarlıysa yüklenir: başarılı + SUCCESS +
///   aynı sipariş no + aynı tutar + fraud onaylı.
/// </summary>
public sealed class IyzicoTestleri
{
    [Fact]
    public void Yetki_basligi_IYZWSv2_bicimi_ve_imza_govdeye_bagli()
    {
        var b = IyzicoIstemcisi.YetkiBasligi("api-1", "gizli-1", "123", "/payment/test", "{\"a\":1}");
        Assert.StartsWith("IYZWSv2 ", b);
        var ham = Encoding.UTF8.GetString(Convert.FromBase64String(b["IYZWSv2 ".Length..]));
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes("gizli-1"));
        var beklenen = Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes("123/payment/test{\"a\":1}"))).ToLowerInvariant();
        Assert.Equal($"apiKey:api-1&randomKey:123&signature:{beklenen}", ham);
        // Gövde değişirse imza değişir.
        Assert.NotEqual(b, IyzicoIstemcisi.YetkiBasligi("api-1", "gizli-1", "123", "/payment/test", "{\"a\":2}"));
    }

    [Fact]
    public void Tutar_nokta_ondalik()
    {
        Assert.Equal("1068.0", IyzicoIstemcisi.Tutar(1068m));
        Assert.Equal("778.8", IyzicoIstemcisi.Tutar(778.80m));
        Assert.Equal("2988.12", IyzicoIstemcisi.Tutar(2988.12m));
    }

    private static IyzicoSorgu Sorgu(string durum = "SUCCESS", decimal odenen = 1068m, string no = "7",
                                     int fraud = 1, bool basarili = true)
        => new(basarili, durum, "PAY-1", odenen, "GYZ-" + no, no, "0008", "MASTER_CARD", fraud, basarili ? "" : "Kart reddedildi");

    [Fact]
    public void Dogrula_yalniz_tutarli_ve_odenmis_sonucu_kabul_eder()
    {
        Assert.True(IyzicoIstemcisi.Dogrula(Sorgu(), 7, 1068m).Odendi);
        Assert.False(IyzicoIstemcisi.Dogrula(Sorgu(basarili: false), 7, 1068m).Odendi);
        Assert.Contains("reddedildi", IyzicoIstemcisi.Dogrula(Sorgu(basarili: false), 7, 1068m).Sebep);
        Assert.False(IyzicoIstemcisi.Dogrula(Sorgu(durum: "FAILURE"), 7, 1068m).Odendi);
        Assert.Contains("bu siparişe ait değil", IyzicoIstemcisi.Dogrula(Sorgu(no: "8"), 7, 1068m).Sebep);
        Assert.Contains("tutar", IyzicoIstemcisi.Dogrula(Sorgu(odenen: 1.0m), 7, 1068m).Sebep);
        Assert.Contains("risk", IyzicoIstemcisi.Dogrula(Sorgu(fraud: 0), 7, 1068m).Sebep);
    }
}
