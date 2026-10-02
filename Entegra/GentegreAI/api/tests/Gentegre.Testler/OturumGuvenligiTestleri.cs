using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace Gentegre.Testler;

/// <summary>
/// DENETİM 28.09.2026 — FAZ B: KİMLİK VE OTURUM (bulgu 4, 5, 6).
///
/// <para>Gerçek API sürecine HTTP. Anonim parola uçlarında her test kendi
/// <c>X-Forwarded-For</c> adresini kullanır (loopback güvenilen proxy): IP
/// sınırı testleri birbirinin sayacını etkilemez.</para>
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed partial class OturumGuvenligiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private static string YeniIp() =>
        $"198.18.{Random.Shared.Next(0, 255)}.{Random.Shared.Next(1, 254)}";

    [GeneratedRegex(@"kodunuz:?\s*(\d{6})")]
    private static partial Regex KodDeseni();

    /// <summary>Kuyruğa düşen (gönderilmeyen - işçi kapalı) son kod.</summary>
    private async Task<string> SonKodAsync(int kullanici)
    {
        var govde = await api.Veri.TekDegerAsync<string>(
            "select govde from public.bildirim where kaynak_tur = 43 and kaynak_id = @p0 order by id desc limit 1",
            [kullanici]) ?? "";
        var m = KodDeseni().Match(govde);
        Assert.True(m.Success, "kuyrukta kod yok: " + govde);
        return m.Groups[1].Value;
    }

    // ------------------------------------------------------------ bulgu 4 ----

    [VtFact]
    public async Task Parola_degismeli_hesap_is_uclarina_arayuzu_atlayarak_da_erisemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("pd", "lab:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, parolaDegismeli: true);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);

        var (access, refresh) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access);

        var y = await h.PostAsJsonAsync("/api/liste/lab-istem", new { });
        Assert.Equal(HttpStatusCode.Forbidden, y.StatusCode);
        Assert.Equal("PAROLA_DEGISMELI", await ApiSunucuOlgusu.HataKoduAsync(y));

        // Parola ekraninin ihtiyaci olan profil ucu acik.
        Assert.Equal(HttpStatusCode.OK, (await h.GetAsync("/api/kimlik/ben")).StatusCode);

        // Yenileme ve sube degistirme kapiyi ASMAZ.
        using var anonim = api.Istemci();
        var yenile = await anonim.PostAsJsonAsync("/api/kimlik/yenile", new { refreshToken = refresh });
        Assert.Equal(HttpStatusCode.OK, yenile.StatusCode);
        var j = await yenile.Content.ReadFromJsonAsync<JsonElement>();
        using (var h2 = api.Istemci(j.GetProperty("accessToken").GetString()))
        {
            Assert.Equal(HttpStatusCode.Forbidden, (await h2.PostAsJsonAsync("/api/liste/lab-istem", new { })).StatusCode);
            Assert.Equal(HttpStatusCode.Forbidden, (await h2.PostAsJsonAsync("/api/kimlik/sube", new { subeId = Merkez })).StatusCode);

            // Parola degisince yeni token cifti gelir ve oturum akisi calisir.
            var p = await h2.PostAsJsonAsync("/api/kimlik/parola",
                new { eskiParola = TestDunyasi.Parola, yeniParola = "Yeni.Parola.2026!" });
            Assert.Equal(HttpStatusCode.OK, p.StatusCode);
            var yeni = await p.Content.ReadFromJsonAsync<JsonElement>();
            using var h3 = api.Istemci(yeni.GetProperty("accessToken").GetString());
            Assert.Equal(HttpStatusCode.OK, (await h3.PostAsJsonAsync("/api/liste/lab-istem", new { })).StatusCode);

            // Eski refresh (diger oturumlar) kapandi.
            Assert.Equal(HttpStatusCode.Unauthorized,
                (await anonim.PostAsJsonAsync("/api/kimlik/yenile",
                    new { refreshToken = j.GetProperty("refreshToken").GetString() })).StatusCode);

            // Bayrak SONRADAN acilirsa mevcut token da kapanir.
            await api.Veri.CalistirAsync("update public.taraf_kullanici set parola_degismeli = 1 where id = @p0", [u]);
            Assert.Equal(HttpStatusCode.Forbidden, (await h3.PostAsJsonAsync("/api/liste/lab-istem", new { })).StatusCode);

            // Pasif hesap gecerli token'la giremez.
            await api.Veri.CalistirAsync("update public.taraf_kullanici set parola_degismeli = 0, aktif = 0 where id = @p0", [u]);
            Assert.Equal(HttpStatusCode.Unauthorized, (await h3.PostAsJsonAsync("/api/liste/lab-istem", new { })).StatusCode);
        }
    }

    // ------------------------------------------------------------ bulgu 5 ----

    [VtFact]
    public async Task Ilk_parola_tckn_son4_ile_tek_basina_belirlenemez_kod_tek_kullanimlik()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("ilk", "lab:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, parolaHash: "", vkno: "10000000146",
                                              cepTel: "05550001122");
        using var h = api.Istemci(ip: YeniIp());

        // ESKI SALDIRI: yalniz TCKN son 4 ile parola belirlemek artik mumkun degil.
        var eski = await h.PostAsJsonAsync("/api/kimlik/ilk-parola",
            new { kod, tcknSon4 = "0146", yeniParola = "Saldirgan.2026!" });
        Assert.Equal(HttpStatusCode.Unauthorized, eski.StatusCode);
        Assert.Equal("", await api.Veri.TekDegerAsync<string>(
            "select parola_hash from public.taraf_kullanici where id = @p0", [u]));

        // Yanlis TCKN: cevap AYNI (bilgi sizmaz), kod uretilmez, sayac isler.
        var yanlis = await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod, tcknSon4 = "9999" });
        var dogruCevap = await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod = "yok-" + kod, tcknSon4 = "0146" });
        Assert.Equal(HttpStatusCode.OK, yanlis.StatusCode);
        Assert.Equal(await yanlis.Content.ReadAsStringAsync().ContinueWith(t => Govde(t.Result)),
                     await dogruCevap.Content.ReadAsStringAsync().ContinueWith(t => Govde(t.Result)));
        Assert.Equal(0L, await api.Veri.TekDegerAsync<long>(
            "select count(*) from public.parola_sifirlama where kullanici_id = @p0", [u]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select hatali_giris from public.taraf_kullanici where id = @p0", [u]));

        // Dogru TCKN: kod kayitli kanala (kuyruk) gider.
        Assert.Equal(HttpStatusCode.OK,
            (await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod, tcknSon4 = "0146" })).StatusCode);
        var kodDegeri = await SonKodAsync(u);

        // Yanlis kod reddedilir; dogru kod parolayi belirler; AYNI kod ikinci kez calismaz.
        Assert.Equal(HttpStatusCode.Unauthorized, (await h.PostAsJsonAsync("/api/kimlik/ilk-parola",
            new { kod, dogrulamaKodu = kodDegeri == "123456" ? "654321" : "123456", yeniParola = "Dogru.Parola.2026!" })).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await h.PostAsJsonAsync("/api/kimlik/ilk-parola",
            new { kod, dogrulamaKodu = kodDegeri, yeniParola = "Dogru.Parola.2026!" })).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await h.PostAsJsonAsync("/api/kimlik/ilk-parola",
            new { kod, dogrulamaKodu = kodDegeri, yeniParola = "Baska.Parola.2026!" })).StatusCode);

        // Parola belirlenen hesapla giris; ikinci deneme parolayi degistirmedi.
        await api.GirisAsync(kod, "Dogru.Parola.2026!");
    }

    private static string Govde(string s) => s;

    [VtFact]
    public async Task Ilk_parola_suresi_gecmis_kod_ve_es_zamanli_kullanim_tek_basari()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("ilk2", "lab:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez, parolaHash: "", vkno: "10000000146",
                                              cepTel: "05550001123");
        using var h = api.Istemci(ip: YeniIp());

        await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod, tcknSon4 = "0146" });
        var k1 = await SonKodAsync(u);
        // Suresi gecmis kod.
        await api.Veri.CalistirAsync("update public.parola_sifirlama set bitis = now() - interval '1 minute' where kullanici_id = @p0", [u]);
        Assert.Equal(HttpStatusCode.Unauthorized, (await h.PostAsJsonAsync("/api/kimlik/ilk-parola",
            new { kod, dogrulamaKodu = k1, yeniParola = "Dogru.Parola.2026!" })).StatusCode);

        await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod, tcknSon4 = "0146" });
        var k2 = await SonKodAsync(u);

        // AYNI kodla 6 es zamanli istek: en fazla BIR basari.
        using var bariyer = new Barrier(6);
        var istekler = Enumerable.Range(0, 6).Select(i => Task.Run(async () =>
        {
            using var hi = api.Istemci(ip: YeniIp());
            bariyer.SignalAndWait();
            return (await hi.PostAsJsonAsync("/api/kimlik/ilk-parola",
                new { kod, dogrulamaKodu = k2, yeniParola = $"Paralel.{i}.Parola!" })).StatusCode;
        })).ToArray();
        var sonuc = await Task.WhenAll(istekler);
        Assert.Equal(1, sonuc.Count(s => s == HttpStatusCode.OK));
        Assert.Equal(1L, await api.Veri.TekDegerAsync<long>(
            "select count(*) from public.parola_sifirlama where kullanici_id = @p0 and kullanildi is not null", [u]));
    }

    [VtFact]
    public async Task Ilk_parola_ip_esigi_asilinca_reddedilir_ve_parolali_hesaba_calismaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("ilk3", "lab:g");
        var (_, parolali) = await d.KullaniciAsync(rol, Merkez, vkno: "10000000146", cepTel: "05550001124");
        var ip = YeniIp();
        using var h = api.Istemci(ip: ip);

        // Parolasi olan hesaba ilk parola akisi kod GONDERMEZ ve parola yazamaz.
        await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod = parolali, tcknSon4 = "0146" });
        Assert.Equal(HttpStatusCode.Unauthorized, (await h.PostAsJsonAsync("/api/kimlik/ilk-parola",
            new { kod = parolali, dogrulamaKodu = "123456", yeniParola = "Saldirgan.2026!" })).StatusCode);
        await api.GirisAsync(parolali, TestDunyasi.Parola);

        // IP esigi: bu istemciden 20 basarisiz deneme sonrasi istek islenmez.
        for (var i = 0; i < 20; i++)
            await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod = "yok" + i, tcknSon4 = "0000" });
        var y = await h.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod = parolali, tcknSon4 = "0146" });
        Assert.Equal((HttpStatusCode)422, y.StatusCode);
        d.Temizle($"delete from public.giris_denemesi where ip = '{ip}'");

        // Baska istemci etkilenmez.
        using var h2 = api.Istemci(ip: YeniIp());
        Assert.Equal(HttpStatusCode.OK,
            (await h2.PostAsJsonAsync("/api/kimlik/ilk-parola/kod", new { kod = parolali, tcknSon4 = "0146" })).StatusCode);
    }

    // ------------------------------------------------------------ bulgu 6 ----

    private async Task<(string Kod, int Id)> OturumKullanicisiAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("ref" + Guid.NewGuid().ToString("N")[..4], "lab:g");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        return (kod, u);
    }

    private async Task<HttpResponseMessage> YenileAsync(string refresh, string? ip = null)
    {
        using var h = api.Istemci(ip: ip);
        return await h.PostAsJsonAsync("/api/kimlik/yenile", new { refreshToken = refresh });
    }

    [VtFact]
    public async Task Es_zamanli_yenilemede_en_fazla_bir_gecerli_dal_olusur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (kod, u) = await OturumKullanicisiAsync(d);
        const int Paralel = 16;

        // Birkac tur: yaris penceresi milisaniyeler; tek tur sansa kalir.
        for (var tur = 0; tur < 4; tur++)
        {
            var (_, refresh) = await api.GirisAsync(kod, TestDunyasi.Parola);
            var ilk = await api.Veri.TekDegerAsync<long>(
                "select max(id) from public.oturum where kullanici_id = @p0 and onceki_oturum_id is null", [u]);

            // Baglantilar ONCEDEN acilir; bariyer yalniz istegin kendisini hizalar.
            var istemciler = Enumerable.Range(0, Paralel).Select(_ => api.Istemci()).ToArray();
            await Task.WhenAll(istemciler.Select(h => h.GetAsync("/api/saglik")));
            using var bariyer = new Barrier(Paralel);
            var gorevler = istemciler.Select(h => Task.Factory.StartNew(() =>
            {
                bariyer.SignalAndWait();
                return h.PostAsJsonAsync("/api/kimlik/yenile", new { refreshToken = refresh })
                        .GetAwaiter().GetResult().StatusCode;
            }, TaskCreationOptions.LongRunning)).ToArray();
            var sonuc = await Task.WhenAll(gorevler);
            foreach (var h in istemciler) h.Dispose();

            Assert.True(sonuc.Count(s => s == HttpStatusCode.OK) <= 1, $"tur {tur}: " + string.Join(",", sonuc));
            // Ayni eski satirdan birden fazla yeni dal ACILMADI.
            Assert.True(await api.Veri.TekDegerAsync<long>(
                "select count(*) from public.oturum where onceki_oturum_id = @p0", [ilk]) <= 1, $"tur {tur}");
            // Tekrar kullanim tespit edildiyse aile KALICI olarak kapandi.
            if (sonuc.Any(s => s == HttpStatusCode.Unauthorized))
                Assert.Equal(0L, await api.Veri.TekDegerAsync<long>("""
                    select count(*) from public.oturum
                     where aile_id = (select aile_id from public.oturum where id = @p0)
                       and iptal_tarihi is null
                    """, [ilk]));
        }
    }

    [VtFact]
    public async Task Iptal_edilmis_token_tekrar_kullanilinca_aile_kalici_iptal_edilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (kod, u) = await OturumKullanicisiAsync(d);
        var (_, r1) = await api.GirisAsync(kod, TestDunyasi.Parola);

        var y = await YenileAsync(r1);
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        var r2 = (await y.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("refreshToken").GetString()!;

        Assert.Equal(HttpStatusCode.Unauthorized, (await YenileAsync(r1)).StatusCode);   // tekrar kullanim
        Assert.Equal(HttpStatusCode.Unauthorized, (await YenileAsync(r2)).StatusCode);   // aile kapandi
        Assert.Equal("tekrar_kullanim", await api.Veri.TekDegerAsync<string>(
            "select iptal_nedeni from public.oturum where kullanici_id = @p0 order by id desc limit 1", [u]));
    }

    [VtFact]
    public async Task Yeni_kayit_yazilamazsa_eski_token_tukenmez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (kod, u) = await OturumKullanicisiAsync(d);
        var (_, r1) = await api.GirisAsync(kod, TestDunyasi.Parola);

        // YENI oturum satiri yazilirken DB hatasi: yalniz bu IP icin.
        var ip = YeniIp();
        var tetik = "tg_test_oturum_" + d.Onek;
        await api.Veri.CalistirAsync($"""
            create or replace function public.{tetik}() returns trigger language plpgsql as $$
            begin
              if new.ip = '{ip}' then raise exception 'test: oturum yazilamadi'; end if;
              return new;
            end $$;
            create trigger {tetik} before insert on public.oturum
              for each row execute function public.{tetik}();
            """, null);
        d.Temizle($"drop function if exists public.{tetik}() cascade");

        // Hata sozlesmeye gore cevrilir (PG raise -> 422); onemli olan
        //   istemciye YENI token donmemesi.
        var hatali = await YenileAsync(r1, ip);
        Assert.False(hatali.IsSuccessStatusCode, await hatali.Content.ReadAsStringAsync());

        // Eski satir iptal edilmemis (rollback) - token hala kullanilabilir.
        Assert.Equal(0L, await api.Veri.TekDegerAsync<long>(
            "select count(*) from public.oturum where kullanici_id = @p0 and iptal_tarihi is not null", [u]));
        Assert.Equal(HttpStatusCode.OK, (await YenileAsync(r1)).StatusCode);
    }

    [VtFact]
    public async Task Suresi_dolmus_token_ve_pasif_hesap_reddedilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (kod, u) = await OturumKullanicisiAsync(d);
        var (_, r1) = await api.GirisAsync(kod, TestDunyasi.Parola);
        await api.Veri.CalistirAsync(
            "update public.oturum set bitis_tarihi = now() - interval '1 minute' where kullanici_id = @p0", [u]);
        Assert.Equal(HttpStatusCode.Unauthorized, (await YenileAsync(r1)).StatusCode);

        var (_, r2) = await api.GirisAsync(kod, TestDunyasi.Parola);
        await api.Veri.CalistirAsync("update public.taraf_kullanici set aktif = 0 where id = @p0", [u]);
        Assert.Equal(HttpStatusCode.Unauthorized, (await YenileAsync(r2)).StatusCode);
        Assert.Equal("kullanici_pasif", await api.Veri.TekDegerAsync<string>(
            "select iptal_nedeni from public.oturum where kullanici_id = @p0 order by id desc limit 1", [u]));
    }
}
