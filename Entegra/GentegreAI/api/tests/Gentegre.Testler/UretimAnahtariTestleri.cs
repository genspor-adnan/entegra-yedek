using Gentegre.Api.Servisler;

namespace Gentegre.Testler;

/// <summary>
/// ÜRETİM ANAHTAR KAPISI (kod inceleme raporu 28.10.2026 B01): Production'da boş, kısa ya da depodaki geliştirme
/// anahtarıyla API açılmaz; geliştirmede kontrol yok.
/// </summary>
public class UretimAnahtariTestleri
{
    [Theory]
    [InlineData("")]
    [InlineData("kisa-anahtar")]
    [InlineData("gelistirme-imza-anahtari-en-az-32-karakter-olmali-degistir")]
    public void Uretimde_zayif_anahtar_reddedilir(string anahtar)
        => Assert.Throws<InvalidOperationException>(() => GuvenlikAyarlari.UretimAnahtariniDogrula(anahtar, uretim: true));

    [Fact]
    public void Uretimde_guclu_anahtar_ve_gelistirmede_her_anahtar_gecer()
    {
        GuvenlikAyarlari.UretimAnahtariniDogrula(Convert.ToBase64String(new byte[48].Select((_, i) => (byte)(i * 7 + 3)).ToArray()), uretim: true);
        GuvenlikAyarlari.UretimAnahtariniDogrula("gelistirme-imza-anahtari-en-az-32-karakter-olmali-degistir", uretim: false);
    }

    [Fact]
    public void Depodaki_appsettings_gelistirme_anahtarini_tasir_ve_uretimde_reddedilir()
    {
        var d = new DirectoryInfo(AppContext.BaseDirectory);
        while (d != null && !File.Exists(Path.Combine(d.FullName, "src", "Gentegre.Api", "appsettings.json"))) d = d.Parent;
        Assert.NotNull(d);
        var json = File.ReadAllText(Path.Combine(d!.FullName, "src", "Gentegre.Api", "appsettings.json"));
        var anahtar = System.Text.Json.JsonDocument.Parse(json).RootElement.GetProperty("Guvenlik").GetProperty("ImzaAnahtari").GetString();
        Assert.Throws<InvalidOperationException>(() => GuvenlikAyarlari.UretimAnahtariniDogrula(anahtar, uretim: true));
    }
}
