using System.Reflection;
using Gentegre.Api.Uclar;
using Gentegre.Veri.Depolar;

namespace Gentegre.Testler;

/// <summary>
/// BELGE BAŞLIK ALANI BEYAZ LİSTESİ ↔ YAZMA HARİTASI (kullanıcı 15.11.2026: "yeni başvuru eklemek istedim hata:
/// Bilinmeyen belge alanı: enabizBildirim"). Yazma haritasına (BelgeDeposu.Yazma) eklenen alan, uç tarafındaki tip
/// listesine (BelgeUclari.BaslikTipi) eklenmezse kart 422 alır ve başvuru hiç kaydedilemez - aynı tuzak daha önce
/// emekli (590) ve hastaId (658) ile yaşandı. Bu test iki listeyi birbirine kilitler: haritadaki her alanın tipi olmalı.
/// </summary>
public sealed class BelgeBaslikAlanTestleri
{
    private static IEnumerable<string> HaritaAlanlari(string ad)
    {
        var f = typeof(BelgeDeposu).GetField(ad, BindingFlags.NonPublic | BindingFlags.Static)
                ?? throw new InvalidOperationException($"BelgeDeposu.{ad} bulunamadı");
        return ((Dictionary<string, string>)f.GetValue(null)!).Keys;
    }

    private static string? BaslikTipi(string alan)
    {
        var m = typeof(BelgeUclari).GetMethod("BaslikTipi", BindingFlags.NonPublic | BindingFlags.Static)
                ?? throw new InvalidOperationException("BelgeUclari.BaslikTipi bulunamadı");
        return (string?)m.Invoke(null, [alan]);
    }

    [Theory]
    [InlineData("BasvuruKolonlari")]
    [InlineData("ProvizyonKolonlari")]
    [InlineData("SevkiyatKolonlari")]
    public void Yazma_haritasindaki_her_alanin_baslik_tipi_var(string harita)
    {
        var eksik = HaritaAlanlari(harita).Where(a => BaslikTipi(a) is null).ToList();
        Assert.True(eksik.Count == 0, $"{harita}: tipi olmayan alan(lar) -> {string.Join(", ", eksik)}");
    }

    [Fact]
    public void Bildirim_bayraklari_sayi_tipinde()
    {
        Assert.Equal("sayi", BaslikTipi("enabizBildirim"));
        Assert.Equal("sayi", BaslikTipi("teleradBildirim"));
    }
}
