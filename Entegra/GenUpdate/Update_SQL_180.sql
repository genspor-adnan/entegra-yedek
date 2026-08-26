-- ============================================================
-- Update_SQL_180.sql   (MSSQL)
-- Stok kart kopyalama: paket fiyat baglantisi yeni pakete tasinsin
--
-- Update 177 paket icerigini (PAKETDETAY) klonluyordu. Ancak paket stokta
-- STOKFIYAT.PAKETID kaynak stok ID'si ise, kopya kartta fiyat satiri eski
-- pakete bagli kalabiliyordu. Bu update:
--   1) Eksikse PAKETDETAY klonlama blogunu ekler.
--   2) STOKFIYAT.PAKETID = KaynakId olan kopya fiyatlari YeniId'ye cevirir.
-- Idempotenttir; mevcut sp_Api_Stok_Klonla_Json metnini yerinde patch'ler.
-- ============================================================

DECLARE @Proc nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_Api_Stok_Klonla_Json'));

IF @Proc IS NULL
    THROW 51002, N'sp_Api_Stok_Klonla_Json bulunamadi.', 1;

DECLARE @Eklenecek nvarchar(max) = N'';

IF @Proc NOT LIKE N'%PAKET FIYAT BAGLANTISI (Update_SQL_180)%'
    SET @Eklenecek = @Eklenecek + N'
    -- PAKET FIYAT BAGLANTISI (Update_SQL_180): Kaydet API''si fiyatlari
    --   kaynak PAKETID ile eklediyse kopya paket fiyatlarini yeni pakete bagla.
    UPDATE dbo.STOKFIYAT SET PAKETID = @YeniId
     WHERE STOKID = @YeniId AND PAKETID = @KaynakId;
';

IF @Proc NOT LIKE N'%FROM dbo.PAKETDETAY WHERE PAKETID = @KaynakId%'
    SET @Eklenecek = @Eklenecek + N'
    -- PAKET ICERIGI (Update_SQL_177/180): stok bir PAKET ise bilesenleri
    --   kartin tanimidir; kopyaya da tasinir.
    INSERT INTO dbo.PAKETDETAY (PAKETID, URUNID, BIRIM, ADET, STOK, EKLEYEN, EKLEMETARIHI, SUBEID, TUR)
    SELECT @YeniId,
           CASE WHEN URUNID = @KaynakId THEN @YeniId ELSE URUNID END,
           BIRIM, ADET, STOK, @KulId, GETDATE(), SUBEID, TUR
      FROM dbo.PAKETDETAY WHERE PAKETID = @KaynakId;
';

IF LEN(@Eklenecek) = 0
BEGIN
    PRINT N'sp_Api_Stok_Klonla_Json zaten paket kopyalama duzeltmelerini iceriyor.';
    RETURN;
END;

DECLARE @Marker nvarchar(200) = N'    -- ISLEMLOG izi:';
DECLARE @Pos int = CHARINDEX(@Marker, @Proc);

IF @Pos = 0
BEGIN
    SET @Marker = N'    EXEC dbo.sp_Api_Log_Kaynak_Isaretle';
    SET @Pos = CHARINDEX(@Marker, @Proc);
END;

IF @Pos = 0
    THROW 51003, N'sp_Api_Stok_Klonla_Json patch noktasi bulunamadi.', 1;

SET @Proc = STUFF(@Proc, @Pos, 0, @Eklenecek + CHAR(13) + CHAR(10));

DECLARE @CreatePos int = PATINDEX(N'%CREATE%PROCEDURE%', UPPER(@Proc));
DECLARE @ProcedurePos int;

IF @CreatePos = 0
    THROW 51004, N'sp_Api_Stok_Klonla_Json CREATE PROCEDURE basligi bulunamadi.', 1;

SET @ProcedurePos = CHARINDEX(N'PROCEDURE', UPPER(@Proc), @CreatePos);
SET @Proc = STUFF(@Proc, @CreatePos, @ProcedurePos - @CreatePos + LEN(N'PROCEDURE'), N'ALTER PROCEDURE');

EXEC sys.sp_executesql @Proc;
PRINT N'sp_Api_Stok_Klonla_Json paket kopyalama duzeltmesi uygulandi.';
