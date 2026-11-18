using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// STOK / BELGE İNCELEMESİ 18.11.2026 bulgu 1-4 (1368): lot bakiyesi stokla aynı yön ve depoda yürür.
///  1 taslak lot bakiyesine dokunmaz, kesinleşince işlenir, silinince iz kalmaz · 2 satış / alış iadesinde lot
///  stokla aynı yönde · 3 korunan satırlı belge düzenlenince lot erimez · 4 iki depolu giriş belgesinin geri alması
///  yazıldığı depodan.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class StokLotYonuTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private static readonly string Tarih = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:00");

    private sealed record Ortam(HttpClient H, int DepoA, int DepoB, int Stok, int Tedarikci, int Musteri);

    private async Task<Ortam> OrtamAsync(TestDunyasi d, int izleme = 2)
    {
        var rol = await d.RolAsync("stoklot", "belge:gedk", "belge.alis.irsaliye:gedk", "belge.satis.irsaliye:gedk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        async Task<int> Depo(string ad)
        {
            var id = await api.Veri.TekDegerAsync<int>(
                "insert into public.depo (ad, durum, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + ad, Merkez]);
            d.Temizle($"delete from public.stok_durum where depo_id = {id}");
            d.Temizle($"delete from public.stok_lot_durum where depo_id = {id}");
            d.Temizle($"delete from public.depo where id = {id}");
            return id;
        }
        var a = await Depo(" A");
        var b = await Depo(" B");
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, @p2, @p3) returning id",
            [d.Onek + "-LOT", d.Onek + " lotlu stok", (short)izleme, Merkez]);
        d.Temizle($"delete from public.stok_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok_lot_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok_seri_lot where stok_id = {stok}");
        d.Temizle($"delete from public.stok where id = {stok}");
        async Task<int> Taraf(string rolKolon)
        {
            var id = await api.Veri.TekDegerAsync<int>(
                $"insert into public.taraf (unvan, {rolKolon}, durum, sube_id) values (@p0, 1, 1, @p1) returning id",
                [d.Onek + " " + rolKolon, Merkez]);
            d.Temizle($"delete from public.taraf where id = {id}");
            return id;
        }
        return new Ortam(api.Istemci(access, Merkez), a, b, stok, await Taraf("tedarikci"), await Taraf("musteri"));
    }

    private async Task<int> YazAsync(TestDunyasi d, Ortam o, object belge, object[] satirlar, bool taslak = false, int? id = null)
    {
        var govde = new { surum = id is null ? null : await Surum(id.Value), belge, satirlar, secenekler = new { taslak } };
        var y = id is null ? await o.H.PostAsJsonAsync("/api/belge/", govde) : await o.H.PutAsJsonAsync($"/api/belge/{id}", govde);
        var g = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {g}");
        var yeni = JsonDocument.Parse(g).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
        if (id is null)
        {
            d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {yeni}");
            d.Temizle($"delete from public.mali_hareket where belge_id = {yeni}");
            d.Temizle($"delete from public.stok_izleme where belge_id = {yeni}");
            d.Temizle($"delete from public.belge_satir where belge_id = {yeni}");
            d.Temizle($"delete from public.belge where id = {yeni}");
        }
        return yeni;
    }

    private Task<string> Surum(int id) => api.Veri.TekDegerAsync<string>("select xmin::text from public.belge where id = @p0", [id])!;

    private Task<decimal> Lot(Ortam o, int depo) => api.Veri.TekDegerAsync<decimal>(
        "select coalesce(sum(kalan), 0) from public.stok_lot_durum where stok_id = @p0 and depo_id = @p1", [o.Stok, depo]);

    private Task<decimal> Stok(Ortam o, int depo) => api.Veri.TekDegerAsync<decimal>(
        "select coalesce(sum(kalan), 0) from public.stok_durum where stok_id = @p0 and depo_id = @p1", [o.Stok, depo]);

    private object AlisIrsaliyesi(Ortam o, string no, int tipi = 1, int? cikisDepo = null)
        => new { tur = 10, tipi, belgeTarihi = Tarih, tarafId = o.Tedarikci, girisDepoId = o.DepoA, cikisDepoId = cikisDepo, belgeNo = no };

    private static object LotSatiri(int stok, decimal adet, object izlem, int? id = null)
        => new { satirId = id, tur = 1, stokId = stok, adet, miktar = adet, birimFiyat = 10, izlemler = new[] { izlem } };

    [VtFact]
    public async Task Taslak_lot_bakiyesine_dokunmaz_kesinlesince_islenir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        var satir = new[] { LotSatiri(o.Stok, 10, new { lotNo = "L-TSL", miktar = 10 }) };

        var id = await YazAsync(d, o, AlisIrsaliyesi(o, "TS" + d.Onek[^6..]), satir, taslak: true);
        Assert.Equal(0m, await Lot(o, o.DepoA));                       // eskiden 10 (stok 0)
        await YazAsync(d, o, AlisIrsaliyesi(o, "TS" + d.Onek[^6..]), satir, taslak: true, id: id);
        Assert.Equal(0m, await Lot(o, o.DepoA));                       // eskiden 20
        await YazAsync(d, o, AlisIrsaliyesi(o, "TS" + d.Onek[^6..]), satir, taslak: false, id: id);
        Assert.Equal(10m, await Lot(o, o.DepoA));
        Assert.Equal(10m, await Stok(o, o.DepoA));

        var sil = await o.H.DeleteAsync($"/api/belge/{id}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(0m, await Lot(o, o.DepoA));
        Assert.Equal(0m, await Stok(o, o.DepoA));
    }

    [VtFact]
    public async Task Iadede_lot_stokla_ayni_yonde()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        await YazAsync(d, o, AlisIrsaliyesi(o, "GR" + d.Onek[^6..]), [LotSatiri(o.Stok, 10, new { lotNo = "L-IAD", miktar = 10 })]);
        var lot = await api.Veri.TekDegerAsync<int>(
            "select id from public.stok_seri_lot where stok_id = @p0 and lot_no = 'L-IAD'", [o.Stok]);
        Assert.Equal(10m, await Lot(o, o.DepoA));

        // Satış İADESİ (14, tipi 2): mal GİRER - istemci lotu stoktakilerden SEÇER (seriLotId).
        var iade = await YazAsync(d, o,
            new { tur = 14, tipi = 2, belgeTarihi = Tarih, tarafId = o.Musteri, cikisDepoId = o.DepoA },
            [LotSatiri(o.Stok, 3, new { seriLotId = lot, miktar = 3 })]);
        Assert.Equal(13m, await Stok(o, o.DepoA));
        Assert.Equal(13m, await Lot(o, o.DepoA));                      // eskiden 7 (lot düşüyordu)

        // Alış İADESİ (10, tipi 2): mal ÇIKAR - istemci lotu giriş penceresinden YAZAR (lotNo).
        await YazAsync(d, o, AlisIrsaliyesi(o, "AI" + d.Onek[^6..], tipi: 2),
            [LotSatiri(o.Stok, 2, new { lotNo = "L-IAD", miktar = 2 })]);
        Assert.Equal(11m, await Stok(o, o.DepoA));
        Assert.Equal(11m, await Lot(o, o.DepoA));                      // eskiden 15 (lot ekleniyordu)

        // İadeyi silmek yazdığını geri alır.
        var sil = await o.H.DeleteAsync($"/api/belge/{iade}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(8m, await Stok(o, o.DepoA));
        Assert.Equal(8m, await Lot(o, o.DepoA));
    }

    [VtFact]
    public async Task Korunan_satirli_belge_duzenlenince_lot_erimez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        var no = "KR" + d.Onek[^6..];
        var id = await YazAsync(d, o, AlisIrsaliyesi(o, no), [LotSatiri(o.Stok, 5, new { lotNo = "L-KOR", miktar = 5 })]);
        var satirId = await api.Veri.TekDegerAsync<int>("select id from public.belge_satir where belge_id = @p0", [id]);
        // ÜTS bildirimi satırı korur (silinip yeniden yazılmaz).
        var uts = await api.Veri.TekDegerAsync<int>("""
            insert into public.uts_bildirim (id, tur, sube_id, belge_satir_id)
            values ((select coalesce(max(id), 0) + 1 from public.uts_bildirim), 1, 1, @p0) returning id
            """, [satirId]);
        d.Temizle($"delete from public.uts_bildirim where id = {uts}");
        Assert.Equal(5m, await Lot(o, o.DepoA));

        var satir = new[] { LotSatiri(o.Stok, 5, new { lotNo = "L-KOR", miktar = 5 }, satirId) };
        await YazAsync(d, o, AlisIrsaliyesi(o, no), satir, id: id);
        await YazAsync(d, o, AlisIrsaliyesi(o, no), satir, id: id);
        Assert.Equal(5m, await Stok(o, o.DepoA));
        Assert.Equal(5m, await Lot(o, o.DepoA));                       // eskiden her kayıtta -5
    }

    [VtFact]
    public async Task Iki_depolu_giris_belgesi_yazdigi_depodan_geri_alinir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        var id = await YazAsync(d, o, AlisIrsaliyesi(o, "ID" + d.Onek[^6..], cikisDepo: o.DepoB),
            [new { tur = 1, stokId = o.Stok, adet = 10, miktar = 10, birimFiyat = 10 }]);
        Assert.Equal(10m, await Stok(o, o.DepoA));
        var sil = await o.H.DeleteAsync($"/api/belge/{id}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(0m, await Stok(o, o.DepoA));                      // eskiden A'da +10 kalıyordu
        Assert.Equal(0m, await Stok(o, o.DepoB));                      // ve B -10'a düşüyordu
    }
}
