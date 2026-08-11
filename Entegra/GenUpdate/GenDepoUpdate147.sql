-- ============================================================
-- GenDepoUpdate147.sql
-- MESAJLASMA: KISI LISTESI (sol panelde "Kişiler" bolumu)
--
-- Sol panel WhatsApp duzeni: ustte arama, altta "Sohbetler" (mevcut kanallar),
--   onun altinda "Kişiler" (sistemde kullanicisi olan personel). Kisiye tiklayinca
--   birebir kanal acilir/bulunur (sp_Api_Mesaj_Kanal_Kaydet_Json / Islem=birebir).
--
-- Kaynak: KULLANICI (aktif) + REHBER. Kendisi haric.
--   @Kosullar: {"KulId":n,"Ara":"","TopN":200}
-- Cikti SATIR KUMESI (Json2 deseninde JSON yalnizca GIRDIdir).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Kisi_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- ListeSPJson imza uyumu (kullanilmiyor)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.Ara'), N'');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 200);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        REHBERID = R.ID,
        ADI      = R.FIRMA,
        KOD      = R.KOD,
        -- Zaten acik birebir sohbet varsa ID'si (liste iki kez gostermesin diye)
        KANALID  = dbo.fn_Prog_Mesaj_BirebirKanal(@KulId, R.ID)
    FROM dbo.KULLANICI K
        INNER JOIN dbo.REHBER R ON R.ID = K.REHBERID
    WHERE ISNULL(K.DURUM, 0) = 1
      AND R.ID <> @KulId
      AND (@Ara IS NULL OR R.FIRMA LIKE N'%' + @Ara + N'%' OR R.KOD LIKE N'%' + @Ara + N'%')
    ORDER BY R.FIRMA;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kisi_Liste_Json2 TO gentegre_api;
GO
