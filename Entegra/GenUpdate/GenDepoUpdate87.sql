-- ============================================================
-- GenDepoUpdate87.sql
-- sp_Api_Belge_Donusum_Baslik_Json : donusumde HEDEF BASLIK olusturma
--   + fn_Api_Donusum_Esleme genisletildi (depo / doviz / e-fatura sonuc eslemesi)
--
-- NEDEN: TTablo.BelgeDonustur (Belge Donusum ekrani, sag tus donusumleri, teklif/
--   servis/uretim/stok talep yollari) basligi hala Pascal'da elle string birlestirerek
--   olusturuyordu: BelgeDonustur_BaslikOlusur. Yeni sp_Api_Belge_Donusum_Json ise
--   KENDI kucuk kolon kumesiyle basligi yaziyordu. Iki farkli baslik uretimi vardi ve
--   SP tarafi eksikti: KOCANNO, BASLIK/ADRES/ILCE/IL/VD/VNO, AKTIVITEID, REHBERILETID,
--   SERVISID, DETAYBOLUMU, OZELKOD, EFATURADURUM/EFATURASONUC, SENARYO yazilmiyordu.
--   Kullanici siparisten irsaliye donusumu yapinca eski yol calisti (beklenen).
--
-- IS BOLUMU (bilincli):
--   Pascal'da KALAN: kocan numarasi (oturum kaydi kocannumaralari), belge no/seri
--     (SiradakiBelgeNumarasi + e-Fatura ozel durumu TUR=15), varsayilan senaryo ve
--     varsayilan doviz (GENINI). Bunlar oturum/opsiyon verisi, SP'de yok.
--   SP'ye GECEN: INSERT'un kendisi + donusum turune gore depo ve doviz eslemesi
--     (BelgeDonustur_BaslikOlusur'daki case bloklarinin birebir karsiligi) + ISLEMLOG.
--
-- Boylece baslik uretimi TEK yerde toplaniyor; sp_Api_Belge_Donusum_Json da ayni
--   ic yordami cagiriyor (GenDepoUpdate88'de baglanacak degil - bu dosyada yapiliyor).
--
-- GIRDI : {"DonusumTuru":409,"KaynakBelgeId":23201,"HedefTur":14,
--          "KocanNo":3,"BelgeNo":"104151","BelgeSeri":"","Senaryo":1,
--          "VarsayilanDoviz":"TL","Oturum":{"KulId":5,"SubeId":-1}}
-- CIKTI : {"Sonuc":1,"HedefBelgeId":114060,"HedefTablo":"FATBASLIK","Loglanan":1}
-- HATA  : 51001 girdi, 51002 kaynak bulunamadi, 51200 bilinmeyen donusum turu
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- Esleme tablosu: BelgeDonustur_BaslikOlusur'daki depo/doviz case bloklari eklendi.
--   GirisKaynak/CikisKaynak : hedefin GIRISDEPO/CIKISDEPO kolonuna kaynagin HANGI
--     kolonundan deger gelecegi. 'VARSAYILAN7' = konsinye deposu (DEPOLAR.VARSAYILAN=7).
--   KaynakDovizAlan : hedefin RAPORDOVIZ'ine kaynagin hangi kolonu yazilacak;
--     NULL ise cagirandan gelen VarsayilanDoviz (GENINI) kullanilir.
--   EfatSonuc : yeni belgenin EFATURASONUC baslangic degeri (satista 20).
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Api_Donusum_Esleme ()
RETURNS TABLE
AS
RETURN
(
    SELECT DonusumTuru, KaynakTablo, KaynakDetay, KaynakBaglanti, KaynakTur, KaynakTip,
           HedefTur, HedefTablo, Destek, GirisKaynak, CikisKaynak, KaynakDovizAlan, EfatSonuc
    FROM (VALUES
        -- alis siparisi -> irsaliye / fatura / fis
        (406, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  10, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',   0),
        (407, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  11, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        (478, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  12, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        -- satis siparisi -> irsaliye / fatura / fis / giden konsinye
        (409, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  14, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',   0),
        (410, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  15, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,          20),
        (473, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  16, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        (429, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2, 119, 'FATBASLIK', 1, 'VARSAYILAN7', 'CIKISDEPO', NULL,           0),
        -- alis irsaliyesi -> fatura / fis
        (408, 'FATBASLIK', 'FATURA',       'FATBASID',  10, 3,  11, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI', 0),
        (427, 'FATBASLIK', 'FATURA',       'FATBASID',  10, 3,  12, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI', 0),
        -- satis irsaliyesi -> fatura / fis
        (411, 'FATBASLIK', 'FATURA',       'FATBASID',  14, 3,  15, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI',20),
        (424, 'FATBASLIK', 'FATURA',       'FATBASID',  14, 3,  16, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', 'FATURADOVIZI',20),
        -- gelen konsinye -> fatura / irsaliye
        (461, 'FATBASLIK', 'FATURA',       'FATBASID', 109, 3,  11, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        (469, 'FATBASLIK', 'FATURA',       'FATBASID', 109, 3,  10, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        -- giden konsinye -> fatura / irsaliye / fis  (kaynagin GIRISDEPO'su hedefin CIKISDEPO'su)
        (462, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  15, 'FATBASLIK', 1, 'YOK',         'GIRISDEPO', NULL,           0),
        (468, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  14, 'FATBASLIK', 1, 'YOK',         'GIRISDEPO', NULL,           0),
        (472, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  16, 'FATBASLIK', 1, 'YOK',         'GIRISDEPO', NULL,           0),
        -- stok transferi
        (414, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  20, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        (435, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',105, 2,  20, 'FATBASLIK', 1, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        -- ---- tam donusumu SP desteklemiyor (Destek=0) ama BASLIK uretimi destekli ----
        (412, 'TEKLIF',    'TEKLIFDETAY',  'TEKLIFID',  99, 1,   9, 'SIPARIS',   0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        (413, 'TEKLIF',    'TEKLIFDETAY',  'TEKLIFID',  99, 1,  19, 'SIPARIS',   0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        (428, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',105, 2,   9, 'SIPARIS',   0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0),
        (415, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,   6, 'FATBASLIK', 0, 'CIKISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',   0),
        (420, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,   6, 'FATBASLIK', 0, 'CIKISDEPO',   'CIKISDEPO', NULL,           0),
        (425, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  14, 'FATBASLIK', 0, 'YOK',         'CIKISDEPO', 'FATURADOVIZI', 0),
        (426, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  15, 'FATBASLIK', 0, 'YOK',         'CIKISDEPO', 'FATURADOVIZI', 0),
        (431, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  16, 'FATBASLIK', 0, 'GIRISDEPO',   'CIKISDEPO', NULL,           0)
    ) AS E(DonusumTuru, KaynakTablo, KaynakDetay, KaynakBaglanti, KaynakTur, KaynakTip,
           HedefTur, HedefTablo, Destek, GirisKaynak, CikisKaynak, KaynakDovizAlan, EfatSonuc)
);
GO

-- ============================================================
-- Ic yordam: hedef baslik INSERT'i. Hem sp_Api_Belge_Donusum_Baslik_Json
--   (Pascal/BelgeDonustur yolu) hem sp_Api_Belge_Donusum_Json bunu cagirir.
--   Kolon kumesi BelgeDonustur_BaslikOlusur ile BIREBIR.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Donusum_Baslik_Ic
    @DonusumTuru    INT,
    @KaynakBelgeId  INT,
    @HedefTur       INT,
    @KocanNo        INT           = 0,
    @BelgeNo        NVARCHAR(50)  = N'',
    @BelgeSeri      NVARCHAR(50)  = N'',
    @Senaryo        INT           = 1,
    @VarsayilanDoviz NVARCHAR(10) = N'TL',
    @KulId          INT           = 0,
    @SubeId         INT           = -1,
    @HedefBelgeId   INT           OUTPUT,
    @HedefTablo     NVARCHAR(20)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @KaynakTablo NVARCHAR(20), @GirisKaynak NVARCHAR(20), @CikisKaynak NVARCHAR(20),
            @DovizAlan NVARCHAR(20), @EfatSonuc INT;
    SELECT @KaynakTablo = KaynakTablo, @HedefTablo = HedefTablo, @GirisKaynak = GirisKaynak,
           @CikisKaynak = CikisKaynak, @DovizAlan = KaynakDovizAlan, @EfatSonuc = EfatSonuc
    FROM dbo.fn_Api_Donusum_Esleme() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakTablo IS NULL
    BEGIN
        DECLARE @m1 NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
        THROW 51200, @m1, 1;
    END

    -- Depo degerleri: esleme tablosuna gore kaynagin ilgili kolonundan.
    --   'YOK' -> NULL, 'VARSAYILAN7' -> konsinye deposu (DEPOLAR.VARSAYILAN=7, ayni sube).
    DECLARE @GirisDepo INT, @CikisDepo INT, @sGiris INT, @sCikis INT;
    -- TEKLIF kaynagi KAPSAM DISI: TEKLIF tablosunda AKTIVITEID/GIRISDEPO/CIKISDEPO/
    --   BASLIK/ADRES/ILCE/IL/VD/VNO/SATICIKODU kolonlari YOK (dogrulandi). Teklif->siparis
    --   (412/413) Pascal'daki eski yolda kalir.
    IF @KaynakTablo = 'TEKLIF'
        THROW 51200, N'Teklif kaynagi bu SP ile desteklenmiyor (kolon kumesi farkli).', 1;

    IF @KaynakTablo = 'SIPARIS'
        SELECT @sGiris = GIRISDEPO, @sCikis = CIKISDEPO FROM SIPARIS WHERE ID = @KaynakBelgeId;
    ELSE
        SELECT @sGiris = GIRISDEPO, @sCikis = CIKISDEPO FROM FATBASLIK WHERE ID = @KaynakBelgeId;

    SET @GirisDepo = CASE @GirisKaynak WHEN 'GIRISDEPO' THEN @sGiris WHEN 'CIKISDEPO' THEN @sCikis
                          WHEN 'VARSAYILAN7' THEN (SELECT TOP 1 ID FROM DEPOLAR
                                                    WHERE DURUM = 1 AND VARSAYILAN = 7 AND SUBEID = @SubeId)
                          ELSE NULL END;
    SET @CikisDepo = CASE @CikisKaynak WHEN 'GIRISDEPO' THEN @sGiris WHEN 'CIKISDEPO' THEN @sCikis
                          ELSE NULL END;

    IF @HedefTablo = 'SIPARIS'
    BEGIN
        INSERT INTO SIPARIS (TUR, TIPI, REHBERID, PROJEID, AKTIVITEID, SIPARISTARIH, TARIH,
                             KOCANNO, SIPARISNO, ACIKLAMA, GIRISDEPO, CIKISDEPO, BASLIK, ADRES,
                             ILCE, IL, VD, VNO, KDVDURUM, SATICIKODU, DURUM, EKLEYEN, SIPARISSERI,
                             FIYAT_LISTESI, VADE, DOVIZKUR, DOVIZ_CINSI, KUR, REHBERILETID,
                             SUBEID, SERVISID, OZELKOD)
        SELECT @HedefTur, 1, K.REHBERID, K.PROJEID, K.AKTIVITEID, GETDATE(), GETDATE(),
               @KocanNo, @BelgeNo, K.ACIKLAMA, @GirisDepo, @CikisDepo, K.BASLIK, K.ADRES,
               K.ILCE, K.IL, K.VD, K.VNO, K.KDVDURUM, K.SATICIKODU, K.DURUM, @KulId, @BelgeSeri,
               K.FIYAT_LISTESI, K.VADE, K.DOVIZKUR, @VarsayilanDoviz, K.KUR, K.REHBERILETID,
               K.SUBEID, K.SERVISID, K.OZELKOD
        FROM SIPARIS K WHERE K.ID = @KaynakBelgeId;
    END
    ELSE
    BEGIN
        -- Doviz eslemesi - BelgeDonustur_BaslikOlusur ile BIREBIR:
        --   hedefin RAPORDOVIZ'i kaynaktan AYNEN kopyalanir,
        --   hedefin FATURADOVIZI'sine esleme sonucu (@FatDoviz) yazilir.
        --   Esleme NULL ise cagirandan gelen varsayilan doviz (GENINI) kullanilir.
        DECLARE @FatDoviz NVARCHAR(10);
        IF @DovizAlan IS NULL
            SET @FatDoviz = @VarsayilanDoviz;
        ELSE IF @KaynakTablo = 'SIPARIS'
            SELECT @FatDoviz = RAPORDOVIZ FROM SIPARIS WHERE ID = @KaynakBelgeId;
        ELSE
            SELECT @FatDoviz = CASE WHEN @DovizAlan = 'FATURADOVIZI' THEN FATURADOVIZI ELSE RAPORDOVIZ END
              FROM FATBASLIK WHERE ID = @KaynakBelgeId;

        IF @KaynakTablo = 'SIPARIS'
            INSERT INTO FATBASLIK (TUR, TIPI, REHBERID, PROJEID, AKTIVITEID, FATURATARIH, TARIH,
                                   KOCANNO, FATURANO, ACIKLAMA, GIRISDEPO, CIKISDEPO, BASLIK, ADRES,
                                   ILCE, IL, VD, VNO, KDVDURUM, SATICIKODU, DURUM, EKLEYEN, FATURASERI,
                                   FIYAT_LISTESI, VADE, DOVIZKUR, DOVIZ_CINSI, RAPORDOVIZ, FATURADOVIZI,
                                   KUR, REHBERILETID, SUBEID, EFATURADURUM, EFATURASONUC, SENARYO,
                                   SERVISID, DETAYBOLUMU, OZELKOD)
            SELECT @HedefTur, 1, K.REHBERID, K.PROJEID, K.AKTIVITEID, GETDATE(), GETDATE(),
                   @KocanNo, @BelgeNo, K.ACIKLAMA, @GirisDepo, @CikisDepo, K.BASLIK, K.ADRES,
                   K.ILCE, K.IL, K.VD, K.VNO, K.KDVDURUM, K.SATICIKODU, K.DURUM, @KulId, @BelgeSeri,
                   K.FIYAT_LISTESI, K.VADE, K.DOVIZKUR, K.DOVIZ_CINSI, K.RAPORDOVIZ, @FatDoviz,
                   K.KUR, K.REHBERILETID, K.SUBEID, 0, @EfatSonuc, @Senaryo,
                   K.SERVISID, K.DETAYBOLUMU, K.OZELKOD
            FROM SIPARIS K WHERE K.ID = @KaynakBelgeId;
        ELSE
            INSERT INTO FATBASLIK (TUR, TIPI, REHBERID, PROJEID, AKTIVITEID, FATURATARIH, TARIH,
                                   KOCANNO, FATURANO, ACIKLAMA, GIRISDEPO, CIKISDEPO, BASLIK, ADRES,
                                   ILCE, IL, VD, VNO, KDVDURUM, SATICIKODU, DURUM, EKLEYEN, FATURASERI,
                                   FIYAT_LISTESI, VADE, DOVIZKUR, DOVIZ_CINSI, RAPORDOVIZ, FATURADOVIZI,
                                   KUR, REHBERILETID, SUBEID, EFATURADURUM, EFATURASONUC, SENARYO,
                                   SERVISID, DETAYBOLUMU, OZELKOD)
            SELECT @HedefTur, 1, K.REHBERID, K.PROJEID, K.AKTIVITEID, GETDATE(), GETDATE(),
                   @KocanNo, @BelgeNo, K.ACIKLAMA, @GirisDepo, @CikisDepo, K.BASLIK, K.ADRES,
                   K.ILCE, K.IL, K.VD, K.VNO, K.KDVDURUM, K.SATICIKODU, K.DURUM, @KulId, @BelgeSeri,
                   K.FIYAT_LISTESI, K.VADE, K.DOVIZKUR, K.DOVIZ_CINSI, K.RAPORDOVIZ, @FatDoviz,
                   K.KUR, K.REHBERILETID, K.SUBEID, 0, @EfatSonuc, @Senaryo,
                   K.SERVISID, K.DETAYBOLUMU, K.OZELKOD
            FROM FATBASLIK K WHERE K.ID = @KaynakBelgeId;
    END

    SET @HedefBelgeId = CAST(SCOPE_IDENTITY() AS INT);
    IF @HedefBelgeId IS NULL THROW 51002, N'Kaynak belge bulunamadi.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Donusum_Baslik_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DonusumTuru INT          = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru')  AS INT);
    DECLARE @KaynakId    INT          = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakBelgeId') AS INT);
    DECLARE @HedefTur    INT          = TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefTur')     AS INT);
    DECLARE @KocanNo     INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KocanNo') AS INT), 0);
    DECLARE @BelgeNo     NVARCHAR(50) = ISNULL(JSON_VALUE(@Kosullar, '$.BelgeNo'),   N'');
    DECLARE @BelgeSeri   NVARCHAR(50) = ISNULL(JSON_VALUE(@Kosullar, '$.BelgeSeri'), N'');
    DECLARE @Senaryo     INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Senaryo') AS INT), 1);
    DECLARE @VarsDoviz   NVARCHAR(10) = ISNULL(JSON_VALUE(@Kosullar, '$.VarsayilanDoviz'), N'TL');
    DECLARE @KulId       INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId      INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @DonusumTuru IS NULL                THROW 51001, N'DonusumTuru zorunlu.', 1;
    IF @KaynakId IS NULL OR @KaynakId <= 0 THROW 51001, N'KaynakBelgeId zorunlu.', 1;
    IF @HedefTur IS NULL                   THROW 51001, N'HedefTur zorunlu.', 1;

    DECLARE @HedefBelgeId INT, @HedefTablo NVARCHAR(20), @Loglanan INT = 0, @LogN INT;

    EXEC dbo.sp_Api_Belge_Donusum_Baslik_Ic
         @DonusumTuru = @DonusumTuru, @KaynakBelgeId = @KaynakId, @HedefTur = @HedefTur,
         @KocanNo = @KocanNo, @BelgeNo = @BelgeNo, @BelgeSeri = @BelgeSeri,
         @Senaryo = @Senaryo, @VarsayilanDoviz = @VarsDoviz,
         @KulId = @KulId, @SubeId = @SubeId,
         @HedefBelgeId = @HedefBelgeId OUTPUT, @HedefTablo = @HedefTablo OUTPUT;

    -- ISLEMLOG: kart EKLEME. Hedef SIPARIS ise kart TabNo'su siparis kartina denk gelir.
    IF @HedefTablo = 'FATBASLIK'
    BEGIN
        DECLARE @TabKart INT = dbo.fn_Api_Belge_TabNo(@HedefTur, 0);
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @HedefBelgeId,
             @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @HedefBelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
        SET @Loglanan = @Loglanan + @LogN;
    END

    SELECT (SELECT 1 AS Sonuc, @HedefBelgeId AS HedefBelgeId, @HedefTablo AS HedefTablo,
                   @Loglanan AS Loglanan
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

GRANT EXECUTE ON dbo.sp_Api_Belge_Donusum_Baslik_Json TO gentegre_api;
GO
