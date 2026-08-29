-- 257: DEPARTMAN HİYERARŞİSİ (kullanıcı: "departmana ustbirim_id ekle; bu
-- seçilirse bir departman diğerinin altına gelir").
--
-- Örnek: "Dahiliye" -> üst birim "Poliklinikler"; "Muhasebe" -> "Mali İşler".
-- Boş bırakılırsa departman kök seviyededir.

alter table public.departman add column if not exists ustbirim_id integer
  references public.departman(id);
comment on column public.departman.ustbirim_id is
  'Bağlı olduğu üst birim (257). Boşsa kök departman.';

create index if not exists ix_departman_ustbirim
  on public.departman (ustbirim_id) where ustbirim_id is not null;

-- ------------------------------------------------------------ döngü kilidi --
-- Bir departman kendi altına (ya da kendi alt ağacının altına) alınamaz:
-- A -> B -> A zinciri kurulursa ağacı gezen her sorgu sonsuza girer. Tek
-- satırlık "id <> ustbirim_id" kontrolü yalnız BİR adımlık döngüyü yakalar,
-- bu yüzden zincir yukarı doğru yürütülüyor.
create or replace function public.tg_departman_dongu_engel()
returns trigger language plpgsql as $$
declare
  gezen integer := new.ustbirim_id;
  adim  integer := 0;
begin
  if new.ustbirim_id is null then return new; end if;
  if new.ustbirim_id = new.id then
    raise exception 'Departman kendi üst birimi olamaz.';
  end if;
  while gezen is not null and adim < 100 loop
    if gezen = new.id then
      raise exception 'Departman kendi alt biriminin altına alınamaz (döngü).';
    end if;
    select d.ustbirim_id into gezen from public.departman d where d.id = gezen;
    adim := adim + 1;
  end loop;
  return new;
end $$;

drop trigger if exists tg_departman_dongu_engel on public.departman;
create trigger tg_departman_dongu_engel
  before insert or update of ustbirim_id on public.departman
  for each row execute function public.tg_departman_dongu_engel();
