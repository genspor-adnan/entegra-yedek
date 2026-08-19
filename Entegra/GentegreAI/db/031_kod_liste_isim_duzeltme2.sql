-- ============================================================================
--  Gentegre AI — kod_liste otomatik uretilen adlarin duzeltilmesi (devam)
--  031_kod_liste_isim_duzeltme2.sql
--
--  Stok kart idstrip'ine mockup'taki gibi "Tur" (STOKLAR.TIPI, BOLUM -2703) eklendi.
-- ============================================================================
\set ON_ERROR_STOP on

update public.kod_liste set kod = 'stok.tipi', ad = 'Stok Tipi' where eski_bolum = -2703;
