-- ============================================================
-- EBELGE UBL_XML sikistirma (COMPRESS/GZIP) icin sema adimi.
-- Yeni exe'DEN ONCE calistirilmali (kod UBL_XML_ZIP kolonunu referans veriyor).
-- Idempotent: tekrar calistirilabilir. SQL Server 2016+ gerekir (COMPRESS/DECOMPRESS).
-- ============================================================
IF COL_LENGTH('dbo.EBELGE', 'UBL_XML_ZIP') IS NULL
BEGIN
    ALTER TABLE dbo.EBELGE ADD UBL_XML_ZIP varbinary(max) NULL;
    PRINT 'EBELGE.UBL_XML_ZIP eklendi.';
END
ELSE
    PRINT 'EBELGE.UBL_XML_ZIP zaten var.';

-- Opsiyonel: mevcut (duz) kayitlari da sikistirip yer kazanmak icin (mesai disi,
-- batch batch calistirilabilir; ZORUNLU DEGIL - okuma COALESCE ile calisir):
--
-- UPDATE TOP (500) EBELGE
--   SET UBL_XML_ZIP = COMPRESS(CAST(UBL_XML AS NVARCHAR(MAX))), UBL_XML = NULL
--   WHERE UBL_XML IS NOT NULL;   -- 0 satir kalana dek tekrarla
