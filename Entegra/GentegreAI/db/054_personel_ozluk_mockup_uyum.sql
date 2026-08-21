-- ============================================================================
--  Gentegre AI — Personel Özlük: ik_karti.html mockup uyum turu (SGK Sicil No,
--  Meslek Kodu, Yönetici) - kullanici: "mockup baz al.. farkliysa mockup gibi yap"
--  054_personel_ozluk_mockup_uyum.sql
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.personel_ozluk add column if not exists sgk_sicil_no character varying(30) not null default '';
alter table public.personel_ozluk add column if not exists meslek_kodu character varying(60) not null default '';
alter table public.personel_ozluk add column if not exists yonetici_taraf_id integer references public.taraf(id);

-- "Yönetici" combosu icin - v_cari_lookup ile ayni sozlesme (id/ad/aktif), sadece personel.
create or replace view public.v_personel_lookup as
select id, unvan as ad, case when durum = 1 then 1 else 0 end as aktif
  from public.taraf
 where personel = 1;
