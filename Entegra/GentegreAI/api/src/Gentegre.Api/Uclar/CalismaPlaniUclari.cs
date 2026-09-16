using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HEKİM ÇALIŞMA PLANI (711) - türetilen haftalık plan ve "bugün çalışanlar".
/// Şablon/istisna kayıtları generic kartla; burada yalnız türetme
/// (<c>fn_hekim_calisma_bloklari</c>) ve kayıt kabulün bugün listesi.
/// </summary>
public static class CalismaPlaniUclari
{
    public static void CalismaPlaniUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/calisma-plani").WithTags("CalismaPlani").RequireAuthorization();

        // Haftalık (ya da verilen aralık) türetilmiş bloklar. sube 0 = tüm şubeler.
        grup.MapGet("/", async (
            DateOnly? bas, DateOnly? bit, int? hekimId, int? departmanId, int? sube,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            var b0 = bas ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            var b1 = bit ?? b0.AddDays(6);
            if (b1 < b0) b1 = b0;
            if (b1.DayNumber - b0.DayNumber > 62) b1 = b0.AddDays(62);
            var subeId = sube ?? baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var bloklar = await b.ListeAsync("""
                select hekim_id, hekim, sube_id, departman_id, departman, gun, saat_bas, saat_bit, slot_dk, kanallar,
                       kaynak, istisna_tur, sablon_id, istisna_id, aciklama,
                       (select count(*) from public.randevu r where r.hekim_id = f.hekim_id and r.durum in (1, 2)
                          and r.baslangic::date = f.gun and f.saat_bas is not null
                          and r.baslangic::time >= f.saat_bas and r.baslangic::time < f.saat_bit)::int as randevu
                  from public.fn_hekim_calisma_bloklari(@p0, @p1, @p2, @p3, @p4) f
                """, null, [subeId, b0, b1, hekimId, departmanId], o => new
            {
                hekimId = o.GetInt32(0), hekim = o.GetString(1), subeId = o.GetInt32(2), departmanId = o.GetInt32(3), departman = o.GetString(4),
                gun = o.GetFieldValue<DateOnly>(5), saatBas = o.IsDBNull(6) ? null : o.GetFieldValue<TimeOnly>(6).ToString("HH:mm"),
                saatBit = o.IsDBNull(7) ? null : o.GetFieldValue<TimeOnly>(7).ToString("HH:mm"), slotDk = (int)o.GetInt16(8),
                kanallar = o.GetString(9), kaynak = (int)o.GetInt16(10), istisnaTur = o.IsDBNull(11) ? (int?)null : o.GetInt16(11),
                sablonId = o.IsDBNull(12) ? (int?)null : o.GetInt32(12), istisnaId = o.IsDBNull(13) ? (int?)null : o.GetInt32(13),
                aciklama = o.GetString(14), randevu = o.GetInt32(15),
            }, iptal);
            var hekimler = await b.ListeAsync("""
                select distinct t.id, t.unvan, coalesce(t.departman::integer, 0)
                  from public.hekim_calisma_sablon s join public.taraf t on t.id = s.hekim_id
                 where s.aktif = 1 order by t.unvan
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1), departmanId = o.GetInt32(2) }, iptal);
            var bolumler = await b.ListeAsync("""
                select d.id, d.ad, d.randevusuz_kabul from public.departman d
                 where d.durum = 1 and (public.fn_bolum_planli(d.id) = 1 or d.randevusuz_kabul = 1) order by d.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1), randevusuz = o.GetInt16(2) == 1 }, iptal);
            var subeler = await b.ListeAsync("select id, ad from public.sube where aktif = 1 order by ad", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(new { bas = b0, bit = b1, subeId, bloklar, hekimler, bolumler, subeler });
        });

        // Kayıt kabul: bugün çalışan bölüm / hekim (plan bloklarından) + randevusuz bölümler.
        grup.MapGet("/bugun", async (
            DateOnly? gun, int? sube, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            var g = gun ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            var subeId = sube ?? baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select f.departman_id, f.departman, f.hekim_id, f.hekim,
                       string_agg(to_char(f.saat_bas, 'HH24:MI') || '–' || to_char(f.saat_bit, 'HH24:MI'), ' · ' order by f.saat_bas) as saatler,
                       max(f.kaynak) as kaynak, max(f.kanallar) as kanallar,
                       (select count(*) from public.randevu r where r.hekim_id = f.hekim_id and r.durum in (1, 2) and r.baslangic::date = f.gun)::int as randevu,
                       (select count(*) from public.randevu r where r.hekim_id = f.hekim_id and r.durum = 2 and r.baslangic::date = f.gun)::int as gelen,
                       bool_or(localtime between f.saat_bas and f.saat_bit and f.gun = current_date) as simdi
                  from public.fn_hekim_calisma_bloklari(@p0, @p1, @p1) f
                 where f.kaynak in (1, 2)
                 group by f.departman_id, f.departman, f.hekim_id, f.hekim, f.gun
                 order by f.departman, f.hekim
                """, null, [subeId, g], o => new
            {
                departmanId = o.GetInt32(0), departman = o.GetString(1), hekimId = o.GetInt32(2), hekim = o.GetString(3),
                saatler = o.GetString(4), kaynak = (int)o.GetInt16(5), kanallar = o.GetString(6), randevu = o.GetInt32(7), gelen = o.GetInt32(8),
                simdi = !o.IsDBNull(9) && o.GetBoolean(9),
            }, iptal);
            var randevusuz = await b.ListeAsync("select id, ad from public.departman where durum = 1 and randevusuz_kabul = 1 order by ad", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(new { gun = g, subeId, satirlar, randevusuz });
        });
    }
}
