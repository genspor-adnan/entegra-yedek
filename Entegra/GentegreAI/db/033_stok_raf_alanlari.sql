-- ============================================================================
--  Gentegre AI — stok "Raf / Konum" ve "Raf Ömrü" alanlari
--  033_stok_raf_alanlari.sql
--
--  Mockup (stok_karti.html) "Tanım / Sınıflandırma" alt-bolumunde bu iki alani
--    gosteriyor. Kaynak MSSQL STOKLAR.RAFOMRU_SURE / RAFOMRU_BIRIM zaten
--    stg.stoklar'a migrate edilmisti (002/013) ama public.stok'a hic kopyalanmamisti.
--  "Raf / Konum" (mockup: "A-12-03") MSSQL'de gercek karsiligi yok - STOKLAR.YERI
--    var ama tinyint-kodlu ve TAMAMEN BOS (5081/5081 NULL); bu yuzden ayri, bos
--    baslayan serbest metin kolonu olarak eklendi (YERI ile karistirilmadi).
-- ============================================================================
\set ON_ERROR_STOP on

-- raf_omru_sure/raf_omru_birim ZATEN 011_sema_stok.sql'de vardi (NOT NULL default 0) -
--   sadece hic veri kopyalanmamisti ve KartKatalogu'na baglanmamisti. raf_konum YENI.
alter table public.stok
    add column if not exists raf_konum     varchar(30) not null default '';

comment on column public.stok.raf_konum      is 'Serbest metin (or. "A-12-03"). MSSQL STOKLAR.YERI tinyint-kodlu ve BOS - baglanmadi, bu ayri/yeni kolon.';
comment on column public.stok.raf_omru_sure  is 'MSSQL STOKLAR.RAFOMRU_SURE - SKT hesaplamada kullanilir.';
comment on column public.stok.raf_omru_birim is 'MSSQL STOKLAR.RAFOMRU_BIRIM - 1=Gun 2=Ay 3=Yil (GENINI degil, sabit 3 secenek). NOT NULL - stg''de NULL olan 0''a (Gun) dustu.';

-- stg.stoklar zaten dolu (5081 satir, id = public.stok.id korunuyor).
update public.stok s
   set raf_omru_sure  = coalesce(st.rafomru_sure, 0),
       raf_omru_birim = coalesce(st.rafomru_birim, 0)
  from stg.stoklar st
 where st.id = s.id
   and (coalesce(st.rafomru_sure, 0) <> 0 or coalesce(st.rafomru_birim, 0) <> 0);

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.stok where raf_omru_sure > 0;
    raise notice '033 tamam: % stok satirinda raf_omru_sure > 0', v_adet;
end $$;
