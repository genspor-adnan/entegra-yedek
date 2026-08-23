-- ============================================================================
--  Gentegre AI - Hasta tablo adi duzeltmesi
--  067_hasta_bilgisi_tablo_adi.sql
--  Eski public.taraf_hasta iptal edilir; public.hasta_bilgisi public.taraf_hasta olur.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
    if to_regclass('public.hasta_bilgisi') is not null then
        if to_regclass('public.taraf_hasta') is not null then
            if exists (select 1 from public.taraf_hasta limit 1) then
                drop table if exists public.taraf_hasta_iptal_067;
                alter table public.taraf_hasta rename to taraf_hasta_iptal_067;
                alter table public.taraf_hasta_iptal_067 drop constraint if exists taraf_hasta_pkey;
                alter table public.taraf_hasta_iptal_067 drop constraint if exists taraf_hasta_taraf_id_fkey;
                alter table public.taraf_hasta_iptal_067 drop constraint if exists fk_taraf_hasta_kurum;
                drop index if exists public.ux_taraf_hasta_dosya;
                drop index if exists public.ix_taraf_hasta_grup;
            else
                drop table public.taraf_hasta;
            end if;
        end if;

        alter table public.hasta_bilgisi rename to taraf_hasta;

        if exists (select 1 from pg_constraint where conname = 'hasta_bilgisi_pkey')
           and not exists (select 1 from pg_constraint where conname = 'taraf_hasta_pkey') then
            alter table public.taraf_hasta
                rename constraint hasta_bilgisi_pkey to taraf_hasta_pkey;
        end if;

        if exists (select 1 from pg_constraint where conname = 'hasta_bilgisi_id_fkey')
           and not exists (select 1 from pg_constraint where conname = 'taraf_hasta_id_fkey') then
            alter table public.taraf_hasta
                rename constraint hasta_bilgisi_id_fkey to taraf_hasta_id_fkey;
        end if;
    end if;
end $$;

comment on table public.taraf_hasta is
  'Hasta karti 1:1 kimlik/ozluk bilgileri. id = taraf.id.';
