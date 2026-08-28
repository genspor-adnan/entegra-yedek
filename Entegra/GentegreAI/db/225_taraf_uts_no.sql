-- ============================================================================
--  Gentegre AI — CARİDE ÜTS KURUM NO
--  225_taraf_uts_no.sql
--
--  Verme bildiriminde KUN (alan kurumun ÜTS numarası) zorunludur; müşterinin
--  numarası cari kartına BİR KEZ girilir, bildirimler oradan okur. ÜTS'nin
--  "firma sorgula" servisi kapsam dışı (kullanıcı kararı) - elle girilir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf
    add column if not exists uts_kurum_no varchar(30) not null default '';

comment on column public.taraf.uts_kurum_no is
  'Carinin ÜTS kurum/firma numarası (225) - verme bildiriminde KUN.';

create index if not exists ix_taraf_uts_kurum_no
    on public.taraf (uts_kurum_no) where uts_kurum_no <> '';

do $$ begin
    raise notice '225 tamam: taraf.uts_kurum_no.';
end $$;
