using Gentegre.Api.Uclar;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELERADYOLOJİ DÖNEM FATURASI (803).
///
/// Kullanıcı: *"dönem faturasıyla devam et"*.
///
/// Teleradyoloji işi tek tek faturalanmaz: dönem sonunda o kurumun onaylanmış
/// işleri TEK satış faturasına girer. Testler <b>ucun kendi SQL'ini</b>
/// kullanıyor (`TeleradUclari.SatirSql` / `EksikSql`) - kuralı test için
/// ikinci kez yazmak, testin gerçeği değil kendi kopyasını doğrulaması olurdu.
/// </summary>
public sealed class TeleradFaturaTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<(int Kurum, int Hizmet, int Sube)> KurulumAsync(
        NpgsqlConnection b, NpgsqlTransaction t, decimal cezaOrani = 0m)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);
        var taraf = await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, kod, musteri, sube_id)
            values ('TELERAD FATURA TEST KURUMU', 'TRFTK', 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        var kurum = await b.TekDegerAsync<int>("""
            insert into public.telerad_kurum (taraf_id, yon, dicom_ae_title, sube_id)
            values (@p0, 1, '', @p1) returning id
            """, t, [taraf, sube], CancellationToken.None);
        await b.CalistirAsync("""
            insert into public.telerad_sozlesme
                   (kurum_id, baslangic, ucret_modeli, sla_acil_dk, sla_oncelikli_dk,
                    sla_rutin_dk, sla_ceza_oran, durum)
            values (@p0, current_date - 60, 1, 30, 240, 1440, @p1, 1)
            """, t, [kurum, cezaOrani], CancellationToken.None);

        // TEST KENDİ HİZMETİNİ AÇAR: faturanın satırı bir HİZMET kalemidir ve
        //   dev veritabanında radyoloji işaretli hizmet olmayabilir (yok da).
        //   Var olanı ödünç almak, başka sınıfın fiyatına/KDV'sine bağımlı
        //   olmak demekti.
        var hizmet = await b.TekDegerAsync<int>("""
            insert into public.hizmet (kod, ad, tur, kdv, radyoloji, durum, sube_id)
            values ('TRFT01', 'TELERAD TEST BT', 0, 20, 1, 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        return (kurum, hizmet, sube);
    }

    /// <summary>
    /// Onaylanmış, ücreti yazılmış, faturalanmamış istek.
    ///
    /// SLA AŞIMINI TETİK KARAR VERİR (797): bayrağı elle yazmak, testin
    /// gerçek kuralı değil kendi varsayımını doğrulaması olurdu. Geç iş
    /// üretmek için görüntü gelişi ile onay arasını açmak yeter (rutin SLA
    /// sözleşmede 1440 dk).
    /// </summary>
    private static Task<int> OnayliIstekAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int kurum, int sube, int? hizmet, decimal ucret,
        int onayGunOnce = 5, int? gelisGunOnce = null)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, goruntu_durum,
                    tetkik_hizmet_id, ucret, durum, onay_zamani,
                    cekim_zamani, gelis_zamani, sube_id)
            values (@p0, @p6, 1, 1, 1, @p2, @p3, 6,
                    now() - make_interval(days => @p4),
                    now() - make_interval(days => @p5), now() - make_interval(days => @p5), @p1)
            returning id
            """, t, [kurum, sube, hizmet, ucret, onayGunOnce,
                     gelisGunOnce ?? onayGunOnce, Guid.NewGuid().ToString("N")[..10]],
            CancellationToken.None);

    private static Task<List<IDictionary<string, object?>>> SatirlarAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int kurum)
        => b.ListeAsync(TeleradUclari.SatirSql, t,
            [kurum, DateTime.Today.AddDays(-30), DateTime.Today],
            OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);

    [Fact]
    public async Task Donem_isleri_TEK_faturada_toplanir()
    {
        if (!_olgu.Baglandi(nameof(Donem_isleri_TEK_faturada_toplanir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // AYNI TETKİK AYNI ÜCRET TEK SATIR: kuruma otuz ayrı satır göndermek,
        //   faturayı okunamaz kılardı - adet sütunu bunun için var.
        var (kurum, hizmet, sube) = await KurulumAsync(b, t);
        await OnayliIstekAsync(b, t, kurum, sube, hizmet, 450m);
        await OnayliIstekAsync(b, t, kurum, sube, hizmet, 450m);
        await OnayliIstekAsync(b, t, kurum, sube, hizmet, 600m);

        var satirlar = await SatirlarAsync(b, t, kurum);
        Assert.Equal(2, satirlar.Count);                       // 450 x2, 600 x1
        Assert.Equal(2, Convert.ToInt32(satirlar[0]["adet"]));
        Assert.Equal(900m, Convert.ToDecimal(satirlar[0]["tutar"]));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Faturalanmis_istek_IKINCI_KEZ_gelmez()
    {
        if (!_olgu.Baglandi(nameof(Faturalanmis_istek_IKINCI_KEZ_gelmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, hizmet, sube) = await KurulumAsync(b, t);
        var istek = await OnayliIstekAsync(b, t, kurum, sube, hizmet, 450m);
        Assert.Single(await SatirlarAsync(b, t, kurum));

        // `fatura_belge_id` işaretlendi: aynı iş ikinci faturaya giremez.
        //   VAR OLAN bir belge kullanılıyor - kolon yabancı anahtar taşıyor,
        //   uydurma id ile işaretlemek kısıtı ihlal ediyordu.
        var belge = await b.TekDegerAsync<int>(
            "select id from public.belge order by id limit 1", t, [], CancellationToken.None);
        Assert.True(belge > 0, "Denemede kullanilacak belge yok.");
        await b.CalistirAsync(
            "update public.telerad_istek set fatura_belge_id = @p1 where id = @p0",
            t, [istek, belge], CancellationToken.None);
        Assert.Empty(await SatirlarAsync(b, t, kurum));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Onaylanmamis_is_faturaya_GIRMEZ()
    {
        if (!_olgu.Baglandi(nameof(Onaylanmamis_is_faturaya_GIRMEZ))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Para HAK EDİLMİŞ işten doğar: okunmamış tetkik faturalanamaz.
        var (kurum, hizmet, sube) = await KurulumAsync(b, t);
        var istek = await OnayliIstekAsync(b, t, kurum, sube, hizmet, 450m);
        await b.CalistirAsync(
            "update public.telerad_istek set durum = 4 where id = @p0",
            t, [istek], CancellationToken.None);

        Assert.Empty(await SatirlarAsync(b, t, kurum));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task SLA_kacan_is_AYRI_satirda_ve_iskontolu()
    {
        if (!_olgu.Baglandi(nameof(SLA_kacan_is_AYRI_satirda_ve_iskontolu))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // SLA cezası satır İSKONTOSUDUR: süresi kaçan işler ayrı satırda
        //   toplanır ki ceza yalnız onlara uygulansın - zamanında biten işten
        //   indirim yapmak sözleşmeye aykırı olurdu.
        var (kurum, hizmet, sube) = await KurulumAsync(b, t, cezaOrani: 10m);
        await OnayliIstekAsync(b, t, kurum, sube, hizmet, 450m);
        await OnayliIstekAsync(b, t, kurum, sube, hizmet, 450m,
                               onayGunOnce: 5, gelisGunOnce: 10);   // 5 gün geç

        var satirlar = await SatirlarAsync(b, t, kurum);
        Assert.Equal(2, satirlar.Count);
        Assert.Contains(satirlar, s => (bool)(s["slaAsildi"] ?? false));
        Assert.Contains(satirlar, s => !(bool)(s["slaAsildi"] ?? false));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Eksik_is_SESSIZCE_atlanmaz()
    {
        if (!_olgu.Baglandi(nameof(Eksik_is_SESSIZCE_atlanmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Tetkik eşleşmesi olmayan ya da ücreti yazılmamış iş faturaya
        //   giremez ama EKRANDA GÖRÜNÜR: eksiği sessizce atlamak kuruma
        //   eksik fatura kesmek demekti.
        var (kurum, hizmet, sube) = await KurulumAsync(b, t);
        await OnayliIstekAsync(b, t, kurum, sube, null, 450m);      // tetkik yok
        await OnayliIstekAsync(b, t, kurum, sube, hizmet, 0m);      // ücret yok
        await OnayliIstekAsync(b, t, kurum, sube, hizmet, 450m);    // sağlam

        Assert.Single(await SatirlarAsync(b, t, kurum));

        var eksikler = await b.ListeAsync(TeleradUclari.EksikSql, t,
            [kurum, DateTime.Today.AddDays(-30), DateTime.Today],
            OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);
        Assert.Equal(2, eksikler.Count);
        Assert.Contains(eksikler, e => ((string)e["sebep"]!).Contains("Tetkik"));
        Assert.Contains(eksikler, e => ((string)e["sebep"]!).Contains("Ücret"));

        await t.RollbackAsync();
    }

    [Fact]
    public void Fatura_dugmesi_KURUM_listesinde()
    {
        // Fatura kurumun dönemine aittir: düğme kurum listesinde, seçili
        //   kayıtla çalışır.
        var ekran = AksiyonKatalogu.Ekran("telerad-kurum-liste");
        Assert.True(ekran is not null, "Kurum listesi aksiyon ekrani yok.");
        var fatura = ekran!.FirstOrDefault(a => a.Kod == "telerad.faturala");
        Assert.True(fatura is not null, "Dönem faturası düğmesi yok.");
        Assert.True(fatura!.KayitGerekir, "Fatura kurum seçilmeden açılmamalı.");
        Assert.Equal("telerad.faturala", fatura.AksiyonYetkisi);
    }
}
