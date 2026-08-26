-- ============================================================
-- Update_SQL_171.sql   (MSSQL)
-- ALIS IRSALIYESI (TUR=10): KOCANNO=0 kalmis belgeleri kendi kocanina bagla
--
-- SORUN
--   Kocan ayarlari oturum acilisinda yuklenirken (TTablo.KocanAyarlariInit) TUR=10
--   (alis irsaliyesi) ATLANMISTI -> kocannumaralari.AlisIrsaliye = 0 kaliyordu.
--   Belge kaydedilirken FATBASLIK.KOCANNO'ya bu 0 yaziliyordu.
--   sp_BelgeNoGetir ise siradaki numarayi
--       MAX(FATURANO)+1 WHERE TUR=@UstTur AND KOCANNO=<KOCANAYARLARI'ndaki gercek kocan>
--   ile ariyor. Belgeler KOCANNO=0 ile yazildigi icin bu filtre HICBIR kaydi bulamiyor
--   ve her yeni belgede KOCANAYARLARI.BASLANGICNO donuyordu -> numara ARTMIYOR.
--
-- COZUM
--   Kod tarafi duzeltildi (KocanAyarlariInit'e TUR=10/166 eklendi; BelgeNoIslemleri
--   artik SP'nin cozdugu kocan numarasini yaziyor). Bu betik GECMIS kayitlari onarir:
--   uygulamanin KENDI urettigi (FATURANO sayisal) alis irsaliyelerini dogru kocana baglar,
--   boylece numara zinciri kaldigi yerden devam eder.
--
-- GUVENLIK
--   - Yalnizca TUR=10, KOCANNO=0/NULL ve FATURANO SAYISAL olan satirlar.
--     (Tedarikcinin verdigi alfanumerik/bos belge numaralari ELLENMEZ.)
--   - Yalnizca ilgili subede TEK kocan tanimliysa (birden fazlaysa hangisi oldugu
--     belirsizdir -> dokunulmaz).
--   - Yalnizca kocanin BASLANGICTARIHI'nden sonraki belgeler.
--   - Degisen satirlarin eski degeri YEDEK tabloya yazilir.
--   - Idempotent: ikinci calistirmada eslesen satir kalmaz.
-- ============================================================

SET NOCOUNT ON;
-- FATBASLIK'ta filtreli index / computed kolon var: UPDATE icin sart.
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

-- 1) Yedek tablo (bir kez olusur)
IF OBJECT_ID('dbo.YEDEK_FATBASLIK_KOCANNO_171', 'U') IS NULL
    CREATE TABLE dbo.YEDEK_FATBASLIK_KOCANNO_171
    (
        ID            INT           NOT NULL PRIMARY KEY,
        TUR           INT           NULL,
        SUBEID        INT           NULL,
        FATURANO      NVARCHAR(50)  NULL,
        ESKI_KOCANNO  INT           NULL,
        YENI_KOCANNO  INT           NULL,
        TARIH         DATETIME      NOT NULL DEFAULT (GETDATE())
    );

-- 2) Onarilacak satirlar: tur+sube basina TEK kocan sarti
;WITH TekKocan AS
(
    SELECT SUBEID, TUR,
           MIN(KOCANNO)          AS KOCANNO,
           MIN(BASLANGICTARIHI)  AS BASLANGICTARIHI
      FROM dbo.KOCANAYARLARI
     WHERE TUR = 10
     GROUP BY SUBEID, TUR
    HAVING COUNT(*) = 1
),
Hedef AS
(
    SELECT FB.ID, FB.TUR, FB.SUBEID, FB.FATURANO,
           ISNULL(FB.KOCANNO, 0) AS ESKI_KOCANNO,
           TK.KOCANNO            AS YENI_KOCANNO
      FROM dbo.FATBASLIK FB
      JOIN TekKocan     TK ON TK.SUBEID = FB.SUBEID AND TK.TUR = FB.TUR
     WHERE FB.TUR = 10
       AND ISNULL(FB.KOCANNO, 0) = 0
       AND ISNUMERIC(FB.FATURANO) = 1
       AND FB.FATURATARIH >= ISNULL(TK.BASLANGICTARIHI, '1900-01-01')
)
INSERT INTO dbo.YEDEK_FATBASLIK_KOCANNO_171 (ID, TUR, SUBEID, FATURANO, ESKI_KOCANNO, YENI_KOCANNO)
SELECT H.ID, H.TUR, H.SUBEID, H.FATURANO, H.ESKI_KOCANNO, H.YENI_KOCANNO
  FROM Hedef H
 WHERE NOT EXISTS (SELECT 1 FROM dbo.YEDEK_FATBASLIK_KOCANNO_171 Y WHERE Y.ID = H.ID);

-- 3) Guncelleme (yalnizca yedegi alinmis satirlar)
UPDATE FB
   SET FB.KOCANNO = Y.YENI_KOCANNO
  FROM dbo.FATBASLIK FB
  JOIN dbo.YEDEK_FATBASLIK_KOCANNO_171 Y ON Y.ID = FB.ID
 WHERE ISNULL(FB.KOCANNO, 0) = 0;

PRINT 'Update_SQL_171: alis irsaliyesi KOCANNO onarimi tamamlandi.';
