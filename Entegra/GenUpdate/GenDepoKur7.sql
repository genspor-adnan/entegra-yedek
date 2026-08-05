-- ============================================================
-- GenDepoKur7 : LOGCOZUM (log alan ID -> ad cevrim haritasi) + ana DB synonym
--   UInfo, JSON'daki bir alani gosterirken bu tabloya bakar:
--     SELECT <ADKOLON> FROM <KAYNAKTABLO> WHERE <IDKOLON>=<deger> [AND <FILTRE>]
--   Cozum SORGULARI ana DB tablolarinda (GENINI, REHBER...) calisir.
--   GenDepoKur1'den SONRA. Idempotent (tablo yoksa olusturur).
--   NOT: Cozum kurallari (satirlar) ayrica sql_logcozum_doldur.sql ile yuklenir.
-- ============================================================
-- ADLANDIRMA KURALI (05.08.2026): depo veritabani adi <ANA_DB>_GENDEPO olmak zorunda.
--   Ayni sunucuda birden fazla Gentegre veritabani bulunabildigi icin sabit 'GENDEPO'
--   adi ikinci kurulumda MEVCUT depoyu bulup ona baglaniyordu (yanlis depoya log/e-belge).
--   Bu yuzden depo adi artik ANA DB adindan turetilir; script ana DB'den calistirilmalidir.
DECLARE @Depo SYSNAME = DB_NAME() + N'_GENDEPO';
DECLARE @D    NVARCHAR(300) = QUOTENAME(@Depo);      -- [SDI_GENDEPO]
DECLARE @Dq   NVARCHAR(300) = QUOTENAME(@Depo, '''');  -- 'SDI_GENDEPO' (literal)

SET NOCOUNT ON;
IF DB_ID(@Depo) IS NULL EXEC('CREATE DATABASE ' + @D + ' COLLATE SQL_Latin1_General_CP1254_CI_AS');

IF OBJECT_ID(@Depo + '.dbo.LOGCOZUM','U') IS NULL
EXEC('USE ' + @D + ';
CREATE TABLE dbo.LOGCOZUM(
  ID          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LOGCOZUM PRIMARY KEY,
  TABLOID     int           NULL,
  ALAN        nvarchar(64)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
  KAYNAKTABLO nvarchar(128) COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
  IDKOLON     nvarchar(64)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
  ADKOLON     nvarchar(64)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
  FILTRE      nvarchar(400) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  AKTIF       bit           NOT NULL CONSTRAINT DF_LOGCOZUM_AKTIF DEFAULT(1)
);
CREATE INDEX IX_LOGCOZUM_ALAN ON dbo.LOGCOZUM(ALAN, TABLOID);
');

-- Ana DB synonym (eski ana-DB tablosu varsa kaldir)
IF OBJECT_ID('dbo.LOGCOZUM','U')  IS NOT NULL DROP TABLE dbo.LOGCOZUM;
IF OBJECT_ID('dbo.LOGCOZUM','SN') IS NULL
   EXEC('CREATE SYNONYM dbo.LOGCOZUM FOR ' + @D + '.dbo.LOGCOZUM');

SELECT LOGCOZUM = CASE WHEN OBJECT_ID(@Depo + '.dbo.LOGCOZUM','U') IS NOT NULL THEN 'VAR' ELSE 'YOK!' END,
       SYNONYM_DURUM = CASE WHEN OBJECT_ID('dbo.LOGCOZUM','SN') IS NOT NULL THEN 'VAR' ELSE 'YOK/TABLO' END;
