-- 092 - Depo adi benzersiz
--
-- Depo secimi her yerde ADLA yapiliyor (v_depo_lookup, belge kartinda "Çıkış
-- Deposu"), o yuzden ayni adda iki depo kullaniciyi yanlis depoya yazdirabilir.
-- Buyuk/kucuk harf ve bas-son bosluk farki da ayni ad sayilir.

create unique index if not exists ux_depo_ad
    on public.depo (lower(btrim(ad)));

comment on index public.ux_depo_ad is
  'Depo adi benzersiz (buyuk/kucuk harf ve bosluk duyarsiz).';

do $$
declare v_n integer;
begin
    select count(*) into v_n from public.depo;
    raise notice '092 tamam: depo sayisi %', v_n;
end $$;
