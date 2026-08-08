-- ============================================================
-- GenDepoUpdate103.sql
-- SIPARIS KAYNAKLI IZLEMLI URUN - MENU/LISTE DONUSUM YOLU   [plan A5, 2. parca]
--
-- GenDepoUpdate102 ile UBelgeDonusum EKRANINDAN yapilan donusumde depodan
--   seri/lot secimi calisir hale geldi. Bu dosya AYNI ISI SP ZINCIRINDE
--   (liste/menu yolunda) acar: sp_Prog_BelgeDonusum_Uygula_Json2.
--
-- Bugunku davranis: siparis 23202 (urun 86, IZLEME=2, adet 5) listeden
--   irsaliyeye donusturulemiyor - dogrulama "IZLEME_SECIMI_EKSIK" verip
--   duruyor. Dogru da yapiyor; eksik olan ISTEMCININ SECIMI SORUP TEKRAR
--   GONDERMESI ve zincirin depodan secimi KABUL ETMESI.
--
-- UC DEGISIKLIK
--   1) #DonusumIzlemeSecim  + SerilotId  (kaynakta STOKIZLEME yoksa lot
--      dogrudan SERILOTID ile gelir); izlemeler[] artik "serilotId" kabul eder.
--   2) sp_Prog_BelgeDonusum_Dogrula: secim GELDIYSE engellemez, toplam = satir
--      adedi kontrolu yapar. Depo yeterliligi yazma aninda (Aktar_Json) - ayni
--      kural iki yerde yazilmasin.
--   3) sp_Prog_BelgeDonusum_IzlemeAktar: iki dal. Tasima (kaynakta izlem var,
--      depo hareketi 0 - stok zaten cikmisti) ve DEPODAN (yeni kayit, DONUSID=0,
--      depo hareketi GERCEKTEN yapilir - siparisten ilk cikis).
--
-- Depo hareketi karari rota matrisinden (StokDurumDegis) okunur; 410/411 gibi
--   siparis rotalarinda 1'dir, irsaliye->fatura rotalarinda 0.
-- ============================================================
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

CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_IzlemeAktar
    @DonusumTuru INT,
    @HedefBaslikID INT,
    @KullaniciID INT,
    @Aktarilan   INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Aktarilan = 0;

    IF NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim) RETURN;

    DECLARE @HedefTur INT, @GirDepo INT, @CikDepo INT;
    SELECT @HedefTur = TUR, @GirDepo = GIRISDEPO, @CikDepo = CIKISDEPO
    FROM FATBASLIK WHERE ID = @HedefBaslikID;

    -- Cikis nitelikli belgelerde depo CIKISDEPO (eski akisla ayni liste)
    DECLARE @DepoId INT = CASE WHEN @HedefTur IN (4, 14, 15, 16, 99, 119)
                               THEN @CikDepo ELSE @GirDepo END;
    DECLARE @Yon INT = CASE WHEN @HedefTur IN (4, 14, 15, 16, 99, 119) THEN -1 ELSE 1 END;

    -- Depo hareketi yapilacak mi? Rota matrisi soyler:
    --   siparis -> irsaliye/fatura : 1 (stok ILK KEZ burada cikar)
    --   irsaliye -> fatura         : 0 (stok zaten irsaliyeyle cikmisti;
    --                                   satir K-B karariyla ADET=0 ile acilir)
    DECLARE @StokDegis BIT =
        ISNULL((SELECT StokDurumDegis FROM dbo.fn_Prog_BelgeDonusum_Rota()
                WHERE DonusumTuru = @DonusumTuru), 0);

    DECLARE @Secim INT, @Serilot INT, @KaynakSatir INT, @HedefSatir INT,
            @Adet DECIMAL(18,6), @YeniIzlem INT;

    DECLARE ci CURSOR LOCAL FAST_FORWARD FOR
        SELECT ISNULL(I.StokIzlemeId, 0), ISNULL(I.SerilotId, 0),
               I.SatirId, E.HedefSatirId, I.Adet
        FROM #DonusumIzlemeSecim I
             INNER JOIN #DonusumSatirEsleme E ON E.KaynakSatirId = I.SatirId
        ORDER BY I.SatirId, I.StokIzlemeId, I.SerilotId;
    OPEN ci; FETCH NEXT FROM ci INTO @Secim, @Serilot, @KaynakSatir, @HedefSatir, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @YeniIzlem = NULL;

        IF @Secim > 0
        BEGIN
            -- ---- TASIMA: kaynakta STOKIZLEME kaydi var ----
            INSERT INTO STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR, ADET, KALAN,
                                    YER, YERID, DONUSID, SERILOTID, EKLEYEN)
            SELECT SI.STOKID, @HedefTur, @HedefBaslikID, @HedefSatir, SI.IZLEMTUR, @Adet, @Adet,
                   SI.YER, 0, SI.ID, SI.SERILOTID, @KullaniciID
            FROM STOKIZLEME SI WHERE SI.ID = @Secim;
            SET @YeniIzlem = CAST(SCOPE_IDENTITY() AS INT);

            -- [K6/2.4] KAYNAGIN KALAN'INA ELLE DOKUNULMUYOR.
            --   TG_IzlemOrjinalYap yeni satirin DONUSID'sine bakip kaynagin
            --   KALAN'ini ZATEN duserir. Eski Pascal akisi ustune
            --   'update STOKIZLEME set KALAN=0' yaziyordu; kismi donusumde
            --   kalanin sifirlanmasinin sebebi buydu.
        END
        ELSE IF @Serilot > 0
        BEGIN
            -- ---- DEPODAN: kaynak SIPARIS, izlem kaydi yok, DONUSID=0 ----
            --   Depoda yeterli bakiye var mi? Yoksa donusumun tamami geri sarilir.
            DECLARE @Mevcut DECIMAL(18,6) =
                ISNULL((SELECT SDI.KALAN FROM STOKDURUMIZLEME SDI
                        WHERE SDI.SERILOTID = @Serilot AND SDI.DEPOID = @DepoId), 0);
            IF @StokDegis = 1 AND @Mevcut + 0.0001 < @Adet
            BEGIN
                DECLARE @m NVARCHAR(400) =
                    (SELECT N'"' + ISNULL(SSL.LOTNO, SSL.SERINO)
                          + N'" icin depoda yeterli miktar yok (mevcut: '
                          + CAST(CAST(@Mevcut AS decimal(18,3)) AS nvarchar(30))
                          + N', istenen: ' + CAST(CAST(@Adet AS decimal(18,3)) AS nvarchar(30)) + N').'
                     FROM STOKSERILOT SSL WHERE SSL.ID = @Serilot);
                CLOSE ci; DEALLOCATE ci;
                THROW 51200, @m, 1;
            END

            INSERT INTO STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR, ADET, KALAN,
                                    YER, YERID, DONUSID, SERILOTID, EKLEYEN)
            SELECT F.URUNID, @HedefTur, @HedefBaslikID, @HedefSatir, ISNULL(F.IZLEME, 0),
                   @Adet, @Adet, 0, 0, 0, @Serilot, @KullaniciID
            FROM FATURA F WHERE F.ID = @HedefSatir;
            SET @YeniIzlem = CAST(SCOPE_IDENTITY() AS INT);
        END

        IF @YeniIzlem IS NOT NULL
        BEGIN
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniIzlem, @DepoId,
                    CASE WHEN @StokDegis = 1 THEN @Yon * @Adet ELSE 0 END);

            UPDATE #DonusumIzlemeSecim SET YeniIzlemeId = @YeniIzlem
             WHERE SatirId = @KaynakSatir
               AND ISNULL(StokIzlemeId, 0) = @Secim
               AND ISNULL(SerilotId, 0) = @Serilot;
            SET @Aktarilan = @Aktarilan + 1;
        END
        FETCH NEXT FROM ci INTO @Secim, @Serilot, @KaynakSatir, @HedefSatir, @Adet;
    END
    CLOSE ci; DEALLOCATE ci;
END
GO
-- ============================================================
-- GenDepoUpdate93.sql
-- BELGE DONUSUM - KODLAMA ADIM 6: sp_Prog_BelgeDonusum_Uygula_Json2 (ANA SP)
--
-- Uygulamanin cagirdigi TEK yazma noktasi. JSON'u BIR KEZ gecici tablolara acar,
--   transaction'i acar, alt SP'leri sirayla cagirir, sonuc sozlesmesini doner.
--   Alt SP'ler kendi transaction'ini ACMAZ (veri sozlesmesi bolum 3).
--
-- AKIS
--   1  Idempotency: ayni ISTEKID daha once TAMAMLANDI ise onceki sonuc doner
--   2  'BASLADI' islem kaydi TRANSACTION DISINDA yazilir
--      (SQL Server'da autonomous transaction yok; aksi halde hata halinde
--       islem izi de rollback ile geri giderdi)
--   3  JSON -> #DonusumKaynakBaslik / #DonusumKaynakSatir / #DonusumIzlemeSecim
--   4  sadeceKontrol=1 ise: yalniz Dogrula calisir, HICBIR YAZMA olmaz
--   5  BEGIN TRAN -> Dogrula -> Kaydet -> IzlemeAktar -> UretimAktar ->
--      Sonlandir -> COMMIT
--   6  Islem kaydi COMMIT/ROLLBACK SONRASI guncellenir
--
-- SONUC (tek satir, tek NVARCHAR(MAX) kolon - JSON)
--   {"Basarili":1,"HataKodu":0,"Mesaj":"","IslemId":..,"IstekId":"..",
--    "HedefBaslikId":..,"HedefTur":..,"YeniBelge":1,"BelgeNo":"..",
--    "Satirlar":[{kaynakBaslikId,kaynakSatirId,hedefSatirId,donusenAdet,kalanAdet}],
--    "Uyarilar":[{kod,kaynakSatirId,mesaj}]}
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2
    @IstekID          UNIQUEIDENTIFIER,
    @DonusumTuru      INT,
    @KullaniciID      INT,
    @SubeID           INT,
    @KaynaklarJson    NVARCHAR(MAX),
    @HedefBaslikID    INT           = 0,
    @HedefAyarlarJson NVARCHAR(MAX) = N'{}',
    @SeceneklerJson   NVARCHAR(MAX) = N'{}'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;   -- hatayi CATCH'te yapilandirilmis sonuca cevirecegiz

    DECLARE @Basarili BIT = 0, @HataKodu INT = 0, @Mesaj NVARCHAR(400) = N'',
            @IslemId INT = 0, @HedefTur INT = 0, @BelgeNo NVARCHAR(50) = NULL,
            @YeniBelge BIT = 0, @Sonuc NVARCHAR(MAX);

    -- ---------- 0) Dis transaction kontrolu ----------
    --   Bu SP transaction SAHIBIDIR. Cagiran kendi transaction'ini acmis olursa
    --   'BASLADI' islem kaydi da o transaction'a dahil olur ve rollback'te geri
    --   gider; idempotency garantisi bozulur (ayni IstekID ikinci kez gelince
    --   onceki kayit gorunmez ve belge IKINCI KEZ uretilir - testte gorulmustur).
    IF @@TRANCOUNT > 0
        THROW 51001, N'Bu SP kendi transaction''ini yonetir; acik bir transaction icinden cagrilamaz.', 1;

    -- ---------- 1) Idempotency ----------
    DECLARE @Durum NVARCHAR(12), @EskiSonuc NVARCHAR(MAX), @Bas DATETIME;
    SELECT @IslemId = ID, @Durum = DURUM, @EskiSonuc = SONUCJSON, @Bas = BASLAMATARIHI
    FROM dbo.BELGEDONUSUMISLEM WHERE ISTEKID = @IstekID;

    IF @Durum = N'TAMAMLANDI'
    BEGIN
        SELECT ISNULL(@EskiSonuc, N'{"Basarili":1,"Mesaj":"Onceden tamamlandi"}') AS Sonuc;
        RETURN;
    END
    IF @Durum = N'BASLADI' AND DATEDIFF(MINUTE, @Bas, GETDATE()) < 5
    BEGIN
        SELECT (SELECT 0 AS Basarili, 51300 AS HataKodu,
                       N'Ayni istek halen isleniyor.' AS Mesaj, @IslemId AS IslemId
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Secenekler ----------
    DECLARE @SadeceKontrol BIT = ISNULL(TRY_CAST(JSON_VALUE(@SeceneklerJson, '$.sadeceKontrol') AS BIT), 0);
    DECLARE @StokOnayi     BIT = ISNULL(TRY_CAST(JSON_VALUE(@SeceneklerJson, '$.stokOnayi')     AS BIT), 0);
    DECLARE @Tarih    DATETIME     = TRY_CAST(JSON_VALUE(@HedefAyarlarJson, '$.tarih') AS DATETIME);
    DECLARE @BNoGiris NVARCHAR(50) = JSON_VALUE(@HedefAyarlarJson, '$.belgeNo');
    DECLARE @BSeriGiris NVARCHAR(50) = JSON_VALUE(@HedefAyarlarJson, '$.belgeSeri');
    DECLARE @VarsDoviz NVARCHAR(10) = ISNULL(JSON_VALUE(@HedefAyarlarJson, '$.varsayilanDoviz'), N'TL');
    DECLARE @Senaryo   INT = ISNULL(TRY_CAST(JSON_VALUE(@HedefAyarlarJson, '$.senaryo') AS INT), 1);
    DECLARE @DovizKurDegeri DECIMAL(18,6) = ISNULL(TRY_CAST(JSON_VALUE(@HedefAyarlarJson, '$.dovizKurDegeri') AS DECIMAL(18,6)), 1);
    SET @Tarih = ISNULL(@Tarih, GETDATE());

    -- ---------- 2) 'BASLADI' - TRANSACTION DISINDA ----------
    IF @SadeceKontrol = 0
    BEGIN
        IF @IslemId > 0
            UPDATE dbo.BELGEDONUSUMISLEM
               SET DURUM = N'BASLADI', BASLAMATARIHI = GETDATE(), BITISTARIHI = NULL,
                   SONUCJSON = NULL, HATAKODU = NULL
             WHERE ID = @IslemId;
        ELSE
        BEGIN
            INSERT dbo.BELGEDONUSUMISLEM (ISTEKID, DONUSUMTURU, KULLANICIID, SUBEID, DURUM)
            VALUES (@IstekID, @DonusumTuru, @KullaniciID, @SubeID, N'BASLADI');
            SET @IslemId = CAST(SCOPE_IDENTITY() AS INT);
        END
    END

    -- ---------- 3) Gecici tablolar ----------
    CREATE TABLE #DonusumKaynakBaslik (
        BaslikId INT PRIMARY KEY, KaynakTur INT, RehberId INT, SubeId INT,
        GirisDepo INT, CikisDepo INT, KdvDurum NVARCHAR(20), RaporDoviz NVARCHAR(10),
        FaturaDovizi NVARCHAR(10), Kur NVARCHAR(10), DovizKur MONEY,
        BelgeNo NVARCHAR(50), Kilitlendi BIT);

    CREATE TABLE #DonusumKaynakSatir (
        Sira INT IDENTITY PRIMARY KEY, BaslikId INT, SatirId INT, UrunId INT, SatirTur INT,
        KaynakAdet DECIMAL(18,6), KaynakMiktar DECIMAL(18,6), DonusenAdet DECIMAL(18,6),
        KalanAdet DECIMAL(18,6), IstenenAdet DECIMAL(18,6), IstenenMiktar DECIMAL(18,6),
        Birim INT, BirimFiyat DECIMAL(18,6), DovizBirimFiyat DECIMAL(18,6),
        Iskonto FLOAT, Iskonto2 FLOAT, Kdv INT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizKurDegeri MONEY, Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        KampanyaId INT, OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), PozNo INT, Izleme INT,
        MuhKodu NVARCHAR(50), Kasa INT, Mf DECIMAL(18,6), OtvYuzde FLOAT,
        OtvMiktar DECIMAL(18,6), IzlemeKodu NVARCHAR(50), Vade INT, KdvMuafiyeti INT,
        EkipmanId INT, StokYeterli BIT, Durum NVARCHAR(20));

    -- SerilotId: kaynak SIPARIS oldugunda kaynakta STOKIZLEME kaydi YOKTUR;
    --   secim depodan yapilir ve lot dogrudan SERILOTID ile gelir.
    --   (StokIzlemeId o durumda 0/NULL kalir - IzlemeAktar dala gore davranir.)
    CREATE TABLE #DonusumIzlemeSecim (
        SatirId INT, StokIzlemeId INT, SerilotId INT NULL,
        Adet DECIMAL(18,6), YeniIzlemeId INT NULL);

    CREATE TABLE #DonusumSatirEsleme (
        Sira INT, KaynakBaslikId INT, KaynakSatirId INT, HedefSatirId INT,
        DonusenAdet DECIMAL(18,6), KalanAdet DECIMAL(18,6));

    CREATE TABLE #DonusumUyari (
        Sira INT IDENTITY, Kod NVARCHAR(30), KaynakSatirId INT NULL, Mesaj NVARCHAR(400));

    -- ROLLBACK'TEN SAG CIKAN KOPYA: #temp yazmalari transaction'a dahildir ve
    --   geri alinir; TABLO DEGISKENI ise transaction'dan etkilenmez. Is kurali
    --   ihlalinde (yetersiz stok, eksik seri/lot) kullaniciya SATIR SATIR sebep
    --   gosterebilmek icin uyarilar rollback'ten ONCE buraya kopyalanir.
    DECLARE @UyariKalici TABLE (Sira INT IDENTITY, Kod NVARCHAR(30),
                                KaynakSatirId INT NULL, Mesaj NVARCHAR(400));

    BEGIN TRY
        -- ---------- Rota ----------
        DECLARE @KaynakBaslikTablo NVARCHAR(20), @KaynakDetayTablo NVARCHAR(20), @Destek BIT;
        SELECT @KaynakBaslikTablo = KaynakBaslikTablo, @KaynakDetayTablo = KaynakDetayTablo,
               @HedefTur = HedefTur, @Destek = Destek
        FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

        IF @KaynakBaslikTablo IS NULL THROW 51200, N'Bilinmeyen donusum turu.', 1;
        IF @Destek = 0 THROW 51200, N'Bu donusum turu sunucu tarafinda desteklenmiyor.', 1;

        -- ---------- JSON -> gecici tablolar ----------
        DECLARE @K TABLE (BaslikId INT PRIMARY KEY, TumKalan BIT, Satirlar NVARCHAR(MAX));
        INSERT @K (BaslikId, TumKalan, Satirlar)
        SELECT TRY_CAST(JSON_VALUE(J.value, '$.baslikId') AS INT),
               ISNULL(TRY_CAST(JSON_VALUE(J.value, '$.tumKalan') AS BIT), 0),
               JSON_QUERY(J.value, '$.satirlar')
        FROM OPENJSON(@KaynaklarJson) J;

        IF NOT EXISTS (SELECT 1 FROM @K) THROW 51001, N'Kaynak belge gonderilmedi.', 1;

        IF @KaynakBaslikTablo = 'SIPARIS'
            INSERT #DonusumKaynakBaslik
            SELECT S.ID, S.TUR, S.REHBERID, S.SUBEID, ISNULL(S.GIRISDEPO,0), ISNULL(S.CIKISDEPO,0),
                   S.KDVDURUM, S.RAPORDOVIZ, S.RAPORDOVIZ, S.KUR, ISNULL(S.DOVIZKUR,1), S.SIPARISNO, 0
            FROM SIPARIS S INNER JOIN @K K ON K.BaslikId = S.ID;
        ELSE
            INSERT #DonusumKaynakBaslik
            SELECT B.ID, B.TUR, B.REHBERID, B.SUBEID, ISNULL(B.GIRISDEPO,0), ISNULL(B.CIKISDEPO,0),
                   B.KDVDURUM, B.RAPORDOVIZ, B.FATURADOVIZI, B.KUR, ISNULL(B.DOVIZKUR,1), B.FATURANO, 0
            FROM FATBASLIK B INNER JOIN @K K ON K.BaslikId = B.ID;

        IF (SELECT COUNT(*) FROM #DonusumKaynakBaslik) <> (SELECT COUNT(*) FROM @K)
            THROW 51002, N'Kaynak belgelerden biri bulunamadi.', 1;

        -- Satir bazli istek (varsa)
        DECLARE @Ist TABLE (BaslikId INT, SatirId INT, Adet DECIMAL(18,6), Miktar DECIMAL(18,6),
                            BirimFiyat DECIMAL(18,6), DovizBirimFiyat DECIMAL(18,6),
                            Iskonto FLOAT, Iskonto2 FLOAT, Kdv INT, Aciklama NVARCHAR(250),
                            ProjeId INT, MasrafId INT, KampanyaId INT, Izlemeler NVARCHAR(MAX));
        INSERT @Ist
        SELECT K.BaslikId, J.SatirId, J.Adet, J.Miktar, J.BirimFiyat, J.DovizBirimFiyat,
               J.Iskonto, J.Iskonto2, J.Kdv, J.Aciklama, J.ProjeId, J.MasrafId, J.KampanyaId,
               J.Izlemeler
        FROM @K K
             CROSS APPLY OPENJSON(K.Satirlar)
                  WITH (SatirId INT '$.satirId', Adet DECIMAL(18,6) '$.adet',
                        Miktar DECIMAL(18,6) '$.miktar', BirimFiyat DECIMAL(18,6) '$.birimFiyat',
                        DovizBirimFiyat DECIMAL(18,6) '$.dovizBirimFiyat',
                        Iskonto FLOAT '$.iskonto', Iskonto2 FLOAT '$.iskonto2', Kdv INT '$.kdv',
                        Aciklama NVARCHAR(250) '$.aciklama', ProjeId INT '$.projeId',
                        MasrafId INT '$.masrafId', KampanyaId INT '$.kampanyaId',
                        Izlemeler NVARCHAR(MAX) '$.izlemeler' AS JSON) J
        WHERE K.Satirlar IS NOT NULL;

        -- Kaynak satirlar: satir listesi verilmisse yalniz onlar, yoksa tum satirlar
        IF @KaynakDetayTablo = 'SIPARISDETAY'
            INSERT #DonusumKaynakSatir (BaslikId, SatirId, UrunId, SatirTur, KaynakAdet, KaynakMiktar,
                IstenenAdet, IstenenMiktar, Birim, BirimFiyat, DovizBirimFiyat, Iskonto, Iskonto2,
                Kdv, Kur, DovizKuru, DovizKurDegeri, Aciklama, ProjeId, MasrafId, KampanyaId,
                OzelKod, OzelKod2, PozNo, Izleme, MuhKodu, Kasa, Mf, OtvYuzde, OtvMiktar,
                IzlemeKodu, Vade, KdvMuafiyeti, EkipmanId)
            SELECT SD.SIPARISID, SD.ID, SD.URUNID, ISNULL(SD.TUR,1), SD.ADET, ISNULL(SD.MIKTAR, SD.ADET),
                   I.Adet, I.Miktar, ISNULL(SD.BIRIM,0),
                   ISNULL(I.BirimFiyat, ISNULL(SD.BIRIMFIYAT,0)),
                   ISNULL(I.DovizBirimFiyat, ISNULL(SD.DOVIZ_BIRIMFIYAT,0)),
                   ISNULL(I.Iskonto, ISNULL(SD.ISKONTO,0)), ISNULL(I.Iskonto2, ISNULL(SD.ISKONTO2,0)),
                   ISNULL(I.Kdv, ISNULL(SD.KDV,0)), ISNULL(SD.KUR,N'TL'), ISNULL(SD.DOVIZ_KURU,N'TL'),
                   ISNULL(SD.DOVIZKURDEGERI,1), ISNULL(I.Aciklama, ISNULL(SD.ACIKLAMA,N'')),
                   ISNULL(I.ProjeId, ISNULL(SD.PROJEID,0)), ISNULL(I.MasrafId, ISNULL(SD.MASRAFID,0)),
                   ISNULL(I.KampanyaId, ISNULL(SD.KAMPANYAID,0)),
                   ISNULL(SD.OZELKOD,N''), ISNULL(SD.OZELKOD2,N''), ISNULL(SD.POZNO,0),
                   ISNULL(ST.IZLEME,0), SD.MUHKODU, ISNULL(SD.KASA,0), ISNULL(SD.MF,0),
                   ISNULL(SD.OTVYUZDE,0), ISNULL(SD.OTVMIKTAR,0), SD.IZLEMEKODU, ISNULL(SD.VADE,0),
                   NULL,   -- KDVMUHAFIYETI SIPARISDETAY'da YOK
                   ISNULL(SD.EKIPMANID,0)
            FROM SIPARISDETAY SD
                 INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = SD.SIPARISID
                 LEFT JOIN STOKLAR ST ON ST.ID = SD.URUNID
                 LEFT JOIN @Ist I ON I.SatirId = SD.ID
            WHERE NOT EXISTS (SELECT 1 FROM @Ist X WHERE X.BaslikId = SD.SIPARISID)
               OR I.SatirId IS NOT NULL;
        ELSE
            INSERT #DonusumKaynakSatir (BaslikId, SatirId, UrunId, SatirTur, KaynakAdet, KaynakMiktar,
                IstenenAdet, IstenenMiktar, Birim, BirimFiyat, DovizBirimFiyat, Iskonto, Iskonto2,
                Kdv, Kur, DovizKuru, DovizKurDegeri, Aciklama, ProjeId, MasrafId, KampanyaId,
                OzelKod, OzelKod2, PozNo, Izleme, MuhKodu, Kasa, Mf, OtvYuzde, OtvMiktar,
                IzlemeKodu, Vade, KdvMuafiyeti, EkipmanId)
            SELECT F.FATBASID, F.ID, F.URUNID, ISNULL(F.TUR,1), F.ADET, ISNULL(F.MIKTAR, F.ADET),
                   I.Adet, I.Miktar, ISNULL(F.BIRIM,0),
                   ISNULL(I.BirimFiyat, ISNULL(F.BIRIMFIYAT,0)),
                   ISNULL(I.DovizBirimFiyat, ISNULL(F.DOVIZ_BIRIMFIYAT,0)),
                   ISNULL(I.Iskonto, ISNULL(F.ISKONTO,0)), ISNULL(I.Iskonto2, ISNULL(F.ISKONTO2,0)),
                   ISNULL(I.Kdv, ISNULL(F.KDV,0)), ISNULL(F.KUR,N'TL'), ISNULL(F.DOVIZ_KURU,N'TL'),
                   ISNULL(F.DOVIZKURDEGERI,1), ISNULL(I.Aciklama, ISNULL(F.ACIKLAMA,N'')),
                   ISNULL(I.ProjeId, ISNULL(F.PROJEID,0)), ISNULL(I.MasrafId, ISNULL(F.MASRAFID,0)),
                   ISNULL(I.KampanyaId, ISNULL(F.KAMPANYAID,0)),
                   ISNULL(F.OZELKOD,N''), ISNULL(F.OZELKOD2,N''), ISNULL(F.POZNO,0),
                   ISNULL(ST.IZLEME,0), F.MUHKODU, ISNULL(F.KASA,0), ISNULL(F.MF,0),
                   ISNULL(F.OTVYUZDE,0), ISNULL(F.OTVMIKTAR,0), F.IZLEMEKODU, ISNULL(F.VADE,0),
                   F.KDVMUHAFIYETI, ISNULL(F.EKIPMANID,0)
            FROM FATURA F
                 INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = F.FATBASID
                 LEFT JOIN STOKLAR ST ON ST.ID = F.URUNID
                 LEFT JOIN @Ist I ON I.SatirId = F.ID
            WHERE NOT EXISTS (SELECT 1 FROM @Ist X WHERE X.BaslikId = F.FATBASID)
               OR I.SatirId IS NOT NULL;

        -- Izleme secimleri
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, SerilotId, Adet)
        SELECT I.SatirId, ISNULL(J.StokIzlemeId, 0), J.SerilotId, J.Adet
        FROM @Ist I CROSS APPLY OPENJSON(I.Izlemeler)
             WITH (StokIzlemeId INT '$.stokIzlemeId', SerilotId INT '$.serilotId',
                   Adet DECIMAL(18,6) '$.adet') J
        WHERE I.Izlemeler IS NOT NULL
          AND (ISNULL(J.StokIzlemeId, 0) > 0 OR ISNULL(J.SerilotId, 0) > 0);

        -- ---------- 4) Sadece kontrol ----------
        DECLARE @HataSayisi INT = 0;
        IF @SadeceKontrol = 1
        BEGIN
            EXEC dbo.sp_Prog_BelgeDonusum_Dogrula @DonusumTuru = @DonusumTuru,
                 @HedefBaslikID = @HedefBaslikID, @SubeID = @SubeID, @Tarih = @Tarih,
                 @StokOnayi = @StokOnayi, @SadeceKontrol = 1, @HataSayisi = @HataSayisi OUTPUT;
            INSERT @UyariKalici (Kod, KaynakSatirId, Mesaj)
            SELECT Kod, KaynakSatirId, Mesaj FROM #DonusumUyari ORDER BY Sira;
            SET @Basarili = CASE WHEN @HataSayisi > 0 THEN 0 ELSE 1 END;
            SET @HataKodu = CASE WHEN @HataSayisi > 0 THEN 51200 ELSE 0 END;
            SET @Mesaj = CASE WHEN @HataSayisi > 0
                              THEN N'Kontrolde engel bulundu - ayrintilar uyarilarda.'
                              ELSE N'Kontrol tamamlandi.' END;
            GOTO Bitir;
        END

        -- ---------- 5) Islem ----------
        BEGIN TRAN;

        EXEC dbo.sp_Prog_BelgeDonusum_Dogrula @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefBaslikID, @SubeID = @SubeID, @Tarih = @Tarih,
             @StokOnayi = @StokOnayi, @SadeceKontrol = 0, @HataSayisi = @HataSayisi OUTPUT;

        -- Dogrula is kurali ihlalinde THROW ETMEZ, @HataSayisi doner (uyarilar
        --   rollback'te kaybolmasin diye). Once uyarilari KALICI kopyaya al,
        --   sonra geri sar.
        IF @HataSayisi > 0
        BEGIN
            INSERT @UyariKalici (Kod, KaynakSatirId, Mesaj)
            SELECT Kod, KaynakSatirId, Mesaj FROM #DonusumUyari ORDER BY Sira;
            ROLLBACK;
            SET @Basarili = 0;
            SET @HataKodu = 51200;
            SET @Mesaj = N'Donusum yapilamadi - ayrintilar uyarilarda.';
            GOTO Bitir;
        END

        DECLARE @HedefOut INT, @BNoOut NVARCHAR(50), @YeniOut BIT;
        EXEC dbo.sp_Prog_BelgeDonusum_Kaydet @DonusumTuru = @DonusumTuru,
             @KullaniciID = @KullaniciID, @SubeID = @SubeID, @Tarih = @Tarih,
             @HedefBaslikID = @HedefBaslikID, @BelgeNoGiris = @BNoGiris,
             @BelgeSeriGiris = @BSeriGiris, @VarsayilanDoviz = @VarsDoviz, @Senaryo = @Senaryo,
             @HedefBaslikOut = @HedefOut OUTPUT, @BelgeNoOut = @BNoOut OUTPUT,
             @YeniBelgeOut = @YeniOut OUTPUT;

        DECLARE @Akt INT, @Sarf INT, @Yor INT;
        EXEC dbo.sp_Prog_BelgeDonusum_IzlemeAktar @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefOut, @KullaniciID = @KullaniciID, @Aktarilan = @Akt OUTPUT;

        EXEC dbo.sp_Prog_BelgeDonusum_UretimAktar @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefOut, @KullaniciID = @KullaniciID, @SubeID = @SubeID,
             @VarsayilanDoviz = @VarsDoviz, @DovizKurDegeri = @DovizKurDegeri,
             @Eklenen = @Sarf OUTPUT;

        EXEC dbo.sp_Prog_BelgeDonusum_Sonlandir @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefOut, @KullaniciID = @KullaniciID, @SubeID = @SubeID,
             @Yorum = @Yor OUTPUT;

        COMMIT;

        SET @Basarili = 1;
        SET @HedefBaslikID = @HedefOut;
        SET @BelgeNo = @BNoOut;
        SET @YeniBelge = @YeniOut;
    END TRY
    BEGIN CATCH
        -- Yapisal hata (THROW) yolu: uyarilar zaten rollback'e gidecek; varsa
        --   once kalici kopyaya alalim.
        IF XACT_STATE() <> -1
            INSERT @UyariKalici (Kod, KaynakSatirId, Mesaj)
            SELECT Kod, KaynakSatirId, Mesaj FROM #DonusumUyari ORDER BY Sira;
        IF XACT_STATE() <> 0 ROLLBACK;
        SET @Basarili = 0;
        SET @HataKodu = ERROR_NUMBER();
        SET @Mesaj = LEFT(ERROR_MESSAGE(), 400);
    END CATCH

Bitir:
    -- ---------- 6) Sonuc ----------
    --   Uyari ve eslesme listeleri, rollback olsa bile gecici tablolarda kaldigi
    --   surece raporlanir. (ROLLBACK gecici tablo yazmalarini da geri alir; bu
    --   yuzden hata halinde liste bos gelebilir - mesaj her zaman doludur.)
    DECLARE @SatirJson NVARCHAR(MAX) =
        ISNULL((SELECT KaynakBaslikId AS kaynakBaslikId, KaynakSatirId AS kaynakSatirId,
                       HedefSatirId AS hedefSatirId, DonusenAdet AS donusenAdet,
                       KalanAdet AS kalanAdet
                FROM #DonusumSatirEsleme ORDER BY Sira FOR JSON PATH), N'[]');
    -- Uyarilar KALICI kopyadan okunur; #DonusumUyari rollback olduysa bostur.
    DECLARE @UyariJson NVARCHAR(MAX) =
        ISNULL((SELECT Kod AS kod, KaynakSatirId AS kaynakSatirId, Mesaj AS mesaj
                FROM @UyariKalici ORDER BY Sira FOR JSON PATH), N'[]');
    IF @UyariJson = N'[]'
        SET @UyariJson = ISNULL((SELECT Kod AS kod, KaynakSatirId AS kaynakSatirId, Mesaj AS mesaj
                                 FROM #DonusumUyari ORDER BY Sira FOR JSON PATH), N'[]');

    -- Elle string birlestirme YOK: FOR JSON kacislari (tirnak, Turkce, satir sonu)
    --   dogru yapar; JSON_QUERY ile alt diziler string'e cevrilmeden gomulur.
    SET @Sonuc = (SELECT @Basarili AS Basarili, @HataKodu AS HataKodu, @Mesaj AS Mesaj,
                         @IslemId AS IslemId, CAST(@IstekID AS nvarchar(40)) AS IstekId,
                         ISNULL(@HedefBaslikID, 0) AS HedefBaslikId,
                         ISNULL(@HedefTur, 0) AS HedefTur, @YeniBelge AS YeniBelge,
                         @BelgeNo AS BelgeNo,
                         JSON_QUERY(@SatirJson) AS Satirlar,
                         JSON_QUERY(@UyariJson) AS Uyarilar
                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);

    -- ---------- Islem kaydi (COMMIT/ROLLBACK SONRASI) ----------
    IF @SadeceKontrol = 0 AND @IslemId > 0
        UPDATE dbo.BELGEDONUSUMISLEM
           SET DURUM = CASE WHEN @Basarili = 1 THEN N'TAMAMLANDI' ELSE N'HATA' END,
               HEDEFBASLIKID = NULLIF(@HedefBaslikID, 0), HEDEFTUR = NULLIF(@HedefTur, 0),
               BITISTARIHI = GETDATE(), SONUCJSON = @Sonuc, HATAKODU = NULLIF(@HataKodu, 0)
         WHERE ID = @IslemId;

    SELECT @Sonuc AS Sonuc;
END
GO

GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Uygula_Json2 TO gentegre_api;
GO
