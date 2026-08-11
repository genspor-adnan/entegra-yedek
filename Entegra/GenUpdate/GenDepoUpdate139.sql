-- ============================================================
-- GenDepoUpdate139.sql
-- EKSIK FIYAT SATIRLARI -> SUNUCUYA
--
-- UFiyatDegisiklik.EksikFiyatlariEkle: tanimli her fiyat adi icin eksik
--   STOKFIYAT/FIYATLAR satirlarini istemci dongusunde (fiyat adi basina 2 INSERT)
--   ekliyordu; fiyat listesi cogaldikca ekran acilisi yavasliyordu. Tek set-based SP.
--
-- NOT: ilac kademe fiyat hesabi (imalatci/depocu) BU DOSYADAN CIKARILDI - ozellik
--   kullanilmiyor (kullanici karari 10.08.2026). Pascal tarafi eski haliyle duruyor.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- EKSIK FIYAT SATIRLARI: her stok/hizmet icin tanimli her fiyat adinda satir
--   {"Dil":0,"Kur":"TL"}  (GENINI -1007 satis adlari, -1008 alis adlari)
--   Eskiden fiyat adi basina 2 INSERT calisiyordu (istemci dongusu).
-- CIKTI: {"Sonuc":1,"Stok":n,"Hizmet":n}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Fiyat_EksikleriEkle_Json
    @Kosullar NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Dil INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Dil') AS INT), 0);
    DECLARE @Kur NVARCHAR(5) = ISNULL(JSON_VALUE(@Kosullar, '$.Kur'), N'TL');

    -- Fiyat adlari: satis (-1007) ve alis (-1008)
    DECLARE @Ad TABLE (FiyatAdi INT, Satis BIT, PRIMARY KEY (FiyatAdi, Satis));
    INSERT @Ad (FiyatAdi, Satis)
    SELECT DISTINCT DEGER, 1 FROM GENINI WHERE BOLUM = -1007 AND DIL = @Dil AND DEGER IS NOT NULL
    UNION
    SELECT DISTINCT DEGER, 0 FROM GENINI WHERE BOLUM = -1008 AND DIL = @Dil AND DEGER IS NOT NULL;

    -- Dil bulunamazsa -1 (dilsiz) satirlarina dus
    IF NOT EXISTS (SELECT 1 FROM @Ad)
        INSERT @Ad (FiyatAdi, Satis)
        SELECT DISTINCT DEGER, 1 FROM GENINI WHERE BOLUM = -1007 AND DEGER IS NOT NULL
        UNION
        SELECT DISTINCT DEGER, 0 FROM GENINI WHERE BOLUM = -1008 AND DEGER IS NOT NULL;

    DECLARE @Stok INT = 0, @Hizmet INT = 0;

    BEGIN TRAN;

    -- STOKLAR: ana birim + (varsa) 2. birim
    INSERT INTO dbo.STOKFIYAT (STOKID, FIYATADI, BIRIM, FIYAT, KUR, KDVDURUM, PAKETID, SATIS)
    SELECT S.ID, A.FiyatAdi, B.Birim, -1.0, @Kur, 0, 0, A.Satis
    FROM dbo.STOKLAR S
        CROSS JOIN @Ad A
        CROSS APPLY (SELECT Birim = S.ANABIRIM
                     UNION
                     SELECT S.BIRIM2 WHERE ISNULL(S.BIRIM2, 0) <> ISNULL(S.ANABIRIM, 0)) B
    WHERE B.Birim IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.STOKFIYAT SF
                      WHERE SF.STOKID = S.ID AND SF.BIRIM = B.Birim
                        AND SF.FIYATADI = A.FiyatAdi AND SF.SATIS = A.Satis);
    SET @Stok = @@ROWCOUNT;

    -- MASRAFGELIR (hizmetler)
    INSERT INTO dbo.FIYATLAR (HIZMETID, FIYATADI, FIYAT, KUR, KDVDURUM, PAKETID, SATIS)
    SELECT H.ID, A.FiyatAdi, -1.0, @Kur, 0, 0, A.Satis
    FROM dbo.MASRAFGELIR H
        CROSS JOIN @Ad A
    WHERE NOT EXISTS (SELECT 1 FROM dbo.FIYATLAR F
                      WHERE F.HIZMETID = H.ID AND F.FIYATADI = A.FiyatAdi AND F.SATIS = A.Satis);
    SET @Hizmet = @@ROWCOUNT;

    COMMIT;

    SELECT Sonuc = 1, Stok = @Stok, Hizmet = @Hizmet FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_Fiyat_EksikleriEkle_Json TO gentegre_api;
END
GO
