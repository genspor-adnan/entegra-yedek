-- 236: Pozisyon artık KOD (kullanıcı: "pers kartı pozisyon combo ve ID olarak
-- olsun"). taraf.gorev serbest metindi; aynı pozisyon farklı yazımlarla
-- giriliyordu ve listede gruplanamıyordu.
--
-- Yeni kolon taraf.gorev_id, 'taraf.gorev' kod listesinin değerini tutar
-- (235'te açılmış, mevcut metinlerden tohumlanmıştı). Eski metin kolonu
-- SİLİNMEZ - eşleşmeyen kayıtların yazımı orada kalır, gerekirse elle
-- düzeltilebilir.

alter table public.taraf
  add column if not exists gorev_id smallint;

comment on column public.taraf.gorev_id is
  'Pozisyon - kod_liste ''taraf.gorev'' değeri (236). Eski serbest metin: taraf.gorev';

-- Metinden koda eşleme (büyük/küçük ve boşluk farkı yok sayılır).
update public.taraf t
   set gorev_id = d.deger
  from public.kod_deger d
  join public.kod_liste l on l.id = d.liste_id
 where l.kod = 'taraf.gorev'
   and t.gorev_id is null
   and coalesce(trim(t.gorev), '') <> ''
   and lower(trim(t.gorev)) = lower(trim(d.ad));

create index if not exists ix_taraf_gorev_id on public.taraf (gorev_id)
  where gorev_id is not null;
