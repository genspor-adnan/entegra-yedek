-- ============================================================
-- GenDepoKur2 : EBELGE tablosu (GENDEPO) + ana DB synonym
--   e-Belge (e-Fatura/e-Arsiv/e-Irsaliye) ana kaydi. GenDepoKur1'den SONRA.
--   Idempotent: tablo/synonym yoksa olusturur.
-- ============================================================
-- FILTRELI/UNIQUE INDEKS var: bu SET secenekleri ZORUNLU. sqlcmd varsayilani
-- QUOTED_IDENTIFIER OFF'tur (-I bayragi verilmezse) -> 'CREATE INDEX failed because
-- the following SET options have incorrect settings' hatasi ve KURULUM YARIM kalir.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
-- ADLANDIRMA KURALI (05.08.2026): depo veritabani adi <ANA_DB>_GENDEPO olmak zorunda.
--   Ayni sunucuda birden fazla Gentegre veritabani bulunabildigi icin sabit 'GENDEPO'
--   adi ikinci kurulumda MEVCUT depoyu bulup ona baglaniyordu (yanlis depoya log/e-belge).
--   Bu yuzden depo adi artik ANA DB adindan turetilir; script ana DB'den calistirilmalidir.
DECLARE @Depo SYSNAME = DB_NAME() + N'_GENDEPO';
DECLARE @D    NVARCHAR(300) = QUOTENAME(@Depo);      -- [SDI_GENDEPO]
DECLARE @Dq   NVARCHAR(300) = QUOTENAME(@Depo, '''');  -- 'SDI_GENDEPO' (literal)

SET NOCOUNT ON;
IF DB_ID(@Depo) IS NULL EXEC('CREATE DATABASE ' + @D + ' COLLATE SQL_Latin1_General_CP1254_CI_AS');

IF OBJECT_ID(@Depo + '.dbo.EBELGE','U') IS NULL
EXEC('USE ' + @D + ';
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
   EXEC('CREATE SYNONYM dbo.EBELGE FOR ' + @D + '.dbo.EBELGE');

SELECT EBELGE = CASE WHEN OBJECT_ID(@Depo + '.dbo.EBELGE','U') IS NOT NULL THEN 'VAR' ELSE 'YOK!' END,
       SYNONYM_DURUM = CASE WHEN OBJECT_ID('dbo.EBELGE','SN') IS NOT NULL THEN 'VAR'
                      WHEN OBJECT_ID('dbo.EBELGE','U')  IS NOT NULL THEN 'TABLO' ELSE 'YOK!' END;
