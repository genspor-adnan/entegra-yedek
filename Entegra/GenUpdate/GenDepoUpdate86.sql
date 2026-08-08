-- ============================================================
-- GenDepoUpdate86.sql
-- Uretim / UretimEmri / Demirbas listeleri : bellek grant'i sinirlama
--
-- GenDepoUpdate83-85'teki taramanin IKINCI KADEMESI. Bu uc sorguda 83/84/85'teki
--   "kosulsuz 1:N join + DISTINCT" hatasi YOK; bellek istegi baska sebepten:
--   liste TOP kullanmiyor (app TopN=0 gonderir) -> ORDER BY tum tabloyu siraliyor
--   ve genis satirlar (SELECT <tablo>.*) hash join'lerden geciyor.
--
--   OLCUM (UretimEmri, tahmini grant):
--     orijinal (ORDER BY + hash join) : istenen 17,55 MB / gereken 3,50 MB
--     ORDER BY kaldirilirsa           : istenen 11,26 MB / gereken 3,00 MB
--     ORDER BY + LOOP JOIN            : istenen  3,20 MB / gereken 0,50 MB   <-- secilen
--     ORDER BY yok + LOOP JOIN        : istenen  0,00 MB
--
--   Yani asil pay hash join'lerde, ORDER BY'da degil. LOOP JOIN sonuc kumesini ve
--   siralamayi DEGISTIRMEZ; bu yuzden ORDER BY oldugu gibi birakildi (varsayilan
--   goruntu sirasi korunur).
--
-- Olculen istenen bellek (TopN=0, tam liste):
--   sp_Prog_Uretim_Liste_Json2      40,4 MB
--   sp_Prog_UretimEmri_Liste_Json2  17,6 MB
--   sp_Prog_Demirbas_Liste_Json2    10,8 MB
-- ============================================================
-- ============================================================
-- sp_Prog_Uretim_Liste_Json2 - tek JSON parametre (MSSQL)
--   sp_Prog_Uretim_Liste (tipli) deseninin IKI-PARAM JSON karsiligi (Teklif pilotu ile ayni yapi).
--   @Baslik   = SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR). Uretim'de app '' gonderir.
--   @Kosullar = filtreler (JSON: '{"Mod":4,"DateBas":"2026-01-01",...}') -> JSON_VALUE + TRY_CAST ile yerel degiskenlere.
--   ================= GOVDE tipli sp_Prog_Uretim_Liste ILE BIREBIR =================
--   @Mod: 1=Tum (filtresiz), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.tarih)
--   @Pasif: Uretim listesinde kullanilmaz (tipli imzada rezerve) - JSON'da da yok.
--   @SelectList: ek (ozel) alanlar - Uretim'de kullanilmiyor (app '' gonderir).
--   @TopN: Uretim listesinde TOP yok - app 0 gonderir (0 = TOP yok).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Uretim_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)              -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @DateBas    DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.DateBas')   AS DATETIME);
    DECLARE @DateBitis  DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.DateBitis') AS DATETIME);
    DECLARE @UretimID   NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.UretimID');
    DECLARE @UretimNo   NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.UretimNo');
    DECLARE @StokKodu   NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.StokKodu');
    DECLARE @StokAdi    NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.StokAdi');
    DECLARE @SubeID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeID') AS INT);
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    -- Kolon listesi BIREBIR SQLMemo.Text (calisan sorgu)
    SET @SQL = N'
    SELECT ' + @Top + N'
        FB.ID,FB.TUR,[TARIH],[FATURATARIH],[FATURANO],FB.REHBERID,[SAYFA],[STOKISK],FATURA_MATRAHI,[FATURA_TUTARI],FB.KUR,
        FB.OZELKOD, FB.OZELKOD2, FB.DETAYBOLUMU,
        TPLMALIYETSON=FATURA_MATRAHI*STOKISK,TPLMALIYETORT=FATURA_TUTARI*STOKISK,DOVIZ_CINSI,
        SATIS=FB.EKVERGI, KAR=((FB.EKVERGI-FATURA_TUTARI)/nullif(FATURA_TUTARI,0))*100.0,
        DOVIZKUR,KDV_TUTARI,DOVIZ_TUTARI,
        GIRISDEPO,CIKISDEPO,
        GIRISDEPOAD = (SELECT DEPOADI FROM DEPOLAR D WHERE D.ID=FB.GIRISDEPO),
        CIKISDEPOAD = (SELECT DEPOADI FROM DEPOLAR D WHERE D.ID=FB.CIKISDEPO),
        FB.SUBEID,ACIKLAMA,
        S.STOKADI,S.KOD,S.URUNNO, FB.BOLUM, P.PROJEKODU,
        SURE=dbo.fn_TarihFarkiFormatli(FB.TARIH, FB.FATURATARIH),
        BASLAMA_YIL=YEAR(TARIH),
        BASLAMA_AY=MONTH(TARIH),
        BITIS_YIL=YEAR(FATURATARIH),
        BITIS_AY=MONTH(FATURATARIH),
        CARIKOD=(select R.KOD from REHBER R where R.ID=FB.REHBERID),
        CARIAD=(select R.FIRMA from REHBER R where R.ID=FB.REHBERID),
        ISTASYONADI=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.ISYERI),
        LOKASYONADI=(select L.ACIKLAMA from LOKASYON L where L.ID=FB.LOKASYON),
        SORUMLUADI=(select R.FIRMA from REHBER R where R.ID=FB.SATICIKODU),
        ONAYLAYANADI=(select R.FIRMA from REHBER R where R.ID=FB.ONAYLAYAN),
        DURUMNEREDEN = case when (415 in (select YERI from FATURA where FATBASID=FB.ID)) then N''Sipari' + NCHAR(351) + N'ten''
                            when (420 in (select YERI from FATURA where FATBASID=FB.ID)) then N''Sipari' + NCHAR(351) + N'ten'' else N'''' end,
        DURUMNEREYE = case when (426 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=FB.ID))) then N''Faturaya''
                           when (425 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=FB.ID))) then N''' + NCHAR(304) + N'rsaliyeye'' else N'''' end
        ' + @SelectList + N'
    FROM FATBASLIK FB
        left join STOKLAR S on S.ID=FB.AKTIVITEID
        left outer join PROJELER P on P.ID=FB.PROJEID '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = FB.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE FB.TUR=6 ';

    -- Arama-kutusu filtreleri SADECE @Mod=4 (Filtre) icin (eski: Sender<>LabelTumKayitlar)
    IF @Mod = 4
    BEGIN
        IF @DateBas IS NOT NULL
            SET @SQL = @SQL + N' AND FB.TARIH > @pDateBas ';
        IF @DateBitis IS NOT NULL
            SET @SQL = @SQL + N' AND FB.TARIH < DATEADD(SECOND, 86399, CONVERT(DATETIME, CONVERT(DATE, @pDateBitis))) ';
        IF @UretimID IS NOT NULL AND @UretimID <> N''
            SET @SQL = @SQL + N' AND FB.ID LIKE N''%'' + @pUretimID + N''%'' ';
        IF @UretimNo IS NOT NULL AND @UretimNo <> N''
            SET @SQL = @SQL + N' AND FB.FATURANO LIKE N''%'' + @pUretimNo + N''%'' ';
        IF @StokKodu IS NOT NULL AND @StokKodu <> N''
            SET @SQL = @SQL + N' AND S.KOD LIKE N''%'' + @pStokKodu + N''%'' ';
        IF @StokAdi IS NOT NULL AND @StokAdi <> N''
            SET @SQL = @SQL + N' AND S.STOKADI LIKE N''%'' + @pStokAdi + N''%'' ';
        IF @SubeID IS NOT NULL
            SET @SQL = @SQL + N' AND FB.SUBEID = ' + CAST(@SubeID AS NVARCHAR(20)) + N' ';
    END;

    -- Siralama: Son/Sik SP belirler; digerlerinde app'ten gelen @OrderBy (or. FB.TARIH)
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    -- Bellek grant'i sinirlama. Bu liste TOP kullanmiyor (app TopN=0 gonderir), yani
    --   ORDER BY tum tabloyu siraliyor ve genis satirlar (SELECT <tablo>.*) hash join'lerden
    --   geciyordu. SQL Express'te sorgu-bellek semaforu daralinca bu istek karsilanamaz ve
    --   ekran RESOURCE_SEMAPHORE'da donar (bkz. GenDepoUpdate83/84/85).
    --   Tum join'ler benzersiz anahtar uzerinde arama oldugu icin LOOP JOIN hash tamponunu
    --   kaldirir; ORDER BY ve sonuc sirasi AYNEN korunur.
    SET @SQL = @SQL + N' OPTION (LOOP JOIN, MAXDOP 1)';

    EXEC sp_executesql @SQL,
         N'@pDateBas DATETIME, @pDateBitis DATETIME, @pUretimID NVARCHAR(50), @pUretimNo NVARCHAR(50), @pStokKodu NVARCHAR(50), @pStokAdi NVARCHAR(150)',
         @pDateBas = @DateBas, @pDateBitis = @DateBitis, @pUretimID = @UretimID,
         @pUretimNo = @UretimNo, @pStokKodu = @StokKodu, @pStokAdi = @StokAdi;
END;

GO

-- ============================================================
-- sp_Prog_UretimEmri_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR); @Kosullar = filtreler (JSON).
--   sp_Prog_UretimEmri_Liste (tipli) deseninin Json2 karsiligi. GOVDE tipli SP ile BIREBIR.
--   @Kosullar = '{"Mod":4,"BasTar":"2026-01-01",...}' -> JSON_VALUE ile yerel degiskenlere.
--   Absent key -> NULL (filtre uygulanmaz). Bool'lar 0/1 sayi (TRY_CAST AS BIT).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_UretimEmri_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Pasif      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @UretimID   NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.UretimID');
    DECLARE @StokKodu   NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.StokKodu');
    DECLARE @StokAdi    NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.StokAdi');
    DECLARE @DetayUrun  NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.DetayUrun');
    DECLARE @BasTar     DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.BasTar') AS DATETIME);
    DECLARE @BitTar     DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.BitTar') AS DATETIME);
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    -- @OrderBy: tipli SP'de varsayilan N'U.BASTAR' -> parite icin absent=varsayilan.
    DECLARE @OrderBy    NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.OrderBy'), N'U.BASTAR');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    -- SELECT: eski sorgu ile BIREBIR (U.* + joined alias'lar)
    SET @SQL = N'
    SELECT ' + @Top + N'
        U.*,
        S.KOD AS STOKKODU, S.STOKADI, S.URUNNO,
        P.PROJEKODU,
        L.ACIKLAMA AS ANAKAYNAKAD,
        R.FIRMA AS FIRMAAD
        ' + @SelectList + N'
    FROM URETIMEMRI U
        LEFT JOIN STOKLAR S ON S.ID = U.STOKID
        LEFT JOIN PROJELER P ON P.ID = U.PROJEID
        LEFT JOIN LOKASYON L ON L.ID = U.ANAKAYNAK
        LEFT JOIN REHBER R ON R.ID = U.REHBERID '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = U.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';

    -- Metin filtreleri (parametreli). @Mod=1 (Tum) -> app bos gonderir, filtre uygulanmaz.
    IF @UretimID IS NOT NULL AND @UretimID <> N''
        SET @SQL = @SQL + N' AND (U.ID LIKE N''%'' + @pUretimID + N''%'' OR U.EMIRNO LIKE N''%'' + @pUretimID + N''%'') ';
    IF @StokKodu IS NOT NULL AND @StokKodu <> N''
        SET @SQL = @SQL + N' AND (S.KOD LIKE N''%'' + @pStokKodu + N''%'' OR S.URUNNO LIKE N''%'' + @pStokKodu + N''%'') ';
    IF @StokAdi IS NOT NULL AND @StokAdi <> N''
        SET @SQL = @SQL + N' AND S.STOKADI LIKE N''%'' + @pStokAdi + N''%'' ';
    IF @DetayUrun IS NOT NULL AND @DetayUrun <> N''
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM URETIMEMRIDETAY UED
                                         INNER JOIN STOKLAR S2 ON S2.ID = UED.URUNID
                                         WHERE UED.URETIMEMRIID = U.ID
                                           AND (S2.KOD LIKE N''%'' + @pDetayUrun + N''%''
                                                OR S2.URUNNO LIKE N''%'' + @pDetayUrun + N''%'')) ';

    -- Tarih filtreleri (parametreli)
    IF @BasTar IS NOT NULL
        SET @SQL = @SQL + N' AND U.BASTAR >= @pBasTar ';
    IF @BitTar IS NOT NULL
        SET @SQL = @SQL + N' AND U.BASTAR <= @pBitTar ';

    -- Pasif: kapaliyken sadece aktif (eski: CheckPasifler kapali -> U.DURUM>0)
    IF @Pasif = 0
        SET @SQL = @SQL + N' AND U.DURUM > 0 ';

    -- Son/Sik aranan siralamasi (KULLANICI_ARAMA)
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    -- Bellek grant'i sinirlama. Bu liste TOP kullanmiyor (app TopN=0 gonderir), yani
    --   ORDER BY tum tabloyu siraliyor ve genis satirlar (SELECT <tablo>.*) hash join'lerden
    --   geciyordu. SQL Express'te sorgu-bellek semaforu daralinca bu istek karsilanamaz ve
    --   ekran RESOURCE_SEMAPHORE'da donar (bkz. GenDepoUpdate83/84/85).
    --   Tum join'ler benzersiz anahtar uzerinde arama oldugu icin LOOP JOIN hash tamponunu
    --   kaldirir; ORDER BY ve sonuc sirasi AYNEN korunur.
    SET @SQL = @SQL + N' OPTION (LOOP JOIN, MAXDOP 1)';

    EXEC sp_executesql @SQL,
         N'@pUretimID NVARCHAR(50), @pStokKodu NVARCHAR(50), @pStokAdi NVARCHAR(150),
           @pDetayUrun NVARCHAR(50), @pBasTar DATETIME, @pBitTar DATETIME',
         @pUretimID = @UretimID, @pStokKodu = @StokKodu, @pStokAdi = @StokAdi,
         @pDetayUrun = @DetayUrun, @pBasTar = @BasTar, @pBitTar = @BitTar;
END;

GO

-- ============================================================
-- sp_Prog_Demirbas_Liste_Json2 — tek JSON parametre (MSSQL-ONLY)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR/app-uretimi);
--              @Kosullar = filtreler + yetki kisitlari (JSON: cast/parametreli DEGERLER).
--   Tipli sp_Prog_Demirbas_Liste'nin TUM parametreleri JSON_VALUE(@Kosullar,'$.<ad>')+TRY_CAST
--   ile yerel degiskenlere cozulur; absent key -> NULL. Govde tipli SP ile BIREBIR AYNI.
--   Amac: JSON vs tipli-param pariter karsilastirmasi (Teklif pilotu deseni).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Demirbas_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler + yetki (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList     NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN           INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')          AS INT), 0);
    DECLARE @Mod            SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')           AS SMALLINT), 4);
    DECLARE @Pasif          BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif')         AS BIT), 0);
    DECLARE @DurumID        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.DurumID')        AS INT);
    DECLARE @KategoriAdi    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.KategoriAdi');
    DECLARE @LokasyonAdi    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.LokasyonAdi');
    DECLARE @ZimmetAlanAdi  NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.ZimmetAlanAdi');
    DECLARE @DemirbasNo     NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.DemirbasNo');
    DECLARE @DemirbasAdi    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.DemirbasAdi');
    DECLARE @SeriNo         NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.SeriNo');
    DECLARE @SubeYetkiList  NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');
    DECLARE @KullaniciKisit SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KullaniciKisit') AS SMALLINT), 0);
    DECLARE @KullaniciId    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KullaniciId')    AS INT);
    DECLARE @SubeId         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeId')         AS INT);
    DECLARE @KategoriYetki  SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KategoriYetki') AS SMALLINT), 1);
    DECLARE @RolId          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.RolId')          AS INT);
    DECLARE @KulId          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId')          AS INT);
    DECLARE @Modul          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul')          AS INT);
    DECLARE @OrderBy        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    -- SELECT + FROM (SQLMemo runtime sorgusu BIREBIR; nested TOP + convert native)
    SET @SQL = N'
    SELECT ' + @Top + N'
        D.*,
        ZIMMETLIADI = R.FIRMA,
        LOKASYONADI = L.ACIKLAMA,
        KATEGORIADI = DU.AD,
        StokModel.ANAHTAR AS MODELAD,
        KALBITTARIH = (SELECT MAX(GECERLILIKTARIHI) FROM KALIBRASYON K WHERE K.DEMIRBASID = D.ID)
        ' + @SelectList + N'
    FROM DEMIRBAS D
        LEFT OUTER JOIN DEMIRBAS_KATEGORI AS DU ON DU.ID = D.KATEGORIID
        LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = D.MODEL
             AND StokModel.BOLUM = CONVERT(INT, ''-2804'' + CONVERT(VARCHAR(10), D.MARKA))
        LEFT OUTER JOIN REHBER AS R ON R.ID = D.REHBERID
        LEFT OUTER JOIN LOKASYON AS L ON L.ID = (SELECT TOP 1 LOKASYONID
                                                 FROM DEMIRBAS_TUTANAK DT
                                                     INNER JOIN DEMIRBAS_TUTANAK_DETAY DTD
                                                          ON DT.ID = DTD.TUTANAKID AND DTD.DEMIRBASID = D.ID
                                                 ORDER BY ID DESC) '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = D.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';

    -- Durum / Pasif  (AraDurumu set ise oncelikli; degilse pasif kapaliyken DURUM<30)
    IF @DurumID IS NOT NULL
        SET @SQL = @SQL + N' AND D.DURUM = ' + CAST(@DurumID AS NVARCHAR(20)) + N' ';
    ELSE IF @Pasif = 0
        SET @SQL = @SQL + N' AND D.DURUM < 30 ';

    -- Metin filtreleri (parametreli)
    IF @KategoriAdi IS NOT NULL AND @KategoriAdi <> N''
        SET @SQL = @SQL + N' AND DU.AD LIKE N''%'' + @pKategoriAdi + N''%'' ';
    IF @LokasyonAdi IS NOT NULL AND @LokasyonAdi <> N''
        SET @SQL = @SQL + N' AND L.ACIKLAMA LIKE N''%'' + @pLokasyonAdi + N''%'' ';
    IF @ZimmetAlanAdi IS NOT NULL AND @ZimmetAlanAdi <> N''
        SET @SQL = @SQL + N' AND R.FIRMA LIKE N''%'' + @pZimmetAlanAdi + N''%'' ';
    IF @DemirbasNo IS NOT NULL AND @DemirbasNo <> N''
        SET @SQL = @SQL + N' AND D.DEMIRBASNO LIKE N''%'' + @pDemirbasNo + N''%'' ';
    IF @DemirbasAdi IS NOT NULL AND @DemirbasAdi <> N''
        SET @SQL = @SQL + N' AND D.DEMIRBASADI LIKE N''%'' + @pDemirbasAdi + N''%'' ';
    IF @SeriNo IS NOT NULL AND @SeriNo <> N''
        SET @SQL = @SQL + N' AND D.SERINO LIKE N''%'' + @pSeriNo + N''%'' ';

    -- Sube yetkisi (SubeVarmi ise) - int listesi, guvenli
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND D.SUBEID IN (' + @SubeYetkiList + N') ';

    -- Kullanici kisiti (TamYetkili degilse; app 0 gonderir -> no-op)
    IF @KullaniciKisit = 1 AND @KullaniciId IS NOT NULL
        SET @SQL = @SQL + N' AND D.REHBERID = ' + CAST(@KullaniciId AS NVARCHAR(20)) + N' ';
    ELSE IF @KullaniciKisit = 5 AND @KullaniciId IS NOT NULL
        SET @SQL = @SQL + N' AND D.REHBERID IN (SELECT RB.ID FROM REHBER RB
                                 INNER JOIN ROLLER ROL ON RB.SINIF = ROL.ID
                                 WHERE ROL.DEPARTMAN = (SELECT ROL2.DEPARTMAN FROM REHBER RB2
                                                        INNER JOIN ROLLER ROL2 ON RB2.SINIF = ROL2.ID
                                                        WHERE RB2.ID = ' + CAST(@KullaniciId AS NVARCHAR(20)) + N')) ';
    ELSE IF @KullaniciKisit = 10 AND @SubeId IS NOT NULL
        SET @SQL = @SQL + N' AND D.SUBEID = ' + CAST(@SubeId AS NVARCHAR(20)) + N' ';

    -- Kategori yetkisi (TamYetkili degilse; app 1 gonderir -> no-op)
    IF @KategoriYetki = 0
        SET @SQL = @SQL + N' AND D.KATEGORIID = 0 ';
    ELSE IF @KategoriYetki = 2 AND @RolId IS NOT NULL
        SET @SQL = @SQL + N' AND D.KATEGORIID IN (SELECT CAST(ISNULL(Y.BILGI,0) AS INT)
                                 FROM YETKIEK Y WHERE Y.ROLID = ' + CAST(@RolId AS NVARCHAR(20)) + N'
                                   AND Y.MODULID = 280105) ';

    -- Siralama (Son/Sik icin KULLANICI_ARAMA; digerlerinde EKLEMETARIHI desc)
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    ELSE IF @OrderBy IS NULL OR @OrderBy = N'' SET @OrderBy = N'D.EKLEMETARIHI DESC';

    SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    -- Bellek grant'i sinirlama. Bu liste TOP kullanmiyor (app TopN=0 gonderir), yani
    --   ORDER BY tum tabloyu siraliyor ve genis satirlar (SELECT <tablo>.*) hash join'lerden
    --   geciyordu. SQL Express'te sorgu-bellek semaforu daralinca bu istek karsilanamaz ve
    --   ekran RESOURCE_SEMAPHORE'da donar (bkz. GenDepoUpdate83/84/85).
    --   Tum join'ler benzersiz anahtar uzerinde arama oldugu icin LOOP JOIN hash tamponunu
    --   kaldirir; ORDER BY ve sonuc sirasi AYNEN korunur.
    SET @SQL = @SQL + N' OPTION (LOOP JOIN, MAXDOP 1)';

    EXEC sp_executesql @SQL,
         N'@pKategoriAdi NVARCHAR(200), @pLokasyonAdi NVARCHAR(200), @pZimmetAlanAdi NVARCHAR(200),
           @pDemirbasNo NVARCHAR(100), @pDemirbasAdi NVARCHAR(200), @pSeriNo NVARCHAR(100)',
         @pKategoriAdi = @KategoriAdi, @pLokasyonAdi = @LokasyonAdi, @pZimmetAlanAdi = @ZimmetAlanAdi,
         @pDemirbasNo = @DemirbasNo, @pDemirbasAdi = @DemirbasAdi, @pSeriNo = @SeriNo;
END;

