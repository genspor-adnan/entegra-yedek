using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// KURUM TİPİNE GÖRE YENİ KAYIT VARSAYILANI (kullanıcı 15.11.2026: "görüntüleme ve lab profilde yeni randevu
/// açıldığında kartta randevu nedeni tetkik olarak gelmeli"): randevu kartının meta'sı görüntüleme / lab kurulumunda
/// tip = 3 (Tetkik), diğer kurumlarda katalog varsayılanı 1 (Muayene) döner. Kurum tipi test DB'de geçici değişir.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class KartKurumTipiVarsayilaniTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<List<(int Sube, string? Tip)>> TipYazAsync(string tip)
    {
        var eski = await api.Veri.ListeAsync("select sube_id, kurum_tipi from public.kurum_profil where sube_id in (0, @p0)",
            new object?[] { Merkez }, o => (o.GetInt32(0), o.IsDBNull(1) ? null : o.GetString(1)));
        await api.Veri.CalistirAsync("update public.kurum_profil set kurum_tipi = @p0 where sube_id in (0, @p1)", [tip, Merkez]);
        return eski;
    }

    private async Task TipGeriAsync(List<(int Sube, string? Tip)> eski)
    {
        foreach (var (sube, tip) in eski)
            await api.Veri.CalistirAsync("update public.kurum_profil set kurum_tipi = @p0 where sube_id = @p1", [tip, sube]);
    }

    private static async Task<int> RandevuTipVarsayilaniAsync(HttpClient h)
    {
        var y = await h.GetAsync("/api/kart/randevu/alanlar");
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {govde}");
        return JsonDocument.Parse(govde).RootElement.GetProperty("varsayilanlar").GetProperty("tip").GetInt32();
    }

    [VtTheory]
    [InlineData("goruntuleme", 3)]
    [InlineData("lab", 3)]
    [InlineData("tip_merkezi", 1)]
    [InlineData("hastane", 1)]
    public async Task Randevu_karti_kurum_tipine_gore_tip_varsayilani(string kurumTipi, int beklenen)
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("ktvars", ["randevu:ged"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        var h = api.Istemci(access, Merkez);

        var eski = await TipYazAsync(kurumTipi);
        try { Assert.Equal(beklenen, await RandevuTipVarsayilaniAsync(h)); }
        finally { await TipGeriAsync(eski); }
    }
}
