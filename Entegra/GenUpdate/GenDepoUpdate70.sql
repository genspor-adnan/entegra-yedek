-- ============================================================
-- GenDepoUpdate70.sql
-- API: sp_Api_Belge_SeriLot_Yaz_Json
--   Bir belge SATIRININ seri/lot izleme kayitlarini yazar:
--   STOKSERILOT (varsa bul, yoksa ekle) -> STOKIZLEME -> STOKIZLEMEDEPO.
--
-- KANONIK KAYNAK: TTablo.IzlemBilgisiKaydet (Utablo.pas:6790, 27.11.2024
--   duzenlemesi). Kurallar birebir devralindi; asagida SQL karsiliklari.
--
-- YERINE GECER: TM_FATURAGir icindeki seri/lot blogu. Oradaki kusurlar:
--   1) "DELETE FROM STOKSERILOT ... WHERE STOKID=@URUNID" - belge/satir
--      filtresi YOK; urunun TUM seri/lot ana kayitlarini siliyordu.
--      (STOKDURUMIZLEME silmesi de ayni sekilde genisti.)
--   2) INSERT ... OUTPUT satir sirasi ile JSON sirasi ROW_NUMBER ile
--      eslestiriliyordu; OUTPUT sirasi garanti DEGIL. Burada eslesme
--      JSON'daki "Sira" alani uzerinden yapilir.
--   3) Transaction yoktu.
--
-- DEPO HAREKETI KURALLARI (IzlemBilgisiKaydet ile ayni):
--   - StokDurumDegis = false  -> depo hareketi 0 (donusumde daha once
--     irsaliye ile cikildiysa tekrar cikilmaz)
--   - BelgeTur = 99 (stok sayimi) -> depo hareketi 0; KALAN = Kalan - Durum
--   - Cikis turleri (4 diger cikis, 14 satis irs, 15 satis fat, 16 satis fis,
--     119 giden konsinye, 20 transfer, 101 uretim sarf) -> CikisDepo'ya -Kalan
--   - digerleri -> GirisDepo'ya +Kalan
--   - 119 giden konsinye / 20 transfer -> AYRICA GirisDepo'ya +Kalan
--   - 109 gelen konsinye ve IslemTip = 2 (iade) -> AYRICA CikisDepo'ya -Kalan
--
-- GIRDI (JSON):
--   {"BelgeId":5567,"SatirId":9001,"UrunId":505,"BelgeTur":14,"IslemTip":1,
--    "IzlemTur":1,"GirisDepo":0,"CikisDepo":3,"StokDurumDegis":true,
--    "KaynakSatirId":0,"Oturum":{"KulId":5},
--    "SeriLot":[{"Sira":1,"SeriNo":"A1","LotNo":"L1","Urt":"2026-01-01",
--                "Skt":"2027-01-01","Kalan":2.5,"Durum":0,"IzlemId":0}]}
--   SeriLot bos dizi -> yalnizca mevcut kayitlar silinir.
-- CIKTI (JSON):
--   {"Sonuc":1,"BelgeId":..,"SatirId":..,"Silinen":n,"Yazilan":n,
--    "Satirlar":[{"Sira":1,"IzlemId":123,"SeriLotId":45}]}
-- HATA: 51001 zorunlu alan eksik, 51002 belge/satir bulunamadi
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_SeriLot_Yaz_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId')    AS INT);
    DECLARE @SatirId    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SatirId')    AS INT);
    DECLARE @UrunId     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.UrunId')     AS INT);
    DECLARE @BelgeTur   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeTur')   AS INT);
    DECLARE @IslemTip   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.IslemTip')   AS INT), 0);
    DECLARE @IzlemTur   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.IzlemTur')   AS INT), 0);
    DECLARE @GirisDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GirisDepo')  AS INT), 0);
    DECLARE @CikisDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.CikisDepo')  AS INT), 0);
    DECLARE @KaynakSatirId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakSatirId') AS INT), 0);
    DECLARE @StokDurumDegis BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.StokDurumDegis') AS BIT), 1);
    DECLARE @KulId      INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @BelgeId IS NULL OR @BelgeId <= 0 THROW 51001, N'BelgeId zorunlu.', 1;
    IF @SatirId IS NULL OR @SatirId <= 0 THROW 51001, N'SatirId zorunlu.', 1;
    IF @UrunId  IS NULL OR @UrunId  <= 0 THROW 51001, N'UrunId zorunlu.', 1;
    IF @BelgeTur IS NULL                 THROW 51001, N'BelgeTur zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM FATURA WHERE ID = @SatirId AND FATBASID = @BelgeId)
        THROW 51002, N'Belge satiri bulunamadi.', 1;

    -- ---- Girdi satirlari ----
    DECLARE @S TABLE (
        Sira      INT PRIMARY KEY,
        SeriNo    NVARCHAR(100),
        LotNo     NVARCHAR(100),
        Urt       DATE,
        Skt       DATE,
        Kalan     FLOAT,
        Durum     FLOAT,
        IzlemId   INT,
        SeriLotId INT NULL,
        YeniIzlem INT NULL
    );
    INSERT @S (Sira, SeriNo, LotNo, Urt, Skt, Kalan, Durum, IzlemId)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),  -- Sira opsiyonel; verilirse BENZERSIZ olmali
           ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''),
           ISNULL(J.Urt, '1990-01-01'), ISNULL(J.Skt, '1990-01-01'),
           ISNULL(J.Kalan, 0), ISNULL(J.Durum, 0), ISNULL(J.IzlemId, 0)
    FROM OPENJSON(@Kosullar, '$.SeriLot')
         WITH (Sira INT, SeriNo NVARCHAR(100), LotNo NVARCHAR(100),
               Urt DATE, Skt DATE, Kalan FLOAT, Durum FLOAT, IzlemId INT) J;

    DECLARE @Silinen INT = 0, @Yazilan INT = 0;

    BEGIN TRY
        BEGIN TRAN;

        -- ---- 1) Bu URUN + BELGE + SATIR ucusune ait eski kayitlari sil ----
        --   Kapsam UIzleme.pas:1466 ile ayni (urun genelinde DEGIL).
        --   STOKIZLEME delete trigger'i STOKIZLEMEDEPO + STOKDURUMIZLEME'yi siler.
        SELECT @Silinen = COUNT(*) FROM STOKIZLEME
         WHERE STOKID = @UrunId AND BASLIKID = @BelgeId AND SATIRID = @SatirId;

        DELETE FROM STOKIZLEME
         WHERE STOKID = @UrunId AND BASLIKID = @BelgeId AND SATIRID = @SatirId;

        -- ---- 2) STOKSERILOT: varsa bul ----
        UPDATE S SET SeriLotId = X.ID
        FROM @S S
        CROSS APPLY (SELECT TOP 1 SL.ID FROM STOKSERILOT SL
                      WHERE SL.STOKID = @UrunId AND SL.SERINO = S.SeriNo AND SL.LOTNO = S.LotNo
                      ORDER BY SL.ID) X;

        -- ---- 3) STOKSERILOT: yoksa ekle (Sira ile eslesir; OUTPUT sirasina guvenilmez) ----
        DECLARE @Sira INT, @Yeni INT;
        DECLARE cS CURSOR LOCAL FAST_FORWARD FOR
            SELECT Sira FROM @S WHERE SeriLotId IS NULL ORDER BY Sira;
        OPEN cS; FETCH NEXT FROM cS INTO @Sira;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
            SELECT @UrunId, SeriNo, LotNo, Urt, Skt FROM @S WHERE Sira = @Sira;
            SET @Yeni = CAST(SCOPE_IDENTITY() AS INT);
            UPDATE @S SET SeriLotId = @Yeni WHERE Sira = @Sira;
            FETCH NEXT FROM cS INTO @Sira;
        END
        CLOSE cS; DEALLOCATE cS;

        -- ---- 4) STOKIZLEME + STOKIZLEMEDEPO ----
        DECLARE @Kalan FLOAT, @Fark FLOAT, @DonusId INT, @SeriLotId INT, @IzlemId INT, @DepoKalan FLOAT;
        DECLARE cI CURSOR LOCAL FAST_FORWARD FOR
            SELECT Sira, Kalan, Durum, IzlemId, SeriLotId FROM @S ORDER BY Sira;
        OPEN cI; FETCH NEXT FROM cI INTO @Sira, @Kalan, @Fark, @DonusId, @SeriLotId;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- KALAN kolonu: sayimda (99) fark, digerlerinde kalanin kendisi
            SET @Fark = CASE WHEN @BelgeTur = 99 THEN @Kalan - @Fark ELSE @Kalan END;
            -- DONUSID: kaynak satir varsa gelen IzlemId, yoksa 0
            SET @DonusId = CASE WHEN @KaynakSatirId > 0 THEN ISNULL(@DonusId, 0) ELSE 0 END;

            INSERT INTO STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                    KALAN, ADET, EKLEYEN, DONUSID, SERILOTID)
            VALUES (@UrunId, @BelgeTur, @BelgeId, @SatirId, @IzlemTur,
                    @Fark, @Kalan, @KulId, @DonusId, @SeriLotId);
            SET @IzlemId = CAST(SCOPE_IDENTITY() AS INT);
            UPDATE @S SET YeniIzlem = @IzlemId WHERE Sira = @Sira;
            SET @Yazilan = @Yazilan + 1;

            -- Depo hareketi
            SET @DepoKalan = @Kalan;
            IF @StokDurumDegis = 0 OR @BelgeTur = 99 SET @DepoKalan = 0;

            IF @BelgeTur IN (4, 14, 15, 16, 119, 20, 101)
                INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @CikisDepo, -1.0 * @DepoKalan);
            ELSE
                INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @GirisDepo, @DepoKalan);

            IF @BelgeTur IN (119, 20)
                INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @GirisDepo, @DepoKalan);
            ELSE IF @BelgeTur = 109 AND @IslemTip = 2
                INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @CikisDepo, -1.0 * @DepoKalan);

            FETCH NEXT FROM cI INTO @Sira, @Kalan, @Fark, @DonusId, @SeriLotId;
        END
        CLOSE cI; DEALLOCATE cI;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @SatirId AS SatirId,
                   @Silinen AS Silinen, @Yazilan AS Yazilan,
                   (SELECT Sira, YeniIzlem AS IzlemId, SeriLotId
                      FROM @S ORDER BY Sira FOR JSON PATH) AS Satirlar
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_SeriLot_Yaz_Json TO gentegre_api;
GO
