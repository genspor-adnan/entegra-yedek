-- ============================================================
-- GenDepoUpdate3 : GenDepoUpdate2 SONRASI artimli DB guncellemeleri (2026-07-10).
-- BUNDAN SONRAKI tum DB update maddeleri BURAYA eklenir (KURAL: gun degisince YENI dosya).
--
-- CALISTIRMA  : ANA DB baglantisindan (GENTEGREDB / GENTEGREDB2 / GENTEGREDB3 ...).
-- IDEMPOTENT  : tekrar tekrar guvenle calisir (her madde kendi VAR-MI kontrolunu yapar).
-- TEK BATCH   : GO KULLANMA. @depo tum dosyada gecerli kalsin diye tek batch'tir.
--
-- >>> COK-INSTANCE KURALI <<<
--   Depo DB adi (GENDEPO / GENDEPO2 / GENDEPO3 ...) ASLA SABIT YAZILMAZ.
--   Ayni madde metni remote update servisinden TUM musterilere gider; her musterinin
--   deposu farkli olabilir -> @depo ile CALISIRKEN cozulur (GENINI BOLUM=-24120, DIL=0;
--   yoksa 'GENDEPO'). ANA DB nesneleri (IMAJ, GENINI ...) DOGRUDAN; DEPO (GENDEPO*) DDL
--   DAIMA @depo uzerinden dinamik EXEC ile.
-- ============================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @errmsg nvarchar(2048);   -- CATCH bloklarinda ERROR_MESSAGE() tasimak icin

-- ---- Depo DB adini GENINI'den al (ReadString ile AYNI kaynak: ANAHTAR, DIL=0) ----
DECLARE @depo sysname = NULLIF((SELECT ANAHTAR FROM dbo.GENINI WHERE BOLUM = -24120 AND DIL = 0), '');
IF @depo IS NULL OR @depo = ''
  SET @depo = 'GENDEPO';

DECLARE @depoVar bit = CASE WHEN DB_ID(@depo) IS NOT NULL THEN 1 ELSE 0 END;
IF @depoVar = 0
  RAISERROR('GenDepoUpdate3: depo DB (%s) yok -> depo maddeleri atlandi (ANA DB maddeleri calisti).', 10, 1, @depo) WITH NOWAIT;

DECLARE @sql nvarchar(max);

-- ============================================================
-- >>> GERCEK GUNCELLEMELER BURADAN ASAGIYA, SIRAYLA EKLENIR <<<
-- ============================================================

-- ============================================================
-- 2026-07-09/10: DOSYA deposu (belge/resim/medya ICERIK, FILESTREAM) — musteri kurulumu.
--   IMAJ artik blob'u KENDISI tutmaz -> IMAJ.DOSYAID -> DOSYA.ID (SHA-256 hash ile TEKILLESTIRME).
--   ICERIK varbinary(max) FILESTREAM -> Express 10 GB DB limitine SAYILMAZ (byte'lar disk container'da).
--   ONKOSUL: FILESTREAM OS-seviyesi ACIK olmali (Config Manager > FILESTREAM, ADMIN; her
--   musteride ELLE) + servis RESTART. Bu update: (a) SQL-seviye (sp_configure 2),
--   (b) @depo'da FILESTREAM filegroup + DOSYA tablosu + ana DB synonym, (c) IMAJ.DOSYAID.
--   OS-seviye kapaliysa DOSYA ATLANIR (uyarilir; kalan update etkilenmez -> TRY/CATCH).
-- ============================================================

-- ------------------------------------------------------------
-- (a) FILESTREAM SQL erisim seviyesi (SERVER-level, master uzerinden).
--   value_in_use: 0=kapali, 1=T-SQL, 2=T-SQL+Win32 streaming (2 gerekli).
--   Windows tarafi (Config Manager > FILESTREAM) KAPALI ise RECONFIGURE hata verir ->
--   TRY/CATCH ile yut, update'in kalani calissin (o musteride elle acilir).
--   *** DIKKAT: configured=2 yapar ama value_in_use=2 icin SQL Server SERVIS RESTART gerekir
--       (0->2 Win32 streaming gecisi dinamik degil). FILESTREAM filegroup olusturmadan ONCE
--       restart yapilmis olmali. ***
-- ------------------------------------------------------------
BEGIN TRY
  IF (SELECT CAST(value_in_use AS int) FROM sys.configurations WHERE name = 'filestream access level') <> 2
  BEGIN
    EXEC master..sp_configure 'filestream access level', 2;
    RECONFIGURE;
    RAISERROR('FILESTREAM SQL erisim seviyesi 2 yapildi (SERVIS RESTART gerekir).', 10, 1) WITH NOWAIT;
  END
END TRY
BEGIN CATCH
  SET @errmsg = ERROR_MESSAGE();
  RAISERROR('FILESTREAM acilamadi (Windows/Config Manager tarafi kapali olabilir): %s', 10, 1, @errmsg) WITH NOWAIT;
END CATCH

-- ------------------------------------------------------------
-- (b) @depo'da FILESTREAM filegroup + DOSYA tablosu + ana DB synonym
-- ------------------------------------------------------------
DECLARE @fgSay int, @mdf nvarchar(500), @dir nvarchar(500), @fs nvarchar(500);
BEGIN TRY
  IF @depoVar = 1 AND CAST(SERVERPROPERTY('FilestreamEffectiveLevel') AS int) > 0
  BEGIN
    -- 1) FILESTREAM filegroup + container (@depo mdf klasorunun yaninda <depo>_FS)
    SET @fgSay = 0;
    SET @sql = N'SELECT @c = COUNT(*) FROM ' + QUOTENAME(@depo) + N'.sys.filegroups WHERE type_desc = ''FILESTREAM_DATA_FILEGROUP''';
    EXEC sp_executesql @sql, N'@c int OUTPUT', @c = @fgSay OUTPUT;
    IF @fgSay = 0
    BEGIN
      SELECT @mdf = physical_name FROM sys.master_files WHERE database_id = DB_ID(@depo) AND type = 0 AND file_id = 1;
      SET @dir = LEFT(@mdf, LEN(@mdf) - CHARINDEX('\', REVERSE(@mdf)));
      SET @fs  = @dir + '\' + @depo + '_FS';
      SET @sql = N'ALTER DATABASE ' + QUOTENAME(@depo) + N' ADD FILEGROUP DosyaFS CONTAINS FILESTREAM;';
      EXEC(@sql);
      SET @sql = N'ALTER DATABASE ' + QUOTENAME(@depo) + N' ADD FILE (NAME=N''' + @depo + '_FS'', FILENAME=N''' + @fs + N''') TO FILEGROUP DosyaFS;';
      EXEC(@sql);
    END

    -- 2) DOSYA tablosu + HASH benzersiz index
    IF OBJECT_ID(QUOTENAME(@depo)+'.dbo.DOSYA') IS NULL
    BEGIN
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
    END

    -- 3) Ana DB: synonym dbo.DOSYA -> [@depo].dbo.DOSYA
    IF OBJECT_ID(QUOTENAME(@depo)+'.dbo.DOSYA') IS NOT NULL
       AND OBJECT_ID('dbo.DOSYA','SN') IS NULL AND OBJECT_ID('dbo.DOSYA','U') IS NULL
    BEGIN
      SET @sql = N'CREATE SYNONYM dbo.DOSYA FOR ' + QUOTENAME(@depo) + N'.dbo.DOSYA;';
      EXEC(@sql);
    END
  END
  ELSE IF @depoVar = 1
    RAISERROR('DOSYA ATLANDI: FILESTREAM OS-seviyesi kapali (EffectiveLevel=0). Config Manager''dan acip servisi restart edin, sonra bu update''i tekrar calistirin.', 10, 1) WITH NOWAIT;
END TRY
BEGIN CATCH
  SET @errmsg = ERROR_MESSAGE();
  RAISERROR('DOSYA/FILESTREAM kurulumu hata verdi (update kalani etkilenmedi): %s', 10, 1, @errmsg) WITH NOWAIT;
END CATCH

-- ------------------------------------------------------------
-- (c) Ana DB: IMAJ.DOSYAID (DOSYA.ID referansi; blob artik DOSYA'da). FILESTREAM'den BAGIMSIZ.
-- ------------------------------------------------------------
IF COL_LENGTH('dbo.IMAJ','DOSYAID') IS NULL
  ALTER TABLE dbo.IMAJ ADD DOSYAID bigint NULL;

-- ------------------------------------------------------------
-- (d) IMAJ DELETE trigger'i: silinen IMAJ satiri DOSYA'ya referansliysa REFSAYAC'i azalt;
--   0'a inince icerigi sil (FILESTREAM dosyasi GC ile gider). Boylece HANGI YOLDAN silinirse
--   silinsin (DokumanSil, kart-silme cascade 'delete from IMAJ', resim grid delete...) DOSYA
--   refcount TUTARLI kalir + dedup GUVENLI (paylasilan icerik baska referans varken silinmez).
--   Set-bazli: ayni DOSYAID'yi birden fazla satir referans ediyorsa COUNT kadar azaltir.
--   CREATE TRIGGER batch'in ilk ifadesi olmali -> EXEC ile. DOSYA yoksa (FILESTREAM kapali)
--   trigger kurulmaz (DOSYAID zaten hep NULL, gerek yok).
IF OBJECT_ID('dbo.DOSYA') IS NOT NULL AND OBJECT_ID('dbo.IMAJ') IS NOT NULL
BEGIN
  SET @sql = N'CREATE OR ALTER TRIGGER dbo.TG_IMAJ_DosyaRefAzalt ON dbo.IMAJ AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS (SELECT 1 FROM deleted WHERE DOSYAID > 0) RETURN;
  UPDATE d SET REFSAYAC = d.REFSAYAC - x.c
    FROM dbo.DOSYA d
    JOIN (SELECT DOSYAID, COUNT(*) AS c FROM deleted WHERE DOSYAID > 0 GROUP BY DOSYAID) x
      ON x.DOSYAID = d.ID;
  DELETE d FROM dbo.DOSYA d
    JOIN (SELECT DISTINCT DOSYAID FROM deleted WHERE DOSYAID > 0) x ON x.DOSYAID = d.ID
    WHERE d.REFSAYAC <= 0;
END';
  EXEC(@sql);
END
