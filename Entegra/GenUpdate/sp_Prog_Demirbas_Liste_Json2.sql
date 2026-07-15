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

    EXEC sp_executesql @SQL,
         N'@pKategoriAdi NVARCHAR(200), @pLokasyonAdi NVARCHAR(200), @pZimmetAlanAdi NVARCHAR(200),
           @pDemirbasNo NVARCHAR(100), @pDemirbasAdi NVARCHAR(200), @pSeriNo NVARCHAR(100)',
         @pKategoriAdi = @KategoriAdi, @pLokasyonAdi = @LokasyonAdi, @pZimmetAlanAdi = @ZimmetAlanAdi,
         @pDemirbasNo = @DemirbasNo, @pDemirbasAdi = @DemirbasAdi, @pSeriNo = @SeriNo;
END;
