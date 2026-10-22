-- ============================================================
-- Update_SQL_206.sql
-- sp_BelgeNoGetir: @Rezerve parametresi (belge numarasi KAYIT aninda atomik tahsis)
--
-- SORUN: kocanli firmalarda iki kullanici ayni anda yeni siparis/fatura/irsaliye
--   actiginda ayni numara ataniyordu. Numara belge acilirken MAX(no)+1 ile OKUNUYOR,
--   belge ise sonra kaydediliyordu -> arada ikinci kullanici ayni MAX'i goruyordu.
--
-- COZUM: program artik numarayi belge ilk kez kaydedilirken (INSERT) @Rezerve=1 ile
--   ister. @Rezerve=1 sayac yolunu (sp_Prog_SiradakiNo_Ic, GenDepoUpdate135) GENINI
--   -24121 opsiyonundan bagimsiz acar: tek UPDATE ile tahsis, tabloda varsa atla.
--   Sayac ilk kullanimda ayni WHERE ile tablodaki MAX'tan tohumlanir -> mevcut
--   numaralarla carpismaz, veri gecisi gerekmez.
--
-- @Rezerve varsayilani 0: diger cagrilar degismez. Belge donusumu (sp_Prog_BelgeDonusum_Kaydet)
--   yeni hedef belge numarasini artik @Rezerve=1 ile alir (govdesi Update_SQL_198 ile ayni,
--   yalniz o cagri degisti).
-- Sayac kapsamina kocan BASLANGICTARIHI/BASLANGICNO eklendi (donem sifirlamasi sayacta da
--   calissin). Govdenin geri kalani GenDepoUpdate136 ile ayni. Idempotent (CREATE OR ALTER); veri degismez.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_BelgeNoGetir]
(
    @IslemTur INT,
    @SubeID   INT,
    @Kocanno  INT      = 0,
    @BTarihi  DATETIME = '2000-01-01',
    @Rezerve  BIT      = 0      -- 1: numarayi SAYAC'tan atomik TAHSIS et (GENINI -24121'den bagimsiz)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BELGENO TABLE (KOCANNO INT, BELGESERI NVARCHAR(5), BELGENO NVARCHAR(20));

    DECLARE @AKocanno INT, @ABelgeseri NVARCHAR(5), @ABelgeno NVARCHAR(20), @UstTur INT,
            @Dijitsay INT, @BaslaNo NVARCHAR(25), @BasTarihi DATETIME;
    DECLARE @sqlCommand NVARCHAR(200), @NextValue INT;

    -- Sayac acik mi? (GENINI -24121)
    DECLARE @Sayac BIT = CASE WHEN ISNULL((SELECT TOP 1 DEGER FROM dbo.GENINI WHERE BOLUM = -24121), 0) = 1
                              THEN 1 ELSE 0 END;
    -- Belge kaydi (ilk INSERT) aninda cagrilir: numara o an kalici ayrilir -> iki kullanici
    --   ayni numarayi alamaz. Ekranda onizleme icin yapilan cagrilar @Rezerve=0 ile gelir.
    IF @Rezerve = 1 SET @Sayac = 1;
    DECLARE @Kapsam NVARCHAR(80), @Kosul NVARCHAR(1000), @Basla BIGINT, @Yeni BIGINT;
    -- Cekirdek OUTPUT parametreli cagrilir: "INSERT ... EXEC" ic ice olamaz.
    DECLARE @SonNo BIGINT, @NoStr NVARCHAR(40);

    SET @Dijitsay = 0;

    SELECT @UstTur = CASE
        WHEN @IslemTur IN (21,22,23,24,25,26,27,28,29,88,130,141,142) THEN -101
        WHEN @IslemTur IN (31,32,33,34,35,36,37,38,98,125,131,137,140) THEN -102
        WHEN @IslemTur IN (40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
                           132,133,134,135,136,138,139,143,144,145,146,147,148,149) THEN -103
        ELSE @IslemTur END;

    IF @Kocanno IN (0, -99)
        SET @AKocanno = (SELECT TOP 1 KOCANNO FROM KOCANAYARLARI WHERE SUBEID = @SubeID AND TUR = @UstTur);
    ELSE
        SET @AKocanno = @Kocanno;

    ----------------------------------------------------------------- -3333: ID tabanli (degismedi)
    IF @AKocanno = -3333
    BEGIN
        SET @ABelgeseri = '';
        IF @UstTur IN (3, 4, 6, 8, 10, 11, 12, 14, 15, 16, 20, 39, 110, 116, 119, 222)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM FATBASLIK;
        ELSE IF @UstTur IN (9, 19, 101, 105)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM SIPARIS;
        ELSE IF @UstTur = 83
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM SERVIS;
        ELSE IF @UstTur IN (80, 81)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM TEKLIF;
        ELSE IF @UstTur = 250
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM DOKUMAN;
        ELSE
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM KASA;
    END
    ELSE IF @AKocanno <> 0
    BEGIN
        SELECT @ABelgeseri = SERINO, @BaslaNo = BASLANGICNO, @Dijitsay = LEN(BASLANGICNO),
               @BasTarihi = BASLANGICTARIHI
          FROM KOCANAYARLARI
         WHERE SUBEID = @SubeID AND TUR = @UstTur AND KOCANNO = @AKocanno;

        SET @Basla  = ISNULL(TRY_CAST(@BaslaNo AS BIGINT), 1);
        -- Kapsama kocanin baslangic tarihi/numarasi da girer: kocan yeni yil/donem icin
        --   yeniden ayarlaninca (BASLANGICTARIHI/BASLANGICNO degisir) yeni sayac acilir ve
        --   eski davranistaki gibi o tarihten sonraki MAX'tan (yoksa BASLANGICNO'dan) baslar.
        SET @Kapsam = N'T' + CAST(@UstTur AS NVARCHAR(10)) + N'|K' + CAST(@AKocanno AS NVARCHAR(10)) +
                      N'|D' + CONVERT(NVARCHAR(8), ISNULL(@BasTarihi, '19000101'), 112) +
                      N'|B' + ISNULL(@BaslaNo, N'');
        -- Tarih suzgeci sayaca da GECER: tohumlama eski davranisla ayni MAX'i bulsun.
        DECLARE @TrhLit NVARCHAR(30) = N'''' + CONVERT(NVARCHAR(23), ISNULL(@BasTarihi, '19000101'), 126) + N'''';

        ------------------------------------------------------------- FATBASLIK
        IF @UstTur IN (3, 4, 6, 8, 10, 11, 12, 14, 15, 16, 20, 39, 110, 116, 119, 222)
        BEGIN
            SET @Kosul = N'FATURATARIH >= ' + @TrhLit + N' AND TUR = ' + CAST(@UstTur AS NVARCHAR(10)) +
                         N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) + N' AND ISNUMERIC(FATURANO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'FATBASLIK', 'FATURANO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), FATURANO)) + 1)
                                          FROM FATBASLIK
                                         WHERE FATURATARIH >= @BasTarihi AND TUR = @UstTur
                                           AND KOCANNO = @AKocanno AND ISNUMERIC(FATURANO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- SIPARIS
        ELSE IF @UstTur IN (9, 19, 101, 105)
        BEGIN
            SET @Kosul = N'SIPARISTARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(SIPARISNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'SIPARIS', 'SIPARISNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), SIPARISNO)) + 1)
                                          FROM SIPARIS
                                         WHERE SIPARISTARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(SIPARISNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- SERVIS
        ELSE IF @UstTur = 83
        BEGIN
            SET @Kosul = N'TARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(SERVISNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'SERVIS', 'SERVISNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), SERVISNO)) + 1)
                                          FROM SERVIS
                                         WHERE TARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(SERVISNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- TEKLIF
        ELSE IF @UstTur IN (80, 81)
        BEGIN
            SET @Kosul = N'TARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(TEKLIFNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'TEKLIF', 'TEKLIFNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), TEKLIFNO)) + 1)
                                          FROM TEKLIF
                                         WHERE TARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(TEKLIFNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- URETIM EMRI
        ELSE IF @UstTur = 166
        BEGIN
            SET @Kosul = N'TALEPTARIHI >= ' + @TrhLit + N' AND ISNUMERIC(EMIRNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'URETIMEMRI', 'EMIRNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), EMIRNO)) + 1)
                                          FROM URETIMEMRI
                                         WHERE TALEPTARIHI >= @BasTarihi AND ISNUMERIC(EMIRNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- DOKUMAN
        ELSE IF @UstTur = 250
        BEGIN
            SET @Kosul = N'EKLEMETARIHI >= ' + @TrhLit + N' AND ISNUMERIC(BELGENO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'DOKUMAN', 'BELGENO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), BELGENO)) + 1)
                                          FROM DOKUMAN
                                         WHERE EKLEMETARIHI >= @BasTarihi AND ISNUMERIC(BELGENO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- KASA/CEK/SENET: SEQUENCE (zaten atomik)
        ELSE IF @UstTur IN (-103, -102, -101)
        BEGIN
            SET @sqlCommand = N'select @NextValue = NEXT VALUE FOR dbo.seq_' + CONVERT(NVARCHAR(20), @AKocanno);
            EXECUTE sp_executesql @sqlCommand, N'@AKocanno int, @NextValue int OUTPUT',
                    @AKocanno = @AKocanno, @NextValue = @NextValue OUTPUT;
            SET @ABelgeno = CONVERT(NVARCHAR(20), @NextValue);
        END
    END

    WHILE LEN(@ABelgeno) < @Dijitsay
        SET @ABelgeno = '0' + @ABelgeno;

    INSERT INTO @BELGENO (KOCANNO, BELGESERI, BELGENO)
    VALUES (@AKocanno, @ABelgeseri, @ABelgeno);

    SELECT * FROM @BELGENO;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_BelgeNoGetir TO gentegre_api;
GO

-- ---- sp_Prog_BelgeDonusum_Kaydet: hedef belge numarasi @Rezerve=1 ile -----------------
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
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Kaydet TO gentegre_api;
GO
