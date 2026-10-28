using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 28.10.2026 — B04 (kayıp güncelleme / onayla yarışma) ve B06 (kilitli raporda istemin geriye
/// alınması). Aynı sürümle iki kayıttan yalnız biri geçer; onaylı rapora ön rapor ve tanımsız hedef reddedilir,
/// rapor / istem değişmez.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class RadyolojiRaporYarisTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(int Istem, int Rapor)> IstemAsync(TestDunyasi d, bool onayli)
    {
        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, 1) returning id", [d.Onek + " hasta"]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var hizmet = await api.Veri.TekDegerAsync<int>(
            "select min(id) from public.hizmet where coalesce(modalite, 0) > 0 and coalesce(cinsiyet, 0) = 0");
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (hasta_id, hizmet_id, accession_no, sube_id, durum, serbest)
            values (@p0, @p1, @p2, @p3, @p4, 1) returning id
            """, [hasta, hizmet, d.Onek + "-" + Guid.NewGuid().ToString("N")[..6], Merkez, (short)(onayli ? 5 : 3)]);
        var rapor = await api.Veri.TekDegerAsync<int>(
            "insert into public.radyoloji_rapor (istem_id, durum, kilit) values (@p0, @p1, @p2) returning id",
            [istem, (short)(onayli ? 3 : 1), (short)(onayli ? 1 : 0)]);
        await api.Veri.CalistirAsync(
            "insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir) values (@p0, 1, 'Bulgular', 'özgün', 1)", [rapor]);
        d.Temizle($"delete from public.radyoloji_rapor where istem_id = {istem}");
        d.Temizle($"delete from public.radyoloji_istem where id = {istem}");
        return (istem, rapor);
    }

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("rad", "radyoloji:gde", "radyoloji-istem:gde", "rad.rapor_yaz", "rad.rapor_onayla");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private static object Govde(string metin, string? surum)
        => new { surum, bolumler = new[] { new { sira = 1, baslik = "Bulgular", metin, yazdir = 1 } } };

    [VtFact]
    public async Task Ayni_surumle_iki_kayittan_yalniz_biri_gecer()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (istem, rapor) = await IstemAsync(d, onayli: false);
        using var h = await IstemciAsync(d);

        var oku = await h.GetFromJsonAsync<JsonElement>($"/api/radyoloji/istem/{istem}/rapor");
        var surum = oku.GetProperty("rapor").GetProperty("surum").GetString();
        Assert.False(string.IsNullOrEmpty(surum));

        Assert.Equal(HttpStatusCode.OK, (await h.PostAsJsonAsync($"/api/radyoloji/istem/{istem}/rapor", Govde("birinci", surum))).StatusCode);
        // Aynı (artık eski) sürümle ikinci kayıt: 409, birincinin metni korunur.
        Assert.Equal(HttpStatusCode.Conflict, (await h.PostAsJsonAsync($"/api/radyoloji/istem/{istem}/rapor", Govde("ikinci", surum))).StatusCode);
        // Sürümsüz kayıt da kayıtlı raporu ezemez.
        Assert.Equal(HttpStatusCode.Conflict, (await h.PostAsJsonAsync($"/api/radyoloji/istem/{istem}/rapor", Govde("ucuncu", null))).StatusCode);
        Assert.Equal("birinci", await api.Veri.TekDegerAsync<string>(
            "select metin from public.radyoloji_rapor_bolum where rapor_id = @p0", [rapor]));
    }

    [VtFact]
    public async Task Onayli_rapora_on_rapor_ve_tanimsiz_hedef_reddedilir_istem_degismez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (istem, rapor) = await IstemAsync(d, onayli: true);
        using var h = await IstemciAsync(d);

        var onRapor = await h.PostAsync($"/api/radyoloji/rapor/{rapor}/durum?hedef=on-rapor", null);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, onRapor.StatusCode);
        var tanimsiz = await h.PostAsync($"/api/radyoloji/rapor/{rapor}/durum?hedef=xyz", null);
        Assert.Equal(HttpStatusCode.BadRequest, tanimsiz.StatusCode);

        Assert.Equal(5, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_istem where id = @p0", [istem]));
        Assert.Equal(3, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_rapor where id = @p0", [rapor]));
        // Kilitli rapor kaydı da reddedilir, metin değişmez.
        var oku = await h.GetFromJsonAsync<JsonElement>($"/api/radyoloji/istem/{istem}/rapor");
        var surum = oku.GetProperty("rapor").GetProperty("surum").GetString();
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await h.PostAsJsonAsync($"/api/radyoloji/istem/{istem}/rapor", Govde("ezme", surum))).StatusCode);
        Assert.Equal("özgün", await api.Veri.TekDegerAsync<string>(
            "select metin from public.radyoloji_rapor_bolum where rapor_id = @p0", [rapor]));
    }
    [VtFact]
    public async Task Onay_ve_on_rapor_arada_degisen_metni_kabul_etmez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (istem, rapor) = await IstemAsync(d, onayli: false);
        using var h = await IstemciAsync(d);

        // Uzman raporu açtı (s0); radyolog arada kaydetti (s1).
        var s0 = (await h.GetFromJsonAsync<JsonElement>($"/api/radyoloji/istem/{istem}/rapor"))
            .GetProperty("rapor").GetProperty("surum").GetString()!;
        var kayit = await h.PostAsJsonAsync($"/api/radyoloji/istem/{istem}/rapor", Govde("radyolog metni", s0));
        Assert.Equal(HttpStatusCode.OK, kayit.StatusCode);
        var s1 = (await kayit.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("surum").GetString()!;
        Assert.NotEqual(s0, s1);

        // Uzmanın gördüğü (eski) sürümle ve sürümsüz: 409, durum değişmez.
        Assert.Equal(HttpStatusCode.Conflict, (await h.PostAsync($"/api/radyoloji/rapor/{rapor}/durum?hedef=on-rapor&surum={s0}", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await h.PostAsync($"/api/radyoloji/rapor/{rapor}/durum?hedef=onay&surum={s0}", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await h.PostAsync($"/api/radyoloji/rapor/{rapor}/durum?hedef=on-rapor", null)).StatusCode);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_rapor where id = @p0", [rapor]));
        Assert.Equal(3, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_istem where id = @p0", [istem]));

        // Kaydın döndürdüğü güncel sürümle geçer.
        Assert.Equal(HttpStatusCode.OK, (await h.PostAsync($"/api/radyoloji/rapor/{rapor}/durum?hedef=on-rapor&surum={s1}", null)).StatusCode);
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_rapor where id = @p0", [rapor]));
    }
}
