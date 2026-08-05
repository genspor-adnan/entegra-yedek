/* ============================================================================
   dokumler_turkce_onar.sql  —  MUSTERI ANA veritabaninda calistirilir

   SORUN: DOKUMLER.[SQL] (rapor/kokpit sorgulari) icindeki TURKCE HARFLER '?' olmus.
     Ornek: KDR_ALINAN_?EK, KDR_KRED?LER, 'Konsinye ??k??'.
     Bozulma bir aktarim/kod-sayfasi hatasindan geliyor (gercek 0x3F kaybi; mojibake DEGIL).

   ETKI: '?' ODBC'de PARAMETRE ISARETIDIR. FireDAC sorguyu acarken metindeki her '?' icin
     parametre bekler; kod 2 parametre verdigi icin
        "COUNT field incorrect or syntax error"
     hatasi olusur ve ekran (or. Ana Giris > KDR kokpit paneli) hic acilmaz.
     Ayrica bozuk KOLON ADLARI (KDR_ALINAN_?EK) uygulamadaki tile bilesenleriyle
     eslesmez -> deger gosterilemez.

   NE YAPAR: Bilinen bozuk kaliplari dogru Turkce karsiligiyla degistirir. Yalniz
     DOKUMLER.[SQL] kolonuna dokunur, baska tabloya dokunmaz.

   KULLANIM:
     - Once oldugu gibi calistirin  -> yalnizca RAPOR (hangi rapor, kac '?').
     - Duzeltmek icin asagidaki @Uygula = 0 satirini @Uygula = 1 yapip tekrar calistirin.
     - Idempotent: tekrar calistirmak zararsizdir.
============================================================================ */
SET NOCOUNT ON;
SET ANSI_WARNINGS ON;

------------------------------------------------------------------------------
DECLARE @Uygula BIT = 0;      -- 0 = yalniz rapor   |   1 = DUZELTMEYI UYGULA
------------------------------------------------------------------------------

/* ---- Bozuk kalip -> dogru karsilik eslemesi -------------------------------
   SIRA ONEMLI: uzun kaliplar once (KRED?_KARTI, KRED?LER'den once eslesmeli). */
IF OBJECT_ID('tempdb..#Es') IS NOT NULL DROP TABLE #Es;
-- #Es tempdb'de olusur ve SUNUCU collation'ini alir; musteri DB'si farkli collation'da
--   olabilir (or. Turkish_CI_AS vs SQL_Latin1_General_CP1254_CI_AS) -> LIKE/REPLACE'te
--   "collation conflict". Kolonlara DATABASE_DEFAULT verilerek catisma onlenir.
CREATE TABLE #Es (SIRA int IDENTITY(1,1),
                  BOZUK nvarchar(200) COLLATE DATABASE_DEFAULT,
                  DOGRU nvarchar(200) COLLATE DATABASE_DEFAULT);

INSERT #Es (BOZUK, DOGRU) VALUES
    -- Kolon adlari (uygulama bunlarla tile eslestiriyor -> KRITIK)
    (N'KDR_ALINAN_?EK',    N'KDR_ALINAN_ÇEK'),
    (N'KDR_VER?LEN_?EK',   N'KDR_VERİLEN_ÇEK'),
    (N'KDR_VER?LEN_SENET', N'KDR_VERİLEN_SENET'),
    (N'KDR_ALINAN_SENET',  N'KDR_ALINAN_SENET'),      -- zaten dogru (guvenlik icin no-op)
    (N'KDR_KRED?_KARTI',   N'KDR_KREDİ_KARTI'),
    (N'KDR_KRED?LER',      N'KDR_KREDİLER'),
    (N'KDR_BOR?LULAR',     N'KDR_BORÇLULAR'),
    (N'KDR_ALACAKLILAR',   N'KDR_ALACAKLILAR'),       -- no-op
    -- Veri karsilastirmasinda kullanilan metinler (yanlis kalirsa SONUC YANLIS olur)
    (N'Konsinye ??k??',    N'Konsinye Çıkış'),
    (N'Konsinye G?r??',    N'Konsinye Giriş'),
    -- Yorum satirlari (islevsel degil, okunabilirlik)
    (N'--KRED?LER',        N'--KREDİLER'),
    (N'al?nan fatura',     N'alınan fatura');

/* ---- 1) RAPOR ------------------------------------------------------------- */
SELECT RAPOR = d.RAPORADI,
       SORU_ISARETI = LEN(CAST(d.[SQL] AS nvarchar(max)))
                    - LEN(REPLACE(CAST(d.[SQL] AS nvarchar(max)), '?', '')),
       ESLESEN_KALIP = (SELECT COUNT(*) FROM #Es e
                        WHERE e.BOZUK <> e.DOGRU
                          AND CAST(d.[SQL] AS nvarchar(max)) LIKE N'%' + e.BOZUK + N'%')
FROM DOKUMLER d
WHERE CAST(d.[SQL] AS nvarchar(max)) LIKE N'%?%'
ORDER BY 2 DESC;

IF @Uygula = 0
BEGIN
    PRINT '';
    PRINT '*** RAPOR MODU - hicbir degisiklik yapilmadi. ***';
    PRINT 'Duzeltmek icin @Uygula = 1 yapip tekrar calistirin.';
    RETURN;
END

/* ---- 2) DUZELTME ---------------------------------------------------------- */
DECLARE @i int = 1, @son int = (SELECT MAX(SIRA) FROM #Es);
DECLARE @bozuk nvarchar(200), @dogru nvarchar(200), @adet int, @toplam int = 0;

WHILE @i <= @son
BEGIN
    SELECT @bozuk = BOZUK, @dogru = DOGRU FROM #Es WHERE SIRA = @i;

    IF @bozuk <> @dogru
    BEGIN
        -- text kolonu: nvarchar(max)'a cevirip REPLACE, sonra geri yaz
        UPDATE DOKUMLER
           SET [SQL] = REPLACE(CAST([SQL] AS nvarchar(max)), @bozuk, @dogru)
         WHERE CAST([SQL] AS nvarchar(max)) LIKE N'%' + @bozuk + N'%';

        SET @adet = @@ROWCOUNT;
        SET @toplam = @toplam + @adet;
        IF @adet > 0
            PRINT '  ' + @bozuk + '  ->  ' + @dogru + '   (' + CAST(@adet AS varchar(10)) + ' rapor)';
    END

    SET @i = @i + 1;
END

PRINT '';
PRINT 'Duzeltilen kayit sayisi (kalip bazinda toplam): ' + CAST(@toplam AS varchar(10));

/* ---- 3) KALAN DURUM ------------------------------------------------------- */
SELECT KALAN_RAPOR = d.RAPORADI,
       KALAN_SORU  = LEN(CAST(d.[SQL] AS nvarchar(max)))
                   - LEN(REPLACE(CAST(d.[SQL] AS nvarchar(max)), '?', ''))
FROM DOKUMLER d
WHERE CAST(d.[SQL] AS nvarchar(max)) LIKE N'%?%'
ORDER BY 2 DESC;

PRINT '';
PRINT 'NOT: Yukarida hala kayit varsa, o raporlardaki ''?'' bu betikteki kalip listesinde';
PRINT '     YOK demektir. Ilgili metni inceleyip #Es listesine ekleyin.';
