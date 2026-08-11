-- ============================================================
-- GenDepoUpdate168.sql
-- MESAJLASMA: BOS birebir sohbetler listede gorunmesin
--
-- SORUN: "Kişiler" bolumunden birine tiklayinca kanal ANINDA olusuyor ve
--   hic mesaj olmadan sohbet listesinin EN USTUNE giriyordu (yeni kanal =
--   en yeni tarih). Hem liste yeniden kuruluyor (kaydirma bozuluyor) hem de
--   konusulmamis kisiler "sohbet" gibi birikiyordu.
--
-- COZUM:
--   1) Kanal listesi: birebir kanal, KULLANICIYA GORUNUR en az bir mesaj
--      tasimiyorsa listelenmez. Gruplar bos olsa da gorunur (grup kurulmus olmasi
--      basli basina anlamli).
--   2) Kisi listesi: KANALID yalnizca o kanalda GORUNUR mesaj varsa doner;
--      boylece konusulmamis kisi "Kişiler" bolumunde kalir.
--
-- Kanal yine tiklamada olusur (mesaj gonderebilmek icin gerekli); sadece
--   listede gorunmez.
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
        SONMESAJ   = LEFT(CASE WHEN SM.SILINDI = 1 THEN N'(bu mesaj silindi)'
                               ELSE ISNULL(SM.METIN,
                                    CASE WHEN SM.DOSYAID IS NOT NULL
                                         THEN N'[dosya] ' + ISNULL(SM.DOSYAADI, N'') END) END, 120),
        SONGONDEREN = SG.FIRMA,
        SONTARIH   = SM.TARIH,
        OKUNMAMIS  = A.Adet,
        BILDIRIM   = CAST(U.BILDIRIM AS INT),
        YONETICI   = CAST(U.ROL AS INT),
        FAVORI     = CAST(U.FAVORI AS INT)
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        OUTER APPLY (SELECT TOP 1 M.ID, M.METIN, M.TARIH, M.SILINDI, M.DOSYAID, M.DOSYAADI, M.GONDERENID
                       FROM dbo.MESAJ M
                      WHERE M.KANALID = K.ID
                        AND M.ID > U.BASLANGICID
                        AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                         WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)
                      ORDER BY M.ID DESC) SM
        LEFT  JOIN dbo.REHBER SG ON SG.ID = SM.GONDERENID
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
      -- BOS birebir sohbet listelenmez (kanal var ama gorunur mesaj yok)
      AND (K.TUR = 2 OR SM.ID IS NOT NULL)
      AND (@Okunmamis = 0 OR A.Adet > 0)
      AND (@Favori = 0 OR U.FAVORI = 1)
      AND (@Grup = 0 OR K.TUR = 2)
      AND (@Ara IS NULL
           OR (K.TUR = 2 AND K.ADI LIKE N'%' + @Ara + N'%')
           OR (K.TUR = 1 AND KS.FIRMA LIKE N'%' + @Ara + N'%'))
    ORDER BY ISNULL(SM.TARIH, K.OLUSTURMATARIHI) DESC;
END
GO

-- ---- Kisi listesi: KANALID yalniz GORUNUR mesaj varsa -------------------
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

    ;WITH Benim AS
    (
        SELECT U.KANALID
        FROM dbo.MESAJKANALUYE U
            INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.TUR = 1 AND K.DURUM = 1
        WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
          -- Yalniz GORUNUR mesaji olan kanallar "sohbet" sayilir
          AND EXISTS (SELECT 1 FROM dbo.MESAJ M
                       WHERE M.KANALID = U.KANALID AND M.ID > U.BASLANGICID
                         AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                          WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId))
    ),
    Karsi AS
    (
        SELECT U.REHBERID, KANALID = MIN(U.KANALID)
        FROM dbo.MESAJKANALUYE U
            INNER JOIN Benim B ON B.KANALID = U.KANALID
        WHERE U.REHBERID <> @KulId AND U.AYRILMATARIHI IS NULL
        GROUP BY U.REHBERID
    )
    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        REHBERID = R.ID,
        ADI      = R.FIRMA,
        KOD      = R.KOD,
        RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END,
        KANALID  = KR.KANALID
    FROM dbo.KULLANICI K
        INNER JOIN dbo.REHBER R ON R.ID = K.REHBERID
        LEFT  JOIN Karsi KR ON KR.REHBERID = R.ID
    WHERE ISNULL(K.DURUM, 0) = 1
      AND R.ID <> @KulId
      AND (@Ara IS NULL OR R.FIRMA LIKE N'%' + @Ara + N'%' OR R.KOD LIKE N'%' + @Ara + N'%')
    ORDER BY R.FIRMA;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kanal_Liste_Json2 TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kisi_Liste_Json2  TO gentegre_api;
END
GO
