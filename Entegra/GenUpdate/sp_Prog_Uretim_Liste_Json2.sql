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
