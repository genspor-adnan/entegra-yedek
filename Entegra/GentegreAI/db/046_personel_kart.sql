-- ============================================================================
--  Gentegre AI - Personel karti (Ik) icin taraf_personel uyumu
--  046_personel_kart.sql
--
--  taraf_personel 1:1: id = taraf.id. Eski kurulumlarda taraf_id ismi 064 ile
--  id'ye tasinir; temiz kurulumda 017 zaten dogru semayi kurar.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
begin
    if exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'taraf_personel'
          and column_name = 'taraf_id'
    ) and not exists (
        select 1
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'taraf_personel'
          and column_name = 'id'
    ) then
        alter table public.taraf_personel rename column taraf_id to id;
    end if;
end $$;

