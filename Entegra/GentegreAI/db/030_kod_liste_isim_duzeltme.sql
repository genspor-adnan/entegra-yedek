-- ============================================================================
--  Gentegre AI — kod_liste otomatik uretilen adlarin duzeltilmesi
--  030_kod_liste_isim_duzeltme.sql
--
--  013_goc_faz1.sql gocte kod_liste.kod'u "liste_<|BOLUM|>" olarak uretiyor
--    (kod_liste.kod / kod_liste.ad yorumu: "kullanildikca elle duzeltilecek").
--  Stok kartinda Marka/Ana Birim/Izleme alanlari KodListesi ile baglandiginda
--    ilk kullanilan uc liste burada anlamli ada cevrilir.
-- ============================================================================
\set ON_ERROR_STOP on

update public.kod_liste set kod = 'stok.marka',     ad = 'Stok Marka'     where eski_bolum = -2701;
update public.kod_liste set kod = 'stok.ana_birim', ad = 'Stok Ana Birim' where eski_bolum = -2702;
update public.kod_liste set kod = 'stok.izleme',    ad = 'Stok Izleme'    where eski_bolum = -2706;
