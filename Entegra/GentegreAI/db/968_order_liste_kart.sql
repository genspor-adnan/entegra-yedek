-- 968 ORDER LİSTESİ + KARTI (mockup Ekranlar/Yatan/order_listesi_v2.html · order_karti_v2.html)
--
--   * yatis_order: STAT / PRN (+ koşul), infüzyon süresi, seyreltme.
--   * yuksek_riskli_ilac: yüksek riskli (çift kontrol) ilaç anahtarları - order adı
--     ya da ilacın etken maddesi içinde geçerse order "yüksek risk" sayılır.
--   * v_yatis_lookup: kartın "Yatış" alanı (yatak · hasta).
--   * v_yatis_order_ozet: liste / gösterge / önizleme aynı tanımdan okur.
--
-- ZAMAN: doz satırları order saatlerinden oturum saat diliminde (UTC) üretiliyor
--   (698) - "08:00" planlanan saatinin kendisi. Burada da gün / saat aynı şekilde
--   okunur; aksi halde 08:00 dozu 11:00 görünürdü.

alter table public.yatis_order
    add column if not exists stat        smallint     not null default 0,
    add column if not exists prn         smallint     not null default 0,
    add column if not exists prn_kosul   varchar(200) not null default '',
    add column if not exists infuzyon_dk integer,
    add column if not exists seyreltme   varchar(200) not null default '';

create table if not exists public.yuksek_riskli_ilac (
    id                serial primary key,
    anahtar           varchar(80)  not null unique,
    aciklama          varchar(200) not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer,
    degistirme_tarihi timestamptz
);

-- ISMP yüksek riskli ilaç listesinden servislerde en sık geçenler.
insert into public.yuksek_riskli_ilac (anahtar, aciklama)
select v.a, v.b from (values
    ('potasyum klorür', 'Konsantre elektrolit'), ('kcl', 'Konsantre elektrolit'),
    ('magnezyum sülfat', 'Konsantre elektrolit'), ('%3 nacl', 'Hipertonik sodyum'),
    ('insülin', 'Antidiyabetik'), ('heparin', 'Antikoagülan'), ('enoksaparin', 'Antikoagülan'),
    ('varfarin', 'Antikoagülan'), ('morfin', 'Opioid'), ('fentanil', 'Opioid'),
    ('dobutamin', 'İnotrop / vazopressör'), ('dopamin', 'İnotrop / vazopressör'),
    ('noradrenalin', 'İnotrop / vazopressör'), ('norepinefrin', 'İnotrop / vazopressör'),
    ('adrenalin', 'İnotrop / vazopressör'), ('amiodaron', 'Antiaritmik'), ('digoksin', 'Antiaritmik'),
    ('midazolam', 'Sedatif'), ('propofol', 'Sedatif'), ('metotreksat', 'Sitotoksik'),
    ('alteplaz', 'Trombolitik')
) v(a, b)
where not exists (select 1 from public.yuksek_riskli_ilac x where x.anahtar = v.a);

create or replace view public.v_yatis_lookup as
select y.id,
       (coalesce(nullif(yk.kod, '') || ' · ', '') || public.fn_taraf_ad(t.unvan, t.ad, t.soyad))::varchar(160) as ad,
       case when y.durum in (1, 2, 3) then 1 else 0 end::smallint as aktif
  from public.yatis y
  join public.taraf t on t.id = y.hasta_id
  left join public.yatak yk on yk.id = y.yatak_id
 where y.durum <> 0;

drop view if exists public.v_yatis_order_ozet;
create view public.v_yatis_order_ozet as
select od.id as order_id,
       coalesce(d.ad, '')::varchar(120)  as servis,
       coalesce(o.ad, '')::varchar(120)  as oda,
       case when th.dogum_tarihi is null then null else extract(year from age(th.dogum_tarihi))::int end as yas,
       coalesce(th.cinsiyet, 0)::smallint as cinsiyet,
       coalesce(al.alerjiler, '')::varchar(400) as alerjiler,
       -- GÜN x / y: başlangıçtan bugüne; bitişsiz order'da y yok.
       greatest(1, (now()::date - od.baslangic::date) + 1)::int as gun_no,
       case when od.bitis is null then null else greatest(1, od.bitis::date - od.baslangic::date)::int end as gun_toplam,
       coalesce(dz.bugun, '')::varchar(400) as bugun_dozlar,
       coalesce(dz.toplam, 0)::int  as toplam_doz,
       coalesce(dz.verilen, 0)::int as verilen_doz,
       coalesce(dz.geciken, 0)::int as geciken_doz,
       coalesce(dz.bugun_adet, 0)::int as bugun_doz,
       dz.sonraki,
       case when rk.anahtar is null then 0 else 1 end::smallint as yuksek_risk,
       coalesce(rk.anahtar, '')::varchar(80) as risk_anahtar,
       coalesce(ae.etken, '')::varchar(200) as alerji_eslesen,
       case when mk.id is null then 0 else 1 end::smallint as mukerrer,
       case when od.bitis is not null and od.bitis::date = now()::date then 1 else 0 end::smallint as bugun_bitiyor,
       -- UYARI: satırda tek bakışta (alerji > gecikme > imza > mükerrer > bitiş).
       concat_ws(' · ',
           case when ae.etken is not null then 'Alerji: ' || ae.etken end,
           case when coalesce(dz.geciken, 0) > 0 then dz.geciken || ' doz gecikti' end,
           case when od.sozel_order = 1 and od.onay_tarihi is null then 'imza bekliyor' end,
           case when mk.id is not null then 'mükerrer order' end,
           case when od.bitis is not null and od.bitis::date = now()::date and od.durum = 1 then 'bugün bitiyor' end
       )::varchar(400) as uyari
  from public.yatis_order od
  join public.yatis y on y.id = od.yatis_id
  left join public.taraf_hasta th on th.id = y.hasta_id
  left join public.yatak yk on yk.id = y.yatak_id
  left join public.oda o on o.id = yk.oda_id
  left join public.departman d on d.id = coalesce(o.departman_id, y.departman_id)
  left join public.ilac i on i.id = od.ilac_id
  left join lateral (
        select string_agg(distinct coalesce(nullif(a.etken_madde, ''), a.etken), ', ') as alerjiler
          from public.hasta_alerji a where a.hasta_id = y.hasta_id and a.aktif = 1) al on true
  -- ALERJİ EŞLEŞMESİ: alerjinin etken maddesinin ilk kelimesi (4+ harf) order
  --   adında ya da ilacın etken maddesinde geçiyorsa. Sınıf eşlemesi (penisilin
  --   -> amoksisilin) yok; o karar hekimde.
  left join lateral (
        select coalesce(nullif(a.etken_madde, ''), a.etken) as etken
          from public.hasta_alerji a
         where a.hasta_id = y.hasta_id and a.aktif = 1 and od.tur in (1, 2, 8)
           and length(split_part(lower(coalesce(nullif(a.etken_madde, ''), a.etken)), ' ', 1)) >= 4
           and lower(od.ad || ' ' || coalesce(i.etken_madde, ''))
               like '%' || split_part(lower(coalesce(nullif(a.etken_madde, ''), a.etken)), ' ', 1) || '%'
         limit 1) ae on true
  left join lateral (
        select r.anahtar from public.yuksek_riskli_ilac r
         where od.tur in (1, 2) and lower(od.ad || ' ' || coalesce(i.etken_madde, '')) like '%' || lower(r.anahtar) || '%'
         limit 1) rk on true
  left join lateral (
        select x.id from public.yatis_order x
         where x.yatis_id = od.yatis_id and x.id <> od.id and x.durum = 1 and od.durum = 1 and x.tur = od.tur
           and (case when od.ilac_id is not null then x.ilac_id = od.ilac_id else lower(x.ad) = lower(od.ad) end)
         limit 1) mk on true
  left join lateral (
        select count(*) as toplam,
               count(*) filter (where u.durum = 2) as verilen,
               count(*) filter (where u.durum = 5 or (u.durum = 1 and u.planlanan < now() - interval '30 minutes')) as geciken,
               count(*) filter (where u.planlanan::date = now()::date) as bugun_adet,
               min(u.planlanan) filter (where u.durum = 1 and u.planlanan >= now() - interval '30 minutes') as sonraki,
               -- "08:00|2;20:00|1" - saat | durum (1 bekliyor, 2 verildi, 3 atlandı, 4 reddetti, 5 gecikti)
               string_agg(to_char(u.planlanan, 'HH24:MI') || '|' ||
                          case when u.durum = 1 and u.planlanan < now() - interval '30 minutes' then 5 else u.durum end,
                          ';' order by u.planlanan) filter (where u.planlanan::date = now()::date) as bugun
          from public.order_uygulama u where u.order_id = od.id) dz on true;

comment on view public.v_yatis_order_ozet is
  'Order listesi / göstergesi / önizlemesi (968): servis, oda, hasta yaş-cinsiyet-alerji, '
  'gün x/y, bugünkü dozlar, gecikme, yüksek risk, alerji eşleşmesi, mükerrer, uyarı.';
