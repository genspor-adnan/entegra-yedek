-- Update_SQL_196: Liste ekranlarinda "Ek Alanlar Listele" (UFaturalar / FaturalarAramaFrame).
--
-- Ek alanlar artik ana tabloda degil FATBASLIK_USER / SIPARIS_USER tablolarinda (ALANLAR.TABLO
-- = '<Tablo>_USER'); liste SP'leri @Baslik (SELECT ek kolonlari) parametresini alsa da bu
-- tablolari join'lemiyordu -> ek alan kolonlari sorguya girince "Invalid column name" olur,
-- kod tarafi ise ALANLAR'da 'FATBASLIK' aradigi icin hic kolon uretmiyordu (grid bos).
-- Simdi: @Baslik doluysa (yalniz kutu isaretliyken) ' LEFT JOIN <Tablo>_USER FU ON FU.ID=F.ID'
-- eklenir; app kolonlari 'FU.[ALAN] AS [ALAN]' olarak gonderir (UFaturalar.EkAlanlariGetir).
-- @Baslik bos iken SP sorgusu degismez - _USER tablosu olmayan DB'de liste etkilenmez.
-- Canli tanim yerinde yamalanir (188/195 deseni), idempotent, veri degismez.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ---------------------------------------------------------------- sp_Prog_AlisSatis_IrsFatFisKons_Json2
DECLARE @Sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2'));
IF @Sql IS NULL THROW 51200, N'sp_Prog_AlisSatis_IrsFatFisKons_Json2 bulunamadi.', 1;
DECLARE @Eski NVARCHAR(400) = N'FROM FATBASLIK F WITH (NOLOCK)';
DECLARE @Yeni NVARCHAR(400) = N'FROM FATBASLIK F WITH (NOLOCK)'' + CASE WHEN ISNULL(@Baslik, '''') <> '''' THEN '' LEFT JOIN FATBASLIK_USER FU WITH (NOLOCK) ON FU.ID = F.ID'' ELSE '''' END + ''';
IF CHARINDEX(N'FATBASLIK_USER FU', @Sql) > 0
    PRINT N'Update196: sp_Prog_AlisSatis_IrsFatFisKons_Json2 zaten FATBASLIK_USER join''li - atlandi.';
ELSE IF (LEN(@Sql) - LEN(REPLACE(@Sql, @Eski, N''))) / LEN(@Eski) <> 1
    THROW 51200, N'Update196: sp_Prog_AlisSatis_IrsFatFisKons_Json2 icinde beklenen FROM ifadesi tam bir kez bulunamadi, elle kontrol edin.', 1;
ELSE
BEGIN
    SET @Sql = REPLACE(@Sql, @Eski, @Yeni);
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE OR ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    IF CHARINDEX(N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', @Sql) = 0
        THROW 51200, N'Update196: sp_Prog_AlisSatis_IrsFatFisKons_Json2 basligi cozulemedi.', 1;
    EXEC sp_executesql @Sql;
    PRINT N'Update196: sp_Prog_AlisSatis_IrsFatFisKons_Json2 -> FATBASLIK_USER join eklendi.';
END
GO

-- ---------------------------------------------------------------- sp_Prog_AlisSatis_Siparis_Json2
DECLARE @Sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_AlisSatis_Siparis_Json2'));
IF @Sql IS NULL THROW 51200, N'sp_Prog_AlisSatis_Siparis_Json2 bulunamadi.', 1;
DECLARE @Eski NVARCHAR(400) = N'from SIPARIS F (NOLOCK) inner join REHBER R on R.ID = F.REHBERID ';
DECLARE @Yeni NVARCHAR(400) = N'from SIPARIS F (NOLOCK) inner join REHBER R on R.ID = F.REHBERID '' + CASE WHEN ISNULL(@Baslik, '''') <> '''' THEN '' LEFT JOIN SIPARIS_USER FU (NOLOCK) ON FU.ID = F.ID '' ELSE '''' END + ''';
IF CHARINDEX(N'SIPARIS_USER FU', @Sql) > 0
    PRINT N'Update196: sp_Prog_AlisSatis_Siparis_Json2 zaten SIPARIS_USER join''li - atlandi.';
ELSE IF (LEN(@Sql) - LEN(REPLACE(@Sql, @Eski, N''))) / LEN(@Eski) <> 1
    THROW 51200, N'Update196: sp_Prog_AlisSatis_Siparis_Json2 icinde beklenen FROM ifadesi tam bir kez bulunamadi, elle kontrol edin.', 1;
ELSE
BEGIN
    SET @Sql = REPLACE(@Sql, @Eski, @Yeni);
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE OR ALTER PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2');
    IF CHARINDEX(N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2', @Sql) = 0
        THROW 51200, N'Update196: sp_Prog_AlisSatis_Siparis_Json2 basligi cozulemedi.', 1;
    EXEC sp_executesql @Sql;
    PRINT N'Update196: sp_Prog_AlisSatis_Siparis_Json2 -> SIPARIS_USER join eklendi.';
END
GO
