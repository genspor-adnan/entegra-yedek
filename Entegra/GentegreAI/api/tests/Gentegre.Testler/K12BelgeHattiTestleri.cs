using System.Net;
using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K12 (belge hattı + bağ güncellemesi ayrı transaction → çift fatura /
/// çift stok düşümü). Belge yazımı ile kaynak kalemin bağı artık TEK işlemde ve kaynak satırlar kilitli
/// okunuyor: aynı işlem ikinci kez çağrılınca 422 döner, ikinci belge OLUŞMAZ, bağsız satır kalmaz ve stok
/// yalnız bir kez düşer. Eş zamanlı iki çağrıdan da yalnız biri geçer.
///
/// Fikstür: izlemsiz (lot/seri tutmayan) deneme stoğu + bakiyesi; eczane imha tutanağı (komisyon onaylı)
/// ve teknik servis iş emri parçaları. Çıkış fişi varsayılan depoya kesilir.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K12BelgeHattiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const decimal BaslangicBakiye = 100m;
    private const int LogImha = 1204;    // EczaneUclari.LogImha
    private const int LogIsEmri = 1224;  // BiyomedikalUclari.LogIsEmri
    private const int LogBelge = 30;     // BelgeDeposu.LogTabloBelge

    private Task<int> DepoAsync() => api.Veri.TekDegerAsync<int>("""
        select coalesce((select min(id) from public.depo where varsayilan = 1 and coalesce(durum, 1) = 1),
                        (select min(id) from public.depo where coalesce(durum, 1) = 1))
        """, null);

    /// <summary>İzlemsiz deneme stoğu + depoda bakiye. Fişin izleri (belge, satır, log) de temizliğe yazılır.</summary>
    private async Task<int> StokAsync(TestDunyasi d, int depo)
    {
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 0, @p2) returning id",
            [d.Onek + "-STK", d.Onek + " deneme stoğu", Merkez]);
        d.Temizle($"delete from public.stok where id = {stok}");
        await api.Veri.CalistirAsync(
            "insert into public.stok_durum (stok_id, depo_id, giren, cikan, kalan) values (@p0, @p1, @p2, 0, @p2)",
            [stok, depo, BaslangicBakiye]);
        d.Temizle($"delete from public.stok_durum where stok_id = {stok}");
        // Uçların kestiği çıkış fişleri: satır ve izlem cascade ile gider, log ayrı.
        d.Temizle($"delete from public.belge where id in (select s.belge_id from public.belge_satir s where s.stok_id = {stok})");
        d.Temizle($"delete from public.islem_log where tablo_id = {LogBelge} and kayit_id in (select s.belge_id from public.belge_satir s where s.stok_id = {stok})");
        return stok;
    }

    private Task<decimal> KalanAsync(int stok, int depo)
        => api.Veri.TekDegerAsync<decimal>(
            "select kalan from public.stok_durum where stok_id = @p0 and depo_id = @p1", [stok, depo]);

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, params string[] yetkiler)
    {
        var rol = await d.RolAsync("k12", yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        _kullanici = u;
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    /// <summary>Son açılan istemcinin kullanıcısı (iş emrinde müşteri tarafı olarak kullanılır).</summary>
    private int _kullanici;

    // ------------------------------------------------------------ eczane imha ----

    private async Task<(long Imha, string TutanakNo)> ImhaAsync(TestDunyasi d, int stok)
    {
        // durum 1 = komisyon onaylı (imha-et bunu ister).
        var imha = await api.Veri.TekDegerAsync<long>(
            "insert into public.eczane_imha (sube_id, durum, komisyon, ekleyen) values (@p0, 1, 'Komisyon A, B', 0) returning id",
            [Merkez]);
        d.Temizle($"delete from public.eczane_imha where id = {imha}");
        d.Temizle($"delete from public.islem_log where tablo_id = {LogImha} and kayit_id = {imha}");
        await api.Veri.CalistirAsync(
            "insert into public.eczane_imha_satir (imha_id, stok_id, ad, miktar) values (@p0, @p1, @p2, 2)",
            [imha, stok, d.Onek + " deneme"]);
        var tutanakNo = await api.Veri.TekDegerAsync<string>(
            "select tutanak_no from public.eczane_imha where id = @p0", [imha]) ?? "";
        return (imha, tutanakNo);
    }

    private static Task<HttpResponseMessage> ImhaEtAsync(HttpClient h, long imha, int depo)
        => h.PostAsJsonAsync($"/api/eczane/imha/{imha}/imha-et", new { depoId = depo });

    [VtFact]
    public async Task Imha_ikinci_kez_cagrilinca_422_ve_ikinci_fis_olusmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var depo = await DepoAsync();
        var stok = await StokAsync(d, depo);
        var (imha, tutanakNo) = await ImhaAsync(d, stok);
        using var h = await IstemciAsync(d, "eczane.imha:gd", "stok:gd", "eczane.imha_onay");

        var ilk = await ImhaEtAsync(h, imha, depo);
        Assert.True(ilk.StatusCode == HttpStatusCode.OK, $"ilk imha {(int)ilk.StatusCode}: {await ilk.Content.ReadAsStringAsync()}");
        var belgeId = (await ilk.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("belgeId").GetInt32();

        // Aynı tutanak bir daha: iş kuralı (422), fiş yok, stok bir daha düşmez.
        var ikinci = await ImhaEtAsync(h, imha, depo);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ikinci.StatusCode);

        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.belge where aciklama = @p0", ["Eczane imha · " + tutanakNo]));
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>(
            "select durum::int from public.eczane_imha where id = @p0", [imha]));
        Assert.Equal(belgeId, await api.Veri.TekDegerAsync<int>(
            "select belge_id from public.eczane_imha where id = @p0", [imha]));
        Assert.Equal(BaslangicBakiye - 2, await KalanAsync(stok, depo));
    }

    [VtFact]
    public async Task Es_zamanli_iki_imha_cagrisindan_yalniz_biri_gecer()
    {
        await using var d = new TestDunyasi(api.Veri);
        var depo = await DepoAsync();
        var stok = await StokAsync(d, depo);
        var (imha, tutanakNo) = await ImhaAsync(d, stok);
        using var h = await IstemciAsync(d, "eczane.imha:gd", "stok:gd", "eczane.imha_onay");

        // İki istek aynı anda: tutanak satırı kilitli okunduğu için ikinci, birincinin commit'ini bekler ve
        //   "zaten imha edildi" görür. Eskiden ikisi de durum=1 görüp iki fiş keserdi.
        var sonuclar = await Task.WhenAll(ImhaEtAsync(h, imha, depo), ImhaEtAsync(h, imha, depo));
        Assert.Equal(1, sonuclar.Count(y => y.StatusCode == HttpStatusCode.OK));
        Assert.Equal(1, sonuclar.Count(y => y.StatusCode == HttpStatusCode.UnprocessableEntity));

        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.belge where aciklama = @p0", ["Eczane imha · " + tutanakNo]));
        Assert.Equal(BaslangicBakiye - 2, await KalanAsync(stok, depo));
    }

    // -------------------------------------------------- teknik servis parça ----

    [VtFact]
    public async Task Parca_cikisinda_bagsiz_satir_kalmaz_ve_tekrar_dusum_yapilmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var depo = await DepoAsync();
        var stok = await StokAsync(d, depo);
        using var h = await IstemciAsync(d, "demirbas.isemri:gd", "stok:gd");

        // Müşteri cihazı iş emri (sahiplik 2): müşteri tarafı test kullanıcısının kendi kaydı.
        var isEmri = await api.Veri.TekDegerAsync<long>("""
            insert into public.demirbas_is_emri (sube_id, sahiplik, musteri_taraf_id, durum, ekleyen)
            values (@p0, 2, @p1, 1, 0) returning id
            """, [Merkez, _kullanici]);
        d.Temizle($"delete from public.demirbas_is_emri where id = {isEmri}");
        d.Temizle($"delete from public.islem_log where tablo_id = {LogIsEmri} and kayit_id = {isEmri}");
        for (var i = 1; i <= 2; i++)
            await api.Veri.CalistirAsync("""
                insert into public.demirbas_is_emri_parca (is_emri_id, stok_id, ad, miktar, kapsam)
                values (@p0, @p1, @p2, 1, 0)
                """, [isEmri, stok, $"{d.Onek} parça {i}"]);
        var isEmriNo = await api.Veri.TekDegerAsync<string>(
            "select is_emri_no from public.demirbas_is_emri where id = @p0", [isEmri]) ?? "";

        var ilk = await h.PostAsJsonAsync($"/api/demirbas/is-emri/{isEmri}/parca-cikis", new { depoId = depo });
        Assert.True(ilk.StatusCode == HttpStatusCode.OK, $"parça çıkışı {(int)ilk.StatusCode}: {await ilk.Content.ReadAsStringAsync()}");
        var belgeId = (await ilk.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("belgeId").GetInt32();

        // BAĞSIZ SATIR KALMAZ: düşülen her parça fişe bağlı, hepsi aynı fişe.
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.demirbas_is_emri_parca where is_emri_id = @p0 and belge_id is null", [isEmri]));
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.demirbas_is_emri_parca where is_emri_id = @p0 and belge_id = @p1", [isEmri, belgeId]));

        // İkinci çağrı: düşülecek parça kalmadı (422), ikinci fiş yok, bakiye bir kez düştü.
        var ikinci = await h.PostAsJsonAsync($"/api/demirbas/is-emri/{isEmri}/parca-cikis", new { depoId = depo });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ikinci.StatusCode);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.belge where aciklama like @p0", ["Teknik servis parça · " + isEmriNo + "%"]));
        Assert.Equal(BaslangicBakiye - 2, await KalanAsync(stok, depo));
    }
}
