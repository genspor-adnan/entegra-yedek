using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// İSKONTO SÖZLÜ ONAY (1375, kullanıcı 18.11.2026: "bir çok müşterimiz sözlü onay kullanıyor.. banko ilgili
/// yöneticinin sözüyle yüksek oranlarda indirim yapabiliyor" · "sözlü onay / dijital onay opsiyonlu olabilmeli").
///
/// Şube ayarı dijitalken sözlü yol kapalı; açıkken banko onaycı yöneticiyi seçer + gerekçe, iskonto HEMEN satıra
/// kilitli yazılır (oran sınırı yok), talep "sözlü" damgasıyla yönetici adına onaylı kalır, yöneticinin zilinde
/// başvuruya bağlı hatırlatma açılır. Onaycı olmayan kişi adına sözlü onay yazılamaz.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class IskontoSozluOnayTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    [VtFact]
    public async Task Sozlu_onay_ayara_bagli_yoneticiyi_dogrular_iskontoyu_kilitli_yazar_ve_haber_verir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var eskiYontem = await api.Veri.TekDegerAsync<short>(
            "select iskonto_onay_yontemi from public.sube where id = @p0", [Merkez]);
        d.Temizle($"update public.sube set iskonto_onay_yontemi = {eskiYontem} where id = {Merkez}");

        var bankoRol = await d.RolAsync("banko", "belge:gde", "belge_satir:gde");
        var (banko, bankoKod) = await d.KullaniciAsync(bankoRol, Merkez);
        await d.SubeVerAsync(banko, Merkez, yazma: true, varsayilan: true);
        var yonRol = await d.RolAsync("yonetici", "belge.iskonto_onay_ust");
        var (yonetici, _) = await d.KullaniciAsync(yonRol, Merkez);
        await d.SubeVerAsync(yonetici, Merkez, yazma: true, varsayilan: true);
        var (baskasi, _) = await d.KullaniciAsync(bankoRol, Merkez);         // onaycı değil
        await d.SubeVerAsync(baskasi, Merkez, yazma: true, varsayilan: true);

        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " hasta", Merkez]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var belge = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, belge_tarihi, taraf_id, durum, sube_id)
            values (19, 30, now(), @p0, 0, @p1) returning id
            """, [hasta, Merkez]);
        d.Temizle($"delete from public.belge where id = {belge}");
        var satir = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, miktar, adet, birim_fiyat, tutar, kdv, sube_id)
            values (@p0, 1, 2, 1, 1, 1000, 1000, 0, @p1) returning id
            """, [belge, Merkez]);
        d.Temizle($"delete from public.belge_satir where id = {satir}");
        // Temizlik TERS sırada koşar: önce talep / hatırlatma, sonra satır ve belge.
        d.Temizle($"delete from public.iskonto_talep where belge_id = {belge}");
        d.Temizle($"delete from public.iskonto_talep_satir where talep_id in (select id from public.iskonto_talep where belge_id = {belge})");
        d.Temizle($"delete from public.hatirlatma where kaynak = 'basvuru' and kaynak_id = {belge}");

        var (access, _) = await api.GirisAsync(bankoKod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);
        object Govde(int onaylayan, string gerekce = "Müdür bey sözlü onay verdi") => new
        {
            belgeId = belge, gerekce, onaylayanId = onaylayan,
            kalemler = new[] { new { satirId = satir, oran = 40m } },
        };

        // 1) Şube DİJİTAL: sözlü yol kapalı, onaycı listesi boş.
        await api.Veri.CalistirAsync("update public.sube set iskonto_onay_yontemi = 1 where id = @p0", [Merkez]);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsJsonAsync("/api/iskonto-talep/sozlu", Govde(yonetici))).StatusCode);

        // 2) Şube SÖZLÜ: onaycı listesinde yönetici var, banko kendisi ve onaycı olmayan yok.
        await api.Veri.CalistirAsync("update public.sube set iskonto_onay_yontemi = 2 where id = @p0", [Merkez]);
        var bilgi = await h.GetFromJsonAsync<JsonElement>($"/api/iskonto-talep/sozlu-bilgi?belgeId={belge}");
        Assert.Equal(2, bilgi.GetProperty("yontem").GetInt32());
        var onaycilar = bilgi.GetProperty("onaycilar").EnumerateArray().Select(x => x.GetProperty("id").GetInt32()).ToList();
        Assert.Contains(yonetici, onaycilar);
        Assert.DoesNotContain(banko, onaycilar);
        Assert.DoesNotContain(baskasi, onaycilar);

        // 3) Onaycı olmayan kişi adına sözlü onay yok; gerekçesiz de yok.
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsJsonAsync("/api/iskonto-talep/sozlu", Govde(baskasi))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await h.PostAsJsonAsync("/api/iskonto-talep/sozlu", Govde(yonetici, " "))).StatusCode);
        Assert.Equal(0m, await api.Veri.TekDegerAsync<decimal>("select iskonto from public.belge_satir where id = @p0", [satir]));

        // 4) Geçerli sözlü onay: %40 (eşik ve banko tavanı üstü) hemen, kilitli yazılır.
        var y = await h.PostAsJsonAsync("/api/iskonto-talep/sozlu", Govde(yonetici));
        Assert.True(y.IsSuccessStatusCode, await y.Content.ReadAsStringAsync());
        Assert.Equal("40.0000/1", await api.Veri.TekDegerAsync<string>(
            "select iskonto::text || '/' || iskonto_kilit from public.belge_satir where id = @p0", [satir]));
        Assert.Equal($"1/2/{yonetici}/{banko}", await api.Veri.TekDegerAsync<string>("""
            select durum || '/' || onay_yontemi || '/' || onay_id || '/' || isteyen_id
              from public.iskonto_talep where belge_id = @p0
            """, [belge]));
        // Yöneticinin zili: başvuruya bağlı hatırlatma.
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("""
            select count(*)::int from public.hatirlatma
             where sahip_id = @p0 and kaynak = 'basvuru' and kaynak_id = @p1 and baslik like '%Sözlü onayınızla%'
            """, [yonetici, belge]));
        // TUTAR DA YENİLENİR (karar yalnız oranı yazıyordu): 1000 x %40 iskonto = 600, dip toplam da.
        Assert.Equal(600m, await api.Veri.TekDegerAsync<decimal>("select tutar from public.belge_satir where id = @p0", [satir]));
        Assert.Equal(600m, await api.Veri.TekDegerAsync<decimal>("select genel_toplam from public.belge where id = @p0", [belge]));

        // 5) GERİ AL (1377): onaycı olmayan başka görevli alamaz; uygulayan banko alır - oran, kilit, tutar döner.
        var talep = await api.Veri.TekDegerAsync<int>("select id from public.iskonto_talep where belge_id = @p0", [belge]);
        var (bAccess, _) = await api.GirisAsync(await api.Veri.TekDegerAsync<string>(
            "select kod from public.taraf_kullanici where id = @p0", [baskasi]) ?? "", TestDunyasi.Parola);
        using (var hb = api.Istemci(bAccess, Merkez))
            Assert.Equal(HttpStatusCode.Forbidden,
                (await hb.PostAsJsonAsync($"/api/iskonto-talep/{talep}/geri-al", new { neden = "yanlış" })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await h.PostAsJsonAsync($"/api/iskonto-talep/{talep}/geri-al", new { neden = "" })).StatusCode);
        var g = await h.PostAsJsonAsync($"/api/iskonto-talep/{talep}/geri-al", new { neden = "Yanlış hastaya uygulandı" });
        Assert.True(g.IsSuccessStatusCode, await g.Content.ReadAsStringAsync());
        Assert.Equal("0.0000/0/1000.00", await api.Veri.TekDegerAsync<string>(
            "select iskonto::text || '/' || iskonto_kilit || '/' || round(tutar, 2)::text from public.belge_satir where id = @p0", [satir]));
        Assert.Equal(1000m, await api.Veri.TekDegerAsync<decimal>("select genel_toplam from public.belge where id = @p0", [belge]));
        Assert.Equal(3, await api.Veri.TekDegerAsync<int>("select durum::int from public.iskonto_talep where id = @p0", [talep]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("""
            select count(*)::int from public.hatirlatma
             where sahip_id = @p0 and kaynak_id = @p1 and baslik like '%geri alındı%'
            """, [yonetici, belge]));
        // İkinci kez geri alınamaz (artık onaylı değil).
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await h.PostAsJsonAsync($"/api/iskonto-talep/{talep}/geri-al", new { neden = "tekrar" })).StatusCode);
    }

    /// <summary>DİJİTAL onaylı iskontoyu banko geri alamaz, onaycı alır (1377, kullanıcı kararı).</summary>
    [VtFact]
    public async Task Dijital_onay_yalniz_onayci_geri_alir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var bankoRol = await d.RolAsync("banko", "belge:gde", "belge_satir:gde");
        var (banko, bankoKod) = await d.KullaniciAsync(bankoRol, Merkez);
        await d.SubeVerAsync(banko, Merkez, yazma: true, varsayilan: true);
        var yonRol = await d.RolAsync("yonetici", "belge:gde", "belge.iskonto_onay_ust");
        var (yonetici, yonKod) = await d.KullaniciAsync(yonRol, Merkez);
        await d.SubeVerAsync(yonetici, Merkez, yazma: true, varsayilan: true);

        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " hasta", Merkez]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var belge = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, belge_tarihi, taraf_id, durum, sube_id)
            values (19, 30, now(), @p0, 0, @p1) returning id
            """, [hasta, Merkez]);
        d.Temizle($"delete from public.belge where id = {belge}");
        var satir = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, miktar, adet, birim_fiyat, tutar, kdv, sube_id)
            values (@p0, 1, 2, 1, 1, 500, 500, 0, @p1) returning id
            """, [belge, Merkez]);
        d.Temizle($"delete from public.belge_satir where id = {satir}");
        d.Temizle($"delete from public.iskonto_talep where belge_id = {belge}");
        d.Temizle($"delete from public.iskonto_talep_satir where talep_id in (select id from public.iskonto_talep where belge_id = {belge})");

        // Dijital onaylı talep (zincirin sonucu): talep + karar fonksiyonu.
        var talep = await api.Veri.TekDegerAsync<int>("""
            insert into public.iskonto_talep (belge_id, sube_id, oran, gerekce, durum, isteyen_id, ekleyen)
            values (@p0, @p1, 30, 'test', 0, @p2, @p2) returning id
            """, [belge, Merkez, banko]);
        await api.Veri.CalistirAsync("""
            insert into public.iskonto_talep_satir (talep_id, belge_satir_id, birim_fiyat, onceki_iskonto, oran)
            values (@p0, @p1, 500, 0, 30)
            """, [talep, satir]);
        await api.Veri.CalistirAsync("select public.fn_iskonto_talep_karar(@p0, 1::smallint, 30, 'ok', @p1)", [talep, yonetici]);

        var (ba, _) = await api.GirisAsync(bankoKod, TestDunyasi.Parola);
        using (var hb = api.Istemci(ba, Merkez))
            Assert.Equal(HttpStatusCode.Forbidden,
                (await hb.PostAsJsonAsync($"/api/iskonto-talep/{talep}/geri-al", new { neden = "x" })).StatusCode);
        var (ya, _) = await api.GirisAsync(yonKod, TestDunyasi.Parola);
        using var hy = api.Istemci(ya, Merkez);
        // Ekran SATIRDAN geri alır: satırı kilitleyen son onaylı talep bulunur.
        var g = await hy.PostAsJsonAsync($"/api/iskonto-talep/satir/{satir}/geri-al", new { neden = "Kurum değişti" });
        Assert.True(g.IsSuccessStatusCode, await g.Content.ReadAsStringAsync());
        Assert.Equal("0.0000/0/500.00", await api.Veri.TekDegerAsync<string>(
            "select iskonto::text || '/' || iskonto_kilit || '/' || round(tutar, 2)::text from public.belge_satir where id = @p0", [satir]));
    }
}
