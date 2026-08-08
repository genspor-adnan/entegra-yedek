-- ============================================================
-- GenDepoUpdate89.sql
-- BelgeDonustur_* yardimcilarinin tamami sunucuya:
--   fn_Api_Donusum_Esleme      : + DetayTablo / DepoAlani / BelgeTipi kolonlari
--   fn_Api_Donusum_TipBul      : (kaynak belge TUR, belge tipi) -> donusum turu
--   sp_Api_Belge_Donusum_Ayar_Json  : BelgeDonustur_BilgiAyarlari karsiligi
--   sp_Api_Belge_Donusum_Satir_Ic / _Json : BelgeDonustur_DetaySatirOlustur karsiligi
--
-- GenDepoUpdate87/88 basligi sunucuya almisti; bu dosya kalan uc yardimciyi aliyor.
-- Boylece donusum bilgisi TEK KAYNAKTAN (fn_Api_Donusum_Esleme) geliyor; Pascal'daki
--   ayni case bloklarinin uc kopyasi (BaslikOlusur / BilgiAyarlari / DonusTipiBul)
--   ve elle SQL string birlestirme + MSSQL/PG dallanmasi kalkiyor.
--
-- SATIR OLUSTURMA - Pascal ile birebir kurallar:
--   STOKDURUMDEGIS : iki kez stoktan dusmemek icin bazi donusumlerde 0
--                    (giden konsinye irsaliye, teklif->siparis, irs->fat/fis, talep->siparis)
--   TUTAR          : (100 - isnull(ISKONTO2,0)) * (100 - ISKONTO) * Adet * BIRIMFIYAT / 10000
--   DOVIZ_TUTARI   : ayni formul, DOVIZ_BIRIMFIYAT ile
--   YERI/YERID     : donusum turu + kaynak satir ID (donusum bagi)
--   EKIPMANID      : uretim hedefinde (415/420) sabit 1, digerlerinde kaynaktan
--   KDVMUHAFIYETI  : yalniz irsaliye->fatura/fis donusumlerinde (408/427/411/424)
--   EN/BOY/YUZEY/SAYI : yalniz "en-boy hesaplama" opsiyonu acikken (cagirandan gelir)
--   TESLIMTARIHI   : yalniz SIPARISDETAY hedefinde
--   STOKIZLEME     : kaynak FATBASLIK ve satir izlemeli ise seri/lot satirlari hedefe
--                    tasinir, kaynagin KALAN'i sifirlanir, STOKIZLEMEDEPO satiri acilir
--   URETIM RECETE  : 415'te (uretime urun) recetedeki sarf satirlari da eklenir
--
-- KAPSAM DISI: TEKLIFDETAY kaynagi (teklif->siparis 412/413). Pascal'daki eski yol kalir.
--   NOT: eski Pascal kodu 412/413'te satiri FATURA'ya yaziyordu (hedef SIPARIS olmasina
--   ragmen) - mevcut bir tutarsizlik, burada tekrarlanmadi.
--
-- GIRDI : {"DonusumTuru":409,"HedefBaslikId":114061,"KaynakBaslikId":23201,
--          "KaynakSatirId":157989,"Adet":7,"Birim":1,"Miktar":7,"Izleme":0,
--          "EnBoy":0,"VarsayilanDoviz":"TL","DovizKurDegeri":1,
--          "Oturum":{"KulId":5,"SubeId":-1}}
-- CIKTI : {"Sonuc":1,"SatirId":3557600,"HedefDetayTablo":"FATURA","Izlem":0,"Sarf":0}
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- Esleme tablosu genisletildi:
--   DetayTablo : hedef detay tablosu (FATURA / SIPARISDETAY)
--   DepoAlani  : BelgeDonustur_BilgiAyarlari.depoalani (kaynak depo alani adi)
--   BelgeTipi  : BelgeDonustur_DonusTipiBul girdisi (menuden gelen "belge tipi").
--                Ayni (KaynakTur, BelgeTipi) ciftinin tek bir donusum turu olmali.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Api_Donusum_Esleme ()
RETURNS TABLE
AS
RETURN
(
    SELECT E.DonusumTuru, E.KaynakTablo, E.KaynakDetay, E.KaynakBaglanti, E.KaynakTur, E.KaynakTip,
           E.HedefTur, E.HedefTablo, E.Destek, E.GirisKaynak, E.CikisKaynak, E.KaynakDovizAlan,
           E.EfatSonuc, E.DepoAlani,
           DetayTablo = CASE WHEN E.HedefTablo = 'SIPARIS' THEN 'SIPARISDETAY' ELSE 'FATURA' END,
           -- Iki kez stoktan dusmesin diye: bu donusumlerde hedef satir stok hareketi yapmaz.
           StokDurumDegis = CASE WHEN E.DonusumTuru IN (468, 412, 413, 408, 427, 411, 424, 428)
                                 THEN 0 ELSE 1 END,
           -- KDV muafiyeti yalniz irsaliye -> fatura/fis donusumlerinde kopyalanir.
           KdvMuafiyetKopyala = CASE WHEN E.DonusumTuru IN (408, 427, 411, 424) THEN 1 ELSE 0 END,
           -- Uretim hedefinde satir EKIPMANID'si sabit 1.
           EkipmanSabit = CASE WHEN E.DonusumTuru IN (415, 420) THEN 1 ELSE 0 END
    FROM (VALUES
        (406, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  10, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',   0, 'GIRISDEPO'),
        (407, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  11, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO'),
        (478, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  12, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO'),
        (409, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  14, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',   0, 'CIKISDEPO'),
        (410, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  15, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,          20, 'CIKISDEPO'),
        (473, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  16, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'CIKISDEPO'),
        (429, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2, 119, 'FATBASLIK', 1, 'VARSAYILAN7', 'CIKISDEPO', NULL,           0, 'CIKISDEPO'),
        (408, 'FATBASLIK', 'FATURA',       'FATBASID',  10, 3,  11, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI', 0, 'GIRISDEPO'),
        (427, 'FATBASLIK', 'FATURA',       'FATBASID',  10, 3,  12, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI', 0, 'GIRISDEPO'),
        (411, 'FATBASLIK', 'FATURA',       'FATBASID',  14, 3,  15, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI',20, 'CIKISDEPO'),
        (424, 'FATBASLIK', 'FATURA',       'FATBASID',  14, 3,  16, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI',20, 'CIKISDEPO'),
        (461, 'FATBASLIK', 'FATURA',       'FATBASID', 109, 3,  11, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO'),
        (469, 'FATBASLIK', 'FATURA',       'FATBASID', 109, 3,  10, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO'),
        (462, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  15, 'FATBASLIK', 1, 'YOK',         'GIRISDEPO', NULL,           0, 'CIKISDEPO'),
        (468, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  14, 'FATBASLIK', 1, 'YOK',         'GIRISDEPO', NULL,           0, 'CIKISDEPO'),
        (472, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  16, 'FATBASLIK', 1, 'YOK',         'GIRISDEPO', NULL,           0, 'CIKISDEPO'),
        (414, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  20, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'CIKISDEPO'),
        (435, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',105, 2,  20, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'CIKISDEPO'),
        (412, 'TEKLIF',    'TEKLIFDETAY',  'TEKLIFID',  99, 1,   9, 'SIPARIS',   0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO'),
        (413, 'TEKLIF',    'TEKLIFDETAY',  'TEKLIFID',  99, 1,  19, 'SIPARIS',   0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO'),
        (428, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',105, 2,   9, 'SIPARIS',   0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO'),
        (415, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,   6, 'FATBASLIK', 0, 'CIKISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',   0, 'GIRISDEPO'),
        (420, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,   6, 'FATBASLIK', 0, 'CIKISDEPO',   'CIKISDEPO', NULL,           0, 'CIKISDEPO'),
        (425, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  14, 'FATBASLIK', 0, 'YOK',         'CIKISDEPO', 'FATURADOVIZI', 0, 'GIRISDEPO'),
        (426, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  15, 'FATBASLIK', 0, 'YOK',         'CIKISDEPO', 'FATURADOVIZI', 0, 'GIRISDEPO'),
        (431, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  16, 'FATBASLIK', 0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0, 'GIRISDEPO')
    ) AS E(DonusumTuru, KaynakTablo, KaynakDetay, KaynakBaglanti, KaynakTur, KaynakTip,
           HedefTur, HedefTablo, Destek, GirisKaynak, CikisKaynak, KaynakDovizAlan, EfatSonuc, DepoAlani)
);
GO

-- ============================================================
-- fn_Api_Donusum_TipBul : BelgeDonustur_DonusTipiBul karsiligi.
--   "belgetipi" menuden gelen hedef secimi; cogunlukla hedef belge TUR'u ile ayni,
--   birkac ekranda kisayol kodu (1 = irsaliye, 2 = fatura, 0 = konsinye).
--   Eslesme yoksa NULL doner -> cagiran eski davranisi (Abort) uygular.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Api_Donusum_TipBul (@KaynakTur INT, @BelgeTipi INT)
RETURNS INT
AS
BEGIN
    -- Once dogrudan hedef TUR eslesmesi (belgetipi = hedef belge turu)
    DECLARE @R INT = (SELECT TOP 1 DonusumTuru FROM dbo.fn_Api_Donusum_Esleme()
                       WHERE KaynakTur = @KaynakTur AND HedefTur = @BelgeTipi
                       ORDER BY DonusumTuru);
    IF @R IS NOT NULL RETURN @R;

    -- Kisayol kodlari (Pascal'daki ozel dallar)
    RETURN CASE
        WHEN @KaynakTur = 105 AND @BelgeTipi = 9 THEN 428   -- satinalma talebi -> siparis
        WHEN @KaynakTur = 109                    THEN 461   -- gelen konsinye -> fatura
        WHEN @KaynakTur = 119 AND @BelgeTipi = 2 THEN 462   -- giden konsinye -> fatura
        WHEN @KaynakTur = 119                    THEN 468   -- giden konsinye -> irsaliye
        WHEN @KaynakTur =   9 AND @BelgeTipi = 1 THEN 406   -- alis siparisi -> irsaliye
        WHEN @KaynakTur =  19 AND @BelgeTipi = 1 THEN 409   -- satis siparisi -> irsaliye
        WHEN @KaynakTur =  19 AND @BelgeTipi = 0 THEN 429   -- satis siparisi -> konsinye
        WHEN @KaynakTur =  10 AND @BelgeTipi = 2 THEN 408   -- alis irsaliyesi -> fatura
        WHEN @KaynakTur =  14 AND @BelgeTipi = 2 THEN 411   -- satis irsaliyesi -> fatura
        ELSE NULL END;
END
GO

-- ============================================================
-- sp_Api_Belge_Donusum_Ayar_Json : BelgeDonustur_BilgiAyarlari + DonusTipiBul.
--   DonusumTuru verilirse ayarlari, verilmezse (KaynakTur, BelgeTipi) ile once
--   donusum turunu bulur.
-- CIKTI: {"Sonuc":1,"DonusumTuru":409,"BaslikTablo":"SIPARIS","DetayTablo":"SIPARISDETAY",
--         "HedefTablo":"FATBASLIK","HedefDetayTablo":"FATURA","HedefTur":14,
--         "DepoAlani":"CIKISDEPO","Destek":1}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Donusum_Ayar_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DT        INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru') AS INT);
    DECLARE @KaynakTur INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakTur')   AS INT);
    DECLARE @BelgeTipi INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeTipi')   AS INT);

    IF @DT IS NULL AND @KaynakTur IS NOT NULL
        SET @DT = dbo.fn_Api_Donusum_TipBul(@KaynakTur, ISNULL(@BelgeTipi, 0));

    IF @DT IS NULL
        THROW 51001, N'DonusumTuru ya da (KaynakTur, BelgeTipi) zorunlu.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.fn_Api_Donusum_Esleme() WHERE DonusumTuru = @DT)
    BEGIN
        DECLARE @m NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DT AS nvarchar(10));
        THROW 51200, @m, 1;
    END

    SELECT (SELECT 1 AS Sonuc, E.DonusumTuru, BaslikTablo = E.KaynakTablo,
                   DetayTablo = E.KaynakDetay, E.HedefTablo, HedefDetayTablo = E.DetayTablo,
                   E.HedefTur, E.DepoAlani, E.Destek
            FROM dbo.fn_Api_Donusum_Esleme() E WHERE E.DonusumTuru = @DT
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ============================================================
-- sp_Api_Belge_Donusum_Satir_Ic : hedef DETAY satiri olusturur (+ seri/lot tasima,
--   + uretim recete sarflari). BelgeDonustur_DetaySatirOlustur ile birebir.
--
--   Kolon listesi kosullu oldugu icin (EN/BOY, KDVMUHAFIYETI, hedef tablo) tek
--   dinamik cumle kurulur. Tablo/kolon adlari SABIT LISTEDEN (fn_Api_Donusum_Esleme)
--   gelir - cagirandan gelen metin SQL'e girmez; degerler parametreli gider.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Donusum_Satir_Ic
    @DonusumTuru     INT,
    @HedefBaslikId   INT,
    @KaynakBaslikId  INT,
    @KaynakSatirId   INT,
    @Adet            DECIMAL(18,6),
    @Birim           DECIMAL(18,6),
    @Miktar          DECIMAL(18,6),
    @Izleme          INT           = -1,
    @EnBoy           BIT           = 0,
    @VarsayilanDoviz NVARCHAR(10)  = N'TL',
    @DovizKurDegeri  DECIMAL(18,6) = 1,
    @KulId           INT           = 0,
    @SubeId          INT           = -1,
    @SatirId         INT           OUTPUT,
    @IzlemSayi       INT           OUTPUT,
    @SarfSayi        INT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KaynakDetay NVARCHAR(20), @HedefDetay NVARCHAR(20), @KaynakTablo NVARCHAR(20),
            @StokDurumDegis INT, @KdvMuaf INT, @EkipmanSabit INT;
    SELECT @KaynakDetay = KaynakDetay, @HedefDetay = DetayTablo, @KaynakTablo = KaynakTablo,
           @StokDurumDegis = StokDurumDegis, @KdvMuaf = KdvMuafiyetKopyala,
           @EkipmanSabit = EkipmanSabit
    FROM dbo.fn_Api_Donusum_Esleme() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakDetay IS NULL
    BEGIN
        DECLARE @m1 NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
        THROW 51200, @m1, 1;
    END
    IF @KaynakDetay = 'TEKLIFDETAY'
        THROW 51200, N'Teklif kaynagi bu SP ile desteklenmiyor (kolon kumesi farkli).', 1;

    SET @IzlemSayi = 0;
    SET @SarfSayi  = 0;

    -- ---- Hedef detay satiri ----
    DECLARE @Kol NVARCHAR(MAX), @Val NVARCHAR(MAX), @Sql NVARCHAR(MAX);
    DECLARE @Baglanti NVARCHAR(20) = CASE WHEN @HedefDetay = 'SIPARISDETAY' THEN N'SIPARISID' ELSE N'FATBASID' END;
    DECLARE @Ekipman  NVARCHAR(30) = CASE WHEN @EkipmanSabit = 1 THEN N'1' ELSE N'K.EKIPMANID' END;

    SET @Kol = @Baglanti + N',REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,'
             + N'ISKONTO,KDV,OTVYUZDE,OTVMIKTAR,MASRAFID,OZELKOD,OZELKOD2,MUHKODU,KASA,EKLEYEN,KUR,'
             + N'IZLEMEKODU,DOVIZ_TUTARI,DOVIZ_KURU,ISKONTO2,IZLEME,MF,YERI,YERID,DOVIZ_BIRIMFIYAT,'
             + N'DOVIZKURDEGERI,VADE,KAMPANYAID,PROJEID,EKIPMANID,SUBEID';
    SET @Val = N'@pHedef,K.REHBERID,K.TUR,K.URUNID,K.ACIKLAMA,@pAdet,@pBirim,@pMiktar,K.BIRIMFIYAT,'
             + N'(100.0-ISNULL(K.ISKONTO2,0.0))*(100.0-K.ISKONTO)*@pAdet*K.BIRIMFIYAT/10000.0,'
             + N'K.ISKONTO,K.KDV,K.OTVYUZDE,K.OTVMIKTAR,K.MASRAFID,K.OZELKOD,K.OZELKOD2,K.MUHKODU,K.KASA,@pKul,K.KUR,'
             + N'K.IZLEMEKODU,(100.0-ISNULL(K.ISKONTO2,0.0))*(100.0-K.ISKONTO)*@pAdet*K.DOVIZ_BIRIMFIYAT/10000.0,'
             + N'K.DOVIZ_KURU,K.ISKONTO2,K.IZLEME,K.MF,@pDT,@pSatir,K.DOVIZ_BIRIMFIYAT,'
             + N'K.DOVIZKURDEGERI,K.VADE,K.KAMPANYAID,K.PROJEID,' + @Ekipman + N',K.SUBEID';

    IF @HedefDetay = 'SIPARISDETAY'
    BEGIN
        SET @Kol = @Kol + N',TESLIMTARIHI';
        SET @Val = @Val + N',K.TESLIMTARIHI';
    END
    ELSE
    BEGIN
        SET @Kol = @Kol + N',POZNO,STOKDURUMDEGIS';
        SET @Val = @Val + N',K.POZNO,@pSDD';
    END

    IF @EnBoy = 1
    BEGIN
        SET @Kol = @Kol + N',EN,BOY,YUZEY,SAYI';
        SET @Val = @Val + N',K.EN,K.BOY,K.YUZEY,K.SAYI';
    END
    IF @KdvMuaf = 1
    BEGIN
        SET @Kol = @Kol + N',KDVMUHAFIYETI';
        SET @Val = @Val + N',K.KDVMUHAFIYETI';
    END

    SET @Sql = N'INSERT INTO ' + QUOTENAME(@HedefDetay) + N' (' + @Kol + N') SELECT ' + @Val
             + N' FROM ' + QUOTENAME(@KaynakDetay) + N' K WHERE K.ID = @pSatir; SET @pYeni = CAST(SCOPE_IDENTITY() AS INT);';

    EXEC sp_executesql @Sql,
         N'@pHedef INT, @pAdet DECIMAL(18,6), @pBirim DECIMAL(18,6), @pMiktar DECIMAL(18,6),
           @pKul INT, @pDT INT, @pSatir INT, @pSDD INT, @pYeni INT OUTPUT',
         @pHedef = @HedefBaslikId, @pAdet = @Adet, @pBirim = @Birim, @pMiktar = @Miktar,
         @pKul = @KulId, @pDT = @DonusumTuru, @pSatir = @KaynakSatirId,
         @pSDD = @StokDurumDegis, @pYeni = @SatirId OUTPUT;

    IF @SatirId IS NULL THROW 51002, N'Kaynak detay satiri bulunamadi.', 1;

    -- ---- Seri/lot (STOKIZLEME) tasima: yalniz kaynak FATBASLIK ve satir izlemeli ise ----
    IF @Izleme > 0 AND @KaynakTablo = 'FATBASLIK'
    BEGIN
        DECLARE @HedefTur2 INT, @GirDepo INT, @CikDepo INT;
        SELECT @HedefTur2 = TUR, @GirDepo = GIRISDEPO, @CikDepo = CIKISDEPO
        FROM FATBASLIK WHERE ID = @HedefBaslikId;

        -- Cikis nitelikli belgelerde depo CIKISDEPO, digerlerinde GIRISDEPO (Pascal ile ayni)
        DECLARE @DepoId INT = CASE WHEN @HedefTur2 IN (4, 15, 16, 14, 119, 99) THEN @CikDepo ELSE @GirDepo END;

        DECLARE @Izlem TABLE (EskiId INT PRIMARY KEY, Kalan DECIMAL(18,6), YeniId INT NULL);
        INSERT @Izlem (EskiId, Kalan)
        SELECT ID, KALAN FROM STOKIZLEME
        WHERE BASLIKID = @KaynakBaslikId AND SATIRID = @KaynakSatirId;

        DECLARE @EskiId INT, @YeniIzlem INT;
        DECLARE ci CURSOR LOCAL FAST_FORWARD FOR SELECT EskiId FROM @Izlem ORDER BY EskiId;
        OPEN ci; FETCH NEXT FROM ci INTO @EskiId;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR, ADET, KALAN,
                                    YER, YERID, DONUSID, SERILOTID, EKLEYEN)
            SELECT SI.STOKID, @HedefTur2, @HedefBaslikId, @SatirId, SI.IZLEMTUR, SI.KALAN, SI.KALAN,
                   SI.YER, 0, SI.ID, SI.SERILOTID, @KulId
            FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SI.SERILOTID = SSL.ID
            WHERE SI.ID = @EskiId;

            SET @YeniIzlem = CAST(SCOPE_IDENTITY() AS INT);
            IF @YeniIzlem IS NOT NULL
            BEGIN
                INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@YeniIzlem, @DepoId, 0);
                UPDATE STOKIZLEME SET KALAN = 0 WHERE ID = @EskiId;   -- donustu -> kalan sifir
                SET @IzlemSayi = @IzlemSayi + 1;
            END
            FETCH NEXT FROM ci INTO @EskiId;
        END
        CLOSE ci; DEALLOCATE ci;
    END

    -- ---- Uretime URUN olarak eklendiyse (415) recetedeki sarf satirlarini da ekle ----
    IF @DonusumTuru = 415
    BEGIN
        DECLARE @UrunId INT = (SELECT URUNID FROM FATURA WHERE ID = @SatirId);
        DECLARE @ReceteId INT = (SELECT TOP 1 ID FROM URETIMRECETE WHERE STOKID = @UrunId ORDER BY ID);
        IF @ReceteId IS NOT NULL
        BEGIN
            INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, ACIKLAMA, ADET, BIRIM, MIKTAR,
                                BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV,
                                DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT, DOVIZKURDEGERI,
                                MASRAFID, IZLEME, STOKDURUMDEGIS, SUBEID, EKLEYEN, YERI, YERID, EKIPMANID)
            SELECT @HedefBaslikId, 0, URD.TUR, URD.URUNID, URD.ACIKLAMA, URD.ADET * @Miktar,
                   URD.BIRIM, URD.MIKTAR * @Miktar, URD.MALIYETSON, URD.MALIYETORT, @VarsayilanDoviz,
                   0, 0, S.KDV,
                   URD.MALIYETORT / NULLIF(@DovizKurDegeri, 0), @VarsayilanDoviz,
                   URD.MALIYETSON / NULLIF(@DovizKurDegeri, 0), @DovizKurDegeri,
                   URD.MASRAFID, S.IZLEME, 1, @SubeId, @KulId, 461001, URD.ID,
                   CASE WHEN URD.MIKTAR > 0.0 THEN 1 ELSE -1 END
            FROM URETIMRECETEDETAY URD INNER JOIN STOKLAR S ON URD.URUNID = S.ID
            WHERE URD.URUNID <> @UrunId AND URD.URETIMRECETEID = @ReceteId;
            SET @SarfSayi = @@ROWCOUNT;
        END
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Donusum_Satir_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DT      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru')    AS INT);
    DECLARE @Hedef   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefBaslikId')  AS INT);
    DECLARE @KBaslik INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakBaslikId') AS INT);
    DECLARE @KSatir  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakSatirId')  AS INT);
    DECLARE @Adet    DECIMAL(18,6) = TRY_CAST(JSON_VALUE(@Kosullar, '$.Adet')   AS DECIMAL(18,6));
    DECLARE @Birim   DECIMAL(18,6) = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Birim')  AS DECIMAL(18,6)), 0);
    DECLARE @Miktar  DECIMAL(18,6) = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Miktar') AS DECIMAL(18,6)), 0);
    DECLARE @Izleme  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Izleme') AS INT), -1);
    DECLARE @EnBoy   BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.EnBoy')  AS BIT), 0);
    DECLARE @VDoviz  NVARCHAR(10)  = ISNULL(JSON_VALUE(@Kosullar, '$.VarsayilanDoviz'), N'TL');
    DECLARE @DKur    DECIMAL(18,6) = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.DovizKurDegeri') AS DECIMAL(18,6)), 1);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @DT IS NULL OR @Hedef IS NULL OR @KSatir IS NULL OR @Adet IS NULL
        THROW 51001, N'DonusumTuru, HedefBaslikId, KaynakSatirId ve Adet zorunlu.', 1;

    DECLARE @SatirId INT, @IzlemSayi INT, @SarfSayi INT;
    EXEC dbo.sp_Api_Belge_Donusum_Satir_Ic
         @DonusumTuru = @DT, @HedefBaslikId = @Hedef, @KaynakBaslikId = @KBaslik,
         @KaynakSatirId = @KSatir, @Adet = @Adet, @Birim = @Birim, @Miktar = @Miktar,
         @Izleme = @Izleme, @EnBoy = @EnBoy, @VarsayilanDoviz = @VDoviz,
         @DovizKurDegeri = @DKur, @KulId = @KulId, @SubeId = @SubeId,
         @SatirId = @SatirId OUTPUT, @IzlemSayi = @IzlemSayi OUTPUT, @SarfSayi = @SarfSayi OUTPUT;

    DECLARE @HedefDetay NVARCHAR(20) = (SELECT DetayTablo FROM dbo.fn_Api_Donusum_Esleme() WHERE DonusumTuru = @DT);

    SELECT (SELECT 1 AS Sonuc, @SatirId AS SatirId, @HedefDetay AS HedefDetayTablo,
                   @IzlemSayi AS Izlem, @SarfSayi AS Sarf
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

GRANT EXECUTE ON dbo.sp_Api_Belge_Donusum_Ayar_Json  TO gentegre_api;
GRANT EXECUTE ON dbo.sp_Api_Belge_Donusum_Satir_Json TO gentegre_api;
GO
