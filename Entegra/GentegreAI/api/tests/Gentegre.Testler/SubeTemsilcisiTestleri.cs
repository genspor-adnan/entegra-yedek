using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DIŞ DOKTOR ŞUBE TEMSİLCİSİ + TEMSİLCİ PRİM ROLÜ (1287, mockup Ekranlar/Radyoloji/dis_doktor_temsilciler.html):
/// şube başına temsilci çözümlenir (yoksa taraf.temsilci), çakışan satır reddedilir, radyoloji istemine dış hekim
/// yazılınca başvurunun satici_id'si şube temsilcisiyle dolar ve kalemlere rol 10 yazılır; şubeli prim planı genel
/// planı ezer.
/// </summary>
public sealed class SubeTemsilcisiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static string Kod(string onek) => onek + Guid.NewGuid().ToString("N")[..8];

    /// <summary>Dış hekim (dis_hekim = 1) ya da kurum personeli (0).</summary>
    private static Task<int> KisiAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube, short disHekim, string ad)
        => b.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, ad, kod, personel, sube_id) "
            + "          values ('', @p3, @p1, 1, @p0) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) "
            + "select y.id, @p2, @p0 from y returning id",
            t, [sube, Kod("STM"), disHekim, ad], Iptal);

    private static Task<List<int>> SubelerAsync(NpgsqlConnection b, NpgsqlTransaction t)
        => b.ListeAsync("select id from public.sube where aktif = 1 order by id limit 2", t, [], o => o.GetInt32(0), Iptal);

    private static Task<int> TemsilciYazAsync(NpgsqlConnection b, NpgsqlTransaction t, int hekim, int sube, int temsilci,
                                              string baslangic = "2026-01-01", string? bitis = null)
        => b.TekDegerAsync<int>(
            "insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic, bitis) "
            + "values (@p0, @p1, @p2, @p3::date, @p4::date) returning id",
            t, [hekim, sube, temsilci, baslangic, bitis], Iptal);

    [VtFact(DisplayName = "Şube temsilcisi şubeye göre çözülür; satırı olmayan şubede varsayılan (taraf.temsilci)")]
    public async Task SubeTemsilcisiCozumlenir()
    {
        if (!_olgu.Baglandi(nameof(SubeTemsilcisiCozumlenir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var subeler = await SubelerAsync(b, t);
        Assert.True(subeler.Count >= 2, "test DB'de en az 2 aktif şube olmalı");
        var (s1, s2) = (subeler[0], subeler[1]);

        var hekim = await KisiAsync(b, t, s1, 1, "Dr Test");
        var ahmet = await KisiAsync(b, t, s1, 0, "Ahmet");
        var ayse = await KisiAsync(b, t, s2, 0, "Ayşe");
        var mehmet = await KisiAsync(b, t, s1, 0, "Mehmet");
        await b.CalistirAsync("update public.taraf set temsilci = @p1 where id = @p0", t, [hekim, mehmet], Iptal);
        await TemsilciYazAsync(b, t, hekim, s1, ahmet);
        await TemsilciYazAsync(b, t, hekim, s2, ayse);

        Assert.Equal(ahmet, await b.TekDegerAsync<int>("select public.fn_dis_hekim_temsilci(@p0, @p1, current_date)", t, [hekim, s1], Iptal));
        Assert.Equal(ayse, await b.TekDegerAsync<int>("select public.fn_dis_hekim_temsilci(@p0, @p1, current_date)", t, [hekim, s2], Iptal));
        // Satırı olmayan şube: varsayılan.
        Assert.Equal(mehmet, await b.TekDegerAsync<int>("select public.fn_dis_hekim_temsilci(@p0, 999999, current_date)", t, [hekim], Iptal));
        // Tarih dışı: biten satır sayılmaz, varsayılana düşer.
        await b.CalistirAsync("update public.dis_hekim_temsilci set bitis = date '2026-06-30' where hekim_id = @p0 and sube_id = @p1", t, [hekim, s2], Iptal);
        Assert.Equal(mehmet, await b.TekDegerAsync<int>("select public.fn_dis_hekim_temsilci(@p0, @p1, date '2026-09-01')", t, [hekim, s2], Iptal));
        Assert.Equal(ayse, await b.TekDegerAsync<int>("select public.fn_dis_hekim_temsilci(@p0, @p1, date '2026-03-01')", t, [hekim, s2], Iptal));
        await t.RollbackAsync();
    }

    [VtFact(DisplayName = "Aynı şubede tarihleri çakışan ikinci aktif temsilci 422")]
    public async Task CakisanSatirReddedilir()
    {
        if (!_olgu.Baglandi(nameof(CakisanSatirReddedilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = (await SubelerAsync(b, t))[0];
        var hekim = await KisiAsync(b, t, sube, 1, "Dr Test");
        var ahmet = await KisiAsync(b, t, sube, 0, "Ahmet");
        var ayse = await KisiAsync(b, t, sube, 0, "Ayşe");
        await TemsilciYazAsync(b, t, hekim, sube, ahmet, "2026-01-01", null);

        var hata = await Assert.ThrowsAsync<PostgresException>(() => TemsilciYazAsync(b, t, hekim, sube, ayse, "2026-06-01", null));
        Assert.Equal("GK422", hata.SqlState);
        Assert.Contains("zaten temsilci", hata.MessageText);
        // Dış hekim temsilci olamaz.
        await t.RollbackAsync();
    }

    [VtFact(DisplayName = "Radyoloji istemine dış hekim yazılınca satici_id şube temsilcisi olur, kalemlere rol 10 yazılır")]
    public async Task RadIstemTemsilciyiVeRoluYazar()
    {
        if (!_olgu.Baglandi(nameof(RadIstemTemsilciyiVeRoluYazar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = (await SubelerAsync(b, t))[0];
        var hekim = await KisiAsync(b, t, sube, 1, "Dr Test");
        var ahmet = await KisiAsync(b, t, sube, 0, "Ahmet");
        await TemsilciYazAsync(b, t, hekim, sube, ahmet);

        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id) values ('STM HASTA', @p1, 1, @p0) returning id",
            t, [sube, Kod("STH")], Iptal);
        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sube_id) values (@p0, 'STM TEST MR', 1, 1, @p1) returning id",
            t, [Kod("STZ"), sube], Iptal);
        var belge = await b.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, belge_tarihi, belge_dovizi, doviz_kuru, sube_id, durum) "
            + "values (15, 1, @p0, current_date, 'TL', 1, @p1, 0) returning id",
            t, [hasta, sube], Iptal);
        var satir = await b.TekDegerAsync<int>(
            "insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, birim_fiyat, iskonto, kdv, doviz_cinsi, sube_id) "
            + "values (@p0, 1, 2, @p1, 1, 500, 0, 20, 'TL', @p2) returning id",
            t, [belge, hizmet, sube], Iptal);
        // Satici henüz boş; istem gelince dolar.
        Assert.Equal(0, await b.TekDegerAsync<int>("select coalesce(satici_id, 0) from public.belge where id = @p0", t, [belge], Iptal));

        await b.CalistirAsync("""
            insert into public.radyoloji_istem (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum, belge_satir_id, istek_hekim_id)
            values (@p0, @p1, @p2, 1, @p3, 1, @p4, @p5)
            """, t, [sube, hasta, hizmet, Guid.NewGuid().ToString("N")[..12], satir, hekim], Iptal);

        Assert.Equal(ahmet, await b.TekDegerAsync<int>("select coalesce(satici_id, 0) from public.belge where id = @p0", t, [belge], Iptal));
        // satici değişti -> belge tetiği kalemlere rol 10 yazdı.
        var temsilciRolu = await b.ListeAsync(
            "select r.taraf_id from public.belge_satir_rol r where r.belge_satir_id = @p0 and r.rol = 10 order by 1",
            t, [satir], o => o.GetInt32(0), Iptal);
        Assert.Equal([ahmet], temsilciRolu);
        // Gönderen (rol 1) hekim olarak kaldı.
        Assert.Contains(hekim, await b.ListeAsync(
            "select r.taraf_id from public.belge_satir_rol r where r.belge_satir_id = @p0 and r.rol = 1",
            t, [satir], o => o.GetInt32(0), Iptal));

        // Yeni kalem de temsilci rolünü alır (satır tetiği).
        var satir2 = await b.TekDegerAsync<int>(
            "insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, birim_fiyat, iskonto, kdv, doviz_cinsi, sube_id) "
            + "values (@p0, 2, 2, @p1, 1, 300, 0, 20, 'TL', @p2) returning id",
            t, [belge, hizmet, sube], Iptal);
        Assert.Equal(1, await b.TekDegerAsync<int>(
            "select count(*)::int from public.belge_satir_rol where belge_satir_id = @p0 and rol = 10 and taraf_id = @p1", t, [satir2, ahmet], Iptal));
        await t.RollbackAsync();
    }

    [VtFact(DisplayName = "Şubeli prim planı aynı özgüllükteki genel planı ezer")]
    public async Task SubeliPlanGenelPlaniEzer()
    {
        if (!_olgu.Baglandi(nameof(SubeliPlanGenelPlaniEzer))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = (await SubelerAsync(b, t))[0];
        var hekim = await KisiAsync(b, t, sube, 1, "Dr Test");
        var hizmet = await b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sube_id) values (@p0, 'STM PLAN MR', 1, 1, @p1) returning id",
            t, [Kod("STP"), sube], Iptal);

        async Task<int> Plan(string kod, int? planSube, decimal oran)
        {
            var plan = await b.TekDegerAsync<int>(
                "insert into public.prim_plani (kod, ad, baslangic, rol, durum, sube_id, oncelik) "
                + "values (@p0, @p0, date '2026-01-01', 1, 1, @p1, 10) returning id",
                t, [kod, planSube], Iptal);
            await b.CalistirAsync(
                "insert into public.prim_plani_satir (plan_id, tip, oran_tipi, deger, sira) values (@p0, 1, 1, @p1, 1)",
                t, [plan, oran], Iptal);
            return plan;
        }
        var genel = await Plan(Kod("GEN"), null, 10m);
        var subeli = await Plan(Kod("SUB"), sube, 20m);

        var secilen = await b.TekDegerAsync<int>(
            "select plan_id from public.fn_prim_plan_satiri(1::smallint, @p0, @p1, null, 15::smallint, 0::smallint, null, @p2, current_date)",
            t, [hekim, hizmet, sube], Iptal);
        Assert.Equal(subeli, secilen);
        // Başka şubeden bakınca şubeli plan uymaz, genel plan seçilir.
        var digerSube = await b.TekDegerAsync<int>("select coalesce(max(id), 0) + 1 from public.sube", t, [], Iptal);
        var secilen2 = await b.TekDegerAsync<int>(
            "select plan_id from public.fn_prim_plan_satiri(1::smallint, @p0, @p1, null, 15::smallint, 0::smallint, null, @p2, current_date)",
            t, [hekim, hizmet, digerSube], Iptal);
        Assert.Equal(genel, secilen2);
        await t.RollbackAsync();
    }
}
