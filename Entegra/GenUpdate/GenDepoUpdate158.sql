-- ============================================================
-- GenDepoUpdate158.sql
-- MESAJLASMA: grup yoneticiligi, gruptan cikma, sohbeti temizleme
--
--   1) sp_Api_Mesaj_Kanal_Kaydet_Json'a "rol" islemi: yonetici bir uyeyi
--      YONETICI YAPAR / YONETICILIGINI KALDIRIR.
--   2) Grup her zaman EN AZ BIR yonetici tasimali:
--        - son yoneticinin rolu kaldirilamaz
--        - son yonetici, grupta baska uye varken gruptan cikamaz
--      (Kural SUNUCUDA; istemci ayrica uyarir ama guvenlik burada.)
--   3) sp_Api_Mesaj_Kanal_Temizle_Json: yalniz yonetici, kanaldaki TUM mesajlari
--      siler ve okundu imleclerini sifirlar.
--
-- Not: grup KURAN zaten yonetici olarak ekleniyordu (Islem='grup' dalinda ROL=1);
--   bu dosya onu degistirmez.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ---- yardimci: kanaldaki yonetici sayisi --------------------------------
CREATE OR ALTER FUNCTION dbo.fn_Prog_Mesaj_YoneticiSayisi(@KanalId INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM dbo.MESAJKANALUYE
             WHERE KANALID = @KanalId AND AYRILMATARIHI IS NULL AND ROL = 1);
END
GO

-- ---- ROL DEGISTIR (yonetici yap / kaldir) -------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Rol_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @Rol     INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Rol') AS INT), 0);  -- 1 yonetici, 0 uye
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    DECLARE @Uyeler TABLE (RehberId INT PRIMARY KEY);
    INSERT @Uyeler (RehberId)
    SELECT DISTINCT TRY_CAST(value AS INT) FROM OPENJSON(@Kosullar, '$.Uyeler')
    WHERE TRY_CAST(value AS INT) IS NOT NULL;
    IF NOT EXISTS (SELECT 1 FROM @Uyeler) THROW 51001, N'Uyeler zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId
                      AND AYRILMATARIHI IS NULL AND ROL = 1)
        THROW 51200, N'Bu işlem için grup yöneticisi olmalısınız.', 1;

    -- Son yoneticinin rolu kaldirilamaz
    IF @Rol = 0 AND dbo.fn_Prog_Mesaj_YoneticiSayisi(@KanalId) <=
       (SELECT COUNT(*) FROM dbo.MESAJKANALUYE U INNER JOIN @Uyeler Y ON Y.RehberId = U.REHBERID
         WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NULL AND U.ROL = 1)
        THROW 51200, N'Grupta en az bir yönetici kalmalı. Önce başka birini yönetici yapın.', 1;

    UPDATE U SET ROL = CASE WHEN @Rol = 1 THEN 1 ELSE 0 END
    FROM dbo.MESAJKANALUYE U INNER JOIN @Uyeler Y ON Y.RehberId = U.REHBERID
    WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NULL;

    SELECT Sonuc = 1, KanalId = @KanalId, Rol = @Rol,
           YoneticiSayisi = dbo.fn_Prog_Mesaj_YoneticiSayisi(@KanalId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- SOHBETI TEMIZLE (yalniz yonetici) ----------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Temizle_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId
                      AND AYRILMATARIHI IS NULL AND ROL = 1)
        THROW 51200, N'Sohbeti yalnızca grup yöneticisi temizleyebilir.', 1;

    DECLARE @Adet INT;
    BEGIN TRAN;
        SELECT @Adet = COUNT(*) FROM dbo.MESAJ WHERE KANALID = @KanalId;

        -- Ekler GENDEPO.DOSYA'da tekil/hash-dedup tutulur; burada YALNIZ mesaj
        --   satirlari silinir. (Dosya referans dusumu istemci tarafinda
        --   ULog.DosyaReferansAzalt ile yapilir.)
        DELETE FROM dbo.MESAJ WHERE KANALID = @KanalId;

        UPDATE dbo.MESAJKANAL
           SET SONMESAJID = NULL, SONMESAJTARIH = NULL
         WHERE ID = @KanalId;

        UPDATE dbo.MESAJKANALUYE
           SET SONOKUMAID = 0, BASLANGICID = 0
         WHERE KANALID = @KanalId;
    COMMIT;

    SELECT Sonuc = 1, KanalId = @KanalId, SilinenMesaj = @Adet
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.fn_Prog_Mesaj_YoneticiSayisi     TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Kanal_Rol_Json      TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Kanal_Temizle_Json  TO gentegre_api;
END
GO

-- ---- uyecikar dalina SON YONETICI korumasi ----

-- ---- dbo.sp_Api_Mesaj_Kanal_Kaydet_Json ----

-- ---- dbo.sp_Api_Mesaj_Kanal_Kaydet_Json  (2 yer) ----

-- ============================================================
-- 1) KANAL: ac / olustur / uye yonet
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Kaydet_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Islem   NVARCHAR(20) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Islem'), N'birebir'));
    DECLARE @KanalId INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KarsiId INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.KarsiId') AS INT);
    DECLARE @Adi     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Adi');
    DECLARE @Bildirim BIT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Bildirim') AS BIT);
    DECLARE @Gecmis  BIT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.EskiMesajlar') AS BIT), 0); -- yeni uye eski mesajlari gorsun mu
    DECLARE @KulId   INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;

    DECLARE @Uyeler TABLE (RehberId INT PRIMARY KEY);
    INSERT @Uyeler (RehberId)
    SELECT DISTINCT TRY_CAST(value AS INT) FROM OPENJSON(@Kosullar, '$.Uyeler')
    WHERE TRY_CAST(value AS INT) IS NOT NULL AND TRY_CAST(value AS INT) <> @KulId;

    DECLARE @Yeni BIT = 0, @SonId BIGINT;

    ------------------------------------------------------------------ BIREBIR
    IF @Islem = N'birebir'
    BEGIN
        IF ISNULL(@KarsiId, 0) <= 0 THROW 51001, N'KarsiId zorunlu.', 1;
        IF @KarsiId = @KulId        THROW 51200, N'Kendinizle sohbet açamazsınız.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.REHBER WHERE ID = @KarsiId)
            THROW 51002, N'Kişi bulunamadı.', 1;

        BEGIN TRAN;
        -- Yaris korumasi: ayni ikili icin ikinci kanal acilmasin.
        SELECT TOP 1 @KanalId = ID FROM dbo.MESAJKANAL WITH (UPDLOCK, HOLDLOCK)
         WHERE ID = dbo.fn_Prog_Mesaj_BirebirKanal(@KulId, @KarsiId);

        IF @KanalId IS NULL
        BEGIN
            INSERT INTO dbo.MESAJKANAL (TUR, ADI, OLUSTURAN, DURUM, SUBEID)
            VALUES (1, NULL, @KulId, 1, @SubeId);
            SET @KanalId = CAST(SCOPE_IDENTITY() AS INT);
            SET @Yeni = 1;

            INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL)
            VALUES (@KanalId, @KulId, 1), (@KanalId, @KarsiId, 1);
        END
        COMMIT;
    END

    ------------------------------------------------------------------ GRUP
    ELSE IF @Islem = N'grup'
    BEGIN
        IF DATALENGTH(ISNULL(@Adi, N'')) = 0 THROW 51001, N'Grup adı zorunlu.', 1;

        BEGIN TRAN;
        INSERT INTO dbo.MESAJKANAL (TUR, ADI, OLUSTURAN, DURUM, SUBEID)
        VALUES (2, @Adi, @KulId, 1, @SubeId);
        SET @KanalId = CAST(SCOPE_IDENTITY() AS INT);
        SET @Yeni = 1;

        INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL) VALUES (@KanalId, @KulId, 1);
        INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL)
        SELECT @KanalId, U.RehberId, 0 FROM @Uyeler U
        WHERE EXISTS (SELECT 1 FROM dbo.REHBER R WHERE R.ID = U.RehberId);
        COMMIT;
    END

    ------------------------------------------------------------------ UYE EKLE
    ELSE IF @Islem = N'uyeekle'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                        WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
            THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;
        IF (SELECT TUR FROM dbo.MESAJKANAL WHERE ID = @KanalId) <> 2
            THROW 51200, N'Yalnızca gruplara üye eklenebilir.', 1;

        SET @SonId = ISNULL((SELECT MAX(ID) FROM dbo.MESAJ WHERE KANALID = @KanalId), 0);

        BEGIN TRAN;
        -- Daha once ayrilmis uye geri geliyorsa satiri canlandir.
        UPDATE U SET AYRILMATARIHI = NULL, KATILMATARIHI = GETDATE(),
                     BASLANGICID = CASE WHEN @Gecmis = 1 THEN 0 ELSE @SonId END
          FROM dbo.MESAJKANALUYE U INNER JOIN @Uyeler Y ON Y.RehberId = U.REHBERID
         WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NOT NULL;

        INSERT INTO dbo.MESAJKANALUYE (KANALID, REHBERID, ROL, BASLANGICID, SONOKUMAID)
        SELECT @KanalId, Y.RehberId, 0,
               CASE WHEN @Gecmis = 1 THEN 0 ELSE @SonId END,
               CASE WHEN @Gecmis = 1 THEN 0 ELSE @SonId END
          FROM @Uyeler Y
         WHERE EXISTS (SELECT 1 FROM dbo.REHBER R WHERE R.ID = Y.RehberId)
           AND NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                            WHERE U.KANALID = @KanalId AND U.REHBERID = Y.RehberId);
        COMMIT;
    END

    ------------------------------------------------------------------ UYE CIKAR
    ELSE IF @Islem = N'uyecikar'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;
        -- Kendisi cikabilir; baskasini yalnizca yonetici cikarabilir.
        IF EXISTS (SELECT 1 FROM @Uyeler WHERE RehberId <> @KulId)
           AND NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                            WHERE KANALID = @KanalId AND REHBERID = @KulId
                              AND ROL = 1 AND AYRILMATARIHI IS NULL)
            THROW 51200, N'Üye çıkarmak için grup yöneticisi olmalısınız.', 1;

        -- SON YONETICI KORUMASI: grupta baska uye varken son yonetici cikamaz /
        --   cikarilamaz; yoksa grup yoneticisiz kalir ve kimse uye ekleyemez.
        DECLARE @Cikanlar TABLE (RehberId INT PRIMARY KEY);
        INSERT @Cikanlar (RehberId)
        SELECT RehberId FROM @Uyeler
        UNION SELECT @KulId WHERE NOT EXISTS (SELECT 1 FROM @Uyeler);

        IF EXISTS (SELECT 1 FROM dbo.MESAJKANAL WHERE ID = @KanalId AND TUR = 2)
           AND (SELECT COUNT(*) FROM dbo.MESAJKANALUYE U
                 WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NULL
                   AND U.REHBERID NOT IN (SELECT RehberId FROM @Cikanlar)) > 0
           AND (SELECT COUNT(*) FROM dbo.MESAJKANALUYE U
                 WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NULL AND U.ROL = 1
                   AND U.REHBERID NOT IN (SELECT RehberId FROM @Cikanlar)) = 0
            THROW 51200, N'Grupta en az bir yÃ¶netici kalmalÄ±. Ã–nce baÅŸka birini yÃ¶netici yapÄ±n.', 1;

        UPDATE dbo.MESAJKANALUYE SET AYRILMATARIHI = GETDATE()
         WHERE KANALID = @KanalId AND AYRILMATARIHI IS NULL
           AND REHBERID IN (SELECT RehberId FROM @Cikanlar);
    END

    ------------------------------------------------------------------ AD DEGISTIR
    ELSE IF @Islem = N'addegistir'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 OR DATALENGTH(ISNULL(@Adi, N'')) = 0 THROW 51001, N'KanalId ve Adi zorunlu.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                        WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
            THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;
        UPDATE dbo.MESAJKANAL SET ADI = @Adi WHERE ID = @KanalId AND TUR = 2;
    END

    ------------------------------------------------------------------ SESSIZE AL / AC
    ELSE IF @Islem = N'sessize'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;
        UPDATE dbo.MESAJKANALUYE SET BILDIRIM = ISNULL(@Bildirim, 0)
         WHERE KANALID = @KanalId AND REHBERID = @KulId;
    END
    ELSE
        THROW 51001, N'Bilinmeyen Islem.', 1;

    -- bit -> JSON true/false olur; istemci sayi bekliyor (FireDAC/JSON tuzagi) -> CAST
    SELECT Sonuc = 1, KanalId = @KanalId, Yeni = CAST(@Yeni AS INT)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO
