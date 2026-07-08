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

-- ---- Depo DB adini CALISIRKEN coz ----
DECLARE @depo sysname =
  PARSENAME((SELECT base_object_name FROM sys.synonyms WHERE name = 'EBELGE'), 3);
IF @depo IS NULL OR @depo = ''
  SET @depo = PARSENAME((SELECT base_object_name FROM sys.synonyms WHERE name = 'ISLEMLOG'), 3);
IF @depo IS NULL OR @depo = ''
  SET @depo = NULLIF((SELECT DEGER FROM dbo.GENINI WHERE BOLUM = -24120), '');
IF @depo IS NULL OR @depo = ''
  SET @depo = 'GENDEPO';

-- Guvenlik agi: cozulen depo gercekten var mi? Yoksa YANLIS DB'ye yazmaktansa
-- gurultulu dur (update log'una TUR=3 hata olarak duser; operator gorur, duzeltir).
IF DB_ID(@depo) IS NULL
  RAISERROR('GenDepoUpdate2: cozulen depo DB (%s) bulunamadi. Synonym / GENINI(-24120) kontrol edin.', 16, 1, @depo);

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
