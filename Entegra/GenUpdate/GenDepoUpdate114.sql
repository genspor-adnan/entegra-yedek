-- ============================================================
-- GenDepoUpdate114.sql
-- ROTA 428 ACILDI: satinalma talebi -> alis siparisi artik sunucuda
--
-- 428, hedefi SIPARIS olan TEK rotaydi ve Destek=0 ile eski Pascal akisinda
--   birakilmisti: "SIPARIS tarafinda es deger bir kanonik kaydet SP'si yok,
--   ikiz uretim yazmamak icin". GenDepoUpdate113 ile o eksik kapandi
--   (sp_Api_Belge_Siparis_Kaydet_Json).
--
-- UC DEGISIKLIK
--   1) fn_Prog_BelgeDonusum_Rota   : 428 Destek 0 -> 1
--   2) sp_Prog_BelgeDonusum_Kaydet : hedef tabloya gore kanonik SP secimi.
--      JSON sozlesmesi AYNI kaldi - siparis SP'si "Fatura..." adlarini da
--      tanidigi icin ikiz JSON uretmeye gerek yok.
--   3) sp_Prog_BelgeDonusum_Dogrula: hedef detay FATURA degilse IZLEME HIC
--      SORULMAZ. Siparis stok hareketi yapmaz, seri/lot kavrami yoktur; bu
--      guard olmadan izlemeli satirlar "seri/lot secilmeden belge
--      olusturulamaz" ile bloklanirdi.
-- ============================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION dbo.fn_Prog_BelgeDonusum_Rota ()
RETURNS TABLE
AS
RETURN
(
    SELECT DonusumTuru, Aciklama, KaynakTur, HedefTur,
           KaynakBaslikTablo, KaynakDetayTablo, HedefBaslikTablo, HedefDetayTablo,
           KaynakBaglanti, KalanHedefTablo, KalanGrubu,
           GirisDepoKaynak, CikisDepoKaynak, DepoAlani, DovizAlani,
           StokDurumDegis, KdvMuafiyetKopyala, EkipmanSabit, Carpan,
           StokKontrolu, IzlemeAktarim, UretimRecete, BelgeNoPolitikasi, Destek
    FROM (VALUES
    --   DT   Aciklama                             KTur HTur  KBaslik      KDetay          HBaslik      HDetay          KBaglanti     KalanTablo      KalanGrubu    GirisDepo      CikisDepo      DepoAlani    DovizAlani      SDD Kdv Ekp Carp Stok Izl Rec BelgeNo             Destek
        (406, N'Alis siparisi -> alis irsaliyesi',    9,  10, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'RAPORDOVIZ',    1,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1),
        (407, N'Alis siparisi -> alis faturasi',      9,  11, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1),
        (478, N'Alis siparisi -> alis fisi',          9,  12, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1),
        (408, N'Alis irsaliyesi -> alis faturasi',   10,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (427, N'Alis irsaliyesi -> alis fisi',       10,  12, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (409, N'Satis siparisi -> satis irsaliyesi', 19,  14, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',    1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (410, N'Satis siparisi -> satis faturasi',   19,  15, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (473, N'Satis siparisi -> satis fisi',       19,  16, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (429, N'Satis siparisi -> giden konsinye',   19, 119, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'VARSAYILAN7', 'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (411, N'Satis irsaliyesi -> satis faturasi', 14,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (424, N'Satis irsaliyesi -> satis fisi',     14,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (414, N'Siparis -> transfer fisi',           19,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (435, N'Stok talebi -> transfer fisi',      105,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (461, N'Gelen konsinye -> alis faturasi',   109,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GELEN_KON',  'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (468, N'Giden konsinye -> satis irsaliyesi',119,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            0,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (462, N'Giden konsinye -> satis faturasi',  119,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (472, N'Giden konsinye -> satis fisi',      119,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (415, N'Satis siparisi -> uretim (urun)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'RAPORDOVIZ',    1,  0,  1,  1,   0,  0,  1, 'OTOMATIK',         1),
        (420, N'Satis siparisi -> uretim (sarf)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  1, -1,   1,  0,  0, 'OTOMATIK',         1),
        (425, N'Uretim fisi -> satis irsaliyesi',     6,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (426, N'Uretim fisi -> satis faturasi',       6,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        -- K2: kaynak TUR 101 (satinalma talebi) - canli veriyle dogrulandi.
        -- Hedef SIPARIS: trg_Siparis_Aktarim skaler atama yaptigi icin baslik TEK SATIR eklenecek.
        -- DESTEK = 0 (08.08.2026): belge uretimi kanonik yol olan sp_Api_Belge_Kaydet_Json
        --   uzerinden yapiliyor; o SP yalnizca FATBASLIK/FATURA yaziyor. Hedefi SIPARIS olan
        --   bu rota icin SIPARIS tarafinda es deger bir "kaydet" SP'si YOK. Ikiz bir uretim
        --   yazmamak icin rota simdilik kapsam disi; eski akista calismaya devam ediyor.
        --   Sipariş tarafi kanonik kaydet SP'si yazilinca Destek=1 yapilacak.
        (428, N'Satinalma talebi -> alis siparisi', 101,   9, 'SIPARIS',   'SIPARISDETAY', 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  'SIPARISDETAY', 'TALEP_SIP',  'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            0,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1)
    ) AS R(DonusumTuru, Aciklama, KaynakTur, HedefTur,
           KaynakBaslikTablo, KaynakDetayTablo, HedefBaslikTablo, HedefDetayTablo,
           KaynakBaglanti, KalanHedefTablo, KalanGrubu,
           GirisDepoKaynak, CikisDepoKaynak, DepoAlani, DovizAlani,
           StokDurumDegis, KdvMuafiyetKopyala, EkipmanSabit, Carpan,
           StokKontrolu, IzlemeAktarim, UretimRecete, BelgeNoPolitikasi, Destek)
);
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
    -- HEDEF STOK BELGESI DEGILSE IZLEME HIC SORULMAZ.
    --   428 (satinalma talebi -> alis siparisi) gibi rotalarda hedef detay
    --   SIPARISDETAY'dir: siparis stok hareketi yapmaz, seri/lot kavrami
    --   yoktur. Bu guard olmadan asagidaki (b) dali izlemeli satirlarda
    --   "seri/lot secilmeden belge olusturulamaz" deyip donusumu bloklardi.
    DECLARE @HedefDetayTablo NVARCHAR(20) =
        (SELECT HedefDetayTablo FROM dbo.fn_Prog_BelgeDonusum_Rota()
          WHERE DonusumTuru = @DonusumTuru);

    IF @HedefDetayTablo <> 'FATURA'
    BEGIN
        UPDATE #DonusumKaynakSatir SET Durum = N'uygun'
         WHERE ISNULL(Durum, N'') NOT IN (N'atlandi', N'hata');
        RETURN;
    END

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
        --
        --   YALNIZ CIKIS HEDEFLERINDE. Alis/giris belgesinde (siparis -> alis
        --   irsaliyesi/faturasi) lot TEDARIKCIDEN gelir; depodaki mevcut lotu
        --   varsaymak gelen mala baskasinin lot numarasini yazmak demektir.
        --   (08.08.2026: alis irsaliyesi 114108'e depodaki ti0002 otomatik
        --    atanmis, depoya +20 girmisti.) Giriste HER ZAMAN sorulur.
        IF @HedefTur IN (4, 14, 15, 16, 20, 101, 119)
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


CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Kaydet
    @DonusumTuru     INT,
    @KullaniciID     INT,
    @SubeID          INT,
    @Tarih           DATETIME      = NULL,
    @HedefBaslikID   INT           = 0,
    @BelgeNoGiris    NVARCHAR(50)  = NULL,   -- KULLANICI_GIRISI rotalarinda
    @BelgeSeriGiris  NVARCHAR(50)  = NULL,
    @VarsayilanDoviz NVARCHAR(10)  = N'TL',
    @Senaryo         INT           = 1,
    @HedefBaslikOut  INT           OUTPUT,
    @BelgeNoOut      NVARCHAR(50)  OUTPUT,
    @YeniBelgeOut    BIT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Tarih        = ISNULL(@Tarih, GETDATE());
    SET @YeniBelgeOut = CASE WHEN @HedefBaslikID > 0 THEN 0 ELSE 1 END;

    -- ---------- Rota ----------
    DECLARE @HedefTur INT, @HedefBaslikTablo NVARCHAR(20), @GirisKaynak NVARCHAR(20),
            @CikisKaynak NVARCHAR(20), @DovizAlani NVARCHAR(20), @StokDurumDegis INT,
            @KdvMuaf INT, @EkipmanSabit INT, @Carpan INT, @BelgeNoPolitikasi NVARCHAR(20),
            @KaynakBaslikTablo NVARCHAR(20);
    SELECT @HedefTur = HedefTur, @HedefBaslikTablo = HedefBaslikTablo,
           @GirisKaynak = GirisDepoKaynak, @CikisKaynak = CikisDepoKaynak,
           @DovizAlani = DovizAlani, @StokDurumDegis = StokDurumDegis,
           @KdvMuaf = KdvMuafiyetKopyala, @EkipmanSabit = EkipmanSabit, @Carpan = Carpan,
           @BelgeNoPolitikasi = BelgeNoPolitikasi, @KaynakBaslikTablo = KaynakBaslikTablo
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @HedefTur IS NULL
        THROW 51200, N'Bilinmeyen donusum turu.', 1;
    -- Hedef FATBASLIK ya da SIPARIS olabilir; ikisinin de kanonik kaydet SP'si
    --   var (asagida tabloya gore secilir). Baska bir hedef tablosu yok.
    IF @HedefBaslikTablo NOT IN ('FATBASLIK', 'SIPARIS')
        THROW 51200, N'Bu donusumun hedef tablosu desteklenmiyor.', 1;

    -- ---------- Kaynak baslik (dogrulanmis: hepsi uyumlu) ----------
    DECLARE @BaslikId INT, @RehberId INT, @sGiris INT, @sCikis INT,
            @KdvDurum NVARCHAR(20), @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10),
            @Kur NVARCHAR(10), @DovizKur MONEY, @KaynakNo NVARCHAR(50);
    SELECT TOP 1 @BaslikId = BaslikId, @RehberId = RehberId, @sGiris = GirisDepo,
                 @sCikis = CikisDepo, @KdvDurum = KdvDurum, @RaporDoviz = RaporDoviz,
                 @FaturaDovizi = FaturaDovizi, @Kur = Kur, @DovizKur = DovizKur,
                 @KaynakNo = BelgeNo
    FROM #DonusumKaynakBaslik ORDER BY BaslikId;

    IF @BaslikId IS NULL THROW 51001, N'Kaynak baslik bilgisi yok.', 1;

    -- ---------- Depo ----------
    DECLARE @GirisDepo INT = CASE @GirisKaynak
                                  WHEN 'GIRISDEPO'   THEN @sGiris
                                  WHEN 'CIKISDEPO'   THEN @sCikis
                                  WHEN 'VARSAYILAN7' THEN (SELECT TOP 1 ID FROM DEPOLAR
                                                            WHERE DURUM = 1 AND VARSAYILAN = 7
                                                              AND SUBEID = @SubeID)
                                  ELSE NULL END;
    DECLARE @CikisDepo INT = CASE @CikisKaynak
                                  WHEN 'GIRISDEPO' THEN @sGiris
                                  WHEN 'CIKISDEPO' THEN @sCikis
                                  ELSE NULL END;

    -- ---------- Doviz ----------
    --   RAPORDOVIZ kaynaktan aynen; FATURADOVIZI rota politikasina gore.
    DECLARE @FatDoviz NVARCHAR(10) =
        CASE WHEN @DovizAlani IS NULL           THEN @VarsayilanDoviz
             WHEN @DovizAlani = 'RAPORDOVIZ'    THEN @RaporDoviz
             WHEN @DovizAlani = 'FATURADOVIZI'  THEN @FaturaDovizi
             ELSE @VarsayilanDoviz END;
    SET @FatDoviz = ISNULL(NULLIF(@FatDoviz, N''), @VarsayilanDoviz);

    -- ---------- Belge numarasi ----------
    --   OTOMATIK rotalarda numara TRANSACTION ICINDE tahsis edilir; uygulamada
    --   uretilip gonderilmez (es zamanli iki donusumde numara cakismasini
    --   bitiren degisiklik - degerlendirme raporu madde 4).
    DECLARE @KocanNo INT = 0, @BelgeNo NVARCHAR(50) = @BelgeNoGiris,
            @BelgeSeri NVARCHAR(50) = @BelgeSeriGiris;

    IF @YeniBelgeOut = 1 AND @BelgeNoPolitikasi = 'OTOMATIK'
    BEGIN
        SET @KocanNo = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                WHERE TUR = @HedefTur AND SUBEID = -1
                                  AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
        DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
        INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @HedefTur, @SubeID = -1,
                                            @Kocanno = @KocanNo, @BTarihi = @Tarih;
        SELECT TOP 1 @BelgeNo = BelgeNo, @BelgeSeri = BelgeSeri FROM @BN;
    END

    -- ---------- Kaydet JSON ----------
    DECLARE @Baslik NVARCHAR(MAX);
    IF @YeniBelgeOut = 1
        SET @Baslik = (SELECT @HedefTur AS Tur, 1 AS Tipi, @RehberId AS RehberId,
                              @Tarih AS Tarih, @Tarih AS FaturaTarih,
                              @BelgeNo AS FaturaNo, @BelgeSeri AS FaturaSeri,
                              @KocanNo AS KocanNo, @Senaryo AS Senaryo,
                              0 AS EFaturaDurum, 0 AS EFaturaSonuc,      -- K3 / K4
                              @GirisDepo AS GirisDepo, @CikisDepo AS CikisDepo,
                              @KdvDurum AS KdvDurum, @Kur AS Kur,
                              @RaporDoviz AS RaporDoviz, @FatDoviz AS FaturaDovizi,
                              @DovizKur AS DovizKur, @SubeID AS SubeId,
                              LEFT(ISNULL(@KaynakNo, N'') + N' nolu belgeden', 200) AS Aciklama,
                              K.AKTIVITEID AS AktiviteId, K.REHBERILETID AS RehberIletId,
                              K.SERVISID AS ServisId, K.DETAYBOLUMU AS DetayBolumu,
                              K.SATICIKODU AS SaticiKodu, K.PROJEID AS ProjeId,
                              K.VADE AS Vade, K.FIYAT_LISTESI AS FiyatListesi,
                              K.BASLIK AS Unvan, K.ADRES AS Adres, K.ILCE AS Ilce,
                              K.IL AS Il, K.VD AS Vd, K.VNO AS Vno, K.OZELKOD AS OzelKod
                       FROM (SELECT AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
                                    PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO, OZELKOD
                             FROM SIPARIS WHERE ID = @BaslikId AND @KaynakBaslikTablo = 'SIPARIS'
                             UNION ALL
                             SELECT AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
                                    PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO, OZELKOD
                             FROM FATBASLIK WHERE ID = @BaslikId AND @KaynakBaslikTablo = 'FATBASLIK') K
                       FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);
    ELSE
        -- Mevcut belgeye ekleme: baslikta YALNIZ ID gonderilir; hedef basligin
        --   hicbir alani degistirilmez (Kaydet gonderilmeyen alana dokunmaz).
        SET @Baslik = (SELECT @HedefBaslikID AS ID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    DECLARE @Satirlar NVARCHAR(MAX) =
        (SELECT S.Sira                                   AS Sira,
                S.UrunId                                 AS UrunId,
                S.SatirTur                               AS Tur,
                S.IstenenAdet   * @Carpan                AS Adet,
                S.IstenenMiktar * @Carpan                AS Miktar,
                S.Birim                                  AS Birim,
                S.BirimFiyat                             AS BirimFiyat,
                S.Kdv                                    AS Kdv,
                S.Iskonto                                AS Iskonto,
                S.Iskonto2                               AS Iskonto2,
                S.Kur                                    AS Kur,
                S.DovizKuru                              AS DovizKuru,
                S.DovizBirimFiyat                        AS DovizBirimFiyat,
                S.DovizKurDegeri                         AS DovizKurDegeri,
                S.Aciklama                               AS Aciklama,
                S.ProjeId                                AS ProjeId,
                S.MasrafId                               AS MasrafId,
                S.OzelKod                                AS OzelKod,
                S.OzelKod2                               AS OzelKod2,
                S.Izleme                                 AS Izleme,
                -- ---- donusum bagi ----
                @DonusumTuru                             AS Yeri,
                S.SatirId                                AS YerId,
                -- ---- rota politikasi ----
                @StokDurumDegis                          AS StokDurumDegis,
                CASE WHEN @EkipmanSabit = 1 THEN 1 ELSE S.EkipmanId END AS EkipmanId,
                CASE WHEN @KdvMuaf = 1 THEN S.KdvMuafiyeti ELSE NULL END AS KdvMuafiyeti,
                S.PozNo                                  AS PozNo,
                S.Mf                                     AS Mf,
                S.MuhKodu                                AS MuhKodu,
                S.Kasa                                   AS Kasa,
                S.OtvYuzde                               AS OtvYuzde,
                S.OtvMiktar                              AS OtvMiktar,
                S.IzlemeKodu                             AS IzlemeKodu,
                S.Vade                                   AS Vade,
                S.KampanyaId                             AS KampanyaId
         FROM #DonusumKaynakSatir S
         WHERE ISNULL(S.Durum, N'') = N'uygun'
         ORDER BY S.Sira
         FOR JSON PATH);

    IF @Satirlar IS NULL THROW 51200, N'Yazilacak uygun satir yok.', 1;

    DECLARE @Json NVARCHAR(MAX) =
        -- SatirModu "delta": gonderilen satirlar EKLENIR, gonderilmeyenlere dokunulmaz.
        --   ("tam" mevcut belgenin gonderilmeyen satirlarini silerdi - mevcut belgeye
        --    ekleme yaparken bu YANLIS olurdu.)
        N'{"Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar + N',"SatirModu":"delta"}';

    -- ---------- Kanonik belge uretimi ----------
    DECLARE @YeniId INT;
    -- @SonucDondur = 0: Kaydet kendi sonuc setini ISTEMCIYE GONDERMESIN. Aksi
    --   halde uygulama Q.Open ile ILK result set'i (Kaydet'inkini) okur ve ana
    --   SP'nin sonucunu goremez - donusumde bos uyariya sebep olmustu.
    --   Hedef tabloya gore kanonik kaydet SP'si secilir. JSON SOZLESMESI AYNI;
    --   siparis SP'si "Fatura..." adlarini da tanir, boylece burada ikiz JSON
    --   uretmek gerekmiyor. (428 -> SIPARIS)
    IF @HedefBaslikTablo = 'SIPARIS'
        EXEC dbo.sp_Api_Belge_Siparis_Kaydet_Json @Kosullar = @Json,
             @BelgeIdOut = @YeniId OUTPUT, @SonucDondur = 0;
    ELSE
        EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @Json, @BelgeIdOut = @YeniId OUTPUT,
             @SonucDondur = 0;

    SET @HedefBaslikOut = ISNULL(NULLIF(@YeniId, 0), @HedefBaslikID);
    IF ISNULL(@HedefBaslikOut, 0) = 0
        THROW 51200, N'Hedef belge olusturulamadi.', 1;

    SELECT @BelgeNoOut = FATURANO FROM FATBASLIK WHERE ID = @HedefBaslikOut;

    -- ---------- Satir eslesmesi ----------
    --   Hedef satirlar YERI/YERID ile kaynaga bagli; eslesme bu bagdan okunur.
    --   (Kaydet'in sonuc JSON'u da Sira->ID veriyor ama INSERT...EXEC ic ice
    --    gecmedigi icin yakalanamiyor.)
    INSERT #DonusumSatirEsleme (Sira, KaynakBaslikId, KaynakSatirId, HedefSatirId,
                                DonusenAdet, KalanAdet)
    SELECT S.Sira, S.BaslikId, S.SatirId, F.ID,
           S.IstenenAdet, S.KalanAdet - S.IstenenAdet
    FROM #DonusumKaynakSatir S
         INNER JOIN FATURA F ON F.FATBASID = @HedefBaslikOut
                            AND F.YERI  = @DonusumTuru
                            AND F.YERID = S.SatirId
    WHERE ISNULL(S.Durum, N'') = N'uygun';
END
GO

GRANT EXECUTE ON dbo.sp_Prog_BelgeDonusum_Kaydet TO gentegre_api;
GO
