using System.Net;
using System.Net.Http.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// İÇ STOK BELGESİ LİSTEDEN SATIRLARIYLA SİLİNİR (1284, kullanıcı 10.11.2026: "Giriş - Çıkış Fişinde ... direkt
/// silebilsin.. gerekirse logdan geri alırız"): giriş fişi satırlı iken DELETE (satirlarla=0) başarılı, satırlar
/// gider, stok bakiyesi geri alınır, silme logu yazılır. Ticari belgede (teklif) 1267 kuralı aynen: 422.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class StokBelgesiSilTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int LogBelge = 30;

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("stksil", "belge:gedk", "belge.stok.giris:gedk", "belge.satis:gedk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private Task<int> DepoAsync() => api.Veri.TekDegerAsync<int>("""
        select coalesce((select min(id) from public.depo where varsayilan = 1 and coalesce(durum, 1) = 1),
                        (select min(id) from public.depo where coalesce(durum, 1) = 1))
        """, null);

    [VtFact]
    public async Task Giris_fisi_satirli_iken_listeden_silinir_stok_geri_alinir_log_yazilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var istemci = await IstemciAsync(d);
        var depo = await DepoAsync();

        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 0, @p2) returning id",
            [d.Onek + "-STK", d.Onek + " deneme stoğu", Merkez]);
        d.Temizle($"delete from public.stok_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok where id = {stok}");
        // Fişin yazdığı bakiye: 5 girdi, 5 kaldı.
        await api.Veri.CalistirAsync(
            "insert into public.stok_durum (stok_id, depo_id, giren, cikan, kalan) values (@p0, @p1, 5, 0, 5)",
            [stok, depo]);

        var belgeId = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, durum, sube_id, giris_depo_id, belge_no)
            values (3, now(), 0, @p0, @p1, @p2) returning id
            """, [Merkez, depo, d.Onek]);
        d.Temizle($"delete from public.islem_log where tablo_id = {LogBelge} and kayit_id = {belgeId}");
        d.Temizle($"delete from public.belge_satir where belge_id = {belgeId}");
        d.Temizle($"delete from public.belge where id = {belgeId}");
        await api.Veri.CalistirAsync("""
            insert into public.belge_satir (belge_id, sira, tur, stok_id, miktar, adet, birim_fiyat, tutar, sube_id)
            values (@p0, 1, 1, @p1, 5, 5, 10, 50, @p2)
            """, [belgeId, stok, Merkez]);

        // Listeden silme: satirlarla İSTENMEZ - sunucu türe bakıp satırları kendisi götürür.
        var y = await istemci.DeleteAsync($"/api/belge/{belgeId}");
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {await y.Content.ReadAsStringAsync()}");

        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.belge where id = @p0", [belgeId]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.belge_satir where belge_id = @p0", [belgeId]));
        Assert.Equal(0m, await api.Veri.TekDegerAsync<decimal>(
            "select kalan from public.stok_durum where stok_id = @p0 and depo_id = @p1", [stok, depo]));
        // Geri almanın dayanağı: silme logu (tam satır, DELETE'ten önce).
        Assert.True(await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.islem_log where tablo_id = @p0 and kayit_id = @p1", [LogBelge, belgeId]) > 0);
    }

    [VtFact]
    public async Task Ticari_belgede_satirli_silme_kurali_kalir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var istemci = await IstemciAsync(d);

        var tarafId = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, musteri, sube_id) values (@p0, 1, @p1) returning id",
            [d.Onek + " Müşteri", Merkez]);
        d.Temizle($"delete from public.taraf where id = {tarafId}");
        var belgeId = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id, teklif_durum, belge_no)
            values (18, now(), @p0, 0, @p1, 1, @p2) returning id
            """, [tarafId, Merkez, d.Onek]);
        d.Temizle($"delete from public.islem_log where tablo_id = {LogBelge} and kayit_id = {belgeId}");
        d.Temizle($"delete from public.belge_satir where belge_id = {belgeId}");
        d.Temizle($"delete from public.belge where id = {belgeId}");
        await api.Veri.CalistirAsync("""
            insert into public.belge_satir (belge_id, sira, tur, aciklama, miktar, adet, birim_fiyat, tutar, sube_id)
            values (@p0, 1, 3, 'serbest kalem', 1, 1, 100, 100, @p1)
            """, [belgeId, Merkez]);

        var y = await istemci.DeleteAsync($"/api/belge/{belgeId}");
        Assert.Equal(HttpStatusCode.UnprocessableEntity, y.StatusCode);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.belge where id = @p0", [belgeId]));
    }
}
