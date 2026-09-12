using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// ÖDEME DAĞILIMI (470) — beş kovanın kuralı.
///
/// Sayılar <c>Dosya/KurumAltKurum.xlsx</c>'ten birebir alındı: kullanıcının
/// modeli buydu, kod ona uymalı. Kural veritabanında tek yerde
/// (<c>fn_belge_satir_dagit</c>); ekran ve API onu çağırır, kendi hesabını
/// yapmaz - iki yerde duran bir formül zamanla ayrışır.
///
/// DEĞİŞMEZ: <c>tutar = sgk + oss + hasta_provizyon + hasta_ek_katki</c>.
/// Katılım payı bu toplamın DIŞINDADIR (hastadan alınır ama ciro değil).
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class DagilimTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public DagilimTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private sealed record Dagilim(decimal Tutar, decimal Sgk, decimal Oss,
                                  decimal HastaProvizyon, decimal HastaEkKatki,
                                  decimal Katilim);

    private static Task<Dagilim?> DagitAsync(VeriKaynagi veri, short rota, decimal tutar,
        decimal sgkListe = 0, decimal huvListe = 0, decimal ekKatki = 0,
        decimal sgkKatilim = 0, decimal? sgkProv = null, decimal? ossProv = null,
        decimal karsilama = 0)
        => veri.TekAsync(
            "select tutar, sgk, oss, hasta_provizyon, hasta_ek_katki, sgk_katilim_payi " +
            "  from public.fn_belge_satir_dagit(@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)",
            [rota, tutar, sgkListe, huvListe, ekKatki, sgkKatilim, sgkProv, ossProv,
             karsilama],
            o => new Dagilim(o.GetDecimal(0), o.GetDecimal(1), o.GetDecimal(2),
                             o.GetDecimal(3), o.GetDecimal(4), o.GetDecimal(5)));

    [Fact]
    public async Task Ozel_hastada_tutarin_tamami_ek_katkidir()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        var d = await DagitAsync(veri, 1, 1000m);
        Assert.NotNull(d);
        Assert.Equal(1000m, d!.Tutar);
        Assert.Equal(1000m, d.HastaEkKatki);
        Assert.Equal(0m, d.Sgk + d.Oss + d.HastaProvizyon + d.Katilim);
    }

    [Fact]
    public async Task Oss_provizyonu_kalani_hastaya_birakir()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        // Excel: 1000 TTB, sigorta 800 onayladı → hastaya 200 kalır.
        var d = await DagitAsync(veri, 2, 1000m, ossProv: 800m);
        Assert.Equal(800m, d!.Oss);
        Assert.Equal(200m, d.HastaProvizyon);
        Assert.Equal(d.Tutar, d.Sgk + d.Oss + d.HastaProvizyon + d.HastaEkKatki);
    }

    [Fact]
    public async Task Tss_kovalari_toplanip_satir_tutari_olur()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        // Excel: SUT 800 + TTB 2000 + ek katkı 600 = 3400; katılım 100 ayrı.
        var d = await DagitAsync(veri, 3, 0m, sgkListe: 800m, huvListe: 2000m,
                                 ekKatki: 600m, sgkKatilim: 100m);
        Assert.Equal(3400m, d!.Tutar);
        Assert.Equal(800m, d.Sgk);
        Assert.Equal(2000m, d.Oss);
        Assert.Equal(600m, d.HastaEkKatki);
        // TSS'de FARK YUTULUR (kullanıcı): hastaya provizyon payı yazılmaz.
        Assert.Equal(0m, d.HastaProvizyon);
        Assert.Equal(100m, d.Katilim);
    }

    [Fact]
    public async Task Tss_de_sigorta_az_onaylarsa_fark_hastaya_yazilmaz()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        // HUV 2000 iken sigorta 1500 onayladı: fark yutulur, satır küçülür.
        var d = await DagitAsync(veri, 3, 0m, sgkListe: 800m, huvListe: 2000m,
                                 ekKatki: 600m, sgkKatilim: 100m, ossProv: 1500m);
        Assert.Equal(1500m, d!.Oss);
        Assert.Equal(0m, d.HastaProvizyon);
        Assert.Equal(2900m, d.Tutar);
    }

    [Fact]
    public async Task Karma_da_sgk_sonrasi_kalani_sigorta_ve_hasta_paylasir()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        // TTB 4200, SGK 500, sigorta provizyonu 2500.
        //
        // TUTARI PROVIZYON BELIRLER (599, kullanici: "Karma'da hasta sadece
        //   100 TL SGK katılım öder, onun dışında katkı ödemez"): satir
        //   500 + 2500 = 3000 yazilir. Tarife 4200 olsa da ARADAKI FARK
        //   HASTAYA GECMEZ - hastanin tek odedigi katilim payidir (ciro disi,
        //   tutara girmez). Eskiden fark hasta provizyonuna (1200) yaziliyordu.
        var d = await DagitAsync(veri, 4, 0m, sgkListe: 500m, huvListe: 4200m,
                                 sgkKatilim: 100m, ossProv: 2500m);
        Assert.Equal(3000m, d!.Tutar);
        Assert.Equal(500m, d.Sgk);
        Assert.Equal(2500m, d.Oss);
        Assert.Equal(0m, d.HastaProvizyon);
        Assert.Equal(100m, d.Katilim);
        Assert.Equal(d.Tutar, d.Sgk + d.Oss + d.HastaProvizyon + d.HastaEkKatki);
    }

    [Fact]
    public async Task Karma_da_sgk_kapatilirsa_rota_oss_ye_doner()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        // Kullanıcı: "karma tipte hasta SGK kullanılmasın talebinde bulunabilir…
        //   sgk kolonu 0 olur, tüm provizyon TTB üzerinden olur."
        var rota = await veri.TekDegerAsync<short>(
            "select public.fn_dagilim_rota(2::smallint, 203::smallint, 0::smallint)");
        Assert.Equal((short)2, rota);

        var d = await DagitAsync(veri, rota, 4200m, ossProv: 2500m);
        Assert.Equal(0m, d!.Sgk);
        Assert.Equal(2500m, d.Oss);
        Assert.Equal(1700m, d.HastaProvizyon);
        Assert.Equal(0m, d.Katilim);
    }

    [Fact]
    public async Task Sgk_da_satir_sut_ve_ek_katkidan_dogar()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        // Excel: SUT 800 + ek katkı 500 = 1300; katılım 100 ayrı.
        var d = await DagitAsync(veri, 5, 0m, sgkListe: 800m, ekKatki: 500m,
                                 sgkKatilim: 100m);
        Assert.Equal(1300m, d!.Tutar);
        Assert.Equal(800m, d.Sgk);
        Assert.Equal(500m, d.HastaEkKatki);
        Assert.Equal(100m, d.Katilim);

        // MEDULA daha az onaylarsa satır da küçülür - hastaneye "onaylanan
        //   kadar" gelir yazılır, farkı hastaya devretmez.
        var d2 = await DagitAsync(veri, 5, 0m, sgkListe: 800m, ekKatki: 500m,
                                  sgkKatilim: 100m, sgkProv: 700m);
        Assert.Equal(1200m, d2!.Tutar);
        Assert.Equal(700m, d2.Sgk);
    }

    [Theory]
    // tur, alt kurum, sgk kullan → rota
    [InlineData(1, 0, 1, 1)]      // Özel
    [InlineData(2, 201, 1, 2)]    // ÖSS
    [InlineData(2, 202, 1, 3)]    // TSS
    [InlineData(2, 203, 1, 4)]    // Karma
    [InlineData(2, 203, 0, 2)]    // Karma, SGK katkısı kapalı
    [InlineData(3, 302, 1, 5)]    // SGK / Bağ-Kur
    public async Task Rota_kurum_turu_ve_alt_kurumdan_cikar(
        int tur, int altKurum, int sgkKullan, int beklenen)
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        var rota = await veri.TekDegerAsync<short>(
            "select public.fn_dagilim_rota(@p0::smallint, @p1::smallint, @p2::smallint)",
            [(short)tur, (short)altKurum, (short)sgkKullan]);
        Assert.Equal((short)beklenen, rota);
    }

    [Theory]
    // Prim planı KABA grupla çalışır: 1/4 hasta, 2/3 kurum, 5 hiçbiri.
    [InlineData(1, 1)] [InlineData(4, 1)]
    [InlineData(2, 2)] [InlineData(3, 2)]
    [InlineData(5, 0)]
    public async Task Pay_grubu_ince_kodu_kabaya_indirir(int pay, int grup)
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        var sonuc = await veri.TekDegerAsync<short>(
            "select public.fn_dagilim_pay_grubu(@p0::smallint)", [(short)pay]);
        Assert.Equal((short)grup, sonuc);
    }

    [Fact]
    public async Task Alt_kurum_sozlesmenin_turune_uymali()
    {
        if (!_olgu.Baglandi(nameof(DagilimTestleri))) return;
        var veri = _olgu.Gerekli();

        // ÖSS kurumuna Bağ-Kur (302) alt kurumu yazılamaz: rota sessizce
        //   yanlış kurulurdu.
        var kurumId = await veri.TekDegerAsync<int>("""
            select k.id from public.taraf_kurum k where k.tur = 2 limit 1
            """);
        if (kurumId == 0) return;

        var hata = await Assert.ThrowsAnyAsync<Exception>(() =>
            veri.CalistirAsync("""
                insert into public.kurum_sozlesme (kurum_id, ad, alt_kurum, durum)
                values (@p0, 'TEST GECERSIZ', 302, 1)
                """, [kurumId]));
        Assert.Contains("uymuyor", hata.Message, StringComparison.OrdinalIgnoreCase);
    }
}
