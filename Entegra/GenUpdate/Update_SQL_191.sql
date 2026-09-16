-- Update_SQL_191.sql
-- Cari karti > Ticari Bilgiler gridinden (REHBERBILGI YERI=2) artik kullanilmayan
-- 7 alan kaldirilir:
--
--   Masraf Kalemi      (VARSAYILAN=32)
--   Gelir Kalemi       (VARSAYILAN=34)
--   Muhasebe Kodu      (VARSAYILAN=92)
--   Grup Sirket Kodu   (VARSAYILAN NULL - ETIKET ile bulunur)
--   Srm.Mrk. Gelir     (VARSAYILAN=97)
--   Srm.Mrk. Gider     (VARSAYILAN=99)
--   Gratis             (VARSAYILAN=101)
--
-- Grid dogrudan REHBERBILGI'den okur (UReharadlg.dfm TabTicari), alan tanimi ise
-- REHBERAYAR'da durur (YERI=2, SIRA eslesmesi). Alanin hem listeden hem de
-- "Yeni / Duzenle" ekranindan kalkmasi icin iki tablodan da silinmesi gerekir.
--
-- Satirlar SIRA ile degil VARSAYILAN sistem kodu ile bulunur: musteri SIRA'yi
-- veya ETIKET'i degistirmis olabilir, VARSAYILAN sabittir. (Grup Sirket Kodu'nun
-- VARSAYILAN'i NULL oldugu icin yalniz onda ETIKET kalibi kullanilir.)
-- Silinecek SIRA listesi REHBERAYAR'dan turetilir, elle yazilmaz.
--
-- DIKKAT - Gratis: UHizliGiris.pas GratisIslem, cari gratis tutarini
-- "REHBERBILGI B INNER JOIN REHBERAYAR A ON A.VARSAYILAN=101" ile okur. Bu satir
-- kalkinca sorgu bos doner ve Gratis = 0 olur, yani Hizli Giris ekranindaki
-- gratis indirimi devre disi kalir. Kaldirma istegi bu bilgiyle verilmistir.
--
-- Silinen satirlar once REHBERAYAR_Y191 / REHBERBILGI_Y191 tablolarina yedeklenir;
-- betik idempotenttir, ikinci calismada silecek satir bulamaz.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ---- 1) Kaldirilacak alan tanimlari (REHBERAYAR, YERI=2) ---- */
IF OBJECT_ID('tempdb..#Kaldir') IS NOT NULL DROP TABLE #Kaldir;
CREATE TABLE #Kaldir (ID INT PRIMARY KEY, SIRA SMALLINT, ETIKET NVARCHAR(200));

INSERT INTO #Kaldir (ID, SIRA, ETIKET)
SELECT RA.ID, RA.SIRA, RA.ETIKET
FROM dbo.REHBERAYAR RA
WHERE RA.YERI = 2
  AND ( RA.VARSAYILAN IN (32, 34, 92, 97, 99, 101)          -- Masraf/Gelir Kalemi, Muhasebe Kodu,
                                                             -- Srm.Mrk. Gelir/Gider, Gratis
        OR RA.ETIKET LIKE N'Grup%irket%Kod%' );              -- Grup Sirket Kodu (VARSAYILAN NULL)

-- REHBERBILGI'de alan ayrimi yalnizca SIRA ile yapilir. Kalmasi gereken bir alan
-- tanimi ayni SIRA'yi paylasiyorsa (musteri SIRA'lari degistirmis olabilir) o
-- SIRA'daki cari degerlere DOKUNULMAZ - yoksa kalan alanin verisi de silinirdi.
-- Alan tanimi yine de kaldirilir, sadece degerleri birakilir.
IF OBJECT_ID('tempdb..#KaldirSira') IS NOT NULL DROP TABLE #KaldirSira;
CREATE TABLE #KaldirSira (SIRA SMALLINT PRIMARY KEY);

INSERT INTO #KaldirSira (SIRA)
SELECT DISTINCT K.SIRA
FROM #Kaldir K
WHERE NOT EXISTS (SELECT 1 FROM dbo.REHBERAYAR RA
                   WHERE RA.YERI = 2 AND RA.SIRA = K.SIRA
                     AND RA.ID NOT IN (SELECT ID FROM #Kaldir));

/* ---- 2) Yedek tablolar ----
   SELECT..INTO hem olusturur hem doldurur: ayri INSERT kullanilamaz, cunku
   SELECT..INTO kaynak tablonun IDENTITY ozelligini de kopyalar ve ID'ye acik
   deger yazmaya izin vermez. Tablo zaten varsa betik daha once calismistir;
   yedek o calismadan durur, silinecek satir da kalmamistir. */
IF OBJECT_ID('dbo.REHBERAYAR_Y191', 'U') IS NULL
    SELECT RA.* INTO dbo.REHBERAYAR_Y191
    FROM dbo.REHBERAYAR RA
    WHERE RA.ID IN (SELECT ID FROM #Kaldir);

IF OBJECT_ID('dbo.REHBERBILGI_Y191', 'U') IS NULL
    SELECT RB.* INTO dbo.REHBERBILGI_Y191
    FROM dbo.REHBERBILGI RB
    WHERE RB.YERI = 2
      AND RB.SIRA IN (SELECT SIRA FROM #KaldirSira);

/* ---- 3) Ne silinecek ---- */
SELECT N'Kaldirilacak alan tanimi' AS Rapor, K.ID, K.SIRA, K.ETIKET,
       CASE WHEN K.SIRA IN (SELECT SIRA FROM #KaldirSira)
            THEN (SELECT COUNT(*) FROM dbo.REHBERBILGI RB
                   WHERE RB.YERI = 2 AND RB.SIRA = K.SIRA)
            ELSE 0 END AS SilinecekCariKayit
FROM #Kaldir K
ORDER BY K.SIRA;

/* ---- 4) Silme ---- */
BEGIN TRY
    BEGIN TRANSACTION;

    DELETE RB
    FROM dbo.REHBERBILGI RB
    WHERE RB.YERI = 2
      AND RB.SIRA IN (SELECT SIRA FROM #KaldirSira);

    DELETE RA
    FROM dbo.REHBERAYAR RA
    WHERE RA.ID IN (SELECT ID FROM #Kaldir);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

IF OBJECT_ID('tempdb..#Kaldir')     IS NOT NULL DROP TABLE #Kaldir;
IF OBJECT_ID('tempdb..#KaldirSira') IS NOT NULL DROP TABLE #KaldirSira;
GO
