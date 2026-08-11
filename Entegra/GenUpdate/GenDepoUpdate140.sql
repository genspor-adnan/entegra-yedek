-- ============================================================
-- GenDepoUpdate140.sql
-- BELGE KLONLAMA -> KAYDET API'SI UZERINDEN (sp_Api_Belge_Klonla_Json)
--
-- ESKI YOL (Utablo.BelgeKopyala): FATBASLIK ve FATURA satirlari
--   SQLSatiriKopyala ile HAM olarak klonlaniyordu. Sorunlari:
--     * Hangi alanin sifirlanacagi elle listelenmis (FATURATARIH, YERI, YERID,
--       FATURANO, KOCANNO, EFATURADURUM, MUHAKTAR, ZARFID...). Tabloya kolon
--       eklenince kopyaya SESSIZCE tasiniyor (or. yeni bir e-belge alani).
--     * Kaydet API'sinin yaptigi isler ATLANIYORDU: toplam hesabi, durum,
--       ISLEMLOG kaydi, ek alan/stok kurallari. Klon "yariM" bir belge oluyordu.
--     * Transaction yok: baslik kopyalanip satir kopyasi patlarsa satirsiz belge.
--
-- YENI YOL: kaynaktan JSON uretilir ve sp_Api_Belge_Kaydet_Json cagrilir.
--   Yani klon, ELDEN girilmis yeni belge ile AYNI kod yolundan gecer:
--   belge no (kocan/sayac), toplamlar, loglama, ek alanlar - hepsi tek yerde.
--
-- KLONA TASINMAYANLAR (bilerek):
--   YERI/YERID  : donusum bagi - klon yeni/bagimsiz belgedir
--   FATURANO/SERI/KOCANNO : yeni numara Kaydet icinde uretilir
--   EFATURADURUM/SONUC, ZARFID : e-belge gecmisi kopyalanmaz
--   SERVISID, ANAKAYITID : kaynak kayit baglari
--   IZLEME (lot/seri) : satirda izlem varsa klonlama ENGELLENIR (asagida)
--
-- KAPSAM: FATBASLIK tabanli belgeler (fatura/irsaliye/fis/konsinye/tahakkuk).
--   Siparis (TUR 9/19/101) ayri kaydet API'si kullanir - sonraki adim.
--
-- GIRDI : {"KaynakId":123,"Tarih":"2026-08-10","RehberId":null,"Oturum":{...}}
-- CIKTI : {"Sonuc":1,"KaynakId":123,"BelgeId":456,"BelgeNo":"...","Satir":n}
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Klonla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KaynakId INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakId') AS INT);
    DECLARE @Tarih    DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tarih')    AS DATETIME);
    DECLARE @RehberId INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT);
    DECLARE @KulId    INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @KaynakId IS NULL OR @KaynakId <= 0
        THROW 51001, N'KaynakId zorunlu.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.FATBASLIK WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak belge bulunamadi.', 1;

    SET @Tarih = ISNULL(@Tarih, GETDATE());

    DECLARE @Tur INT = (SELECT TUR FROM dbo.FATBASLIK WHERE ID = @KaynakId);

    -- Lot/seri izlemli satir varsa klonlanmaz: klon yeni stok hareketi uretir,
    --   kaynagin lot/serisi ikinci kez cikamaz. (Ayni kural eskiden UI'daydi.)
    IF EXISTS (SELECT 1 FROM dbo.FATURA WHERE FATBASID = @KaynakId AND ISNULL(IZLEME, 0) <> 0)
        THROW 51200, N'Belge içeriğinde izlem bilgisi aktif ürünler var, bu işlem gerçekleştirilemez.', 1;

    ------------------------------------------------------------------ BASLIK
    DECLARE @Baslik NVARCHAR(MAX) =
    (
        SELECT
            Tur            = FB.TUR,
            Tipi           = FB.TIPI,
            Tarih          = CONVERT(NVARCHAR(19), @Tarih, 126),
            FaturaTarih    = CONVERT(NVARCHAR(19), @Tarih, 126),
            RehberId       = ISNULL(@RehberId, FB.REHBERID),
            GirisDepo      = FB.GIRISDEPO,
            CikisDepo      = FB.CIKISDEPO,
            KdvDurum       = FB.KDVDURUM,
            Kur            = FB.KUR,
            DovizCinsi     = FB.DOVIZ_CINSI,
            DovizKur       = FB.DOVIZKUR,
            RaporDoviz     = FB.RAPORDOVIZ,
            FaturaDovizi   = FB.FATURADOVIZI,
            Aciklama       = FB.ACIKLAMA,
            OzelKod        = FB.OZELKOD,
            OzelKod2       = FB.OZELKOD2,
            ProjeId        = FB.PROJEID,
            Vade           = FB.VADE,
            Durum          = 0,                    -- klon TASLAK baslar
            Unvan          = FB.BASLIK,
            Adres          = FB.ADRES,
            Ilce           = FB.ILCE,
            Il             = FB.IL,
            Vd             = FB.VD,
            Vno            = FB.VNO,
            FiyatListesi   = FB.FIYAT_LISTESI,
            EkstredeKullan = FB.EKSTREDEKULLAN,
            AcikKapali     = FB.ACIK_KAPALI,
            MasrafId       = FB.MASRAFID,
            EkVergi        = FB.EKVERGI,
            Senaryo        = FB.SENARYO,
            EFaturaDurum   = 0,
            EFaturaSonuc   = 0,
            RehberIletId   = FB.REHBERILETID,
            SaticiKodu     = FB.SATICIKODU,
            DetayBolumu    = FB.DETAYBOLUMU
        FROM dbo.FATBASLIK FB
        WHERE FB.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    ------------------------------------------------------------------ SATIRLAR
    DECLARE @Satirlar NVARCHAR(MAX) =
    (
        SELECT
            Sira            = ROW_NUMBER() OVER (ORDER BY ISNULL(F.SIRA, F.ID), F.ID),
            UrunId          = F.URUNID,
            Tur             = F.TUR,
            Adet            = F.ADET,
            Miktar          = F.MIKTAR,
            Birim           = F.BIRIM,
            BirimFiyat      = F.BIRIMFIYAT,
            Tutar           = F.TUTAR,
            Kdv             = F.KDV,
            Iskonto         = F.ISKONTO,
            Iskonto2        = F.ISKONTO2,
            Kur             = F.KUR,
            DovizKuru       = F.DOVIZ_KURU,
            DovizBirimFiyat = F.DOVIZ_BIRIMFIYAT,
            DovizKurDegeri  = F.DOVIZKURDEGERI,
            DovizTutari     = F.DOVIZ_TUTARI,
            Aciklama        = F.ACIKLAMA,
            ProjeId         = F.PROJEID,
            MasrafId        = F.MASRAFID,
            OzelKod         = F.OZELKOD,
            OzelKod2        = F.OZELKOD2,
            Izleme          = 0,                   -- lot/seri klona tasinmaz
            PozNo           = F.POZNO,
            EkipmanId       = F.EKIPMANID,
            Mf              = F.MF,
            MuhKodu         = F.MUHKODU,
            Kasa            = F.KASA,
            -- OTVYUZDE bu tabloda BIT: FOR JSON true/false uretir, kaydet API'si
            --   FLOAT bekler -> 'nvarchar to float' hatasi. Sayiya cevir.
            OtvYuzde        = CAST(F.OTVYUZDE AS INT),
            OtvMiktar       = F.OTVMIKTAR,
            Vade            = F.VADE,
            KampanyaId      = F.KAMPANYAID,
            KdvMuafiyeti    = F.KDVMUHAFIYETI
        FROM dbo.FATURA F
        WHERE F.FATBASID = @KaynakId
        ORDER BY ISNULL(F.SIRA, F.ID), F.ID
        FOR JSON PATH
    );

    IF @Satirlar IS NULL
        THROW 51201, N'Kaynak belgede satır yok, kopyalanacak içerik bulunamadı.', 1;

    ------------------------------------------------------------------ KAYDET
    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    -- @SonucDondur=0 : Kaydet kendi sonuc setini GONDERMEZ; istemci bu SP'nin
    --   sonucunu okur (ic ice cagrida ilk result set tuzagi).
    EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @J, @BelgeIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0
        THROW 51202, N'Klon belge oluşturulamadı.', 1;

    -- ISLEMLOG izi: bu belge KOPYA (ALTISLEMTIPI=3), kaynagi @KaynakId.
    --   TabNo belge turune gore cozulur (log kart satiri hangi TABLOID ile yazildiysa).
    DECLARE @LogTabNo INT = (SELECT TOP 1 TABLOID FROM dbo.ISLEMLOG
                              WHERE KAYITID = @YeniId AND ISLEMTIPI = 1 ORDER BY ID DESC);
    IF @LogTabNo IS NOT NULL
        EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = @LogTabNo, @KayitId = @YeniId,
             @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = @LogTabNo;

    SELECT Sonuc    = 1,
           KaynakId = @KaynakId,
           BelgeId  = @YeniId,
           BelgeNo  = (SELECT FATURANO FROM dbo.FATBASLIK WHERE ID = @YeniId),
           Tur      = @Tur,
           Satir    = (SELECT COUNT(*) FROM dbo.FATURA WHERE FATBASID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Belge_Klonla_Json TO gentegre_api;
GO
