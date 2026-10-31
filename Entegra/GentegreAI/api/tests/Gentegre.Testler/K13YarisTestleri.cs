using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K13 (oku-sonra-yaz, koşulsuz UPDATE → çift işlem), K57 / K58
/// (üretim maliyet, satınalma ceza / kabul, steril sayaç) ve K33 (üretimde log yok).
/// Aynı durum geçişinin ikinci isteği 422 ile düşer ve kayıt değişmez; steril döngü sayacı
/// DB'de atomik artar. Eşzamanlılığın kendisi (iki isteğin aynı anda yarışması) burada
/// kurulmaz - koşullu UPDATE + etkilenen satır kontrolü ardışık ikinci istekte de aynı yolu izler.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K13YarisTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    /// <summary>UretimUclari.LogEmir ile aynı (islem_log.tablo_id - uretim_emri).</summary>
    private const int LogEmir = 993;   // KartKatalogu.Uretim uretim-emri (K33: 1429 yanlıştı)

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, params string[] yetkiler)
    {
        var rol = await d.RolAsync("k13", yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    // ------------------------------------------------------------------ üretim ----
    [VtFact]
    public async Task Uretim_emri_ikinci_baslat_422_ve_durum_degismez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var stok = await api.Veri.TekDegerAsync<int>("select min(id) from public.stok");
        Assert.True(stok > 0, "test DB'de stok yok");
        // Onaylı emir, sarf modu 0 (başlatmada sarf fişi kesilmez - burada sınanan durum geçişi).
        var emir = await api.Veri.TekDegerAsync<int>("""
            insert into public.uretim_emri (no, tur, durum, stok_id, adet, sarf_modu, sube_id, ekleyen)
            values (@p0, 2, 2, @p1, 10, 0, @p2, 0) returning id
            """, [d.Onek + "-UE", stok, Merkez]);
        d.Temizle($"delete from public.uretim_emri where id = {emir}");
        d.Temizle($"delete from public.islem_log where tablo_id = {LogEmir} and kayit_id = {emir}");
        using var h = await IstemciAsync(d, "uretim:gde");

        var ilk = await h.PostAsync($"/api/uretim/emri/{emir}/baslat", null);
        Assert.Equal(HttpStatusCode.OK, ilk.StatusCode);
        Assert.Equal(4, (await ilk.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("durum").GetInt32());

        var ikinci = await h.PostAsync($"/api/uretim/emri/{emir}/baslat", null);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ikinci.StatusCode);

        Assert.Equal(4, await api.Veri.TekDegerAsync<int>("select durum::int from public.uretim_emri where id = @p0", [emir]));
        // K33: durum geçişi denetim izine düştü - yalnız başarılı geçiş için tek satır.
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.islem_log where tablo_id = @p0 and kayit_id = @p1", [LogEmir, emir]));
    }

    [VtFact]
    public async Task Uretim_iptal_ve_kapali_emirde_rezerve_ve_fire_422()
    {
        await using var d = new TestDunyasi(api.Veri);
        var stok = await api.Veri.TekDegerAsync<int>("select min(id) from public.stok");
        var iptalEmir = await api.Veri.TekDegerAsync<int>("""
            insert into public.uretim_emri (no, tur, durum, stok_id, adet, sarf_modu, sube_id, ekleyen)
            values (@p0, 2, 0, @p1, 10, 0, @p2, 0) returning id
            """, [d.Onek + "-IP", stok, Merkez]);
        var kapaliEmir = await api.Veri.TekDegerAsync<int>("""
            insert into public.uretim_emri (no, tur, durum, stok_id, adet, sarf_modu, sube_id, ekleyen)
            values (@p0, 2, 7, @p1, 10, 0, @p2, 0) returning id
            """, [d.Onek + "-KP", stok, Merkez]);
        d.Temizle($"delete from public.uretim_emri where id in ({iptalEmir}, {kapaliEmir})");
        using var h = await IstemciAsync(d, "uretim:gde");

        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsync($"/api/uretim/emri/{iptalEmir}/rezerve?ac=true", null)).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsync($"/api/uretim/emri/{kapaliEmir}/rezerve?ac=true", null)).StatusCode);
        var fire = new { stokId = stok, adet = 1m, neden = "test" };
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsJsonAsync($"/api/uretim/emri/{iptalEmir}/fire", fire)).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await h.PostAsJsonAsync($"/api/uretim/emri/{kapaliEmir}/fire", fire)).StatusCode);
        Assert.Equal(0m, await api.Veri.TekDegerAsync<decimal>("select fire_adet from public.uretim_emri where id = @p0", [kapaliEmir]));
    }

    // -------------------------------------------------------------- satınalma ----
    [VtFact]
    public async Task Satinalma_ceza_ikinci_kez_422_tutar_ve_olay_tek()
    {
        await using var d = new TestDunyasi(api.Veri);
        var taraf = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, sube_id) values (@p0, @p1) returning id", [d.Onek + " tedarikçi", Merkez]);
        var belge = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi, belge_no, genel_toplam, ekleyen)
            values (9, 1, @p0, @p1, now(), @p2, 1000, 0) returning id
            """, [taraf, Merkez, d.Onek]);
        await api.Veri.CalistirAsync(
            "insert into public.belge_satinalma (id, gecikme_gun, takip_durum) values (@p0, 5, 0)", [belge]);
        // Temizlik ters sırada çalışır: olay → belge (belge_satinalma cascade) → taraf.
        d.Temizle($"delete from public.taraf where id = {taraf}");
        d.Temizle($"delete from public.belge where id = {belge}");
        d.Temizle($"delete from public.tedarikci_olay where belge_id = {belge}");
        using var h = await IstemciAsync(d, "satinalma.siparis:gde", "satinalma.ceza");

        var ilk = await h.PostAsJsonAsync($"/api/satinalma/siparis/{belge}/ceza", new { tutar = 50m });
        Assert.Equal(HttpStatusCode.OK, ilk.StatusCode);
        var ikinci = await h.PostAsJsonAsync($"/api/satinalma/siparis/{belge}/ceza", new { tutar = 75m });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ikinci.StatusCode);

        Assert.Equal(50m, await api.Veri.TekDegerAsync<decimal>("select ceza_tutar from public.belge_satinalma where id = @p0", [belge]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select ceza_islendi::int from public.belge_satinalma where id = @p0", [belge]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.tedarikci_olay where belge_id = @p0 and tur = 1", [belge]));
    }

    [VtFact]
    public async Task Satinalma_ceza_gecersiz_tutar_400()
    {
        await using var d = new TestDunyasi(api.Veri);
        var taraf = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, sube_id) values (@p0, @p1) returning id", [d.Onek + " tedarikçi", Merkez]);
        var belge = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi, belge_no, genel_toplam, ekleyen)
            values (9, 1, @p0, @p1, now(), @p2, 1000, 0) returning id
            """, [taraf, Merkez, d.Onek]);
        await api.Veri.CalistirAsync(
            "insert into public.belge_satinalma (id, gecikme_gun, takip_durum) values (@p0, 5, 0)", [belge]);
        d.Temizle($"delete from public.taraf where id = {taraf}");
        d.Temizle($"delete from public.belge where id = {belge}");
        using var h = await IstemciAsync(d, "satinalma.siparis:gde", "satinalma.ceza");

        Assert.Equal(HttpStatusCode.BadRequest, (await h.PostAsJsonAsync($"/api/satinalma/siparis/{belge}/ceza", new { tutar = 0m })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await h.PostAsJsonAsync($"/api/satinalma/siparis/{belge}/ceza", new { tutar = -1m })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await h.PostAsJsonAsync($"/api/satinalma/siparis/{belge}/ceza", new { tutar = 1_000_000_000m })).StatusCode);
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select ceza_islendi::int from public.belge_satinalma where id = @p0", [belge]));
    }

    // ------------------------------------------------------------------ steril ----
    [VtFact]
    public async Task Steril_dongu_sayaci_iki_ardisik_baslatmada_farkli()
    {
        await using var d = new TestDunyasi(api.Veri);
        var cihaz = await api.Veri.TekDegerAsync<int>(
            "insert into public.steril_cihaz (ad, tur, sinif, durum, sube_id) values (@p0, 1, 1, 1, @p1) returning id",
            [d.Onek + " otoklav", Merkez]);
        // Test programı: yük istemez, Bowie-Dick kuralına girmez, döngü "test" durumunda açılır
        //   (çalışan döngü sayılmaz) - ikinci başlatma aynı cihazda hemen yapılabilir.
        var program = await api.Veri.TekDegerAsync<int>(
            "insert into public.steril_program (ad, test, aktif, varsayilan) values (@p0, 1, 1, 0) returning id",
            [d.Onek + " BD testi"]);
        // Temizlik ters sırada: olay → indikatör → döngü → program → cihaz.
        d.Temizle($"delete from public.steril_cihaz where id = {cihaz}");
        d.Temizle($"delete from public.steril_program where id = {program}");
        d.Temizle($"delete from public.steril_dongu where cihaz_id = {cihaz}");
        d.Temizle($"delete from public.steril_dongu_indikator where dongu_id in (select id from public.steril_dongu where cihaz_id = {cihaz})");
        d.Temizle($"delete from public.steril_olay where dongu_id in (select id from public.steril_dongu where cihaz_id = {cihaz})");
        using var h = await IstemciAsync(d, "steril.dongu:gde");

        var govde = new { cihazId = cihaz, programId = program };
        var y1 = await h.PostAsJsonAsync("/api/steril/dongu/baslat", govde);
        Assert.True(y1.IsSuccessStatusCode, await y1.Content.ReadAsStringAsync());
        var s1 = (await y1.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("sayacNo").GetInt32();
        var y2 = await h.PostAsJsonAsync("/api/steril/dongu/baslat", govde);
        Assert.True(y2.IsSuccessStatusCode, await y2.Content.ReadAsStringAsync());
        var s2 = (await y2.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("sayacNo").GetInt32();

        Assert.NotEqual(s1, s2);
        Assert.Equal(s1 + 1, s2);
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>(
            "select count(distinct sayac_no)::int from public.steril_dongu where cihaz_id = @p0", [cihaz]));
        Assert.Equal(s2, await api.Veri.TekDegerAsync<int>("select sayac from public.steril_cihaz where id = @p0", [cihaz]));
        // Döngü ile olay / indikatör aynı işlemde yazıldı.
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.steril_olay o join public.steril_dongu dg on dg.id = o.dongu_id where dg.cihaz_id = @p0 and o.tur = 5", [cihaz]));
    }
}
