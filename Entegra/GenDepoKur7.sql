-- ============================================================
-- GenDepoKur7 : LOGCOZUM (log alan ID -> ad cevrim haritasi) + ana DB synonym
--   UInfo, JSON'daki bir alani gosterirken bu tabloya bakar:
--     SELECT <ADKOLON> FROM <KAYNAKTABLO> WHERE <IDKOLON>=<deger> [AND <FILTRE>]
--   Cozum SORGULARI ana DB tablolarinda (GENINI, REHBER...) calisir.
--   GenDepoKur1'den SONRA. Idempotent (tablo yoksa olusturur).
--   NOT: Cozum kurallari (satirlar) ayrica sql_logcozum_doldur.sql ile yuklenir.
-- ============================================================
SET NOCOUNT ON;
IF DB_ID('GENDEPO') IS NULL EXEC('CREATE DATABASE [GENDEPO] COLLATE SQL_Latin1_General_CP1254_CI_AS');

IF OBJECT_ID('GENDEPO.dbo.LOGCOZUM','U') IS NULL
EXEC('USE GENDEPO;
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
   CREATE SYNONYM dbo.LOGCOZUM FOR GENDEPO.dbo.LOGCOZUM;

SELECT LOGCOZUM = CASE WHEN OBJECT_ID('GENDEPO.dbo.LOGCOZUM','U') IS NOT NULL THEN 'VAR' ELSE 'YOK!' END,
       SYNONYM_DURUM = CASE WHEN OBJECT_ID('dbo.LOGCOZUM','SN') IS NOT NULL THEN 'VAR' ELSE 'YOK/TABLO' END;
