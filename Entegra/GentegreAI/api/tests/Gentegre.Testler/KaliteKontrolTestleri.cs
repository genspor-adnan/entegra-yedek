using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// KALİTE KONTROL KURALLARI (442) — Westgard ve oto-onay bağı.
///
/// Kalite kontrolün amacı sistematik hatayı (kaymayı) yakalamaktır: rastgele
/// hata gürültü yapar ve fark edilir, kayma sessizce BÜTÜN hastaları etkiler.
/// Kural motoru SQL'de; okumakla değil çalıştırmakla doğrulanır.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class KaliteKontrolTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public KaliteKontrolTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private static async Task<(int LotId, int HedefId, int TetkikId)> KurAsync(
        VeriKaynagi veri, string kod)
    {
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU'");

        var lotId = await veri.TekDegerAsync<int>("""
            insert into public.lab_kk_lot (kod, materyal_ad, lot, seviye_sayisi, durum)
            values (@p0, 'TEST KONTROL', 'T-001', 2, 0)
            returning id
            """, [kod]);

        // Hedef 100, SD 5: z hesabı okunaklı olsun (105 = +1 SD).
        var hedefId = await veri.TekDegerAsync<int>("""
            insert into public.lab_kk_hedef
                   (lot_id, tetkik_id, seviye, uretici_hedef, uretici_sd, esik_n)
            values (@p0, @p1, 1, 100, 5, 1000)
            returning id
            """, [lotId, tetkikId]);

        return (lotId, hedefId, tetkikId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int lotId)
    {
        await veri.CalistirAsync("delete from public.lab_kk_olcum where lot_id = @p0",
                                 [lotId]);
        await veri.CalistirAsync("delete from public.lab_kk_hedef where lot_id = @p0",
                                 [lotId]);
        await veri.CalistirAsync("delete from public.lab_kk_lot where id = @p0", [lotId]);
    }

    /// <summary>Ölçüm ekler ve Westgard'ı çalıştırır; (durum, ihlaller) döner.</summary>
    private static async Task<(long Id, short Durum, string[] Ihlaller)> OlcumAsync(
        VeriKaynagi veri, int lotId, int hedefId, int tetkikId, decimal deger,
        int dakikaOnce, short seviye = 1)
    {
        var id = await veri.TekDegerAsync<long>("""
            insert into public.lab_kk_olcum
                   (hedef_id, lot_id, tetkik_id, seviye, olcum_zamani, deger, z, hedef, sd)
            values (@p0, @p1, @p2, @p3, now() - make_interval(mins => @p4),
                    @p5, round((@p5 - 100) / 5.0, 3), 100, 5)
            returning id
            """, [hedefId, lotId, tetkikId, seviye, dakikaOnce, deger]);

        var s = await veri.TekAsync(
            "select durum, ihlaller from public.fn_lab_westgard(@p0)", [id],
            o => new { Durum = o.GetInt16(0), Ihlaller = o.GetFieldValue<string[]>(1) });
        return (id, s!.Durum, s.Ihlaller);
    }

    [Fact]
    public async Task Westgard_1_3s_RET_uretir()
    {
        if (!_olgu.Baglandi(nameof(Westgard_1_3s_RET_uretir))) return;
        var veri = _olgu.Gerekli();
        var (lotId, hedefId, tetkikId) = await KurAsync(veri, "TEST-KK-13S");
        try
        {
            // 116 = +3,2 SD → 1_3s (mockuptaki gerçek örnek).
            var (_, durum, ihlaller) = await OlcumAsync(veri, lotId, hedefId, tetkikId,
                                                        116m, 0);
            Assert.Contains("1_3s", ihlaller);
            Assert.Equal(3, durum);          // ret
        }
        finally { await TemizleAsync(veri, lotId); }
    }

    [Fact]
    public async Task Westgard_2_2s_AYNI_YONDE_ardisik_iki_olcumde_tetiklenir()
    {
        if (!_olgu.Baglandi(nameof(Westgard_2_2s_AYNI_YONDE_ardisik_iki_olcumde_tetiklenir)))
            return;
        var veri = _olgu.Gerekli();
        var (lotId, hedefId, tetkikId) = await KurAsync(veri, "TEST-KK-22S");
        try
        {
            // İlk ölçüm +2,4 SD: tek başına yalnız uyarı (1_2s).
            var ilk = await OlcumAsync(veri, lotId, hedefId, tetkikId, 112m, 120);
            Assert.Contains("1_2s", ilk.Ihlaller);
            Assert.DoesNotContain("2_2s", ilk.Ihlaller);
            Assert.Equal(2, ilk.Durum);

            // İkincisi de aynı yönde ±2 SD dışında → sistematik hata, RET.
            var ikinci = await OlcumAsync(veri, lotId, hedefId, tetkikId, 111m, 60);
            Assert.Contains("2_2s", ikinci.Ihlaller);
            Assert.Equal(3, ikinci.Durum);

            // TERS YÖNDE olsaydı 2_2s tetiklenmezdi: kayma değil saçılmadır.
            var ters = await OlcumAsync(veri, lotId, hedefId, tetkikId, 89m, 30);
            Assert.DoesNotContain("2_2s", ters.Ihlaller);
        }
        finally { await TemizleAsync(veri, lotId); }
    }

    [Fact]
    public async Task Westgard_4_1s_kaymayi_UYARI_olarak_yakalar()
    {
        if (!_olgu.Baglandi(nameof(Westgard_4_1s_kaymayi_UYARI_olarak_yakalar))) return;
        var veri = _olgu.Gerekli();
        var (lotId, hedefId, tetkikId) = await KurAsync(veri, "TEST-KK-41S");
        try
        {
            // Dördü de +1 SD ile +2 SD arasında: tek tek bakınca hepsi
            //   "kabul", ama dördü aynı yönde - kayma başlıyor.
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 107m, 240);
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 108m, 180);
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 107m, 120);
            var son = await OlcumAsync(veri, lotId, hedefId, tetkikId, 108m, 60);

            Assert.Contains("4_1s", son.Ihlaller);
            // Varsayılan sette 4_1s UYARI: her kaymada laboratuvarı durdurmak
            //   yerine izlemeye alır.
            Assert.Equal(2, son.Durum);
        }
        finally { await TemizleAsync(veri, lotId); }
    }

    [Fact]
    public async Task Westgard_R_4s_AYNI_CALISMADA_iki_seviye_arasinda_bakar()
    {
        if (!_olgu.Baglandi(nameof(Westgard_R_4s_AYNI_CALISMADA_iki_seviye_arasinda_bakar)))
            return;
        var veri = _olgu.Gerekli();
        var (lotId, hedefId, tetkikId) = await KurAsync(veri, "TEST-KK-R4S");
        try
        {
            var hedef2 = await veri.TekDegerAsync<int>("""
                insert into public.lab_kk_hedef
                       (lot_id, tetkik_id, seviye, uretici_hedef, uretici_sd, esik_n)
                values (@p0, @p1, 2, 100, 5, 1000)
                returning id
                """, [lotId, tetkikId]);

            // Seviye 1: +2,2 SD · Seviye 2 (aynı çalışma): −2,2 SD → açıklık
            //   4,4 SD > 4 → rastgele hata, RET.
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 111m, 5);
            var (_, durum, ihlaller) = await OlcumAsync(veri, lotId, hedef2, tetkikId,
                                                        89m, 4, seviye: 2);

            Assert.Contains("R_4s", ihlaller);
            Assert.Equal(3, durum);
        }
        finally { await TemizleAsync(veri, lotId); }
    }

    [Fact]
    public async Task KK_RET_iken_oto_onay_KAPANIR()
    {
        if (!_olgu.Baglandi(nameof(KK_RET_iken_oto_onay_KAPANIR))) return;
        var veri = _olgu.Gerekli();
        var (lotId, hedefId, tetkikId) = await KurAsync(veri, "TEST-KK-OTO");
        try
        {
            // Ölçüm yokken KK "geçerli" sayılır: kalite kontrolü tanımlanmamış
            //   bir testi çalıştırmamak ayrı bir karardır, burada zorlanmaz.
            Assert.True(await veri.TekDegerAsync<bool>(
                "select public.fn_lab_kk_gecerli(@p0)", [tetkikId]));

            await OlcumAsync(veri, lotId, hedefId, tetkikId, 118m, 10);   // +3,6 SD ret

            Assert.False(await veri.TekDegerAsync<bool>(
                "select public.fn_lab_kk_gecerli(@p0)", [tetkikId]));

            // Düzeltme sonrası GEÇERLİ tekrar ölçümü oto-onayı geri açar.
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 100m, 1);

            Assert.True(await veri.TekDegerAsync<bool>(
                "select public.fn_lab_kk_gecerli(@p0)", [tetkikId]));
        }
        finally { await TemizleAsync(veri, lotId); }
    }

    [Fact]
    public async Task Kumulatif_istatistik_RET_EDILEN_olcumu_saymaz()
    {
        if (!_olgu.Baglandi(nameof(Kumulatif_istatistik_RET_EDILEN_olcumu_saymaz))) return;
        var veri = _olgu.Gerekli();
        var (lotId, hedefId, tetkikId) = await KurAsync(veri, "TEST-KK-KUM");
        try
        {
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 100m, 300);
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 102m, 240);
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 98m, 180);
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 130m, 120);   // +6 SD ret

            await veri.CalistirAsync("select public.fn_lab_kk_kumulatif(@p0)", [hedefId]);

            var h = await veri.TekAsync("""
                select kumulatif_n, kumulatif_ort from public.lab_kk_hedef where id = @p0
                """, [hedefId],
                o => new { N = o.GetInt32(0), Ort = o.GetDecimal(1) });

            // Ret edilen 130 sayılmaz: ölçüm hatası laboratuvarın hedefini
            //   kaydırmamalı.
            Assert.Equal(3, h!.N);
            Assert.Equal(100m, Math.Round(h.Ort, 0));
        }
        finally { await TemizleAsync(veri, lotId); }
    }

    [Fact]
    public async Task Yururlukteki_hedef_ESIK_asilinca_laboratuvar_kumulatifine_gecer()
    {
        if (!_olgu.Baglandi(
                nameof(Yururlukteki_hedef_ESIK_asilinca_laboratuvar_kumulatifine_gecer)))
            return;
        var veri = _olgu.Gerekli();
        var (lotId, hedefId, tetkikId) = await KurAsync(veri, "TEST-KK-HEDEF");
        try
        {
            // Eşik 1000 iken üretici değeri geçerli.
            var uretici = await veri.TekAsync(
                "select hedef, sd, kaynak from public.fn_lab_kk_hedef(@p0)", [hedefId],
                o => new { Hedef = o.GetDecimal(0), Sd = o.GetDecimal(1),
                           Kaynak = o.GetString(2) });
            Assert.Equal(100m, uretici!.Hedef);
            Assert.Equal("üretici", uretici.Kaynak);

            await OlcumAsync(veri, lotId, hedefId, tetkikId, 104m, 300);
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 106m, 240);
            await OlcumAsync(veri, lotId, hedefId, tetkikId, 105m, 180);
            await veri.CalistirAsync("select public.fn_lab_kk_kumulatif(@p0)", [hedefId]);

            // Eşik 3'e indirilince laboratuvarın kendi verisi devreye girer:
            //   yöntem, cihaz ve teknisyen etkisini üretici değeri göremez.
            await veri.CalistirAsync(
                "update public.lab_kk_hedef set esik_n = 3 where id = @p0", [hedefId]);

            var kumulatif = await veri.TekAsync(
                "select hedef, sd, kaynak from public.fn_lab_kk_hedef(@p0)", [hedefId],
                o => new { Hedef = o.GetDecimal(0), Sd = o.GetDecimal(1),
                           Kaynak = o.GetString(2) });
            Assert.Equal(105m, Math.Round(kumulatif!.Hedef, 0));
            Assert.StartsWith("laboratuvar", kumulatif.Kaynak);
        }
        finally { await TemizleAsync(veri, lotId); }
    }
}
