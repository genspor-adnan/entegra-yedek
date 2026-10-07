-- Update_SQL_201: Izibiz dovizli e-Fatura satir tutarliligi.
--
-- FATBASLIK.FATURADOVIZI TL/TRY disindaysa e-belge satirlarinda TL tutarlari
-- yerine FATURA.DOVIZ_BIRIMFIYAT ve FATURA.DOVIZ_TUTARI kullanilir.
-- Canli SP tanimi yerinde ve idempotent bicimde guncellenir; veri degismez.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @Sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_EBelge_GidenFaturaDetay'));
IF @Sql IS NULL
    THROW 51200, N'sp_Prog_EBelge_GidenFaturaDetay bulunamadi.', 1;

IF CHARINDEX(N'EBelgeBirimFiyat = CASE', @Sql) > 0
BEGIN
    PRINT N'Update201: dovizli e-belge satir alanlari zaten guncel - atlandi.';
END
ELSE
BEGIN
    DECLARE @Eski NVARCHAR(100) = N'        F.*,';
    DECLARE @Yeni NVARCHAR(MAX) = N'        F.*,
        EBelgeBirimFiyat = CASE
            WHEN UPPER(LTRIM(RTRIM(ISNULL(FB.FATURADOVIZI, N''TL'')))) NOT IN (N'''', N''TL'', N''TRY'', N''YTL'')
                THEN ISNULL(F.DOVIZ_BIRIMFIYAT, F.BIRIMFIYAT)
            ELSE F.BIRIMFIYAT
        END,
        EBelgeTutar = CASE
            WHEN UPPER(LTRIM(RTRIM(ISNULL(FB.FATURADOVIZI, N''TL'')))) NOT IN (N'''', N''TL'', N''TRY'', N''YTL'')
                THEN ISNULL(F.DOVIZ_TUTARI, F.TUTAR)
            ELSE F.TUTAR
        END,';

    IF CHARINDEX(@Eski, @Sql) = 0
        THROW 51200, N'Update201: beklenen F.* secim ifadesi bulunamadi; SP elle kontrol edilmeli.', 1;

    SET @Sql = REPLACE(@Sql, @Eski, @Yeni);
    SET @Sql = REPLACE(@Sql, N'CREATE OR ALTER PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay', N'ALTER PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay');
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay', N'ALTER PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay', N'ALTER PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay');

    IF CHARINDEX(N'ALTER PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay', @Sql) = 0
        THROW 51200, N'Update201: SP basligi cozulemedi.', 1;

    EXEC sp_executesql @Sql;
    PRINT N'Update201: dovizli e-belge satir fiyat ve tutarlari guncellendi.';
END
GO
