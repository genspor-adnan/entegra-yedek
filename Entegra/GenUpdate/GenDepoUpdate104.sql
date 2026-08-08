-- ============================================================
-- GenDepoUpdate104.sql
-- TEK LOT VARSA SECIM SORMA - otomatik sec
--
-- Depoda o urunden secilebilir TEK lot varsa kullaniciya sormanin bir anlami
--   yok: secebilecegi baska bir sey zaten yok. Ekran acilmasin, adet kadari
--   otomatik secilsin.
--
-- Aday lot tanimi TEK YERDE: fn_Prog_Izleme_DepoAday. Hem sunucu zinciri
--   (sp_Prog_BelgeDonusum_Dogrula) hem uygulama (UBelgeDonusum) bunu kullanir;
--   biri "tek lot" derken digeri baska sey saymasin.
--
-- KURAL: otomatik secim YALNIZ aday sayisi 1 ISE ve o lotun bakiyesi yeterliyse
--   yapilir. Iki ya da daha fazla aday varsa karar kullanicinindir - hangi
--   lotun cikacagi is kararidir (SKT, musteri, parti). Tek adayin bakiyesi
--   yetmiyorsa da sorulur; kullanici gorsun.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION dbo.fn_Prog_Izleme_DepoAday
(
    @StokId INT,
    @DepoId INT,
    @HedefSatirId INT = 0   -- verilirse bu satirin KENDI hareketi disarida birakilir
)
RETURNS TABLE
AS
RETURN
(
    SELECT SDI.SERILOTID,
           SSL.SERINO, SSL.LOTNO, SSL.SKT, SSL.URT,
           Mevcut = CAST(ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) AS decimal(18,6))
    FROM dbo.STOKDURUMIZLEME SDI
         INNER JOIN dbo.STOKSERILOT SSL ON SSL.ID = SDI.SERILOTID
         OUTER APPLY (
             SELECT Kendi = SUM(ISNULL(D.ADET, 0))
             FROM dbo.STOKIZLEMEDEPO D
                  INNER JOIN dbo.STOKIZLEME SI ON SI.ID = D.IZLEMID
             WHERE ISNULL(@HedefSatirId, 0) > 0
               AND SI.SATIRID = @HedefSatirId
               AND SI.SERILOTID = SDI.SERILOTID
               AND D.DEPOID = @DepoId
         ) K
    WHERE SDI.STOKID = @StokId
      AND SDI.DEPOID = @DepoId
      AND ISNULL(SDI.KALAN, 0) - ISNULL(K.Kendi, 0) > 0.0001
);
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT SELECT ON dbo.fn_Prog_Izleme_DepoAday TO gentegre_api;
GO

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

    -- IS KURALI hatalarinda THROW YOK: THROW rollback tetikler ve #DonusumUyari'ya
    --   yazilan satir satir uyarilar da geri gider; kullanici "neden olmadi"
    --   goremez. Cagiran @HataSayisi'na bakip uyarilari KOPYALADIKTAN SONRA
    --   rollback yapar. (Yapisal hatalarda - bilinmeyen rota, satir yok -
    --   THROW korunur.)
    IF @HataSayisi > 0 RETURN;

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
            -- K6: kismi belge YOK - hicbir satir gecmez. Uyarilar korunsun diye
            --   THROW degil RETURN (yukaridaki nota bakiniz).
            SET @HataSayisi = @HataSayisi + @Yetersiz;
            RETURN;
        END
    END

    -- ---------- 7) Izleme ----------   [K6]
    --
    -- IKI FARKLI DURUM VAR - eski Pascal akisi da bu ayrimi yapiyordu
    -- ('if (Izleme>0) and (KaynakTabloAdi = ''FATBASLIK'')'):
    --
    --  a) KAYNAK FATURA (irsaliye -> fatura/fis, konsinye, uretimden):
    --     kaynakta STOKIZLEME kaydi VARDIR; seri/lot hedefe TASINIR.
    --     Cagiran secim gondermediyse kaynagin kalanli kayitlarindan FIFO ile
    --     otomatik secilir (eski akis da hepsini otomatik tasiyordu).
    --  b) KAYNAK SIPARISDETAY (siparisten belge):
    --     SIPARIS stok hareketi yapmaz, STOKIZLEME kaydi YOKTUR; seri/lot
    --     DEPODAN SECILMELIDIR. Bu secim ekrandan yapilir. Secim gelmediyse
    --     donusum yapilmaz (eski akis da engelliyordu).
    IF @IzlemeAktarim = 1
    BEGIN
        -- (a) Secim gonderilmemis izlemeli satirlar icin FIFO otomatik secim
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, Adet)
        SELECT X.SatirId, X.IzlemId, X.Pay
        FROM (
            SELECT S.SatirId, SI.ID AS IzlemId,
                   Pay = CASE WHEN SUM(SI.KALAN) OVER (PARTITION BY S.SatirId
                                                       ORDER BY SI.ID
                                                       ROWS UNBOUNDED PRECEDING) <= S.IstenenAdet
                              THEN SI.KALAN
                              ELSE S.IstenenAdet
                                 - ISNULL(SUM(SI.KALAN) OVER (PARTITION BY S.SatirId
                                                              ORDER BY SI.ID
                                                              ROWS BETWEEN UNBOUNDED PRECEDING
                                                                       AND 1 PRECEDING), 0)
                         END
            FROM #DonusumKaynakSatir S
                 INNER JOIN STOKIZLEME SI WITH (UPDLOCK, HOLDLOCK)
                         ON SI.BASLIKID = S.BaslikId AND SI.SATIRID = S.SatirId
                        AND ISNULL(SI.KALAN, 0) > 0
            WHERE ISNULL(S.Durum, N'') <> N'atlandi'
              AND ISNULL(S.Izleme, 0) > 0
              AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId)
        ) X
        WHERE X.Pay > 0.0001;

        -- Hala secimi olmayan izlemeli satir varsa kaynakta yeterli seri/lot yok
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_KAYNAKTA_YOK', S.SatirId,
               N'"' + ISNULL(ST.STOKADI, N'?') + N'" icin kaynak belgede kalan seri/lot yok.'
        FROM #DonusumKaynakSatir S
             LEFT JOIN STOKLAR ST ON ST.ID = S.UrunId
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId);
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

        -- ---- Secim dogrulamasi ORTAK SP'DEN ----
        --   'Secilen adet = satir adedi' ve 'lotta yeterli kalan var mi'
        --   kontrolleri burada IKINCI KEZ yaziliyordu. Artik izleme ekraniyla
        --   AYNI nesne kullaniliyor: sp_Prog_Izleme_Dogrula_Json (A3).
        --   Boylece ekran ile donusum ayni kurali uygular; biri degisince
        --   digeri geride kalmaz.
        DECLARE @Sorun TABLE (KOD NVARCHAR(30), SERILOTID INT NULL, MESAJ NVARCHAR(400));
        DECLARE @dSatir INT, @dStok INT, @dIzleme INT, @dAdet DECIMAL(18,6), @dJson NVARCHAR(MAX);

        DECLARE cd CURSOR LOCAL FAST_FORWARD FOR
            SELECT S.SatirId, S.UrunId, ISNULL(S.Izleme, 0), S.IstenenAdet
            FROM #DonusumKaynakSatir S
            WHERE ISNULL(S.Durum, N'') <> N'atlandi' AND ISNULL(S.Izleme, 0) > 0;
        OPEN cd; FETCH NEXT FROM cd INTO @dSatir, @dStok, @dIzleme, @dAdet;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @dJson =
                N'{"mod":"donusum","donusumTuru":' + CAST(@DonusumTuru AS nvarchar(10))
              + N',"stokId":' + CAST(ISNULL(@dStok, 0) AS nvarchar(12))
              + N',"izlemTur":' + CAST(@dIzleme AS nvarchar(10))
              + N',"gerekliAdet":' + CAST(@dAdet AS nvarchar(30))
              + N',"kaynak":{"baslikId":0,"satirId":' + CAST(@dSatir AS nvarchar(12)) + N'}'
              + N',"secim":'
              -- DIKKAT: #DonusumIzlemeSecim KAYNAK STOKIZLEME.ID tutar, dogrulama
              --   SP'si ise SERILOTID bekler. Cevrim burada yapiliyor.
              + ISNULL((SELECT serilotId = SI.SERILOTID, adet = I.Adet
                        FROM #DonusumIzlemeSecim I
                             INNER JOIN STOKIZLEME SI ON SI.ID = I.StokIzlemeId
                        WHERE I.SatirId = @dSatir
                        FOR JSON PATH), N'[]') + N'}';

            DELETE @Sorun;
            INSERT @Sorun (KOD, SERILOTID, MESAJ)
            EXEC dbo.sp_Prog_Izleme_Dogrula_Json @dJson;

            INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
            SELECT KOD, @dSatir, MESAJ FROM @Sorun;
            SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

            FETCH NEXT FROM cd INTO @dSatir, @dStok, @dIzleme, @dAdet;
        END
        CLOSE cd; DEALLOCATE cd;

        IF @HataSayisi > 0 RETURN;
    END
    ELSE
    BEGIN
        -- (b) Kaynak SIPARIS: seri/lot DEPODAN secilir (SIPARIS stok hareketi
        --   yapmaz, STOKIZLEME kaydi yoktur).
        --
        -- ---- TEK ADAY LOT: SORMA, OTOMATIK SEC ----
        --   Depoda secilebilir tek lot varsa kullaniciya soracak bir sey yok.
        --   Iki ve uzeri adayda karar kullanicinindir (SKT/parti is karari).
        --   Aday tanimi fn_Prog_Izleme_DepoAday'da - ekran da ayni TVF'i kullanir.
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, SerilotId, Adet)
        SELECT S.SatirId, 0, A.SERILOTID, S.IstenenAdet
        FROM #DonusumKaynakSatir S
             INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = S.BaslikId
             CROSS APPLY (
                 SELECT TOP 2 D.SERILOTID, D.Mevcut
                 FROM dbo.fn_Prog_Izleme_DepoAday(S.UrunId,
                          CASE WHEN @DepoAlani = 'GIRISDEPO' THEN B.GirisDepo ELSE B.CikisDepo END,
                          0) D
             ) A
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND S.SatirTur = 1
          AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId)
          AND A.Mevcut + 0.0001 >= S.IstenenAdet
          -- tam olarak BIR aday olmali
          AND (SELECT COUNT(*) FROM dbo.fn_Prog_Izleme_DepoAday(S.UrunId,
                   CASE WHEN @DepoAlani = 'GIRISDEPO' THEN B.GirisDepo ELSE B.CikisDepo END, 0)) = 1;

        --   Secim GELMEDIYSE engelle. Istemci bu uyariyi alinca izleme ekranini
        --   acar, kullaniciya lotlari sectirir ve ayni istegi izlemeler[] ile
        --   TEKRAR gonderir (stok yetersizligindeki "sor ve tekrar dene"
        --   deseninin aynisi).
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_SECIMI_EKSIK', S.SatirId,
               N'"' + ISNULL(ST.STOKADI, N'?') + N'" izlemeli bir urun; hangi seri/lot '
             + N'cikacagi secilmeden bu belge olusturulamaz.'
        FROM #DonusumKaynakSatir S
             LEFT JOIN STOKLAR ST ON ST.ID = S.UrunId
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND S.SatirTur = 1
          AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId);
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;
        IF @HataSayisi > 0 RETURN;

        -- Secim GELDIYSE: toplami satir adediyle tutmali (yarim izlem sessiz
        --   veri bozulmasidir).
        --   Depodaki bakiye yeterliligi BURADA TEKRARLANMAZ: yazma aninda
        --   sp_Prog_Izleme_Aktar_Json (depodan kip) kontrol edip 51200 atar,
        --   islem geri sarilir. Ayni kural iki yerde yazilmasin.
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_ADET_UYUSMAZ', S.SatirId,
               N'"' + ISNULL(ST.STOKADI, N'?') + N'" icin secilen seri/lot toplami ('
             + CAST(CAST(T.Toplam AS decimal(18,3)) AS nvarchar(30)) + N') satir adediyle ('
             + CAST(CAST(S.IstenenAdet AS decimal(18,3)) AS nvarchar(30)) + N') ayni degil.'
        FROM #DonusumKaynakSatir S
             LEFT JOIN STOKLAR ST ON ST.ID = S.UrunId
             CROSS APPLY (SELECT Toplam = ISNULL(SUM(I.Adet), 0)
                          FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId) T
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND S.SatirTur = 1
          AND EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId)
          AND ABS(T.Toplam - S.IstenenAdet) > 0.0001;
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;
        IF @HataSayisi > 0 RETURN;
    END

    -- ---------- Sonuc ----------
    UPDATE #DonusumKaynakSatir SET Durum = N'uygun'
     WHERE ISNULL(Durum, N'') NOT IN (N'atlandi', N'hata');
END
GO

GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Dogrula TO gentegre_api;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

