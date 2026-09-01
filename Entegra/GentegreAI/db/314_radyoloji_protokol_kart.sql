-- 314: Çekim protokolü ekrandan yönetilebilsin.
--
-- Kullanıcı: "protokol ekranını yap". Tablo 283'te açılmıştı ama EKRANI YOKTU
-- ve tek satır bile girilmemişti; hazırlık talimatı bu yüzden yalnız modalite
-- varsayılanından (311) geliyordu.
--
-- Tablonun kendi kimliği yok (PK = hizmet_id). Jenerik kart/liste altyapısı
-- kayıtları `id` ile açıyor (kart rotası /radyoloji-protokol/:id, detay yazıcı
-- ve islem_log da id bekliyor) - bu yüzden yapay anahtar ekleniyor, hizmet
-- bağı TEKİL kısıt olarak korunuyor: bir tetkikin tek protokolü olur.

alter table public.radyoloji_protokol
  add column if not exists id integer generated always as identity;

do $$
begin
  -- PK hizmet_id ise: id'ye taşı, hizmet_id benzersiz kısıt olarak kalsın.
  if exists (select 1
               from information_schema.table_constraints c
               join information_schema.key_column_usage k
                 on k.constraint_name = c.constraint_name
              where c.table_schema = 'public' and c.table_name = 'radyoloji_protokol'
                and c.constraint_type = 'PRIMARY KEY' and k.column_name = 'hizmet_id')
  then
    alter table public.radyoloji_protokol drop constraint radyoloji_protokol_pkey;
    alter table public.radyoloji_protokol add primary key (id);
  end if;
end $$;

alter table public.radyoloji_protokol
  add constraint ux_radyoloji_protokol_hizmet unique (hizmet_id);

comment on column public.radyoloji_protokol.id is
  'Yapay anahtar (314) - jenerik kart/liste altyapısı kayıtları id ile açar.';
comment on column public.radyoloji_protokol.sure_dk is
  'Çekim süresi (dk) - randevu kapasitesi bu süreden hesaplanır.';
comment on column public.radyoloji_protokol.hazirlik_metni is
  'Hastaya verilecek hazırlık talimatı; boşsa modalite varsayılanı kullanılır (311).';

-- Yetki: protokol radyoloji modülünün tanım ekranıdır, ayrı yetki açılmadı.
