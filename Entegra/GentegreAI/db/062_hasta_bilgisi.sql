-- ============================================================================
--  Gentegre AI - Hasta bilgisi 1:1 detay tablosu
--  062_hasta_bilgisi.sql
--  Hasta kartinda dogum/cinsiyet/uyruk/kan grubu/meslek alanlari taraf_hasta
--  tablosunda tutulur.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.taraf_hasta (
    id                  integer primary key references public.taraf(id) on delete cascade,
    dogum_tarihi        date,
    dogum_yeri          character varying(60) not null default '',
    cinsiyet            smallint not null default 0,
    uyruk               character varying(60) not null default 'TC',
    kan_grubu           smallint not null default 0,
    meslek              character varying(60) not null default '',
    ekleyen             integer not null default 0,
    ekleme_tarihi       timestamp not null default now()::timestamp,
    degistiren          integer not null default 0,
    degistirme_tarihi   timestamp
);

comment on table public.taraf_hasta is
  'Hasta karti 1:1 kimlik/ozluk bilgileri. id = taraf.id.';

