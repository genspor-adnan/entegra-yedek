-- ============================================================
-- LOGCOZUM: log alan degerlerini (ID) anlasilir ada cevirme haritasi.
--   UInfo, JSON'daki bir alani gosterirken bu tabloya bakar:
--     SELECT <ADKOLON> FROM <KAYNAKTABLO> WHERE <IDKOLON> = <logdaki_deger> [AND <FILTRE>]
--   Eslesme yoksa deger (ID) aynen gosterilir. Yeni modul/alan = yeni SATIR (kod degismez).
--   Ana DB'de (lookup tablolari burada). Idempotent.
-- ============================================================
IF OBJECT_ID('dbo.LOGCOZUM','U') IS NULL
CREATE TABLE dbo.LOGCOZUM(
  ID          int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LOGCOZUM PRIMARY KEY,
  TABLOID     int           NULL,       -- log tablosu (71 cari, 88 stok...). NULL = tum tablolar (genel)
  ALAN        nvarchar(64)  NOT NULL,   -- JSON alan adi (SEKTOR, KATEGORI, EKLEYEN...)
  KAYNAKTABLO nvarchar(128) NOT NULL,   -- lookup tablosu (GENINI, REHBERVARSAYILAN, REHBER...)
  IDKOLON     nvarchar(64)  NOT NULL,   -- degerin arandigi kolon (BOLUM, NO, ID...)
  ADKOLON     nvarchar(64)  NOT NULL,   -- gosterilecek ad kolonu (ACIKLAMA, TANIM, FIRMA...)
  FILTRE      nvarchar(400) NULL,       -- ek WHERE (opsiyonel; ör. DIL=1)
  AKTIF       bit           NOT NULL CONSTRAINT DF_LOGCOZUM_AKTIF DEFAULT(1)
);
-- Ayni (TABLOID, ALAN) icin hizli arama
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_LOGCOZUM_ALAN' AND object_id=OBJECT_ID('dbo.LOGCOZUM'))
  CREATE INDEX IX_LOGCOZUM_ALAN ON dbo.LOGCOZUM(ALAN, TABLOID);

SELECT SATIR = COUNT(*) FROM dbo.LOGCOZUM;
