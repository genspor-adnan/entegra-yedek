-- ============================================================================
--  Gentegre AI - Kullanici tablo adi duzeltmesi
--  065_kullanici_tablo_adi.sql
--  public.kullanici tablosu public.taraf_kullanici olarak yeniden adlandirilir.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
    if to_regclass('public.kullanici') is not null
       and to_regclass('public.taraf_kullanici') is null then
        alter table public.kullanici rename to taraf_kullanici;
    end if;

    if exists (select 1 from pg_constraint where conname = 'ck_kullanici_kod') then
        alter table public.taraf_kullanici
            rename constraint ck_kullanici_kod to ck_taraf_kullanici_kod;
    end if;

    if exists (select 1 from pg_constraint where conname = 'fk_kullanici_rol') then
        alter table public.taraf_kullanici
            rename constraint fk_kullanici_rol to fk_taraf_kullanici_rol;
    end if;

    alter index if exists public.ux_kullanici_kod rename to ux_taraf_kullanici_kod;
    alter index if exists public.ux_kullanici_eski_id rename to ux_taraf_kullanici_eski_id;
    alter index if exists public.ix_kullanici_rol rename to ix_taraf_kullanici_rol;
end $$;

comment on table public.taraf_kullanici is
  'Uygulama kullanicisi. id = personel rollu taraf kaydi (eski KULLANICI.REHBERID). Kullanici TEK role baglidir.';

