using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELERADYOLOJİ ÇEKİRDEĞİ (797).
///
/// Kullanıcı: *"teleradyolojiyi yap"* · tasarım
/// `Ekranlar/Teleradyoloji/telerad_sureci.html`.
///
/// Okuma işi iç akışın aynısıdır; teleradyolojiye özel olan işin ÇEVRESİDİR -
/// hangi kurum, hangi sözleşme, SLA ne zaman doluyor, kime atandı. Bu testler
/// o çevrenin kurallarını korur; hepsi VERİTABANINDA (tetik), çünkü istek
/// ekrandan da, DICOM alımından da, içe aktarımdan da açılabilir.
/// </summary>
public sealed class TeleradyolojiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Kendi kurumunu ve sözleşmesini açan deneme kurulumu.</summary>
    private static async Task<(int Kurum, int Sozlesme)> KurulumAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int slaAcil = 30, int slaRutin = 1440)
    {
        // TEST KENDI CARISINI ACAR: var olan bir cariyi odunc almak iki
        //   tuzak birden uretti - "en yenisi" baska sinifin geri aldigi satir
        //   olup FK ihlali verdi, "en eskisi" ise dev verisindeki gercek
        //   telerad kurumuyla unique (taraf_id) catisti. Kendi satirimiz
        //   geri alinca iz birakmaz.
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);
        var taraf = await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, kod, musteri, sube_id)
            values ('TELERAD TEST KURUMU', 'TRTEST', 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        var kurum = await b.TekDegerAsync<int>("""
            insert into public.telerad_kurum (taraf_id, yon, dicom_ae_title)
            values (@p0, 1, '') returning id
            """, t, [taraf], CancellationToken.None);
        var sozlesme = await b.TekDegerAsync<int>("""
            insert into public.telerad_sozlesme
                   (kurum_id, baslangic, ucret_modeli, sla_acil_dk, sla_oncelikli_dk,
                    sla_rutin_dk, durum)
            values (@p0, current_date - 10, 1, @p1, 240, @p2, 1) returning id
            """, t, [kurum, slaAcil, slaRutin], CancellationToken.None);
        return (kurum, sozlesme);
    }

    private static Task<int> IstekAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int kurum, short oncelik, string erisim, int gecenDk = 0, short goruntu = 1)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, goruntu_durum, cekim_zamani, gelis_zamani)
            values (@p0, @p1, @p2, @p3, now() - make_interval(mins => @p4),
                    now() - make_interval(mins => @p4))
            returning id
            """, t, [kurum, erisim, oncelik, goruntu, gecenDk], CancellationToken.None);

    [Fact]
    public async Task Istek_numarasi_ve_SOZLESME_kendiliginden()
    {
        if (!_olgu.Baglandi(nameof(Istek_numarasi_ve_SOZLESME_kendiliginden))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, sozlesme) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, 3, "T-001");

        var satir = await b.ListeAsync(
            "select istek_no, sozlesme_id, sla_dk from public.telerad_istek where id = @p0",
            t, [id], o => (No: o.GetString(0), Sozlesme: o.GetInt32(1), Sla: o.GetInt32(2)),
            CancellationToken.None);

        // TR-yyyy/nnnnn · sözleşme kurumun O TARİHTE aktif olanından çözülür.
        Assert.StartsWith("TR-" + DateTime.Today.Year + "/", satir[0].No);
        Assert.Equal(sozlesme, satir[0].Sozlesme);
        // SLA ÖNCELİĞE GÖRE sözleşmeden kopyalanır: acil 30 dk.
        Assert.Equal(30, satir[0].Sla);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task SLA_GORUNTU_geldigi_an_baslar()
    {
        if (!_olgu.Baglandi(nameof(SLA_GORUNTU_geldigi_an_baslar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kurum isteği akşam açıp görüntüyü sabah gönderebilir; söz verdiğimiz
        //   süre OKUMAYA BAŞLAYABİLDİĞİMİZ andan işler.
        var (kurum, _) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, 3, "T-002", gecenDk: 35);

        var satir = await b.ListeAsync(
            "select kalan_dk, sla_riskli, durum from public.v_telerad_istek where id = @p0",
            t, [id], o => (Kalan: o.GetInt32(0), Riskli: o.GetInt16(1), Durum: o.GetInt16(2)),
            CancellationToken.None);

        Assert.True(satir[0].Kalan < 0, "35 dakika geçmiş acil istek SLA'yı aşmış olmalı.");
        Assert.Equal((short)1, satir[0].Riskli);
        // Görüntü tamam -> "sırada" (1 -> 2): durumu ekran değil tetik yürütür.
        Assert.Equal((short)2, satir[0].Durum);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Atama_GECMISI_kendiliginden_yazilir()
    {
        if (!_olgu.Baglandi(nameof(Atama_GECMISI_kendiliginden_yazilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, _) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, 1, "T-003");
        var radyolog = await b.TekDegerAsync<int>(
            "select id from public.taraf where personel = 1 order by id limit 1",
            t, [], CancellationToken.None);
        Assert.True(radyolog > 0, "Denemede kullanilacak personel kaydi yok.");

        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = @p1, degistiren = 7 where id = @p0",
            t, [id, radyolog], CancellationToken.None);

        var durum = await b.TekDegerAsync<short>(
            "select durum from public.telerad_istek where id = @p0", t, [id],
            CancellationToken.None);
        Assert.Equal((short)3, durum);              // sırada -> atandı

        var iz = await b.ListeAsync(
            "select radyolog_id, atayan_id, neden from public.telerad_atama where istek_id = @p0",
            t, [id], o => (Radyolog: o.GetInt32(0), Atayan: o.GetInt32(1), Neden: o.GetInt16(2)),
            CancellationToken.None);
        Assert.Single(iz);
        Assert.Equal(radyolog, iz[0].Radyolog);
        Assert.Equal(7, iz[0].Atayan);
        Assert.Equal((short)2, iz[0].Neden);        // elle atama

        // ATAMA KALKINCA SIRAYA DÖNER: "atandı" ama kimsede olmayan iş,
        //   çalışma listesinde görünmeyen iştir.
        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = null where id = @p0",
            t, [id], CancellationToken.None);
        Assert.Equal((short)2, await b.TekDegerAsync<short>(
            "select durum from public.telerad_istek where id = @p0", t, [id],
            CancellationToken.None));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Onayda_SLA_asimi_KARARI_verilir()
    {
        if (!_olgu.Baglandi(nameof(Onayda_SLA_asimi_KARARI_verilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, _) = await KurulumAsync(b, t);
        var gec = await IstekAcAsync(b, t, kurum, 3, "T-004", gecenDk: 45);   // acil, 30 dk
        var zamaninda = await IstekAcAsync(b, t, kurum, 1, "T-005");          // rutin, 1440 dk

        foreach (var id in new[] { gec, zamaninda })
            await b.CalistirAsync("update public.telerad_istek set durum = 6 where id = @p0",
                t, [id], CancellationToken.None);

        // Onay zamanı ve aşım kararı TEK yerde (tetik) veriliyor.
        Assert.Equal((short)1, await b.TekDegerAsync<short>(
            "select sla_asildi from public.telerad_istek where id = @p0", t, [gec],
            CancellationToken.None));
        Assert.Equal((short)0, await b.TekDegerAsync<short>(
            "select sla_asildi from public.telerad_istek where id = @p0", t, [zamaninda],
            CancellationToken.None));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Ayni_erisim_numarasi_IKI_KEZ_girilemez()
    {
        if (!_olgu.Baglandi(nameof(Ayni_erisim_numarasi_IKI_KEZ_girilemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kurumun PACS'i aynı çalışmayı tekrar gönderirse ikinci KAYIT değil
        //   aynı istek güncellenmeli - yoksa çalışma listesi ikizlenir ve iş
        //   iki radyologa düşer.
        var (kurum, _) = await KurulumAsync(b, t);
        await IstekAcAsync(b, t, kurum, 1, "ACC-9");

        await b.CalistirAsync("savepoint sp_ikiz", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => IstekAcAsync(b, t, kurum, 1, "ACC-9"));
        Assert.Equal("23505", h.SqlState);          // unique ihlali
        await b.CalistirAsync("rollback to savepoint sp_ikiz", t, [], CancellationToken.None);

        await t.RollbackAsync();
    }

    [Fact]
    public void Calisma_listesi_ACIL_ve_SLA_sirasinda()
    {
        // Çalışma listesinin sırası bir tercih değil işin kendisidir: radyolog
        //   listenin başından alır. Acil önce, sonra SLA'sı dolmak üzere olan.
        var kaynak = KaynakKatalogu.Bul("telerad-istek");
        Assert.NotNull(kaynak);
        Assert.Contains("oncelik desc", kaynak!.VarsayilanSirala);
        Assert.Contains("sla_bitis", kaynak.VarsayilanSirala);

        // Kalan dakika SUNUCUDA hesaplanır (görünümden gelir): iki ekran iki
        //   farklı "şimdi" kullanırsa liste kendi içinde çelişir.
        Assert.Contains(kaynak.Kolonlar, k => k.Ad == "kalanDk");
        Assert.Contains(kaynak.Kolonlar, k => k.Ad == "slaRiskli");
    }

    [Fact]
    public void Portal_kurumu_KENDI_isteklerini_gorur()
    {
        // Gönderen kurum portalı (794/795): kurum bağı `telerad_kurum.taraf_id`
        //   üzerinden - portal kullanıcısı kurumun CARİ kaydıdır.
        var kaynak = KaynakKatalogu.Bul("telerad-istek")!;
        Assert.NotNull(kaynak.PortalKosullari);
        Assert.Contains("kurum_taraf_id", kaynak.PortalKosullari![PortalKapsam.DisKurum]);
        // Hasta bu listede işi yok: portal türü 3 açıkça KAPALI.
        Assert.Equal("false", kaynak.PortalKosullari[PortalKapsam.Hasta]);
    }
}
