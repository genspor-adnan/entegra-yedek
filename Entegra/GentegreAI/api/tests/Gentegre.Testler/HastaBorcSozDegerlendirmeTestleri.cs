using Gentegre.Api.Uclar;
using O = Gentegre.Api.Uclar.HastaBorcSozDegerlendirme.Odeme;

namespace Gentegre.Testler;

/// <summary>
/// ÖDEME SÖZÜ / PLANI DEĞERLENDİRMESİ (kullanıcı 19.11.2026: "borç bir kısmı veya tamamı ödendiğinde söz kaydı nasıl
/// azalacak/kalkacak?"): söz sonrası tahsilat sözden düşülür; tamamı ya da borç kapanınca tutuldu; plan taksitleri sırayla.
/// </summary>
public sealed class HastaBorcSozDegerlendirmeTestleri
{
    private static readonly DateTime Bugun = new(2026, 11, 19);
    private static readonly DateTime SozAni = new(2026, 11, 1, 9, 0, 0, DateTimeKind.Utc);
    private static O Od(int gun, decimal tutar) => new(1, SozAni.AddDays(gun), tutar);

    [Fact]
    public void Soz_kismi_odeme_kalan_duser_vade_gecince_tutulmadi()
    {
        var gelecek = HastaBorcSozDegerlendirme.Degerlendir(2, 1000m, Bugun.AddDays(5), null, SozAni, 1500m, [Od(2, 600m)], Bugun);
        Assert.Equal("bekliyor", gelecek.Durum);
        Assert.Equal(600m, gelecek.Odenen);
        Assert.Equal(400m, gelecek.Kalan);

        var gecmis = HastaBorcSozDegerlendirme.Degerlendir(2, 1000m, Bugun.AddDays(-1), null, SozAni, 1500m, [Od(2, 600m)], Bugun);
        Assert.Equal("tutulmadi", gecmis.Durum);
    }

    [Fact]
    public void Soz_tutari_odenince_ya_da_borc_kapaninca_tutuldu_soz_oncesi_odeme_sayilmaz()
    {
        Assert.Equal("tutuldu", HastaBorcSozDegerlendirme.Degerlendir(2, 1000m, Bugun.AddDays(-3), null, SozAni, 200m,
            [Od(1, 700m), Od(4, 300m)], Bugun).Durum);
        Assert.Equal("tutuldu", HastaBorcSozDegerlendirme.Degerlendir(2, 1000m, Bugun.AddDays(-3), null, SozAni, 0m, [], Bugun).Durum);
        // Söz verilmeden ÖNCE alınan ödeme söze sayılmaz; iade (eksi) düşer.
        var d = HastaBorcSozDegerlendirme.Degerlendir(2, 1000m, Bugun.AddDays(3), null, SozAni, 900m,
            [Od(-1, 500m), Od(2, 400m), Od(3, -100m)], Bugun);
        Assert.Equal(300m, d.Odenen);
        Assert.Equal(700m, d.Kalan);
    }

    [Fact]
    public void Plan_taksitler_sirayla_gecikme_ve_sonraki()
    {
        // 900 / 3 taksit, ilk 05.11 (geçti), 05.12, 05.01. 300 ödendi: 1/3, gecikme yok, sonraki 05.12 300.
        var ilk = new DateTime(2026, 11, 5);
        var a = HastaBorcSozDegerlendirme.Degerlendir(3, 900m, ilk, 3, SozAni, 900m, [Od(3, 300m)], Bugun);
        Assert.Equal("bekliyor", a.Durum);
        Assert.Equal(1, a.OdenenTaksit);
        Assert.Equal(0, a.GecikenTaksit);
        Assert.Equal(new DateTime(2026, 12, 5), a.SonrakiVade);
        Assert.Equal(300m, a.SonrakiTutar);

        // Hiç ödenmedi: ilk taksit gecikti.
        var b = HastaBorcSozDegerlendirme.Degerlendir(3, 900m, ilk, 3, SozAni, 900m, [], Bugun);
        Assert.Equal("tutulmadi", b.Durum);
        Assert.Equal(1, b.GecikenTaksit);

        // Kısmi (150): sonraki taksitten kalan 150.
        var c = HastaBorcSozDegerlendirme.Degerlendir(3, 900m, ilk, 3, SozAni, 900m, [Od(3, 150m)], Bugun);
        Assert.Equal(0, c.OdenenTaksit);
        Assert.Equal(150m, c.SonrakiTutar);

        // Kuruş farkı son taksitte; tamamı ödendi -> tutuldu.
        var t = HastaBorcSozDegerlendirme.Degerlendir(3, 1000m, ilk, 3, SozAni, 50m, [Od(3, 1000m)], Bugun);
        Assert.Equal("tutuldu", t.Durum);
        Assert.Equal(3, t.OdenenTaksit);
        Assert.Null(t.SonrakiVade);
    }
}
