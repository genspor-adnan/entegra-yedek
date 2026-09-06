using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// GENETİK KURALLARI (439) — ACMG sınıflaması, sonuç özeti, yeniden
/// değerlendirme.
///
/// Sınıflama kuralı ACMG/AMP 2015 Tablo 5'tir ve doğrudan hasta tanısını
/// belirler: bir "olası patojenik"in VUS'a düşmesi tanıyı kaldırır, tersi
/// olmayan bir tanı koyar. Kural SQL'de yaşıyor; okumakla değil
/// çalıştırmakla doğrulanır.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class GenetikTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public GenetikTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private static async Task<short> SinifAsync(VeriKaynagi veri, params string[] kod)
        => await veri.TekDegerAsync<short>(
            "select public.fn_lab_acmg_sinif(@p0)", [kod]);

    // ------------------------------------------------------------- ACMG

    [Fact]
    public async Task ACMG_patojenik_kombinasyonlari()
    {
        if (!_olgu.Baglandi(nameof(ACMG_patojenik_kombinasyonlari))) return;
        var veri = _olgu.Gerekli();

        // PVS1 + PS1  → patojenik (Tablo 5, kural a)
        Assert.Equal(5, await SinifAsync(veri, "PVS1", "PS1"));
        // İki güçlü kanıt → patojenik (kural b)
        Assert.Equal(5, await SinifAsync(veri, "PS1", "PS4"));
        // PS + 3 orta → patojenik (kural c)
        Assert.Equal(5, await SinifAsync(veri, "PS4", "PM1", "PM2", "PM5"));
        // Mockup'taki gerçek örnek: MYBPC3 c.1504C>T
        Assert.Equal(5, await SinifAsync(veri, "PS4", "PP1_Strong", "PM2", "PP3", "PP5"));
    }

    [Fact]
    public async Task ACMG_guc_eki_KODUN_KENDI_SINIFINI_EZER()
    {
        if (!_olgu.Baglandi(nameof(ACMG_guc_eki_KODUN_KENDI_SINIFINI_EZER))) return;
        var veri = _olgu.Gerekli();

        // PP1 normalde DESTEKLEYİCİ; PP1_Strong ClinGen pratiğinde GÜÇLÜ
        //   sayılır. Ek yok sayılsaydı bu varyant VUS'a düşerdi - yani
        //   hastanın tanısı kaybolurdu.
        Assert.Equal(5, await SinifAsync(veri, "PS4", "PP1_Strong"));
        Assert.Equal(3, await SinifAsync(veri, "PS4", "PP1"));

        // PM2_Supporting: orta değil destekleyici sayılır.
        Assert.Equal(3, await SinifAsync(veri, "PM2_Supporting", "PP3"));
        Assert.Equal(4, await SinifAsync(veri, "PM2", "PM1", "PM5"));
    }

    [Fact]
    public async Task ACMG_benign_ve_CELISKILI_kanit()
    {
        if (!_olgu.Baglandi(nameof(ACMG_benign_ve_CELISKILI_kanit))) return;
        var veri = _olgu.Gerekli();

        Assert.Equal(1, await SinifAsync(veri, "BA1"));                // tek başına
        Assert.Equal(1, await SinifAsync(veri, "BS1", "BS2"));
        Assert.Equal(2, await SinifAsync(veri, "BS1", "BP4"));
        Assert.Equal(2, await SinifAsync(veri, "BP4", "BP7"));

        // ÇELİŞKİLİ KANIT VUS'TUR: hem patojenik hem benign ölçüt sağlanıyorsa
        //   birini seçmek, kanıtın yarısını görmezden gelmektir.
        Assert.Equal(3, await SinifAsync(veri, "PS1", "PM2", "BS1", "BP4"));

        // Kanıt yoksa da VUS - "kanıt yok" benign demek değildir.
        Assert.Equal(3, await SinifAsync(veri));
    }

    // ------------------------------------------------- vaka / özet / banka

    private static async Task<(int HastaId, int IstemId, int SatirId, int VakaId)>
        VakaKurAsync(VeriKaynagi veri)
    {
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GEN-KARDIYO'");
        var panelId = await veri.TekDegerAsync<int>(
            "select id from public.lab_genetik_panel where kod = 'PNL-KARDIYO'");

        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, ad, soyad, hasta, sube_id)
            values ('TEST GENETIK HASTA', 'TEST', 'GENETIK', 1,
                    (select min(id) from public.sube))
            returning id
            """);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, istem_no, bolum, durum)
            values (@p0, 'TEST-GEN', 3, 1) returning id
            """, [hastaId]);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, kod, ad, durum, sira)
            values (@p0, @p1, 'GEN-KARDIYO', 'Kardiyo NGS', 2, 10) returning id
            """, [istemId, tetkikId]);
        var vakaId = await veri.TekDegerAsync<int>("""
            insert into public.lab_genetik_vaka
                   (vaka_no, istem_satir_id, istem_id, tetkik_id, hasta_id, panel_id,
                    durum, tesadufi_bulgu, onam_tarihi)
            values ('TEST-GEN-' || nextval('lab_genetik_vaka_id_seq')::text,
                    @p0, @p1, @p2, @p3, @p4, 4, 2, now())
            returning id
            """, [satirId, istemId, tetkikId, hastaId, panelId]);

        return (hastaId, istemId, satirId, vakaId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int hastaId, int istemId,
                                           int vakaId)
    {
        await veri.CalistirAsync("delete from public.lab_varyant where vaka_id = @p0",
                                 [vakaId]);
        await veri.CalistirAsync("delete from public.lab_genetik_vaka where id = @p0",
                                 [vakaId]);
        await veri.CalistirAsync("delete from public.lab_istem_satir where istem_id = @p0",
                                 [istemId]);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId]);
        await veri.CalistirAsync("delete from public.taraf where id = @p0", [hastaId]);
    }

    private static async Task<int> VaryantAsync(VeriKaynagi veri, int vakaId, string gen,
                                                string hgvs, string[] acmg,
                                                bool ikincil = false)
        => await veri.TekDegerAsync<int>("""
            insert into public.lab_varyant
                   (vaka_id, gen_sembol, hgvs_c, acmg_kriterler, ikincil_bulgu)
            values (@p0, @p1, @p2, @p3, @p4) returning id
            """, [vakaId, gen, hgvs, acmg, (short)(ikincil ? 1 : 0)]);

    [Fact]
    public async Task Varyant_sinifi_KANITTAN_turetilir_ve_raporlama_varsayilani_kurulur()
    {
        if (!_olgu.Baglandi(
                nameof(Varyant_sinifi_KANITTAN_turetilir_ve_raporlama_varsayilani_kurulur)))
            return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, vakaId) = await VakaKurAsync(veri);
        try
        {
            var patojenik = await VaryantAsync(veri, vakaId, "MYBPC3", "c.1504C>T",
                ["PS4", "PP1_Strong", "PM2", "PP3", "PP5"]);
            var benign = await VaryantAsync(veri, vakaId, "TTN", "c.58784G>A",
                ["BS1", "BP4"]);

            var p = await veri.TekAsync(
                "select sinif, raporla from public.lab_varyant where id = @p0",
                [patojenik], o => new { Sinif = o.GetInt16(0), Raporla = o.GetInt16(1) });
            var b = await veri.TekAsync(
                "select sinif, raporla from public.lab_varyant where id = @p0",
                [benign], o => new { Sinif = o.GetInt16(0), Raporla = o.GetInt16(1) });

            Assert.Equal(5, p!.Sinif);
            Assert.Equal(1, p.Raporla);
            // BENIGN RAPORLANMAZ: hekimi ilgilendirmeyen 1.284 varyantı basmak,
            //   asıl bulgunun görülmemesine yol açar.
            Assert.Equal(2, b!.Sinif);
            Assert.Equal(0, b.Raporla);

            // Kanıt değişince sınıf KENDİLİĞİNDEN güncellenir: 1 güçlü +
            //   1 orta kanıt "olası patojenik"tir (4), patojenik değil -
            //   tanı koydurmak için ikinci bir güçlü kanıt gerekir.
            await veri.CalistirAsync("""
                update public.lab_varyant set acmg_kriterler = @p1 where id = @p0
                """, [benign, new[] { "PS1", "PM2" }]);
            Assert.Equal(4, await veri.TekDegerAsync<short>(
                "select sinif from public.lab_varyant where id = @p0", [benign]));
        }
        finally { await TemizleAsync(veri, hastaId, istemId, vakaId); }
    }

    [Fact]
    public async Task Uzman_sinifi_ezerse_kural_UZERINE_YAZMAZ()
    {
        if (!_olgu.Baglandi(nameof(Uzman_sinifi_ezerse_kural_UZERINE_YAZMAZ))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, vakaId) = await VakaKurAsync(veri);
        try
        {
            var id = await VaryantAsync(veri, vakaId, "MYH7", "c.2389G>A",
                ["PM2_Supporting", "PP3"]);
            Assert.Equal(3, await veri.TekDegerAsync<short>(
                "select sinif from public.lab_varyant where id = @p0", [id]));

            // Uzman aile segregasyonuna dayanarak 4'e çekti.
            await veri.CalistirAsync("""
                update public.lab_varyant
                   set sinif = 4, sinif_elle = 1, sinif_neden = 'Aile segregasyonu'
                 where id = @p0
                """, [id]);

            // Kanıt listesi sonradan değişse bile uzman kararı korunur.
            await veri.CalistirAsync("""
                update public.lab_varyant set acmg_kriterler = @p1 where id = @p0
                """, [id, new[] { "BP4" }]);

            Assert.Equal(4, await veri.TekDegerAsync<short>(
                "select sinif from public.lab_varyant where id = @p0", [id]));
        }
        finally { await TemizleAsync(veri, hastaId, istemId, vakaId); }
    }

    [Fact]
    public async Task Vaka_ozeti_POZITIF_VUS_NEGATIF_ayrimini_yapar()
    {
        if (!_olgu.Baglandi(nameof(Vaka_ozeti_POZITIF_VUS_NEGATIF_ayrimini_yapar))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, vakaId) = await VakaKurAsync(veri);
        try
        {
            // Varyant yok → negatif.
            Assert.StartsWith("NEGATİF", await veri.TekDegerAsync<string>(
                "select public.fn_lab_genetik_ozet(@p0)", [vakaId]));

            // Yalnız VUS → "belirsiz": VUS'u pozitif saymak, hastaya olmayan
            //   bir tanı koymaktır.
            var vus = await VaryantAsync(veri, vakaId, "MYH7", "c.2389G>A",
                ["PM2_Supporting", "PP3"]);
            Assert.StartsWith("BELİRSİZ", await veri.TekDegerAsync<string>(
                "select public.fn_lab_genetik_ozet(@p0)", [vakaId]));

            // Patojenik eklenince pozitif.
            await VaryantAsync(veri, vakaId, "MYBPC3", "c.1504C>T",
                ["PS4", "PP1_Strong", "PM2", "PP3"]);
            var ozet = await veri.TekDegerAsync<string>(
                "select public.fn_lab_genetik_ozet(@p0)", [vakaId]);
            Assert.StartsWith("POZİTİF", ozet);
            Assert.Contains("MYBPC3", ozet);

            // Raporlanmayan varyant özete GİRMEZ.
            await veri.CalistirAsync(
                "update public.lab_varyant set raporla = 0 where id = @p0", [vus]);
            Assert.DoesNotContain("MYH7", await veri.TekDegerAsync<string>(
                "select public.fn_lab_genetik_ozet(@p0)", [vakaId]));
        }
        finally { await TemizleAsync(veri, hastaId, istemId, vakaId); }
    }

    [Fact]
    public async Task Ikincil_bulgu_hasta_ISTEMIYORSA_raporlanmaz()
    {
        if (!_olgu.Baglandi(nameof(Ikincil_bulgu_hasta_ISTEMIYORSA_raporlanmaz))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, vakaId) = await VakaKurAsync(veri);
        try
        {
            // Tesadüfi bulgu: patojenik olsa bile varsayılan olarak kapalı.
            var id = await VaryantAsync(veri, vakaId, "BRCA1", "c.5266dupC",
                ["PVS1", "PS4", "PM2"], ikincil: true);

            var v = await veri.TekAsync(
                "select sinif, raporla from public.lab_varyant where id = @p0",
                [id], o => new { Sinif = o.GetInt16(0), Raporla = o.GetInt16(1) });

            Assert.Equal(5, v!.Sinif);
            Assert.Equal(0, v.Raporla);
        }
        finally { await TemizleAsync(veri, hastaId, istemId, vakaId); }
    }

    [Fact]
    public async Task Bilgi_bankasi_sinifi_degisince_YENIDEN_DEGERLENDIRME_listesine_duser()
    {
        if (!_olgu.Baglandi(
                nameof(Bilgi_bankasi_sinifi_degisince_YENIDEN_DEGERLENDIRME_listesine_duser)))
            return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, vakaId) = await VakaKurAsync(veri);
        const string hgvs = "c.9999TEST>A";
        try
        {
            await VaryantAsync(veri, vakaId, "TESTGEN", hgvs, ["PM2_Supporting", "PP3"]);
            await veri.CalistirAsync(
                "update public.lab_genetik_vaka set durum = 7, onay_zamani = now() where id = @p0",
                [vakaId]);

            // Banka aynı sınıfı taşırken liste BOŞ.
            await veri.CalistirAsync("""
                insert into public.lab_varyant_bilgi (gen_sembol, hgvs_c, sinif)
                values ('TESTGEN', @p0, 3)
                on conflict (upper(gen_sembol), hgvs_c) do update set sinif = 3
                """, [hgvs]);
            Assert.Equal(0, await veri.TekDegerAsync<long>("""
                select count(*) from public.v_lab_varyant_yeniden where vaka_id = @p0
                """, [vakaId]));

            // VUS sonradan patojenik oldu: hasta yıllar önce "belirsiz" rapor
            //   almıştı - bu vaka yeniden değerlendirilmeli.
            await veri.CalistirAsync("""
                update public.lab_varyant_bilgi set sinif = 5, surum = surum + 1
                 where upper(gen_sembol) = 'TESTGEN' and hgvs_c = @p0
                """, [hgvs]);

            var satir = await veri.TekAsync("""
                select rapor_sinif, guncel_sinif from public.v_lab_varyant_yeniden
                 where vaka_id = @p0
                """, [vakaId],
                o => new { Rapor = o.GetInt16(0), Guncel = o.GetInt16(1) });

            Assert.NotNull(satir);
            Assert.Equal(3, satir!.Rapor);
            Assert.Equal(5, satir.Guncel);
        }
        finally
        {
            await veri.CalistirAsync("""
                delete from public.lab_varyant_bilgi
                 where upper(gen_sembol) = 'TESTGEN' and hgvs_c = @p0
                """, [hgvs]);
            await TemizleAsync(veri, hastaId, istemId, vakaId);
        }
    }
}
