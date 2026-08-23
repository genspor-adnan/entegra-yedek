-- ============================================================================
--  Gentegre AI — Personel Özlük: Doğum Yeri (ik_karti.html mockup)
--  051_personel_ozluk_dogum_yeri.sql
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf_personel add column if not exists dogum_yeri character varying(60) not null default '';

