-- ============================================================
-- GenDepoUpdate151.sql
-- MESAJLASMA: kisi kunyesi + grup uye adlari
--
--   1) sp_Prog_Mesaj_Kisi_Bilgi_Json2: sohbet bilgisi panosunda birebir
--      sohbette gosterilen kunye (ad soyad, bolum/rol, departman, gorev,
--      e-posta). Kaynak IK ekraninin kullandigi yollar:
--        REHBER.SINIF -> ROLLER (DEPARTMAN -> GENINI -2251, GOREVID -> -2252)
--        e-posta      -> REHBERILETISIM + REHBERBILGI + REHBERAYAR.VARSAYILAN=46
--   2) sp_Prog_Mesaj_Kanal_Liste_Json2'ye UYELER kolonu: grup basliginin
--      altinda "Ali, Ayse, Mehmet" seklinde yazmak icin. STRING_AGG YERINE
--      FOR XML PATH: eski SQL Server surumlerinde de calissin.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Kisi_Bilgi_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- ListeSPJson imza uyumu (kullanilmiyor)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @RehberId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT), 0);
    DECLARE @Dil      INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Dil') AS INT), 0);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;
    IF @RehberId <= 0 THROW 51001, N'RehberId zorunlu.', 1;

    SELECT
        REHBERID  = R.ID,
        ADSOYAD   = R.FIRMA,
        KOD       = R.KOD,
        BOLUM     = ROL.ROL,
        DEPARTMAN = (SELECT TOP 1 G.ANAHTAR FROM dbo.GENINI G
                      WHERE G.BOLUM = -2251 AND G.DEGER = ROL.DEPARTMAN AND G.DIL = @Dil),
        GOREV     = (SELECT TOP 1 G.ANAHTAR FROM dbo.GENINI G
                      WHERE G.BOLUM = -2252 AND G.DEGER = ROL.GOREVID AND G.DIL = @Dil),
        EPOSTA    = (SELECT TOP 1 RB.BILGI
                       FROM dbo.REHBERILETISIM RI
                            INNER JOIN dbo.REHBERBILGI RB ON RB.YER_ID = RI.ID
                            INNER JOIN dbo.REHBERAYAR  RA ON RA.YERI = RB.YERI AND RA.ETIKET = RB.ETIKET
                      WHERE RI.REHBERID = R.ID AND RB.YERI = 1 AND RA.VARSAYILAN = 46
                        AND RB.BILGI LIKE N'%@%.%'),
        SUBE      = (SELECT TOP 1 S.FIRMA FROM dbo.REHBER S WHERE S.ID = R.SUBEID)
    FROM dbo.REHBER R
        LEFT JOIN dbo.ROLLER ROL ON ROL.ID = R.SINIF
    WHERE R.ID = @RehberId;
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
        -- Grup basliginin altindaki "Ali, Ayse, Mehmet" satiri
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
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kisi_Bilgi_Json2   TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kanal_Liste_Json2  TO gentegre_api;
END
GO
