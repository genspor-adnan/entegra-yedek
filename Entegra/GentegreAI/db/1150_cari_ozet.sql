-- =============================================================================
--  1150  CARI OZETI - Musteri Listesi Ver3 (mockup Ekranlar/musteri_listesi_ver3.html)
--
--  Musteri listesinin para kolonlari ve gosterge seridi tek gorunumden:
--    bakiye           yerel para (TL) karsiligi, cari ekstresinin bakiyesi
--                     (v_cari_ekstre ile AYNI kume: cari hesabi, ekstrede
--                     kullanilan, iptal olmayan, bakiyeye dahil)
--    doviz_bakiye     yerel olmayan para birimlerinin kendi bakiyesi,
--                     "USD:42500.0000;EUR:-18900.0000" (+ borc, - alacak)
--    vadesi_gecen     FIFO: vadesi (plan_tarihi, yoksa islem tarihi + carinin
--                     vade gunu) bugunden
--                     once olan borclar - toplam alacak. Tahsilat once en eski
--                     borcu kapatir (alacak yaslandirmanin kurali).
--    son_satis        son satis faturasi / fisi / tahakkuku (tur 15/16/17)
--    ciro_12ay        son 12 ayin satisi (KDV dahil, cari hareketinden - iade
--                     duser), ciro_egri ayni 12 ay, aylik, virgullu
--    ciro_bu_yil / ciro_gecen_yil   yilbasindan bugune / gecen yilin ayni donemi
--    son_tahsilat     son alacak hareketi (tahsilat, cek, iade disinda)
--
--  SUBE: cari ana veridir (subeler arasi ortak), ozet de TUM subelerin
--  hareketini sayar. Cari Ekstre listesi aktif subeye suzuludur - cok subeli
--  kurulumda iki rakam farkli olabilir (bilerek; bkz. dokuman/00_TARIHCE).
-- =============================================================================

begin;

create or replace view public.v_cari_ozet as
with yp as materialized (
    -- Yerel para bir kez okunur: satir basina fn_yerel_para() 20 bin satirda 250 ms.
    select public.fn_yerel_para()::text as kod
),
h as materialized (
    -- VADE: hareketin plan tarihi; yoksa islem tarihi + carinin vade gunu (taraf_musteri).
    select e.taraf_id, e.tur, e.islem_tarihi,
           coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => coalesce(tm.vade_gun, 0))) as vade,
           e.doviz_cinsi, e.borc, e.alacak, e.yerel_borc, e.yerel_alacak
      from public.v_mali_hareket_ek e
      left join public.taraf_musteri tm on tm.id = e.taraf_id
     where e.hesap_turu = 'C' and e.cari_ekstre = 1 and e.islem_durum in (1, 2)
       and e.bakiye_dahil = 1 and e.taraf_id is not null
),
bakiye as (
    select h.taraf_id,
           sum(h.yerel_borc - h.yerel_alacak) as bakiye,
           greatest(coalesce(sum(h.yerel_borc) filter (
                        where h.vade < date_trunc('day', now())), 0)
                    - sum(h.yerel_alacak), 0) as vadesi_gecen,
           max(h.islem_tarihi) filter (where h.tur in (15, 16, 17) and h.yerel_borc > 0) as son_satis,
           max(h.islem_tarihi) filter (where h.yerel_alacak > 0 and h.tur not in (15, 16, 17)) as son_tahsilat,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months') as ciro_12ay,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17) and h.islem_tarihi >= date_trunc('year', now())) as ciro_bu_yil,
           sum(h.yerel_borc - h.yerel_alacak) filter (
               where h.tur in (15, 16, 17) and h.islem_tarihi >= date_trunc('year', now()) - interval '1 year'
                 and h.islem_tarihi < now() - interval '1 year') as ciro_gecen_yil
      from h
     group by h.taraf_id
),
doviz as (
    select x.taraf_id, string_agg(x.doviz_cinsi || ':' || x.b::text, ';' order by x.doviz_cinsi) as doviz_bakiye
      from (select h.taraf_id, h.doviz_cinsi, sum(h.borc - h.alacak) as b
              from h, yp
             where h.doviz_cinsi <> yp.kod
             group by h.taraf_id, h.doviz_cinsi
            having abs(sum(h.borc - h.alacak)) >= 0.005) x
     group by x.taraf_id
),
ay as (
    select h.taraf_id, date_trunc('month', h.islem_tarihi) as ay, sum(h.yerel_borc - h.yerel_alacak) as t
      from h
     where h.tur in (15, 16, 17) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months'
     group by 1, 2
),
egri as (
    select k.taraf_id, string_agg(round(coalesce(a.t, 0))::text, ',' order by g.ay) as ciro_egri
      from (select distinct taraf_id from ay) k
     cross join generate_series(date_trunc('month', now()) - interval '11 months',
                                date_trunc('month', now()), interval '1 month') g(ay)
      left join ay a on a.taraf_id = k.taraf_id and a.ay = g.ay
     group by k.taraf_id
)
select b.taraf_id, b.bakiye, b.vadesi_gecen, b.son_satis, b.son_tahsilat,
       coalesce(b.ciro_12ay, 0) as ciro_12ay, coalesce(b.ciro_bu_yil, 0) as ciro_bu_yil,
       coalesce(b.ciro_gecen_yil, 0) as ciro_gecen_yil,
       coalesce(d.doviz_bakiye, '') as doviz_bakiye, coalesce(e.ciro_egri, '') as ciro_egri
  from bakiye b
  left join doviz d on d.taraf_id = b.taraf_id
  left join egri e on e.taraf_id = b.taraf_id;

comment on view public.v_cari_ozet is
    '1150: cari basina bakiye (TL karsiligi), doviz bakiyeleri, vadesi gecen (FIFO), son satis / tahsilat, 12 ay ciro ve aylik egri. Musteri Listesi Ver3 kolonlari ve gosterge seridi.';

commit;
