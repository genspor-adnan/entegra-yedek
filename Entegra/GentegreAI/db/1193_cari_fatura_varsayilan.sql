-- =============================================================================
--  1193  CARİYE ÖZEL FATURA TİPİ / SENARYO
--
--  Kullanıcı (26.10.2026): "müş kartı ebelge ayarlarına Fatura Tipi ve Senaryo comboları ekle.. bunlardan
--  biri seçilmişse bu müşteriye fat keserken bunlar kullanılır yoksa default ayarlar".
--  Boş (null) = genel varsayılan: fatura tipi Satış (1), senaryo Genel Ayarlar efatura.senaryo.
--  Değerler belge.tipi / belge.senaryo kodlarıyla aynı (web belgeSabitleri FATURA_TIPLERI / SENARYO_SECENEK).
--  Yeni satış faturasında cari seçilince kart doldurur; kullanıcı belgede değiştirebilir.
--  İdempotent; mevcut veri değişmez.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

alter table public.taraf add column if not exists varsayilan_fatura_tipi smallint;
alter table public.taraf add column if not exists varsayilan_senaryo     smallint;

comment on column public.taraf.varsayilan_fatura_tipi is
  'Bu cariye kesilen satış faturasının varsayılan tipi (belge.tipi kodu); null = Satış (1).';
comment on column public.taraf.varsayilan_senaryo is
  'Bu cariye kesilen satış faturasının varsayılan e-Fatura senaryosu (belge.senaryo kodu); null = efatura.senaryo ayarı.';

commit;
