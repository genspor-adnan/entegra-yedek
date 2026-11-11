using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SAHA PERFORMANSI `/api/dis-hekim/performans` (1292, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §6; kullanıcı:
/// "yönetimin de temsilcilerin ve doktorların performansını görmeleri gerekiyor").
///
/// <para><b>Gönderim</b> = radyoloji istemi (istek_hekim_id dolu, iptal hariç), tarih = çekim ya da ekleme; tutar =
/// isteme bağlı belge satırının tutarı. <b>Temsilci</b> = istemin başvurusundaki <c>belge.satici_id</c> (kayıt anındaki
/// şube temsilcisi, 1287) - sonradan temsilci değişse geçmiş dönem oynamaz; satici yoksa hekimin bugünkü temsilcisi.
/// <b>Ziyaret / plan uyumu / talep</b> dis_hekim_ziyaret, dis_hekim_talep (1289); <b>prim</b> hakedis_satir rol 1
/// (gönderen) ve rol 10 (temsilci), dönem tarihli, iptal (0) hariç.</para>
///
/// <para>Önceki dönem = aynı uzunlukta bir önceki aralık. Yalnız OKUR.</para>
/// </summary>
public static class SahaPerformansUclari
{
    private const string Kod = "dis_doktor.performans";

    public static void SahaPerformansUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dis-hekim/performans").WithTags("Saha Performansı").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? sube, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);

            var bugun = DateTime.Today;
            var b1 = (bas ?? new DateTime(bugun.Year, bugun.Month, 1)).Date;
            var b2 = (bit ?? b1.AddMonths(1).AddDays(-1)).Date;
            if (b2 < b1) (b1, b2) = (b2, b1);
            var gun = (b2 - b1).Days + 1;
            var o1 = b1.AddDays(-gun); var o2 = b1.AddDays(-1);
            var subeId = sube is > 0 ? sube : null;

            await using var b = await veri.AcAsync(iptal);

            // Gönderim satırları: dönem + önceki dönem, hekim × temsilci × şube.
            var gonderim = await b.ListeAsync("""
                with g as (
                    select i.istek_hekim_id as hekim_id, i.sube_id, i.modalite,
                           coalesce(i.cekim_tarihi, i.ekleme_tarihi)::date as gun,
                           coalesce(bs.tutar, 0) as tutar,
                           coalesce(nullif(bl.satici_id, 0), public.fn_dis_hekim_temsilci(i.istek_hekim_id, i.sube_id, current_date)) as temsilci_id
                      from public.radyoloji_istem i
                      left join public.belge_satir bs on bs.id = i.belge_satir_id
                      left join public.belge bl on bl.id = bs.belge_id
                     where i.istek_hekim_id is not null and i.durum > 0
                       and coalesce(i.cekim_tarihi, i.ekleme_tarihi) >= @p2::date
                       and coalesce(i.cekim_tarihi, i.ekleme_tarihi) < (@p1::date + 1)
                       and (@p4::int is null or i.sube_id = @p4)
                    union all
                    -- ERP (1297): "gönderim" = müşterinin satış faturası / fişi (iade sayılmaz); modalite -1 = Satış.
                    select bl.taraf_id, bl.sube_id, -1 as modalite, bl.belge_tarihi::date as gun,
                           coalesce(bl.genel_toplam, 0) as tutar,
                           coalesce(nullif(bl.satici_id, 0), public.fn_dis_hekim_temsilci(bl.taraf_id, bl.sube_id, current_date)) as temsilci_id
                      from public.belge bl
                      join public.taraf t on t.id = bl.taraf_id and t.musteri = 1 and t.personel = 0
                     where bl.tur in (15, 16) and coalesce(bl.tipi, 0) <> 2 and bl.durum = 0
                       and bl.belge_tarihi >= @p2::date and bl.belge_tarihi < (@p1::date + 1)
                       and (@p4::int is null or bl.sube_id = @p4)
                )
                select g.hekim_id, g.sube_id, g.temsilci_id, g.modalite,
                       (g.gun >= @p0::date) as donem,
                       count(*)::int as adet, sum(g.tutar) as tutar, max(g.gun) as son
                  from g group by 1, 2, 3, 4, 5
                """, null, [b1, b2, o1, o2, subeId], o => new
                {
                    hekimId = o.GetInt32(0), subeId = o.IsDBNull(1) ? 0 : o.GetInt32(1),
                    temsilciId = o.IsDBNull(2) ? 0 : o.GetInt32(2), modalite = o.IsDBNull(3) ? 0 : Convert.ToInt32(o.GetValue(3)),
                    donem = o.GetBoolean(4), adet = o.GetInt32(5), tutar = o.IsDBNull(6) ? 0m : o.GetDecimal(6),
                    son = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                }, iptal);

            var modaliteAd = (await b.ListeAsync("""
                select kd.deger, kd.ad from public.kod_liste kl join public.kod_deger kd on kd.liste_id = kl.id where kl.kod = 'rad.modalite'
                """, null, [], o => (Convert.ToInt32(o.GetValue(0)), o.GetString(1)), iptal)).ToDictionary(x => x.Item1, x => x.Item2);
            modaliteAd[-1] = "Satış";

            // Ziyaretler (dönem): temsilci × hekim; yapıldı / planlı-geçmiş / iptal.
            var ziyaret = await b.ListeAsync("""
                select z.temsilci_id, z.hekim_id, z.sube_id, z.durum, count(*)::int, max(z.tarih)::date
                  from public.dis_hekim_ziyaret z
                 where z.tarih >= @p0::date and z.tarih < (@p1::date + 1) and (@p2::int is null or z.sube_id = @p2)
                 group by 1, 2, 3, 4
                """, null, [b1, b2, subeId], o => new
                {
                    temsilciId = o.IsDBNull(0) ? 0 : o.GetInt32(0), hekimId = o.GetInt32(1), subeId = o.GetInt32(2),
                    durum = Convert.ToInt32(o.GetValue(3)), adet = o.GetInt32(4), son = o.GetDateTime(5),
                }, iptal);
            var sonZiyaret = await b.ListeAsync("""
                select z.hekim_id, max(z.tarih)::date from public.dis_hekim_ziyaret z where z.durum = 1 group by 1
                """, null, [], o => (o.GetInt32(0), o.GetDateTime(1)), iptal);
            var sonZiyaretMap = sonZiyaret.ToDictionary(x => x.Item1, x => x.Item2);

            // Hekim ↔ temsilci bağı (bugün) + hekim kimliği.
            var hekimler = await b.ListeAsync("""
                select v.hekim_id, v.hekim_ad, v.hekim_kurum, v.sube_id, v.sube_ad, v.temsilci_id, v.temsilci_ad,
                       v.siklik_hafta, v.acik_talep, v.gecikme_gun, v.yeni_hekim,
                       coalesce((select g.ad from public.personel_gorev g where g.id = t.gorev_id), '') as brans,
                       t.ekleme_tarihi::date
                  from public.v_dis_hekim_ziyaret_vade v join public.taraf t on t.id = v.hekim_id
                 where (@p0::int is null or v.sube_id = @p0)
                """, null, [subeId], o => new
                {
                    hekimId = o.GetInt32(0), ad = o.GetString(1), kurum = o.GetString(2),
                    subeId = o.IsDBNull(3) ? 0 : o.GetInt32(3), subeAd = o.GetString(4),
                    temsilciId = o.IsDBNull(5) ? 0 : o.GetInt32(5), temsilciAd = o.GetString(6),
                    siklik = Convert.ToInt32(o.GetValue(7)), acikTalep = o.GetInt32(8), gecikme = o.GetInt32(9),
                    yeni = Convert.ToInt32(o.GetValue(10)) == 1, brans = o.GetString(11), kayit = o.GetDateTime(12),
                }, iptal);

            // Talepler: tür × durum; dönemde kapanan + ortalama kapanma; en çok sorumlu.
            var talepler = await b.ListeAsync("""
                select t.tur_ad,
                       count(*) filter (where t.durum = 1)::int as acik,
                       count(*) filter (where t.durum = 2)::int as onayda,
                       count(*) filter (where t.gecikme_gun > 0)::int as gecen,
                       count(*) filter (where t.durum in (3, 4) and t.kapanma >= @p0::date and t.kapanma < (@p1::date + 1))::int as kapanan,
                       coalesce(avg(extract(epoch from (t.kapanma - t.ekleme_tarihi)) / 86400)
                                filter (where t.durum in (3, 4) and t.kapanma >= @p0::date and t.kapanma < (@p1::date + 1)), 0)::numeric(8,1) as ort_gun,
                       coalesce((select x.sorumlu_ad || ' · ' || count(*) from public.v_dis_hekim_talep x
                                  where x.tur = t.tur and x.sorumlu_id is not null and x.durum in (1, 2)
                                  group by x.sorumlu_ad order by count(*) desc limit 1), '') as encok
                  from public.v_dis_hekim_talep t
                 where (@p2::int is null or t.sube_id = @p2)
                 group by t.tur, t.tur_ad order by t.tur
                """, null, [b1, b2, subeId], o => new
                {
                    tur = o.GetString(0), acik = o.GetInt32(1), onayda = o.GetInt32(2), terminiGecen = o.GetInt32(3),
                    kapanan = o.GetInt32(4), ortKapanmaGun = o.GetDecimal(5), encok = o.GetString(6),
                }, iptal);
            var talepOzet = await b.ListeAsync("""
                select coalesce(t.temsilci_id, 0), t.hekim_id,
                       count(*) filter (where t.durum in (1, 2))::int, count(*) filter (where t.gecikme_gun > 0)::int
                  from public.v_dis_hekim_talep t where (@p0::int is null or t.sube_id = @p0) group by 1, 2
                """, null, [subeId], o => (temsilci: o.GetInt32(0), hekim: o.GetInt32(1), acik: o.GetInt32(2), gecen: o.GetInt32(3)), iptal);

            // Prim (dönem): gönderen (rol 1) hekim başına, temsilci (rol 10) temsilci başına.
            var prim = await b.ListeAsync("""
                select h.rol, h.taraf_id, sum(h.tutar) from public.hakedis_satir h
                 where h.rol in (1, 10) and h.durum <> 0 and h.tarih >= @p0::date and h.tarih < (@p1::date + 1)
                 group by 1, 2
                """, null, [b1, b2], o => (rol: Convert.ToInt32(o.GetValue(0)), taraf: o.GetInt32(1), tutar: o.GetDecimal(2)), iptal);
            var gonderenPrim = prim.Where(p => p.rol == 1).ToDictionary(p => p.taraf, p => p.tutar);
            var temsilciPrim = prim.Where(p => p.rol == 10).ToDictionary(p => p.taraf, p => p.tutar);

            // ---------------------------------------------------- hesap --
            decimal yuzde(decimal simdi, decimal once) => once == 0 ? (simdi == 0 ? 0 : 100) : Math.Round((simdi - once) * 100 / once, 1);
            var gDonem = gonderim.Where(g => g.donem).ToList();
            var gOnce = gonderim.Where(g => !g.donem).ToList();
            var gonderenHekimOnce3Ay = gOnce.Select(g => g.hekimId).ToHashSet();

            var temsilciler = hekimler.GroupBy(h => new { h.temsilciId, h.temsilciAd, h.subeId, h.subeAd })
                .Where(x => x.Key.temsilciId > 0)
                .Select(x =>
                {
                    var tid = x.Key.temsilciId;
                    var hekimKumesi = x.Select(h => h.hekimId).ToHashSet();
                    var gd = gDonem.Where(g => g.temsilciId == tid).ToList();
                    var go = gOnce.Where(g => g.temsilciId == tid).ToList();
                    var z = ziyaret.Where(v => v.temsilciId == tid).ToList();
                    var yapildi = z.Where(v => v.durum == 1).Sum(v => v.adet);
                    var planliGecmis = z.Where(v => v.durum == 0 && v.son < bugun).Sum(v => v.adet);
                    var iptalEdilen = z.Where(v => v.durum == 2).Sum(v => v.adet);
                    var planToplam = yapildi + planliGecmis + iptalEdilen;
                    var aktif = gd.Select(g => g.hekimId).Distinct().Count();
                    var oncekiHekim = go.Select(g => g.hekimId).ToHashSet();
                    var simdikiHekim = gd.Select(g => g.hekimId).ToHashSet();
                    var ta = talepOzet.Where(t => t.temsilci == tid).ToList();
                    return new
                    {
                        id = tid, ad = x.Key.temsilciAd, subeId = x.Key.subeId, subeAd = x.Key.subeAd,
                        hekim = hekimKumesi.Count, aktifHekim = aktif,
                        ziyaret = yapildi, planUyumu = planToplam == 0 ? (decimal?)null : Math.Round(yapildi * 100m / planToplam, 0),
                        gonderim = gd.Sum(g => g.adet), onceki = go.Sum(g => g.adet),
                        degisim = yuzde(gd.Sum(g => g.adet), go.Sum(g => g.adet)),
                        tutar = gd.Sum(g => g.tutar),
                        yeniHekim = x.Count(h => h.kayit >= b1 && h.kayit <= b2),
                        kaybedilen = oncekiHekim.Count(h => !simdikiHekim.Contains(h)),
                        acikTalep = ta.Sum(t => t.acik), terminiGecen = ta.Sum(t => t.gecen),
                        prim = temsilciPrim.GetValueOrDefault(tid),
                    };
                })
                .OrderByDescending(t => t.gonderim).ToList();

            var doktorlar = hekimler.GroupBy(h => h.hekimId).Select(x =>
            {
                var h = x.First();
                var gd = gDonem.Where(g => g.hekimId == h.hekimId).ToList();
                var go = gOnce.Where(g => g.hekimId == h.hekimId).ToList();
                var mod = gd.GroupBy(g => g.modalite).OrderByDescending(m => m.Sum(g => g.adet)).Take(3)
                            .Select(m => $"{modaliteAd.GetValueOrDefault(m.Key, m.Key.ToString())} {m.Sum(g => g.adet)}");
                var sonG = gonderim.Where(g => g.hekimId == h.hekimId).Max(g => g.son);
                var sonZ = sonZiyaretMap.TryGetValue(h.hekimId, out var sz) ? sz : (DateTime?)null;
                var ziy3 = ziyaret.Where(v => v.hekimId == h.hekimId && v.durum == 1).Sum(v => v.adet);
                var simdi = gd.Sum(g => g.adet); var once = go.Sum(g => g.adet);
                var sessiz = sonG is null ? (int?)null : (bugun - sonG.Value).Days;
                return new
                {
                    id = h.hekimId, ad = h.ad, brans = h.brans, kurum = h.kurum,
                    temsilciler = string.Join(" · ", x.Select(y => $"{y.subeAd}: {y.temsilciAd}".Trim(':', ' ')).Distinct()),
                    gonderim = simdi, onceki = once, degisim = yuzde(simdi, once), tutar = gd.Sum(g => g.tutar),
                    modaliteler = string.Join(" / ", mod),
                    sonGonderim = sonG, sonZiyaret = sonZ, ziyaret = ziy3,
                    acikTalep = h.acikTalep, gonderenPrimi = gonderenPrim.GetValueOrDefault(h.hekimId),
                    dusen = once > 0 && simdi * 2 < once, sessiz = (sessiz is null || sessiz >= 60) && !h.yeni,
                    yeni = h.yeni, ziyaretEdilmeyen = h.gecikme > 0, gecikme = h.gecikme,
                };
            }).OrderByDescending(d => d.gonderim).ToList();

            var subeler = temsilciler.GroupBy(t => new { t.subeId, t.subeAd }).Select(x => new
            {
                subeId = x.Key.subeId, subeAd = x.Key.subeAd, temsilci = x.Count(),
                hekim = hekimler.Where(h => h.subeId == x.Key.subeId).Select(h => h.hekimId).Distinct().Count(),
                aktifHekim = gDonem.Where(g => g.subeId == x.Key.subeId).Select(g => g.hekimId).Distinct().Count(),
                ziyaret = x.Sum(t => t.ziyaret),
                planUyumu = x.Any(t => t.planUyumu is not null) ? Math.Round(x.Where(t => t.planUyumu is not null).Average(t => t.planUyumu!.Value), 0) : (decimal?)null,
                gonderim = gDonem.Where(g => g.subeId == x.Key.subeId).Sum(g => g.adet),
                onceki = gOnce.Where(g => g.subeId == x.Key.subeId).Sum(g => g.adet),
                degisim = yuzde(gDonem.Where(g => g.subeId == x.Key.subeId).Sum(g => g.adet), gOnce.Where(g => g.subeId == x.Key.subeId).Sum(g => g.adet)),
                tutar = gDonem.Where(g => g.subeId == x.Key.subeId).Sum(g => g.tutar),
                temsilciPrimi = x.Sum(t => t.prim),
            }).OrderBy(s => s.subeAd).ToList();

            var toplamG = gDonem.Sum(g => g.adet); var toplamO = gOnce.Sum(g => g.adet);
            var tumZiyaret = ziyaret.Where(v => v.durum == 1).Sum(v => v.adet);
            var tumPlan = tumZiyaret + ziyaret.Where(v => (v.durum == 0 && v.son < bugun) || v.durum == 2).Sum(v => v.adet);
            var ozet = new
            {
                gonderim = toplamG, onceki = toplamO, degisim = yuzde(toplamG, toplamO),
                tutar = gDonem.Sum(g => g.tutar), oncekiTutar = gOnce.Sum(g => g.tutar),
                ziyaret = tumZiyaret, planUyumu = tumPlan == 0 ? (decimal?)null : Math.Round(tumZiyaret * 100m / tumPlan, 0),
                dusenHekim = doktorlar.Count(d => d.dusen), sessizHekim = doktorlar.Count(d => d.sessiz),
                gonderenPrimi = gonderenPrim.Values.Sum(), temsilciPrimi = temsilciPrim.Values.Sum(),
                temsilci = temsilciler.Count, hekim = doktorlar.Count,
            };
            var subeAdlari = await b.ListeAsync("select id, ad from public.sube where aktif = 1 order by ad", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                donem = new { bas = b1.ToString("yyyy-MM-dd"), bit = b2.ToString("yyyy-MM-dd"), oncekiBas = o1.ToString("yyyy-MM-dd"), oncekiBit = o2.ToString("yyyy-MM-dd") },
                ozet, temsilciler, doktorlar, subeler, talepler, subeAdlari, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
