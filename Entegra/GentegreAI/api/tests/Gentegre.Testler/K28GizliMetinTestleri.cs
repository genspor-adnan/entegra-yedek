using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K28: entegrasyon sırları DB'de AES-GCM ile şifreli (GizliMetin). Kart dolu
/// sırrı maskeyle döner, maske gelirse değişmez; eski düz metin okunur ve tarayıcı tarafından şifrelenir.
/// Test API'si de depodaki geliştirme anahtarını kullanır (appsettings.json) - test süreci aynı anahtarla çözer.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K28GizliMetinTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    static K28GizliMetinTestleri() => GizliMetin.Kur(GizliMetin.GelistirmeAnahtari, uretim: false);

    [Fact]
    public void Sifrele_coz_gidis_donus_her_seferde_farkli_nonce()
    {
        var a = GizliMetin.Sifrele("Gizli Şifre 123!");
        var b = GizliMetin.Sifrele("Gizli Şifre 123!");
        Assert.StartsWith(GizliMetin.Onek, a);
        Assert.NotEqual(a, b);                                    // rastgele nonce
        Assert.Equal("Gizli Şifre 123!", GizliMetin.Coz(a));
        Assert.Equal(a, GizliMetin.Sifrele(a));                   // iki kez şifrelenmez
        Assert.Equal("", GizliMetin.Coz(null));
        Assert.Equal("eski-duz-metin", GizliMetin.Coz("eski-duz-metin"));   // geçiş: düz metin olduğu gibi
    }

    [Fact]
    public void Kurcalanmis_sifreli_metin_IS_KURALI_ve_uretimde_gelistirme_anahtari_reddedilir()
    {
        var s = GizliMetin.Sifrele("abc")!;
        var bayt = Convert.FromBase64String(s[GizliMetin.Onek.Length..]);
        bayt[^1] ^= 0x01;                                         // etiket bozuldu
        var h = Assert.Throws<GentegreHatasi>(() => GizliMetin.Coz(GizliMetin.Onek + Convert.ToBase64String(bayt)));
        Assert.Equal("IS_KURALI", h.Kod);

        Assert.Throws<InvalidOperationException>(() => GizliMetin.Kur(GizliMetin.GelistirmeAnahtari, uretim: true));
        Assert.Throws<InvalidOperationException>(() => GizliMetin.Kur("", uretim: false));
        Assert.Throws<InvalidOperationException>(() => GizliMetin.Kur(Convert.ToBase64String(new byte[16]), uretim: false));
        GizliMetin.Kur(GizliMetin.GelistirmeAnahtari, uretim: false);   // sonraki testler için geri
    }

    [VtFact]
    public async Task Kart_sifreyi_DBde_sifreli_yazar_maskeyle_doner_maske_degistirmez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("k28", ["entegrasyon:ged"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        var hesapKod = "K28_" + Guid.NewGuid().ToString("N")[..6].ToUpperInvariant();
        var y = await h.PostAsJsonAsync("/api/kart/entegrasyon-hesap",
            new { kart = new { kod = hesapKod, ad = d.Onek + " k28", kullaniciAdi = "kul", sifre = "Cok-Gizli-1" } });
        Assert.True(y.StatusCode == HttpStatusCode.Created, await y.Content.ReadAsStringAsync());
        var id = (await y.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("kart").GetProperty("id").GetInt64();
        d.Temizle($"delete from public.entegrasyon_hesap where id = {id}");

        // DB'de şifreli, düz metin YOK; log da düz şifreyi taşımaz.
        var dbDeger = await api.Veri.TekDegerAsync<string>("select sifre from public.entegrasyon_hesap where id = @p0", [id]);
        Assert.StartsWith(GizliMetin.Onek, dbDeger);
        Assert.Equal("Cok-Gizli-1", GizliMetin.Coz(dbDeger));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.islem_log where tablo_id = 951 and kayit_id = @p0 and bilgi::text like '%Cok-Gizli-1%'", [id]));

        // Okuma: maske, sır istemciye gitmez.
        var kart = (await h.GetFromJsonAsync<JsonElement>($"/api/kart/entegrasyon-hesap/{id}")).GetProperty("kart");
        Assert.Equal(GizliMetin.Maske, kart.GetProperty("sifre").GetString());
        var surum = kart.GetProperty("surum").GetString();

        // Maskeyle kayıt: şifre DEĞİŞMEZ (başka alan değişir).
        var p = await h.PutAsJsonAsync($"/api/kart/entegrasyon-hesap/{id}",
            new { surum, kart = new { kullaniciAdi = "kul2", sifre = GizliMetin.Maske } });
        Assert.True(p.IsSuccessStatusCode, await p.Content.ReadAsStringAsync());
        Assert.Equal(dbDeger, await api.Veri.TekDegerAsync<string>("select sifre from public.entegrasyon_hesap where id = @p0", [id]));

        // Yeni şifre: yeniden şifrelenir.
        surum = (await h.GetFromJsonAsync<JsonElement>($"/api/kart/entegrasyon-hesap/{id}")).GetProperty("kart").GetProperty("surum").GetString();
        p = await h.PutAsJsonAsync($"/api/kart/entegrasyon-hesap/{id}", new { surum, kart = new { sifre = "Yeni-2" } });
        Assert.True(p.IsSuccessStatusCode, await p.Content.ReadAsStringAsync());
        Assert.Equal("Yeni-2", GizliMetin.Coz(await api.Veri.TekDegerAsync<string>(
            "select sifre from public.entegrasyon_hesap where id = @p0", [id])));
    }

    [VtFact]
    public async Task Tarayici_duz_metni_sifreler_ve_okuyucu_cozer()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hesapKod = "K28T_" + Guid.NewGuid().ToString("N")[..6].ToUpperInvariant();
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.entegrasyon_hesap (kod, ad, sifre) values (@p0, @p1, 'duz-sifre') returning id",
            [hesapKod, d.Onek + " tarayici"]);
        d.Temizle($"delete from public.entegrasyon_hesap where id = {id}");

        var servisler = new ServiceCollection().AddSingleton(api.Veri).BuildServiceProvider();
        Assert.True(await GizliMetinTarayici.TaraAsync(servisler, NullLogger.Instance, CancellationToken.None) >= 1);

        var dbDeger = await api.Veri.TekDegerAsync<string>("select sifre from public.entegrasyon_hesap where id = @p0", [id]);
        Assert.StartsWith(GizliMetin.Onek, dbDeger);
        Assert.Equal("duz-sifre", GizliMetin.Coz(dbDeger));
        // İkinci tur: zaten şifreli satıra dokunmaz.
        await GizliMetinTarayici.TaraAsync(servisler, NullLogger.Instance, CancellationToken.None);
        Assert.Equal(dbDeger, await api.Veri.TekDegerAsync<string>("select sifre from public.entegrasyon_hesap where id = @p0", [id]));
    }
    /// <summary>JSON içi sır (ayarlar.client_secret): kartta maske, maskeyle kayıt korur, diğer anahtarlar düz.</summary>
    [VtFact]
    public async Task Ayarlar_client_secret_sifreli_maskeli_ve_korunur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("k28j", ["entegrasyon:ged"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        var y = await h.PostAsJsonAsync("/api/kart/entegrasyon-hesap", new { kart = new {
            kod = "K28J_" + Guid.NewGuid().ToString("N")[..6].ToUpperInvariant(), ad = d.Onek + " k28j",
            ayarlar = "{\"client_secret\":\"sir-123\",\"scope\":\"oob\"}" } });
        Assert.True(y.StatusCode == HttpStatusCode.Created, await y.Content.ReadAsStringAsync());
        var id = (await y.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("kart").GetProperty("id").GetInt64();
        d.Temizle($"delete from public.entegrasyon_hesap where id = {id}");

        string? DbSir() => api.Veri.TekDegerAsync<string>(
            "select ayarlar ->> 'client_secret' from public.entegrasyon_hesap where id = @p0", [id]).GetAwaiter().GetResult();
        var ilk = DbSir();
        Assert.StartsWith(GizliMetin.Onek, ilk);
        Assert.Equal("sir-123", GizliMetin.Coz(ilk));
        Assert.Equal("oob", await api.Veri.TekDegerAsync<string>(
            "select ayarlar ->> 'scope' from public.entegrasyon_hesap where id = @p0", [id]));

        var kart = (await h.GetFromJsonAsync<JsonElement>($"/api/kart/entegrasyon-hesap/{id}")).GetProperty("kart");
        var ayar = kart.GetProperty("ayarlar").GetString()!;
        Assert.DoesNotContain("enc1:", ayar);
        Assert.Contains(GizliMetin.Maske, ayar);

        // Ekranın döndürdüğü (maskeli) JSON'u başka anahtar değiştirerek kaydet: sır aynen korunur.
        var p = await h.PutAsJsonAsync($"/api/kart/entegrasyon-hesap/{id}", new {
            surum = kart.GetProperty("surum").GetString(), kart = new { ayarlar = ayar.Replace("oob", "yeni") } });
        Assert.True(p.IsSuccessStatusCode, await p.Content.ReadAsStringAsync());
        Assert.Equal(ilk, DbSir());
        Assert.Equal("yeni", await api.Veri.TekDegerAsync<string>(
            "select ayarlar ->> 'scope' from public.entegrasyon_hesap where id = @p0", [id]));
    }
}
