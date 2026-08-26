-- ============================================================
-- Update_SQL_179.sql   (MSSQL)
-- Belge donusumunde e-Fatura aktifse satis faturasi no 0 olsun
--
-- Siparis/irsaliye listesinden "faturasini olustur" server donusum
-- yolunu kullanir: sp_Prog_BelgeDonusum_Kaydet.
-- ============================================================

DECLARE @Proc nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Prog_BelgeDonusum_Kaydet'));
DECLARE @Kural nvarchar(200) = N'IF @YeniBelgeOut = 1 AND @HedefTur = 15';

IF @Proc IS NULL
BEGIN
    PRINT 'sp_Prog_BelgeDonusum_Kaydet bulunamadi; Update_SQL_179 atlandi.';
END
ELSE
BEGIN
    DECLARE @Degisti bit = 0;
    DECLARE @Ilk int = CHARINDEX(@Kural, @Proc);
    DECLARE @Ikinci int = CASE WHEN @Ilk > 0 THEN CHARINDEX(@Kural, @Proc, @Ilk + LEN(@Kural)) ELSE 0 END;

    IF @Ikinci > 0
    BEGIN
        SET @Proc = STUFF(@Proc, @Ilk, @Ikinci - @Ilk, N'');
        SET @Degisti = 1;
    END
    ELSE IF @Ilk = 0
    BEGIN
        DECLARE @Pos int = CHARINDEX(N'IF @YeniBelgeOut = 1 AND @BelgeNoPolitikasi = ''OTOMATIK''', @Proc);
        IF @Pos = 0
            THROW 51200, 'Update_SQL_179: sp_Prog_BelgeDonusum_Kaydet beklenen blok bulunamadi.', 1;

        SET @Proc = STUFF(@Proc, @Pos, 0,
N'IF @YeniBelgeOut = 1 AND @HedefTur = 15 AND
       ISNULL((SELECT TOP 1 TRY_CONVERT(INT, DEGER)
                 FROM GENINI
                WHERE BOLUM = -24030 AND DIL IN (-1, 0)
                ORDER BY CASE WHEN DIL = -1 THEN 0 ELSE 1 END), 0) <> 0
    BEGIN
        SET @BelgeNo = N''0'';
        SET @KocanNo = 0;
    END
    ELSE ');
        SET @Degisti = 1;
    END

    IF CHARINDEX(@Kural, @Proc) = 0
        THROW 51200, 'Update_SQL_179: sp_Prog_BelgeDonusum_Kaydet beklenen blok bulunamadi.', 1;

    IF @Degisti = 1
    BEGIN
        DECLARE @CreatePos int = PATINDEX(N'%CREATE%PROCEDURE%dbo.sp_Prog_BelgeDonusum_Kaydet%', @Proc);
        IF @CreatePos = 0
            THROW 51200, 'Update_SQL_179: sp_Prog_BelgeDonusum_Kaydet CREATE basligi bulunamadi.', 1;

        SET @Proc = SUBSTRING(@Proc, @CreatePos, LEN(@Proc));
        SET @Proc = STUFF(@Proc, 1, CHARINDEX(N'PROCEDURE', UPPER(@Proc)) + LEN(N'PROCEDURE') - 1,
                          N'ALTER PROCEDURE');
        EXEC sp_executesql @Proc;
    END
    ELSE
    BEGIN
        PRINT 'sp_Prog_BelgeDonusum_Kaydet zaten Update_SQL_179 kuralini iceriyor.';
    END
END
