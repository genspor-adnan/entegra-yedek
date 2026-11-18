using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Api.Servisler;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// HASTA VERİSİ İNCELEMESİ 18.11.2026 bulgu 7-10:
///  7 KVKK SMS kodu eşzamanlı denemede de 5 hakla sınırlı · 8 portal davetinde eşzamanlı deneme sınırı, kişi başına
///  24 saat sınırı, kimliksiz ad maskeli · 9 MERNİS doğrulama portala ve yalnız görme yetkisine kapalı · 10 e-Nabız
///  paket kartı şube kapsamında. (6 - silme paketinin bildirim kapısından muaf olması - üretici koşuludur.)
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HastaVerisiIkinciTurTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, string ad, short portalTuru, params string[] yetkiler)
    {
        var rol = await d.RolAsync(ad, yetkiler);
        if (portalTuru > 0)
            await api.Veri.CalistirAsync("update public.rol set portal_turu = @p1 where id = @p0", [rol, portalTuru]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, hasta: portalTuru == 3);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private async Task<int> HastaAsync(TestDunyasi d, string tckn, string ad)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, hasta, kisi, sube_id, vkno, durum) values (@p0, @p1, @p2, 1, 1, 1, @p3, 1) returning id",
            [ad, ad.Split(' ')[0], ad.Split(' ')[1], tckn]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    [VtFact]
    public async Task KVKK_kodu_eszamanli_denemede_de_bes_hakla_sinirli()
    {
        await using var d = new TestDunyasi(api.Veri);
        using var h = await IstemciAsync(d, "kvkk", 0, "belge:gd");
        var hasta = await HastaAsync(d, "9" + Random.Shared.NextInt64(1000000000, 9999999999), "Kvkk Deneme");
        var belge = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no, kdv_durum, belge_dovizi, rapor_dovizi, doviz_kuru)
            values (19, 30, 0, now(), @p0, 1, 'KVKKTEST', 'Dahil', 'TL', 'TL', 1) returning id
            """, [hasta]);
        var kod = Random.Shared.Next(100000, 1000000).ToString();
        await api.Veri.CalistirAsync("""
            insert into public.belge_basvuru (id, kvkk_sms_kod, kvkk_sms_tarihi, kvkk_kod_hata) values (@p0, @p1, now(), 0)
            on conflict (id) do update set kvkk_sms_kod = excluded.kvkk_sms_kod, kvkk_sms_tarihi = now(), kvkk_kod_hata = 0
            """, [belge, kod]);
        d.Temizle($"delete from public.belge where id = {belge}");
        d.Temizle($"delete from public.belge_basvuru where id = {belge}");
        d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {belge}");

        var yanlis = Enumerable.Range(0, 20).Select(i => ((int.Parse(kod) + 1 + i) % 900000 + 100000).ToString()).ToArray();
        var yanitlar = await Task.WhenAll(yanlis.Select(k => h.PostAsJsonAsync($"/api/basvuru/{belge}/kvkk-kod", new { kod = k })));
        Assert.All(yanitlar, y => Assert.Equal(HttpStatusCode.UnprocessableEntity, y.StatusCode));
        // Eskiden hepsi "0 hata" okuyup denenirdi; şimdi en çok 5 deneme değerlendirilir.
        Assert.Equal(5, await api.Veri.TekDegerAsync<int>("select kvkk_kod_hata::int from public.belge_basvuru where id = @p0", [belge]));
        // Hak bitti: doğru kod da artık geçmez (yeni SMS gerekir).
        var dogru = await h.PostAsJsonAsync($"/api/basvuru/{belge}/kvkk-kod", new { kod });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, dogru.StatusCode);
    }

    [VtFact]
    public async Task Portal_davetinde_deneme_sinirlari_ve_maskeli_ad()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tckn = "9" + Random.Shared.NextInt64(1000000000, 9999999999);
        var hasta = await HastaAsync(d, tckn, "Ayşe Yılmazoğlu");
        d.Temizle($"delete from public.portal_davet where taraf_id = {hasta}");
        async Task<string> DavetAsync()
        {
            var jeton = Guid.NewGuid().ToString("N") + Guid.NewGuid().ToString("N");
            await api.Veri.CalistirAsync("""
                insert into public.portal_davet (taraf_id, kanal, alici, jeton_ozet, durum, gecerlilik)
                values (@p0, 1, '905000000000', @p1, 1, (now() + interval '48 hours')::timestamp)
                """, [hasta, PortalDavetServisi.Ozet(jeton)]);
            return jeton;
        }
        using var h = api.Istemci(null, null);

        var j1 = await DavetAsync();
        var g = await (await h.GetAsync($"/api/davet/{j1}")).Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(g.GetProperty("gecerli").GetBoolean());
        Assert.Equal("A*** Y***", g.GetProperty("kisi").GetString());          // tam ad dönmez

        var son4 = tckn[^4..];
        var yanlis = son4 == "0000" ? "1111" : "0000";
        var yanitlar = await Task.WhenAll(Enumerable.Range(0, 20).Select(_ =>
            h.PostAsJsonAsync("/api/davet/kullan", new { jeton = j1, tcknSon4 = yanlis, yeniParola = "Uzun.Parola.2026!" })));
        Assert.All(yanitlar, y => Assert.Equal(HttpStatusCode.Unauthorized, y.StatusCode));
        Assert.Equal(5, await api.Veri.TekDegerAsync<int>(
            "select deneme::int from public.portal_davet where taraf_id = @p0", [hasta]));      // eskiden 20

        // Yeni davet hakkı tazelemez: kişinin 24 saatlik sınırı dolu - doğru son 4 bile geçmez.
        var j2 = await DavetAsync();
        var y2 = await h.PostAsJsonAsync("/api/davet/kullan", new { jeton = j2, tcknSon4 = son4, yeniParola = "Uzun.Parola.2026!" });
        Assert.Equal(HttpStatusCode.Unauthorized, y2.StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.taraf_kullanici where id = @p0", [hasta]));
    }

    [VtFact]
    public async Task MERNIS_dogrulama_portala_ve_yalniz_gorme_yetkisine_kapali()
    {
        await using var d = new TestDunyasi(api.Veri);
        var istek = new { kimlikNo = "10000000146", ad = "AHMET", soyad = "YILMAZ", dogumYili = 1980 };
        using (var portal = await IstemciAsync(d, "portal-mernis", 3, "hasta:ge"))
            Assert.Equal(HttpStatusCode.Forbidden, (await portal.PostAsJsonAsync("/api/mernis/dogrula", istek)).StatusCode);
        using (var gorur = await IstemciAsync(d, "gorur-mernis", 0, "hasta:g"))
            Assert.Equal(HttpStatusCode.Forbidden, (await gorur.PostAsJsonAsync("/api/mernis/dogrula", istek)).StatusCode);
    }

    [VtFact]
    public async Task e_Nabiz_paket_karti_sube_kapsaminda()
    {
        await using var d = new TestDunyasi(api.Veri);
        using var h = await IstemciAsync(d, "entegrasyon", 0, "entegrasyon:g");
        var baskaSube = await api.Veri.TekDegerAsync<int>("select id from public.sube where id <> @p0 order by id limit 1", [Merkez]);
        async Task<long> PaketAsync(int sube)
        {
            var id = await api.Veri.TekDegerAsync<long>("""
                insert into public.enabiz_paket (paket_turu_id, kaynak_tur, kaynak_id, sube_id, icerik_hash)
                values ((select min(id) from public.enabiz_paket_turu), 1, 0, @p0, @p1) returning id
                """, [sube, Guid.NewGuid().ToString("N")]);
            d.Temizle($"delete from public.enabiz_paket where id = {id}");
            return id;
        }
        var benim = await PaketAsync(Merkez);
        var baska = await PaketAsync(baskaSube);
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/enabiz/paket/{benim}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.GetAsync($"/api/enabiz/paket/{baska}")).StatusCode);
    }
}
