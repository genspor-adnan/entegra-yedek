using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HASTA BORCU - TEK KAYNAK (Alacak Yaşlandırma ve Hasta Borç Takibi ortak).
///
/// Başvuru başına: hasta payı = genel toplam - kurum payı (SGK + ÖSS dağılımı,
/// toplamı aşamaz), kalan = hasta payı - net tahsilat (iade düşülür, iptal 9
/// sayılmaz). Hasta icmaliyle (HastaIcmalUclari) AYNI kural; yalnız gerçek
/// başvuru (tür 19), iptal başvuru (6) hariç. Kural iki ekranda ayrı yazılırsa
/// biri güncellenip öteki unutulduğunda aynı hasta için iki farklı borç çıkar.
/// </summary>
internal static class HastaBorcSorgusu
{
    public sealed record Basvuru(int HastaId, int BelgeId, string ProtokolNo, DateTime Tarih, string Bolum,
                                 decimal Toplam, decimal KurumPayi, decimal Tahsil, decimal Kalan,
                                 DateTime? SonTahsilat);

    /// <summary>
    /// <paramref name="bitis"/> öncesindeki başvurular (kalanı sıfır olanlar
    /// dahil - son tahsilat tarihi bütün başvurulardan okunur). Hasta listesi
    /// verilirse yalnız onlar.
    /// </summary>
    public static Task<List<Basvuru>> BasvurularAsync(NpgsqlConnection b, DateTime bitis, int sube,
                                                     int[]? hastalar, CancellationToken iptal)
        => b.ListeAsync("""
            with bsv as (
                select be.id, be.belge_no, be.belge_tarihi, be.genel_toplam,
                       coalesce(bb.hasta_id, be.taraf_id) as hasta_id, bb.bolum_id
                  from public.belge be
                  join public.belge_basvuru bb on bb.id = be.id
                 where be.tipi = 30 and be.tur = 19 and be.durum <> 6
                   and be.belge_tarihi < @p0
                   and (@p1 = 0 or coalesce(be.sube_id, 0) in (0, @p1))
                   and (cardinality(@p2::int[]) = 0 or coalesce(bb.hasta_id, be.taraf_id) = any(@p2::int[])))
            select s.hasta_id, s.id, coalesce(s.belge_no, ''), s.belge_tarihi, coalesce(d.ad, ''), s.genel_toplam,
                   coalesce((select sum(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0))
                               from public.belge_satir st
                               left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                              where st.belge_id = s.id), 0),
                   coalesce((select sum(case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end)
                               from public.kasa_islem ki
                               join public.kasa_islem_turu kt on kt.kod = ki.tur
                              where ki.belge_id = s.id and ki.durum <> 9 and ki.islem_tarihi < @p0), 0),
                   (select max(ki.islem_tarihi) from public.kasa_islem ki
                     where ki.belge_id = s.id and ki.durum <> 9 and ki.islem_tarihi < @p0)
              from bsv s
              left join public.departman d on d.id = s.bolum_id
             where s.hasta_id is not null
            """, null, [bitis, sube, hastalar ?? Array.Empty<int>()], o =>
        {
            var toplam = o.GetDecimal(5);
            var kurum = Math.Min(o.GetDecimal(6), toplam);
            var tahsil = o.GetDecimal(7);
            return new Basvuru(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetDateTime(3), o.GetString(4),
                               toplam, kurum, tahsil, toplam - kurum - tahsil,
                               o.IsDBNull(8) ? null : o.GetDateTime(8));
        }, iptal);
}
