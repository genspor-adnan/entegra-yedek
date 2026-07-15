-- ============================================================
-- EBELGE.UBL_XML -> UBL_XML_ZIP GUVENLI (dogrulamali) migration.
-- 3 faz: (1) sikistir - UBL_XML DOKUNULMAZ (yedek), (2) round-trip DOGRULA,
--        (3) yalnizca dogrulama GECERSE duz UBL_XML'i bosalt.
-- Kayipsiz + geri donulebilir. Mesai disi + yedek onerilir.
-- ! ONCE 'sql_ubl_zip_ekle.sql' calistirilmis (UBL_XML_ZIP kolonu var) olmali.
-- ! Idempotent: tekrar calistirilabilir.
-- ============================================================
SET NOCOUNT ON;

-- ---- ONCESI durum ----
SELECT 'ONCESI' AS ASAMA,
       DUZ_KAYIT = COUNT(*),
       DUZ_MB    = CONVERT(decimal(10,2), SUM(DATALENGTH(UBL_XML))/1048576.0)
FROM EBELGE WHERE UBL_XML IS NOT NULL;

-- ---- FAZ 1: Sikistir (UBL_XML'e DOKUNMA = yedek duruyor). Batch (500) ----
DECLARE @n int = 1;
WHILE @n > 0
BEGIN
    UPDATE TOP (500) EBELGE
       SET UBL_XML_ZIP = COMPRESS(CAST(UBL_XML AS NVARCHAR(MAX)))
     WHERE UBL_XML IS NOT NULL AND UBL_XML_ZIP IS NULL;
    SET @n = @@ROWCOUNT;
END

-- ---- FAZ 2: DOGRULA (acilan = orijinal mi, tum satirlar) ----
DECLARE @uyusmayan int;
SELECT @uyusmayan = COUNT(*)
FROM EBELGE
WHERE UBL_XML IS NOT NULL AND UBL_XML_ZIP IS NOT NULL
  AND CAST(UBL_XML AS NVARCHAR(MAX)) <> CAST(DECOMPRESS(UBL_XML_ZIP) AS NVARCHAR(MAX));

-- ---- FAZ 3: Yalnizca TUM satirlar dogrulandiysa duz kolonu bosalt ----
IF @uyusmayan = 0
BEGIN
    UPDATE EBELGE SET UBL_XML = NULL
     WHERE UBL_XML_ZIP IS NOT NULL AND UBL_XML IS NOT NULL;
    PRINT 'Dogrulama OK: UBL_XML bosaltildi, veri UBL_XML_ZIP''te (zipli).';
END
ELSE
    PRINT 'UYARI: ' + CAST(@uyusmayan AS varchar(20)) +
          ' satir round-trip dogrulanamadi -> UBL_XML KORUNDU (bosaltilmadi).';

-- ---- SONRASI durum ----
SELECT 'SONRASI' AS ASAMA,
       UYUSMAYAN   = @uyusmayan,
       KALAN_DUZ   = (SELECT COUNT(*) FROM EBELGE WHERE UBL_XML IS NOT NULL),
       ZIPLI_KAYIT = (SELECT COUNT(*) FROM EBELGE WHERE UBL_XML_ZIP IS NOT NULL),
       ZIP_MB      = (SELECT CONVERT(decimal(10,2), SUM(DATALENGTH(UBL_XML_ZIP))/1048576.0)
                      FROM EBELGE WHERE UBL_XML_ZIP IS NOT NULL);

-- ============================================================
-- ROLLBACK (gerekirse): zipli kayitlari tekrar duz UBL_XML'e ac
-- UPDATE EBELGE SET UBL_XML = CAST(DECOMPRESS(UBL_XML_ZIP) AS NVARCHAR(MAX))
--  WHERE UBL_XML IS NULL AND UBL_XML_ZIP IS NOT NULL;
-- (Istersen sonra: UPDATE EBELGE SET UBL_XML_ZIP = NULL WHERE UBL_XML IS NOT NULL;)
-- ============================================================
