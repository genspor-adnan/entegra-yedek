-- ============================================================================
--  Gentegre AI — Depo bazli MIN / MAX stok seviyesi
--  099_stok_durum_limit.sql
--
--  Stok kartinin "Stok Durumu" sekmesi (Ekranlar/stok_karti.html): depo x stok
--  gridinde Min ve Max sutunlari var ve mockup'in notu "Min/Max ve kritik seviye
--  DEPO BAZLI tanimlanir" diyor. Bugun yalniz stok.min_stok (tum depolar icin
--  TEK deger) vardi.
--
--  NULL = "bu depo icin ayri limit yok, stok.min_stok gecerli". Boylece mevcut
--  davranis aynen korunur; kullanici bir depoya deger girerse o depoda o gecerli.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.stok_durum
    add column if not exists min_stok numeric(19,4),
    add column if not exists max_stok numeric(19,4);

comment on column public.stok_durum.min_stok is
  'Bu DEPODAKI kritik seviye. NULL ise stok.min_stok (kart geneli) gecerlidir (099).';
comment on column public.stok_durum.max_stok is
  'Bu depodaki hedef/azami seviye - yalniz gosterim ve siparis onerisi icin (099).';

do $$
declare v_kolon integer;
begin
    select count(*) into v_kolon
      from information_schema.columns
     where table_schema = 'public' and table_name = 'stok_durum'
       and column_name in ('min_stok', 'max_stok');
    raise notice '099 tamam: stok_durum limit kolonu %/2', v_kolon;
end $$;
