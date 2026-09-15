using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ MUAYENE KARTI ÜST ŞERİDİ — mockup
/// <c>Ekranlar/Goz/goz_detayli_muayene.html</c> başlık + bağlam kutuları.
///
/// <para><b>Hekim kartı açtığında dört şeyi ÖLÇÜMDEN ÖNCE okur:</b> kim (yaş,
/// cinsiyet, protokol), niçin geldi (şikâyet), neyi var (sistemik hastalık ve
/// kullandığı ilaç), teknikerin ne ölçtüğü (otoref/tonometri saatleri, dilate
/// mi). Mockup bu yüzden ölçüm sekmelerinin ÜSTÜNE bir bağlam şeridi koyuyor —
/// bunlar sekmeye gömülseydi hekim her muayenede iki kez gezinirdi.</para>
///
/// <para><b>ÖN TETKİK CİHAZDAN GELİR, ELLE YAZILMAZ:</b> şerit, kaynağı cihaz
/// (kaynak = 3) olan ölçümlerin saatini gösterir. "Otoref ✔ 10:02" satırı,
/// teknikerin ölçümü yaptığının ve cihazın gönderdiğinin kanıtı; hekim aynı
/// değeri ikinci kez ölçmek zorunda kalmaz.</para>
///
/// <para><b>Tamamlanma sayaçları AYNI SORGUDAN:</b> mockup'ın alt durum
/// çubuğu ("VA ✔ · Ref ✔ · GİB ✔ …") hangi ölçüm kümesinin dolduğunu söyler.
/// İstemci sekme sayaçlarından toplasaydı, açılmamış sekmenin verisi
/// olmadığı için eksik sayardı.</para>
/// </summary>
public static partial class GozUclari
{
    private static void SeritUcunuEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/muayene/{id:int}/serit", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var kimlik = await baglanti.TekAsync("""
                select t.unvan                                as hasta,
                       -- TİPSİZ `null` DALI OLMAZ: CASE'in bir dalı `unknown`
                       --   kalınca sürücü sonucu çözemiyor ("22P02"). Null da
                       --   tiplenir.
                       case when th.dogum_tarihi is null then null::int
                            else extract(year from age(th.dogum_tarihi))::int end as yas,
                       coalesce(th.cinsiyet, 0)               as cinsiyet,
                       coalesce(t.kod, '')                    as hasta_no,
                       coalesce(m.muayene_no, '')             as protokol,
                       m.muayene_tarihi,
                       coalesce(h.unvan, '')                  as hekim,
                       coalesce(d.ad, '')                     as bolum,
                       coalesce(m.sikayet, '')                as sikayet,
                       coalesce(m.ozgecmis_notu, '')          as ozgecmis,
                       -- SİSTEM SORGUSU JSONB'dir (sistem sistem yanıtlar):
                       --   şeritte tek satır özet gerekiyor, ham JSON değil.
                       --   Boş nesne ({}) de "yok" sayılır.
                       case when m.sistem_sorgusu is null
                              or m.sistem_sorgusu::text in ('{}', 'null') then ''
                            else (select string_agg(a.key || ': ' || a.value, ' · ')
                                    from jsonb_each_text(m.sistem_sorgusu) a)
                       end                                    as sistem,
                       coalesce(m.soygecmis_notu, '')         as soygecmis,
                       coalesce(gm.dilate, 0)                 as dilate,
                       coalesce(gm.dilatasyon_ilac, '')       as dilatasyon_ilac,
                       coalesce(gm.muayene_turu, 0)           as muayene_turu,
                       -- TAMAMLANMA bir ZAMAN damgası (muayene ne zaman
                       --   kapandı), bayrak değil: dolu olması "tamamlandı"
                       --   demek. Kolonu smallint sanıp okumak 400 veriyordu.
                       (m.tamamlanma is not null)             as tamamlandi,
                       -- ODA: ünite akışında hastanın o an bulunduğu istasyon.
                       --   Muayene kaydında oda kolonu yok; akış satırı taşıyor.
                       coalesce((select i.oda from public.goz_ziyaret_istasyon i
                                  where i.belge_id = m.belge_id and i.oda <> ''
                                  order by i.giris desc limit 1), '') as oda
                  from public.goz_muayene gm
                  join public.muayene m on m.id = gm.muayene_id
                  join public.taraf t on t.id = gm.hasta_id
                  left join public.taraf_hasta th on th.id = gm.hasta_id
                  left join public.taraf h on h.id = m.personel_id
                  left join public.departman d on d.id = m.bolum_id
                 where gm.id = @p0
                """, null, [id], o => new
            {
                hasta = o.GetString(0),
                yas = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                cinsiyet = (int)o.GetInt16(2),
                hastaNo = o.GetString(3),
                protokol = o.GetString(4),
                tarih = o.GetDateTime(5),
                hekim = o.GetString(6),
                bolum = o.GetString(7),
                sikayet = o.GetString(8),
                ozgecmis = o.GetString(9),
                sistem = o.GetString(10),
                soygecmis = o.GetString(11),
                dilate = o.GetInt16(12) == 1,
                dilatasyonIlac = o.GetString(13),
                muayeneTuru = (int)o.GetInt16(14),
                tamamlandi = o.GetBoolean(15),
                oda = o.GetString(16),
            }, iptal);

            if (kimlik is null) return Results.NotFound();

            // ÖN TETKİK: kaynağı CİHAZ olan ölçümler ve saatleri. Hekimin
            //   "bunu tekniker ölçtü mü" sorusunun cevabı; elle girilen
            //   değerle karıştırılmasın diye kaynak ayrımı korunuyor.
            var onTetkik = await baglanti.ListeAsync("""
                select 'Otoref'::text as ad, min(r.zaman) as zaman, count(*)::int as sayi
                  from public.goz_refraksiyon r
                 where r.goz_muayene_id = @p0 and r.kaynak = 3
                having count(*) > 0
                union all
                select (case when max(t.yontem) = 1 then 'Tonometri (NCT)'
                             else 'Tonometri' end)::text,
                       min(t.zaman), count(*)::int
                  from public.goz_tonometri t
                 where t.goz_muayene_id = @p0 and t.kaynak = 3
                having count(*) > 0
                union all
                select 'Pakimetri'::text, min(t.zaman), count(*)::int
                  from public.goz_tonometri t
                 where t.goz_muayene_id = @p0 and t.kaynak = 3 and t.cct_um is not null
                having count(*) > 0
                """, null, [id], o => new
            {
                ad = o.GetString(0),
                zaman = o.IsDBNull(1) ? (DateTime?)null : o.GetDateTime(1),
                sayi = o.GetInt32(2),
            }, iptal);

            // TAMAMLANMA: mockup'ın durum çubuğu. Hangi ölçüm kümesi dolu,
            //   hangisi boş - "tanı ana" ayrı sayılır çünkü ana tanısı
            //   olmayan muayene kapanmamalı.
            var durum = await baglanti.TekAsync("""
                select (select count(*) from public.goz_gorme x
                         where x.goz_muayene_id = @p0)::int        as va,
                       (select count(*) from public.goz_refraksiyon x
                         where x.goz_muayene_id = @p0)::int        as ref,
                       (select count(*) from public.goz_tonometri x
                         where x.goz_muayene_id = @p0)::int        as gib,
                       (select count(*) from public.goz_on_segment x
                         where x.goz_muayene_id = @p0)::int        as on_segment,
                       (select count(*) from public.goz_fundus x
                         where x.goz_muayene_id = @p0)::int        as fundus,
                       -- TANI genel muayene kaydına düşer (public.tani):
                       --   göz tanısı da ICD-10'dur, ayrı bir tablo açmak
                       --   hastanın tanı listesini ikiye bölerdi.
                       (select count(*) from public.tani x
                          join public.goz_muayene g on g.muayene_id = x.muayene_id
                         where g.id = @p0)::int                    as tani
                """, null, [id], o => new
            {
                va = o.GetInt32(0),
                ref_ = o.GetInt32(1),
                gib = o.GetInt32(2),
                onSegment = o.GetInt32(3),
                fundus = o.GetInt32(4),
                tani = o.GetInt32(5),
            }, iptal);

            return Results.Ok(new { kimlik, onTetkik, durum });
        });
    }
}
