-- ============================================================
-- GenDepoUpdate132.sql
-- BELGE IPTAL (DURUM=6) SUNUCUYA TASINDI : sp_Api_Belge_Iptal_Json
--
-- ONCEKI DURUM (UFaturalar.BelgeIptalEt) ve UC KUSURU
--   1) TRANSACTION YOK: baslik guncellendi, detay guncellenmedi ya da STOKIZLEME
--      yarim silindi -> belge tutarsiz kalabiliyordu.
--   2) KAYNAK DURUMU GUNCELLENMIYOR: iptalde FATURA.YERI/YERID SIFIRLANIYOR,
--      yani donusum bagi kopuyor. Kaynak siparis "Kismi/Tamamlandi" olarak
--      KALIYOR ve kalan adet yanlis hesaplanıyordu (8'i donmus siparis, hedefi
--      iptal edilince hala Kismi gorunuyordu). Artik bag KOPARILMADAN ONCE
--      kaynak listesi alinir, iptal sonrasi durumlar yeniden hesaplanir.
--   3) LOG YOK: kim/ne zaman iptal etti izlenemiyordu. Artik ISLEMLOG'a
--      "degistirme" (ISLEMTIPI=2) satiri yazilir - kart ve etkilenen detaylar.
--
-- IPTAL NE YAPAR (davranis AYNEN korundu)
--   Siparis (9/19/101/105) : SIPARIS.DURUM=6 + baslik tutarlari 0
--                            SIPARISDETAY fiyat/tutar/adet/miktar 0
--   Belge (digerleri)      : FATBASLIK.DURUM=6 + baslik tutarlari 0
--                            FATURA fiyat/tutar/adet/miktar/STOKDURUMDEGIS 0,
--                            YERI/YERID 0 (donusum bagi kopar)
--                            STOKIZLEME satirlari silinir
--
-- GIRDI : {"BelgeId":114125,"Tur":15,"Oturum":{"KulId":5,"SubeId":-1}}
--         Tur verilmezse tablodan okunur.
-- CIKTI : {"Sonuc":1,"BelgeId":..,"Tur":..,"Detay":n,"Izleme":n,"Loglanan":n,
--          "KaynakDurum":[{"BelgeId":..,"Durum":..}]}
-- HATA  : 51001 BelgeId eksik, 51002 belge yok, 51200 zaten iptal
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Iptal_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Tur     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tur')     AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip      VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist     VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @BelgeId IS NULL OR @BelgeId <= 0
        THROW 51001, N'BelgeId zorunlu.', 1;

    -- Siparis mi belge mi? (Tur verilmediyse iki tablodan da ara)
    DECLARE @Siparis BIT = 0, @Durum INT;
    IF @Tur IS NULL
    BEGIN
        SELECT @Tur = TUR, @Durum = ISNULL(DURUM,0), @Siparis = 1 FROM SIPARIS WHERE ID = @BelgeId;
        IF @Tur IS NULL
            SELECT @Tur = TUR, @Durum = ISNULL(DURUM,0), @Siparis = 0 FROM FATBASLIK WHERE ID = @BelgeId;
    END
    ELSE
    BEGIN
        IF @Tur IN (9, 19, 101, 105)
        BEGIN
            SET @Siparis = 1;
            SELECT @Durum = ISNULL(DURUM,0) FROM SIPARIS WHERE ID = @BelgeId;
        END
        ELSE
            SELECT @Durum = ISNULL(DURUM,0) FROM FATBASLIK WHERE ID = @BelgeId;
    END

    IF @Tur IS NULL OR @Durum IS NULL
        THROW 51002, N'Belge bulunamadi.', 1;
    IF @Durum = 6
        THROW 51200, N'Belge zaten iptal edilmiş.', 1;

    -- ---- KAYNAK BAGLARI: YERI/YERID SIFIRLANMADAN ONCE al ----
    --   (iptal sonrasi kaynak siparis/irsaliye durumu yeniden hesaplanacak)
    DECLARE @Kaynak TABLE (BelgeId INT PRIMARY KEY, Siparis BIT);
    IF @Siparis = 0
    BEGIN
        INSERT @Kaynak (BelgeId, Siparis)
        SELECT DISTINCT S.ID, 1
        FROM FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'SIPARISDETAY'
             INNER JOIN SIPARISDETAY SD ON SD.ID = F.YERID
             INNER JOIN SIPARIS S       ON S.ID = SD.SIPARISID
        WHERE F.FATBASID = @BelgeId;

        INSERT @Kaynak (BelgeId, Siparis)
        SELECT DISTINCT FB.ID, 0
        FROM FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'FATURA'
             INNER JOIN FATURA F2    ON F2.ID = F.YERID
             INNER JOIN FATBASLIK FB ON FB.ID = F2.FATBASID
        WHERE F.FATBASID = @BelgeId
          AND FB.ID NOT IN (SELECT BelgeId FROM @Kaynak);
    END

    DECLARE @Loglanan INT = 0, @n INT = 0, @Detay INT = 0, @Izleme INT = 0;

    BEGIN TRAN;

    -- ---- 1) LOG (degistirme) - iptal ONCESI anlik goruntu ----
    IF @Siparis = 1
    BEGIN
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'SIPARIS', @Kosul = N'ID=@pB', @KosulPar = @BelgeId,
             @TabNo = 91, @UstTabNo = 91, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'SIPARISDETAY', @Kosul = N'SIPARISID=@pB', @KosulPar = @BelgeId,
             @TabNo = 92, @UstTabNo = 91, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
    END
    ELSE
    BEGIN
        DECLARE @TabKart INT = dbo.fn_Api_Belge_TabNo(@Tur, 0);
        DECLARE @TabDet  INT = dbo.fn_Api_Belge_TabNo(@Tur, 1);
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @Kosul = N'ID=@pB', @KosulPar = @BelgeId,
             @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @Kosul = N'FATBASID=@pB', @KosulPar = @BelgeId,
             @TabNo = @TabDet, @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
        -- Silinecek izleme satirlari SILME logu olarak yazilir (Geri Al'a temel)
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKIZLEME',
             @Kosul = N'BASLIKID=@pB', @KosulPar = @BelgeId,
             @TabNo = 367, @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 0, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
    END

    -- ---- 2) IPTAL (davranis eskisiyle AYNI) ----
    IF @Siparis = 1
    BEGIN
        UPDATE SIPARIS
           SET DURUM = 6, SIPARIS_MATRAHI = 0, KDV_TUTARI = 0, EKVERGI = 0,
               SIPARIS_TUTARI = 0, DOVIZ_TUTARI = 0
         WHERE ID = @BelgeId;

        UPDATE SIPARISDETAY
           SET BIRIMFIYAT = 0, TUTAR = 0, DOVIZ_TUTARI = 0, DOVIZ_BIRIMFIYAT = 0,
               ADET = 0, MIKTAR = 0
         WHERE SIPARISID = @BelgeId;
        SET @Detay = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        UPDATE FATBASLIK
           SET DURUM = 6, FATURA_MALIYETI_ORT = 0, FATURA_MATRAHI = 0, KDV_TUTARI = 0,
               EKVERGI = 0, FATURA_TUTARI = 0, DOVIZ_TUTARI = 0
         WHERE ID = @BelgeId;

        -- Izleme satirlari ONCE silinir: STOKIZLEME DELETE tetigi stogu
        --   STOKIZLEMEDEPO'dan okuyup iade eder (bkz. GenDepoUpdate125).
        DELETE FROM STOKIZLEME WHERE BELGETUR = @Tur AND BASLIKID = @BelgeId;
        SET @Izleme = @@ROWCOUNT;

        UPDATE FATURA
           SET BIRIMFIYAT = 0, TUTAR = 0, DOVIZ_TUTARI = 0, DOVIZ_BIRIMFIYAT = 0,
               STOKDURUMDEGIS = 0, ADET = 0, MIKTAR = 0, YERI = 0, YERID = 0
         WHERE FATBASID = @BelgeId;
        SET @Detay = @@ROWCOUNT;
    END

    COMMIT;

    -- ---- 3) KAYNAK DURUMLARINI YENIDEN HESAPLA (bag koptu, kalan degisti) ----
    DECLARE @KId INT, @KSip BIT, @t2 INT, @d2 INT, @o2 INT, @s2 INT, @tm2 INT,
            @k2 INT, @a2 INT, @n2 NVARCHAR(60), @y2 BIT;
    DECLARE @Sonuc TABLE (BelgeId INT, Durum INT);
    DECLARE @KKaynak NVARCHAR(10);   -- EXEC parametresi IFADE alamaz
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT BelgeId, Siparis FROM @Kaynak;
    OPEN cur; FETCH NEXT FROM cur INTO @KId, @KSip;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @KKaynak = CASE WHEN @KSip = 1 THEN N'siparis' ELSE N'belge' END;
        BEGIN TRY
            EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic
                 @BelgeId = @KId,
                 @Kaynak = @KKaynak,
                 @Yaz = 1,
                 @Tur = @t2 OUTPUT, @Durum = @d2 OUTPUT, @OncekiDurum = @o2 OUTPUT,
                 @Satir = @s2 OUTPUT, @Tamamlanan = @tm2 OUTPUT, @Kismi = @k2 OUTPUT,
                 @Acik = @a2 OUTPUT, @Neden = @n2 OUTPUT, @Yazildi = @y2 OUTPUT;
            INSERT @Sonuc VALUES (@KId, @d2);
        END TRY
        BEGIN CATCH
            -- kaynak silinmis/kapsam disi olabilir - iptali bozma
        END CATCH
        FETCH NEXT FROM cur INTO @KId, @KSip;
    END
    CLOSE cur; DEALLOCATE cur;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Tur AS Tur, @Detay AS Detay,
                   @Izleme AS Izleme, @Loglanan AS Loglanan,
                   (SELECT BelgeId, Durum FROM @Sonuc FOR JSON PATH) AS KaynakDurum
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Belge_Iptal_Json TO gentegre_api;
GO
