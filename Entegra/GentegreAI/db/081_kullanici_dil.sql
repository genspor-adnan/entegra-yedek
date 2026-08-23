-- 081_kullanici_dil.sql
-- Kullanici tercih dili. Idempotent: eski kurulumlarda kolon yoksa ekler.

alter table public.taraf_kullanici
    add column if not exists dil smallint not null default 0;

comment on column public.taraf_kullanici.dil is
    'Kullanici arayuz dili. 0=Turkce, 1=English, 2=Deutsch.';
