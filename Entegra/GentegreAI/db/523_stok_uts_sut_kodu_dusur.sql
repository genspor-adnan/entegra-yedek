-- =====================================================================
--  523_stok_uts_sut_kodu_dusur.sql
--  ÜTS uzantısındaki `sut_kodu` düşer - stokun KENDİ kodu SUT kodudur.
--
--  Kullanıcı: "ayrıca SUT kolonu varsa düşür, normal kod yeter."
--
--  521'de hizmet tarafındaki `hizmet.sut_kodu` düşmüştü; şemada kalan tek
--  SUT kolonu `stok_uts.sut_kodu` idi (119'daki ÜTS 1:1 uzantısı). Stoklar
--  da SKRS'nin SUT listesinden ("Malzemeler" tipi) kurulduğu için stokun
--  `kod` alanı zaten SUT kodudur - ikinci bir kolon aynı değeri iki kaynağa
--  bölerdi. Kolon hiç dolmamıştı (0 satır) ve ÜTS bildiriminde de
--  okunmuyordu; yalnız kartta bir giriş alanı olarak duruyordu.
-- =====================================================================

alter table public.stok_uts drop column if exists sut_kodu;
