-- ============================================================
-- GenDepoUpdate142.sql
-- SIPARIS KLONLAMA -> KAYDET API'SI UZERINDEN (sp_Api_Belge_Siparis_Klonla_Json)
--
-- 140'ta FATBASLIK tabanli belgeler klon API'sine gecmisti; siparis (TUR 9/19/101)
--   kendi kaydet API'sini kullandigi icin disarida kalmisti ve hala Pascal'daki ham
--   SQLSatiriKopyala zinciriyle klonlaniyordu. Bu dosya onu da ayni desene alir:
--     kaynagi oku -> JSON kur -> sp_Api_Belge_Siparis_Kaydet_Json
--   Boylece klon, elden girilmis yeni siparisle AYNI kod yolundan gecer
--   (belge no, toplamlar, durum, ISLEMLOG tek yerde).
--
-- KLONA TASINMAYANLAR (bilerek)
--   YERI/YERID          : donusum bagi (teklif/talep -> siparis) - klon bagimsizdir
--   SIPARISNO/SERI/KOCAN: yeni numara Kaydet icinde uretilir
--   DURUM               : klon TASLAK (0) baslar
--   ONAY/ONAYLAYAN/ONAYTARIHI, BIRIMONAY* : onay gecmisi kopyalanmaz
--   SERVISID, ANAKAYITID: kaynak kayit baglari
--   satirda IZLEME      : lot/seri klona tasinmaz; kaynakta varsa klonlama ENGELLENIR
--
-- GIRDI : {"KaynakId":123,"Tarih":"2026-08-10","RehberId":null,"Oturum":{...}}
-- CIKTI : {"Sonuc":1,"KaynakId":123,"BelgeId":456,"BelgeNo":"...","Tur":19,"Satir":n}
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Siparis_Klonla_Json
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
    IF NOT EXISTS (SELECT 1 FROM dbo.SIPARIS WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak sipariş bulunamadı.', 1;

    SET @Tarih = ISNULL(@Tarih, GETDATE());
    DECLARE @Tur INT = (SELECT TUR FROM dbo.SIPARIS WHERE ID = @KaynakId);

    -- SIPARIS NUMARASI: siparis kaydet API'si numara URETMEZ (cagirandan bekler;
    --   fatura tarafinda Kaydet kendi uretiyor). Eski Pascal yolu da burada
    --   SiradakiBelgeNumarasi cagiriyordu -> ayni isi klon SP'si yapar.
    DECLARE @Kocan INT = ISNULL((SELECT TOP 1 KOCANNO FROM dbo.KOCANAYARLARI
                                  WHERE TUR = @Tur AND SUBEID = @SubeId
                                    AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                  ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
    DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
    INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @Tur, @SubeID = @SubeId,
                                        @Kocanno = @Kocan, @BTarihi = @Tarih;
    DECLARE @No NVARCHAR(50), @Seri NVARCHAR(50);
    SELECT TOP 1 @No = BelgeNo, @Seri = BelgeSeri FROM @BN;

    -- Lot/seri izlemli satir varsa klonlanmaz (fatura klonuyla ayni kural).
    IF EXISTS (SELECT 1 FROM dbo.SIPARISDETAY WHERE SIPARISID = @KaynakId AND ISNULL(IZLEME, 0) <> 0)
        THROW 51200, N'Belge içeriğinde izlem bilgisi aktif ürünler var, bu işlem gerçekleştirilemez.', 1;

    ------------------------------------------------------------------ BASLIK
    DECLARE @Baslik NVARCHAR(MAX) =
    (
        SELECT
            Tur           = S.TUR,
            Tipi          = S.TIPI,
            Tarih         = CONVERT(NVARCHAR(19), @Tarih, 126),
            SiparisTarih  = CONVERT(NVARCHAR(19), @Tarih, 126),
            SiparisNo     = @No,
            SiparisSeri   = @Seri,
            KocanNo       = NULLIF(@Kocan, 0),
            RehberId      = ISNULL(@RehberId, S.REHBERID),
            GirisDepo     = S.GIRISDEPO,
            CikisDepo     = S.CIKISDEPO,
            KdvDurum      = S.KDVDURUM,
            Kur           = S.KUR,
            DovizCinsi    = S.DOVIZ_CINSI,
            DovizKur      = S.DOVIZKUR,
            RaporDoviz    = S.RAPORDOVIZ,
            Aciklama      = S.ACIKLAMA,
            OzelKod       = S.OZELKOD,
            ProjeId       = S.PROJEID,
            Vade          = S.VADE,
            Durum         = 0,                     -- klon TASLAK baslar
            Unvan         = S.BASLIK,
            Adres         = S.ADRES,
            Ilce          = S.ILCE,
            Il            = S.IL,
            Vd            = S.VD,
            Vno           = S.VNO,
            FiyatListesi  = S.FIYAT_LISTESI,
            SubeId        = S.SUBEID,
            AktiviteId    = S.AKTIVITEID,
            RehberIletId  = S.REHBERILETID,
            SaticiKodu    = S.SATICIKODU,
            DetayBolumu   = S.DETAYBOLUMU
        FROM dbo.SIPARIS S
        WHERE S.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    ------------------------------------------------------------------ SATIRLAR
    DECLARE @Satirlar NVARCHAR(MAX) =
    (
        SELECT
            Sira            = ROW_NUMBER() OVER (ORDER BY SD.ID),
            UrunId          = SD.URUNID,
            Tur             = SD.TUR,
            Adet            = SD.ADET,
            Miktar          = SD.MIKTAR,
            Birim           = SD.BIRIM,
            BirimFiyat      = SD.BIRIMFIYAT,
            Tutar           = SD.TUTAR,
            Kdv             = SD.KDV,
            Iskonto         = SD.ISKONTO,
            Iskonto2        = SD.ISKONTO2,
            Kur             = SD.KUR,
            DovizKuru       = SD.DOVIZ_KURU,
            DovizBirimFiyat = SD.DOVIZ_BIRIMFIYAT,
            DovizKurDegeri  = SD.DOVIZKURDEGERI,
            DovizTutari     = SD.DOVIZ_TUTARI,
            Aciklama        = SD.ACIKLAMA,
            ProjeId         = SD.PROJEID,
            MasrafId        = SD.MASRAFID,
            OzelKod         = SD.OZELKOD,
            OzelKod2        = SD.OZELKOD2,
            Izleme          = 0,                   -- lot/seri klona tasinmaz
            PozNo           = SD.POZNO,
            EkipmanId       = SD.EKIPMANID,
            Mf              = SD.MF,
            MuhKodu         = SD.MUHKODU,
            Kasa            = SD.KASA,
            -- OTVYUZDE bu tabloda BIT: FOR JSON true/false uretir, kaydet API'si
            --   FLOAT bekler -> 'nvarchar to float' hatasi. Sayiya cevir.
            OtvYuzde        = CAST(SD.OTVYUZDE AS INT),
            OtvMiktar       = SD.OTVMIKTAR,
            Vade            = SD.VADE,
            KampanyaId      = SD.KAMPANYAID,
            TeslimTarihi    = SD.TESLIMTARIHI
        FROM dbo.SIPARISDETAY SD
        WHERE SD.SIPARISID = @KaynakId
        ORDER BY SD.ID
        FOR JSON PATH
    );

    IF @Satirlar IS NULL
        THROW 51201, N'Kaynak siparişte satır yok, kopyalanacak içerik bulunamadı.', 1;

    ------------------------------------------------------------------ KAYDET
    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    EXEC dbo.sp_Api_Belge_Siparis_Kaydet_Json @Kosullar = @J,
         @BelgeIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0
        THROW 51202, N'Klon sipariş oluşturulamadı.', 1;

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
           BelgeNo  = (SELECT SIPARISNO FROM dbo.SIPARIS WHERE ID = @YeniId),
           Tur      = @Tur,
           Satir    = (SELECT COUNT(*) FROM dbo.SIPARISDETAY WHERE SIPARISID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Belge_Siparis_Klonla_Json TO gentegre_api;
GO
