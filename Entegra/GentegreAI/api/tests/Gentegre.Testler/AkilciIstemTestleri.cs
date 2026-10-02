using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// AKILCI TEST İSTEMİ (873) — Bakanlık EK-2 kılavuzunun beş kuralı.
///
/// Testler kendi hasta/hekim/tetkik/kural satırlarını açar ve siler; kurum
/// kataloğuna dokunmaz. Kurallar SUNUCUDA: fonksiyon (branş / süre / basamak /
/// kapalı), servis (gerekçesiz uyarı 422 + kararla geçiş + kayıt), refleks
/// (sonuç eşiği → ikincil tetkik), reflektif (lab uzmanı istemi).
/// Veritabanı yoksa atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class AkilciIstemTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public AkilciIstemTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private static IstekBaglami Baglam(int kullanici, params string[] kodlar) => new()
    {
        KullaniciId = kullanici, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = 1, IzlemeNo = "test",
        Yetkiler = new YetkiSeti(1, kodlar.Select(k => new YetkiKaydi(k, 0, true, true, true, true)), []),
    };

    /// <summary>Test dünyası: iki bölüm (SKRS kodlu), hekim, hasta, başvuru, tetkik+hizmet, kural.</summary>
    private sealed class Dunya : IAsyncDisposable
    {
        public Gentegre.Veri.VeriKaynagi Veri = default!;
        public int IcHastDep, GozDep, HekimIc, HekimGoz, Hasta, Belge, Hizmet, Tetkik, HedefHizmet, HedefTetkik, Kural, RefleksKural;
        public string Sut = "T873" + Random.Shared.Next(1000, 9999);

        public static async Task<Dunya> KurAsync(Gentegre.Veri.VeriKaynagi veri)
        {
            var d = new Dunya { Veri = veri };
            // Bölümler KURUM KATALOĞUNDAN (departman.kod benzersiz, SKRS klinik kodu):
            //   157 İç Hastalıkları, 151 Göz - ikisi de kurulumda var (611/619).
            d.IcHastDep = await veri.TekDegerAsync<int>("select id from public.departman where kod = '157' limit 1", null);
            d.GozDep = await veri.TekDegerAsync<int>("select id from public.departman where kod = '151' limit 1", null);
            Assert.True(d.IcHastDep > 0 && d.GozDep > 0, "departman 157 / 151 kurulumda olmalı");
            d.HekimIc = await veri.TekDegerAsync<int>(
                "insert into public.taraf (unvan, personel, departman, sube_id) values ('T873 Dr İç', 1, @p0, 1) returning id", [d.IcHastDep]);
            d.HekimGoz = await veri.TekDegerAsync<int>(
                "insert into public.taraf (unvan, personel, departman, sube_id) values ('T873 Dr Göz', 1, @p0, 1) returning id", [d.GozDep]);
            d.Hasta = await veri.TekDegerAsync<int>(
                "insert into public.taraf (unvan, hasta, sube_id) values ('T873 Hasta', 1, 1) returning id", null);
            d.Belge = await veri.TekDegerAsync<int>("""
                insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi, ekleyen)
                values (19, 30, @p0, 1, now(), 1) returning id
                """, [d.Hasta]);
            await veri.CalistirAsync("""
                insert into public.belge_basvuru (id, bolum_id, personel_id, hasta_id)
                values (@p0, @p1, @p2, @p3)
                """, [d.Belge, d.IcHastDep, d.HekimIc, d.Hasta]);
            d.Hizmet = await veri.TekDegerAsync<int>(
                "insert into public.hizmet (kod, ad, tur, sube_id) values (@p0, 'T873 Test', 2, 1) returning id", [d.Sut]);
            d.Tetkik = await veri.TekDegerAsync<int>("""
                insert into public.lab_tetkik (kod, ad, hizmet_id, bolum, tur, numune_tipi, tup_tipi, birim, durum)
                values (@p0, 'T873 Test', @p1, 1, 1, 1, 1, 'mg/dL', 0) returning id
                """, ["T873A", d.Hizmet]);
            d.HedefHizmet = await veri.TekDegerAsync<int>(
                "insert into public.hizmet (kod, ad, tur, sube_id) values (@p0, 'T873 Hedef', 2, 1) returning id", [d.Sut + "H"]);
            d.HedefTetkik = await veri.TekDegerAsync<int>("""
                insert into public.lab_tetkik (kod, ad, hizmet_id, bolum, tur, numune_tipi, tup_tipi, birim, durum)
                values (@p0, 'T873 Hedef', @p1, 1, 1, 1, 1, 'mg/dL', 0) returning id
                """, ["T873B", d.HedefHizmet]);
            // Kural: 30 gün, yalnız İç Hastalıkları (157), 2.-3. basamak.
            d.Kural = await veri.TekDegerAsync<int>("""
                insert into public.lab_akilci_kural (sut_kodu, ad, hizmet_id, sure_gun, brans_kodlari, tum_branslar, basamak, kaynak_surum)
                values (@p0, 'T873 Test', @p1, 30, '157', 0, 2, 'test') returning id
                """, [d.Sut, d.Hizmet]);
            d.RefleksKural = await veri.TekDegerAsync<int>("""
                insert into public.lab_refleks_kural (tetkik_id, kosul, esik, hedef_tetkik_id, aciklama)
                values (@p0, '>', 100, @p1, 'T873 refleks') returning id
                """, [d.Tetkik, d.HedefTetkik]);
            return d;
        }

        public async ValueTask DisposeAsync()
        {
            var v = Veri;
            await v.CalistirAsync("delete from public.lab_akilci_gerekce where hasta_id = @p0", [Hasta]);
            await v.CalistirAsync("delete from public.lab_sonuc where istem_satir_id in (select s.id from public.lab_istem_satir s join public.lab_istem i on i.id = s.istem_id where i.taraf_id = @p0)", [Hasta]);
            await v.CalistirAsync("delete from public.lab_istem_satir where istem_id in (select id from public.lab_istem where taraf_id = @p0)", [Hasta]);
            await v.CalistirAsync("delete from public.lab_numune where istem_id in (select id from public.lab_istem where taraf_id = @p0)", [Hasta]);
            await v.CalistirAsync("delete from public.lab_istem where taraf_id = @p0", [Hasta]);
            await v.CalistirAsync("delete from public.lab_refleks_kural where id = @p0", [RefleksKural]);
            await v.CalistirAsync("delete from public.lab_akilci_kural where id = @p0", [Kural]);
            await v.CalistirAsync("delete from public.lab_tetkik where id in (@p0, @p1)", [Tetkik, HedefTetkik]);
            await v.CalistirAsync("delete from public.hizmet where id in (@p0, @p1)", [Hizmet, HedefHizmet]);
            await v.CalistirAsync("delete from public.belge_basvuru where id = @p0", [Belge]);
            await v.CalistirAsync("delete from public.belge where id = @p0", [Belge]);
            await v.CalistirAsync("delete from public.taraf where id in (@p0, @p1, @p2)", [HekimIc, HekimGoz, Hasta]);
        }
    }

    private sealed record KontrolSatiri(int TetkikId, string Kural, string Seviye, string Mesaj);

    private static async Task<List<KontrolSatiri>> KontrolAsync(Gentegre.Veri.VeriKaynagi veri, int hasta, int? hekim, int sube, params int[] tetkikler)
        => await veri.ListeAsync(
            "select tetkik_id, kural, seviye, mesaj from public.fn_lab_akilci_kontrol(@p0, @p1, @p2, @p3)",
            [hasta, hekim, sube, tetkikler],
            o => new KontrolSatiri(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3)));

    [VtFact]
    public async Task Brans_disi_hekim_UYARI_alir_yetkili_brans_temiz_gecer()
    {
        if (!_olgu.Baglandi(nameof(Brans_disi_hekim_UYARI_alir_yetkili_brans_temiz_gecer))) return;
        await using var d = await Dunya.KurAsync(_olgu.Gerekli());
        var goz = await KontrolAsync(d.Veri, d.Hasta, d.HekimGoz, 1, d.Tetkik);
        Assert.Single(goz);
        Assert.Equal("brans", goz[0].Kural);
        Assert.Equal("uyari", goz[0].Seviye);
        Assert.Contains("İç Hastalıkları", goz[0].Mesaj);

        var ic = await KontrolAsync(d.Veri, d.Hasta, d.HekimIc, 1, d.Tetkik);
        Assert.Empty(ic);                                   // yetkili branş, sonuç yok: uyarı yok
        Assert.Empty(await KontrolAsync(d.Veri, d.Hasta, null, 1, d.Tetkik));   // banko: branş denetlenmez
    }

    [VtFact]
    public async Task Sure_dolmadan_tekrar_UYARI_son_sonuclarla_doner()
    {
        if (!_olgu.Baglandi(nameof(Sure_dolmadan_tekrar_UYARI_son_sonuclarla_doner))) return;
        var veri = _olgu.Gerekli();
        await using var d = await Dunya.KurAsync(veri);
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);
        var baglam = Baglam(d.HekimIc, "lab", "lab.sonuc");

        // 1. istem: yetkili hekim, uyarı yok.
        var istem1 = await servis.IstemAcAsync(d.Belge, [new(d.Tetkik, null)], 1, "", "", baglam, CancellationToken.None);
        Assert.True(istem1 > 0);

        // 2. istem aynı gün: açık istem var → süre uyarısı, gerekçesiz 422 AKILCI_UYARI.
        var h = await Assert.ThrowsAsync<GentegreHatasi>(() =>
            servis.IstemAcAsync(d.Belge, [new(d.Tetkik, null)], 1, "", "", baglam, CancellationToken.None));
        Assert.Equal(HataKodu.IsKurali, h.Kod);
        Assert.Contains("emin misiniz", h.Message);
        Assert.Contains("AKILCI_UYARI", System.Text.Json.JsonSerializer.Serialize(h.Engel));

        // Uydurma gerekçe kodu geçmez.
        var d2 = await Assert.ThrowsAsync<GentegreHatasi>(() =>
            servis.IstemAcAsync(d.Belge, [new(d.Tetkik, null)], 1, "", "", baglam, CancellationToken.None,
                                akilci: [new LabServisi.AkilciKarar(d.Tetkik, "sure", 99)]));
        Assert.Equal(HataKodu.Dogrulama, d2.Kod);

        // SKRS gerekçesi (2 = tedavinin takibi) ile geçer; karar kayda düşer.
        var istem2 = await servis.IstemAcAsync(d.Belge, [new(d.Tetkik, null)], 1, "", "", baglam, CancellationToken.None,
                                               akilci: [new LabServisi.AkilciKarar(d.Tetkik, "sure", 2)]);
        Assert.True(istem2 > istem1);
        var kayit = await veri.TekAsync(
            "select kural_turu, karar, gerekce_kod, istem_id from public.lab_akilci_gerekce where hasta_id = @p0 order by id desc limit 1", [d.Hasta],
            o => new { Kural = o.GetString(0), Karar = o.GetString(1), Kod = o.GetInt16(2), Istem = o.GetInt32(3) });
        Assert.NotNull(kayit);
        Assert.Equal(("sure", "devam", (short)2, istem2), (kayit!.Kural, kayit.Karar, kayit.Kod, kayit.Istem));

        // Vazgeçme kaydı (§4.6).
        await servis.AkilciVazgecAsync(d.Hasta, d.HekimIc, [new LabServisi.AkilciKarar(d.Tetkik, "sure", 0, "hekim vazgeçti")], baglam, CancellationToken.None);
        var iptal = await veri.TekDegerAsync<long>(
            "select count(*) from public.lab_akilci_gerekce where hasta_id = @p0 and karar = 'iptal'", [d.Hasta]);
        Assert.Equal(1L, iptal);
    }

    [VtFact]
    public async Task Basamak_3_testi_2_basamak_subede_ENGEL_kapali_test_ENGEL()
    {
        if (!_olgu.Baglandi(nameof(Basamak_3_testi_2_basamak_subede_ENGEL_kapali_test_ENGEL))) return;
        var veri = _olgu.Gerekli();
        await using var d = await Dunya.KurAsync(veri);
        var eskiBasamak = await veri.TekDegerAsync<short>("select basamak from public.sube where id = 1");
        try
        {
            await veri.CalistirAsync("update public.sube set basamak = 2 where id = 1");
            await veri.CalistirAsync("update public.lab_akilci_kural set basamak = 3 where id = @p0", [d.Kural]);
            var s = await KontrolAsync(veri, d.Hasta, d.HekimIc, 1, d.Tetkik);
            Assert.Single(s);
            Assert.Equal(("basamak", "engel"), (s[0].Kural, s[0].Seviye));
            Assert.Contains("üçüncü basamak", s[0].Mesaj);

            var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);
            var h = await Assert.ThrowsAsync<GentegreHatasi>(() =>
                servis.IstemAcAsync(d.Belge, [new(d.Tetkik, null)], 1, "", "", Baglam(d.HekimIc, "lab"), CancellationToken.None));
            Assert.Contains("AKILCI_ENGEL", System.Text.Json.JsonSerializer.Serialize(h.Engel));

            // 3. basamak şube: engel yok.
            await veri.CalistirAsync("update public.sube set basamak = 3 where id = 1");
            Assert.Empty(await KontrolAsync(veri, d.Hasta, d.HekimIc, 1, d.Tetkik));

            // Kapalı test: basamaktan bağımsız engel.
            await veri.CalistirAsync("update public.lab_akilci_kural set kapali = 1 where id = @p0", [d.Kural]);
            var k = await KontrolAsync(veri, d.Hasta, d.HekimIc, 1, d.Tetkik);
            Assert.Equal(("kapali", "engel"), (k[0].Kural, k[0].Seviye));
        }
        finally { await veri.CalistirAsync("update public.sube set basamak = @p0 where id = 1", [eskiBasamak]); }
    }

    [VtFact]
    public async Task Refleks_kural_esik_asilinca_hedef_tetkigi_ayni_isteme_ekler()
    {
        if (!_olgu.Baglandi(nameof(Refleks_kural_esik_asilinca_hedef_tetkigi_ayni_isteme_ekler))) return;
        var veri = _olgu.Gerekli();
        await using var d = await Dunya.KurAsync(veri);
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);
        var baglam = Baglam(d.HekimIc, "lab", "lab.sonuc");
        var istem = await servis.IstemAcAsync(d.Belge, [new(d.Tetkik, null)], 1, "", "", baglam, CancellationToken.None);
        var satir = await veri.TekDegerAsync<int>(
            "select id from public.lab_istem_satir where istem_id = @p0 and tetkik_id = @p1", [istem, d.Tetkik]);

        // Eşik altı: hedef eklenmez.
        var s1 = await servis.SonucYazAsync(new LabServisi.SonucIstegi(satir, "50", null, null, null), null, null, baglam, CancellationToken.None);
        Assert.DoesNotContain("Refleks", s1.Mesaj);
        Assert.Equal(1L, await veri.TekDegerAsync<long>("select count(*) from public.lab_istem_satir where istem_id = @p0", [istem]));

        // Eşik üstü (>100): hedef tetkik aynı isteme, aynı numuneye, kaynak_turu 1 ile eklenir; bir kez.
        var s2 = await servis.SonucYazAsync(new LabServisi.SonucIstegi(satir, "150", null, null, null), null, null, baglam, CancellationToken.None);
        Assert.Contains("Refleks test eklendi", s2.Mesaj);
        var eklenen = await veri.TekAsync(
            "select kaynak_turu, numune_id from public.lab_istem_satir where istem_id = @p0 and tetkik_id = @p1", [istem, d.HedefTetkik],
            o => new { Kaynak = o.GetInt16(0), Numune = o.IsDBNull(1) ? (int?)null : o.GetInt32(1) });
        Assert.NotNull(eklenen);
        Assert.Equal(1, eklenen!.Kaynak);
        Assert.NotNull(eklenen.Numune);
        await servis.SonucYazAsync(new LabServisi.SonucIstegi(satir, "160", null, null, null), null, null, baglam, CancellationToken.None);
        Assert.Equal(2L, await veri.TekDegerAsync<long>("select count(*) from public.lab_istem_satir where istem_id = @p0", [istem]));
        Assert.Equal(1L, await veri.TekDegerAsync<long>(
            "select count(*) from public.lab_akilci_gerekce where hasta_id = @p0 and kural_turu = 'refleks'", [d.Hasta]));
    }

    [VtFact]
    public async Task Reflektif_istem_lab_uzmani_satiri_kaynak_2_ile_ekler()
    {
        if (!_olgu.Baglandi(nameof(Reflektif_istem_lab_uzmani_satiri_kaynak_2_ile_ekler))) return;
        var veri = _olgu.Gerekli();
        await using var d = await Dunya.KurAsync(veri);
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);
        var istem = await servis.IstemAcAsync(d.Belge, [new(d.Tetkik, null)], 1, "", "", Baglam(d.HekimIc, "lab"), CancellationToken.None);

        var eklenen = await servis.ReflektifEkleAsync(istem, [d.HedefTetkik, d.Tetkik], "ferritin düşük, demir paneli",
                                                      Baglam(d.HekimGoz, "lab", "lab.onay"), CancellationToken.None);
        Assert.Equal(["T873 Hedef"], eklenen);        // mevcut tetkik ikinci kez eklenmez
        var satir = await veri.TekAsync(
            "select kaynak_turu, aciklama from public.lab_istem_satir where istem_id = @p0 and tetkik_id = @p1", [istem, d.HedefTetkik],
            o => new { Kaynak = o.GetInt16(0), Aciklama = o.GetString(1) });
        Assert.Equal(2, satir!.Kaynak);
        Assert.StartsWith("Laboratuvar Uzmanı Reflektif İstemi", satir.Aciklama);
        Assert.Equal(1L, await veri.TekDegerAsync<long>(
            "select count(*) from public.lab_akilci_gerekce where hasta_id = @p0 and kural_turu = 'reflektif'", [d.Hasta]));
    }
}
