-- =============================================================================
--  1251  BELGE_SATIR KAYNAK BAĞI - KISMİ OLMAYAN İNDEKS
--
--  Kullanıcı 03.11.2026 (ZONE): "bugünkü yapılanlar (home da yapılacak işler) geçmemiş".
--
--  TEŞHİS. /api/gundem 30 sn'de zaman aşımına düşüyordu (hata_log 16-18, "Timeout during reading attempt",
--  GundemUclari Irsaliye). "Faturası kesilmemiş irsaliye" sorgusu her irsaliye satırı için bağlı fatura
--  satırlarını İLİŞKİLİ alt sorguyla toplar: hs.kaynak_tur = 30 and hs.kaynak_id = s.id. Tek indeks 012'deki
--  ix_belge_satir_kaynak KISMİ (where kaynak_id > 0): planlayıcı dış satırın s.id'sinin > 0 olduğunu
--  kanıtlayamadığından indeksi kullanamıyor, her satırda belge_satir'i baştan sona tarıyordu
--  (ZONE: 4.4 bin irsaliye x 171 bin satır, maliyet 397 milyon). Aynı desen eşleşme icmali, dönüşüm,
--  iade satırları ve panel sorgularında da var - tek tek koşul eklemek yerine kısmi olmayan indeks.
--
--  Yalnız indeks eklenir; veri değişmez. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

create index if not exists ix_belge_satir_kaynak_bag on public.belge_satir (kaynak_id, kaynak_tur);
