using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÜRETİM LİSTELERİNİN ÖZET ŞERİTLERİ (1254, mockup uretim_emri_listesi_v2.html / uretim_fisi_listesi.html `.ozet`).
/// Liste satırlarının kapsam süzgecinden geçmez - kurum (şube) genelini sayar; portalda yok. Hangi kutunun hangi
/// seviyede çizileceğini web seçer (uretimListeSeviye.ts), sunucu hepsini döner.
/// </summary>
public static partial class UretimFisiUclari
{
    private static void OzetUclari(RouteGroupBuilder grup)
    {
        // GET /api/uretim/emri/ozet - açık emir sayıları, plan / üretilen, termini geçen, karantina, malzeme hazırlık.
        grup.MapGet("/emri/ozet", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu özet portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var ozet = await b.TekAsync("""
                with e as (select * from public.uretim_emri e where (@p0 = 0 or e.sube_id in (0, @p0)))
                select count(*) filter (where e.durum between 1 and 5)                         as "acik",
                       count(*) filter (where e.durum = 1)                                     as "taslak",
                       count(*) filter (where e.durum = 2)                                     as "onayli",
                       count(*) filter (where e.durum = 3)                                     as "serbest",
                       count(*) filter (where e.durum in (4, 5))                               as "uretimde",
                       coalesce(sum(e.adet) filter (where e.durum between 1 and 5), 0)         as "plan",
                       coalesce(sum(e.uretilen_adet) filter (where e.durum between 1 and 5), 0) as "uretilen",
                       count(*) filter (where e.durum between 1 and 5 and e.termin < current_date) as "geciken",
                       (select x.no from e x where x.durum between 1 and 5 and x.termin < current_date
                         order by x.termin limit 1)                                            as "gecikenNo",
                       (select (current_date - x.termin) from e x where x.durum between 1 and 5 and x.termin < current_date
                         order by x.termin limit 1)                                            as "gecikenGun",
                       count(*) filter (where e.durum between 1 and 3
                                          and public.fn_uretim_malzeme_hazirlik(e.id) < 100)   as "malzemeEksik",
                       coalesce(round(avg(public.fn_uretim_malzeme_hazirlik(e.id))
                                      filter (where e.durum between 1 and 3)), 0)             as "malzemeHazirlik",
                       (select count(*) from public.uretim_fisi f where f.durum = 2 and f.seviye = 'denetimli'
                          and (@p0 = 0 or f.sube_id in (0, @p0)))                              as "karantinaParti",
                       (select coalesce(sum(f.uretilen), 0) from public.uretim_fisi f where f.durum = 2 and f.seviye = 'denetimli'
                          and (@p0 = 0 or f.sube_id in (0, @p0)))                              as "karantinaAdet"
                  from e
                """, null, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { ozet, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/fis/ozet?bas=&bit= - dönemdeki fişler (varsayılan bu ay): sayı, üretilen, malzeme, işçilik, toplam,
        //   ortalama birim; karantina ve taslak dönemden bağımsız (bekleyen iş).
        grup.MapGet("/fis/ozet", async (DateTime? bas, DateTime? bit, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis.liste", Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu özet portalda kullanılamaz.");
            var bugun = Saat.Bugun;
            var b0 = (bas ?? new DateTime(bugun.Year, bugun.Month, 1)).Date;
            var b1 = (bit ?? b0.AddMonths(1).AddDays(-1)).Date.AddDays(1);
            await using var b = await veri.AcAsync(iptal);
            var ozet = await b.TekAsync("""
                with f as (select * from public.uretim_fisi f where (@p0 = 0 or f.sube_id in (0, @p0)))
                select count(*) filter (where f.durum > 0 and f.bas >= @p1 and f.bas < @p2)            as "fis",
                       count(*) filter (where f.durum = 1)                                             as "taslak",
                       count(*) filter (where f.durum = 0 and f.bas >= @p1 and f.bas < @p2)            as "tersKayit",
                       coalesce(sum(f.uretilen) filter (where f.durum in (2, 3) and f.bas >= @p1 and f.bas < @p2), 0) as "uretilen",
                       count(distinct f.stok_id) filter (where f.durum in (2, 3) and f.bas >= @p1 and f.bas < @p2)   as "mamul",
                       (select count(*) from public.uretim_fisi_satir s join f on f.id = s.fis_id
                         where s.grup = 4 and s.ana_urun = 0 and f.durum in (2, 3) and f.bas >= @p1 and f.bas < @p2) as "yanUrun",
                       coalesce(sum(f.malzeme + f.fire_normal) filter (where f.durum in (2, 3) and f.bas >= @p1 and f.bas < @p2), 0) as "malzeme",
                       coalesce(sum(f.iscilik) filter (where f.durum in (2, 3) and f.bas >= @p1 and f.bas < @p2), 0)  as "iscilik",
                       coalesce(sum(f.toplam) filter (where f.durum in (2, 3) and f.bas >= @p1 and f.bas < @p2), 0)   as "toplam",
                       count(*) filter (where f.durum = 2 and f.seviye = 'denetimli')                                  as "karantinaParti",
                       coalesce(sum(f.uretilen) filter (where f.durum = 2 and f.seviye = 'denetimli'), 0)             as "karantinaAdet",
                       count(*) filter (where f.durum = 4 and f.bas >= @p1 and f.bas < @p2)                            as "reddedilen"
                  from f
                """, null, [baglam.SubeId ?? 0, b0, b1], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { ozet, bas = b0, bit = b1.AddDays(-1), izlemeNo = baglam.IzlemeNo });
        });
    }
}
