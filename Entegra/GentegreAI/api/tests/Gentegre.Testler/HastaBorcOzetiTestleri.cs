using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// HASTA BORÇ ÖZETİ (19.11.2026: söz / plan başvuru bandı, tahsilat, icmal ve randevu kartında):
/// `GET /api/hasta-borc/hasta/{id}` açık sözü döner; randevu / başvuru görme yetkisi de yeter; borç yoksa vadesi geçmiş
/// söz "tutulmadi" sayılmaz (borç takibiyle aynı kural).
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HastaBorcOzetiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    [VtFact]
    public async Task Soz_ozeti_okunur_ve_borcsuzda_tutulmadi_sayilmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " Borçlu", Merkez]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        d.Temizle($"delete from public.hasta_borc_islem where hasta_id = {hasta}");

        // Söz yazan: borç takibi yetkisi.
        var rolY = await d.RolAsync("hbo-y", ["hasta.borc_takip:ged", "hasta:g"]);
        var (uy, kody) = await d.KullaniciAsync(rolY, Merkez);
        await d.SubeVerAsync(uy, Merkez, yazma: true, varsayilan: true);
        var (ay, _) = await api.GirisAsync(kody, TestDunyasi.Parola);
        using var hy = api.Istemci(ay, Merkez);
        var vade = DateTime.UtcNow.Date.AddDays(10).ToString("yyyy-MM-dd");
        var s = await hy.PostAsJsonAsync("/api/hasta-borc/soz", new { hastaId = hasta, tur = 3, tutar = 900m, vade, taksitSayisi = 3, aciklama = "maaş" });
        Assert.True(s.IsSuccessStatusCode, await s.Content.ReadAsStringAsync());

        // Okuyan: yalnız randevu görme (randevu kartı) - borç takibi yetkisi yok.
        var rolR = await d.RolAsync("hbo-r", ["randevu:g", "hasta:g"]);
        var (ur, kodr) = await d.KullaniciAsync(rolR, Merkez);
        await d.SubeVerAsync(ur, Merkez, yazma: false, varsayilan: true);
        var (ar, _) = await api.GirisAsync(kodr, TestDunyasi.Parola);
        using var hr = api.Istemci(ar, Merkez);
        var j = await hr.GetFromJsonAsync<JsonElement>($"/api/hasta-borc/hasta/{hasta}");
        var soz = j.GetProperty("soz");
        Assert.Equal(3, soz.GetProperty("tur").GetInt32());
        Assert.Equal(3, soz.GetProperty("taksitSayisi").GetInt32());
        Assert.Equal(900m, soz.GetProperty("tutar").GetDecimal());
        Assert.Equal("bekliyor", soz.GetProperty("durum").GetString());
        Assert.Equal(0m, j.GetProperty("borc").GetDecimal());

        // Vadesi geçti ama borç yok: tutulmadı DEĞİL.
        await api.Veri.CalistirAsync("update public.hasta_borc_islem set vade = current_date - 3 where hasta_id = @p0 and tur = 3", [hasta]);
        j = await hr.GetFromJsonAsync<JsonElement>($"/api/hasta-borc/hasta/{hasta}");
        Assert.Equal("bekliyor", j.GetProperty("soz").GetProperty("durum").GetString());

        // Hiç yetkisi olmayan (stok) okuyamaz.
        var rolS = await d.RolAsync("hbo-s", ["stok:g"]);
        var (us, kods) = await d.KullaniciAsync(rolS, Merkez);
        await d.SubeVerAsync(us, Merkez, yazma: false, varsayilan: true);
        var (as_, _) = await api.GirisAsync(kods, TestDunyasi.Parola);
        using var hs = api.Istemci(as_, Merkez);
        Assert.Equal(HttpStatusCode.Forbidden, (await hs.GetAsync($"/api/hasta-borc/hasta/{hasta}")).StatusCode);
    }
}
