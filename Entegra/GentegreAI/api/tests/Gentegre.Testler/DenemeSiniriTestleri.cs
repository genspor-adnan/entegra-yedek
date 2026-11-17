using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME 17.11.2026 (5 ve 8):
///  * "Başkası adına" şifre: yanlış şifre şifresi istenen radyoloğun GİRİŞ sayacını artırmaz (hesabı kilitletilemez);
///    ÇAĞIRAN 15 dakikada 5 hatalı denemeden sonra durdurulur.
///  * KVKK SMS onay kodu: 5 hatalı denemede kilitlenir, SMS'ten 30 dakika sonra geçersizdir (1364).
///  * Radyolog = rol kartındaki "Radyolog" bayrağı (1365); rol KODU önemli değil.
/// Bütün yanlış şifreler testin kendi açtığı hesaplarda denenir.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class DenemeSiniriTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(HttpClient Istemci, int Id)> KullaniciAsync(TestDunyasi d, int rol)
    {
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        d.Temizle($"delete from public.giris_denemesi where kullanici_id = {u} or sebep like '%:u{u}'");
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return (api.Istemci(access, Merkez), u);
    }

    [VtFact]
    public async Task Baskasi_adina_yanlis_sifre_radyologu_kilitlemez_cagiran_durdurulur()
    {
        await using var d = new TestDunyasi(api.Veri);
        // Radyolog: rol KODU kalıba uymuyor ("uzm") ama bayrak işaretli - radyolog sayılır (1365).
        var radRol = await d.RolAsync("uzm", "radyoloji:gde", "radyoloji-istem:gde", "rad.rapor_yaz", "rad.rapor_onayla");
        await api.Veri.CalistirAsync("update public.rol set radyolog = 1 where id = @p0", [radRol]);
        var (_, radyolog) = await KullaniciAsync(d, radRol);
        var yazRol = await d.RolAsync("yaz", "radyoloji:gde", "radyoloji-istem:gde", "rad.rapor_yaz");
        var (cagiran, cagiranId) = await KullaniciAsync(d, yazRol);

        // Şifre, rapor okunmadan önce denetlenir: rapor 0 yeterli.
        async Task<string> Dene() =>
            await (await cagiran.PostAsJsonAsync("/api/radyoloji/rapor/0/durum?hedef=onay&surum=x",
                new { adinaId = radyolog, parola = "yanlis-sifre" })).Content.ReadAsStringAsync();
        for (var i = 0; i < 5; i++)
            Assert.Contains("Parola hatal", await Dene());
        Assert.Contains("hatalı şifre denemesi", JsonSerializer.Deserialize<JsonElement>(await Dene())
            .GetProperty("hata").GetProperty("mesaj").GetString());
        // Radyoloğun giriş hesabı etkilenmedi.
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select coalesce(hatali_giris, 0)::int from public.taraf_kullanici where id = @p0", [radyolog]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.taraf_kullanici where id = @p0 and kilit_bitis > now()", [radyolog]));
        _ = cagiranId;
    }

    [VtFact]
    public async Task KVKK_onay_kodu_5_hatada_kilitlenir_ve_30_dakikada_eskir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("kvkk", "belge:gde");
        var (istemci, _) = await KullaniciAsync(d, rol);
        var hasta = await api.Veri.TekDegerAsync<int>("select min(id) from public.taraf where hasta = 1", []);
        var basvuru = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no)
            values (19, 30, 0, now(), @p0, @p1, @p2) returning id
            """, [hasta, Merkez, d.Onek]);
        d.Temizle($"delete from public.belge_basvuru where id = {basvuru}");
        d.Temizle($"delete from public.belge where id = {basvuru}");
        await api.Veri.CalistirAsync(
            "insert into public.belge_basvuru (id, kvkk_sms_kod, kvkk_sms_tarihi) values (@p0, '654321', now())", [basvuru]);

        async Task<string> Gir(string kod) =>
            JsonSerializer.Deserialize<JsonElement>(await (await istemci.PostAsJsonAsync(
                $"/api/basvuru/{basvuru}/kvkk-kod", new { kod })).Content.ReadAsStringAsync())
            .TryGetProperty("hata", out var h) ? h.GetProperty("mesaj").GetString()! : "tamam";

        Assert.Contains("4 deneme hakkı", await Gir("111111"));
        for (var i = 0; i < 4; i++) await Gir("111111");
        // Sınır doldu: DOĞRU kod da artık kabul edilmez - yeni SMS gerekir.
        Assert.Contains("kilitlendi", await Gir("654321"));

        // Yeni SMS (sayaç sıfır) ama 31 dakika önce: süre doldu.
        await api.Veri.CalistirAsync(
            "update public.belge_basvuru set kvkk_kod_hata = 0, kvkk_sms_tarihi = now() - interval '31 minutes' where id = @p0", [basvuru]);
        Assert.Contains("süresi doldu", await Gir("654321"));

        // Süre içinde doğru kod: onay.
        await api.Veri.CalistirAsync("update public.belge_basvuru set kvkk_sms_tarihi = now() where id = @p0", [basvuru]);
        Assert.Equal("tamam", await Gir("654321"));
        Assert.Equal(4, await api.Veri.TekDegerAsync<int>("select kvkk_onay::int from public.belge_basvuru where id = @p0", [basvuru]));
    }
}
