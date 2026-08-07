-- ============================================================
-- GenDepoUpdate74.sql
-- API: donusum uygulama (acik-degerli sozlesme) + ic yardimcilar
--   dbo.sp_Api_Belge_Toplam_Yaz_Ic   : toplamlari hesaplar/yazar (SONUC KUMESI DONDURMEZ)
--   dbo.sp_Api_Belge_Durum_Yaz_Ic    : kapanma durumunu hesaplar/yazar (sonuc kumesi yok)
--   dbo.sp_Api_Belge_ToplamHesapla_Json / _DurumHesapla_Json : ince sarmalayici oldu
--   dbo.sp_Api_Donusum_Uygula_Json   : kaynak satirlari hedef belgeye donusturur
--
-- NEDEN IC YARDIMCI: bir SP baska bir SP'yi cagirinca onun SELECT'i istemciye
--   fazladan sonuc kumesi olarak gider. Hesap/yazma kismi sonuc kumesi
--   dondurmeyen ic SP'lere alindi; JSON sarmalayicilar yalnizca ciktilar.
--
-- ---- sp_Api_Donusum_Uygula_Json : ACIK-DEGERLI SOZLESME ----
-- KAPSAM SINIRI (bilincli): bu SP fiyat/iskonto/KDV HESAPLAMAZ. Delphi'deki
--   UBelgeDonusum.StokEkle (13.900 karakter) kullaniciya soru soran FiyatSor
--   diyalogu, hedef grid dataset'i ve showmessage'li depo kontrolleri iceriyor;
--   bunun birebir SQL karsiligi yok. Burada degerleri CAGIRAN gonderir
--   (mobil/web'de zaten fiyat sorma UI'i yoktur). Delphi kendi yolunda kalir,
--   yalnizca kalan kontrolunu bu SP'den/Kontrol SP'sinden alir.
--
-- SUNUCUYA TASINAN IS KURALI: asiri donusum korumasi. Kaynak satirlar
--   UPDLOCK ile kilitlenip kalan TRANSACTION ICINDE hesaplanir; iki kullanici
--   ayni satiri ayni anda donusturemez (bugun istemcide kontrol ediliyor ve
--   ikisi de geciyor).
--
-- GIRDI:
--   {"Kaynak":2,"DonusumTuru":409,"HedefUretim":false,"HedefBelgeId":5567,
--    "Oturum":{"KulId":5,"SubeId":-1},
--    "Satirlar":[{"Sira":1,"KaynakSatirId":156958,"UrunId":505,"Tur":1,
--                 "Adet":3,"Miktar":3,"Birim":51,"BirimFiyat":150,"Kdv":20,
--                 "Iskonto":0,"Iskonto2":0,"Kur":"TL","DovizKuru":"TL",
--                 "DovizBirimFiyat":0,"DovizKurDegeri":1,"Aciklama":"",
--                 "ProjeId":0,"MasrafId":0,"OzelKod":"","OzelKod2":"","Izleme":0}]}
--   TUTAR verilmezse hesaplanir: round(round(BirimFiyat*Adet,2)
--                                *(100-Iskonto)*(100-Iskonto2)/10000, 2)
--   (karar 1: TUTAR ISKONTO2'yi ICERIR - SP/TOPLAM_FORMUL_KARSILASTIRMA.md §5)
-- CIKTI:
--   {"Sonuc":1,"HedefBelgeId":..,"Yazilan":n,
--    "Satirlar":[{"Sira":1,"KaynakSatirId":..,"SatirId":9001}],
--    "Toplam":{...},"KaynakDurum":[{"BelgeId":..,"Durum":9}]}
-- HATA: 51001 girdi, 51002 hedef belge yok, 51200 kalan yetersiz
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- Toplam: hesap + yazma (sonuc kumesi DONDURMEZ)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Toplam_Yaz_Ic
    @BelgeId  INT,
    @Yaz      BIT = 1,
    @Zorla    BIT = 0,
    @Matrah   MONEY OUTPUT,
    @Kdv      MONEY OUTPUT,
    @Toplam   MONEY OUTPUT,
    @Doviz    MONEY OUTPUT,
    @Maliyet  MONEY OUTPUT,
    @EkVergi  MONEY OUTPUT,
    @Neden    NVARCHAR(60) OUTPUT,
    @Yazildi  BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Neden = N''; SET @Yazildi = 0;

    DECLARE @Tur INT, @Tipi INT, @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10), @EFatDurum INT;
    SELECT @Tur          = TUR,
           @Tipi         = ISNULL(TIPI, 0),
           @EkVergi      = ISNULL(EKVERGI, 0),
           @RaporDoviz   = ISNULL(RAPORDOVIZ, N'TL'),
           @FaturaDovizi = ISNULL(FATURADOVIZI, N'TL'),
           @EFatDurum    = ISNULL(EFATURADURUM, 0)
    FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL THROW 51002, N'Belge bulunamadi.', 1;

    -- Kapsam: gelen e-belge ve uretim fisinde formul gecersiz (bkz. GenDepoUpdate68)
    IF @EFatDurum <> 0 SET @Neden = N'gelen e-belge';
    ELSE IF @Tur = 6   SET @Neden = N'uretim fisi';

    SELECT @Matrah = CAST(MAX(CASE WHEN TUR = 4 THEN DEGER END) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId);
    IF @Matrah IS NULL
        SELECT @Matrah = CAST(SUM(DEGER) AS MONEY)
        FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 1;

    SELECT @Toplam = CAST(SUM(DEGER) AS MONEY),
           @Doviz  = CAST(SUM(DOVIZTUTARI) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 20;

    SET @Matrah = ISNULL(@Matrah, 0);
    SET @Toplam = ISNULL(@Toplam, 0);

    IF @Tipi IN (4, 7, 8)
    BEGIN
        SELECT @Kdv = CAST(SUM(DEGER) AS MONEY) FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 15;
        SET @Kdv    = ISNULL(@Kdv, 0);
        SET @Matrah = @Matrah - ABS(@EkVergi);
    END
    ELSE
        SET @Kdv = @Toplam - @Matrah;

    IF @RaporDoviz = N'TL' AND @FaturaDovizi = N'TL' SET @Doviz = @Toplam;
    SET @Doviz = ISNULL(@Doviz, @Toplam);

    SELECT @Maliyet = CAST(ISNULL(ROUND(SUM(F.MIKTAR * ISNULL(SOM.BIRIMMALIYET, 0.0)), 2), 0.0) AS MONEY)
    FROM FATURA F LEFT OUTER JOIN STOK_ORT_MALIYET SOM ON F.ID = SOM.FATURAID
    WHERE F.FATBASID = @BelgeId;
    SET @Maliyet = ISNULL(@Maliyet, 0);

    IF @Yaz = 1 AND (@Neden = N'' OR @Zorla = 1)
    BEGIN
        UPDATE FATBASLIK
           SET FATURA_MATRAHI = @Matrah, KDV_TUTARI = @Kdv, FATURA_TUTARI = @Toplam,
               DOVIZ_TUTARI = @Doviz, FATURA_MALIYETI_ORT = @Maliyet
         WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_ToplamHesapla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Yaz     BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Yaz')   AS BIT), 1);
    DECLARE @Zorla   BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Zorla') AS BIT), 0);
    IF @BelgeId IS NULL OR @BelgeId <= 0 THROW 51001, N'BelgeId zorunlu.', 1;

    DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
            @EkVergi MONEY, @Neden NVARCHAR(60), @Yazildi BIT;
    EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @BelgeId, @Yaz = @Yaz, @Zorla = @Zorla,
         @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
         @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkVergi OUTPUT,
         @Neden = @Neden OUTPUT, @Yazildi = @Yazildi OUTPUT;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId,
                   CASE WHEN @Neden = N'' THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden AS Neden, @Yazildi AS Yazildi,
                   @Matrah AS Matrah, @Kdv AS Kdv, @Toplam AS Toplam,
                   @Doviz AS Doviz, @Maliyet AS Maliyet, @EkVergi AS EkVergi
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ============================================================
-- Durum: hesap + yazma (sonuc kumesi DONDURMEZ)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Durum_Yaz_Ic
    @BelgeId     INT,
    @Kaynak      NVARCHAR(10) = N'siparis',
    @Yaz         BIT = 1,
    @Tur         INT OUTPUT,
    @Durum       INT OUTPUT,
    @OncekiDurum INT OUTPUT,
    @Satir       INT OUTPUT,
    @Tamamlanan  INT OUTPUT,
    @Kismi       INT OUTPUT,
    @Acik        INT OUTPUT,
    @Neden       NVARCHAR(60) OUTPUT,
    @Yazildi     BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Neden = N''; SET @Yazildi = 0;
    SET @Satir = 0; SET @Tamamlanan = 0; SET @Kismi = 0; SET @Acik = 0;

    IF @Kaynak = N'siparis'
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM SIPARIS   WHERE ID = @BelgeId;
    ELSE
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL THROW 51002, N'Kayit bulunamadi.', 1;
    SET @Durum = @OncekiDurum;

    IF @OncekiDurum NOT IN (0, 1, 9)
        SET @Neden = N'durum korumali (' + CAST(@OncekiDurum AS nvarchar(10)) + N')';

    DECLARE @Yeri TABLE (K INT PRIMARY KEY);
    IF @Neden = N''
    BEGIN
        IF @Kaynak = N'siparis'
        BEGIN
            IF @Tur = 19 INSERT @Yeri (K) VALUES (409),(410),(415),(420),(429),(473);
            ELSE IF @Tur = 9 INSERT @Yeri (K) VALUES (406),(407),(478);
            ELSE SET @Neden = N'siparis turu kapsam disi';
        END
        ELSE
        BEGIN
            IF @Tur = 14 INSERT @Yeri (K) VALUES (411),(424);
            ELSE IF @Tur = 10 INSERT @Yeri (K) VALUES (408),(427);
            ELSE SET @Neden = N'belge turu kapsam disi';
        END
    END

    IF @Neden = N''
    BEGIN
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6), Cikan DECIMAL(18,6));
        IF @Kaynak = N'siparis'
            INSERT @S SELECT SD.ID, ISNULL(SD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = SD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM SIPARISDETAY SD WHERE SD.SIPARISID = @BelgeId AND ISNULL(SD.ADET,0) > 0;
        ELSE
            INSERT @S SELECT FD.ID, ISNULL(FD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = FD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM FATURA FD WHERE FD.FATBASID = @BelgeId AND ISNULL(FD.ADET,0) > 0;

        SELECT @Satir      = COUNT(*),
               @Tamamlanan = ISNULL(SUM(CASE WHEN Adet - Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Acik       = ISNULL(SUM(CASE WHEN Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Kismi      = ISNULL(SUM(CASE WHEN Cikan > 0 AND Adet - Cikan > 0 THEN 1 ELSE 0 END), 0)
        FROM @S;

        IF @Satir = 0            SET @Neden = N'adetli satir yok';
        ELSE IF @Satir = @Tamamlanan SET @Durum = 9;
        ELSE IF @Acik = @Satir       SET @Durum = 0;
        ELSE                         SET @Durum = 1;
    END

    IF @Yaz = 1 AND @Neden = N'' AND @Durum <> @OncekiDurum
    BEGIN
        IF @Kaynak = N'siparis' UPDATE SIPARIS   SET DURUM = @Durum WHERE ID = @BelgeId;
        ELSE                    UPDATE FATBASLIK SET DURUM = @Durum WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_DurumHesapla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @BelgeId INT          = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Kaynak  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kaynak'), N'siparis'));
    DECLARE @Yaz     BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Yaz') AS BIT), 1);
    IF @BelgeId IS NULL OR @BelgeId <= 0 THROW 51001, N'BelgeId zorunlu.', 1;
    IF @Kaynak NOT IN (N'siparis', N'belge') THROW 51001, N'Kaynak "siparis" ya da "belge" olmali.', 1;

    DECLARE @Tur INT, @Durum INT, @Onceki INT, @Satir INT, @Tam INT, @Kis INT, @Acik INT,
            @Neden NVARCHAR(60), @Yazildi BIT;
    EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @BelgeId, @Kaynak = @Kaynak, @Yaz = @Yaz,
         @Tur = @Tur OUTPUT, @Durum = @Durum OUTPUT, @OncekiDurum = @Onceki OUTPUT,
         @Satir = @Satir OUTPUT, @Tamamlanan = @Tam OUTPUT, @Kismi = @Kis OUTPUT,
         @Acik = @Acik OUTPUT, @Neden = @Neden OUTPUT, @Yazildi = @Yazildi OUTPUT;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Kaynak AS Kaynak, @Tur AS Tur,
                   CASE WHEN @Neden = N'' THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden AS Neden, @Durum AS Durum, @Onceki AS OncekiDurum, @Yazildi AS Yazildi,
                   @Satir AS Satir, @Tam AS Tamamlanan, @Kis AS Kismi, @Acik AS Acik
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ============================================================
-- Donusum uygula
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_Uygula_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Kaynak       INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kaynak')       AS INT);
    DECLARE @DonusumTuru  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru')  AS INT);
    DECLARE @HedefUretim  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefUretim')  AS BIT), 0);
    DECLARE @HedefBelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefBelgeId') AS INT);
    DECLARE @KulId        INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId       INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @Kaynak IS NULL OR @Kaynak NOT IN (1,2,3) THROW 51001, N'Kaynak 1/2/3 olmali.', 1;
    IF @DonusumTuru IS NULL                      THROW 51001, N'DonusumTuru zorunlu.', 1;
    IF @HedefBelgeId IS NULL OR @HedefBelgeId <= 0 THROW 51001, N'HedefBelgeId zorunlu.', 1;

    DECLARE @HTur INT, @HReh INT, @HGir INT, @HCik INT;
    SELECT @HTur = TUR, @HReh = REHBERID, @HGir = ISNULL(GIRISDEPO,0), @HCik = ISNULL(CIKISDEPO,0)
    FROM FATBASLIK WHERE ID = @HedefBelgeId;
    IF @HTur IS NULL THROW 51002, N'Hedef belge bulunamadi.', 1;

    DECLARE @S TABLE (
        Sira INT PRIMARY KEY, KaynakSatirId INT, UrunId INT, Tur INT,
        Adet DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
        BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6), Kdv INT,
        Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
        Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), Izleme INT,
        YeniSatirId INT NULL);
    INSERT @S (Sira, KaynakSatirId, UrunId, Tur, Adet, Miktar, Birim, BirimFiyat, Tutar, Kdv,
               Iskonto, Iskonto2, Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, DovizTutari,
               Aciklama, ProjeId, MasrafId, OzelKod, OzelKod2, Izleme)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
           J.KaynakSatirId, ISNULL(J.UrunId,0), ISNULL(J.Tur,1),
           ISNULL(J.Adet,0), ISNULL(J.Miktar, ISNULL(J.Adet,0)), ISNULL(J.Birim,0),
           ISNULL(J.BirimFiyat,0), J.Tutar, ISNULL(J.Kdv,0),
           ISNULL(J.Iskonto,0), ISNULL(J.Iskonto2,0),
           ISNULL(J.Kur,N'TL'), ISNULL(J.DovizKuru,N'TL'),
           ISNULL(J.DovizBirimFiyat,0), ISNULL(J.DovizKurDegeri,1), ISNULL(J.DovizTutari,0),
           ISNULL(J.Aciklama,N''), ISNULL(J.ProjeId,0), ISNULL(J.MasrafId,0),
           ISNULL(J.OzelKod,N''), ISNULL(J.OzelKod2,N''), ISNULL(J.Izleme,0)
    FROM OPENJSON(@Kosullar, '$.Satirlar')
         WITH (Sira INT, KaynakSatirId INT, UrunId INT, Tur INT, Adet DECIMAL(18,6),
               Miktar DECIMAL(18,6), Birim INT, BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6),
               Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
               DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
               Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT, OzelKod NVARCHAR(50),
               OzelKod2 NVARCHAR(50), Izleme INT) J
    WHERE J.KaynakSatirId IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @S) THROW 51001, N'Satirlar bos olamaz.', 1;

    -- TUTAR verilmediyse hesapla (karar 1: ISKONTO2 dahil, carpimsal)
    UPDATE @S SET Tutar = ROUND(ROUND(BirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE Tutar IS NULL;

    DECLARE @Yazilan INT = 0;
    DECLARE @KaynakBelgeler TABLE (BelgeId INT PRIMARY KEY);

    BEGIN TRY
        BEGIN TRAN;

        -- ---- Asiri donusum korumasi: kaynak satirlari KILITLE, kalani transaction icinde hesapla ----
        IF @Kaynak = 1
            SELECT @Yazilan = COUNT(*) FROM TEKLIFDETAY WITH (UPDLOCK, HOLDLOCK)
             WHERE ID IN (SELECT KaynakSatirId FROM @S);
        ELSE IF @Kaynak = 2
            SELECT @Yazilan = COUNT(*) FROM SIPARISDETAY WITH (UPDLOCK, HOLDLOCK)
             WHERE ID IN (SELECT KaynakSatirId FROM @S);
        ELSE
            SELECT @Yazilan = COUNT(*) FROM FATURA WITH (UPDLOCK, HOLDLOCK)
             WHERE ID IN (SELECT KaynakSatirId FROM @S);
        SET @Yazilan = 0;

        DECLARE @Hata NVARCHAR(400) = NULL;
        SELECT TOP 1 @Hata = N'Kaynak satir ' + CAST(S.KaynakSatirId AS nvarchar(20)) + N': ' +
               CASE WHEN K.Kalan IS NULL THEN N'kaynak satir bulunamadi'
                    WHEN S.Adet <= 0 THEN N'adet sifir/negatif'
                    ELSE N'kalan yetersiz (istenen ' + CAST(S.Adet AS nvarchar(30)) +
                         N', kalan ' + CAST(ISNULL(K.Kalan,0) AS nvarchar(30)) + N')' END
        FROM @S S
        OUTER APPLY dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, S.KaynakSatirId, @HedefUretim) K
        WHERE K.Kalan IS NULL OR S.Adet <= 0 OR S.Adet > K.Kalan + 0.0001
        ORDER BY S.Sira;

        IF @Hata IS NOT NULL THROW 51200, @Hata, 1;

        -- ---- Hedef satirlari yaz ----
        DECLARE @Sira INT;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Sira FROM @S ORDER BY Sira;
        OPEN c; FETCH NEXT FROM c INTO @Sira;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, STOKID, ACIKLAMA, ADET, MIKTAR,
                                BIRIM, BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV, MASRAFID,
                                OZELKOD, OZELKOD2, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT,
                                DOVIZKURDEGERI, PROJEID, IZLEME, SUBEID, EKLEYEN, EKLEMETARIHI,
                                YERI, YERID, GIRDEPO, CIKDEPO, STOKDURUMDEGIS, GIRISKAYNAK)
            SELECT @HedefBelgeId, @HReh, S.Tur, S.UrunId, S.UrunId, S.Aciklama, S.Adet, S.Miktar,
                   S.Birim, S.BirimFiyat, S.Tutar, S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                   S.OzelKod, S.OzelKod2, S.DovizTutari, S.DovizKuru, S.DovizBirimFiyat,
                   S.DovizKurDegeri, S.ProjeId, S.Izleme, @SubeId, @KulId, GETDATE(),
                   @DonusumTuru, S.KaynakSatirId, @HGir, @HCik, 1, 1
            FROM @S S WHERE S.Sira = @Sira;

            UPDATE @S SET YeniSatirId = CAST(SCOPE_IDENTITY() AS INT) WHERE Sira = @Sira;
            SET @Yazilan = @Yazilan + 1;
            FETCH NEXT FROM c INTO @Sira;
        END
        CLOSE c; DEALLOCATE c;

        -- ---- Hedef belge toplamlari ----
        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkVergi MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @HedefBelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkVergi OUTPUT,
             @Neden = @TNeden OUTPUT, @Yazildi = @TYazildi OUTPUT;

        -- ---- Kaynak belgelerin kapanma durumu ----
        IF @Kaynak = 2
            INSERT @KaynakBelgeler (BelgeId)
            SELECT DISTINCT SD.SIPARISID FROM SIPARISDETAY SD
             WHERE SD.ID IN (SELECT KaynakSatirId FROM @S) AND SD.SIPARISID IS NOT NULL;
        ELSE IF @Kaynak = 3
            INSERT @KaynakBelgeler (BelgeId)
            SELECT DISTINCT F.FATBASID FROM FATURA F
             WHERE F.ID IN (SELECT KaynakSatirId FROM @S) AND F.FATBASID IS NOT NULL;

        DECLARE @kb INT, @dTur INT, @dDurum INT, @dOnce INT, @dSat INT, @dTam INT, @dKis INT,
                @dAcik INT, @dNeden NVARCHAR(60), @dYaz BIT;
        DECLARE @Durumlar TABLE (BelgeId INT, Durum INT, Yazildi BIT, Neden NVARCHAR(60));
        -- EXEC parametresine CASE verilemez -> once degiskene al
        DECLARE @KaynakAd NVARCHAR(10) = CASE WHEN @Kaynak = 2 THEN N'siparis' ELSE N'belge' END;
        DECLARE ck CURSOR LOCAL FAST_FORWARD FOR SELECT BelgeId FROM @KaynakBelgeler;
        OPEN ck; FETCH NEXT FROM ck INTO @kb;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @kb,
                 @Kaynak = @KaynakAd,
                 @Tur = @dTur OUTPUT, @Durum = @dDurum OUTPUT, @OncekiDurum = @dOnce OUTPUT,
                 @Satir = @dSat OUTPUT, @Tamamlanan = @dTam OUTPUT, @Kismi = @dKis OUTPUT,
                 @Acik = @dAcik OUTPUT, @Neden = @dNeden OUTPUT, @Yazildi = @dYaz OUTPUT;
            INSERT @Durumlar VALUES (@kb, @dDurum, @dYaz, @dNeden);
            FETCH NEXT FROM ck INTO @kb;
        END
        CLOSE ck; DEALLOCATE ck;

        COMMIT;

        SELECT (SELECT 1 AS Sonuc, @HedefBelgeId AS HedefBelgeId, @Yazilan AS Yazilan,
                       (SELECT Sira, KaynakSatirId, YeniSatirId AS SatirId
                          FROM @S ORDER BY Sira FOR JSON PATH) AS Satirlar,
                       (SELECT @Matrah AS Matrah, @Kdv AS Kdv, @Toplam AS Toplam, @Doviz AS Doviz
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Toplam,
                       (SELECT BelgeId, Durum, Yazildi, Neden
                          FROM @Durumlar ORDER BY BelgeId FOR JSON PATH) AS KaynakDurum
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
GRANT EXECUTE ON dbo.sp_Api_Donusum_Uygula_Json TO gentegre_api;
GO
