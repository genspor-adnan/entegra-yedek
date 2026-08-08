-- ============================================================
-- GenDepoUpdate79.sql
-- sp_Api_Belge_Kaydet_Json genisletme (GERIYE UYUMLU - yalniz opsiyonel alan eklendi)
--
-- NEDEN: Ubelgegiris (toplu belge girisi) F5-Kaydet akisi bu SP'ye baglaniyor.
--   O ekran basliga su alanlari da yaziyor; sozlesmede karsiliklari yoktu:
--     BASLIK / ADRES / ILCE / IL / VD / VNO  (kendi firma bilgileri)
--     FIYAT_LISTESI, EKSTREDEKULLAN, ACIK_KAPALI, MASRAFID, FATURADOVIZI, EKVERGI
--
-- AYRICA DUZELTME - satirda STOKID:
--   Onceki surum STOKID'ye her zaman UrunId yaziyordu (TM_FATURAGir'den devralinan
--   davranis). TUR=0 satirlarda UrunId bir MASRAF/GELIR kalemi ID'sidir; onu
--   STOKID'ye yazmak stok referansini yanlis doldurur. Artik STOKID yalnizca
--   Tur <> 0 (stok satiri) iken doldurulur.
--
-- Yeni baslik alanlari (hepsi opsiyonel; gonderilmezse yeni belgede NULL/varsayilan,
--   guncellemede mevcut deger korunur):
--   "Baslik":{... ,"Unvan":"","Adres":"","Ilce":"","Il":"","Vd":"","Vno":"",
--             "FiyatListesi":0,"EkstredeKullan":false,"AcikKapali":false,
--             "MasrafId":0,"FaturaDovizi":"TL","EkVergi":0}
--   NOT: FATBASLIK.BASLIK kolonu JSON'da "Unvan" adiyla gecer - "Baslik" nesnenin
--        kendi adi oldugu icin cakismasin diye.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Kaydet_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SatirModu NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));
    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    IF @SatirModu NOT IN (N'delta', N'tam') THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    -- ---- Baslik alanlari ----
    DECLARE @BelgeId   INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ID') AS INT);
    DECLARE @Tur       INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tur') AS INT);
    DECLARE @Tipi      INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tipi') AS INT);
    DECLARE @Tarih     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tarih') AS DATETIME);
    DECLARE @FatTarih  DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FaturaTarih') AS DATETIME);
    DECLARE @RehberId  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberId') AS INT);
    DECLARE @GirisDepo INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.GirisDepo') AS INT);
    DECLARE @CikisDepo INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.CikisDepo') AS INT);
    DECLARE @KdvDurum  NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.KdvDurum');
    DECLARE @Kur       NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.Kur');
    DECLARE @DovizCins NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.DovizCinsi');
    DECLARE @DovizKur  MONEY         = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.DovizKur') AS MONEY);
    DECLARE @RaporDvz  NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.RaporDoviz');
    DECLARE @Aciklama  NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Baslik.Aciklama');
    DECLARE @OzelKod   NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.OzelKod');
    DECLARE @OzelKod2  NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.OzelKod2');
    DECLARE @ProjeId   INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ProjeId') AS INT);
    DECLARE @Vade      INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Vade') AS INT);
    DECLARE @FaturaNo  NVARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar, '$.Baslik.FaturaNo'), N'');
    DECLARE @FatSeri   NVARCHAR(20)  = NULLIF(JSON_VALUE(@Kosullar, '$.Baslik.FaturaSeri'), N'');
    DECLARE @Durum     INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Durum') AS INT);
    -- yeni (opsiyonel)
    DECLARE @Unvan     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Unvan');
    DECLARE @Adres     NVARCHAR(150) = JSON_VALUE(@Kosullar, '$.Baslik.Adres');
    DECLARE @Ilce      NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Ilce');
    DECLARE @Il        NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Il');
    DECLARE @Vd        NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Vd');
    DECLARE @Vno       NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Vno');
    DECLARE @FiyatLst  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FiyatListesi') AS INT);
    DECLARE @EkstreKul BIT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EkstredeKullan') AS BIT);
    DECLARE @AcikKapali BIT     = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.AcikKapali') AS BIT);
    DECLARE @MasrafId  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.MasrafId') AS INT);
    DECLARE @FatDoviz  NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.FaturaDovizi');
    DECLARE @EkVergi   MONEY    = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EkVergi') AS MONEY);

    DECLARE @Yeni BIT = CASE WHEN ISNULL(@BelgeId, 0) = 0 THEN 1 ELSE 0 END;
    IF @Yeni = 1 AND (@Tur IS NULL OR @RehberId IS NULL)
        THROW 51001, N'Yeni belgede Baslik.Tur ve Baslik.RehberId zorunlu.', 1;
    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM FATBASLIK WHERE ID = @BelgeId)
        THROW 51002, N'Belge bulunamadi.', 1;

    -- ---- Satirlar ----
    DECLARE @S TABLE (
        Sira INT PRIMARY KEY, SatirId INT, Sil BIT, UrunId INT, Tur INT,
        Adet DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
        BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6), Kdv INT,
        Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
        Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), Izleme INT,
        SeriLot NVARCHAR(MAX), Islem NVARCHAR(10) NULL, YeniId INT NULL);
    INSERT @S (Sira, SatirId, Sil, UrunId, Tur, Adet, Miktar, Birim, BirimFiyat, Tutar, Kdv,
               Iskonto, Iskonto2, Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, DovizTutari,
               Aciklama, ProjeId, MasrafId, OzelKod, OzelKod2, Izleme, SeriLot)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
           ISNULL(J.ID, 0), ISNULL(J.Sil, 0), ISNULL(J.UrunId, 0), ISNULL(J.Tur, 1),
           ISNULL(J.Adet, 0), ISNULL(J.Miktar, ISNULL(J.Adet, 0)), ISNULL(J.Birim, 0),
           ISNULL(J.BirimFiyat, 0), J.Tutar, ISNULL(J.Kdv, 0),
           ISNULL(J.Iskonto, 0), ISNULL(J.Iskonto2, 0),
           ISNULL(J.Kur, N'TL'), ISNULL(J.DovizKuru, N'TL'),
           ISNULL(J.DovizBirimFiyat, 0), ISNULL(J.DovizKurDegeri, 1), ISNULL(J.DovizTutari, 0),
           ISNULL(J.Aciklama, N''), ISNULL(J.ProjeId, 0), ISNULL(J.MasrafId, 0),
           ISNULL(J.OzelKod, N''), ISNULL(J.OzelKod2, N''), ISNULL(J.Izleme, 0), J.SeriLot
    FROM OPENJSON(@Kosullar, '$.Satirlar')
         WITH (Sira INT, ID INT, Sil BIT, UrunId INT, Tur INT, Adet DECIMAL(18,6),
               Miktar DECIMAL(18,6), Birim INT, BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6),
               Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
               DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
               Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT, OzelKod NVARCHAR(50),
               OzelKod2 NVARCHAR(50), Izleme INT, SeriLot NVARCHAR(MAX) AS JSON) J;

    UPDATE @S SET Tutar = ROUND(ROUND(BirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE Tutar IS NULL;

    DECLARE @BelgeNo NVARCHAR(50) = @FaturaNo, @SilinenSatir INT = 0;

    BEGIN TRY
        BEGIN TRAN;

        IF @Yeni = 1
        BEGIN
            IF @BelgeNo IS NULL
            BEGIN
                DECLARE @Kocan INT = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                              WHERE TUR = @Tur AND SUBEID = -1
                                                AND CAST(BASLANGICTARIHI AS date) <= CAST(GETDATE() AS date)
                                              ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
                DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
                INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @Tur, @SubeID = -1,
                                                    @Kocanno = @Kocan, @BTarihi = @Tarih;
                SELECT TOP 1 @BelgeNo = BelgeNo, @FatSeri = ISNULL(@FatSeri, BelgeSeri) FROM @BN;
            END

            INSERT INTO FATBASLIK (TARIH, TUR, TIPI, REHBERID, PROJEID, FATURATARIH,
                                   FATURANO, FATURASERI, GIRISDEPO, CIKISDEPO,
                                   KDVDURUM, KUR, DOVIZ_CINSI, DOVIZKUR, RAPORDOVIZ, FATURADOVIZI,
                                   BASLIK, ADRES, ILCE, IL, VD, VNO,
                                   FIYAT_LISTESI, EKSTREDEKULLAN, ACIK_KAPALI, MASRAFID, EKVERGI,
                                   ACIKLAMA, OZELKOD, OZELKOD2, DURUM, VADE, SUBEID,
                                   EKLEYEN, EKLEMETARIHI, GIRISKAYNAK)
            VALUES (ISNULL(@Tarih, GETDATE()), @Tur, ISNULL(@Tipi, 1), @RehberId, ISNULL(@ProjeId, 0),
                    ISNULL(@FatTarih, ISNULL(@Tarih, GETDATE())),
                    @BelgeNo, @FatSeri, ISNULL(@GirisDepo, 0), ISNULL(@CikisDepo, 0),
                    ISNULL(@KdvDurum, N'Hariç'), ISNULL(@Kur, N'TL'), ISNULL(@DovizCins, N'TL'),
                    ISNULL(@DovizKur, 1), ISNULL(@RaporDvz, N'TL'), ISNULL(@FatDoviz, N'TL'),
                    @Unvan, @Adres, @Ilce, @Il, @Vd, @Vno,
                    @FiyatLst, ISNULL(@EkstreKul, 0), ISNULL(@AcikKapali, 0), @MasrafId, ISNULL(@EkVergi, 0),
                    ISNULL(@Aciklama, N''), ISNULL(@OzelKod, N''), ISNULL(@OzelKod2, N''),
                    ISNULL(@Durum, 0), ISNULL(@Vade, 0), @SubeId,
                    @KulId, GETDATE(), 1);
            SET @BelgeId = CAST(SCOPE_IDENTITY() AS INT);
        END
        ELSE
        BEGIN
            UPDATE FATBASLIK
               SET TARIH        = COALESCE(@Tarih, TARIH),
                   TUR          = COALESCE(@Tur, TUR),
                   TIPI         = COALESCE(@Tipi, TIPI),
                   REHBERID     = COALESCE(@RehberId, REHBERID),
                   PROJEID      = COALESCE(@ProjeId, PROJEID),
                   FATURATARIH  = COALESCE(@FatTarih, FATURATARIH),
                   FATURANO     = COALESCE(@FaturaNo, FATURANO),
                   FATURASERI   = COALESCE(@FatSeri, FATURASERI),
                   GIRISDEPO    = COALESCE(@GirisDepo, GIRISDEPO),
                   CIKISDEPO    = COALESCE(@CikisDepo, CIKISDEPO),
                   KDVDURUM     = COALESCE(@KdvDurum, KDVDURUM),
                   KUR          = COALESCE(@Kur, KUR),
                   DOVIZ_CINSI  = COALESCE(@DovizCins, DOVIZ_CINSI),
                   DOVIZKUR     = COALESCE(@DovizKur, DOVIZKUR),
                   RAPORDOVIZ   = COALESCE(@RaporDvz, RAPORDOVIZ),
                   FATURADOVIZI = COALESCE(@FatDoviz, FATURADOVIZI),
                   BASLIK       = COALESCE(@Unvan, BASLIK),
                   ADRES        = COALESCE(@Adres, ADRES),
                   ILCE         = COALESCE(@Ilce, ILCE),
                   IL           = COALESCE(@Il, IL),
                   VD           = COALESCE(@Vd, VD),
                   VNO          = COALESCE(@Vno, VNO),
                   FIYAT_LISTESI  = COALESCE(@FiyatLst, FIYAT_LISTESI),
                   EKSTREDEKULLAN = COALESCE(@EkstreKul, EKSTREDEKULLAN),
                   ACIK_KAPALI    = COALESCE(@AcikKapali, ACIK_KAPALI),
                   MASRAFID     = COALESCE(@MasrafId, MASRAFID),
                   EKVERGI      = COALESCE(@EkVergi, EKVERGI),
                   ACIKLAMA     = COALESCE(@Aciklama, ACIKLAMA),
                   OZELKOD      = COALESCE(@OzelKod, OZELKOD),
                   OZELKOD2     = COALESCE(@OzelKod2, OZELKOD2),
                   DURUM        = COALESCE(@Durum, DURUM),
                   VADE         = COALESCE(@Vade, VADE),
                   DEGISTIREN   = @KulId,
                   DEGISTIRMETARIHI = GETDATE()
             WHERE ID = @BelgeId;
            SELECT @BelgeNo = FATURANO, @Tur = TUR FROM FATBASLIK WHERE ID = @BelgeId;
        END

        DECLARE @HGir INT, @HCik INT;
        SELECT @HGir = ISNULL(GIRISDEPO, 0), @HCik = ISNULL(CIKISDEPO, 0),
               @Tur = TUR, @RehberId = REHBERID
        FROM FATBASLIK WHERE ID = @BelgeId;

        IF @SatirModu = N'tam'
        BEGIN
            DELETE FROM STOKIZLEME
             WHERE BASLIKID = @BelgeId
               AND SATIRID IN (SELECT ID FROM FATURA WHERE FATBASID = @BelgeId
                                AND ID NOT IN (SELECT SatirId FROM @S WHERE SatirId > 0));
            DELETE FROM FATURA
             WHERE FATBASID = @BelgeId
               AND ID NOT IN (SELECT SatirId FROM @S WHERE SatirId > 0);
            SET @SilinenSatir = @SilinenSatir + @@ROWCOUNT;
        END

        DECLARE @Sira INT, @SatirId INT, @Sil BIT, @UrunId INT, @SeriLot NVARCHAR(MAX);
        DECLARE @sl1 INT, @sl2 INT;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Sira, SatirId, Sil, UrunId, SeriLot FROM @S ORDER BY Sira;
        OPEN c; FETCH NEXT FROM c INTO @Sira, @SatirId, @Sil, @UrunId, @SeriLot;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @Sil = 1 AND @SatirId > 0
            BEGIN
                DELETE FROM STOKIZLEME WHERE BASLIKID = @BelgeId AND SATIRID = @SatirId;
                DELETE FROM FATURA WHERE ID = @SatirId AND FATBASID = @BelgeId;
                SET @SilinenSatir = @SilinenSatir + @@ROWCOUNT;
                UPDATE @S SET Islem = N'sil' WHERE Sira = @Sira;
            END
            ELSE IF @SatirId > 0
            BEGIN
                UPDATE F
                   SET F.TUR = S.Tur, F.URUNID = S.UrunId,
                       -- STOKID yalniz STOK satirinda (Tur<>0); masraf/gelir satirinda UrunId
                       -- bir MASRAFGELIR ID'sidir, stok referansina yazilmaz.
                       F.STOKID = CASE WHEN S.Tur = 0 THEN 0 ELSE S.UrunId END,
                       F.ACIKLAMA = S.Aciklama, F.ADET = S.Adet, F.MIKTAR = S.Miktar,
                       F.BIRIM = S.Birim, F.BIRIMFIYAT = S.BirimFiyat, F.TUTAR = S.Tutar,
                       F.KUR = S.Kur, F.ISKONTO = S.Iskonto, F.ISKONTO2 = S.Iskonto2,
                       F.KDV = S.Kdv, F.MASRAFID = S.MasrafId, F.OZELKOD = S.OzelKod,
                       F.OZELKOD2 = S.OzelKod2, F.DOVIZ_TUTARI = S.DovizTutari,
                       F.DOVIZ_KURU = S.DovizKuru, F.DOVIZ_BIRIMFIYAT = S.DovizBirimFiyat,
                       F.DOVIZKURDEGERI = S.DovizKurDegeri, F.PROJEID = S.ProjeId,
                       F.IZLEME = S.Izleme, F.DEGISTIREN = @KulId, F.DEGISTIRMETARIHI = GETDATE()
                FROM FATURA F INNER JOIN @S S ON S.Sira = @Sira
                WHERE F.ID = @SatirId AND F.FATBASID = @BelgeId;
                UPDATE @S SET Islem = N'guncelle', YeniId = @SatirId WHERE Sira = @Sira;
            END
            ELSE
            BEGIN
                INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, STOKID, ACIKLAMA, ADET, MIKTAR,
                                    BIRIM, BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV, MASRAFID,
                                    OZELKOD, OZELKOD2, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT,
                                    DOVIZKURDEGERI, PROJEID, IZLEME, SUBEID, EKLEYEN, EKLEMETARIHI,
                                    GIRDEPO, CIKDEPO, STOKDURUMDEGIS, GIRISKAYNAK)
                SELECT @BelgeId, @RehberId, S.Tur, S.UrunId,
                       CASE WHEN S.Tur = 0 THEN 0 ELSE S.UrunId END,
                       S.Aciklama, S.Adet, S.Miktar,
                       S.Birim, S.BirimFiyat, S.Tutar, S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                       S.OzelKod, S.OzelKod2, S.DovizTutari, S.DovizKuru, S.DovizBirimFiyat,
                       S.DovizKurDegeri, S.ProjeId, S.Izleme, @SubeId, @KulId, GETDATE(),
                       @HGir, @HCik, 1, 1
                FROM @S S WHERE S.Sira = @Sira;
                SET @SatirId = CAST(SCOPE_IDENTITY() AS INT);
                UPDATE @S SET Islem = N'ekle', YeniId = @SatirId WHERE Sira = @Sira;
            END

            IF @Sil = 0 AND @SeriLot IS NOT NULL AND @SatirId > 0
                EXEC dbo.sp_Api_Belge_SeriLot_Yaz_Ic
                     @BelgeId = @BelgeId, @SatirId = @SatirId, @UrunId = @UrunId,
                     @BelgeTur = @Tur, @SeriLotJson = @SeriLot,
                     @GirisDepo = @HGir, @CikisDepo = @HCik, @KulId = @KulId,
                     @Silinen = @sl1 OUTPUT, @Yazilan = @sl2 OUTPUT;

            FETCH NEXT FROM c INTO @Sira, @SatirId, @Sil, @UrunId, @SeriLot;
        END
        CLOSE c; DEALLOCATE c;

        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkV MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @BelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkV OUTPUT,
             @Neden = @TNeden OUTPUT, @Yazildi = @TYazildi OUTPUT;

        COMMIT;

        SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @BelgeNo AS BelgeNo, @Yeni AS Yeni,
                       @SilinenSatir AS SilinenSatir,
                       (SELECT Sira, ISNULL(YeniId, SatirId) AS ID, Islem
                          FROM @S ORDER BY Sira FOR JSON PATH) AS Satirlar,
                       (SELECT @Matrah AS Matrah, @Kdv AS Kdv, @Toplam AS Toplam,
                               @Doviz AS Doviz, @TNeden AS Neden
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Toplam
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

GRANT EXECUTE ON dbo.sp_Api_Belge_Kaydet_Json TO gentegre_api;
GO
