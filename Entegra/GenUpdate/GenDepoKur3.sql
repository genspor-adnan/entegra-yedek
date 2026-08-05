-- ============================================================
-- GenDepoKur3 : EBELGEMESAJ tablosu (GENDEPO) + ana DB synonym
--   e-Belge islem/mesaj gecmisi (gonderim sonucu, hata, durum). FK -> EBELGE.
--   GenDepoKur2'den (EBELGE) SONRA. Idempotent.
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

IF OBJECT_ID(@Depo + '.dbo.EBELGEMESAJ','U') IS NULL
EXEC('USE ' + @D + ';
CREATE TABLE dbo.EBELGEMESAJ(
  ID                bigint IDENTITY(1,1) NOT NULL,
  EBELGEID          bigint NOT NULL,
  YON               tinyint NOT NULL,
  ISLEMTURU         tinyint NOT NULL,
  MESAJTIPI         tinyint NOT NULL CONSTRAINT DF_EBELGEMESAJ_MESAJTIPI DEFAULT(0),
  MESAJ             nvarchar(max) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  HTTPKODU          int NULL,
  SERVISKODU        nvarchar(100) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  HATAKODU          nvarchar(100) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  HATAMESAJI        nvarchar(max) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  EKLEYEN           int NULL,
  EKLEMETARIHI      datetime NOT NULL CONSTRAINT DF_EBELGEMESAJ_EKLEMETARIHI DEFAULT(GETDATE()),
  SENKRON_TURU      tinyint NULL,
  ONCEKI_DURUM_KODU nvarchar(100) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  YENI_DURUM_KODU   nvarchar(100) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  YANIT_JSON        nvarchar(max) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  CONSTRAINT PK_EBELGEMESAJ PRIMARY KEY CLUSTERED (ID)
);
CREATE INDEX IX_EBELGEHAREKET_EBELGEID ON dbo.EBELGEMESAJ(EBELGEID, EKLEMETARIHI DESC);
IF OBJECT_ID(''dbo.EBELGE'',''U'') IS NOT NULL AND OBJECT_ID(''dbo.FK_EBELGEHAREKET_EBELGE'') IS NULL
  ALTER TABLE dbo.EBELGEMESAJ WITH CHECK ADD CONSTRAINT FK_EBELGEHAREKET_EBELGE
    FOREIGN KEY(EBELGEID) REFERENCES dbo.EBELGE(ID);
');

IF OBJECT_ID('dbo.EBELGEMESAJ','U') IS NULL AND OBJECT_ID('dbo.EBELGEMESAJ','SN') IS NULL
   EXEC('CREATE SYNONYM dbo.EBELGEMESAJ FOR ' + @D + '.dbo.EBELGEMESAJ');

SELECT EBELGEMESAJ = CASE WHEN OBJECT_ID(@Depo + '.dbo.EBELGEMESAJ','U') IS NOT NULL THEN 'VAR' ELSE 'YOK!' END,
       SYNONYM_DURUM = CASE WHEN OBJECT_ID('dbo.EBELGEMESAJ','SN') IS NOT NULL THEN 'VAR' ELSE 'YOK/TABLO' END;
