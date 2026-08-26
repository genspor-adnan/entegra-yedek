-- ======================================================================
-- KONSOLIDE UPDATE 09 - DIGER
-- ======================================================================
-- 2 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- FUNCTION: fn_api_depodbadi  (kaynak: GenDepoUpdate71) ----
CREATE OR ALTER FUNCTION dbo.fn_Api_DepoDBAdi ()
RETURNS sysname
AS
BEGIN
    DECLARE @d sysname = DB_NAME() + N'_GENDEPO';
    IF DB_ID(@d) IS NULL SET @d = N'GENDEPO';
    RETURN @d;
END
GO

-- ---- TRIGGER: trg_uretimemriuser_skt_guncelle  (kaynak: GenDepoUpdate87) ----
CREATE OR ALTER TRIGGER [dbo].[Trg_UretimEmriUser_SKT_Guncelle]
ON [dbo].[URETIMEMRI_USER]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Sonsuz dongu olmasin: SKT'nin kendisi degistiyse tekrar hesaplama.
    --   (recursive triggers KAPALI ama UPDATE(SKT) kontrolu yine de acik yazilmis
    --    bir guvenlik; URT degismediyse is yok.)
    IF UPDATE(SKT) AND NOT UPDATE(URT) RETURN;

    UPDATE UU
       SET SKT = CASE WHEN S.KATEGORI = 7 THEN DATEADD(YEAR, 5, I.URT) ELSE NULL END
      FROM URETIMEMRI_USER UU
           INNER JOIN inserted   I ON I.ID = UU.ID
           INNER JOIN URETIMEMRI U ON U.ID = I.ID
           INNER JOIN STOKLAR    S ON S.ID = U.STOKID
     WHERE I.URT IS NOT NULL;
END
GO
