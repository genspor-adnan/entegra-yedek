using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// BAŞVURU KURUM TİPİ KURALLARI (kod inceleme 16.11.2026): geliş nedeni varsayılanı, Sıra No ve Refakatçi görünürlüğü
/// tek yerde, sunucuda. Kullanıcı kuralları: lab / görüntüleme → geliş nedeni Tetkik (3); Sıra No lab / görüntüleme /
/// muayenehane'de yok; Refakatçi yalnız hastanede.
/// </summary>
public sealed class BasvuruKurumKurallariTestleri
{
    [Theory]
    [InlineData("lab", 3, false, false)]
    [InlineData("goruntuleme", 3, false, false)]
    [InlineData("goruntuleme_lab", 3, false, false)]
    [InlineData("muayenehane", null, false, false)]
    [InlineData("hastane", null, true, true)]
    [InlineData("tip_merkezi", null, true, false)]
    [InlineData("dis", null, true, false)]
    [InlineData(null, null, true, false)]
    public void Kurum_tipine_gore_kurallar(string? tip, int? gelisNedeni, bool siraNo, bool refakatci)
    {
        var k = BasvuruKurumKurallari.Icin(tip);
        Assert.Equal(gelisNedeni, k.GelisNedeniVarsayilan);
        Assert.Equal(siraNo, k.SiraNoVar);
        Assert.Equal(refakatci, k.RefakatciVar);
    }
}
