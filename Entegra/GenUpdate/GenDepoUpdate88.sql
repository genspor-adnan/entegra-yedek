-- ============================================================
-- GenDepoUpdate88.sql
-- sp_Api_Belge_Donusum_Json : baslik uretimini ortak ic yordama devret
--
-- GenDepoUpdate87 ile hedef baslik INSERT'i sp_Api_Belge_Donusum_Baslik_Ic'e tasindi
--   (kolon kumesi BelgeDonustur_BaslikOlusur ile birebir). Bu SP onceden KENDI kucuk
--   kolon kumesiyle baslik yaziyordu; KOCANNO, BASLIK/ADRES/ILCE/IL/VD/VNO, AKTIVITEID,
--   REHBERILETID, SERVISID, DETAYBOLUMU, OZELKOD, EFATURADURUM/EFATURASONUC ve SENARYO
--   yazilmiyordu. Artik iki yol da AYNI basligi uretiyor.
--
-- Yeni opsiyonel girdiler: "Senaryo" ve "VarsayilanDoviz" (Delphi GENINI'den gonderir).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Donusum_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DonusumTuru  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru')  AS INT);
    DECLARE @KaynakId     INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakBelgeId') AS INT);
    DECLARE @HedefBelgeId INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefBelgeId') AS INT), 0);
    DECLARE @Tarih        DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tarih') AS DATETIME);
    DECLARE @KulId        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId       INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    -- Baslik uretimi icin (bkz. sp_Api_Belge_Donusum_Baslik_Ic). Cagiran gondermezse
    --   makul varsayilan; Delphi tarafi GENINI degerlerini gonderir.
    DECLARE @Senaryo      INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Senaryo') AS INT), 1);
    DECLARE @VarsDoviz    NVARCHAR(10) = ISNULL(JSON_VALUE(@Kosullar, '$.VarsayilanDoviz'), N'TL');

    IF @DonusumTuru IS NULL                 THROW 51001, N'DonusumTuru zorunlu.', 1;
    IF @KaynakId IS NULL OR @KaynakId <= 0  THROW 51001, N'KaynakBelgeId zorunlu.', 1;
    SET @Tarih = ISNULL(@Tarih, GETDATE());

    DECLARE @KaynakTablo NVARCHAR(20), @KaynakDetay NVARCHAR(20), @KaynakBaglanti NVARCHAR(20),
            @BeklenenTur INT, @KaynakTip INT, @HedefTur INT, @HedefTablo NVARCHAR(20), @Destek INT;
    SELECT @KaynakTablo = KaynakTablo, @KaynakDetay = KaynakDetay, @KaynakBaglanti = KaynakBaglanti,
           @BeklenenTur = KaynakTur, @KaynakTip = KaynakTip, @HedefTur = HedefTur,
           @HedefTablo = HedefTablo, @Destek = Destek
    FROM dbo.fn_Api_Donusum_Esleme() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakTablo IS NULL
    BEGIN
        DECLARE @m1 NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
        THROW 51200, @m1, 1;
    END
    IF @Destek = 0
    BEGIN
        DECLARE @m2 NVARCHAR(300) = N'Bu donusum turu (' + CAST(@DonusumTuru AS nvarchar(10)) +
            N') henuz sunucu tarafinda desteklenmiyor; Belge Donusum ekranini kullanin.';
        THROW 51200, @m2, 1;
    END

    -- ---- Kaynak baslik ----
    DECLARE @Tur INT, @Tipi INT, @RehberId INT, @GirisDepo INT, @CikisDepo INT,
            @KdvDurum NVARCHAR(10), @Kur NVARCHAR(10), @DovizCins NVARCHAR(10),
            @DovizKur MONEY, @RaporDvz NVARCHAR(10), @ProjeId INT, @Vade INT,
            @SaticiKodu INT, @FiyatLst INT, @KaynakNo NVARCHAR(50);

    IF @KaynakTablo = 'SIPARIS'
        SELECT @Tur = TUR, @Tipi = ISNULL(TIPI,1), @RehberId = REHBERID,
               @GirisDepo = ISNULL(GIRISDEPO,0), @CikisDepo = ISNULL(CIKISDEPO,0),
               @KdvDurum = KDVDURUM, @Kur = KUR, @DovizCins = DOVIZ_CINSI,
               @DovizKur = ISNULL(DOVIZKUR,1), @RaporDvz = RAPORDOVIZ,
               @ProjeId = ISNULL(PROJEID,0), @Vade = ISNULL(VADE,0),
               @SaticiKodu = SATICIKODU, @FiyatLst = FIYAT_LISTESI, @KaynakNo = SIPARISNO
        FROM SIPARIS WHERE ID = @KaynakId;
    ELSE
        SELECT @Tur = TUR, @Tipi = ISNULL(TIPI,1), @RehberId = REHBERID,
               @GirisDepo = ISNULL(GIRISDEPO,0), @CikisDepo = ISNULL(CIKISDEPO,0),
               @KdvDurum = KDVDURUM, @Kur = KUR, @DovizCins = DOVIZ_CINSI,
               @DovizKur = ISNULL(DOVIZKUR,1), @RaporDvz = RAPORDOVIZ,
               @ProjeId = ISNULL(PROJEID,0), @Vade = ISNULL(VADE,0),
               @SaticiKodu = SATICIKODU, @FiyatLst = FIYAT_LISTESI, @KaynakNo = FATURANO
        FROM FATBASLIK WHERE ID = @KaynakId;

    IF @Tur IS NULL THROW 51002, N'Kaynak belge bulunamadi.', 1;
    IF @Tur <> @BeklenenTur
    BEGIN
        DECLARE @m3 NVARCHAR(300) = N'Kaynak belge turu (' + CAST(@Tur AS nvarchar(10)) +
            N') bu donusum icin beklenenle (' + CAST(@BeklenenTur AS nvarchar(10)) + N') uyusmuyor.';
        THROW 51200, @m3, 1;
    END
    IF @HedefBelgeId > 0 AND NOT EXISTS (SELECT 1 FROM FATBASLIK WHERE ID = @HedefBelgeId)
        THROW 51002, N'Hedef belge bulunamadi.', 1;

    DECLARE @BelgeNo NVARCHAR(50), @FatSeri NVARCHAR(20), @Satir INT = 0, @Loglanan INT = 0, @LogN INT;

    BEGIN TRY
        BEGIN TRAN;

        -- ---- Kaynak satirlar: KILITLE + kalan hesabi (transaction icinde) ----
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, UrunId INT, Tur INT,
                          Kalan DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
                          BirimFiyat DECIMAL(18,6), Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT,
                          Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
                          DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY,
                          Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
                          OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), Izleme INT, PozNo INT);

        DECLARE @Secili TABLE (ID INT PRIMARY KEY);
        INSERT @Secili (ID) SELECT DISTINCT CAST(value AS INT)
          FROM OPENJSON(@Kosullar, '$.SatirIds') WHERE ISNUMERIC(value) = 1;

        IF @KaynakTablo = 'SIPARIS'
            INSERT @S (SatirId, UrunId, Tur, Kalan, Miktar, Birim, BirimFiyat, Kdv, Iskonto, Iskonto2,
                       Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, Aciklama, ProjeId, MasrafId,
                       OzelKod, OzelKod2, Izleme, PozNo)
        SELECT SD.ID, SD.URUNID, ISNULL(SD.TUR,1), K.Kalan,
                   CASE WHEN ISNULL(SD.ADET,0) = 0 THEN K.Kalan
                        ELSE ROUND(ISNULL(SD.MIKTAR, SD.ADET) * K.Kalan / SD.ADET, 6) END,
                   ISNULL(SD.BIRIM,0), ISNULL(SD.BIRIMFIYAT,0), ISNULL(SD.KDV,0),
                   ISNULL(SD.ISKONTO,0), ISNULL(SD.ISKONTO2,0),
                   ISNULL(SD.KUR,N'TL'), ISNULL(SD.DOVIZ_KURU,N'TL'),
                   ISNULL(SD.DOVIZ_BIRIMFIYAT,0), ISNULL(SD.DOVIZKURDEGERI,1),
                   ISNULL(SD.ACIKLAMA,N''), ISNULL(SD.PROJEID,0), ISNULL(SD.MASRAFID,0),
                   ISNULL(SD.OZELKOD,N''), ISNULL(SD.OZELKOD2,N''), ISNULL(SD.IZLEME,0), ISNULL(SD.POZNO,0)
            FROM SIPARISDETAY SD WITH (UPDLOCK, HOLDLOCK)
                CROSS APPLY dbo.fn_Api_Donusum_Kalan(@KaynakTip, @DonusumTuru, SD.ID, 0) K
            WHERE SD.SIPARISID = @KaynakId AND K.Kalan > 0.0001
              AND (NOT EXISTS (SELECT 1 FROM @Secili) OR SD.ID IN (SELECT ID FROM @Secili));
        ELSE
            INSERT @S (SatirId, UrunId, Tur, Kalan, Miktar, Birim, BirimFiyat, Kdv, Iskonto, Iskonto2,
                       Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, Aciklama, ProjeId, MasrafId,
                       OzelKod, OzelKod2, Izleme, PozNo)
        SELECT F.ID, F.URUNID, ISNULL(F.TUR,1), K.Kalan,
                   CASE WHEN ISNULL(F.ADET,0) = 0 THEN K.Kalan
                        ELSE ROUND(ISNULL(F.MIKTAR, F.ADET) * K.Kalan / F.ADET, 6) END,
                   ISNULL(F.BIRIM,0), ISNULL(F.BIRIMFIYAT,0), ISNULL(F.KDV,0),
                   ISNULL(F.ISKONTO,0), ISNULL(F.ISKONTO2,0),
                   ISNULL(F.KUR,N'TL'), ISNULL(F.DOVIZ_KURU,N'TL'),
                   ISNULL(F.DOVIZ_BIRIMFIYAT,0), ISNULL(F.DOVIZKURDEGERI,1),
                   ISNULL(F.ACIKLAMA,N''), ISNULL(F.PROJEID,0), ISNULL(F.MASRAFID,0),
                   ISNULL(F.OZELKOD,N''), ISNULL(F.OZELKOD2,N''), ISNULL(F.IZLEME,0), ISNULL(F.POZNO,0)
            FROM FATURA F WITH (UPDLOCK, HOLDLOCK)
                CROSS APPLY dbo.fn_Api_Donusum_Kalan(@KaynakTip, @DonusumTuru, F.ID, 0) K
            WHERE F.FATBASID = @KaynakId AND K.Kalan > 0.0001
              AND (NOT EXISTS (SELECT 1 FROM @Secili) OR F.ID IN (SELECT ID FROM @Secili));

        IF NOT EXISTS (SELECT 1 FROM @S)
            THROW 51200, N'Donusturulecek kalan satir yok (belge tamamlanmis olabilir).', 1;

        DECLARE @TabKart  INT = dbo.fn_Api_Belge_TabNo(@HedefTur, 0);
        DECLARE @TabDetay INT = dbo.fn_Api_Belge_TabNo(@HedefTur, 1);

        -- ---- Hedef baslik (verilmediyse olustur) ----
        IF @HedefBelgeId = 0
        BEGIN
            DECLARE @Kocan INT = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                          WHERE TUR = @HedefTur AND SUBEID = -1
                                            AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                          ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
            DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
            INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @HedefTur, @SubeID = -1,
                                                @Kocanno = @Kocan, @BTarihi = @Tarih;
            SELECT TOP 1 @BelgeNo = BelgeNo, @FatSeri = BelgeSeri FROM @BN;

            -- Baslik uretimi TEK yerde: sp_Api_Belge_Donusum_Baslik_Ic (GenDepoUpdate87).
            --   Kolon kumesi BelgeDonustur_BaslikOlusur ile birebir; depo/doviz eslemesi
            --   fn_Api_Donusum_Esleme'den gelir. Onceki halde bu SP KENDI kucuk kolon
            --   kumesiyle yaziyordu (KOCANNO/BASLIK/ADRES/SENARYO/EFATURASONUC vb. eksikti).
            DECLARE @HedefTabloAd NVARCHAR(20);
            EXEC dbo.sp_Api_Belge_Donusum_Baslik_Ic
                 @DonusumTuru = @DonusumTuru, @KaynakBelgeId = @KaynakId, @HedefTur = @HedefTur,
                 @KocanNo = @Kocan, @BelgeNo = @BelgeNo, @BelgeSeri = @FatSeri,
                 @Senaryo = @Senaryo, @VarsayilanDoviz = @VarsDoviz,
                 @KulId = @KulId, @SubeId = @SubeId,
                 @HedefBelgeId = @HedefBelgeId OUTPUT, @HedefTablo = @HedefTabloAd OUTPUT;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @HedefBelgeId,
                 @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @HedefBelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
            SET @Loglanan = @Loglanan + @LogN;
        END
        ELSE
            SELECT @BelgeNo = FATURANO, @GirisDepo = ISNULL(GIRISDEPO,0),
                   @CikisDepo = ISNULL(CIKISDEPO,0), @RehberId = REHBERID
            FROM FATBASLIK WHERE ID = @HedefBelgeId;

        -- ---- Satirlar (YERI/YERID bagi) ----
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
            SET @Satir = @Satir + 1;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @YeniId,
                 @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @HedefBelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
            SET @Loglanan = @Loglanan + @LogN;

            FETCH NEXT FROM c INTO @SatirId;
        END
        CLOSE c; DEALLOCATE c;

        -- ---- Hedef toplamlari ----
        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkVergi MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @HedefBelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkVergi OUTPUT,
             @Neden = @TNeden OUTPUT, @Yazildi = @TYazildi OUTPUT;

        -- ---- Kaynak belgenin kapanma durumu ----
        DECLARE @KaynakAd NVARCHAR(10) = CASE WHEN @KaynakTablo = 'SIPARIS' THEN N'siparis' ELSE N'belge' END;
        DECLARE @dTur INT, @dDurum INT, @dOnce INT, @dSat INT, @dTam INT, @dKis INT,
                @dAcik INT, @dNeden NVARCHAR(60), @dYaz BIT;
        EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @KaynakId, @Kaynak = @KaynakAd,
             @Tur = @dTur OUTPUT, @Durum = @dDurum OUTPUT, @OncekiDurum = @dOnce OUTPUT,
             @Satir = @dSat OUTPUT, @Tamamlanan = @dTam OUTPUT, @Kismi = @dKis OUTPUT,
             @Acik = @dAcik OUTPUT, @Neden = @dNeden OUTPUT, @Yazildi = @dYaz OUTPUT;

        COMMIT;

        SELECT (SELECT 1 AS Sonuc, @DonusumTuru AS DonusumTuru, @KaynakId AS KaynakBelgeId,
                       @HedefBelgeId AS HedefBelgeId, @BelgeNo AS HedefBelgeNo,
                       @HedefTur AS HedefTur, @Satir AS Satir, @Loglanan AS Loglanan,
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

