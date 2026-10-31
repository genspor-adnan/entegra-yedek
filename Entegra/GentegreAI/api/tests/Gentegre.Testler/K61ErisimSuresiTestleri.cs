using System.Text;
using System.Text.Json;
using Gentegre.Api.Servisler;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K61: erişim token'ı ayar ne olursa olsun en çok 60 dk geçerli
/// (`guvenlik.jwt_dakika` kurulumlarda 480 idi). Ayar değeri değiştirilmez, yalnız kodda üst sınır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K61ErisimSuresiTestleri(ApiSunucuOlgusu api)
{
    [Fact]
    public void Ayar_sinirlarin_icine_cekilir()
    {
        Assert.Equal(60, KimlikServisi.ErisimDakikasi(480));
        Assert.Equal(30, KimlikServisi.ErisimDakikasi(30));
        Assert.Equal(5, KimlikServisi.ErisimDakikasi(0));
    }

    [VtFact]
    public async Task Giris_tokeni_60_dakikadan_uzun_degil()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("k61", ["hasta:g"]);
        var (_, kod) = await d.KullaniciAsync(rol, 1);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);

        var govde = access.Split('.')[1].Replace('-', '+').Replace('_', '/');
        govde = govde.PadRight(govde.Length + (4 - govde.Length % 4) % 4, '=');
        using var j = JsonDocument.Parse(Encoding.UTF8.GetString(Convert.FromBase64String(govde)));
        var sure = j.RootElement.GetProperty("exp").GetInt64() - DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        Assert.InRange(sure, 1, KimlikServisi.EnFazlaErisimDakika * 60 + 5);
    }
}
