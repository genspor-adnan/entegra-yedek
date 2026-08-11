-- ============================================================
-- GenDepoUpdate146.sql
-- KURUM ICI MESAJLASMA - SP KATMANI (masaustu + ileride web/mobil ORTAK)
--
--   sp_Api_Mesaj_Kanal_Kaydet_Json  : birebir kanal ac/bul, grup olustur,
--                                     uye ekle/cikar, ad degistir, sessize al
--   sp_Api_Mesaj_Gonder_Json        : mesaj (+ dosya) gonder
--   sp_Prog_Mesaj_Kanal_Liste_Json2 : sohbet listesi (son mesaj + okunmamis)
--   sp_Prog_Mesaj_Gecmis_Json2      : imlecli gecmis (sayfalama + polling)
--   sp_Api_Mesaj_Okundu_Json        : okundu imlecini ilerlet
--   sp_Api_Mesaj_Sil_Json           : mesaji sil (kendi / grup yoneticisi)
--   sp_Prog_Mesaj_Yokla_Json        : UCUZ yoklama - "yeni var mi?"
--
-- Kullanici = REHBER.ID. Cikti tek satir/tek kolon JSON (diger API'lerle ayni).
-- Hata kodlari: 51001 eksik/gecersiz girdi, 51002 kayit yok, 51200 is kurali.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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
        IF ISNULL(@Adi, N'') = N'' THROW 51001, N'Grup adı zorunlu.', 1;

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

        UPDATE dbo.MESAJKANALUYE SET AYRILMATARIHI = GETDATE()
         WHERE KANALID = @KanalId AND AYRILMATARIHI IS NULL
           AND REHBERID IN (SELECT RehberId FROM @Uyeler
                            UNION ALL SELECT @KulId WHERE NOT EXISTS (SELECT 1 FROM @Uyeler));
    END

    ------------------------------------------------------------------ AD DEGISTIR
    ELSE IF @Islem = N'addegistir'
    BEGIN
        IF ISNULL(@KanalId, 0) <= 0 OR ISNULL(@Adi, N'') = N'' THROW 51001, N'KanalId ve Adi zorunlu.', 1;
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

-- ============================================================
-- 2) MESAJ GONDER
-- ============================================================
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
    IF ISNULL(@Metin, N'') = N'' AND @DosyaId IS NULL
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

-- ============================================================
-- 3) SOHBET LISTESI (son mesaj + okunmamis)
--   {"KulId":n,"Ara":"","TopN":100}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Mesaj_Kanal_Liste_Json2
    -- @Baslik: uygulamanin ORTAK liste cagiricisi (Tablo.ListeSPJson) iki parametre
    --   gonderir; burada kullanilmiyor ama imza uyumu icin duruyor.
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KulId') AS INT), 0);
    DECLARE @Ara   NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.Ara'), N'');
    DECLARE @TopN  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.TopN') AS INT), 100);
    IF @KulId <= 0 THROW 51001, N'KulId zorunlu.', 1;

    SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
        KANALID    = K.ID,
        TUR        = K.TUR,
        -- Birebirde baslik = karsi tarafin adi; grupta grup adi
        ADI        = CASE WHEN K.TUR = 2 THEN K.ADI ELSE KS.FIRMA END,
        KARSIID    = CASE WHEN K.TUR = 1 THEN KS.ID END,
        UYESAYISI  = (SELECT COUNT(*) FROM dbo.MESAJKANALUYE X
                       WHERE X.KANALID = K.ID AND X.AYRILMATARIHI IS NULL),
        SONMESAJ   = LEFT(ISNULL(SM.METIN, CASE WHEN SM.DOSYAID IS NOT NULL THEN N'[dosya] ' + ISNULL(SM.DOSYAADI, N'') END), 120),
        SONGONDEREN = SG.FIRMA,
        SONTARIH   = K.SONMESAJTARIH,
        OKUNMAMIS  = (SELECT COUNT(*) FROM dbo.MESAJ M
                       WHERE M.KANALID = K.ID AND M.ID > U.SONOKUMAID
                         AND M.ID > U.BASLANGICID AND M.SILINDI = 0
                         AND M.GONDERENID <> @KulId),
        BILDIRIM   = CAST(U.BILDIRIM AS INT),
        YONETICI   = CAST(U.ROL AS INT)
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        LEFT  JOIN dbo.MESAJ      SM ON SM.ID = K.SONMESAJID
        LEFT  JOIN dbo.REHBER     SG ON SG.ID = SM.GONDERENID
        -- birebirde karsi taraf
        OUTER APPLY (SELECT TOP 1 R.ID, R.FIRMA
                       FROM dbo.MESAJKANALUYE U2 INNER JOIN dbo.REHBER R ON R.ID = U2.REHBERID
                      WHERE U2.KANALID = K.ID AND U2.REHBERID <> @KulId) KS
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
      AND (@Ara IS NULL
           OR (K.TUR = 2 AND K.ADI LIKE N'%' + @Ara + N'%')
           OR (K.TUR = 1 AND KS.FIRMA LIKE N'%' + @Ara + N'%'))
    -- DIKKAT: *_Liste_Json2 deseninde JSON yalnizca GIRDIdir; cikti SATIR KUMESI
    --   olmali (grid kolonlari alan adlarina baglanir). FOR JSON konulursa istemci
    --   "field KANALID not found" hatasi alir.
    ORDER BY ISNULL(K.SONMESAJTARIH, K.OLUSTURMATARIHI) DESC;
END
GO

-- ============================================================
-- 4) GECMIS (imlecli): ilk acilis / yukari kaydirma / polling
--   {"KulId":n,"KanalId":n,"OncekiId":null,"SonrakiId":null,"TopN":50}
--     OncekiId  -> bu ID'den ESKI mesajlar (yukari kaydirma)
--     SonrakiId -> bu ID'den YENI mesajlar (polling)
-- ============================================================
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

    ;WITH S AS (
        SELECT TOP (CASE WHEN @TopN > 0 THEN @TopN ELSE 2147483647 END)
               M.ID, M.KANALID, M.GONDERENID, M.TARIH, M.METIN, M.YANITID,
               M.DOSYAID, M.DOSYAADI, M.DOSYABOYUT, M.SILINDI
        FROM dbo.MESAJ M
        WHERE M.KANALID = @KanalId
          AND M.ID > @Baslangic
          AND (@Onceki  IS NULL OR M.ID < @Onceki)
          AND (@Sonraki IS NULL OR M.ID > @Sonraki)
        ORDER BY CASE WHEN @Sonraki IS NULL THEN M.ID END DESC,   -- eski yon: en yeniden geri
                 CASE WHEN @Sonraki IS NOT NULL THEN M.ID END ASC -- polling: sirali ileri
    )
    SELECT MESAJID   = S.ID,
           GONDERENID= S.GONDERENID,
           GONDEREN  = R.FIRMA,
           BENIMMI   = CASE WHEN S.GONDERENID = @KulId THEN 1 ELSE 0 END,
           TARIH     = S.TARIH,
           -- NVARCHAR(MAX) -> FireDAC ftWideMemo (blob) olarak esler ve gecikmeli
           --   getirir; istemcide AsString BOS gorunuyordu. Sinirli tipe cast:
           METIN     = CAST(CASE WHEN S.SILINDI = 1 THEN NULL ELSE S.METIN END AS NVARCHAR(4000)),
           SILINDI   = CAST(S.SILINDI AS INT),
           YANITID   = S.YANITID,
           YANITMETIN= LEFT(YM.METIN, 80),
           DOSYAID   = S.DOSYAID,
           DOSYAADI  = S.DOSYAADI,
           DOSYABOYUT= S.DOSYABOYUT
    FROM S
        LEFT JOIN dbo.REHBER R  ON R.ID  = S.GONDERENID
        LEFT JOIN dbo.MESAJ  YM ON YM.ID = S.YANITID
    ORDER BY S.ID;
END
GO

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

-- ============================================================
-- 6) MESAJ SIL (yumusak): kendi mesaji ya da grup yoneticisi
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Mesaj_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @MesajId BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.MesajId') AS BIGINT);
    IF @KulId <= 0 OR ISNULL(@MesajId, 0) <= 0 THROW 51001, N'MesajId ve Oturum.KulId zorunlu.', 1;

    DECLARE @KanalId INT, @Gonderen INT;
    SELECT @KanalId = KANALID, @Gonderen = GONDERENID FROM dbo.MESAJ WHERE ID = @MesajId;
    IF @KanalId IS NULL THROW 51002, N'Mesaj bulunamadı.', 1;

    IF @Gonderen <> @KulId
       AND NOT EXISTS (SELECT 1 FROM dbo.MESAJKANALUYE
                        WHERE KANALID = @KanalId AND REHBERID = @KulId
                          AND ROL = 1 AND AYRILMATARIHI IS NULL)
        THROW 51200, N'Bu mesajı silme yetkiniz yok.', 1;

    UPDATE dbo.MESAJ SET SILINDI = 1, SILEN = @KulId, SILMETARIHI = GETDATE()
     WHERE ID = @MesajId AND SILINDI = 0;

    SELECT Sonuc = 1, MesajId = @MesajId, KanalId = @KanalId
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ============================================================
-- 7) YOKLAMA (polling) - UCUZ olmali: her istemci 2-3 sn'de bir cagirir
--   {"KulId":n}
--   Cikti: toplam okunmamis + kanal basina son ID/okunmamis (yalniz DEGISENLER)
-- ============================================================
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
        Kanallar  = (SELECT KANALID = K2.ID, SONMESAJID = K2.SONMESAJID,
                            OKUNMAMIS = A2.Adet, BILDIRIM = CAST(U2.BILDIRIM AS INT)
                     FROM dbo.MESAJKANALUYE U2
                          INNER JOIN dbo.MESAJKANAL K2 ON K2.ID = U2.KANALID AND K2.DURUM = 1
                          CROSS APPLY (SELECT Adet = COUNT(*) FROM dbo.MESAJ M
                                        WHERE M.KANALID = K2.ID AND M.ID > U2.SONOKUMAID
                                          AND M.ID > U2.BASLANGICID AND M.SILINDI = 0
                                          AND M.GONDERENID <> @KulId) A2
                     WHERE U2.REHBERID = @KulId AND U2.AYRILMATARIHI IS NULL AND A2.Adet > 0
                     FOR JSON PATH)
    FROM dbo.MESAJKANALUYE U
        INNER JOIN dbo.MESAJKANAL K ON K.ID = U.KANALID AND K.DURUM = 1
        CROSS APPLY (SELECT Adet = COUNT(*) FROM dbo.MESAJ M
                      WHERE M.KANALID = K.ID AND M.ID > U.SONOKUMAID
                        AND M.ID > U.BASLANGICID AND M.SILINDI = 0
                        AND M.GONDERENID <> @KulId) A
    WHERE U.REHBERID = @KulId AND U.AYRILMATARIHI IS NULL
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Kanal_Kaydet_Json  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Gonder_Json        TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Kanal_Liste_Json2 TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Gecmis_Json2      TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Okundu_Json        TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Mesaj_Sil_Json           TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Mesaj_Yokla_Json        TO gentegre_api;
END
GO
