-- ============================================================
-- Update_SQL_170.sql   (MSSQL)
-- E-BELGE SERI KURALLARI: kaymis KULLANICIID alanini onar (MSSQL)
--
-- SORUN
--   Seri kurali GENINI'de tek metin olarak tutulur:
--       ANAHTAR = 'SERI,SENARYO,KULLANICIID[,AKTIF]'      (alanlar SOLDAN)
--       BOLUM   = -24130 e-Fatura | -24131 e-Arsiv | -24133 e-Irsaliye,  DIL = -1
--   4. alan (AKTIF) sonradan eklendi. Eski okuma kodu MSSQL'de parsename()
--   kullaniyordu ve parsename SAGDAN sayar:
--       3 alanli (eski): parsename(..,2)=SENARYO     parsename(..,1)=KULLANICIID  (dogru)
--       4 alanli (yeni): parsename(..,2)=KULLANICIID parsename(..,1)=AKTIF        (KAYIK)
--   Opsiyon ekrani bu kaymis degerleri okuyup geri kaydedince AKTIF bayragi (1)
--   KULLANICIID alanina yaziliyordu. Sonuc: kural var olmayan/yanlis bir kullaniciya
--   bagli gorunuyor, fatura keserken hicbir seri eslesmiyor ve
--   "Bu belge turu icin gecerli ilk seri tanimi yok" hatasi aliniyordu.
--
-- KOD TARAFI
--   Ayristirma artik SQL'de degil Pascal'da, tek yerde yapiliyor (UEBelgeSeri.pas).
--   Bu script yalnizca ZATEN BOZULMUS veriyi onarir.
--
-- MUSTERIDE CALISTIRMA NOTLARI
--   * Idempotent: tekrar tekrar calistirilabilir, ikinci calistirmada is yapmaz.
--   * Once YEDEK alinir (dbo.GENINI_SERI_YEDEK, her calisma damgali - ustune yazmaz).
--   * SADECE ISPATLANABILIR SEKILDE BOZUK satirlar onarilir:
--       - kayit 4 alanli
--       - son alan 0/1 (gercek AKTIF bayragi)
--       - 3. alan (KULLANICIID) > 0
--       - o ID'de TANIMLI KULLANICI YOK  -> kural hicbir kullaniciya uyamaz, olu kural
--     Gercek bir kullaniciya bagli kurallar DEGISTIRILMEZ; yalnizca raporlanir.
--   * @SadeceRapor = 1 yapilirsa hicbir yazma islemi yapilmaz (kuru calisma).
--   * KULLANICI tablosu yoksa otomatik onarim atlanir, yalnizca rapor uretilir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

DECLARE @SadeceRapor BIT = 0;          -- 1 = kuru calisma (hicbir sey yazilmaz)
DECLARE @Calisma DATETIME = GETDATE();
DECLARE @KullaniciTablosuVar BIT =
        CASE WHEN OBJECT_ID('dbo.KULLANICI', 'U') IS NOT NULL THEN 1 ELSE 0 END;

IF OBJECT_ID('dbo.GENINI', 'U') IS NULL
BEGIN
    PRINT 'Update_SQL_170: GENINI tablosu yok, atlandi.';
    RETURN;
END;

-- ------------------------------------------------------------
-- 1) Ilgili kayitlari alanlarina ayir
-- ------------------------------------------------------------
IF OBJECT_ID('tempdb..#Kural') IS NOT NULL DROP TABLE #Kural;

WITH H AS (
    SELECT BOLUM, DEGER, DIL, SIRA, ANAHTAR,
           P1   = LEFT(ANAHTAR, CHARINDEX(',', ANAHTAR + ',') - 1),
           K1   = SUBSTRING(ANAHTAR, CHARINDEX(',', ANAHTAR + ',') + 1, 4000),
           ADET = LEN(ANAHTAR) - LEN(REPLACE(ANAHTAR, ',', '')) + 1
    FROM dbo.GENINI
    WHERE BOLUM IN (-24130, -24131, -24133)
      AND DIL = -1
      AND ANAHTAR IS NOT NULL
), H2 AS (
    SELECT H.*,
           P2 = LEFT(K1, CHARINDEX(',', K1 + ',') - 1),
           K2 = SUBSTRING(K1, CHARINDEX(',', K1 + ',') + 1, 4000)
    FROM H
), H3 AS (
    SELECT H2.*,
           P3 = LEFT(K2, CHARINDEX(',', K2 + ',') - 1),
           K3 = SUBSTRING(K2, CHARINDEX(',', K2 + ',') + 1, 4000)
    FROM H2
)
SELECT BOLUM, DEGER, DIL, SIRA, ANAHTAR, ADET,
       SERI        = P1,
       SENARYO     = P2,
       KULLANICIID = P3,
       AKTIF       = LEFT(K3, CHARINDEX(',', K3 + ',') - 1)
INTO #Kural
FROM H3;

-- ------------------------------------------------------------
-- 2) Onarilacak satirlar (ispatlanabilir sekilde bozuk)
-- ------------------------------------------------------------
IF OBJECT_ID('tempdb..#Bozuk') IS NOT NULL DROP TABLE #Bozuk;

SELECT K.*
INTO #Bozuk
FROM #Kural K
WHERE K.ADET >= 4
  AND K.AKTIF IN ('0', '1')                      -- son alan gercek AKTIF bayragi
  AND K.KULLANICIID NOT LIKE '%[^0-9]%'          -- sayisal
  AND K.KULLANICIID <> ''
  AND TRY_CONVERT(INT, K.KULLANICIID) > 0
  AND @KullaniciTablosuVar = 1
  AND NOT EXISTS (SELECT 1 FROM dbo.KULLANICI U
                  WHERE U.REHBERID = TRY_CONVERT(INT, K.KULLANICIID));

-- ------------------------------------------------------------
-- 3) Rapor
-- ------------------------------------------------------------
SELECT DURUM = 'ONARILACAK (tanimli kullanici yok)',
       BOLUM, SIRA, ANAHTAR, SERI, SENARYO, KULLANICIID, AKTIF
FROM #Bozuk
ORDER BY BOLUM, SIRA;

SELECT DURUM = 'GOZDEN GECIR (gercek kullaniciya bagli - DOKUNULMADI)',
       BOLUM, SIRA, ANAHTAR, SERI, SENARYO, KULLANICIID, AKTIF
FROM #Kural K
WHERE K.ADET >= 4
  AND K.KULLANICIID NOT LIKE '%[^0-9]%'
  AND TRY_CONVERT(INT, K.KULLANICIID) > 0
  AND NOT EXISTS (SELECT 1 FROM #Bozuk B
                  WHERE B.BOLUM = K.BOLUM AND B.ANAHTAR = K.ANAHTAR AND B.DEGER = K.DEGER)
ORDER BY BOLUM, SIRA;

IF NOT EXISTS (SELECT 1 FROM #Bozuk)
BEGIN
    PRINT 'Update_SQL_170: onarilacak kayit yok.';
    RETURN;
END;

IF @SadeceRapor = 1
BEGIN
    PRINT 'Update_SQL_170: @SadeceRapor = 1, yazma yapilmadi.';
    RETURN;
END;

-- ------------------------------------------------------------
-- 4) Yedek + onarim (tek transaction)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.GENINI_SERI_YEDEK', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GENINI_SERI_YEDEK (
        YEDEKTARIH  DATETIME       NOT NULL,
        KAYNAK      NVARCHAR(40)   NOT NULL,
        BOLUM       INT            NULL,
        DEGER       INT            NULL,
        DIL         INT            NULL,
        SIRA        INT            NULL,
        ANAHTAR     NVARCHAR(255)  NULL
    );
END;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.GENINI_SERI_YEDEK (YEDEKTARIH, KAYNAK, BOLUM, DEGER, DIL, SIRA, ANAHTAR)
    SELECT @Calisma, 'Update_SQL_170', BOLUM, DEGER, DIL, SIRA, ANAHTAR
    FROM #Bozuk;

    UPDATE G
    SET G.ANAHTAR = B.SERI + ',' + B.SENARYO + ',0,' + B.AKTIF
    FROM dbo.GENINI G
    INNER JOIN #Bozuk B
            ON B.BOLUM = G.BOLUM
           AND B.DEGER = G.DEGER
           AND B.DIL   = G.DIL
           AND B.ANAHTAR = G.ANAHTAR;

    COMMIT TRANSACTION;
    PRINT 'Update_SQL_170: onarim tamamlandi. Yedek -> dbo.GENINI_SERI_YEDEK';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Update_SQL_170 HATA: ' + ERROR_MESSAGE();
    THROW;
END CATCH;

-- ------------------------------------------------------------
-- 5) Son durum
-- ------------------------------------------------------------
SELECT DURUM = 'SON DURUM', BOLUM, SIRA, ANAHTAR
FROM dbo.GENINI
WHERE BOLUM IN (-24130, -24131, -24133) AND DIL = -1
ORDER BY BOLUM, SIRA, ANAHTAR;
GO
