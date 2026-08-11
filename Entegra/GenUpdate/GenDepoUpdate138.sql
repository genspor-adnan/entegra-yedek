-- ============================================================
-- GenDepoUpdate138.sql
-- HIZLI GIRIS (POS/kasiyer) - PARA YAZAN ADIMLAR SUNUCUYA
--
-- SORUN (UHizliGiris.BtnTahsilatClick, 211 satir): tahsilat satirlari KASA'ya
--   TEK TEK ekleniyor (dataset Append/Post dongusu), sonra satis/fatura olusuyor,
--   sonra KASA satirlari faturaya baglaniyor. Dosyada TEK BIR StartTransaction YOK.
--   Ortada kopan baglanti = yarim tahsilat (bazi odemeler yazili, bazisi degil) ya
--   da faturaya baglanmamis kasa satiri. Kasiyer bunu ancak gun sonu farkinda olur.
--
-- BU DOSYA: para yazan uc adim tek transaction'a alinir.
--   sp_Api_POS_Tahsilat_Json : tum odeme satirlari (KASA / perakendede SATISKASA)
--   sp_Api_POS_Satis_Json    : SATIS + SATISDETAY (once iki ayri komuttu -> yetim SATIS riski)
--   sp_Api_POS_Iskonto_Json  : gecici fatura tablosu + FATURA + FATBASLIK toplamlari
--
-- GECICI TABLOLAR: POS ##global temp tablolarini adiyla gecirir (##Fat_<spid>_<zaman>).
--   Ad dogrulanir (sadece ##harf/rakam/alt-cizgi + tempdb'de var mi) -> enjeksiyon yok.
--
-- BELGENO: kasa makbuz numarasi yine sp_BelgeNoGetir'den alinir (kocan SEQUENCE'i).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ---- Yardimci: ##global temp tablo adi guvenli mi -------------------------
CREATE OR ALTER FUNCTION dbo.fn_Prog_GeciciTabloGecerli(@Ad sysname)
RETURNS BIT
AS
BEGIN
    IF @Ad IS NULL OR LEN(@Ad) < 3 RETURN 0;
    IF LEFT(@Ad, 2) <> '##' RETURN 0;
    IF @Ad LIKE '%[^0-9A-Za-z_#]%' RETURN 0;          -- yalnizca harf/rakam/_/#
    IF OBJECT_ID('tempdb..' + @Ad) IS NULL RETURN 0;  -- gercekten var mi
    RETURN 1;
END
GO

-- ============================================================
-- 1) TAHSILAT: tum odeme satirlari TEK transaction
--   {"RehId":..,"FatTur":..,"YerId":..,"FaturaId":..,"MasrafId":..,"Kur":"TL",
--    "Perakende":0/1,"KasaTakipTabNo":..,"GirisKaynak":..,
--    "Satirlar":[{"Tur":21,"HesapId":5,"MusteriHesapId":0,"Tutar":100.0,"HesapTuru":"K"}],
--    "Oturum":{"KulId":..,"SubeId":..}}
--   Perakende=1 -> KASA yerine SATISKASA (hizli satis kaydi, ID uretmez -> '0')
-- CIKTI: {"Sonuc":1,"Idler":"12,13","Adet":2}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_POS_Tahsilat_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RehId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehId')    AS INT), 0);
    DECLARE @FatTur   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.FatTur')   AS INT), 0);
    DECLARE @YerId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.YerId')    AS INT), 0);
    DECLARE @FaturaId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.FaturaId') AS INT), 0);
    DECLARE @MasrafId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.MasrafId') AS INT), 0);
    DECLARE @Kur      NVARCHAR(5) = ISNULL(JSON_VALUE(@Kosullar, '$.Kur'), N'TL');
    DECLARE @Perakende BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Perakende') AS BIT), 0);
    DECLARE @KasaTakip INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KasaTakipTabNo') AS INT), 0);
    DECLARE @GirisKay  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GirisKaynak')    AS INT), 0);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Simdi    DATETIME = GETDATE();

    DECLARE @Satir TABLE (Sira INT IDENTITY(1,1), Tur INT, HesapId INT, MusteriHesapId INT,
                          Tutar MONEY, HesapTuru CHAR(1));
    INSERT @Satir (Tur, HesapId, MusteriHesapId, Tutar, HesapTuru)
    SELECT ISNULL(Tur, 0), ISNULL(HesapId, 0), ISNULL(MusteriHesapId, 0),
           ISNULL(Tutar, 0), ISNULL(LEFT(HesapTuru, 1), 'K')
    FROM OPENJSON(@Kosullar, '$.Satirlar')
    WITH (Tur INT '$.Tur', HesapId INT '$.HesapId', MusteriHesapId INT '$.MusteriHesapId',
          Tutar MONEY '$.Tutar', HesapTuru NVARCHAR(2) '$.HesapTuru')
    WHERE ISNULL(Tutar, 0) >= 0.01;

    IF NOT EXISTS (SELECT 1 FROM @Satir)
    BEGIN
        SELECT Sonuc = 1, Idler = N'', Adet = 0 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
        RETURN;
    END

    DECLARE @Yeni TABLE (ID BIGINT);
    DECLARE @Idler NVARCHAR(MAX) = N'', @Adet INT = 0;
    DECLARE @i INT = 1, @Son INT = (SELECT MAX(Sira) FROM @Satir);
    DECLARE @Tur INT, @HesapId INT, @MHesapId INT, @Tutar MONEY, @HTur CHAR(1);
    DECLARE @BN TABLE (KOCANNO INT, BELGESERI NVARCHAR(5), BELGENO NVARCHAR(20));
    DECLARE @BelgeNo NVARCHAR(30);

    BEGIN TRAN;

    WHILE @i <= @Son
    BEGIN
        SELECT @Tur = Tur, @HesapId = HesapId, @MHesapId = MusteriHesapId,
               @Tutar = Tutar, @HTur = HesapTuru
          FROM @Satir WHERE Sira = @i;

        IF @Tur IS NULL BEGIN SET @i += 1; CONTINUE; END

        IF @Perakende = 1
        BEGIN
            INSERT INTO dbo.SATISKASA (TUR, TARIH, REHBERID, HESAPID, TUTAR, FATURAID, EKLEYEN, SUBEID, AKTAR)
            VALUES (@Tur, @Simdi, @RehId, @HesapId, @Tutar, 0, @KulId, @SubeId, 0);
            SET @Idler = @Idler + CASE WHEN @Idler = N'' THEN N'' ELSE N',' END + N'0';
        END
        ELSE
        BEGIN
            -- Makbuz no: kocan SEQUENCE'i (sp_BelgeNoGetir). NOT: bu SP "INSERT ... EXEC"
            --   kullandigi icin sp_Api_POS_Tahsilat_Json'un kendisi INSERT-EXEC ile cagrilamaz.
            DELETE @BN;
            INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @Tur, @SubeID = @SubeId;
            SELECT TOP 1 @BelgeNo = ISNULL(BELGESERI, N'') + ISNULL(BELGENO, N'') FROM @BN;

            DELETE @Yeni;
            INSERT INTO dbo.KASA (TUR, PLANTARIHI, ISLEMTARIHI, BELGENO, REHBERID, HESAPID,
                                  BORC, ALACAK, KUR, DOVIZ_TUTARI, DOVIZ_KURU, HESAPTURU,
                                  MASRAFID, FATURAID, MUSTERIHESAPID,
                                  EKLEYEN, SUBEID, YERI, YERID, GIRISKAYNAK)
            OUTPUT inserted.ID INTO @Yeni (ID)
            VALUES (@Tur, @Simdi, @Simdi, @BelgeNo, @RehId, @HesapId,
                    0, @Tutar, @Kur, @Tutar, @Kur, @HTur,
                    CASE WHEN @FatTur > 0 THEN NULLIF(@MasrafId, 0) END,
                    CASE WHEN @FatTur > 0 THEN NULLIF(@FaturaId, 0) END,
                    CASE WHEN @Tur = 25 THEN NULLIF(@MHesapId, 0) END,
                    @KulId, @SubeId, @KasaTakip, @YerId, @GirisKay);

            SET @Idler = @Idler + CASE WHEN @Idler = N'' THEN N'' ELSE N',' END +
                         CAST((SELECT TOP 1 ID FROM @Yeni) AS NVARCHAR(20));
        END

        SET @Adet += 1;
        SET @i += 1;
    END

    COMMIT;

    SELECT Sonuc = 1, Idler = @Idler, Adet = @Adet FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ============================================================
-- 2) SATIS: SATIS + SATISDETAY tek transaction
--   {"FatBasTablo":"##Fat_..FATBAS","FatTablo":"##Fat_..","Oturum":{...}}
-- CIKTI: {"Sonuc":1,"SatisId":..,"Detay":..}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_POS_Satis_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @FatBas sysname = JSON_VALUE(@Kosullar, '$.FatBasTablo');
    DECLARE @Fat    sysname = JSON_VALUE(@Kosullar, '$.FatTablo');
    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF dbo.fn_Prog_GeciciTabloGecerli(@FatBas) = 0 OR dbo.fn_Prog_GeciciTabloGecerli(@Fat) = 0
        THROW 51401, N'Gecici tablo bulunamadi.', 1;

    DECLARE @SQL NVARCHAR(MAX), @SatisId BIGINT, @Detay INT;

    BEGIN TRAN;

    SET @SQL = N'INSERT INTO dbo.SATIS (TARIH, TUR, REHBERID, FATURANO, CIKISDEPO, EKLEYEN) ' +
               N'SELECT FATURATARIH, TUR, REHBERID, FATURANO, CIKISDEPO, @kul FROM ' + @FatBas + N'; ' +
               N'SET @sid = SCOPE_IDENTITY();';
    EXEC sp_executesql @SQL, N'@kul INT, @sid BIGINT OUTPUT', @kul = @KulId, @sid = @SatisId OUTPUT;

    SET @SQL = N'INSERT INTO dbo.SATISDETAY (SATISID, URUNID, ADET, BIRIM, MIKTAR, BIRIMFIYAT, TUTAR, ISKONTO, ISKONTO2) ' +
               N'SELECT @sid, URUNID, ADET, BIRIM, MIKTAR, BIRIMFIYAT, TUTAR, ISKONTO, ISKONTO2 FROM ' + @Fat + N'; ' +
               N'SET @n = @@ROWCOUNT;';
    EXEC sp_executesql @SQL, N'@sid BIGINT, @n INT OUTPUT', @sid = @SatisId, @n = @Detay OUTPUT;

    COMMIT;

    SELECT Sonuc = 1, SatisId = @SatisId, Detay = ISNULL(@Detay, 0) FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ============================================================
-- 3) ISKONTO: gecici tablo + FATURA + FATBASLIK toplamlari tek transaction
--   {"FatTablo":"##Fat_..","AdisyonId":..,"Oran":10.0}
--   (Eskiden ucu ayri komuttu: ortada kopunca adisyon iskontolu, fatura degil.)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_POS_Iskonto_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Fat    sysname = JSON_VALUE(@Kosullar, '$.FatTablo');
    DECLARE @Adisyon INT   = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.AdisyonId') AS INT), 0);
    DECLARE @Oran   FLOAT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oran') AS FLOAT), 0);

    IF dbo.fn_Prog_GeciciTabloGecerli(@Fat) = 0
        THROW 51401, N'Gecici tablo bulunamadi.', 1;

    DECLARE @SQL NVARCHAR(MAX);

    BEGIN TRAN;

    SET @SQL = N'UPDATE ' + @Fat + N' SET ISKONTO = @o, ' +
               N'TUTAR = ADET * BIRIMFIYAT * ((100.0 - @o) / 100.0), ' +
               N'DOVIZ_TUTARI = ADET * BIRIMFIYAT * ((100.0 - @o) / 100.0)';
    EXEC sp_executesql @SQL, N'@o FLOAT', @o = @Oran;

    IF @Adisyon > 0
    BEGIN
        UPDATE dbo.FATURA
           SET ISKONTO = @Oran,
               TUTAR   = ADET * BIRIMFIYAT * ((100.0 - @Oran) / 100.0)
         WHERE FATBASID = @Adisyon;

        UPDATE dbo.FATBASLIK
           SET KDV_TUTARI = (SELECT CASE WHEN FATBASLIK.KDVDURUM = N'Hariç'
                                         THEN ISNULL(ROUND(SUM(F.TUTAR * (F.KDV / 100.0)), 2), 0.0)
                                         ELSE ROUND(ISNULL(SUM(F.TUTAR - (F.TUTAR / (1 + (F.KDV / 100.0)))), 0.0), 2) END
                               FROM dbo.FATURA F WHERE F.FATBASID = FATBASLIK.ID),
               FATURA_TUTARI = (SELECT CASE WHEN FATBASLIK.KDVDURUM = N'Hariç'
                                            THEN ISNULL(SUM(ROUND(F.TUTAR * (1 + (F.KDV / 100.0)), 2)), 0.0)
                                            ELSE ISNULL(SUM(ROUND(F.TUTAR, 2)), 0.0) END
                                  FROM dbo.FATURA F WHERE F.FATBASID = FATBASLIK.ID)
         WHERE ID = @Adisyon;
    END

    COMMIT;

    SELECT Sonuc = 1, AdisyonId = @Adisyon, Oran = @Oran FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_POS_Tahsilat_Json TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_POS_Satis_Json    TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_POS_Iskonto_Json  TO gentegre_api;
    GRANT EXECUTE  ON dbo.fn_Prog_GeciciTabloGecerli TO gentegre_api;  -- skaler fonksiyon: EXECUTE
END
GO
