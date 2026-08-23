-- ============================================================================
--  Gentegre AI - Kisi rolu 1:1 uzanti tablosu
--  069_taraf_kisi.sql
--  taraf_kisi hazir tablo: id = taraf.id.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.taraf_kisi (
    id                   integer primary key references public.taraf(id) on delete cascade,
    ekleyen              integer   not null default 0,
    ekleme_tarihi        timestamp not null default now()::timestamp,
    degistiren           integer   not null default 0,
    degistirme_tarihi    timestamp
);

insert into public.taraf_kisi (id)
select t.id
  from public.taraf t
 where t.kisi = 1
   and not exists (select 1 from public.taraf_kisi k where k.id = t.id);

comment on table public.taraf_kisi is
  'Kisi rolu 1:1 uzanti tablosu. id = taraf.id.';
