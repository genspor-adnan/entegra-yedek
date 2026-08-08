-- ============================================================
-- GenDepoUpdate83.sql
-- sp_Prog_Dokuman_Liste_Json2 : bellek grant'i (RESOURCE_SEMAPHORE donmasi) duzeltmesi
--
-- BELIRTI: Program acilirken Dokuman sekmesi olusurken KILITLENIYORDU. Sunucuda
--   oturum RESOURCE_SEMAPHORE'da bekliyordu (10+ dakika, sonu gelmez). Istenen
--   bellek grant'i 80.424 KB, gereken minimum yalnizca 6.160 KB, "ideal" 193.064 KB.
--   SQL Express + dolu makinede sorgu-bellek semaforu 9.600 KB'a dusunce bu istek
--   ASLA karsilanamaz -> sorgu sonsuza kadar bekler, ekran donar.
--
-- KOK NEDEN: iki kolda da "SELECT DISTINCT D.*" vardi. DISTINCT, DOKUMAN'in TUM
--   kolonlari (+ hesaplanan genis kolonlar) uzerinde hash/sort ister; grant tahmini
--   satir genisligi x tahmini satir sayisi ile sisiyordu.
--   DISTINCT'e gerek olmasinin TEK sebebi arm1'deki
--     LEFT OUTER JOIN DOKUMANYETKI DY ON DY.YERI = 321 AND DY.YERID = D.ID
--   idi: bir dokumanda birden fazla yetki satiri varsa satir cogaliyordu.
--   arm2'de bu join HIC YOK - oradaki DISTINCT tamamen gereksizdi (kalan tum
--   join'ler benzersiz ID uzerinde 1:1).
--
-- COZUM: yetki join'i EXISTS'e cevrildi (satir cogaltmaz, ayni sonuc kumesi),
--   iki koldan da DISTINCT kaldirildi. Sorgu artik buyuk grant istemiyor.
--
-- CLAUDE.md kurali: "kosulsuz DISTINCT / yalniz opsiyonel filtre icin gereken
--   detay JOIN, SQL Express'te RESOURCE_SEMAPHORE'da dondurur - musteriler hep
--   Express." Bu duzeltme tam o kural.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Dokuman_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod') AS INT), 3);
    DECLARE @KlasorId   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KlasorId') AS INT);
    DECLARE @TabNo      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TabNo') AS INT);
    DECLARE @TamYetki   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TamYetki') AS BIT), 0);
    DECLARE @GD         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.GD') AS INT), 1);
    DECLARE @Kullanan   INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kullanan') AS INT), 0);
    DECLARE @AraDokuman NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraDokuman'), N'');
    DECLARE @AraKonu    NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraKonu'), N'');
    DECLARE @AraAnahtar NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraAnahtar'), N'');
    DECLARE @AraKurum   NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraKurum'), N'');
    DECLARE @AraSorumlu NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraSorumlu'), N'');
    DECLARE @AraLokasyon NVARCHAR(200)= NULLIF(JSON_VALUE(@Kosullar,'$.AraLokasyon'), N'');
    DECLARE @Bolum      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Bolum') AS INT);
    -- SON/SIK ARANAN (KULLANICI_ARAMA): 0 = kapali, 1 = Son (tarih), 2 = Sik (kullanim).
    --   Modul = MODUL_Dokuman (32), Kul = oturum kullanicisi. Eksikse otomatik kapanir.
    DECLARE @AramaModu    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AramaModu') AS INT), 0);
    DECLARE @AramaModulID INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul')     AS INT), 0);
    DECLARE @AramaKul     INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kul')       AS INT), 0);
    IF @AramaModulID <= 0 OR @AramaKul <= 0 SET @AramaModu = 0;

    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @Kategori   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Kategori') AS INT);
    DECLARE @Pasif      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @TarihVar   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihVar') AS BIT), 0);
    DECLARE @TarihBas   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);

    -- Bolum/Modul/Kategori: 0 => filtre yok (orijinal 'EditValue > 0' kosulu)
    IF @Bolum    = 0 SET @Bolum    = NULL;
    IF @Modul    = 0 SET @Modul    = NULL;
    IF @Kategori = 0 SET @Kategori = NULL;

    -- Klasor agaci BIR KEZ maddelestirilir. Onceki halde rekursif CTE dort ayri
    --   skaler alt sorguda (KLASORAD) referans ediliyordu; her referans plan
    --   tarafina index spool (worktable) koyup bellek grant'ini sisiriyordu.
    IF OBJECT_ID('tempdb..#Dizin') IS NOT NULL DROP TABLE #Dizin;
    ;WITH Dizin AS
    (
        SELECT ID, USTID, AD = CAST(AD AS NVARCHAR(260))
        FROM DOKUMANKLASOR
        WHERE USTID = 0
        UNION ALL
        SELECT A.ID, A.USTID, AD = CAST(V.AD + N'\' + A.AD AS NVARCHAR(260))
        FROM DOKUMANKLASOR A
        INNER JOIN Dizin V ON V.ID = A.USTID
    )
    SELECT ID, AD INTO #Dizin FROM Dizin OPTION (MAXRECURSION 0);
    CREATE UNIQUE CLUSTERED INDEX IX_Dizin ON #Dizin(ID);

    -- ---------- arm1: DTIP=1  (DOKUMAN D) ----------
    SELECT
        D.*, DTIP = 1, KISAYOLID = 0,
        Firma.FIRMA AS KURUM, Lokasyon.ACIKLAMA AS LOKASYONAD, Sorumlu.FIRMA AS SORUMLUAD,
        EXT = N'.' + I.BELGETURU, I.SURUM, I.BOYUT,
        KLASORAD      = (SELECT AD    FROM #Dizin WHERE ID = D.KLASOR),
        ONAYLAYACAKAD = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAYLAYACAK),
        ONAYLAYANAD   = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAY),
        EKLEYENAD     = (SELECT FIRMA FROM REHBER WHERE ID = D.EKLEYEN),
        DEGISTIRENAD  = (SELECT FIRMA FROM REHBER WHERE ID = D.DEGISTIREN),
        -- SON/SIK ARANAN siralama kolonlari (KULLANICI_ARAMA). ORDER BY YOK: siralama
        --   GRID'den yapilir (kullanicinin kayitli grid siralamasi bozulmasin). Bu kolonlar
        --   normal listede de dolar: "en son ne zaman actim / kac kez actim".
        SONERISIM = (SELECT MAX(KA.DEGISTIRMETARIHI) FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul),
        ERISIMSAY = (SELECT MAX(KA.SAY)              FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul)
    FROM DOKUMAN D
        INNER JOIN IMAJ I ON I.ID = (SELECT TOP 1 ID FROM IMAJ WHERE YERI = 1 AND YER_ID = D.ID ORDER BY ID DESC)
        LEFT OUTER JOIN REHBER   Firma    ON Firma.ID    = D.REHBERID
        LEFT OUTER JOIN LOKASYON Lokasyon ON Lokasyon.ID = D.LOKASYON
        LEFT OUTER JOIN REHBER   Sorumlu  ON Sorumlu.ID  = I.REHBERID
    WHERE (
        (   -- Mod=1 klasor-agac
            @Mod = 1
            AND D.KLASOR = @KlasorId
            AND ( @TamYetki = 1
                  OR ( D.GIZLILIKDERECESI <= @GD
                       AND EXISTS (SELECT 1 FROM DOKUMANYETKI DY
                                    WHERE DY.YERI = 321 AND DY.YERID = D.ID AND DY.GOR = 1
                                      AND (DY.REHBERID = 0 OR DY.REHBERID = @Kullanan)) ) )
        )
        OR
        (   -- Mod=2 arama-formu
            @Mod = 2
            AND (@AraDokuman  IS NULL OR D.AD             LIKE N'%' + @AraDokuman  + N'%')
            AND (@AraKonu     IS NULL OR D.KONU           LIKE N'%' + @AraKonu     + N'%')
            AND (@AraAnahtar  IS NULL OR D.ANAHTAR        LIKE N'%' + @AraAnahtar  + N'%')
            AND (@AraKurum    IS NULL OR Firma.FIRMA      LIKE N'%' + @AraKurum    + N'%')
            AND (@AraSorumlu  IS NULL OR Sorumlu.FIRMA    LIKE N'%' + @AraSorumlu  + N'%')
            AND (@AraLokasyon IS NULL OR Lokasyon.ACIKLAMA LIKE N'%' + @AraLokasyon + N'%')
            AND (@Bolum       IS NULL OR D.BOLUM    = @Bolum)
            AND (@Modul       IS NULL OR D.MODUL    = @Modul)
            AND (@Kategori    IS NULL OR D.KATEGORI = @Kategori)
            AND (@Pasif       = 1     OR D.DURUM    = 1)
            AND (@TamYetki    = 1     OR D.GIZLILIKDERECESI <= @GD)
            AND (@TarihVar    = 0     OR (D.TARIH >= @TarihBas AND D.TARIH <= @TarihBit))
        )
        OR @Mod = 3   -- Mod=3 tum-kayitlar
        )
        AND (@AramaModu = 0
             OR EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA
                         WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID
                           AND KA.KULID = @AramaKul))

    UNION ALL

    -- ---------- arm2: DTIP=0  (DOKUMANKISAYOL DK) ----------
    SELECT
        D.*, DTIP = 0, KISAYOLID = DK.ID,
        Firma.FIRMA AS KURUM, Lokasyon.ACIKLAMA AS LOKASYONAD, Sorumlu.FIRMA AS SORUMLUAD,
        EXT = CASE WHEN D.AD LIKE N'%.%'
                   THEN N'.' + REVERSE(SUBSTRING(REVERSE(ISNULL(D.AD, N'.')), 1,
                                CHARINDEX(N'.', REVERSE(ISNULL(D.AD, N'.')), 1) - 1))
                   ELSE N'' END,
        I.SURUM, I.BOYUT,
        KLASORAD      = (SELECT AD    FROM #Dizin WHERE ID = D.KLASOR),
        ONAYLAYACAKAD = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAYLAYACAK),
        ONAYLAYANAD   = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAY),
        EKLEYENAD     = (SELECT FIRMA FROM REHBER WHERE ID = D.EKLEYEN),
        DEGISTIRENAD  = (SELECT FIRMA FROM REHBER WHERE ID = D.DEGISTIREN),
        -- SON/SIK ARANAN siralama kolonlari (KULLANICI_ARAMA). ORDER BY YOK: siralama
        --   GRID'den yapilir (kullanicinin kayitli grid siralamasi bozulmasin). Bu kolonlar
        --   normal listede de dolar: "en son ne zaman actim / kac kez actim".
        SONERISIM = (SELECT MAX(KA.DEGISTIRMETARIHI) FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul),
        ERISIMSAY = (SELECT MAX(KA.SAY)              FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul)
    FROM DOKUMANKISAYOL DK
        INNER JOIN DOKUMAN D ON DK.DOKUMANID = D.ID
        INNER JOIN IMAJ I ON I.ID = (SELECT TOP 1 ID FROM IMAJ WHERE YERI = 1 AND YER_ID = D.ID ORDER BY ID DESC)
        LEFT OUTER JOIN REHBER   Firma    ON Firma.ID    = D.REHBERID
        LEFT OUTER JOIN LOKASYON Lokasyon ON Lokasyon.ID = D.LOKASYON
        LEFT OUTER JOIN REHBER   Sorumlu  ON Sorumlu.ID  = I.REHBERID
    WHERE (
        (   -- Mod=1 klasor-agac (arm2: kisayol yeri/yer_id)
            @Mod = 1
            AND DK.YER = @TabNo AND DK.YER_ID = @KlasorId
        )
        OR
        (   -- Mod=2 arama-formu (arm1 ile ayni filtre)
            @Mod = 2
            AND (@AraDokuman  IS NULL OR D.AD             LIKE N'%' + @AraDokuman  + N'%')
            AND (@AraKonu     IS NULL OR D.KONU           LIKE N'%' + @AraKonu     + N'%')
            AND (@AraAnahtar  IS NULL OR D.ANAHTAR        LIKE N'%' + @AraAnahtar  + N'%')
            AND (@AraKurum    IS NULL OR Firma.FIRMA      LIKE N'%' + @AraKurum    + N'%')
            AND (@AraSorumlu  IS NULL OR Sorumlu.FIRMA    LIKE N'%' + @AraSorumlu  + N'%')
            AND (@AraLokasyon IS NULL OR Lokasyon.ACIKLAMA LIKE N'%' + @AraLokasyon + N'%')
            AND (@Bolum       IS NULL OR D.BOLUM    = @Bolum)
            AND (@Modul       IS NULL OR D.MODUL    = @Modul)
            AND (@Kategori    IS NULL OR D.KATEGORI = @Kategori)
            AND (@Pasif       = 1     OR D.DURUM    = 1)
            AND (@TamYetki    = 1     OR D.GIZLILIKDERECESI <= @GD)
            AND (@TarihVar    = 0     OR (D.TARIH >= @TarihBas AND D.TARIH <= @TarihBit))
        )
        OR @Mod = 3   -- Mod=3 tum-kayitlar
        )
        AND (@AramaModu = 0
             OR EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA
                         WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID
                           AND KA.KULID = @AramaKul))
    -- Tum join'ler benzersiz anahtar uzerinde arama (REHBER/LOKASYON/IMAJ PK).
    -- LOOP JOIN: hash/sort tamponu istemez -> bellek grant'i minimuma iner.
    -- Bu sorgu SQL Express'te 78 MB grant isteyip RESOURCE_SEMAPHORE'da donuyordu.
    OPTION (LOOP JOIN, MAXDOP 1);
END;
GO
