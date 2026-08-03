SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_Prog_EBelge_GidenFaturaDetay
    @invoiceId int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.FATBASLIK
        WHERE ID = @invoiceId
          AND TUR IN (14, 15)
    )
        THROW 50003, 'Giden e-Fatura/e-Irsaliye kaydi bulunamadi.', 1;

    SELECT
        F.*,
        LineNumber = ROW_NUMBER() OVER
        (
            ORDER BY CASE WHEN ISNULL(F.SIRA, 0) = 0 THEN 2147483647 ELSE F.SIRA END, F.ID
        ),
        ProductName = CASE
            WHEN F.TUR IN (1, 11) THEN S.STOKADI
            ELSE MG.AD
        END,
        ProductCode = CASE
            WHEN F.TUR IN (1, 11) THEN S.KOD
            ELSE MG.KOD
        END,
        BuyersItemCode = CASE
            WHEN R.OZELKOD = N'DMO' AND F.TUR IN (1, 11) THEN SU.SMKODU
            WHEN ISNULL(R.OZELKOD, N'') <> N'DMO' AND F.TUR IN (1, 11) THEN S.KOD
            ELSE MG.KOD
        END,
        ManufacturersItemCode = CASE
            WHEN F.TUR IN (1, 11) THEN S.URUNNO
            ELSE MG.KOD
        END,
        -- GTIN (StandardItemIdentification) stok kartinda URUNNO
        BARKOD = CASE
            WHEN F.TUR IN (1, 11) THEN ISNULL(S.URUNNO, N'')
            ELSE N''
        END,
        UnitName = U.ANAHTAR,
        UnitCodeConverted = CASE F.BIRIM
            WHEN 10 THEN 'MIN' -- Dakika
            WHEN 11 THEN 'HUR' -- Saat
            WHEN 12 THEN 'DAY' -- Gun
            WHEN 51 THEN 'C62' -- Adet
            WHEN 52 THEN 'MTR' -- Metre
            WHEN 53 THEN 'CS'  -- Koli
            WHEN 54 THEN 'SET' -- Set
            WHEN 55 THEN 'SET' -- Takim
            WHEN 56 THEN 'BX'  -- Kutu
            WHEN 57 THEN 'KGM' -- Kg
            WHEN 58 THEN 'MTK' -- m2
            WHEN 59 THEN 'PF'  -- Palet
            ELSE 'C62'
        END,
        ModelName = CASE
            WHEN R.OZELKOD = N'DMO' AND F.TUR IN (1, 11) THEN ISNULL(SU.SUTKODU, N'')
            WHEN F.TUR IN (1, 11) THEN ISNULL(MODELG.ANAHTAR, N'')
            ELSE N''
        END,
        BrandName = CASE
            WHEN FB.TUR = 14 AND R.OZELKOD = N'DMO' AND F.TUR IN (1, 11)
                THEN ISNULL(SU.DMOKODU, N'')
            WHEN FB.TUR = 15 AND R.OZELKOD = N'IHALE' AND F.TUR IN (1, 11)
                THEN ISNULL(SU.IHALESIRANO, N'')
            WHEN F.TUR IN (1, 11)
                THEN ISNULL(MARKA.ANAHTAR, N'')
            ELSE N''
        END,
        ManufacturerName = CASE
            WHEN F.TUR IN (1, 11) THEN ISNULL(MARKA.ANAHTAR, N'')
            ELSE N''
        END,
        SERINO = ISNULL(IZLEM.SERINO, N''),
        LOTNO = ISNULL(IZLEM.LOTNO, N''),
        AdditionalItemIdentification = ISNULL(dbo.fn_Efatura_AdditionalItemIdentification(F.FATBASID, F.ID), ''),
        Note = ISNULL(IZLEM.Note, N''),
        GTIP = ISNULL(S.GTIP, N'')   -- ihracat: satir bazli GTIP (yalniz urun satiri; STOKLAR join F.TUR IN(1,11))
    FROM dbo.FATURA F
    INNER JOIN dbo.FATBASLIK FB ON FB.ID = F.FATBASID
    INNER JOIN dbo.REHBER R ON R.ID = FB.REHBERID
    LEFT JOIN dbo.STOKLAR S
        ON S.ID = F.URUNID
       AND F.TUR IN (1, 11)
    LEFT JOIN dbo.STOKLAR_USER SU
        ON SU.ID = S.ID
    LEFT JOIN dbo.MASRAFGELIR MG
        ON MG.ID = F.URUNID
       AND F.TUR NOT IN (1, 11)
    OUTER APPLY
    (
        SELECT TOP (1) G.ANAHTAR
        FROM dbo.GENINI G
        WHERE G.BOLUM = -2702
          AND G.DIL = -1
          AND G.DEGER = F.BIRIM
        ORDER BY G.SIRA
    ) U
    OUTER APPLY
    (
        SELECT TOP (1) G.ANAHTAR
        FROM dbo.GENINI G
        WHERE G.BOLUM = -2701
          AND G.DIL = -1
          AND G.DEGER = S.MARKA
        ORDER BY G.SIRA
    ) MARKA
    OUTER APPLY
    (
        -- Model markaya bagli: GENINI bolumu '-2701'+MARKA seklinde
        SELECT TOP (1) G.ANAHTAR
        FROM dbo.GENINI G
        WHERE G.BOLUM = CONVERT(int, N'-2701' + CONVERT(varchar(10), S.MARKA))
          AND G.DIL = -1
          AND G.DEGER = S.MODEL
        ORDER BY G.SIRA
    ) MODELG
    OUTER APPLY
    (
        SELECT
            SERINO = STUFF
            (
                (
                    SELECT N', ' + SL.SERINO
                    FROM dbo.STOKIZLEME SI
                    INNER JOIN dbo.STOKSERILOT SL ON SL.ID = SI.SERILOTID
                    WHERE SI.BASLIKID = F.FATBASID
                      AND SI.SATIRID = F.ID
                      AND SI.STOKID = F.URUNID
                      AND ISNULL(SL.SERINO, N'') <> N''
                    ORDER BY SI.ID
                    FOR XML PATH(''), TYPE
                ).value('.', 'nvarchar(max)'),
                1, 2, N''
            ),
            LOTNO = STUFF
            (
                (
                    SELECT N', ' + COALESCE(NULLIF(SL.LOTNO, N''), NULLIF(SL.LOTNO_EX, N''))
                    FROM dbo.STOKIZLEME SI
                    INNER JOIN dbo.STOKSERILOT SL ON SL.ID = SI.SERILOTID
                    WHERE SI.BASLIKID = F.FATBASID
                      AND SI.SATIRID = F.ID
                      AND SI.STOKID = F.URUNID
                      AND COALESCE(NULLIF(SL.LOTNO, N''), NULLIF(SL.LOTNO_EX, N'')) IS NOT NULL
                    ORDER BY SI.ID
                    FOR XML PATH(''), TYPE
                ).value('.', 'nvarchar(max)'),
                1, 2, N''
            ),
            Note = STUFF
            (
                (
                    SELECT
                        CHAR(13) + CHAR(10) +
                        CONCAT
                        (
                            CASE WHEN ISNULL(SL.SERINO, N'') <> N''
                                THEN N'Seri No: ' + SL.SERINO + N' ' ELSE N'' END,
                            CASE WHEN COALESCE(NULLIF(SL.LOTNO, N''), NULLIF(SL.LOTNO_EX, N'')) IS NOT NULL
                                THEN N'Lot No: ' + COALESCE(NULLIF(SL.LOTNO, N''), SL.LOTNO_EX) + N' ' ELSE N'' END,
                            CASE WHEN SL.URT > CONVERT(datetime, '19900101', 112)
                                THEN N'Üretim Tarihi: ' + CONVERT(nvarchar(10), SL.URT, 104) + N' ' ELSE N'' END,
                            CASE WHEN SL.SKT > CONVERT(datetime, '19900101', 112)
                                THEN N'Son Kullanma Tarihi: ' + CONVERT(nvarchar(10), SL.SKT, 104) + N' ' ELSE N'' END,
                            CASE WHEN SI.ADET IS NOT NULL
                                THEN N'Miktar: ' + CONVERT(nvarchar(50), CONVERT(decimal(18, 6), SI.ADET)) ELSE N'' END
                        )
                    FROM dbo.STOKIZLEME SI
                    INNER JOIN dbo.STOKSERILOT SL ON SL.ID = SI.SERILOTID
                    WHERE SI.BASLIKID = F.FATBASID
                      AND SI.SATIRID = F.ID
                      AND SI.STOKID = F.URUNID
                    ORDER BY SI.ID
                    FOR XML PATH(''), TYPE
                ).value('.', 'nvarchar(max)'),
                1, 2, N''
            )
    ) IZLEM
    WHERE F.FATBASID = @invoiceId
    ORDER BY LineNumber;
END;
