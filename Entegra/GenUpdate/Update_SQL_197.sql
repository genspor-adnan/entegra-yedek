-- Update_SQL_197: Cari listesi - "Detay" (CRM=1) + Son/Sik Aranan (Mod 3/5) birlikte hata.
--
-- sp_Prog_Cari_Liste_Json2, CRM=1 iken sorguyu 'select * from ( ... ) as cc' ile sarar; Mod 3/5
-- icin eklenen 'ORDER BY KA.DEGISTIRMETARIHI / KA.SAY' sarmalamanin DISINDA kalinca KA takma
-- adi gorunmez -> "The multi-part identifier KA.DEGISTIRMETARIHI could not be bound".
-- Cozum: Mod 3/5'te KA kolonlari SELECT listesine alias'la eklenir (KA_DEGISTIRMETARIHI, KA_SAY),
-- ORDER BY bu alias'lari kullanir; sarmali/sarmasiz ikisinde de calisir.
-- Canli tanim yerinde yamalanir (188/195/196 deseni), idempotent, veri degismez.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @Sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_Cari_Liste_Json2'));
IF @Sql IS NULL THROW 51200, N'sp_Prog_Cari_Liste_Json2 bulunamadi.', 1;
IF CHARINDEX(N'KA_DEGISTIRMETARIHI', @Sql) > 0
    PRINT N'Update197: sp_Prog_Cari_Liste_Json2 zaten yamali - atlandi.';
ELSE IF (LEN(@Sql) - LEN(REPLACE(@Sql, N'DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'''');', N''))) / LEN(N'DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'''');') <> 1
      OR CHARINDEX(N'ORDER BY KA.DEGISTIRMETARIHI DESC', @Sql) = 0 OR CHARINDEX(N'ORDER BY KA.SAY DESC', @Sql) = 0
    THROW 51200, N'Update197: beklenen ifadeler bulunamadi, SP elle kontrol edilmeli.', 1;
ELSE
BEGIN
    SET @Sql = REPLACE(@Sql, N'DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'''');', N'DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'''');
    -- Update197: Son/Sik (Mod 3/5) siralama kolonlari SELECT listesine alias''la alinir; CRM=1
    --   sarmalamasi (select * from (...) cc) disinda KA gorunmez -> "KA.DEGISTIRMETARIHI could not be bound".
    IF ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,''$.Mod'') AS SMALLINT), 0) IN (3, 5)
       AND JSON_VALUE(@Kosullar,''$.KulId'') IS NOT NULL AND JSON_VALUE(@Kosullar,''$.Modul'') IS NOT NULL
        SET @SelectList = @SelectList + N'', KA.DEGISTIRMETARIHI AS KA_DEGISTIRMETARIHI, KA.SAY AS KA_SAY'';');
    SET @Sql = REPLACE(@Sql, N'ORDER BY KA.DEGISTIRMETARIHI DESC', N'ORDER BY KA_DEGISTIRMETARIHI DESC');
    SET @Sql = REPLACE(@Sql, N'ORDER BY KA.SAY DESC', N'ORDER BY KA_SAY DESC');
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE dbo.sp_Prog_Cari_Liste_Json2', N'ALTER PROCEDURE dbo.sp_Prog_Cari_Liste_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE OR ALTER PROCEDURE dbo.sp_Prog_Cari_Liste_Json2', N'ALTER PROCEDURE dbo.sp_Prog_Cari_Liste_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE dbo.sp_Prog_Cari_Liste_Json2', N'ALTER PROCEDURE dbo.sp_Prog_Cari_Liste_Json2');
    IF CHARINDEX(N'ALTER PROCEDURE dbo.sp_Prog_Cari_Liste_Json2', @Sql) = 0
        THROW 51200, N'Update197: SP basligi cozulemedi.', 1;
    EXEC sp_executesql @Sql;
    PRINT N'Update197: sp_Prog_Cari_Liste_Json2 Son/Sik siralamasi CRM sarmalamasiyla uyumlu hale getirildi.';
END
GO
