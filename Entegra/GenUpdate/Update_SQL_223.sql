/*
  Update_SQL_223 - Belge donusumunde EN/BOY/YUZEY/SAYI hedef satira gecer

  Kullanici (05.11.2026): sipariste girilen en-boy-m2 irsaliyeye donusturulunce
  0 geliyordu. Donusum sp_Prog_BelgeDonusum_Kaydet -> sp_Api_Belge_Kaydet_Json
  hattiyla yazar; bu hat EN/BOY/YUZEY/SAYI tasimiyordu (eski Delphi donusumu
  Utablo'da EnBoyHesaplamaAktif ile tasiyordu).

  Kolonlar opsiyoneldir (Opsiyon > En/Boy hesaplama; her DB'de yok): hedef FATURA
  ve kaynak detay tablosunda (SIPARISDETAY / FATURA) dordu de varsa dinamik SQL
  ile kopyalanir, yoksa hicbir sey yapilmaz.
  YUZEY = birim m2 (EN*BOY/1e6), ADET = YUZEY*SAYI (USiparisWizard). Kismi
  donusumde SAYI = ADET / YUZEY olarak yeniden hesaplanir; tam donusumde
  kaynak SAYI aynen gecer.

  Yordam govdesi Update_SQL_206 ile ayni; yalniz sondaki EN/BOY blogu eklendi.
  Tekrar calistirilabilir. Var olan belgelere dokunmaz (yalniz yeni donusumler).
*/
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Kaydet
    @DonusumTuru     INT,
    @KullaniciID     INT,
    @SubeID          INT,
    @Tarih           DATETIME      = NULL,
    @HedefBaslikID   INT           = 0,
    @BelgeNoGiris    NVARCHAR(50)  = NULL,
    @BelgeSeriGiris  NVARCHAR(50)  = NULL,
    @VarsayilanDoviz NVARCHAR(10)  = N'TL',
    @Senaryo         INT           = 1,
    @HedefBaslikOut  INT           OUTPUT,
    @BelgeNoOut      NVARCHAR(50)  OUTPUT,
    @YeniBelgeOut    BIT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Tarih        = ISNULL(@Tarih, GETDATE());
    SET @YeniBelgeOut = CASE WHEN @HedefBaslikID > 0 THEN 0 ELSE 1 END;

    DECLARE @HedefTur INT, @HedefBaslikTablo NVARCHAR(20), @GirisKaynak NVARCHAR(20),
            @CikisKaynak NVARCHAR(20), @DovizAlani NVARCHAR(20), @StokDurumDegis INT,
            @KdvMuaf INT, @EkipmanSabit INT, @Carpan INT, @BelgeNoPolitikasi NVARCHAR(20),
            @KaynakBaslikTablo NVARCHAR(20);
    SELECT @HedefTur = HedefTur, @HedefBaslikTablo = HedefBaslikTablo,
           @GirisKaynak = GirisDepoKaynak, @CikisKaynak = CikisDepoKaynak,
           @DovizAlani = DovizAlani, @StokDurumDegis = StokDurumDegis,
           @KdvMuaf = KdvMuafiyetKopyala, @EkipmanSabit = EkipmanSabit, @Carpan = Carpan,
           @BelgeNoPolitikasi = BelgeNoPolitikasi, @KaynakBaslikTablo = KaynakBaslikTablo
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @HedefTur IS NULL
        THROW 51200, N'Bilinmeyen donusum turu.', 1;
    IF @HedefBaslikTablo <> 'FATBASLIK'
        THROW 51200, N'Bu donusumun hedefi FATBASLIK degil - Kaydet yolu kullanilamaz.', 1;

    DECLARE @BaslikId INT, @RehberId INT, @sGiris INT, @sCikis INT,
            @KdvDurum NVARCHAR(20), @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10),
            @Kur NVARCHAR(10), @DovizKur MONEY, @KaynakNo NVARCHAR(50);
    SELECT TOP 1 @BaslikId = BaslikId, @RehberId = RehberId, @sGiris = GirisDepo,
                 @sCikis = CikisDepo, @KdvDurum = KdvDurum, @RaporDoviz = RaporDoviz,
                 @FaturaDovizi = FaturaDovizi, @Kur = Kur, @DovizKur = DovizKur,
                 @KaynakNo = BelgeNo
    FROM #DonusumKaynakBaslik ORDER BY BaslikId;

    IF @BaslikId IS NULL THROW 51001, N'Kaynak baslik bilgisi yok.', 1;

    DECLARE @GirisDepo INT = CASE @GirisKaynak
                                  WHEN 'GIRISDEPO'   THEN @sGiris
                                  WHEN 'CIKISDEPO'   THEN @sCikis
                                  WHEN 'VARSAYILAN7' THEN (SELECT TOP 1 ID FROM DEPOLAR
                                                            WHERE DURUM = 1 AND VARSAYILAN = 7
                                                              AND SUBEID = @SubeID)
                                  ELSE NULL END;
    DECLARE @CikisDepo INT = CASE @CikisKaynak
                                  WHEN 'GIRISDEPO' THEN @sGiris
                                  WHEN 'CIKISDEPO' THEN @sCikis
                                  ELSE NULL END;

    DECLARE @FatDoviz NVARCHAR(10) =
        CASE WHEN @DovizAlani IS NULL           THEN @VarsayilanDoviz
             WHEN @DovizAlani = 'RAPORDOVIZ'    THEN @RaporDoviz
             WHEN @DovizAlani = 'FATURADOVIZI'  THEN @FaturaDovizi
             ELSE @VarsayilanDoviz END;
    SET @FatDoviz = ISNULL(NULLIF(@FatDoviz, N''), @VarsayilanDoviz);

    DECLARE @KocanNo INT = 0, @BelgeNo NVARCHAR(50) = @BelgeNoGiris,
            @BelgeSeri NVARCHAR(50) = @BelgeSeriGiris;

    IF @YeniBelgeOut = 1 AND @BelgeNoPolitikasi = 'OTOMATIK'
    BEGIN
        SET @KocanNo = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                WHERE TUR = @HedefTur AND SUBEID = -1
                                  AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
        DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
        -- @Rezerve=1 (Update_SQL_206): numara koçandan atomik ayrilir, es zamanli
        --   donusumler ayni numarayi alamaz.
        INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @HedefTur, @SubeID = -1,
                                            @Kocanno = @KocanNo, @BTarihi = @Tarih, @Rezerve = 1;
        SELECT TOP 1 @BelgeNo = BelgeNo, @BelgeSeri = BelgeSeri FROM @BN;
    END

    DECLARE @Baslik NVARCHAR(MAX);
    IF @YeniBelgeOut = 1
        SET @Baslik = (SELECT @HedefTur AS Tur, 1 AS Tipi, @RehberId AS RehberId,
                              @Tarih AS Tarih, @Tarih AS FaturaTarih,
                              @BelgeNo AS FaturaNo, @BelgeSeri AS FaturaSeri,
                              @KocanNo AS KocanNo, @Senaryo AS Senaryo,
                              0 AS EFaturaDurum, 0 AS EFaturaSonuc,
                              @GirisDepo AS GirisDepo, @CikisDepo AS CikisDepo,
                              @KdvDurum AS KdvDurum, @Kur AS Kur,
                              @RaporDoviz AS RaporDoviz, @FatDoviz AS FaturaDovizi,
                              @DovizKur AS DovizKur, @SubeID AS SubeId,
                              N'' AS Aciklama,   -- kaynak belge no artik NOT 1'e yazilmaz (Kaynak alani gosterir)
                              K.AKTIVITEID AS AktiviteId, K.REHBERILETID AS RehberIletId,
                              K.SERVISID AS ServisId, K.DETAYBOLUMU AS DetayBolumu,
                              K.SATICIKODU AS SaticiKodu, K.PROJEID AS ProjeId,
                              K.VADE AS Vade, K.FIYAT_LISTESI AS FiyatListesi,
                              K.BASLIK AS Unvan, K.ADRES AS Adres, K.ILCE AS Ilce,
                              K.IL AS Il, K.VD AS Vd, K.VNO AS Vno, K.OZELKOD AS OzelKod
                       FROM (SELECT AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
                                    PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO, OZELKOD
                             FROM SIPARIS WHERE ID = @BaslikId AND @KaynakBaslikTablo = 'SIPARIS'
                             UNION ALL
                             SELECT AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
                                    PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO, OZELKOD
                             FROM FATBASLIK WHERE ID = @BaslikId AND @KaynakBaslikTablo = 'FATBASLIK') K
                       FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);
    ELSE
        SET @Baslik = (SELECT @HedefBaslikID AS ID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    DECLARE @Satirlar NVARCHAR(MAX) =
        (SELECT S.Sira                                   AS Sira,
                S.UrunId                                 AS UrunId,
                S.SatirTur                               AS Tur,
                S.IstenenAdet   * @Carpan                AS Adet,
                S.IstenenMiktar * @Carpan                AS Miktar,
                S.Birim                                  AS Birim,
                S.BirimFiyat                             AS BirimFiyat,
                S.Kdv                                    AS Kdv,
                S.Iskonto                                AS Iskonto,
                S.Iskonto2                               AS Iskonto2,
                S.Kur                                    AS Kur,
                S.DovizKuru                              AS DovizKuru,
                S.DovizBirimFiyat                        AS DovizBirimFiyat,
                S.DovizKurDegeri                         AS DovizKurDegeri,
                S.Aciklama                               AS Aciklama,
                S.ProjeId                                AS ProjeId,
                S.MasrafId                               AS MasrafId,
                S.OzelKod                                AS OzelKod,
                S.OzelKod2                               AS OzelKod2,
                S.Izleme                                 AS Izleme,
                @DonusumTuru                             AS Yeri,
                S.SatirId                                AS YerId,
                @StokDurumDegis                          AS StokDurumDegis,
                CASE WHEN @EkipmanSabit = 1 THEN 1 ELSE S.EkipmanId END AS EkipmanId,
                CASE WHEN @KdvMuaf = 1 THEN S.KdvMuafiyeti ELSE NULL END AS KdvMuafiyeti,
                S.PozNo                                  AS PozNo,
                S.Mf                                     AS Mf,
                S.MuhKodu                                AS MuhKodu,
                S.Kasa                                   AS Kasa,
                S.OtvYuzde                               AS OtvYuzde,
                S.OtvMiktar                              AS OtvMiktar,
                S.IzlemeKodu                             AS IzlemeKodu,
                S.Vade                                   AS Vade,
                S.KampanyaId                             AS KampanyaId
         FROM #DonusumKaynakSatir S
         WHERE ISNULL(S.Durum, N'') = N'uygun'
         ORDER BY S.Sira
         FOR JSON PATH);

    IF @Satirlar IS NULL THROW 51200, N'Yazilacak uygun satir yok.', 1;

    DECLARE @Json NVARCHAR(MAX) =
        N'{"Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar + N',"SatirModu":"delta"}';

    DECLARE @YeniId INT;
    EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @Json, @BelgeIdOut = @YeniId OUTPUT,
         @SonucDondur = 0;

    SET @HedefBaslikOut = ISNULL(NULLIF(@YeniId, 0), @HedefBaslikID);
    IF ISNULL(@HedefBaslikOut, 0) = 0
        THROW 51200, N'Hedef belge olusturulamadi.', 1;

    IF @YeniBelgeOut = 1 AND @KaynakBaslikTablo = 'SIPARIS'
    BEGIN
        UPDATE FB
           SET ANAKAYITID = S.ANAKAYITID
          FROM FATBASLIK FB
               INNER JOIN SIPARIS S ON S.ID = @BaslikId
         WHERE FB.ID = @HedefBaslikOut
           AND ISNULL(S.ANAKAYITID, 0) > 0;
    END

    -- Update193: kaynak belgenin alttaki aciklamasi (Not 1) yeni hedef belgeye gecsin.
    IF @YeniBelgeOut = 1
    BEGIN
        DECLARE @KaynakAciklama NVARCHAR(600) =
            CASE WHEN @KaynakBaslikTablo = 'SIPARIS'
                 THEN (SELECT ACIKLAMA FROM SIPARIS   WHERE ID = @BaslikId)
                 WHEN @KaynakBaslikTablo = 'FATBASLIK'
                 THEN (SELECT ACIKLAMA FROM FATBASLIK WHERE ID = @BaslikId)
                 ELSE NULL END;
        IF LTRIM(RTRIM(ISNULL(@KaynakAciklama, N''))) <> N''
            UPDATE FATBASLIK SET ACIKLAMA = LEFT(@KaynakAciklama, 300)
             WHERE ID = @HedefBaslikOut;
    END

    -- Update198: kaynak belgenin EK ALANLARI (<KaynakTablo>_USER) yeni hedefin FATBASLIK_USER'ina.
    IF @YeniBelgeOut = 1
    BEGIN
        DECLARE @KaynakUser SYSNAME = @KaynakBaslikTablo + N'_USER';
        IF OBJECT_ID(N'dbo.' + @KaynakUser) IS NOT NULL AND OBJECT_ID(N'dbo.FATBASLIK_USER') IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM FATBASLIK_USER WHERE ID = @HedefBaslikOut)
        BEGIN
            DECLARE @Kolonlar NVARCHAR(MAX) =
                STUFF((SELECT N', ' + QUOTENAME(H.name)
                       FROM sys.columns H
                            INNER JOIN sys.columns K ON K.object_id = OBJECT_ID(N'dbo.' + @KaynakUser)
                                                     AND K.name = H.name
                       WHERE H.object_id = OBJECT_ID(N'dbo.FATBASLIK_USER')
                         AND H.is_identity = 0 AND H.is_computed = 0
                         AND H.name NOT IN (N'ID', N'EKLEYEN', N'EKLEMETARIHI', N'DEGISTIREN', N'DEGISTIRMETARIHI')
                       ORDER BY H.column_id
                       FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, N'');
            IF @Kolonlar IS NOT NULL
            BEGIN
                DECLARE @EkSql NVARCHAR(MAX) =
                    N'INSERT INTO dbo.FATBASLIK_USER (ID, ' + @Kolonlar +
                    CASE WHEN COL_LENGTH(N'dbo.FATBASLIK_USER', N'EKLEYEN') IS NOT NULL THEN N', EKLEYEN' ELSE N'' END +
                    CASE WHEN COL_LENGTH(N'dbo.FATBASLIK_USER', N'EKLEMETARIHI') IS NOT NULL THEN N', EKLEMETARIHI' ELSE N'' END +
                    N') SELECT @Hedef, ' + @Kolonlar +
                    CASE WHEN COL_LENGTH(N'dbo.FATBASLIK_USER', N'EKLEYEN') IS NOT NULL THEN N', @Kul' ELSE N'' END +
                    CASE WHEN COL_LENGTH(N'dbo.FATBASLIK_USER', N'EKLEMETARIHI') IS NOT NULL THEN N', GETDATE()' ELSE N'' END +
                    N' FROM dbo.' + QUOTENAME(@KaynakUser) + N' WHERE ID = @Kaynak';
                EXEC sp_executesql @EkSql, N'@Hedef INT, @Kaynak INT, @Kul INT',
                     @Hedef = @HedefBaslikOut, @Kaynak = @BaslikId, @Kul = @KullaniciID;
            END
        END
    END

    SELECT @BelgeNoOut = FATURANO FROM FATBASLIK WHERE ID = @HedefBaslikOut;

    INSERT #DonusumSatirEsleme (Sira, KaynakBaslikId, KaynakSatirId, HedefSatirId,
                                DonusenAdet, KalanAdet)
    SELECT S.Sira, S.BaslikId, S.SatirId, F.ID,
           S.IstenenAdet, S.KalanAdet - S.IstenenAdet
    FROM #DonusumKaynakSatir S
         INNER JOIN FATURA F ON F.FATBASID = @HedefBaslikOut
                            AND F.YERI  = @DonusumTuru
                            AND F.YERID = S.SatirId
    WHERE ISNULL(S.Durum, N'') = N'uygun';

    -- Update223: kaynak satirin EN/BOY/YUZEY/SAYI'si hedef satira (kolonlar opsiyonel).
    DECLARE @KaynakDetay SYSNAME =
        CASE WHEN @KaynakBaslikTablo = 'SIPARIS' THEN N'SIPARISDETAY' ELSE N'FATURA' END;
    IF COL_LENGTH(N'dbo.FATURA', N'EN') IS NOT NULL AND COL_LENGTH(N'dbo.FATURA', N'BOY') IS NOT NULL
       AND COL_LENGTH(N'dbo.FATURA', N'YUZEY') IS NOT NULL AND COL_LENGTH(N'dbo.FATURA', N'SAYI') IS NOT NULL
       AND COL_LENGTH(N'dbo.' + @KaynakDetay, N'EN') IS NOT NULL
       AND COL_LENGTH(N'dbo.' + @KaynakDetay, N'BOY') IS NOT NULL
       AND COL_LENGTH(N'dbo.' + @KaynakDetay, N'YUZEY') IS NOT NULL
       AND COL_LENGTH(N'dbo.' + @KaynakDetay, N'SAYI') IS NOT NULL
    BEGIN
        DECLARE @EnBoySql NVARCHAR(MAX) = N'
        UPDATE H
           SET EN = K.EN, BOY = K.BOY, YUZEY = K.YUZEY,
               SAYI = CASE WHEN ABS(ISNULL(H.ADET,0)) = ABS(ISNULL(K.ADET,0)) OR ISNULL(K.YUZEY,0) = 0
                           THEN K.SAYI
                           ELSE ABS(H.ADET) / K.YUZEY END
          FROM #DonusumSatirEsleme E
               INNER JOIN dbo.FATURA H ON H.ID = E.HedefSatirId AND H.FATBASID = @Hedef
               INNER JOIN dbo.' + QUOTENAME(@KaynakDetay) + N' K ON K.ID = E.KaynakSatirId
         WHERE ISNULL(K.EN,0) <> 0 OR ISNULL(K.BOY,0) <> 0 OR ISNULL(K.YUZEY,0) <> 0 OR ISNULL(K.SAYI,0) <> 0;';
        EXEC sp_executesql @EnBoySql, N'@Hedef INT', @Hedef = @HedefBaslikOut;
    END
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Kaydet TO gentegre_api;
GO
