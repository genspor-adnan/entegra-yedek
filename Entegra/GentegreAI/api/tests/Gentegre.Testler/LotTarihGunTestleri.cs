using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Testler;

/// <summary>
/// LOT ÜRT / SKT GÜN OLARAK OKUNUR (kullanıcı 09.11.2026: "ürt ve skt bilgisi girdiğim tarihlerden 1 gün
/// önceye gelmişti", müşteri de aynı). Kolon timestamptz: girilen gün şube gece yarısı olarak UTC'ye çevrilip
/// saklanır (09.11 İstanbul = 08.11 21:00Z). Okumada ham UTC an dönünce istemci metni slice(0,10) ile kesip
/// bir gün geri gösteriyordu. Okuma uçları artık oturum (şube) dilimindeki GÜNÜ verir (::date).
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class LotTarihGunTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(int Stok, int Depo, int Lot)> FiksturAsync(TestDunyasi d)
    {
        var depo = await api.Veri.TekDegerAsync<int>(
            "select coalesce((select min(id) from public.depo where coalesce(durum, 1) = 1), 1)", null);
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 5, @p2) returning id",
            [d.Onek + "-LOT", d.Onek + " lot stoğu", Merkez]);
        d.Temizle($"delete from public.stok where id = {stok}");
        // İstanbul 09.11.2026 00:00 = 08.11.2026 21:00Z - kullanıcının girişiyle aynı saklama biçimi.
        var lot = await api.Veri.TekDegerAsync<int>("""
            insert into public.stok_seri_lot (stok_id, lot_no, seri_no, uretim_tarihi, son_kullanma_tarihi)
            values (@p0, @p1, '', timestamptz '2026-11-08 21:00:00+00', timestamptz '2031-11-08 21:00:00+00') returning id
            """, [stok, d.Onek + "-L1"]);
        d.Temizle($"delete from public.stok_seri_lot where id = {lot}");
        await api.Veri.CalistirAsync(
            "insert into public.stok_lot_durum (stok_id, depo_id, seri_lot_id, kalan) values (@p0, @p1, @p2, 5)",
            [stok, depo, lot]);
        d.Temizle($"delete from public.stok_lot_durum where seri_lot_id = {lot}");
        return (stok, depo, lot);
    }

    [VtFact]
    public async Task Depo_lotlari_girilen_gunu_verir_bir_gun_geri_kaymaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (stok, depo, lot) = await FiksturAsync(d);

        var lotlar = await new StokDurumDeposu(api.Veri, new LogDeposu()).LotlarAsync(stok, depo);
        var satir = Assert.Single(lotlar, l => l.seriLotId == lot);
        Assert.Equal(new DateTime(2026, 11, 9), satir.uretimTarihi);
        Assert.Equal(new DateTime(2031, 11, 9), satir.sonKullanmaTarihi);
        Assert.NotEqual(DateTimeKind.Utc, satir.uretimTarihi!.Value.Kind);   // JSON'a "…T21:00:00Z" diye gitmesin
    }

    [VtFact]
    public async Task Lot_ucu_json_metni_gunle_baslar()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (stok, depo, _) = await FiksturAsync(d);
        var rol = await d.RolAsync("lotgun", ["stok:g"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        var istemci = api.Istemci(access, Merkez);

        var y = await istemci.GetAsync($"/api/kart/stok/{stok}/lot?depoId={depo}");
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, govde);
        using var j = JsonDocument.Parse(govde);
        var ilk = j.RootElement.GetProperty("lotlar")[0];
        Assert.StartsWith("2026-11-09", ilk.GetProperty("uretimTarihi").GetString());
        Assert.StartsWith("2031-11-09", ilk.GetProperty("sonKullanmaTarihi").GetString());
    }
}
