-- ============================================================
-- GenDepoUpdate73.sql
-- API: donusum KALAN hesabi + sunucu tarafi asiri-donusum kontrolu
--   dbo.fn_Api_Donusum_Kalan        : bir kaynak satirin donusen / kalan miktari
--   dbo.sp_Api_Donusum_Kontrol_Json : istenen miktar donusturulebilir mi
--
-- NEDEN
--   Bugun "kalan" hesabi sp_Prog_BelgeDonusum_Kaynak_Json2 icinde INLINE ve
--   UBelgeDonusum.BtnSecClick istemcide "KALAN > 0.0001" diye bakiyor. Iki
--   kullanici ayni siparis satirini AYNI ANDA donusturmeye kalkarsa ikisi de
--   gecer - kaynak satir asiri donusur. Kontrol sunucuda ve donusumu yazan
--   transaction'in ICINDE olmali.
--
-- KALAN FORMULU (sp_Prog_BelgeDonusum_Kaynak_Json2'deki uc dalin aynisi)
--   @Kaynak = 1  TEKLIF  (TEKLIFDETAY -> SIPARISDETAY)
--       donusen = SUM(SIPARISDETAY.ADET WHERE YERI=@DonusumTuru)
--               + SUM(SIPARISDETAY.ADET WHERE YERI=416)          -- iade
--   @Kaynak = 2  SIPARIS (SIPARISDETAY -> SIPARISDETAY / FATURA / URETIMEMRIDETAY)
--       donusen = |SUM(SIPARISDETAY.ADET WHERE YERI=@DonusumTuru)|
--               + |SUM(hedef.ADET WHERE URUNID=kaynak.URUNID AND YERI=@DonusumTuru)|
--         hedef: @HedefUretim=1 -> URETIMEMRIDETAY, degilse FATURA
--   @Kaynak = 3  FATBASLIK (FATURA -> FATURA)
--       donusen = SUM(FATURA.ADET WHERE YERI=@DonusumTuru
--                     OR (@DonusumTuru=411 AND YERI=424))          -- satis irs->fat/fis
--               + SUM(FATURA.ADET WHERE YERI=416)                  -- iade
--   kalan = kaynak.ADET - donusen
--
-- GIRDI (Kontrol):
--   {"Kaynak":2,"DonusumTuru":409,"HedefUretim":false,
--    "Satirlar":[{"SatirId":156958,"Adet":3}]}
-- CIKTI:
--   {"Sonuc":1,"Uygun":1,"Satirlar":[{"SatirId":..,"Adet":..,"Kalan":..,"Uygun":1,"Neden":""}]}
--   Uygun=0 -> en az bir satirda kalan yetersiz/satir yok.
-- HATA : 51001 zorunlu alan eksik
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION dbo.fn_Api_Donusum_Kalan
(
    @Kaynak      INT,   -- 1=TEKLIF, 2=SIPARIS, 3=FATBASLIK
    @DonusumTuru INT,   -- hedef TabNo (409/410/473/406/407/411/424/...)
    @SatirId     INT,
    @HedefUretim BIT = 0
)
RETURNS TABLE
AS
RETURN
(
    -- 1) TEKLIF
    SELECT Adet = CAST(TD.ADET AS decimal(18,6)),
           Donusen = CAST(
               ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = TD.ID), 0.0)
             + ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = 416            AND F1.YERID = TD.ID), 0.0)
             AS decimal(18,6)),
           Kalan = CAST(TD.ADET
             - ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = TD.ID), 0.0)
             - ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = 416            AND F1.YERID = TD.ID), 0.0)
             AS decimal(18,6))
    FROM TEKLIFDETAY TD
    WHERE @Kaynak = 1 AND TD.ID = @SatirId

    UNION ALL

    -- 2) SIPARIS
    SELECT CAST(SD.ADET AS decimal(18,6)),
           CAST(
               ABS(ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0))
             + ABS(CASE WHEN @HedefUretim = 1
                        THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0)
                        ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0) END)
             AS decimal(18,6)),
           CAST(SD.ADET - (
               ABS(ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0))
             + ABS(CASE WHEN @HedefUretim = 1
                        THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0)
                        ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0) END))
             AS decimal(18,6))
    FROM SIPARISDETAY SD
    WHERE @Kaynak = 2 AND SD.ID = @SatirId

    UNION ALL

    -- 3) FATBASLIK (FATURA satiri)
    SELECT CAST(F.ADET AS decimal(18,6)),
           CAST(
               ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                        WHERE (F1.YERI = @DonusumTuru OR (@DonusumTuru = 411 AND F1.YERI = 424)) AND F1.YERID = F.ID), 0.0)
             + ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI = 416 AND F1.YERID = F.ID), 0.0)
             AS decimal(18,6)),
           CAST(F.ADET
             - ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                        WHERE (F1.YERI = @DonusumTuru OR (@DonusumTuru = 411 AND F1.YERI = 424)) AND F1.YERID = F.ID), 0.0)
             - ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI = 416 AND F1.YERID = F.ID), 0.0)
             AS decimal(18,6))
    FROM FATURA F
    WHERE @Kaynak = 3 AND F.ID = @SatirId
);
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_Kontrol_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kaynak')      AS INT);
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru') AS INT);
    DECLARE @HedefUretim BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefUretim') AS BIT), 0);

    IF @Kaynak IS NULL OR @Kaynak NOT IN (1, 2, 3)
        THROW 51001, N'Kaynak 1 (teklif), 2 (siparis) ya da 3 (belge) olmali.', 1;
    IF @DonusumTuru IS NULL
        THROW 51001, N'DonusumTuru zorunlu.', 1;

    DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6));
    INSERT @S (SatirId, Adet)
    SELECT J.SatirId, ISNULL(J.Adet, 0)
    FROM OPENJSON(@Kosullar, '$.Satirlar') WITH (SatirId INT, Adet DECIMAL(18,6)) J
    WHERE J.SatirId IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @S)
        THROW 51001, N'Satirlar bos olamaz.', 1;

    DECLARE @R TABLE (SatirId INT, Adet DECIMAL(18,6), Kalan DECIMAL(18,6),
                      Uygun BIT, Neden NVARCHAR(60));
    INSERT @R (SatirId, Adet, Kalan, Uygun, Neden)
    SELECT S.SatirId, S.Adet, ISNULL(K.Kalan, 0),
           CASE WHEN K.Kalan IS NULL THEN 0
                WHEN S.Adet <= 0 THEN 0
                -- 0.0001 toleransi UBelgeDonusum.BtnSecClick ile ayni
                WHEN S.Adet > K.Kalan + 0.0001 THEN 0
                ELSE 1 END,
           CASE WHEN K.Kalan IS NULL THEN N'kaynak satir bulunamadi'
                WHEN S.Adet <= 0 THEN N'adet sifir/negatif'
                WHEN S.Adet > ISNULL(K.Kalan, 0) + 0.0001 THEN N'kalan yetersiz'
                ELSE N'' END
    FROM @S S
    OUTER APPLY dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, S.SatirId, @HedefUretim) K;

    DECLARE @Uygun BIT = CASE WHEN EXISTS (SELECT 1 FROM @R WHERE Uygun = 0) THEN 0 ELSE 1 END;

    SELECT (SELECT 1 AS Sonuc, @Uygun AS Uygun,
                   (SELECT SatirId, Adet, Kalan, Uygun, Neden FROM @R ORDER BY SatirId FOR JSON PATH) AS Satirlar
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Donusum_Kontrol_Json TO gentegre_api;
GO
