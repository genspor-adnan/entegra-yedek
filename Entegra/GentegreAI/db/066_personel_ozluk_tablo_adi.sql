-- ============================================================================
--  Gentegre AI - Personel tablo adi duzeltmesi
--  066_personel_ozluk_tablo_adi.sql
--  public.personel_ozluk tablosu public.taraf_personel olarak yeniden adlandirilir.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
    if to_regclass('public.personel_ozluk') is not null
       and to_regclass('public.taraf_personel') is null then
        alter table public.personel_ozluk rename to taraf_personel;
    end if;

    if exists (select 1 from pg_constraint where conname = 'personel_ozluk_pkey') then
        alter table public.taraf_personel
            rename constraint personel_ozluk_pkey to taraf_personel_pkey;
    end if;

    if exists (select 1 from pg_constraint where conname = 'personel_ozluk_id_fkey') then
        alter table public.taraf_personel
            rename constraint personel_ozluk_id_fkey to taraf_personel_id_fkey;
    end if;

    if exists (select 1 from pg_constraint where conname = 'personel_ozluk_sube_id_fkey') then
        alter table public.taraf_personel
            rename constraint personel_ozluk_sube_id_fkey to taraf_personel_sube_id_fkey;
    end if;

    if exists (select 1 from pg_constraint where conname = 'personel_ozluk_yonetici_taraf_id_fkey') then
        alter table public.taraf_personel
            rename constraint personel_ozluk_yonetici_taraf_id_fkey to taraf_personel_yonetici_taraf_id_fkey;
    end if;
end $$;

comment on table public.taraf_personel is
  'Personel ozluk bilgileri. 1:1 iliski: id = taraf.id.';
