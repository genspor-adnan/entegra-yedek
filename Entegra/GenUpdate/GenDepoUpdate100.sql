-- ============================================================
-- GenDepoUpdate100.sql
-- sp_Prog_Izleme_Aktar_Json  ->  KISMI ADET TASIMASI (istenenAdet)
--
-- NEDEN
--   Belge donusumunde izlemeli urunlerde ADET degistirilemiyordu
--   (UBelgeDonusum.FiyatSor: "if IZLEME > 0 then PanelMiktar.Enabled := False",
--    03/08/2022). Gerekce: eski akis kaynagin TUM kalanini tasiyor ve hangi
--    seri/lottan ne kadar gittigini takip edemiyordu.
--
--   Artik takip ediliyor: her tasinan satir DONUSID ile kaynagina bagli,
--   TG_IzlemOrjinalYap kaynagin KALAN'ini adet kadar dusuruyor. Dolayisiyla
--   kilit kalkabilir - ama SP'nin "hepsini tasi" davranisi ADEDE BAGLANMALI,
--   yoksa adet 3 secilse bile izlem 10 giderdi.
--
-- YENI ALAN
--   "istenenAdet": tasinacak TOPLAM adet.
--     - "secim" gonderilmisse yok sayilir (kullanici zaten lot bazinda sectiyse).
--     - gonderilmezse / 0 ise ESKI DAVRANIS: kaynagin tum kalani.
--     - gonderilmisse kaynagin kalanindan FIFO (SKT, sonra kayit sirasi) ile
--       TAM O KADAR alinir; son lot gerekiyorsa BOLUNUR.
--
-- HATA
--   istenenAdet kaynagin toplam kalanindan buyukse 51200 ile reddedilir -
--   sessizce eksik tasima yapilmaz.
--
-- Diger davranis GenDepoUpdate98 ile ayni: kaynagin KALAN'ina ELLE DOKUNULMAZ.
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

    IF @KaynakSatir IS NULL OR @KaynakSatir <= 0 THROW 51001, N'kaynak.satirId zorunlu.', 1;
    IF @HedefSatir  IS NULL OR @HedefSatir  <= 0 THROW 51001, N'hedef.satirId zorunlu.', 1;
    IF @HedefBaslik IS NULL OR @HedefBaslik <= 0 THROW 51001, N'hedef.baslikId zorunlu.', 1;
    IF @HedefTur    IS NULL                      THROW 51001, N'hedef.tur zorunlu.', 1;

    -- Depo zorunlulugu: hareket yapilacaksa gecerli depo SART.
    IF @StokHar = 1 AND ISNULL(@DepoId, 0) <= 0
        THROW 51001, N'Stok hareketi yapilacaksa gecerli depoId zorunlu.', 1;

    -- ---------- Tasinacaklar ----------
    DECLARE @T TABLE (KaynakIzlemId INT PRIMARY KEY, SerilotId INT, StokId INT,
                      IzlemTur INT, Yer INT, Adet DECIMAL(18,6));

    DECLARE @SecimVar BIT = CASE WHEN EXISTS (SELECT 1 FROM OPENJSON(@Kosullar, '$.secim')) THEN 1 ELSE 0 END;

    IF @SecimVar = 1
        -- Acik secim: hangi seri/lottan ne kadar. istenenAdet yok sayilir.
        INSERT @T (KaynakIzlemId, SerilotId, StokId, IzlemTur, Yer, Adet)
        SELECT MIN(SI.ID), SI.SERILOTID, MIN(SI.STOKID), MIN(SI.IZLEMTUR), MIN(SI.YER), MIN(J.Adet)
        FROM OPENJSON(@Kosullar, '$.secim')
             WITH (SerilotId INT '$.serilotId', Adet DECIMAL(18,6) '$.adet') J
             INNER JOIN dbo.STOKIZLEME SI ON SI.SATIRID = @KaynakSatir
                                         AND SI.SERILOTID = J.SerilotId
        WHERE J.Adet > 0
        GROUP BY SI.SERILOTID;
    ELSE IF ISNULL(@Istenen, 0) > 0
    BEGIN
        -- ---------- KISMI: FIFO ile istenen kadar ----------
        DECLARE @Mevcut DECIMAL(18,6) =
            ISNULL((SELECT SUM(ABS(ISNULL(SI.KALAN, 0)))
                    FROM dbo.STOKIZLEME SI
                    WHERE SI.SATIRID = @KaynakSatir), 0);

        IF @Mevcut + 0.0001 < @Istenen
        BEGIN
            DECLARE @msg NVARCHAR(300) =
                N'Kaynak belgede tasinabilir seri/lot yetersiz (mevcut: '
              + CAST(CAST(@Mevcut  AS decimal(18,3)) AS nvarchar(30)) + N', istenen: '
              + CAST(CAST(@Istenen AS decimal(18,3)) AS nvarchar(30)) + N').';
            THROW 51200, @msg, 1;
        END

        -- Kumulatif toplamla FIFO dilimi: sirasi SKT (once dolan), sonra kayit
        --   sirasi. Sinira denk gelen lot BOLUNUR.
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

    DECLARE @Kid INT, @Adet DECIMAL(18,6), @YeniId INT, @Aktarilan INT = 0,
            @Toplam DECIMAL(18,6) = 0;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT KaynakIzlemId, Adet FROM @T ORDER BY KaynakIzlemId;
    OPEN c; FETCH NEXT FROM c INTO @Kid, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                    ADET, KALAN, YER, YERID, DONUSID, SERILOTID, EKLEYEN)
        SELECT SI.STOKID, @HedefTur, @HedefBaslik, @HedefSatir, SI.IZLEMTUR,
               @Adet, @Adet, SI.YER, 0, SI.ID, SI.SERILOTID, @KulId
        FROM dbo.STOKIZLEME SI WHERE SI.ID = @Kid;

        SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);
        IF @YeniId IS NOT NULL
        BEGIN
            -- K-B: stok hareketi yoksa da satir acilir, ADET = 0
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, ISNULL(@DepoId, 0),
                    CASE WHEN @StokHar = 1 THEN @Yon * @Adet ELSE 0 END);

            -- KAYNAGIN KALAN'INA ELLE DOKUNULMUYOR: TG_IzlemOrjinalYap yeni
            --   satirin DONUSID'sine bakip kaynagi zaten dusuruyor.
            SET @Aktarilan = @Aktarilan + 1;
            SET @Toplam = @Toplam + @Adet;
        END
        FETCH NEXT FROM c INTO @Kid, @Adet;
    END
    CLOSE c; DEALLOCATE c;

    SELECT (SELECT 1 AS Sonuc, @Aktarilan AS Aktarilan, @Toplam AS ToplamAdet
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Aktar_Json TO gentegre_api;
GO
