-- ============================================================================
--  Gentegre AI — STOK KART FIYATI TEK YERDE
--  128_fn_stok_kart_fiyat.sql
--
--  "Stogun kart fiyati" kurali BES ayri yerde kopyalanmisti (stok listesinin
--  satis fiyati / satis dovizi / alis fiyati / alis dovizi kolonlari + paket
--  icerigi cagrisi): her biri ayni sarti tasiyordu ama biri degistiginde
--  otekiler geride kalirdi.
--
--  KURAL (degismedi): stok_fiyat'ta alis ve satis AYRI satirdir, fiyat -1 ise
--  "girilmemis" demektir; en dusuk fiyat_adi (ana liste) esas alinir.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_stok_kart_fiyat(
    p_stok_id integer,
    p_satis   smallint)
returns table (fiyat numeric, doviz_cinsi varchar)
language sql
stable
parallel safe
as $$
    select f.fiyat, f.doviz_cinsi
      from public.stok_fiyat f
     where f.stok_id = p_stok_id
       and f.satis   = p_satis
       and f.fiyat   > 0
     order by f.fiyat_adi
     limit 1
$$;

comment on function public.fn_stok_kart_fiyat(integer, smallint) is
  'Stogun kart fiyati (128): satis=1 satis listesi, satis=0 alis. En dusuk fiyat_adi, fiyat > 0.';

do $$
declare v_f numeric; v_d varchar;
begin
    select fiyat, doviz_cinsi into v_f, v_d
      from public.fn_stok_kart_fiyat((select min(stok_id) from public.stok_fiyat where fiyat > 0), 1::smallint);
    raise notice '128 tamam: fn_stok_kart_fiyat hazir (ornek % %)', v_f, v_d;
end $$;
