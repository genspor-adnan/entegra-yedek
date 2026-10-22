using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// CTRL+K "TC / telefon + yeni hasta / başvuru / personel" ucu (<c>/api/hizli-bul/kimlik</c>) ve
/// BAŞLANGIÇ "Bekleyen işler" özlük belgesi kartı - gerçek API sürecinde.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HizliBulKimlikTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private int _rolSayaci;

    private static string RastgeleTc() => "9" + Random.Shared.NextInt64(1_000_000_000, 9_999_999_999).ToString();
    private static string RastgeleCep() => "5" + Random.Shared.Next(100_000_000, 999_999_999).ToString();

    private async Task<HttpClient> Giris(TestDunyasi d, params string[] yetkiler)
    {
        var rol = await d.RolAsync("hb" + (++_rolSayaci), yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private static int[] Idler(JsonElement j, string alan) => j.GetProperty(alan).EnumerateArray().Select(x => x.GetProperty("id").GetInt32()).ToArray();

    [VtFact]
    public async Task Tc_ile_hasta_bulunur_numara_dogrulanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tc = RastgeleTc();
        var rol = await d.RolAsync("hasta-k");
        var (hasta, _) = await d.KullaniciAsync(rol, Merkez, vkno: tc, hasta: true);
        using var h = await Giris(d, "hasta:g");

        var j = await h.GetFromJsonAsync<JsonElement>($"/api/hizli-bul/kimlik?q={tc}");
        Assert.Equal("tc", j.GetProperty("tur").GetString());
        Assert.Contains(hasta, Idler(j, "hastalar"));

        // 0'la başlayan 11 hane TC değil (telefon), 9 hane ne TC ne telefon: boş yanıt.
        var bos = await h.GetFromJsonAsync<JsonElement>("/api/hizli-bul/kimlik?q=123456789");
        Assert.Equal("", bos.GetProperty("tur").GetString());
        Assert.Empty(Idler(bos, "hastalar"));
    }

    [VtFact]
    public async Task Pasif_hasta_da_kayitli_sayilir_mukerrer_kart_acilmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tc = RastgeleTc();
        var rol = await d.RolAsync("hasta-k");
        var (hasta, _) = await d.KullaniciAsync(rol, Merkez, vkno: tc, hasta: true);
        await api.Veri.CalistirAsync("update public.taraf set durum = 0 where id = @p0", [hasta]);
        using var h = await Giris(d, "hasta:g");

        var j = await h.GetFromJsonAsync<JsonElement>($"/api/hizli-bul/kimlik?q={tc}");
        var satir = Assert.Single(j.GetProperty("hastalar").EnumerateArray(), x => x.GetProperty("id").GetInt32() == hasta);
        Assert.Contains("Pasif", satir.GetProperty("bilgi").GetString());
    }

    [VtFact]
    public async Task Telefon_kayitli_bicimden_bagimsiz_son_on_haneyle_eslesir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var cep = RastgeleCep();
        var bicimli = $"+90 {cep[..3]} {cep[3..6]} {cep[6..8]} {cep[8..]}";
        var rol = await d.RolAsync("hasta-k");
        var (hasta, _) = await d.KullaniciAsync(rol, Merkez, cepTel: bicimli, hasta: true);
        using var h = await Giris(d, "hasta:g");

        foreach (var yazim in new[] { cep, "0" + cep, "90" + cep })
        {
            var j = await h.GetFromJsonAsync<JsonElement>($"/api/hizli-bul/kimlik?q={yazim}");
            Assert.Equal("tel", j.GetProperty("tur").GetString());
            Assert.Contains(hasta, Idler(j, "hastalar"));
        }
    }

    [VtFact]
    public async Task Her_tur_kendi_yetkisine_bagli()
    {
        await using var d = new TestDunyasi(api.Veri);
        var tc = RastgeleTc();
        var rol = await d.RolAsync("kayit");
        var (hasta, _) = await d.KullaniciAsync(rol, Merkez, vkno: tc, hasta: true);
        var (personel, _) = await d.KullaniciAsync(rol, Merkez, vkno: tc);

        using (var yalnizHasta = await Giris(d, "hasta:g"))
        {
            var j = await yalnizHasta.GetFromJsonAsync<JsonElement>($"/api/hizli-bul/kimlik?q={tc}");
            Assert.Contains(hasta, Idler(j, "hastalar"));
            Assert.Empty(Idler(j, "personeller"));
        }
        using (var yalnizPersonel = await Giris(d, "personel:g"))
        {
            var j = await yalnizPersonel.GetFromJsonAsync<JsonElement>($"/api/hizli-bul/kimlik?q={tc}");
            Assert.Empty(Idler(j, "hastalar"));
            Assert.Contains(personel, Idler(j, "personeller"));
        }
        using (var hicbiri = await Giris(d))
        {
            var j = await hicbiri.GetFromJsonAsync<JsonElement>($"/api/hizli-bul/kimlik?q={tc}");
            Assert.Empty(Idler(j, "hastalar"));
            Assert.Empty(Idler(j, "personeller"));
        }
    }

    // ------------------------------------------------ bekleyen işler: belge --

    [VtFact]
    public async Task Personelin_eksik_zorunlu_belgesi_kendi_bekleyen_islerinde_gorunur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var dep = await api.Veri.TekDegerAsync<int>(
            "insert into public.departman (ad, durum) values (@p0, 1) returning id", [d.Onek + " birim"]);
        var tur = await api.Veri.TekDegerAsync<int>(
            "insert into public.personel_belge_turu (ad, grup) values (@p0, 5) returning id", [d.Onek + " sertifika"]);
        await api.Veri.CalistirAsync(
            "insert into public.personel_belge_kapsam (belge_turu_id, departman_id) values (@p0, @p1)", [tur, dep]);
        d.Temizle($"delete from public.departman where id = {dep}");
        d.Temizle($"delete from public.personel_belge_turu where id = {tur}");   // kapsam cascade

        var rol = await d.RolAsync("pers");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        await api.Veri.CalistirAsync("update public.taraf set departman = @p1, durum = 1 where id = @p0", [u, dep]);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        var j = await h.GetFromJsonAsync<JsonElement>("/api/baslangic/bekleyen");
        // Kurumun "tüm personel" türleri de sayılır: sayı listedeki eksik / süresi dolmuş satırlar kadar.
        var belgeler = j.GetProperty("belgeler").EnumerateArray().ToList();
        Assert.Contains(belgeler, x => x.GetProperty("belge").GetString() == d.Onek + " sertifika"
                                       && x.GetProperty("durum").GetInt32() == 1);
        Assert.Equal(belgeler.Count(x => x.GetProperty("durum").GetInt32() is 1 or 2), j.GetProperty("belgeEksik").GetInt32());
        // Belge takip yetkisi yok: kurum geneli kart gelmez.
        Assert.False(j.TryGetProperty("ikBelgeEksikKisi", out _));
    }

    [VtFact]
    public async Task Belge_takip_yetkilisi_kurum_geneli_eksik_kisi_sayisini_gorur()
    {
        await using var d = new TestDunyasi(api.Veri);
        using var h = await Giris(d, "ik.belge_takip.liste:g");
        var y = await h.GetAsync("/api/baslangic/bekleyen");
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        var j = await y.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(j.TryGetProperty("ikBelgeEksikKisi", out var n) && n.GetInt32() >= 0);
    }
}
