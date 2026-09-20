-- =====================================================================
--  905_profil_menu_bolgeli.sql
--  MENÜ TİPİ ARTIK PROFİLDE (kullanıcı: "menü tipini profillere kaydet").
--
--  "Bölgeli menü" (Hasta Akışı · Klinikler gibi renkli bölge başlıkları)
--  eskiden yalnız ürün modu 2 ise açılıyor, sonra kurum tipine (hastane /
--  tıp merkezi) göre koda gömülüyordu. Artık kurum PROFİLİNDE saklanır:
--
--    menu_bolgeli = 1  bölgeli (çok branşlı büyük kurum menüsü)
--                 = 0  düz gruplu
--                 = NULL  kurum tipine göre otomatik (hastane/tip_merkezi=1)
--
--  Böylece bir dal merkezi isterse bölgeli menüyü açabilir, hastane
--  kapatabilir - karar kodda değil, profil ekranında.
-- =====================================================================

alter table public.kurum_profil
  add column if not exists menu_bolgeli smallint;

comment on column public.kurum_profil.menu_bolgeli is
  'Menü tipi: 1 bölgeli (Hasta Akışı/Klinikler başlıkları), 0 düz, '
  'NULL = kurum tipine göre otomatik (hastane/tip_merkezi bölgeli).';

-- Mevcut profillere kurum tipine göre başlangıç değeri (NULL kalanlar zaten
--   otomatik çözülür; yine de görünür olsun diye yazıyoruz).
update public.kurum_profil
   set menu_bolgeli = case when kurum_tipi in ('hastane','tip_merkezi') then 1 else 0 end
 where menu_bolgeli is null;

do $$
begin
    raise notice '905 tamam: menu_bolgeli dolu profil %',
        (select count(*) from public.kurum_profil where menu_bolgeli is not null);
end $$;
