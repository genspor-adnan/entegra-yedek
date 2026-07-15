-- ============================================================
-- GenDepoKur5 : ISLEMLOG (audit log) - LOG<yyyy> tablosu + view + ana DB synonym
--   Icinde bulunulan yil tablosu LOG<yyyy> (yoksa). ISLEMLOG view = tum LOG<yyyy>
--   UNION ALL. Ana DB'de ISLEMLOG synonym'i (UInfo/loglama bunun uzerinden okur).
--   Uygulama (ULog) sonraki yil tablolarini + view'i ayrica yonetir; bu script
--   yalnizca ilk gecerliligi saglar. LOG<yyyy> yapisi ULog.LogYilTablosu ile AYNI
--   (REHBERID/STOKID dahil). GenDepoKur1'den SONRA. Idempotent.
-- ============================================================
SET NOCOUNT ON;
IF DB_ID('GENDEPO') IS NULL EXEC('CREATE DATABASE [GENDEPO] COLLATE SQL_Latin1_General_CP1254_CI_AS');

-- 1) Icinde bulunulan yil tablosu LOG<yyyy>
DECLARE @yil varchar(4) = CAST(YEAR(GETDATE()) AS varchar(4));
EXEC('USE GENDEPO;
IF OBJECT_ID(''dbo.LOG' + @yil + ''',''U'') IS NULL
BEGIN
CREATE TABLE dbo.LOG' + @yil + '(
 ID bigint IDENTITY(1,1) NOT NULL,
 TARIH datetime2(0) NOT NULL CONSTRAINT DF_LOG' + @yil + '_TARIH DEFAULT(SYSDATETIME()),
 IP varchar(45) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
 ISTASYON varchar(64) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
 KULLANICIID int NULL, SUBEID smallint NULL, ISLEMTIPI tinyint NOT NULL,
 ALTISLEMTIPI tinyint NULL,
 USTTABLOID int NULL, USTKAYITID bigint NULL,
 TABLOID int NULL, KAYITID bigint NULL,
 REHBERID bigint NULL, STOKID bigint NULL,
 BILGI varbinary(max) NULL,
 CONSTRAINT PK_LOG' + @yil + ' PRIMARY KEY CLUSTERED (ID));
CREATE INDEX IX_LOG' + @yil + '_UST    ON dbo.LOG' + @yil + '(USTTABLOID,USTKAYITID);
CREATE INDEX IX_LOG' + @yil + '_KAYIT  ON dbo.LOG' + @yil + '(TABLOID,KAYITID);
CREATE INDEX IX_LOG' + @yil + '_REHBER ON dbo.LOG' + @yil + '(REHBERID);
CREATE INDEX IX_LOG' + @yil + '_STOK   ON dbo.LOG' + @yil + '(STOKID);
CREATE INDEX IX_LOG' + @yil + '_TARIH  ON dbo.LOG' + @yil + '(TARIH);
END');

-- 2) ISLEMLOG view = tum LOG<yyyy> UNION ALL (dinamik)
EXEC('USE GENDEPO;
DECLARE @u nvarchar(max)='''';
SELECT @u=@u+CASE WHEN @u='''' THEN '''' ELSE '' UNION ALL '' END+
 ''SELECT ID,TARIH,IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,ALTISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI FROM dbo.''+name
FROM sys.tables WHERE name LIKE ''LOG[0-9][0-9][0-9][0-9]'' ORDER BY name;
IF @u<>'''' EXEC(''CREATE OR ALTER VIEW dbo.ISLEMLOG AS ''+@u);');

-- 3) Ana DB synonym (eski ana-DB ISLEMLOG tablosu varsa kaldir)
IF OBJECT_ID('dbo.ISLEMLOG','U') IS NOT NULL DROP TABLE dbo.ISLEMLOG;
IF NOT EXISTS(SELECT 1 FROM sys.synonyms WHERE name='ISLEMLOG')
    CREATE SYNONYM dbo.ISLEMLOG FOR GENDEPO.dbo.ISLEMLOG;

SELECT YIL_TABLO = (SELECT name FROM GENDEPO.sys.tables WHERE name='LOG'+CAST(YEAR(GETDATE()) AS varchar(4))),
       VIEW_DURUM = CASE WHEN OBJECT_ID('GENDEPO.dbo.ISLEMLOG') IS NOT NULL THEN 'VAR' ELSE 'YOK!' END,
       SYNONYM_DURUM = CASE WHEN OBJECT_ID('dbo.ISLEMLOG','SN') IS NOT NULL THEN 'VAR' ELSE 'YOK/TABLO' END;
