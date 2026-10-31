using System.Net;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K03/K04: hesap yönetim uçları (pasife alma, parola sıfırlama, oturum kapatma,
/// personel-hesap?sifirla) yalnız `kullanici.degistir` / `personel.degistir` ile çalışıyordu; yetkili ama daha dar
/// bir hesap yöneticiyi kilitleyebiliyor ya da parolasını bilinen değere çekebiliyordu. Kural: hedef yönetenden
/// daha geniş yetkiliyse 403; sıfırlama tek kişi ve oturumları kapatır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HesapYonetimiKapisiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(int Id, string Kod, HttpClient H)> KullaniciAsync(TestDunyasi d, string rolAdi, params string[] yetkiler)
    {
        var rol = await d.RolAsync(rolAdi, yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return (u, kod, api.Istemci(access, Merkez));
    }

    [VtFact]
    public async Task Daha_genis_yetkili_hesap_yonetilemez_dar_olan_yonetilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var yoneten = await KullaniciAsync(d, "bilgi-islem", "kullanici:gd", "personel:gd");
        using var h = yoneten.H;
        // Hedef B: yönetende olmayan bir yetki (rol.degistir) taşır → yönetilemez.
        var genis = await KullaniciAsync(d, "genis", "kullanici:gd", "rol:gd");
        using var hGenis = genis.H;
        // Hedef C: yalnız görme → yönetilebilir.
        var dar = await KullaniciAsync(d, "dar", "hasta:g");
        using var hDar = dar.H;

        Assert.Equal(HttpStatusCode.Forbidden, (await h.PostAsync($"/api/kullanici/{genis.Id}/durum?aktif=false", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await h.PostAsync($"/api/kullanici/{genis.Id}/parola-sifirla", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await h.PostAsync($"/api/kullanici/{genis.Id}/oturum-kapat", null)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await hGenis.GetAsync("/api/kimlik/ben")).StatusCode);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select aktif::int from public.taraf_kullanici where id = @p0", [genis.Id]));

        Assert.Equal(HttpStatusCode.OK, (await h.PostAsync($"/api/kullanici/{dar.Id}/oturum-kapat", null)).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await hDar.GetAsync("/api/kimlik/ben")).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await h.PostAsync($"/api/kullanici/{dar.Id}/durum?aktif=false", null)).StatusCode);
    }

    [VtFact]
    public async Task Personel_hesap_sifirlama_tek_kisi_kullanici_yetkisi_ve_hiyerarsi_ister()
    {
        await using var d = new TestDunyasi(api.Veri);
        var ik = await KullaniciAsync(d, "ik", "personel:gd");
        using var hIk = ik.H;
        var yonetici = await KullaniciAsync(d, "yonetici-gibi", "kullanici:gd", "personel:gd");
        using var hY = yonetici.H;
        var genis = await KullaniciAsync(d, "genis", "kullanici:gd", "rol:gd");
        using var hGenis = genis.H;
        var dar = await KullaniciAsync(d, "dar", "hasta:g");
        using var hDar = dar.H;
        // personel-hesap yalnız AKTİF personel kartını (durum = 1) hedefler.
        await api.Veri.CalistirAsync("update public.taraf set durum = 1 where id in (@p0, @p1)", [dar.Id, genis.Id]);
        var eskiHash = await api.Veri.TekDegerAsync<string>("select parola_hash from public.taraf_kullanici where id = @p0", [dar.Id]);

        // Toplu sıfırlama yok.
        Assert.Equal(HttpStatusCode.BadRequest, (await hY.PostAsync("/api/kimlik/personel-hesap?sifirla=true", null)).StatusCode);
        // Yalnız personel.degistir ile sıfırlama yok.
        Assert.Equal(HttpStatusCode.Forbidden, (await hIk.PostAsync($"/api/kimlik/personel-hesap?sifirla=true&tarafId={dar.Id}", null)).StatusCode);
        // Daha geniş yetkili hedef sıfırlanamaz.
        Assert.Equal(HttpStatusCode.Forbidden, (await hY.PostAsync($"/api/kimlik/personel-hesap?sifirla=true&tarafId={genis.Id}", null)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await hGenis.GetAsync("/api/kimlik/ben")).StatusCode);

        // Dar hedef: sıfırlanır, oturumu düşer.
        var y = await hY.PostAsync($"/api/kimlik/personel-hesap?sifirla=true&tarafId={dar.Id}", null);
        Assert.Equal(HttpStatusCode.OK, y.StatusCode);
        Assert.NotEqual(eskiHash, await api.Veri.TekDegerAsync<string>("select parola_hash from public.taraf_kullanici where id = @p0", [dar.Id]));
        Assert.Equal(HttpStatusCode.Unauthorized, (await hDar.GetAsync("/api/kimlik/ben")).StatusCode);
    }
}
