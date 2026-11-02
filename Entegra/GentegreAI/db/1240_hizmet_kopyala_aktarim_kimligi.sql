-- =============================================================================
--  1240  HİZMET KOPYASI AKTARIM KİMLİĞİ TAŞIMAZ
--
--  1237 fn_hizmet_kopyala bütün kolonları kopyalıyordu: aktarılmış eski hizmetin (aktarim_kaynak 2, ISLEMLER, id)
--  kimliği yeni SUT üyesine de geçiyor, ux_hizmet_aktarim reddediyordu (KOSUYOLU "Diz MR" yönlere ayırma).
--  Kopya yeni bir kayıttır: aktarim_kaynak / aktarim_tablo / aktarim_id boş.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_hizmet_kopyala(p_eski integer) returns integer language plpgsql as $$
declare v_kol text; v_sec text; v_id integer;
begin
  select string_agg(quote_ident(column_name), ',' order by ordinal_position),
         string_agg(case when column_name in ('aktarim_kaynak', 'aktarim_tablo', 'aktarim_id') then 'null'
                         else quote_ident(column_name) end, ',' order by ordinal_position)
    into v_kol, v_sec
    from information_schema.columns
   where table_schema = 'public' and table_name = 'hizmet' and is_identity = 'NO' and is_generated = 'NEVER';
  execute format('insert into public.hizmet (%s) select %s from public.hizmet where id = $1 returning id', v_kol, v_sec)
    into v_id using p_eski;
  return v_id;
end $$;

commit;
