-- ============================================================
-- GenDepoUpdate162.sql
-- MESAJLASMA: sol paneldeki filtre cipleri  Tümü / Okunmamış / Favoriler / Gruplar
--
--   Favori KULLANICIYA OZEL: MESAJKANALUYE.FAVORI (kanalda degil, uyelikte).
--   Kanal listesi SP'sine iki filtre daha: YalnizFavori, YalnizGrup.
--   sp_Api_Mesaj_Kanal_Favori_Json: yildizi ac/kapa.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('dbo.MESAJKANALUYE', 'FAVORI') IS NULL
    ALTER TABLE dbo.MESAJKANALUYE
        ADD FAVORI BIT NOT NULL CONSTRAINT DF_MESAJKANALUYE_FAV DEFAULT (0);
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Favori_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @Favori  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Favori') AS BIT), 0);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    UPDATE dbo.MESAJKANALUYE SET FAVORI = @Favori
     WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL;

    SELECT Sonuc = 1, KanalId = @KanalId, Favori = CAST(@Favori AS INT)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- kanal listesi: FAVORI kolonu + iki yeni filtre ---------------------
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
    DECLARE @Favori    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YalnizFavori') AS BIT), 0);
    DECLARE @Grup      BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YalnizGrup') AS BIT), 0);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        KANALID    = K.ID,
        TUR        = K.TUR,
        ADI        = CASE WHEN K.TUR = 2 THEN K.ADI ELSE KS.FIRMA END,
        KARSIID    = CASE WHEN K.TUR = 1 THEN KS.ID END,
        RESIMVAR   = CASE WHEN K.TUR = 1 THEN ISNULL(KS.RESIMVAR, 0)
                          WHEN K.DOSYAID IS NOT NULL THEN 1 ELSE 0 END,
        GRUPDOSYAID = CASE WHEN K.TUR = 2 THEN K.DOSYAID END,
        UYESAYISI  = (SELECT COUNT(*) FROM dbo.MESAJKANALUYE X
                       WHERE X.KANALID = K.ID AND X.AYRILMATARIHI IS NULL),
        UYELER     = CASE WHEN K.TUR = 2 THEN
                       STUFF((SELECT N', ' + CASE WHEN U3.REHBERID = @KulId THEN N'Siz' ELSE R2.FIRMA END
                                FROM dbo.MESAJKANALUYE U3
                                     INNER JOIN dbo.REHBER R2 ON R2.ID = U3.REHBERID
                               WHERE U3.KANALID = K.ID AND U3.AYRILMATARIHI IS NULL
                               ORDER BY CASE WHEN U3.REHBERID = @KulId THEN 1 ELSE 0 END, R2.FIRMA
                               FOR XML PATH(N''), TYPE).value(N'.', N'NVARCHAR(MAX)'), 1, 2, N'')
                     END,
        SONMESAJ   = LEFT(ISNULL(SM.METIN, CASE WHEN SM.DOSYAID IS NOT NULL THEN N'[dosya] ' + ISNULL(SM.DOSYAADI, N'') END), 120),
        SONGONDEREN = SG.FIRMA,
        SONTARIH   = K.SONMESAJTARIH,
        OKUNMAMIS  = A.Adet,
        BILDIRIM   = CAST(U.BILDIRIM AS INT),
        YONETICI   = CAST(U.ROL AS INT),
        FAVORI     = CAST(U.FAVORI AS INT)
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        LEFT  JOIN dbo.MESAJ      SM ON SM.ID = K.SONMESAJID
        LEFT  JOIN dbo.REHBER     SG ON SG.ID = SM.GONDERENID
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA,
                            RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
                       FROM dbo.MESAJKANALUYE U2 INNER JOIN dbo.REHBER R ON R.ID = U2.REHBERID
                      WHERE U2.KANALID = K.ID AND U2.REHBERID <> @KulId) KS
        CROSS APPLY (SELECT Adet = COUNT(*) FROM dbo.MESAJ M
                      WHERE M.KANALID = K.ID AND M.ID > U.SONOKUMAID
                        AND M.ID > U.BASLANGICID AND M.SILINDI = 0
                        AND M.GONDERENID <> @KulId
                        AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                         WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)) A
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
      AND (@Okunmamis = 0 OR A.Adet > 0)
      AND (@Favori = 0 OR U.FAVORI = 1)
      AND (@Grup = 0 OR K.TUR = 2)
      AND (@Ara IS NULL
           OR (K.TUR = 2 AND K.ADI LIKE N'%' + @Ara + N'%')
           OR (K.TUR = 1 AND KS.FIRMA LIKE N'%' + @Ara + N'%'))
    ORDER BY ISNULL(K.SONMESAJTARIH, K.OLUSTURMATARIHI) DESC;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Kanal_Favori_Json   TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kanal_Liste_Json2  TO gentegre_api;
END
GO
