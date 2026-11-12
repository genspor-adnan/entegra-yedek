using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// BOŞ KOD → SÜTUN VARSAYILANI (12.11.2026; kullanıcı: "stok kartı marka giriyorum ama modeli yok girmiyorum.. model
/// zorunlu diye hata veriyor.. olmamalı"). Seçilmeyen kod combosu boş (null) gelir; `stok.model smallint not null
/// default 0` NULL'u reddediyordu. Kart yazımı boş değeri NOT NULL + varsayılanlı sütuna DEFAULT olarak yazar - eklemede
/// de, düzenlemede (model temizlenince) de.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class KartBosKodVarsayilanTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    [VtFact]
    public async Task Marka_secili_model_bos_stok_karti_kaydedilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("boskod", ["stok:ged"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        var h = api.Istemci(access, Merkez);
        var kategori = await api.Veri.TekDegerAsync<int>("select min(id) from public.v_stok_kategori_lookup where aktif = 1", null);
        var marka = await api.Veri.TekDegerAsync<int?>("""
            select min(kd.deger::int) from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
             where kl.kod = 'stok.marka'
            """, null) ?? 0;

        // Ekranın gönderdiği gibi: marka seçili, model boş (combo sıfırlandı).
        var y = await h.PostAsJsonAsync("/api/kart/stok", new
        {
            kart = new { kod = d.Onek + "-BK", ad = d.Onek + " boş model stoğu", durum = 1, izleme = 0, tipi = 1, kdv = 20, kategori, marka, model = "" },
        });
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {govde}");
        var id = JsonDocument.Parse(govde).RootElement.GetProperty("kart").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.islem_log where kayit_id = {id} and tablo_id in (select tablo_id from public.islem_log where kayit_id = {id} limit 1)");
        d.Temizle($"delete from public.stok where id = {id}");
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select model from public.stok where id = @p0", [id]));

        // Düzenlemede model temizlenir (null) - yine 0.
        await api.Veri.CalistirAsync("update public.stok set model = 5 where id = @p0", [id]);
        var surum = await api.Veri.TekDegerAsync<string>("select xmin::text from public.stok where id = @p0", [id]);
        var p = await h.PutAsJsonAsync($"/api/kart/stok/{id}", new { surum, kart = new { model = (string?)null } });
        Assert.True(p.IsSuccessStatusCode, $"{(int)p.StatusCode} {await p.Content.ReadAsStringAsync()}");
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select model from public.stok where id = @p0", [id]));
    }
}
