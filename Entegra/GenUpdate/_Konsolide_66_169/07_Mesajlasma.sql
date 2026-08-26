-- ======================================================================
-- KONSOLIDE UPDATE 07 - MESAJLASMA
-- ======================================================================
-- 20 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- FUNCTION: fn_prog_mesaj_birebirkanal  (kaynak: GenDepoUpdate145) ----
-- ---- Birebir kanal tekilligi ---------------------------------------------
--   Iki kullanici arasinda TEK birebir kanal olmali. Uyelik iki satirda
--   tutuldugu icin kisit tabloda ifade edilemiyor -> yardimci fonksiyon,
--   kanal acan SP once bunu sorar (yarista ikinci kanal olusursa liste
--   ekrani ikisini de gosterir; SP UPDLOCK ile acar, bkz. 146).
CREATE OR ALTER FUNCTION dbo.fn_Prog_Mesaj_BirebirKanal(@Kul1 INT, @Kul2 INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT TOP 1 K.ID
            FROM dbo.MESAJKANAL K
            WHERE K.TUR = 1 AND K.DURUM = 1
              AND EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                           WHERE U.KANALID = K.ID AND U.REHBERID = @Kul1 AND U.AYRILMATARIHI IS NULL)
              AND EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                           WHERE U.KANALID = K.ID AND U.REHBERID = @Kul2 AND U.AYRILMATARIHI IS NULL)
              AND (SELECT COUNT(*) FROM dbo.MESAJKANALUYE U
                    WHERE U.KANALID = K.ID AND U.AYRILMATARIHI IS NULL) = 2
            ORDER BY K.ID);
END
GO

-- ---- FUNCTION: fn_prog_mesaj_yoneticisayisi  (kaynak: GenDepoUpdate158) ----
-- ---- yardimci: kanaldaki yonetici sayisi --------------------------------
CREATE OR ALTER FUNCTION dbo.fn_Prog_Mesaj_YoneticiSayisi(@KanalId INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM dbo.MESAJKANALUYE
             WHERE KANALID = @KanalId AND AYRILMATARIHI IS NULL AND ROL = 1);
END
GO

-- ---- PROCEDURE: sp_api_mesaj_gonder_json  (kaynak: GenDepoUpdate156) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Gonder_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId    INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @Metin      NVARCHAR(MAX) = JSON_VALUE(@Kosullar, '$.Metin');
    DECLARE @YanitId    BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.YanitId') AS BIGINT);
    DECLARE @DosyaId    INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.DosyaId') AS INT);
    DECLARE @DosyaAdi   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.DosyaAdi');
    DECLARE @DosyaBoyut BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DosyaBoyut') AS BIGINT);
    DECLARE @KulId      INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 OR ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId ve Oturum.KulId zorunlu.', 1;
    -- BOSLUK KONTROLU DATALENGTH ILE: "= N''" karsilastirmasi COLLATION agirligina
    --   bakar; SC olmayan collation'da (Turkish_CI_AS) emoji gibi ek-duzlem
    --   karakterlerin agirligi YOKTUR -> N'<emoji>' = N'' TRUE doner ve tek
    --   emojilik mesaj "bos" sayilip reddedilirdi. DATALENGTH collation'dan
    --   bagimsizdir (bayt sayar).
    IF DATALENGTH(ISNULL(@Metin, N'')) = 0 AND @DosyaId IS NULL
        THROW 51001, N'Boş mesaj gönderilemez.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    DECLARE @Id BIGINT, @Trh DATETIME2(0) = SYSDATETIME();

    BEGIN TRAN;
    INSERT INTO dbo.MESAJ (KANALID, GONDERENID, TARIH, METIN, YANITID, DOSYAID, DOSYAADI, DOSYABOYUT)
    VALUES (@KanalId, @KulId, @Trh, @Metin, @YanitId, @DosyaId, @DosyaAdi, @DosyaBoyut);
    SET @Id = SCOPE_IDENTITY();

    -- Liste ekrani icin denormalize alanlar
    UPDATE dbo.MESAJKANAL SET SONMESAJID = @Id, SONMESAJTARIH = @Trh WHERE ID = @KanalId;
    -- Gonderen kendi mesajini okumus sayilir
    UPDATE dbo.MESAJKANALUYE SET SONOKUMAID = @Id
     WHERE KANALID = @KanalId AND REHBERID = @KulId AND SONOKUMAID < @Id;
    COMMIT;

    SELECT Sonuc = 1, MesajId = @Id, KanalId = @KanalId,
           Tarih = CONVERT(NVARCHAR(19), @Trh, 126)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_mesaj_kanal_avatar_json  (kaynak: GenDepoUpdate154) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Avatar_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @DosyaId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DosyaId') AS INT);  -- NULL/0 = kaldir
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId
                      AND AYRILMATARIHI IS NULL AND ROL = 1)
        THROW 51200, N'Bu işlem için grup yöneticisi olmalısınız.', 1;

    UPDATE dbo.MESAJKANAL SET DOSYAID = NULLIF(@DosyaId, 0) WHERE ID = @KanalId;

    SELECT Sonuc = 1, KanalId = @KanalId, DosyaId = NULLIF(@DosyaId, 0)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_mesaj_kanal_favori_json  (kaynak: GenDepoUpdate162) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Favori_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @Favori  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Favori') AS BIT), 0);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    UPDATE dbo.MESAJKANALUYE SET FAVORI = @Favori
     WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL;

    SELECT Sonuc = 1, KanalId = @KanalId, Favori = CAST(@Favori AS INT)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_mesaj_kanal_kaydet_json  (kaynak: GenDepoUpdate158) ----
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

-- ---- PROCEDURE: sp_api_mesaj_kanal_rol_json  (kaynak: GenDepoUpdate158) ----
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

-- ---- PROCEDURE: sp_api_mesaj_kanal_temizle_json  (kaynak: GenDepoUpdate165) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Kanal_Temizle_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @Kapsam  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kapsam'), N'ben'));

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    DECLARE @Adet INT = 0;

    IF @Kapsam = N'herkes'
    BEGIN
        -- Kalici silme: yalniz GRUP yoneticisi (birebirde iki taraf da ROL=1 oldugu
        --   icin TUR = 2 sarti sart - bkz. GenDepoUpdate161)
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE U
                            INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.TUR = 2
                        WHERE U.KANALID = @KanalId AND U.REHBERID = @KulId
                          AND U.AYRILMATARIHI IS NULL AND U.ROL = 1)
            THROW 51200, N'Sohbeti herkesten yalnızca grup yöneticisi temizleyebilir.', 1;

        BEGIN TRAN;
            SELECT @Adet = COUNT(*) FROM dbo.MESAJ WHERE KANALID = @KanalId;

            DELETE G FROM dbo.MESAJGIZLI G
             INNER JOIN dbo.MESAJ M ON M.ID = G.MESAJID
             WHERE M.KANALID = @KanalId;

            -- Ekler GENDEPO.DOSYA'da hash-dedup tutulur; burada yalniz mesaj satirlari.
            DELETE FROM dbo.MESAJ WHERE KANALID = @KanalId;

            UPDATE dbo.MESAJKANAL SET SONMESAJID = NULL, SONMESAJTARIH = NULL WHERE ID = @KanalId;
            UPDATE dbo.MESAJKANALUYE SET SONOKUMAID = 0, BASLANGICID = 0 WHERE KANALID = @KanalId;
        COMMIT;
    END
    ELSE
    BEGIN
        -- YALNIZ BENDEN: kanaldaki tum mesajlari bu kullaniciya gizle
        INSERT INTO dbo.MESAJGIZLI (MESAJID, REHBERID)
        SELECT M.ID, @KulId
          FROM dbo.MESAJ M
         WHERE M.KANALID = @KanalId
           AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                            WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId);
        SET @Adet = @@ROWCOUNT;

        -- Okundu imlecini de sona al: gizlenen mesajlar rozet uretmesin
        UPDATE U
           SET SONOKUMAID = ISNULL((SELECT MAX(M2.ID) FROM dbo.MESAJ M2
                                     WHERE M2.KANALID = @KanalId), U.SONOKUMAID)
          FROM dbo.MESAJKANALUYE U
         WHERE U.KANALID = @KanalId AND U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL;
    END

    SELECT Sonuc = 1, KanalId = @KanalId, Kapsam = @Kapsam, SilinenMesaj = @Adet
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_mesaj_okundu_json  (kaynak: GenDepoUpdate146) ----
-- ============================================================
-- 5) OKUNDU (imleci ilerlet - yalniz ileri)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Okundu_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @KanalId INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @SonId   BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SonOkumaId') AS BIGINT);

    IF @KulId <= 0 OR ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId ve Oturum.KulId zorunlu.', 1;
    IF @SonId IS NULL
        SET @SonId = ISNULL((SELECT MAX(ID) FROM dbo.MESAJ WHERE KANALID = @KanalId), 0);

    UPDATE dbo.MESAJKANALUYE SET SONOKUMAID = @SonId
     WHERE KANALID = @KanalId AND REHBERID = @KulId AND SONOKUMAID < @SonId;

    SELECT Sonuc = 1, KanalId = @KanalId, SonOkumaId = @SonId
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_mesaj_okunmadi_json  (kaynak: GenDepoUpdate163) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Okunmadi_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KanalId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @KulId <= 0 THROW 51001, N'Oturum.KulId zorunlu.', 1;
    IF ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    -- Karsi taraftan gelen SON mesaj (silinmis ve kendimden gizlenmisler haric)
    DECLARE @Son BIGINT =
        (SELECT MAX(M.ID) FROM dbo.MESAJ M
          WHERE M.KANALID = @KanalId AND M.GONDERENID <> @KulId AND M.SILINDI = 0
            AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                             WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId));

    IF @Son IS NOT NULL
        UPDATE dbo.MESAJKANALUYE
           SET SONOKUMAID = CASE WHEN @Son - 1 < BASLANGICID THEN BASLANGICID ELSE @Son - 1 END
         WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL;

    SELECT Sonuc = 1, KanalId = @KanalId, SonMesajId = @Son
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_mesaj_sil_json  (kaynak: GenDepoUpdate161) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @MesajId BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.MesajId') AS BIGINT);
    DECLARE @Kapsam  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kapsam'), N'ben'));
    IF @KulId <= 0 OR ISNULL(@MesajId, 0) <= 0 THROW 51001, N'MesajId ve Oturum.KulId zorunlu.', 1;

    DECLARE @KanalId INT, @Gonderen INT, @Tur TINYINT;
    SELECT @KanalId = M.KANALID, @Gonderen = M.GONDERENID, @Tur = K.TUR
      FROM dbo.MESAJ M INNER JOIN dbo.MESAJKANAL K ON K.ID = M.KANALID
     WHERE M.ID = @MesajId;
    IF @KanalId IS NULL THROW 51002, N'Mesaj bulunamadı.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    IF @Kapsam = N'herkes'
    BEGIN
        -- Gonderen her zaman; yonetici ayricaligi YALNIZ GRUPTA (TUR = 2)
        IF @Gonderen <> @KulId
           AND NOT (@Tur = 2 AND EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                                          WHERE KANALID = @KanalId AND REHBERID = @KulId
                                            AND ROL = 1 AND AYRILMATARIHI IS NULL))
            THROW 51200, N'Bu mesajı yalnızca gönderen (grupta yönetici) herkesten silebilir.', 1;

        UPDATE dbo.MESAJ SET SILINDI = 1, SILEN = @KulId, SILMETARIHI = GETDATE()
         WHERE ID = @MesajId AND SILINDI = 0;
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI WHERE MESAJID = @MesajId AND REHBERID = @KulId)
            INSERT INTO dbo.MESAJGIZLI (MESAJID, REHBERID) VALUES (@MesajId, @KulId);
    END

    SELECT Sonuc = 1, MesajId = @MesajId, KanalId = @KanalId, Kapsam = @Kapsam
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_avatar  (kaynak: GenDepoUpdate148) ----
-- Avatar icerigi (yalnizca gorunen satirlar icin, istemci onbellekler)
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Avatar
    @RehberId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RESIM FROM dbo.REHBER WHERE ID = @RehberId;
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_avatar_toplu  (kaynak: GenDepoUpdate157) ----
-- ---- dbo.sp_Prog_Mesaj_Avatar_Toplu ----

-- ---- dbo.sp_Prog_Mesaj_Avatar_Toplu  (1 yer) ----

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Avatar_Toplu
    @Idler NVARCHAR(MAX)          -- '1064,1098,3228'
AS
BEGIN
    SET NOCOUNT ON;
    IF DATALENGTH(ISNULL(@Idler, N'')) = 0 RETURN;

    DECLARE @X XML = CAST(N'<i>' + REPLACE(@Idler, N',', N'</i><i>') + N'</i>' AS XML);

    ;WITH Idler AS
    (
        SELECT ID = T.c.value(N'.', N'INT')
        FROM @X.nodes(N'/i') T(c)
    )
    SELECT R.ID, R.RESIM
    FROM dbo.REHBER R
        INNER JOIN Idler I ON I.ID = R.ID
    WHERE R.RESIM IS NOT NULL;
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_gecmis_json2  (kaynak: GenDepoUpdate160) ----
-- ---- GECMIS: kullanicidan gizlenen mesajlar gelmesin ---------------------
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Gecmis_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- ListeSPJson imza uyumu (kullanilmiyor)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId')   AS INT), 0);
    DECLARE @KanalId INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId')  AS INT);
    DECLARE @Onceki  BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.OncekiId') AS BIGINT);
    DECLARE @Sonraki BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SonrakiId')AS BIGINT);
    DECLARE @TopN    INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 50);

    IF @KulId <= 0 OR ISNULL(@KanalId, 0) <= 0 THROW 51001, N'KulId ve KanalId zorunlu.', 1;

    DECLARE @Baslangic BIGINT =
        (SELECT BASLANGICID FROM dbo.MESAJKANALUYE
          WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL);
    IF @Baslangic IS NULL THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    -- 1) SADECE ID'ler siralanir: dar satir -> kucuk bellek grant'i
    --    (SQL Express'te genis kolonlarla siralama 33 MB grant istiyordu, bkz. 153)
    DECLARE @Sec TABLE (ID BIGINT PRIMARY KEY);
    INSERT @Sec (ID)
    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END) M.ID
    FROM dbo.MESAJ M
    WHERE M.KANALID = @KanalId
      AND M.ID > @Baslangic
      AND (@Onceki  IS NULL OR M.ID < @Onceki)
      AND (@Sonraki IS NULL OR M.ID > @Sonraki)
      -- "Sil" (kendinden gizle) yapilmis mesajlar bu kullaniciya GELMEZ
      AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                       WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)
    ORDER BY CASE WHEN @Sonraki IS NULL THEN M.ID END DESC,
             CASE WHEN @Sonraki IS NOT NULL THEN M.ID END ASC;

    -- 2) Genis kolonlar ID uzerinden getirilir (siralama @Sec'in PK sirasindan)
    SELECT MESAJID   = S.ID,
           GONDERENID= S.GONDERENID,
           GONDEREN  = R.FIRMA,
           BENIMMI   = CASE WHEN S.GONDERENID = @KulId THEN 1 ELSE 0 END,
           TARIH     = S.TARIH,
           METIN     = CAST(CASE WHEN S.SILINDI = 1 THEN NULL ELSE S.METIN END AS NVARCHAR(4000)),
           SILINDI   = CAST(S.SILINDI AS INT),
           YANITID   = S.YANITID,
           YANITMETIN= CAST(LEFT(YM.METIN, 80) AS NVARCHAR(80)),
           DOSYAID   = S.DOSYAID,
           DOSYAADI  = S.DOSYAADI,
           DOSYABOYUT= S.DOSYABOYUT
    FROM @Sec I
        INNER JOIN dbo.MESAJ  S  ON S.ID  = I.ID
        LEFT  JOIN dbo.REHBER R  ON R.ID  = S.GONDERENID
        LEFT  JOIN dbo.MESAJ  YM ON YM.ID = S.YANITID
    ORDER BY I.ID
    OPTION (FORCE ORDER, LOOP JOIN);
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_icerik_ara_json2  (kaynak: GenDepoUpdate160) ----
-- ---- ICERIK ARAMASI: gizlenenler cikmasin -------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Icerik_Ara_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Ara');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 100);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;
    IF DATALENGTH(ISNULL(@Ara, N'')) = 0 THROW 51001, N'Aranacak metin zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        MESAJID   = M.ID,
        KANALID   = K.ID,
        TUR       = K.TUR,
        KANALADI  = CASE WHEN K.TUR = 2 THEN K.ADI ELSE KS.FIRMA END,
        KARSIID   = CASE WHEN K.TUR = 1 THEN KS.ID END,
        RESIMVAR  = CASE WHEN K.TUR = 1 THEN ISNULL(KS.RESIMVAR, 0)
                         WHEN K.DOSYAID IS NOT NULL THEN 1 ELSE 0 END,
        GRUPDOSYAID = CASE WHEN K.TUR = 2 THEN K.DOSYAID END,
        GONDEREN  = G.FIRMA,
        BENIMMI   = CASE WHEN M.GONDERENID = @KulId THEN 1 ELSE 0 END,
        TARIH     = M.TARIH,
        METIN     = CAST(LEFT(M.METIN, 200) AS NVARCHAR(200))
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        INNER JOIN dbo.MESAJ      M ON M.KANALID = K.ID AND M.ID > U.BASLANGICID
                                   AND M.SILINDI = 0
        LEFT  JOIN dbo.REHBER     G ON G.ID = M.GONDERENID
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA,
                            RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
                       FROM dbo.MESAJKANALUYE U2 INNER JOIN dbo.REHBER R ON R.ID = U2.REHBERID
                      WHERE U2.KANALID = K.ID AND U2.REHBERID <> @KulId) KS
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
      AND M.METIN LIKE N'%' + @Ara + N'%'
      AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G2
                       WHERE G2.MESAJID = M.ID AND G2.REHBERID = @KulId)
    ORDER BY M.ID DESC;
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_kanal_liste_json2  (kaynak: GenDepoUpdate168) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Kanal_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.Ara'), N'');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 100);
    DECLARE @Okunmamis BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YalnizOkunmamis') AS BIT), 0);
    DECLARE @Favori    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YalnizFavori') AS BIT), 0);
    DECLARE @Grup      BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YalnizGrup') AS BIT), 0);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        KANALID    = K.ID,
        TUR        = K.TUR,
        ADI        = CASE WHEN K.TUR = 2 THEN K.ADI ELSE KS.FIRMA END,
        KARSIID    = CASE WHEN K.TUR = 1 THEN KS.ID END,
        RESIMVAR   = CASE WHEN K.TUR = 1 THEN ISNULL(KS.RESIMVAR, 0)
                          WHEN K.DOSYAID IS NOT NULL THEN 1 ELSE 0 END,
        GRUPDOSYAID = CASE WHEN K.TUR = 2 THEN K.DOSYAID END,
        UYESAYISI  = (SELECT COUNT(*) FROM dbo.MESAJKANALUYE X
                       WHERE X.KANALID = K.ID AND X.AYRILMATARIHI IS NULL),
        UYELER     = CASE WHEN K.TUR = 2 THEN
                       STUFF((SELECT N', ' + CASE WHEN U3.REHBERID = @KulId THEN N'Siz' ELSE R2.FIRMA END
                                FROM dbo.MESAJKANALUYE U3
                                     INNER JOIN dbo.REHBER R2 ON R2.ID = U3.REHBERID
                               WHERE U3.KANALID = K.ID AND U3.AYRILMATARIHI IS NULL
                               ORDER BY CASE WHEN U3.REHBERID = @KulId THEN 1 ELSE 0 END, R2.FIRMA
                               FOR XML PATH(N''), TYPE).value(N'.', N'NVARCHAR(MAX)'), 1, 2, N'')
                     END,
        SONMESAJ   = LEFT(CASE WHEN SM.SILINDI = 1 THEN N'(bu mesaj silindi)'
                               ELSE ISNULL(SM.METIN,
                                    CASE WHEN SM.DOSYAID IS NOT NULL
                                         THEN N'[dosya] ' + ISNULL(SM.DOSYAADI, N'') END) END, 120),
        SONGONDEREN = SG.FIRMA,
        SONTARIH   = SM.TARIH,
        OKUNMAMIS  = A.Adet,
        BILDIRIM   = CAST(U.BILDIRIM AS INT),
        YONETICI   = CAST(U.ROL AS INT),
        FAVORI     = CAST(U.FAVORI AS INT)
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        OUTER APPLY (SELECT TOP 1 M.ID, M.METIN, M.TARIH, M.SILINDI, M.DOSYAID, M.DOSYAADI, M.GONDERENID
                       FROM dbo.MESAJ M
                      WHERE M.KANALID = K.ID
                        AND M.ID > U.BASLANGICID
                        AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                         WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)
                      ORDER BY M.ID DESC) SM
        LEFT  JOIN dbo.REHBER SG ON SG.ID = SM.GONDERENID
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA,
                            RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
                       FROM dbo.MESAJKANALUYE U2 INNER JOIN dbo.REHBER R ON R.ID = U2.REHBERID
                      WHERE U2.KANALID = K.ID AND U2.REHBERID <> @KulId) KS
        CROSS APPLY (SELECT Adet = COUNT(*) FROM dbo.MESAJ M
                      WHERE M.KANALID = K.ID AND M.ID > U.SONOKUMAID
                        AND M.ID > U.BASLANGICID AND M.SILINDI = 0
                        AND M.GONDERENID <> @KulId
                        AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                         WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId)) A
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
      -- BOS birebir sohbet listelenmez (kanal var ama gorunur mesaj yok)
      AND (K.TUR = 2 OR SM.ID IS NOT NULL)
      AND (@Okunmamis = 0 OR A.Adet > 0)
      AND (@Favori = 0 OR U.FAVORI = 1)
      AND (@Grup = 0 OR K.TUR = 2)
      AND (@Ara IS NULL
           OR (K.TUR = 2 AND K.ADI LIKE N'%' + @Ara + N'%')
           OR (K.TUR = 1 AND KS.FIRMA LIKE N'%' + @Ara + N'%'))
    ORDER BY ISNULL(SM.TARIH, K.OLUSTURMATARIHI) DESC;
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_kisi_bilgi_json2  (kaynak: GenDepoUpdate155) ----
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

-- ---- PROCEDURE: sp_prog_mesaj_kisi_liste_json2  (kaynak: GenDepoUpdate168) ----
-- ---- Kisi listesi: KANALID yalniz GORUNUR mesaj varsa -------------------
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Kisi_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.Ara'), N'');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 200);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;

    ;WITH Benim AS
    (
        SELECT U.KANALID
        FROM dbo.MESAJKANALUYE U
            INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.TUR = 1 AND K.DURUM = 1
        WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
          -- Yalniz GORUNUR mesaji olan kanallar "sohbet" sayilir
          AND EXISTS (SELECT 1 FROM dbo.MESAJ M
                       WHERE M.KANALID = U.KANALID AND M.ID > U.BASLANGICID
                         AND NOT EXISTS (SELECT 1 FROM dbo.MESAJGIZLI G
                                          WHERE G.MESAJID = M.ID AND G.REHBERID = @KulId))
    ),
    Karsi AS
    (
        SELECT U.REHBERID, KANALID = MIN(U.KANALID)
        FROM dbo.MESAJKANALUYE U
            INNER JOIN Benim B ON B.KANALID = U.KANALID
        WHERE U.REHBERID <> @KulId AND U.AYRILMATARIHI IS NULL
        GROUP BY U.REHBERID
    )
    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        REHBERID = R.ID,
        ADI      = R.FIRMA,
        KOD      = R.KOD,
        RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END,
        KANALID  = KR.KANALID
    FROM dbo.KULLANICI K
        INNER JOIN dbo.REHBER R ON R.ID = K.REHBERID
        LEFT  JOIN Karsi KR ON KR.REHBERID = R.ID
    WHERE ISNULL(K.DURUM, 0) = 1
      AND R.ID <> @KulId
      AND (@Ara IS NULL OR R.FIRMA LIKE N'%' + @Ara + N'%' OR R.KOD LIKE N'%' + @Ara + N'%')
    ORDER BY R.FIRMA;
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_uye_liste_json2  (kaynak: GenDepoUpdate150) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Uye_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- ListeSPJson imza uyumu (kullanilmiyor)
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @KanalId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KanalId') AS INT), 0);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;
    IF @KanalId <= 0 THROW 51001, N'KanalId zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                    WHERE KANALID = @KanalId AND REHBERID = @KulId AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu sohbetin üyesi değilsiniz.', 1;

    SELECT
        REHBERID = R.ID,
        ADI      = R.FIRMA,
        KOD      = R.KOD,
        ROL      = CAST(U.ROL AS INT),                 -- 1 = grup yoneticisi
        BEN      = CASE WHEN R.ID = @KulId THEN 1 ELSE 0 END,
        RESIMVAR = CASE WHEN R.RESIM IS NOT NULL THEN 1 ELSE 0 END
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.REHBER R ON R.ID = U.REHBERID
    WHERE U.KANALID = @KanalId AND U.AYRILMATARIHI IS NULL
    ORDER BY U.ROL DESC, R.FIRMA;
END
GO

-- ---- PROCEDURE: sp_prog_mesaj_yokla_json  (kaynak: GenDepoUpdate164) ----
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
