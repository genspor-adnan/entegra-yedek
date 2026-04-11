CREATE OR ALTER PROCEDURE [dbo].[sp_Prog_AlisSatis_IrsFatFisKons]
    @SelectList NVARCHAR(MAX),
    @TopN INT = 100,
    @Tur SMALLINT,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @SubeIDList NVARCHAR(MAX) = NULL,
    @Faturano NVARCHAR(50) = NULL,
    @Baslik NVARCHAR(150) = NULL,
    @CariFirma NVARCHAR(100) = NULL,
    @Aciklama NVARCHAR(100) = NULL,
    @Stok NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #SubeIDs (ID SMALLINT);

    IF (@SubeIDList IS NOT NULL) AND (@SubeIDList <> '')
    BEGIN
        INSERT INTO #SubeIDs
        SELECT TRY_CAST(value AS SMALLINT)
        FROM dbo.fn_SplitString(@SubeIDList, ',')
        WHERE TRY_CAST(value AS SMALLINT) IS NOT NULL;
    END;

    DECLARE @SQL NVARCHAR(MAX) = '
    SELECT DISTINCT TOP (' + CAST(@TopN AS NVARCHAR(20)) + ') ' + '
    F.ID,F.DURUM,F.ODEMEPLANI,F.FATURATARIH,F.FATURANO,F.FATURASERI,F.TIPI,F.REHBERID,F.TUR,F.SUBEID,F.SANAL,F.BASLIK, FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI, F.KUR,
    FATURA_MALIYETI_ORT, ORTKARORAN=round((FATURA_MATRAHI-FATURA_MALIYETI_ORT)/nullif(FATURA_MALIYETI_ORT,0)*100.0,2),
    ORTKAR=FATURA_MATRAHI-FATURA_MALIYETI_ORT, F.ACIKLAMA,F.OZELKOD,F.OZELKOD2, CARIKOD=R.KOD,CARIAD=R.FIRMA,DOVIZ_CINSI=F.RAPORDOVIZ,DOVIZKUR,F.DOVIZ_TUTARI,
    DOVIZ_FATURA_MATRAHI=isnull((F.DOVIZ_TUTARI-F.DOVIZ_TUTARI*(convert(float,KDV_TUTARI)/nullif(convert(float,FATURA_TUTARI),0))),0),
    DOVIZ_KDV_TUTARI=isnull((F.DOVIZ_TUTARI*(convert(float,KDV_TUTARI)/nullif(convert(float,FATURA_TUTARI),0)) ),0), F.GIRISDEPO,F.CIKISDEPO,
    CIKISDEPOADI = case when F.TUR in (10,11,12,109) then DGIR.DEPOADI else DCIK.DEPOADI end, F.IRSALIYENO,
    F.SATICIKODU,F.DETAYBOLUMU, SATICIADI = SATICIBILGI.FIRMA,F.VADE, VADETARIH=FATURATARIH + F.VADE,
    DURUMNEREDEN = case
        when exists(select F2.ID from SIPARISDETAY F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (406,407,409,410,429,473) and F1.FATBASID=F.ID)) then ''Siparişten''
        when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (408,410,411,424,427) and F1.FATBASID=F.ID)) then ''İrsaliyeden''
        when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (461,462,464,468,472) and F1.FATBASID=F.ID)) then ''Konsinyeden''
        when exists(select F2.ID from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (425,426) and F1.FATBASID=F.ID)) then ''Üretimden''
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
    F.YAZDIRILDI, ONAYLAYACAK=0, ONAYLAYAN=0, EFATURADURUM ' + ISNULL(@SelectList, '') + '
FROM FATBASLIK F WITH (NOLOCK)
    INNER JOIN REHBER R ON R.ID = F.REHBERID
    LEFT JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID
    LEFT JOIN DEPOLAR DCIK ON DCIK.ID=F.CIKISDEPO
    LEFT JOIN DEPOLAR DGIR ON DGIR.ID=F.GIRISDEPO';

    IF @Stok IS NOT NULL AND @Stok <> '' AND @Stok <> 'ALL'
        SET @SQL += '
    LEFT JOIN FATURA FT ON FT.FATBASID = F.ID
    LEFT JOIN STOKLAR ST ON FT.URUNID = ST.ID';

    SET @SQL += '
    WHERE F.TUR = @Tur';

    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL AND @StartDate <> '' AND @EndDate <> ''
        SET @SQL += ' AND F.FATURATARIH BETWEEN @StartDate AND @EndDate';

    IF @SubeIDList IS NOT NULL AND @SubeIDList <> ''
        SET @SQL += ' AND EXISTS (SELECT 1 FROM #SubeIDs S WHERE S.ID = F.SUBEID)';

    IF @Faturano IS NOT NULL AND @Faturano <> 'ALL'
        SET @SQL += ' AND F.FATURANO LIKE ''%' + REPLACE(@Faturano, '''', '''''') + '%''';

    IF @Baslik IS NOT NULL AND @Baslik <> 'ALL'
        SET @SQL += ' AND F.BASLIK LIKE ''%' + REPLACE(@Baslik, '''', '''''') + '%''';

    IF @CariFirma IS NOT NULL AND @CariFirma <> 'ALL'
        SET @SQL += ' AND (R.FIRMA LIKE ''%' + REPLACE(@CariFirma, '''', '''''') + '%'' OR F.BASLIK LIKE ''%' + REPLACE(@CariFirma, '''', '''''') + '%'')';

    IF @Aciklama IS NOT NULL AND @Aciklama <> '' AND @Aciklama <> 'ALL'
        SET @SQL += ' AND F.ACIKLAMA LIKE ''%' + REPLACE(@Aciklama, '''', '''''') + '%''';

    IF @Stok IS NOT NULL AND @Stok <> '' AND @Stok <> 'ALL'
    BEGIN
        SET @SQL += ' AND (ST.STOKADI LIKE ''%' + REPLACE(@Stok, '''', '''''') + '%''';
        SET @SQL += ' OR ST.KOD LIKE ''%' + REPLACE(@Stok, '''', '''''') + '%''';
        SET @SQL += ' OR ST.URUNNO LIKE ''%' + REPLACE(@Stok, '''', '''''') + '%'')';
    END;

    SET @SQL += ' ORDER BY F.FATURATARIH DESC';

    EXEC sp_executesql
        @SQL,
        N'@Tur SMALLINT, @StartDate DATETIME, @EndDate DATETIME',
        @Tur, @StartDate, @EndDate;

    DROP TABLE #SubeIDs;
END
