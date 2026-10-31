using System.Net;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K01/K02/K05/K07: hasta, lab, İSG özel uçları kaynak iznini kontrol edip kimlikle
/// okuyordu; portal rollerinde (hasta, dış kurum) o izinler var. Portal kullanıcısı yalnız KENDİ kaydını açabilmeli,
/// başkasınınki olmayan kayıtla aynı 404'ü almalı; TCKN / telefon → hasta çözücüsü portala kapalı olmalı.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class PortalKapsamTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<int> HastaAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id, vkno, durum) values (@p0, 1, 1, @p1, 1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], "9" + Random.Shared.NextInt64(100000000, 999999999)]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    /// <summary>Hastanın bir lab istemi + barkodlu numunesi.</summary>
    private async Task<(int Istem, string Barkod)> NumuneAsync(TestDunyasi d, int hasta)
    {
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, @p1, @p2, 1, 2, 3, 1) returning id
            """, [hasta, Merkez, d.Onek + "-" + Guid.NewGuid().ToString("N")[..6]]);
        var barkod = "T" + Guid.NewGuid().ToString("N")[..9].ToUpperInvariant();
        var numune = await api.Veri.TekDegerAsync<int>(
            "insert into public.lab_numune (barkod, istem_id, hasta_id, sube_id) values (@p0, @p1, @p2, @p3) returning id",
            [barkod, istem, hasta, Merkez]);
        d.Temizle($"delete from public.lab_numune where id = {numune}");
        d.Temizle($"delete from public.lab_istem where id = {istem}");
        return (istem, barkod);
    }

    private async Task<HttpClient> PortalAsync(TestDunyasi d, short portalTuru, string rolAdi, bool hasta, string[] yetkiler,
        Action<int>? kullaniciIdAl = null)
    {
        var rol = await d.RolAsync(rolAdi, yetkiler);
        await api.Veri.CalistirAsync("update public.rol set portal_turu = @p1 where id = @p0", [rol, portalTuru]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, hasta: hasta);
        await d.SubeVerAsync(u, Merkez, yazma: false, varsayilan: true);
        kullaniciIdAl?.Invoke(u);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    [VtFact]
    public async Task Portal_hastasi_baska_hastanin_ozetini_ve_numunesini_acamaz_mukerrer_kapali()
    {
        await using var d = new TestDunyasi(api.Veri);
        var kendiId = 0;
        using var h = await PortalAsync(d, 3, "portal-hasta", hasta: true,
            ["hasta:g", "lab:g", "lab.numune:g"], id => kendiId = id);
        var baska = await HastaAsync(d);
        var benimNumune = await NumuneAsync(d, kendiId);
        var baskaNumune = await NumuneAsync(d, baska);

        // Kendi kaydı açılır.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/hasta/{kendiId}/kart-ozeti")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/lab/numune/barkod/{benimNumune.Barkod}")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/lab/istem/{benimNumune.Istem}")).StatusCode);

        // Başkasının kaydı: olmayan kayıtla aynı 404.
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/hasta/{baska}/kart-ozeti")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync("/api/hasta/2147483000/kart-ozeti")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/lab/numune/barkod/{baskaNumune.Barkod}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync("/api/lab/numune/barkod/YOK000000")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/lab/istem/{baskaNumune.Istem}")).StatusCode);

        // TCKN → kimlik çözücüsü portala kapalı.
        var vkno = await api.Veri.TekDegerAsync<string>("select vkno from public.taraf where id = @p0", [baska]);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/hasta/mukerrer?rol=hasta&vkno={vkno}")).StatusCode);
    }

    [VtFact]
    public async Task Mukerrer_kontrolu_kurum_icinde_kart_yazma_yetkisi_ister()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var vkno = await api.Veri.TekDegerAsync<string>("select vkno from public.taraf where id = @p0", [hasta]);

        var salt = await d.RolAsync("salt-gor", "hasta:g");
        var (u1, k1) = await d.KullaniciAsync(salt, Merkez);
        await d.SubeVerAsync(u1, Merkez, yazma: true, varsayilan: true);
        var (a1, _) = await api.GirisAsync(k1, TestDunyasi.Parola);
        using var h1 = api.Istemci(a1, Merkez);
        Assert.Equal(HttpStatusCode.Forbidden, (await h1.GetAsync($"/api/hasta/mukerrer?rol=hasta&vkno={vkno}")).StatusCode);

        var yazar = await d.RolAsync("kayit-kabul", "hasta:ge");
        var (u2, k2) = await d.KullaniciAsync(yazar, Merkez);
        await d.SubeVerAsync(u2, Merkez, yazma: true, varsayilan: true);
        var (a2, _) = await api.GirisAsync(k2, TestDunyasi.Parola);
        using var h2 = api.Istemci(a2, Merkez);
        var y = await h2.GetAsync($"/api/hasta/mukerrer?rol=hasta&vkno={vkno}");
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        Assert.Contains(hasta.ToString(), await y.Content.ReadAsStringAsync());
    }

    [VtFact]
    public async Task Isg_firma_yetkilisi_baska_firmanin_calisanini_acamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var kendiId = 0;
        using var h = await PortalAsync(d, 2, "firma-yetkilisi", hasta: false,
            ["isg.firma:g", "isg.calisan:g"], id => kendiId = id);
        var baskaTaraf = await HastaAsync(d);

        async Task<(int Firma, int Calisan)> FirmaAsync(int tarafId)
        {
            var firma = await api.Veri.TekDegerAsync<int>(
                "insert into public.isg_firma (taraf_id, sube_id) values (@p0, @p1) returning id", [tarafId, Merkez]);
            var calisanHasta = await HastaAsync(d);
            var calisan = await api.Veri.TekDegerAsync<int>(
                "insert into public.isg_calisan (hasta_id, firma_id, sube_id) values (@p0, @p1, @p2) returning id",
                [calisanHasta, firma, Merkez]);
            d.Temizle($"delete from public.isg_calisan where id = {calisan}");
            d.Temizle($"delete from public.isg_firma where id = {firma}");
            return (firma, calisan);
        }
        var benim = await FirmaAsync(kendiId);
        var baska = await FirmaAsync(baskaTaraf);

        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/isg/firma/{benim.Firma}")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/isg/calisan/{benim.Calisan}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/isg/firma/{baska.Firma}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/isg/calisan/{baska.Calisan}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync("/api/isg/calisan/2147483000")).StatusCode);
    }
}
