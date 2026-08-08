-- ============================================================
-- GenDepoUpdate88.sql
-- BELGE DONUSUM - KODLAMA ADIM 1: sp_Api_Belge_Kaydet_Json genisletmesi
--
-- Donusum akisi belge uretimi icin YENI nesne yazmayacak; kanonik yol olan bu
--   SP'yi cagiracak (bkz. BelgeDonusum_Veri_Sozlesmesi.txt bolum 0).
--   Bunun icin Kaydet'e eksik ALANLAR ve bir OUTPUT parametresi eklendi.
--   HICBIR MEVCUT DAVRANIS DEGISMEDI: tum yeni alanlar opsiyonel, gonderilmezse
--   eski degerler/varsayilanlar yaziliyor; @BelgeIdOut varsayilanli oldugu icin
--   tek parametreyle cagiran mevcut kod (Ubelgegiris, Delphi) etkilenmiyor.
--
-- EKLENEN BASLIK ALANLARI
--   KocanNo, Senaryo, EFaturaDurum, EFaturaSonuc, AktiviteId, RehberIletId,
--   ServisId, DetayBolumu, SaticiKodu
--   (K3: EFATURADURUM varsayilani 0. K4: EFATURASONUC varsayilani 0 - eski
--    akistaki "satis rotalarinda 20" kurali kaldirildi, TUM rotalar icin 0.)
--
-- EKLENEN SATIR ALANLARI
--   Yeri, YerId  <-- DONUSUM BAGI. Hedef satirin hangi donusum turuyle hangi
--                    kaynak satirdan uretildigini tutar; kalan hesabinin
--                    (KalanGrubu) dayandigi tek bilgi budur.
--   PozNo, StokDurumDegis, EkipmanId, Mf, MuhKodu, Kasa, OtvYuzde, OtvMiktar,
--   IzlemeKodu, Vade, KampanyaId, KdvMuafiyeti
--
--   KAPSAM DISI - EN/BOY/YUZEY/SAYI ve TESLIMTARIHI:
--     Bu kolonlar FATURA tablosunda YOK (dogrulandi). EN/BOY/YUZEY/SAYI
--     "en-boy hesaplama" opsiyonu ile gelen musteri kolonlaridir; eski Delphi
--     kodu bunlari SQL'e KOSULLU olarak ekliyordu (EnBoyHesaplamaAktif).
--     TESLIMTARIHI ise SIPARISDETAY/TEKLIFDETAY/SATINALMADETAY'a ait; Kaydet
--     FATURA yazdigi icin ilgisiz. Bu alanlar statik SQL'e konamaz - opsiyonu
--     kullanan musterilerde ayri bir cozum gerekir (ayri karar)
--   StokDurumDegis gonderilmezse 1 (eski davranis) - iki kez stok dusmemesi
--   gereken rotalarda cagiran 0 gonderir.
--
-- EKLENEN PARAMETRE
--   @BelgeIdOut INT = NULL OUTPUT
--   Kaydet kendi icinde INSERT...EXEC kullaniyor (sp_BelgeNoGetir), bu yuzden
--   disaridan "INSERT @T EXEC sp_Api_Belge_Kaydet_Json" ile sarmalanamaz
--   (INSERT...EXEC ic ice gecmez). Cagiran SP yeni belge ID'sini bu parametreden
--   alir; sonuc JSON'u aynen donmeye devam eder.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Kaydet_Json
    @Kosullar    NVARCHAR(MAX),
    -- Cagiran SP icinden yeni belge ID'sini almak icin. Bu SP kendi icinde
    --   INSERT...EXEC kullaniyor (sp_BelgeNoGetir), bu yuzden disaridan
    --   INSERT...EXEC ile sarmalanamaz -> OUTPUT parametresi.
    --   Tek parametreyle cagiran mevcut kod ETKILENMEZ.
    @BelgeIdOut  INT = NULL OUTPUT
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

    -- Baslikta ID DISINDA alan gonderilmis mi? (Ubelgegiris'in 2. cagrisi gibi
    --   "sadece satir yaz" isteklerinde gereksiz "degistirme" logu olusmasin.)
    --   DIKKAT: @Tur/@BelgeNo asagida UPDATE sonrasi tablodan YENIDEN okunuyor;
    --   bu bayrak MUTLAKA o ezilmeden once hesaplanmali.
    DECLARE @BaslikAlanVar BIT =
        CASE WHEN @Tarih IS NOT NULL OR @Tur IS NOT NULL OR @Tipi IS NOT NULL
                  OR @RehberId IS NOT NULL OR @FatTarih IS NOT NULL OR @FaturaNo IS NOT NULL
                  OR @FatSeri IS NOT NULL OR @GirisDepo IS NOT NULL OR @CikisDepo IS NOT NULL
                  OR @KdvDurum IS NOT NULL OR @Kur IS NOT NULL OR @DovizCins IS NOT NULL
                  OR @DovizKur IS NOT NULL OR @RaporDvz IS NOT NULL OR @Aciklama IS NOT NULL
                  OR @OzelKod IS NOT NULL OR @OzelKod2 IS NOT NULL OR @ProjeId IS NOT NULL
                  OR @Vade IS NOT NULL OR @Durum IS NOT NULL OR @Unvan IS NOT NULL
                  OR @Adres IS NOT NULL OR @Ilce IS NOT NULL OR @Il IS NOT NULL
                  OR @Vd IS NOT NULL OR @Vno IS NOT NULL OR @FiyatLst IS NOT NULL
                  OR @EkstreKul IS NOT NULL OR @AcikKapali IS NOT NULL OR @MasrafId IS NOT NULL
                  OR @FatDoviz IS NOT NULL OR @EkVergi IS NOT NULL
             THEN 1 ELSE 0 END;

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
        SeriLot NVARCHAR(MAX), Islem NVARCHAR(10) NULL, YeniId INT NULL,
        -- ---- Donusum akisi icin ek satir alanlari (opsiyonel) ----
        --   Yeri/YerId DONUSUM BAGIDIR: hedef satir hangi donusum turuyle
        --   hangi kaynak satirdan uretildi. Kalan hesabi buna dayanir.
        Yeri INT NULL, YerId INT NULL, PozNo INT NULL, StokDurumDegis INT NULL,
        EkipmanId INT NULL, Mf INT NULL, MuhKodu NVARCHAR(50) NULL, Kasa INT NULL,
        OtvYuzde FLOAT NULL, OtvMiktar DECIMAL(18,6) NULL, IzlemeKodu NVARCHAR(50) NULL,
        Vade INT NULL, KampanyaId INT NULL, KdvMuafiyeti INT NULL);
    INSERT @S (Sira, SatirId, Sil, UrunId, Tur, Adet, Miktar, Birim, BirimFiyat, Tutar, Kdv,
               Iskonto, Iskonto2, Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, DovizTutari,
               Aciklama, ProjeId, MasrafId, OzelKod, OzelKod2, Izleme, SeriLot,
               Yeri, YerId, PozNo, StokDurumDegis, EkipmanId, Mf, MuhKodu, Kasa,
               OtvYuzde, OtvMiktar, IzlemeKodu, Vade, KampanyaId, KdvMuafiyeti)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
           ISNULL(J.ID, 0), ISNULL(J.Sil, 0), ISNULL(J.UrunId, 0), ISNULL(J.Tur, 1),
           ISNULL(J.Adet, 0), ISNULL(J.Miktar, ISNULL(J.Adet, 0)), ISNULL(J.Birim, 0),
           ISNULL(J.BirimFiyat, 0), J.Tutar, ISNULL(J.Kdv, 0),
           ISNULL(J.Iskonto, 0), ISNULL(J.Iskonto2, 0),
           ISNULL(J.Kur, N'TL'), ISNULL(J.DovizKuru, N'TL'),
           ISNULL(J.DovizBirimFiyat, 0), ISNULL(J.DovizKurDegeri, 1), ISNULL(J.DovizTutari, 0),
           ISNULL(J.Aciklama, N''), ISNULL(J.ProjeId, 0), ISNULL(J.MasrafId, 0),
           ISNULL(J.OzelKod, N''), ISNULL(J.OzelKod2, N''), ISNULL(J.Izleme, 0), J.SeriLot,
           J.Yeri, J.YerId, J.PozNo, J.StokDurumDegis, J.EkipmanId, J.Mf,
           J.MuhKodu, J.Kasa, J.OtvYuzde, J.OtvMiktar, J.IzlemeKodu, J.Vade,
           J.KampanyaId, J.KdvMuafiyeti
    FROM OPENJSON(@Kosullar, '$.Satirlar')
         WITH (Sira INT, ID INT, Sil BIT, UrunId INT, Tur INT, Adet DECIMAL(18,6),
               Miktar DECIMAL(18,6), Birim INT, BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6),
               Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
               DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
               Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT, OzelKod NVARCHAR(50),
               OzelKod2 NVARCHAR(50), Izleme INT,
                   Yeri INT, YerId INT, PozNo INT, StokDurumDegis INT, EkipmanId INT, Mf INT,
                   MuhKodu NVARCHAR(50), Kasa INT, OtvYuzde FLOAT, OtvMiktar DECIMAL(18,6),
                   IzlemeKodu NVARCHAR(50), Vade INT, KampanyaId INT, KdvMuafiyeti INT,
                   SeriLot NVARCHAR(MAX) AS JSON) J;

    UPDATE @S SET Tutar = ROUND(ROUND(BirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE Tutar IS NULL;

    -- ---- Donusum akisinin ihtiyac duydugu ek baslik alanlari ----
    --   Hepsi OPSIYONEL; gonderilmezse eski davranis aynen korunur.
    DECLARE @KocanNo      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.KocanNo')      AS INT);
    DECLARE @Senaryo      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Senaryo')      AS INT);
    DECLARE @EFatDurum    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EFaturaDurum') AS INT);
    DECLARE @EFatSonuc    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EFaturaSonuc') AS INT);
    DECLARE @AktiviteId   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.AktiviteId')   AS INT);
    DECLARE @RehberIletId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberIletId') AS INT);
    DECLARE @ServisId     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ServisId')     AS INT);
    DECLARE @SaticiKodu   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SaticiKodu')   AS INT);
    DECLARE @DetayBolumu  NVARCHAR(MAX) = JSON_VALUE(@Kosullar, '$.Baslik.DetayBolumu');

    DECLARE @BelgeNo NVARCHAR(50) = @FaturaNo, @SilinenSatir INT = 0;
    DECLARE @TabKart INT, @TabDetay INT, @LogN INT, @Loglanan INT = 0;

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
                                   KOCANNO, SENARYO, EFATURADURUM, EFATURASONUC, AKTIVITEID,
                                   REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
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
                    ISNULL(@KocanNo, 0), ISNULL(@Senaryo, 1),
                    -- K3/K4: EFATURADURUM ve EFATURASONUC varsayilani 0.
                    ISNULL(@EFatDurum, 0), ISNULL(@EFatSonuc, 0), ISNULL(@AktiviteId, -1),
                    @RehberIletId, ISNULL(@ServisId, -1), @DetayBolumu, @SaticiKodu,
                    @KulId, GETDATE(), 1);
            SET @BelgeId = CAST(SCOPE_IDENTITY() AS INT);
            -- ISLEMLOG: kart EKLEME
            SET @TabKart = dbo.fn_Api_Belge_TabNo(@Tur, 0);
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @BelgeId,
                 @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @BelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
            SET @Loglanan = @Loglanan + @LogN;
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
            -- ISLEMLOG: kart DEGISTIRME. Yalniz baslik alani gonderilmis cagrilarda
            --   (Ubelgegiris'in 2. cagrisi gibi "sadece satir yaz") gereksiz satir
            --   olusmasin diye, baslikta ID disinda alan varsa loglanir.
            IF @BaslikAlanVar = 1
            BEGIN
                SET @TabKart = dbo.fn_Api_Belge_TabNo(@Tur, 0);
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @BelgeId,
                     @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 2, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
            END
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

        SET @TabKart  = dbo.fn_Api_Belge_TabNo(@Tur, 0);
        SET @TabDetay = dbo.fn_Api_Belge_TabNo(@Tur, 1);

        DECLARE @Sira INT, @SatirId INT, @Sil BIT, @UrunId INT, @SeriLot NVARCHAR(MAX);
        DECLARE @sl1 INT, @sl2 INT;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Sira, SatirId, Sil, UrunId, SeriLot FROM @S ORDER BY Sira;
        OPEN c; FETCH NEXT FROM c INTO @Sira, @SatirId, @Sil, @UrunId, @SeriLot;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @Sil = 1 AND @SatirId > 0
            BEGIN
                -- ISLEMLOG: satir SILME - SILMEDEN ONCE (Geri Al buna bagli)
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @SatirId,
                     @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 0, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
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
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @SatirId,
                     @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 2, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
            END
            ELSE
            BEGIN
                INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, STOKID, ACIKLAMA, ADET, MIKTAR,
                                    BIRIM, BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV, MASRAFID,
                                    OZELKOD, OZELKOD2, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT,
                                    DOVIZKURDEGERI, PROJEID, IZLEME, SUBEID, EKLEYEN, EKLEMETARIHI,
                                    GIRDEPO, CIKDEPO, STOKDURUMDEGIS, GIRISKAYNAK,
                                    YERI, YERID, POZNO, EKIPMANID, MF, MUHKODU, KASA,
                                    OTVYUZDE, OTVMIKTAR, IZLEMEKODU, VADE, KAMPANYAID,
                                    KDVMUHAFIYETI)
                SELECT @BelgeId, @RehberId, S.Tur, S.UrunId,
                       CASE WHEN S.Tur = 0 THEN 0 ELSE S.UrunId END,
                       S.Aciklama, S.Adet, S.Miktar,
                       S.Birim, S.BirimFiyat, S.Tutar, S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                       S.OzelKod, S.OzelKod2, S.DovizTutari, S.DovizKuru, S.DovizBirimFiyat,
                       S.DovizKurDegeri, S.ProjeId, S.Izleme, @SubeId, @KulId, GETDATE(),
                       @HGir, @HCik, ISNULL(S.StokDurumDegis, 1), 1,
                       S.Yeri, S.YerId, S.PozNo, S.EkipmanId, S.Mf, S.MuhKodu, S.Kasa,
                       S.OtvYuzde, S.OtvMiktar, S.IzlemeKodu, S.Vade, S.KampanyaId,
                       S.KdvMuafiyeti
                FROM @S S WHERE S.Sira = @Sira;
                SET @SatirId = CAST(SCOPE_IDENTITY() AS INT);
                UPDATE @S SET Islem = N'ekle', YeniId = @SatirId WHERE Sira = @Sira;
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @SatirId,
                     @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
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

        SET @BelgeIdOut = @BelgeId;
        COMMIT;

        SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @BelgeNo AS BelgeNo, @Yeni AS Yeni,
                       @SilinenSatir AS SilinenSatir, @Loglanan AS Loglanan,
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
