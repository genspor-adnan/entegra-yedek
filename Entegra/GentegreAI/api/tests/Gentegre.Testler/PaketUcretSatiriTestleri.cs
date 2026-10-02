using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// PANEL / CHECK-UP TEK ÜCRET SATIRI (925, kullanıcı).
///
/// Kullanıcı: *"TİT istemi… ücrete aktarıldığında tek satır gelmelidir…
/// hemogram ve diğer paneller de"* ve *"check-up'lar da ücret satırında tek
/// olmalı"*. Ücret satırı paneli/paketi taşır, laboratuvar yaprak tetkikleri
/// çalışır; iki taraf "kapsam" (fn_hizmet_paket_kapsam) ile buluşur:
///   * kapsam kök + ara panel + yaprak döner (fn_hizmet_paket_ac yalnız yaprak);
///   * panel satırı panelden doğan istemi, check-up satırı içindeki her
///     istemi serbest bırakır; kapsam dışı istem bekler;
///   * yalnız check-up satırı girilmiş başvuru kaydedilince istem paket
///     içeriğinden açılır, panel parametreleri panel köküyle işaretlenir.
///
/// Test kendi hizmet/panel/tetkik/hasta/başvurusunu açar ve siler.
/// Veritabanı yoksa atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class PaketUcretSatiriTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam() => new()
    {
        KullaniciId = 1, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = 1, IzlemeNo = "test",
        Yetkiler = new YetkiSeti(1, [new YetkiKaydi("lab.istem", 0, true, true, true, true)], []),
    };

    /// <summary>
    /// Check-up (Chk) = Panel (A + B) + C. Panel bir lab_panel; D kapsam dışı.
    /// </summary>
    private sealed class Dunya : IAsyncDisposable
    {
        public VeriKaynagi Veri = default!;
        public int HA, HB, HC, HD, HPanel, HChk, TA, TB, TC, TD, Panel, Hasta, Belge;
        private readonly string _e = "T925" + Random.Shared.Next(10000, 99999);

        private async Task<int> HizmetAsync(string ek, int paket) =>
            await Veri.TekDegerAsync<int>(
                "insert into public.hizmet (kod, ad, tur, sube_id, paket) values (@p0, @p1, 2, 1, @p2) returning id",
                [_e + ek, _e + " " + ek, paket]);

        private async Task<int> TetkikAsync(string ek, int hizmet) =>
            await Veri.TekDegerAsync<int>("""
                insert into public.lab_tetkik (kod, ad, hizmet_id, bolum, tur, numune_tipi, tup_tipi, birim, durum)
                values (@p0, @p1, @p2, 1, 1, 1, 1, 'mg/dL', 0) returning id
                """, [_e + ek, _e + " " + ek, hizmet]);

        public static async Task<Dunya> KurAsync(VeriKaynagi veri)
        {
            var d = new Dunya { Veri = veri };
            d.HA = await d.HizmetAsync("A", 0);
            d.HB = await d.HizmetAsync("B", 0);
            d.HC = await d.HizmetAsync("C", 0);
            d.HD = await d.HizmetAsync("D", 0);
            d.HPanel = await d.HizmetAsync("P", 1);
            d.HChk = await d.HizmetAsync("K", 1);
            d.TA = await d.TetkikAsync("A", d.HA);
            d.TB = await d.TetkikAsync("B", d.HB);
            d.TC = await d.TetkikAsync("C", d.HC);
            d.TD = await d.TetkikAsync("D", d.HD);
            await veri.CalistirAsync("""
                insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira, adet)
                values (@p0, @p1, 10, 1), (@p0, @p2, 20, 1), (@p3, @p0, 10, 1), (@p3, @p4, 20, 1)
                """, [d.HPanel, d.HA, d.HB, d.HChk, d.HC]);
            d.Panel = await veri.TekDegerAsync<int>(
                "insert into public.lab_panel (kod, ad, hizmet_id) values (@p0, @p1, @p2) returning id",
                [d._e + "P", d._e + " Panel", d.HPanel]);
            d.Hasta = await veri.TekDegerAsync<int>(
                "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, 1) returning id", [d._e + " Hasta"]);
            d.Belge = await veri.TekDegerAsync<int>("""
                insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi, ekleyen)
                values (19, 30, @p0, 1, now(), 1) returning id
                """, [d.Hasta]);
            await veri.CalistirAsync("insert into public.belge_basvuru (id, hasta_id) values (@p0, @p1)",
                                     [d.Belge, d.Hasta]);
            return d;
        }

        public Task SatirEkleAsync(int hizmet) => Veri.CalistirAsync("""
            insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, adet, birim_fiyat, tutar, kdv, sube_id)
            values (@p0, (select coalesce(max(sira), 0) + 1 from public.belge_satir where belge_id = @p0),
                    2, @p1, 1, 1, 100, 100, 0, 1)
            """, [Belge, hizmet]);

        /// <summary>Bekleyen (serbest=0) istem: verilen tetkik(ler), panel kökenli olabilir.</summary>
        public async Task<int> BekleyenIstemAsync(int? panel, params int[] tetkikler)
        {
            var id = await Veri.TekDegerAsync<int>("""
                insert into public.lab_istem (belge_id, taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik, serbest)
                values (@p0, @p1, 1, 'T925-' || floor(random() * 1000000)::text, 1, 1, 1, 1, 0)
                returning id
                """, [Belge, Hasta]);
            var sira = 0;
            foreach (var t in tetkikler)
                await Veri.CalistirAsync("""
                    insert into public.lab_istem_satir (istem_id, tetkik_id, panel_id, durum, sira)
                    values (@p0, @p1, @p2, 1, @p3)
                    """, [id, t, panel, (short)(++sira * 10)]);
            return id;
        }

        public Task<short> SerbestAsync(int istem) => Veri.TekDegerAsync<short>(
            "select serbest from public.lab_istem where id = @p0", [istem]);

        public async ValueTask DisposeAsync()
        {
            var v = Veri;
            await v.CalistirAsync("delete from public.lab_akilci_gerekce where hasta_id = @p0", [Hasta]);
            await v.CalistirAsync("delete from public.lab_istem_satir where istem_id in (select id from public.lab_istem where taraf_id = @p0)", [Hasta]);
            await v.CalistirAsync("delete from public.lab_numune where istem_id in (select id from public.lab_istem where taraf_id = @p0)", [Hasta]);
            await v.CalistirAsync("delete from public.lab_istem where taraf_id = @p0", [Hasta]);
            await v.CalistirAsync("delete from public.belge_satir_dagilim where belge_satir_id in (select id from public.belge_satir where belge_id = @p0)", [Belge]);
            await v.CalistirAsync("delete from public.belge_satir where belge_id = @p0", [Belge]);
            await v.CalistirAsync("delete from public.belge_basvuru where id = @p0", [Belge]);
            await v.CalistirAsync("delete from public.belge where id = @p0", [Belge]);
            await v.CalistirAsync("delete from public.taraf where id = @p0", [Hasta]);
            await v.CalistirAsync("delete from public.lab_panel where id = @p0", [Panel]);
            await v.CalistirAsync("delete from public.lab_tetkik where id = any(@p0)", [new[] { TA, TB, TC, TD }]);
            await v.CalistirAsync("delete from public.hizmet_paket where paket_hizmet_id = any(@p0)", [new[] { HPanel, HChk }]);
            await v.CalistirAsync("delete from public.hizmet where id = any(@p0)", [new[] { HA, HB, HC, HD, HPanel, HChk }]);
        }
    }

    [VtFact]
    public async Task Kapsam_kok_ara_panel_ve_yapraklari_doner()
    {
        if (!_olgu.Baglandi(nameof(Kapsam_kok_ara_panel_ve_yapraklari_doner))) return;
        await using var d = await Dunya.KurAsync(_olgu.Gerekli());

        var kapsam = await d.Veri.ListeAsync(
            "select hizmet_id from public.fn_hizmet_paket_kapsam(@p0)", [d.HChk], o => o.GetInt32(0));
        Assert.Equal(new[] { d.HA, d.HB, d.HC, d.HPanel, d.HChk }.OrderBy(x => x), kapsam.OrderBy(x => x));

        // Paketsiz hizmetin kapsamı yalnız kendisidir.
        var tek = await d.Veri.ListeAsync(
            "select hizmet_id from public.fn_hizmet_paket_kapsam(@p0)", [d.HD], o => o.GetInt32(0));
        Assert.Equal([d.HD], tek);
    }

    [VtFact]
    public async Task Panel_satiri_panel_istemini_serbest_birakir_kapsam_disi_bekler()
    {
        if (!_olgu.Baglandi(nameof(Panel_satiri_panel_istemini_serbest_birakir_kapsam_disi_bekler))) return;
        await using var d = await Dunya.KurAsync(_olgu.Gerekli());

        var panelIstem = await d.BekleyenIstemAsync(d.Panel, d.TA, d.TB);
        var disIstem = await d.BekleyenIstemAsync(null, d.TD);

        // Ücrette yalnız PANEL satırı var (A/B'nin kendi hizmeti yok).
        await d.SatirEkleAsync(d.HPanel);
        await d.Veri.CalistirAsync("select public.fn_basvuru_istem_serbest_uygula(@p0)", [d.Belge]);

        Assert.Equal(1, await d.SerbestAsync(panelIstem));
        Assert.Equal(0, await d.SerbestAsync(disIstem));
    }

    [VtFact]
    public async Task Checkup_satiri_icindeki_panel_ve_tek_tetkik_istemlerini_serbest_birakir()
    {
        if (!_olgu.Baglandi(nameof(Checkup_satiri_icindeki_panel_ve_tek_tetkik_istemlerini_serbest_birakir))) return;
        await using var d = await Dunya.KurAsync(_olgu.Gerekli());

        var panelIstem = await d.BekleyenIstemAsync(d.Panel, d.TA, d.TB);
        var tekIstem = await d.BekleyenIstemAsync(null, d.TC);
        var disIstem = await d.BekleyenIstemAsync(null, d.TD);

        await d.SatirEkleAsync(d.HChk);
        await d.Veri.CalistirAsync("select public.fn_basvuru_istem_serbest_uygula(@p0)", [d.Belge]);

        Assert.Equal(1, await d.SerbestAsync(panelIstem));
        Assert.Equal(1, await d.SerbestAsync(tekIstem));
        Assert.Equal(0, await d.SerbestAsync(disIstem));
    }

    [VtFact]
    public async Task Yalniz_checkup_satiri_girilen_basvuruda_istem_paket_iceriginden_acilir()
    {
        if (!_olgu.Baglandi(nameof(Yalniz_checkup_satiri_girilen_basvuruda_istem_paket_iceriginden_acilir))) return;
        var veri = _olgu.Gerekli();
        await using var d = await Dunya.KurAsync(veri);
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        // Ücret TEK satır: check-up.
        await d.SatirEkleAsync(d.HChk);
        var istemId = await servis.BasvurudanIstemTamamlaAsync(d.Belge, Baglam(), CancellationToken.None);
        Assert.True(istemId > 0, "check-up satırından istem açılmalı");

        var satirlar = await veri.ListeAsync("""
            select s.tetkik_id, s.panel_id from public.lab_istem_satir s
              join public.lab_istem i on i.id = s.istem_id
             where i.belge_id = @p0
            """, [d.Belge], o => (Tetkik: o.GetInt32(0), Panel: o.IsDBNull(1) ? (int?)null : o.GetInt32(1)));

        // A, B (panelden) + C (tek); D kapsam dışı.
        Assert.Equal(new[] { d.TA, d.TB, d.TC }.OrderBy(x => x), satirlar.Select(s => s.Tetkik).OrderBy(x => x));
        Assert.All(satirlar.Where(s => s.Tetkik != d.TC), s => Assert.Equal(d.Panel, s.Panel));
        Assert.Null(satirlar.Single(s => s.Tetkik == d.TC).Panel);

        // İkinci kayıt aynı tetkikleri yeniden istemez.
        Assert.Equal(0, await servis.BasvurudanIstemTamamlaAsync(d.Belge, Baglam(), CancellationToken.None));
    }
}
