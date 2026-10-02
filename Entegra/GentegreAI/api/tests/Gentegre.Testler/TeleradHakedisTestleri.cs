using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELERADYOLOJİ HAKEDİŞ BAĞI — RAPORLAYAN PAYI (807).
///
/// Kullanıcı: *"hakediş bağıyla devam et"*. Tasarım (797 adım 9): onaylı
/// rapor → rol Raporlayan → Prim modülü.
///
/// 803'te dönem faturası üretiliyordu ama satırlarına kimse yazılmıyordu:
/// `belge_satir_rol` boş kaldığı için işi okuyan radyolog prim kazanmıyordu.
/// <b>Yeni prim motoru yazılmadı</b> - rol yazılır, gerisini mevcut hat yapar.
/// </summary>
public sealed class TeleradHakedisTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Fatura satırı + o satırı besleyen istekler (kendi verisiyle).</summary>
    private static async Task<(int Satir, int Kurum, int Sube)> SatirKurAsync(
        NpgsqlConnection b, NpgsqlTransaction t)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);
        var taraf = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('TELERAD HAKEDIS TEST', 'TRHK', 1, @p0) returning id",
            t, [sube], CancellationToken.None);
        var kurum = await b.TekDegerAsync<int>(
            "insert into public.telerad_kurum (taraf_id, yon, dicom_ae_title, sube_id) "
            + "values (@p0, 1, '', @p1) returning id",
            t, [taraf, sube], CancellationToken.None);

        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, tur, kdv, radyoloji, durum, sube_id) "
            + "values ('TRHK01', 'TELERAD HAKEDIS BT', 0, 20, 1, 1, @p0) returning id",
            t, [sube], CancellationToken.None);

        // Fatura: belge hattı yerine DOĞRUDAN satır - test hakediş bağını
        //   ölçüyor, fatura üretimini değil (o 803 testlerinde).
        var belge = await b.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, belge_tarihi, belge_dovizi, "
            + "  doviz_kuru, sube_id, durum) "
            + "values (15, 1, @p0, current_date, 'TL', 1, @p1, 0) returning id",
            t, [taraf, sube], CancellationToken.None);
        var satir = await b.TekDegerAsync<int>(
            // Satirin subesi de yazilmali (fk_belge_satir_sube).
            "insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, "
            + "  birim_fiyat, iskonto, kdv, doviz_cinsi, sube_id) "
            + "values (@p0, 1, 2, @p1, 4, 450, 0, 20, 'TL', @p2) returning id",
            t, [belge, hizmet, sube], CancellationToken.None);

        return (satir, kurum, sube);
    }

    private static Task<int> RadyologAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, string kod, short disHekim = 0)
        => b.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, kod, personel, sube_id) "
            + "          values (@p1, @p1, 1, @p0) returning id) "
            // taraf_personel.sube_id NOT NULL.
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) "
            + "select y.id, @p2, @p0 from y returning id",
            t, [sube, kod, disHekim], CancellationToken.None);

    private static Task<int> IstekAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int kurum, int sube, int satir, int? radyolog)
        => b.TekDegerAsync<int>(
            "insert into public.telerad_istek "
            + "(kurum_id, dis_erisim_no, oncelik, modalite, goruntu_durum, ucret, durum, "
            + " onay_zamani, cekim_zamani, gelis_zamani, sube_id, atanan_radyolog_id, "
            + " fatura_satir_id) "
            + "values (@p0, @p4, 1, 1, 1, 450, 6, now(), now(), now(), @p1, @p3, @p2) "
            + "returning id",
            t, [kurum, sube, satir, radyolog, Guid.NewGuid().ToString("N")[..10]],
            CancellationToken.None);

    private static Task<List<(int Taraf, decimal Pay)>> PaylarAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int satir)
        => b.ListeAsync(
            "select taraf_id, pay_yuzde from public.belge_satir_rol "
            + " where belge_satir_id = @p0 and rol = 5 order by pay_yuzde desc, taraf_id",
            t, [satir], o => (o.GetInt32(0), o.GetDecimal(1)), CancellationToken.None);

    private static Task<int> RolUretAsync(NpgsqlConnection b, NpgsqlTransaction t, int satir)
        => b.TekDegerAsync<int>(
            "select public.fn_telerad_fatura_rol("
            + "  (select belge_id from public.belge_satir where id = @p0))",
            t, [satir], CancellationToken.None);

    [VtFact]
    public async Task Pay_ADEDE_gore_bolunur()
    {
        if (!_olgu.Baglandi(nameof(Pay_ADEDE_gore_bolunur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Bir fatura satırı aynı tetkikten onlarca işi toplar ve bunları
        //   FARKLI radyologlar okumuş olabilir. Satırı radyologa göre bölmek
        //   müşteriye anlamsız satırlar gösterirdi; pay yüzdesi bunun için var.
        var (satir, kurum, sube) = await SatirKurAsync(b, t);
        var a = await RadyologAcAsync(b, t, sube, 'A' + Guid.NewGuid().ToString("N")[..6]);
        var c = await RadyologAcAsync(b, t, sube, 'C' + Guid.NewGuid().ToString("N")[..6]);

        await IstekAcAsync(b, t, kurum, sube, satir, a);
        await IstekAcAsync(b, t, kurum, sube, satir, a);
        await IstekAcAsync(b, t, kurum, sube, satir, a);
        await IstekAcAsync(b, t, kurum, sube, satir, c);

        Assert.Equal(2, await RolUretAsync(b, t, satir));

        var paylar = await PaylarAsync(b, t, satir);
        Assert.Equal(2, paylar.Count);
        Assert.Equal(a, paylar[0].Taraf);
        Assert.Equal(75m, paylar[0].Pay);
        Assert.Equal(25m, paylar[1].Pay);
        Assert.Equal(100m, paylar.Sum(x => x.Pay));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Atanmamis_isin_payi_BOSTA_kalir()
    {
        if (!_olgu.Baglandi(nameof(Atanmamis_isin_payi_BOSTA_kalir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kalan payı okuyanlara dağıtmak, YAPILMAMIŞ iş için prim ödemek
        //   olurdu: payda satırdaki TÜM işler.
        var (satir, kurum, sube) = await SatirKurAsync(b, t);
        var a = await RadyologAcAsync(b, t, sube, 'A' + Guid.NewGuid().ToString("N")[..6]);

        await IstekAcAsync(b, t, kurum, sube, satir, a);
        await IstekAcAsync(b, t, kurum, sube, satir, a);
        await IstekAcAsync(b, t, kurum, sube, satir, null);   // radyologu yok
        await IstekAcAsync(b, t, kurum, sube, satir, null);

        await RolUretAsync(b, t, satir);
        var paylar = await PaylarAsync(b, t, satir);
        Assert.Single(paylar);
        Assert.Equal(50m, paylar[0].Pay);       // 4 işin 2'si

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task DIS_radyolog_da_PAY_alir()
    {
        if (!_olgu.Baglandi(nameof(DIS_radyolog_da_PAY_alir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 361 "dis hekim yalniz Gonderen rolunde prim alabilir" diyordu; o
        //   kural dis hekimin hastayi GONDEREN taraf oldugu varsayimiyla
        //   yazilmisti. Teleradyolojide isi disaridan calisan radyolog YAPAR -
        //   kural 808'de daraltildi (Gonderen + Raporlayan) ve dis radyolog
        //   artik payini alir. 807'de bu is paysiz kaliyordu.
        var (satir, kurum, sube) = await SatirKurAsync(b, t);
        var ic  = await RadyologAcAsync(b, t, sube, 'I' + Guid.NewGuid().ToString("N")[..6]);
        var dis = await RadyologAcAsync(b, t, sube, 'D' + Guid.NewGuid().ToString("N")[..6],
                                        disHekim: 1);

        await IstekAcAsync(b, t, kurum, sube, satir, ic);
        await IstekAcAsync(b, t, kurum, sube, satir, dis);

        Assert.Equal(2, await RolUretAsync(b, t, satir));
        var paylar = await PaylarAsync(b, t, satir);
        Assert.Equal(2, paylar.Count);
        Assert.Contains(paylar, x => x.Taraf == dis && x.Pay == 50m);
        Assert.Contains(paylar, x => x.Taraf == ic  && x.Pay == 50m);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task DIS_hekime_OTEKI_roller_kapali()
    {
        if (!_olgu.Baglandi(nameof(DIS_hekime_OTEKI_roller_kapali))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // KURAL SILINMEDI, DARALTILDI (808): "Uygulayan" / "Anestezi" /
        //   "Teknisyen" kurum icinde fiilen yapilan islerdir - disaridan
        //   calisan biri onlari yapmaz, o rolde prim satiri neredeyse her
        //   zaman yanlis kisi secimidir.
        var (satir, _, sube) = await SatirKurAsync(b, t);
        var dis = await RadyologAcAsync(b, t, sube, 'D' + Guid.NewGuid().ToString("N")[..6],
                                        disHekim: 1);

        await b.CalistirAsync("savepoint sp_rol", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "insert into public.belge_satir_rol "
            + "(belge_satir_id, rol, taraf_id, pay_yuzde, kaynak) "
            + "values (@p0, 3, @p1, 100, 1)",              // 3 = Uygulayan
            t, [satir, dis], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);
        await b.CalistirAsync("rollback to savepoint sp_rol", t, [], CancellationToken.None);

        // GONDEREN ve RAPORLAYAN gecer.
        foreach (var rol in new[] { 1, 5 })
        {
            await b.CalistirAsync(
                "insert into public.belge_satir_rol "
                + "(belge_satir_id, rol, taraf_id, pay_yuzde, kaynak) "
                + "values (@p0, @p2, @p1, 50, 1)",
                t, [satir, dis, rol], CancellationToken.None);
        }

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task ELLE_yazilmis_rol_ezilmez()
    {
        if (!_olgu.Baglandi(nameof(ELLE_yazilmis_rol_ezilmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 326 deseni: kullanıcı bilerek düzeltmiş olabilir - türetilmiş
        //   (kaynak 2) satır tazelenir, elle yazılan (kaynak 1) korunur.
        var (satir, kurum, sube) = await SatirKurAsync(b, t);
        var a = await RadyologAcAsync(b, t, sube, 'A' + Guid.NewGuid().ToString("N")[..6]);
        var elle = await RadyologAcAsync(b, t, sube, 'E' + Guid.NewGuid().ToString("N")[..6]);

        await IstekAcAsync(b, t, kurum, sube, satir, a);
        await b.CalistirAsync(
            "insert into public.belge_satir_rol "
            + "(belge_satir_id, rol, taraf_id, pay_yuzde, kaynak) "
            + "values (@p0, 5, @p1, 100, 1)",
            t, [satir, elle], CancellationToken.None);

        Assert.Equal(0, await RolUretAsync(b, t, satir));
        var paylar = await PaylarAsync(b, t, satir);
        Assert.Single(paylar);
        Assert.Equal(elle, paylar[0].Taraf);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Tekrar_calistirmak_GUVENLI()
    {
        if (!_olgu.Baglandi(nameof(Tekrar_calistirmak_GUVENLI))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Fatura iki kez tazelenirse pay İKİYE KATLANMAMALI: türetilmiş
        //   satırlar silinip yeniden yazılıyor.
        var (satir, kurum, sube) = await SatirKurAsync(b, t);
        var a = await RadyologAcAsync(b, t, sube, 'A' + Guid.NewGuid().ToString("N")[..6]);
        await IstekAcAsync(b, t, kurum, sube, satir, a);

        await RolUretAsync(b, t, satir);
        await RolUretAsync(b, t, satir);

        var paylar = await PaylarAsync(b, t, satir);
        Assert.Single(paylar);
        Assert.Equal(100m, paylar[0].Pay);

        await t.RollbackAsync();
    }
}
