-- ============================================================================
--  Gentegre AI — Kisi karti: Ad/Soyad yerine Unvan (037'nin trigger'i geri alindi)
--  038_kisi_karti_unvan_geri_al.sql
--
--  Kullanici: "Kisi kartinda Ad Soyad yerine Unvan olsun - Ad Soyad IK (personel) ve
--  hasta kartinda olacak" (o kartlar HENUZ YOK). 037'de kisi=1 satirinda unvan'i
--  ad+soyad'dan otomatik ureten trigger artik gereksiz - kisi karti dogrudan unvan
--  yaziyor, ad/soyad hic kullanilmiyor. Trigger acik kalsaydi, ad/soyad DOLU olan
--  eski bir satir tekrar UPDATE edilince (kart Unvan'i degistirse bile) unvan'i
--  sessizce ad+soyad'a GERI CEVIRIRDI - kullanicinin yeni Unvan'ini kaybettirirdi.
-- ============================================================================
\set ON_ERROR_STOP on

drop trigger if exists trg_taraf_kisi_unvan_ata on public.taraf;
drop function if exists public.fn_taraf_kisi_unvan_ata();
