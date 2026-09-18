using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// GÖNDEREN PRİMİ: KENDİ ADINA GÖNDERENE (825).
///
/// Kullanıcı: *"kendi adına hasta gönderen doktor eğer tanımlıysa gönderen
/// primi alır"* · *"kurum adına hasta gönderen doktor prim almaz"*.
///
/// Ölçüt kişinin kartı değil İSTEMİN SATIRI: <c>istek_kurum_id</c> doluysa iş
/// kurum adına gelmiştir. Böylece kuruma bağlı bir hekim kendi özel hastasını
/// gönderdiğinde (kurum boş) primi yine hak eder.
/// </summary>
public sealed class GonderenPrimiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static Task<int> HizmetAcAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube)
        => b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sube_id) "
            + "values (@p0, 'GONDEREN PRIMI TEST BT', 1, 1, @p1) returning id",
            t, [$"GPR{Guid.NewGuid().ToString("N")[..8]}", sube], Iptal);

    /// <summary>Dış hekim (dis_hekim = 1) ya da iç personel.</summary>
    private static Task<int> HekimAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, short disHekim)
        => b.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, kod, personel, sube_id) "
            + "          values (@p1, @p1, 1, @p0) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) "
            + "select y.id, @p2, @p0 from y returning id",
            t, [sube, $"GPR{Guid.NewGuid().ToString("N")[..8]}", disHekim], Iptal);

    /// <summary>Ücretlendirilmiş istem: rol türetimi kalem olmadan çalışmaz.</summary>
    private static async Task<int> IstemAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, int? hekim, int? kurum)
    {
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id) "
            + "values ('GONDEREN PRIMI HASTA', @p1, 1, @p0) returning id",
            t, [sube, $"GPH{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        var hizmet = await HizmetAcAsync(b, t, sube);
        var belge = await b.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, belge_tarihi, belge_dovizi, "
            + "  doviz_kuru, sube_id, durum) "
            + "values (15, 1, @p0, current_date, 'TL', 1, @p1, 0) returning id",
            t, [hasta, sube], Iptal);
        var satir = await b.TekDegerAsync<int>(
            "insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, "
            + "  birim_fiyat, iskonto, kdv, doviz_cinsi, sube_id) "
            + "values (@p0, 1, 2, @p1, 1, 500, 0, 20, 'TL', @p2) returning id",
            t, [belge, hizmet, sube], Iptal);

        return await b.TekDegerAsync<int>("""
            insert into public.radyoloji_istem
                   (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum,
                    belge_satir_id, istek_hekim_id, istek_kurum_id)
            values (@p0, @p1, @p2, 1, @p3, 1, @p4, @p5, @p6) returning id
            """,
            t, [sube, hasta, hizmet, Guid.NewGuid().ToString("N")[..12], satir,
                hekim, kurum], Iptal);
    }

    /// <summary>Kalemin Gönderen (rol 1) tarafları.</summary>
    private static async Task<List<int>> GonderenlerAsync(NpgsqlConnection b,
        NpgsqlTransaction t, int istem)
        => await b.ListeAsync(
            "select r.taraf_id from public.belge_satir_rol r "
            + "  join public.radyoloji_istem i on i.belge_satir_id = r.belge_satir_id "
            + " where i.id = @p0 and r.rol = 1 order by r.taraf_id",
            t, [istem], o => o.GetInt32(0), Iptal);

    private static Task<List<int>> IsteyenlerAsync(NpgsqlConnection b,
        NpgsqlTransaction t, int istem)
        => b.ListeAsync(
            "select r.taraf_id from public.belge_satir_rol r "
            + "  join public.radyoloji_istem i on i.belge_satir_id = r.belge_satir_id "
            + " where i.id = @p0 and r.rol = 2 order by r.taraf_id",
            t, [istem], o => o.GetInt32(0), Iptal);

    [Fact(DisplayName = "Kendi adına gönderen dış hekim Gönderen olur")]
    public async Task KendiAdinaGonderenHekim()
    {
        if (!_olgu.Baglandi(nameof(KendiAdinaGonderenHekim))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hekim = await HekimAcAsync(b, t, sube, 1);
        var istem = await IstemAcAsync(b, t, sube, hekim, null);

        Assert.Equal([hekim], await GonderenlerAsync(b, t, istem));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Kurum adına gelen işte hekim prim almaz, Gönderen kurumdur")]
    public async Task KurumAdinaGonderenHekimAlmaz()
    {
        if (!_olgu.Baglandi(nameof(KurumAdinaGonderenHekimAlmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hekim = await HekimAcAsync(b, t, sube, 1);
        var kurum = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('GONDEREN PRIMI KURUM', @p1, 1, @p0) returning id",
            t, [sube, $"GPK{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        var istem = await IstemAcAsync(b, t, sube, hekim, kurum);

        var gonderenler = await GonderenlerAsync(b, t, istem);
        Assert.Equal([kurum], gonderenler);
        Assert.DoesNotContain(hekim, gonderenler);
        // Hekim "İsteyen" olarak da yazılmaz: o rol kurum personelinin.
        Assert.DoesNotContain(hekim, await IsteyenlerAsync(b, t, istem));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "İç hekim İsteyen kalır, Gönderen olmaz")]
    public async Task IcHekimIsteyen()
    {
        if (!_olgu.Baglandi(nameof(IcHekimIsteyen))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hekim = await HekimAcAsync(b, t, sube, 0);
        var istem = await IstemAcAsync(b, t, sube, hekim, null);

        Assert.Equal([hekim], await IsteyenlerAsync(b, t, istem));
        Assert.Empty(await GonderenlerAsync(b, t, istem));
        await t.RollbackAsync();
    }

    // ---------------------------------------------------- istem kurumu (826) ----

    /// <summary>Kuruma BAĞLI dış hekim: kartında `taraf.bag_id` dolu.</summary>
    private static async Task<(int Hekim, int Kurum)> BagliHekimAcAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int sube)
    {
        var kurum = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('GONDEREN PRIMI BAGLI KURUM', @p1, 1, @p0) returning id",
            t, [sube, $"GPB{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        var hekim = await HekimAcAsync(b, t, sube, 1);
        await b.CalistirAsync("update public.taraf set bag_id = @p1 where id = @p0",
            t, [hekim, kurum], Iptal);
        return (hekim, kurum);
    }

    private static Task<int?> IstemKurumuAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int istem)
        => b.TekDegerAsync<int?>(
            "select istek_kurum_id from public.radyoloji_istem where id = @p0",
            t, [istem], Iptal);

    [Fact(DisplayName = "Bağlı hekimin istemi kurumu bağlı kurumdan alır (826)")]
    public async Task BagliHekimKurumuOtomatik()
    {
        if (!_olgu.Baglandi(nameof(BagliHekimKurumuOtomatik))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var (hekim, kurum) = await BagliHekimAcAsync(b, t, sube);
        // Ekran kurum YAZMIYOR: tetik hekimin kartından doldurmalı.
        var istem = await IstemAcAsync(b, t, sube, hekim, null);

        Assert.Equal(kurum, await IstemKurumuAsync(b, t, istem));
        // 825 ile birlikte: prim kuruma, hekime değil.
        Assert.Equal([kurum], await GonderenlerAsync(b, t, istem));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Kurum elle boşaltılırsa tetik geri doldurmaz (kendi adına)")]
    public async Task ElleBosaltilanKurumGeriDolmaz()
    {
        if (!_olgu.Baglandi(nameof(ElleBosaltilanKurumGeriDolmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var (hekim, _) = await BagliHekimAcAsync(b, t, sube);
        var istem = await IstemAcAsync(b, t, sube, hekim, null);

        // Hekim kendi özel hastasını gönderiyor: memur kurumu boşaltır.
        await b.CalistirAsync(
            "update public.radyoloji_istem set istek_kurum_id = null where id = @p0",
            t, [istem], Iptal);

        Assert.Null(await IstemKurumuAsync(b, t, istem));
        // Kendi adına: gönderen primi HEKİME.
        Assert.Equal([hekim], await GonderenlerAsync(b, t, istem));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Bağımsız hekimin istemi kurumsuz kalır")]
    public async Task BagimsizHekimKurumsuz()
    {
        if (!_olgu.Baglandi(nameof(BagimsizHekimKurumsuz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hekim = await HekimAcAsync(b, t, sube, 1);   // bag_id YOK
        var istem = await IstemAcAsync(b, t, sube, hekim, null);

        Assert.Null(await IstemKurumuAsync(b, t, istem));
        Assert.Equal([hekim], await GonderenlerAsync(b, t, istem));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Elle seçilmiş kurum hekimin bağlı kurumunu EZMEZ")]
    public async Task ElleSecilenKurumKorunur()
    {
        if (!_olgu.Baglandi(nameof(ElleSecilenKurumKorunur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var (hekim, _) = await BagliHekimAcAsync(b, t, sube);
        var baskaKurum = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('GONDEREN PRIMI BASKA KURUM', @p1, 1, @p0) returning id",
            t, [sube, $"GPX{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        // Hekim iki kurumda çalışıyor, bu iş ÖTEKİ kurumun.
        var istem = await IstemAcAsync(b, t, sube, hekim, baskaKurum);

        Assert.Equal(baskaKurum, await IstemKurumuAsync(b, t, istem));
        Assert.Equal([baskaKurum], await GonderenlerAsync(b, t, istem));
        await t.RollbackAsync();
    }

    // -------------------------------------------------------- lab (827) ----

    /// <summary>Lab istemi: gönderen hekim `personel_id`, kurum `dis_kurum_id`.</summary>
    private static Task<int> LabIstemAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, int hasta, int? hekim, int? kurum)
        => b.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (taraf_id, sube_id, istem_tarihi, durum, personel_id, dis_kurum_id)
            values (@p0, @p1, current_date, 1, @p2, @p3) returning id
            """, t, [hasta, sube, hekim, kurum], Iptal);

    private static Task<int?> LabKurumuAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int istem)
        => b.TekDegerAsync<int?>(
            "select dis_kurum_id from public.lab_istem where id = @p0", t, [istem], Iptal);

    private static Task<int> HastaAcAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube)
        => b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id) "
            + "values ('GONDEREN PRIMI LAB HASTA', @p1, 1, @p0) returning id",
            t, [sube, $"GPL{Guid.NewGuid().ToString("N")[..8]}"], Iptal);

    [Fact(DisplayName = "Lab isteminde kurum bağlı kurumdan dolar (827)")]
    public async Task LabKurumuOtomatik()
    {
        if (!_olgu.Baglandi(nameof(LabKurumuOtomatik))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var (hekim, kurum) = await BagliHekimAcAsync(b, t, sube);
        var hasta = await HastaAcAsync(b, t, sube);
        var istem = await LabIstemAcAsync(b, t, sube, hasta, hekim, null);

        Assert.Equal(kurum, await LabKurumuAsync(b, t, istem));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "Lab: elle boşaltılan kurum geri dolmaz")]
    public async Task LabElleBosaltilanKurum()
    {
        if (!_olgu.Baglandi(nameof(LabElleBosaltilanKurum))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var (hekim, _) = await BagliHekimAcAsync(b, t, sube);
        var hasta = await HastaAcAsync(b, t, sube);
        var istem = await LabIstemAcAsync(b, t, sube, hasta, hekim, null);

        await b.CalistirAsync(
            "update public.lab_istem set dis_kurum_id = null where id = @p0",
            t, [istem], Iptal);

        Assert.Null(await LabKurumuAsync(b, t, istem));
        await t.RollbackAsync();
    }

    [Fact(DisplayName = "İç personelin bağlı carisi istem kurumu SAYILMAZ (827)")]
    public async Task IcPersonelBagliCariKurumOlmaz()
    {
        if (!_olgu.Baglandi(nameof(IcPersonelBagliCariKurumOlmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        // İÇ personel (dis_hekim = 0) ama kartında "Bağlı Cari" dolu.
        var personel = await HekimAcAsync(b, t, sube, 0);
        var cari = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('GONDEREN PRIMI IC CARI', @p1, 1, @p0) returning id",
            t, [sube, $"GPI{Guid.NewGuid().ToString("N")[..8]}"], Iptal);
        await b.CalistirAsync("update public.taraf set bag_id = @p1 where id = @p0",
            t, [personel, cari], Iptal);

        var radIstem = await IstemAcAsync(b, t, sube, personel, null);
        var hasta = await HastaAcAsync(b, t, sube);
        var labIstem = await LabIstemAcAsync(b, t, sube, hasta, personel, null);

        // Bağlı cari bir "gönderen kurum" değildir: prim oraya kaymamalı.
        Assert.Null(await IstemKurumuAsync(b, t, radIstem));
        Assert.Null(await LabKurumuAsync(b, t, labIstem));
        Assert.Empty(await GonderenlerAsync(b, t, radIstem));
        await t.RollbackAsync();
    }
}
