-- ======================================================================
-- KONSOLIDE UPDATE 03 - IZLEME / SERI-LOT (+ trigger)
-- ======================================================================
-- 11 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- FUNCTION: fn_prog_izleme_depoaday  (kaynak: GenDepoUpdate104) ----
CREATE OR ALTER FUNCTION dbo.fn_Prog_Izleme_DepoAday
(
    @StokId INT,
    @DepoId INT,
    @HedefSatirId INT = 0   -- verilirse bu satirin KENDI hareketi disarida birakilir
)
RETURNS TABLE
AS
RETURN
(
    SELECT SDI.SERILOTID,
           SSL.SERINO, SSL.LOTNO, SSL.SKT, SSL.URT,
           Mevcut = CAST(ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) AS decimal(18,6))
    FROM dbo.STOKDURUMIZLEME SDI
         INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SDI.SERILOTID
         OUTER APPLY (
             SELECT Kendi = SUM(ISNULL(D.ADET, 0))
             FROM dbo.STOKIZLEMEDEPO D
                  INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
             WHERE ISNULL(@HedefSatirId, 0) > 0
               AND SI.SATIRID = @HedefSatirId
               AND SI.SERILOTID = SDI.SERILOTID
               AND D.DEPOID = @DepoId
         ) K
    WHERE SDI.STOKID = @StokId
      AND SDI.DEPOID = @DepoId
      AND ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) > 0.0001
);
GO

-- ---- PROCEDURE: sp_prog_belgedonusum_izlemeaktar  (kaynak: GenDepoUpdate112) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_IzlemeAktar
    @DonusumTuru INT,
    @HedefBaslikID INT,
    @KullaniciID INT,
    @Aktarilan   INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Aktarilan = 0;

    IF NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim) RETURN;

    DECLARE @HedefTur INT, @GirDepo INT, @CikDepo INT;
    SELECT @HedefTur = TUR, @GirDepo = GIRISDEPO, @CikDepo = CIKISDEPO
    FROM FATBASLIK WHERE ID = @HedefBaslikID;

    DECLARE @DepoId INT = CASE WHEN @HedefTur IN (4, 14, 15, 16, 99, 119)
                               THEN @CikDepo ELSE @GirDepo END;

    -- Depo hareketi yapilacak mi? Rota matrisi soyler:
    --   siparis -> irsaliye/fatura : 1 (stok ILK KEZ burada cikar/girer)
    --   irsaliye -> fatura         : 0 (stok zaten irsaliyeyle hareket etti;
    --                                   satir K-B karariyla ADET=0 ile acilir)
    DECLARE @StokDegis BIT =
        ISNULL((SELECT StokDurumDegis FROM dbo.fn_Prog_BelgeDonusum_Rota()
                WHERE DonusumTuru = @DonusumTuru), 0);

    -- ---------- 1) Yeni seri/lot kartlari ----------
    --   GIRIS donusumlerinde lot tedarikciden gelir, kart HENUZ YOKTUR.
    --   Kart BURADA acilir - cagiranin transaction'i icinde, boylece donusum
    --   geri sararsa kart da geri sarar.
    UPDATE I SET I.SerilotId = SSL.ID
      FROM #DonusumIzlemeSecim I
           INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = I.UrunId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = ISNULL(I.SeriNo, N'') COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'') COLLATE DATABASE_DEFAULT
     WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0;

    INSERT INTO dbo.STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
    SELECT DISTINCT I.UrunId, ISNULL(I.SeriNo, N''), ISNULL(I.LotNo, N''),
           ISNULL(I.Urt, '1990-01-01'), ISNULL(I.Skt, '1990-01-01')
    FROM #DonusumIzlemeSecim I
    WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0
      AND ISNULL(I.UrunId, 0) > 0
      AND (ISNULL(I.SeriNo, N'') <> N'' OR ISNULL(I.LotNo, N'') <> N'');

    UPDATE I SET I.SerilotId = SSL.ID
      FROM #DonusumIzlemeSecim I
           INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = I.UrunId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = ISNULL(I.SeriNo, N'') COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'') COLLATE DATABASE_DEFAULT
     WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0;

    IF EXISTS (SELECT 1 FROM #DonusumIzlemeSecim
               WHERE ISNULL(SerilotId, 0) = 0 AND ISNULL(StokIzlemeId, 0) = 0)
        THROW 51200, N'Seri/lot karti olusturulamadi (seri no ve lot no bos olamaz).', 1;

    -- ---------- 2) Her satir cifti icin kanonik SP ----------
    DECLARE @KaynakSatir INT, @HedefSatir INT, @Json NVARCHAR(MAX), @Secim NVARCHAR(MAX);
    DECLARE @Sonuc TABLE (Sonuc NVARCHAR(MAX));

    DECLARE cp CURSOR LOCAL FAST_FORWARD FOR
        SELECT I.SatirId, E.HedefSatirId
        FROM #DonusumIzlemeSecim I
             INNER JOIN #DonusumSatirEsleme E ON E.KaynakSatirId = I.SatirId
        GROUP BY I.SatirId, E.HedefSatirId;
    OPEN cp; FETCH NEXT FROM cp INTO @KaynakSatir, @HedefSatir;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Kaynakta izlem kaydi VARSA tasima (kaynakIzlemId), yoksa depodan
        --   secim (serilotId). Aktar_Json ikisini de tanir.
        SET @Secim =
            ISNULL((SELECT kaynakIzlemId = ISNULL(I.StokIzlemeId, 0),
                           serilotId     = ISNULL(I.SerilotId, 0),
                           adet          = I.Adet
                    FROM #DonusumIzlemeSecim I
                    WHERE I.SatirId = @KaynakSatir
                    FOR JSON PATH), N'[]');

        DECLARE @Tasima BIT = CASE WHEN EXISTS (
            SELECT 1 FROM #DonusumIzlemeSecim I
            WHERE I.SatirId = @KaynakSatir AND ISNULL(I.StokIzlemeId, 0) > 0)
            THEN 1 ELSE 0 END;

        SET @Json =
            N'{' +
            CASE WHEN @Tasima = 1
                 THEN N'"kaynak":{"satirId":' + CAST(@KaynakSatir AS nvarchar(12)) + N'},'
                 ELSE N'' END +
            N'"hedef":{"tur":' + CAST(@HedefTur AS nvarchar(10)) +
            N',"baslikId":' + CAST(@HedefBaslikID AS nvarchar(12)) +
            N',"satirId":'  + CAST(@HedefSatir AS nvarchar(12)) + N'},' +
            N'"depoId":' + CAST(ISNULL(@DepoId, 0) AS nvarchar(12)) + N',' +
            N'"stokHareketi":' + CASE WHEN @StokDegis = 1 THEN N'true' ELSE N'false' END + N',' +
            N'"kullaniciId":' + CAST(@KullaniciID AS nvarchar(12)) + N',' +
            N'"secim":' + @Secim + N'}';

        DELETE @Sonuc;
        INSERT @Sonuc (Sonuc)
        EXEC dbo.sp_Prog_Izleme_Aktar_Json @Kosullar = @Json;

        SET @Aktarilan = @Aktarilan +
            ISNULL((SELECT TRY_CAST(JSON_VALUE(Sonuc, '$.Aktarilan') AS INT) FROM @Sonuc), 0);

        FETCH NEXT FROM cp INTO @KaynakSatir, @HedefSatir;
    END
    CLOSE cp; DEALLOCATE cp;
END
GO

-- ---- PROCEDURE: sp_prog_izleme_aday_json  (kaynak: GenDepoUpdate111) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Aday_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod         NVARCHAR(20) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.mod'), N'donusum'));
    DECLARE @StokId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')      AS INT);
    DECLARE @IzlemTur    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur')    AS INT);
    DECLARE @DepoId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.depoId')      AS INT);
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.donusumTuru') AS INT);
    DECLARE @HedefBaslik INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId')  AS INT);
    DECLARE @HedefSatir  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')   AS INT);
    DECLARE @KaynakBaslik INT= TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.baslikId') AS INT);
    DECLARE @KaynakSatir INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.satirId')  AS INT);

    IF @StokId IS NULL OR @StokId <= 0 THROW 51001, N'stokId zorunlu.', 1;
    IF @Mod NOT IN (N'donusum', N'cikis', N'giris')
        THROW 51001, N'mod "donusum", "cikis" ya da "giris" olmali. (Sayim ayri akistir.)', 1;

    -- ---------- Yontem secimi ----------
    DECLARE @Yontem NVARCHAR(10);

    -- CAGIRAN DOGRUDAN SOYLEYEBILIR: izleme ekrani hangi listeye ihtiyaci
    --   oldugunu bilir ama donusum TURUNU bilmez (elinde yalniz kaynak satir
    --   vardir). "yontem" verildiginde rota matrisine bakilmaz.
    DECLARE @YontemDis NVARCHAR(10) = LOWER(NULLIF(JSON_VALUE(@Kosullar, '$.yontem'), N''));
    IF @YontemDis IS NOT NULL AND @YontemDis NOT IN (N'tasima', N'depo', N'kendi')
        THROW 51001, N'yontem "tasima", "depo" ya da "kendi" olmali.', 1;

    IF @YontemDis IS NOT NULL
        SET @Yontem = @YontemDis
    ELSE IF @Mod = N'donusum'
    BEGIN
        IF @DonusumTuru IS NULL THROW 51001, N'mod=donusum icin donusumTuru zorunlu.', 1;
        IF @KaynakSatir IS NULL OR @KaynakSatir <= 0
            THROW 51001, N'mod=donusum icin kaynak.satirId zorunlu.', 1;

        DECLARE @KaynakDetay NVARCHAR(20);
        SELECT @KaynakDetay = KaynakDetayTablo
        FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

        IF @KaynakDetay IS NULL
        BEGIN
            DECLARE @m NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
            THROW 51200, @m, 1;
        END
        -- Kaynak FATURA -> tasinacak kayit VAR; SIPARISDETAY -> depodan secilir
        SET @Yontem = CASE WHEN @KaynakDetay = 'FATURA' THEN N'tasima' ELSE N'depo' END;
    END
    ELSE IF @Mod = N'cikis'
        SET @Yontem = N'depo'
    ELSE
        SET @Yontem = N'kendi';

    IF @Yontem = N'depo' AND (@DepoId IS NULL OR @DepoId <= 0)
        THROW 51001, N'Depodan secim icin gecerli depoId zorunlu.', 1;

    -- ---------- H2: bu satirin halihazirdaki secimi ----------
    DECLARE @Secili TABLE (SERILOTID INT PRIMARY KEY, Adet DECIMAL(18,6), IzlemId INT);
    IF ISNULL(@HedefSatir, 0) > 0
        INSERT @Secili (SERILOTID, Adet, IzlemId)
        SELECT SI.SERILOTID, SUM(ISNULL(SI.ADET, 0)), MIN(SI.ID)
        FROM dbo.STOKIZLEME SI
        WHERE SI.BASLIKID = @HedefBaslik AND SI.SATIRID = @HedefSatir
          AND ISNULL(SI.SERILOTID, 0) > 0
        GROUP BY SI.SERILOTID;

    -- ============================================================
    IF @Yontem = N'tasima'
    BEGIN
        -- Kaynak belge satirindan tasinabilir seri/lot
        -- MEVCUT = kaynagin kalani ARTI bu hedef satirin KENDI aldigi.
        --   Kendi etkisini geri eklemezsek kayitli bir donusum yeniden
        --   acildiginda kaynak "tukenmis" gorunur (KALAN 0) ve kullanici
        --   adedi ARTIRAMAZ - yalnizca dusurebilir. Depo yonteminde ayni
        --   duzeltme zaten vardi; tasimada eksikti. (08.08.2026: 114116 ->
        --   114118 donusumunde ekran DURUM 0 gosterdi, izlem degistirilemedi.)
        --   Baglanti DONUSID uzerinden KESIN: hedefin satiri kaynagin hangi
        --   izlem kaydindan aldigini orada tutar.
        SELECT SERILOTID   = SI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(ABS(ISNULL(SI.KALAN, 0)) + ISNULL(K.Kendi, 0) AS decimal(18,6)),
               SECILI      = CAST(CASE WHEN S.SERILOTID IS NULL THEN 0 ELSE 1 END AS bit),
               SECILENADET = CAST(ISNULL(ABS(S.Adet), 0) AS decimal(18,6)),
               KAYNAKIZLEMID = SI.ID
        FROM dbo.STOKIZLEME SI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SI.SERILOTID
             LEFT JOIN @Secili S ON S.SERILOTID = SI.SERILOTID
             OUTER APPLY (
                 SELECT Kendi = SUM(ABS(ISNULL(H.ADET, 0)))
                 FROM dbo.STOKIZLEME H
                 WHERE ISNULL(@HedefSatir, 0) > 0
                   AND H.SATIRID = @HedefSatir
                   AND H.DONUSID = SI.ID
             ) K
        WHERE SI.SATIRID = @KaynakSatir
          AND SI.BASLIKID = ISNULL(NULLIF(@KaynakBaslik, 0), SI.BASLIKID)
          -- Tukenmis kayit gizlenir; ISTISNA: hedefte zaten secili olan kalir
          AND (ABS(ISNULL(SI.KALAN, 0)) + ISNULL(K.Kendi, 0) > 0.0001
               OR S.SERILOTID IS NOT NULL)
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
    ELSE IF @Yontem = N'depo'
    BEGIN
        -- Depodaki bakiyeden secim.
        --   MEVCUT = STOKDURUMIZLEME.KALAN EKSI bu satirin KENDI hareketi
        --   (eski SQLCikan'in iki dalli hesabinin karsiligi: bakiye + kendi
        --    etkisinin geri alinmasi. Boylece satir yeniden acildiginda
        --    kullanici kendi sectigini "hala secilebilir" gorur.)
        SELECT SERILOTID   = SDI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) AS decimal(18,6)),
               SECILI      = CAST(CASE WHEN S.SERILOTID IS NULL THEN 0 ELSE 1 END AS bit),
               SECILENADET = CAST(ISNULL(ABS(S.Adet), 0) AS decimal(18,6)),
               KAYNAKIZLEMID = CAST(NULL AS INT)
        FROM dbo.STOKDURUMIZLEME SDI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SDI.SERILOTID
             LEFT JOIN @Secili S ON S.SERILOTID = SDI.SERILOTID
             OUTER APPLY (
                 SELECT Kendi = SUM(ISNULL(D.ADET, 0))
                 FROM dbo.STOKIZLEMEDEPO D
                      INNER JOIN dbo.STOKIZLEME SI2 ON SI2.ID = D.IZLEMID
                 WHERE SI2.SATIRID = @HedefSatir
                   AND SI2.SERILOTID = SDI.SERILOTID
                   AND D.DEPOID = @DepoId
             ) K
        WHERE SDI.STOKID = @StokId
          AND SDI.DEPOID = @DepoId
          AND (ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) > 0.0001 OR S.SERILOTID IS NOT NULL)
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
    ELSE
    BEGIN
        -- GIRIS: bu belge satirinin KENDI kayitlari. Kullanici yeni seri/lot
        --   girer; mevcutlar isaretli gelir (eski SQLGiren'in karsiligi).
        --   Giriste "depodaki bakiye" kavrami YOK - stok bu belgeyle olusuyor.
        SELECT SERILOTID   = SI.SERILOTID,
               SERINO      = SSL.SERINO,
               LOTNO       = SSL.LOTNO,
               SKT         = SSL.SKT,
               URT         = SSL.URT,
               MEVCUT      = CAST(SUM(ISNULL(SI.ADET, 0)) AS decimal(18,6)),
               SECILI      = CAST(1 AS bit),
               SECILENADET = CAST(SUM(ISNULL(SI.ADET, 0)) AS decimal(18,6)),
               KAYNAKIZLEMID = MIN(SI.ID)
        FROM dbo.STOKIZLEME SI
             INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SI.SERILOTID
        WHERE SI.BASLIKID = @HedefBaslik AND SI.SATIRID = @HedefSatir
          AND (@IzlemTur IS NULL OR SI.IZLEMTUR = @IzlemTur)
        GROUP BY SI.SERILOTID, SSL.SERINO, SSL.LOTNO, SSL.SKT, SSL.URT
        ORDER BY SSL.SKT, SSL.LOTNO, SSL.SERINO;
    END
END
GO

-- ---- PROCEDURE: sp_prog_izleme_aktar_json  (kaynak: GenDepoUpdate109) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Aktar_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KaynakSatir INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.satirId') AS INT);
    DECLARE @HedefTur    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.hedef.tur')      AS INT);
    DECLARE @HedefBaslik INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.hedef.baslikId') AS INT);
    DECLARE @HedefSatir  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.hedef.satirId')  AS INT);
    DECLARE @DepoId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.depoId')         AS INT);
    DECLARE @StokHar     BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.stokHareketi') AS BIT), 1);
    DECLARE @KulId       INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kullaniciId') AS INT), 0);
    DECLARE @Istenen DECIMAL(18,6) = TRY_CAST(JSON_VALUE(@Kosullar, '$.istenenAdet') AS DECIMAL(18,6));

    IF @HedefSatir  IS NULL OR @HedefSatir  <= 0 THROW 51001, N'hedef.satirId zorunlu.', 1;
    IF @HedefBaslik IS NULL OR @HedefBaslik <= 0 THROW 51001, N'hedef.baslikId zorunlu.', 1;
    IF @HedefTur    IS NULL                      THROW 51001, N'hedef.tur zorunlu.', 1;

    IF @StokHar = 1 AND ISNULL(@DepoId, 0) <= 0
        THROW 51001, N'Stok hareketi yapilacaksa gecerli depoId zorunlu.', 1;

    DECLARE @SecimVar BIT = CASE WHEN EXISTS (SELECT 1 FROM OPENJSON(@Kosullar, '$.secim')) THEN 1 ELSE 0 END;
    -- Kaynak yoksa DEPODAN kip; secim zorunlu (neyin cikacagini kimse tahmin edemez)
    DECLARE @Depodan BIT = CASE WHEN ISNULL(@KaynakSatir, 0) > 0 THEN 0 ELSE 1 END;

    IF @Depodan = 1 AND @SecimVar = 0
        THROW 51001, N'Kaynak belgede seri/lot kaydi olmadigindan secim zorunlu (depodan secilir).', 1;

    DECLARE @T TABLE (Sira INT IDENTITY, KaynakIzlemId INT NULL, SerilotId INT,
                      StokId INT, IzlemTur INT, Yer INT, Adet DECIMAL(18,6));

    -- ============================================================
    -- B) DEPODAN SECIM  (kaynak STOKIZLEME kaydi yok - siparis vb.)
    -- ============================================================
    IF @Depodan = 1
    BEGIN
        DECLARE @StokId INT, @IzlemTur INT, @SatirAdet DECIMAL(18,6);
        SELECT @StokId = F.URUNID, @IzlemTur = ISNULL(F.IZLEME, 0),
               @SatirAdet = ABS(ISNULL(F.ADET, 0))
        FROM dbo.FATURA F WHERE F.ID = @HedefSatir;

        IF @StokId IS NULL THROW 51001, N'hedef.satirId bulunamadi.', 1;

        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT NULL, J.SerilotId, @StokId, @IzlemTur, 0, SUM(J.Adet)
        FROM OPENJSON(@Kosullar, '$.secim')
             WITH (SerilotId INT '$.serilotId', Adet DECIMAL(18,6) '$.adet') J
        WHERE J.Adet > 0 AND ISNULL(J.SerilotId, 0) > 0
        GROUP BY J.SerilotId;

        -- Secilen toplam satir adediyle uyusmali
        DECLARE @Toplam DECIMAL(18,6) = ISNULL((SELECT SUM(Adet) FROM @T), 0);
        IF @SatirAdet > 0 AND ABS(@Toplam - @SatirAdet) > 0.0001
        BEGIN
            DECLARE @m3 NVARCHAR(300) =
                N'Secilen seri/lot toplami (' + CAST(CAST(@Toplam AS decimal(18,3)) AS nvarchar(30))
              + N') satir adediyle (' + CAST(CAST(@SatirAdet AS decimal(18,3)) AS nvarchar(30))
              + N') ayni degil.';
            THROW 51200, @m3, 1;
        END

        -- Depoda yeterli bakiye var mi (bu satirin kendi hareketi haric)
        --   YALNIZ CIKISTA: alista mal GELIYOR, lotun depoda bulunmasi
        --   beklenmez. Yon asagida hesaplaniyor; burada ayni kurali kullan.
        IF @StokHar = 1 AND @HedefTur IN (4, 14, 15, 16, 99, 119) AND EXISTS (
            SELECT 1 FROM @T T
            OUTER APPLY (
                SELECT Mevcut = ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0)
                FROM dbo.STOKDURUMIZLEME SDI
                     OUTER APPLY (SELECT Kendi = SUM(ISNULL(D.ADET, 0))
                                  FROM dbo.STOKIZLEMEDEPO D
                                       INNER JOIN dbo.STOKIZLEME SI2 ON SI2.ID = D.IZLEMID
                                  WHERE SI2.SATIRID = @HedefSatir
                                    AND SI2.SERILOTID = T.SerilotId
                                    AND D.DEPOID = @DepoId) K
                WHERE SDI.SERILOTID = T.SerilotId AND SDI.DEPOID = @DepoId) M
            WHERE ISNULL(M.Mevcut, 0) + 0.0001 < T.Adet)
        BEGIN
            DECLARE @m4 NVARCHAR(400) =
                (SELECT TOP 1 N'"' + ISNULL(SSL.LOTNO, SSL.SERINO)
                     + N'" icin depoda yeterli miktar yok (mevcut: '
                     + CAST(CAST(ISNULL(M.Mevcut, 0) AS decimal(18,3)) AS nvarchar(30))
                     + N', istenen: ' + CAST(CAST(T.Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
                 FROM @T T
                      INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = T.SerilotId
                      OUTER APPLY (
                          SELECT Mevcut = ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0)
                          FROM dbo.STOKDURUMIZLEME SDI
                               OUTER APPLY (SELECT Kendi = SUM(ISNULL(D.ADET, 0))
                                            FROM dbo.STOKIZLEMEDEPO D
                                                 INNER JOIN dbo.STOKIZLEME SI2 ON SI2.ID = D.IZLEMID
                                            WHERE SI2.SATIRID = @HedefSatir
                                              AND SI2.SERILOTID = T.SerilotId
                                              AND D.DEPOID = @DepoId) K
                          WHERE SDI.SERILOTID = T.SerilotId AND SDI.DEPOID = @DepoId) M
                 WHERE ISNULL(M.Mevcut, 0) + 0.0001 < T.Adet);
            THROW 51200, @m4, 1;
        END
    END
    -- ============================================================
    -- A) TASIMA  (kaynak belgede STOKIZLEME kaydi var)
    -- ============================================================
    ELSE IF @SecimVar = 1
    BEGIN
        -- Eslesme once kaynakIzlemId (kesin), yoksa serilotId
        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT SI.ID, SI.SERILOTID, SI.STOKID, SI.IZLEMTUR, SI.YER, J.Adet
        FROM OPENJSON(@Kosullar, '$.secim')
             WITH (KaynakIzlemId INT '$.kaynakIzlemId', Adet DECIMAL(18,6) '$.adet') J
             INNER JOIN dbo.STOKIZLEME SI ON SI.ID = J.KaynakIzlemId
        WHERE J.Adet > 0 AND ISNULL(J.KaynakIzlemId, 0) > 0
          AND SI.SATIRID = @KaynakSatir;

        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT MIN(SI.ID), SI.SERILOTID, MIN(SI.STOKID), MIN(SI.IZLEMTUR), MIN(SI.YER), MIN(J.Adet)
        FROM OPENJSON(@Kosullar, '$.secim')
             WITH (KaynakIzlemId INT '$.kaynakIzlemId',
                   SerilotId INT '$.serilotId', Adet DECIMAL(18,6) '$.adet') J
             INNER JOIN dbo.STOKIZLEME SI ON SI.SATIRID = @KaynakSatir
                                         AND SI.SERILOTID = J.SerilotId
        WHERE J.Adet > 0 AND ISNULL(J.KaynakIzlemId, 0) = 0
          AND NOT EXISTS (SELECT 1 FROM @T T2 WHERE T2.SerilotId = J.SerilotId)
        GROUP BY SI.SERILOTID;

        IF EXISTS (SELECT 1 FROM @T T
                   INNER JOIN dbo.STOKIZLEME SI ON SI.ID = T.KaynakIzlemId
                   WHERE ABS(ISNULL(SI.KALAN, 0)) + 0.0001 < T.Adet)
        BEGIN
            DECLARE @m2 NVARCHAR(300) =
                (SELECT TOP 1 N'Secilen seri/lot icin kaynakta yeterli kalan yok (mevcut: '
                     + CAST(CAST(ABS(ISNULL(SI.KALAN,0)) AS decimal(18,3)) AS nvarchar(30))
                     + N', istenen: ' + CAST(CAST(T.Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
                 FROM @T T INNER JOIN dbo.STOKIZLEME SI ON SI.ID = T.KaynakIzlemId
                 WHERE ABS(ISNULL(SI.KALAN, 0)) + 0.0001 < T.Adet);
            THROW 51200, @m2, 1;
        END
    END
    ELSE IF ISNULL(@Istenen, 0) > 0
    BEGIN
        -- KISMI: FIFO ile istenen kadar
        DECLARE @Mevcut DECIMAL(18,6) =
            ISNULL((SELECT SUM(ABS(ISNULL(SI.KALAN, 0)))
                    FROM dbo.STOKIZLEME SI WHERE SI.SATIRID = @KaynakSatir), 0);

        IF @Mevcut + 0.0001 < @Istenen
        BEGIN
            DECLARE @msg NVARCHAR(300) =
                N'Kaynak belgede tasinabilir seri/lot yetersiz (mevcut: '
              + CAST(CAST(@Mevcut  AS decimal(18,3)) AS nvarchar(30)) + N', istenen: '
              + CAST(CAST(@Istenen AS decimal(18,3)) AS nvarchar(30)) + N').';
            THROW 51200, @msg, 1;
        END

        ;WITH K AS (
            SELECT SI.ID, SI.SERILOTID, SI.STOKID, SI.IZLEMTUR, SI.YER,
                   Kalan = ABS(ISNULL(SI.KALAN, 0)),
                   Onceki = ISNULL(SUM(ABS(ISNULL(SI.KALAN, 0))) OVER (
                                ORDER BY SSL.SKT, SI.ID
                                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0)
            FROM dbo.STOKIZLEME SI
                 INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SI.SERILOTID
            WHERE SI.SATIRID = @KaynakSatir AND ABS(ISNULL(SI.KALAN, 0)) > 0.0001
        )
        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT K.ID, K.SERILOTID, K.STOKID, K.IZLEMTUR, K.YER,
               CASE WHEN K.Onceki + K.Kalan <= @Istenen THEN K.Kalan
                    ELSE @Istenen - K.Onceki END
        FROM K
        WHERE K.Onceki < @Istenen - 0.0001;
    END
    ELSE
        -- Secim de istenenAdet de yok: kaynagin TUM kalani (eski davranis)
        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT SI.ID, SI.SERILOTID, SI.STOKID, SI.IZLEMTUR, SI.YER, ABS(ISNULL(SI.KALAN, 0))
        FROM dbo.STOKIZLEME SI
        WHERE SI.SATIRID = @KaynakSatir AND ABS(ISNULL(SI.KALAN, 0)) > 0.0001;

    IF NOT EXISTS (SELECT 1 FROM @T)
    BEGIN
        SELECT (SELECT 1 AS Sonuc, 0 AS Aktarilan, 0 AS ToplamAdet
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- Yon: cikis nitelikli hedef turlerde depo hareketi NEGATIF
    DECLARE @Yon INT = CASE WHEN @HedefTur IN (4, 14, 15, 16, 99, 119) THEN -1 ELSE 1 END;

    DECLARE @Sira INT, @Adet DECIMAL(18,6), @YeniId INT, @Aktarilan INT = 0,
            @ToplamY DECIMAL(18,6) = 0;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Sira, Adet FROM @T ORDER BY Sira;
    OPEN c; FETCH NEXT FROM c INTO @Sira, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                    ADET, KALAN, YER, YERID, DONUSID, SERILOTID, EKLEYEN)
        SELECT T.StokId, @HedefTur, @HedefBaslik, @HedefSatir, T.IzlemTur,
               @Adet, @Adet, ISNULL(T.Yer, 0), 0, ISNULL(T.KaynakIzlemId, 0),
               T.SerilotId, @KulId
        FROM @T T WHERE T.Sira = @Sira;

        SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);
        IF @YeniId IS NOT NULL
        BEGIN
            -- K-B: stok hareketi yoksa da satir acilir, ADET = 0
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, ISNULL(@DepoId, 0),
                    CASE WHEN @StokHar = 1 THEN @Yon * @Adet ELSE 0 END);

            -- Tasima kipinde kaynagin KALAN'ina ELLE DOKUNULMAZ:
            --   TG_IzlemOrjinalYap DONUSID'ye bakip zaten duserir.
            SET @Aktarilan = @Aktarilan + 1;
            SET @ToplamY = @ToplamY + @Adet;
        END
        FETCH NEXT FROM c INTO @Sira, @Adet;
    END
    CLOSE c; DEALLOCATE c;

    SELECT (SELECT 1 AS Sonuc, @Aktarilan AS Aktarilan, @ToplamY AS ToplamAdet,
                   CASE WHEN @Depodan = 1 THEN N'depodan' ELSE N'tasima' END AS Kip
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_prog_izleme_bakiyekontrol  (kaynak: GenDepoUpdate94) ----
-- ============================================================
-- 3) sp_Prog_Izleme_BakiyeKontrol - SALT OKUMA RAPOR
--
--    STOKDURUMIZLEME (trigger'la tutulan bakiye) ile gercek hareket toplamini
--    (SUM(STOKIZLEMEDEPO.ADET)) karsilastirir. HICBIR SEY YAZMAZ.
--
--    @Ayrinti = 0 : yalnizca ozet (toplam / uyusan / sapan)
--    @Ayrinti = 1 : sapan kayitlarin listesi (en buyuk farktan baslayarak)
--    @Esik        : bu degerden kucuk mutlak farklar yok sayilir (yuvarlama)
--
--    Onarim BU DOSYADA YOK. Rapor gorulup karar verildikten sonra ayri bir
--    adimda yapilacak: musteride trigger'lardan onceki donemden gelen ya da
--    elle duzeltilmis bakiyeler olabilir.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_BakiyeKontrol
    @Ayrinti BIT   = 0,
    @Esik    FLOAT = 0.0001,
    @UstSinir INT  = 200
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Gercek AS
    (
        SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Hareket = SUM(ISNULL(D.ADET, 0))
        FROM dbo.STOKIZLEMEDEPO D
             INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
        GROUP BY SI.STOKID, D.DEPOID, SI.SERILOTID
    ),
    Karsilastirma AS
    (
        SELECT STOKID    = ISNULL(S.STOKID, G.STOKID),
               DEPOID    = ISNULL(S.DEPOID, G.DEPOID),
               SERILOTID = ISNULL(S.SERILOTID, G.SERILOTID),
               Bakiye    = ISNULL(S.KALAN, 0),
               Hareket   = ISNULL(G.Hareket, 0),
               Fark      = ISNULL(S.KALAN, 0) - ISNULL(G.Hareket, 0)
        FROM Gercek G
             FULL OUTER JOIN dbo.STOKDURUMIZLEME S
                  ON S.STOKID = G.STOKID AND S.DEPOID = G.DEPOID
                 AND S.SERILOTID = G.SERILOTID
    )
    SELECT Toplam  = COUNT(*),
           Uyusan  = SUM(CASE WHEN ABS(Fark) <  @Esik THEN 1 ELSE 0 END),
           Sapan   = SUM(CASE WHEN ABS(Fark) >= @Esik THEN 1 ELSE 0 END),
           EnBuyukFark = MAX(ABS(Fark)),
           -- Gecersiz depo (0) kayitlari ayrica sayilir: bakiye satiri gecerli
           --   bir depo olmadan olusmus demektir.
           GecersizDepo = SUM(CASE WHEN ISNULL(DEPOID, 0) = 0 THEN 1 ELSE 0 END)
    FROM Karsilastirma;

    IF @Ayrinti = 1
    BEGIN
        ;WITH Gercek AS
        (
            SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Hareket = SUM(ISNULL(D.ADET, 0))
            FROM dbo.STOKIZLEMEDEPO D
                 INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
            GROUP BY SI.STOKID, D.DEPOID, SI.SERILOTID
        ),
        Karsilastirma AS
        (
            SELECT STOKID    = ISNULL(S.STOKID, G.STOKID),
                   DEPOID    = ISNULL(S.DEPOID, G.DEPOID),
                   SERILOTID = ISNULL(S.SERILOTID, G.SERILOTID),
                   Bakiye    = ISNULL(S.KALAN, 0),
                   Hareket   = ISNULL(G.Hareket, 0),
                   Fark      = ISNULL(S.KALAN, 0) - ISNULL(G.Hareket, 0)
            FROM Gercek G
                 FULL OUTER JOIN dbo.STOKDURUMIZLEME S
                      ON S.STOKID = G.STOKID AND S.DEPOID = G.DEPOID
                     AND S.SERILOTID = G.SERILOTID
        )
        SELECT TOP (@UstSinir)
               K.STOKID, StokKodu = ST.KOD, StokAdi = ST.STOKADI,
               K.DEPOID, DepoAdi = DP.DEPOADI,
               K.SERILOTID, SSL.SERINO, SSL.LOTNO,
               K.Bakiye, K.Hareket, K.Fark
        FROM Karsilastirma K
             LEFT JOIN dbo.STOKLAR     ST ON ST.ID = K.STOKID
             LEFT JOIN dbo.DEPOLAR     DP ON DP.ID = K.DEPOID
             LEFT JOIN dbo.STOKSERILOT SSL ON SSL.ID = K.SERILOTID
        WHERE ABS(K.Fark) >= @Esik
        ORDER BY ABS(K.Fark) DESC;
    END
END
GO

-- ---- PROCEDURE: sp_prog_izleme_bakiyeonar  (kaynak: GenDepoUpdate95) ----
-- ============================================================
-- sp_Prog_Izleme_BakiyeOnar
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_BakiyeOnar
    @Uygula            BIT   = 0,      -- 0 = KURU CALISMA (yazma yok)
    @Esik              FLOAT = 0.0001,
    @StokID            INT   = NULL,   -- kapsam daraltma
    @DepoID            INT   = NULL,
    @GecersizDepoDahil BIT   = 0,      -- DEPOID = 0 kayitlari
    @HareketsizSifirla BIT   = 0,      -- bakiyesi olup hareketi olmayanlari sifirla
    @KullaniciID       INT   = NULL,
    @PartiID           INT   = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Aday TABLE (
        STOKID INT, DEPOID INT, SERILOTID INT,
        EskiKalan FLOAT NULL, YeniKalan FLOAT, Fark FLOAT, SatirVar BIT,
        PRIMARY KEY (STOKID, DEPOID, SERILOTID));

    INSERT @Aday (STOKID, DEPOID, SERILOTID, EskiKalan, YeniKalan, Fark, SatirVar)
    SELECT K.STOKID, K.DEPOID, K.SERILOTID, K.Bakiye, K.Hareket,
           K.Bakiye - K.Hareket, K.SatirVar
    FROM (
        SELECT STOKID    = ISNULL(S.STOKID, G.STOKID),
               DEPOID    = ISNULL(S.DEPOID, G.DEPOID),
               SERILOTID = ISNULL(S.SERILOTID, G.SERILOTID),
               Bakiye    = S.KALAN,                 -- NULL = bakiye satiri YOK
               Hareket   = ISNULL(G.Hareket, 0),
               SatirVar  = CASE WHEN S.STOKID IS NULL THEN 0 ELSE 1 END,
               HareketVar= CASE WHEN G.STOKID IS NULL THEN 0 ELSE 1 END
        FROM (SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Hareket = SUM(ISNULL(D.ADET, 0))
              FROM dbo.STOKIZLEMEDEPO D
                   INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
              GROUP BY SI.STOKID, D.DEPOID, SI.SERILOTID) G
             FULL OUTER JOIN dbo.STOKDURUMIZLEME S
                  ON S.STOKID = G.STOKID AND S.DEPOID = G.DEPOID
                 AND S.SERILOTID = G.SERILOTID
    ) K
    WHERE ABS(ISNULL(K.Bakiye, 0) - K.Hareket) >= @Esik
      AND (@StokID IS NULL OR K.STOKID = @StokID)
      AND (@DepoID IS NULL OR K.DEPOID = @DepoID)
      AND (@GecersizDepoDahil = 1 OR ISNULL(K.DEPOID, 0) <> 0)
      -- Bakiyesi var ama HIC hareketi yok: varsayilan olarak DOKUNMA
      AND (@HareketsizSifirla = 1 OR K.HareketVar = 1);

    IF @Uygula = 0
    BEGIN
        -- KURU CALISMA: ne yapilacagini goster, hicbir sey yazma
        SELECT Mod = N'KURU CALISMA - hicbir sey yazilmadi',
               Etkilenecek = COUNT(*),
               EklenecekSatir = SUM(CASE WHEN SatirVar = 0 THEN 1 ELSE 0 END),
               GuncellenecekSatir = SUM(CASE WHEN SatirVar = 1 THEN 1 ELSE 0 END),
               EnBuyukFark = MAX(ABS(Fark))
        FROM @Aday;

        SELECT TOP 200
               A.STOKID, StokKodu = ST.KOD, StokAdi = ST.STOKADI,
               A.DEPOID, DepoAdi = DP.DEPOADI,
               A.SERILOTID, SSL.SERINO, SSL.LOTNO,
               EskiKalan = A.EskiKalan, YeniKalan = A.YeniKalan, Fark = A.Fark,
               Islem = CASE WHEN A.SatirVar = 0 THEN N'EKLE' ELSE N'GUNCELLE' END
        FROM @Aday A
             LEFT JOIN dbo.STOKLAR     ST  ON ST.ID  = A.STOKID
             LEFT JOIN dbo.DEPOLAR     DP  ON DP.ID  = A.DEPOID
             LEFT JOIN dbo.STOKSERILOT SSL ON SSL.ID = A.SERILOTID
        ORDER BY ABS(A.Fark) DESC;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM @Aday)
    BEGIN
        SELECT Mod = N'Onarilacak kayit yok', Etkilenen = 0, PartiID = 0;
        RETURN;
    END

    SET @PartiID = ISNULL((SELECT MAX(PARTIID) FROM dbo.IZLEMEBAKIYEONARIM), 0) + 1;

    BEGIN TRAN;

        -- Once kaydi yaz (eski deger dahil) - geri alinabilirlik icin
        INSERT dbo.IZLEMEBAKIYEONARIM
               (PARTIID, KULLANICIID, STOKID, DEPOID, SERILOTID, ESKIKALAN, YENIKALAN, FARK)
        SELECT @PartiID, @KullaniciID, STOKID, DEPOID, SERILOTID, EskiKalan, YeniKalan, Fark
        FROM @Aday;

        -- Eksik bakiye satirlarini ac
        INSERT dbo.STOKDURUMIZLEME (STOKID, DEPOID, SERILOTID, KALAN)
        SELECT A.STOKID, A.DEPOID, A.SERILOTID, A.YeniKalan
        FROM @Aday A WHERE A.SatirVar = 0;

        -- Mevcutlari duzelt
        UPDATE S
           SET S.KALAN = A.YeniKalan
          FROM dbo.STOKDURUMIZLEME S
               INNER JOIN @Aday A ON A.STOKID = S.STOKID AND A.DEPOID = S.DEPOID
                                 AND A.SERILOTID = S.SERILOTID
         WHERE A.SatirVar = 1;

    COMMIT;

    SELECT Mod = N'UYGULANDI', PartiID = @PartiID,
           Etkilenen = (SELECT COUNT(*) FROM dbo.IZLEMEBAKIYEONARIM WHERE PARTIID = @PartiID),
           GeriAlmaKomutu = N'EXEC dbo.sp_Prog_Izleme_BakiyeOnar_GeriAl @PartiID = '
                          + CAST(@PartiID AS nvarchar(12));
END
GO

-- ---- PROCEDURE: sp_prog_izleme_bakiyeonar_gerial  (kaynak: GenDepoUpdate95) ----
-- ============================================================
-- sp_Prog_Izleme_BakiyeOnar_GeriAl
--   Bir partiyi ESKI degerlerine dondurur. Onarim sirasinda EKLENEN satirlar
--   (ESKIKALAN NULL) SILINIR, guncellenenler eski degerine yazilir.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_BakiyeOnar_GeriAl
    @PartiID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.IZLEMEBAKIYEONARIM
                    WHERE PARTIID = @PartiID AND GERIALINDI = 0)
    BEGIN
        SELECT Mod = N'Geri alinacak parti yok ya da zaten geri alinmis';
        RETURN;
    END

    BEGIN TRAN;

        -- Onarimda EKLENEN satirlari kaldir
        DELETE S
          FROM dbo.STOKDURUMIZLEME S
               INNER JOIN dbo.IZLEMEBAKIYEONARIM O
                    ON O.STOKID = S.STOKID AND O.DEPOID = S.DEPOID
                   AND O.SERILOTID = S.SERILOTID
         WHERE O.PARTIID = @PartiID AND O.GERIALINDI = 0 AND O.ESKIKALAN IS NULL;

        -- Guncellenenleri eski degerine dondur
        UPDATE S
           SET S.KALAN = O.ESKIKALAN
          FROM dbo.STOKDURUMIZLEME S
               INNER JOIN dbo.IZLEMEBAKIYEONARIM O
                    ON O.STOKID = S.STOKID AND O.DEPOID = S.DEPOID
                   AND O.SERILOTID = S.SERILOTID
         WHERE O.PARTIID = @PartiID AND O.GERIALINDI = 0 AND O.ESKIKALAN IS NOT NULL;

        UPDATE dbo.IZLEMEBAKIYEONARIM SET GERIALINDI = 1 WHERE PARTIID = @PartiID;

    COMMIT;

    SELECT Mod = N'GERI ALINDI', PartiID = @PartiID,
           Satir = (SELECT COUNT(*) FROM dbo.IZLEMEBAKIYEONARIM WHERE PARTIID = @PartiID);
END
GO

-- ---- PROCEDURE: sp_prog_izleme_dogrula_json  (kaynak: GenDepoUpdate97) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Dogrula_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod         NVARCHAR(20) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.mod'), N'donusum'));
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.donusumTuru') AS INT);
    DECLARE @StokId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')      AS INT);
    DECLARE @IzlemTur    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur') AS INT), 0);
    DECLARE @DepoId      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.depoId')      AS INT);
    DECLARE @Gerekli     DECIMAL(18,6) = TRY_CAST(JSON_VALUE(@Kosullar, '$.gerekliAdet') AS DECIMAL(18,6));
    DECLARE @HedefBaslik INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId')  AS INT);
    DECLARE @HedefSatir  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')   AS INT);
    DECLARE @KaynakSatir INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynak.satirId')  AS INT);

    DECLARE @Sorun TABLE (Sira INT IDENTITY, KOD NVARCHAR(30), SERILOTID INT NULL,
                          MESAJ NVARCHAR(400));

    -- ---------- Girdiler ----------
    DECLARE @Secim TABLE (SERILOTID INT, Adet DECIMAL(18,6));
    INSERT @Secim (SERILOTID, Adet)
    SELECT J.SerilotId, J.Adet
    FROM OPENJSON(@Kosullar, '$.secim')
         WITH (SerilotId INT '$.serilotId', Adet DECIMAL(18,6) '$.adet') J;

    DECLARE @Yeni TABLE (SeriNo NVARCHAR(64), LotNo NVARCHAR(50),
                         Skt DATETIME, Urt DATETIME, Adet DECIMAL(18,6));
    INSERT @Yeni (SeriNo, LotNo, Skt, Urt, Adet)
    SELECT J.SeriNo, J.LotNo, J.Skt, J.Urt, J.Adet
    FROM OPENJSON(@Kosullar, '$.yeni')
         WITH (SeriNo NVARCHAR(64) '$.seriNo', LotNo NVARCHAR(50) '$.lotNo',
               Skt DATETIME '$.skt', Urt DATETIME '$.urt', Adet DECIMAL(18,6) '$.adet') J;

    -- ---------- 1) Izlemli satirda secim zorunlu ----------
    IF @IzlemTur > 0 AND NOT EXISTS (SELECT 1 FROM @Secim) AND NOT EXISTS (SELECT 1 FROM @Yeni)
        INSERT @Sorun (KOD, SERILOTID, MESAJ)
        SELECT N'SECIM_YOK', NULL,
               N'"' + ISNULL((SELECT STOKADI FROM dbo.STOKLAR WHERE ID = @StokId), N'?')
             + N'" izlemeli bir urun; seri/lot secimi yapilmali.';

    -- ---------- 2) Gecersiz adet ----------
    INSERT @Sorun (KOD, SERILOTID, MESAJ)
    SELECT N'ADET_GECERSIZ', S.SERILOTID,
           N'Seri/lot icin gecersiz adet: ' + CAST(CAST(S.Adet AS decimal(18,3)) AS nvarchar(30))
    FROM @Secim S WHERE ISNULL(S.Adet, 0) <= 0;

    -- ---------- 3) Ayni seri/lot birden fazla kez ----------
    INSERT @Sorun (KOD, SERILOTID, MESAJ)
    SELECT N'MUKERRER_LOT', S.SERILOTID,
           N'Ayni seri/lot birden fazla kez gonderildi.'
    FROM @Secim S GROUP BY S.SERILOTID HAVING COUNT(*) > 1;

    -- ---------- 4) Secilen toplam = gerekli adet ----------
    IF @Gerekli IS NOT NULL AND @Gerekli > 0
    BEGIN
        DECLARE @Toplam DECIMAL(18,6) =
            ISNULL((SELECT SUM(Adet) FROM @Secim), 0) + ISNULL((SELECT SUM(Adet) FROM @Yeni), 0);
        IF ABS(@Toplam - @Gerekli) > 0.0001
            INSERT @Sorun (KOD, SERILOTID, MESAJ)
            SELECT N'ADET_UYUMSUZ', NULL,
                   N'Secilen seri/lot toplami (' + CAST(CAST(@Toplam AS decimal(18,3)) AS nvarchar(30))
                 + N') satir adediyle (' + CAST(CAST(@Gerekli AS decimal(18,3)) AS nvarchar(30))
                 + N') ayni degil.';
    END

    -- ---------- 5) Secilen lotta yeterli kalan var mi ----------
    --   Kaynak turune gore olculur; aday listesiyle AYNI hesap:
    --     kaynak FATURA      -> kaynak STOKIZLEME.KALAN
    --     kaynak SIPARISDETAY-> depodaki bakiye EKSI bu satirin kendi hareketi
    DECLARE @KaynakDetay NVARCHAR(20);
    IF @DonusumTuru IS NOT NULL
        SELECT @KaynakDetay = KaynakDetayTablo
        FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakDetay = 'FATURA' AND ISNULL(@KaynakSatir, 0) > 0
        INSERT @Sorun (KOD, SERILOTID, MESAJ)
        SELECT N'LOT_KALAN_YETERSIZ', S.SERILOTID,
               N'Kaynak belgede bu seri/lot icin yeterli kalan yok (mevcut: '
             + CAST(CAST(ISNULL(K.Kalan, 0) AS decimal(18,3)) AS nvarchar(30))
             + N', istenen: ' + CAST(CAST(S.Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
        FROM @Secim S
             OUTER APPLY (SELECT Kalan = SUM(ABS(ISNULL(SI.KALAN, 0)))
                          FROM dbo.STOKIZLEME SI
                          WHERE SI.SATIRID = @KaynakSatir AND SI.SERILOTID = S.SERILOTID) K
        WHERE ISNULL(K.Kalan, 0) + 0.0001 < S.Adet;

    IF ISNULL(@KaynakDetay, 'SIPARISDETAY') = 'SIPARISDETAY' AND ISNULL(@DepoId, 0) > 0
        INSERT @Sorun (KOD, SERILOTID, MESAJ)
        SELECT N'LOT_KALAN_YETERSIZ', S.SERILOTID,
               N'Depoda bu seri/lot icin yeterli kalan yok (mevcut: '
             + CAST(CAST(ISNULL(D.Mevcut, 0) AS decimal(18,3)) AS nvarchar(30))
             + N', istenen: ' + CAST(CAST(S.Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
        FROM @Secim S
             OUTER APPLY (
                 SELECT Mevcut = ISNULL(SDI.KALAN, 0) - ISNULL(K2.Kendi, 0)
                 FROM dbo.STOKDURUMIZLEME SDI
                      OUTER APPLY (SELECT Kendi = SUM(ISNULL(DD.ADET, 0))
                                   FROM dbo.STOKIZLEMEDEPO DD
                                        INNER JOIN dbo.STOKIZLEME SI2 ON SI2.ID = DD.IZLEMID
                                   WHERE SI2.SATIRID = @HedefSatir
                                     AND SI2.SERILOTID = S.SERILOTID
                                     AND DD.DEPOID = @DepoId) K2
                 WHERE SDI.STOKID = @StokId AND SDI.DEPOID = @DepoId
                   AND SDI.SERILOTID = S.SERILOTID) D
        WHERE ISNULL(D.Mevcut, 0) + 0.0001 < S.Adet;

    -- ---------- 6) Yeni lot: ayni lot no farkli tarihlerle var mi ----------
    --   Eski TabIzlemBeforePost kurali (124 satir) - orada kullaniciya soruluyordu;
    --   burada UYARI olarak bildiriliyor, karar cagiranin.
    INSERT @Sorun (KOD, SERILOTID, MESAJ)
    SELECT N'LOT_TARIH_UYUSMAZ', SSL.ID,
           N'"' + Y.LotNo + N'" lot numarasi daha once farkli tarihlerle girilmis (SKT: '
         + ISNULL(CONVERT(nvarchar(10), SSL.SKT, 104), N'-') + N', URT: '
         + ISNULL(CONVERT(nvarchar(10), SSL.URT, 104), N'-') + N').'
    FROM @Yeni Y
         INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = @StokId AND SSL.LOTNO = Y.LotNo
    WHERE ISNULL(Y.LotNo, N'') <> N''
      AND (ISNULL(SSL.SKT, '1990-01-01') <> ISNULL(Y.Skt, '1990-01-01')
        OR ISNULL(SSL.URT, '1990-01-01') <> ISNULL(Y.Urt, '1990-01-01'));

    SELECT KOD, SERILOTID, MESAJ FROM @Sorun ORDER BY Sira;
END
GO

-- ---- PROCEDURE: sp_prog_izleme_yaz_json  (kaynak: GenDepoUpdate108) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Yaz_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tur      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.tur')      AS INT);
    DECLARE @BaslikId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId') AS INT);
    DECLARE @SatirId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')  AS INT);
    DECLARE @IslemTip INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.islemTip') AS INT), 0);
    DECLARE @StokId   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')   AS INT);
    DECLARE @IzlemTur INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur') AS INT), 0);
    DECLARE @GirDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.girDepo') AS INT), 0);
    DECLARE @CikDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.cikDepo') AS INT), 0);
    DECLARE @StokHar  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.stokHareketi') AS BIT), 1);
    DECLARE @KaynakSatir INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynakSatirId') AS INT), 0);
    DECLARE @OncekiSil BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.oncekiSil') AS BIT), 1);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kullaniciId') AS INT), 0);

    IF @Tur      IS NULL                 THROW 51001, N'belge.tur zorunlu.', 1;
    IF @BaslikId IS NULL OR @BaslikId<=0 THROW 51001, N'belge.baslikId zorunlu.', 1;
    IF @SatirId  IS NULL OR @SatirId <=0 THROW 51001, N'belge.satirId zorunlu.', 1;
    IF @StokId   IS NULL OR @StokId  <=0 THROW 51001, N'stokId zorunlu.', 1;

    -- ---------- Girdi satirlari ----------
    DECLARE @S TABLE (Sira INT IDENTITY, SerilotId INT NULL, IzlemId INT NULL,
                      SeriNo NVARCHAR(64) COLLATE DATABASE_DEFAULT,
                      LotNo  NVARCHAR(50) COLLATE DATABASE_DEFAULT,
                      Skt DATETIME NULL, Urt DATETIME NULL, Adet DECIMAL(18,6));
    INSERT @S (SerilotId, IzlemId, SeriNo, LotNo, Skt, Urt, Adet)
    SELECT J.SerilotId, ISNULL(J.IzlemId, 0), ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''),
           J.Skt, J.Urt, J.Adet
    FROM OPENJSON(@Kosullar, '$.satirlar')
         WITH (SerilotId INT '$.serilotId', IzlemId INT '$.izlemId',
               SeriNo NVARCHAR(64) '$.seriNo', LotNo NVARCHAR(50) '$.lotNo',
               Skt DATETIME '$.skt', Urt DATETIME '$.urt',
               Adet DECIMAL(18,6) '$.adet') J
    WHERE ISNULL(J.Adet, 0) > 0;

    -- ---------- Depo korumasi ----------
    --   Hareket yapilacaksa gecerli depo SART. Yon asagidaki ile ayni kural.
    DECLARE @Cikis BIT = CASE WHEN @Tur IN (4, 14, 15, 16, 20, 101, 119) THEN 1 ELSE 0 END;
    IF @StokHar = 1 AND EXISTS (SELECT 1 FROM @S)
       AND ((@Cikis = 1 AND @CikDepo <= 0) OR (@Cikis = 0 AND @GirDepo <= 0))
        THROW 51001, N'Bu belgede depo secilmedigi icin seri/lot hareketi kaydedilemez. Once belgenin giris/cikis deposunu secin.', 1;

    -- ---------- Onceki kayitlar ----------
    IF @OncekiSil = 1
    BEGIN
        DECLARE @Eski TABLE (Id INT PRIMARY KEY);
        INSERT @Eski (Id)
        SELECT ID FROM dbo.STOKIZLEME
         WHERE BELGETUR = @Tur AND STOKID = @StokId
           AND BASLIKID = @BaslikId AND SATIRID = @SatirId;

        -- SIRA ONEMLI: STOKIZLEME ONCE silinir.
        --   TG_StokIzlemeDurumSil (STOKIZLEME FOR DELETE) bakiyeyi geri verirken
        --   deleted'i STOKIZLEMEDEPO ile JOIN'ler. Depo satirlarini once
        --   silersek trigger hicbir sey bulamaz ve bakiye eksik kalir.
        --   Olculdu (08.08.2026): ayni satiri iki kez yazinca bakiye
        --   233 -> 223 oluyordu, dogrusu 228.
        DELETE FROM dbo.STOKIZLEME WHERE ID IN (SELECT Id FROM @Eski);
        DELETE FROM dbo.STOKIZLEMEDEPO WHERE IZLEMID IN (SELECT Id FROM @Eski);
    END

    IF NOT EXISTS (SELECT 1 FROM @S)
    BEGIN
        SELECT (SELECT 1 AS Sonuc, 0 AS Yazilan, 0 AS ToplamAdet
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Eksik seri/lot kartlari ----------
    --   serilotId gelmemis satirlar once (STOKID, SERINO, LOTNO) ile aranir,
    --   yoksa STOKSERILOT'a eklenir. Tarih yoksa 1990-01-01 (eski sentinel).
    UPDATE S
       SET S.SerilotId = SSL.ID
      FROM @S S
           INNER JOIN dbo.STOKSERILOT SSL
                   ON SSL.STOKID = @StokId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = S.SeriNo COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = S.LotNo COLLATE DATABASE_DEFAULT
     WHERE ISNULL(S.SerilotId, 0) = 0;

    DECLARE @Yeni TABLE (Sira INT, SerilotId INT);
    INSERT INTO dbo.STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
    OUTPUT INSERTED.ID INTO @Yeni (SerilotId)
    SELECT @StokId, S.SeriNo, S.LotNo,
           ISNULL(S.Urt, '1990-01-01'), ISNULL(S.Skt, '1990-01-01')
    FROM @S S WHERE ISNULL(S.SerilotId, 0) = 0;

    -- OUTPUT ile Sira eslestirilemez (INSERT...SELECT'te kaynak kolon
    --   OUTPUT'a alinamaz); yeni eklenenler tekrar arama ile baglanir.
    UPDATE S
       SET S.SerilotId = SSL.ID
      FROM @S S
           INNER JOIN dbo.STOKSERILOT SSL
                   ON SSL.STOKID = @StokId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = S.SeriNo COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = S.LotNo COLLATE DATABASE_DEFAULT
     WHERE ISNULL(S.SerilotId, 0) = 0;

    IF EXISTS (SELECT 1 FROM @S WHERE ISNULL(SerilotId, 0) = 0)
        THROW 51200, N'Seri/lot karti olusturulamadi (seri no ve lot no bos olamaz).', 1;

    -- ---------- Yazma ----------
    DECLARE @Sira INT, @Serilot INT, @IzlemId INT, @Adet DECIMAL(18,6),
            @YeniId INT, @Yazilan INT = 0, @Toplam DECIMAL(18,6) = 0,
            @Hareket DECIMAL(18,6);

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, SerilotId, IzlemId, Adet FROM @S ORDER BY Sira;
    OPEN c; FETCH NEXT FROM c INTO @Sira, @Serilot, @IzlemId, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                    ADET, KALAN, YER, YERID, DONUSID, SERILOTID, EKLEYEN)
        VALUES (@StokId, @Tur, @BaslikId, @SatirId, @IzlemTur,
                @Adet, @Adet, 0, 0,
                CASE WHEN @KaynakSatir > 0 THEN ISNULL(@IzlemId, 0) ELSE 0 END,
                @Serilot, @KulId);
        SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);

        SET @Hareket = CASE WHEN @StokHar = 1 THEN @Adet ELSE 0 END;

        IF @Cikis = 1
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @CikDepo, -1.0 * @Hareket);
        ELSE
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @GirDepo, @Hareket);

        -- Transfer ve giden konsinye: cikisin karsiligi giris deposuna
        IF @Tur IN (20, 119)
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @GirDepo, @Hareket);
        -- Gelen konsinye IADE (islemTip 2): konsinyeden cikis, ana depoya giris
        ELSE IF @Tur = 109 AND @IslemTip = 2
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @CikDepo, -1.0 * @Hareket);

        SET @Yazilan = @Yazilan + 1;
        SET @Toplam = @Toplam + @Adet;
        FETCH NEXT FROM c INTO @Sira, @Serilot, @IzlemId, @Adet;
    END
    CLOSE c; DEALLOCATE c;

    SELECT (SELECT 1 AS Sonuc, @Yazilan AS Yazilan, @Toplam AS ToplamAdet
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- TRIGGER: tg_izlemorjinalyap  (kaynak: GenDepoUpdate94) ----
-- ============================================================
-- 2) TG_IzlemOrjinalYap - UPDATE olayi eklendi
--
--    Govde AYNEN korundu (set bazli, cok satirli islemlere dayanikli).
--    Tek fark: FOR INSERT, DELETE -> FOR INSERT, UPDATE, DELETE.
--    Boylece bir cocuk kaydin ADET'i ya da DONUSID'si degistiginde kaynak
--    izlem kaydinin KALAN'i yeniden hesaplanir.
--    Trigger kendi tablosuna yaziyor; veritabaninda RECURSIVE TRIGGERS KAPALI
--    oldugu icin kendini tekrar tetiklemez.
-- ============================================================
CREATE OR ALTER TRIGGER [dbo].[TG_IzlemOrjinalYap]
ON [dbo].[STOKIZLEME]
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Etkilenen AS
    (
        SELECT DONUSID AS ID FROM inserted WHERE ISNULL(DONUSID, 0) > 0
        UNION
        SELECT DONUSID AS ID FROM deleted  WHERE ISNULL(DONUSID, 0) > 0
    ),
    Donusen AS
    (
        SELECT S.DONUSID AS ID, SUM(ISNULL(S.ADET, 0)) AS ToplamAdet
        FROM dbo.STOKIZLEME AS S
             INNER JOIN Etkilenen AS E ON E.ID = S.DONUSID
        WHERE ISNULL(S.DONUSID, 0) > 0
        GROUP BY S.DONUSID
    )
    UPDATE O
       SET O.KALAN = ISNULL(O.ADET, 0) - ISNULL(D.ToplamAdet, 0)
    FROM dbo.STOKIZLEME AS O
         INNER JOIN Etkilenen AS E ON E.ID = O.ID
         LEFT JOIN Donusen AS D ON D.ID = O.ID;
END
GO

-- ---- TRIGGER: tg_stokizlemedurumupdate  (kaynak: GenDepoUpdate94) ----
-- ============================================================
-- 1) TG_StokIzlemeDurumUpdate - ARTIMSAL hale getirildi
--
--    Delta, inserted ve deleted'in AYRI AYRI toplanmasiyla bulunur:
--      + inserted.ADET      - deleted.ADET
--    Bu bicim, guncelleme sirasinda IZLEMID/DEPOID (yani PK) degisse bile
--    dogru calisir: eski anahtar dusulur, yeni anahtara eklenir.
--
--    Cursor yerine SET BAZLI: cok satirli UPDATE'te de dogru (eski cursor
--    surumu cok satirda da calisiyordu ama satir satir, yavas).
-- ============================================================
CREATE OR ALTER TRIGGER [dbo].[TG_StokIzlemeDurumUpdate]
ON [dbo].[STOKIZLEMEDEPO]
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(ADET) AND NOT UPDATE(DEPOID) AND NOT UPDATE(IZLEMID) RETURN;

    DECLARE @D TABLE (STOKID INT, DEPOID INT, SERILOTID INT, Delta FLOAT,
                      PRIMARY KEY (STOKID, DEPOID, SERILOTID));

    INSERT @D (STOKID, DEPOID, SERILOTID, Delta)
    SELECT X.STOKID, X.DEPOID, X.SERILOTID, SUM(X.Delta)
    FROM (
        SELECT SI.STOKID, I.DEPOID, SI.SERILOTID, Delta = ISNULL(I.ADET, 0)
        FROM inserted I INNER JOIN dbo.STOKIZLEME SI ON SI.ID = I.IZLEMID
        UNION ALL
        SELECT SI.STOKID, D.DEPOID, SI.SERILOTID, Delta = -1.0 * ISNULL(D.ADET, 0)
        FROM deleted D INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
    ) X
    GROUP BY X.STOKID, X.DEPOID, X.SERILOTID
    HAVING SUM(X.Delta) <> 0.0;

    IF NOT EXISTS (SELECT 1 FROM @D) RETURN;

    -- Bakiye satiri yoksa ac (eski surumde bu guvenlik yorum satirindaydi)
    INSERT INTO dbo.STOKDURUMIZLEME (STOKID, DEPOID, SERILOTID, KALAN)
    SELECT D.STOKID, D.DEPOID, D.SERILOTID, 0.0
    FROM @D D
    WHERE NOT EXISTS (SELECT 1 FROM dbo.STOKDURUMIZLEME S
                       WHERE S.STOKID = D.STOKID AND S.DEPOID = D.DEPOID
                         AND S.SERILOTID = D.SERILOTID);

    UPDATE S
       SET S.KALAN = ISNULL(S.KALAN, 0) + D.Delta
      FROM dbo.STOKDURUMIZLEME S
           INNER JOIN @D D ON D.STOKID = S.STOKID AND D.DEPOID = S.DEPOID
                          AND D.SERILOTID = S.SERILOTID;
END
GO
