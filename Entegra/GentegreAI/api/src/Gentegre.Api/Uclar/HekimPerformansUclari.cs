using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HEKİM / BÖLÜM PERFORMANS İCMALİ (mockup Ekranlar/İcmal/
/// hekim_performans_icmali.html, kullanıcı 10.10.2026: "hekim performans
/// icmalini kodla").
///
/// Dönemde hekim (belge_basvuru.personel_id) ya da bölüm başına: başvuru,
/// hizmet kalemi, ciro (belge.genel_toplam - fn_belge_diptoplam'ın yazdığı),
/// iskonto satır satır yuvarlanıp toplanır (İskonto İcmali ile aynı rakam),
/// kurum payı (SGK + ÖSS dağılımı, toplamı aşamaz), hasta payı, iskonto
/// (satır: adet x birim fiyat - tutar), tahsil (net kasa) ve HAKEDİŞ
/// (hakedis_satir, dönem tarihli, iptal 0 hariç). Önceki eşit uzunluktaki
/// dönemle ciro karşılaştırması. Yalnız gerçek başvuru (tür 19), iptal (6)
/// hariç - hasta / kurum icmaliyle aynı küme.
///
/// Hekimlerdeki seçim (hekimler=) hizmet grupları, aylık trend ve özeti
/// süzer; hekim / bölüm tabloları her zaman tam liste. Yalnız OKUR.
/// </summary>
public static class HekimPerformansUclari
{
    /// <summary>Ekran kodu (1021) - haklarını prim'den (Hakedişler) kopyalar.</summary>
    private const string Kod = "prim.hekim_performans";

    private sealed record Satir(int BelgeId, DateTime Tarih, int HekimId, string Hekim, int BolumId, string Bolum,
                                decimal Ciro, decimal Kurum, decimal Iskonto, decimal Tahsil, long Kalem);

    public static void HekimPerformansUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/hekim-performans").WithTags("Doktor Performans").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, short? kurumTuru, int? bolum, string? hekimler,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            // Varsayılan dönem: geçen ay.
            var buAy = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            // ÖNCEKİ DÖNEM: tam takvim ayı (ya da ayları) seçildiyse bir önceki
            //   aylar - "Eylül'e göre" karşılaştırma 2 Ağustos'tan başlamamalı;
            //   değilse aynı uzunlukta hemen önceki aralık.
            var tamAy = baslangic.Day == 1 && bitis.Day == 1;
            var aySayisi = (bitis.Year - baslangic.Year) * 12 + bitis.Month - baslangic.Month;
            var oncekiBas = tamAy ? baslangic.AddMonths(-aySayisi) : baslangic.AddDays(-(bitis - baslangic).Days);
            var sube = baglam.SubeId ?? 0;
            var tur = kurumTuru ?? 0;
            var bol = bolum ?? 0;
            var secili = (hekimler ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => int.TryParse(x, out var n) ? n : 0).Where(n => n > 0).Distinct().ToArray();
            await using var b = await veri.AcAsync(iptal);

            // Trend için 6 ay geriden, karşılaştırma için önceki dönemden başlayarak tek sorgu.
            var trendBas = new DateTime(sonGun.Year, sonGun.Month, 1).AddMonths(-5);
            var enEski = new[] { oncekiBas, trendBas, baslangic }.Min();
            var satirlar = await SatirlarAsync(b, enEski, bitis, sube, tur, bol, iptal);

            var donem = satirlar.Where(x => x.Tarih >= baslangic && x.Tarih < bitis).ToList();
            var onceki = satirlar.Where(x => x.Tarih >= oncekiBas && x.Tarih < baslangic).ToList();

            // HAKEDİŞ: dönem tarihli hakediş satırları (iptal 0 hariç), hekim başına.
            var hakedis = (await b.ListeAsync("""
                select hs.taraf_id, sum(hs.tutar)
                  from public.hakedis_satir hs
                 where hs.tarih >= @p0 and hs.tarih < @p1 and coalesce(hs.durum, 1) <> 0
                 group by hs.taraf_id
                """, null, [baslangic, bitis], o => (id: o.GetInt32(0), tutar: o.GetDecimal(1)), iptal))
                .ToDictionary(x => x.id, x => x.tutar);

            object Ozetle(IEnumerable<Satir> k, IEnumerable<Satir> onc, decimal hak)
            {
                var l = k.ToList();
                var ciro = l.Sum(x => x.Ciro);
                var kurum = l.Sum(x => x.Kurum);
                var oncCiro = onc.Sum(x => x.Ciro);
                return new
                {
                    basvuru = l.Count, hizmet = l.Sum(x => x.Kalem), ciro, kurumPayi = kurum, hastaPayi = ciro - kurum,
                    kurumOrani = ciro > 0 ? Math.Round(100 * kurum / ciro, 1) : 0m,
                    iskonto = l.Sum(x => x.Iskonto), tahsil = l.Sum(x => x.Tahsil), hakedis = hak,
                    ortBasvuru = l.Count > 0 ? Math.Round(ciro / l.Count, 2) : 0m,
                    oncekiCiro = oncCiro,
                    degisim = oncCiro > 0 ? Math.Round(100 * (ciro - oncCiro) / oncCiro, 1) : (decimal?)null,
                };
            }

            var hekimListesi = donem.Where(x => x.HekimId > 0).GroupBy(x => x.HekimId).Select(g =>
            {
                // Hekimin dönemde en çok başvuru aldığı bölüm.
                var anaBolum = g.GroupBy(x => x.Bolum).OrderByDescending(x => x.Count()).First().Key;
                return new
                {
                    id = g.Key, ad = g.First().Hekim, bolum = anaBolum,
                    deger = Ozetle(g, onceki.Where(x => x.HekimId == g.Key), hakedis.GetValueOrDefault(g.Key)),
                    ciro = g.Sum(x => x.Ciro),
                };
            }).OrderByDescending(x => x.ciro).Select(x => new { x.id, x.ad, x.bolum, x.deger }).ToList();

            var hekimsiz = donem.Where(x => x.HekimId == 0).ToList();

            var bolumListesi = donem.GroupBy(x => x.BolumId).Select(g => new
            {
                id = g.Key, ad = g.First().Bolum is { Length: > 0 } a ? a : "(bölümsüz)",
                hekim = g.Where(x => x.HekimId > 0).Select(x => x.HekimId).Distinct().Count(),
                deger = Ozetle(g, onceki.Where(x => x.BolumId == g.Key),
                               g.Where(x => x.HekimId > 0).Select(x => x.HekimId).Distinct()
                                .Sum(h => hakedis.GetValueOrDefault(h))),
                ciro = g.Sum(x => x.Ciro),
            }).OrderByDescending(x => x.ciro).Select(x => new { x.id, x.ad, x.hekim, x.deger }).ToList();

            // Seçili hekimler (yoksa hepsi) - grup, trend ve özet bu kümeden.
            Func<Satir, bool> secimde = x => secili.Length == 0 || secili.Contains(x.HekimId);
            var kume = donem.Where(secimde).ToList();
            var idler = kume.Select(x => x.BelgeId).ToArray();

            var gruplar = await b.ListeAsync("""
                select coalesce(kt.ad, 'Diğer'), count(*), sum(st.tutar),
                       sum(least(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0), st.tutar)),
                       sum(round(greatest(st.adet * st.birim_fiyat - st.tutar, 0), 2))
                  from public.belge_satir st
                  left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                  left join public.hizmet h on h.id = st.hizmet_id
                  left join public.kategori kt on kt.id = h.kategori
                 where st.belge_id = any(@p0)
                 group by 1
                 order by 3 desc
                """, null, [idler], o => new
            {
                grup = o.GetString(0), kalem = o.GetInt64(1), tutar = o.GetDecimal(2),
                kurumPayi = o.GetDecimal(3), iskonto = o.GetDecimal(4),
            }, iptal);

            var trend = Enumerable.Range(0, 6).Select(i =>
            {
                var ay = trendBas.AddMonths(i);
                var l = satirlar.Where(secimde).Where(x => x.Tarih >= ay && x.Tarih < ay.AddMonths(1)).ToList();
                return new { yil = ay.Year, ay = ay.Month, basvuru = l.Count, ciro = l.Sum(x => x.Ciro), kurumPayi = l.Sum(x => x.Kurum) };
            }).ToList();

            var bolumAdlari = await b.ListeAsync("""
                select distinct d.id, d.ad from public.departman d
                  join public.belge_basvuru bb on bb.bolum_id = d.id
                 order by d.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun, oncekiBas, oncekiBit = baslangic.AddDays(-1) },
                secili,
                ozet = Ozetle(kume, onceki.Where(secimde),
                              secili.Length == 0 ? hakedis.Values.Sum() : secili.Sum(h => hakedis.GetValueOrDefault(h))),
                hekimsiz = new { basvuru = hekimsiz.Count, ciro = hekimsiz.Sum(x => x.Ciro) },
                hekimler = hekimListesi, bolumler = bolumListesi, gruplar, trend, bolumAdlari,
            });
        });
    }

    /// <summary>Başvuru başına ciro / kurum / iskonto / tahsil / kalem (tek sorgu).</summary>
    private static Task<List<Satir>> SatirlarAsync(NpgsqlConnection b, DateTime bas, DateTime bitis, int sube,
                                                   short kurumTuru, int bolum, CancellationToken iptal)
        => b.ListeAsync("""
            select be.id, be.belge_tarihi, coalesce(bb.personel_id, 0),
                   coalesce(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::varchar(120), ''),
                   coalesce(bb.bolum_id, 0), coalesce(d.ad, ''), be.genel_toplam,
                   coalesce(p.kurum, 0), coalesce(p.iskonto, 0), coalesce(p.kalem, 0),
                   coalesce((select sum(case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end)
                               from public.kasa_islem ki
                               join public.kasa_islem_turu kt on kt.kod = ki.tur
                              where ki.belge_id = be.id and ki.durum <> 9), 0)
              from public.belge be
              join public.belge_basvuru bb on bb.id = be.id
              left join public.taraf hk on hk.id = bb.personel_id
              left join public.departman d on d.id = bb.bolum_id
              left join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
              left join lateral (
                  select sum(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0)) as kurum,
                         sum(round(greatest(st.adet * st.birim_fiyat - st.tutar, 0), 2)) as iskonto,
                         count(*) as kalem
                    from public.belge_satir st
                    left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                   where st.belge_id = be.id) p on true
             where be.tipi = 30 and be.tur = 19 and be.durum <> 6
               and be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
               and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
               and (@p3 = 0 or coalesce(k.tur, 1) = @p3)
               and (@p4 = 0 or bb.bolum_id = @p4)
            """, null, [bas, bitis, sube, kurumTuru, bolum], o =>
        {
            var ciro = o.GetDecimal(6);
            return new Satir(o.GetInt32(0), o.GetDateTime(1), o.GetInt32(2), o.GetString(3), o.GetInt32(4), o.GetString(5),
                             ciro, Math.Min(o.GetDecimal(7), ciro), o.GetDecimal(8), o.GetDecimal(10), o.GetInt64(9));
        }, iptal);
}
