-- ============================================================
-- GenDepoKur6 : LOGREFERANS (kart ad/kod hizli arama) + ana DB synonym
--   (TABLOID, KAYITID) -> AD / KOD. Master log yazilirken UPSERT edilir; silinen
--   kayit da kalir (SILINDI=1). UInfo aramasi bunun uzerinden yapilir.
--   GenDepoKur1'den SONRA. Idempotent (tablo yoksa olusturur).
-- ============================================================
SET NOCOUNT ON;
IF DB_ID('GENDEPO') IS NULL EXEC('CREATE DATABASE [GENDEPO] COLLATE SQL_Latin1_General_CP1254_CI_AS');

IF OBJECT_ID('GENDEPO.dbo.LOGREFERANS','U') IS NULL
EXEC('USE GENDEPO;
CREATE TABLE dbo.LOGREFERANS(
  ID       bigint        IDENTITY(1,1) NOT NULL CONSTRAINT PK_LOGREFERANS PRIMARY KEY,
  TABLOID  int           NOT NULL,
  KAYITID  bigint        NOT NULL,
  AD       nvarchar(200) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  KOD      nvarchar(60)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  SILINDI  bit           NOT NULL CONSTRAINT DF_LOGREFERANS_SILINDI DEFAULT(0),
  SONISLEM datetime      NULL
);
CREATE INDEX IX_LOGREFERANS_KAYIT ON dbo.LOGREFERANS(TABLOID, KAYITID, ID);
CREATE INDEX IX_LOGREFERANS_AD    ON dbo.LOGREFERANS(AD);
CREATE INDEX IX_LOGREFERANS_KOD   ON dbo.LOGREFERANS(KOD);
');

-- Ana DB synonym (eski ana-DB tablosu varsa kaldir)
IF OBJECT_ID('dbo.LOGREFERANS','U')  IS NOT NULL DROP TABLE dbo.LOGREFERANS;
IF OBJECT_ID('dbo.LOGREFERANS','SN') IS NULL
   CREATE SYNONYM dbo.LOGREFERANS FOR GENDEPO.dbo.LOGREFERANS;

SELECT LOGREFERANS = CASE WHEN OBJECT_ID('GENDEPO.dbo.LOGREFERANS','U') IS NOT NULL THEN 'VAR' ELSE 'YOK!' END,
       SYNONYM_DURUM = CASE WHEN OBJECT_ID('dbo.LOGREFERANS','SN') IS NOT NULL THEN 'VAR' ELSE 'YOK/TABLO' END;
