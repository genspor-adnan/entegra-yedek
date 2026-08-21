-- ============================================================================
--  Gentegre AI — Personel Özlük: Sözleşme Türü / Deneme Süresi
--  050_personel_ozluk_sozlesme_deneme.sql
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.personel_ozluk add column if not exists sozlesme_turu smallint not null default 0;
alter table public.personel_ozluk add column if not exists deneme_suresi smallint not null default 0;
