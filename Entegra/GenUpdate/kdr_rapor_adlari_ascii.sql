/* ============================================================================
   kdr_rapor_adlari_ascii.sql  —  MUSTERI ANA veritabaninda calistirilir

   AMAC: DOKUMLER.RAPORADI icindeki KDR raporlarinin adlarindaki TURKCE HARFLERI
         ASCII karsiligina cevirir (KDR_BORÇLULAR -> KDR_BORCLULAR).

   NEDEN: Ana Giris > KDR panelindeki kutucuklar (tile) DELPHI BILESENLERIDIR ve
     bilesen adi Turkce harf ICEREMEZ; DFM'de adlari KDR_BORCLULAR, KDR_ALINAN_CEK,
     KDR_KREDILER... seklindedir. Kod raporu
        FindComponent(alan_adi)              -> kutucuk degerleri icin
        where RAPORADI = <bilesen_adi>       -> tiklaninca acilan liste icin
     seklinde BILESEN ADIYLA eslestirir. Rapor adi Turkce yazilinca eslesme olmaz:
       - kutucuklar 0 gorunur,
       - kutucuga tiklayinca sagdaki grid BOS gelir.
     (Ayni sebeple KDR_SONUC raporunun SELECT KOLON ADLARI da ASCII olmalidir.)

   KAPSAM: Yalniz 'KDR%' ile baslayan rapor ADLARI. Rapor SQL'lerinin ICINDEKI metin
     literalleri (or. 'Konsinye Çıkış') TURKCE KALIR - onlar veriyle karsilastirilir.

   KULLANIM:
     - Once oldugu gibi calistirin  -> yalnizca RAPOR (ne degisecek).
     - Uygulamak icin @Uygula = 0 satirini @Uygula = 1 yapip tekrar calistirin.
     - Idempotent: tekrar calistirmak zararsizdir.

   NOT: Dosya UTF-8 (BOM). sqlcmd ile:  -f 65001  ZORUNLU.
============================================================================ */
SET NOCOUNT ON;

------------------------------------------------------------------------------
DECLARE @Uygula BIT = 0;      -- 0 = yalniz rapor   |   1 = ADLARI DEGISTIR
------------------------------------------------------------------------------

/* Turkce -> ASCII cevrim yardimcisi (BIN2 collation: 'Ç' ile 'C' AYRI gorulsun) */
IF OBJECT_ID('tempdb..#Ad') IS NOT NULL DROP TABLE #Ad;
SELECT ID,
       ESKI = RAPORADI,
       YENI = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              RAPORADI COLLATE Latin1_General_BIN2,
              N'Ç',N'C'),N'ç',N'c'),N'Ğ',N'G'),N'ğ',N'g'),N'İ',N'I'),N'ı',N'i'),
              N'Ö',N'O'),N'ö',N'o'),N'Ş',N'S'),N'ş',N's'),N'Ü',N'U'),N'ü',N'u')
INTO #Ad
FROM DOKUMLER
WHERE RAPORADI LIKE N'KDR%';

DELETE #Ad WHERE ESKI COLLATE Latin1_General_BIN2 = YENI COLLATE Latin1_General_BIN2;

/* ---- 1) RAPOR ------------------------------------------------------------- */
SELECT ESKI_AD = ESKI, YENI_AD = YENI,
       CAKISMA = CASE WHEN EXISTS (SELECT 1 FROM DOKUMLER d
                                    WHERE d.RAPORADI COLLATE Latin1_General_BIN2 = a.YENI COLLATE Latin1_General_BIN2)
                      THEN 'AYNI ADDA KAYIT VAR - ATLANACAK' ELSE '' END
FROM #Ad a
ORDER BY ESKI;

IF NOT EXISTS (SELECT 1 FROM #Ad)
BEGIN
    PRINT 'Duzeltilecek rapor adi yok (hepsi zaten ASCII).';
    RETURN;
END

IF @Uygula = 0
BEGIN
    PRINT '';
    PRINT '*** RAPOR MODU - hicbir degisiklik yapilmadi. ***';
    PRINT 'Uygulamak icin @Uygula = 1 yapip tekrar calistirin.';
    RETURN;
END

/* ---- 2) UYGULA ------------------------------------------------------------ */
DECLARE @eski sysname, @yeni sysname, @adet int = 0;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT ESKI, YENI FROM #Ad;
OPEN c; FETCH NEXT FROM c INTO @eski, @yeni;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Hedef adda ZATEN kayit varsa dokunma (mukerrer rapor olusturmayalim)
    IF EXISTS (SELECT 1 FROM DOKUMLER WHERE RAPORADI COLLATE Latin1_General_BIN2 = @yeni COLLATE Latin1_General_BIN2)
        PRINT '  ATLANDI (ayni ad var): ' + @eski;
    ELSE
    BEGIN
        UPDATE DOKUMLER SET RAPORADI = @yeni
         WHERE RAPORADI COLLATE Latin1_General_BIN2 = @eski COLLATE Latin1_General_BIN2;
        SET @adet = @adet + @@ROWCOUNT;
        PRINT '  ' + @eski + '  ->  ' + @yeni;
    END
    FETCH NEXT FROM c INTO @eski, @yeni;
END
CLOSE c; DEALLOCATE c;

PRINT '';
PRINT 'Degistirilen rapor adi: ' + CAST(@adet AS varchar(10));

/* ---- 3) SON DURUM --------------------------------------------------------- */
SELECT RAPOR = RAPORADI,
       ASCII_MI = CASE WHEN RAPORADI COLLATE Latin1_General_BIN2 =
                            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                            RAPORADI COLLATE Latin1_General_BIN2,
                            N'Ç',N'C'),N'ç',N'c'),N'Ğ',N'G'),N'ğ',N'g'),N'İ',N'I'),N'ı',N'i'),
                            N'Ö',N'O'),N'ö',N'o'),N'Ş',N'S'),N'ş',N's'),N'Ü',N'U'),N'ü',N'u')
                       THEN 'evet' ELSE 'HAYIR' END
FROM DOKUMLER WHERE RAPORADI LIKE N'KDR%' ORDER BY RAPORADI;
