-- ============================================================
-- GenDepoUpdate7 : sp_Prog_Teklif_Liste_Json2  (2-param JSON, guncel)
--   Liste ekrani sunucu-tarafi listeleme SP'si. ANA DB baglantisindan.
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: GenDepoUpdate4 (KULLANICI_ARAMA).
-- ============================================================

-- ============================================================
-- PILOT: sp_Prog_Teklif_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT kolonlari (ham SQL, guvenilir); @Kosullar = filtreler (JSON).
--   @Kosullar = '{"Mod":4,"TarihBas":"2026-01-01",...}' -> JSON_VALUE ile yerel degiskenlere.
--   Amac: JSON vs tipli-param karsilastirmasi (parite + sure + kod).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Teklif_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)              -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList        NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN              INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')  AS INT), 0);
    DECLARE @Mod               SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')   AS SMALLINT), 4);
    DECLARE @TarihBas          DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATE);
    DECLARE @TarihBit          DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATE);
    DECLARE @Hazirlayan        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Hazirlayan');
    DECLARE @Musteri           NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Musteri');
    DECLARE @Konusu            NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Konusu');
    DECLARE @Turu              INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Turu') AS INT);
    DECLARE @BelgeNo           NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.BelgeNo');
    DECLARE @Stok              NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Stok');
    DECLARE @Durumu            INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Durumu') AS INT);
    DECLARE @Revize            BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Revize') AS BIT), 0);
    DECLARE @Kabul             BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kabul') AS BIT), 0);
    DECLARE @Reddedilenler     BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Reddedilenler') AS BIT), 0);
    DECLARE @SubeYetkiList     NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');
    DECLARE @HazirlayanZorunlu INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.HazirlayanZorunlu') AS INT);
    DECLARE @SubeZorunlu       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeZorunlu') AS INT);
    DECLARE @KulId             INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul             INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy           NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    SET @SQL = N'
    SELECT ' + @Top + N'
        T.*,
        P.PROJEKODU, P.PROJEADI,
        CARIKOD = R1.KOD, R1.FIRMA,
        HAZIRLAYAN, R2.FIRMA AS HAZIRLAYANAD,
        RP.FIRMA AS MUS_ILGILIAD,
        VERILENSIPARIS = CASE WHEN 412 IN (SELECT YERI FROM SIPARISDETAY WHERE YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID = T.ID)) THEN ''Var'' ELSE '''' END,
        ALINANSIPARIS  = CASE WHEN 413 IN (SELECT YERI FROM SIPARISDETAY WHERE YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID = T.ID)) THEN ''Var'' ELSE '''' END,
        TEKLIFGUNSAYISI = DATEDIFF(day, T.TARIH, GETDATE()),
        DURUMGUNSAYISI  = DATEDIFF(day, DURUMTARIHI, GETDATE()),
        TESLIMTARIHI = (SELECT MIN(TESLIMTARIHI) FROM TEKLIFDETAY WHERE TEKLIFID = T.ID),
        TESLIMTARIHI = (SELECT MIN(TESLIMTARIHI) FROM TEKLIFDETAY WHERE TEKLIFID = T.ID),
        ONAYLAYACAK2 = R3.FIRMA,
        GECERLILIK_KALAN = CASE WHEN ISNULL(T.GECERLILIK_SURESI, 0) = 0 THEN 0 ELSE DATEDIFF(day, GETDATE(), T.TARIH + GECERLILIK_SURESI) END,
        ONAYLAYAN = R4.FIRMA,
        DISONAYCI = RP2.FIRMA,
        SONUCAD  = (SELECT ANAHTAR FROM GENINI WHERE BOLUM = -2911 AND DEGER = T.SONUC  AND DIL = -1),
        SEBEBIAD = (SELECT ANAHTAR FROM GENINI WHERE BOLUM = -2912 AND DEGER = T.SEBEBI AND DIL = -1),
        PRJ_DURUM = P.DURUM, PRJ_SONUC = P.SONUC, PRJ_SEBEBI = P.SEBEBI
        ' + @SelectList + N'
    FROM TEKLIF T
        LEFT OUTER JOIN REHBER R1  ON R1.ID  = T.REHBERID
        LEFT OUTER JOIN REHBER R2  ON R2.ID  = T.HAZIRLAYAN
        LEFT OUTER JOIN REHBER RP  ON RP.ID  = T.MUS_ILGILI
        LEFT OUTER JOIN PROJELER P ON P.ID   = T.PROJEID
        LEFT OUTER JOIN REHBER R3  ON T.ONAYLAYACAK = R3.ID
        LEFT OUTER JOIN REHBER R4  ON T.ONAYLAYAN   = R4.ID
        LEFT OUTER JOIN REHBER RP2 ON T.DISONAY     = RP2.ID ';

    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
        SET @SQL = @SQL + N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = T.ID AND KA.KULID = '
                 + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' ';

    SET @SQL = @SQL + N' WHERE 1 = 1 ';

    IF @TarihBas IS NOT NULL AND @TarihBit IS NOT NULL
        SET @SQL = @SQL + N' AND (T.TARIH BETWEEN @pTarihBas AND @pTarihBit) ';
    IF @Hazirlayan IS NOT NULL AND @Hazirlayan <> N''
        SET @SQL = @SQL + N' AND R2.FIRMA LIKE @pHazirlayan + N''%'' ';
    IF @Musteri IS NOT NULL AND @Musteri <> N''
        SET @SQL = @SQL + N' AND R1.FIRMA LIKE @pMusteri + N''%'' ';
    IF @Konusu IS NOT NULL AND @Konusu <> N''
        SET @SQL = @SQL + N' AND T.KONUSU LIKE @pKonusu + N''%'' ';
    IF @BelgeNo IS NOT NULL AND @BelgeNo <> N''
        SET @SQL = @SQL + N' AND ISNULL(TEKLIFNO, N'''') LIKE N''%'' + @pBelgeNo + N''%'' ';
    IF @Turu IS NOT NULL AND @Turu > 0
        SET @SQL = @SQL + N' AND T.TURU = ' + CAST(@Turu AS NVARCHAR(20)) + N' ';
    IF @Stok IS NOT NULL AND @Stok <> N''
        SET @SQL = @SQL + N'
        AND EXISTS (
            SELECT 1 FROM TEKLIFDETAY TD
                LEFT OUTER JOIN STOKLAR S      ON S.ID  = TD.URUNID AND TD.TUR = 1
                LEFT OUTER JOIN MASRAFGELIR MG ON MG.ID = TD.URUNID AND TD.TUR = 0
            WHERE TD.TEKLIFID = T.ID
              AND (S.STOKADI LIKE N''%'' + @pStok + N''%''
                OR S.KOD     LIKE N''%'' + @pStok + N''%''
                OR MG.AD     LIKE N''%'' + @pStok + N''%''
                OR MG.KOD    LIKE N''%'' + @pStok + N''%'')
        ) ';

    IF @Durumu IS NOT NULL AND @Durumu > 0
    BEGIN
        DECLARE @Dr NVARCHAR(100) = CAST(@Durumu AS NVARCHAR(20));
        IF @Revize        = 1 SET @Dr = @Dr + N',5';
        IF @Kabul         = 1 SET @Dr = @Dr + N',7';
        IF @Reddedilenler = 1 SET @Dr = @Dr + N',6';
        SET @SQL = @SQL + N' AND T.DURUM IN (' + @Dr + N') ';
    END
    ELSE
    BEGIN
        DECLARE @a NVARCHAR(100) = N'';
        IF @Revize        = 0 SET @a = CASE WHEN @a = N'' THEN N'5' ELSE @a + N',5' END;
        IF @Kabul         = 0 SET @a = CASE WHEN @a = N'' THEN N'7' ELSE @a + N',7' END;
        IF @Reddedilenler = 0 SET @a = CASE WHEN @a = N'' THEN N'6' ELSE @a + N',6' END;
        IF @a <> N''
            SET @SQL = @SQL + N' AND T.DURUM NOT IN (' + @a + N') ';
        ELSE
            SET @SQL = @SQL + N' AND T.DURUM NOT IN (-1) ';
    END;

    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND T.SUBEID IN (' + @SubeYetkiList + N') ';
    IF @HazirlayanZorunlu IS NOT NULL
        SET @SQL = @SQL + N' AND T.HAZIRLAYAN = ' + CAST(@HazirlayanZorunlu AS NVARCHAR(20)) + N' ';
    IF @SubeZorunlu IS NOT NULL
        SET @SQL = @SQL + N' AND T.SUBEID = ' + CAST(@SubeZorunlu AS NVARCHAR(20)) + N' ';

    SET @SQL = @SQL + N' AND T.TEKLIFTUR = 80 ';

    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    ELSE IF @OrderBy IS NULL OR @OrderBy = N'' SET @OrderBy = N'T.TARIH';

    SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pTarihBas DATE, @pTarihBit DATE, @pHazirlayan NVARCHAR(200), @pMusteri NVARCHAR(200), @pKonusu NVARCHAR(200), @pBelgeNo NVARCHAR(100), @pStok NVARCHAR(200)',
         @pTarihBas = @TarihBas, @pTarihBit = @TarihBit, @pHazirlayan = @Hazirlayan,
         @pMusteri = @Musteri, @pKonusu = @Konusu, @pBelgeNo = @BelgeNo, @pStok = @Stok;
END;
