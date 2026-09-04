-- ============================================================================
--  385 - PRIM SATIRININ ROLU PLANDAN DOLAR
--
--  379'da rol plan basligina tasindi ve satir kartindan kaldirildi; ama
--  `prim_plani_satir.rol` kolonu NOT NULL ve varsayilani yok. Sonuc: kart
--  artik rol GONDERMEDIGI icin YENI SATIR HIC EKLENEMIYOR -
--  "rol bos birakilamaz" (23502). Kullanicinin gordugu sey "plan kaydedilmedi";
--  tarafi tutmayan bir hata, cunku kolon UI'dan cikarilirken DB tarafi
--  guncellenmemis.
--
--  COZUM: kolon TARIHSEL olarak kalsin (eski hakedis satirlari hangi kuraldan
--  dogdugunu plan satirinda tasiyor) ama degeri PLANDAN turetilsin. Boylece
--  tek gercek vardir - planin rolu - ve satir kolonu onun kopyasi olarak
--  tutarli kalir.
-- ============================================================================

create or replace function public.tg_prim_satir_rol()
returns trigger
language plpgsql
as $function$
begin
    -- Rol verilmemis (ya da 0) ise PLANIN rolu yazilir. Verilmisse dokunulmaz:
    --   eski kayitlarin kendi degeri korunur.
    if coalesce(new.rol, 0) = 0 then
        select p.rol into new.rol from public.prim_plani p where p.id = new.plan_id;
    end if;
    return new;
end $function$;

drop trigger if exists tr_prim_satir_rol on public.prim_plani_satir;
create trigger tr_prim_satir_rol
    before insert or update of plan_id on public.prim_plani_satir
    for each row execute function public.tg_prim_satir_rol();

comment on function public.tg_prim_satir_rol() is
  'Satirin rolu PLANDAN dolar (385): rol 379''da baslige tasindi ve satir '
  'kartindan kaldirildi, ama kolon NOT NULL oldugu icin yeni satir hic '
  'eklenemiyordu. Kolon tarihsel/denetim amaciyla duruyor.';

-- Kolon NOT NULL kalsin ama tetik oncesi null gelebilsin diye varsayilan 0:
--   tetik zaten dogru degeri yaziyor, varsayilan yalnizca guvenlik agi.
alter table public.prim_plani_satir alter column rol set default 0;
