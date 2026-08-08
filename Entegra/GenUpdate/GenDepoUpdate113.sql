-- ============================================================
-- GenDepoUpdate113.sql
-- sp_Api_Belge_Siparis_Kaydet_Json - SIPARIS icin kanonik kaydet
--
-- sp_Api_Belge_Kaydet_Json FATBASLIK/FATURA yaziyor. SIPARIS tarafinda es
--   deger bir nesne yoktu; bu yuzden 428 (satinalma talebi -> alis siparisi)
--   rotasi Destek=0 ile eski Pascal akisinda kalmisti.
--
-- AYNI SOZLESME: {"Baslik":{...},"Satirlar":[...],"SatirModu":"delta"|"tam"}
--   Boylece donusum zinciri (sp_Prog_BelgeDonusum_Kaydet) JSON'u degistirmeden,
--   yalnizca hedef tabloya gore SP secerek calisabiliyor.
--
-- ALAN ADLARI: donusum zinciri belge alanlarini "Fatura..." adlariyla
--   uretiyor. Ikiz JSON yazmamak icin bu SP HER IKI adi da kabul eder:
--     FaturaTarih | SiparisTarih   -> SIPARISTARIH
--     FaturaNo    | SiparisNo      -> SIPARISNO
--     FaturaSeri  | SiparisSeri    -> SIPARISSERI
--     FaturaDovizi| DovizCinsi     -> DOVIZ_CINSI
--   SIPARIS'te karsiligi OLMAYAN alanlar (Senaryo, EFaturaDurum, EFaturaSonuc)
--   sessizce yok sayilir - e-Belge sureci siparise ait degildir.
--
-- SATIR ALANLARI: SIPARISDETAY'da STOKDURUMDEGIS ve KDVMUAFIYETI KOLONU YOK
--   (siparis stok hareketi yapmaz, e-Belge muafiyeti fatura kavramidir);
--   gonderilseler de yazilmazlar.
--
-- TOPLAMLAR: SP_PRG_Siparis_DipToplami ile hesaplanir (uygulamanin kullandigi
--   ayni formul). TUR kodlari: 4 = Ara Toplam (matrah), 15 = KDV, 20 = Genel.
--
-- @SonucDondur = 0: ic cagrilarda sonuc kumesi ISTEMCIYE SIZMASIN
--   (cagiran Q.Open ile ILK result set'i okur; donusumde bos uyariya sebep
--    olmustu - ayni tuzak).
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Siparis_Kaydet_Json
    @Kosullar     NVARCHAR(MAX),
    @BelgeIdOut   INT = NULL OUTPUT,
    @SonucDondur  BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BelgeId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ID') AS INT);
    DECLARE @Yeni     BIT = CASE WHEN ISNULL(@BelgeId, 0) > 0 THEN 0 ELSE 1 END;
    DECLARE @SatirModu NVARCHAR(10) =
        LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));

    IF @SatirModu NOT IN (N'delta', N'tam')
        THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    -- ---------- Baslik alanlari ----------
    DECLARE @Tur      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tur')      AS INT);
    DECLARE @Tipi     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tipi')     AS INT);
    DECLARE @RehberId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberId') AS INT);
    DECLARE @Tarih    DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tarih') AS DATETIME);
    DECLARE @STarih   DATETIME = COALESCE(
        TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SiparisTarih') AS DATETIME),
        TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FaturaTarih')  AS DATETIME), @Tarih);
    DECLARE @BelgeNo  NVARCHAR(50) = COALESCE(
        JSON_VALUE(@Kosullar, '$.Baslik.SiparisNo'), JSON_VALUE(@Kosullar, '$.Baslik.FaturaNo'));
    DECLARE @BelgeSeri NVARCHAR(50) = COALESCE(
        JSON_VALUE(@Kosullar, '$.Baslik.SiparisSeri'), JSON_VALUE(@Kosullar, '$.Baslik.FaturaSeri'));
    DECLARE @KocanNo  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.KocanNo') AS INT);
    DECLARE @GirisDepo INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.GirisDepo') AS INT);
    DECLARE @CikisDepo INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.CikisDepo') AS INT);
    DECLARE @KdvDurum NVARCHAR(20) = JSON_VALUE(@Kosullar, '$.Baslik.KdvDurum');
    DECLARE @Kur      NVARCHAR(10) = JSON_VALUE(@Kosullar, '$.Baslik.Kur');
    DECLARE @RaporDoviz NVARCHAR(10) = JSON_VALUE(@Kosullar, '$.Baslik.RaporDoviz');
    DECLARE @DovizCinsi NVARCHAR(10) = COALESCE(
        JSON_VALUE(@Kosullar, '$.Baslik.DovizCinsi'), JSON_VALUE(@Kosullar, '$.Baslik.FaturaDovizi'));
    DECLARE @DovizKur MONEY = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.DovizKur') AS MONEY);
    DECLARE @SubeId   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SubeId') AS INT);
    DECLARE @Aciklama NVARCHAR(255) = JSON_VALUE(@Kosullar, '$.Baslik.Aciklama');
    DECLARE @AktiviteId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.AktiviteId') AS INT);
    DECLARE @RehberIletId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberIletId') AS INT);
    DECLARE @ServisId    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ServisId') AS INT);
    DECLARE @DetayBolumu INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.DetayBolumu') AS INT);
    DECLARE @SaticiKodu  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SaticiKodu') AS INT);
    DECLARE @ProjeId     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ProjeId') AS INT);
    DECLARE @Vade        INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Vade') AS INT);
    DECLARE @FiyatListesi INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FiyatListesi') AS INT);
    DECLARE @Unvan  NVARCHAR(255) = JSON_VALUE(@Kosullar, '$.Baslik.Unvan');
    DECLARE @Adres  NVARCHAR(255) = JSON_VALUE(@Kosullar, '$.Baslik.Adres');
    DECLARE @Ilce   NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Ilce');
    DECLARE @Il     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Il');
    DECLARE @Vd     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Vd');
    DECLARE @Vno    NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Vno');
    DECLARE @OzelKod NVARCHAR(50) = JSON_VALUE(@Kosullar, '$.Baslik.OzelKod');
    DECLARE @Durum  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Durum') AS INT);
    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @Yeni = 1 AND (@Tur IS NULL OR ISNULL(@RehberId, 0) = 0)
        THROW 51001, N'Yeni siparis icin Baslik.Tur ve Baslik.RehberId zorunlu.', 1;
    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM SIPARIS WHERE ID = @BelgeId)
        THROW 51002, N'Siparis bulunamadi.', 1;

    -- ---------- Satirlar ----------
    DECLARE @S TABLE (
        Sira INT PRIMARY KEY, SatirId INT, Sil BIT, UrunId INT, Tur INT,
        Adet DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
        BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6), Kdv INT,
        Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
        Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        OzelKod NVARCHAR(50) COLLATE DATABASE_DEFAULT,
        OzelKod2 NVARCHAR(50) COLLATE DATABASE_DEFAULT,
        Izleme INT, Yeri INT, YerId INT, PozNo INT, EkipmanId INT,
        Mf DECIMAL(18,6), MuhKodu NVARCHAR(50) COLLATE DATABASE_DEFAULT, Kasa INT,
        OtvYuzde FLOAT, OtvMiktar DECIMAL(18,6),
        IzlemeKodu NVARCHAR(50) COLLATE DATABASE_DEFAULT, Vade INT, KampanyaId INT,
        TeslimTarihi DATETIME, YeniId INT NULL);

    INSERT @S (Sira, SatirId, Sil, UrunId, Tur, Adet, Miktar, Birim, BirimFiyat, Tutar,
               Kdv, Iskonto, Iskonto2, Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri,
               DovizTutari, Aciklama, ProjeId, MasrafId, OzelKod, OzelKod2, Izleme,
               Yeri, YerId, PozNo, EkipmanId, Mf, MuhKodu, Kasa, OtvYuzde, OtvMiktar,
               IzlemeKodu, Vade, KampanyaId, TeslimTarihi)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT 1))), J.SatirId,
           ISNULL(J.Sil, 0), J.UrunId, ISNULL(J.Tur, 1), J.Adet,
           ISNULL(J.Miktar, J.Adet), ISNULL(J.Birim, 0), ISNULL(J.BirimFiyat, 0), J.Tutar,
           ISNULL(J.Kdv, 0), ISNULL(J.Iskonto, 0), ISNULL(J.Iskonto2, 0),
           J.Kur, J.DovizKuru, ISNULL(J.DovizBirimFiyat, 0), ISNULL(J.DovizKurDegeri, 1),
           J.DovizTutari, J.Aciklama, J.ProjeId, J.MasrafId, J.OzelKod, J.OzelKod2,
           ISNULL(J.Izleme, 0), J.Yeri, J.YerId, J.PozNo, J.EkipmanId, J.Mf, J.MuhKodu,
           J.Kasa, J.OtvYuzde, J.OtvMiktar, J.IzlemeKodu, J.Vade, J.KampanyaId,
           J.TeslimTarihi
    FROM OPENJSON(@Kosullar, '$.Satirlar')
         WITH (Sira INT '$.Sira', SatirId INT '$.SatirId', Sil BIT '$.Sil',
               UrunId INT '$.UrunId', Tur INT '$.Tur',
               Adet DECIMAL(18,6) '$.Adet', Miktar DECIMAL(18,6) '$.Miktar',
               Birim INT '$.Birim', BirimFiyat DECIMAL(18,6) '$.BirimFiyat',
               Tutar DECIMAL(18,6) '$.Tutar', Kdv INT '$.Kdv',
               Iskonto FLOAT '$.Iskonto', Iskonto2 FLOAT '$.Iskonto2',
               Kur NVARCHAR(10) '$.Kur', DovizKuru NVARCHAR(10) '$.DovizKuru',
               DovizBirimFiyat DECIMAL(18,6) '$.DovizBirimFiyat',
               DovizKurDegeri MONEY '$.DovizKurDegeri',
               DovizTutari DECIMAL(18,6) '$.DovizTutari',
               Aciklama NVARCHAR(250) '$.Aciklama', ProjeId INT '$.ProjeId',
               MasrafId INT '$.MasrafId', OzelKod NVARCHAR(50) '$.OzelKod',
               OzelKod2 NVARCHAR(50) '$.OzelKod2', Izleme INT '$.Izleme',
               Yeri INT '$.Yeri', YerId INT '$.YerId', PozNo INT '$.PozNo',
               EkipmanId INT '$.EkipmanId', Mf DECIMAL(18,6) '$.Mf',
               MuhKodu NVARCHAR(50) '$.MuhKodu', Kasa INT '$.Kasa',
               OtvYuzde FLOAT '$.OtvYuzde', OtvMiktar DECIMAL(18,6) '$.OtvMiktar',
               IzlemeKodu NVARCHAR(50) '$.IzlemeKodu', Vade INT '$.Vade',
               KampanyaId INT '$.KampanyaId', TeslimTarihi DATETIME '$.TeslimTarihi') J;

    -- Tutar gonderilmediyse ayni formul (sp_Api_Belge_Kaydet_Json ile birebir)
    UPDATE @S SET Tutar = ROUND(ROUND(BirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE Tutar IS NULL;
    UPDATE @S SET DovizTutari = ROUND(ROUND(DovizBirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE DovizTutari IS NULL;

    -- ---------- Baslik yaz ----------
    IF @Yeni = 1
    BEGIN
        INSERT INTO SIPARIS
            (TUR, TIPI, REHBERID, TARIH, SIPARISTARIH, SIPARISNO, SIPARISSERI, KOCANNO,
             GIRISDEPO, CIKISDEPO, KDVDURUM, KUR, RAPORDOVIZ, DOVIZ_CINSI, DOVIZKUR,
             SUBEID, ACIKLAMA, AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU,
             SATICIKODU, PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO,
             OZELKOD, DURUM, EKLEYEN, EKLEMETARIHI)
        VALUES
            (@Tur, ISNULL(@Tipi, 1), @RehberId, ISNULL(@Tarih, GETDATE()),
             ISNULL(@STarih, GETDATE()), @BelgeNo, @BelgeSeri, @KocanNo,
             @GirisDepo, @CikisDepo, @KdvDurum, @Kur, @RaporDoviz, @DovizCinsi,
             ISNULL(@DovizKur, 1), @SubeId, @Aciklama, @AktiviteId, @RehberIletId,
             @ServisId, @DetayBolumu, @SaticiKodu, @ProjeId, @Vade, @FiyatListesi,
             @Unvan, @Adres, @Ilce, @Il, @Vd, @Vno, @OzelKod, ISNULL(@Durum, 0),
             @KulId, GETDATE());
        SET @BelgeId = CAST(SCOPE_IDENTITY() AS INT);
    END
    ELSE
        -- Gonderilmeyen alana DOKUNULMAZ (COALESCE ile mevcut deger korunur).
        UPDATE SIPARIS
           SET TIPI = COALESCE(@Tipi, TIPI), REHBERID = COALESCE(@RehberId, REHBERID),
               TARIH = COALESCE(@Tarih, TARIH), SIPARISTARIH = COALESCE(@STarih, SIPARISTARIH),
               SIPARISNO = COALESCE(@BelgeNo, SIPARISNO),
               SIPARISSERI = COALESCE(@BelgeSeri, SIPARISSERI),
               KOCANNO = COALESCE(@KocanNo, KOCANNO),
               GIRISDEPO = COALESCE(@GirisDepo, GIRISDEPO),
               CIKISDEPO = COALESCE(@CikisDepo, CIKISDEPO),
               KDVDURUM = COALESCE(@KdvDurum, KDVDURUM), KUR = COALESCE(@Kur, KUR),
               RAPORDOVIZ = COALESCE(@RaporDoviz, RAPORDOVIZ),
               DOVIZ_CINSI = COALESCE(@DovizCinsi, DOVIZ_CINSI),
               DOVIZKUR = COALESCE(@DovizKur, DOVIZKUR),
               ACIKLAMA = COALESCE(@Aciklama, ACIKLAMA),
               PROJEID = COALESCE(@ProjeId, PROJEID), VADE = COALESCE(@Vade, VADE),
               DURUM = COALESCE(@Durum, DURUM),
               DEGISTIREN = @KulId, DEGISTIRMETARIHI = GETDATE()
         WHERE ID = @BelgeId;

    -- ---------- Satirlar yaz ----------
    IF @SatirModu = N'tam'
        DELETE FROM SIPARISDETAY
         WHERE SIPARISID = @BelgeId
           AND ID NOT IN (SELECT ISNULL(SatirId, 0) FROM @S WHERE ISNULL(Sil, 0) = 0);

    DELETE SD FROM SIPARISDETAY SD
     INNER JOIN @S S ON S.SatirId = SD.ID
     WHERE SD.SIPARISID = @BelgeId AND S.Sil = 1;

    UPDATE SD
       SET SD.URUNID = S.UrunId, SD.TUR = S.Tur, SD.ADET = S.Adet, SD.MIKTAR = S.Miktar,
           SD.BIRIM = S.Birim, SD.BIRIMFIYAT = S.BirimFiyat, SD.TUTAR = S.Tutar,
           SD.KDV = S.Kdv, SD.ISKONTO = S.Iskonto, SD.ISKONTO2 = S.Iskonto2,
           SD.KUR = S.Kur, SD.DOVIZ_KURU = S.DovizKuru,
           SD.DOVIZ_BIRIMFIYAT = S.DovizBirimFiyat, SD.DOVIZKURDEGERI = S.DovizKurDegeri,
           SD.DOVIZ_TUTARI = S.DovizTutari, SD.ACIKLAMA = S.Aciklama,
           SD.PROJEID = S.ProjeId, SD.MASRAFID = S.MasrafId, SD.OZELKOD = S.OzelKod,
           SD.OZELKOD2 = S.OzelKod2, SD.IZLEME = S.Izleme,
           SD.YERI = COALESCE(S.Yeri, SD.YERI), SD.YERID = COALESCE(S.YerId, SD.YERID),
           SD.POZNO = S.PozNo, SD.EKIPMANID = S.EkipmanId, SD.MF = S.Mf,
           SD.MUHKODU = S.MuhKodu, SD.KASA = S.Kasa, SD.OTVYUZDE = S.OtvYuzde,
           SD.OTVMIKTAR = S.OtvMiktar, SD.IZLEMEKODU = S.IzlemeKodu, SD.VADE = S.Vade,
           SD.KAMPANYAID = S.KampanyaId,
           SD.TESLIMTARIHI = COALESCE(S.TeslimTarihi, SD.TESLIMTARIHI),
           SD.DEGISTIREN = @KulId, SD.DEGISTIRMETARIHI = GETDATE()
      FROM SIPARISDETAY SD INNER JOIN @S S ON S.SatirId = SD.ID
     WHERE SD.SIPARISID = @BelgeId AND ISNULL(S.Sil, 0) = 0;

    INSERT INTO SIPARISDETAY
        (SIPARISID, REHBERID, TUR, URUNID, ACIKLAMA, ADET, BIRIM, MIKTAR, BIRIMFIYAT,
         TUTAR, ISKONTO, ISKONTO2, KDV, MASRAFID, OZELKOD, OZELKOD2, MUHKODU, KASA,
         KUR, IZLEMEKODU, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT, DOVIZKURDEGERI,
         IZLEME, MF, YERI, YERID, POZNO, EKIPMANID, OTVYUZDE, OTVMIKTAR, VADE,
         PROJEID, KAMPANYAID, TESLIMTARIHI, SUBEID, EKLEYEN, EKLEMETARIHI)
    SELECT @BelgeId, @RehberId, S.Tur, S.UrunId, S.Aciklama, S.Adet, S.Birim, S.Miktar,
           S.BirimFiyat, S.Tutar, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId, S.OzelKod,
           S.OzelKod2, S.MuhKodu, S.Kasa, S.Kur, S.IzlemeKodu, S.DovizTutari,
           S.DovizKuru, S.DovizBirimFiyat, S.DovizKurDegeri, S.Izleme, S.Mf,
           S.Yeri, S.YerId, S.PozNo, S.EkipmanId, S.OtvYuzde, S.OtvMiktar, S.Vade,
           S.ProjeId, S.KampanyaId, S.TeslimTarihi, @SubeId, @KulId, GETDATE()
    FROM @S S
    WHERE ISNULL(S.Sil, 0) = 0 AND ISNULL(S.SatirId, 0) = 0;

    -- Yeni satirlarin ID'lerini sira ile geri esle (cagiran eslesme kurabilsin)
    ;WITH Y AS (
        SELECT SD.ID, sn = ROW_NUMBER() OVER (ORDER BY SD.ID)
        FROM SIPARISDETAY SD
        WHERE SD.SIPARISID = @BelgeId
          AND SD.EKLEMETARIHI >= DATEADD(SECOND, -5, GETDATE())
          AND NOT EXISTS (SELECT 1 FROM @S X WHERE X.SatirId = SD.ID)
    ), K AS (
        SELECT S.Sira, sn = ROW_NUMBER() OVER (ORDER BY S.Sira)
        FROM @S S WHERE ISNULL(S.Sil, 0) = 0 AND ISNULL(S.SatirId, 0) = 0
    )
    UPDATE S SET S.YeniId = Y.ID
      FROM @S S INNER JOIN K ON K.Sira = S.Sira INNER JOIN Y ON Y.sn = K.sn;

    -- ---------- Toplamlar ----------
    --   Uygulamanin kullandigi ayni formul: SP_PRG_Siparis_DipToplami.
    --   TUR 4 = Ara Toplam (matrah), 15 = KDV toplam, 20 = Genel toplam.
    --   Kolon sirasi SP'nin DONDURDUGU sirayla ayni olmali (INSERT ... EXEC
    --   ada gore degil KONUMA gore eslesir): TUR, ACIKLAMA, DEGER, KUR,
    --   DOVIZTUTARI, DOVIZ_KURU.
    DECLARE @T TABLE (TUR TINYINT, ACIKLAMA VARCHAR(255) COLLATE DATABASE_DEFAULT,
                      DEGER FLOAT, KUR VARCHAR(5) COLLATE DATABASE_DEFAULT,
                      DOVIZTUTARI FLOAT, DOVIZ_KURU VARCHAR(5) COLLATE DATABASE_DEFAULT);
    INSERT @T EXEC dbo.SP_PRG_Siparis_DipToplami @SIPARISID = @BelgeId;

    UPDATE SIPARIS
       SET SIPARIS_MATRAHI = ISNULL((SELECT TOP 1 DEGER FROM @T WHERE TUR = 4), 0),
           KDV_TUTARI      = ISNULL((SELECT TOP 1 DEGER FROM @T WHERE TUR = 15), 0),
           SIPARIS_TUTARI  = ISNULL((SELECT TOP 1 DEGER FROM @T WHERE TUR = 20), 0),
           DOVIZ_TUTARI    = ISNULL((SELECT TOP 1 DOVIZTUTARI FROM @T WHERE TUR = 20), 0)
     WHERE ID = @BelgeId;

    SET @BelgeIdOut = @BelgeId;

    IF @SonucDondur = 1
        SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Yeni AS YeniBelge,
                       (SELECT Sira, SatirId = ISNULL(SatirId, YeniId) FROM @S
                        WHERE ISNULL(Sil, 0) = 0 ORDER BY Sira FOR JSON PATH) AS Satirlar
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Api_Belge_Siparis_Kaydet_Json TO gentegre_api;
GO
