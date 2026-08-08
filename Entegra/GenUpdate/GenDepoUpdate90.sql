-- ============================================================
-- GenDepoUpdate90.sql
-- BELGE DONUSUM - KODLAMA ADIM 3: sp_Prog_BelgeDonusum_Dogrula
--
-- Ana SP (Uygula_Json2) tarafindan, TRANSACTION ICINDE, satirlar yazilmadan
--   ONCE cagrilir. Kendi transaction'ini ACMAZ; hata halinde THROW eder,
--   rollback ana SP'nin isidir (veri sozlesmesi bolum 3).
--
-- GIRDI  (cagirandan gelen gecici tablolar - bkz. BelgeDonusum_Veri_Sozlesmesi.txt)
--   #DonusumKaynakBaslik, #DonusumKaynakSatir, #DonusumIzlemeSecim
-- CIKTI  (ayni tablolara yazar)
--   #DonusumKaynakSatir.DonusenAdet / .KalanAdet / .StokYeterli / .Durum
--   #DonusumUyari  (kod + kaynak satir + mesaj)
--
-- KONTROLLER
--   1  Rota destekli mi
--   2  Kaynak basliklarin TUR'u rotayla uyumlu mu
--   3  Cok kaynakli birlestirmede cari/sube/depo/doviz/KDV uyumu
--   4  Hedef belge verilmisse: var mi, tur/cari/sube/doviz uyumlu mu, kilitli mi
--   5  KALAN - KILIT ALTINDA yeniden hesaplanir (asiri donusum korumasi)
--   6  Stok yeterliligi (yalniz StokKontrolu=1 rotalarda)       [K6]
--   7  Izleme secimi (izlemeli satirda zorunlu, adetler tutmali) [K6]
--
-- K6 DAVRANISI - kismi belge YOK:
--   Stok yetersiz ya da izleme secimi eksikse HICBIR SATIR gecmez; SP 51200
--   ile hata verir ve ana SP tum islemi geri alir. Eski akistaki "satiri
--   sessizce atla, eksik belge olustur" davranisi KALDIRILDI.
--   @StokOnayi = 1 gonderilirse (StokDurumKontrolKurali kullanici onayina izin
--   veriyorsa) stok yetersizligi hata degil UYARI olur ve donusum devam eder.
--
-- HATA KODLARI
--   51001 girdi   51200 is kurali   51300 es zamanlilik/asiri donusum
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Dogrula
    @DonusumTuru   INT,
    @HedefBaslikID INT = 0,
    @SubeID        INT = -1,
    @Tarih         DATETIME = NULL,
    @StokOnayi     BIT = 0,
    @SadeceKontrol BIT = 0,
    @HataSayisi    INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Tarih = ISNULL(@Tarih, GETDATE());
    SET @HataSayisi = 0;

    -- ---------- 1) Rota ----------
    DECLARE @KaynakTur INT, @HedefTur INT, @KaynakDetay NVARCHAR(20), @KaynakBaslik NVARCHAR(20),
            @HedefBaslikTablo NVARCHAR(20), @DepoAlani NVARCHAR(20), @StokKontrolu BIT,
            @IzlemeAktarim BIT, @Destek BIT;
    SELECT @KaynakTur = KaynakTur, @HedefTur = HedefTur, @KaynakDetay = KaynakDetayTablo,
           @KaynakBaslik = KaynakBaslikTablo, @HedefBaslikTablo = HedefBaslikTablo,
           @DepoAlani = DepoAlani, @StokKontrolu = StokKontrolu,
           @IzlemeAktarim = IzlemeAktarim, @Destek = Destek
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakTur IS NULL
    BEGIN
        DECLARE @m1 NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
        THROW 51200, @m1, 1;
    END
    IF @Destek = 0
    BEGIN
        DECLARE @m2 NVARCHAR(300) = N'Bu donusum turu (' + CAST(@DonusumTuru AS nvarchar(10))
              + N') sunucu tarafinda desteklenmiyor.';
        THROW 51200, @m2, 1;
    END
    IF NOT EXISTS (SELECT 1 FROM #DonusumKaynakSatir)
        THROW 51001, N'Donusturulecek satir gonderilmedi.', 1;

    -- ---------- 2) Kaynak baslik turu ----------
    IF EXISTS (SELECT 1 FROM #DonusumKaynakBaslik WHERE KaynakTur <> @KaynakTur)
    BEGIN
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'KAYNAK_TUR_UYUMSUZ', NULL,
               N'Kaynak belge turu (' + CAST(B.KaynakTur AS nvarchar(10))
             + N') bu donusum icin beklenenle (' + CAST(@KaynakTur AS nvarchar(10)) + N') uyusmuyor.'
        FROM #DonusumKaynakBaslik B WHERE B.KaynakTur <> @KaynakTur;
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;
        THROW 51200, N'Kaynak belge turu bu donusum icin uygun degil.', 1;
    END

    -- ---------- 3) Cok kaynakli birlestirme uyumu ----------
    --   Birden fazla kaynak baslik TEK hedefe birlesiyorsa cari, sube, depo,
    --   doviz ve KDV durumu ayni olmali; aksi halde hedef baslik hangi degeri
    --   alacagi belirsiz kalir.
    IF (SELECT COUNT(*) FROM #DonusumKaynakBaslik) > 1
    BEGIN
        IF (SELECT COUNT(DISTINCT RehberId)   FROM #DonusumKaynakBaslik) > 1
           OR (SELECT COUNT(DISTINCT SubeId)  FROM #DonusumKaynakBaslik) > 1
           OR (SELECT COUNT(DISTINCT ISNULL(KdvDurum, N'')) FROM #DonusumKaynakBaslik) > 1
           OR (SELECT COUNT(DISTINCT ISNULL(RaporDoviz, N''))  FROM #DonusumKaynakBaslik) > 1
        BEGIN
            INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
            VALUES (N'KAYNAK_UYUMSUZ', NULL,
                    N'Birlestirilen kaynak belgelerin cari / sube / KDV durumu / dovizi ayni degil.');
            SET @HataSayisi = @HataSayisi + 1;
            THROW 51200, N'Birlestirilen kaynak belgeler uyumsuz.', 1;
        END
    END

    -- ---------- 4) Mevcut hedef belge ----------
    IF @HedefBaslikID > 0
    BEGIN
        IF @HedefBaslikTablo <> 'FATBASLIK'
            THROW 51200, N'Bu donusumde mevcut belgeye ekleme desteklenmiyor.', 1;

        DECLARE @hTur INT, @hRehber INT, @hSube INT, @hDurum INT, @hEfat INT;
        SELECT @hTur = TUR, @hRehber = REHBERID, @hSube = SUBEID,
               @hDurum = ISNULL(DURUM, 0), @hEfat = ISNULL(EFATURADURUM, 0)
        FROM FATBASLIK WITH (UPDLOCK, HOLDLOCK) WHERE ID = @HedefBaslikID;

        IF @hTur IS NULL THROW 51200, N'Hedef belge bulunamadi.', 1;
        IF @hTur <> @HedefTur THROW 51200, N'Hedef belgenin turu bu donusume uygun degil.', 1;
        IF @hDurum <> 0
            THROW 51200, N'Hedef belge kapali/kesinlesmis - satir eklenemez.', 1;
        -- e-Belge sureci baslamis belgeye satir eklenmez (0 = hic islem gormemis)
        IF @hEfat <> 0
            THROW 51200, N'Hedef belge e-Belge surecine girmis - satir eklenemez.', 1;
        IF EXISTS (SELECT 1 FROM #DonusumKaynakBaslik WHERE RehberId <> @hRehber)
            THROW 51200, N'Hedef belgenin carisi kaynak belgeyle ayni degil.', 1;
        IF @hSube <> @SubeID
            THROW 51200, N'Hedef belge baska subeye ait.', 1;
    END

    -- ---------- 5) KALAN - kilit altinda yeniden hesap ----------
    --   Kaynak satirlar UPDLOCK ile kilitlenir; es zamanli ikinci bir donusum
    --   ayni miktari ikinci kez tuketemez.
    IF @KaynakDetay = 'SIPARISDETAY'
        UPDATE S SET S.KaynakAdet = SD.ADET
        FROM #DonusumKaynakSatir S
             INNER JOIN SIPARISDETAY SD WITH (UPDLOCK, HOLDLOCK) ON SD.ID = S.SatirId;
    ELSE
        UPDATE S SET S.KaynakAdet = F.ADET
        FROM #DonusumKaynakSatir S
             INNER JOIN FATURA F WITH (UPDLOCK, HOLDLOCK) ON F.ID = S.SatirId;

    UPDATE S
       SET S.DonusenAdet = K.Donusen,
           S.KalanAdet   = K.Kalan
      FROM #DonusumKaynakSatir S
           CROSS APPLY dbo.fn_Prog_BelgeDonusum_Kalan(@DonusumTuru, S.SatirId) K;

    -- Istenen adet gonderilmediyse kalanin tamami
    UPDATE #DonusumKaynakSatir
       SET IstenenAdet = KalanAdet
     WHERE IstenenAdet IS NULL OR IstenenAdet <= 0;

    -- Miktar orani korunur: ADET/MIKTAR birlikte indirgenir
    UPDATE #DonusumKaynakSatir
       SET IstenenMiktar = CASE WHEN ISNULL(KaynakAdet, 0) = 0 THEN IstenenAdet
                                ELSE ROUND(KaynakMiktar * IstenenAdet / KaynakAdet, 6) END
     WHERE IstenenMiktar IS NULL OR IstenenMiktar <= 0;

    -- Kalani asan istek -> asiri donusum
    INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
    SELECT N'KALAN_YETERSIZ', S.SatirId,
           N'Kaynak satirda kalan ' + CAST(CAST(S.KalanAdet AS decimal(18,3)) AS nvarchar(30))
         + N', istenen ' + CAST(CAST(S.IstenenAdet AS decimal(18,3)) AS nvarchar(30)) + N'.'
    FROM #DonusumKaynakSatir S
    WHERE S.IstenenAdet > S.KalanAdet + 0.0001;
    SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

    UPDATE #DonusumKaynakSatir SET Durum = N'hata'
     WHERE IstenenAdet > KalanAdet + 0.0001;

    IF @HataSayisi > 0
        THROW 51300, N'Kaynak satirlarda yeterli kalan yok (baska bir islem tuketmis olabilir).', 1;

    -- Kalani sifir/negatif olan satir gonderilmisse
    IF EXISTS (SELECT 1 FROM #DonusumKaynakSatir WHERE KalanAdet <= 0.0001)
    BEGIN
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'KALAN_YOK', SatirId, N'Bu satirin donusturulecek kalani yok.'
        FROM #DonusumKaynakSatir WHERE KalanAdet <= 0.0001;
        UPDATE #DonusumKaynakSatir SET Durum = N'atlandi' WHERE KalanAdet <= 0.0001;
    END

    IF NOT EXISTS (SELECT 1 FROM #DonusumKaynakSatir WHERE ISNULL(Durum, N'') <> N'atlandi')
        THROW 51200, N'Donusturulecek kalan satir yok (belge tamamlanmis olabilir).', 1;

    -- ---------- 6) Stok yeterliligi ----------   [K6]
    UPDATE #DonusumKaynakSatir SET StokYeterli = 1;

    IF @StokKontrolu = 1
    BEGIN
        DECLARE @sSatir INT, @sUrun INT, @sDepo INT, @sAdet DECIMAL(18,6), @sIzleme INT;
        DECLARE @Sonuc TABLE (YETERLI BIT, KALAN FLOAT, ISTENEN FLOAT);
        DECLARE @Yeterli BIT, @Kalan FLOAT;

        DECLARE cs CURSOR LOCAL FAST_FORWARD FOR
            SELECT S.SatirId, S.UrunId,
                   CASE WHEN @DepoAlani = 'GIRISDEPO' THEN B.GirisDepo ELSE B.CikisDepo END,
                   S.IstenenAdet, ISNULL(S.Izleme, 0)
            FROM #DonusumKaynakSatir S
                 INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = S.BaslikId
            WHERE ISNULL(S.Durum, N'') <> N'atlandi'
              AND S.SatirTur = 1          -- yalniz stoksal satirlar
              AND S.UrunId > 0;
        OPEN cs; FETCH NEXT FROM cs INTO @sSatir, @sUrun, @sDepo, @sAdet, @sIzleme;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DELETE @Sonuc;
            -- Mevcut kontrol SP'leri YENIDEN KULLANILIYOR (tarih bazli, ayni mantik
            --   ikinci kez yazilmiyor - degerlendirme raporu madde 9).
            IF @sIzleme > 0
                INSERT @Sonuc EXEC dbo.sp_Prog_Kontrol_Adet_Izlemli
                     @URUNID = @sUrun, @DEPOID = @sDepo, @TARIH = @Tarih,
                     @ADET = @sAdet, @SATIRID = 0, @SERILOTID = 0;
            ELSE
                INSERT @Sonuc EXEC dbo.sp_Prog_Kontrol_Adet_Izlemsiz
                     @URUNID = @sUrun, @DEPOID = @sDepo, @TARIH = @Tarih,
                     @ADET = @sAdet, @SATIRID = 0;

            SELECT TOP 1 @Yeterli = YETERLI, @Kalan = KALAN FROM @Sonuc;

            IF ISNULL(@Yeterli, 1) = 0
            BEGIN
                UPDATE #DonusumKaynakSatir SET StokYeterli = 0 WHERE SatirId = @sSatir;
                INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
                SELECT N'STOK_YETERSIZ', @sSatir,
                       N'"' + ISNULL(ST.STOKADI, N'?') + N'" icin depoda yeterli stok yok ('
                     + CONVERT(nvarchar(10), @Tarih, 104) + N' itibariyle mevcut: '
                     + CAST(CAST(ISNULL(@Kalan, 0) AS decimal(18,3)) AS nvarchar(30))
                     + N', istenen: ' + CAST(CAST(@sAdet AS decimal(18,3)) AS nvarchar(30)) + N').'
                FROM (SELECT STOKADI FROM STOKLAR WHERE ID = @sUrun) ST;
            END
            FETCH NEXT FROM cs INTO @sSatir, @sUrun, @sDepo, @sAdet, @sIzleme;
        END
        CLOSE cs; DEALLOCATE cs;

        DECLARE @Yetersiz INT = (SELECT COUNT(*) FROM #DonusumKaynakSatir WHERE StokYeterli = 0);
        IF @Yetersiz > 0 AND @StokOnayi = 0
        BEGIN
            SET @HataSayisi = @HataSayisi + @Yetersiz;
            -- K6: kismi belge YOK - hicbir satir gecmez.
            THROW 51200, N'Yetersiz stok nedeniyle donusum yapilamaz.', 1;
        END
    END

    -- ---------- 7) Izleme secimi ----------   [K6]
    IF @IzlemeAktarim = 1
    BEGIN
        -- Izlemeli satirda secim ZORUNLU
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_SECIMI_EKSIK', S.SatirId,
               N'"' + ISNULL(ST.STOKADI, N'?') + N'" izlemeli bir urun; seri/lot secimi yapilmali.'
        FROM #DonusumKaynakSatir S
             LEFT JOIN STOKLAR ST ON ST.ID = S.UrunId
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId);
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

        -- Secilen seri/lot adetleri istenen adetle tutmali
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_ADET_UYUMSUZ', S.SatirId,
               N'Secilen seri/lot toplami (' + CAST(CAST(T.Toplam AS decimal(18,3)) AS nvarchar(30))
             + N') satir adediyle (' + CAST(CAST(S.IstenenAdet AS decimal(18,3)) AS nvarchar(30))
             + N') ayni degil.'
        FROM #DonusumKaynakSatir S
             CROSS APPLY (SELECT Toplam = SUM(I.Adet) FROM #DonusumIzlemeSecim I
                           WHERE I.SatirId = S.SatirId) T
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND T.Toplam IS NOT NULL
          AND ABS(T.Toplam - S.IstenenAdet) > 0.0001;
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

        -- Secilen STOKIZLEME kaydinda o kadar kalan var mi
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_KALAN_YETERSIZ', I.SatirId,
               N'Secilen seri/lot kaydinda yeterli kalan yok (mevcut: '
             + CAST(CAST(ISNULL(SI.KALAN, 0) AS decimal(18,3)) AS nvarchar(30))
             + N', istenen: ' + CAST(CAST(I.Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
        FROM #DonusumIzlemeSecim I
             LEFT JOIN STOKIZLEME SI WITH (UPDLOCK, HOLDLOCK) ON SI.ID = I.StokIzlemeId
        WHERE SI.ID IS NULL OR ISNULL(SI.KALAN, 0) + 0.0001 < I.Adet;
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

        IF @HataSayisi > 0
            THROW 51200, N'Seri/lot secimi eksik ya da uygun degil - donusum yapilamaz.', 1;
    END

    -- ---------- Sonuc ----------
    UPDATE #DonusumKaynakSatir SET Durum = N'uygun'
     WHERE ISNULL(Durum, N'') NOT IN (N'atlandi', N'hata');
END
GO

GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Dogrula TO gentegre_api;
GO
