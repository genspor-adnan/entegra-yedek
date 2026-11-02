-- =============================================================================
--  1231  RADYOLOJİ - YÖN EKİ YÖNLÜ SUT ADINDA TEKRARLANMAZ
--
--  1229 fn_radyoloji_yon_ek tetkik adına "(SAĞ)" ekliyordu; yönlü SUT kodunda (1230 hizmet.yon) yön zaten
--  adın içinde: "MRG, Ayak - Sağ, Kontrastsız (SAĞ)". İki parametreli sürüm hizmetin sabit yönü varsa
--  ek vermez. Tek parametreli sürüm geriye uyum için kalır.
-- =============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_radyoloji_yon_ek(p_yon smallint, p_hizmet_yon smallint)
returns text language sql immutable as $$
  select case when coalesce(p_hizmet_yon, 0) > 0 then '' else public.fn_radyoloji_yon_ek(p_yon) end
$$;
