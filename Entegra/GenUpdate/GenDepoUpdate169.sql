-- ============================================================
-- GenDepoUpdate169.sql
-- Kullanici bazli DevExpress skin tercihi
--
-- NULL / bos: mevcut uygulama gorunumu korunur.
-- Diger    : DevExpress SkinName (orn. Office2016Dark).
-- ============================================================
IF COL_LENGTH('dbo.KULLANICI', 'SKINADI') IS NULL
BEGIN
    ALTER TABLE dbo.KULLANICI ADD SKINADI NVARCHAR(50) NULL;
END
GO
