-- ============================================================
-- GenDepoKur2 : EBELGE tablosu (GENDEPO) + ana DB synonym
--   e-Belge (e-Fatura/e-Arsiv/e-Irsaliye) ana kaydi. GenDepoKur1'den SONRA.
--   Idempotent: tablo/synonym yoksa olusturur.
-- ============================================================
SET NOCOUNT ON;
IF DB_ID('GENDEPO') IS NULL EXEC('CREATE DATABASE [GENDEPO] COLLATE SQL_Latin1_General_CP1254_CI_AS');

IF OBJECT_ID('GENDEPO.dbo.EBELGE','U') IS NULL
EXEC('USE GENDEPO;
CREATE TABLE dbo.EBELGE(
  ID                 bigint IDENTITY(1,1) NOT NULL,
  FATBASLIKID        int NULL,
  REHBERID           int NULL,
  BELGETURU          tinyint NOT NULL,
  YON                tinyint NOT NULL,
  UUID               varchar(50)    COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  BELGENO            nvarchar(50)   COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  GONDERICIALIAS     nvarchar(500)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  ALICIALIAS         nvarchar(500)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  DURUM              tinyint NOT NULL CONSTRAINT DF_EBELGE_DURUM DEFAULT(0),
  API_JSON           nvarchar(max)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  UBL_XML            nvarchar(max)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  EKLEYEN            int NULL,
  DEGISTIREN         int NULL,
  EKLEMETARIHI       datetime NOT NULL CONSTRAINT DF_EBELGE_EKLEMETARIHI DEFAULT(GETDATE()),
  DEGISTIRMETARIHI   datetime NULL,
  SERVIS_DURUM_KODU  nvarchar(100)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  SERVIS_DURUM_ADI   nvarchar(250)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  GIB_DURUM_KODU     nvarchar(50)   COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  GIB_DURUM_ACIKLAMA nvarchar(500)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  YANIT_DURUM_KODU   nvarchar(100)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  YANIT_DURUM_ADI    nvarchar(250)  COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  UBL_XML_ZIP        varbinary(max) NULL,
  CONSTRAINT PK_EBELGE PRIMARY KEY CLUSTERED (ID)
);
CREATE UNIQUE INDEX UX_EBELGE_UUID   ON dbo.EBELGE(UUID) WHERE UUID IS NOT NULL;
CREATE INDEX IX_EBELGE_FATBASLIKID   ON dbo.EBELGE(FATBASLIKID);
CREATE INDEX IX_EBELGE_LISTE         ON dbo.EBELGE(YON,BELGETURU,DURUM);
');

-- Ana DB synonym (yeni musteri: gercek tablo yok -> dogrudan synonym)
IF OBJECT_ID('dbo.EBELGE','U') IS NULL AND OBJECT_ID('dbo.EBELGE','SN') IS NULL
   CREATE SYNONYM dbo.EBELGE FOR GENDEPO.dbo.EBELGE;

SELECT EBELGE = CASE WHEN OBJECT_ID('GENDEPO.dbo.EBELGE','U') IS NOT NULL THEN 'VAR' ELSE 'YOK!' END,
       SYNONYM_DURUM = CASE WHEN OBJECT_ID('dbo.EBELGE','SN') IS NOT NULL THEN 'VAR'
                      WHEN OBJECT_ID('dbo.EBELGE','U')  IS NOT NULL THEN 'TABLO' ELSE 'YOK!' END;
