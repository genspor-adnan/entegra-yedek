using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// TEKLİF İÇ ONAYI (1282, mockup Ekranlar/Teklif/teklif_ic_onay.html): hazırlayan onaylayanı seçip onaya sunar,
/// teklif Onayda (6) olur ve kalemler kilitlenir; onaylayan Onayımdakiler'de görür; "bilgi-iste" = düzeltme (8,
/// kilit açılır); "onayla" = Onaylandı (7); "reddet" = Reddedildi (9). Yeniden sunumda eski zincir kapanır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class TeklifIcOnayTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(HttpClient Hazirlayan, HttpClient Onaylayan, int OnaylayanId, int BelgeId)> KurAsync(TestDunyasi d)
    {
        // Tür izni (TurIzinli): satış teklifi `belge.satis` ekran kodunun DEĞİŞTİR yetkisini ister.
        var hazirlayanRol = await d.RolAsync("tklhaz", "belge:ged", "belge.satis:ged");
        var onaylayanRol = await d.RolAsync("tklony", "belge:g", "belge.teklif_onay");
        var (hazId, hazKod) = await d.KullaniciAsync(hazirlayanRol, Merkez);
        var (onyId, onyKod) = await d.KullaniciAsync(onaylayanRol, Merkez);
        await d.SubeVerAsync(hazId, Merkez, yazma: true, varsayilan: true);
        await d.SubeVerAsync(onyId, Merkez, yazma: true, varsayilan: true);

        var tarafId = await api.Veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, musteri, sube_id) values (@p0, 1, @p1) returning id
            """, [d.Onek + " Müşteri", Merkez]);
        d.Temizle($"delete from public.taraf where id = {tarafId}");
        var belgeId = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id, teklif_durum, genel_toplam, belge_no)
            values (18, now(), @p0, 0, @p1, 1, 1500, @p2) returning id
            """, [tarafId, Merkez, d.Onek]);
        d.Temizle($"delete from public.islem_log where (tablo_id = 30 and kayit_id = {belgeId}) or (tablo_id = 1243 and kayit_id in (select id from public.onay where kaynak_tur = 30 and kaynak_id = {belgeId}))");
        d.Temizle($"delete from public.onay_adim where onay_id in (select id from public.onay where kaynak_tur = 30 and kaynak_id = {belgeId})");
        d.Temizle($"delete from public.onay where kaynak_tur = 30 and kaynak_id = {belgeId}");
        d.Temizle($"delete from public.belge where id = {belgeId}");

        var (hazAccess, _) = await api.GirisAsync(hazKod, TestDunyasi.Parola);
        var (onyAccess, _) = await api.GirisAsync(onyKod, TestDunyasi.Parola);
        return (api.Istemci(hazAccess, Merkez), api.Istemci(onyAccess, Merkez), onyId, belgeId);
    }

    private static async Task BasariliAsync(Task<HttpResponseMessage> istek)
    {
        var y = await istek;
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {await y.Content.ReadAsStringAsync()}");
    }

    private async Task<int> TeklifDurumAsync(int belgeId) =>
        await api.Veri.TekDegerAsync<int>("select coalesce(teklif_durum, 1) from public.belge where id = @p0", [belgeId]);

    [VtFact]
    public async Task Onaya_sun_kilitler_onaylayan_onaylar_7_olur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (haz, ony, onyId, belgeId) = await KurAsync(d);

        // Onaylayan seçim listesi yetkiden gelir.
        var yetkili = await ony.GetFromJsonAsync<List<JsonElement>>("/api/onay/yetkili/belge.teklif_onay");
        Assert.Contains(yetkili!, x => x.GetProperty("id").GetInt32() == onyId);

        var y = await haz.PostAsJsonAsync($"/api/belge/{belgeId}/onaya-sun",
            new { onaylayanId = onyId, sonTarih = (string?)null, not = "bayi fiyatı" });
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, govde);
        Assert.Equal(6, await TeklifDurumAsync(belgeId));

        // Onaydayken kalem/başlık değişikliği 422.
        var k = await haz.PutAsJsonAsync($"/api/belge/{belgeId}", new { belge = new { aciklama = "x" }, satirlar = Array.Empty<object>() });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, k.StatusCode);
        // Elle durum değişikliği de 422.
        var e = await haz.PostAsJsonAsync($"/api/belge/{belgeId}/teklif-durum", new { durum = 2 });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, e.StatusCode);

        // Onay sekmesi: kim sundu, kime düştü (adıyla).
        var zincir = await haz.GetFromJsonAsync<JsonElement>($"/api/onay/kayit/30/{belgeId}");
        Assert.False(string.IsNullOrEmpty(zincir.GetProperty("onay").GetProperty("baslatanAd").GetString()));
        var adim = zincir.GetProperty("adimlar").EnumerateArray().First();
        Assert.Equal(onyId, adim.GetProperty("atananId").GetInt32());
        Assert.False(string.IsNullOrEmpty(adim.GetProperty("atananAd").GetString()));

        // Onaylayanın kutusunda görünür (akış kodu, kayıt no).
        var kutu = await ony.GetFromJsonAsync<JsonElement>("/api/onay/kutum");
        var satir = kutu.GetProperty("satirlar").EnumerateArray()
            .FirstOrDefault(s => s.GetProperty("kaynakTur").GetInt32() == 30 && s.GetProperty("kaynakId").GetInt64() == belgeId);
        Assert.NotEqual(JsonValueKind.Undefined, satir.ValueKind);
        Assert.Equal("teklif.satis", satir.GetProperty("akisKod").GetString());
        Assert.Equal(d.Onek, satir.GetProperty("kayitNo").GetString());

        // Hazırlayan karar veremez: aksiyon yetkisi yok (403); yetkisi olsa da atanan başkası / vekâlet yok (422).
        var yanlis = await haz.PostAsJsonAsync($"/api/onay/kayit/30/{belgeId}/karar", new { karar = "onayla" });
        Assert.Contains(yanlis.StatusCode, new[] { HttpStatusCode.Forbidden, HttpStatusCode.UnprocessableEntity });

        var karar = await ony.PostAsJsonAsync($"/api/onay/kayit/30/{belgeId}/karar", new { karar = "onayla", gerekce = "uygun" });
        Assert.True(karar.IsSuccessStatusCode, await karar.Content.ReadAsStringAsync());
        Assert.Equal(7, await TeklifDurumAsync(belgeId));

        // Onaylandı: hâlâ kilitli; durum elle Sunuldu'ya alınabilir (müşteriye gönderim).
        var k2 = await haz.PutAsJsonAsync($"/api/belge/{belgeId}", new { belge = new { aciklama = "y" }, satirlar = Array.Empty<object>() });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, k2.StatusCode);
        var sun = await haz.PostAsJsonAsync($"/api/belge/{belgeId}/teklif-durum", new { durum = 2 });
        Assert.True(sun.IsSuccessStatusCode, await sun.Content.ReadAsStringAsync());
        Assert.Equal(2, await TeklifDurumAsync(belgeId));
    }

    [VtFact]
    public async Task Duzeltme_iste_8_yapar_yeniden_sunulur_geri_cek_1_yapar()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (haz, ony, onyId, belgeId) = await KurAsync(d);

        await BasariliAsync(haz.PostAsJsonAsync($"/api/belge/{belgeId}/onaya-sun", new { onaylayanId = onyId }));
        var duz = await ony.PostAsJsonAsync($"/api/onay/kayit/30/{belgeId}/karar", new { karar = "bilgi-iste", gerekce = "iskonto %10'u geçmesin" });
        Assert.True(duz.IsSuccessStatusCode, await duz.Content.ReadAsStringAsync());
        Assert.Equal(8, await TeklifDurumAsync(belgeId));

        // Düzeltme istendi: kilit açık, hazırlayan düzeltip yeniden sunar - eski zincir kapanır, yenisi açılır.
        await BasariliAsync(haz.PostAsJsonAsync($"/api/belge/{belgeId}/onaya-sun", new { onaylayanId = onyId, not = "düzeltildi" }));
        Assert.Equal(6, await TeklifDurumAsync(belgeId));
        var zincirler = await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.onay where kaynak_tur = 30 and kaynak_id = @p0", [belgeId]);
        var acik = await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.onay where kaynak_tur = 30 and kaynak_id = @p0 and durum = 0", [belgeId]);
        Assert.Equal(2, zincirler);
        Assert.Equal(1, acik);

        // Geri çek: zincir iptal, durum Hazırlanıyor, kart yeniden yazılabilir.
        var geri = await haz.PostAsJsonAsync($"/api/belge/{belgeId}/onay-geri-cek", new { });
        Assert.True(geri.IsSuccessStatusCode, await geri.Content.ReadAsStringAsync());
        Assert.Equal(1, await TeklifDurumAsync(belgeId));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.onay where kaynak_tur = 30 and kaynak_id = @p0 and durum = 0", [belgeId]));

        // Reddet -> 9, kart açık.
        await BasariliAsync(haz.PostAsJsonAsync($"/api/belge/{belgeId}/onaya-sun", new { onaylayanId = onyId }));
        var ret = await ony.PostAsJsonAsync($"/api/onay/kayit/30/{belgeId}/karar", new { karar = "reddet", gerekce = "olmaz" });
        Assert.True(ret.IsSuccessStatusCode, await ret.Content.ReadAsStringAsync());
        Assert.Equal(9, await TeklifDurumAsync(belgeId));
    }
}
