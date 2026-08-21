-- ============================================================================
--  Gentegre AI — Personel Özlük: Uyruğu / Vardiya Türü / SGK Başlama Tarihi
--  048_personel_ozluk_uyruk_vardiya_sgk.sql
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.personel_ozluk add column if not exists uyruk character varying(60) not null default 'TC';
alter table public.personel_ozluk add column if not exists vardiya_turu smallint not null default 0;
alter table public.personel_ozluk add column if not exists sgk_baslama_tarihi date;
