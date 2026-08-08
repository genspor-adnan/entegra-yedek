-- ============================================================
-- GenDepoUpdate82.sql
-- API: sp_Api_Belge_Donusum_Json  -- GENEL belge donusumu (@DonusumTuru ile)
--   + dbo.fn_Api_Donusum_Esleme   : donusum turu -> kaynak/hedef eslemesi (tek kaynak)
--
-- TTablo.BelgeDonustur'un (Utablo.pas, ~21.800 karakter) case blogundaki esleme
--   tablosu SP tarafina alindi. Delphi'deki yordam simdilik duruyor; cagri
--   yerleri asama asama buraya gececek.
--
-- sp_Api_Donusum_SiparistenBelge_Json artik BU SP'nin ince sarmalayicisidir
--   (geriye uyumluluk; yeni kod dogrudan sp_Api_Belge_Donusum_Json cagirmali).
--
-- 1. ASAMA KAPSAMI: hedefi FATBASLIK olan donusumler.
--   406/407/478  alis siparisi   -> irsaliye / fatura / fis
--   409/410/473  satis siparisi  -> irsaliye / fatura / fis
--   429          satis siparisi  -> giden konsinye
--   408/427      alis irsaliyesi -> fatura / fis
--   411/424      satis irsaliyesi-> fatura / fis
--   461/469      gelen konsinye  -> fatura / irsaliye
--   462/468/472  giden konsinye  -> fatura / irsaliye / fis
--   414/435      siparis / stok talep -> stok transferi
--
--   KAPSAM DISI (henuz): hedefi SIPARIS olanlar (412/413 teklif->siparis,
--   428 satinalma talebi->siparis) ve uretim hedefleri (415/420/425/426/431).
--   Bunlar 51200 ile acikca reddedilir; UBelgeDonusum / BelgeDonustur yolu kalir.
--
-- HENUZ TASINMAYAN KURALLAR (BelgeDonustur'da var, burada YOK - bilincli):
--   izlemli urun engeli, stok yeterlilik kontrolu, hedefte e-fatura/e-irsaliye
--   durumu, detay sablonu (REHBERBILGI) ve yorum kopyalama.
--   Bu yuzden BelgeDonustur HENUZ EMEKLI EDILMEDI.
--
-- SUNUCUDA OLAN (Pascal yolunda olmayan): tek transaction, asiri donusum
--   korumasi (UPDLOCK + kalan), hedef toplamlari, kaynak belgenin kapanma
--   durumu, ISLEMLOG.
--
-- GIRDI : {"DonusumTuru":409,"KaynakBelgeId":23202,"HedefBelgeId":0,
--          "Tarih":"2026-08-08","SatirIds":[156958],"Oturum":{"KulId":5,"SubeId":-1}}
--          HedefBelgeId > 0 -> yeni belge acilmaz, MEVCUT belgeye eklenir.
-- CIKTI : {"Sonuc":1,"DonusumTuru":..,"KaynakBelgeId":..,"HedefBelgeId":..,
--          "HedefBelgeNo":"..","HedefTur":..,"Satir":n,"Loglanan":n,
--          "Toplam":{...},"KaynakDurum":{...}}
-- HATA  : 51001 girdi, 51002 kaynak/hedef bulunamadi,
--         51200 kapsam disi donusum / kalan satir yok / kaynak tur uyumsuz
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- Donusum esleme tablosu (TTablo.BelgeDonustur case blogunun karsiligi)
--   KaynakTip : fn_Api_Donusum_Kalan icin 1=teklif, 2=siparis, 3=belge
--   Destek    : 1 = bu SP destekliyor, 0 = kapsam disi (Pascal yolunda)
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Api_Donusum_Esleme ()
RETURNS TABLE
AS
RETURN
(
    SELECT DonusumTuru, KaynakTablo, KaynakDetay, KaynakBaglanti, KaynakTur, KaynakTip,
           HedefTur, HedefTablo, Destek
    FROM (VALUES
        -- alis siparisi -> irsaliye / fatura / fis
        (406, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  10, 'FATBASLIK', 1),
        (407, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  11, 'FATBASLIK', 1),
        (478, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  9, 2,  12, 'FATBASLIK', 1),
        -- satis siparisi -> irsaliye / fatura / fis / giden konsinye
        (409, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  14, 'FATBASLIK', 1),
        (410, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  15, 'FATBASLIK', 1),
        (473, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  16, 'FATBASLIK', 1),
        (429, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2, 119, 'FATBASLIK', 1),
        -- alis irsaliyesi -> fatura / fis
        (408, 'FATBASLIK', 'FATURA',       'FATBASID',  10, 3,  11, 'FATBASLIK', 1),
        (427, 'FATBASLIK', 'FATURA',       'FATBASID',  10, 3,  12, 'FATBASLIK', 1),
        -- satis irsaliyesi -> fatura / fis
        (411, 'FATBASLIK', 'FATURA',       'FATBASID',  14, 3,  15, 'FATBASLIK', 1),
        (424, 'FATBASLIK', 'FATURA',       'FATBASID',  14, 3,  16, 'FATBASLIK', 1),
        -- gelen konsinye -> fatura / irsaliye
        (461, 'FATBASLIK', 'FATURA',       'FATBASID', 109, 3,  11, 'FATBASLIK', 1),
        (469, 'FATBASLIK', 'FATURA',       'FATBASID', 109, 3,  10, 'FATBASLIK', 1),
        -- giden konsinye -> fatura / irsaliye / fis
        (462, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  15, 'FATBASLIK', 1),
        (468, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  14, 'FATBASLIK', 1),
        (472, 'FATBASLIK', 'FATURA',       'FATBASID', 119, 3,  16, 'FATBASLIK', 1),
        -- stok transferi
        (414, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,  20, 'FATBASLIK', 1),
        (435, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 105, 2, 20, 'FATBASLIK', 1),
        -- ---- kapsam disi (Pascal yolunda kalanlar) ----
        (412, 'TEKLIF',    'TEKLIFDETAY',  'TEKLIFID',  99, 1,   9, 'SIPARIS',   0),
        (413, 'TEKLIF',    'TEKLIFDETAY',  'TEKLIFID',  99, 1,  19, 'SIPARIS',   0),
        (428, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',101, 2,   9, 'SIPARIS',   0),
        (415, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,   6, 'FATBASLIK', 0),
        (420, 'SIPARIS',   'SIPARISDETAY', 'SIPARISID', 19, 2,   6, 'FATBASLIK', 0),
        (425, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  14, 'FATBASLIK', 0),
        (426, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  15, 'FATBASLIK', 0),
        (431, 'FATBASLIK', 'FATURA',       'FATBASID',   6, 3,  16, 'FATBASLIK', 0)
    ) AS E(DonusumTuru, KaynakTablo, KaynakDetay, KaynakBaglanti, KaynakTur, KaynakTip,
           HedefTur, HedefTablo, Destek)
);
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
                    LEFT(ISNULL(@KaynakNo, N'') + N' nolu belgeden', 200),
                    0, @Vade, @SubeId, @KulId, GETDATE(), 1);
            SET @HedefBelgeId = CAST(SCOPE_IDENTITY() AS INT);

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

-- ============================================================
-- Geriye uyumluluk: eski ad artik ince sarmalayici.
--   Yeni kod dogrudan sp_Api_Belge_Donusum_Json cagirmali.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_SiparistenBelge_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SiparisId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SiparisId') AS INT);
    DECLARE @HedefTur  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefTur')  AS INT);
    IF @SiparisId IS NULL OR @HedefTur IS NULL
        THROW 51001, N'SiparisId ve HedefTur zorunlu.', 1;

    DECLARE @Tur INT = (SELECT TUR FROM SIPARIS WHERE ID = @SiparisId);
    IF @Tur IS NULL THROW 51002, N'Siparis bulunamadi.', 1;

    DECLARE @DT INT = (SELECT TOP 1 DonusumTuru FROM dbo.fn_Api_Donusum_Esleme()
                        WHERE KaynakTablo = 'SIPARIS' AND KaynakTur = @Tur AND HedefTur = @HedefTur);
    IF @DT IS NULL
    BEGIN
        DECLARE @m NVARCHAR(300) = N'Bu siparis turu (' + CAST(@Tur AS nvarchar(10)) +
            N') hedef belge turune (' + CAST(@HedefTur AS nvarchar(10)) + N') donusturulemez.';
        THROW 51200, @m, 1;
    END

    DECLARE @Yeni NVARCHAR(MAX) =
        JSON_MODIFY(JSON_MODIFY(@Kosullar, '$.DonusumTuru', @DT), '$.KaynakBelgeId', @SiparisId);
    EXEC dbo.sp_Api_Belge_Donusum_Json @Yeni;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_Donusum_Json TO gentegre_api;
GO
