using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K26 / K16 (acil, ameliyathane, göz): kurum içi özel uçlar kaynak iznini
/// kontrol edip kimlikle okuyor / yazıyordu. Merkez şubesinde çalışan kullanıcı Ankara'nın acil başvurusunu,
/// ameliyatını ve göz akış satırını kimlikle açamamalı (olmayan kayıtla AYNI 404, yan etki yok); "sıradakini çağır"
/// başka şubenin bekleyenini çağırmamalı; salt-okuma şubesinde göz muayenesi açma (INSERT) 403 almalı.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K26KapsamKlinikTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int Ankara = 3;

    private async Task<int> HastaAsync(TestDunyasi d, int sube = Merkez)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], sube]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    /// <summary>Triyajı 3 (sarı) yapılmış, çıkışı olmayan acil başvurusu.</summary>
    private async Task<long> AcilBasvuruAsync(TestDunyasi d, int hasta, int sube)
    {
        var id = await api.Veri.TekDegerAsync<long>("""
            insert into public.acil_basvuru (sube_id, hasta_id, triyaj, triyaj_zamani, sikayet, ekleyen)
            values (@p0, @p1, 3, now(), 'test', 0) returning id
            """, [sube, hasta]);
        d.Temizle($"delete from public.acil_triyaj_gecmis where basvuru_id = {id}");
        d.Temizle($"delete from public.acil_cagri where basvuru_id = {id}");
        d.Temizle($"delete from public.acil_basvuru where id = {id}");
        return id;
    }

    /// <summary>Planlanmış (durum 0) ameliyat; numarayı tetik yazar.</summary>
    private async Task<long> AmeliyatAsync(TestDunyasi d, int hasta, int sube)
    {
        var id = await api.Veri.TekDegerAsync<long>("""
            insert into public.ameliyat (sube_id, hasta_id, durum, plan_baslangic, plan_sure_dk, ekleyen)
            values (@p0, @p1, 0, now(), 60, 0) returning id
            """, [sube, hasta]);
        d.Temizle($"delete from public.ameliyat_kontrol where ameliyat_id = {id}");
        d.Temizle($"delete from public.ameliyat where id = {id}");
        return id;
    }

    /// <summary>Başvuru (belge tür 19) + göz ünitesinde AÇIK akış satırı (istasyon, çağrılmamış, dilatasyonsuz).</summary>
    private async Task<(int Belge, int Akis)> GozAkisAsync(TestDunyasi d, int hasta, int sube, short istasyon = 1,
                                                           string giris = "now()")
    {
        var belge = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi) values (19, 30, @p0, @p1, now()) returning id",
            [hasta, sube]);
        // Giriş zamanı fikstüre göre: "en uzun bekleyen" sırası testte belirleyici.
        var akis = await api.Veri.TekDegerAsync<int>($"""
            insert into public.goz_ziyaret_istasyon (sube_id, belge_id, hasta_id, istasyon, giris, sira_no, ekleyen)
            values (@p0, @p1, @p2, @p3, {giris}, 1, 0) returning id
            """, [sube, belge, hasta, istasyon]);
        d.Temizle($"delete from public.goz_ziyaret_istasyon where belge_id = {belge}");
        d.Temizle($"delete from public.goz_muayene where muayene_id in (select id from public.muayene where belge_id = {belge})");
        d.Temizle($"delete from public.muayene where belge_id = {belge}");
        d.Temizle($"delete from public.belge_basvuru where id = {belge}");
        d.Temizle($"delete from public.belge where id = {belge}");
        return (belge, akis);
    }

    /// <summary>Merkez'de çalışan klinik kullanıcı: acil + ameliyathane + göz yetkileri; şube yazma hakkı parametre.</summary>
    private async Task<HttpClient> MerkezIstemcisiAsync(TestDunyasi d, bool yazma = true)
    {
        var rol = await d.RolAsync("klinik",
            "acil.basvuru:gd", "acil.triyaj:gd", "ameliyathane.ameliyat:gd", "goz:gd", "goz.muayene:ged", "hasta:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: yazma, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    [VtFact]
    public async Task Baska_subenin_acil_basvurusu_ameliyati_ve_goz_akisi_kimlikle_acilamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var acilA = await AcilBasvuruAsync(d, hasta, Merkez);
        var acilB = await AcilBasvuruAsync(d, hasta, Ankara);
        var amelA = await AmeliyatAsync(d, hasta, Merkez);
        var amelB = await AmeliyatAsync(d, hasta, Ankara);
        var gozA = await GozAkisAsync(d, hasta, Merkez);
        var gozB = await GozAkisAsync(d, hasta, Ankara);
        using var h = await MerkezIstemcisiAsync(d);

        // Kendi şubesi açılır.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/acil/basvuru/{acilA}/sure")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/ameliyathane/ameliyat/{amelA}/akis")).StatusCode);
        Assert.Equal(HttpStatusCode.OK,
            (await h.PostAsJsonAsync($"/api/goz/akis/{gozA.Akis}/dilatasyon", new { ilac = "tropikamid" })).StatusCode);

        // Başka şube: var olmayan kayıtla aynı 404 - okuma ve yazma.
        foreach (var yol in new[]
        {
            $"/api/acil/basvuru/{acilB}/sure", "/api/acil/basvuru/2147483000/sure",
            $"/api/ameliyathane/ameliyat/{amelB}/akis", "/api/ameliyathane/ameliyat/2147483000/akis",
            $"/api/ameliyathane/ameliyat/{amelB}/kontrol",
        })
            Assert.True((await h.GetAsync(yol)).StatusCode == HttpStatusCode.NotFound, yol);

        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync($"/api/acil/basvuru/{acilB}/triyaj", new { duzey = 1 })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync($"/api/ameliyathane/ameliyat/{amelB}/kontrol", new { yanitlar = Array.Empty<object>() })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync($"/api/goz/akis/{gozB.Akis}/dilatasyon", new { ilac = "tropikamid" })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsync($"/api/goz/akis/{gozB.Akis}/muayene", null)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsync("/api/goz/akis/2147483000/muayene", null)).StatusCode);

        // Yan etki yok: Ankara'nın triyajı, dilatasyonu ve kontrol listesi değişmedi; muayene açılmadı.
        Assert.Equal(3, await api.Veri.TekDegerAsync<int>(
            "select triyaj::int from public.acil_basvuru where id = @p0", [acilB]));
        Assert.True(await api.Veri.TekDegerAsync<bool>(
            "select dilatasyon_zamani is null from public.goz_ziyaret_istasyon where id = @p0", [gozB.Akis]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.ameliyat_kontrol where ameliyat_id = @p0", [amelB]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.muayene where belge_id = @p0", [gozB.Belge]));
    }

    [VtFact]
    public async Task Siradakini_cagir_baska_subenin_bekleyenini_cagirmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        // Ankara'nın hastası EN UZUN bekleyen (10 yıl): şube sınırı olmasa "sıradaki" o olurdu.
        var ankara = await GozAkisAsync(d, hasta, Ankara, istasyon: 2, giris: "now() - interval '10 years'");
        var merkez = await GozAkisAsync(d, hasta, Merkez, istasyon: 2);
        using var h = await MerkezIstemcisiAsync(d);

        var y = await h.PostAsync("/api/goz/akis/cagir?istasyon=2", null);
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        var j = await y.Content.ReadFromJsonAsync<JsonElement>();
        var cagrilan = j.GetProperty("id").GetInt32();
        Assert.NotEqual(ankara.Akis, cagrilan);

        // Ankara'nın satırına çağrı damgası düşmedi.
        Assert.True(await api.Veri.TekDegerAsync<bool>(
            "select cagri_zamani is null from public.goz_ziyaret_istasyon where id = @p0", [ankara.Akis]));
        _ = merkez;
    }

    [VtFact]
    public async Task Salt_okuma_subesinde_goz_muayenesi_acilamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var akis = await GozAkisAsync(d, hasta, Merkez);
        // Rol yetkisi var (goz.muayene:ged) ama Merkez'de kullanici_sube.yazma = 0.
        using var h = await MerkezIstemcisiAsync(d, yazma: false);

        var y = await h.PostAsync($"/api/goz/akis/{akis.Akis}/muayene", null);
        Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);

        // INSERT olmadı: muayene numarası tüketilmedi, göz uzantısı açılmadı.
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.muayene where belge_id = @p0", [akis.Belge]));
    }
}
