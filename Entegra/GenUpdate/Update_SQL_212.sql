/*
  Update_SQL_212 - Cari ekstre: musteri iletisim adi (ILETISIMAD) kolonu.

  fn_Cari_Ekstre ve fn_Cari_Detayli_Ekstre sonucuna ILETISIMAD eklenir:
    - KASA satirlari      -> KASA.REHBERILETID (Update_SQL_211) -> REHBERILETISIM.AD
    - FATBASLIK satirlari -> FATBASLIK.REHBERILETID            -> REHBERILETISIM.AD
    - Cek / senet         -> NULL
  Kolon tablonun SONUNA eklenir; mevcut kolonlarin sirasi degismez.

  Fonksiyonlar mevcut tanimlari uzerine yamalanir (OBJECT_DEFINITION -> ekle ->
  ALTER). Beklenen ifadeler bulunamazsa hata verir, hicbir sey degismez.
  Tekrar calistirilirsa atlanir. Update_SQL_211'den SONRA calismalidir.
*/
IF COL_LENGTH('dbo.KASA', 'REHBERILETID') IS NULL
    THROW 51200, N'Update212: once Update_SQL_211 (KASA.REHBERILETID) calistirilmali.', 1;

DECLARE @KasaIlt NVARCHAR(200) = N',ILETISIMAD=(select RI.AD from REHBERILETISIM RI where RI.ID=K.REHBERILETID)';
DECLARE @FatIlt  NVARCHAR(200) = N',ILETISIMAD=(select RI.AD from REHBERILETISIM RI where RI.ID=F.REHBERILETID)';
DECLARE @BosIlt  NVARCHAR(200) = N',ILETISIMAD=CAST(NULL AS nvarchar(100))';
DECLARE @P INT;

-- ============================================================ fn_Cari_Ekstre
DECLARE @D NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.fn_Cari_Ekstre'));
IF @D IS NULL THROW 51200, N'Update212: fn_Cari_Ekstre bulunamadi.', 1;

IF CHARINDEX(N'ILETISIMAD', @D) > 0
    PRINT N'Update212: fn_Cari_Ekstre zaten yamali - atlandi.';
ELSE
BEGIN
    -- Her UNION kolu ADET=1.0,BIRIM='',BIRIMFIYAT=0.0 ile biter; sira KASA, FATBASLIK, CEK, SENET.
    DECLARE @A NVARCHAR(100) = N'ADET=1.0,BIRIM='''',BIRIMFIYAT=0.0';
    DECLARE @P1 INT = CHARINDEX(@A, @D);
    DECLARE @P2 INT = CASE WHEN @P1 > 0 THEN CHARINDEX(@A, @D, @P1 + 1) ELSE 0 END;
    DECLARE @P3 INT = CASE WHEN @P2 > 0 THEN CHARINDEX(@A, @D, @P2 + 1) ELSE 0 END;
    DECLARE @P4 INT = CASE WHEN @P3 > 0 THEN CHARINDEX(@A, @D, @P3 + 1) ELSE 0 END;
    DECLARE @P5 INT = CASE WHEN @P4 > 0 THEN CHARINDEX(@A, @D, @P4 + 1) ELSE 1 END;
    DECLARE @Kasa INT = CHARINDEX(N'KASA K (NOLOCK)', @D),
            @Fat  INT = CHARINDEX(N'FATBASLIK F (NOLOCK)', @D),
            @Cek  INT = CHARINDEX(N'CEKLER C (NOLOCK)', @D),
            @Sen  INT = CHARINDEX(N'SENETLER C (NOLOCK)', @D);
    DECLARE @Liste NVARCHAR(100) = N'VADETARIHI,ADET,BIRIM,BIRIMFIYAT';
    DECLARE @Tablo NVARCHAR(100) = N'[BIRIMFIYAT] [money] NULL';

    IF @P4 = 0 OR @P5 <> 0
       OR NOT (@P1 < @Kasa AND @Kasa < @P2 AND @P2 < @Fat AND @Fat < @P3
               AND @P3 < @Cek AND @Cek < @P4 AND @P4 < @Sen)
       OR (DATALENGTH(@D) - DATALENGTH(REPLACE(@D, @Liste, N''))) / DATALENGTH(@Liste) <> 2
       OR (DATALENGTH(@D) - DATALENGTH(REPLACE(@D, @Tablo, N''))) / DATALENGTH(@Tablo) <> 1
        THROW 51200, N'Update212: fn_Cari_Ekstre beklenen yapida degil, elle kontrol edin.', 1;

    -- Sondan basa ekle (onceki konumlar kaymasin)
    SET @D = STUFF(@D, @P4 + LEN(@A), 0, @BosIlt);
    SET @D = STUFF(@D, @P3 + LEN(@A), 0, @BosIlt);
    SET @D = STUFF(@D, @P2 + LEN(@A), 0, @FatIlt);
    SET @D = STUFF(@D, @P1 + LEN(@A), 0, @KasaIlt);
    SET @D = REPLACE(@D, @Liste, @Liste + N',ILETISIMAD');
    SET @D = REPLACE(@D, @Tablo, @Tablo + N', [ILETISIMAD] [nvarchar](100) NULL');

    SET @P = PATINDEX(N'%CREATE%FUNCTION%', @D);
    SET @D = STUFF(@D, @P, CHARINDEX(N'FUNCTION', @D, @P) - @P, N'ALTER ');
    EXEC sp_executesql @D;
    PRINT N'Update212: fn_Cari_Ekstre yamalandi.';
END

-- ============================================================ fn_Cari_Detayli_Ekstre
SET @D = OBJECT_DEFINITION(OBJECT_ID('dbo.fn_Cari_Detayli_Ekstre'));
IF @D IS NULL THROW 51200, N'Update212: fn_Cari_Detayli_Ekstre bulunamadi.', 1;

IF CHARINDEX(N'ILETISIMAD', @D) > 0
    PRINT N'Update212: fn_Cari_Detayli_Ekstre zaten yamali - atlandi.';
ELSE
BEGIN
    -- Kollar dogrudan INSERT @TOPLAM'a gider; her kolun sonuna (From'dan once) eklenir.
    DECLARE @FK NVARCHAR(100) = N'From KASA K (NOLOCK)',
            @FF NVARCHAR(100) = N'From FATBASLIK F (NOLOCK)',
            @FC NVARCHAR(100) = N'From CEKLER C (NOLOCK)',
            @FS NVARCHAR(100) = N'From SENETLER C (NOLOCK)',
            @TD NVARCHAR(100) = N'[BIRIMFIYAT] [money] NULL)';
    IF (DATALENGTH(@D) - DATALENGTH(REPLACE(@D, @FK, N''))) / DATALENGTH(@FK) <> 1
       OR (DATALENGTH(@D) - DATALENGTH(REPLACE(@D, @FC, N''))) / DATALENGTH(@FC) <> 1
       OR (DATALENGTH(@D) - DATALENGTH(REPLACE(@D, @FS, N''))) / DATALENGTH(@FS) <> 1
       OR (DATALENGTH(@D) - DATALENGTH(REPLACE(@D, @FF, N''))) / DATALENGTH(@FF) < 1
       OR (DATALENGTH(@D) - DATALENGTH(REPLACE(@D, @TD, N''))) / DATALENGTH(@TD) <> 1
        THROW 51200, N'Update212: fn_Cari_Detayli_Ekstre beklenen yapida degil, elle kontrol edin.', 1;

    SET @D = REPLACE(@D, @FK, @KasaIlt + NCHAR(13) + NCHAR(10) + @FK);
    SET @D = REPLACE(@D, @FF, @FatIlt  + NCHAR(13) + NCHAR(10) + @FF);
    SET @D = REPLACE(@D, @FC, @BosIlt  + NCHAR(13) + NCHAR(10) + @FC);
    SET @D = REPLACE(@D, @FS, @BosIlt  + NCHAR(13) + NCHAR(10) + @FS);
    SET @D = REPLACE(@D, @TD, N'[BIRIMFIYAT] [money] NULL, [ILETISIMAD] [nvarchar](100) NULL)');

    SET @P = PATINDEX(N'%CREATE%FUNCTION%', @D);
    SET @D = STUFF(@D, @P, CHARINDEX(N'FUNCTION', @D, @P) - @P, N'ALTER ');
    EXEC sp_executesql @D;
    PRINT N'Update212: fn_Cari_Detayli_Ekstre yamalandi.';
END
