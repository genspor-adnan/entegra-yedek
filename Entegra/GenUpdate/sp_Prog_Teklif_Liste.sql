-- ============================================================
-- sp_Prog_Teklif_Liste — Teklif liste ekrani sunucu-tarafi listeleme (UTeklifListeDlg)
--   sp_Prog_Stok_Liste deseninin Teklif karsiligi.
--   SELECT/FROM/JOIN kismi eski SQLMemo (JvTimer1Timer) sorgusu ile BIREBIR aynidir
--   (T.* + hesap kolonlari + REHBER/PROJE join'leri) -> grid kolonlari degismez.
--   PERFORMANS: eski kod AraStok icin FROM'a INNER JOIN TEKLIFDETAY + STOKLAR/MASRAFGELIR
--   ekleyip (GROUP BY/DISTINCT olmadan) teklif satirlarini cogaltiyordu; burada bu filtre
--   EXISTS'e cevrildi (bir teklif tek satir kalir). Metin filtreleri sp_executesql ile
--   parametreli (plan reuse + enjeksiyon guvenli); sayisal filtreler int cast.
--   @Mod: 1=Tum, 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.DEGISTIRMETARIHI)
--   Teklif'te "Cok Kullanilan" (Mod=2) yoktur.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Teklif_Liste
    @SelectList        NVARCHAR(MAX) = N'',      -- ',[Cap]=Field,...' (ek alan SELECT; Teklif'te genelde bos)
    @TopN              INT           = 0,        -- 0 = TOP yok; Son/Sik icin kayit limiti
    @Mod               SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @TarihBas          DATE          = NULL,     -- T.TARIH between
    @TarihBit          DATE          = NULL,
    @Hazirlayan        NVARCHAR(200) = NULL,     -- R2.FIRMA like 'x%'
    @Musteri           NVARCHAR(200) = NULL,     -- R1.FIRMA like 'x%'
    @Konusu            NVARCHAR(200) = NULL,     -- T.KONUSU like 'x%'  (AraKonusu.EditValue>0 iken)
    @Turu              INT           = NULL,     -- T.TURU = x           (AraTuru.EditValue>0 iken)
    @BelgeNo           NVARCHAR(100) = NULL,     -- ISNULL(TEKLIFNO,'') like '%x%'
    @Stok              NVARCHAR(200) = NULL,     -- stok/masraf satir aramasi (EXISTS)
    @Durumu            INT           = NULL,     -- AraDurumu.EditValue
    @Revize            BIT           = 0,        -- AraRevize.Checked
    @Kabul             BIT           = 0,        -- AraKabulEdilenler.Checked
    @Reddedilenler     BIT           = 0,        -- AraReddedilenler.Checked
    @SubeYetkiList     NVARCHAR(MAX) = NULL,     -- SubeVarmi iken yetkili sube id listesi (virgullu)
    @HazirlayanZorunlu INT           = NULL,     -- ModulYetki=1  -> T.HAZIRLAYAN = x (sadece kendi)
    @SubeZorunlu       INT           = NULL,     -- ModulYetki=10 -> T.SUBEID = x (sadece kendi sube)
    @KulId             INT           = NULL,     -- @Mod=3/5 icin kullanici (KULLANICI_ARAMA)
    @Modul             INT           = NULL,     -- @Mod=3/5 icin MODUL.MODULID (Teklif=29)
    @OrderBy           NVARCHAR(200) = NULL      -- NULL -> T.TARIH
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    -- SELECT + FROM + JOIN: eski SQLMemo ile BIREBIR
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

    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join (unique KULID,MODUL,KAYITID)
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
        SET @SQL = @SQL + N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = T.ID AND KA.KULID = '
                 + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' ';

    SET @SQL = @SQL + N' WHERE 1 = 1 ';

    -- Tarih araligi (app her zaman gonderir)
    IF @TarihBas IS NOT NULL AND @TarihBit IS NOT NULL
        SET @SQL = @SQL + N' AND (T.TARIH BETWEEN @pTarihBas AND @pTarihBit) ';

    -- Metin filtreleri (parametreli)
    IF @Hazirlayan IS NOT NULL AND @Hazirlayan <> N''
        SET @SQL = @SQL + N' AND R2.FIRMA LIKE @pHazirlayan + N''%'' ';
    IF @Musteri IS NOT NULL AND @Musteri <> N''
        SET @SQL = @SQL + N' AND R1.FIRMA LIKE @pMusteri + N''%'' ';
    IF @Konusu IS NOT NULL AND @Konusu <> N''
        SET @SQL = @SQL + N' AND T.KONUSU LIKE @pKonusu + N''%'' ';
    IF @BelgeNo IS NOT NULL AND @BelgeNo <> N''
        SET @SQL = @SQL + N' AND ISNULL(TEKLIFNO, N'''') LIKE N''%'' + @pBelgeNo + N''%'' ';

    -- Turu (sayisal)
    IF @Turu IS NOT NULL AND @Turu > 0
        SET @SQL = @SQL + N' AND T.TURU = ' + CAST(@Turu AS NVARCHAR(20)) + N' ';

    -- Stok/Masraf satir aramasi: eski FROM join yerine EXISTS (teklif satiri cogalmaz)
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

    -- DURUM filtresi (eski JvTimer mantigi birebir):
    --   Durumu>0  -> DURUM IN (Durumu [,5 revize][,7 kabul][,6 red])
    --   Durumu<=0 -> DURUM NOT IN (isaretsizler: 5/7/6); hepsi isaretliyse NOT IN (-1)
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

    -- Sube yetkisi (SubeVarmi iken app @SubeYetkiList gonderir)
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND T.SUBEID IN (' + @SubeYetkiList + N') ';

    -- ModulYetki_TekSubeTum.Teklif: 1=sadece kendi, 10=sadece kendi sube
    IF @HazirlayanZorunlu IS NOT NULL
        SET @SQL = @SQL + N' AND T.HAZIRLAYAN = ' + CAST(@HazirlayanZorunlu AS NVARCHAR(20)) + N' ';
    IF @SubeZorunlu IS NOT NULL
        SET @SQL = @SQL + N' AND T.SUBEID = ' + CAST(@SubeZorunlu AS NVARCHAR(20)) + N' ';

    -- Teklif belge turu (her zaman)
    SET @SQL = @SQL + N' AND T.TEKLIFTUR = 80 ';

    -- Siralama: Son/Sik icin KULLANICI_ARAMA, aksi halde TARIH
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    ELSE IF @OrderBy IS NULL OR @OrderBy = N'' SET @OrderBy = N'T.TARIH';

    SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pTarihBas DATE, @pTarihBit DATE, @pHazirlayan NVARCHAR(200), @pMusteri NVARCHAR(200), @pKonusu NVARCHAR(200), @pBelgeNo NVARCHAR(100), @pStok NVARCHAR(200)',
         @pTarihBas = @TarihBas, @pTarihBit = @TarihBit, @pHazirlayan = @Hazirlayan,
         @pMusteri = @Musteri, @pKonusu = @Konusu, @pBelgeNo = @BelgeNo, @pStok = @Stok;
END;
