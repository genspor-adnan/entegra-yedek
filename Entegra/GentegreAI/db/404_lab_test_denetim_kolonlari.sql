-- ============================================================================
--  404 - lab_istem_test DENETIM KOLONLARI (mevcut kusur)
--
--  Lab istemine test satiri EKLENEMIYORDU: kart cercevesi her detay satirina
--  "ekleyen" yaziyor (butun detay tablolarinda oldugu gibi) ama bu tabloda o
--  kolon yoktu:
--      42703: column "ekleyen" of relation "lab_istem_test" does not exist
--  Istek 500 ile dusuyordu; kusur panik deger bildirimi (399) uctan uca
--  denenirken ortaya cikti.
--
--  Cozum semayi digerleriyle esitlemek: lab_istem, muayene ve tum detay
--  tablolari ayni dort denetim kolonunu tasiyor.
-- ============================================================================

alter table public.lab_istem_test
    add column if not exists ekleyen           integer   not null default 0,
    add column if not exists ekleme_tarihi     timestamp not null default now(),
    add column if not exists degistiren        integer   not null default 0,
    add column if not exists degistirme_tarihi timestamp;
