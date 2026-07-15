-- ============================================================
-- GenDepoUpdate2 : GenDepoUpdate1 SONRASI artimli DB guncellemeleri.
-- BUNDAN SONRAKI tum DB update maddeleri BURAYA, bu desende eklenir.
--
-- CALISTIRMA  : ANA DB baglantisindan (GENTEGREDB / GENTEGREDB2 / GENTEGREDB3 ...).
-- IDEMPOTENT  : tekrar tekrar guvenle calisir (her madde kendi VAR-MI kontrolunu yapar).
-- TEK BATCH   : GO KULLANMA. @depo tum dosyada gecerli kalsin diye tek batch'tir.
--
-- >>> COK-INSTANCE KURALI <<<
--   Depo DB adi (GENDEPO / GENDEPO2 / GENDEPO3 ...) ASLA SABIT YAZILMAZ.
--   Ayni madde metni remote update servisinden TUM musterilere gider; her musterinin
--   deposu farkli olabilir. Bu yuzden depo adi asagidaki @depo ile CALISIRKEN cozulur:
--     1) ana DB'deki EBELGE synonym hedefi (uygulamanin da guvendigi kaynak)
--     2) yoksa ISLEMLOG synonym hedefi
--     3) yoksa GENINI opsiyonu (BOLUM=-24120, Ops_FaturaOpsiyon_DepoDBAdi)
--     4) yoksa 'GENDEPO' (eski tek-instance varsayilani)
--
--   * ANA DB nesneleri (TABLOLAR, LOGCOZUM synonym, AYARADI, GENINI ...) -> DOGRUDAN yaz.
--   * DEPO (GENDEPO*) DDL/DML -> DAIMA @depo uzerinden dinamik EXEC ile ('USE '+@depo).
--     (DDL synonym'i cozmez; bu yuzden gercek DB adi sart.)
-- ============================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ---- Depo DB adini GENINI'den al (ReadString ile AYNI kaynak: ANAHTAR, DIL=0) ----
--   NOT: depo adi ANAHTAR'da tutulur (DEGER=0'dir). Synonym'den okumaya gerek yok;
--   uygulama da depoyu buradan okur -> tek dogruluk kaynagi.
DECLARE @depo sysname = NULLIF((SELECT ANAHTAR FROM dbo.GENINI WHERE BOLUM = -24120 AND DIL = 0), '');
IF @depo IS NULL OR @depo = ''
  SET @depo = 'GENDEPO';

-- @depo YALNIZ depo maddeleri icin gerekli. Depo yoksa depo maddeleri atlanir; ANA DB
-- maddeleri yine calismali -> HARD dur YOK, sadece sev-10 bilgi (WITH NOWAIT).
DECLARE @depoVar bit = CASE WHEN DB_ID(@depo) IS NOT NULL THEN 1 ELSE 0 END;
IF @depoVar = 0
  RAISERROR('GenDepoUpdate2: depo DB (%s) yok -> depo maddeleri atlandi (ANA DB maddeleri calisti).', 10, 1, @depo) WITH NOWAIT;

DECLARE @sql nvarchar(max);

-- ============================================================
-- SABLON A - DEPO maddesi (kopyala-cogalt). @depo ile dinamik, idempotent.
--   Ic string'de tek tirnaklari '' seklinde ikile.
-- ------------------------------------------------------------
-- SET @sql = N'USE ' + QUOTENAME(@depo) + N';
-- IF COL_LENGTH(''dbo.EBELGE'',''YENIKOLON'') IS NULL
--   ALTER TABLE dbo.EBELGE ADD YENIKOLON int NULL;';
-- EXEC(@sql);
--
-- Yeni DEPO tablosu + ana DB synonym ornegi:
-- IF OBJECT_ID(QUOTENAME(@depo)+'.dbo.YENITABLO') IS NULL
--   EXEC('CREATE TABLE '+QUOTENAME(@depo)+'.dbo.YENITABLO (ID int IDENTITY PRIMARY KEY, AD nvarchar(100) NULL);');
-- IF OBJECT_ID('dbo.YENITABLO','SN') IS NULL AND OBJECT_ID('dbo.YENITABLO','U') IS NULL
--   EXEC('CREATE SYNONYM dbo.YENITABLO FOR '+QUOTENAME(@depo)+'.dbo.YENITABLO;');
-- ============================================================

-- ============================================================
-- SABLON B - ANA DB maddesi (dinamige gerek yok, dogrudan).
-- ------------------------------------------------------------
-- MERGE dbo.TABLOLAR AS h USING (VALUES (999,'YENITAB',N'Ad',N'Modul')) AS k(TABLOID,TABLOADI,GORUNUM,MODUL)
-- ON h.TABLOID=k.TABLOID
-- WHEN MATCHED THEN UPDATE SET TABLOADI=k.TABLOADI,GORUNUM=k.GORUNUM,MODUL=k.MODUL
-- WHEN NOT MATCHED THEN INSERT(TABLOID,TABLOADI,GORUNUM,MODUL) VALUES(k.TABLOID,k.TABLOADI,k.GORUNUM,k.MODUL);
-- ============================================================


-- ============================================================
-- >>> GERCEK GUNCELLEMELER BURADAN ASAGIYA, SIRAYLA EKLENIR <<<
-- (tarih + kisa aciklama ile; her madde idempotent olsun)
-- ============================================================

-- 2026-07-09: SNAPSHOT tablosu — GERI-ALINABILIR form/wizard oturumlari icin acilis
--   satir goruntuleri. Duzenleme acilisinda ilgili tablolarin satirlari buraya (tam
--   JSON) yazilir; Cancel'da geri yuklenir (delete + IDENTITY_INSERT), Finish'te silinir.
--   OTURUMID=oturum, SIRA=geri-yukleme sirasi (ust once), FILTRE=o oturumun satirlarini
--   secen kosul (subquery olabilir -> REHBER>REHBERILETISIM>REHBERBILGI gibi hiyerarsi).
--   KAYITID/SATIRJSON NULL = "kapsam satiri" (acilista bos tabloya eklenenleri silmek icin).
IF @depoVar = 1 AND OBJECT_ID(QUOTENAME(@depo)+'.dbo.SNAPSHOT') IS NULL
BEGIN
  SET @sql = N'USE '+QUOTENAME(@depo)+N';
CREATE TABLE dbo.SNAPSHOT(
  ID          bigint           IDENTITY(1,1) NOT NULL CONSTRAINT PK_SNAPSHOT PRIMARY KEY,
  OTURUMID    nvarchar(36)     COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
  ANATABLOADI nvarchar(128)    COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  ANAID       bigint           NULL,
  SIRA        smallint         NOT NULL,
  TABLOADI    nvarchar(128)    COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
  FILTRE      nvarchar(1000)   COLLATE SQL_Latin1_General_CP1254_CI_AS NOT NULL,
  KAYITID     bigint           NULL,
  SATIRJSON   nvarchar(max)    COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  TARIH       datetime2(0)     NOT NULL CONSTRAINT DF_SNAPSHOT_TARIH DEFAULT(SYSDATETIME())
);
CREATE INDEX IX_SNAPSHOT_OTURUM ON dbo.SNAPSHOT(OTURUMID, SIRA, ID);
CREATE INDEX IX_SNAPSHOT_ANA    ON dbo.SNAPSHOT(ANATABLOADI, ANAID);';
  EXEC(@sql);
END;

-- 2026-07-09: TABLOLAR'a "Sistem" kategorisi (TABLOID=900). Kayit-bagimsiz sistem/login
--   olaylari (ULog.LogSistemIslem -> e-fatura guncelle butonu vb.) UInfo GENEL log ekraninda
--   "Sistem" altinda gruplansin (yoksa COALESCE ile ham "900" gorunurdu). ANA DB (synonym).
MERGE dbo.TABLOLAR AS h
USING (VALUES (900, N'SISTEM', N'Sistem', N'Sistem')) AS k(TABLOID, TABLOADI, GORUNUM, MODUL)
ON h.TABLOID = k.TABLOID
WHEN MATCHED THEN UPDATE SET TABLOADI = k.TABLOADI, GORUNUM = k.GORUNUM, MODUL = k.MODUL
WHEN NOT MATCHED THEN INSERT (TABLOID, TABLOADI, GORUNUM, MODUL) VALUES (k.TABLOID, k.TABLOADI, k.GORUNUM, k.MODUL);
