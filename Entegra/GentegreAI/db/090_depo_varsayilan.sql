-- 090 - Depo karti: varsayilan depo tekligi
--
-- depo tablosunda "ux_depo_varsayilan" (unique, varsayilan = 1) ikinci bir
-- varsayilan depoyu HATAYLA reddeder. Kullanici acisindan dogru davranis
-- "yeni secilen varsayilan olur, eskisi birakir" - bunu uygulama koduna
-- birakirsak (kart ekrani, ice aktarim, elle SQL) bir yerde unutulur ve
-- kullanici anlamsiz bir benzersizlik hatasi gorur. Tetikleyici tek yer.

create or replace function public.fn_depo_varsayilan_tek()
returns trigger
language plpgsql
as $$
begin
    if new.varsayilan = 1 then
        update public.depo
           set varsayilan = 0
         where varsayilan = 1
           and id <> new.id;
    end if;
    return new;
end $$;

comment on function public.fn_depo_varsayilan_tek() is
  'Bir depo varsayilan yapilinca onceki varsayilani birakir (ux_depo_varsayilan).';

drop trigger if exists trg_depo_varsayilan_tek on public.depo;

create trigger trg_depo_varsayilan_tek
    before insert or update of varsayilan on public.depo
    for each row
    execute function public.fn_depo_varsayilan_tek();

do $$
declare v_n integer;
begin
    select count(*) into v_n from public.depo where varsayilan = 1;
    raise notice '090 tamam: varsayilan depo sayisi %', v_n;
end $$;
