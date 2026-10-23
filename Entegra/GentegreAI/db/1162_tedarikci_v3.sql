-- =============================================================================
--  1162  TEDARİKÇİ LİSTESİ / KARTI V3
--
--  Kullanıcı (24.10.2026): "v3 tedarikçi listesi ve kartı mockup'larını koda
--  dök" (mockup Ekranlar/tedarikci_listesi_ver3.html + tedarikci_karti_ver3.html).
--
--  · taraf_tedarikci: satınalma koşulları (müşterideki taraf_musteri'nin
--    karşılığı) - vade, ödeme şekli / günü, erken ödeme iskontosu, alış fiyat
--    listesi, tedarik süresi, minimum sipariş, teslim şekli, sözleşme, bize
--    tanınan kredi limiti, onay durumu (A/B/C), tedarikçi türü, yerli / ithal.
--  · v_cari_ozet (1150 üstüne): tedarikçi gözüyle sütunlar - vadesi geçen
--    ÖDEME ve 30 günde ödenecek (alacak tarafı, aynı FIFO yaklaşımı), son alış,
--    son ödeme, 12 ay alım + eğri, bu yıl / geçen yıl alım. Müşteri sütunları
--    aynen kalır.
--  İdempotent.
-- =============================================================================

begin;

create table if not exists public.taraf_tedarikci (
    id                   integer primary key references public.taraf (id) on delete cascade,
    vade_gun             integer       not null default 0,
    odeme_sekli          smallint,                              -- 1 nakit 2 havale 3 çek 4 senet 5 kredi kartı 6 çek / havale
    odeme_gunu           varchar(60)   not null default '',     -- "her ayın 15'i ve 30'u"
    erken_odeme_iskonto  numeric(9,4)  not null default 0,      -- %
    erken_odeme_gun      integer       not null default 0,
    alis_fiyat_listesi_id integer,
    tedarik_suresi_gun   integer       not null default 0,
    min_siparis          numeric(14,2) not null default 0,
    teslim_sekli         smallint,                              -- 1 tedarikçi teslim 2 kargo 3 ambar 4 biz alırız
    sozlesme_no          varchar(40)   not null default '',
    sozlesme_bitis       date,
    kredi_limiti         numeric(14,2) not null default 0,      -- bize tanınan
    onay_durumu          smallint      not null default 0,      -- 0 - / 1 A onaylı / 2 B / 3 C izlemede
    tedarikci_turu       smallint      not null default 0,      -- 1 üretici 2 distribütör 3 toptancı 4 hizmet 5 ithalatçı
    yerli_ithal          smallint      not null default 1,      -- 1 yerli 2 ithal
    satinalmaci_id       integer,
    sube_id              integer       not null default 0,
    ekleyen              integer       not null default 0,
    ekleme_tarihi        timestamp     not null default now()::timestamp,
    degistiren           integer       not null default 0,
    degistirme_tarihi    timestamp
);
comment on table public.taraf_tedarikci is 'Tedarikci satinalma kosullari (mockup tedarikci_karti_ver3 - taraf_musteri karsiligi). 1:1 taraf.';

-- v_cari_ozet: 1150 + tedarikçi sütunları (view kolon ekleme: drop + create).
drop view if exists public.v_cari_ozet;
create view public.v_cari_ozet as
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
bakiye as (
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
    select h.taraf_id, date_trunc('month', h.islem_tarihi) as ay,
           sum(h.yerel_borc - h.yerel_alacak) filter (where h.tur in (15, 16, 17)) as t,
           sum(h.yerel_alacak - h.yerel_borc) filter (where h.tur in (11, 12, 13)) as a
      from h
     where h.tur in (15, 16, 17, 11, 12, 13) and h.islem_tarihi >= date_trunc('month', now()) - interval '11 months'
     group by 1, 2
),
egri as (
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
    '1150 + 1162: cari basina bakiye, doviz bakiyeleri, vadesi gecen (alacak ve ODEME), 30 gunde odenecek, son satis / tahsilat / alis / odeme, 12 ay ciro ve ALIM + aylik egriler. Musteri ve Tedarikci Listesi Ver3.';

commit;
