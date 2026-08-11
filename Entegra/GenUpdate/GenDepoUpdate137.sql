-- ============================================================
-- GenDepoUpdate137.sql
-- KASA HAREKETI SILME -> SUNUCUYA (sp_Api_KasaHareket_Sil_Json)
--
-- SORUN: Utablo.KasaSilmeIslemleri 161 satir, 24 ayri yazma, 7 cagri yeri
--   (UKasa, UFaturalar, UFaturalar2, UReharadlg, UAnaGirisSayfasiFrame...).
--   TRANSACTION YOK: cek hareketi silinip CEKLER durumu guncellenmeden ya da
--   geri-donus satiri silinip asil satir dururken kopan baglanti kasayi tutarsiz
--   birakiyor. Loglama da dagilmis (bazi dallarda var, bazilarinda yok).
--
-- KAPSAM: yalnizca KASA SATIRI dallari. Pascal'daki on-dallar (cek/senet ->
--   CekSil, fatura/irsaliye -> FaturaSil, tahakkuk -> FATBASLIK) KENDI API'lerine
--   sahip; onlar Pascal'da kalir ve bu SP cagrilmadan once yonlendirilir.
--
-- LOGLAMA: silmeden ONCE (Geri Al buna bagli), sp_Api_Log_Yaz_Ic ile.
-- TRANSACTION: tek BEGIN TRAN / COMMIT, XACT_ABORT ON.
--
-- CIKTI (JSON): {"Sonuc":1,"KayitId":..,"Tur":..,"SilinenSatir":..,"Loglanan":..,
--                "FaturaId":..}  -- FaturaId>0 ise cagiran FaturaDurumUpdate yapar
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_KasaHareket_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Id     BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);
    DECLARE @KulId  INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip     VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist    VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @Id IS NULL OR @Id <= 0
        THROW 51001, N'KayitId zorunlu.', 1;

    ------------------------------------------------------------------ KASA satiri
    DECLARE @Tur INT, @HesapId INT, @RehberId INT, @FaturaId INT, @CekSenetId INT,
            @KrediId INT, @GeriDonusId INT, @Yeri INT, @YerId INT, @Aciklama NVARCHAR(400);

    SELECT @Tur = ISNULL(TUR, 0), @HesapId = ISNULL(HESAPID, 0), @RehberId = ISNULL(REHBERID, 0),
           @FaturaId = ISNULL(FATURAID, 0), @CekSenetId = ISNULL(CEKSENETID, 0),
           @KrediId = ISNULL(KREDIID, 0), @GeriDonusId = ISNULL(GERIDONUSID, -1),
           @Yeri = ISNULL(YERI, 0), @YerId = ISNULL(YERID, 0), @Aciklama = ISNULL(ACIKLAMA, N'')
      FROM dbo.KASA WHERE ID = @Id;

    IF @Tur IS NULL
        THROW 51002, N'Kasa hareketi bulunamadi.', 1;

    DECLARE @Loglanan INT = 0, @Silinen INT = 0, @n INT;
    DECLARE @TabNo_KASA INT = 43, @TabNo_FATBASLIK INT = 30, @TabNo_FATBASLIK_USER INT = 502;

    BEGIN TRAN;

    ------------------------------------------------------------------ 22/32: gider-gelir
    IF @Tur IN (22, 32)
    BEGIN
        IF @GeriDonusId = -9 AND @Yeri = @TabNo_FATBASLIK AND @YerId > 0
        BEGIN
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @Kosul = N'ID=@pB', @KosulPar = @YerId,
                 @TabNo = @TabNo_FATBASLIK, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK_USER', @Kosul = N'ID=@pB', @KosulPar = @YerId,
                 @TabNo = @TabNo_FATBASLIK_USER, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);

            DELETE FROM dbo.FATBASLIK WHERE ID = @YerId;
            SET @Silinen += @@ROWCOUNT;
        END
        ELSE IF @Tur = 32
        BEGIN
            -- Bagli KASA satirlari (virman karsiligi)
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'YERID=@pB', @KosulPar = @Id,
                 @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);
            DELETE FROM dbo.KASA WHERE YERID = @Id;
            SET @Silinen += @@ROWCOUNT;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @Kosul = N'KASA=@pB', @KosulPar = @Id,
                 @TabNo = @TabNo_FATBASLIK, @UstTabNo = @TabNo_FATBASLIK, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK_USER',
                 @Kosul = N'ID IN (SELECT ID FROM FATBASLIK WHERE KASA=@pB)', @KosulPar = @Id,
                 @TabNo = @TabNo_FATBASLIK_USER, @UstTabNo = @TabNo_FATBASLIK, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);

            DELETE FROM dbo.FATBASLIK WHERE KASA = @Id;
            SET @Silinen += @@ROWCOUNT;
        END
    END

    ------------------------------------------------------------------ 31: avans
    ELSE IF @Tur = 31 AND CHARINDEX(N'AVANS', UPPER(@Aciklama)) > 0
    BEGIN
        DELETE FROM dbo.PLANAVANS WHERE KASAID = @Id;
        SET @Silinen += @@ROWCOUNT;
    END

    ------------------------------------------------------------------ 35/350: kredi karti
    ELSE IF @Tur IN (35, 350)
    BEGIN
        DELETE FROM dbo.PLANKREDIKARTI WHERE KASAID = @Id;
        SET @Silinen += @@ROWCOUNT;
    END

    ------------------------------------------------------------------ 40-50,57,65,75,87: virman/geri donus
    ELSE IF (@Tur BETWEEN 40 AND 50 OR @Tur IN (57, 65, 75, 87)) AND @GeriDonusId > -1
    BEGIN
        -- 40/42: maas avansina virman + taksitli ise taksitler (KASALAR.KASATUR=196)
        IF @Tur IN (40, 42)
        BEGIN
            DELETE FROM dbo.PLANMAAS
             WHERE YERID = @RehberId
               AND DURUM IN (@Id, @GeriDonusId)
               AND EXISTS (SELECT 1 FROM dbo.KASA K
                             INNER JOIN dbo.KASALAR KS ON KS.ID = K.HESAPID
                            WHERE K.ID = dbo.PLANMAAS.DURUM AND KS.KASATUR = 196);
            SET @Silinen += @@ROWCOUNT;
        END

        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'ID=@pB', @KosulPar = @GeriDonusId,
             @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @GeriDonusId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 0, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n, 0);

        DELETE FROM dbo.KASA WHERE ID = @GeriDonusId;
        SET @Silinen += @@ROWCOUNT;
    END

    ------------------------------------------------------------------ 51-54: cek/senet portfoye don
    ELSE IF @Tur IN (51, 52, 53, 54)
    BEGIN
        DECLARE @Islem INT = CASE WHEN @Tur IN (51, 52) THEN 136 ELSE 143 END;

        DELETE FROM dbo.CEKHAREKET WHERE CEKSENETLERID = @CekSenetId AND ISLEM = @Islem;
        SET @Silinen += @@ROWCOUNT;

        DECLARE @SonIslem INT =
            (SELECT TOP 1 ISLEM FROM dbo.CEKHAREKET WHERE CEKSENETLERID = @CekSenetId ORDER BY TARIH DESC);

        IF @SonIslem IS NOT NULL
            UPDATE dbo.CEKLER SET DURUM = 1, TUR = @SonIslem WHERE ID = @CekSenetId;
        ELSE
            UPDATE dbo.CEKLER SET DURUM = 1 WHERE ID = @CekSenetId;
    END

    ------------------------------------------------------------------ 58/59: kredi taksit zinciri
    ELSE IF @Tur IN (58, 59)
    BEGIN
        DECLARE @KasaId BIGINT = @Id, @SonrakiId BIGINT, @YerIdZ INT, @Adim INT = 0;
        WHILE @KasaId > 0 AND @Adim < 100
        BEGIN
            SELECT @YerIdZ = ISNULL(YERID, 0), @SonrakiId = ISNULL(GERIDONUSID, 0)
              FROM dbo.KASA WHERE ID = @KasaId;
            IF @@ROWCOUNT = 0 BREAK;

            IF @YerIdZ > 0
                UPDATE dbo.PLANKREDI SET ODENMIS = 0 WHERE ID = @YerIdZ;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'ID=@pB', @KosulPar = @KasaId,
                 @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);

            DELETE FROM dbo.KASA WHERE ID = @KasaId;
            SET @Silinen += @@ROWCOUNT;

            SET @KasaId = @SonrakiId;
            SET @Adim += 1;
        END
    END

    ------------------------------------------------------------------ ASIL KASA SATIRI
    --   58/59 zinciri kendi icinde sildi -> tekrar silinmez.
    IF @Tur NOT IN (58, 59)
       AND ( @Tur IN (0,1,2,13,17,21,22,25,26,28,29,31,32,35,36,38,39,51,52,53,54,
                      57,58,59,61,65,91,95,71,75,81,87,88,98,125,350)
             OR (@Tur BETWEEN 40 AND 50)
             OR @Tur > 2600 )     -- 2600+ : Sodexo vb. kupon turleri
    BEGIN
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'ID=@pB', @KosulPar = @Id,
             @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @Id,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 0, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n, 0);

        DELETE FROM dbo.KASA WHERE ID = @Id;
        SET @Silinen += @@ROWCOUNT;
    END

    COMMIT;

    SELECT Sonuc = 1, KayitId = @Id, Tur = @Tur, SilinenSatir = @Silinen,
           Loglanan = @Loglanan, FaturaId = @FaturaId
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_KasaHareket_Sil_Json TO gentegre_api;
GO
