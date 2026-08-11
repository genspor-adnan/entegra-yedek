-- ============================================================
-- GenDepoUpdate143.sql
-- KOPYA / DONUSUM IZI (ISLEMLOG) + KLON KOD-AD KURALI
--
-- 1) IZ: klon ve donusumle olusan kayitlar zaten "ekleme" (ISLEMTIPI=1) olarak
--    loglaniyor, ama "kopya mi, neyin kopyasi" bilgisi yoktu. Yeni kolon/tablo
--    EKLEMEDEN mevcut satir zenginlestirilir:
--      ALTISLEMTIPI = 3  -> Kopyalandi (klon)
--      ALTISLEMTIPI = 5  -> Donusumle olustu
--      BILGI JSON'una  "_KopyaKaynak" / "_DonusumKaynak" (+ "_KaynakTablo")
--    ISLEMTIPI 1 kalir: kayit gercekten eklendi, Geri Al davranisi degismez.
--
--    BILGI varbinary(max) (COMPRESS'li JSON) -> DECOMPRESS + JSON_MODIFY + COMPRESS.
--
-- 2) KLON KOD/AD KURALI (kullanici karari 10.08.2026):
--      kod : <KAYNAKKOD>_K1   (dolu ise _K2, _K3 ...)
--      ad  : <KAYNAKAD> (KOPYA)
--    Stok/cari/IK klon SP'leri bunu uretir; disaridan Kod/Ad gonderilirse o kullanilir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- 1) IZ BIRAKICI: son "ekleme" log satirini isaretler
--    @AltTip: 3 = kopya, 5 = donusum
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Log_Kaynak_Isaretle
    @TabNo       INT,
    @KayitId     BIGINT,
    @AltTip      TINYINT,
    @KaynakId    BIGINT,
    @KaynakTabNo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@KayitId, 0) <= 0 OR ISNULL(@KaynakId, 0) <= 0 RETURN;

    DECLARE @LogTablo sysname, @Yil INT = YEAR(GETDATE());
    EXEC dbo.sp_Api_Log_YilTablosu @Yil = @Yil, @Tablo = @LogTablo OUTPUT;
    IF OBJECT_ID(@LogTablo, 'U') IS NULL RETURN;

    DECLARE @Alan NVARCHAR(30) = CASE WHEN @AltTip = 5 THEN N'_DonusumKaynak' ELSE N'_KopyaKaynak' END;

    -- Son EKLEME satiri (ayni islemde yazilan kart satiri) isaretlenir.
    DECLARE @SQL NVARCHAR(MAX) = N'
    ;WITH S AS (
        SELECT TOP 1 ID, ALTISLEMTIPI, BILGI
        FROM ' + @LogTablo + N'
        WHERE TABLOID = @t AND KAYITID = @k AND ISLEMTIPI = 1
        ORDER BY ID DESC
    )
    UPDATE S
       SET ALTISLEMTIPI = @a,
           BILGI = CASE
                     WHEN BILGI IS NULL THEN NULL
                     ELSE COMPRESS(
                            JSON_MODIFY(
                              JSON_MODIFY(CAST(DECOMPRESS(BILGI) AS nvarchar(max)),
                                          ''$.' + @Alan + N''', CAST(@s AS nvarchar(20))),
                              ''$._KaynakTablo'', CAST(ISNULL(@kt, @t) AS nvarchar(20))))
                   END;';

    EXEC sp_executesql @SQL,
         N'@t INT, @k BIGINT, @a TINYINT, @s BIGINT, @kt INT',
         @t = @TabNo, @k = @KayitId, @a = @AltTip, @s = @KaynakId, @kt = @KaynakTabNo;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Log_Kaynak_Isaretle TO gentegre_api;
GO

-- ============================================================
-- 2) DONUSUM IZI: sp_Api_Donusum_Uygula_Json hedef belgeyi isaretler
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

        -- ---- DONUSUM IZI (GenDepoUpdate143) ----
        --   Hedef belgenin EKLEME log satiri "Donusumle olustu" (ALTISLEMTIPI=5)
        --   olarak isaretlenir; kaynak belge ID'si BILGI._DonusumKaynak'a yazilir.
        --   Birden fazla kaynak varsa ilki yazilir (zincir SP'leri tamamini verir).
        DECLARE @IzKaynak INT = (SELECT TOP 1 BelgeId FROM @KaynakBelgeler ORDER BY BelgeId);
        DECLARE @IzTabNo  INT = (SELECT TOP 1 TABLOID FROM dbo.ISLEMLOG
                                  WHERE KAYITID = @HedefBelgeId AND ISLEMTIPI = 1 ORDER BY ID DESC);
        IF @IzKaynak IS NOT NULL AND @IzTabNo IS NOT NULL
            EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = @IzTabNo, @KayitId = @HedefBelgeId,
                 @AltTip = 5, @KaynakId = @IzKaynak, @KaynakTabNo = @IzTabNo;

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
