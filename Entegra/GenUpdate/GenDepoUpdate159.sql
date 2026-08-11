-- ============================================================
-- GenDepoUpdate159.sql
-- MESAJLASMA: TUM sohbetlerde icerik aramasi ("İçerikte Ara")
--
-- Kullanicinin UYESI OLDUGU kanallardaki mesaj metinlerinde arar; her satirda
--   hangi sohbet oldugu ve mesajin kirpilmis metni doner. Istemci sonuca
--   tiklayinca ilgili sohbeti acar.
--
-- Yetki: yalniz uyesi olunan kanallar; uyeden ONCEKI mesajlar (BASLANGICID)
--   ve silinmis mesajlar disarida.
-- Cikti SATIR KUMESI (Json2 deseni: JSON yalnizca GIRDIdir).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Icerik_Ara_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- ListeSPJson imza uyumu (kullanilmiyor)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Ara');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 100);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;
    -- Bosluk kontrolu DATALENGTH ile: "= N''" collation agirligina bakar ve
    --   emoji gibi ek-duzlem karakterleri BOS sayar (bkz. GenDepoUpdate156).
    IF DATALENGTH(ISNULL(@Ara, N'')) = 0 THROW 51001, N'Aranacak metin zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        MESAJID   = M.ID,
        KANALID   = K.ID,
        TUR       = K.TUR,
        KANALADI  = CASE WHEN K.TUR = 2 THEN K.ADI ELSE KS.FIRMA END,
        KARSIID   = CASE WHEN K.TUR = 1 THEN KS.ID END,
        RESIMVAR  = CASE WHEN K.TUR = 1 THEN ISNULL(KS.RESIMVAR, 0)
                         WHEN K.DOSYAID IS NOT NULL THEN 1 ELSE 0 END,
        GRUPDOSYAID = CASE WHEN K.TUR = 2 THEN K.DOSYAID END,
        GONDEREN  = G.FIRMA,
        BENIMMI   = CASE WHEN M.GONDERENID = @KulId THEN 1 ELSE 0 END,
        TARIH     = M.TARIH,
        METIN     = CAST(LEFT(M.METIN, 200) AS NVARCHAR(200))
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        INNER JOIN dbo.MESAJ      M ON M.KANALID = K.ID AND M.ID > U.BASLANGICID
                                   AND M.SILINDI = 0
        LEFT  JOIN dbo.REHBER     G ON G.ID = M.GONDERENID
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA,
                            RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
                       FROM dbo.MESAJKANALUYE U2 INNER JOIN dbo.REHBER R ON R.ID = U2.REHBERID
                      WHERE U2.KANALID = K.ID AND U2.REHBERID <> @KulId) KS
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
      AND M.METIN LIKE N'%' + @Ara + N'%'
    ORDER BY M.ID DESC;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Icerik_Ara_Json2 TO gentegre_api;
GO
