-- ============================================================================
--  Gentegre AI — Kisi karti Rol (kisi_karti.html/kisi_listesi.html "KARAR/ETKİ/MUHS/KULL/TEKN")
--  040_kisi_rol.sql
--
--  GENINI kaynakli DEGIL (mockup'a ozel kisa sabit liste, MSSQL'de karsiligi yok).
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf add column if not exists rol smallint;

comment on column public.taraf.rol is
  'Kisi rolu (sadece kisi=1): 1 Karar Verici, 2 Etkileyen, 3 Kullanici, 4 Mali/Muhasebe, 5 Teknik. Sabit liste, GENINI kaynakli degil.';
