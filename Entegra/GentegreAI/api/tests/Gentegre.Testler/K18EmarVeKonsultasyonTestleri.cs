using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K18 (eMAR doz gecikmesi şube duvar saati ile UTC anı kıyaslıyordu:
/// planlanan = şimdi olan doz 3 saat "geç" sayılıp gecikme sebebi istiyordu), K17 (başka istemin konsültasyon
/// id'siyle görüş yazılabiliyordu), K59 (arada uygulanan doz koşulsuz ezilebiliyordu), K37 (OnayMotoru'nda aynı
/// basamağa iki karar - ikincisi 422).
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K18EmarVeKonsultasyonTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<int> HastaAsync(TestDunyasi d)
    {
        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, 1) returning id", [d.Onek + " hasta"]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        return hasta;
    }

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, string rolAdi, params string[] yetkiler)
    {
        var rol = await d.RolAsync(rolAdi, yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    // ------------------------------------------------------------------ K18 / K59 ----

    /// <summary>Yatış + order + planlanan dozu ŞİMDİ olan tek uygulama satırı.</summary>
    private async Task<(int Yatis, long Doz)> DozAsync(TestDunyasi d, int hasta)
    {
        var yatis = await api.Veri.TekDegerAsync<int>(
            "insert into public.yatis (hasta_id, sube_id, durum) values (@p0, @p1, 2) returning id", [hasta, Merkez]);
        // Order ve dozlar yatışla birlikte düşer (FK cascade); temizlik taraf silinmeden önce koşar.
        d.Temizle($"delete from public.yatis where id = {yatis}");
        // saatler boş: tetik kendi doz satırını üretmez, planı test yazar.
        var order = await api.Veri.TekDegerAsync<int>("""
            insert into public.yatis_order (yatis_id, sube_id, tur, ad, durum, saatler)
            values (@p0, @p1, 1, 'Test ilaç 1x1', 1, '[]'::jsonb) returning id
            """, [yatis, Merkez]);
        var doz = await api.Veri.TekDegerAsync<long>(
            "insert into public.order_uygulama (order_id, planlanan, durum) values (@p0, now(), 1) returning id", [order]);
        return (yatis, doz);
    }

    [VtFact]
    public async Task Planlanan_simdi_olan_doz_gecikmis_sayilmaz_ve_ikinci_uygulama_reddedilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var (_, doz) = await DozAsync(d, hasta);
        using var h = await IstemciAsync(d, "hemsire", "yatan.order:gd");

        // Gecikme sebebi YOK: planlanan an = şimdi, 30 dakikalık eşiğin altında -> 200 ve gecikti=false.
        //   Düzeltme öncesi şube duvar saati (UTC+3) UTC anla kıyaslanıp 400 "gecikme sebebi yazılmalı" dönüyordu.
        var y = await h.PostAsJsonAsync($"/api/yatan/doz/{doz}/uygula", new { elleDogrulandi = true });
        Assert.True(y.StatusCode == HttpStatusCode.OK, $"uygula {(int)y.StatusCode}: {await y.Content.ReadAsStringAsync()}");
        var j = await y.Content.ReadFromJsonAsync<JsonElement>();
        Assert.False(j.GetProperty("gecikti").GetBoolean());
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select durum::int from public.order_uygulama where id = @p0", [doz]));
        // Uygulanan an UTC olarak yazıldı: planlanandan en fazla birkaç dakika uzak (dilim kayması 3 saat olurdu).
        Assert.True(await api.Veri.TekDegerAsync<bool>(
            "select abs(extract(epoch from (uygulanan - planlanan))) < 600 from public.order_uygulama where id = @p0", [doz]));

        // K59: uygulanmış doz ikinci kez uygulanamaz / atlanmış yapılamaz - 422, kayıt değişmez.
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await h.PostAsJsonAsync($"/api/yatan/doz/{doz}/uygula", new { elleDogrulandi = true })).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await h.PostAsJsonAsync($"/api/yatan/doz/{doz}/atla", new { atlamaNedeni = "deneme", hastaReddetti = false })).StatusCode);
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select durum::int from public.order_uygulama where id = @p0", [doz]));
    }

    [VtFact]
    public async Task Kapsam_disi_subenin_dozu_404()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var (yatis, doz) = await DozAsync(d, hasta);
        // Yatışı başka (pasif) şubeye taşı: kullanıcının şubesi Merkez - liste de göstermez, doz ucu da 404 (K59).
        var baskaSube = await d.PasifSubeAsync();
        await api.Veri.CalistirAsync("update public.yatis set sube_id = @p1 where id = @p0", [yatis, baskaSube]);
        using var h = await IstemciAsync(d, "hemsire", "yatan.order:gd");

        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync($"/api/yatan/doz/{doz}/uygula", new { elleDogrulandi = true })).StatusCode);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select durum::int from public.order_uygulama where id = @p0", [doz]));
    }

    // ------------------------------------------------------------------------ K17 ----

    private async Task<int> RadyolojiIstemAsync(TestDunyasi d, int hasta)
    {
        var hizmet = await api.Veri.TekDegerAsync<int>(
            "select min(id) from public.hizmet where coalesce(modalite, 0) > 0 and coalesce(cinsiyet, 0) = 0");
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (hasta_id, hizmet_id, accession_no, sube_id, durum, serbest)
            values (@p0, @p1, @p2, @p3, 3, 1) returning id
            """, [hasta, hizmet, d.Onek + "-" + Guid.NewGuid().ToString("N")[..6], Merkez]);
        // Konsültasyon satırları istemle düşer (FK cascade).
        d.Temizle($"delete from public.radyoloji_istem where id = {istem}");
        return istem;
    }

    [VtFact]
    public async Task Baska_istemin_konsultasyon_idsi_ile_cevap_404_ve_gorus_degismez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var istemA = await RadyolojiIstemAsync(d, hasta);
        var istemB = await RadyolojiIstemAsync(d, hasta);
        var konsB = await api.Veri.TekDegerAsync<int>(
            "insert into public.radyoloji_konsultasyon (istem_id, durum, gerekce) values (@p0, 1, 'ikinci görüş') returning id", [istemB]);
        using var h = await IstemciAsync(d, "rad", "radyoloji:gde", "radyoloji-istem:gde", "rad.rapor_yaz");

        // A isteminin yolundan B'nin konsültasyonuna görüş: 404, B'nin görüşü ve durumu değişmez.
        var yanlis = await h.PostAsJsonAsync($"/api/radyoloji/istem/{istemA}/konsultasyon?konsultasyonId={konsB}",
            new { gerekce = "", gorus = "yabancı görüş" });
        Assert.Equal(HttpStatusCode.NotFound, yanlis.StatusCode);
        Assert.Equal("", await api.Veri.TekDegerAsync<string>("select gorus from public.radyoloji_konsultasyon where id = @p0", [konsB]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_konsultasyon where id = @p0", [konsB]));

        // Doğru istemden cevap geçer; cevaplanmış görüşe ikinci cevap yine 404 (açık konsültasyon yok).
        var dogru = await h.PostAsJsonAsync($"/api/radyoloji/istem/{istemB}/konsultasyon?konsultasyonId={konsB}",
            new { gerekce = "", gorus = "uyumlu" });
        Assert.True(dogru.StatusCode == HttpStatusCode.OK, $"cevap {(int)dogru.StatusCode}: {await dogru.Content.ReadAsStringAsync()}");
        Assert.Equal("uyumlu", await api.Veri.TekDegerAsync<string>("select gorus from public.radyoloji_konsultasyon where id = @p0", [konsB]));
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_konsultasyon where id = @p0", [konsB]));
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync($"/api/radyoloji/istem/{istemB}/konsultasyon?konsultasyonId={konsB}",
                new { gerekce = "", gorus = "ikinci kez" })).StatusCode);
        Assert.Equal("uyumlu", await api.Veri.TekDegerAsync<string>("select gorus from public.radyoloji_konsultasyon where id = @p0", [konsB]));
    }

    // ------------------------------------------------------------------------ K37 ----

    private static IstekBaglami Baglam(int kullanici) => new()
    {
        KullaniciId = kullanici, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = Merkez,
        Yetkiler = new YetkiSeti(1, [], []),
    };

    /// <summary>
    /// Aynı basamağa iki eşzamanlı karar: ikincisi onay satırının kilidinde bekler, ilki commit olunca
    /// basamağı karara bağlanmış bulur ve 422 (IS_KURALI) alır - imza iki kez yazılmaz, sıra iki kez ilerlemez.
    /// Motor doğrudan çağrılır (fikstür: iki basamaklı akış, kaynağa bağlı olmayan kaynak kimliği).
    /// </summary>
    [VtFact]
    public async Task Ayni_basamaga_ikinci_karar_422()
    {
        await using var d = new TestDunyasi(api.Veri);
        const int kaynakTur = 1241;
        var kaynakId = -Random.Shared.NextInt64(1_000_000, 9_000_000);
        var akisKod = (d.Onek + "_k37").ToLowerInvariant();
        var akisId = await api.Veri.TekDegerAsync<int>(
            "insert into public.onay_akis (kod, ad, kaynak_tur, aktif) values (@p0, 'K37 testi', @p1, 1) returning id",
            [akisKod, kaynakTur]);
        d.Temizle($"delete from public.onay where kaynak_tur = {kaynakTur} and kaynak_id = {kaynakId}");
        d.Temizle($"delete from public.onay_akis where id = {akisId}");
        await api.Veri.CalistirAsync("""
            insert into public.onay_akis_adim (akis_id, sira, ad, sahip_turu, rol, aktif)
            values (@p0, 1, 'Birinci imza', 1, 0, 1), (@p0, 2, 'İkinci imza', 1, 0, 1)
            """, [akisId]);

        var motor = new OnayMotoru(api.Veri);
        var baglam = Baglam(1);
        await using (var b0 = await api.Veri.AcAsync())
            await motor.BaslatAsync(b0, null, akisKod, kaynakId, 0, [], baglam);

        // 1. karar: işlem AÇIK bırakılır (onay satırı kilitli).
        await using var b1 = await api.Veri.AcAsync();
        await using var t1 = await b1.BeginTransactionAsync();
        var ilk = await motor.KararAsync(b1, t1, kaynakTur, kaynakId, OnayMotoru.Onaylandi, null, baglam);
        Assert.Equal(1, ilk.Sira);

        // 2. karar aynı basamağa: kilitte bekler. Beklediği pg_stat_activity'den görülür, sonra ilki commit edilir.
        await using var b2 = await api.Veri.AcAsync();
        var pid2 = await b2.TekDegerAsync<int>("select pg_backend_pid()", null, null);
        await using var t2 = await b2.BeginTransactionAsync();
        var ikinci = motor.KararAsync(b2, t2, kaynakTur, kaynakId, OnayMotoru.Onaylandi, null, baglam);

        var bekleme = DateTime.UtcNow.AddSeconds(15);
        while (DateTime.UtcNow < bekleme && !ikinci.IsCompleted)
        {
            var bekliyor = await api.Veri.TekDegerAsync<string>(
                "select coalesce(wait_event_type, '') from pg_stat_activity where pid = @p0", [pid2]);
            if (bekliyor == "Lock") break;
            await Task.Delay(100);
        }
        await t1.CommitAsync();

        var hata = await Assert.ThrowsAsync<GentegreHatasi>(() => ikinci);
        Assert.Equal(HataKodu.IsKurali, hata.Kod);
        await t2.RollbackAsync();

        // Basamak 1 bir kez karara bağlandı, basamak 2 hâlâ bekliyor, zincir yürüyor.
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select a.durum::int from public.onay_adim a join public.onay o on o.id = a.onay_id where o.kaynak_tur = @p0 and o.kaynak_id = @p1 and a.sira = 1",
            [kaynakTur, kaynakId]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select a.durum::int from public.onay_adim a join public.onay o on o.id = a.onay_id where o.kaynak_tur = @p0 and o.kaynak_id = @p1 and a.sira = 2",
            [kaynakTur, kaynakId]));
    }
}
