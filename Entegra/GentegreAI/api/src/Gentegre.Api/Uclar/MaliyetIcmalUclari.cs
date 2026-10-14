using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HASTA BAŞI MALİYET / SARF İCMALİ (mockup Ekranlar/İcmal/
/// hasta_basi_maliyet_icmali.html, kullanıcı 10.10.2026: "hasta başı maliyet
/// icmalini kodla").
///
/// Başvuru başına ciro (belge.genel_toplam) ile MALİYET karşılaştırması:
///   düşülen sarf  - radyoloji_sarf (istem), dis_seans_sarf (seans; kendi
///                   maliyeti varsa o), ameliyat_sarf (ameliyat): GERÇEK tüketim
///   faturalı stok - başvurudaki stok satırı, aynı stok için sarf kaydı yoksa
/// Aynı başvuruda aynı stok iki kez sayılmaz (sarf kaydı önceliklidir).
/// Birim maliyet fn_uretim_stok_maliyeti (giriş belgelerinden ağırlıklı
/// ortalama, yoksa alış fiyatı). İlaç = ilaç kataloğuna bağlı stok
/// (ilac.stok_id), diğerleri sarf.
///
/// FATURALANMAMIŞ SARF: düşülmüş ama başvuruda aynı stok satırı olmayan
/// kalem - kaçak gelir adayı (her sarf faturalanmaz; liste kontrol içindir).
/// Hizmet kârlılığı: başvuru maliyeti hizmet satırlarına TUTAR oranında
/// dağıtılır; hizmetin standart sarf seti (hizmet_sarf_seti) varsa onun
/// maliyeti de gösterilir. Yalnız gerçek başvuru (tür 19), iptal hariç. Yalnız OKUR.
/// </summary>
public static class MaliyetIcmalUclari
{
    /// <summary>Ekran kodu (1024) - haklarını kasa.finans'tan kopyalar.</summary>
    private const string Kod = "maliyet.hasta_basi";

    private sealed record Kalem(int BelgeId, int StokId, string Ad, decimal Miktar, decimal Maliyet,
                                bool Ilac, string Kaynak, bool Faturali);

    public static void MaliyetIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/maliyet-icmal").WithTags("Hasta Başı Maliyet").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? bolum,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var basvurular = await b.ListeAsync("""
                select be.id, coalesce(be.belge_no, ''), be.belge_tarihi, coalesce(bb.hasta_id, be.taraf_id, 0),
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                       coalesce(bb.bolum_id, 0), coalesce(d.ad, ''),
                       coalesce(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::varchar(120), ''), be.genel_toplam
                  from public.belge be
                  join public.belge_basvuru bb on bb.id = be.id
                  left join public.taraf h  on h.id  = coalesce(bb.hasta_id, be.taraf_id)
                  left join public.taraf hk on hk.id = bb.personel_id
                  left join public.departman d on d.id = bb.bolum_id
                 where be.tipi = 30 and be.tur = 19 and be.durum <> 6
                   and be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
                   and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
                   and (@p3 = 0 or bb.bolum_id = @p3)
                 order by be.belge_tarihi, be.id
                """, null, [baslangic, bitis, sube, bolum ?? 0], o => new
            {
                id = o.GetInt32(0), protokolNo = o.GetString(1), tarih = o.GetDateTime(2), hastaId = o.GetInt32(3),
                hasta = o.GetString(4), bolumId = o.GetInt32(5), bolum = o.GetString(6), hekim = o.GetString(7),
                ciro = o.GetDecimal(8),
            }, iptal);
            var idler = basvurular.Select(x => x.id).ToArray();

            // Düşülen sarf (üç kaynak) + başvurudaki stok satırları - tek sorgu.
            var kalemler = await b.ListeAsync("""
                with sarf as (
                    select i.belge_id, r.stok_id, r.miktar, null::numeric as maliyet, 'radyoloji' as kaynak
                      from public.radyoloji_sarf r join public.radyoloji_istem i on i.id = r.istem_id
                     where i.belge_id = any(@p0)
                    union all
                    select s.belge_id, d.stok_id, d.miktar, nullif(d.maliyet, 0), 'dis'
                      from public.dis_seans_sarf d join public.dis_seans s on s.id = d.seans_id
                     where s.belge_id = any(@p0)
                    union all
                    select am.belge_id, a.stok_id, a.miktar, null, 'ameliyat'
                      from public.ameliyat_sarf a join public.ameliyat am on am.id = a.ameliyat_id
                     where am.belge_id = any(@p0) and a.stok_id is not null),
                fatura as (
                    select st.belge_id, st.stok_id, sum(coalesce(nullif(st.miktar, 0), st.adet)) as miktar
                      from public.belge_satir st
                     where st.belge_id = any(@p0) and st.stok_id is not null
                     group by st.belge_id, st.stok_id)
                select x.belge_id, x.stok_id, coalesce(s.ad, ''), x.miktar,
                       round(coalesce(x.maliyet, x.miktar * public.fn_uretim_stok_maliyeti(x.stok_id)), 2),
                       exists (select 1 from public.ilac il where il.stok_id = x.stok_id), x.kaynak, x.faturali
                  from (
                    select sa.belge_id, sa.stok_id, sa.miktar, sa.maliyet, sa.kaynak,
                           exists (select 1 from fatura f where f.belge_id = sa.belge_id and f.stok_id = sa.stok_id) as faturali
                      from sarf sa
                    union all
                    -- faturalı stok satırı: aynı başvuruda aynı stok için sarf kaydı YOKSA
                    select f.belge_id, f.stok_id, f.miktar, null, 'fatura', true
                      from fatura f
                     where not exists (select 1 from sarf sa where sa.belge_id = f.belge_id and sa.stok_id = f.stok_id)
                  ) x
                  left join public.stok s on s.id = x.stok_id
                """, null, [idler], o => new Kalem(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetDecimal(3),
                    o.GetDecimal(4), o.GetBoolean(5), o.GetString(6), o.GetBoolean(7)), iptal);

            // Hizmet satırları (kârlılık dağıtımı) + standart sarf seti maliyeti.
            var hizmetSatirlari = await b.ListeAsync("""
                select st.belge_id, coalesce(st.hizmet_id, 0), coalesce(hz.ad, st.aciklama, ''), st.adet, st.tutar,
                       coalesce((select sum(ss.miktar * public.fn_uretim_stok_maliyeti(ss.stok_id))
                                   from public.hizmet_sarf_seti ss where ss.hizmet_id = st.hizmet_id), 0)
                  from public.belge_satir st
                  left join public.hizmet hz on hz.id = st.hizmet_id
                 where st.belge_id = any(@p0) and st.hizmet_id is not null
                """, null, [idler], o => (belge: o.GetInt32(0), hizmetId: o.GetInt32(1), ad: o.GetString(2),
                    adet: o.GetDecimal(3), tutar: o.GetDecimal(4), standart: o.GetDecimal(5)), iptal);

            var satirlar = basvurular.Select(x =>
            {
                var k = kalemler.Where(y => y.BelgeId == x.id).ToList();
                var sarf = k.Where(y => !y.Ilac).Sum(y => y.Maliyet);
                var ilac = k.Where(y => y.Ilac).Sum(y => y.Maliyet);
                var kar = x.ciro - sarf - ilac;
                return new
                {
                    x.id, x.protokolNo, x.tarih, x.hastaId, x.hasta, x.bolumId, x.bolum, x.hekim, x.ciro,
                    sarf, ilac, kar, marj = x.ciro > 0 ? Math.Round(100 * kar / x.ciro, 1) : (decimal?)null,
                    kalemler = k.Select(y => new { y.StokId, y.Ad, y.Miktar, y.Maliyet, y.Ilac, y.Kaynak, y.Faturali }),
                };
            }).ToList();

            // Hizmet kârlılığı: başvuru maliyeti satırlara tutar oranında.
            var maliyetBelge = satirlar.ToDictionary(x => x.id, x => x.sarf + x.ilac);
            var belgeHizmetTutari = hizmetSatirlari.GroupBy(h => h.belge).ToDictionary(g => g.Key, g => g.Sum(h => h.tutar));
            var hizmetler = hizmetSatirlari.GroupBy(h => (h.hizmetId, h.ad)).Select(g =>
            {
                var ciro = g.Sum(h => h.tutar);
                var maliyet = Math.Round(g.Sum(h => belgeHizmetTutari.GetValueOrDefault(h.belge) is > 0 and var t
                    ? maliyetBelge.GetValueOrDefault(h.belge) * h.tutar / t : 0), 2);
                var adet = g.Sum(h => h.adet);
                return new
                {
                    hizmetId = g.Key.hizmetId, ad = g.Key.ad, adet, ciro, maliyet,
                    ortFiyat = adet > 0 ? Math.Round(ciro / adet, 2) : 0m,
                    ortMaliyet = adet > 0 ? Math.Round(maliyet / adet, 2) : 0m,
                    standartSarf = Math.Round(g.First().standart, 2),
                    marj = ciro > 0 ? Math.Round(100 * (ciro - maliyet) / ciro, 1) : (decimal?)null,
                };
            }).OrderBy(x => x.marj ?? 999).ToList();

            var faturasizSarf = kalemler.Where(k => k.Kaynak != "fatura" && !k.Faturali).Select(k =>
            {
                var bv = basvurular.First(x => x.id == k.BelgeId);
                return new { belgeId = k.BelgeId, bv.protokolNo, bv.tarih, bv.hasta, bv.bolum, k.StokId, k.Ad, k.Miktar, k.Maliyet, k.Ilac, k.Kaynak };
            }).ToList();

            var bolumler = satirlar.GroupBy(x => (x.bolumId, x.bolum)).Select(g =>
            {
                var ciro = g.Sum(x => x.ciro); var sarf = g.Sum(x => x.sarf); var ilac = g.Sum(x => x.ilac);
                return new
                {
                    id = g.Key.bolumId, ad = g.Key.bolum is { Length: > 0 } a ? a : "(bölümsüz)", basvuru = g.Count(),
                    ciro, sarf, ilac, kar = ciro - sarf - ilac,
                    marj = ciro > 0 ? Math.Round(100 * (ciro - sarf - ilac) / ciro, 1) : (decimal?)null,
                    hastaBasi = g.Count() > 0 ? Math.Round((sarf + ilac) / g.Count(), 2) : 0m,
                };
            }).OrderByDescending(x => x.ciro).ToList();

            var ciroT = satirlar.Sum(x => x.ciro); var sarfT = satirlar.Sum(x => x.sarf); var ilacT = satirlar.Sum(x => x.ilac);
            var ozet = new
            {
                basvuru = satirlar.Count, ciro = ciroT, sarf = sarfT, ilac = ilacT, kar = ciroT - sarfT - ilacT,
                marj = ciroT > 0 ? Math.Round(100 * (ciroT - sarfT - ilacT) / ciroT, 1) : (decimal?)null,
                zarar = satirlar.Count(x => x.kar < 0), zararTutar = satirlar.Where(x => x.kar < 0).Sum(x => x.kar),
                maliyetliBasvuru = satirlar.Count(x => x.sarf + x.ilac > 0),
                hastaBasi = satirlar.Count > 0 ? Math.Round((sarfT + ilacT) / satirlar.Count, 2) : 0m,
                faturasizKalem = faturasizSarf.Count, faturasizMaliyet = faturasizSarf.Sum(x => x.Maliyet),
            };

            var bolumAdlari = basvurular.Where(x => x.bolumId > 0).Select(x => new { id = x.bolumId, ad = x.bolum })
                                        .DistinctBy(x => x.id).OrderBy(x => x.ad).ToList();

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet,
                basvurular = satirlar.OrderBy(x => x.marj ?? 999).ToList(), hizmetler, faturasizSarf, bolumler, bolumAdlari,
            });
        });
    }
}
