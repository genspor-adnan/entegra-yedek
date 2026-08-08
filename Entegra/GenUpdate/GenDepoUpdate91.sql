-- ============================================================
-- GenDepoUpdate91.sql
-- BELGE DONUSUM - KODLAMA ADIM 4: sp_Prog_BelgeDonusum_Kaydet
--
-- Planın BaslikOlustur + SatirAktar adimlarinin BIRLESIMI. Belge uretimi icin
--   YENI NESNE YAZILMIYOR: gecici tablolardan Kaydet JSON'unu kurup kanonik
--   sp_Api_Belge_Kaydet_Json'u cagiriyor (veri sozlesmesi bolum 0).
--
-- GIRDI (cagirandan gelen gecici tablolar)
--   #DonusumKaynakBaslik, #DonusumKaynakSatir (Dogrula tarafindan doldurulmus)
-- CIKTI
--   #DonusumSatirEsleme  (kaynak satir -> hedef satir eslesmesi)
--   @HedefBaslikID OUTPUT, @BelgeNo OUTPUT, @YeniBelge OUTPUT
--
-- ROTA POLITIKASI (fn_Prog_BelgeDonusum_Rota)
--   Depo   : GirisDepoKaynak / CikisDepoKaynak - 'YOK' -> NULL,
--            'VARSAYILAN7' -> konsinye deposu (DEPOLAR.VARSAYILAN=7, ayni sube)
--   Doviz  : RAPORDOVIZ kaynaktan AYNEN kopyalanir; FATURADOVIZI'ye DovizAlani
--            ile secilen kaynak kolonu, NULL ise @VarsayilanDoviz yazilir
--   Satir  : StokDurumDegis, EkipmanSabit (415/420 -> 1), KdvMuafiyetKopyala
--            (yalniz 408/427/411/424), Carpan (420 -> -1)
--   BelgeNo: OTOMATIK -> transaction ICINDE sp_BelgeNoGetir ile tahsis edilir
--            (es zamanlilik guvenli). KULLANICI_GIRISI -> cagirandan gelir.
--
-- KAPSAM: hedefi FATBASLIK olan rotalar. Hedefi SIPARIS olan 428 rotasi
--   Destek=0 - Kaydet yalnizca FATBASLIK/FATURA yazar, SIPARIS tarafinda es
--   deger bir kanonik "kaydet" SP'si yoktur. Ikiz uretim yazmamak icin o rota
--   eski akista kaldi.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Kaydet
    @DonusumTuru     INT,
    @KullaniciID     INT,
    @SubeID          INT,
    @Tarih           DATETIME      = NULL,
    @HedefBaslikID   INT           = 0,
    @BelgeNoGiris    NVARCHAR(50)  = NULL,   -- KULLANICI_GIRISI rotalarinda
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

    -- ---------- Rota ----------
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

    -- ---------- Kaynak baslik (dogrulanmis: hepsi uyumlu) ----------
    DECLARE @BaslikId INT, @RehberId INT, @sGiris INT, @sCikis INT,
            @KdvDurum NVARCHAR(20), @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10),
            @Kur NVARCHAR(10), @DovizKur MONEY, @KaynakNo NVARCHAR(50);
    SELECT TOP 1 @BaslikId = BaslikId, @RehberId = RehberId, @sGiris = GirisDepo,
                 @sCikis = CikisDepo, @KdvDurum = KdvDurum, @RaporDoviz = RaporDoviz,
                 @FaturaDovizi = FaturaDovizi, @Kur = Kur, @DovizKur = DovizKur,
                 @KaynakNo = BelgeNo
    FROM #DonusumKaynakBaslik ORDER BY BaslikId;

    IF @BaslikId IS NULL THROW 51001, N'Kaynak baslik bilgisi yok.', 1;

    -- ---------- Depo ----------
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

    -- ---------- Doviz ----------
    --   RAPORDOVIZ kaynaktan aynen; FATURADOVIZI rota politikasina gore.
    DECLARE @FatDoviz NVARCHAR(10) =
        CASE WHEN @DovizAlani IS NULL           THEN @VarsayilanDoviz
             WHEN @DovizAlani = 'RAPORDOVIZ'    THEN @RaporDoviz
             WHEN @DovizAlani = 'FATURADOVIZI'  THEN @FaturaDovizi
             ELSE @VarsayilanDoviz END;
    SET @FatDoviz = ISNULL(NULLIF(@FatDoviz, N''), @VarsayilanDoviz);

    -- ---------- Belge numarasi ----------
    --   OTOMATIK rotalarda numara TRANSACTION ICINDE tahsis edilir; uygulamada
    --   uretilip gonderilmez (es zamanli iki donusumde numara cakismasini
    --   bitiren degisiklik - degerlendirme raporu madde 4).
    DECLARE @KocanNo INT = 0, @BelgeNo NVARCHAR(50) = @BelgeNoGiris,
            @BelgeSeri NVARCHAR(50) = @BelgeSeriGiris;

    IF @YeniBelgeOut = 1 AND @BelgeNoPolitikasi = 'OTOMATIK'
    BEGIN
        SET @KocanNo = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                WHERE TUR = @HedefTur AND SUBEID = -1
                                  AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
        DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
        INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @HedefTur, @SubeID = -1,
                                            @Kocanno = @KocanNo, @BTarihi = @Tarih;
        SELECT TOP 1 @BelgeNo = BelgeNo, @BelgeSeri = BelgeSeri FROM @BN;
    END

    -- ---------- Kaydet JSON ----------
    DECLARE @Baslik NVARCHAR(MAX);
    IF @YeniBelgeOut = 1
        SET @Baslik = (SELECT @HedefTur AS Tur, 1 AS Tipi, @RehberId AS RehberId,
                              @Tarih AS Tarih, @Tarih AS FaturaTarih,
                              @BelgeNo AS FaturaNo, @BelgeSeri AS FaturaSeri,
                              @KocanNo AS KocanNo, @Senaryo AS Senaryo,
                              0 AS EFaturaDurum, 0 AS EFaturaSonuc,      -- K3 / K4
                              @GirisDepo AS GirisDepo, @CikisDepo AS CikisDepo,
                              @KdvDurum AS KdvDurum, @Kur AS Kur,
                              @RaporDoviz AS RaporDoviz, @FatDoviz AS FaturaDovizi,
                              @DovizKur AS DovizKur, @SubeID AS SubeId,
                              LEFT(ISNULL(@KaynakNo, N'') + N' nolu belgeden', 200) AS Aciklama,
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
        -- Mevcut belgeye ekleme: baslikta YALNIZ ID gonderilir; hedef basligin
        --   hicbir alani degistirilmez (Kaydet gonderilmeyen alana dokunmaz).
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
                -- ---- donusum bagi ----
                @DonusumTuru                             AS Yeri,
                S.SatirId                                AS YerId,
                -- ---- rota politikasi ----
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
        -- SatirModu "delta": gonderilen satirlar EKLENIR, gonderilmeyenlere dokunulmaz.
        --   ("tam" mevcut belgenin gonderilmeyen satirlarini silerdi - mevcut belgeye
        --    ekleme yaparken bu YANLIS olurdu.)
        N'{"Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar + N',"SatirModu":"delta"}';

    -- ---------- Kanonik belge uretimi ----------
    DECLARE @YeniId INT;
    -- @SonucDondur = 0: Kaydet kendi sonuc setini ISTEMCIYE GONDERMESIN. Aksi
    --   halde uygulama Q.Open ile ILK result set'i (Kaydet'inkini) okur ve ana
    --   SP'nin sonucunu goremez - donusumde bos uyariya sebep olmustu.
    EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @Json, @BelgeIdOut = @YeniId OUTPUT,
         @SonucDondur = 0;

    SET @HedefBaslikOut = ISNULL(NULLIF(@YeniId, 0), @HedefBaslikID);
    IF ISNULL(@HedefBaslikOut, 0) = 0
        THROW 51200, N'Hedef belge olusturulamadi.', 1;

    SELECT @BelgeNoOut = FATURANO FROM FATBASLIK WHERE ID = @HedefBaslikOut;

    -- ---------- Satir eslesmesi ----------
    --   Hedef satirlar YERI/YERID ile kaynaga bagli; eslesme bu bagdan okunur.
    --   (Kaydet'in sonuc JSON'u da Sira->ID veriyor ama INSERT...EXEC ic ice
    --    gecmedigi icin yakalanamiyor.)
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

GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Kaydet TO gentegre_api;
GO
