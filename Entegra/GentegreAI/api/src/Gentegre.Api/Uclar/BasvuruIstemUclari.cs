using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BAŞVURU → İSTEM BANKO KAPISI (912). Poliklinikte hekimin muayenede açtığı
/// lab/radyoloji isteği <c>serbest=0</c> ile başvuruya düşer; laboratuvar ve
/// radyoloji çalışma listesinde GÖRÜNMEZ. Banko tetkiği ücretlendirip
/// <b>serbest bırakınca</b> (serbest=1) istem worklist'e iner. Ödeme ayrı
/// aşamadır - serbest bırakmak "ücretlendirildi/kabule hazır" demektir, tahsilat
/// sonraya kalabilir. Acil/yatan/dış/banko kaynaklı istemler zaten serbest=1
/// gelir, burada listelenmez.
/// </summary>
public static class BasvuruIstemUclari
{
    public sealed record SerbestIstegi(int[]? LabIstemIdler, int[]? RadyolojiIstemIdler);

    public static void BasvuruIstemUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/basvuru").WithTags("Başvuru · Banko").RequireAuthorization();

        // BEKLEYEN İSTEMLER: banko ücretlendirme ekranı - hekimin açtığı ama
        //   henüz serbest bırakılmamış lab/radyoloji istekleri.
        grup.MapGet("/{belgeId:int}/bekleyen-istem", async (
            int belgeId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var lab = await b.ListeAsync("""
                select i.id, i.oncelik,
                       coalesce((select string_agg(t.ad, ', ' order by t.ad)
                                   from public.lab_istem_satir s
                                   join public.lab_tetkik t on t.id = s.tetkik_id
                                  where s.istem_id = i.id and s.durum <> 0), '') as tetkikler
                  from public.lab_istem i
                 where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 9
                 order by i.id
                """, null, [belgeId],
                o => new { tur = "lab", id = o.GetInt32(0), oncelik = o.GetInt16(1),
                           tetkik = o.GetString(2) }, iptal);

            var rad = await b.ListeAsync("""
                select i.id, i.oncelik, coalesce(hz.ad, '') as tetkik
                  from public.radyoloji_istem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                 where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 0
                 order by i.id
                """, null, [belgeId],
                o => new { tur = "radyoloji", id = o.GetInt32(0), oncelik = o.GetInt16(1),
                           tetkik = o.GetString(2) }, iptal);

            return Results.Ok(new { lab, radyoloji = rad,
                                    toplam = lab.Count + rad.Count,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // SERBEST BIRAK: banko ücretlendirdi → istemler worklist'e düşsün.
        //   Id verilmezse başvurunun TÜM bekleyen istemleri serbest bırakılır.
        grup.MapPost("/{belgeId:int}/istem-serbest", async (
            int belgeId, SerbestIstegi? istek, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);

            var labIds = istek?.LabIstemIdler;
            var radIds = istek?.RadyolojiIstemIdler;
            var hepsi = (labIds is null || labIds.Length == 0)
                      && (radIds is null || radIds.Length == 0);

            var labN = await b.CalistirAsync("""
                update public.lab_istem set serbest = 1, degistiren = @p1, degistirme_tarihi = now()
                 where belge_id = @p0 and serbest = 0
                   and (@p2::bool or id = any(@p3))
                """, null, [belgeId, baglam.KullaniciId, hepsi, labIds ?? []], iptal);

            var radN = await b.CalistirAsync("""
                update public.radyoloji_istem set serbest = 1, degistiren = @p1, degistirme_tarihi = now()
                 where belge_id = @p0 and serbest = 0
                   and (@p2::bool or id = any(@p3))
                """, null, [belgeId, baglam.KullaniciId, hepsi, radIds ?? []], iptal);

            return Results.Ok(new { lab = labN, radyoloji = radN, toplam = labN + radN,
                                    mesaj = labN + radN == 0
                                        ? "Serbest bırakılacak bekleyen istem yok."
                                        : $"{labN + radN} istem serbest bırakıldı, çalışma listelerine düştü.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
