-- 286: RADYOLOJİ SEÇİM GÖRÜNÜMLERİ (worklist ve istem kartı için).
--
-- Kart alanları combo'yu `(id, ad, aktif)` sözleşmesiyle çeker; radyolojide
-- üç seçim kaynağı gerekiyor: cihaz, tetkik (yalnız radyoloji hizmetleri) ve
-- istem hekimi (283'te v_rad_hekim_lookup olarak açıldı).

create or replace view public.v_rad_cihaz_lookup as
select c.id,
       (coalesce(nullif(c.kod, '') || ' · ', '') || c.ad)::varchar(160) as ad,
       c.durum as aktif
  from public.radyoloji_cihaz c;

comment on view public.v_rad_cihaz_lookup is 'Modalite cihazı seçimi (286).';

-- TETKİK: tüm hizmetler değil, YALNIZ radyoloji işaretli olanlar. İstem başka
-- bir hizmete açılırsa worklist'e klinik karşılığı olmayan satır düşer.
create or replace view public.v_rad_tetkik_lookup as
select h.id,
       (coalesce(nullif(h.kod, '') || ' · ', '') || h.ad)::varchar(200) as ad,
       case when coalesce(h.durum, 1) = 1 then 1 else 0 end as aktif
  from public.hizmet h
 where h.radyoloji = 1;

comment on view public.v_rad_tetkik_lookup is
  'Radyoloji tetkiki seçimi (286) - hizmet.radyoloji = 1 olanlar.';
