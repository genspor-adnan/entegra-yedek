using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TESLİM KUYRUĞU (814) — kuyruğa alma kuralları ve geri çekilme.
///
/// Gönderimin kendisi loopback'te sınanıyor (<see cref="MllpIstemciTestleri"/>);
/// burada sınanan, <b>neyin kuyruğa girip neyin girmediği</b>: raporsuz iş,
/// kanalı portal olan kurum, kapalı Bakanlık hedefi ve aynı işin iki kez
/// kuyruğa alınması.
/// </summary>
public sealed class TeleradTeslimKuyruguTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    /// <summary>Kurum + istek (+ istenirse onaylı rapor) açar.</summary>
    private static async Task<(int Istek, int Kurum)> ZeminAsync(
        NpgsqlConnection b, NpgsqlTransaction t, short kanal, short bakanlik, bool raporlu)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var taraf = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('TESLIM TEST KURUMU', 'TSLTST', 1, @p0) returning id",
            t, [sube], Iptal);
        var kurum = await b.TekDegerAsync<int>("""
            insert into public.telerad_kurum
                   (taraf_id, yon, sube_id, hl7_tur, hl7_adres, bakanlik_gonderim,
                    skrs_kodu, msh_uygulama)
            values (@p0, 1, @p1, @p2, '127.0.0.1:65000', @p3, '12345', 'GENOTIP')
            returning id
            """, t, [taraf, sube, kanal, bakanlik], Iptal);

        int? raporId = null;
        if (raporlu)
        {
            var hasta = await b.TekDegerAsync<int>(
                "insert into public.taraf (unvan, kod, hasta, sube_id) "
                + "values ('TESLIM TEST HASTA', 'TSLHST', 1, @p0) returning id",
                t, [sube], Iptal);
            var hizmet = await b.TekDegerAsync<int>(
                "insert into public.hizmet (kod, ad, radyoloji, modalite, sut_kodu, sube_id) "
                + "values (@p0, 'TESLIM TEST BT', 1, 1, '801950', @p1) returning id",
                t, [$"TSL{Guid.NewGuid().ToString("N")[..8]}", sube], Iptal);
            var istemId = await b.TekDegerAsync<int>("""
                insert into public.radyoloji_istem
                       (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum)
                values (@p0, @p1, @p2, 1, @p3, 5) returning id
                """, t, [sube, hasta, hizmet, Guid.NewGuid().ToString("N")[..12]], Iptal);
            raporId = await b.TekDegerAsync<int>("""
                insert into public.radyoloji_rapor (istem_id, durum, kilit, onay_tarihi)
                values (@p0, 3, 1, now()::timestamp) returning id
                """, t, [istemId], Iptal);
        }

        var istek = await b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, sube_id, durum, rapor_id)
            values (@p0, @p2, 1, 1, @p1, 6, @p3) returning id
            """, t, [kurum, sube, Guid.NewGuid().ToString("N")[..10], raporId], Iptal);
        return (istek, kurum);
    }

    [VtFact]
    public async Task Raporsuz_is_kuyruga_alinmaz()
    {
        if (!_olgu.Baglandi(nameof(Raporsuz_is_kuyruga_alinmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (istek, _) = await ZeminAsync(b, t, kanal: 1, bakanlik: 0, raporlu: false);

        // Boş gövdeli ORU karşı tarafta "rapor geldi" sayılır, hasta raporsuz kalır.
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 1::smallint, 0)",
            t, [istek], Iptal));
        Assert.Contains("Raporu onaylanmamış", h.MessageText, StringComparison.Ordinal);
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Portal_kanalinda_kuyruk_kullanilmaz()
    {
        if (!_olgu.Baglandi(nameof(Portal_kanalinda_kuyruk_kullanilmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kanal "Portal": kurum raporu kendi ekranından alır, mesaj gitmez.
        var (istek, _) = await ZeminAsync(b, t, kanal: 0, bakanlik: 0, raporlu: true);

        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 1::smallint, 0)",
            t, [istek], Iptal));
        Assert.Contains("HL7 ORU değil", h.MessageText, StringComparison.Ordinal);
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Bakanlik_kapaliyken_hedef_2_reddedilir()
    {
        if (!_olgu.Baglandi(nameof(Bakanlik_kapaliyken_hedef_2_reddedilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (istek, _) = await ZeminAsync(b, t, kanal: 1, bakanlik: 0, raporlu: true);

        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 2::smallint, 0)",
            t, [istek], Iptal));
        Assert.Contains("Bakanlık bildirimi kapalı", h.MessageText, StringComparison.Ordinal);
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Ayni_is_ve_hedef_icin_tek_satir()
    {
        if (!_olgu.Baglandi(nameof(Ayni_is_ve_hedef_icin_tek_satir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (istek, _) = await ZeminAsync(b, t, kanal: 1, bakanlik: 1, raporlu: true);

        var ilk = await b.TekDegerAsync<long>(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 1::smallint, 0)", t, [istek], Iptal);
        var ikinci = await b.TekDegerAsync<long>(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 1::smallint, 0)", t, [istek], Iptal);

        // İkinci satır açılsaydı aynı rapor iki kez gider, karşı HBYS'de
        //   mükerrer rapor doğardı.
        Assert.Equal(ilk, ikinci);

        // Hedef AYRI satır: kuruma gitmiş olması Bakanlığa gittiği anlamına gelmez.
        var bakanlik = await b.TekDegerAsync<long>(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 2::smallint, 0)", t, [istek], Iptal);
        Assert.NotEqual(ilk, bakanlik);
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Teslim_edilmis_satir_yeniden_beklemeye_dusmez()
    {
        if (!_olgu.Baglandi(nameof(Teslim_edilmis_satir_yeniden_beklemeye_dusmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (istek, _) = await ZeminAsync(b, t, kanal: 1, bakanlik: 0, raporlu: true);
        var id = await b.TekDegerAsync<long>(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 1::smallint, 0)", t, [istek], Iptal);
        await b.CalistirAsync(
            "update public.telerad_teslim set durum = 3 where id = @p0", t, [id], Iptal);

        // Başarılı teslim tekrar kuyruğa girmez: düzeltme ek rapor olarak gider.
        await b.CalistirAsync(
            "select public.fn_telerad_teslim_kuyrukla(@p0, 1::smallint, 0)", t, [istek], Iptal);
        var durum = await b.TekDegerAsync<short>(
            "select durum from public.telerad_teslim where id = @p0", t, [id], Iptal);
        Assert.Equal(3, durum);
        await t.RollbackAsync();
    }

    [VtTheory]
    [InlineData((short)1, "00:01:00")]
    [InlineData((short)3, "00:15:00")]
    [InlineData((short)5, "04:00:00")]
    [InlineData((short)9, "1 day")]
    public async Task Geri_cekilme_artan(short deneme, string beklenen)
    {
        if (!_olgu.Baglandi(nameof(Geri_cekilme_artan))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Sabit aralık, karşı sistem kapalıyken günde binlerce boş bağlantı demek.
        var s = await b.TekDegerAsync<string>(
            "select public.fn_telerad_teslim_sonraki(@p0)::text", null, [deneme], Iptal);
        Assert.Equal(beklenen, s);
    }

    [VtFact]
    public async Task Otomatik_kuyruklama_ayari_kapali_dogar()
    {
        if (!_olgu.Baglandi(nameof(Otomatik_kuyruklama_ayari_kapali_dogar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Bugünkü akış "Teslim Et" düğmesi; otomatiğe geçmek ürün kararıdır.
        var deger = await b.TekDegerAsync<string>(
            "select deger from public.referans where anahtar = 'telerad.teslim_otomatik'",
            null, [], Iptal);
        Assert.Equal("0", deger);
    }
}
