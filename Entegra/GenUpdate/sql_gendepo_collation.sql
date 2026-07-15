-- ============================================================
-- GENDEPO collation -> SQL_Latin1_General_CP1254_CI_AS (BILIM ile ayni).
-- Amac: cross-DB 'collation conflict' hatalarini kaldirmak (UInfo LOGREFERANS<->STOKLAR vb.)
-- Kapsam: LOGREFERANS, LOGCOZUM ve LOG20xx char kolonlari + 3 index + DB varsayilani.
-- Idempotent: Turkish_CI_AS kolon kalmayinca ALTER'lar bos kume uzerinde calisir.
-- NOT: DB varsayilan collation'i (adim 5) exclusive erisim ister; uygulamayi kapatin.
--      Cross-DB INDEXPROPERTY NULL dondugu icin index kontrolu sys.indexes ile yapilir.
-- ============================================================
SET NOCOUNT ON;
DECLARE @kolonHata nvarchar(2000)=N'(yok)', @dbHata nvarchar(2000)=N'(denenmedi)';

-- ---- KOLON + INDEX donusumu (exclusive gerekmez) ----
BEGIN TRY
    IF EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='IX_LOGCOZUM_ALAN'   AND object_id=OBJECT_ID('GENDEPO.dbo.LOGCOZUM'))
        DROP INDEX IX_LOGCOZUM_ALAN ON GENDEPO.dbo.LOGCOZUM;
    IF EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='IX_LOGREFERANS_AD'  AND object_id=OBJECT_ID('GENDEPO.dbo.LOGREFERANS'))
        DROP INDEX IX_LOGREFERANS_AD ON GENDEPO.dbo.LOGREFERANS;
    IF EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='IX_LOGREFERANS_KOD' AND object_id=OBJECT_ID('GENDEPO.dbo.LOGREFERANS'))
        DROP INDEX IX_LOGREFERANS_KOD ON GENDEPO.dbo.LOGREFERANS;

    DECLARE @sql nvarchar(max)=N'';
    SELECT @sql = @sql +
        'ALTER TABLE GENDEPO.dbo.' + QUOTENAME(t.name) + ' ALTER COLUMN ' + QUOTENAME(c.name) + ' ' +
        ty.name + '(' + CASE WHEN c.max_length=-1 THEN 'max'
                             WHEN ty.name LIKE 'n%' THEN CONVERT(varchar(10),c.max_length/2)
                             ELSE CONVERT(varchar(10),c.max_length) END + ') ' +
        'COLLATE SQL_Latin1_General_CP1254_CI_AS ' +
        CASE WHEN c.is_nullable=1 THEN 'NULL' ELSE 'NOT NULL' END + ';' + CHAR(13)+CHAR(10)
    FROM GENDEPO.sys.columns c
    JOIN GENDEPO.sys.tables t ON t.object_id=c.object_id
    JOIN GENDEPO.sys.types ty ON ty.user_type_id=c.user_type_id
    WHERE c.collation_name='Turkish_CI_AS';
    EXEC(@sql);

    IF NOT EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='IX_LOGCOZUM_ALAN'   AND object_id=OBJECT_ID('GENDEPO.dbo.LOGCOZUM'))
        CREATE INDEX IX_LOGCOZUM_ALAN ON GENDEPO.dbo.LOGCOZUM(ALAN);
    IF NOT EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='IX_LOGREFERANS_AD'  AND object_id=OBJECT_ID('GENDEPO.dbo.LOGREFERANS'))
        CREATE INDEX IX_LOGREFERANS_AD ON GENDEPO.dbo.LOGREFERANS(AD);
    IF NOT EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='IX_LOGREFERANS_KOD' AND object_id=OBJECT_ID('GENDEPO.dbo.LOGREFERANS'))
        CREATE INDEX IX_LOGREFERANS_KOD ON GENDEPO.dbo.LOGREFERANS(KOD);
END TRY
BEGIN CATCH SET @kolonHata=ERROR_MESSAGE(); END CATCH

EXEC GENDEPO.sys.sp_refreshview 'dbo.ISLEMLOG';

-- ---- DB VARSAYILAN collation (exclusive) ----
-- SQL Server FILTRELI index'leri (WHERE'li) DB collation'ina BAGIMLI sayar (Msg 5075).
-- ALTER DATABASE COLLATE oncesi dusurulur, sonra AYNEN geri kurulur.
ALTER DATABASE GENDEPO SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

IF EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='UX_EBELGE_UUID' AND object_id=OBJECT_ID('GENDEPO.dbo.EBELGE'))
    DROP INDEX UX_EBELGE_UUID ON GENDEPO.dbo.EBELGE;
IF EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='UX_EBELGEKUYRUK_AKTIF_IS' AND object_id=OBJECT_ID('GENDEPO.dbo.EBELGEKUYRUK'))
    DROP INDEX UX_EBELGEKUYRUK_AKTIF_IS ON GENDEPO.dbo.EBELGEKUYRUK;

BEGIN TRY
    ALTER DATABASE GENDEPO COLLATE SQL_Latin1_General_CP1254_CI_AS;
    SET @dbHata=N'(basarili)';
END TRY
BEGIN CATCH SET @dbHata=ERROR_MESSAGE(); END CATCH

-- Filtreli index'leri geri kur (COLLATE basarili olsun/olmasin)
IF NOT EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='UX_EBELGE_UUID' AND object_id=OBJECT_ID('GENDEPO.dbo.EBELGE'))
    CREATE UNIQUE INDEX UX_EBELGE_UUID ON GENDEPO.dbo.EBELGE(UUID) WHERE UUID IS NOT NULL;
IF NOT EXISTS(SELECT 1 FROM GENDEPO.sys.indexes WHERE name='UX_EBELGEKUYRUK_AKTIF_IS' AND object_id=OBJECT_ID('GENDEPO.dbo.EBELGEKUYRUK'))
    CREATE UNIQUE INDEX UX_EBELGEKUYRUK_AKTIF_IS ON GENDEPO.dbo.EBELGEKUYRUK(EBELGEID, ISLEMTURU) WHERE DURUM IN (0,1,9);

ALTER DATABASE GENDEPO SET MULTI_USER;

SELECT @kolonHata AS KOLON_HATASI, @dbHata AS DB_DEFAULT_SONUC,
       DATABASEPROPERTYEX('GENDEPO','Collation') AS GENDEPO_COLLATION,
       (SELECT COUNT(*) FROM GENDEPO.sys.columns WHERE collation_name='Turkish_CI_AS') AS KALAN_TURKISH_KOLON;
