-- ============================================================
-- GenDepoUpdate163.sql
-- MESAJLASMA: sohbeti "okunmadi" isaretleme
--
--   Okundu isaretleme zaten var (sp_Api_Mesaj_Okundu_Json - imleci en sona alir).
--   Bunun tersi: okundu imlecini SON GELEN mesajin BIR GERISINE alir, boylece
--   sohbet listesinde okunmamis rozeti (1) yeniden cikar.
--
--   Kendi yazdiklarimiz okunmamis sayilmaz; imlec yalniz KARSI TARAFTAN gelen
--   son mesaja gore ayarlanir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Okunmadi_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    -- Karsi taraftan gelen SON mesaj (silinmis ve kendimden gizlenmisler haric)
    DECLARE @Son BIGINT =
        (SELECT MAX(M.ID) FROM dbo.MESAJ M
          WHERE M.KANALID = @KanalId AND M.GONDERENID <> @KulId AND M.SILINDI = 0
            AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                             WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId));

    IF @Son IS NOT NULL
        UPDATE dbo.MESAJKANALUYE
           SET SONOKUMAID = CASE WHEN @Son - 1 < BASLANGICID THEN BASLANGICID ELSE @Son - 1 END
         WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL;

    SELECT Sonuc = 1, KanalId = @KanalId, SonMesajId = @Son
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Okunmadi_Json TO gentegre_api;
GO
