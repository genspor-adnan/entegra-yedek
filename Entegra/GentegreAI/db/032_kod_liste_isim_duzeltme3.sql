-- ============================================================================
--  Gentegre AI — kod_liste otomatik uretilen adlarin duzeltilmesi (devam)
--  032_kod_liste_isim_duzeltme3.sql
--
--  Stok "Genel" sekmesi mockup'taki (stok_karti.html) "Tanım / Sınıflandırma"
--    alt-bolumune uyacak sekilde "Grup" (STOKLAR.GRUBU, BOLUM -2704) acildi.
-- ============================================================================
\set ON_ERROR_STOP on

update public.kod_liste set kod = 'stok.grubu', ad = 'Stok Grubu' where eski_bolum = -2704;
