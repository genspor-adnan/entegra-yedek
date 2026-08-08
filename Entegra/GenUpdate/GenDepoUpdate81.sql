-- ============================================================
-- GenDepoUpdate81.sql
-- API: sp_Api_Donusum_SiparistenBelge_Json
--   Bir SIPARIS'i tek islemde hedef belgeye (irsaliye / fatura / fis / konsinye)
--   donusturur: hedef FATBASLIK olusur, kalan miktarli satirlar YERI/YERID bagiyla
--   kopyalanir, toplamlar ve kaynak siparisin kapanma durumu hesaplanir.
--   Hepsi TEK transaction.
--
-- KULLANIM: siparis listesinde sag tus -> "Irsaliyeye/Faturaya donustur".
--   Delphi'de UBelgeDonusum diyalogunu acmadan, secili siparisi dogrudan cevirir.
--   (Kalemi tek tek secerek donusturme UBelgeDonusum ekraninda kalir.)
--
-- SUNUCUYA TASINAN IS KURALLARI
--   - Asiri donusum korumasi: kaynak satirlar UPDLOCK ile kilitlenir, kalan
--     miktar fn_Api_Donusum_Kalan ile TRANSACTION ICINDE hesaplanir. Iki kullanici
--     ayni siparisi ayni anda donusturemez.
--   - Kalani 0 olan satir atlanir; hicbir satir kalmadiysa 51200 ile reddedilir.
--
-- TUR -> HEDEF ESLEME (PrjConst TabNo_DONUSUM_*)
--   Satis siparisi (TUR=19):  irsaliye 14 -> YERI 409 | fatura 15 -> 410
--                             fis 16 -> 473           | konsinye 119 -> 429
--   Alis siparisi  (TUR=9):   irsaliye 10 -> YERI 406 | fatura 11 -> 407
--                             fis 12 -> 478
--
-- GIRDI : {"SiparisId":23203,"HedefTur":14,"Tarih":"2026-08-08",
--          "SatirIds":[156958,156959],            -- opsiyonel; yoksa TUM kalan satirlar
--          "Oturum":{"KulId":5,"SubeId":-1}}
-- CIKTI : {"Sonuc":1,"SiparisId":..,"HedefBelgeId":..,"HedefBelgeNo":"..",
--          "HedefTur":..,"DonusumTuru":..,"Satir":n,"Toplam":{...},
--          "KaynakDurum":{"Durum":..,"Yazildi":..}}
-- HATA  : 51001 girdi, 51002 siparis bulunamadi,
--         51200 donusturulecek kalan satir yok / hedef tur uyumsuz
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_SiparistenBelge_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SiparisId INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.SiparisId') AS INT);
    DECLARE @HedefTur  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefTur')  AS INT);
    DECLARE @Tarih     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tarih')     AS DATETIME);
    DECLARE @KulId     INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId    INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @SiparisId IS NULL OR @SiparisId <= 0 THROW 51001, N'SiparisId zorunlu.', 1;
    IF @HedefTur  IS NULL                    THROW 51001, N'HedefTur zorunlu.', 1;
    SET @Tarih = ISNULL(@Tarih, GETDATE());

    DECLARE @Tur INT, @Tipi INT, @RehberId INT, @GirisDepo INT, @CikisDepo INT,
            @KdvDurum NVARCHAR(10), @Kur NVARCHAR(10), @DovizCins NVARCHAR(10),
            @DovizKur MONEY, @RaporDvz NVARCHAR(10), @ProjeId INT, @Aciklama NVARCHAR(200),
            @Vade INT, @SaticiKodu INT, @FiyatLst INT, @SiparisNo NVARCHAR(50);
    SELECT @Tur = TUR, @Tipi = ISNULL(TIPI, 1), @RehberId = REHBERID,
           @GirisDepo = ISNULL(GIRISDEPO, 0), @CikisDepo = ISNULL(CIKISDEPO, 0),
           @KdvDurum = KDVDURUM, @Kur = KUR, @DovizCins = DOVIZ_CINSI,
           @DovizKur = ISNULL(DOVIZKUR, 1), @RaporDvz = RAPORDOVIZ,
           @ProjeId = ISNULL(PROJEID, 0), @Aciklama = ACIKLAMA, @Vade = ISNULL(VADE, 0),
           @SaticiKodu = SATICIKODU, @FiyatLst = FIYAT_LISTESI, @SiparisNo = SIPARISNO
    FROM SIPARIS WHERE ID = @SiparisId;

    IF @Tur IS NULL THROW 51002, N'Siparis bulunamadi.', 1;

    -- ---- Hedef tur -> donusum (YERI) kodu ----
    DECLARE @DonusumTuru INT =
        CASE WHEN @Tur = 19 THEN CASE @HedefTur WHEN 14 THEN 409 WHEN 15 THEN 410
                                                WHEN 16 THEN 473 WHEN 119 THEN 429 END
             WHEN @Tur = 9  THEN CASE @HedefTur WHEN 10 THEN 406 WHEN 11 THEN 407
                                                WHEN 12 THEN 478 END
        END;
    IF @DonusumTuru IS NULL
    BEGIN
        DECLARE @m NVARCHAR(200) = N'Bu siparis turu (' + CAST(@Tur AS nvarchar(10)) +
            N') hedef belge turune (' + CAST(@HedefTur AS nvarchar(10)) + N') donusturulemez.';
        THROW 51200, @m, 1;
    END

    DECLARE @HedefBelgeId INT, @BelgeNo NVARCHAR(50), @FatSeri NVARCHAR(20), @Satir INT = 0;

    BEGIN TRY
        BEGIN TRAN;

        -- ---- Kaynak satirlari KILITLE, kalanlari hesapla ----
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, UrunId INT, Tur INT,
                          Kalan DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
                          BirimFiyat DECIMAL(18,6), Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT,
                          Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
                          DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY,
                          Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
                          OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), Izleme INT, PozNo INT,
                          YeniSatirId INT NULL);

        DECLARE @Secili TABLE (ID INT PRIMARY KEY);
        INSERT @Secili (ID) SELECT DISTINCT CAST(value AS INT)
          FROM OPENJSON(@Kosullar, '$.SatirIds') WHERE ISNUMERIC(value) = 1;

        INSERT @S (SatirId, UrunId, Tur, Kalan, Miktar, Birim, BirimFiyat, Kdv, Iskonto, Iskonto2,
                   Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, Aciklama, ProjeId, MasrafId,
                   OzelKod, OzelKod2, Izleme, PozNo)
        SELECT SD.ID, SD.URUNID, ISNULL(SD.TUR, 1), K.Kalan,
               -- Miktar ADET ile ayni oranda kalana indirgenir (birim cevrimi korunur)
               CASE WHEN ISNULL(SD.ADET, 0) = 0 THEN K.Kalan
                    ELSE ROUND(ISNULL(SD.MIKTAR, SD.ADET) * K.Kalan / SD.ADET, 6) END,
               ISNULL(SD.BIRIM, 0), ISNULL(SD.BIRIMFIYAT, 0), ISNULL(SD.KDV, 0),
               ISNULL(SD.ISKONTO, 0), ISNULL(SD.ISKONTO2, 0),
               ISNULL(SD.KUR, N'TL'), ISNULL(SD.DOVIZ_KURU, N'TL'),
               ISNULL(SD.DOVIZ_BIRIMFIYAT, 0), ISNULL(SD.DOVIZKURDEGERI, 1),
               ISNULL(SD.ACIKLAMA, N''), ISNULL(SD.PROJEID, 0), ISNULL(SD.MASRAFID, 0),
               ISNULL(SD.OZELKOD, N''), ISNULL(SD.OZELKOD2, N''), ISNULL(SD.IZLEME, 0),
               ISNULL(SD.POZNO, 0)
        FROM SIPARISDETAY SD WITH (UPDLOCK, HOLDLOCK)
            CROSS APPLY dbo.fn_Api_Donusum_Kalan(2, @DonusumTuru, SD.ID, 0) K
        WHERE SD.SIPARISID = @SiparisId
          AND K.Kalan > 0.0001
          AND (NOT EXISTS (SELECT 1 FROM @Secili) OR SD.ID IN (SELECT ID FROM @Secili));

        IF NOT EXISTS (SELECT 1 FROM @S)
            THROW 51200, N'Donusturulecek kalan satir yok (siparis tamamlanmis olabilir).', 1;

        -- ---- Hedef belge basligi ----
        DECLARE @Kocan INT = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                      WHERE TUR = @HedefTur AND SUBEID = -1
                                        AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                      ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
        DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
        INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @HedefTur, @SubeID = -1,
                                            @Kocanno = @Kocan, @BTarihi = @Tarih;
        SELECT TOP 1 @BelgeNo = BelgeNo, @FatSeri = BelgeSeri FROM @BN;

        INSERT INTO FATBASLIK (TARIH, TUR, TIPI, REHBERID, PROJEID, FATURATARIH,
                               FATURANO, FATURASERI, GIRISDEPO, CIKISDEPO,
                               KDVDURUM, KUR, DOVIZ_CINSI, DOVIZKUR, RAPORDOVIZ, FATURADOVIZI,
                               FIYAT_LISTESI, SATICIKODU, ACIKLAMA, DURUM, VADE, SUBEID,
                               EKLEYEN, EKLEMETARIHI, GIRISKAYNAK)
        VALUES (@Tarih, @HedefTur, @Tipi, @RehberId, @ProjeId, @Tarih,
                @BelgeNo, @FatSeri, @GirisDepo, @CikisDepo,
                ISNULL(@KdvDurum, N'Hariç'), ISNULL(@Kur, N'TL'), ISNULL(@DovizCins, N'TL'),
                @DovizKur, ISNULL(@RaporDvz, N'TL'), ISNULL(@RaporDvz, N'TL'),
                @FiyatLst, @SaticiKodu,
                LEFT(ISNULL(@SiparisNo, N'') + N' nolu siparisten', 200),
                0, @Vade, @SubeId, @KulId, GETDATE(), 1);
        SET @HedefBelgeId = CAST(SCOPE_IDENTITY() AS INT);

        DECLARE @TabKart  INT = dbo.fn_Api_Belge_TabNo(@HedefTur, 0);
        DECLARE @TabDetay INT = dbo.fn_Api_Belge_TabNo(@HedefTur, 1);
        DECLARE @LogN INT, @Loglanan INT = 0;
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @HedefBelgeId,
             @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @HedefBelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
        SET @Loglanan = @Loglanan + @LogN;

        -- ---- Satirlar (YERI/YERID bagi ile) ----
        DECLARE @SatirId INT, @YeniId INT;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT SatirId FROM @S ORDER BY SatirId;
        OPEN c; FETCH NEXT FROM c INTO @SatirId;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, STOKID, ACIKLAMA, ADET, MIKTAR,
                                BIRIM, BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV, MASRAFID,
                                OZELKOD, OZELKOD2, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT,
                                DOVIZKURDEGERI, PROJEID, IZLEME, POZNO, SUBEID, EKLEYEN, EKLEMETARIHI,
                                YERI, YERID, GIRDEPO, CIKDEPO, STOKDURUMDEGIS, GIRISKAYNAK)
            SELECT @HedefBelgeId, @RehberId, S.Tur, S.UrunId,
                   CASE WHEN S.Tur = 0 THEN 0 ELSE S.UrunId END,
                   S.Aciklama, S.Kalan, S.Miktar,
                   S.Birim, S.BirimFiyat,
                   ROUND(ROUND(S.BirimFiyat * S.Kalan, 2)
                         * (100.0 - S.Iskonto) * (100.0 - S.Iskonto2) / 10000.0, 2),
                   S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                   S.OzelKod, S.OzelKod2,
                   ROUND(S.DovizBirimFiyat * S.Kalan, 2), S.DovizKuru, S.DovizBirimFiyat,
                   S.DovizKurDegeri, S.ProjeId, S.Izleme, S.PozNo, @SubeId, @KulId, GETDATE(),
                   @DonusumTuru, S.SatirId, @GirisDepo, @CikisDepo, 1, 1
            FROM @S S WHERE S.SatirId = @SatirId;

            SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);
            UPDATE @S SET YeniSatirId = @YeniId WHERE SatirId = @SatirId;
            SET @Satir = @Satir + 1;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @YeniId,
                 @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @HedefBelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
            SET @Loglanan = @Loglanan + @LogN;

            FETCH NEXT FROM c INTO @SatirId;
        END
        CLOSE c; DEALLOCATE c;

        -- ---- Hedef belge toplamlari ----
        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkVergi MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @HedefBelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkVergi OUTPUT,
             @Neden = @TNeden OUTPUT, @Yazildi = @TYazildi OUTPUT;

        -- ---- Kaynak siparisin kapanma durumu ----
        DECLARE @dTur INT, @dDurum INT, @dOnce INT, @dSat INT, @dTam INT, @dKis INT,
                @dAcik INT, @dNeden NVARCHAR(60), @dYaz BIT;
        EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @SiparisId, @Kaynak = N'siparis',
             @Tur = @dTur OUTPUT, @Durum = @dDurum OUTPUT, @OncekiDurum = @dOnce OUTPUT,
             @Satir = @dSat OUTPUT, @Tamamlanan = @dTam OUTPUT, @Kismi = @dKis OUTPUT,
             @Acik = @dAcik OUTPUT, @Neden = @dNeden OUTPUT, @Yazildi = @dYaz OUTPUT;

        COMMIT;

        SELECT (SELECT 1 AS Sonuc, @SiparisId AS SiparisId, @HedefBelgeId AS HedefBelgeId,
                       @BelgeNo AS HedefBelgeNo, @HedefTur AS HedefTur,
                       @DonusumTuru AS DonusumTuru, @Satir AS Satir, @Loglanan AS Loglanan,
                       (SELECT @Matrah AS Matrah, @Kdv AS Kdv, @Toplam AS Toplam, @Doviz AS Doviz
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Toplam,
                       (SELECT @dDurum AS Durum, @dYaz AS Yazildi, @dNeden AS Neden
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS KaynakDurum
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Donusum_SiparistenBelge_Json TO gentegre_api;
GO
