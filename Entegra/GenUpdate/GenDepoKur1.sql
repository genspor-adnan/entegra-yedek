-- ============================================================
-- GenDepoKur1 : GENDEPO veritabani (ilk kurulum, yeni musteri)
--   - Collation SQL_Latin1_General_CP1254_CI_AS (ana DB ile ayni -> cross-DB
--     'collation conflict' bastan onlenir; sunucu default'u ne olursa olsun).
--   - AUTO_CLOSE OFF (surekli yazim), RECOVERY SIMPLE (log DB'si sismesin).
-- Ana DB baglantisindan calistir. GO YOK (SqlClient/ps1 uyumlu).
-- SIRA: 1 -> 2 (EBELGE) -> 3 (EBELGEMESAJ) -> 4 (EBELGEKUYRUK)
--       -> 5 (ISLEMLOG/LOG) -> 6 (LOGREFERANS) -> 7 (LOGCOZUM)
-- ============================================================
SET NOCOUNT ON;

IF DB_ID('GENDEPO') IS NULL
BEGIN
    EXEC('CREATE DATABASE [GENDEPO] COLLATE SQL_Latin1_General_CP1254_CI_AS');
    EXEC('ALTER DATABASE [GENDEPO] SET AUTO_CLOSE OFF');
    EXEC('ALTER DATABASE [GENDEPO] SET RECOVERY SIMPLE');
END

-- Kontrol
SELECT GENDEPO_DURUM = CASE WHEN DB_ID('GENDEPO') IS NULL THEN 'YOK!' ELSE 'VAR' END,
       COLLATION     = CONVERT(sysname, DATABASEPROPERTYEX('GENDEPO','Collation'));
