-- 1331 - Hizmetin modalitesi tek değer: hizmet.modalite → radyoloji_protokol.modalite
--
-- Kullanıcı 12.11.2026: "mr.002 ye baktım boştu", "radyoloji protokolü sekmesinde göremedim". İstem (1242) ve worklist
-- hizmet.modalite'yi okur; kart sekmesinde ise protokol satırının modalitesi vardı (protokolsüz hizmette boş). Kart artık
-- hizmetinkini gösterir, protokolün alanı gizli. Bu dosya protokol satırının modalitesini hizmetinkiyle eşit tutar:
--   * hizmet.modalite değişince varsa protokol satırına yazılır;
--   * protokol satırı açılırken / modalitesi boşken hizmetinki alınır.
-- Toplu protokol satırı AÇILMAZ (varsayılan süre / kontrast gibi değerler yazılırdı). Mevcut satırlar: hizmetin modalitesi
-- doluysa ve protokolünki farklıysa protokolünki hizmetinkine çekilir (istemin okuduğu değer esas) - önce sayı raporlanır.
--
-- Tekrar çalıştırılabilir.
\set ON_ERROR_STOP on
begin;

do $$
declare n integer;
begin
  select count(*) into n from public.radyoloji_protokol p join public.hizmet h on h.id = p.hizmet_id
   where coalesce(h.modalite, 0) > 0 and p.modalite is distinct from h.modalite;
  raise notice '1331: hizmetinkinden farklı protokol modalitesi: % satır (hizmetinkine çekilecek)', n;
end $$;

update public.radyoloji_protokol p set modalite = h.modalite
  from public.hizmet h
 where h.id = p.hizmet_id and coalesce(h.modalite, 0) > 0 and p.modalite is distinct from h.modalite;

create or replace function public.tg_hizmet_modalite_protokole()
returns trigger language plpgsql as $f$
begin
  if new.modalite is distinct from old.modalite and coalesce(new.modalite, 0) > 0 then
    update public.radyoloji_protokol set modalite = new.modalite
     where hizmet_id = new.id and modalite is distinct from new.modalite;
  end if;
  return new;
end $f$;
drop trigger if exists tg_hizmet_modalite_protokole on public.hizmet;
create trigger tg_hizmet_modalite_protokole after update of modalite on public.hizmet
  for each row execute function public.tg_hizmet_modalite_protokole();

create or replace function public.tg_radyoloji_protokol_modalite()
returns trigger language plpgsql as $f$
begin
  -- Protokolün modalitesi kartta gizli: hizmetinki esas.
  select coalesce(nullif(h.modalite, 0), new.modalite) into new.modalite from public.hizmet h where h.id = new.hizmet_id;
  return new;
end $f$;
drop trigger if exists tg_radyoloji_protokol_modalite on public.radyoloji_protokol;
create trigger tg_radyoloji_protokol_modalite before insert or update on public.radyoloji_protokol
  for each row execute function public.tg_radyoloji_protokol_modalite();

commit;
