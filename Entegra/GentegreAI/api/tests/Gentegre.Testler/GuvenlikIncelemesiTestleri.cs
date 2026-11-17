using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// GÜVENLİK İNCELEMESİ 18.11.2026 düzeltmeleri. Yanlış parolalar YALNIZ testin kendi açtığı hesaplarda denenir.
///  1 toplu personel-hesap parolasız hesaba tahmin edilebilir parola yazmaz · 2 kilitliyken doğru / yanlış parola aynı
///  cevap · 3 hız sınırı yolu harf / sondaki '/' duyarsız · 4 iki adımlı doğrulama açık hesap giremez (özellik yok)
///  7 kapsamlı kullanıcıda kapsam kolonu tanımsız kişi verisi kapalı · 8 parola-unuttum hesap varlığını söylemez
///  9 kilit bitince sayaç baştan.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class GuvenlikIncelemesiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(int Id, string Kod)> HesapAsync(TestDunyasi d, string ad, params string[] yetkiler)
    {
        var rol = await d.RolAsync(ad, yetkiler.Length > 0 ? yetkiler : ["hasta:g"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        d.Temizle($"delete from public.giris_denemesi where kullanici_id = {u}");
        return (u, kod);
    }

    private async Task<(HttpStatusCode Durum, string Mesaj)> GirAsync(string kod, string parola)
    {
        using var h = api.Istemci(null, null);
        var y = await h.PostAsJsonAsync("/api/kimlik/giris", new { kod, parola });
        var govde = await y.Content.ReadAsStringAsync();
        var mesaj = govde.Length > 0 && JsonSerializer.Deserialize<JsonElement>(govde).TryGetProperty("hata", out var e)
            ? e.GetProperty("mesaj").GetString() ?? "" : "";
        return (y.StatusCode, mesaj);
    }

    [VtFact]
    public async Task Kilitli_hesapta_dogru_ve_yanlis_parola_ayni_cevabi_alir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (id, kod) = await HesapAsync(d, "kilit");
        await api.Veri.CalistirAsync(
            "update public.taraf_kullanici set hatali_giris = 5, kilit_bitis = now()::timestamp + interval '15 minutes' where id = @p0", [id]);
        var dogru = await GirAsync(kod, TestDunyasi.Parola);
        var yanlis = await GirAsync(kod, "yanlis-parola-123");
        Assert.Equal(HttpStatusCode.Unauthorized, dogru.Durum);
        Assert.Equal(dogru, yanlis);
    }

    [VtFact]
    public async Task Kilit_bitince_tek_yanlis_deneme_yeniden_kilitlemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (id, kod) = await HesapAsync(d, "kilitbitti");
        await api.Veri.CalistirAsync(
            "update public.taraf_kullanici set hatali_giris = 5, kilit_bitis = now()::timestamp - interval '1 minute' where id = @p0", [id]);
        await GirAsync(kod, "yanlis-parola-123");
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select hatali_giris::int from public.taraf_kullanici where id = @p0", [id]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.taraf_kullanici where id = @p0 and kilit_bitis > now()::timestamp", [id]));
        // Doğru parola hâlâ girer.
        Assert.Equal(HttpStatusCode.OK, (await GirAsync(kod, TestDunyasi.Parola)).Durum);
    }

    [VtFact]
    public async Task Iki_adimli_dogrulama_acik_hesap_giremez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (id, kod) = await HesapAsync(d, "totp");
        await api.Veri.CalistirAsync("update public.taraf_kullanici set totp_aktif = 1 where id = @p0", [id]);
        var y = await GirAsync(kod, TestDunyasi.Parola);
        Assert.Equal(HttpStatusCode.Forbidden, y.Durum);
        Assert.Contains("2 adımlı", y.Mesaj);
    }

    [VtFact]
    public async Task Toplu_personel_hesap_parolasiz_hesaba_parola_yazmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (_, ikKod) = await HesapAsync(d, "ik", "personel:gd");
        var (hedef, _) = await HesapAsync(d, "hedef");
        await api.Veri.CalistirAsync("update public.taraf set durum = 1 where id = @p0", [hedef]);
        await api.Veri.CalistirAsync("update public.taraf_kullanici set parola_hash = '' where id = @p0", [hedef]);
        var (access, _) = await api.GirisAsync(ikKod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        var y = await h.PostAsync($"/api/kimlik/personel-hesap?tarafId={hedef}", null);
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        Assert.Equal(0, (await y.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("parolaAtanan").GetInt32());
        // Hâlâ parolasız: ilk girişte İLK PAROLA (kayıtlı kanala kod) akışına düşer.
        Assert.Equal("", await api.Veri.TekDegerAsync<string>("select parola_hash from public.taraf_kullanici where id = @p0", [hedef]));
    }

    [VtFact]
    public async Task Parola_unuttum_hesap_varligini_soylemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (_, kod) = await HesapAsync(d, "unuttum");
        using var h = api.Istemci(null, null);
        var var_ = await (await h.PostAsJsonAsync("/api/kimlik/parola-unuttum", new { kod })).Content.ReadAsStringAsync();
        var yok = await (await h.PostAsJsonAsync("/api/kimlik/parola-unuttum", new { kod = "yok-" + d.Onek })).Content.ReadAsStringAsync();
        Assert.Equal(yok, var_);
        Assert.DoesNotContain("hedef", var_);
    }

    [Theory]
    [InlineData("/api/kimlik/giris", true)]
    [InlineData("/api/kimlik/Giris", true)]
    [InlineData("/API/KIMLIK/GIRIS/", true)]
    [InlineData("/api/kimlik/giris/", true)]
    [InlineData("/api/kimlik/Yenile", true)]
    [InlineData("/api/kimlik/Parola-Unuttum/dogrula", true)]
    [InlineData("/api/kimlik/ILK-PAROLA/kod", true)]
    [InlineData("/api/kimlik/ben", false)]
    [InlineData("/api/kimlik/hesabim", false)]
    public void Hiz_siniri_yolu_harf_ve_sondaki_bolu_duyarsiz(string yol, bool sinirli)
        => Assert.Equal(sinirli, KimlikSinirYolu.Sinirli(yol));

    [Fact]
    public void Kapsamli_kullanicida_kapsam_kolonu_olmayan_kisi_verisi_kapali()
    {
        // Kişiye ait kayıt taşıyan (portal kuralı tanımlı) ama kapsam kolonu olmayan kaynak.
        var kisiVerisi = KaynakKatalogu.Tumu.FirstOrDefault(k => k.PortalKosullari is { Count: > 0 } && k.KapsamKolonu is null);
        if (kisiVerisi is not null)
        {
            var sql = new SorguUretici(kisiVerisi).Sayim(new ListeIstegi(), 1, [123], 1).Sql;
            Assert.Contains("false", sql);
        }
        // Tanım listesi (portal kuralı da kapsam kolonu da yok) açık kalır.
        var tanim = KaynakKatalogu.Tumu.First(k => k.PortalKosullari is null && k.KapsamKolonu is null && k.SabitKosul is null);
        Assert.DoesNotContain("false", new SorguUretici(tanim).Sayim(new ListeIstegi(), 1, [123], 1).Sql);
        // Kapsam kolonu olan kaynakta kural kolona uygulanır.
        var kolonlu = KaynakKatalogu.Tumu.First(k => k.KapsamKolonu is not null);
        Assert.Contains(kolonlu.KapsamKolonu!, new SorguUretici(kolonlu).Sayim(new ListeIstegi(), 1, [123], 1).Sql);
    }
}
