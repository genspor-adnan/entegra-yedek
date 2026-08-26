-- ============================================================
-- Update_PG_175.sql   #pg   (PostgreSQL)
-- KALITESABLONDETAY: eksik sure ve sira kolonlarini ekle
--
-- Update_SQL_175.sql'in PG karsiligi. Kolonlar bazi kurulumlarda yok; uygulama
--   (UUretimRecete) bunlari kullandigi icin "Field 'SURE' not found" ile ekran acilmiyor.
--   MSSQL smalldatetime -> PG timestamp; smallint aynen.
-- Idempotent: IF NOT EXISTS ile eklenir.
-- ============================================================

DO $$
BEGIN
    IF to_regclass('public.kalitesablondetay') IS NULL THEN
        RAISE NOTICE 'Update_PG_175: kalitesablondetay tablosu yok, atlandi.';
        RETURN;
    END IF;

    ALTER TABLE public.kalitesablondetay ADD COLUMN IF NOT EXISTS sure timestamp NULL;
    ALTER TABLE public.kalitesablondetay ADD COLUMN IF NOT EXISTS sira smallint NULL;
END $$;

SELECT column_name AS kolon, data_type AS tip
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name   = 'kalitesablondetay'
   AND column_name IN ('sure', 'sira');
