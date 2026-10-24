using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// BELGE YÖNÜ - `tipi = 2` her türde iade DEĞİLDİR (24.10.2026, stok sayımı
/// geliştirilirken bulundu). Stok fişinde tip fişin sebebidir (db/101): giriş
/// fişi tipi 2 "Sayım Fazlası", çıkış fişi tipi 2 "İmha". Bunlar iade sayılınca
/// sayım fazlası stoktan düşüyor, imha stoğa ekleniyordu.
/// </summary>
public sealed class BelgeYonuTestleri
{
    [Theory]
    [InlineData(3, 1, false)]   // giriş fişi · fire
    [InlineData(3, 2, false)]   // giriş fişi · sayım fazlası - GİRER
    [InlineData(4, 2, true)]    // çıkış fişi · imha - ÇIKAR
    [InlineData(4, 5, true)]    // çıkış fişi · sayım eksiği
    [InlineData(15, 1, true)]   // satış faturası
    [InlineData(15, 2, false)]  // satış iadesi - mal geri girer
    public void Stok_fisinde_tip_iade_degil_sebeptir(int tur, int tipi, bool cikis)
        => Assert.Equal(cikis, BelgeTuru.CikisMi(tur, tipi));
}
