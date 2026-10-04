using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ MUAYENE LİSTESİ + KARTI (970, mockup Ekranlar/Goz/goz_muayene_listesi_v2.html ·
/// goz_muayene_karti_v2.html).
///
/// Gösterge kutuları / sol panel sayıları, liste önizlemesi, kartın Tonometri
/// eğilimi ve Karşılaştırma sekmesi (aynı veri: hastanın son göz muayeneleri),
/// Tanı &amp; Plan sağ paneli (tanılar + muayeneden doğan işler), Görüntüler sekmesi.
/// Satır başı değerler v_goz_muayene_ozet'ten: liste kolonu ile kutu aynı tanımı okur.
/// </summary>
public static partial class GozUclari
{
    private static void ListeUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/muayene-gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            // BUGÜN dışındaki kutular SON 30 GÜN (kontrol gecikmesi ve taslak hariç):
            //   eski bir muayenenin yüksek GİB'i bugünün işi değil, gecikmiş kontrol ise öyle.
            var gosterge = await b.TekAsync("""
                select count(*) filter (where (m.muayene_tarihi at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date) as bugun,
                       count(*) filter (where v.dilatasyon_bekliyor = 1)                                   as dilatasyon,
                       count(*) filter (where v.gib_yuksek > 0 and m.muayene_tarihi >= now() - interval '30 days') as "gibYuksek",
                       count(*) filter (where v.gorme_dusus > 0 and m.muayene_tarihi >= now() - interval '30 days') as "gormeDusus",
                       count(*) filter (where v.kontrol_gecikmis = 1)                                      as "kontrolGecikmis",
                       count(*) filter (where not v.tamamlandi)                                            as taslak
                  from public.goz_muayene gm
                  join public.muayene m on m.id = gm.muayene_id
                  join public.v_goz_muayene_ozet v on v.goz_muayene_id = gm.id
                 where (@p0::int is null or gm.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var turler = await b.ListeAsync("""
                select gm.muayene_turu as tur, count(*) as sayi from public.goz_muayene gm
                 where (@p0::int is null or gm.sube_id = @p0) group by 1 order by 1
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var hekimler = await b.ListeAsync("""
                select m.personel_id as id, coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '(hekimsiz)') as ad,
                       count(*) as sayi
                  from public.goz_muayene gm join public.muayene m on m.id = gm.muayene_id
                  left join public.taraf h on h.id = m.personel_id
                 where (@p0::int is null or gm.sube_id = @p0)
                 group by 1, 2 order by 3 desc, 2
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { gosterge, turler, hekimler, izlemeNo = baglam.IzlemeNo });
        });

        // ÖNİZLEME (liste sağ paneli): hasta, bu muayene sağ / sol, GİB eğilimi, tanı & plan.
        grup.MapGet("/muayene/{id:int}/onizleme", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                select gm.id, gm.hasta_id as "hastaId", public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as hasta,
                       v.yas, v.cinsiyet, v.takip_hastaliklar as takip,
                       coalesce((select string_agg(distinct coalesce(nullif(a.etken_madde, ''), a.etken), ', ')
                                   from public.hasta_alerji a where a.hasta_id = gm.hasta_id and a.aktif = 1), '') as alerji,
                       coalesce((select string_agg(nullif(z.aktif_tedavi, ''), ' · ') from public.goz_hasta_ozet z
                                  where z.hasta_id = gm.hasta_id), '') as tedavi,
                       v.bcva_od as "bcvaOd", v.bcva_os as "bcvaOs", v.gorme_dusus as "gormeDusus",
                       v.gib_od as "gibOd", v.gib_os as "gibOs", v.hedef_od as "hedefOd", v.hedef_os as "hedefOs",
                       v.gib_yuksek as "gibYuksek",
                       (select max(t2.cct_um) filter (where t2.goz = 1) from public.goz_tonometri t2 where t2.goz_muayene_id = gm.id) as "cctOd",
                       (select max(t2.cct_um) filter (where t2.goz = 2) from public.goz_tonometri t2 where t2.goz_muayene_id = gm.id) as "cctOs",
                       (select max(f.cd_dikey) filter (where f.goz = 1) from public.goz_fundus f where f.goz_muayene_id = gm.id) as "cdOd",
                       (select max(f.cd_dikey) filter (where f.goz = 2) from public.goz_fundus f where f.goz_muayene_id = gm.id) as "cdOs",
                       v.tani, coalesce(gm.plan, '') as plan, v.kontrol_tarihi as "kontrolTarihi", v.tamamlandi,
                       v.hekim_id as "hekimId"
                  from public.goz_muayene gm
                  join public.taraf t on t.id = gm.hasta_id
                  join public.v_goz_muayene_ozet v on v.goz_muayene_id = gm.id
                 where gm.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Göz muayenesi bulunamadı.");
            var gecmis = await GecmisAsync(b, id, 6, iptal);
            return Results.Ok(new { muayene = o, gecmis, izlemeNo = baglam.IzlemeNo });
        });

        // KARŞILAŞTIRMA (kart sekmesi + Tonometri eğilimi): bu muayene ve öncekiler.
        grup.MapGet("/muayene/{id:int}/karsilastirma", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await GecmisAsync(b, id, 8, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // TANI & PLAN SAĞ PANELİ: muayene tanıları + bu muayeneden doğan işler.
        grup.MapGet("/muayene/{id:int}/isler", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var tanilar = await b.ListeAsync("""
                select t.id, t.icd_kod as kod, coalesce(i.ad, '') as ad, coalesce(t.taraf, 0) as taraf,
                       coalesce(t.kesinlik, 0) as kesinlik, coalesce(t.tur, 0) as tur
                  from public.tani t
                  join public.goz_muayene gm on gm.muayene_id = t.muayene_id
                  left join public.icd i on i.kod = t.icd_kod
                 where gm.id = @p0 order by t.sira, t.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var isler = await b.ListeAsync("""
                select 'gozluk' as tur, 'Gözlük reçetesi' as ad, r.ekleme_tarihi as zaman, '' as ayrinti, r.id
                  from public.goz_gozluk_recetesi r join public.goz_muayene gm on gm.id = @p0
                 where r.id = gm.gozluk_recete_id
                union all
                select 'goruntuleme',
                       case g.tetkik when 1 then 'OCT maküla' when 2 then 'OCT RNFL/GCC' when 3 then 'OCT ön segment' when 4 then 'OCT-A'
                            when 5 then 'FAF' when 6 then 'FA / ICGA' when 7 then 'Fundus foto' when 8 then 'Görme alanı'
                            when 9 then 'Topografi' when 10 then 'Pakimetri' when 11 then 'Biyometri' when 12 then 'Endotel'
                            when 13 then 'UBM' when 14 then 'B-scan USG' when 15 then 'ERG / VEP' else 'Görüntüleme' end,
                       g.istem_zamani, case g.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end, g.id
                  from public.goz_goruntuleme g join public.goz_muayene gm on gm.id = @p0
                 where g.muayene_id = gm.muayene_id
                union all
                select 'islem', coalesce(h.ad, case i.tur when 1 then 'Enjeksiyon' when 2 then 'Lazer' when 3 then 'Ameliyat' else 'Göz işlemi' end),
                       coalesce(i.planlanan_tarih, i.ekleme_tarihi),
                       case i.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end, i.id
                  from public.goz_islem i join public.goz_muayene gm on gm.id = @p0
                  left join public.hizmet h on h.id = i.hizmet_id
                 where i.muayene_id = gm.muayene_id
                union all
                select 'randevu', 'Kontrol randevusu', r.baslangic, '', r.id
                  from public.muayene m join public.goz_muayene gm on gm.muayene_id = m.id and gm.id = @p0
                  join public.randevu r on r.id = m.kontrol_randevu_id
                order by 3
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { tanilar, isler, izlemeNo = baglam.IzlemeNo });
        });

        // GÖRÜNTÜLER (kart sekmesi): hastanın göz görüntüleme kayıtları + bu muayenenin çizimleri.
        grup.MapGet("/muayene/{id:int}/goruntuler", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select * from (
                    select coalesce(g.cekim_zamani, g.istem_zamani) as zaman,
                           case g.tetkik when 1 then 'OCT maküla' when 2 then 'OCT RNFL/GCC' when 3 then 'OCT ön segment' when 4 then 'OCT-A'
                                when 5 then 'FAF' when 6 then 'FA / ICGA' when 7 then 'Fundus foto' when 8 then 'Görme alanı'
                                when 9 then 'Topografi' when 10 then 'Pakimetri' when 11 then 'Biyometri' when 12 then 'Endotel'
                                when 13 then 'UBM' when 14 then 'B-scan USG' when 15 then 'ERG / VEP' else 'Görüntüleme' end as tur,
                           case g.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end as goz,
                           coalesce(c.ad, '') as kaynak,
                           case g.durum when 1 then 'İstendi' when 2 then 'Çekildi' when 3 then 'Değerlendirildi' when 0 then 'İptal' else '' end as durum,
                           (g.muayene_id = gm.muayene_id) as "buMuayene", 'goruntuleme' as nesne, g.id
                      from public.goz_goruntuleme g
                      join public.goz_muayene gm on gm.id = @p0 and g.hasta_id = gm.hasta_id
                      left join public.goz_cihaz c on c.id = g.cihaz_id
                    union all
                    select z.ekleme_tarihi, 'Göz şeması', case z.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end,
                           'Çizim', case when z.kilitli = 1 then 'Kilitli' else 'Taslak' end, true, 'cizim', z.id
                      from public.goz_cizim z where z.goz_muayene_id = @p0
                ) x order by zaman desc nulls last limit 60
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Hastanın bu muayene ve önceki göz muayeneleri (en yeni önce): görme, GİB,
    /// C/D, RNFL, MD, plan. RNFL / MD önce muayenenin ek testinden, yoksa aynı
    /// gün çekilen görüntülemenin ölçümünden.
    /// </summary>
    private static Task<List<IDictionary<string, object?>>> GecmisAsync(
        Npgsql.NpgsqlConnection b, int id, int adet, CancellationToken iptal)
        => b.ListeAsync("""
            select gm.id, m.muayene_tarihi as tarih, gm.muayene_turu as tur, (gm.id = @p0) as bu,
                   v.bcva_od as "bcvaOd", v.bcva_os as "bcvaOs", v.gib_od as "gibOd", v.gib_os as "gibOs",
                   v.hedef_od as "hedefOd", v.hedef_os as "hedefOs",
                   (select max(f.cd_dikey) filter (where f.goz = 1) from public.goz_fundus f where f.goz_muayene_id = gm.id) as "cdOd",
                   (select max(f.cd_dikey) filter (where f.goz = 2) from public.goz_fundus f where f.goz_muayene_id = gm.id) as "cdOs",
                   coalesce((select max(e.deger_sayi) from public.goz_ek_test e where e.goz_muayene_id = gm.id and e.goz = 1 and e.test ilike '%rnfl%'),
                            (select max(o.deger) from public.goz_goruntuleme g join public.goz_goruntuleme_olcum o on o.goruntuleme_id = g.id
                              where g.hasta_id = gm.hasta_id and o.goz = 1 and o.olcum = 'rnfl_ort'
                                and g.cekim_zamani::date = m.muayene_tarihi::date)) as "rnflOd",
                   coalesce((select max(e.deger_sayi) from public.goz_ek_test e where e.goz_muayene_id = gm.id and e.goz = 2 and e.test ilike '%rnfl%'),
                            (select max(o.deger) from public.goz_goruntuleme g join public.goz_goruntuleme_olcum o on o.goruntuleme_id = g.id
                              where g.hasta_id = gm.hasta_id and o.goz = 2 and o.olcum = 'rnfl_ort'
                                and g.cekim_zamani::date = m.muayene_tarihi::date)) as "rnflOs",
                   (select min(o.deger) from public.goz_goruntuleme g join public.goz_goruntuleme_olcum o on o.goruntuleme_id = g.id
                     where g.hasta_id = gm.hasta_id and o.olcum = 'md' and g.cekim_zamani::date = m.muayene_tarihi::date) as md,
                   coalesce(gm.plan, '') as plan
              from public.goz_muayene gm
              join public.muayene m on m.id = gm.muayene_id
              join public.v_goz_muayene_ozet v on v.goz_muayene_id = gm.id
              join public.goz_muayene bu on bu.id = @p0
              join public.muayene bm on bm.id = bu.muayene_id
             where gm.hasta_id = bu.hasta_id and m.muayene_tarihi <= bm.muayene_tarihi
             order by m.muayene_tarihi desc limit @p1
            """, null, [id, adet], OkuyucuGenisletmeleri.Sozluk, iptal);
}
