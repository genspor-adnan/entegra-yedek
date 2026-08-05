-- ============================================================
-- GenDepoKur1 : GENDEPO veritabani (ilk kurulum, yeni musteri)
--   - Collation SQL_Latin1_General_CP1254_CI_AS (ana DB ile ayni -> cross-DB
--     'collation conflict' bastan onlenir; sunucu default'u ne olursa olsun).
--   - AUTO_CLOSE OFF (surekli yazim), RECOVERY SIMPLE (log DB'si sismesin).
-- Ana DB baglantisindan calistir. GO YOK (SqlClient/ps1 uyumlu).
-- SIRA: 1 -> 2 (EBELGE) -> 3 (EBELGEMESAJ) -> 4 (EBELGEKUYRUK)
--       -> 5 (ISLEMLOG/LOG) -> 6 (LOGREFERANS) -> 7 (LOGCOZUM)
-- ============================================================
-- ADLANDIRMA KURALI (05.08.2026): depo veritabani adi <ANA_DB>_GENDEPO olmak zorunda.
--   Ayni sunucuda birden fazla Gentegre veritabani bulunabildigi icin sabit 'GENDEPO'
--   adi ikinci kurulumda MEVCUT depoyu bulup ona baglaniyordu (yanlis depoya log/e-belge).
--   Bu yuzden depo adi artik ANA DB adindan turetilir; script ana DB'den calistirilmalidir.
DECLARE @Depo SYSNAME = DB_NAME() + N'_GENDEPO';
DECLARE @D    NVARCHAR(300) = QUOTENAME(@Depo);      -- [SDI_GENDEPO]
DECLARE @Dq   NVARCHAR(300) = QUOTENAME(@Depo, '''');  -- 'SDI_GENDEPO' (literal)

SET NOCOUNT ON;

IF DB_ID(@Depo) IS NULL
BEGIN
    EXEC('CREATE DATABASE ' + @D + ' COLLATE SQL_Latin1_General_CP1254_CI_AS');
    EXEC('ALTER DATABASE ' + @D + ' SET AUTO_CLOSE OFF');
    EXEC('ALTER DATABASE ' + @D + ' SET RECOVERY SIMPLE');
END

-- Kontrol
SELECT GENDEPO_DURUM = CASE WHEN DB_ID(@Depo) IS NULL THEN 'YOK!' ELSE 'VAR' END,
       COLLATION     = CONVERT(sysname, DATABASEPROPERTYEX(@Depo,'Collation'));
