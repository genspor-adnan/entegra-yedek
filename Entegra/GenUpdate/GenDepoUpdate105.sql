-- ============================================================
-- GenDepoUpdate105.sql
-- sp_Prog_Izleme_Yaz_Json - IZLEME YAZMANIN KANONIK NESNESI   [plan A8.1]
--
-- NEDEN
--   Izleme ekrani bugun kendi yaziyor ve bunu FORM YOK EDILIRKEN yapiyor
--   (UIzleme.FormDestroy -> Tablo.IzlemBilgisiKaydet). Sonuc mrOk verildikten
--   SONRA calisiyor: hata olursa kullaniciya mesaj yok, cagiranin
--   transaction'ina giremiyor, cagiran "basarili" sanip devam ediyor.
--   Bu SP ile yazma cagiranin kontrolune gecer; ekran yalnizca SECER.
--
-- DAVRANIS Utablo.IzlemBilgisiKaydet'ten BIREBIR devralindi:
--   * STOKSERILOT (STOKID, SERINO, LOTNO) ile aranir; yoksa eklenir.
--     Tarih verilmezse 1990-01-01 (eski akisin sentinel'i - degistirilmedi,
--     mevcut veriyle karsilastirmalar bozulmasin).
--   * STOKIZLEME: ADET = KALAN = satirin adedi, DONUSID kaynak varsa izlemId.
--   * Depo hareketi:
--       cikis turleri (4,14,15,16,20,101,119) -> CikDepo, NEGATIF
--       digerleri                             -> GirDepo, POZITIF
--       transfer (20) ve giden konsinye (119) -> AYRICA GirDepo, POZITIF
--       gelen konsinye (109) + islemTip 2     -> AYRICA CikDepo, NEGATIF
--     stokHareketi=false ise adet 0 yazilir (satir yine acilir - K-B karari).
--   * GECERSIZ DEPO (0) KORUMASI: hareket varken depo 0 ise 51001. Pascal'a
--     08.08.2026'da eklenen korumanin sunucu karsiligi; BILIM'de bu yuzden
--     15 hareket DEPOID=0 ile yazilmisti.
--
-- ONCEKI KAYITLAR
--   oncekiSil (varsayilan 1): ayni (BELGETUR, STOKID, BASLIKID, SATIRID) icin
--   var olan izlemler silinir - ekran yeniden acilip kaydedildiginde mukerrer
--   olusmasin. BELGETUR kosula DAHIL: BASLIKID/SATIRID belge turleri arasinda
--   ortak sayi uzayindan gelir, tur olmadan baska belgenin izlemi silinebilir.
--
-- GIRDI
--   {"belge":{"tur":15,"baslikId":114102,"satirId":3557596,"islemTip":1},
--    "stokId":86,"izlemTur":2,"girDepo":0,"cikDepo":1,
--    "stokHareketi":true,"kaynakSatirId":0,"oncekiSil":true,"kullaniciId":5,
--    "satirlar":[{"serilotId":6784,"adet":5},
--                {"seriNo":"A1","lotNo":"L9","skt":"2027-01-01","adet":3}]}
--
-- CIKTI {"Sonuc":1,"Yazilan":n,"ToplamAdet":x}
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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
                      SeriNo NVARCHAR(64), LotNo NVARCHAR(50),
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
                  AND ISNULL(SSL.SERINO, N'') = S.SeriNo
                  AND ISNULL(SSL.LOTNO,  N'') = S.LotNo
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
                  AND ISNULL(SSL.SERINO, N'') = S.SeriNo
                  AND ISNULL(SSL.LOTNO,  N'') = S.LotNo
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

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Yaz_Json TO gentegre_api;
GO
