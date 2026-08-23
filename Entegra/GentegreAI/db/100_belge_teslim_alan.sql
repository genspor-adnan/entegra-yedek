-- ============================================================================
--  Gentegre AI — Belgede TESLIM ALAN
--  100_belge_teslim_alan.sql
--
--  Depolar arasi stok transferinde (belge tur 20) mali kimin teslim ettigi ve
--  kimin teslim aldigi ZORUNLU bilgidir - iki depo arasindaki sorumluluk
--  devrinin kaydi budur. `belge.teslim_eden_id` vardi, karsiligi yoktu.
--
--  Irsaliyelerde de kullanilabilir (opsiyonel); zorunluluk kartta ture gore.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge
    add column if not exists teslim_alan_id bigint;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_belge_teslim_alan') then
        alter table public.belge
            add constraint fk_belge_teslim_alan
            foreign key (teslim_alan_id) references public.taraf(id);
    end if;
end $$;

comment on column public.belge.teslim_alan_id is
  'Mali TESLIM ALAN personel (taraf.personel=1). Stok transferinde zorunlu (100).';

do $$
declare v_var boolean;
begin
    select count(*) = 1 into v_var
      from information_schema.columns
     where table_schema = 'public' and table_name = 'belge' and column_name = 'teslim_alan_id';
    raise notice '100 tamam: belge.teslim_alan_id %', case when v_var then 'eklendi' else 'YOK' end;
end $$;
