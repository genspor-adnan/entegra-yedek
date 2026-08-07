-- ============================================================
-- GenDepoUpdate78.sql
-- API F grubu: sp_Api_Belge_Kaydet_Json  -- belge BUTUNU tek cagri/tek transaction
--   + dbo.sp_Api_Belge_SeriLot_Yaz_Ic (ic yardimci; SeriLot_Yaz_Json artik sarmalayici)
--
-- YERINE GECER: TM_FATBASLIKGuncelle (38 parametre) + TM_FATURAGir (33 parametre).
--   Bugun istemci once basligi kaydediyor, sonra HER SATIR icin ayri cagri
--   yapiyor; basligin toplamlari her satir cagrisinda bastan hesaplaniyor
--   (n satirda n kez tam tarama) ve hicbiri transaction icinde degil.
--
-- ACIK-DEGERLI SOZLESME (Donusum_Uygula ile ayni): SP fiyat/iskonto/KDV
--   HESAPLAMAZ; degerleri cagiran gonderir. TUTAR verilmezse karar 1'e gore
--   hesaplanir: round(round(BirimFiyat*Adet,2)*(100-Isk1)*(100-Isk2)/10000, 2).
--
-- DUZELTILEN KUSURLAR (TM'ye gore)
--   1) INSERT ve UPDATE AYNI kolon kumesini yazar. TM'de UPDATE VD/VNO,
--      INSERT ID_VERGIDAI/ID_VERGINO dolduruyordu - ayni belge kaydetme yoluna
--      gore farkli alanlara yaziliyordu.
--   2) SCOPE_IDENTITY() (TM: @@IDENTITY - tetikleyici baska tabloya yazarsa
--      yanlis ID doner).
--   3) Tek transaction; hata halinde tam geri alma (TM'de transaction yok,
--      CATCH hatayi SONUC KUMESI olarak donduruyordu).
--   4) Miktar/adet DECIMAL(18,6) (TM: int -> kusurat sessizce kirpiliyordu).
--   5) Silme sihirli string ile degil, satirda "Sil":true alaniyla.
--   6) Baslik guncellemede gonderilmeyen alan EZILMEZ (COALESCE ile mevcut
--      deger korunur); TM tum alanlari kosulsuz yaziyordu.
--
-- SATIR MODU
--   "delta" (varsayilan): yalniz gelen satirlar islenir (ID>0 guncelle,
--                         ID yok/0 ekle, "Sil":true sil)
--   "tam"              : ek olarak, gonderilmeyen mevcut satirlar SILINIR
--
-- GIRDI:
--   {"Surum":1,"SatirModu":"delta","Oturum":{"KulId":5,"SubeId":-1},
--    "Baslik":{"ID":0,"Tur":14,"Tipi":1,"Tarih":"2026-08-08","FaturaTarih":"2026-08-08",
--              "RehberId":1874,"GirisDepo":0,"CikisDepo":3,"KdvDurum":"Hariç",
--              "Kur":"TL","DovizCinsi":"TL","DovizKur":1,"RaporDoviz":"TL",
--              "Aciklama":"","OzelKod":"","OzelKod2":"","ProjeId":0,"Vade":0,
--              "FaturaNo":null,"FaturaSeri":null},
--    "Satirlar":[{"Sira":1,"ID":0,"UrunId":505,"Tur":1,"Adet":2.75,"Miktar":2.75,
--                 "Birim":51,"BirimFiyat":150,"Kdv":20,"Iskonto":0,"Iskonto2":0,
--                 "Kur":"TL","DovizKuru":"TL","Aciklama":"","ProjeId":0,
--                 "SeriLot":[{"Sira":1,"SeriNo":"A1","LotNo":"L1","Kalan":2.75}]},
--                {"Sira":2,"ID":991,"Sil":true}]}
--   Baslik.ID = 0/yok -> YENI belge; belge no verilmezse sp_BelgeNoGetir uretir.
-- CIKTI:
--   {"Sonuc":1,"BelgeId":..,"BelgeNo":"..","Yeni":1,
--    "Satirlar":[{"Sira":1,"ID":9001,"Islem":"ekle"}],
--    "SilinenSatir":n,"Toplam":{...},"Durum":{...}}
-- HATA: 51001 girdi, 51002 belge bulunamadi
--
-- NOT: Bu SP icinde "INSERT ... EXEC sp_BelgeNoGetir" vardir; dolayisiyla
--   BU SP'nin kendisi INSERT..EXEC ile cagrilamaz (ic ice INSERT EXEC yasak).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- Seri/lot: ic yardimci (sonuc kumesi DONDURMEZ)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_SeriLot_Yaz_Ic
    @BelgeId        INT,
    @SatirId        INT,
    @UrunId         INT,
    @BelgeTur       INT,
    @SeriLotJson    NVARCHAR(MAX),
    @IslemTip       INT = 0,
    @IzlemTur       INT = 0,
    @GirisDepo      INT = 0,
    @CikisDepo      INT = 0,
    @StokDurumDegis BIT = 1,
    @KaynakSatirId  INT = 0,
    @KulId          INT = 0,
    @Silinen        INT OUTPUT,
    @Yazilan        INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Silinen = 0; SET @Yazilan = 0;

    DECLARE @S TABLE (Sira INT PRIMARY KEY, SeriNo NVARCHAR(100), LotNo NVARCHAR(100),
                      Urt DATE, Skt DATE, Kalan FLOAT, Durum FLOAT, IzlemId INT,
                      SeriLotId INT NULL, YeniIzlem INT NULL);
    INSERT @S (Sira, SeriNo, LotNo, Urt, Skt, Kalan, Durum, IzlemId)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
           ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''),
           ISNULL(J.Urt, '1990-01-01'), ISNULL(J.Skt, '1990-01-01'),
           ISNULL(J.Kalan, 0), ISNULL(J.Durum, 0), ISNULL(J.IzlemId, 0)
    FROM OPENJSON(ISNULL(@SeriLotJson, N'[]'))
         WITH (Sira INT, SeriNo NVARCHAR(100), LotNo NVARCHAR(100),
               Urt DATE, Skt DATE, Kalan FLOAT, Durum FLOAT, IzlemId INT) J;

    SELECT @Silinen = COUNT(*) FROM STOKIZLEME
     WHERE STOKID = @UrunId AND BASLIKID = @BelgeId AND SATIRID = @SatirId;
    DELETE FROM STOKIZLEME
     WHERE STOKID = @UrunId AND BASLIKID = @BelgeId AND SATIRID = @SatirId;

    IF NOT EXISTS (SELECT 1 FROM @S) RETURN;

    UPDATE S SET SeriLotId = X.ID
    FROM @S S
    CROSS APPLY (SELECT TOP 1 SL.ID FROM STOKSERILOT SL
                  WHERE SL.STOKID = @UrunId AND SL.SERINO = S.SeriNo AND SL.LOTNO = S.LotNo
                  ORDER BY SL.ID) X;

    DECLARE @Sira INT, @Yeni INT;
    DECLARE cS CURSOR LOCAL FAST_FORWARD FOR SELECT Sira FROM @S WHERE SeriLotId IS NULL ORDER BY Sira;
    OPEN cS; FETCH NEXT FROM cS INTO @Sira;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
        SELECT @UrunId, SeriNo, LotNo, Urt, Skt FROM @S WHERE Sira = @Sira;
        SET @Yeni = CAST(SCOPE_IDENTITY() AS INT);
        UPDATE @S SET SeriLotId = @Yeni WHERE Sira = @Sira;
        FETCH NEXT FROM cS INTO @Sira;
    END
    CLOSE cS; DEALLOCATE cS;

    DECLARE @Kalan FLOAT, @Fark FLOAT, @DonusId INT, @SeriLotId INT, @IzlemId INT, @DepoKalan FLOAT;
    DECLARE cI CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Kalan, Durum, IzlemId, SeriLotId FROM @S ORDER BY Sira;
    OPEN cI; FETCH NEXT FROM cI INTO @Sira, @Kalan, @Fark, @DonusId, @SeriLotId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Fark    = CASE WHEN @BelgeTur = 99 THEN @Kalan - @Fark ELSE @Kalan END;
        SET @DonusId = CASE WHEN @KaynakSatirId > 0 THEN ISNULL(@DonusId, 0) ELSE 0 END;

        INSERT INTO STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                KALAN, ADET, EKLEYEN, DONUSID, SERILOTID)
        VALUES (@UrunId, @BelgeTur, @BelgeId, @SatirId, @IzlemTur,
                @Fark, @Kalan, @KulId, @DonusId, @SeriLotId);
        SET @IzlemId = CAST(SCOPE_IDENTITY() AS INT);
        SET @Yazilan = @Yazilan + 1;

        SET @DepoKalan = @Kalan;
        IF @StokDurumDegis = 0 OR @BelgeTur = 99 SET @DepoKalan = 0;

        IF @BelgeTur IN (4, 14, 15, 16, 119, 20, 101)
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @CikisDepo, -1.0 * @DepoKalan);
        ELSE
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @GirisDepo, @DepoKalan);

        IF @BelgeTur IN (119, 20)
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @GirisDepo, @DepoKalan);
        ELSE IF @BelgeTur = 109 AND @IslemTip = 2
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @CikisDepo, -1.0 * @DepoKalan);

        FETCH NEXT FROM cI INTO @Sira, @Kalan, @Fark, @DonusId, @SeriLotId;
    END
    CLOSE cI; DEALLOCATE cI;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_SeriLot_Yaz_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @SatirId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SatirId') AS INT);
    DECLARE @UrunId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.UrunId')  AS INT);
    DECLARE @BelgeTur INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeTur') AS INT);
    DECLARE @IslemTip INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.IslemTip') AS INT), 0);
    DECLARE @IzlemTur INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.IzlemTur') AS INT), 0);
    DECLARE @GirisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GirisDepo') AS INT), 0);
    DECLARE @CikisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.CikisDepo') AS INT), 0);
    DECLARE @KaynakSatirId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakSatirId') AS INT), 0);
    DECLARE @StokDurumDegis BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.StokDurumDegis') AS BIT), 1);
    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @SeriLot NVARCHAR(MAX) = JSON_QUERY(@Kosullar, '$.SeriLot');

    IF @BelgeId IS NULL OR @SatirId IS NULL OR @UrunId IS NULL OR @BelgeTur IS NULL
        THROW 51001, N'BelgeId, SatirId, UrunId ve BelgeTur zorunlu.', 1;
    IF NOT EXISTS (SELECT 1 FROM FATURA WHERE ID = @SatirId AND FATBASID = @BelgeId)
        THROW 51002, N'Belge satiri bulunamadi.', 1;

    DECLARE @Sil INT, @Yaz INT;
    BEGIN TRY
        BEGIN TRAN;
        EXEC dbo.sp_Api_Belge_SeriLot_Yaz_Ic
             @BelgeId = @BelgeId, @SatirId = @SatirId, @UrunId = @UrunId, @BelgeTur = @BelgeTur,
             @SeriLotJson    = @SeriLot,
             @IslemTip       = @IslemTip,
             @IzlemTur       = @IzlemTur,
             @GirisDepo      = @GirisDepo,
             @CikisDepo      = @CikisDepo,
             @StokDurumDegis = @StokDurumDegis,
             @KaynakSatirId  = @KaynakSatirId,
             @KulId          = @KulId,
             @Silinen = @Sil OUTPUT, @Yazilan = @Yaz OUTPUT;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @SatirId AS SatirId,
                   @Sil AS Silinen, @Yaz AS Yazilan
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ============================================================
-- Belge kaydet
-- ============================================================
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
            -- Belge no: verilmediyse kocan uzerinden uretilir (sp_BelgeNoGetir)
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
                                   KDVDURUM, KUR, DOVIZ_CINSI, DOVIZKUR, RAPORDOVIZ,
                                   ACIKLAMA, OZELKOD, OZELKOD2, DURUM, VADE, SUBEID,
                                   EKLEYEN, EKLEMETARIHI, GIRISKAYNAK)
            VALUES (ISNULL(@Tarih, GETDATE()), @Tur, ISNULL(@Tipi, 1), @RehberId, ISNULL(@ProjeId, 0),
                    ISNULL(@FatTarih, ISNULL(@Tarih, GETDATE())),
                    @BelgeNo, @FatSeri, ISNULL(@GirisDepo, 0), ISNULL(@CikisDepo, 0),
                    ISNULL(@KdvDurum, N'Hariç'), ISNULL(@Kur, N'TL'), ISNULL(@DovizCins, N'TL'),
                    ISNULL(@DovizKur, 1), ISNULL(@RaporDvz, N'TL'),
                    ISNULL(@Aciklama, N''), ISNULL(@OzelKod, N''), ISNULL(@OzelKod2, N''),
                    ISNULL(@Durum, 0), ISNULL(@Vade, 0), @SubeId,
                    @KulId, GETDATE(), 1);
            SET @BelgeId = CAST(SCOPE_IDENTITY() AS INT);
        END
        ELSE
        BEGIN
            -- Gonderilmeyen alan EZILMEZ (COALESCE ile mevcut deger korunur)
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

        -- ---- SatirModu = tam: gonderilmeyen mevcut satirlari sil ----
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

        -- ---- Satirlar ----
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
                   SET F.TUR = S.Tur, F.URUNID = S.UrunId, F.STOKID = S.UrunId,
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
                SELECT @BelgeId, @RehberId, S.Tur, S.UrunId, S.UrunId, S.Aciklama, S.Adet, S.Miktar,
                       S.Birim, S.BirimFiyat, S.Tutar, S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                       S.OzelKod, S.OzelKod2, S.DovizTutari, S.DovizKuru, S.DovizBirimFiyat,
                       S.DovizKurDegeri, S.ProjeId, S.Izleme, @SubeId, @KulId, GETDATE(),
                       @HGir, @HCik, 1, 1
                FROM @S S WHERE S.Sira = @Sira;
                SET @SatirId = CAST(SCOPE_IDENTITY() AS INT);
                UPDATE @S SET Islem = N'ekle', YeniId = @SatirId WHERE Sira = @Sira;
            END

            -- Seri/lot (varsa) - satir silinmediyse
            IF @Sil = 0 AND @SeriLot IS NOT NULL AND @SatirId > 0
                EXEC dbo.sp_Api_Belge_SeriLot_Yaz_Ic
                     @BelgeId = @BelgeId, @SatirId = @SatirId, @UrunId = @UrunId,
                     @BelgeTur = @Tur, @SeriLotJson = @SeriLot,
                     @GirisDepo = @HGir, @CikisDepo = @HCik, @KulId = @KulId,
                     @Silinen = @sl1 OUTPUT, @Yazilan = @sl2 OUTPUT;

            FETCH NEXT FROM c INTO @Sira, @SatirId, @Sil, @UrunId, @SeriLot;
        END
        CLOSE c; DEALLOCATE c;

        -- ---- Toplamlar + durum ----
        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkVergi MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @BelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkVergi OUTPUT,
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

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_Kaydet_Json TO gentegre_api;
GRANT EXECUTE ON dbo.sp_Api_Belge_SeriLot_Yaz_Json TO gentegre_api;
GO
