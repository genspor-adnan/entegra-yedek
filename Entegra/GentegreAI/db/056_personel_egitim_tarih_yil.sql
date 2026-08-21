-- ============================================================================
--  Gentegre AI — Personel Eğitim/Sertifika tarih alanı yıl veya tarih olabilir
--  056_personel_egitim_tarih_yil.sql
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'personel_egitim'
      and column_name = 'tarih'
      and data_type = 'date'
  ) then
    alter table public.personel_egitim
      alter column tarih type character varying(10)
      using coalesce(to_char(tarih, 'YYYY-MM-DD'), '');
  end if;
end $$;

alter table public.personel_egitim
  alter column tarih set default '',
  alter column tarih set not null;

comment on column public.personel_egitim.tarih is
  'Eğitim tarihi; yalnız yıl (2024) veya normal tarih (2024-06-15 / 15.06.2024) yazılabilir.';
