-- ============================================================
-- GenDepoUpdate48 (musteri uygulama)
--   DOSYA deposu ONARIM/TAMAMLAMA (FILESTREAM). GenDepoUpdate3'teki DOSYA kurulumu
--   FILESTREAM OS-seviyesi KAPALIYKEN calisirsa YARIM kalabilir:
--     - DosyaFS filegroup olusur AMA icine FILESTREAM FILE eklenemez (ADD FILE hata) ->
--       sonraki re-run'lar '@fgSay>0' gordugu icin ADD FILE'i ATLAR -> DOSYA tablosu
--       'FILESTREAM_ON DosyaFS' ile olusturulamaz -> uygulamada:
--       "Invalid object name 'GENDEPO.dbo.DOSYA'".
--   Bu madde her parcayi BAGIMSIZ VAR-MI ile tamamlar (filegroup / FILESTREAM file /
--     DOSYA tablosu / ana DB synonym). FILESTREAM OS-seviyesi ACIK olmali (EffectiveLevel>0).
--   COK-INSTANCE: depo adi @depo ile cozulur (GENINI BOLUM=-24120 DIL=0; yoksa 'GENDEPO').
--   Tek batch (GO yok), idempotent. Ana DB baglantisindan calistirilir.
-- ============================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @errmsg nvarchar(2048);
DECLARE @sql    nvarchar(max);
DECLARE @depo   sysname = NULLIF((SELECT ANAHTAR FROM dbo.GENINI WHERE BOLUM = -24120 AND DIL = 0), '');
IF @depo IS NULL OR @depo = ''
  SET @depo = 'GENDEPO';

DECLARE @depoVar bit = CASE WHEN DB_ID(@depo) IS NOT NULL THEN 1 ELSE 0 END;

IF @depoVar = 0
BEGIN
  RAISERROR('GenDepoUpdate48: depo DB (%s) yok -> DOSYA onarimi atlandi.', 10, 1, @depo) WITH NOWAIT;
  RETURN;
END

IF CAST(SERVERPROPERTY('FilestreamEffectiveLevel') AS int) = 0
BEGIN
  RAISERROR('GenDepoUpdate48: FILESTREAM OS-seviyesi KAPALI (EffectiveLevel=0). Config Manager > FILESTREAM acip servisi restart edin, sonra tekrar calistirin. DOSYA onarimi atlandi.', 10, 1) WITH NOWAIT;
  RETURN;
END

DECLARE @fgSay int, @fileSay int, @mdf nvarchar(500), @dir nvarchar(500), @fs nvarchar(500);

BEGIN TRY
  -- (1) DosyaFS filegroup var mi?
  SET @fgSay = 0;
  SET @sql = N'SELECT @c = COUNT(*) FROM ' + QUOTENAME(@depo) + N'.sys.filegroups WHERE name = ''DosyaFS'' AND type_desc = ''FILESTREAM_DATA_FILEGROUP''';
  EXEC sp_executesql @sql, N'@c int OUTPUT', @c = @fgSay OUTPUT;
  IF @fgSay = 0
  BEGIN
    SET @sql = N'ALTER DATABASE ' + QUOTENAME(@depo) + N' ADD FILEGROUP DosyaFS CONTAINS FILESTREAM;';
    EXEC(@sql);
    RAISERROR('GenDepoUpdate48: DosyaFS filegroup olusturuldu.', 10, 1) WITH NOWAIT;
  END

  -- (2) DosyaFS icinde FILESTREAM FILE (container) var mi?  <-- YARIM-KALMA burada onarilir
  SET @fileSay = 0;
  SET @sql = N'SELECT @c = COUNT(*) FROM ' + QUOTENAME(@depo) + N'.sys.database_files df
               JOIN ' + QUOTENAME(@depo) + N'.sys.filegroups fg ON fg.data_space_id = df.data_space_id
               WHERE fg.name = ''DosyaFS'' AND df.type = 2';
  EXEC sp_executesql @sql, N'@c int OUTPUT', @c = @fileSay OUTPUT;
  IF @fileSay = 0
  BEGIN
    SELECT @mdf = physical_name FROM sys.master_files WHERE database_id = DB_ID(@depo) AND type = 0 AND file_id = 1;
    SET @dir = LEFT(@mdf, LEN(@mdf) - CHARINDEX('\', REVERSE(@mdf)));

    -- FILESTREAM container klasoru SQL tarafindan olusturulur -> ONCEDEN VAR OLMAMALI.
    -- Yarim-kalan onceki denemeden '<depo>_FS' klasoru diskte kalmis olabilir
    -- ("Cannot create file ... because it already exists"). CAKISMAYAN ilk adi sec.
    DECLARE @fsAd sysname, @n int = 1, @dolu int;
    DECLARE @fe TABLE(FileExists int, IsDir int, ParentExists int);
    WHILE @n < 100
    BEGIN
      SET @fsAd = @depo + '_FS' + CASE WHEN @n = 1 THEN '' ELSE '_' + CAST(@n AS varchar(3)) END;
      SET @fs   = @dir + '\' + @fsAd;
      DELETE @fe;
      INSERT @fe EXEC master.dbo.xp_fileexist @fs;
      -- DIKKAT: klasor icin FileExists=0 AMA IsDir=1 doner -> ikisini de kontrol et.
      SELECT @dolu = CASE WHEN FileExists = 1 OR IsDir = 1 THEN 1 ELSE 0 END FROM @fe;
      IF @dolu = 0 BREAK;   -- diskte hic yok -> bu adi kullan
      SET @n += 1;
    END

    SET @sql = N'ALTER DATABASE ' + QUOTENAME(@depo) + N' ADD FILE (NAME=N''' + @fsAd + N''', FILENAME=N''' + @fs + N''') TO FILEGROUP DosyaFS;';
    EXEC(@sql);
    RAISERROR('GenDepoUpdate48: FILESTREAM container eklendi (%s).', 10, 1, @fs) WITH NOWAIT;
  END

  -- (3) DOSYA tablosu var mi?
  IF OBJECT_ID(QUOTENAME(@depo)+'.dbo.DOSYA') IS NULL
  BEGIN
    -- NOT: bu DOSYA DDL'i GenDepoUpdate3'teki ile BIREBIR AYNI olmali (sema-drift riski);
    --   DOSYA sutunlari degisirse iki scripti de guncelle.
    SET @sql = N'USE ' + QUOTENAME(@depo) + N';
CREATE TABLE dbo.DOSYA(
  ID        bigint IDENTITY(1,1) NOT NULL CONSTRAINT PK_DOSYA PRIMARY KEY,
  DOSYAGUID uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT DF_DOSYA_GUID DEFAULT NEWID() CONSTRAINT UQ_DOSYA_GUID UNIQUE,
  HASH      binary(32)    NOT NULL,
  BOYUT     bigint        NOT NULL,
  UZANTI    nvarchar(20)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  MIMETYPE  nvarchar(100) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  ICERIK    varbinary(max) FILESTREAM NOT NULL,
  REFSAYAC  int           NOT NULL CONSTRAINT DF_DOSYA_REF DEFAULT 1,
  EKLEME    datetime2(0)  NOT NULL CONSTRAINT DF_DOSYA_EKLEME DEFAULT(SYSDATETIME())
) FILESTREAM_ON DosyaFS;
CREATE UNIQUE INDEX UX_DOSYA_HASH ON dbo.DOSYA(HASH);';
    EXEC(@sql);
    RAISERROR('GenDepoUpdate48: DOSYA tablosu olusturuldu.', 10, 1) WITH NOWAIT;
  END

  -- (4) Ana DB: synonym dbo.DOSYA -> [@depo].dbo.DOSYA
  IF OBJECT_ID(QUOTENAME(@depo)+'.dbo.DOSYA') IS NOT NULL
     AND OBJECT_ID('dbo.DOSYA','SN') IS NULL AND OBJECT_ID('dbo.DOSYA','U') IS NULL
  BEGIN
    SET @sql = N'CREATE SYNONYM dbo.DOSYA FOR ' + QUOTENAME(@depo) + N'.dbo.DOSYA;';
    EXEC(@sql);
    RAISERROR('GenDepoUpdate48: ana DB synonym dbo.DOSYA olusturuldu.', 10, 1) WITH NOWAIT;
  END

  RAISERROR('GenDepoUpdate48: DOSYA deposu HAZIR.', 10, 1) WITH NOWAIT;
END TRY
BEGIN CATCH
  SET @errmsg = ERROR_MESSAGE();
  RAISERROR('GenDepoUpdate48: DOSYA onarimi HATA verdi: %s', 16, 1, @errmsg) WITH NOWAIT;
END CATCH
