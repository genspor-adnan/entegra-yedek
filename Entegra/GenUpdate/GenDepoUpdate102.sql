-- ============================================================
-- GenDepoUpdate102.sql
-- sp_Prog_Izleme_Aktar_Json -> KAYNAKSIZ (DEPODAN SECIM) KIPI   [plan A5]
--
-- NEDEN
--   Siparisten irsaliye/faturaya donusumde izlemeli urun HIC islenmiyordu:
--   SIPARIS stok hareketi yapmaz, STOKIZLEME kaydi YOKTUR - dolayisiyla
--   "tasinacak" bir sey de yoktur. Lotlar DEPODAKI BAKIYEDEN secilmeli.
--   (Ornek: siparis 23202 / satir 158000, urun 86, IZLEME=2, adet 5 - izlemli
--    oldugu halde irsaliyeye donusturulemiyordu.)
--
-- IKI KIP, TEK SP (yazma mantigi tek yerde kalsin diye ayri SP yazilmadi):
--   A) TASIMA   - kaynak.satirId verilir. Kaynagin STOKIZLEME kayitlari hedefe
--                 tasinir, DONUSID kaynagi gosterir, kaynagin KALAN'ini
--                 TG_IzlemOrjinalYap duserir.
--   B) DEPODAN  - kaynak.satirId YOK. secim[] serilotId ile gelir; yeni
--                 STOKIZLEME kaydi acilir, DONUSID = 0 (tasima degil, ilk
--                 cikis). Depodaki bakiye yeterli mi kontrol edilir.
--
-- B kipinde stokId / izlemTur HEDEF SATIRDAN okunur (cagiranin gonderdigine
--   guvenilmez - urun ve izleme turu belgenin kendisinde yazilidir).
--
-- Secilen toplam hedef satirin adediyle uyusmazsa 51200: yarim izlem birakmak
--   sessiz veri bozulmasidir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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
        IF @StokHar = 1 AND EXISTS (
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

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Aktar_Json TO gentegre_api;
GO
