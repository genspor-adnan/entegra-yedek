using System.Net;
using System.Net.Http.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 28.10.2026 — B02: radyoloji özel uçları kayıt kapsamını atlıyordu. A şubesinde çalışan,
/// B şubesine izni olmayan kullanıcı B'nin istemini kimliğiyle okuyamamalı / yazamamalı / onaylayamamalı;
/// cevap var olmayan kayıtla AYNI 404 olmalı ve yan etki bırakmamalı.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class RadyolojiErisimTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int Ankara = 3;

    private async Task<(int Istem, int Rapor)> IstemAsync(TestDunyasi d, int hasta, int sube)
    {
        var hizmet = await api.Veri.TekDegerAsync<int>("select min(id) from public.hizmet where coalesce(modalite, 0) > 0 and coalesce(cinsiyet, 0) = 0");
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (hasta_id, hizmet_id, accession_no, sube_id, durum, serbest)
            values (@p0, @p1, @p2, @p3, 3, 1) returning id
            """, [hasta, hizmet, d.Onek + "-" + Guid.NewGuid().ToString("N")[..6], sube]);
        var rapor = await api.Veri.TekDegerAsync<int>(
            "insert into public.radyoloji_rapor (istem_id, durum) values (@p0, 1) returning id", [istem]);
        await api.Veri.CalistirAsync(
            "insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir) values (@p0, 1, 'Bulgular', 'özgün', 1)",
            [rapor]);
        d.Temizle($"delete from public.radyoloji_rapor where istem_id = {istem}");
        d.Temizle($"delete from public.radyoloji_istem where id = {istem}");
        return (istem, rapor);
    }

    private async Task<int> HastaAsync(TestDunyasi d, int sube = Merkez)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], sube]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    [VtFact]
    public async Task Baska_subenin_radyoloji_istemi_okunamaz_yazilamaz_onaylanamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var a = await IstemAsync(d, hasta, Merkez);
        var b = await IstemAsync(d, hasta, Ankara);

        var rol = await d.RolAsync("radyoloji", "radyoloji:gde", "radyoloji-istem:gde", "rad.rapor_yaz", "rad.rapor_onayla");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        // Kendi şubesi açılır.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync($"/api/radyoloji/istem/{a.Istem}/rapor")).StatusCode);

        // Başka şube: var olmayan kayıtla aynı 404.
        foreach (var yol in new[]
        {
            $"/api/radyoloji/istem/{b.Istem}/rapor", $"/api/radyoloji/istem/{b.Istem}/kart-detay",
            $"/api/radyoloji/istem/{b.Istem}/akis", $"/api/radyoloji/rapor/{b.Rapor}/cikti",
            "/api/radyoloji/istem/2147483000/rapor",
        })
            Assert.True((await h.GetAsync(yol)).StatusCode == HttpStatusCode.NotFound, yol);

        var yaz = await h.PostAsJsonAsync($"/api/radyoloji/istem/{b.Istem}/rapor",
            new { bolumler = new[] { new { sira = 1, baslik = "Bulgular", metin = "ezildi", yazdir = 1 } } });
        Assert.Equal(HttpStatusCode.NotFound, yaz.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsync($"/api/radyoloji/rapor/{b.Rapor}/durum?hedef=onay", null)).StatusCode);

        // Yan etki yok: B'nin metni ve durumu değişmedi.
        Assert.Equal("özgün", await api.Veri.TekDegerAsync<string>(
            "select metin from public.radyoloji_rapor_bolum where rapor_id = @p0", [b.Rapor]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select durum::int from public.radyoloji_rapor where id = @p0", [b.Rapor]));
    }
    private async Task<HttpClient> MerkezIstemcisiAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("radyoloji", "radyoloji:gde", "radyoloji-istem:gde", "hasta:g", "rad.istem_ac", "rad.rapor_yaz");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    /// <summary>
    /// PORTAL HASTASI (portal_turu 3): hasta kaynağının kapsamı yalnız kendisi. Kurum içi kullanıcı için hasta
    /// şubeler arası ortaktır - "kapsam dışı hasta" portal kullanıcısında oluşur.
    /// </summary>
    private async Task<(HttpClient H, int Kendi)> PortalIstemcisiAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("portal", "radyoloji:gde", "radyoloji-istem:gde", "hasta:g", "rad.istem_ac");
        await api.Veri.CalistirAsync("update public.rol set portal_turu = 3 where id = @p0", [rol]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, hasta: true);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return (api.Istemci(access, Merkez), u);
    }

    [VtFact]
    public async Task Istem_secenekleri_kapsam_disi_hastanin_gecmisini_vermez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var ortak = await HastaAsync(d);
        var a = await IstemAsync(d, ortak, Merkez);
        var b = await IstemAsync(d, ortak, Ankara);
        using var h = await MerkezIstemcisiAsync(d);

        // Kapsamdaki hasta: geçmişte yalnız kendi şubesinin istemi (Ankara istemi sayılmaz).
        var y = await h.GetAsync($"/api/radyoloji/istem-secenekleri?hastaId={ortak}");
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        var gecmis = (await y.Content.ReadFromJsonAsync<System.Text.Json.JsonElement>()).GetProperty("gecmis");
        Assert.Equal(1, gecmis.GetArrayLength());

        _ = (a, b);

        // Portal hastası: kendi geçmişi açılır; başka hasta (istemi olsa da) ve olmayan hasta aynı 404.
        var (p, kendi) = await PortalIstemcisiAsync(d);
        using var _p = p;
        await IstemAsync(d, kendi, Merkez);
        Assert.Equal(HttpStatusCode.OK, (await p.GetAsync($"/api/radyoloji/istem-secenekleri?hastaId={kendi}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await p.GetAsync($"/api/radyoloji/istem-secenekleri?hastaId={ortak}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await p.GetAsync("/api/radyoloji/istem-secenekleri?hastaId=2147483000")).StatusCode);
    }

    [VtFact]
    public async Task Kapsam_disi_hastaya_ve_baskasinin_basvurusuna_istem_acilamaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var benim = await HastaAsync(d);
        var disari = await HastaAsync(d);
        var hizmet = await api.Veri.TekDegerAsync<int>(
            "select min(id) from public.hizmet where coalesce(modalite, 0) > 0 and coalesce(cinsiyet, 0) = 0");
        // Ankara şubesinde benim hastama açılmış başvuru (başkasının başvurusu).
        var belge = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi) values (19, 30, @p0, @p1, now()) returning id",
            [benim, Ankara]);
        d.Temizle($"delete from public.belge where id = {belge}");
        d.Temizle($"delete from public.radyoloji_istem where hasta_id in ({benim}, {disari})");
        using var h = await MerkezIstemcisiAsync(d);
        var (p, _) = await PortalIstemcisiAsync(d);
        using var _p = p;

        object Istek(int hasta, int? belgeId) => new
        {
            hastaId = hasta, belgeId, klinikBilgi = "test", basvuruAc = false,
            tetkikler = new[] { new { hizmetId = hizmet } },
        };
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PostAsJsonAsync("/api/radyoloji/istem", Istek(benim, belge))).StatusCode);
        // Portal hastası başka hastaya istem açamaz.
        Assert.Equal(HttpStatusCode.NotFound,
            (await p.PostAsJsonAsync("/api/radyoloji/istem", Istek(disari, null))).StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.radyoloji_istem where hasta_id in (@p0, @p1)", [benim, disari]));
    }

    /// <summary>
    /// TESLİM DÜZELTME (kullanıcı 18.11.2026): yanlış yazılan teslim alan / kalem düzeltilir, zaman değişmez, değişiklik
    /// istem loguna düşer; başka istemin teslim kimliğiyle düzeltme 404, okuma ucu kalemleri döndürür.
    /// </summary>
    [VtFact]
    public async Task Teslim_bilgisi_duzeltilir_zaman_degismez_loglanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var a = await IstemAsync(d, hasta, Merkez);
        var b = await IstemAsync(d, hasta, Merkez);
        var teslim = await api.Veri.TekDegerAsync<int>("""
            insert into public.radyoloji_teslim (istem_id, tur, teslim_zamani, alan_ad, rapor_verildi)
            values (@p0, 2, '2026-11-18 10:00+00', 'Yanlis Ad', 1) returning id
            """, [a.Istem]);
        d.Temizle($"delete from public.islem_log where tablo_id = 940 and kayit_id in ({a.Istem}, {b.Istem})");
        var rol = await d.RolAsync("teslim", "radyoloji:gde", "radyoloji-istem:gde", "rad.teslim");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);
        var govde = new { tur = 2, alanAd = "Doğru Ad", alanYakinlik = "Eşi", kimlikDogrulandi = 1, aciklama = "",
                          raporVerildi = 1, filmVerildi = 0, cdVerildi = 1, dijitalVerildi = 0 };

        var y = await h.PutAsJsonAsync($"/api/radyoloji/istem/{a.Istem}/teslim/{teslim}", govde);
        Assert.True(y.IsSuccessStatusCode, await y.Content.ReadAsStringAsync());
        Assert.Equal("Doğru Ad/Eşi/1/1/2026-11-18 10:00", await api.Veri.TekDegerAsync<string>("""
            select alan_ad || '/' || alan_yakinlik || '/' || rapor_verildi || '/' || cd_verildi || '/'
                   || to_char(teslim_zamani at time zone 'UTC', 'YYYY-MM-DD HH24:MI')
              from public.radyoloji_teslim where id = @p0
            """, [teslim]));
        Assert.Equal(1L, await api.Veri.TekDegerAsync<long>(
            "select count(*) from public.islem_log where tablo_id = 940 and kayit_id = @p0 and islem_tipi = 2", [a.Istem]));
        // Başka istemin yolundan bu teslim düzeltilemez.
        Assert.Equal(HttpStatusCode.NotFound,
            (await h.PutAsJsonAsync($"/api/radyoloji/istem/{b.Istem}/teslim/{teslim}", govde)).StatusCode);
        // Okuma ucu kalemleri döndürür (modal onlarla dolar).
        var l = await h.GetFromJsonAsync<List<Dictionary<string, System.Text.Json.JsonElement>>>($"/api/radyoloji/istem/{a.Istem}/teslimler");
        Assert.Equal(1, l![0]["cdVerildi"].GetInt32());
    }

    /// <summary>TESLİMDE BORÇ UYARISI (kullanıcı 18.11.2026): hastanın kesin başvurularındaki tahsil edilmemiş hasta payı.</summary>
    [VtFact]
    public async Task Teslim_durumu_hastanin_acik_borcunu_verir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var a = await IstemAsync(d, hasta, Merkez);
        var rol = await d.RolAsync("teslimb", "radyoloji:gde", "radyoloji-istem:gde", "rad.teslim");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);
        async Task<decimal> Borc() => (await h.GetFromJsonAsync<Dictionary<string, System.Text.Json.JsonElement>>(
            $"/api/radyoloji/istem/{a.Istem}/teslim-durum"))!["acikBorc"].GetDecimal();

        Assert.Equal(0m, await Borc());

        var belge = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge (tur, taraf_id, sube_id, belge_tarihi, durum) values (19, @p0, @p1, now(), 0) returning id",
            [hasta, Merkez]);
        d.Temizle($"delete from public.belge where id = {belge}");
        var satir = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge_satir (belge_id, sira, tur, aciklama, miktar, adet, birim_fiyat, tutar, kdv, sube_id) values (@p0, 1, 0, 'Ücret', 1, 1, 250, 250, 0, @p1) returning id",
            [belge, Merkez]);
        await api.Veri.CalistirAsync("""
            insert into public.belge_satir_dagilim (belge_satir_id, hasta_provizyon, sgk, oss, hasta_ek_katki)
            values (@p0, 250, 0, 0, 0)
            on conflict (belge_satir_id) do update set hasta_provizyon = 250, sgk = 0, oss = 0, hasta_ek_katki = 0
            """, [satir]);
        Assert.Equal(250m, await Borc());

        // Taslak başvuru borç sayılmaz.
        await api.Veri.CalistirAsync("update public.belge set durum = 1 where id = @p0", [belge]);
        Assert.Equal(0m, await Borc());
    }

    /// <summary>
    /// REVİZE (1374, kullanıcı 18.11.2026): teslim edilmiş onaylı raporun onayı geri alınamaz (422 + revize önerisi);
    /// revizede eski hâl arşiv kopyası olur (no, metin, teslim bağı), rapor taslağa döner ve -R1 numarasını alır;
    /// yeniden onaylanınca teslim listesinde tekrar "Hazır" (yeniden teslim bekler); ikinci revize -R2.
    /// </summary>
    [VtFact]
    public async Task Disari_cikmis_rapor_onay_iptal_edilemez_revize_edilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var a = await IstemAsync(d, hasta, Merkez);
        var rol = await d.RolAsync("revize", "radyoloji:gde", "radyoloji-istem:gde", "rad.rapor_yaz");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var no = "RT-" + Guid.NewGuid().ToString("N")[..8];
        await api.Veri.CalistirAsync("""
            update public.radyoloji_rapor set durum = 3, kilit = 1, onaylayan_id = @p1, onay_tarihi = now(), rapor_no = @p2
             where id = @p0
            """, [a.Rapor, u, no]);
        await api.Veri.CalistirAsync("update public.radyoloji_istem set durum = 5 where id = @p0", [a.Istem]);
        await api.Veri.CalistirAsync(
            "insert into public.radyoloji_teslim (istem_id, rapor_id, tur, alan_ad, rapor_verildi) values (@p0, @p1, 2, 'Hasta', 1)",
            [a.Istem, a.Rapor]);
        d.Temizle($"delete from public.islem_log where tablo_id = 941 and kayit_id = {a.Rapor}");
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);
        Task<string> Surum() => api.Veri.TekDegerAsync<string>("select xmin::text from public.radyoloji_rapor where id = @p0", [a.Rapor])!;

        // 1) Onay iptali: reddedilir, revize önerilir.
        var ip = await h.PostAsJsonAsync($"/api/radyoloji/rapor/{a.Rapor}/onay-iptal?surum={await Surum()}", new { });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ip.StatusCode);
        var ipG = await ip.Content.ReadAsStringAsync();
        Assert.Contains("revize", ipG);
        // Ekran engeli önceden bilir.
        var ekran = await h.GetFromJsonAsync<Dictionary<string, System.Text.Json.JsonElement>>($"/api/radyoloji/istem/{a.Istem}/rapor");
        Assert.Equal("Rapor teslim edildi", ekran!["iptalEngeli"].GetString());

        // 2) Nedensiz revize yok.
        Assert.Equal(HttpStatusCode.BadRequest,
            (await h.PostAsJsonAsync($"/api/radyoloji/rapor/{a.Rapor}/revize?surum={await Surum()}", new { neden = "" })).StatusCode);

        // 3) Revize.
        var rv = await h.PostAsJsonAsync($"/api/radyoloji/rapor/{a.Rapor}/revize?surum={await Surum()}", new { neden = "Taraf yanlış" });
        var rvG = await rv.Content.ReadAsStringAsync();
        Assert.True(rv.IsSuccessStatusCode, rvG);
        Assert.Equal($"1/0/{no}-R1/1", await api.Veri.TekDegerAsync<string>(
            "select durum || '/' || kilit || '/' || rapor_no || '/' || revize_no from public.radyoloji_rapor where id = @p0", [a.Rapor]));
        var arsiv = await api.Veri.TekDegerAsync<int>(
            "select id from public.radyoloji_rapor where ust_rapor_id = @p0 and revize = 1", [a.Rapor]);
        Assert.Equal($"3/1/{no}/Taraf yanlış/özgün", await api.Veri.TekDegerAsync<string>("""
            select r.durum || '/' || r.kilit || '/' || r.rapor_no || '/' || r.revize_nedeni || '/'
                   || (select b.metin from public.radyoloji_rapor_bolum b where b.rapor_id = r.id)
              from public.radyoloji_rapor r where r.id = @p0
            """, [arsiv]));
        Assert.Equal(arsiv, await api.Veri.TekDegerAsync<int>(
            "select rapor_id from public.radyoloji_teslim where istem_id = @p0", [a.Istem]));          // teslim izi arşivde
        Assert.Equal(3, await api.Veri.TekDegerAsync<int>("select durum::int from public.radyoloji_istem where id = @p0", [a.Istem]));
        var ekran2 = await h.GetFromJsonAsync<Dictionary<string, System.Text.Json.JsonElement>>($"/api/radyoloji/istem/{a.Istem}/rapor");
        Assert.Equal(1, ekran2!["revizeler"].GetArrayLength());

        // 4) Yeniden onay: teslim listesinde yeniden "Hazır" (eski teslim düzeltilmiş rapor için sayılmaz).
        await api.Veri.CalistirAsync("update public.radyoloji_rapor set durum = 3, kilit = 1, onaylayan_id = @p1, onay_tarihi = now() where id = @p0", [a.Rapor, u]);
        await api.Veri.CalistirAsync("update public.radyoloji_istem set durum = 5 where id = @p0", [a.Istem]);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select takip_durum from public.v_radyoloji_teslim_takip where istem_id = @p0", [a.Istem]));
        Assert.Equal(a.Rapor, await api.Veri.TekDegerAsync<int>(
            "select (select x.id from public.radyoloji_rapor x where x.istem_id = @p0 and coalesce(x.revize, 0) = 0 order by x.id desc limit 1)", [a.Istem]));

        // 5) İkinci revize: yeniden onaylı ve henüz dışarı çıkmamış raporda engel yok - doğrudan revize ucu -R2 verir.
        var rv2 = await h.PostAsJsonAsync($"/api/radyoloji/rapor/{a.Rapor}/revize?surum={await Surum()}", new { neden = "İkinci düzeltme" });
        Assert.True(rv2.IsSuccessStatusCode, await rv2.Content.ReadAsStringAsync());
        Assert.Equal($"{no}-R2", await api.Veri.TekDegerAsync<string>("select rapor_no from public.radyoloji_rapor where id = @p0", [a.Rapor]));
        Assert.Equal($"{no}-R1", await api.Veri.TekDegerAsync<string>(
            "select rapor_no from public.radyoloji_rapor where ust_rapor_id = @p0 and revize_no = 2", [a.Rapor]));
    }
}
