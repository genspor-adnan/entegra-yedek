-- ============================================================
-- GenDepoUpdate148.sql
-- MESAJLASMA: sohbet listesine "yalniz okunmamis" filtresi + avatar bilgisi
--
--   1) Sol paneldeki filtre cipleri (Tumu / Okunmamis N) icin @Kosullar'a
--      "YalnizOkunmamis":1 eklendi.
--   2) Avatar: birebir sohbette karsi tarafin, kisi listesinde kisinin
--      FOTOGRAFI olup olmadigi (RESIMVAR) donuyor. Blob'un KENDISI listede
--      TASINMAZ (yavaslatir); istemci yalnizca gorunen satirlar icin okur.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Kanal_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.Ara'), N'');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 100);
    DECLARE @Okunmamis BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YalnizOkunmamis') AS BIT), 0);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        KANALID    = K.ID,
        TUR        = K.TUR,
        ADI        = CASE WHEN K.TUR = 2 THEN K.ADI ELSE KS.FIRMA END,
        KARSIID    = CASE WHEN K.TUR = 1 THEN KS.ID END,
        RESIMVAR   = CASE WHEN K.TUR = 1 AND KS.RESIM IS NOT NULL THEN 1 ELSE 0 END,
        UYESAYISI  = (SELECT COUNT(*) FROM dbo.MESAJKANALUYE X
                       WHERE X.KANALID = K.ID AND X.AYRILMATARIHI IS NULL),
        SONMESAJ   = LEFT(ISNULL(SM.METIN, CASE WHEN SM.DOSYAID IS NOT NULL THEN N'[dosya] ' + ISNULL(SM.DOSYAADI, N'') END), 120),
        SONGONDEREN = SG.FIRMA,
        SONTARIH   = K.SONMESAJTARIH,
        OKUNMAMIS  = A.Adet,
        BILDIRIM   = CAST(U.BILDIRIM AS INT),
        YONETICI   = CAST(U.ROL AS INT)
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        LEFT  JOIN dbo.MESAJ      SM ON SM.ID = K.SONMESAJID
        LEFT  JOIN dbo.REHBER     SG ON SG.ID = SM.GONDERENID
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA, R.RESIM
                       FROM dbo.MESAJKANALUYE U2 INNER JOIN dbo.REHBER R ON R.ID = U2.REHBERID
                      WHERE U2.KANALID = K.ID AND U2.REHBERID <> @KulId) KS
        CROSS APPLY (SELECT Adet = COUNT(*) FROM dbo.MESAJ M
                      WHERE M.KANALID = K.ID AND M.ID > U.SONOKUMAID
                        AND M.ID > U.BASLANGICID AND M.SILINDI = 0
                        AND M.GONDERENID <> @KulId) A
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
      AND (@Okunmamis = 0 OR A.Adet > 0)
      AND (@Ara IS NULL
           OR (K.TUR = 2 AND K.ADI LIKE N'%' + @Ara + N'%')
           OR (K.TUR = 1 AND KS.FIRMA LIKE N'%' + @Ara + N'%'))
    ORDER BY ISNULL(K.SONMESAJTARIH, K.OLUSTURMATARIHI) DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Kisi_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
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
        RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END,
        KANALID  = dbo.fn_Prog_Mesaj_BirebirKanal(@KulId, R.ID)
    FROM dbo.KULLANICI K
        INNER JOIN dbo.REHBER R ON R.ID = K.REHBERID
    WHERE ISNULL(K.DURUM, 0) = 1
      AND R.ID <> @KulId
      AND (@Ara IS NULL OR R.FIRMA LIKE N'%' + @Ara + N'%' OR R.KOD LIKE N'%' + @Ara + N'%')
    ORDER BY R.FIRMA;
END
GO

-- Avatar icerigi (yalnizca gorunen satirlar icin, istemci onbellekler)
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Avatar
    @RehberId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RESIM FROM dbo.REHBER WHERE ID = @RehberId;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kanal_Liste_Json2 TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kisi_Liste_Json2  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Avatar            TO gentegre_api;
END
GO
