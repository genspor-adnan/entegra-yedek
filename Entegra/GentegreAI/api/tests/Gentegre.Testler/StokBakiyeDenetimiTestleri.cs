using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// STOK BAKİYE DENETİMİ (12.11.2026; kullanıcı: "Giriş belgesi ile stoğu arttırıyorum, çıkış belgesi ile hepsini çıkış
/// yapıyorum, sonra giriş belgesini silebiliyorum. Stok eksiye düşüyor.. Genel bir çalışma yap" → "Her zaman engelle").
/// Giriş tarafındaki bakiyeyi eksiye düşüren silme / düzenleme ayardan bağımsız 422; çıkış tarafı ayara uyar; zaten
/// eksi olan stoğa giriş serbest; transferin varış deposu da giriş tarafıdır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class StokBakiyeDenetimiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private static readonly string Tarih = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:00");

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("bakiye", "belge:gedk", "belge.stok.giris:gedk", "belge.stok.cikis:gedk", "belge.stok.transfer:gedk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private async Task<int> DepoAsync(TestDunyasi d, string ad)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.depo (ad, durum, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " " + ad, Merkez]);
        d.Temizle($"delete from public.stok_durum where depo_id = {id}");
        d.Temizle($"delete from public.depo where id = {id}");
        return id;
    }

    private async Task<int> StokAsync(TestDunyasi d, string ek)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 0, @p2) returning id",
            [d.Onek + "-" + ek, d.Onek + " bakiye stoğu " + ek, Merkez]);
        d.Temizle($"delete from public.stok_durum where stok_id = {id}");
        d.Temizle($"delete from public.stok where id = {id}");
        return id;
    }

    private static object[] Satir(int stok, decimal miktar) => [new { tur = 1, stokId = stok, adet = miktar, miktar, birimFiyat = 10 }];

    private async Task<int> YazAsync(TestDunyasi d, HttpClient h, object belge, object[] satirlar)
    {
        var y = await h.PostAsJsonAsync("/api/belge/", new { belge, satirlar });
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {govde}");
        var id = JsonDocument.Parse(govde).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
        // Temizlik sırası: TestDunyasi tersten çalıştırır.
        d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {id}");
        d.Temizle($"delete from public.stok_izleme where belge_id = {id}");
        d.Temizle($"delete from public.belge_satir where belge_id = {id}");
        d.Temizle($"delete from public.belge where id = {id}");
        return id;
    }

    private Task<decimal> KalanAsync(int stok, int depo) => api.Veri.TekDegerAsync<decimal>(
        "select coalesce((select kalan from public.stok_durum where stok_id = @p0 and depo_id = @p1), 0)", [stok, depo]);

    private static async Task<string> MesajAsync(HttpResponseMessage y)
    {
        var g = await y.Content.ReadAsStringAsync();
        return JsonDocument.Parse(g).RootElement.TryGetProperty("hata", out var h) ? h.GetProperty("mesaj").GetString() ?? "" : g;
    }

    private Task<string> SurumAsync(int id) => api.Veri.TekDegerAsync<string>("select xmin::text from public.belge where id = @p0", [id])!;

    [VtFact]
    public async Task Tuketilmis_giris_silinemez_azaltilamaz_artirilabilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var h = await IstemciAsync(d);
        var depo = await DepoAsync(d, "Depo");
        var stok = await StokAsync(d, "A");

        var giris = await YazAsync(d, h, new { tur = 3, tipi = 1, belgeTarihi = Tarih, girisDepoId = depo }, Satir(stok, 10));
        var cikis = await YazAsync(d, h, new { tur = 4, tipi = 1, belgeTarihi = Tarih, cikisDepoId = depo }, Satir(stok, 10));
        Assert.Equal(0m, await KalanAsync(stok, depo));

        // 1) Kullanıcının durumu: tüketilmiş girişi silmek - 422, stok ve belge yerinde.
        var sil = await h.DeleteAsync($"/api/belge/{giris}");
        Assert.Equal(HttpStatusCode.UnprocessableEntity, sil.StatusCode);
        Assert.Contains("eksiye düşürür", await MesajAsync(sil));
        Assert.Equal(0m, await KalanAsync(stok, depo));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.belge where id = @p0", [giris]));

        // 2) Giriş miktarını çıkışın altına indirmek - 422.
        var azalt = await h.PutAsJsonAsync($"/api/belge/{giris}", new
        {
            surum = await SurumAsync(giris), belge = new { tur = 3, tipi = 1, belgeTarihi = Tarih, girisDepoId = depo }, satirlar = Satir(stok, 4),
        });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, azalt.StatusCode);
        Assert.Equal(0m, await KalanAsync(stok, depo));

        // 3) Artırmak serbest.
        var artir = await h.PutAsJsonAsync($"/api/belge/{giris}", new
        {
            surum = await SurumAsync(giris), belge = new { tur = 3, tipi = 1, belgeTarihi = Tarih, girisDepoId = depo }, satirlar = Satir(stok, 12),
        });
        Assert.True(artir.IsSuccessStatusCode, $"{(int)artir.StatusCode} {await artir.Content.ReadAsStringAsync()}");
        Assert.Equal(2m, await KalanAsync(stok, depo));

        // 4) Önce çıkış, sonra giriş silinirse serbest - bakiye sıfıra döner.
        Assert.True((await h.DeleteAsync($"/api/belge/{cikis}")).IsSuccessStatusCode);
        Assert.Equal(12m, await KalanAsync(stok, depo));
        Assert.True((await h.DeleteAsync($"/api/belge/{giris}")).IsSuccessStatusCode);
        Assert.Equal(0m, await KalanAsync(stok, depo));
    }

    [VtFact]
    public async Task Transferin_varisindan_cikis_yapildiysa_transfer_silinemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var h = await IstemciAsync(d);
        var a = await DepoAsync(d, "Depo A");
        var b = await DepoAsync(d, "Depo B");
        var stok = await StokAsync(d, "T");
        // Transfer teslim eden / teslim alan ister (personel taraf).
        var kisi = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, personel, sube_id) values (@p0, 'Test', 'Teslim', 1, @p1) returning id",
            [d.Onek + " Teslim", Merkez]);
        d.Temizle($"delete from public.taraf where id = {kisi}");
        var kisi2 = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, personel, sube_id) values (@p0, 'Test', 'Alan', 1, @p1) returning id",
            [d.Onek + " Alan", Merkez]);
        d.Temizle($"delete from public.taraf where id = {kisi2}");

        await YazAsync(d, h, new { tur = 3, tipi = 1, belgeTarihi = Tarih, girisDepoId = a }, Satir(stok, 5));
        var transfer = await YazAsync(d, h, new { tur = 20, tipi = 1, belgeTarihi = Tarih, cikisDepoId = a, girisDepoId = b, teslimEdenId = kisi, teslimAlanId = kisi2 }, Satir(stok, 5));
        await YazAsync(d, h, new { tur = 4, tipi = 1, belgeTarihi = Tarih, cikisDepoId = b }, Satir(stok, 5));
        Assert.Equal(0m, await KalanAsync(stok, a));
        Assert.Equal(0m, await KalanAsync(stok, b));

        var sil = await h.DeleteAsync($"/api/belge/{transfer}");
        Assert.Equal(HttpStatusCode.UnprocessableEntity, sil.StatusCode);
        Assert.Equal(0m, await KalanAsync(stok, b));
        Assert.Equal(0m, await KalanAsync(stok, a));
    }

    [VtFact]
    public async Task Eksi_stoga_giris_serbest_cikis_ayara_uyar()
    {
        await using var d = new TestDunyasi(api.Veri);
        var h = await IstemciAsync(d);
        var depo = await DepoAsync(d, "Depo");
        var stok = await StokAsync(d, "E");
        var ayar = await api.Veri.TekDegerAsync<string>("select deger from public.referans where anahtar = 'stok.negatif_davranis'");
        Assert.Equal("1", ayar);   // test DB'si "uyar" - çıkış eksiye düşer, uyarı döner

        // Girişsiz çıkış: ayar "uyar" - yazılır, uyarı döner.
        var y = await h.PostAsJsonAsync("/api/belge/", new { belge = new { tur = 4, tipi = 1, belgeTarihi = Tarih, cikisDepoId = depo }, satirlar = Satir(stok, 3) });
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, govde);
        Assert.Contains("eksiye düştü", JsonDocument.Parse(govde).RootElement.GetRawText().Replace("\\u00FC", "ü").Replace("\\u015F", "ş"));
        var cikis = JsonDocument.Parse(govde).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {cikis}");
        d.Temizle($"delete from public.belge_satir where belge_id = {cikis}");
        d.Temizle($"delete from public.belge where id = {cikis}");
        Assert.Equal(-3m, await KalanAsync(stok, depo));

        // Zaten eksi olan stoğa giriş serbest (eskiden "engelle" modunda reddedilirdi).
        await YazAsync(d, h, new { tur = 3, tipi = 1, belgeTarihi = Tarih, girisDepoId = depo }, Satir(stok, 1));
        Assert.Equal(-2m, await KalanAsync(stok, depo));
    }
}
