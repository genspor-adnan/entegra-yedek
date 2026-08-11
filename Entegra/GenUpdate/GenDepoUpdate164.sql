-- ============================================================
-- GenDepoUpdate164.sql
-- MESAJLASMA: sessize alinan sohbetler SES CIKARMASIN
--
--   Sessize alma zaten vardi (MESAJKANALUYE.BILDIRIM + Islem='sessize'), ancak
--   yoklama SP'si toplam okunmamisi tek sayi donduruyordu; istemci sesi buna
--   gore caliyordu -> sessize alinan sohbet de "ding" diyordu.
--
--   Yokla ciktisina "Sesli" eklendi: YALNIZ bildirimi ACIK sohbetlerin okunmamis
--   toplami. Istemci rozeti "Okunmamis", sesi "Sesli" degerine gore verir.
--   Ayrica kendinden silinen (MESAJGIZLI) mesajlar hicbir sayima girmez.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Yokla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;

    SELECT
        SonId     = ISNULL(MAX(K.SONMESAJID), 0),
        Okunmamis = ISNULL(SUM(A.Adet), 0),
        -- Sessize alinmamis (BILDIRIM = 1) sohbetlerin okunmamisi: SES bunun icin
        Sesli     = ISNULL(SUM(CASE WHEN U.BILDIRIM = 1 THEN A.Adet ELSE 0 END), 0),
        Kanallar  = (SELECT KANALID = K2.ID, SONMESAJID = K2.SONMESAJID,
                            OKUNMAMIS = A2.Adet, BILDIRIM = CAST(U2.BILDIRIM AS INT)
                     FROM dbo.MESAJKANALUYE U2
                          INNER JOIN dbo.MESAJKANAL K2 ON K2.ID = U2.KANALID AND K2.DURUM = 1
                          CROSS APPLY (SELECT Adet = COUNT(*) FROM dbo.MESAJ M
                                        WHERE M.KANALID = K2.ID AND M.ID > U2.SONOKUMAID
                                          AND M.ID > U2.BASLANGICID AND M.SILINDI = 0
                                          AND M.GONDERENID <> @KulId
                                          AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                                           WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)) A2
                     WHERE U2.REHBERID = @KulId AND U2.AYRILMATARIHI IS NULL AND A2.Adet > 0
                     FOR JSON PATH)
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        CROSS APPLY (SELECT Adet = COUNT(*) FROM dbo.MESAJ M
                      WHERE M.KANALID = K.ID AND M.ID > U.SONOKUMAID
                        AND M.ID > U.BASLANGICID AND M.SILINDI = 0
                        AND M.GONDERENID <> @KulId
                        AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                         WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)) A
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Yokla_Json TO gentegre_api;
GO
