-- 270: KATEGORİ AĞACI (kullanıcı: "kategori istediğimiz kadar alt seviyeli
-- olmalı", "kodu ve adı olmalı").
--
-- Tablo zaten `ust_id` taşıyordu ama hiçbir yerde kullanılmıyordu (15 kategori,
-- hepsi kök) ve kategoriyi yönetecek ekran yoktu. Burada:
--   1) döngü kilidi (A -> B -> A ağacı gezen her sorguyu sonsuza sokar),
--   2) lookup'ta TAM YOL ("Genel > Dental > İmplant") - aynı adlı iki alt
--      kategori birbirine karışmasın.

create index if not exists ix_kategori_ust on public.kategori (ust_id)
  where ust_id is not null;

create or replace function public.tg_kategori_dongu_engel()
returns trigger language plpgsql as $$
declare
  gezen integer := new.ust_id;
  adim  integer := 0;
begin
  if new.ust_id is null then return new; end if;
  if new.ust_id = new.id then
    raise exception 'Kategori kendi üst kategorisi olamaz.';
  end if;
  while gezen is not null and adim < 100 loop
    if gezen = new.id then
      raise exception 'Kategori kendi alt kategorisinin altına alınamaz (döngü).';
    end if;
    select k.ust_id into gezen from public.kategori k where k.id = gezen;
    adim := adim + 1;
  end loop;
  return new;
end $$;

drop trigger if exists tg_kategori_dongu_engel on public.kategori;
create trigger tg_kategori_dongu_engel
  before insert or update of ust_id on public.kategori
  for each row execute function public.tg_kategori_dongu_engel();

-- ------------------------------------------------------------------ lookup --
-- Tam yol: kök kategoriden aşağı " > " ile birleşir. Derinlik sınırsız;
-- recursive CTE 20 seviyede kesilir (bozuk veri sonsuz döngüye sokmasın).
drop view if exists public.v_kategori_lookup;
create view public.v_kategori_lookup as
with recursive agac as (
    select k.id, k.aktif,
           (case when k.kod = '' then k.ad else k.kod || ' - ' || k.ad end)::text as yol,
           1 as derinlik
      from public.kategori k
     where k.ust_id is null
    union all
    select k.id, k.aktif,
           a.yol || ' > ' ||
           (case when k.kod = '' then k.ad else k.kod || ' - ' || k.ad end)::text,
           a.derinlik + 1
      from public.kategori k
      join agac a on a.id = k.ust_id
     where a.derinlik < 20
)
select id, yol::varchar(400) as ad, aktif from agac;
