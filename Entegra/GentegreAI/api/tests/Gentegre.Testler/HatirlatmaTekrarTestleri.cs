using Gentegre.Api.Uclar;

namespace Gentegre.Testler;

/// <summary>
/// KİŞİSEL HATIRLATICI (1139) — tekrarın sonraki zamanı ve listede görünen tekrar metni.
/// Saf fonksiyonlar (DB gerekmez). 22.10.2026 Perşembe referans gün.
/// </summary>
public sealed class HatirlatmaTekrarTestleri
{
    private static DateTime T(int ay, int gun, int saat = 9, int dk = 0) => new(2026, ay, gun, saat, dk, 0);
    private static readonly DateTime Simdi = T(10, 22, 10);   // Perşembe 10:00

    [Fact]
    public void Tekrarsiz_hatirlatmanin_sonrakisi_yok()
        => Assert.Null(HatirlatmaUclari.Sonraki(T(10, 22), 0, 1, 0, null, Simdi));

    [Fact]
    public void Her_gun_bir_sonraki_gune_ayni_saatte()
        => Assert.Equal(T(10, 23), HatirlatmaUclari.Sonraki(T(10, 22), 1, 1, 0, null, Simdi));

    [Fact]
    public void Kacirilan_tekrarlar_atlanir_simdiden_sonraki_ilk_an()
        // Bir hafta açılmayan "her gün" yedi kez sormaz: 15.10'dan bugünü geçen ilk an 23.10.
        => Assert.Equal(T(10, 23), HatirlatmaUclari.Sonraki(T(10, 15), 1, 1, 0, null, Simdi));

    [Fact]
    public void Erken_tamamlanan_tekrar_mevcut_tekrarin_ardindakine_gider()
        // 22.10 08:00'lik "her gün" 07:00'de tamamlandı: sonraki 23.10 08:00 (bugünkü tekrar kapandı).
        => Assert.Equal(T(10, 23, 8), HatirlatmaUclari.Sonraki(T(10, 22, 8), 1, 1, 0, null, T(10, 22, 7)));

    [Fact]
    public void Iki_gunde_bir()
        => Assert.Equal(T(10, 24), HatirlatmaUclari.Sonraki(T(10, 22), 1, 2, 0, null, Simdi));

    [Fact]
    public void Haftalik_gun_secimsiz_yedi_gun_sonra()
        => Assert.Equal(T(10, 29), HatirlatmaUclari.Sonraki(T(10, 22), 2, 1, 0, null, Simdi));

    [Fact]
    public void Haftalik_gun_secimsiz_iki_haftada_bir()
        => Assert.Equal(T(11, 5), HatirlatmaUclari.Sonraki(T(10, 22), 2, 2, 0, null, Simdi));

    [Fact]
    public void Haftalik_secili_gunler_siradaki_secili_gune_gider()
    {
        const short PtCu = 1 | 16;   // Pazartesi + Cuma
        // Perşembe 22.10 -> Cuma 23.10, Cuma -> Pazartesi 26.10.
        Assert.Equal(T(10, 23), HatirlatmaUclari.Sonraki(T(10, 22), 2, 1, PtCu, null, Simdi));
        Assert.Equal(T(10, 26), HatirlatmaUclari.Sonraki(T(10, 23), 2, 1, PtCu, null, T(10, 23, 10)));
    }

    [Fact]
    public void Is_gunleri_hafta_sonunu_atlar()
        // Cuma 23.10 -> Pazartesi 26.10.
        => Assert.Equal(T(10, 26), HatirlatmaUclari.Sonraki(T(10, 23), 5, 1, 0, null, T(10, 23, 10)));

    [Fact]
    public void Aylik_ve_yillik()
    {
        Assert.Equal(T(11, 22), HatirlatmaUclari.Sonraki(T(10, 22), 3, 1, 0, null, Simdi));
        Assert.Equal(new DateTime(2027, 10, 22, 9, 0, 0), HatirlatmaUclari.Sonraki(T(10, 22), 4, 1, 0, null, Simdi));
    }

    [Fact]
    public void Ay_sonu_kisa_aya_kirpilir()
        // 31 Ocak aylık -> 28 Şubat (DateTime.AddMonths): ay atlanmaz.
        => Assert.Equal(new DateTime(2027, 2, 28, 9, 0, 0),
            HatirlatmaUclari.Sonraki(new DateTime(2027, 1, 31, 9, 0, 0), 3, 1, 0, null, new DateTime(2027, 1, 31, 10, 0, 0)));

    [Fact]
    public void Bitis_gecilince_tekrar_biter()
    {
        Assert.Null(HatirlatmaUclari.Sonraki(T(10, 22), 1, 1, 0, T(10, 22).Date, Simdi));
        // Bitiş günü dahil.
        Assert.Equal(T(10, 23), HatirlatmaUclari.Sonraki(T(10, 22), 1, 1, 0, T(10, 23).Date, Simdi));
    }

    [Theory]
    [InlineData(1, 1, 0, "her gün")]
    [InlineData(1, 3, 0, "3 günde bir")]
    [InlineData(2, 1, 0, "her perşembe")]          // gün seçilmemiş: zamanın günü
    [InlineData(2, 1, 16, "her cuma")]              // tek gün: tam ad
    [InlineData(2, 1, 1 | 4 | 16, "her Pt, Ça, Cu")]
    [InlineData(2, 2, 0, "2 haftada bir")]
    [InlineData(3, 1, 0, "her ay 22.")]
    [InlineData(4, 1, 0, "her yıl 22.10")]
    [InlineData(5, 1, 0, "iş günleri")]
    [InlineData(0, 1, 0, "")]
    public void Tekrar_metni(short tekrar, short aralik, short gunler, string beklenen)
        => Assert.Equal(beklenen, HatirlatmaUclari.TekrarMetni(tekrar, aralik, gunler, null, T(10, 22)));

    [Fact]
    public void Tekrar_metninde_bitis_tarihi()
        => Assert.Equal("her gün, 31.10'a kadar", HatirlatmaUclari.TekrarMetni(1, 1, 0, T(10, 31).Date, T(10, 22)));
}
