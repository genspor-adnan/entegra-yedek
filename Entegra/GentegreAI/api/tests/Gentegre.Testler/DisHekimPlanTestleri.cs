using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DIŞ DOKTOR ZİYARET PLANI (1290, mockup temsilci_ziyaret.html §3): vade görünümü sıklıktan gecikmeyi hesaplar,
/// fn_dis_hekim_plan_uret vadesi dolan hekime haftaya ÖNERİ açar, ikinci çağrı tekrar açmaz, gün başı sınırı tutar.
/// </summary>
public sealed class DisHekimPlanTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static Task<int> KisiAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube, short disHekim, string ad, short siklik = 0)
        => b.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, ad, kod, personel, durum, sube_id) "
            + "          values ('', @p3, @p1, 1, 1, @p0) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id, ziyaret_sikligi_hafta) "
            + "select y.id, @p2, @p0, @p4 from y returning id",
            t, [sube, "DZP" + Guid.NewGuid().ToString("N")[..8], disHekim, ad, siklik], Iptal);

    [VtFact(DisplayName = "Vade: sıklık + son ziyaret gecikmeyi verir; Planı Üret öneri açar, tekrar açmaz")]
    public async Task VadeVePlanUret()
    {
        if (!_olgu.Baglandi(nameof(VadeVePlanUret))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var temsilci = await KisiAsync(b, t, sube, 0, "Temsilci");
        var h1 = await KisiAsync(b, t, sube, 1, "Dr Gecikmis", 4);
        var h2 = await KisiAsync(b, t, sube, 1, "Dr Yeni", 4);
        var h3 = await KisiAsync(b, t, sube, 1, "Dr Sikliksiz", 0);
        foreach (var h in new[] { h1, h2, h3 })
            await b.CalistirAsync("insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')",
                                  t, [h, sube, temsilci], Iptal);
        // h1: 6 hafta önce yapılmış ziyaret -> vade 2 hafta geçti. h2: hiç ziyaret yok -> vade = kayıt + 4 hafta (gelecek).
        await b.CalistirAsync("""
            insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, durum, sonuc, hatirlat)
            values (@p0, @p1, @p2, now() - interval '42 days', 1, 1, 0)
            """, t, [h1, temsilci, sube], Iptal);

        var v1 = await b.TekAsync("select gecikme_gun, vade_tarihi, planli_ziyaret_id from public.v_dis_hekim_ziyaret_vade where hekim_id = @p0 and temsilci_id = @p1",
                                  t, [h1, temsilci], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.InRange(Convert.ToInt32(v1!["gecikme_gun"]), 13, 15);
        Assert.True(v1["planli_ziyaret_id"] is null or DBNull);
        var v2 = await b.TekAsync("select gecikme_gun from public.v_dis_hekim_ziyaret_vade where hekim_id = @p0 and temsilci_id = @p1",
                                  t, [h2, temsilci], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.Equal(0, Convert.ToInt32(v2!["gecikme_gun"]));
        var v3 = await b.TekAsync("select vade_tarihi from public.v_dis_hekim_ziyaret_vade where hekim_id = @p0 and temsilci_id = @p1",
                                  t, [h3, temsilci], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.True(v3!["vade_tarihi"] is null or DBNull);

        // Gelecek hafta için üret: yalnız h1 (vadesi dolan, sıklıklı, planı yok).
        var haftaBas = DateOnly.FromDateTime(DateTime.Today.AddDays(7 - ((int)DateTime.Today.DayOfWeek + 6) % 7));
        var sayi = await b.TekDegerAsync<int>("select public.fn_dis_hekim_plan_uret(@p0, @p1, @p2, 6, true, 0)",
                                              t, [temsilci, sube, haftaBas], Iptal);
        Assert.Equal(1, sayi);
        var oneri = await b.TekAsync("""
            select hekim_id, oneri, durum, tarih::date as gun from public.dis_hekim_ziyaret
             where temsilci_id = @p0 and durum = 0 order by id desc limit 1
            """, t, [temsilci], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.Equal(h1, Convert.ToInt32(oneri!["hekim_id"]));
        Assert.Equal(1, Convert.ToInt32(oneri["oneri"]));
        var gun = DateOnly.FromDateTime(Convert.ToDateTime(oneri["gun"]));
        Assert.InRange(gun.DayNumber - haftaBas.DayNumber, 0, 4);
        // Artık planı var: ikinci çağrı açmaz; vade görünümü planlıyı gösterir.
        Assert.Equal(0, await b.TekDegerAsync<int>("select public.fn_dis_hekim_plan_uret(@p0, @p1, @p2, 6, true, 0)",
                                                   t, [temsilci, sube, haftaBas], Iptal));
        Assert.Equal(1, await b.TekDegerAsync<int>("select coalesce(planli_oneri, 0)::int from public.v_dis_hekim_ziyaret_vade where hekim_id = @p0 and temsilci_id = @p1",
                                                   t, [h1, temsilci], Iptal));
        await t.RollbackAsync();
    }

    [VtFact(DisplayName = "Gün başı sınırı: 7 hekim, gün başı 1 -> 5 öneri, 2 bekler")]
    public async Task GunBasiSiniri()
    {
        if (!_olgu.Baglandi(nameof(GunBasiSiniri))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var temsilci = await KisiAsync(b, t, sube, 0, "Temsilci2");
        for (var i = 0; i < 7; i++)
        {
            var h = await KisiAsync(b, t, sube, 1, $"Dr {i}", 2);
            await b.CalistirAsync("insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')",
                                  t, [h, sube, temsilci], Iptal);
            await b.CalistirAsync("update public.taraf set ekleme_tarihi = now() - interval '60 days' where id = @p0", t, [h], Iptal);
        }
        var haftaBas = DateOnly.FromDateTime(DateTime.Today.AddDays(7 - ((int)DateTime.Today.DayOfWeek + 6) % 7));
        var sayi = await b.TekDegerAsync<int>("select public.fn_dis_hekim_plan_uret(@p0, @p1, @p2, 1, false, 0)",
                                              t, [temsilci, sube, haftaBas], Iptal);
        Assert.Equal(5, sayi);
        await t.RollbackAsync();
    }
}
