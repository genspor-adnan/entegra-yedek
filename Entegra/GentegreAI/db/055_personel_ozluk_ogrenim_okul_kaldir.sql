-- ============================================================================
--  Gentegre AI — Personel Özlük: Öğrenim Durumu / Okul kaldırıldı
--  055_personel_ozluk_ogrenim_okul_kaldir.sql
--
--  Kullanici: "personel_ozluk ten ogreim ve okul u kaldır".
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.personel_ozluk drop column if exists ogrenim_durumu;
alter table public.personel_ozluk drop column if exists okul;
