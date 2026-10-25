using Gentegre.Api.Uclar;

namespace Gentegre.Testler;

/// <summary>
/// TEKLİF DÖNÜŞÜM İCMALİ (1186) - teklif durum kuralı ve gece işinin "süresi doldu" seçimi.
/// VERİTABANI GEREKTİRMEZ: iki saf fonksiyon (TeklifIcmalUclari.DurumBul / SuresiDolarMi); gece işinin SQL'i
/// aynı koşulu (açık 1/2, vade_gun &gt; 0, belge_tarihi + vade_gun &lt; şube bugünü, hiç dönüş yok) uygular.
/// Karar 25.10.2026: süresi dolan, hiç satırı dönmemiş teklif kendiliğinden kaybedilir; kısmen dönen kaybedilmez.
/// </summary>
public class TeklifSureKuraliTestleri
{
    private static readonly DateTime Bugun = new(2026, 10, 25);

    [Theory]
    [InlineData((short)2, 30, "2026-09-20", false, true)]   // geçerlilik 20.10 bitti → kayıp
    [InlineData((short)1, 30, "2026-09-20", false, true)]   // hazırlanıyor da kapanır
    [InlineData((short)2, 30, "2026-09-25", false, false)]  // son gün bugün (25.10) → henüz değil
    [InlineData((short)2, 30, "2026-09-24", false, true)]   // son gün dün → kayıp
    [InlineData((short)2, 0, "2026-01-01", false, false)]   // geçerlilik süresi yok → hiç dolmaz
    [InlineData((short)2, 30, "2026-09-20", true, false)]   // kısmen / tam dönmüş → dokunulmaz
    [InlineData((short)3, 30, "2026-09-20", false, false)]  // kabul edilmiş → gece işi seçmez
    [InlineData((short)4, 30, "2026-09-20", false, false)]  // zaten kaybedildi
    [InlineData((short)5, 30, "2026-09-20", false, false)]  // iptal
    public void SuresiDolarMi(short durum, int vade, string tarih, bool donus, bool beklenen)
        => Assert.Equal(beklenen, TeklifIcmalUclari.SuresiDolarMi(durum, vade, DateTime.Parse(tarih), donus, Bugun));

    [Theory]
    [InlineData((short)5, 0, null, "iptal")]
    [InlineData((short)4, 0, null, "kaybedildi")]
    [InlineData((short)2, 1, null, "dondu")]
    [InlineData((short)2, 0.4, null, "kismen")]
    [InlineData((short)3, 0, null, "kabul")]
    [InlineData((short)2, 0, "2026-10-24", "suresi_doldu")]
    [InlineData((short)2, 0, "2026-10-25", "bekliyor")]
    [InlineData((short)1, 0, null, "hazirlaniyor")]
    [InlineData((short)2, 0, null, "bekliyor")]
    public void DurumBul(short durum, double oran, string? gecerlilik, string beklenen)
        => Assert.Equal(beklenen, TeklifIcmalUclari.DurumBul(durum, (decimal)oran,
            gecerlilik is null ? null : DateTime.Parse(gecerlilik), Bugun));

    [Fact]
    public void KaybedilenTeklifDonusDeIcerseKayipKalir()
        // Kaybedildi işaretlemesi dönüşten önce gelir: Red (4) durumunda dönen oran durumu değiştirmez.
        => Assert.Equal("kaybedildi", TeklifIcmalUclari.DurumBul(4, 1m, null, Bugun));
}
