--  Gentegre AI - Dokuman belge turu
--  060_dokuman_belge_turu.sql
--  Kullanici yazabilir: is sozlesmesi, saglik raporu vb.

alter table public.dokuman
    add column if not exists belge_turu character varying(80) not null default '';

comment on column public.dokuman.belge_turu is
  'Kullanici tarafindan yazilan belge turu: is sozlesmesi, saglik raporu vb.';
