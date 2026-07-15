-- ============================================================
-- LOGCOZUM: log alan degerlerini (ID) anlasilir ada cevirme haritasi.
--   UInfo, JSON'daki bir alani gosterirken bu tabloya bakar:
--     SELECT <ADKOLON> FROM <KAYNAKTABLO> WHERE <IDKOLON> = <logdaki_deger> [AND <FILTRE>]
--   Eslesme yoksa deger (ID) aynen gosterilir. Yeni modul/alan = yeni SATIR (kod degismez).
--   Tablo GENDEPO'da (ISLEMLOG/LOGREFERANS ile birlikte); ana DB'de synonym ile erisilir.
--   Cozum SORGULARI ana DB tablolarinda (GENINI, REHBER...) calisir (UInfo ana baglanti).
-- ============================================================
IF DB_ID('GENDEPO') IS NULL EXEC('CREATE DATABASE [GENDEPO] COLLATE SQL_Latin1_General_CP1254_CI_AS');

EXEC('USE GENDEPO;
IF OBJECT_ID(''dbo.LOGCOZUM'',''U'') IS NULL
CREATE TABLE dbo.LOGCOZUM(
  ID          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LOGCOZUM PRIMARY KEY,
  TABLOID     int           NULL,       -- log tablosu (71 cari, 88 stok...). NULL = tum tablolar (genel)
  ALAN        nvarchar(64)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,   -- JSON alan adi (SEKTOR, KATEGORI, EKLEYEN...)
  KAYNAKTABLO nvarchar(128) COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,   -- lookup tablosu (GENINI, REHBER...)
  IDKOLON     nvarchar(64)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,   -- degerin arandigi kolon (BOLUM, NO, ID...)
  ADKOLON     nvarchar(64)  COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,   -- gosterilecek ad kolonu (ANAHTAR, FIRMA, AD...)
  FILTRE      nvarchar(400) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,   -- ek WHERE (opsiyonel; ör. BOLUM=-2204)
  AKTIF       bit           NOT NULL CONSTRAINT DF_LOGCOZUM_AKTIF DEFAULT(1)
);
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=''IX_LOGCOZUM_ALAN'' AND object_id=OBJECT_ID(''dbo.LOGCOZUM''))
  CREATE INDEX IX_LOGCOZUM_ALAN ON dbo.LOGCOZUM(ALAN, TABLOID);
');

-- Ana DB synonym: UInfo "LOGCOZUM" uzerinden okur (GENDEPO'ya isaret eder).
IF OBJECT_ID('dbo.LOGCOZUM','SN') IS NOT NULL DROP SYNONYM dbo.LOGCOZUM;
IF OBJECT_ID('dbo.LOGCOZUM','U') IS NOT NULL DROP TABLE dbo.LOGCOZUM;   -- eski ana-DB tablosu (varsa) kalksin
CREATE SYNONYM dbo.LOGCOZUM FOR GENDEPO.dbo.LOGCOZUM;

SELECT SATIR = COUNT(*) FROM dbo.LOGCOZUM;
