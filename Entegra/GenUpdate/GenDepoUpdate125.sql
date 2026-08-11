-- ============================================================
-- GenDepoUpdate125.sql
-- SNAPSHOT (geri-alinabilir oturum) tablosuna iki kolon:
--   SILSIRA smallint  : SILME sirasi. Bos ise SIRA kullanilir.
--   TAMSIL  bit       : 1 = geri yuklemede filtredeki TUM satirlar silinip
--                       snapshot'takiler yeniden EKLENIR (satir-eslemeli
--                       UPDATE yapilmaz).
--
-- NEDEN (izleme ornegi, 10.08.2026):
--   Stok izlemede iade/geri-yukleme TETIKLE yapiliyor:
--     TG_StokIzlemeDurumSil  -> STOKIZLEME'den SILINCE calisir ve stogu
--                               STOKIZLEMEDEPO satirlarindan okuyup iade eder.
--     STOKIZLEMEDEPO'nun DELETE tetigi YOK (yalniz INSERT/UPDATE var).
--   Yani depo satirlari, izlem satirindan ONCE silinirse stok iadesi KAYBOLUR.
--   Snapshot motoru ise silmeyi SIRA DESC (cocuk once) yapiyordu -> iptalden
--   sonra STOKDURUMIZLEME eksik kaliyordu (lot 43653: 17 -> 7).
--   Cozum: bu cift icin SILME sirasi ile GERI-EKLEME sirasi AYRI olmali:
--     STOKIZLEME     : Sira=3, SilSira=4  (once silinir, sonra eklenir)
--     STOKIZLEMEDEPO : Sira=4, SilSira=3  (sonra silinir, en son eklenir)
--   Ayrica ikisi de TAMSIL=1: satirlar UPDATE ile degil, sil+ekle ile geri
--   gelir; boylece tetikler dogru sirayla calisip stok tam iade edilir.
--
-- Kolonlar OPSIYONEL: eski oturumlarda NULL kalir, motor eski davranisi surdurur.
-- ============================================================
SET NOCOUNT ON;

-- Depo adi calisirken cozulur (GenDepoUpdate2 ile ayni kural: GENINI BOLUM=-24120).
DECLARE @depo sysname = NULLIF((SELECT ANAHTAR FROM dbo.GENINI WHERE BOLUM = -24120 AND DIL = 0), '');
IF @depo IS NULL OR @depo = '' SET @depo = 'GENDEPO';
DECLARE @sql nvarchar(max);

IF DB_ID(@depo) IS NULL
BEGIN
    PRINT 'Depo veritabani yok: ' + @depo;
    RETURN;
END;

IF OBJECT_ID(QUOTENAME(@depo) + '.dbo.SNAPSHOT') IS NULL
BEGIN
    PRINT 'SNAPSHOT tablosu yok (GenDepoUpdate2 uygulanmamis).';
    RETURN;
END;

SET @sql = N'USE ' + QUOTENAME(@depo) + N';
IF COL_LENGTH(''dbo.SNAPSHOT'', ''SILSIRA'') IS NULL
    ALTER TABLE dbo.SNAPSHOT ADD SILSIRA smallint NULL;
IF COL_LENGTH(''dbo.SNAPSHOT'', ''TAMSIL'') IS NULL
    ALTER TABLE dbo.SNAPSHOT ADD TAMSIL bit NULL;';
EXEC(@sql);

PRINT 'SNAPSHOT.SILSIRA / SNAPSHOT.TAMSIL hazir.';
