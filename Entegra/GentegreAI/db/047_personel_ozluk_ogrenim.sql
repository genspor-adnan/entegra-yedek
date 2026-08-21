-- ============================================================================
--  Gentegre AI — Personel Özlük: Öğrenim Durumu / Okul / Çalışma Şekli
--  047_personel_ozluk_ogrenim.sql
--
--  Kullanici: "Öğrenim Durumu combo... Okulu eşit serbest.. Çalışma Şekli: Yarı Zamanlı/
--  Tam Zamanlı".
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.personel_ozluk add column if not exists ogrenim_durumu smallint not null default 0;
alter table public.personel_ozluk add column if not exists okul character varying(150) not null default '';
alter table public.personel_ozluk add column if not exists calisma_sekli smallint not null default 0;
