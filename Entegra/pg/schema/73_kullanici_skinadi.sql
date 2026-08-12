-- ============================================================
-- 73_kullanici_skinadi.sql
-- Kullanici bazli DevExpress skin tercihi (PG)
--
-- NULL / bos: mevcut uygulama gorunumu korunur.
-- Diger    : DevExpress SkinName (orn. Office2016Dark).
-- ============================================================
ALTER TABLE IF EXISTS public.kullanici
    ADD COLUMN IF NOT EXISTS skinadi varchar(50);
