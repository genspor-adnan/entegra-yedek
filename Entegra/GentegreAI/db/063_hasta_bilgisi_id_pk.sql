-- ============================================================================
--  Gentegre AI - Hasta bilgisi 1:1 anahtar duzeltmesi
--  063_hasta_bilgisi_id_pk.sql
--  Eski hasta_bilgisi.taraf_id kaldirilir; hedef tablo taraf_hasta olur.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'hasta_bilgisi'
          and column_name = 'taraf_id'
    ) then
        alter table public.hasta_bilgisi rename to hasta_bilgisi_eski_063;
        alter table public.hasta_bilgisi_eski_063 drop constraint if exists hasta_bilgisi_pkey;
        drop index if exists public.ux_hasta_bilgisi_taraf;

        if to_regclass('public.taraf_hasta') is not null then
            if exists (select 1 from public.taraf_hasta limit 1) then
                drop table if exists public.taraf_hasta_iptal_063;
                alter table public.taraf_hasta rename to taraf_hasta_iptal_063;
            else
                drop table public.taraf_hasta;
            end if;
        end if;

        create table public.taraf_hasta (
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

        insert into public.taraf_hasta (
            id, dogum_tarihi, dogum_yeri, cinsiyet, uyruk, kan_grubu, meslek,
            ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi
        )
        select
            taraf_id, dogum_tarihi, dogum_yeri, cinsiyet, uyruk, kan_grubu, meslek,
            ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi
        from public.hasta_bilgisi_eski_063;

        drop table public.hasta_bilgisi_eski_063;
    elsif to_regclass('public.hasta_bilgisi') is not null
          and to_regclass('public.taraf_hasta') is null then
        alter table public.hasta_bilgisi rename to taraf_hasta;
    end if;
end $$;

comment on table public.taraf_hasta is
  'Hasta karti 1:1 kimlik/ozluk bilgileri. id = taraf.id.';
