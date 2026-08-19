-- ============================================================================
--  Gentegre AI — stok "GTİP Kodu" alani
--  034_stok_gtip.sql
--
--  Mockup (stok_karti.html) "Vergi & Ana Birim" alt-bolumunde gosteriyor.
--  Kaynak MSSQL STOKLAR.GTIP zaten stg.stoklar'a migrate edilmisti (002) ama
--    public.stok'a hic kopyalanmamisti. Cok az doluluk (BILIM'de 2/5081) - yine
--    de kullanici acikca istedi, alan ekleniyor.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.stok
    add column if not exists gtip_kodu varchar(30) not null default '';

comment on column public.stok.gtip_kodu is 'MSSQL STOKLAR.GTIP - Gumruk Tarife Istatistik Pozisyonu. BILIM''de cok seyrek dolu (2/5081).';

update public.stok s
   set gtip_kodu = st.gtip
  from stg.stoklar st
 where st.id = s.id
   and coalesce(st.gtip, '') <> '';

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.stok where gtip_kodu <> '';
    raise notice '034 tamam: % stok satirinda gtip_kodu dolu', v_adet;
end $$;
