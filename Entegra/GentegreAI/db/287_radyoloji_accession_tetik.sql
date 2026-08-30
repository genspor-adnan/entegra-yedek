-- 287: ACCESSION NO KENDİLİĞİNDEN ÜRETİLİR.
--
-- Numara üç ayrı yoldan doğuyor: hekim istemi, dış hasta kabulü ve elle açılan
-- istem kartı. Üretimi çağıranlara bırakmak, birinin unutmasıyla accession'sız
-- (PACS'e eşleşmeyen) istem doğurur. Kural veritabanına konur: alan boşsa
-- BEFORE INSERT'te doldurulur.
--
-- Modalite de aynı mantıkla: verilmediyse tetkikin (hizmet) modalitesinden
-- gelir - iki yerde ayrı tutulup ayrışmasın.

create or replace function public.tg_radyoloji_istem_hazirla()
returns trigger
language plpgsql as $$
begin
  if coalesce(new.accession_no, '') = '' then
    new.accession_no := public.fn_radyoloji_accession(
        coalesce(new.cekim_tarihi::date, current_date));
  end if;

  if coalesce(new.modalite, 0) = 0 then
    select coalesce(h.modalite, 0) into new.modalite
      from public.hizmet h where h.id = new.hizmet_id;
  end if;

  -- Çekim zamanı girildiyse istem en az "Çekildi" durumundadır: teknisyen
  --   zamanı yazıp durumu güncellemeyi unutursa worklist yanlış gösterir.
  if new.cekim_tarihi is not null and coalesce(new.durum, 1) = 1 then
    new.durum := 2;
  end if;

  return new;
end $$;

drop trigger if exists tg_radyoloji_istem_hazirla on public.radyoloji_istem;
create trigger tg_radyoloji_istem_hazirla
before insert on public.radyoloji_istem
for each row execute function public.tg_radyoloji_istem_hazirla();

-- Güncellemede de aynı çekim-zamanı kuralı geçerli (kart üzerinden çekim
-- zamanı yazıldığında).
create or replace function public.tg_radyoloji_istem_guncelle()
returns trigger
language plpgsql as $$
begin
  if new.cekim_tarihi is not null and old.cekim_tarihi is null
     and coalesce(new.durum, 1) = 1 then
    new.durum := 2;
  end if;
  return new;
end $$;

drop trigger if exists tg_radyoloji_istem_guncelle on public.radyoloji_istem;
create trigger tg_radyoloji_istem_guncelle
before update on public.radyoloji_istem
for each row execute function public.tg_radyoloji_istem_guncelle();

comment on function public.tg_radyoloji_istem_hazirla() is
  'İstem açılışında accession/modalite doldurur, çekim zamanı varsa durumu Çekildi yapar (287).';
