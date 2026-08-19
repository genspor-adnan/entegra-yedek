-- ============================================================================
--  Gentegre AI — durum kodu aciklamasi
--  028_durum_kodu_notu.sql
--
--  TUZAK: 001'deki yorum "0 aktif, 1 pasif" diyordu; DOGRUSU TERSI.
--    GENINI kod listeleri (BOLUM -2708 ve -2201): 1 = Aktif, 0 = Pasif.
--    Veri de bunu dogruluyor: REHBER'in 2.488 kaydi 1, 226'si 0.
--    Yanlis yorum yuzunden kart ekrani aktif cariyi "Pasif" gosteriyordu.
--  Sema degismiyor - yalniz kolon aciklamalari yaziliyor ki bir daha ters okunmasin.
-- ============================================================================
\set ON_ERROR_STOP on

comment on column public.taraf.durum is '1 = AKTIF, 0 = pasif (GENINI BOLUM -2708/-2201). DIKKAT: sifir "aktif" DEGILDIR.';
comment on column public.stok.durum  is '1 = AKTIF, 0 = pasif (taraf.durum ile ayni kodlama).';
comment on column public.belge.durum is '0 = kesin, 1 = taslak, 2 = iptal (belge durumu; taraf/stok durumundan FARKLI kodlama).';

do $$
declare v_aktif integer; v_pasif integer;
begin
  select count(*) filter (where durum = 1), count(*) filter (where durum = 0)
    into v_aktif, v_pasif from public.taraf;
  raise notice '028 tamam: taraf -> % aktif (durum=1), % pasif (durum=0)', v_aktif, v_pasif;
end $$;
