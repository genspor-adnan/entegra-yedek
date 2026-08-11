-- ============================================================
-- GenDepoUpdate150.sql
-- MESAJLASMA: KANAL UYE LISTESI (sag taraftaki "sohbet bilgisi" bolumu)
--
-- Sohbet basligindaki avatara tiklayinca acilan panel bunu kullanir:
--   grupta uyeler (yonetici isaretli), birebirde karsi taraf.
--   @Kosullar: {"KulId":n,"KanalId":n}
-- Cikti SATIR KUMESI (Json2 deseni: JSON yalnizca GIRDIdir).
--
-- Yetki: yalnizca kanalin UYESI listeyi gorebilir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Uye_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- ListeSPJson imza uyumu (kullanilmiyor)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @KanalId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT), 0);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;
    IF @KanalId <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    SELECT
        REHBERID = R.ID,
        ADI      = R.FIRMA,
        KOD      = R.KOD,
        ROL      = CAST(U.ROL AS INT),                 -- 1 = grup yoneticisi
        BEN      = CASE WHEN R.ID = @KulId THEN 1 ELSE 0 END,
        RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.REHBER R ON R.ID = U.REHBERID
    WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NULL
    ORDER BY U.ROL DESC, R.FIRMA;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Uye_Liste_Json2 TO gentegre_api;
GO
