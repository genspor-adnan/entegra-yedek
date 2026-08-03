CREATE OR ALTER PROCEDURE dbo.sp_Prog_Fatura_StokDetay
    @FATBASID INT,
    @MinKolonSayisi INT = 6
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @SQL NVARCHAR(MAX),
        @KOLONBASLIK SYSNAME,
        @URUNADI NVARCHAR(100),
        @URUNFIYATI NVARCHAR(100),
        @URUNID INT,
        @ETIKET NVARCHAR(100),
        @BILGI NVARCHAR(1000),
        @SIRA INT,
        @RESIM VARBINARY(MAX),
        @DETAYBOLUMU NVARCHAR(50),
        @KOLONSAYISI INT,
        @Count INT;

    CREATE TABLE #RehberBilgiView(
        ID INT IDENTITY(1,1),
        SIRA INT NULL,
        ETIKET NVARCHAR(100) NULL,
        KONU NVARCHAR(50) NULL,
        GIRIS INT NULL
    );

    SELECT TOP 1 @KOLONSAYISI = COUNT(*)
    FROM STOKLAR S
    INNER JOIN FATURA TD ON S.ID = TD.URUNID AND TD.TUR = 1
    WHERE TD.FATBASID = @FATBASID
      AND ISNULL(S.DETAYBOLUMU, '') <> ''
    GROUP BY S.DETAYBOLUMU
    ORDER BY COUNT(*) DESC;

    SET @KOLONSAYISI = ISNULL(@KOLONSAYISI, 0);
    IF @KOLONSAYISI < @MinKolonSayisi
        SET @KOLONSAYISI = @MinKolonSayisi;

    SET @Count = 0;
    WHILE @Count < @KOLONSAYISI
    BEGIN
        SET @SQL = N'ALTER TABLE #RehberBilgiView ADD ' +
                   QUOTENAME(N'Ürün' + CONVERT(NVARCHAR(5), @Count + 1)) + N' NVARCHAR(1000) NULL, ' +
                   QUOTENAME(N'Resim' + CONVERT(NVARCHAR(5), @Count + 1)) + N' VARBINARY(MAX) NULL';
        EXEC sys.sp_executesql @SQL;
        SET @Count += 1;
    END;

    INSERT INTO #RehberBilgiView (SIRA, ETIKET, KONU, GIRIS)
    SELECT RA.SIRA, RA.ETIKET, RA.BOLUM, RA.GIRIS
    FROM REHBERAYAR RA
    WHERE RA.YERI = 88
      AND RA.BOLUM IN (
          SELECT DISTINCT S.DETAYBOLUMU
          FROM STOKLAR S
          WHERE ISNULL(S.DETAYBOLUMU, '') <> ''
            AND S.ID IN (SELECT T.URUNID FROM FATURA T WHERE T.TUR = 1 AND T.FATBASID = @FATBASID)
      )
    ORDER BY RA.BOLUM;

    INSERT INTO #RehberBilgiView (SIRA, ETIKET, KONU, GIRIS)
    SELECT DISTINCT -1, N'Ürün Adı', S.DETAYBOLUMU, -1
    FROM STOKLAR S
    WHERE ISNULL(S.DETAYBOLUMU, '') <> ''
      AND S.ID IN (SELECT T.URUNID FROM FATURA T WHERE T.TUR = 1 AND T.FATBASID = @FATBASID);

    INSERT INTO #RehberBilgiView (SIRA, ETIKET, KONU, GIRIS)
    SELECT DISTINCT 2147483640, N'Fiyatı', S.DETAYBOLUMU, 2147483640
    FROM STOKLAR S
    WHERE ISNULL(S.DETAYBOLUMU, '') <> ''
      AND S.ID IN (SELECT T.URUNID FROM FATURA T WHERE T.TUR = 1 AND T.FATBASID = @FATBASID);

    DECLARE cur_Konular CURSOR LOCAL FAST_FORWARD FOR
        SELECT S.DETAYBOLUMU
        FROM STOKLAR S
        WHERE ISNULL(S.DETAYBOLUMU, '') <> ''
          AND S.ID IN (SELECT T.URUNID FROM FATURA T WHERE T.TUR = 1 AND T.FATBASID = @FATBASID)
        GROUP BY S.DETAYBOLUMU
        ORDER BY COUNT(*) DESC;

    OPEN cur_Konular;
    FETCH NEXT FROM cur_Konular INTO @DETAYBOLUMU;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE cur_Urunler CURSOR LOCAL FAST_FORWARD FOR
            SELECT T.URUNID,
                   N'Ürün' + CONVERT(NVARCHAR(5), ROW_NUMBER() OVER(ORDER BY T.URUNID)),
                   S.STOKADI,
                   CONVERT(NVARCHAR(50), T.TUTAR) + T.KUR
            FROM STOKLAR S
            INNER JOIN FATURA T ON T.TUR = 1 AND T.URUNID = S.ID
            WHERE T.FATBASID = @FATBASID
              AND S.DETAYBOLUMU = @DETAYBOLUMU;

        OPEN cur_Urunler;
        FETCH NEXT FROM cur_Urunler INTO @URUNID, @KOLONBASLIK, @URUNADI, @URUNFIYATI;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SQL = N'UPDATE #RehberBilgiView SET ' + QUOTENAME(@KOLONBASLIK) +
                       N' = @Deger WHERE KONU = @Konu AND SIRA = -1 AND ETIKET = N''Ürün Adı''';
            EXEC sys.sp_executesql @SQL, N'@Deger NVARCHAR(1000), @Konu NVARCHAR(50)', @Deger = @URUNADI, @Konu = @DETAYBOLUMU;

            SET @SQL = N'UPDATE #RehberBilgiView SET ' + QUOTENAME(@KOLONBASLIK) +
                       N' = @Deger WHERE KONU = @Konu AND SIRA = 2147483640 AND ETIKET = N''Fiyatı''';
            EXEC sys.sp_executesql @SQL, N'@Deger NVARCHAR(1000), @Konu NVARCHAR(50)', @Deger = @URUNFIYATI, @Konu = @DETAYBOLUMU;

            DECLARE cur_Etiketler CURSOR LOCAL FAST_FORWARD FOR
                SELECT RB2.ETIKET, RB2.BILGI, RB2.SIRA
                FROM REHBERBILGI RB2
                INNER JOIN REHBERAYAR RA2 ON RB2.SIRA = RA2.SIRA AND RB2.ETIKET = RA2.ETIKET
                WHERE RA2.BOLUM = @DETAYBOLUMU
                  AND RB2.YERI = 88
                  AND RB2.YER_ID = @URUNID;

            OPEN cur_Etiketler;
            FETCH NEXT FROM cur_Etiketler INTO @ETIKET, @BILGI, @SIRA;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @SQL = N'UPDATE #RehberBilgiView SET ' + QUOTENAME(@KOLONBASLIK) +
                           N' = @Deger WHERE KONU = @Konu AND SIRA = @Sira AND ETIKET = @Etiket';
                EXEC sys.sp_executesql @SQL,
                    N'@Deger NVARCHAR(1000), @Konu NVARCHAR(50), @Sira INT, @Etiket NVARCHAR(100)',
                    @Deger = @BILGI, @Konu = @DETAYBOLUMU, @Sira = @SIRA, @Etiket = @ETIKET;
                FETCH NEXT FROM cur_Etiketler INTO @ETIKET, @BILGI, @SIRA;
            END;
            CLOSE cur_Etiketler;
            DEALLOCATE cur_Etiketler;

            DECLARE cur_Resimler CURSOR LOCAL FAST_FORWARD FOR
                SELECT RB2.ETIKET, RB2.BILGI, RB2.SIRA, RR.RESIM
                FROM REHBERBILGI RB2
                INNER JOIN REHBERAYAR RA2 ON RB2.SIRA = RA2.SIRA AND RB2.ETIKET = RA2.ETIKET
                LEFT OUTER JOIN REHBERBILGIRESIM RR ON RB2.ID = RR.REHBERBILGIID
                WHERE RA2.BOLUM = @DETAYBOLUMU
                  AND RB2.YERI = 88
                  AND RB2.YER_ID = @URUNID;

            OPEN cur_Resimler;
            FETCH NEXT FROM cur_Resimler INTO @ETIKET, @BILGI, @SIRA, @RESIM;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @SQL = N'UPDATE #RehberBilgiView SET ' + QUOTENAME(REPLACE(@KOLONBASLIK, N'Ürün', N'Resim')) +
                           N' = @Resim WHERE KONU = @Konu AND SIRA = @Sira AND ETIKET = @Etiket';
                EXEC sys.sp_executesql @SQL,
                    N'@Resim VARBINARY(MAX), @Konu NVARCHAR(50), @Sira INT, @Etiket NVARCHAR(100)',
                    @Resim = @RESIM, @Konu = @DETAYBOLUMU, @Sira = @SIRA, @Etiket = @ETIKET;
                FETCH NEXT FROM cur_Resimler INTO @ETIKET, @BILGI, @SIRA, @RESIM;
            END;
            CLOSE cur_Resimler;
            DEALLOCATE cur_Resimler;

            FETCH NEXT FROM cur_Urunler INTO @URUNID, @KOLONBASLIK, @URUNADI, @URUNFIYATI;
        END;
        CLOSE cur_Urunler;
        DEALLOCATE cur_Urunler;

        FETCH NEXT FROM cur_Konular INTO @DETAYBOLUMU;
    END;
    CLOSE cur_Konular;
    DEALLOCATE cur_Konular;

    SELECT * FROM #RehberBilgiView ORDER BY KONU, SIRA;
END;
