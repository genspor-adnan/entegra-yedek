-- ============================================================================
--  412 - MUAYENE DETAY TABLOLARINA DENETIM KOLONLARI
--
--  Kart DETAY satiri kaydedilirken ekleyen/degistiren kolonlari YAZILIR; kolon
--  yoksa istek 500 ile duser ve hata ancak o sekme kullanildiginda gorulur.
--  Ayni tuzak db/404'te lab_istem_test'te de cikmisti - yeni detay tablosu
--  acarken denetim dortlusu (ekleyen, ekleme_tarihi, degistiren,
--  degistirme_tarihi) standarttir.
-- ============================================================================

alter table public.muayene_bulgu
    add column if not exists ekleyen           integer   not null default 0,
    add column if not exists ekleme_tarihi     timestamp not null default now(),
    add column if not exists degistiren        integer   not null default 0,
    add column if not exists degistirme_tarihi timestamp;

alter table public.muayene_sablon_alan
    add column if not exists ekleyen           integer   not null default 0,
    add column if not exists ekleme_tarihi     timestamp not null default now(),
    add column if not exists degistiren        integer   not null default 0,
    add column if not exists degistirme_tarihi timestamp;
