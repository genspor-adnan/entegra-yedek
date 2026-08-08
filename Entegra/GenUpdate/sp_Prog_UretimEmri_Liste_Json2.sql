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
