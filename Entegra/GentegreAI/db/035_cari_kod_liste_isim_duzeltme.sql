-- ============================================================================
--  Gentegre AI — cari (taraf) kart alanlarinin kod_liste adlandirmasi
--  035_cari_kod_liste_isim_duzeltme.sql
--
--  Cari kartinin Genel sekmesindeki Grup/Kategori/Statu alanlari onceki
--  oturumda KodListesi baglanmadan (duz sayi olarak) kaldi (mockup'ta combo).
--  BOLUM numaralari PrjConst.pas'tan (Ops_CariKart_*): Grup=-2200, Kategori=-2208,
--  Statu=-2209. Sektor=-2204 de ayni pas dosyasinda ama katalogda alan yok, o da
--  ileride kullanilabilir diye adlandiriliyor.
-- ============================================================================
\set ON_ERROR_STOP on

update public.kod_liste set kod = 'taraf.grup',     ad = 'Cari Grup'     where eski_bolum = -2200;
update public.kod_liste set kod = 'taraf.kategori', ad = 'Cari Kategori' where eski_bolum = -2208;
update public.kod_liste set kod = 'taraf.statu',    ad = 'Cari Statu'    where eski_bolum = -2209;
update public.kod_liste set kod = 'taraf.sektor',   ad = 'Cari Sektor'   where eski_bolum = -2204;
