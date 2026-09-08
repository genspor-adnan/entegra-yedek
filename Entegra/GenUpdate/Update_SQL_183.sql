-- ============================================================
-- Update_SQL_183.sql   (MSSQL)
-- Fatura kopyalamada e-Fatura aktifse satis faturasi no 0 olsun
--
-- sp_Api_Belge_Klonla_Json, baslik JSON'una FaturaNo vermedigi icin
-- sp_Api_Belge_Kaydet_Json yeni numara uretebiliyordu. E-belgede numarayi
-- servis verecegi icin kopya taslak FATURANO=0, KOCANNO=0 acilmali.
-- ============================================================

DECLARE @Proc nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Api_Belge_Klonla_Json'));
DECLARE @Kural nvarchar(200) = N'FaturaNo       = CASE WHEN FB.TUR = 15 AND';

IF @Proc IS NULL
BEGIN
    PRINT 'sp_Api_Belge_Klonla_Json bulunamadi; Update_SQL_183 atlandi.';
END
ELSE IF CHARINDEX(@Kural, @Proc) > 0
BEGIN
    PRINT 'sp_Api_Belge_Klonla_Json zaten Update_SQL_183 kuralini iceriyor.';
END
ELSE
BEGIN
    DECLARE @Bul nvarchar(200) = N'            DetayBolumu    = FB.DETAYBOLUMU';
    DECLARE @Pos int = CHARINDEX(@Bul, @Proc);
    IF @Pos = 0
        THROW 51200, 'Update_SQL_183: sp_Api_Belge_Klonla_Json beklenen baslik JSON blogu bulunamadi.', 1;

    DECLARE @Ekle nvarchar(max) =
N'            FaturaNo       = CASE WHEN FB.TUR = 15 AND
                                      ISNULL((SELECT TOP 1 TRY_CONVERT(INT, DEGER)
                                                FROM GENINI
                                               WHERE BOLUM = -24030 AND DIL IN (-1, 0)
                                               ORDER BY CASE WHEN DIL = -1 THEN 0 ELSE 1 END), 0) <> 0
                                    THEN N''0'' ELSE NULL END,
            KocanNo        = CASE WHEN FB.TUR = 15 AND
                                      ISNULL((SELECT TOP 1 TRY_CONVERT(INT, DEGER)
                                                FROM GENINI
                                               WHERE BOLUM = -24030 AND DIL IN (-1, 0)
                                               ORDER BY CASE WHEN DIL = -1 THEN 0 ELSE 1 END), 0) <> 0
                                    THEN 0 ELSE NULL END,
';

    SET @Proc = STUFF(@Proc, @Pos, 0, @Ekle);

    DECLARE @CreatePos int = PATINDEX(N'%CREATE%PROCEDURE%dbo.sp_Api_Belge_Klonla_Json%', @Proc);
    IF @CreatePos = 0
        THROW 51200, 'Update_SQL_183: sp_Api_Belge_Klonla_Json CREATE basligi bulunamadi.', 1;

    SET @Proc = SUBSTRING(@Proc, @CreatePos, LEN(@Proc));
    SET @Proc = STUFF(@Proc, 1, CHARINDEX(N'PROCEDURE', UPPER(@Proc)) + LEN(N'PROCEDURE') - 1,
                      N'ALTER PROCEDURE');
    EXEC sp_executesql @Proc;
END
