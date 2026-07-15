-- ============================================================
-- sp_Prog_Gorev_Liste — Gorev (Is Listesi) arama ekrani sunucu-tarafi listeleme
--   UGorevListeDlg.GorevArama'nin (SQLGorevMemo + string-concat filtreler) SP karsiligi.
--   Stok pilotunun (sp_Prog_Stok_Liste) deseni: dinamik SQL, parametreli metin filtreleri
--   (plan reuse + enjeksiyon guvenli), sayisal filtreler int-cast ile.
--   SELECT listesi SQLGorevMemo ile BIREBIR (grid kolon paritesi icin).
--   @Mod: 1=Tum, 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.DEGISTIRMETARIHI)
--   @Pasif: 0=sadece acik (G.ACKAPA=0, CheckTamamlanan kapali), 1=hepsi (tamamlananlar dahil)
--   @SelectList: ek (ozel) alanlar - app gorunur kolonlardan ',[Cap]=Field,...' uretir
--
--   Not: SQLGorevMemo'daki LEFT JOIN GOREVYORUM 1:cok oldugundan orijinalde 'select distinct'
--   kullanilir; burada da SELECT DISTINCT. Son/Sik siralamasinda (DISTINCT + ORDER BY) KA
--   siralama kolonlari SELECT'e alias ile eklenir (aksi halde 5075/145 hatasi).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Gorev_Liste
    @SelectList   NVARCHAR(MAX) = N'',      -- ',[Cap]=Field,...' (ek alan SELECT)
    @TopN         INT           = 0,        -- 0 = TOP yok (Tum/Filtre); Son/Sik'te kayit sayisi
    @Mod          SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @Pasif        BIT           = 0,        -- 0=sadece acik (ACKAPA=0) 1=hepsi
    @Ara          NVARCHAR(200) = NULL,     -- KONUSU / GOREVYORUM.YORUM LIKE
    @Tarih        BIT           = 0,        -- checkTarih: BASLAMATARIHI araligi uygula
    @BasTarih     NVARCHAR(20)  = NULL,     -- 'yyyy-mm-dd'
    @BitTarih     NVARCHAR(20)  = NULL,     -- 'yyyy-mm-dd'
    @FirmaID      INT           = NULL,     -- G.REHBERID (AraFirma)
    @OlusturanID  INT           = NULL,     -- G.EKLEYEN (EditOlusturan)
    @AtananID     INT           = NULL,     -- GOREVKULLANICI.REHBERID (EditAtanan; GK join)
    @GorevID      INT           = NULL,     -- G.ID (EditID)
    @KulId        INT           = NULL,     -- @Mod=3/5 icin kullanici (KULLANICI_ARAMA)
    @Modul        INT           = NULL,     -- @Mod=3/5 icin MODUL (TabNo_GOREVLER=33)
    @OrderBy      NVARCHAR(200) = NULL      -- or. '3,2,G.EKLEYEN desc'; Son/Sik'te SP override
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    -- Son/Sik: DISTINCT + ORDER BY icin siralama kolonlari SELECT'e alias ile eklenir
    -- (KA join ile ayni kosul: KA yoksa kolonlara referans verilmez)
    DECLARE @SonSikCol NVARCHAR(120) = CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
                                            THEN N', KA.DEGISTIRMETARIHI AS SON_ARAMA, KA.SAY AS SIK_ARAMA '
                                            ELSE N'' END;

    SET @SQL = N'
    SELECT DISTINCT ' + @Top + N'
        G.ID, G.ACKAPA,
        LISTEID=G.LISTEID, LISTEADI=GL.ADI,
        G.KONUSU,
        TURU=(SELECT top 1 ANAHTAR FROM GENINI where BOLUM=-21044 and DIL=-1 and DEGER=G.TURU),
        G.EKLEYEN,
        G.REHBERID,CARIAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.REHBERID),
        MUS_ILGILI = (SELECT FIRMA FROM REHBER R WHERE R.ID=G.MUS_ILGILI),
        ATANAN1=(SELECT [dbo].[fn_GorevVerilenKisiler](11, G.ID)),
        G.BASLAMATARIHI,G.BITISTARIHI,
        TEKRAR_BIT=convert(bit, (CASE WHEN TEKRARID>0 THEN 1 ELSE 0 END)),
        ANIMSAT_BIT=convert(bit, (CASE WHEN ANIMSAT>0 THEN 1 ELSE 0 END)),
        G.BAYRAK, G.DURUM, G.EKLEMETARIHI,
        PROJEKODU=(SELECT PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID),
        EKLEYENAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN)
        ' + @SonSikCol + @SelectList + N'
    FROM GOREVLER G
        INNER JOIN GOREVLISTE GL on G.LISTEID=GL.ID
        LEFT JOIN GOREVYORUM GY ON G.ID=GY.GOREVID '
    -- @AtananID: GOREVKULLANICI join (orijinal SQLGorevMemo --GK yer tutucusu)
    + CASE WHEN @AtananID IS NOT NULL AND @AtananID > 0
           THEN N' LEFT JOIN GOREVKULLANICI GK ON GK.LISTGOREVID=G.ID and GK.TUR=11 '
           ELSE N'' END
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = G.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1=1 ';

    -- Pasif=0: sadece acik gorevler (CheckTamamlanan kapali -> ACKAPA=0)
    IF @Pasif = 0
        SET @SQL = @SQL + N' AND G.ACKAPA = 0 ';

    -- Metin arama (KONUSU / GOREVYORUM.YORUM) - parametreli
    IF @Ara IS NOT NULL AND @Ara <> N''
        SET @SQL = @SQL + N' AND (G.KONUSU LIKE N''%'' + @pAra + N''%'' OR GY.YORUM LIKE N''%'' + @pAra + N''%'') ';

    -- Tarih araligi (BASLAMATARIHI) - orijinaldeki > ve < ile birebir
    IF @Tarih = 1 AND @BasTarih IS NOT NULL AND @BitTarih IS NOT NULL
    BEGIN
        SET @SQL = @SQL + N' AND G.BASLAMATARIHI >''' + @BasTarih + N' 00:00'' ';
        SET @SQL = @SQL + N' AND G.BASLAMATARIHI <''' + @BitTarih + N' 23:59'' ';
    END;

    -- Sayisal filtreler (guvenli - int cast)
    IF @FirmaID IS NOT NULL AND @FirmaID > 0
        SET @SQL = @SQL + N' AND G.REHBERID = ' + CAST(@FirmaID AS NVARCHAR(20)) + N' ';
    IF @OlusturanID IS NOT NULL AND @OlusturanID > 0
        SET @SQL = @SQL + N' AND G.EKLEYEN = ' + CAST(@OlusturanID AS NVARCHAR(20)) + N' ';
    IF @AtananID IS NOT NULL AND @AtananID > 0
        SET @SQL = @SQL + N' AND GK.REHBERID = ' + CAST(@AtananID AS NVARCHAR(20)) + N' ';
    IF @GorevID IS NOT NULL AND @GorevID > 0
        SET @SQL = @SQL + N' AND G.ID = ' + CAST(@GorevID AS NVARCHAR(20)) + N' ';

    -- Son/Sik aranan siralamasi (KULLANICI_ARAMA); DISTINCT icin SELECT alias'lari
    IF @Mod = 5 SET @OrderBy = N'SON_ARAMA DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'SIK_ARAMA DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pAra NVARCHAR(200)',
         @pAra = @Ara;
END;
