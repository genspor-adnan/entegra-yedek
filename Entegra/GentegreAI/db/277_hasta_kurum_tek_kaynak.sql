-- 277: HASTANIN KURUMU TEK KAYNAKTAN (274 boşluğu).
--
-- Kurum bilgisi İKİ yerde duruyordu:
--   taraf_hasta.kurum_id        -> kartın kimlik şeridi, başvuruya taşınan alan
--   taraf_hasta_kurum (1:N)     -> poliçe tarihçesi, "sonuncusu aktif"
-- Yeni poliçe girildiğinde ikincisi değişiyor, birincisi eski kurumda kalıyordu:
-- başvuru ESKİ kuruma açılıp yanlış kampanyayla fiyatlanabiliyordu.
--
-- Poliçe tarihçesi ASIL KAYNAKTIR; taraf_hasta.kurum_id artık onun türevi -
-- aktif poliçe değiştikçe tetik günceller. Poliçesi hiç olmayan hastada alan
-- serbest kalır (aday hasta kartı doğrudan oraya yazıyor, 266).

create or replace function public.tg_taraf_hasta_kurum_yansit()
returns trigger
language plpgsql as $$
declare
  v_hasta integer := coalesce(new.hasta_id, old.hasta_id);
  v_kurum integer;
begin
  -- Hastanın AKTİF poliçesindeki kurum; aktif poliçe kalmadıysa en son giren.
  select k.kurum_id into v_kurum
    from public.taraf_hasta_kurum k
   where k.hasta_id = v_hasta
   order by k.aktif desc, k.id desc
   limit 1;

  update public.taraf_hasta h
     set kurum_id = v_kurum
   where h.id = v_hasta
     and h.kurum_id is distinct from v_kurum;

  return null;
end $$;

comment on function public.tg_taraf_hasta_kurum_yansit() is
  'Aktif poliçenin kurumunu taraf_hasta.kurum_id alanına yansıtır (277).';

drop trigger if exists tg_taraf_hasta_kurum_yansit on public.taraf_hasta_kurum;

-- AFTER + FOR EACH ROW: "tek aktif" tetiği (248) diğer satırları pasife
--   çektikten SONRA çalışsın; yoksa yansıyan değer bir adım geriden gelir.
create trigger tg_taraf_hasta_kurum_yansit
after insert or update or delete on public.taraf_hasta_kurum
for each row execute function public.tg_taraf_hasta_kurum_yansit();

-- Mevcut veriyi bir kez hizala: poliçesi olan hastalarda alan poliçeden gelir.
update public.taraf_hasta h
   set kurum_id = k.kurum_id
  from (
      select distinct on (hasta_id) hasta_id, kurum_id
        from public.taraf_hasta_kurum
       order by hasta_id, aktif desc, id desc
  ) k
 where k.hasta_id = h.id
   and h.kurum_id is distinct from k.kurum_id;
