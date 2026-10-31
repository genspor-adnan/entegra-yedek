using System.Net;
using System.Net.Http.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K13 / K14 / K15: durum koşullu yazım ve tek transaction.
/// (a) Personel avansı ikinci kez ödenemez ve kasa işlemi bir kez yazılır (K13).
/// (b) Kasa dağıtımı: başka şubenin işlemi 404, başka belgenin satır kimliği 400, taslak işlem 422 (K15).
/// (c) Banko kapanış onayı ikinci kez 422; tutanak ve fark fişi tek (K14).
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K14KasaBankoTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    /// <summary>islem_log / kaynak_tur kodları (AvansUclari.LogAvans, BankoOturumUclari.LogTablo).</summary>
    private const int KaynakAvans = 1257, KaynakBanko = 1385;

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, int kullaniciId, string kod)
    {
        await d.SubeVerAsync(kullaniciId, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private async Task<int> HesapAsync(TestDunyasi d, string tur, string ad)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.hesap (tur, ad, sube_id) values (@p0, @p1, @p2) returning id", [tur, d.Onek + " " + ad, Merkez]);
        d.Temizle($"delete from public.hesap where id = {id}");
        return id;
    }

    // ============================================================ (a) avans ===
    [VtFact]
    public async Task Avans_ikinci_odeme_422_ve_tek_kasa_islemi()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("ik", "ik.avans:gd", "ik.avans_ode");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        using var h = await IstemciAsync(d, u, kod);

        var hesap = await HesapAsync(d, "B", "banka");
        var avans = await api.Veri.TekDegerAsync<int>("""
            insert into public.personel_avans (taraf_id, tutar, taksit_sayisi, ilk_donem, durum, sube_id)
            values (@p0, 1200, 3, '2026-12', 2, @p1) returning id
            """, [u, Merkez]);
        // Temizlik ters sırada koşar: kesinti → avans → kasa işlemi → (hesap, yukarıda kayıtlı).
        d.Temizle($"delete from public.kasa_islem where kaynak_tur = {KaynakAvans} and kaynak_id = {avans}");
        d.Temizle($"delete from public.personel_avans where id = {avans}");
        d.Temizle($"delete from public.personel_avans_kesinti where avans_id = {avans}");

        var govde = new { hesapId = hesap, tur = 32 };
        var ilk = await h.PostAsJsonAsync($"/api/ik/avans/{avans}/ode", govde);
        Assert.Equal(HttpStatusCode.OK, ilk.StatusCode);

        var ikinci = await h.PostAsJsonAsync($"/api/ik/avans/{avans}/ode", govde);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ikinci.StatusCode);

        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.kasa_islem where kaynak_tur = @p0 and kaynak_id = @p1", [KaynakAvans, avans]));
        Assert.Equal(4, await api.Veri.TekDegerAsync<int>("select durum::int from public.personel_avans where id = @p0", [avans]));
        Assert.Equal(3, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.personel_avans_kesinti where avans_id = @p0", [avans]));
        // Ödeme bağı kasa işlemini gösterir.
        Assert.True(await api.Veri.TekDegerAsync<bool>(
            "select odeme_islem_id = (select min(id) from public.kasa_islem where kaynak_tur = @p1 and kaynak_id = @p0) from public.personel_avans where id = @p0",
            [avans, KaynakAvans]));
    }

    // ===================================================== (b) kasa dağıtımı ===
    private async Task<int> BelgeAsync(TestDunyasi d, int hasta)
    {
        var id = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, belge_tarihi, taraf_id, durum, sube_id)
            values (19, now(), @p0, 0, @p1) returning id
            """, [hasta, Merkez]);
        d.Temizle($"delete from public.belge where id = {id}");
        return id;
    }

    private async Task<int> KasaIslemiAsync(TestDunyasi d, int hasta, int belge, int sube, short durum)
    {
        var id = await api.Veri.TekDegerAsync<int>("""
            insert into public.kasa_islem (tur, islem_tarihi, taraf_id, tutar, yerel_tutar, durum, belge_id, sube_id)
            values ((select kod from public.kasa_islem_turu where yon = 1 order by kod limit 1), now(), @p0, 100, 100, @p1, @p2, @p3)
            returning id
            """, [hasta, durum, belge, sube]);
        d.Temizle($"delete from public.kasa_islem where id = {id}");
        return id;
    }

    [VtFact]
    public async Task Kasa_dagitim_baska_sube_404_baska_belge_satiri_400_taslak_422()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("kasa", "kasa_islem:gd");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        using var h = await IstemciAsync(d, u, kod);

        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " hasta", Merkez]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var baskaSube = await d.PasifSubeAsync();

        var belgeA = await BelgeAsync(d, hasta);
        var belgeB = await BelgeAsync(d, hasta);
        var hizmet = await api.Veri.TekDegerAsync<int>("select min(id) from public.hizmet");
        var satirB = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, adet, birim_fiyat, tutar, kdv, sube_id)
            values (@p0, 1, 2, @p1, 1, 1, 100, 100, 0, @p2) returning id
            """, [belgeB, hizmet, Merkez]);
        d.Temizle($"delete from public.belge_satir where id = {satirB}");

        var baskaSubeIslem = await KasaIslemiAsync(d, hasta, belgeA, baskaSube, durum: 2);
        var benimIslem = await KasaIslemiAsync(d, hasta, belgeA, Merkez, durum: 2);
        var taslakIslem = await KasaIslemiAsync(d, hasta, belgeA, Merkez, durum: 0);

        // Başka şubenin kasa işlemi: var olmayanla aynı 404.
        var bos = new { otomatik = false, satirlar = Array.Empty<object>() };
        Assert.Equal(HttpStatusCode.NotFound, (await h.PostAsJsonAsync($"/api/kasa-islem/{baskaSubeIslem}/dagitim", bos)).StatusCode);

        // Başka belgenin satır kimliği: 400 DOGRULAMA, hiçbir dağıtım satırı yazılmaz.
        var yabanci = new { otomatik = false, satirlar = new[] { new { belgeSatirId = satirB, pay = 1, tutar = 10m } } };
        var y = await h.PostAsJsonAsync($"/api/kasa-islem/{benimIslem}/dagitim", yabanci);
        Assert.Equal(HttpStatusCode.BadRequest, y.StatusCode);
        Assert.Equal("DOGRULAMA", await ApiSunucuOlgusu.HataKoduAsync(y));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.kasa_islem_dagitim where kasa_islem_id = @p0", [benimIslem]));

        // Taslak (gerçekleşmemiş) işleme dağıtım yazılmaz.
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await h.PostAsJsonAsync($"/api/kasa-islem/{taslakIslem}/dagitim", bos)).StatusCode);
    }

    // ================================================ (c) banko kapanış onayı ===
    [VtFact]
    public async Task Banko_kapanis_onayi_ikinci_kez_422_tutanak_ve_fark_fisi_tek()
    {
        await using var d = new TestDunyasi(api.Veri);
        var gorevliRol = await d.RolAsync("banko", "banko_oturum:ged");
        var sorumluRol = await d.RolAsync("sorumlu", "banko_oturum:g", "banko_onay:gd");
        var (gorevli, _) = await d.KullaniciAsync(gorevliRol, Merkez);
        await d.SubeVerAsync(gorevli, Merkez, yazma: true, varsayilan: true);
        var (sorumlu, sorumluKod) = await d.KullaniciAsync(sorumluRol, Merkez);
        using var h = await IstemciAsync(d, sorumlu, sorumluKod);

        // Fark fişinin karşı hesabı kurum ayarından: eski değer saklanır, sonda geri yazılır.
        var eskiAyar = await api.Veri.TekDegerAsync<string>(
            "select deger from public.referans where anahtar = 'banko.fark_hesap_id'");
        d.Temizle(eskiAyar is null
            ? "delete from public.referans where anahtar = 'banko.fark_hesap_id'"
            : $"update public.referans set deger = '{eskiAyar.Replace("'", "''")}' where anahtar = 'banko.fark_hesap_id'");
        var kasaHesap = await HesapAsync(d, "K", "banko kasa");
        var farkHesap = await HesapAsync(d, "K", "sayım farkı");
        await api.Veri.CalistirAsync("""
            insert into public.referans (anahtar, deger) values ('banko.fark_hesap_id', @p0)
            on conflict (anahtar) do update set deger = excluded.deger
            """, [farkHesap.ToString()]);

        var banko = await api.Veri.TekDegerAsync<int>("""
            insert into public.banko (kod, ad, sube_id, hesap_id, acilis_onay, gun_sonu_onay)
            values (@p0, @p1, @p2, @p3, 0, 1) returning id
            """, [d.Onek, d.Onek + " banko", Merkez, kasaHesap]);
        d.Temizle($"delete from public.banko where id = {banko}");
        // Teslime gönderilmiş (3) oturum, 50 ₺ fazla ile.
        var oturum = await api.Veri.TekDegerAsync<long>("""
            insert into public.banko_oturum (banko_id, sube_id, kullanici_id, durum, acilis_ts, kapanis_talep_ts,
                                             kapanis_sayim, kapanis_beklenen, kapanis_fark, fark_neden, fark_aciklama)
            values (@p0, @p1, @p2, 3, now(), now(), 150, 100, 50, 3, 'test fazlası') returning id
            """, [banko, Merkez, gorevli]);
        d.Temizle($"delete from public.banko_oturum where id = {oturum}");
        d.Temizle($"delete from public.kasa_islem where kaynak_tur = {KaynakBanko} and kaynak_id = {oturum}");
        d.Temizle($"update public.banko_oturum set fark_islem_id = null where id = {oturum}");

        var govde = new { not = "" };
        var ilk = await h.PostAsJsonAsync($"/api/banko-oturum/{oturum}/onayla", govde);
        Assert.Equal(HttpStatusCode.OK, ilk.StatusCode);
        var ikinci = await h.PostAsJsonAsync($"/api/banko-oturum/{oturum}/onayla", govde);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ikinci.StatusCode);

        Assert.Equal(4, await api.Veri.TekDegerAsync<int>("select durum::int from public.banko_oturum where id = @p0", [oturum]));
        var tutanak = await api.Veri.TekDegerAsync<string>("select tutanak_no from public.banko_oturum where id = @p0", [oturum]);
        Assert.StartsWith("TT-", tutanak);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.kasa_islem where kaynak_tur = @p0 and kaynak_id = @p1", [KaynakBanko, oturum]));
        Assert.True(await api.Veri.TekDegerAsync<bool>(
            "select fark_islem_id is not null from public.banko_oturum where id = @p0", [oturum]));
    }
}
