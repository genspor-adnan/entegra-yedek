-- ============================================================
-- Loglama (ISLEMLOG) kurulumu. Ana DB baglantisindan (ayni SQL instance) calistir.
--   1) GENDEPO veritabanini (yoksa) olusturur + log DB ayarlari.
--   2) Eski GENDEPO.dbo.ISLEMLOG TABLOSUNU kaldirir (artik view olacak).
--   3) Icinde bulunulan yil tablosu LOG<yyyy> (yoksa) - okuma icin en az 1 tablo gerek.
--   4) ISLEMLOG view = tum LOG<yyyy> UNION ALL (kurulumdan itibaren gecerli/bos).
--   5) Ana DB'de synonym ISLEMLOG -> GENDEPO.dbo.ISLEMLOG.
--
-- NOT: LOG<yyyy>'ye YAZMA view'e bagli DEGIL (INSERT dogrudan tabloya). View yalnizca
-- OKUMA (UInfo) icin. Uygulama (ULog) sonraki yil tablolarini ve view'i ayrica yonetir;
-- bu script yalnizca ilk gecerliligi saglar.
--
-- * Idempotent. GO YOK -> ps1/SqlDataAdapter ile de uyumlu (her sey EXEC ile).
-- ============================================================

-- 1) GENDEPO (yoksa). ALTER'lar YALNIZCA yeni olustururken (kimse bagli degilken;
--    mevcut DB'de ALTER DATABASE deadlock yapabilir).
IF DB_ID('GENDEPO') IS NULL
BEGIN
    EXEC('CREATE DATABASE [GENDEPO]');
    EXEC('ALTER DATABASE [GENDEPO] SET AUTO_CLOSE OFF');    -- surekli yazim: kapanmasin
    EXEC('ALTER DATABASE [GENDEPO] SET RECOVERY SIMPLE');   -- log DB'si: tran-log sismesin
END

-- 2) Eski GENDEPO.dbo.ISLEMLOG TABLOSU (artik view olacak)
EXEC('USE GENDEPO; IF OBJECT_ID(''dbo.ISLEMLOG'',''U'') IS NOT NULL DROP TABLE dbo.ISLEMLOG;');

-- 3) Icinde bulunulan yil tablosu LOG<yyyy> (yoksa). DDL = ULog.LogYilTablosu ile ayni.
DECLARE @yil varchar(4) = CAST(YEAR(GETDATE()) AS varchar(4));
EXEC('USE GENDEPO;
IF OBJECT_ID(''dbo.LOG' + @yil + ''',''U'') IS NULL
BEGIN
CREATE TABLE dbo.LOG' + @yil + '(
 ID bigint IDENTITY(1,1) NOT NULL,
 TARIH datetime2(3) NOT NULL CONSTRAINT DF_LOG' + @yil + '_TARIH DEFAULT(SYSDATETIME()),
 IP varchar(45) NULL, ISTASYON varchar(64) NULL, KULLANICIID int NULL,
 SUBEID smallint NULL, ISLEMTIPI tinyint NOT NULL,
 USTTABLOID int NULL, USTKAYITID bigint NULL,
 TABLOID int NULL, KAYITID bigint NULL, BILGI varbinary(max) NULL,
 CONSTRAINT PK_LOG' + @yil + ' PRIMARY KEY CLUSTERED (ID));
CREATE INDEX IX_LOG' + @yil + '_UST ON dbo.LOG' + @yil + '(USTTABLOID,USTKAYITID);
CREATE INDEX IX_LOG' + @yil + '_KAYIT ON dbo.LOG' + @yil + '(TABLOID,KAYITID);
CREATE INDEX IX_LOG' + @yil + '_TARIH ON dbo.LOG' + @yil + '(TARIH);
END');

-- 4) ISLEMLOG view = tum LOG<yyyy> UNION ALL (GENDEPO). CREATE VIEW batch'te tek
--    statement olmali -> USE GENDEPO'lu dis EXEC + ic EXEC ile.
EXEC('USE GENDEPO;
DECLARE @u nvarchar(max)='''';
SELECT @u=@u+CASE WHEN @u='''' THEN '''' ELSE '' UNION ALL '' END+
 ''SELECT ID,TARIH,IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,USTTABLOID,USTKAYITID,TABLOID,KAYITID,BILGI FROM dbo.''+name
FROM sys.tables WHERE name LIKE ''LOG[0-9][0-9][0-9][0-9]'' ORDER BY name;
IF @u<>'''' EXEC(''CREATE OR ALTER VIEW dbo.ISLEMLOG AS ''+@u);');

-- 5) Ana DB synonym (view'e cozer)
IF NOT EXISTS(SELECT 1 FROM sys.synonyms WHERE name='ISLEMLOG')
    CREATE SYNONYM dbo.ISLEMLOG FOR GENDEPO.dbo.ISLEMLOG;

-- Kontrol
SELECT SYNONYM=name, HEDEF=base_object_name FROM sys.synonyms WHERE name='ISLEMLOG';
SELECT YIL_TABLO=name FROM GENDEPO.sys.tables
WHERE name LIKE 'LOG[0-9][0-9][0-9][0-9]' ORDER BY name;
SELECT VIEW_VAR=CASE WHEN OBJECT_ID('GENDEPO.dbo.ISLEMLOG') IS NOT NULL THEN 'VAR' ELSE 'YOK' END;
