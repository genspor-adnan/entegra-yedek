using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// KİŞİSEL HATIRLATICI (1139) — görünürlük, paylaşım ve tamamlama kuralları GERÇEK API sürecinde.
///
/// <para>Hatırlatmanın yetki kodu yok: kayıt kişiye özel, her uç görünürlüğü kendisi süzer (sahip ·
/// seçilen kişi · birim). Bu yüzden testler "başkası görmüyor / düzenleyemiyor / silemiyor"u ve
/// paylaşımın iki kapanma kipini (herkes için / herkes kendi işaretini) uçtan uca sınar.</para>
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HatirlatmaGuvenligiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private static object Govde(string baslik, string zaman, object? ek = null)
    {
        var d = new Dictionary<string, object?>
        {
            ["baslik"] = baslik, ["notu"] = "", ["zaman"] = zaman, ["uyarDk"] = 0, ["oncelik"] = 2, ["renk"] = 0,
            ["etiket"] = "", ["tekrar"] = 0, ["tekrarAralik"] = 1, ["tekrarGunler"] = 0, ["tekrarBitis"] = null,
            ["kanalUygulama"] = true, ["kanalSms"] = false, ["kanalEposta"] = false,
            ["kaynak"] = "", ["kaynakId"] = null, ["kaynakAd"] = "",
            ["paylasim"] = 0, ["paylasimDepartmanId"] = null, ["herkesKapatir"] = true, ["paylasilanDuzenler"] = false,
            ["paylasilanlar"] = Array.Empty<int>(),
        };
        if (ek is not null)
            foreach (var p in ek.GetType().GetProperties()) d[p.Name] = p.GetValue(ek);
        return d;
    }

    private static string Yarin(int saat = 9) => DateTime.Now.Date.AddDays(1).AddHours(saat).ToString("yyyy-MM-dd'T'HH:mm");

    private async Task<(int Id, HttpClient H)> Kullanici(TestDunyasi d, int rol, int? departman = null)
    {
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        if (departman is { } dep) await api.Veri.CalistirAsync("update public.taraf set departman = @p1 where id = @p0", [u, dep]);
        d.Temizle($"delete from public.hatirlatma where sahip_id = {u}");
        d.Temizle($"delete from public.hatirlatma_paylasim where kullanici_id = {u}");
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return (u, api.Istemci(access, Merkez));
    }

    private static async Task<int> Ekle(HttpClient h, object govde)
    {
        var y = await h.PostAsJsonAsync("/api/hatirlatma", govde);
        Assert.True(y.IsSuccessStatusCode, await y.Content.ReadAsStringAsync());
        return (await y.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("id").GetInt32();
    }

    private static async Task<int[]> AcikIdler(HttpClient h)
        => (await h.GetFromJsonAsync<JsonElement>("/api/hatirlatma?cip=acik"))
            .EnumerateArray().Select(x => x.GetProperty("id").GetInt32()).ToArray();

    // --------------------------------------------------------- görünürlük --

    [VtFact]
    public async Task Paylasilmayan_hatirlatmayi_baskasi_goremez_degistiremez_silemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        var (_, b) = await Kullanici(d, rol);
        using (a) using (b)
        {
            var id = await Ekle(a, Govde("gizli", Yarin()));

            Assert.Contains(id, await AcikIdler(a));
            Assert.DoesNotContain(id, await AcikIdler(b));
            Assert.Equal(HttpStatusCode.NotFound, (await b.GetAsync($"/api/hatirlatma/{id}")).StatusCode);
            Assert.Equal(HttpStatusCode.NotFound, (await b.PutAsJsonAsync($"/api/hatirlatma/{id}", Govde("ele geçir", Yarin()))).StatusCode);
            Assert.Equal(HttpStatusCode.NotFound, (await b.PostAsJsonAsync($"/api/hatirlatma/{id}/tamamla", new { })).StatusCode);
            Assert.Equal(HttpStatusCode.NotFound, (await b.PostAsJsonAsync($"/api/hatirlatma/{id}/ertele", new { dakika = 10 })).StatusCode);
            Assert.Equal(HttpStatusCode.NotFound, (await b.DeleteAsync($"/api/hatirlatma/{id}")).StatusCode);

            // Satır değişmedi.
            var baslik = await api.Veri.TekDegerAsync<string>("select baslik from public.hatirlatma where id = @p0", [id]);
            Assert.Equal("gizli", baslik);
        }
    }

    [VtFact]
    public async Task Paylasilan_gorur_ve_tamamlar_ama_izinsiz_duzenleyemez_silemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        var (bId, b) = await Kullanici(d, rol);
        using (a) using (b)
        {
            var id = await Ekle(a, Govde("ortak", Yarin(), new { paylasim = 1, paylasilanlar = new[] { bId } }));

            Assert.Contains(id, await AcikIdler(b));
            Assert.Equal(HttpStatusCode.OK, (await b.GetAsync($"/api/hatirlatma/{id}")).StatusCode);
            var duzen = await b.PutAsJsonAsync($"/api/hatirlatma/{id}", Govde("değişti", Yarin()));
            Assert.Equal(HttpStatusCode.Forbidden, duzen.StatusCode);
            Assert.Equal(HttpStatusCode.NotFound, (await b.DeleteAsync($"/api/hatirlatma/{id}")).StatusCode);
            Assert.Equal(HttpStatusCode.OK, (await b.PostAsJsonAsync($"/api/hatirlatma/{id}/ertele", new { dakika = 30 })).StatusCode);
        }
    }

    [VtFact]
    public async Task Duzenleme_izni_verilen_paylasilan_duzenler_ama_paylasimi_degistiremez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        var (bId, b) = await Kullanici(d, rol);
        var (cId, c) = await Kullanici(d, rol);
        using (a) using (b) using (c)
        {
            var id = await Ekle(a, Govde("ortak", Yarin(),
                new { paylasim = 1, paylasilanlar = new[] { bId }, paylasilanDuzenler = true }));

            // B başlığı değiştirir ve C'yi de eklemeye çalışır: başlık değişir, paylaşım değişmez.
            var y = await b.PutAsJsonAsync($"/api/hatirlatma/{id}", Govde("B düzenledi", Yarin(),
                new { paylasim = 1, paylasilanlar = new[] { bId, cId }, paylasilanDuzenler = true }));
            Assert.Equal(HttpStatusCode.OK, y.StatusCode);
            Assert.Equal("B düzenledi", await api.Veri.TekDegerAsync<string>("select baslik from public.hatirlatma where id = @p0", [id]));
            Assert.DoesNotContain(id, await AcikIdler(c));
        }
    }

    // ------------------------------------------------------------ kapanma --

    [VtFact]
    public async Task Herkes_kapatir_kipinde_paylasilanin_tamamlamasi_herkes_icin_kapatir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        var (bId, b) = await Kullanici(d, rol);
        using (a) using (b)
        {
            var id = await Ekle(a, Govde("ortak", Yarin(), new { paylasim = 1, paylasilanlar = new[] { bId }, herkesKapatir = true }));
            Assert.Equal(HttpStatusCode.OK, (await b.PostAsJsonAsync($"/api/hatirlatma/{id}/tamamla", new { })).StatusCode);

            Assert.DoesNotContain(id, await AcikIdler(a));
            Assert.DoesNotContain(id, await AcikIdler(b));
            Assert.Equal((short)2, await api.Veri.TekDegerAsync<short>("select durum from public.hatirlatma where id = @p0", [id]));
        }
    }

    [VtFact]
    public async Task Herkes_kendi_isaretini_koyar_kipinde_son_isaretle_kapanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        var (bId, b) = await Kullanici(d, rol);
        using (a) using (b)
        {
            var id = await Ekle(a, Govde("ortak", Yarin(), new { paylasim = 1, paylasilanlar = new[] { bId }, herkesKapatir = false }));

            // B kapatır: B'nin listesinden düşer, A'da açık kalır.
            await b.PostAsJsonAsync($"/api/hatirlatma/{id}/tamamla", new { });
            Assert.DoesNotContain(id, await AcikIdler(b));
            Assert.Contains(id, await AcikIdler(a));
            Assert.Equal((short)1, await api.Veri.TekDegerAsync<short>("select durum from public.hatirlatma where id = @p0", [id]));

            // A da kapatınca satır kapanır.
            await a.PostAsJsonAsync($"/api/hatirlatma/{id}/tamamla", new { });
            Assert.DoesNotContain(id, await AcikIdler(a));
            Assert.Equal((short)2, await api.Veri.TekDegerAsync<short>("select durum from public.hatirlatma where id = @p0", [id]));
        }
    }

    [VtFact]
    public async Task Birim_paylasimini_yalniz_o_birimdekiler_gorur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var dep = await api.Veri.TekDegerAsync<int>(
            "insert into public.departman (ad, durum) values (@p0, 1) returning id", [d.Onek + " birim"]);
        d.Temizle($"delete from public.departman where id = {dep}");
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        var (_, ici) = await Kullanici(d, rol, dep);
        var (_, disi) = await Kullanici(d, rol);
        using (a) using (ici) using (disi)
        {
            var id = await Ekle(a, Govde("birime", Yarin(), new { paylasim = 2, paylasimDepartmanId = dep }));
            Assert.Contains(id, await AcikIdler(ici));
            Assert.DoesNotContain(id, await AcikIdler(disi));
        }
    }

    [VtFact]
    public async Task Tekrarlayan_tamamlaninca_kapanmaz_sonraki_zamana_ilerler()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        using (a)
        {
            var id = await Ekle(a, Govde("her gün", Yarin(), new { tekrar = 1 }));
            var y = await (await a.PostAsJsonAsync($"/api/hatirlatma/{id}/tamamla", new { })).Content.ReadFromJsonAsync<JsonElement>();
            Assert.False(y.GetProperty("kapandi").GetBoolean());
            Assert.Contains(id, await AcikIdler(a));
            var gun = await api.Veri.TekDegerAsync<int>(
                "select (zaman::date - current_date) from public.hatirlatma where id = @p0", [id]);
            Assert.Equal(2, gun);   // yarın -> öbür gün
            Assert.Equal(1L, await api.Veri.TekDegerAsync<long>(
                "select count(*) from public.hatirlatma_hareket where hatirlatma_id = @p0 and olay = 5", [id]));
        }
    }

    [VtFact]
    public async Task Gecersiz_istek_dogrulama_hatasi_verir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("hat");
        var (_, a) = await Kullanici(d, rol);
        using (a)
        {
            Assert.Equal(HttpStatusCode.BadRequest, (await a.PostAsJsonAsync("/api/hatirlatma", Govde("", Yarin()))).StatusCode);
            Assert.Equal(HttpStatusCode.BadRequest, (await a.PostAsJsonAsync("/api/hatirlatma", Govde("x", "yarın"))).StatusCode);
            Assert.Equal(HttpStatusCode.BadRequest, (await a.PostAsJsonAsync("/api/hatirlatma",
                Govde("x", Yarin(), new { kanalUygulama = false }))).StatusCode);
            // Bağlı kayıt türü SQL / yol karakteri taşıyamaz.
            Assert.Equal(HttpStatusCode.BadRequest, (await a.PostAsJsonAsync("/api/hatirlatma",
                Govde("x", Yarin(), new { kaynak = "cari'; drop", kaynakId = 1 }))).StatusCode);
        }
    }
}
