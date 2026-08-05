-- ============================================================
-- sp_Prog_AlisSatis_IrsFatFisKons_Json2 - Fatura/Irsaliye/Fis liste (2 PARAM JSON, SELF-CONTAINED)
--   TEK SP (wrapper YOK): @Kosullar JSON'i cozup isi KENDI icinde yapar.
--   @Baslik = SELECT ek kolonlari (eski @SelectList, app-uretimi/GUVENILIR).
--   @Kosullar ornek: '{"TopN":200,"Tur":14,"StartDate":"2026-07-01T00:00:00",
--     "EndDate":"2026-07-31T23:59:59","SubeIDList":"-1,0,1","Faturano":"",
--     "Baslik":"","CariFirma":"","Aciklama":"","Stok":""}'
-- ============================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_Prog_AlisSatis_IrsFatFisKons_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (=eski @SelectList)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON)
AS
BEGIN
    SET NOCOUNT ON;

    -- @Kosullar (JSON filtreler) -> yerel degiskenler. @Baslik param'i = eski @SelectList
    -- (SELECT ek kolonlari, app-uretimi). Arama '$.Baslik' -> @AraBaslik (eski @Baslik).
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 100);
    DECLARE @Tur        SMALLINT      = TRY_CAST(JSON_VALUE(@Kosullar,'$.Tur') AS SMALLINT);
    DECLARE @StartDate  DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.StartDate') AS DATETIME);
    DECLARE @EndDate    DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.EndDate') AS DATETIME);
    DECLARE @SubeIDList NVARCHAR(MAX) = ISNULL(JSON_VALUE(@Kosullar,'$.SubeIDList'), N'');
    DECLARE @Faturano   NVARCHAR(100) = ISNULL(JSON_VALUE(@Kosullar,'$.Faturano'),  N'');
    DECLARE @AraBaslik  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Baslik'),    N'');
    DECLARE @CariFirma  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.CariFirma'), N'');
    DECLARE @Aciklama   NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Aciklama'),  N'');
    DECLARE @Stok       NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Stok'),      N'');

CREATE TABLE #SubeIDs (ID SMALLINT);



    IF (@SubeIDList IS NOT NULL) AND (@SubeIDList <> '')

    BEGIN

        INSERT INTO #SubeIDs

        SELECT TRY_CAST(value AS SMALLINT)

        FROM dbo.fn_SplitString(@SubeIDList, ',')

        WHERE TRY_CAST(value AS SMALLINT) IS NOT NULL;

    END;



    -- Stok filtresi FATURA/STOKLAR detay JOIN'i ekler (baslik basina COK satir) -> yalniz
    -- o durumda DISTINCT gerekir. DISTINCT tum kolonlar uzerinde sort/hash demek: TAM
    -- listede (TopN=0) 50 bin genis satirda buyuk bellek grant'i ister ve SQL Express'te
    -- RESOURCE_SEMAPHORE'da sonsuz bekler (ekran kilitlenir). Diger dallarda kaldirildi.
    DECLARE @StokJoin BIT = CASE WHEN @Stok IS NOT NULL AND @Stok <> '' AND @Stok <> 'ALL'
                                 THEN 1 ELSE 0 END;

    DECLARE @SQL NVARCHAR(MAX) = '

    SELECT ' + CASE WHEN @StokJoin = 1 THEN N'DISTINCT ' ELSE N'' END
             + CASE WHEN @TopN > 0                              -- TopN=0 => TOP yok (TAM liste)
                             THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                             ELSE N'' END + '

    F.ID,F.DURUM,F.ODEMEPLANI,F.FATURATARIH,F.FATURANO,F.FATURASERI,F.TIPI,F.SENARYO,F.REHBERID,F.TUR,F.SUBEID,F.SANAL,F.BASLIK, FATURA_MATRAHI, 

    KDV_TUTARI, FATURA_TUTARI, F.KUR,

    FATURA_MALIYETI_ORT, ORTKARORAN=round((FATURA_MATRAHI-FATURA_MALIYETI_ORT)/nullif(FATURA_MALIYETI_ORT,0)*100.0,2),

    ORTKAR=FATURA_MATRAHI-FATURA_MALIYETI_ORT, F.ACIKLAMA,F.OZELKOD,F.OZELKOD2, 

CARIKOD=R.KOD,CARIAD=R.FIRMA,DOVIZ_CINSI=F.RAPORDOVIZ,DOVIZKUR,F.DOVIZ_TUTARI,

    DOVIZ_FATURA_MATRAHI=isnull((F.DOVIZ_TUTARI-F.DOVIZ_TUTARI*(convert(float,KDV_TUTARI)/nullif(convert(float,FATURA_TUTARI),0))),0),

    DOVIZ_KDV_TUTARI=isnull((F.DOVIZ_TUTARI*(convert(float,KDV_TUTARI)/nullif(convert(float,FATURA_TUTARI),0)) ),0), F.GIRISDEPO,F.CIKISDEPO,

    CIKISDEPOADI = case when F.TUR in (10,11,12,109) then DGIR.DEPOADI else DCIK.DEPOADI end, F.IRSALIYENO,

    F.SATICIKODU,F.DETAYBOLUMU, SATICIADI = SATICIBILGI.FIRMA,F.VADE, VADETARIH=FATURATARIH + F.VADE,

    DURUMNEREDEN = case

        when exists(select F2.ID from SIPARISDETAY F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (406,407,409,410,429,473) and 

F1.FATBASID=F.ID)) then ''Siparişten''

        when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (408,410,411,424,427) and

        F1.FATBASID=F.ID)) then ''İrsaliyeden''

        when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (461,462,464,468,472) and

        F1.FATBASID=F.ID)) then ''Konsinyeden''

        when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (425,426) and F1.FATBASID=F.ID)) then 

''Üretimden''

        else ''''

    end,

    DURUMNEREYE = case

        when (F.TUR=10) and (408 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''

        when (F.TUR=10) and (427 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Fişe''

        when (F.TUR=14) and (411 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''

        when (F.TUR=14) and (424 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Fişe''

        when (F.TUR=109) and (461 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''

        when (F.TUR=119) and (462 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''

        when (F.TUR=119) and (468 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''İrsaliyeye''

        when (F.TUR=119) and (472 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Fişe''

        else ''''

    end,

    TESLIMTARIHI='''',F.FATURA_GON_TARIHI, F.ZARFID,

    ZARF=(select AD from BELGEZARFI B where B.ID=F.ZARFID),

    ISEMRIDURUM=isnull((select I.DURUM from ISEMRI I where I.YERI=F.TUR and I.YERID=F.ID),-1),

    F.YAZDIRILDI, ONAYLAYACAK=0, ONAYLAYAN=0, EFATURADURUM, EFATURASONUC ' + ISNULL(@Baslik, '') + '

FROM FATBASLIK F WITH (NOLOCK)

    INNER JOIN REHBER R ON R.ID = F.REHBERID


    LEFT JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID

    LEFT JOIN DEPOLAR DCIK ON DCIK.ID=F.CIKISDEPO

    LEFT JOIN DEPOLAR DGIR ON DGIR.ID=F.GIRISDEPO';



    IF @Stok IS NOT NULL AND @Stok <> '' AND @Stok <> 'ALL'

        SET @SQL += '

    LEFT JOIN FATURA FT ON FT.FATBASID = F.ID

    LEFT JOIN STOKLAR ST ON FT.URUNID = ST.ID';



    SET @SQL += '  WHERE F.TUR = @Tur';



    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL AND @StartDate <> '' AND @EndDate <> ''

        SET @SQL += ' AND F.FATURATARIH BETWEEN @StartDate AND @EndDate';



    IF @SubeIDList IS NOT NULL AND @SubeIDList <> ''

        SET @SQL += ' AND EXISTS (SELECT 1 FROM #SubeIDs S WHERE S.ID = F.SUBEID)';



    IF @Faturano IS NOT NULL AND @Faturano <> '' AND @Faturano <> 'ALL'

        SET @SQL += ' AND F.FATURANO LIKE ''%'' + @Faturano + ''%''';



    IF @AraBaslik IS NOT NULL AND @AraBaslik <> '' AND @AraBaslik <> 'ALL'

        SET @SQL += ' AND F.BASLIK LIKE ''%'' + @AraBaslik + ''%''';



    IF @CariFirma IS NOT NULL AND @CariFirma <> '' AND @CariFirma <> 'ALL'

        -- REHBERBILGI eskiden LEFT JOIN idi: ayni cariye ait birden cok "Fatura Başlığı"
        -- satiri baslik satirini COGALTIR (bu yuzden DISTINCT gerekiyordu). EXISTS ile
        -- cogaltma yok, join yalniz bu filtre kullanildiginda calisir.
        SET @SQL += ' AND (R.FIRMA LIKE ''%'' + @CariFirma + ''%'' OR F.BASLIK LIKE ''%'' + @CariFirma + ''%''
                       OR EXISTS (SELECT 1 FROM REHBERBILGI RB WITH (NOLOCK)
                                  WHERE RB.YER_ID = R.ID AND RB.YERI = 2
                                    AND RB.ETIKET = ''Fatura Başlığı''
                                    AND ISNULL(RB.BILGI,'''') <> ''''
                                    AND RB.BILGI LIKE ''%'' + @CariFirma + ''%''))';



    IF @Aciklama IS NOT NULL AND @Aciklama <> '' AND @Aciklama <> 'ALL'

        SET @SQL += ' AND F.ACIKLAMA LIKE ''%'' + @Aciklama + ''%''';



    IF @Stok IS NOT NULL AND @Stok <> '' AND @Stok <> 'ALL'

    BEGIN

        SET @SQL += ' AND (ST.STOKADI LIKE ''%'' + @Stok + ''%''';

        SET @SQL += ' OR ST.KOD LIKE ''%'' + @Stok + ''%''';

        SET @SQL += ' OR ST.URUNNO LIKE ''%'' + @Stok + ''%'')';

    END;



    SET @SQL += ' ORDER BY F.FATURATARIH DESC';



    EXEC sp_executesql

        @SQL,

        N'@Tur SMALLINT, @StartDate DATETIME, @EndDate DATETIME, @Faturano NVARCHAR(100), @AraBaslik NVARCHAR(200), @CariFirma NVARCHAR(200), @Aciklama NVARCHAR(200), @Stok NVARCHAR(200)',

        @Tur, @StartDate, @EndDate, @Faturano, @AraBaslik, @CariFirma, @Aciklama, @Stok;



    DROP TABLE #SubeIDs;
END
