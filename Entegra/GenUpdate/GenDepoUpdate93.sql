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

    CREATE TABLE #DonusumIzlemeSecim (
        SatirId INT, StokIzlemeId INT, Adet DECIMAL(18,6), YeniIzlemeId INT NULL);

    CREATE TABLE #DonusumSatirEsleme (
        Sira INT, KaynakBaslikId INT, KaynakSatirId INT, HedefSatirId INT,
        DonusenAdet DECIMAL(18,6), KalanAdet DECIMAL(18,6));

    CREATE TABLE #DonusumUyari (
        Sira INT IDENTITY, Kod NVARCHAR(30), KaynakSatirId INT NULL, Mesaj NVARCHAR(400));

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
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, Adet)
        SELECT I.SatirId, J.StokIzlemeId, J.Adet
        FROM @Ist I CROSS APPLY OPENJSON(I.Izlemeler)
             WITH (StokIzlemeId INT '$.stokIzlemeId', Adet DECIMAL(18,6) '$.adet') J
        WHERE I.Izlemeler IS NOT NULL;

        -- ---------- 4) Sadece kontrol ----------
        DECLARE @HataSayisi INT = 0;
        IF @SadeceKontrol = 1
        BEGIN
            EXEC dbo.sp_Prog_BelgeDonusum_Dogrula @DonusumTuru = @DonusumTuru,
                 @HedefBaslikID = @HedefBaslikID, @SubeID = @SubeID, @Tarih = @Tarih,
                 @StokOnayi = @StokOnayi, @SadeceKontrol = 1, @HataSayisi = @HataSayisi OUTPUT;
            SET @Basarili = 1;
            SET @Mesaj = N'Kontrol tamamlandi.';
            GOTO Bitir;
        END

        -- ---------- 5) Islem ----------
        BEGIN TRAN;

        EXEC dbo.sp_Prog_BelgeDonusum_Dogrula @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefBaslikID, @SubeID = @SubeID, @Tarih = @Tarih,
             @StokOnayi = @StokOnayi, @SadeceKontrol = 0, @HataSayisi = @HataSayisi OUTPUT;

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
    DECLARE @UyariJson NVARCHAR(MAX) =
        ISNULL((SELECT Kod AS kod, KaynakSatirId AS kaynakSatirId, Mesaj AS mesaj
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
