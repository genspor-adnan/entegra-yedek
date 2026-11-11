using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// DEPO GENEL KURALI (kullanıcı 11.11.2026: "tüm alış/satış belgeleri + stoktan talep + stok transfer: varsa depo
/// giriş/çıkış comboları seçilmiş olmalı; satır eklenince depo(lar) değişemez"): depolu belge deposuz yazılmaz (400),
/// kalemli belgenin deposu güncellemede değiştirilemez (422), aynı depoyla güncelleme serbest.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class BelgeDepoKuraliTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("depokural", "belge:gedk", "belge.stok.giris:gedk");
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

    [VtFact]
    public async Task Deposuz_fis_yazilmaz_kalemli_fisin_deposu_degismez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var h = await IstemciAsync(d);
        var depo1 = await DepoAsync(d, "Depo A");
        var depo2 = await DepoAsync(d, "Depo B");
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 0, @p2) returning id",
            [d.Onek + "-STK", d.Onek + " deneme stoğu", Merkez]);
        d.Temizle($"delete from public.stok_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok where id = {stok}");
        var satirlar = new[] { new { tur = 1, stokId = stok, adet = 5, miktar = 5, birimFiyat = 10 } };
        var tarih = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:00");

        // 1) Depo seçilmeden giriş fişi yazılmaz.
        var y1 = await h.PostAsJsonAsync("/api/belge/", new { belge = new { tur = 3, tipi = 1, belgeTarihi = tarih }, satirlar });
        Assert.Equal(HttpStatusCode.BadRequest, y1.StatusCode);
        Assert.Equal("DOGRULAMA", await ApiSunucuOlgusu.HataKoduAsync(y1));

        // 2) Depoyla yazılır.
        var y2 = await h.PostAsJsonAsync("/api/belge/", new { belge = new { tur = 3, tipi = 1, belgeTarihi = tarih, girisDepoId = depo1 }, satirlar });
        var govde = await y2.Content.ReadAsStringAsync();
        Assert.True(y2.IsSuccessStatusCode, $"{(int)y2.StatusCode} {govde}");
        var belgeId = JsonDocument.Parse(govde).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {belgeId}");
        d.Temizle($"delete from public.belge_satir where belge_id = {belgeId}");
        d.Temizle($"delete from public.belge where id = {belgeId}");
        var surum = await api.Veri.TekDegerAsync<string>("select xmin::text from public.belge where id = @p0", [belgeId]);

        // 3) Kalem varken depo değişmez (422), satırlar yeniden gönderilse de.
        var y3 = await h.PutAsJsonAsync($"/api/belge/{belgeId}", new { surum, belge = new { tur = 3, tipi = 1, belgeTarihi = tarih, girisDepoId = depo2 }, satirlar });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, y3.StatusCode);
        Assert.Equal(depo1, await api.Veri.TekDegerAsync<int>("select giris_depo_id from public.belge where id = @p0", [belgeId]));

        // 4) Aynı depoyla güncelleme serbest.
        surum = await api.Veri.TekDegerAsync<string>("select xmin::text from public.belge where id = @p0", [belgeId]);
        var y4 = await h.PutAsJsonAsync($"/api/belge/{belgeId}", new { surum, belge = new { tur = 3, tipi = 1, belgeTarihi = tarih, girisDepoId = depo1, aciklama = "x" }, satirlar });
        Assert.True(y4.IsSuccessStatusCode, $"{(int)y4.StatusCode} {await y4.Content.ReadAsStringAsync()}");
    }
}
