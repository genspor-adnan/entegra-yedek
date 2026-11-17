using System.Net;
using System.Net.Http.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// HASTA VERİSİ ve PARA incelemeleri (18.11.2026) düzeltmeleri:
///  * Hasta icmali, KVKK durumu, e-Nabız erişimi hasta kayıt kapısından geçer (portal hastası başkasınınkini açamaz);
///    e-Nabız erişim anahtarı yalnız oturum sahibi adına; hastanın belgesi yalnız `cari` yetkisiyle açılmaz.
///  * Dip toplam (1366): iki iskontolu KDV, web tevkifatı, KDV dahil iskonto.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HastaVerisiVeDipToplamTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<int> HastaAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, musteri, sube_id, vkno, durum) values (@p0, 1, 1, 1, @p1, 1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], "9" + Random.Shared.NextInt64(100000000, 999999999)]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    private async Task<HttpClient> PortalHastaAsync(TestDunyasi d, Action<int> kendi)
    {
        var rol = await d.RolAsync("portal-hasta", "hasta:g", "belge:g", "enabiz.erisim:gd");
        await api.Veri.CalistirAsync("update public.rol set portal_turu = 3 where id = @p0", [rol]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, hasta: true);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        kendi(u);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private async Task<(HttpClient H, int Id)> IcKullaniciAsync(TestDunyasi d, string ad, params string[] yetkiler)
    {
        var rol = await d.RolAsync(ad, yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return (api.Istemci(access, Merkez), u);
    }

    [VtFact]
    public async Task Portal_hastasi_baskasinin_icmalini_ve_kvkk_durumunu_acamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var kendi = 0;
        using var h = await PortalHastaAsync(d, id => kendi = id);
        var baska = await HastaAsync(d);

        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/hasta-icmal/{kendi}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/hasta-icmal/{baska}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/basvuru/kvkk-durum?hastaId={baska}")).StatusCode);
        // e-Nabız erişim anahtarı: başkasının hastası için alınamaz (Bakanlığa istek gitmeden 404).
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync("/api/enabiz/erisim", new { hastaId = baska })).StatusCode);
    }

    [VtFact]
    public async Task e_Nabiz_erisimi_baska_hekim_adina_acilamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (h, _) = await IcKullaniciAsync(d, "sekreter", "hasta:g", "enabiz.erisim:gd");
        var (_, hekim) = await IcKullaniciAsync(d, "hekim", "hasta:g");
        var hasta = await HastaAsync(d);
        using (h)
        {
            var y = await h.PostAsJsonAsync("/api/enabiz/erisim", new { hastaId = hasta, hekimId = hekim });
            Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);
        }
    }

    [VtFact]
    public async Task Hastanin_belgesi_yalniz_cari_yetkisiyle_acilmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (finans, _) = await IcKullaniciAsync(d, "finans", "cari:g");
        var hasta = await HastaAsync(d);
        using (finans)
        {
            // Aktarımda hastalar müşteri işaretli: cari listesinde görünür ama belgesi hasta verisidir.
            var y = await finans.GetAsync($"/api/dokuman/taraf/{hasta}");
            Assert.Equal(HttpStatusCode.NotFound, y.StatusCode == HttpStatusCode.Forbidden ? HttpStatusCode.NotFound : y.StatusCode);
        }
    }

    [VtFact]
    public async Task Dip_toplam_iki_iskonto_web_tevkifati_ve_dahil_iskonto()
    {
        await using var b = await api.Veri.AcAsync();
        await using var tx = await b.BeginTransactionAsync();   // her şey geri alınır
        var taraf = await b.TekDegerAsync<int>("select min(id) from public.taraf", tx, []);
        async Task<int> BelgeAsync(string kdvDurum, short tur, short tipi) => await b.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no, kdv_durum, belge_dovizi, rapor_dovizi, doviz_kuru)
            values (@p0, @p1, 0, now(), @p2, 1, 'DIPTEST', @p3, 'TL', 'TL', 1) returning id
            """, tx, [tur, tipi, taraf, kdvDurum]);
        async Task<double> Deger(int belge, int dTur) => await b.TekDegerAsync<double>(
            "select d_deger from public.fn_belge_diptoplam(@p0) where d_tur = @p1", tx, [belge, (double)dTur]);

        // 1) Hariç, 13 x 65, %10 + %5, KDV %10: matrah 722,48 -> KDV 72,25, genel 794,73.
        var b1 = await BelgeAsync("Hariç", 15, 1);
        await b.CalistirAsync("""
            insert into public.belge_satir (belge_id, sira, tur, adet, miktar, birim_fiyat, iskonto, iskonto2, kdv, tutar, doviz_birim_fiyat, sube_id)
            values (@p0, 1, 2, 13, 13, 65, 10, 5, 10, 722.48, 65, 1)
            """, tx, [b1]);
        Assert.Equal(72.25, await Deger(b1, 5), 2);
        Assert.Equal(794.73, await Deger(b1, 20), 2);

        // 2) Web tevkifatı: matrah 1000, KDV %20, 4/10 -> KDV Toplam 200 (tam), genel 1120.
        var b2 = await BelgeAsync("Hariç", 15, 1);
        await b.CalistirAsync("""
            insert into public.belge_satir (belge_id, sira, tur, adet, miktar, birim_fiyat, kdv, tutar, doviz_birim_fiyat, tevkifat_orani, sube_id)
            values (@p0, 1, 2, 1, 1, 1000, 20, 1000, 1000, 40, 1)
            """, tx, [b2]);
        Assert.Equal(200, await Deger(b2, 15), 2);
        Assert.Equal(1120, await Deger(b2, 20), 2);

        // 3) Dahil, 110 brüt, KDV %10, %10 iskonto -> iskonto 10,00, genel 99,00.
        var b3 = await BelgeAsync("Dahil", 19, 30);
        await b.CalistirAsync("""
            insert into public.belge_satir (belge_id, sira, tur, adet, miktar, birim_fiyat, birim_fiyat_kdvli, iskonto, kdv, tutar, tutar_kdvli, doviz_birim_fiyat, sube_id)
            values (@p0, 1, 2, 1, 1, 100, 110, 10, 10, 90, 99, 100, 1)
            """, tx, [b3]);
        Assert.Equal(10, await Deger(b3, 3), 2);
        Assert.Equal(99, await Deger(b3, 20), 2);
        await tx.RollbackAsync();
    }
}
