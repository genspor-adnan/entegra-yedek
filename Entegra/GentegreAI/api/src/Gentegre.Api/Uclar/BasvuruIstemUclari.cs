using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

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

        // DOKTOR İSTEMİNİ ÜCRETLENDİR: başvurunun bekleyen (serbest=0) lab/
        //   radyoloji istemlerinin hizmetlerini ÜCRET satırı olarak başvuruya
        //   ekler (fiyat listesi + sözleşme iskontosu + karşılama). Ücret satırı
        //   eklenince belge_satir tetiği istemleri serbest bırakır (worklist'e
        //   düşer). Banko "Doktor İstemi" düğmesinden çağırır.
        grup.MapPost("/{belgeId:int}/istem-ucretlendir", async (
            int belgeId, VeriKaynagi veri, BelgeDeposu belgeDepo, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);

            // Faturalanacak hizmetler: radyoloji istemin hizmeti; lab istemin
            //   tetkiklerinin hizmeti. Zaten başvuruda ücret satırı olan hizmet
            //   atlanır (mükerrer kalem olmasın).
            var hizmetler = await b.ListeAsync("""
                select distinct hz.id, coalesce(hz.modalite, 0) as modalite
                  from (
                    select i.hizmet_id as hid from public.radyoloji_istem i
                     where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 0 and i.hizmet_id is not null
                    union
                    select t.hizmet_id from public.lab_istem i
                      join public.lab_istem_satir s on s.istem_id = i.id
                      join public.lab_tetkik t on t.id = s.tetkik_id
                     where i.belge_id = @p0 and i.serbest = 0 and i.durum <> 9 and s.durum <> 0
                       and t.hizmet_id is not null
                  ) q
                  join public.hizmet hz on hz.id = q.hid
                 where not exists (select 1 from public.belge_satir bs
                                    where bs.belge_id = @p0 and bs.hizmet_id = hz.id)
                """, null, [belgeId], o => (Id: o.GetInt32(0), Modalite: o.GetInt32(1)), iptal);

            if (hizmetler.Count == 0)
                return Results.Ok(new { eklenen = 0, mesaj = "Ücretlendirilecek bekleyen doktor istemi yok.",
                                        izlemeNo = baglam.IzlemeNo });

            // Sözleşme iskonto (modül) + karşılama (kurum payı) - başvuruda ödeyen
            //   kurum sözleşmesinden; yoksa 0 (hasta öder, iskontosuz).
            var labIsk = await b.TekDegerAsync<int>("select coalesce(s.lab_iskonto,0) from public.belge_basvuru bb join public.kurum_sozlesme s on s.id=bb.sozlesme_id where bb.id=@p0", null, [belgeId], iptal);
            var radIsk = await b.TekDegerAsync<int>("select coalesce(s.rad_iskonto,0) from public.belge_basvuru bb join public.kurum_sozlesme s on s.id=bb.sozlesme_id where bb.id=@p0", null, [belgeId], iptal);
            var karsilama = await b.TekDegerAsync<decimal>("select coalesce(s.varsayilan_karsilama,0) from public.belge_basvuru bb join public.kurum_sozlesme s on s.id=bb.sozlesme_id where bb.id=@p0", null, [belgeId], iptal);
            var hastaId = await b.TekDegerAsync<int>("select taraf_id from public.belge where id=@p0", null, [belgeId], iptal);
            var kampanya = await b.TekDegerAsync<int?>("select kampanya_id from public.belge where id=@p0", null, [belgeId], iptal);

            var (belge, satirlar) = await BelgeGovdesi.OkuAsync(b, belgeId, iptal);
            var sira = satirlar.Count;
            foreach (var h in hizmetler)
            {
                var fiyat = await b.TekDegerAsync<decimal>("""
                    select coalesce(
                        (select fs.fiyat from public.fiyat_listesi_satir fs join public.belge bl on bl.id=@p2
                          where fs.liste_id=bl.fiyat_listesi_id and fs.hizmet_id=@p1 limit 1),
                        (select f.fiyat from public.fn_belge_kalem_fiyati(@p0,2::smallint,null,@p1,current_date) f limit 1),
                        0)
                    """, null, [hastaId, h.Id, belgeId], iptal);
                if (kampanya is int kid && kid > 0 && fiyat > 0)
                    fiyat = await b.TekDegerAsync<decimal>("select coalesce(f.fiyat,@p3) from public.fn_kampanya_fiyat(@p0,null,@p1,@p2) f limit 1", null, [kid, h.Id, fiyat, fiyat], iptal);
                var kdv = await b.TekDegerAsync<int>("select coalesce(kdv,0) from public.hizmet where id=@p0", null, [h.Id], iptal);
                var iskonto = h.Modalite > 0 ? radIsk : labIsk;
                satirlar.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>
                {
                    ["tur"] = 2, ["hizmetId"] = h.Id, ["miktar"] = 1m, ["birimFiyat"] = fiyat,
                    ["iskonto"] = (decimal)iskonto, ["iskontoKilit"] = iskonto > 0 ? 1 : 0,
                    ["pay"] = (int)karsilama, ["kdv"] = kdv, ["dovizCinsi"] = "TL", ["sira"] = ++sira,
                }));
            }
            await belgeDepo.GuncelleAsync(belgeId, belge, satirlar,
                new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);
            // Karşılama dağılımı (915) - kurum payı.
            await b.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(id) from public.belge_satir where belge_id=@p0 and hizmet_id is not null", null, [belgeId], iptal);

            return Results.Ok(new { eklenen = hizmetler.Count,
                                    mesaj = $"{hizmetler.Count} doktor istemi ücretlendirildi ve çalışma listesine düştü.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
