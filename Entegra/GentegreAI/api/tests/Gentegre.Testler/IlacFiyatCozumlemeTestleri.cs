using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// SGK Ek-4/A ÇÖZÜMLEME KURALLARI (406/407).
///
/// Bu kuralların ikisi de canlı veride kırıldı ve HATA VERMEDİ - yanlış
/// sayıyla sessizce devam etti; bir birim testinin varlık sebebi tam da bu:
///
///   * Excel iskontoyu "7.0000000000000007E-2" diye yazabiliyor. Eczacı
///     iskontosu ise "0-2,5%" gibi bir ARALIK. İkisi de '-' taşıyor: aralık
///     kuralını önce uygulamak %7'yi %200 yapıyordu.
///   * Kademe sınırları sütun BAŞLIĞINDA yazıyor ve her yayında değişiyor;
///     "ve altında" kademesi ÜST sınırdır, alt değil.
/// </summary>
public class IlacFiyatCozumlemeTestleri
{
    [Theory]
    [InlineData("0,4", 0.4)]
    [InlineData("0.4", 0.4)]
    [InlineData("%40", 40)]
    [InlineData("7.0000000000000007E-2", 0.07)]   // ÜSTEL - aralık değil
    [InlineData("0-2,5%", 2.5)]                    // ARALIK - üst sınır
    [InlineData("", 0)]
    [InlineData("yok", 0)]
    public void Ondalik_ustel_ve_araligi_ayirir(string metin, decimal beklenen)
        => Assert.Equal(beklenen, decimal.Round(IlacListeCozumleme.Ondalik(metin), 6));

    [Fact]
    public void Kademeler_sinirlari_BASLIKTAN_okur()
    {
        // Başlıklar dosyadaki gibi (TitckIlacGuncelleme.Sadelestir'den geçmiş hali).
        var satir = new Dictionary<string, string>
        {
            ["KAMU NO"] = "A04061",
            ["DEPOCUYA SATIS FIYATI (FIRMA SATIS FIYATI) 151,25 TL VE UZERI ISE"] = "0.4",
            ["DEPOCUYA SATIS FIYATI (FIRMA SATIS FIYATI) 100,38 TL (DAHIL) - "
             + "151,24 TL (DAHIL) ARASINDA ISE"] = "0.1",
            ["DEPOCUYA SATIS FIYATI (FIRMA SATIS FIYATI) 52,44 TL (DAHIL) - "
             + "100,37 TL (DAHIL) ARASINDA ISE"] = "0.05",
            ["DEPOCUYA SATIS FIYATI (FIRMA SATIS FIYATI) 52,43 TL VE ALTINDA ISE"] = "0",
        };

        var kademeler = IlacListeCozumleme.Kademeler(satir);

        Assert.Equal(4, kademeler.Count);
        // "ve üzeri": alt sınır var, üst sınır YOK.
        Assert.Contains(kademeler, k => k.Alt == 151.25m && k.Ust is null && k.Oran == 0.4m);
        // aralık: küçük olan alt, büyük olan üst.
        Assert.Contains(kademeler, k => k.Alt == 100.38m && k.Ust == 151.24m && k.Oran == 0.1m);
        // "ve altında": ÜST sınır var, alt YOK. (Ters yazılınca ucuz ilaçlar
        //   hiçbir kademeye düşmüyor ve en yüksek iskonto uygulanıyordu.)
        Assert.Contains(kademeler, k => k.Alt is null && k.Ust == 52.43m && k.Oran == 0m);

        var json = IlacListeCozumleme.KademeJson(kademeler);
        Assert.Contains("\"ust\":null", json);
        Assert.Contains("\"alt\":null", json);
        // Ondalık ayırıcı NOKTA olmalı: jsonb virgülü kabul etmez.
        Assert.Contains("151.25", json);
        Assert.DoesNotContain("151,25", json);
    }
}
