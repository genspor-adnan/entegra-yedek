using System.Net;
using System.Net.Http.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K26 / K16 / K32 (kurum içi özel uçlar):
/// <list type="bullet">
///   <item>K26: belge yazma uçları (<c>/termin</c>, <c>/rezerve</c>, <c>/dagit</c>) tür yetkisini kontrol edip
///   kimlikle yazıyordu - başka ŞUBENİN belgesi kimliğiyle değiştirilebiliyordu. Artık liste ile aynı kapsam
///   kuralından geçer; kapsam dışı belge olmayanla aynı 404'ü alır.</item>
///   <item>K32: kurum profili istemciden gelen <c>subeId</c>'yi doğrulamıyordu - kullanıcının yetkili olmadığı
///   şubenin ürün modu değiştirilebiliyordu.</item>
///   <item>K16: entegrasyon <c>/sina</c> `son_sonuc` YAZIYOR ama Gör yetkisiyle çalışıyordu - salt okuma şubede
///   de yazılıyordu.</item>
/// </list>
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K26KapsamBelgeTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int Ankara = 3;

    private async Task<int> HastaAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id, vkno, durum) values (@p0, 1, 1, @p1, 1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], "9" + Random.Shared.NextInt64(100000000, 999999999)]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    /// <summary>Başvuru belgesi (tür 19 / tip 30 - çekirdek `belge` yetkisinin açtığı küme) verilen şubede.</summary>
    private async Task<int> BasvuruAsync(TestDunyasi d, int hasta, int sube)
    {
        var id = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi, ekleyen)
            values (19, 30, @p0, @p1, now(), 1) returning id
            """, [hasta, sube]);
        d.Temizle($"delete from public.belge where id = {id}");
        return id;
    }

    private async Task<HttpClient> KullaniciAsync(TestDunyasi d, string rolAdi, string[] yetkiler, bool yazma)
    {
        var rol = await d.RolAsync(rolAdi, yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: yazma, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    // ---------------------------------------------------------------- K26 ----

    [VtFact]
    public async Task Merkez_kullanicisi_Ankara_belgesine_termin_yazamaz_404()
    {
        await using var d = new TestDunyasi(api.Veri);
        using var h = await KullaniciAsync(d, "belge-yazar", ["belge:gd"], yazma: true);
        var hasta = await HastaAsync(d);
        var ankara = await BasvuruAsync(d, hasta, Ankara);
        var merkez = await BasvuruAsync(d, hasta, Merkez);

        var govde = new { satirlar = new[] { new { satirId = 1, teslimTarihi = (DateTime?)null } } };

        // Başka şubenin belgesi: olmayan belgeyle AYNI 404 (kaydın varlığı sızmaz).
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync($"/api/belge/{ankara}/termin", govde)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync("/api/belge/2147483000/termin", govde)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync($"/api/belge/{ankara}/rezerve", new { ac = true })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync($"/api/belge/{ankara}/dagit", new { })).StatusCode);

        // Kendi şubesinin belgesi kapıdan GEÇER: cevap artık kapsam değil iş kuralıdır
        //   (satırsız belgede termin / dağılım 4xx iş hatası verir, 404 değil).
        // Satır kimliği bu belgenin değil diye ayrı bir 404 var ("Satır bu belgeye ait değil") - kapı için boş liste.
        var t = await h.PostAsJsonAsync($"/api/belge/{merkez}/termin", new { satirlar = Array.Empty<object>() });
        Assert.True(t.StatusCode != HttpStatusCode.NotFound, "termin: " + await t.Content.ReadAsStringAsync());
        var g = await h.PostAsJsonAsync($"/api/belge/{merkez}/dagit", new { });
        Assert.True(g.StatusCode != HttpStatusCode.NotFound, "dagit: " + await g.Content.ReadAsStringAsync());
    }

    // ---------------------------------------------------------------- K32 ----

    [VtFact]
    public async Task Kurum_profili_yetkisiz_sube_idsiyle_degistirilemez_403_ve_deger_degismez()
    {
        await using var d = new TestDunyasi(api.Veri);
        // Kullanıcı yalnız Merkez'de yetkili; Ankara'nın profilini hedefliyor.
        using var h = await KullaniciAsync(d, "ayar-yazar", ["ayar:gd"], yazma: true);

        var once = await api.Veri.TekDegerAsync<short?>(
            "select urun_modu from public.kurum_profil where sube_id = @p0", [Ankara]);
        var hedef = once is 1 ? 2 : 1;

        var y = await h.PutAsJsonAsync("/api/kurum-profil/", new { urunModu = hedef, subeId = Ankara });
        Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);
        Assert.Equal("YASAK", await ApiSunucuOlgusu.HataKoduAsync(y));

        var sonra = await api.Veri.TekDegerAsync<short?>(
            "select urun_modu from public.kurum_profil where sube_id = @p0", [Ankara]);
        Assert.Equal(once, sonra);
    }

    // ---------------------------------------------------------------- K16 ----

    [VtFact]
    public async Task Entegrasyon_sina_salt_okuma_subede_403_ve_son_sonuc_yazilmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hesap = await api.Veri.TekDegerAsync<int>("""
            insert into public.entegrasyon_hesap (kod, ad, aktif, test_mi, kullanici_adi, sifre, uygulama_kodu, url)
            values ('SKRS', @p0, 1, 1, 'tz-kullanici', 'tz-sifre', 'tz-uyg', 'http://127.0.0.1:9/api/SkrsService')
            returning id
            """, [d.Onek + " skrs"]);
        d.Temizle($"delete from public.entegrasyon_hesap where id = {hesap}");

        // Rolde Gör + Değiştir var; şube SALT OKUMA. Eski davranış: Gör yetiyordu, son_sonuc yazılıyordu.
        using var salt = await KullaniciAsync(d, "entegrasyon-salt", ["entegrasyon:gd"], yazma: false);
        var y = await salt.PostAsync($"/api/entegrasyon/{hesap}/sina", null);
        Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);
        Assert.Equal("YASAK", await ApiSunucuOlgusu.HataKoduAsync(y));

        var sonuc = await api.Veri.TekDegerAsync<string>(
            "select son_sonuc from public.entegrasyon_hesap where id = @p0", [hesap]);
        Assert.Equal("", sonuc);

        // Yalnız Gör yetkisi, yazılabilir şube: yazan uç için de yetmez.
        using var gor = await KullaniciAsync(d, "entegrasyon-gor", ["entegrasyon:g"], yazma: true);
        Assert.Equal(HttpStatusCode.Forbidden, (await gor.PostAsync($"/api/entegrasyon/{hesap}/sina", null)).StatusCode);
    }
}
