using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// HBYS İNCELEMESİ 18.11.2026 (lab / radyoloji / muayene / reçete):
///  1 lab istemi gövdedeki başvuru / hastanın kapsamından geçer · 3 reçete kopyala ilaç eklemeyle aynı kurallar
///  (tamamlanmış muayene 422, reçete türü yükselir, alerji uyarısı) · 4 reçete kontrolü sorgudaki hastanın kayıt kapsamından geçer
///  · 8 ilaç eklemede kutu / süre sınırı · 9 akılcı karar salt okunur şubede yazmaz · 10 muayene raporu silme / değişiklik loglanır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HbysIncelemeTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int Ankara = 3;

    private async Task<int> HastaAsync(TestDunyasi d, int sube)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], sube]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    private async Task<int> MuayeneAsync(TestDunyasi d, int hasta, int sube, short durum = 1)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.muayene (taraf_id, sube_id, durum, muayene_tarihi) values (@p0, @p1, @p2, now()) returning id",
            [hasta, sube, durum]);
        d.Temizle($"delete from public.islem_log where tablo_id in (960, 963) and (kayit_id = {id} or ust_kayit_id = {id})");
        d.Temizle($"delete from public.muayene where id = {id}");
        d.Temizle($"delete from public.recete where muayene_id = {id}");
        return id;
    }

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, params string[] yetkiler)
    {
        var rol = await d.RolAsync("hbysinc", yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    [VtFact]
    public async Task Lab_istemi_baska_subenin_basvurusuna_acilamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d, Ankara);
        var belge = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge (tur, taraf_id, sube_id, belge_tarihi) values (19, @p0, @p1, now()) returning id",
            [hasta, Ankara]);
        d.Temizle($"delete from public.belge where id = {belge}");
        using var h = await IstemciAsync(d, "lab:gde", "hasta:g");

        var y = await h.PostAsJsonAsync("/api/lab/istem", new { belgeId = belge, satirlar = Array.Empty<object>() });
        Assert.Equal(HttpStatusCode.NotFound, y.StatusCode);
        var y2 = await h.PostAsJsonAsync("/api/lab/istem", new { belgeId = belge, hastaId = hasta, satirlar = Array.Empty<object>() });
        Assert.Equal(HttpStatusCode.NotFound, y2.StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.lab_istem where belge_id = @p0", [belge]));
    }

    [VtFact]
    public async Task Recete_kontrolu_kapsam_disi_hastayi_okumaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var benim = await HastaAsync(d, Merkez);
        var baska = await HastaAsync(d, Merkez);
        // Kayıt kapsamı tanımlı kullanıcı (K42): yalnız `benim` hastasını görür.
        var rol = await d.RolAsync("hbysinc", "muayene:gde", "hasta:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        await api.Veri.CalistirAsync("insert into public.kullanici_kapsam (kullanici_id, tur, hedef_id) values (@p0, 1, @p1)", [u, benim]);
        d.Temizle($"delete from public.kullanici_kapsam where kullanici_id = {u}");
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/recete/kontrol?hastaId={benim}&barkod=8690000000001")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/recete/kontrol?hastaId={baska}&barkod=8690000000001")).StatusCode);
    }

    [VtFact]
    public async Task Recete_kopyala_ilac_ekleme_kurallarini_uygular()
    {
        await using var d = new TestDunyasi(api.Veri);
        var barkod = "869" + Random.Shared.NextInt64(1_000_000_000L, 9_999_999_999L);
        await api.Veri.CalistirAsync(
            "insert into public.ilac (barkod, ad, etken_madde, recete_turu) values (@p0, @p1, 'testmadde', 2)",
            [barkod, d.Onek + " kontrollü ilaç"]);
        d.Temizle($"delete from public.ilac where barkod = '{barkod}'");
        var hasta = await HastaAsync(d, Merkez);

        // Önceki muayenenin İMZALI kırmızı reçetesi.
        var eski = await MuayeneAsync(d, hasta, Merkez, durum: 3);
        var kaynak = await api.Veri.TekDegerAsync<int>(
            "insert into public.recete (muayene_id, hasta_id, sube_id, durum, tur, imza_zamani) values (@p0, @p1, @p2, 2, 2, now()) returning id",
            [eski, hasta, Merkez]);
        await api.Veri.CalistirAsync(
            "insert into public.recete_satir (recete_id, ilac_barkod, ilac_ad, doz, periyot) values (@p0, @p1, 'Kontrollü', '1', '1x1')",
            [kaynak, barkod]);
        // Alerji kaydı sonradan girildi - kopyada uyarı çıkmalı.
        await api.Veri.CalistirAsync(
            "insert into public.hasta_ilac (hasta_id, ilac_barkod, ilac_ad, etken_madde, aktif) values (@p0, '8690000000999', 'Başka marka', 'testmadde', 1)",
            [hasta]);
        d.Temizle($"delete from public.hasta_ilac where hasta_id = {hasta}");

        using var h = await IstemciAsync(d, "muayene:gde", "hasta:g");

        // Tamamlanmış muayeneye kopya yok.
        var tamam = await MuayeneAsync(d, hasta, Merkez, durum: 3);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsync($"/api/recete/muayene/{tamam}/kopyala", null)).StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.recete where muayene_id = @p0", [tamam]));

        var yeni = await MuayeneAsync(d, hasta, Merkez);
        var y = await h.PostAsync($"/api/recete/muayene/{yeni}/kopyala", null);
        var g = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, g);
        var kok = JsonDocument.Parse(g).RootElement;
        var recete = kok.GetProperty("receteId").GetInt32();
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select tur::int from public.recete where id = @p0", [recete]));   // eskiden 0
        Assert.Contains(kok.GetProperty("uyarilar").EnumerateArray(), u => u.GetString()!.StartsWith("TEKRAR"));
    }

    [VtFact]
    public async Task Recete_ilac_eklemede_kutu_ve_sure_sinirlanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var barkod = "869" + Random.Shared.NextInt64(1_000_000_000L, 9_999_999_999L);
        await api.Veri.CalistirAsync("insert into public.ilac (barkod, ad) values (@p0, @p1)", [barkod, d.Onek + " ilaç"]);
        d.Temizle($"delete from public.ilac where barkod = '{barkod}'");
        var hasta = await HastaAsync(d, Merkez);
        var muayene = await MuayeneAsync(d, hasta, Merkez);
        using var h = await IstemciAsync(d, "muayene:gde", "hasta:g");

        foreach (var govde in new object[] { new { barkod, kutu = 70000 }, new { barkod, kutu = -5 }, new { barkod, sureGun = 40000 } })
            Assert.Equal(HttpStatusCode.BadRequest, (await h.PostAsJsonAsync($"/api/recete/muayene/{muayene}", govde)).StatusCode);
        var y = await h.PostAsJsonAsync($"/api/recete/muayene/{muayene}", new { barkod, kutu = 2, doz = new string('x', 30) });
        Assert.True(y.IsSuccessStatusCode, await y.Content.ReadAsStringAsync());          // eskiden uzun doz 500
        Assert.Equal(20, await api.Veri.TekDegerAsync<int>(
            "select length(s.doz) from public.recete_satir s join public.recete r on r.id = s.recete_id where r.muayene_id = @p0", [muayene]));
    }

    [VtFact]
    public async Task Akilci_karar_salt_okunur_subede_yazilmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d, Merkez);
        var rol = await d.RolAsync("hbysinc", "lab:g", "hasta:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: false, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        var y = await h.PostAsJsonAsync("/api/lab/akilci-karar",
            new { hastaId = hasta, kararlar = new[] { new { tetkikId = 1, kural = "sure", gerekceKod = 0 } } });
        Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);                                  // eskiden 200
    }

    [VtFact]
    public async Task Muayene_raporu_silme_ve_degisiklik_loglanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d, Merkez);
        var muayene = await MuayeneAsync(d, hasta, Merkez);
        var rapor = await api.Veri.TekDegerAsync<int>(
            "insert into public.muayene_rapor (muayene_id, hasta_id, tur, gun, sube_id) values (@p0, @p1, 1, 3, @p2) returning id",
            [muayene, hasta, Merkez]);
        d.Temizle($"delete from public.islem_log where tablo_id = 966 and kayit_id = {rapor}");
        d.Temizle($"delete from public.muayene_rapor where id = {rapor}");
        using var h = await IstemciAsync(d, "muayene:gde", "hasta:g");
        Task<int> Log(short islem) => api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.islem_log where tablo_id = 966 and kayit_id = @p0 and islem_tipi = @p1", [rapor, islem]);

        var put = await h.PutAsJsonAsync($"/api/muayene/rapor/{rapor}", new { tur = 1, gun = 5, aciklama = "istirahat", icdKod = "J06" });
        Assert.True(put.IsSuccessStatusCode, await put.Content.ReadAsStringAsync());
        var sil = await h.DeleteAsync($"/api/muayene/rapor/{rapor}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(1, await Log(2));                                                         // değişiklik (eskiden 0)
        Assert.Equal(1, await Log(0));                                                         // silme (eskiden 0)
    }
}
