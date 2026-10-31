using System.Net;
using System.Net.Http.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K26 / K34: muayene ve reçete özel uçları yetkiyi kontrol edip kimlikle
/// (<c>where id = @p0</c>) okuyor / yazıyordu. Merkez'de çalışan, Ankara'ya izni olmayan kullanıcı Ankara'nın
/// muayenesini / reçetesini kimliğiyle açamamalı; cevap var olmayan kayıtla AYNI 404 olmalı ve yan etki
/// bırakmamalı. K34: tamamlanmış (durum 3) muayeneye tanı / bulgu yazılamaz (422).
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K26KapsamMuayeneTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int Ankara = 3;

    private async Task<int> HastaAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], Merkez]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    /// <summary>Muayene: durum 1 açık · 3 tamamlandı. Tanı ve reçete satırları muayeneyle birlikte silinir (cascade).</summary>
    private async Task<int> MuayeneAsync(TestDunyasi d, int hasta, int sube, short durum = 1)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.muayene (taraf_id, sube_id, durum, muayene_tarihi) values (@p0, @p1, @p2, now()) returning id",
            [hasta, sube, durum]);
        d.Temizle($"delete from public.islem_log where tablo_id in (960, 963) and (kayit_id = {id} or ust_kayit_id = {id})");
        d.Temizle($"delete from public.muayene where id = {id}");
        return id;
    }

    /// <summary>Taslak reçete + bir ilaç satırı.</summary>
    private async Task<(int Recete, int Satir)> ReceteAsync(TestDunyasi d, int muayene, int hasta, int sube)
    {
        var recete = await api.Veri.TekDegerAsync<int>(
            "insert into public.recete (muayene_id, hasta_id, sube_id, durum) values (@p0, @p1, @p2, 1) returning id",
            [muayene, hasta, sube]);
        var satir = await api.Veri.TekDegerAsync<int>(
            "insert into public.recete_satir (recete_id, ilac_barkod, ilac_ad, doz, periyot) values (@p0, '8690000000001', 'Test ilaç', '1', '1x1') returning id",
            [recete]);
        d.Temizle($"delete from public.islem_log where tablo_id in (969, 970) and (kayit_id in ({recete}, {satir}) or ust_kayit_id = {recete})");
        d.Temizle($"delete from public.recete where id = {recete}");
        return (recete, satir);
    }

    /// <summary>Merkez'de çalışan, yalnız Merkez'e şube bağı olan hekim.</summary>
    private async Task<HttpClient> MerkezIstemcisiAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("hekim", "muayene:gde", "hasta:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    [VtFact]
    public async Task Baska_subenin_muayenesi_okunamaz_yazilamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var benim = await MuayeneAsync(d, hasta, Merkez);
        var ankara = await MuayeneAsync(d, hasta, Ankara);
        using var h = await MerkezIstemcisiAsync(d);

        // Kendi şubesi açılır.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/muayene/{benim}/sekme-verisi")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/muayene/{benim}/tanilar")).StatusCode);

        // Başka şube ve olmayan kayıt: AYNI 404.
        foreach (var yol in new[]
        {
            $"/api/muayene/{ankara}/sekme-verisi", $"/api/muayene/{ankara}/tanilar",
            $"/api/muayene/{ankara}/bulgu-metni", "/api/muayene/2147483000/sekme-verisi",
        })
            Assert.True((await h.GetAsync(yol)).StatusCode == HttpStatusCode.NotFound, yol);

        // Yazma yolları da kapalı: tanı ekleme, "tümü normal", muayeneye al.
        var icd = await api.Veri.TekDegerAsync<string>("select min(kod) from public.icd");
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync($"/api/muayene/{ankara}/tani/{icd}", new { kesinlik = 1 })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsync($"/api/muayene/{ankara}/tumu-normal", null)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsync($"/api/muayene/{ankara}/al", null)).StatusCode);

        // Yan etki yok: Ankara muayenesine tanı yazılmadı, başlangıç damgalanmadı.
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.tani where muayene_id = @p0", [ankara]));
        Assert.True(await api.Veri.TekDegerAsync<bool>(
            "select baslangic is null from public.muayene where id = @p0", [ankara]));
    }

    [VtFact]
    public async Task Baska_subenin_recete_satiri_silinemez_degistirilemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var benimMuayene = await MuayeneAsync(d, hasta, Merkez);
        var ankaraMuayene = await MuayeneAsync(d, hasta, Ankara);
        var benim = await ReceteAsync(d, benimMuayene, hasta, Merkez);
        var ankara = await ReceteAsync(d, ankaraMuayene, hasta, Ankara);
        using var h = await MerkezIstemcisiAsync(d);

        // Ankara reçetesinin satırı: silme ve düzeltme 404, satır yerinde ve değişmemiş.
        Assert.Equal(HttpStatusCode.NotFound, (await h.DeleteAsync($"/api/recete/{ankara.Recete}/ilac/{ankara.Satir}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PutAsJsonAsync($"/api/recete/{ankara.Recete}/ilac/{ankara.Satir}", new { doz = "99" })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsync($"/api/recete/{ankara.Recete}/imzala", null)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.DeleteAsync("/api/recete/2147483000/ilac/1")).StatusCode);
        Assert.Equal("1", await api.Veri.TekDegerAsync<string>(
            "select doz from public.recete_satir where id = @p0", [ankara.Satir]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select durum::int from public.recete where id = @p0", [ankara.Recete]));

        // Kendi reçetesi: satır silinir ve silme logu TAM SATIRLA, DELETE'ten önce düşer (970 → üst 969).
        Assert.Equal(HttpStatusCode.OK, (await h.DeleteAsync($"/api/recete/{benim.Recete}/ilac/{benim.Satir}")).StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.recete_satir where id = @p0", [benim.Satir]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("""
            select count(*)::int from public.islem_log
             where tablo_id = 970 and kayit_id = @p0 and islem_tipi = 0 and ust_tablo_id = 969 and ust_kayit_id = @p1
               and bilgi ->> 'ilac_barkod' = '8690000000001'
            """, [benim.Satir, benim.Recete]));
    }

    [VtFact]
    public async Task Tamamlanmis_muayeneye_tani_eklenmez_acik_muayenede_silme_loglanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var kapali = await MuayeneAsync(d, hasta, Merkez, durum: 3);
        var acik = await MuayeneAsync(d, hasta, Merkez);
        using var h = await MerkezIstemcisiAsync(d);
        var icd = await api.Veri.TekDegerAsync<string>("select min(kod) from public.icd");

        // Tamamlanmış muayene: tanı, şablon ve "tümü normal" 422 (IS_KURALI); tanı yazılmadı.
        var y = await h.PostAsJsonAsync($"/api/muayene/{kapali}/tani/{icd}", new { kesinlik = 1 });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, y.StatusCode);
        Assert.Equal("IS_KURALI", await ApiSunucuOlgusu.HataKoduAsync(y));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsync($"/api/muayene/{kapali}/tumu-normal", null)).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await h.PostAsJsonAsync($"/api/muayene/{kapali}/onceki-kopyala/{acik}", new { })).StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.tani where muayene_id = @p0", [kapali]));

        // Açık muayene: tanı eklenir, silinir; silme logu DELETE'ten önce tam satırla (963 → üst 960).
        Assert.Equal(HttpStatusCode.OK, (await h.PostAsJsonAsync($"/api/muayene/{acik}/tani/{icd}", new { kesinlik = 1 })).StatusCode);
        var taniId = await api.Veri.TekDegerAsync<int>(
            "select max(id) from public.tani where muayene_id = @p0", [acik]);
        Assert.Equal(HttpStatusCode.OK, (await h.DeleteAsync($"/api/muayene/{acik}/tani/{taniId}")).StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.tani where id = @p0", [taniId]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("""
            select count(*)::int from public.islem_log
             where tablo_id = 963 and kayit_id = @p0 and islem_tipi = 0 and ust_tablo_id = 960 and ust_kayit_id = @p1
               and bilgi ->> 'icd_kod' = @p2
            """, [taniId, acik, icd]));
    }
}
