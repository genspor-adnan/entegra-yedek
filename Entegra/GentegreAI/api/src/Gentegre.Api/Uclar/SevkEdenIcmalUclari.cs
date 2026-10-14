using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SEVK EDEN / DIŞ DOKTOR İCMALİ (mockup Ekranlar/İcmal/sevk_eden_icmali.html,
/// kullanıcı 10.10.2026: "mockup gibi kodla").
///
/// Gönderen = hizmet satırındaki "Gönderen" rolü (belge_satir_rol rol 1; 825:
/// kendi adına gönderen dış hekim, kurum adına gelen iş kurum). Gönderen
/// başına: sevkli başvuru, sevkli satırların cirosu, KOMİSYON = gönderen primi
/// (hakedis_satir rol 1, dönem tarihli, iptal 0 hariç) ve ödeme durumu
/// (satır durumu 1 taslak · 2 kesin · 3 onaylı · 4 ödendi; hakedis_id dolu =
/// ödeme listesinde). Komisyon BURADA HESAPLANMAZ: prim motoru üretir, ekran
/// okur. Onay ve ödeme listesi Prim modülünün uçlarıyla (/api/prim/onayla,
/// /api/prim/donem-kapat) yapılır.
///
/// Önceki eşit dönemle sevk karşılaştırması; önceki dönemde sevki olmayan
/// gönderen "yeni". Yalnız gerçek başvuru (tür 19), iptal hariç. Yalnız OKUR.
/// </summary>
public static class SevkEdenIcmalUclari
{
    /// <summary>Ekran kodu (1025) - haklarını prim'den kopyalar.</summary>
    private const string Kod = "prim.sevk_eden";

    private sealed record SevkSatiri(int GonderenId, int BelgeId, DateTime Tarih, decimal Tutar);

    public static void SevkEdenIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/sevk-eden").WithTags("Sevk Eden İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, string? gonderenler,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            // Önceki dönem: tam ay(lar) seçildiyse önceki takvim ay(lar)ı (Doktor Performans kuralı).
            var tamAy = baslangic.Day == 1 && bitis.Day == 1;
            var aySayisi = (bitis.Year - baslangic.Year) * 12 + bitis.Month - baslangic.Month;
            var oncekiBas = tamAy ? baslangic.AddMonths(-aySayisi) : baslangic.AddDays(-(bitis - baslangic).Days);
            var sube = baglam.SubeId ?? 0;
            var secili = (gonderenler ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => int.TryParse(x, out var n) ? n : 0).Where(n => n > 0).Distinct().ToArray();
            await using var b = await veri.AcAsync(iptal);

            var sevk = await SevklerAsync(b, oncekiBas, bitis, sube, iptal);
            var donem = sevk.Where(x => x.Tarih >= baslangic).ToList();
            var onceki = sevk.Where(x => x.Tarih < baslangic).ToList();
            var ids = donem.Select(x => x.GonderenId).Distinct().ToArray();

            var kisiler = (await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       case when k.id is not null then 'kurum' when coalesce(tp.dis_hekim, 0) = 1 then 'dis' else 'ic' end,
                       coalesce(tp.brans, ''), coalesce(t.telefon, '')
                  from public.taraf t
                  left join public.taraf_personel tp on tp.id = t.id
                  left join public.taraf_kurum k on k.id = t.id
                 where t.id = any(@p0)
                """, null, [ids], o => (id: o.GetInt32(0), ad: o.GetString(1), tur: o.GetString(2),
                    brans: o.GetString(3), tel: o.GetString(4)), iptal)).ToDictionary(x => x.id);

            // KOMİSYON: dönem tarihli gönderen primi satırları (rol 1).
            var primler = await b.ListeAsync("""
                select hs.id, hs.taraf_id, hs.tarih, hs.tutar, coalesce(hs.durum, 1)::smallint, hs.hakedis_id,
                       coalesce(h.durum, 0)::smallint, coalesce(be.belge_no, ''), coalesce(hs.taban, 0), coalesce(hs.deger, 0),
                       coalesce(hs.oran_tipi, 1)::smallint
                  from public.hakedis_satir hs
                  left join public.hakedis h on h.id = hs.hakedis_id
                  left join public.belge_satir st on st.id = hs.belge_satir_id
                  left join public.belge be on be.id = st.belge_id
                 where hs.rol = 1 and hs.tarih >= @p0 and hs.tarih < @p1 and coalesce(hs.durum, 1) <> 0
                 order by hs.tarih, hs.id
                """, null, [baslangic, bitis], o => new
            {
                id = o.GetInt32(0), gonderenId = o.GetInt32(1), tarih = o.GetDateTime(2), tutar = o.GetDecimal(3),
                durum = (int)o.GetInt16(4), hakedisId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
                hakedisDurum = (int)o.GetInt16(6), protokolNo = o.GetString(7), taban = o.GetDecimal(8),
                deger = o.GetDecimal(9), oranTipi = (int)o.GetInt16(10),
            }, iptal);

            static string OdemeDurumu(IEnumerable<int> durumlar, bool listede)
            {
                var d = durumlar.ToList();
                if (d.Count == 0) return "yok";
                if (d.All(x => x == 4)) return "odendi";
                if (listede) return "listede";
                if (d.All(x => x >= 3)) return "onayli";
                if (d.Any(x => x == 1)) return "taslak";
                return "hesaplandi";
            }

            var doktorlar = donem.GroupBy(x => x.GonderenId).Select(g =>
            {
                kisiler.TryGetValue(g.Key, out var k);
                var ciro = g.Sum(x => x.Tutar);
                var basvuru = g.Select(x => x.BelgeId).Distinct().Count();
                var onc = onceki.Where(x => x.GonderenId == g.Key).ToList();
                var oncBasvuru = onc.Select(x => x.BelgeId).Distinct().Count();
                var p = primler.Where(x => x.gonderenId == g.Key).ToList();
                var komisyon = p.Sum(x => x.tutar);
                return new
                {
                    id = g.Key, ad = k.ad ?? "", tur = k.tur ?? "ic", brans = k.brans ?? "", telefon = k.tel ?? "",
                    basvuru, ciro, ortBasvuru = basvuru > 0 ? Math.Round(ciro / basvuru, 2) : 0m,
                    komisyon, oran = ciro > 0 ? Math.Round(100 * komisyon / ciro, 1) : 0m,
                    odenen = p.Where(x => x.durum == 4).Sum(x => x.tutar),
                    bekleyen = p.Where(x => x.durum != 4).Sum(x => x.tutar),
                    odemeDurumu = OdemeDurumu(p.Select(x => x.durum), p.Any(x => x.hakedisId != null && x.durum != 4)),
                    oncekiBasvuru = oncBasvuru, oncekiCiro = onc.Sum(x => x.Tutar),
                    yeni = oncBasvuru == 0,
                    degisim = oncBasvuru > 0 ? Math.Round(100m * (basvuru - oncBasvuru) / oncBasvuru, 1) : (decimal?)null,
                };
            }).OrderByDescending(x => x.ciro).ToList();

            // Seçili gönderenler (yoksa hepsi) - başvuru ve ödeme sekmeleri bu kümeden.
            Func<int, bool> secimde = id => secili.Length == 0 || secili.Contains(id);
            var kumeBelge = donem.Where(x => secimde(x.GonderenId)).ToList();
            var belgeIdler = kumeBelge.Select(x => x.BelgeId).Distinct().ToArray();
            var basvuruBilgi = (await b.ListeAsync("""
                select be.id, coalesce(be.belge_no, ''), be.belge_tarihi,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''), coalesce(d.ad, '')
                  from public.belge be
                  join public.belge_basvuru bb on bb.id = be.id
                  left join public.taraf h on h.id = coalesce(bb.hasta_id, be.taraf_id)
                  left join public.departman d on d.id = bb.bolum_id
                 where be.id = any(@p0)
                """, null, [belgeIdler], o => (id: o.GetInt32(0), no: o.GetString(1), tarih: o.GetDateTime(2),
                    hasta: o.GetString(3), bolum: o.GetString(4)), iptal)).ToDictionary(x => x.id);

            var basvurular = kumeBelge.GroupBy(x => (x.GonderenId, x.BelgeId)).Select(g =>
            {
                basvuruBilgi.TryGetValue(g.Key.BelgeId, out var bv);
                kisiler.TryGetValue(g.Key.GonderenId, out var k);
                return new
                {
                    belgeId = g.Key.BelgeId, protokolNo = bv.no ?? "", tarih = bv.tarih, hasta = bv.hasta ?? "",
                    bolum = bv.bolum ?? "", gonderenId = g.Key.GonderenId, gonderen = k.ad ?? "", tutar = g.Sum(x => x.Tutar),
                };
            }).OrderBy(x => x.tarih).ToList();

            var odemeler = primler.Where(x => secimde(x.gonderenId)).Select(x =>
            {
                kisiler.TryGetValue(x.gonderenId, out var k);
                return new { x.id, x.gonderenId, gonderen = k.ad ?? "", x.tarih, x.protokolNo, x.taban, x.oranTipi, x.deger, x.tutar, x.durum, x.hakedisId, x.hakedisDurum };
            }).ToList();

            var kd = doktorlar.Where(x => secimde(x.id)).ToList();
            var ozet = new
            {
                gonderen = kd.Count, disHekim = kd.Count(x => x.tur == "dis"), kurum = kd.Count(x => x.tur == "kurum"),
                basvuru = kumeBelge.Select(x => x.BelgeId).Distinct().Count(),
                ciro = kd.Sum(x => x.ciro),
                ortBasvuru = kumeBelge.Select(x => x.BelgeId).Distinct().Count() is > 0 and var n ? Math.Round(kd.Sum(x => x.ciro) / n, 2) : 0m,
                komisyon = kd.Sum(x => x.komisyon), odenen = kd.Sum(x => x.odenen), bekleyen = kd.Sum(x => x.bekleyen),
                yeni = kd.Count(x => x.yeni),
                oncekiBasvuru = onceki.Where(x => secimde(x.GonderenId)).Select(x => x.BelgeId).Distinct().Count(),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun, oncekiBas, oncekiBit = baslangic.AddDays(-1) },
                secili, ozet, doktorlar, basvurular, odemeler,
            });
        });
    }

    /// <summary>
    /// Gönderen rolü olan hizmet satırları (rol 1): gönderen, başvuru, tarih, satır tutarı.
    /// Ciro SATIR tutarıdır - başvurunun gönderenin göndermediği kalemleri ona yazılmaz.
    /// </summary>
    private static Task<List<SevkSatiri>> SevklerAsync(NpgsqlConnection b, DateTime bas, DateTime bitis, int sube,
                                                     CancellationToken iptal)
        => b.ListeAsync("""
            select r.taraf_id, be.id, be.belge_tarihi, st.tutar
              from public.belge_satir_rol r
              join public.belge_satir st on st.id = r.belge_satir_id
              join public.belge be on be.id = st.belge_id
             where r.rol = 1 and r.taraf_id is not null
               and be.tipi = 30 and be.tur = 19 and be.durum <> 6
               and be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
               and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
            """, null, [bas, bitis, sube], o => new SevkSatiri(o.GetInt32(0), o.GetInt32(1), o.GetDateTime(2), o.GetDecimal(3)), iptal);
}
