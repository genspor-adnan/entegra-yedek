using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// AVANS İADESİ (780) — kullanıcı: *"avans iadesini de yap"*.
///
/// İade avans kaydını KÜÇÜLTMEZ: ödeme yönünde ayrı bir kasa işlemidir ve
/// `avans_kaynak_id` ile avansına bağlanır. Buradaki testler aynı paranın iki
/// kez harcanmasını engelleyen kuralları sabitler - iade edilmiş avans ne
/// mahsup edilebilir, ne ikinci kez iade edilebilir, ne de başkasına ödenir.
///
/// Her test kendi transaction'ında çalışır ve geri alınır.
/// </summary>
public sealed class AvansIadesiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<(int Hasta, int Avans, int Sube)> AvansAsync(
        NpgsqlConnection b, NpgsqlTransaction t, decimal tutar)
    {
        var tur = await b.TekDegerAsync<int>(
            "select kod from public.kasa_islem_turu where yon = 1 order by kod limit 1",
            t, [], CancellationToken.None);
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube order by id limit 1", t, [], CancellationToken.None);
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, grup, durum, sube_id) "
            + "values ('TEST IADE HASTA', 101, 1, @p0) returning id",
            t, [sube], CancellationToken.None);
        var avans = await b.TekDegerAsync<int>(
            "insert into public.kasa_islem "
            + "       (tur, islem_tarihi, taraf_id, tutar, yerel_tutar, durum, avans, sube_id) "
            + "values (@p0, current_date, @p1, @p2, @p2, 2, 1, @p3) returning id",
            t, [tur, hasta, tutar, sube], CancellationToken.None);
        return (hasta, avans, sube);
    }

    /// <summary>Avansa bağlı ödeme satırı; tür verilmezse ilk ödeme türü.</summary>
    private static Task<int> IadeAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int avansId, int tarafId, decimal tutar, int sube, int? tur = null)
        => b.TekDegerAsync<int>(
            "insert into public.kasa_islem "
            + "       (tur, islem_tarihi, taraf_id, tutar, yerel_tutar, durum, "
            + "        avans_kaynak_id, sube_id) "
            + "values (coalesce(@p4, (select kod from public.kasa_islem_turu "
            + "                        where yon = -1 and grup = 'odeme' "
            + "                        order by kod limit 1)), "
            + "        current_date, @p1, @p2, @p2, 2, @p0, @p3) returning id",
            t, [avansId, tarafId, tutar, sube, tur], CancellationToken.None);

    private static Task<List<IDictionary<string, object>>> AvansSatiriAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int avansId)
        => b.ListeAsync(
            "select a.kullanilan, a.iade, a.kalan, a.durum_adi "
            + "  from public.v_hasta_avans a where a.kasa_islem_id = @p0",
            t, [avansId], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);

    [VtFact]
    public async Task Iade_KALANDAN_duser_ve_durumu_degistirir()
    {
        if (!_olgu.Baglandi(nameof(Iade_KALANDAN_duser_ve_durumu_degistirir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (hasta, avans, sube) = await AvansAsync(b, t, 1000m);
        await IadeAsync(b, t, avans, hasta, 400m, sube);

        var s = await AvansSatiriAsync(b, t, avans);
        Assert.Single(s);
        // İADE KULLANIM DEĞİLDİR: para hizmete sayılmadı, kasadan çıktı. İkisi
        //   tek kolonda toplansaydı "ne kadarı işe yaradı" sorusu cevapsız
        //   kalırdı.
        Assert.Equal(0m, Convert.ToDecimal(s[0]["kullanilan"]));
        Assert.Equal(400m, Convert.ToDecimal(s[0]["iade"]));
        Assert.Equal(600m, Convert.ToDecimal(s[0]["kalan"]));
        Assert.Equal("Kısmen İade", s[0]["durum_adi"]?.ToString());

        await IadeAsync(b, t, avans, hasta, 600m, sube);
        s = await AvansSatiriAsync(b, t, avans);
        Assert.Equal(0m, Convert.ToDecimal(s[0]["kalan"]));
        Assert.Equal("İade Edildi", s[0]["durum_adi"]?.ToString());

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Iade_KALANI_asamaz()
    {
        if (!_olgu.Baglandi(nameof(Iade_KALANI_asamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Aşarsa kurum hastaya ALMADIĞI parayı öder.
        var (hasta, avans, sube) = await AvansAsync(b, t, 500m);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => IadeAsync(b, t, avans, hasta, 600m, sube));
        Assert.Equal("GK422", h.SqlState);      // API mesajı kullanıcıya aynen geçirir
        Assert.Contains("kalan avansı aşamaz", h.MessageText);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Kullanilmis_avansin_KALANI_kadar_iade_edilir()
    {
        if (!_olgu.Baglandi(nameof(Kullanilmis_avansin_KALANI_kadar_iade_edilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Mahsup edilmiş kısım artık hastanın parası değil: 1000'in 700'ü
        //   hizmete sayıldıysa iade edilebilecek olan 300'dür.
        var (hasta, avans, sube) = await AvansAsync(b, t, 1000m);
        var satirId = await b.TekDegerAsync<int>(
            "select id from public.belge_satir order by id limit 1", t, [],
            CancellationToken.None);
        await b.CalistirAsync(
            "insert into public.kasa_islem_dagitim (kasa_islem_id, belge_satir_id, pay, tutar) "
            + "values (@p0, @p1, 1, 700)", t, [avans, satirId], CancellationToken.None);

        // SAVEPOINT: PG'de hata alan transaction'da sonraki her komut
        //   "current transaction is aborted" ile reddedilir - reddi denedikten
        //   SONRA geçerli iadeyi yazabilmek için ara nokta gerekiyor.
        await b.CalistirAsync("savepoint sp_asim", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => IadeAsync(b, t, avans, hasta, 400m, sube));
        Assert.Contains("300", h.MessageText);          // kalan mesajda yazar
        await b.CalistirAsync("rollback to savepoint sp_asim", t, [], CancellationToken.None);

        await IadeAsync(b, t, avans, hasta, 300m, sube);
        var s = await AvansSatiriAsync(b, t, avans);
        Assert.Equal(0m, Convert.ToDecimal(s[0]["kalan"]));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Iade_edilen_avans_MAHSUP_edilemez()
    {
        if (!_olgu.Baglandi(nameof(Iade_edilen_avans_MAHSUP_edilemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 322'nin görünümü "dağıtılmamış tahsilat" diyordu; iade bir dağıtım
        //   olmadığı için geri ödenen para orada hâlâ mahsup edilebilir
        //   görünürdü - aynı 500 TL hem hastaya verilir hem başvurusuna
        //   sayılırdı.
        var (hasta, avans, sube) = await AvansAsync(b, t, 500m);
        var once = await b.TekDegerAsync<decimal?>(
            "select dagitilmamis from public.v_taraf_avans where kasa_islem_id = @p0",
            t, [avans], CancellationToken.None);
        Assert.Equal(500m, once ?? 0m);

        await IadeAsync(b, t, avans, hasta, 500m, sube);
        var sonra = await b.TekDegerAsync<decimal?>(
            "select dagitilmamis from public.v_taraf_avans where kasa_islem_id = @p0",
            t, [avans], CancellationToken.None);
        Assert.Null(sonra);      // görünümden tümüyle düşer

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Iade_TAHSILAT_turunde_olamaz()
    {
        if (!_olgu.Baglandi(nameof(Iade_TAHSILAT_turunde_olamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Tahsilat türüyle yazılan "iade" parayı kasaya İKİNCİ KEZ sokardı.
        var (hasta, avans, sube) = await AvansAsync(b, t, 300m);
        var tahsilatTuru = await b.TekDegerAsync<int>(
            "select kod from public.kasa_islem_turu where yon = 1 order by kod limit 1",
            t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => IadeAsync(b, t, avans, hasta, 100m, sube, tahsilatTuru));
        Assert.Contains("ÖDEME türünde", h.MessageText);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Iade_AVANSIN_SAHIBINE_yapilir()
    {
        if (!_olgu.Baglandi(nameof(Iade_AVANSIN_SAHIBINE_yapilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Başkasına ödenen para iade değil, başka bir işlemdir.
        var (_, avans, sube) = await AvansAsync(b, t, 300m);
        var baskasi = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, grup, durum, sube_id) "
            + "values ('TEST BASKA HASTA', 101, 1, @p0) returning id",
            t, [sube], CancellationToken.None);

        var h = await Assert.ThrowsAsync<PostgresException>(
            () => IadeAsync(b, t, avans, baskasi, 100m, sube));
        Assert.Contains("sahibine", h.MessageText);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Iptal_edilen_iade_KALANI_geri_verir()
    {
        if (!_olgu.Baglandi(nameof(Iptal_edilen_iade_KALANI_geri_verir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // İade iptal edilirse para geri gelmiş demektir: avans yeniden
        //   kullanılabilir olmalı, yoksa hastanın parası sistemde kaybolurdu.
        var (hasta, avans, sube) = await AvansAsync(b, t, 400m);
        var iadeId = await IadeAsync(b, t, avans, hasta, 400m, sube);
        Assert.Equal(0m, Convert.ToDecimal((await AvansSatiriAsync(b, t, avans))[0]["kalan"]));

        await b.CalistirAsync("update public.kasa_islem set durum = 3 where id = @p0",
            t, [iadeId], CancellationToken.None);

        var s = await AvansSatiriAsync(b, t, avans);
        Assert.Equal(0m, Convert.ToDecimal(s[0]["iade"]));
        Assert.Equal(400m, Convert.ToDecimal(s[0]["kalan"]));
        Assert.Equal("Açık", s[0]["durum_adi"]?.ToString());

        await t.RollbackAsync();
    }
}
