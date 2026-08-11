-- ============================================================
-- GenDepoUpdate131.sql
-- IPTAL (DURUM=6) kaynak belge DONUSMEZ - sunucu tarafi guvence
--
--   Kural GenDepoUpdate130'da tanimlandi (fn_Prog_Donusum_KaynakDonusebilirMi).
--   Burada donusum API'leri o kurali UYGULAR: iptal edilmis kaynaktan satir
--   donusturulmek istenirse islem REDDEDILIR (51201). Boylece ekran/mobil
--   hangi yoldan gelirse gelsin (liste, belge icindeki "donustur" butonu,
--   mobil istek) iptal belge zincire giremez.
--
--   Kaynak satir -> kaynak belge cozumu KAYNAK turune gore:
--     1 teklif  -> TEKLIFDETAY.TEKLIFID   (TEKLIF karti; iptal alani yok, atlanir)
--     2 siparis -> SIPARISDETAY.SIPARISID (SIPARIS.DURUM)
--     3 belge   -> FATURA.FATBASID        (FATBASLIK.DURUM)
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_KaynakIptalKontrol_Ic
    @Kaynak   INT,                 -- 1 teklif / 2 siparis / 3 belge
    @SatirIds NVARCHAR(MAX)        -- virgullu satir ID listesi (fn_SplitString)
AS
BEGIN
    SET NOCOUNT ON;
    IF @Kaynak NOT IN (2, 3) RETURN;          -- teklifte iptal durumu yok

    DECLARE @Iptal NVARCHAR(200);

    IF @Kaynak = 2
        SELECT TOP 1 @Iptal = CAST(S.SIPARISNO AS nvarchar(50))
        FROM SIPARISDETAY SD
             INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
        WHERE SD.ID IN (SELECT TRY_CAST(value AS INT) FROM dbo.fn_SplitString(@SatirIds, ','))
          AND dbo.fn_Prog_Donusum_KaynakDonusebilirMi('SIPARIS', S.ID) = 0;
    ELSE
        SELECT TOP 1 @Iptal = CAST(FB.FATURANO AS nvarchar(50))
        FROM FATURA F
             INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
        WHERE F.ID IN (SELECT TRY_CAST(value AS INT) FROM dbo.fn_SplitString(@SatirIds, ','))
          AND dbo.fn_Prog_Donusum_KaynakDonusebilirMi('FATBASLIK', FB.ID) = 0;

    IF @Iptal IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR(300) =
            N'Kaynak belge iptal edilmiş (' + @Iptal + N'), dönüştürülemez.';
        THROW 51201, @m, 1;
    END
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Donusum_KaynakIptalKontrol_Ic TO gentegre_api;
GO

-- ---- Donusum API'lerine IPTAL kontrolu (sunucu tarafi guvence) ----
--   Kaynak belge iptal edilmisse (DURUM=6) hem KONTROL hem UYGULA reddeder.
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_Kontrol_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kaynak')      AS INT);
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru') AS INT);
    DECLARE @HedefUretim BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefUretim') AS BIT), 0);

    IF @Kaynak IS NULL OR @Kaynak NOT IN (1, 2, 3)
        THROW 51001, N'Kaynak 1 (teklif), 2 (siparis) ya da 3 (belge) olmali.', 1;
    IF @DonusumTuru IS NULL
        THROW 51001, N'DonusumTuru zorunlu.', 1;

    DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6));
    INSERT @S (SatirId, Adet)
    SELECT J.SatirId, ISNULL(J.Adet, 0)
    FROM OPENJSON(@Kosullar, '$.Satirlar') WITH (SatirId INT, Adet DECIMAL(18,6)) J
    WHERE J.SatirId IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @S)
        THROW 51001, N'Satirlar bos olamaz.', 1;
    -- IPTAL kaynak DONUSMEZ (GenDepoUpdate130/131): satirlarin bagli oldugu
    --   kaynak belge iptal edilmisse islem burada durur (51201).
    DECLARE @Ids NVARCHAR(MAX) =
        STUFF((SELECT ',' + CAST(SatirId AS nvarchar(20)) FROM @S FOR XML PATH('')), 1, 1, '');
    EXEC dbo.sp_Api_Donusum_KaynakIptalKontrol_Ic @Kaynak = @Kaynak, @SatirIds = @Ids;


    DECLARE @R TABLE (SatirId INT, Adet DECIMAL(18,6), Kalan DECIMAL(18,6),
                      Uygun BIT, Neden NVARCHAR(60));
    INSERT @R (SatirId, Adet, Kalan, Uygun, Neden)
    SELECT S.SatirId, S.Adet, ISNULL(K.Kalan, 0),
           CASE WHEN K.Kalan IS NULL THEN 0
                WHEN S.Adet <= 0 THEN 0
                -- 0.0001 toleransi UBelgeDonusum.BtnSecClick ile ayni
                WHEN S.Adet > K.Kalan + 0.0001 THEN 0
                ELSE 1 END,
           CASE WHEN K.Kalan IS NULL THEN N'kaynak satir bulunamadi'
                WHEN S.Adet <= 0 THEN N'adet sifir/negatif'
                WHEN S.Adet > ISNULL(K.Kalan, 0) + 0.0001 THEN N'kalan yetersiz'
                ELSE N'' END
    FROM @S S
    OUTER APPLY dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, S.SatirId, @HedefUretim) K;

    DECLARE @Uygun BIT = CASE WHEN EXISTS (SELECT 1 FROM @R WHERE Uygun = 0) THEN 0 ELSE 1 END;

    SELECT (SELECT 1 AS Sonuc, @Uygun AS Uygun,
                   (SELECT SatirId, Adet, Kalan, Uygun, Neden FROM @R ORDER BY SatirId FOR JSON PATH) AS Satirlar
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

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
    -- IPTAL kaynak DONUSMEZ: satir listesi asagida dolduruluyor; kontrol
    --   satirlar hazir olur olmaz yapilir (bkz. asagida @Ids).

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

    -- IPTAL kaynak DONUSMEZ (GenDepoUpdate130/131): satirlarin bagli oldugu
    --   kaynak belge iptal edilmisse islem burada durur (51201).
    DECLARE @Ids NVARCHAR(MAX) =
        STUFF((SELECT ',' + CAST(KaynakSatirId AS nvarchar(20)) FROM @S FOR XML PATH('')), 1, 1, '');
    EXEC dbo.sp_Api_Donusum_KaynakIptalKontrol_Ic @Kaynak = @Kaynak, @SatirIds = @Ids;


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

-- ---- Kaynak LISTESI: iptal belge gorunmesin ----------------------------
--   Ekranda da gorunmemeli: kullanici iptal belgeyi listede gorup secmeye
--   calismasin (SP zaten reddediyor, ama liste temiz olmali).
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Kaynak_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak       INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kaynak') AS INT), 0);
    DECLARE @CbTur        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CbTur') AS INT), 0);
    DECLARE @DonusumTuru  INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.DonusumTuru') AS INT), 0);
    DECLARE @HedefBaslikTur INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.HedefBaslikTur') AS INT), 0);
    DECLARE @HedefUretim  BIT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.HedefUretim') AS BIT), 0);
    DECLARE @EnBoy        BIT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.EnBoy') AS BIT), 0);
    DECLARE @TarihBas     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    DECLARE @RehID        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.RehID') AS INT), 0);
    DECLARE @BelgeNo      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.BelgeNo'), N'');
    DECLARE @StokKod      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.StokKod'), N'');
    DECLARE @UrunNo       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.UrunNo'), N'');
    DECLARE @StokAd       NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.StokAd'), N'');
    DECLARE @Barkod       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Barkod'), N'');
    DECLARE @KalmayanGoster BIT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KalmayanGoster') AS BIT), 0);
    DECLARE @GizlenenGoster BIT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.GizlenenGoster') AS BIT), 0);
    DECLARE @IzlemeTur    INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IzlemeTur') AS INT), 0);
    DECLARE @Serino       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Serino'), N'');
    DECLARE @SktTarih     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.SktTarih') AS DATETIME);
    DECLARE @Karekod      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Karekod'), N'');
    DECLARE @BoyutPattern NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.BoyutPattern'), N'');

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @prm NVARCHAR(MAX) = N'@CbTur int,@DonusumTuru int,@HedefBaslikTur int,@HedefUretim bit,
        @TarihBas datetime,@TarihBit datetime,@RehID int,@BelgeNo nvarchar(100),@StokKod nvarchar(100),
        @UrunNo nvarchar(100),@StokAd nvarchar(200),@Barkod nvarchar(100),@KalmayanGoster bit,
        @GizlenenGoster bit,@IzlemeTur int,@Serino nvarchar(100),@SktTarih datetime,@Karekod nvarchar(100),
        @BoyutPattern nvarchar(200)';

    -- ortak izleme detay filtresi (STOKSERILOT); <D> = detay tablo aliasi (SD veya F)
    -- IZLEM(eski)->SSL.SERINO, SKT->SSL.SKT. serino/karekod/boyut=SERINO, skt=SKT.
    DECLARE @izl NVARCHAR(MAX) = N'
          AND (@IzlemeTur=0 OR ST.IZLEME=@IzlemeTur)
          AND (@Serino IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE N''%''+@Serino+N''%''))
          AND (@SktTarih IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SKT=@SktTarih))
          AND (@Karekod IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE N''%''+@Karekod+N''%''))
          AND (@BoyutPattern IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE @BoyutPattern))';

    -- =====================================================================
    -- KAYNAK 1: TEKLIF  (izleme orijinalde YOK)
    -- =====================================================================
    IF @Kaynak = 1
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=S.ID, SATIRID=SD.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA, S.TARIH,
            BELGENO=S.TEKLIFNO, ST.KOD, ST.STOKADI, ST.ANABIRIM, SD.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
            SD.ADET, SD.MIKTAR, SD.BIRIM, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
            SD.DOVIZ_BIRIMFIYAT, SD.DOVIZ_KURU, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI, SD.MASRAFID, SD.MERKEZID, SD.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=428 AND F1.YERID=SD.ID),0.0),
            IADE=0.0,
            KALAN=SD.ADET-ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                         -ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=416 AND F1.YERID=SD.ID),0.0),
            SD.TESLIMTARIHI,
            SATICI=S.HAZIRLAYAN,
            SD.PROJEID, SD.POZNO, ST.URUNNO,
            DETAY_OZELKOD=SD.OZELKOD, DETAY_OZELKOD2=SD.OZELKOD2,
            BASLIK_OZELKOD=S.OZELKOD, BASLIK_OZELKOD2=CAST(NULL AS NVARCHAR(50)),
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=SD.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID) THEN 1 ELSE 0 END'
          + CASE WHEN @EnBoy=1 THEN N', SD.EN, SD.BOY, SD.YUZEY, SD.SAYI' ELSE N'' END + N'
        FROM TEKLIF S
            INNER JOIN TEKLIFDETAY SD ON S.ID=SD.TEKLIFID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.TARIH >= @TarihBas AND S.TARIH <= @TarihBit
  AND ISNULL(S.DURUM,0) <> 6   /* IPTAL kaynak listelenmez (GenDepoUpdate130) */
          AND (@RehID = 0 OR @HedefBaslikTur = 9 OR R.ID=@RehID)
          AND (@BelgeNo IS NULL OR S.TEKLIFNO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1 OR SD.ADET > ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID))';
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 2: SIPARIS
    -- =====================================================================
    IF @Kaynak = 2
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=S.ID, SATIRID=SD.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA,
            TARIH=S.SIPARISTARIH, BELGENO=S.SIPARISNO, ST.KOD, ST.STOKADI, ST.ANABIRIM, SD.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
            SD.ADET, SD.MIKTAR, SD.BIRIM, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
            SD.DOVIZ_BIRIMFIYAT, SD.DOVIZ_KURU, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI, SD.MASRAFID, SD.MERKEZID, SD.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                   + CASE WHEN @HedefUretim=1
                          THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                          ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END,
            IADE=0.0,
            KALAN=SD.ADET-(ABS(ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0))
                   + ABS(CASE WHEN @HedefUretim=1
                          THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                          ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END)),
            SD.TESLIMTARIHI, S.REHBERILETID, SEVK=(SELECT AD FROM REHBERILETISIM WHERE ID=S.REHBERILETID),
            SATICI=S.SATICIKODU, DEPOAD=(SELECT DEPOADI FROM DEPOLAR WHERE ID=CASE WHEN S.TUR=19 THEN S.CIKISDEPO ELSE S.GIRISDEPO END),
            SD.PROJEID, SD.POZNO, ST.URUNNO, S.DETAYBOLUMU,
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=SD.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=S.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID) THEN 1 ELSE 0 END,
            DETAY_OZELKOD=SD.OZELKOD, DETAY_OZELKOD2=SD.OZELKOD2,
            BASLIK_OZELKOD=S.OZELKOD, BASLIK_OZELKOD2=S.OZELKOD2'
          + CASE WHEN @EnBoy=1 THEN N', SD.EN, SD.BOY, SD.YUZEY, SD.SAYI' ELSE N'' END + N'
        FROM SIPARIS S
            INNER JOIN SIPARISDETAY SD ON S.ID=SD.SIPARISID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.SIPARISTARIH >= @TarihBas AND S.SIPARISTARIH <= @TarihBit
  AND ISNULL(S.DURUM,0) <> 6   /* IPTAL kaynak listelenmez */
          AND (@RehID = 0 OR @CbTur = 101 OR R.ID=@RehID)
          AND S.TUR=@CbTur
          AND (@BelgeNo IS NULL OR S.SIPARISNO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1
               OR SD.ADET > ABS(ISNULL((SELECT SUM(S1.ADET) FROM SIPARISDETAY S1 WHERE S1.YERI=@DonusumTuru AND S1.YERID=SD.ID),0.0))
                          + ABS(CASE WHEN @HedefBaslikTur=66
                                 THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                                 ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=S.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID))'
          + REPLACE(@izl, N'<D>', N'SD');
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 3: FATBASLIK
    -- =====================================================================
    IF @Kaynak = 3
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=FB.ID, SATIRID=F.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA,
            TARIH=FB.FATURATARIH, BELGENO=FB.FATURANO, ST.KOD, ST.STOKADI, ST.ANABIRIM, F.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, F.KDV, F.KUR, F.DOVIZ_KURU,
            F.ADET, F.MIKTAR, F.BIRIM, F.BIRIMFIYAT, F.ISKONTO, F.ISKONTO2, F.TUTAR,
            F.DOVIZ_BIRIMFIYAT, F.DOVIZ_KURU, F.DOVIZKURDEGERI, F.DOVIZ_TUTARI, F.MASRAFID, F.MERKEZID, F.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0),
            IADE=ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=416 AND F1.YERID=F.ID),0.0),
            KALAN=F.ADET-ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0)
                        -ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=416 AND F1.YERID=F.ID),0.0),
            TESLIMTARIHI=FB.FATURATARIH,
            SATICI=FB.SATICIKODU, DEPOAD=(SELECT DEPOADI FROM DEPOLAR WHERE ID=CASE WHEN FB.TUR IN (10,11,12,119) THEN FB.GIRISDEPO ELSE FB.CIKISDEPO END),
            F.PROJEID, F.POZNO, ST.URUNNO, FB.DETAYBOLUMU,
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=F.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=FB.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=F.ID) THEN 1 ELSE 0 END,
            DETAY_OZELKOD=F.OZELKOD, DETAY_OZELKOD2=F.OZELKOD2,
            BASLIK_OZELKOD=FB.OZELKOD, BASLIK_OZELKOD2=FB.OZELKOD2'
          + CASE WHEN @EnBoy=1 THEN N', F.EN, F.BOY, F.YUZEY, F.SAYI' ELSE N'' END + N'
        FROM FATBASLIK FB
            INNER JOIN FATURA F ON FB.ID=F.FATBASID
            INNER JOIN STOKLAR ST ON F.TUR=1 AND F.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=FB.REHBERID
        WHERE FB.FATURATARIH >= @TarihBas AND FB.FATURATARIH <= @TarihBit
  AND ISNULL(FB.DURUM,0) <> 6   /* IPTAL kaynak listelenmez */
          AND (@RehID = 0 OR R.ID=@RehID)
          AND FB.TUR=@CbTur
          AND (@BelgeNo IS NULL OR FB.FATURANO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1 OR F.ADET > ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=FB.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=F.ID))'
          + REPLACE(@izl, N'<D>', N'F');
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END
END
GO
