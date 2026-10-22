-- Update_SQL_207: Cari ekrani Alis/Satis alt sekmeleri - irsaliye/fatura/fis/konsinye listesi
--   SECILI CARIYE suzulsun.
--
-- Cari ekrani (UReharadlg) alt sekmede sp_Prog_AlisSatis_IrsFatFisKons_Json2'yi
-- '{"TopN":0,"Tur":..,"RehberId":<cari>}' ile cagirir. RehberId filtresi SP dosyasina
-- (GenUpdate\sp_Prog_AlisSatis_IrsFatFisKons_Json2.sql) eklenmis ama hicbir Update ile
-- dagitilmamisti: canli SP '$.RehberId'i okumuyor, o turdeki TUM carilerin belgelerini
-- (TOP'suz) donduruyordu. Sonuc: baska cariye gecince liste degismiyor, cari belgesizse
-- bos gelmiyor ve her cari degisiminde binlerce satir + satir basi alt sorgular -> yavas.
-- (Siparis SP'si sp_Prog_AlisSatis_Siparis_Json2 RehberId'yi zaten okuyor.)
--
-- Canli tanim yerinde yamalanir (195/196 deseni): @RehberId okunur, doluysa
-- 'AND F.REHBERID = <id>' eklenir (NCI_FB_REH_TUR_TARIH indeksi kullanilir).
-- Idempotent ('$.RehberId' zaten varsa atlanir), veri degismez.
--
-- Ayrica iki kapsayan indeks: her iki SP'deki satir basi DURUMNEREDEN/DURUMNEREYE/TESLIMTARIHI
-- alt sorgulari SIPARISDETAY'i SIPARISID'ye, FATURA'yi YERID'ye gore okuyup YERI'ye bakiyor;
-- mevcut tek kolonlu indeksler YERI'yi icermedigi icin her satirda anahtar aramasi + spool
-- olusuyordu (en kalabalik caride siparis listesi ~1,1 sn -> ~0,5 sn).

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @Sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2'));
IF @Sql IS NULL THROW 51200, N'sp_Prog_AlisSatis_IrsFatFisKons_Json2 bulunamadi.', 1;
DECLARE @Eski1 NVARCHAR(400) = N'CREATE TABLE #SubeIDs (ID SMALLINT);';
DECLARE @Yeni1 NVARCHAR(400) = N'-- Belirli cariye ait belgeler (cari ekrani Alis/Satis alt sekmesi) - Update_SQL_207
    DECLARE @RehberId INT = TRY_CAST(JSON_VALUE(@Kosullar,''$.RehberId'') AS INT);
CREATE TABLE #SubeIDs (ID SMALLINT);';
DECLARE @Eski2 NVARCHAR(400) = N'SET @SQL += ''  WHERE F.TUR = @Tur'';';
DECLARE @Yeni2 NVARCHAR(400) = N'SET @SQL += ''  WHERE F.TUR = @Tur'';
    IF ISNULL(@RehberId, 0) > 0
        SET @SQL += '' AND F.REHBERID = '' + CAST(@RehberId AS NVARCHAR(20));';
IF CHARINDEX(N'$.RehberId', @Sql) > 0
    PRINT N'Update207: sp_Prog_AlisSatis_IrsFatFisKons_Json2 zaten RehberId suzgecli - atlandi.';
ELSE IF (LEN(@Sql) - LEN(REPLACE(@Sql, @Eski1, N''))) / LEN(@Eski1) <> 1
     OR (LEN(@Sql) - LEN(REPLACE(@Sql, @Eski2, N''))) / LEN(@Eski2) <> 1
    THROW 51200, N'Update207: sp_Prog_AlisSatis_IrsFatFisKons_Json2 icinde beklenen ifadeler tam bir kez bulunamadi, elle kontrol edin.', 1;
ELSE
BEGIN
    SET @Sql = REPLACE(@Sql, @Eski1, @Yeni1);
    SET @Sql = REPLACE(@Sql, @Eski2, @Yeni2);
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE [dbo].[sp_Prog_AlisSatis_IrsFatFisKons_Json2]', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE   PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE OR ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    SET @Sql = REPLACE(@Sql, N'CREATE PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2');
    IF CHARINDEX(N'ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2', @Sql) = 0
        THROW 51200, N'Update207: sp_Prog_AlisSatis_IrsFatFisKons_Json2 basligi cozulemedi.', 1;
    EXEC sp_executesql @Sql;
    PRINT N'Update207: sp_Prog_AlisSatis_IrsFatFisKons_Json2 -> RehberId suzgeci eklendi.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SIPARISDETAY') AND name = 'IX_SIPARISDETAY_SIPARISID_YERI')
    CREATE INDEX IX_SIPARISDETAY_SIPARISID_YERI ON dbo.SIPARISDETAY (SIPARISID) INCLUDE (YERI, YERID, TESLIMTARIHI);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.FATURA') AND name = 'IX_FATURA_YERID_YERI')
    CREATE INDEX IX_FATURA_YERID_YERI ON dbo.FATURA (YERID) INCLUDE (YERI);
GO
