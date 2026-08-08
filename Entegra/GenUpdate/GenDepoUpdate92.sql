-- ============================================================
-- GenDepoUpdate92.sql
-- BELGE DONUSUM - KODLAMA ADIM 5: IzlemeAktar / UretimAktar / Sonlandir
--
--   dbo.fn_Prog_BelgeDonusum_YorumTabNo : belge TUR -> GOREVYORUM.TUR
--   dbo.sp_Prog_BelgeDonusum_IzlemeAktar
--   dbo.sp_Prog_BelgeDonusum_UretimAktar
--   dbo.sp_Prog_BelgeDonusum_Sonlandir
--
-- Ucu de ana SP tarafindan TRANSACTION ICINDE cagrilir; kendi transaction'ini
--   acmaz, hata halinde THROW eder.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- fn_Prog_BelgeDonusum_YorumTabNo
--
-- DIKKAT: GOREVYORUM.TUR, ISLEMLOG'un TABLOID'inden FARKLI bir TabNo ailesi
--   kullanir. Ornegin alis siparisi icin ISLEMLOG TABLOID 28 (fn_Api_Belge_TabNo)
--   ama GOREVYORUM.TUR 91'dir (TabNo_SIPARIS_Gelen). Ikisini karistirmak
--   yorumlarin gorunmez bir sekmeye baglanmasina yol acar - bu yuzden ayri
--   fonksiyon.
--   Degerler Utablo.pas'taki TabNo_* sabitlerinden alindi.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Prog_BelgeDonusum_YorumTabNo (@BelgeTur INT)
RETURNS INT
AS
BEGIN
    RETURN CASE @BelgeTur
        WHEN   9 THEN  91   -- TabNo_SIPARIS_Gelen    (alis siparisi)
        WHEN  19 THEN  92   -- TabNo_SIPARIS_Giden    (satis siparisi)
        WHEN  10 THEN 104   -- TabNo_IRSALIYE_Gelen
        WHEN  14 THEN 105   -- TabNo_IRSALIYE_Giden
        WHEN  11 THEN  28   -- TabNo_FATBASLIK_Gelen  (alis faturasi)
        WHEN  15 THEN  29   -- TabNo_FATBASLIK_Giden  (satis faturasi)
        WHEN  12 THEN 106   -- TabNo_FIS_Gelen
        WHEN  16 THEN 107   -- TabNo_FIS_Giden
        WHEN  20 THEN 134   -- TabNo_TRANSFER
        WHEN   6 THEN 144   -- TabNo_URETIMFISI
        WHEN 109 THEN 209   -- TabNo_KONSINYE_GELEN
        WHEN 119 THEN 219   -- TabNo_KONSINYE_GIDEN
        WHEN 101 THEN 463   -- TabNo_SATINALMA       (satinalma talebi)
        WHEN 105 THEN 464   -- TabNo_STOKTALEP
        ELSE NULL END;
END
GO

-- ============================================================
-- sp_Prog_BelgeDonusum_IzlemeAktar
--
-- Secilen seri/lot kayitlarini hedef satirlara tasir.
--
-- DAVRANIS DEGISIKLIGI [K6 / 2.4]: kaynak STOKIZLEME kaydinin KALAN'i TAMAMEN
--   sifirlanmaz; YALNIZ DONUSEN MIKTAR dusulur. Eski akis kismi donusumde de
--   KALAN=0 yapiyordu, bu yuzden kismen donusmus seri/lot kayitlari izleme
--   raporlarinda "tukendi" gorunuyordu.
--   BULGU: dogru dusumu TG_IzlemOrjinalYap trigger'i ZATEN yapiyor; eski akistaki
--   hata, trigger'in isini yaptiktan SONRA Pascal'in KALAN=0 yazmasiydi. Bu SP
--   kalana elle DOKUNMAZ.
--
-- Depo secimi eski akisla ayni: cikis nitelikli hedef turlerde CIKISDEPO,
--   digerlerinde GIRISDEPO.
-- ============================================================
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

    DECLARE @Secim INT, @KaynakSatir INT, @HedefSatir INT, @Adet DECIMAL(18,6), @YeniIzlem INT;

    DECLARE ci CURSOR LOCAL FAST_FORWARD FOR
        SELECT I.StokIzlemeId, I.SatirId, E.HedefSatirId, I.Adet
        FROM #DonusumIzlemeSecim I
             INNER JOIN #DonusumSatirEsleme E ON E.KaynakSatirId = I.SatirId
        ORDER BY I.SatirId, I.StokIzlemeId;
    OPEN ci; FETCH NEXT FROM ci INTO @Secim, @KaynakSatir, @HedefSatir, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR, ADET, KALAN,
                                YER, YERID, DONUSID, SERILOTID, EKLEYEN)
        SELECT SI.STOKID, @HedefTur, @HedefBaslikID, @HedefSatir, SI.IZLEMTUR, @Adet, @Adet,
               SI.YER, 0, SI.ID, SI.SERILOTID, @KullaniciID
        FROM STOKIZLEME SI
             INNER JOIN STOKSERILOT SSL ON SI.SERILOTID = SSL.ID
        WHERE SI.ID = @Secim;

        SET @YeniIzlem = CAST(SCOPE_IDENTITY() AS INT);
        IF @YeniIzlem IS NOT NULL
        BEGIN
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@YeniIzlem, @DepoId, 0);

            -- [K6/2.4] KAYNAGIN KALAN'INA ELLE DOKUNULMUYOR.
            --   TG_IzlemOrjinalYap (STOKIZLEME AFTER INSERT) yeni satirin DONUSID'sine
            --   bakip kaynagin KALAN'ini ZATEN DUSURUYOR. Testle dogrulandi:
            --   kalan 2 iken 1 adetlik aktarim sonrasi trigger kalani 1 yapiyor.
            --   Eski Pascal akisi bunun USTUNE 'update STOKIZLEME set KALAN=0' yaziyordu;
            --   kismi donusumde kalanin tamamen sifirlanmasinin sebebi buydu. Burada o
            --   UPDATE YOK - dolayisiyla kismi izleme kendiliginden dogru calisiyor.
            --   (Ilk yazimda elle dusme de eklemistim; trigger ile CIFTE DUSUM yapip
            --    kalani 0'a indiriyordu - test yakaladi, kaldirildi.)

            UPDATE #DonusumIzlemeSecim SET YeniIzlemeId = @YeniIzlem
             WHERE StokIzlemeId = @Secim AND SatirId = @KaynakSatir;
            SET @Aktarilan = @Aktarilan + 1;
        END
        FETCH NEXT FROM ci INTO @Secim, @KaynakSatir, @HedefSatir, @Adet;
    END
    CLOSE ci; DEALLOCATE ci;
END
GO

-- ============================================================
-- sp_Prog_BelgeDonusum_UretimAktar
--
-- Uretime URUN olarak eklenen satirlarin recetesindeki SARF satirlarini hedef
--   belgeye ekler. Yalniz UretimRecete=1 olan rotada (415) calisir.
--   Kurallar eski BelgeDonustur_DetaySatirOlustur ile birebir:
--     ADET/MIKTAR receteden x hedef satirin miktari
--     BIRIMFIYAT = MALIYETSON, TUTAR = MALIYETORT
--     doviz alanlari DovizKurDegeri'ne bolunerek
--     YERI = TabNo_URETIMRECETEDETAY, YERID = URETIMRECETEDETAY.ID
--     EKIPMANID = MIKTAR > 0 ? 1 : -1
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_UretimAktar
    @DonusumTuru     INT,
    @HedefBaslikID   INT,
    @KullaniciID     INT,
    @SubeID          INT,
    @VarsayilanDoviz NVARCHAR(10) = N'TL',
    @DovizKurDegeri  DECIMAL(18,6) = 1,
    @Eklenen         INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Eklenen = 0;

    IF NOT EXISTS (SELECT 1 FROM dbo.fn_Prog_BelgeDonusum_Rota()
                    WHERE DonusumTuru = @DonusumTuru AND UretimRecete = 1)
        RETURN;

    -- TabNo_URETIMRECETEDETAY = 139 (Utablo.pas). Recete satirinin baglantisi.
    DECLARE @TabRecete INT = 139;

    INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, ACIKLAMA, ADET, BIRIM, MIKTAR,
                        BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV,
                        DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT, DOVIZKURDEGERI,
                        MASRAFID, IZLEME, STOKDURUMDEGIS, SUBEID, EKLEYEN, EKLEMETARIHI,
                        YERI, YERID, EKIPMANID)
    SELECT @HedefBaslikID, 0, URD.TUR, URD.URUNID, URD.ACIKLAMA,
           URD.ADET * H.MIKTAR, URD.BIRIM, URD.MIKTAR * H.MIKTAR,
           URD.MALIYETSON, URD.MALIYETORT, @VarsayilanDoviz, 0, 0, S.KDV,
           URD.MALIYETORT / NULLIF(@DovizKurDegeri, 0), @VarsayilanDoviz,
           URD.MALIYETSON / NULLIF(@DovizKurDegeri, 0), @DovizKurDegeri,
           URD.MASRAFID, S.IZLEME, 1, @SubeID, @KullaniciID, GETDATE(),
           @TabRecete, URD.ID,
           CASE WHEN URD.MIKTAR > 0.0 THEN 1 ELSE -1 END
    FROM #DonusumSatirEsleme E
         INNER JOIN FATURA H  ON H.ID = E.HedefSatirId
         INNER JOIN URETIMRECETE R ON R.STOKID = H.URUNID
         INNER JOIN URETIMRECETEDETAY URD ON URD.URETIMRECETEID = R.ID
                                         AND URD.URUNID <> H.URUNID
         INNER JOIN STOKLAR S ON S.ID = URD.URUNID;

    SET @Eklenen = @@ROWCOUNT;
END
GO

-- ============================================================
-- sp_Prog_BelgeDonusum_Sonlandir
--
-- 1) Kaynak belgelerin DURUM'u  -> mevcut sp_Api_Belge_Durum_Yaz_Ic yeniden
--    kullanilir (ayni mantik ikinci kez yazilmiyor)
-- 2) Irsaliye -> fatura/fis sonrasi kaynak "durtme": kaynak FATURA satirlari
--    guncellenerek TG_StokDurumGuncelle ve TG_StokFiyatGuncelle uyandirilir.
--    (Trigger envanteri: TG_MaliyetGuncelle DEVRE DISI ve FATBASLIK'ta - eski
--     varsayim yanlisti.)
-- 3) Yorum kopyalama [K5 + T2]: TUM rotalarda. Yorumun kendisi + yoruma bagli
--    DOKUMAN (MODUL=210) + o dokumanin IMAJ satirlari kopyalanir.
--    IMAJ icerigi GENDEPO.DOSYA'da (FILESTREAM, hash-dedup); DOSYAID
--    referansi PAYLASILIR, icerik cogaltilmaz.
--    Kolon listeleri sys.columns'tan URETILIR - elle yazilmis kolon listesi
--    sema degisince sessizce bozulurdu.
--
-- TOPLAM/MALIYET YAZILMAZ: toplamlari Kaydet, stok/maliyeti trigger'lar yazar
--   (veri sozlesmesi bolum 8 - cifte hesap riski).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Sonlandir
    @DonusumTuru   INT,
    @HedefBaslikID INT,
    @KullaniciID   INT,
    @SubeID        INT,
    @Yorum         INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Yorum = 0;

    DECLARE @KaynakTur INT, @HedefTur INT, @KaynakBaslikTablo NVARCHAR(20);
    SELECT @KaynakTur = KaynakTur, @HedefTur = HedefTur, @KaynakBaslikTablo = KaynakBaslikTablo
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    -- ---------- 1) Kaynak belge durumu ----------
    DECLARE @KaynakAd NVARCHAR(10) = CASE WHEN @KaynakBaslikTablo = 'SIPARIS'
                                          THEN N'siparis' ELSE N'belge' END;
    DECLARE @bId INT, @dTur INT, @dDurum INT, @dOnce INT, @dSat INT, @dTam INT,
            @dKis INT, @dAcik INT, @dNeden NVARCHAR(60), @dYaz BIT;

    DECLARE cb CURSOR LOCAL FAST_FORWARD FOR SELECT BaslikId FROM #DonusumKaynakBaslik;
    OPEN cb; FETCH NEXT FROM cb INTO @bId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @bId, @Kaynak = @KaynakAd,
             @Tur = @dTur OUTPUT, @Durum = @dDurum OUTPUT, @OncekiDurum = @dOnce OUTPUT,
             @Satir = @dSat OUTPUT, @Tamamlanan = @dTam OUTPUT, @Kismi = @dKis OUTPUT,
             @Acik = @dAcik OUTPUT, @Neden = @dNeden OUTPUT, @Yazildi = @dYaz OUTPUT;
        FETCH NEXT FROM cb INTO @bId;
    END
    CLOSE cb; DEALLOCATE cb;

    -- ---------- 2) Kaynak durtme (irsaliye -> fatura/fis) ----------
    IF @DonusumTuru IN (408, 427, 411, 424)
        UPDATE F SET F.STOKDURUMDEGIS = F.STOKDURUMDEGIS
          FROM FATURA F
               INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = F.FATBASID;

    -- ---------- 3) Yorum kopyalama ----------
    DECLARE @KayTab INT = dbo.fn_Prog_BelgeDonusum_YorumTabNo(@KaynakTur);
    DECLARE @HedTab INT = dbo.fn_Prog_BelgeDonusum_YorumTabNo(@HedefTur);

    IF @KayTab IS NOT NULL AND @HedTab IS NOT NULL
       AND EXISTS (SELECT 1 FROM GOREVYORUM Y
                    INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = Y.GOREVID
                    WHERE Y.TUR = @KayTab)
    BEGIN
        -- Kopyalanacak yorumlar
        DECLARE @Y TABLE (EskiId INT PRIMARY KEY, YeniId INT NULL);
        INSERT @Y (EskiId)
        SELECT Y.ID FROM GOREVYORUM Y
               INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = Y.GOREVID
        WHERE Y.TUR = @KayTab;

        -- GOREVYORUM kolonlari (IDENTITY/computed/temporal haric), override edilenler ayri
        DECLARE @Kol NVARCHAR(MAX) =
            STUFF((SELECT N',' + QUOTENAME(c.name) FROM sys.columns c
                    WHERE c.object_id = OBJECT_ID('GOREVYORUM')
                      AND c.is_identity = 0 AND c.is_computed = 0
                      AND c.generated_always_type = 0 AND c.is_hidden = 0
                      AND c.name NOT IN ('GOREVID','TUR','EKLEYEN','EKLEMETARIHI',
                                         'DEGISTIREN','DEGISTIRMETARIHI')
                    ORDER BY c.column_id FOR XML PATH('')), 1, 1, N'');

        DECLARE @eski INT, @yeni INT, @sql NVARCHAR(MAX);
        DECLARE @HedefGorevId INT = @HedefBaslikID;

        DECLARE cy CURSOR LOCAL FAST_FORWARD FOR SELECT EskiId FROM @Y ORDER BY EskiId;
        OPEN cy; FETCH NEXT FROM cy INTO @eski;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = N'INSERT INTO GOREVYORUM (GOREVID, TUR, EKLEYEN, EKLEMETARIHI, '
                     + N'DEGISTIREN, DEGISTIRMETARIHI, ' + @Kol + N') '
                     + N'SELECT @pHedef, @pTab, @pKul, GETDATE(), @pKul, GETDATE(), ' + @Kol
                     + N' FROM GOREVYORUM WHERE ID = @pEski; SET @pYeni = CAST(SCOPE_IDENTITY() AS INT);';
            EXEC sp_executesql @sql,
                 N'@pHedef INT, @pTab INT, @pKul INT, @pEski INT, @pYeni INT OUTPUT',
                 @pHedef = @HedefGorevId, @pTab = @HedTab, @pKul = @KullaniciID,
                 @pEski = @eski, @pYeni = @yeni OUTPUT;

            UPDATE @Y SET YeniId = @yeni WHERE EskiId = @eski;
            SET @Yorum = @Yorum + 1;
            FETCH NEXT FROM cy INTO @eski;
        END
        CLOSE cy; DEALLOCATE cy;

        -- ---- Yoruma bagli DOKUMAN (MODUL=210) + IMAJ ----
        IF EXISTS (SELECT 1 FROM DOKUMAN D INNER JOIN @Y Y ON Y.EskiId = D.MODULID
                    WHERE D.MODUL = 210)
        BEGIN
            DECLARE @DKol NVARCHAR(MAX) =
                STUFF((SELECT N',' + QUOTENAME(c.name) FROM sys.columns c
                        WHERE c.object_id = OBJECT_ID('DOKUMAN')
                          AND c.is_identity = 0 AND c.is_computed = 0
                          AND c.generated_always_type = 0 AND c.is_hidden = 0
                          AND c.name NOT IN ('MODULID','EKLEYEN','EKLEMETARIHI',
                                             'DEGISTIREN','DEGISTIRMETARIHI')
                        ORDER BY c.column_id FOR XML PATH('')), 1, 1, N'');
            DECLARE @IKol NVARCHAR(MAX) =
                STUFF((SELECT N',' + QUOTENAME(c.name) FROM sys.columns c
                        WHERE c.object_id = OBJECT_ID('IMAJ')
                          AND c.is_identity = 0 AND c.is_computed = 0
                          AND c.generated_always_type = 0 AND c.is_hidden = 0
                          AND c.name NOT IN ('YER_ID','EKLEYEN','EKLEMETARIHI',
                                             'DEGISTIREN','DEGISTIRMETARIHI')
                        ORDER BY c.column_id FOR XML PATH('')), 1, 1, N'');

            DECLARE @eskiDok INT, @yeniYorum INT, @yeniDok INT;
            DECLARE cd CURSOR LOCAL FAST_FORWARD FOR
                SELECT D.ID, Y.YeniId FROM DOKUMAN D INNER JOIN @Y Y ON Y.EskiId = D.MODULID
                 WHERE D.MODUL = 210 AND Y.YeniId IS NOT NULL;
            OPEN cd; FETCH NEXT FROM cd INTO @eskiDok, @yeniYorum;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @sql = N'INSERT INTO DOKUMAN (MODULID, EKLEYEN, EKLEMETARIHI, DEGISTIREN, '
                         + N'DEGISTIRMETARIHI, ' + @DKol + N') '
                         + N'SELECT @pYorum, @pKul, GETDATE(), @pKul, GETDATE(), ' + @DKol
                         + N' FROM DOKUMAN WHERE ID = @pEski; SET @pYeni = CAST(SCOPE_IDENTITY() AS INT);';
                EXEC sp_executesql @sql,
                     N'@pYorum INT, @pKul INT, @pEski INT, @pYeni INT OUTPUT',
                     @pYorum = @yeniYorum, @pKul = @KullaniciID, @pEski = @eskiDok,
                     @pYeni = @yeniDok OUTPUT;

                -- IMAJ satirlari: DOSYAID referansi PAYLASILIR (FILESTREAM icerigi cogaltilmaz)
                SET @sql = N'INSERT INTO IMAJ (YER_ID, EKLEYEN, EKLEMETARIHI, DEGISTIREN, '
                         + N'DEGISTIRMETARIHI, ' + @IKol + N') '
                         + N'SELECT @pDok, @pKul, GETDATE(), @pKul, GETDATE(), ' + @IKol
                         + N' FROM IMAJ WHERE YERI = 1 AND YER_ID = @pEski;';
                EXEC sp_executesql @sql, N'@pDok INT, @pKul INT, @pEski INT',
                     @pDok = @yeniDok, @pKul = @KullaniciID, @pEski = @eskiDok;

                FETCH NEXT FROM cd INTO @eskiDok, @yeniYorum;
            END
            CLOSE cd; DEALLOCATE cd;
        END
    END
END
GO

GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_IzlemeAktar TO gentegre_api;
GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_UretimAktar TO gentegre_api;
GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Sonlandir   TO gentegre_api;
GO
