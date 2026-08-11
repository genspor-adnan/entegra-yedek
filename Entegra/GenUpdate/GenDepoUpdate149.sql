-- ============================================================
-- GenDepoUpdate149.sql
-- MESAJLASMA - LISTE PERFORMANSI
--
--   1) sp_Prog_Mesaj_Kisi_Liste_Json2 satir BASINA skaler
--      fn_Prog_Mesaj_BirebirKanal cagiriyordu (her kullanici icin 2 EXISTS +
--      1 COUNT). 200 kullanicida 200 ayri alt-plan. Yerine birebir kanallar
--      TEK CTE ile toplanip LEFT JOIN ediliyor.
--   2) Kanal listesinde OUTER APPLY karsi tarafin RESIM (image) kolonunu
--      disari tasiyordu; blob'un kendisi hic gerekmiyor -> RESIMVAR APPLY
--      ICINDE bit'e cevriliyor, blob plandan tamamen cikiyor.
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

    ;WITH Benim AS
    (
        -- Kullanicinin icinde oldugu BIREBIR kanallar
        SELECT U.KANALID
        FROM dbo.MESAJKANALUYE U
            INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.TUR = 1 AND K.DURUM = 1
        WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
    ),
    Karsi AS
    (
        -- O kanallardaki KARSI taraf -> kisi basina kanal ID'si (tek gecis)
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
        RESIMVAR   = CASE WHEN K.TUR = 1 THEN ISNULL(KS.RESIMVAR, 0) ELSE 0 END,
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
        -- RESIM (image) blob'u disari CIKMAZ: burada bit'e cevriliyor
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA,
                            RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
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

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kisi_Liste_Json2  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kanal_Liste_Json2 TO gentegre_api;
END
GO
