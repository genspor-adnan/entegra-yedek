using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// LAB KALEMİNDE GÖNDEREN PRİMİ (828).
///
/// 825'in kuralı laboratuvarda da geçerli: <b>kurum adına</b> gelen işte
/// Gönderen kurumdur (hekim prim almaz), <b>kendi adına</b> gelende dış
/// hekimdir. İç personelin istemi gönderen primi doğurmaz.
///
/// Bağ ücret satırı üzerinden kurulur: istemin belgesindeki, hizmeti bir
/// <c>lab_tetkik</c>/<c>lab_panel</c> karşılığı olan kalemler
/// (<c>lab_istem_satir.belge_satir_id</c> şemada var ama hiçbir yol onu
/// yazmıyor).
/// </summary>
public sealed class LabGonderenPrimiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static Task<int> SubeAsync(NpgsqlConnection b, NpgsqlTransaction t)
        => b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);

    private static Task<int> HekimAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, short disHekim)
        => b.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, kod, personel, sube_id) "
            + "          values (@p1, @p1, 1, @p0) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) "
            + "select y.id, @p2, @p0 from y returning id",
            t, [sube, $"LGP{Guid.NewGuid().ToString("N")[..8]}", disHekim], Iptal);

    /// <summary>Kuruma bağlı dış hekim: kartında `taraf.bag_id` dolu (827).</summary>
    private static async Task<(int Hekim, int Kurum)> BagliHekimAcAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int sube)
    {
        var kurum = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('LAB PRIM BAGLI KURUM', @p1, 1, @p0) returning id",
            t, [sube, $"LGK{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        var hekim = await HekimAcAsync(b, t, sube, 1);
        await b.CalistirAsync("update public.taraf set bag_id = @p1 where id = @p0",
            t, [hekim, kurum], Iptal);
        return (hekim, kurum);
    }

    private static Task<int> HastaAcAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube)
        => b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id) "
            + "values ('LAB PRIM HASTA', @p1, 1, @p0) returning id",
            t, [sube, $"LGH{Guid.NewGuid().ToString("N")[..8]}"], Iptal);

    /// <summary>Lab hizmeti + `lab_tetkik` karşılığı: kalem böyle tanınır.</summary>
    private static async Task<int> LabHizmetiAcAsync(NpgsqlConnection b,
        NpgsqlTransaction t, int sube)
    {
        var kod = $"LGT{Guid.NewGuid().ToString("N")[..8]}";
        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, sube_id) "
            + "values (@p0, 'LAB PRIM TETKIK', @p1) returning id",
            t, [kod, sube], Iptal);
        await b.CalistirAsync(
            "insert into public.lab_tetkik (kod, ad, hizmet_id, durum, sube_id) "
            + "values (@p0, 'LAB PRIM TETKIK', @p1, 0, @p2)",
            t, [kod, hizmet, sube], Iptal);
        return hizmet;
    }

    private static Task<int> BelgeAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, int hasta)
        => b.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, belge_tarihi, belge_dovizi, "
            + "  doviz_kuru, sube_id, durum) "
            + "values (15, 1, @p0, current_date, 'TL', 1, @p1, 0) returning id",
            t, [hasta, sube], Iptal);

    private static Task<int> KalemAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, int belge, int hizmet)
        => b.TekDegerAsync<int>(
            "insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, "
            + "  birim_fiyat, iskonto, kdv, doviz_cinsi, sube_id) "
            + "values (@p0, 1, 2, @p1, 1, 200, 0, 20, 'TL', @p2) returning id",
            t, [belge, hizmet, sube], Iptal);

    private static Task<int> IstemAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, int hasta, int belge, int? hekim, int? kurum)
        => b.TekDegerAsync<int>(
            "insert into public.lab_istem "
            + "       (taraf_id, sube_id, istem_tarihi, durum, personel_id, "
            + "        dis_kurum_id, belge_id) "
            + "values (@p0, @p1, current_date, 1, @p2, @p3, @p4) returning id",
            t, [hasta, sube, hekim, kurum, belge], Iptal);

    private static Task<List<int>> GonderenlerAsync(NpgsqlConnection b,
        NpgsqlTransaction t, int satir)
        => b.ListeAsync(
            "select taraf_id from public.belge_satir_rol "
            + " where belge_satir_id = @p0 and rol = 1 order by taraf_id",
            t, [satir], o => o.GetInt32(0), Iptal);

    [Fact(DisplayName = "Lab: kendi adına gönderen dış hekim Gönderen olur")]
    public async Task KendiAdinaHekim()
    {
        if (!_olgu.Baglandi(nameof(KendiAdinaHekim))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await SubeAsync(b, t);
        var hekim = await HekimAcAsync(b, t, sube, 1);        // bağımsız: bag_id yok
        var hasta = await HastaAcAsync(b, t, sube);
        var hizmet = await LabHizmetiAcAsync(b, t, sube);
        var belge = await BelgeAcAsync(b, t, sube, hasta);
        var satir = await KalemAcAsync(b, t, sube, belge, hizmet);
        await IstemAcAsync(b, t, sube, hasta, belge, hekim, null);

        Assert.Equal([hekim], await GonderenlerAsync(b, t, satir));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Lab: kurum adına gelen işte prim kuruma, hekime değil")]
    public async Task KurumAdina()
    {
        if (!_olgu.Baglandi(nameof(KurumAdina))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await SubeAsync(b, t);
        var (hekim, kurum) = await BagliHekimAcAsync(b, t, sube);
        var hasta = await HastaAcAsync(b, t, sube);
        var hizmet = await LabHizmetiAcAsync(b, t, sube);
        var belge = await BelgeAcAsync(b, t, sube, hasta);
        var satir = await KalemAcAsync(b, t, sube, belge, hizmet);
        // Kurum yazılmadı: 827 tetiği hekimin bağlı kurumundan doldurur.
        await IstemAcAsync(b, t, sube, hasta, belge, hekim, null);

        var gonderenler = await GonderenlerAsync(b, t, satir);
        Assert.Equal([kurum], gonderenler);
        Assert.DoesNotContain(hekim, gonderenler);
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Lab: iç personelin istemi gönderen primi doğurmaz")]
    public async Task IcPersonelPrimYok()
    {
        if (!_olgu.Baglandi(nameof(IcPersonelPrimYok))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await SubeAsync(b, t);
        var personel = await HekimAcAsync(b, t, sube, 0);
        var hasta = await HastaAcAsync(b, t, sube);
        var hizmet = await LabHizmetiAcAsync(b, t, sube);
        var belge = await BelgeAcAsync(b, t, sube, hasta);
        var satir = await KalemAcAsync(b, t, sube, belge, hizmet);
        await IstemAcAsync(b, t, sube, hasta, belge, personel, null);

        Assert.Empty(await GonderenlerAsync(b, t, satir));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Lab: ücret kalemi SONRA eklenince rol yazılır")]
    public async Task KalemSonraGelir()
    {
        if (!_olgu.Baglandi(nameof(KalemSonraGelir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await SubeAsync(b, t);
        var hekim = await HekimAcAsync(b, t, sube, 1);
        var hasta = await HastaAcAsync(b, t, sube);
        var hizmet = await LabHizmetiAcAsync(b, t, sube);
        var belge = await BelgeAcAsync(b, t, sube, hasta);
        // Önce KALEMSİZ belge + istem: ücretleme sonradan yapılıyor.
        await IstemAcAsync(b, t, sube, hasta, belge, hekim, null);
        var satir = await KalemAcAsync(b, t, sube, belge, hizmet);

        Assert.Equal([hekim], await GonderenlerAsync(b, t, satir));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Lab: belgede farklı göndericiler varsa otomatik rol yazılmaz")]
    public async Task FarkliGondericiRolYazmaz()
    {
        if (!_olgu.Baglandi(nameof(FarkliGondericiRolYazmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await SubeAsync(b, t);
        var hekim1 = await HekimAcAsync(b, t, sube, 1);
        var hekim2 = await HekimAcAsync(b, t, sube, 1);
        var hasta = await HastaAcAsync(b, t, sube);
        var hizmet = await LabHizmetiAcAsync(b, t, sube);
        var belge = await BelgeAcAsync(b, t, sube, hasta);
        var satir = await KalemAcAsync(b, t, sube, belge, hizmet);

        await IstemAcAsync(b, t, sube, hasta, belge, hekim1, null);
        // Aynı kaleme iki gönderen yazmak primi ikiye katlardı.
        await IstemAcAsync(b, t, sube, hasta, belge, hekim2, null);

        Assert.Empty(await GonderenlerAsync(b, t, satir));
        await t.RollbackAsync();
    }
}
