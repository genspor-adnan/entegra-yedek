-- ============================================================
-- GenDepoUpdate155.sql
-- MESAJLASMA: kisi kunyesinde DEPARTMAN ve GOREV bos geliyordu
--
-- TESHIS: sp_Prog_Mesaj_Kisi_Bilgi_Json2 lookup'lari "AND G.DIL = @Dil" (0) ile
--   suzuyordu; bu kurulumdaki GENINI kayitlari DIL = -1 (DIL-BAGIMSIZ) olarak
--   girilmis -> hicbir satir eslesmiyor, kolonlar NULL donuyordu.
--   (Veri yerinde: REHBER.SINIF -> ROLLER.DEPARTMAN/GOREVID -> GENINI -2251/-2252)
--
-- COZUM: once istenen dil, yoksa dil-bagimsiz (-1), o da yoksa herhangi biri.
--   Ayrica ROLLER.ROL (bolum/rol adi) zaten donuyordu, dokunulmadi.
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
        -- DIL onceligi: istenen dil > dil-bagimsiz (-1) > herhangi biri
        DEPARTMAN = (SELECT TOP 1 G.ANAHTAR FROM dbo.GENINI G
                      WHERE G.BOLUM = -2251 AND G.DEGER = ROL.DEPARTMAN
                        AND ISNULL(G.ANAHTAR, N'') <> N''
                      ORDER BY CASE WHEN G.DIL = @Dil THEN 0
                                    WHEN G.DIL = -1   THEN 1 ELSE 2 END),
        GOREV     = (SELECT TOP 1 G.ANAHTAR FROM dbo.GENINI G
                      WHERE G.BOLUM = -2252 AND G.DEGER = ROL.GOREVID
                        AND ISNULL(G.ANAHTAR, N'') <> N''
                      ORDER BY CASE WHEN G.DIL = @Dil THEN 0
                                    WHEN G.DIL = -1   THEN 1 ELSE 2 END),
        EPOSTA    = (SELECT TOP 1 RB.BILGI
                       FROM dbo.REHBERILETISIM RI
                            INNER JOIN dbo.REHBERBILGI RB ON RB.YER_ID = RI.ID
                            INNER JOIN dbo.REHBERAYAR  RA ON RA.YERI = RB.YERI AND RA.ETIKET = RB.ETIKET
                      WHERE RI.REHBERID = R.ID AND RB.YERI = 1 AND RA.VARSAYILAN = 46
                        AND RB.BILGI LIKE N'%@%.%'),
        TELEFON   = (SELECT TOP 1 RB.BILGI
                       FROM dbo.REHBERILETISIM RI
                            INNER JOIN dbo.REHBERBILGI RB ON RB.YER_ID = RI.ID
                            INNER JOIN dbo.REHBERAYAR  RA ON RA.YERI = RB.YERI AND RA.ETIKET = RB.ETIKET
                      WHERE RI.REHBERID = R.ID AND RB.YERI = 1 AND RA.VARSAYILAN IN (41, 42)
                        AND ISNULL(RB.BILGI, N'') <> N''),
        SUBE      = (SELECT TOP 1 S.FIRMA FROM dbo.REHBER S WHERE S.ID = R.SUBEID)
    FROM dbo.REHBER R
        LEFT JOIN dbo.ROLLER ROL ON ROL.ID = R.SINIF
    WHERE R.ID = @RehberId;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kisi_Bilgi_Json2 TO gentegre_api;
GO
