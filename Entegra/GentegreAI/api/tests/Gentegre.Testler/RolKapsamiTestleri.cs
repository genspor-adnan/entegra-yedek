using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// ROL KAPSAMI (RolKapsami; kullanıcı 10.11.2026: "temsilci sadece kendi doktorlarını ve kendi ziyaretlerini görecek,
/// sorumlu ve yönetici hepsini"): rolü yalnız saha_temsilci olan kullanıcı dış doktor / ziyaret listesinde ve kartında
/// yalnız kendine bağlı kayıtları görür; saha_sorumlu hepsini; geniş rolü olan daralmaz.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class RolKapsamiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    /// <summary>Sistem rolü (göç 1296): kurulumla gelir, test açmaz / silmez - rol kodu RolKapsami'nin baktığı koddur.</summary>
    private async Task<int> SistemRolAsync(string kod)
    {
        var id = await api.Veri.TekDegerAsync<int>("select coalesce((select id from public.rol where kod = @p0 and sistem = 1), 0)", [kod]);
        Assert.True(id > 0, $"sistem rolü yok (göç 1296 uygulanmamış): {kod}");
        return id;
    }

    private async Task<int> HekimAsync(TestDunyasi d, string ad)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, ad, kod, personel, durum, sube_id) values ('', @p1, @p0, 1, 1, @p2) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) select y.id, 1, @p2 from y returning id",
            [d.Onek + ad.Replace(" ", "")[^1..], d.Onek + " " + ad, Merkez]);
        d.Temizle($"delete from public.dis_hekim_ziyaret where hekim_id = {id}");
        d.Temizle($"delete from public.dis_hekim_temsilci where hekim_id = {id}");
        d.Temizle($"delete from public.taraf_personel where id = {id}");
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    private static async Task<List<int>> ListeIdleriAsync(HttpClient h, string kaynak)
    {
        var y = await h.PostAsJsonAsync($"/api/liste/{kaynak}", new { sayfa = 1, boyut = 500 });
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {await y.Content.ReadAsStringAsync()}");
        var j = await y.Content.ReadFromJsonAsync<JsonElement>();
        return j.GetProperty("satirlar").EnumerateArray().Select(s => s.GetProperty("id").GetInt32()).ToList();
    }

    [VtFact]
    public async Task Temsilci_yalniz_kendi_hekim_ve_ziyaretlerini_gorur_sorumlu_hepsini()
    {
        await using var d = new TestDunyasi(api.Veri);
        var temsilciRol = await SistemRolAsync("saha_temsilci");
        var sorumluRol = await SistemRolAsync("saha_sorumlu");

        var (aId, aKod) = await d.KullaniciAsync(temsilciRol, Merkez);
        var (bId, bKod) = await d.KullaniciAsync(temsilciRol, Merkez);
        var (sId, sKod) = await d.KullaniciAsync(sorumluRol, Merkez);
        foreach (var k in new[] { aId, bId, sId })
        {
            await d.SubeVerAsync(k, Merkez, yazma: true, varsayilan: true);
            await api.Veri.CalistirAsync("insert into public.taraf_personel (id, dis_hekim, sube_id) values (@p0, 0, @p1) on conflict (id) do nothing", [k, Merkez]);
            d.Temizle($"delete from public.taraf_personel where id = {k}");
        }
        var h1 = await HekimAsync(d, "Hekim A");
        var h2 = await HekimAsync(d, "Hekim B");
        await api.Veri.CalistirAsync("insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')", [h1, Merkez, aId]);
        await api.Veri.CalistirAsync("insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')", [h2, Merkez, bId]);
        var z1 = await api.Veri.TekDegerAsync<int>(
            "insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, durum, sonuc, hatirlat) values (@p0, @p1, @p2, now(), 1, 1, 0) returning id", [h1, aId, Merkez]);
        var z2 = await api.Veri.TekDegerAsync<int>(
            "insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, durum, sonuc, hatirlat) values (@p0, @p1, @p2, now(), 1, 1, 0) returning id", [h2, bId, Merkez]);

        var (aAccess, _) = await api.GirisAsync(aKod, TestDunyasi.Parola);
        var (sAccess, _) = await api.GirisAsync(sKod, TestDunyasi.Parola);
        var a = api.Istemci(aAccess, Merkez);
        var s = api.Istemci(sAccess, Merkez);

        // Temsilci A: yalnız kendi hekimi ve kendi ziyareti.
        var aHekimler = await ListeIdleriAsync(a, "dis-hekim");
        Assert.Contains(h1, aHekimler); Assert.DoesNotContain(h2, aHekimler);
        var aZiyaretler = await ListeIdleriAsync(a, "dis-hekim-ziyaret");
        Assert.Contains(z1, aZiyaretler); Assert.DoesNotContain(z2, aZiyaretler);
        // Kart: başkasının ziyareti / hekimi "bulunamadı".
        Assert.Equal(HttpStatusCode.OK, (await a.GetAsync($"/api/kart/dis-hekim-ziyaret/{z1}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await a.GetAsync($"/api/kart/dis-hekim-ziyaret/{z2}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await a.GetAsync($"/api/kart/dis-hekim/{h2}")).StatusCode);

        // YAZMA KAPISI: başkasının ziyareti güncellenmez / taşınmaz / iptal edilmez (satır DEĞİŞMEZ).
        var z2Oncesi = await api.Veri.TekDegerAsync<DateTime>("select tarih from public.dis_hekim_ziyaret where id = @p0", [z2]);
        var z1Kart = await (await a.GetAsync($"/api/kart/dis-hekim-ziyaret/{z1}")).Content.ReadFromJsonAsync<JsonElement>();
        var surum = (z1Kart.TryGetProperty("surum", out var sv) ? sv : z1Kart.GetProperty("kart").GetProperty("surum")).GetString();
        var put = await a.PutAsJsonAsync($"/api/kart/dis-hekim-ziyaret/{z2}", new { surum, kart = new { notu = "sızma" } });
        Assert.Equal(HttpStatusCode.NotFound, put.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await a.PostAsJsonAsync($"/api/dis-hekim/ziyaret/{z2}/tasi", new { tarih = DateTime.Now.AddDays(1) })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await a.PostAsync($"/api/dis-hekim/ziyaret/{z2}/iptal", null)).StatusCode);
        // Silme: temsilcide sil hakkı yok (403 yetki kapısı önce); hakkı olsa da kapsam dışı 404 - ikisi de satırı korur.
        Assert.Contains((await a.DeleteAsync($"/api/kart/dis-hekim-ziyaret/{z2}")).StatusCode, new[] { HttpStatusCode.NotFound, HttpStatusCode.Forbidden });
        Assert.Equal(z2Oncesi, await api.Veri.TekDegerAsync<DateTime>("select tarih from public.dis_hekim_ziyaret where id = @p0", [z2]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select count(*) from public.dis_hekim_ziyaret where id = @p0 and durum = 1", [z2]));
        // /planla: temsilci B'nin hekimine planlayamaz; kendi hekimine B adına plansa da temsilci KENDİSİ olur.
        Assert.Equal(HttpStatusCode.NotFound, (await a.PostAsJsonAsync("/api/dis-hekim/planla", new { hekimId = h2, tarih = DateTime.Now.AddDays(2), temsilciId = bId })).StatusCode);
        var planla = await a.PostAsJsonAsync("/api/dis-hekim/planla", new { hekimId = h1, tarih = DateTime.Now.AddDays(2), temsilciId = bId });
        Assert.True(planla.IsSuccessStatusCode, await planla.Content.ReadAsStringAsync());
        var z3 = (await planla.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("id").GetInt32();
        Assert.Equal(aId, await api.Veri.TekDegerAsync<int>("select temsilci_id from public.dis_hekim_ziyaret where id = @p0", [z3]));

        // Sorumlu: hepsi.
        var sHekimler = await ListeIdleriAsync(s, "dis-hekim");
        Assert.Contains(h1, sHekimler); Assert.Contains(h2, sHekimler);
        var sZiyaretler = await ListeIdleriAsync(s, "dis-hekim-ziyaret");
        Assert.Contains(z1, sZiyaretler); Assert.Contains(z2, sZiyaretler);
        Assert.Equal(HttpStatusCode.OK, (await s.GetAsync($"/api/kart/dis-hekim-ziyaret/{z2}")).StatusCode);
    }
}
