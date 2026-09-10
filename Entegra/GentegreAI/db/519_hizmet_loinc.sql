-- =====================================================================
--  519_hizmet_loinc.sql
--  Hizmet kataloğunda LOINC kodu.
--
--  Kullanıcı: "hizmet listesi tek; bu hizmet listesinde SUT/TTB-HUV/LOINC
--  kodları da olmalı. LOINC lab'a özgü ise tetkik kataloğunda da olabilir."
--
--  `sut_kodu` ve `huv_kodu` (484) zaten kartta; LOINC yoktu. İki yerde
--  tutulur ama AYNI ANLAMDA değil:
--    * `hizmet.loinc`     - satılabilir kalemin uluslararası karşılığı;
--                           e-Nabız/araştırma bildiriminde kullanılır.
--    * `lab_tetkik.loinc` - çalışılan testin karşılığı (zaten vardı, 433).
--  Panelde ikisi ayrışır: "Tam Kan Sayımı" hizmetinin LOINC'i ile içindeki
--  hemoglobinin LOINC'i başka kodlardır - o yüzden tek kolona indirilmedi.
--
--  SKRS'nin LOINC listesi (NUMARASI · Türkçe karşılığı · ÖRNEKBİRİM ·
--  MATERYAL · METOT) buraya kaynak olacak; kod alanı önce açılır.
-- =====================================================================

alter table public.hizmet
    add column if not exists loinc varchar(12) not null default '';

comment on column public.hizmet.loinc is
    'LOINC kodu (519) - laboratuvar tetkikinin uluslararası karşılığı; lab_tetkik.loinc çalışılan testin kodudur.';

create index if not exists ix_hizmet_loinc on public.hizmet (loinc) where loinc <> '';

-- Lab tetkikinin LOINC'i varsa ve hizmetinki boşsa: köprüden (501) taşınır.
update public.hizmet h
   set loinc = t.loinc
  from public.lab_tetkik t
 where t.hizmet_id = h.id and h.loinc = '' and coalesce(t.loinc, '') <> '';
