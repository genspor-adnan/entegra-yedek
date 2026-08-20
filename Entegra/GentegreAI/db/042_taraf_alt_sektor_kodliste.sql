-- ============================================================================
--  Gentegre AI — Cari Alt Sektor kod listesi
--  042_taraf_alt_sektor_kodliste.sql
--
--  Kullanici: "cari kartta grup yerine Sektör combo hemen sağına Alt Sektör combo".
--  taraf.alt_sektor kolonu semada zaten vardi (integer, hic veri yoktu) ama kod_liste
--  kaydi yoktu - MSSQL/GENINI tarafinda da karsiligi yok (yeni liste, eski_bolum NULL).
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.kod_liste (kod, ad)
select 'taraf.alt_sektor', 'Cari Alt Sektor'
where not exists (select 1 from public.kod_liste where kod = 'taraf.alt_sektor');
