-- ============================================================================
--  Gentegre AI — Tahakkuk belgeleri muhasebe fisi URETMEZ
--  098_tahakkuk_fis_uretmez.sql
--
--  Kullanici karari: "satis fisleri icin muhasebe fis kayitlari olusur ama
--  tahakkuklar icin olusmaz".
--
--  Tahakkuk (13 Alacak Tahakkuku / 17 Borc Tahakkuku) cari bakiyeyi ve
--  ekstreyi etkileyen ama muhasebelesmeyen bir ARA kayittir: gerceklesen
--  islem (fatura/tahsilat) geldiginde muhasebe onunla yazilir. Iki kere
--  fis yazilmasin diye tur bayragi kapatiliyor.
--
--  Satis Fisi (16) ve faturalar (11/15) fis_mi = 1 olarak KALIR - belge
--  fisleme (Kasa plani F7, fn_belge_fisle) bu bayragi okuyacak.
-- ============================================================================
\set ON_ERROR_STOP on

update public.kasa_islem_turu
   set fis_mi = 0
 where kod in (13, 17) and fis_mi <> 0;

comment on column public.kasa_islem_turu.fis_mi is
  '1 ise bu tur muhasebe fisi uretir. Tahakkuklar (13/17) 0: cari bakiyeyi etkiler, muhasebelesmez (098).';

do $$
declare r record;
begin
    for r in select kod, ad, fis_mi, stok_etkiler, cari_etkiler
               from public.kasa_islem_turu
              where kod in (13, 15, 16, 17) order by kod
    loop
        raise notice '098: % (%) fis_mi=% stok=% cari=%',
                     r.kod, r.ad, r.fis_mi, r.stok_etkiler, r.cari_etkiler;
    end loop;
end $$;
