-- sp_Grnt_CariOlustur
-- Basit cari (REHBER) olusturma SP'si. Eski sp_Grnt_CariIslem cok karmasik;
-- gelen kutusundan cari kaydi olusturmak icin sadelestirilmis bir alternatif.
--
-- Girdi (jsonData):
--   KOD            : Cari kodu (zorunlu, ornek "320.01.225")
--   FIRMA          : Cari unvani (zorunlu)
--   EKLEYEN        : Kullanici ID (int, zorunlu)
--   VNO            : Vergi No / TCKN
--   VD             : Vergi Dairesi
--   FATURABASLIK   : Fatura basligi (bos ise FIRMA kullanilir)
--   ADRES          : Adres
--   ILCE           : Ilce
--   IL             : Il
--   SUBEID         : Sube ID (opsiyonel, default -1)
--   GNTPID         : Kaynak EBELGE.ID (opsiyonel, izleme amaciyla)
--
-- Cikti:
--   SONUC_ID  : Yeni REHBER.ID (basari) veya 0/<0 (hata)
--   SONUC_MESAJ : Hata mesaji
--
-- GRUP, KOD'un ilk segmentinden turetilir (ornek "320.01.225" -> 320).
-- REHBERBILGI.SIRA icin ISNULL((REHBERAYAR), 0) kullanilir; REHBERAYAR'da
-- ETIKET yoksa SIRA=0 yazilir, hata vermez.

CREATE OR ALTER PROC [dbo].[sp_Grnt_CariOlustur]
(
    @jsonData NVARCHAR(MAX),
    @SONUC_ID INT OUTPUT,
    @SONUC_MESAJ VARCHAR(1000) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @KOD nvarchar(20),
        @FIRMA nvarchar(150),
        @EKLEYEN int,
        @VNO nvarchar(50),
        @VD nvarchar(50),
        @FATURABASLIK nvarchar(150),
        @ADRES nvarchar(300),
        @ILCE nvarchar(50),
        @IL nvarchar(50),
        @SUBEID smallint,
        @GNTPID int,
        @ALIAS nvarchar(200),
        @ALIASBELGETURU tinyint,
        @TEL nvarchar(50),
        @WEB nvarchar(200),
        @EPOSTA nvarchar(200),
        @GRUP int,
        @REHBERID int,
        @REHBERILETISIMID int;

    SET @SONUC_ID = 0;
    SET @SONUC_MESAJ = '';

    BEGIN TRY
        SELECT
            @KOD          = JSON_VALUE(@jsonData, '$.KOD'),
            @FIRMA        = JSON_VALUE(@jsonData, '$.FIRMA'),
            @EKLEYEN      = JSON_VALUE(@jsonData, '$.EKLEYEN'),
            @VNO          = JSON_VALUE(@jsonData, '$.VNO'),
            @VD           = JSON_VALUE(@jsonData, '$.VD'),
            @FATURABASLIK = JSON_VALUE(@jsonData, '$.FATURABASLIK'),
            @ADRES        = JSON_VALUE(@jsonData, '$.ADRES'),
            @ILCE         = JSON_VALUE(@jsonData, '$.ILCE'),
            @IL           = JSON_VALUE(@jsonData, '$.IL'),
            @SUBEID       = JSON_VALUE(@jsonData, '$.SUBEID'),
            @GNTPID       = JSON_VALUE(@jsonData, '$.GNTPID'),
            @ALIAS        = JSON_VALUE(@jsonData, '$.ALIAS'),
            @ALIASBELGETURU = JSON_VALUE(@jsonData, '$.ALIASBELGETURU'),
            @TEL          = JSON_VALUE(@jsonData, '$.TEL'),
            @WEB          = JSON_VALUE(@jsonData, '$.WEB'),
            @EPOSTA       = JSON_VALUE(@jsonData, '$.EPOSTA');

        IF ISNULL(@KOD, N'') = N''
        BEGIN
            SET @SONUC_MESAJ = 'KOD bos olamaz';
            RETURN;
        END;
        IF ISNULL(@FIRMA, N'') = N''
        BEGIN
            SET @SONUC_MESAJ = 'FIRMA bos olamaz';
            RETURN;
        END;
        IF ISNULL(@EKLEYEN, 0) = 0
        BEGIN
            SET @SONUC_MESAJ = 'EKLEYEN zorunlu';
            RETURN;
        END;

        -- Ayni KOD'lu kayit varsa hata don.
        IF EXISTS (SELECT 1 FROM REHBER WHERE KOD = @KOD)
        BEGIN
            SET @SONUC_MESAJ = 'Bu KOD zaten kayitli: ' + @KOD;
            RETURN;
        END;

        IF ISNULL(@SUBEID, 0) = 0 SET @SUBEID = -1;
        IF ISNULL(@FATURABASLIK, N'') = N'' SET @FATURABASLIK = @FIRMA;

        -- GRUP: KOD'un ilk noktaya kadar olan kismi (ornek "320.01.225" -> 320)
        SET @GRUP = TRY_CAST(
            CASE
                WHEN CHARINDEX('.', @KOD) > 0
                    THEN LEFT(@KOD, CHARINDEX('.', @KOD) - 1)
                ELSE @KOD
            END
            AS int);
        IF @GRUP IS NULL SET @GRUP = 0;

        BEGIN TRANSACTION;

        -- 1) REHBER
        INSERT INTO REHBER (KOD, FIRMA, GRUP, DURUM, EKLEYEN, EKLEMETARIHI, SUBEID, GNTPID)
        VALUES (@KOD, @FIRMA, @GRUP, 1, @EKLEYEN, GETDATE(), @SUBEID, @GNTPID);

        SET @REHBERID = SCOPE_IDENTITY();

        -- 2) REHBERILETISIM (Merkez)
        INSERT INTO REHBERILETISIM (REHBERID, AD, VARSAYILAN, AKTIF, EKLEYEN, EKLEMETARIHI, SUBEID)
        VALUES (@REHBERID, 'Merkez', 1, 1, @EKLEYEN, GETDATE(), @SUBEID);

        SET @REHBERILETISIMID = SCOPE_IDENTITY();

        -- 3) REHBERBILGI - YERI=1 (iletisim)
        IF ISNULL(@ADRES, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (1, @REHBERILETISIMID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 1 AND ETIKET = N'Adres'), 0),
                    N'Adres', @ADRES, @EKLEYEN, @SUBEID);

        IF ISNULL(@ILCE, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (1, @REHBERILETISIMID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 1 AND ETIKET = N'İlçe'), 0),
                    N'İlçe', @ILCE, @EKLEYEN, @SUBEID);

        IF ISNULL(@IL, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (1, @REHBERILETISIMID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 1 AND ETIKET = N'İl'), 0),
                    N'İl', @IL, @EKLEYEN, @SUBEID);

        IF ISNULL(@TEL, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (1, @REHBERILETISIMID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 1 AND ETIKET = N'İş Tel'), 0),
                    N'İş Tel', @TEL, @EKLEYEN, @SUBEID);

        IF ISNULL(@WEB, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (1, @REHBERILETISIMID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 1 AND ETIKET = N'Web'), 0),
                    N'Web', @WEB, @EKLEYEN, @SUBEID);

        IF ISNULL(@EPOSTA, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (1, @REHBERILETISIMID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 1 AND ETIKET = N'Eposta'), 0),
                    N'Eposta', @EPOSTA, @EKLEYEN, @SUBEID);

        -- 4) REHBERBILGI - YERI=2 (cari)
        IF ISNULL(@VD, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (2, @REHBERID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 2 AND ETIKET = N'Vergi Dairesi'), 0),
                    N'Vergi Dairesi', @VD, @EKLEYEN, @SUBEID);

        IF ISNULL(@VNO, N'') <> N''
            INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
            VALUES (2, @REHBERID,
                    ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 2 AND ETIKET = N'Vergi No'), 0),
                    N'Vergi No', @VNO, @EKLEYEN, @SUBEID);

        INSERT INTO REHBERBILGI (YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, SUBEID)
        VALUES (2, @REHBERID,
                ISNULL((SELECT TOP 1 SIRA FROM REHBERAYAR WHERE YERI = 2 AND ETIKET = N'Fatura Başlığı'), 0),
                N'Fatura Başlığı', @FATURABASLIK, @EKLEYEN, @SUBEID);

        -- 5) REHBERALIAS - sender alias (varsa)
        IF ISNULL(@ALIAS, N'') <> N''
        BEGIN
            IF ISNULL(@ALIASBELGETURU, 0) = 0 SET @ALIASBELGETURU = 151; -- RAlias_EFatura
            INSERT INTO REHBERALIAS (REHBERID, BELGETURU, ALIAS, VARSAYILAN, AKTIF)
            VALUES (@REHBERID, @ALIASBELGETURU, @ALIAS, 1, 1);
        END;

        COMMIT TRANSACTION;

        SET @SONUC_ID = @REHBERID;
        SET @SONUC_MESAJ = 'Cari olusturuldu. ID: ' + CAST(@REHBERID AS varchar(10)) + ' KOD: ' + @KOD;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @SONUC_ID = -1;
        SET @SONUC_MESAJ = 'Hata: ' + ERROR_MESSAGE();
    END CATCH;
END;
