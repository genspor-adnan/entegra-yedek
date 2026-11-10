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

    /// <summary>Kodu SABİT rol (RolKapsami kodla eşleşir): varsa kullanılır, yoksa açılır ve testin sonunda silinir.</summary>
    private async Task<int> SabitRolAsync(TestDunyasi d, string kod, string ad, params string[] yetkiler)
    {
        // Var olan rol (kurulumdan ya da yarım kalmış bir koşudan) kullanılır; hakları her koşuda tamamlanır.
        var mevcut = await api.Veri.TekDegerAsync<int>("select coalesce((select id from public.rol where kod = @p0), 0)", [kod]);
        var id = mevcut > 0 ? mevcut
            : await api.Veri.TekDegerAsync<int>("insert into public.rol (kod, ad) values (@p0, @p1) returning id", [kod, ad]);
        if (mevcut == 0)
        {
            // Temizlik SIRASI: önce kullanıcılar (TestDunyasi), sonra bağlar, en son rol - rol silinemezse hakları da silmeyelim.
            d.Temizle($"delete from public.rol where id = {id} and not exists (select 1 from public.taraf_kullanici k where k.rol_id = {id})");
            d.Temizle($"delete from public.rol_yetki where rol_id = {id} and not exists (select 1 from public.rol r where r.id = {id})");
        }
        foreach (var y in yetkiler)
        {
            var (ykod, islem) = y.Contains(':') ? (y[..y.IndexOf(':')], y[(y.IndexOf(':') + 1)..]) : (y, "g");
            var eklenen = await api.Veri.CalistirAsync("""
                insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
                select @p0, y.id, 1, @p2, @p3, @p4 from public.yetki y where y.kod = @p1
                on conflict (rol_id, yetki_id) do update set gor = 1, ekle = excluded.ekle, degistir = excluded.degistir, sil = excluded.sil
                """, [id, ykod, (short)(islem.Contains('e') ? 1 : 0), (short)(islem.Contains('d') ? 1 : 0), (short)(islem.Contains('k') ? 1 : 0)]);
            Assert.True(eklenen == 1, $"yetki bulunamadı: {ykod}");
        }
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
        var temsilciRol = await SabitRolAsync(d, "saha_temsilci", "Müşteri Temsilcisi (Saha)",
            "dis_doktor.liste", "dis_doktor:ged", "dis_doktor.ziyaret:ged");
        var sorumluRol = await SabitRolAsync(d, "saha_sorumlu", "Müşteri Temsilci Sorumlusu (Saha)",
            "dis_doktor.liste", "dis_doktor:gedk", "dis_doktor.ziyaret:gedk");

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

        // Sorumlu: hepsi.
        var sHekimler = await ListeIdleriAsync(s, "dis-hekim");
        Assert.Contains(h1, sHekimler); Assert.Contains(h2, sHekimler);
        var sZiyaretler = await ListeIdleriAsync(s, "dis-hekim-ziyaret");
        Assert.Contains(z1, sZiyaretler); Assert.Contains(z2, sZiyaretler);
        Assert.Equal(HttpStatusCode.OK, (await s.GetAsync($"/api/kart/dis-hekim-ziyaret/{z2}")).StatusCode);
    }
}
