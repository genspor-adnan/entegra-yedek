-- ============================================================
-- LOGREFERANS: kart (master) ad/kod referansi - HIZLI arama (GENDEPO).
--   (TABLOID, KAYITID) -> AD / KOD. Master log yazilirken UPSERT edilir.
--   Silinen kayit da kalir (SILINDI=1) -> silinmis karti ADINDAN bulmak icin.
-- Ana DB'de LOGREFERANS synonym'i (UInfo bunun uzerinden okur; ISLEMLOG gibi).
-- Idempotent; EXEC tabanli (GO yok, ps1/SqlClient uyumlu).
-- ============================================================
IF DB_ID('GENDEPO') IS NULL EXEC('CREATE DATABASE [GENDEPO]');

-- NOT: eski tablo DROP edilip yeniden kurulur.
-- Ad/kod DEGISINCE yeni satir eklenir (eski isim korunur) -> kayit basina COK satir.
EXEC('USE GENDEPO;
IF OBJECT_ID(''dbo.LOGREFERANS'',''U'') IS NOT NULL DROP TABLE dbo.LOGREFERANS;
CREATE TABLE dbo.LOGREFERANS(
  ID       bigint        IDENTITY(1,1) NOT NULL CONSTRAINT PK_LOGREFERANS PRIMARY KEY,
  TABLOID  int           NOT NULL,   -- modul/tablo (71 cari, 88 stok, 33 gorev...)
  KAYITID  bigint        NOT NULL,   -- kaydin ID''si
  AD       nvarchar(200) NULL,       -- gorunen ad (FIRMA / stok adi) - aranan alan
  KOD      nvarchar(60)  NULL,       -- kod (cari/stok kod)
  SILINDI  bit           NOT NULL CONSTRAINT DF_LOGREFERANS_SILINDI DEFAULT(0),
  SONISLEM datetime      NULL        -- bu satirin log zamani
);
CREATE INDEX IX_LOGREFERANS_KAYIT ON dbo.LOGREFERANS(TABLOID, KAYITID, ID);  -- son satir lookup
CREATE INDEX IX_LOGREFERANS_AD    ON dbo.LOGREFERANS(AD);
CREATE INDEX IX_LOGREFERANS_KOD   ON dbo.LOGREFERANS(KOD);
');

-- Ana DB synonym: UInfo "LOGREFERANS" uzerinden okur (GENDEPO'ya isaret eder).
IF OBJECT_ID('dbo.LOGREFERANS','SN') IS NOT NULL DROP SYNONYM dbo.LOGREFERANS;
CREATE SYNONYM dbo.LOGREFERANS FOR GENDEPO.dbo.LOGREFERANS;

SELECT SATIR = COUNT(*) FROM dbo.LOGREFERANS;
