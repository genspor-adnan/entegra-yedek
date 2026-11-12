-- 1327 - v_cari_ozet: ara adımlar MATERIALIZED (cari listesi zaman aşımı)
--
-- Kullanıcı 12.11.2026: "medx serverda tedarikçi listesi hata veriyor.. yeni alış irsaliyesi deyince gelen tedarikçi
-- listesi de hatalı". Sunucu günlüğü: /api/liste/cari → Npgsql "Timeout during reading attempt". Cari listesi
-- v_cari_ozet'e left join yapıyor; görünümün bakiye / doviz / ay / egri CTE'leri satır içine açılıyordu (yalnız yp ve h
-- materialized idi). Planlayıcı CTE sonuç tahminini 1-3 satır sanıp iç içe döngü seçiyor, eğri adımını her cari için
-- yeniden sıralıyordu (MEDX: 533 cari × ~3000 satır). Tedarikçi listesi sorgusu MEDX'te 2030 ms → 57 ms (aynı veri,
-- yalnız ara adımlar materialized); arama + toplam sayım eklenince eski hâl 30 sn sınırını aşıyordu.
-- Sütunlar ve hesap DEĞİŞMEZ (1162'nin birebir aynısı + materialized) - create or replace, bağımlılar korunur.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

create or replace view public.v_cari_ozet as
with yp as materialized (
    select public.fn_yerel_para()::text as kod
),
h as materialized (
    -- VADE: hareketin plan tarihi; yoksa işlem tarihi + carinin vade günü (müşteride taraf_musteri,
    --   alış belgelerinde taraf_tedarikci).
    select e.taraf_id, e.tur, e.islem_tarihi,
           coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days =>
               case when e.tur in (11, 12, 13) then coalesce(tt.vade_gun, tm.vade_gun, 0) else coalesce(tm.vade_gun, 0) end)) as vade,
           e.doviz_cinsi, e.borc, e.alacak, e.yerel_borc, e.yerel_alacak
      from public.v_mali_hareket_ek e
      left join public.taraf_musteri tm on tm.id = e.taraf_id
      left join public.taraf_tedarikci tt on tt.id = e.taraf_id
     where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.islem_durum in (1, 2)
       and e.bakiye_dahil = 1 and e.taraf_id is not null
),
bakiye as materialized (
    select h.taraf_id,
           sum(h.yerel_borc - h.yerel_alacak) as bakiye,
           greatest(coalesce(sum(h.yerel_borc) filter (where h.vade < date_trunc('day', now())), 0)
                    - sum(h.yerel_alacak), 0) as vadesi_gecen,
           -- TEDARİKÇİ GÖZÜ (1162): alacak tarafı aynı kural - ödemeler (borç) önce vadesi en eski borcumuzu kapatır.
           greatest(coalesce(sum(h.yerel_alacak) filter (where h.vade < date_trunc('day', now())), 0)
                    - sum(h.yerel_borc), 0) as vadesi_gecen_odeme,
           greatest(coalesce(sum(h.yerel_alacak) filter (where h.vade < date_trunc('day', now()) + interval '30 days'), 0)
                    - sum(h.yerel_borc), 0)
             - greatest(coalesce(sum(h.yerel_alacak) filter (where h.vade < date_trunc('day', now())), 0)
                    - sum(h.yerel_borc), 0) as odenecek_30,
           max(h.islem_tarihi) filter (where h.tur in (15, 16, 17) and h.yerel_borc > 0) as son_satis,
           max(h.islem_tarihi) filter (where h.yerel_alacak > 0 and h.tur not in (15, 16, 17, 11, 12, 13)) as son_tahsilat,
           max(h.islem_tarihi) filter (where h.tur in (11, 12, 13) and h.yerel_alacak > 0) as son_alis,
           max(h.islem_tarihi) filter (where h.yerel_borc > 0 and h.tur not in (15, 16, 17, 11, 12, 13)) as son_odeme,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months') as ciro_12ay,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17) and h.islem_tarihi >= date_trunc('year', now())) as ciro_bu_yil,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17) and h.islem_tarihi >= date_trunc('year', now()) - interval '1 year'
                 and h.islem_tarihi < now() - interval '1 year') as ciro_gecen_yil,
           sum(h.yerel_alacak - h.yerel_borc) filter (
               where h.tur in (11, 12, 13) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months') as alis_12ay,
           sum(h.yerel_alacak - h.yerel_borc) filter (
               where h.tur in (11, 12, 13) and h.islem_tarihi >= date_trunc('year', now())) as alis_bu_yil,
           sum(h.yerel_alacak - h.yerel_borc) filter (
               where h.tur in (11, 12, 13) and h.islem_tarihi >= date_trunc('year', now()) - interval '1 year'
                 and h.islem_tarihi < now() - interval '1 year') as alis_gecen_yil
      from h
     group by h.taraf_id
),
doviz as materialized (
    select x.taraf_id, string_agg(x.doviz_cinsi || ':' || x.b::text, ';' order by x.doviz_cinsi) as doviz_bakiye
      from (select h.taraf_id, h.doviz_cinsi, sum(h.borc - h.alacak) as b
              from h, yp
             where h.doviz_cinsi <> yp.kod
             group by h.taraf_id, h.doviz_cinsi
            having abs(sum(h.borc - h.alacak)) >= 0.005) x
     group by x.taraf_id
),
ay as materialized (
    select h.taraf_id, date_trunc('month', h.islem_tarihi) as ay,
           sum(h.yerel_borc - h.yerel_alacak) filter (where h.tur in (15, 16, 17)) as t,
           sum(h.yerel_alacak - h.yerel_borc) filter (where h.tur in (11, 12, 13)) as a
      from h
     where h.tur in (15, 16, 17, 11, 12, 13) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months'
     group by 1, 2
),
egri as materialized (
    select k.taraf_id, string_agg(round(coalesce(a.t, 0))::text, ',' order by g.ay) as ciro_egri,
           string_agg(round(coalesce(a.a, 0))::text, ',' order by g.ay) as alis_egri
      from (select distinct taraf_id from ay) k
     cross join generate_series(date_trunc('month', now()) - interval '11 months',
                                date_trunc('month', now()), interval '1 month') g(ay)
      left join ay a on a.taraf_id = k.taraf_id and a.ay = g.ay
     group by k.taraf_id
)
select b.taraf_id, b.bakiye, b.vadesi_gecen, b.son_satis, b.son_tahsilat,
       coalesce(b.ciro_12ay, 0) as ciro_12ay, coalesce(b.ciro_bu_yil, 0) as ciro_bu_yil,
       coalesce(b.ciro_gecen_yil, 0) as ciro_gecen_yil,
       coalesce(d.doviz_bakiye, '') as doviz_bakiye, coalesce(e.ciro_egri, '') as ciro_egri,
       b.vadesi_gecen_odeme, b.odenecek_30, b.son_alis, b.son_odeme,
       coalesce(b.alis_12ay, 0) as alis_12ay, coalesce(b.alis_bu_yil, 0) as alis_bu_yil,
       coalesce(b.alis_gecen_yil, 0) as alis_gecen_yil, coalesce(e.alis_egri, '') as alis_egri
  from bakiye b
  left join doviz d on d.taraf_id = b.taraf_id
  left join egri e on e.taraf_id = b.taraf_id;

comment on view public.v_cari_ozet is
    '1150 + 1162 (+1327 materialized ara adımlar): cari basina bakiye, doviz bakiyeleri, vadesi gecen (alacak ve ODEME), 30 gunde odenecek, son satis / tahsilat / alis / odeme, 12 ay ciro ve ALIM + aylik egriler. Musteri ve Tedarikci Listesi Ver3.';

commit;
