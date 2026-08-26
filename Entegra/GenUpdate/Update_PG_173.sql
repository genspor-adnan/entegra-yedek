-- ============================================================
-- Update_PG_173.sql   #pg   (PostgreSQL)
-- KALITESABLONDETAY: toleransdegeri ve miktar -> numeric(12,4)
--
-- Update_SQL_173.sql'in PG karsiligi; ayni gerekce:
--   Delphi persistent TBCDField'lerin Size'i (ondalik hane) sabit 4 bekliyor; kolon
--   olcegi 2 olan kurulumlarda dataset acilisinda "size mismatch expecting 4 actual 2".
--   Olcek tek degere (12,4) sabitlenir. Genisletmedir, veri kaybi yok.
-- Idempotent: olcek zaten 4 ise hicbir sey yapmaz.
-- ============================================================

DO $$
DECLARE
    r record;
BEGIN
    IF to_regclass('public.kalitesablondetay') IS NULL THEN
        RAISE NOTICE 'Update_PG_173: kalitesablondetay tablosu yok, atlandi.';
        RETURN;
    END IF;

    FOR r IN
        SELECT column_name, numeric_scale
          FROM information_schema.columns
         WHERE table_schema = 'public'
           AND table_name   = 'kalitesablondetay'
           AND column_name IN ('toleransdegeri', 'miktar')
           AND data_type = 'numeric'
           AND coalesce(numeric_scale, 0) < 4
    LOOP
        EXECUTE format('ALTER TABLE public.kalitesablondetay ALTER COLUMN %I TYPE numeric(12,4)',
                       r.column_name);
        RAISE NOTICE 'Update_PG_173: % numeric(12,%) -> numeric(12,4).', r.column_name, r.numeric_scale;
    END LOOP;
END $$;

SELECT column_name AS kolon,
       data_type || '(' || numeric_precision || ',' || numeric_scale || ')' AS tip
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name   = 'kalitesablondetay'
   AND column_name IN ('toleransdegeri', 'miktar');
