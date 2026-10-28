using System.Net;
using System.Net.Http.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 28.10.2026 — B02: radyoloji özel uçları kayıt kapsamını atlıyordu. A şubesinde çalışan,
/// B şubesine izni olmayan kullanıcı B'nin istemini kimliğiyle okuyamamalı / yazamamalı / onaylayamamalı;
/// cevap var olmayan kayıtla AYNI 404 olmalı ve yan etki bırakmamalı.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class RadyolojiErisimTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int Ankara = 3;

    private async Task<(int Istem, int Rapor)> IstemAsync(TestDunyasi d, int hasta, int sube)
    {
        var hizmet = await api.Veri.TekDegerAsync<int>("select min(id) from public.hizmet where coalesce(modalite, 0) > 0 and coalesce(cinsiyet, 0) = 0");
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (hasta_id, hizmet_id, accession_no, sube_id, durum, serbest)
            values (@p0, @p1, @p2, @p3, 3, 1) returning id
            """, [hasta, hizmet, d.Onek + "-" + Guid.NewGuid().ToString("N")[..6], sube]);
        var rapor = await api.Veri.TekDegerAsync<int>(
            "insert into public.radyoloji_rapor (istem_id, durum) values (@p0, 1) returning id", [istem]);
        await api.Veri.CalistirAsync(
            "insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir) values (@p0, 1, 'Bulgular', 'özgün', 1)",
            [rapor]);
        d.Temizle($"delete from public.radyoloji_rapor where istem_id = {istem}");
        d.Temizle($"delete from public.radyoloji_istem where id = {istem}");
        return (istem, rapor);
    }

    private async Task<int> HastaAsync(TestDunyasi d, int sube = Merkez)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], sube]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    [VtFact]
    public async Task Baska_subenin_radyoloji_istemi_okunamaz_yazilamaz_onaylanamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var a = await IstemAsync(d, hasta, Merkez);
        var b = await IstemAsync(d, hasta, Ankara);

        var rol = await d.RolAsync("radyoloji", "radyoloji:gde", "radyoloji-istem:gde", "rad.rapor_yaz", "rad.rapor_onayla");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        // Kendi şubesi açılır.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/radyoloji/istem/{a.Istem}/rapor")).StatusCode);

        // Başka şube: var olmayan kayıtla aynı 404.
        foreach (var yol in new[]
        {
            $"/api/radyoloji/istem/{b.Istem}/rapor", $"/api/radyoloji/istem/{b.Istem}/kart-detay",
            $"/api/radyoloji/istem/{b.Istem}/akis", $"/api/radyoloji/rapor/{b.Rapor}/cikti",
            "/api/radyoloji/istem/2147483000/rapor",
        })
            Assert.True((await h.GetAsync(yol)).StatusCode == HttpStatusCode.NotFound, yol);

        var yaz = await h.PostAsJsonAsync($"/api/radyoloji/istem/{b.Istem}/rapor",
            new { bolumler = new[] { new { sira = 1, baslik = "Bulgular", metin = "ezildi", yazdir = 1 } } });
        Assert.Equal(HttpStatusCode.NotFound, yaz.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsync($"/api/radyoloji/rapor/{b.Rapor}/durum?hedef=onay", null)).StatusCode);

        // Yan etki yok: B'nin metni ve durumu değişmedi.
        Assert.Equal("özgün", await api.Veri.TekDegerAsync<string>(
            "select metin from public.radyoloji_rapor_bolum where rapor_id = @p0", [b.Rapor]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select durum::int from public.radyoloji_rapor where id = @p0", [b.Rapor]));
    }
    private async Task<HttpClient> MerkezIstemcisiAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("radyoloji", "radyoloji:gde", "radyoloji-istem:gde", "hasta:g", "rad.istem_ac", "rad.rapor_yaz");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    /// <summary>
    /// PORTAL HASTASI (portal_turu 3): hasta kaynağının kapsamı yalnız kendisi. Kurum içi kullanıcı için hasta
    /// şubeler arası ortaktır - "kapsam dışı hasta" portal kullanıcısında oluşur.
    /// </summary>
    private async Task<(HttpClient H, int Kendi)> PortalIstemcisiAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("portal", "radyoloji:gde", "radyoloji-istem:gde", "hasta:g", "rad.istem_ac");
        await api.Veri.CalistirAsync("update public.rol set portal_turu = 3 where id = @p0", [rol]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, hasta: true);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return (api.Istemci(access, Merkez), u);
    }

    [VtFact]
    public async Task Istem_secenekleri_kapsam_disi_hastanin_gecmisini_vermez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var ortak = await HastaAsync(d);
        var a = await IstemAsync(d, ortak, Merkez);
        var b = await IstemAsync(d, ortak, Ankara);
        using var h = await MerkezIstemcisiAsync(d);

        // Kapsamdaki hasta: geçmişte yalnız kendi şubesinin istemi (Ankara istemi sayılmaz).
        var y = await h.GetAsync($"/api/radyoloji/istem-secenekleri?hastaId={ortak}");
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        var gecmis = (await y.Content.ReadFromJsonAsync<System.Text.Json.JsonElement>()).GetProperty("gecmis");
        Assert.Equal(1, gecmis.GetArrayLength());

        _ = (a, b);

        // Portal hastası: kendi geçmişi açılır; başka hasta (istemi olsa da) ve olmayan hasta aynı 404.
        var (p, kendi) = await PortalIstemcisiAsync(d);
        using var _p = p;
        await IstemAsync(d, kendi, Merkez);
        Assert.Equal(HttpStatusCode.OK, (await p.GetAsync($"/api/radyoloji/istem-secenekleri?hastaId={kendi}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await p.GetAsync($"/api/radyoloji/istem-secenekleri?hastaId={ortak}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await p.GetAsync("/api/radyoloji/istem-secenekleri?hastaId=2147483000")).StatusCode);
    }

    [VtFact]
    public async Task Kapsam_disi_hastaya_ve_baskasinin_basvurusuna_istem_acilamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var benim = await HastaAsync(d);
        var disari = await HastaAsync(d);
        var hizmet = await api.Veri.TekDegerAsync<int>(
            "select min(id) from public.hizmet where coalesce(modalite, 0) > 0 and coalesce(cinsiyet, 0) = 0");
        // Ankara şubesinde benim hastama açılmış başvuru (başkasının başvurusu).
        var belge = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi) values (19, 30, @p0, @p1, now()) returning id",
            [benim, Ankara]);
        d.Temizle($"delete from public.belge where id = {belge}");
        d.Temizle($"delete from public.radyoloji_istem where hasta_id in ({benim}, {disari})");
        using var h = await MerkezIstemcisiAsync(d);
        var (p, _) = await PortalIstemcisiAsync(d);
        using var _p = p;

        object Istek(int hasta, int? belgeId) => new
        {
            hastaId = hasta, belgeId, klinikBilgi = "test", basvuruAc = false,
            tetkikler = new[] { new { hizmetId = hizmet } },
        };
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync("/api/radyoloji/istem", Istek(benim, belge))).StatusCode);
        // Portal hastası başka hastaya istem açamaz.
        Assert.Equal(HttpStatusCode.NotFound,
            (await p.PostAsJsonAsync("/api/radyoloji/istem", Istek(disari, null))).StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.radyoloji_istem where hasta_id in (@p0, @p1)", [benim, disari]));
    }
}
