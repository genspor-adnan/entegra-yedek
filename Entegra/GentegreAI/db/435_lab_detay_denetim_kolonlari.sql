-- =====================================================================
-- 435 - LAB DETAY TABLOLARINA DENETIM KOLONLARI
--
-- Kart deposu her detay satirina ekleyen/ekleme_tarihi/degistiren/
-- degistirme_tarihi yazar (ISLEMLOG portu, 419'daki desen). Kolonlar
-- yoksa INSERT "42703: column ekleyen of relation ... does not exist"
-- ile duser ve KART HIC KAYDEDILMEZ.
--
-- Ayni tuzak db/404 (lab_istem_test) ve db/412 (muayene detaylari) icin
-- de yasandi: 433'te acilan iki yeni detay tablosu ayni eksikle geldi.
-- Yeni bir detay tablosu acarken denetim kolonlari da acilmali.
-- =====================================================================

alter table public.lab_tetkik_referans
    add column if not exists ekleyen           integer   not null default 0,
    add column if not exists ekleme_tarihi     timestamp not null default now(),
    add column if not exists degistiren        integer   not null default 0,
    add column if not exists degistirme_tarihi timestamp;

alter table public.lab_panel_satir
    add column if not exists ekleyen           integer   not null default 0,
    add column if not exists ekleme_tarihi     timestamp not null default now(),
    add column if not exists degistiren        integer   not null default 0,
    add column if not exists degistirme_tarihi timestamp;

-- lab_panel'de aciklama YOKTU: panel karti "notlar" alani olmadan da
--   calisiyor ama tetkik katalogunda oldugu gibi serbest not tutulabilmeli
--   (panel kapsami "hangi durumda istenir" bilgisini tasir).
alter table public.lab_panel
    add column if not exists aciklama varchar(300) not null default '',
    add column if not exists sube_id  integer      not null default 0;

do $$
begin
    raise notice '435 tamam: lab_tetkik_referans / lab_panel_satir denetim kolonlari, lab_panel.aciklama';
end $$;
