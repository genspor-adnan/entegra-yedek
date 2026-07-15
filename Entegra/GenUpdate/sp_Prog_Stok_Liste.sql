-- ============================================================
-- sp_Prog_Stok_Liste — Stok liste ekrani sunucu-tarafi listeleme (UStokListeDlg)
--   UFaturalar sp_Prog_AlisSatis_* deseninin Stok karsiligi.
--   PERFORMANS: eski JvTimer sorgusu STOKBARKOD join + 24 kolon GROUP BY ile
--   tekillestiriyordu. Burada join YOK -> barkod filtresi EXISTS, GROUP BY YOK
--   (her stok dogal tek satir), StokModel/SDKALAN/RECETEVAR scalar subquery,
--   metin filtreleri parametreli (plan reuse + enjeksiyon guvenli). Sonuc kumesi ayni.
--   @Mod: 1=Tum, 2=Cok Kullanilan (GENINI), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.tarih)
--   @Pasif: 0=sadece aktif (S.DURUM=1), 1=hepsi
--   @SelectList: ek (ozel) alanlar - app gorunur kolonlardan ',[Cap]=Field,...' uretir
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Stok_Liste
    @SelectList     NVARCHAR(MAX) = N'',     -- ',[Cap]=Field,...' (ek alan SELECT)
    @TopN           INT           = 200,     -- 0 = TOP yok (Tum mod)
    @Mod            SMALLINT      = 4,        -- 1=Tum 2=CokKullanilan 4=Filtre
    @Pasif          BIT           = 0,        -- 0=aktif 1=hepsi
    @StokAdi        NVARCHAR(150) = NULL,
    @Kod            NVARCHAR(50)  = NULL,
    @KategoriID     INT           = NULL,
    @MarkaID        INT           = NULL,
    @ModelID        INT           = NULL,
    @GrubuID        INT           = NULL,
    @SubeID         INT           = NULL,     -- tek sube secimi (<1 ise filtre)
    @Barkod         NVARCHAR(50)  = NULL,     -- '', 'NULL', 'NOT NULL' ozel; yoksa LIKE
    @SubeYetkiList  NVARCHAR(MAX) = NULL,     -- yetkili sube id listesi (virgullu)
    @CokKullanBolum INT           = NULL,     -- @Mod=2 icin GENINI.BOLUM
    @KulId          INT           = NULL,     -- @Mod=3/5 icin kullanici (KULLANICI_ARAMA)
    @Modul          INT           = NULL,     -- @Mod=3/5 icin MODUL.MODULID (Stok=27)
    @OrderBy        NVARCHAR(200) = NULL      -- or. '1' (Tum mod order by 1); NULL=siralamasiz
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    SET @SQL = N'
    SELECT ' + @Top + N'
        S.ID, S.KOD, S.STOKADI, K.AD, S.TIPI, S.MARKA, S.GRUBU, S.OZELLIK, S.ICERIK, S.OZELKOD, S.SUBEID, S.URUNNO,
        S.MUHKODU, S.ANABIRIM, S.BIRIM2, S.BIRIM2MIKTAR, S.MINSTOK, S.KDV, S.DURUM, S.HUCRE,
        S.IZLEME, S.BILDIRIM, S.NOTLAR,
        STOKMODEL = (SELECT TOP 1 G.ANAHTAR FROM GENINI G
                     WHERE G.DIL < 0 AND G.DEGER = S.MODEL
                       AND G.BOLUM = CONVERT(INT, ''-2701'' + CONVERT(VARCHAR(10), S.MARKA))),
        SDKALAN   = (SELECT SUM(SD.KALAN) FROM STOKDURUM SD WHERE SD.STOKID = S.ID),
        RECETEVAR = ISNULL((SELECT TOP 1 1 FROM URETIMRECETE UR WHERE UR.STOKID = S.ID), 0)
        ' + @SelectList + N'
    FROM STOKLAR S
        LEFT OUTER JOIN KATEGORI K ON K.ID = S.KATEGORI '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join (unique KULID,MODUL,KAYITID)
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = S.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';

    -- Pasif: kapaliyken sadece aktif
    IF @Pasif = 0
        SET @SQL = @SQL + N' AND S.DURUM = 1 ';

    -- Sube yetkisi (SubeVarmi ise app @SubeYetkiList gonderir)
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND S.SUBEID IN (0,' + @SubeYetkiList + N') ';

    -- @Mod=2: Cok Kullanilanlar (GENINI bolumundeki kodlar) - EXISTS
    IF @Mod = 2 AND @CokKullanBolum IS NOT NULL
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM GENINI G
                                         WHERE G.BOLUM = ' + CAST(@CokKullanBolum AS NVARCHAR(20)) + N'
                                           AND G.ANAHTAR = S.KOD AND G.DIL = -1) ';

    -- Metin filtreleri (parametreli)
    IF @StokAdi IS NOT NULL AND @StokAdi <> N''
        SET @SQL = @SQL + N' AND S.STOKADI LIKE N''%'' + @pStokAdi + N''%'' ';
    IF @Kod IS NOT NULL AND @Kod <> N''
        SET @SQL = @SQL + N' AND (S.KOD LIKE N''%'' + @pKod + N''%'' OR S.URUNNO LIKE N''%'' + @pKod + N''%'') ';

    -- Sayisal filtreler (guvenli - int cast)
    IF @KategoriID IS NOT NULL AND @KategoriID > 0
        SET @SQL = @SQL + N' AND S.KATEGORI = ' + CAST(@KategoriID AS NVARCHAR(20)) + N' ';
    IF @MarkaID IS NOT NULL AND @MarkaID > 0
        SET @SQL = @SQL + N' AND S.MARKA = ' + CAST(@MarkaID AS NVARCHAR(20)) + N' ';
    IF @ModelID IS NOT NULL AND @ModelID > 0
        SET @SQL = @SQL + N' AND S.MODEL = ' + CAST(@ModelID AS NVARCHAR(20)) + N' ';
    IF @GrubuID IS NOT NULL AND @GrubuID > 0
        SET @SQL = @SQL + N' AND S.GRUBU = ' + CAST(@GrubuID AS NVARCHAR(20)) + N' ';
    IF @SubeID IS NOT NULL AND @SubeID < 1
        SET @SQL = @SQL + N' AND S.SUBEID = ' + CAST(@SubeID AS NVARCHAR(20)) + N' ';

    -- Barkod: JOIN yerine EXISTS (group by gerektirmez)
    IF @Barkod IS NOT NULL AND @Barkod <> N''
    BEGIN
        IF UPPER(@Barkod) = N'NULL'
            SET @SQL = @SQL + N' AND NOT EXISTS (SELECT 1 FROM STOKBARKOD SB WHERE SB.STOKID = S.ID) ';
        ELSE IF UPPER(@Barkod) = N'NOT NULL'
            SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM STOKBARKOD SB WHERE SB.STOKID = S.ID) ';
        ELSE
            SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM STOKBARKOD SB WHERE SB.STOKID = S.ID AND SB.BARKOD LIKE @pBarkod + N''%'') ';
    END;

    -- Son/Sik aranan siralamasi (KULLANICI_ARAMA)
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pStokAdi NVARCHAR(150), @pKod NVARCHAR(50), @pBarkod NVARCHAR(50)',
         @pStokAdi = @StokAdi, @pKod = @Kod, @pBarkod = @Barkod;
END;
