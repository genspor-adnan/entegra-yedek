-- ============================================================
-- GenDepoUpdate108.sql
-- COLLATION CAKISMASI - gecici tablo ile STOKSERILOT arasinda
--
-- HATA (08.08.2026): alis siparisi -> irsaliye donusumunde lot 'si001'
--   girilip kaydedilince
--     "Cannot resolve the collation conflict between 'Turkish_CI_AS' and
--      'SQL_Latin1_General_CP1254_CI_AS' in the equal to operation."
--
-- NEDEN: GECICI TABLO kolonlari TEMPDB'nin collation'ini alir (bu sunucuda
--   Turkish_CI_AS); STOKSERILOT.SERINO/LOTNO ise veritabanininkini
--   (SQL_Latin1_General_CP1254_CI_AS). GenDepoUpdate107 ile #DonusumIzlemeSecim'e
--   eklenen SeriNo/LotNo kolonlari STOKSERILOT ile karsilastirildigi anda
--   catisma cikiyor. Ayni tuzak table variable'lar (@Sec) icin de gecerli.
--
-- COZUM: metin kolonlari COLLATE DATABASE_DEFAULT ile tanimlanir ve
--   karsilastirmalarda da acikca belirtilir. (Veritabani collation'ina
--   dokunulmaz - GENDEPO tarafinda filtreli index yuzunden ALTER DATABASE
--   COLLATE zaten mumkun degil.)
-- ============================================================

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

    -- ---- YENI SERI/LOT KARTLARI (giris donusumleri) ----
    --   Kart BURADA acilir, cagiranin transaction'i icinde: donusum geri
    --   sararsa kart da geri saril. (Parse asamasinda acilsaydi sadeceKontrol
    --   cagrisi bile bos kart birakirdi - olculdu.)
    UPDATE I SET I.SerilotId = SSL.ID
      FROM #DonusumIzlemeSecim I
           INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = I.UrunId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = ISNULL(I.SeriNo, N'') COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'') COLLATE DATABASE_DEFAULT
     WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0;

    INSERT INTO dbo.STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
    SELECT DISTINCT I.UrunId, ISNULL(I.SeriNo, N''), ISNULL(I.LotNo, N''),
           ISNULL(I.Urt, '1990-01-01'), ISNULL(I.Skt, '1990-01-01')
    FROM #DonusumIzlemeSecim I
    WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0
      AND ISNULL(I.UrunId, 0) > 0
      AND (ISNULL(I.SeriNo, N'') <> N'' OR ISNULL(I.LotNo, N'') <> N'');

    UPDATE I SET I.SerilotId = SSL.ID
      FROM #DonusumIzlemeSecim I
           INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = I.UrunId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = ISNULL(I.SeriNo, N'') COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = ISNULL(I.LotNo,  N'') COLLATE DATABASE_DEFAULT
     WHERE ISNULL(I.SerilotId, 0) = 0 AND ISNULL(I.StokIzlemeId, 0) = 0;

    IF EXISTS (SELECT 1 FROM #DonusumIzlemeSecim
               WHERE ISNULL(SerilotId, 0) = 0 AND ISNULL(StokIzlemeId, 0) = 0)
        THROW 51200, N'Seri/lot karti olusturulamadi (seri no ve lot no bos olamaz).', 1;

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
    -- SeriNo/LotNo/Skt/Urt: GIRIS donusumlerinde lot HENUZ KART DEGILDIR
    --   (tedarikciden gelir). Kart, transaction icinde IzlemeAktar'da acilir.
    -- COLLATE DATABASE_DEFAULT SART: gecici tablo kolonlari TEMPDB'nin
    --   collation'ini alir (burada Turkish_CI_AS), STOKSERILOT ise
    --   veritabanininkini (SQL_Latin1_General_CP1254_CI_AS). Aciklamasiz
    --   birakilirsa lot eslestirmesi "Cannot resolve the collation conflict"
    --   ile patlar (08.08.2026, alis donusumunde lot 'si001' girilirken).
    CREATE TABLE #DonusumIzlemeSecim (
        SatirId INT, StokIzlemeId INT, SerilotId INT NULL, UrunId INT NULL,
        SeriNo NVARCHAR(64) COLLATE DATABASE_DEFAULT NULL,
        LotNo  NVARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        Skt DATETIME NULL, Urt DATETIME NULL,
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
        -- Secim satirlari. GIRIS donusumlerinde (siparis -> alis irsaliyesi/
        --   faturasi) lot TEDARIKCIDEN gelir ve HENUZ KART OLARAK YOKTUR;
        --   ekran serilotId yerine seriNo/lotNo/skt/urt gonderir. Kart burada,
        --   donusumun KENDI TRANSACTION'INDA acilir.
        DECLARE @Sec TABLE (SatirId INT, StokIzlemeId INT, SerilotId INT NULL,
                            UrunId INT,
                            SeriNo NVARCHAR(64) COLLATE DATABASE_DEFAULT,
                            LotNo  NVARCHAR(50) COLLATE DATABASE_DEFAULT,
                            Skt DATETIME NULL, Urt DATETIME NULL, Adet DECIMAL(18,6));
        INSERT @Sec (SatirId, StokIzlemeId, SerilotId, UrunId, SeriNo, LotNo, Skt, Urt, Adet)
        SELECT I.SatirId, ISNULL(J.StokIzlemeId, 0), J.SerilotId,
               (SELECT TOP 1 S.UrunId FROM #DonusumKaynakSatir S WHERE S.SatirId = I.SatirId),
               ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''), J.Skt, J.Urt, J.Adet
        FROM @Ist I CROSS APPLY OPENJSON(I.Izlemeler)
             WITH (StokIzlemeId INT '$.stokIzlemeId', SerilotId INT '$.serilotId',
                   SeriNo NVARCHAR(64) '$.seriNo', LotNo NVARCHAR(50) '$.lotNo',
                   Skt DATETIME '$.skt', Urt DATETIME '$.urt',
                   Adet DECIMAL(18,6) '$.adet') J
        WHERE I.Izlemeler IS NOT NULL AND ISNULL(J.Adet, 0) > 0;

        -- Kart varsa bagla
        UPDATE S SET S.SerilotId = SSL.ID
          FROM @Sec S
               INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = S.UrunId
                      AND ISNULL(SSL.SERINO, N'') = S.SeriNo
                      AND ISNULL(SSL.LOTNO,  N'') = S.LotNo
         WHERE ISNULL(S.SerilotId, 0) = 0 AND ISNULL(S.StokIzlemeId, 0) = 0
           AND (S.SeriNo <> N'' OR S.LotNo <> N'');

        -- Kart YOKSA BURADA ACILMAZ: bu blok BEGIN TRAN'dan ONCE calisiyor.
        --   Burada acilan kart, donusum geri sarilsa (ya da yalnizca kontrol
        --   yapilsa) bile veritabaninda kalirdi - olculdu: sadeceKontrol
        --   cagrisi iki bos lot karti birakti. Kart, islemin kendi
        --   transaction'i icinde sp_Prog_BelgeDonusum_IzlemeAktar'da acilir.
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, SerilotId, UrunId,
                                    SeriNo, LotNo, Skt, Urt, Adet)
        SELECT S.SatirId, S.StokIzlemeId, S.SerilotId, S.UrunId,
               S.SeriNo, S.LotNo, S.Skt, S.Urt, S.Adet
        FROM @Sec S
        WHERE ISNULL(S.StokIzlemeId, 0) > 0
           OR ISNULL(S.SerilotId, 0) > 0
           OR S.SeriNo <> N'' OR S.LotNo <> N'';

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


SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Izleme_Yaz_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tur      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.tur')      AS INT);
    DECLARE @BaslikId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.baslikId') AS INT);
    DECLARE @SatirId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.satirId')  AS INT);
    DECLARE @IslemTip INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.belge.islemTip') AS INT), 0);
    DECLARE @StokId   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.stokId')   AS INT);
    DECLARE @IzlemTur INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.izlemTur') AS INT), 0);
    DECLARE @GirDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.girDepo') AS INT), 0);
    DECLARE @CikDepo  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.cikDepo') AS INT), 0);
    DECLARE @StokHar  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.stokHareketi') AS BIT), 1);
    DECLARE @KaynakSatir INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kaynakSatirId') AS INT), 0);
    DECLARE @OncekiSil BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.oncekiSil') AS BIT), 1);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kullaniciId') AS INT), 0);

    IF @Tur      IS NULL                 THROW 51001, N'belge.tur zorunlu.', 1;
    IF @BaslikId IS NULL OR @BaslikId<=0 THROW 51001, N'belge.baslikId zorunlu.', 1;
    IF @SatirId  IS NULL OR @SatirId <=0 THROW 51001, N'belge.satirId zorunlu.', 1;
    IF @StokId   IS NULL OR @StokId  <=0 THROW 51001, N'stokId zorunlu.', 1;

    -- ---------- Girdi satirlari ----------
    DECLARE @S TABLE (Sira INT IDENTITY, SerilotId INT NULL, IzlemId INT NULL,
                      SeriNo NVARCHAR(64) COLLATE DATABASE_DEFAULT,
                      LotNo  NVARCHAR(50) COLLATE DATABASE_DEFAULT,
                      Skt DATETIME NULL, Urt DATETIME NULL, Adet DECIMAL(18,6));
    INSERT @S (SerilotId, IzlemId, SeriNo, LotNo, Skt, Urt, Adet)
    SELECT J.SerilotId, ISNULL(J.IzlemId, 0), ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''),
           J.Skt, J.Urt, J.Adet
    FROM OPENJSON(@Kosullar, '$.satirlar')
         WITH (SerilotId INT '$.serilotId', IzlemId INT '$.izlemId',
               SeriNo NVARCHAR(64) '$.seriNo', LotNo NVARCHAR(50) '$.lotNo',
               Skt DATETIME '$.skt', Urt DATETIME '$.urt',
               Adet DECIMAL(18,6) '$.adet') J
    WHERE ISNULL(J.Adet, 0) > 0;

    -- ---------- Depo korumasi ----------
    --   Hareket yapilacaksa gecerli depo SART. Yon asagidaki ile ayni kural.
    DECLARE @Cikis BIT = CASE WHEN @Tur IN (4, 14, 15, 16, 20, 101, 119) THEN 1 ELSE 0 END;
    IF @StokHar = 1 AND EXISTS (SELECT 1 FROM @S)
       AND ((@Cikis = 1 AND @CikDepo <= 0) OR (@Cikis = 0 AND @GirDepo <= 0))
        THROW 51001, N'Bu belgede depo secilmedigi icin seri/lot hareketi kaydedilemez. Once belgenin giris/cikis deposunu secin.', 1;

    -- ---------- Onceki kayitlar ----------
    IF @OncekiSil = 1
    BEGIN
        DECLARE @Eski TABLE (Id INT PRIMARY KEY);
        INSERT @Eski (Id)
        SELECT ID FROM dbo.STOKIZLEME
         WHERE BELGETUR = @Tur AND STOKID = @StokId
           AND BASLIKID = @BaslikId AND SATIRID = @SatirId;

        -- SIRA ONEMLI: STOKIZLEME ONCE silinir.
        --   TG_StokIzlemeDurumSil (STOKIZLEME FOR DELETE) bakiyeyi geri verirken
        --   deleted'i STOKIZLEMEDEPO ile JOIN'ler. Depo satirlarini once
        --   silersek trigger hicbir sey bulamaz ve bakiye eksik kalir.
        --   Olculdu (08.08.2026): ayni satiri iki kez yazinca bakiye
        --   233 -> 223 oluyordu, dogrusu 228.
        DELETE FROM dbo.STOKIZLEME WHERE ID IN (SELECT Id FROM @Eski);
        DELETE FROM dbo.STOKIZLEMEDEPO WHERE IZLEMID IN (SELECT Id FROM @Eski);
    END

    IF NOT EXISTS (SELECT 1 FROM @S)
    BEGIN
        SELECT (SELECT 1 AS Sonuc, 0 AS Yazilan, 0 AS ToplamAdet
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Eksik seri/lot kartlari ----------
    --   serilotId gelmemis satirlar once (STOKID, SERINO, LOTNO) ile aranir,
    --   yoksa STOKSERILOT'a eklenir. Tarih yoksa 1990-01-01 (eski sentinel).
    UPDATE S
       SET S.SerilotId = SSL.ID
      FROM @S S
           INNER JOIN dbo.STOKSERILOT SSL
                   ON SSL.STOKID = @StokId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = S.SeriNo COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = S.LotNo COLLATE DATABASE_DEFAULT
     WHERE ISNULL(S.SerilotId, 0) = 0;

    DECLARE @Yeni TABLE (Sira INT, SerilotId INT);
    INSERT INTO dbo.STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
    OUTPUT INSERTED.ID INTO @Yeni (SerilotId)
    SELECT @StokId, S.SeriNo, S.LotNo,
           ISNULL(S.Urt, '1990-01-01'), ISNULL(S.Skt, '1990-01-01')
    FROM @S S WHERE ISNULL(S.SerilotId, 0) = 0;

    -- OUTPUT ile Sira eslestirilemez (INSERT...SELECT'te kaynak kolon
    --   OUTPUT'a alinamaz); yeni eklenenler tekrar arama ile baglanir.
    UPDATE S
       SET S.SerilotId = SSL.ID
      FROM @S S
           INNER JOIN dbo.STOKSERILOT SSL
                   ON SSL.STOKID = @StokId
                  AND ISNULL(SSL.SERINO, N'') COLLATE DATABASE_DEFAULT = S.SeriNo COLLATE DATABASE_DEFAULT
                  AND ISNULL(SSL.LOTNO,  N'') COLLATE DATABASE_DEFAULT = S.LotNo COLLATE DATABASE_DEFAULT
     WHERE ISNULL(S.SerilotId, 0) = 0;

    IF EXISTS (SELECT 1 FROM @S WHERE ISNULL(SerilotId, 0) = 0)
        THROW 51200, N'Seri/lot karti olusturulamadi (seri no ve lot no bos olamaz).', 1;

    -- ---------- Yazma ----------
    DECLARE @Sira INT, @Serilot INT, @IzlemId INT, @Adet DECIMAL(18,6),
            @YeniId INT, @Yazilan INT = 0, @Toplam DECIMAL(18,6) = 0,
            @Hareket DECIMAL(18,6);

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, SerilotId, IzlemId, Adet FROM @S ORDER BY Sira;
    OPEN c; FETCH NEXT FROM c INTO @Sira, @Serilot, @IzlemId, @Adet;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                    ADET, KALAN, YER, YERID, DONUSID, SERILOTID, EKLEYEN)
        VALUES (@StokId, @Tur, @BaslikId, @SatirId, @IzlemTur,
                @Adet, @Adet, 0, 0,
                CASE WHEN @KaynakSatir > 0 THEN ISNULL(@IzlemId, 0) ELSE 0 END,
                @Serilot, @KulId);
        SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);

        SET @Hareket = CASE WHEN @StokHar = 1 THEN @Adet ELSE 0 END;

        IF @Cikis = 1
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @CikDepo, -1.0 * @Hareket);
        ELSE
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @GirDepo, @Hareket);

        -- Transfer ve giden konsinye: cikisin karsiligi giris deposuna
        IF @Tur IN (20, 119)
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @GirDepo, @Hareket);
        -- Gelen konsinye IADE (islemTip 2): konsinyeden cikis, ana depoya giris
        ELSE IF @Tur = 109 AND @IslemTip = 2
            INSERT INTO dbo.STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET)
            VALUES (@YeniId, @CikDepo, -1.0 * @Hareket);

        SET @Yazilan = @Yazilan + 1;
        SET @Toplam = @Toplam + @Adet;
        FETCH NEXT FROM c INTO @Sira, @Serilot, @IzlemId, @Adet;
    END
    CLOSE c; DEALLOCATE c;

    SELECT (SELECT 1 AS Sonuc, @Yazilan AS Yazilan, @Toplam AS ToplamAdet
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Izleme_Yaz_Json TO gentegre_api;
GO
