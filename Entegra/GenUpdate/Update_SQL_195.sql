-- Update_SQL_195: Fatura/Irsaliye/Fis listesi (UFaturalar grid) ID'ye gore azalan gelsin.
--
-- sp_Prog_AlisSatis_IrsFatFisKons_Json2 sonucu 'ORDER BY F.FATURATARIH DESC' idi; ayni gun
-- icinde eklenen belgeler karisik siralaniyordu (kullanici: "grid ID'ye gore desc gelsin").
-- TOP (@TopN) sayfalamasi ayni ORDER BY'a bagli oldugu icin sayfa buyutme (TSayfaliListe)
-- tutarli kalir. Canli tanim yerinde yamalanir (musteri DB'sindeki surumden bagimsiz);
-- ifade zaten degismisse hicbir sey yapilmaz. Idempotent, veri degismez.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @Sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2'));
IF @Sql IS NULL
    THROW 51200, N'sp_Prog_AlisSatis_IrsFatFisKons_Json2 bulunamadi.', 1;

DECLARE @Eski NVARCHAR(200) = N''' ORDER BY F.FATURATARIH DESC''';
DECLARE @Yeni NVARCHAR(200) = N''' ORDER BY F.ID DESC''';

IF CHARINDEX(@Eski, @Sql) = 0
BEGIN
    IF CHARINDEX(@Yeni, @Sql) > 0
        PRINT N'Update195: siralama zaten F.ID DESC - atlandi.';
    ELSE
        THROW 51200, N'Update195: beklenen ORDER BY ifadesi bulunamadi, SP elle kontrol edilmeli.', 1;
END
ELSE
BEGIN
    SET @Sql = REPLACE(@Sql, @Eski, @Yeni);
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE OR ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    IF CHARINDEX(N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', @Sql) = 0
        THROW 51200, N'Update195: SP basligi cozulemedi.', 1;
    EXEC sp_executesql @Sql;
    PRINT N'Update195: sp_Prog_AlisSatis_IrsFatFisKons_Json2 siralamasi F.ID DESC yapildi.';
END
GO
