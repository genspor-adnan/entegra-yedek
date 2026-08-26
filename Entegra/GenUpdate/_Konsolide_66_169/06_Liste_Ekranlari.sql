-- ======================================================================
-- KONSOLIDE UPDATE 06 - LISTE EKRANLARI (_Json2)
-- ======================================================================
-- 14 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- PROCEDURE: sp_prog_alissatis_irsfatfiskons_json2  (kaynak: GenDepoUpdate123) ----
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
    -- SON ARANAN: kullanicinin son actigi/kestigi belgeler (KULLANICI_ARAMA).
    --   Modul = belge turunun MODUL.MODULID'si (her belge turu AYRI liste),
    --   Kul   = kullanici ID. Ikisi de dolu ve SonAranan=1 ise liste bu kayitlara sinirlanir
    --   ve KULLANICI_ARAMA.DEGISTIRMETARIHI DESC siralanir (en son dokunulan en ustte).
    DECLARE @SonAranan  TINYINT       = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SonAranan') AS TINYINT), 0);  -- 0=Tumu 1=Son 2=Sik
    DECLARE @Modul      INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT), 0);
    DECLARE @Kul        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kul')   AS INT), 0);
    IF @Modul <= 0 OR @Kul <= 0 SET @SonAranan = 0;   -- eksik bilgi -> normal liste

    DECLARE @SubeIDList NVARCHAR(MAX) = ISNULL(JSON_VALUE(@Kosullar,'$.SubeIDList'), N'');
    DECLARE @Faturano   NVARCHAR(100) = ISNULL(JSON_VALUE(@Kosullar,'$.Faturano'),  N'');
    DECLARE @AraBaslik  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Baslik'),    N'');
    DECLARE @CariFirma  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.CariFirma'), N'');
    DECLARE @Aciklama   NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Aciklama'),  N'');
    DECLARE @Stok       NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Stok'),      N'');
    -- Belirli bir cariye ait belgeler (cari ekranindaki Alis/Satis alt sekmesi).
    --   @CariFirma cari ADI uzerinden LIKE arar; bu KIMLIK uzerinden kesin filtredir.
    DECLARE @RehberId   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.RehberId') AS INT);

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

    F.YAZDIRILDI, ONAYLAYACAK=0, ONAYLAYAN=0, EFATURADURUM, EFATURASONUC,
    -- SON/SIK ARANAN siralama kolonlari (KULLANICI_ARAMA). EN SONA eklenir: kolon SIRASI
    --   degismemeli, kod bazi yerlerde POZISYONEL erisiyor (Fields[0] = F.ID).
    SONERISIM = (SELECT MAX(KA.DEGISTIRMETARIHI) FROM KULLANICI_ARAMA KA
                  WHERE KA.KAYITID = F.ID AND KA.MODUL = @Modul AND KA.KULID = @Kul),
    ERISIMSAY = (SELECT MAX(KA.SAY) FROM KULLANICI_ARAMA KA
                  WHERE KA.KAYITID = F.ID AND KA.MODUL = @Modul AND KA.KULID = @Kul) ' + ISNULL(@Baslik, '') + '

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

    IF ISNULL(@RehberId, 0) > 0
        SET @SQL += ' AND F.REHBERID = ' + CAST(@RehberId AS NVARCHAR(20));



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



    -- Son Aranan modunda liste KULLANICI_ARAMA ile sinirlanir ve o tabloya gore siralanir.
    IF @SonAranan > 0
        SET @SQL += ' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA
                                   WHERE KA.KAYITID = F.ID AND KA.MODUL = @Modul AND KA.KULID = @Kul)';

    SET @SQL += ' ORDER BY F.FATURATARIH DESC';   -- Son/Sik siralamasi GRID'den yapilir



    EXEC sp_executesql

        @SQL,

        N'@Tur SMALLINT, @StartDate DATETIME, @EndDate DATETIME, @Faturano NVARCHAR(100), @AraBaslik NVARCHAR(200), @CariFirma NVARCHAR(200), @Aciklama NVARCHAR(200), @Stok NVARCHAR(200), @Modul INT, @Kul INT',

        @Tur, @StartDate, @EndDate, @Faturano, @AraBaslik, @CariFirma, @Aciklama, @Stok, @Modul, @Kul;



    DROP TABLE #SubeIDs;
END
GO

-- ---- PROCEDURE: sp_prog_alissatis_siparis_json2  (kaynak: GenDepoUpdate123) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_AlisSatis_Siparis_Json2
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
    -- SON ARANAN (KULLANICI_ARAMA): kullanicinin bu belge turunde son actigi/kestigi
    --   kayitlar. Modul = belge turunun MODUL.MODULID'si, Kul = kullanici ID.
    DECLARE @SonAranan  TINYINT       = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SonAranan') AS TINYINT), 0);  -- 0=Tumu 1=Son 2=Sik
    DECLARE @Modul      INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT), 0);
    DECLARE @Kul        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kul')   AS INT), 0);
    IF @Modul <= 0 OR @Kul <= 0 SET @SonAranan = 0;

    DECLARE @SubeIDList NVARCHAR(MAX) = ISNULL(JSON_VALUE(@Kosullar,'$.SubeIDList'), N'');
    DECLARE @Faturano   NVARCHAR(100) = ISNULL(JSON_VALUE(@Kosullar,'$.Faturano'),  N'');
    DECLARE @AraBaslik  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Baslik'),    N'');
    DECLARE @CariFirma  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.CariFirma'), N'');
    DECLARE @Aciklama   NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Aciklama'),  N'');
    DECLARE @Stok       NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Stok'),      N'');
    -- Belirli bir cariye ait belgeler (cari ekranindaki Alis/Satis alt sekmesi).
    --   @CariFirma cari ADI uzerinden LIKE arar; bu KIMLIK uzerinden kesin filtredir.
    DECLARE @RehberId   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.RehberId') AS INT);

CREATE TABLE #SubeIDs (ID SMALLINT);
    IF @SubeIDList IS NOT NULL  AND @SubeIDList <> ''
    BEGIN
        INSERT INTO #SubeIDs
        SELECT TRY_CAST(value AS SMALLINT)
        FROM dbo.fn_SplitString(@SubeIDList, ',')
        WHERE TRY_CAST(value AS SMALLINT) IS NOT NULL;
    END

    DECLARE @BaseSelect NVARCHAR(MAX) = '
F.ID,F.DURUM,F.ODEMEPLANI,FATURATARIH=SIPARISTARIH,FATURANO=SIPARISNO,FATURASERI=F.SIPARISSERI,F.TIPI,SENARYO=CAST(NULL AS smallint),F.REHBERID,F.TUR,F.SUBEID,F.BASLIK, FATURA_MATRAHI=SIPARIS_TUTARI-KDV_TUTARI, 
KDV_TUTARI,FATURA_TUTARI=SIPARIS_TUTARI,F.KUR,KURFATURA_MALIYETI_ORT=0.0,ORTKARORAN=0.0, ORTKAR=0.0  
,F.ACIKLAMA,F.OZELKOD,F.OZELKOD2,CARIKOD=R.KOD,CARIAD=R.FIRMA,DOVIZ_CINSI=F.RAPORDOVIZ,F.DOVIZKUR,DOVIZ_TUTARI=(SIPARIS_TUTARI/nullif(DOVIZKUR,0.0)),  
DOVIZ_FATURA_MATRAHI=((SIPARIS_TUTARI-KDV_TUTARI)/nullif(DOVIZKUR,0.0)),DOVIZ_KDV_TUTARI=(convert(float,KDV_TUTARI)/nullif(convert(float,DOVIZKUR),0.0))  
,F.GIRISDEPO,F.CIKISDEPO,CIKISDEPOADI = D.DEPOADI,
F.IRSALIYENO , F.SATICIKODU,F.DETAYBOLUMU, SATICIADI = SATICIBILGI.FIRMA, F.VADE, VADETARIH=SIPARISTARIH + F.VADE,  



DURUMNEREDEN = case     when (F.TUR=9)and(412 in 
(select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Teklifden''     when (F.TUR=19)and(413 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Teklifden''    when 
(F.TUR=9)and(83 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Servisden''     when (F.TUR=19)and(83 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then 
''Servisden''    when (F.TUR=9)and(428 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Talepten''    when (F.TUR=101)and(465 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Üretimden''    else '''' end,   DURUMNEREYE = case  	when (F.TUR=9)and(407 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''     	when (F.TUR=9)and(406 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye''   	when (F.TUR=101)and(428 in (select YERI from SIPARISDETAY where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Siparişe''   	when (F.TUR=19)and(410 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''    	when (F.TUR=19)and(409 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye''    when (F.TUR=19)and(473 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Fişe''     	when (F.TUR=19)and(429 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Konsinyeye''  	when (F.TUR=19)and(415 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine''  	when (F.TUR=19)and(420 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine''  	else '''' end,     TESLIMTARIHI =(Select Min(TESLIMTARIHI) from SIPARISDETAY Where SIPARISID=F.ID ), FATURA_GON_TARIHI=null,  ZARFID=null,ZARF=null,ISEMRIDURUM=isnull((select I.DURUM from ISEMRI I where I.YERI=F.TUR and I.YERID=F.ID),-1),F.YAZDIRILDI,  F.ONAYLAYACAK,F.ONAYLAYAN,EFATURADURUM=0,
-- SON/SIK ARANAN siralama kolonlari (KULLANICI_ARAMA). EN SONA eklenir: kolon SIRASI
--   degismemeli, kod bazi yerlerde POZISYONEL erisiyor (Fields[0] = F.ID).
SONERISIM = (SELECT MAX(KA.DEGISTIRMETARIHI) FROM KULLANICI_ARAMA KA
              WHERE KA.KAYITID = F.ID AND KA.MODUL = @Modul AND KA.KULID = @Kul),
ERISIMSAY = (SELECT MAX(KA.SAY) FROM KULLANICI_ARAMA KA
              WHERE KA.KAYITID = F.ID AND KA.MODUL = @Modul AND KA.KULID = @Kul) ';

    -- SIPARISDETAY/STOKLAR JOIN'i YALNIZ stok filtresi icin gerekli (SD./ST. baska yerde
    -- kullanilmiyor). Kosulsuz join baslik basina detay sayisi kadar satir uretiyor,
    -- DISTINCT de bunu tum kolonlar uzerinde sort/hash ile temizliyordu: TAM listede
    -- buyuk bellek grant'i -> SQL Express'te RESOURCE_SEMAPHORE beklemesi (ekran kilitlenir).
    DECLARE @StokJoin BIT = CASE WHEN @Stok IS NOT NULL AND @Stok <> '' AND @Stok <> 'ALL'
                                 THEN 1 ELSE 0 END;

    DECLARE @SQL NVARCHAR(MAX) = '
        SELECT ' + CASE WHEN @StokJoin = 1 THEN N'DISTINCT ' ELSE N'' END
                 + CASE WHEN @TopN > 0                          -- TopN=0 => TOP yok (TAM liste)
                                 THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                 ELSE N'' END + @BaseSelect +
        CASE WHEN @Baslik IS NOT NULL AND @Baslik <> '' THEN   @Baslik ELSE '' END + '
from SIPARIS F (NOLOCK) inner join REHBER R on R.ID = F.REHBERID  ' +
        CASE WHEN @StokJoin = 1 THEN '
INNER JOIN SIPARISDETAY SD ON F.ID = SD.SIPARISID
LEFT OUTER JOIN STOKLAR ST ON ST.ID = SD.URUNID ' ELSE '' END + '
LEFT OUTER JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID
LEFT OUTER JOIN DEPOLAR D ON D.ID=F.CIKISDEPO
        WHERE F.TUR = @Tur' +
        -- Eski INNER JOIN SIPARISDETAY detaysiz siparisleri listeden DUSURUYORDU;
        -- join kaldirildi, ayni suzmeyi cogaltmadan yapan EXISTS ile davranis korunur.
        CASE WHEN @StokJoin = 1 THEN ''
             ELSE ' AND EXISTS (SELECT 1 FROM SIPARISDETAY SD2 WITH (NOLOCK) WHERE SD2.SIPARISID = F.ID)'
        END;

    IF ISNULL(@RehberId, 0) > 0
        SET @SQL += ' AND F.REHBERID = ' + CAST(@RehberId AS NVARCHAR(20));


    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL and @StartDate <>'' AND @EndDate <> ''
        SET @SQL += ' AND F.SIPARISTARIH BETWEEN @StartDate AND @EndDate';

    IF (@SubeIDList IS NOT NULL)  AND (@SubeIDList <> '')
        SET @SQL += ' AND EXISTS (SELECT 1 FROM #SubeIDs X WHERE X.ID = F.SUBEID)';

    IF @Faturano IS NOT NULL AND @Faturano <> '' AND @Faturano <> 'ALL'
        SET @SQL += ' AND F.SIPARISNO LIKE ''%'' + @Faturano + ''%''';

    IF @AraBaslik IS NOT NULL AND @AraBaslik <> '' AND @AraBaslik <> 'ALL'
        SET @SQL += ' AND F.BASLIK LIKE ''%'' + @AraBaslik + ''%''';

    IF @CariFirma IS NOT NULL AND @CariFirma <> '' AND @CariFirma <> 'ALL'
        SET @SQL += ' AND R.FIRMA LIKE ''%'' + @CariFirma + ''%''';

    IF @Aciklama IS NOT NULL AND @Aciklama <> '' AND @Aciklama <> 'ALL'
        SET @SQL += ' AND F.ACIKLAMA LIKE ''%'' + @Aciklama + ''%''';

    IF @Stok IS NOT NULL AND @Stok <> '' AND @Stok <> 'ALL'
        SET @SQL += ' AND (ST.KOD LIKE ''%'' + @Stok + ''%'' 
                      OR ST.STOKADI LIKE ''%'' + @Stok + ''%'' 
                      OR ST.URUNNO LIKE ''%'' + @Stok + ''%'')';

    IF @SonAranan > 0
        SET @SQL += ' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA
                                   WHERE KA.KAYITID = F.ID AND KA.MODUL = @Modul AND KA.KULID = @Kul)';

    SET @SQL += ' ORDER BY F.SIPARISTARIH DESC';

    EXEC sp_executesql
        @SQL,
        N'@Tur SMALLINT, @StartDate DATETIME, @EndDate DATETIME, @Baslik NVARCHAR(MAX), @SubeIDList NVARCHAR(MAX),
          @Faturano NVARCHAR(50), @AraBaslik NVARCHAR(150), @CariFirma NVARCHAR(100), @Aciklama NVARCHAR(100), @Stok NVARCHAR(150), @Modul INT, @Kul INT',
        @Tur, @StartDate, @EndDate, @Baslik, @SubeIDList,
        @Faturano, @AraBaslik, @CariFirma, @Aciklama, @Stok, @Modul, @Kul;

    DROP TABLE #SubeIDs;
END
GO

-- ---- PROCEDURE: sp_prog_cari_liste_json2  (kaynak: GenDepoUpdate121) ----
-- ============================================================
-- GenDepoUpdate121.sql
-- sp_Prog_Cari_Liste_Json2 : Detay + Son/Sik Arananlar birlikte patliyordu
--
-- HATA (09.08.2026): Cari listede "Detay" isaretliyken "Son Arananlar"a
--   basilinca
--     The multi-part identifier "KA.DEGISTIRMETARIHI" could not be bound.
--
-- NEDEN: Detay (CRM) sarmalamasi sorguyu 'select * from ( ... ) as cc' icine
--   aliyor. Dis kapsamda KULLANICI_ARAMA takma adi (KA) YOK; KA kolonlari
--   select listesinde de yok (liste kolonlarini uygulama gonderiyor).
--   ORDER BY ise sarmalamadan sonra ekleniyor ve hala KA.* diyordu.
--
-- COZUM: sarmalanmis halde siralama iliskili alt sorguyla yapiliyor
--   (cc.ID uzerinden KULLANICI_ARAMA'ya bakarak). Sonuc kumesinin bicimi
--   DEGISMEZ - select listesine kolon eklenmedi.
--
-- Ayrica LATENT bir hata kapatildi: @KulId/@Modul NULL ise KA join'i hic
--   eklenmiyor ama ORDER BY KA.* yine yaziliyordu. O durumda artik
--   ORDER BY 1 kullaniliyor.
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Cari_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR = Paramst)
    @Kosullar NVARCHAR(MAX)             -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL (typed default korunur). ----
    DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @Variant       SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Variant')      AS SMALLINT), 0);
    DECLARE @TopN          INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')         AS INT), 200);
    DECLARE @Mod           SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')          AS SMALLINT), 4);
    DECLARE @IlgiliArama   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IlgiliArama')  AS BIT), 0);
    DECLARE @KulId         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId')        AS INT);
    DECLARE @Modul         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul')        AS INT), 22);
    DECLARE @CRM           BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CRM')          AS BIT), 0);
    DECLARE @AraFirma      NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.AraFirma');
    DECLARE @AraYetkili    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.AraYetkili');
    DECLARE @AraKod        NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.AraKod');
    DECLARE @AraOzelKod    NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.AraOzelKod');
    DECLARE @Arailler      NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Arailler');
    DECLARE @TemsilciAd    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.TemsilciAd');
    DECLARE @TemsilciID    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TemsilciID')   AS INT);
    DECLARE @GrupID        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GrupID')       AS INT);
    DECLARE @BolgeID       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.BolgeID')      AS INT);
    DECLARE @KategoriID    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KategoriID')   AS INT);
    DECLARE @SinifID       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SinifID')      AS INT);
    DECLARE @Pasifler      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasifler')     AS BIT), 0);
    DECLARE @AksiyonFrame  BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AksiyonFrame') AS BIT), 0);
    DECLARE @Potansiyel    BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Potansiyel')   AS BIT), 0);
    DECLARE @SubeList      NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeList');
    DECLARE @TekSubeTum    INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TekSubeTum')   AS INT), 0);
    DECLARE @SubeId        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeId')       AS INT);
    DECLARE @EkipmanFiltre BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.EkipmanFiltre') AS BIT), 0);
    DECLARE @AnalizWhere   SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AnalizWhere')  AS SMALLINT), 0);
    DECLARE @OrderCol      SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.OrderCol')     AS SMALLINT), 0);

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL   NVARCHAR(MAX);
    DECLARE @Top   NVARCHAR(30) = CASE WHEN @TopN > 0
                                       THEN N'top (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                       ELSE N'' END;
    DECLARE @BASTARIH DATETIME =
            CONVERT(VARCHAR(4), YEAR(GETDATE())) + '-01-01 00:00:00';

    -- --------- FROM iskeleti (iki base memo) -----------------
    IF @Variant = 1
    BEGIN
        -- SQLMemoBA: BORC/ALACAK/TAKIPTE/IRSALIYE toplama alt-sorgusu (app'teki DFM memosu ile birebir)
        SET @SQL = N'
    SELECT ' + @Top + @SelectList + N'
    FROM(
        select REHBERID,
               TOPLAM_BORC   = SUM(isnull(BORC,0)),
               TOPLAM_ALACAK = SUM(isnull(ALACAK,0)),
               TAKIPTE       = ABS(SUM(ISNULL(TAKIPTE,0))),
               IRSALIYE      = ABS(SUM(ISNULL(IRSALIYE,0))),
               KUR           = isnull(KUR,''TL'')
        from (
            SELECT REHBERID,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) AS BORC,
                   0 AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM FATBASLIK F
            WHERE isnull(F.DURUM,0)<>6 and (F.TUR in (15,16,17)) AND FATURATARIH >= @pBasTarih
            GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end
            UNION ALL
            SELECT FB.REHBERID, 0 AS BORC, 0 AS ALACAK,
                   CASE WHEN FB.EKSTREDEKULLAN = 1 THEN FB.DOVIZ_CINSI ELSE FB.KUR END AS KUR,
                   0 AS TAKIPTE,
                   CAST(SUM(CASE WHEN FB.EKSTREDEKULLAN = 1 THEN CASE WHEN F.DOVIZ_KURU <> ''TL'' THEN F.DOVIZ_BIRIMFIYAT * (1 - ISKONTO / 100.0) * (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * (1 + ISNULL(F.KDV, 10) / 100.0) ELSE ((F.ISKONTOLUBRMFIYAT * (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * (1 + ISNULL(F.KDV, 10) / 100.0)))/FB.DOVIZKUR END ELSE F.ISKONTOLUBRMFIYAT * (F.ADET - ISNULL(F1.FATURA_ADET, 0)) * (1 + ISNULL(F.KDV, 10) / 100.0) END) AS DECIMAL(18,2)) AS IRSALIYE
            FROM FATBASLIK FB
                 INNER JOIN FATURA F ON F.FATBASID = FB.ID
                 LEFT JOIN (SELECT YERID, SUM(ADET) AS FATURA_ADET FROM FATURA WHERE YERI IN (411,424) GROUP BY YERID ) F1 ON F1.YERID = F.ID
            WHERE ISNULL(FB.DURUM, 0) <> 6 AND FB.TUR = 14
            GROUP BY FB.REHBERID, FB.EKSTREDEKULLAN,FB.DOVIZ_CINSI,FB.KUR
            UNION ALL
            SELECT REHBERID, 0 AS BORC,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) AS FATURA_ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM FATBASLIK F
            WHERE isnull(F.DURUM,0)<>6 and (F.TUR in (8,11,12,13)) AND FATURATARIH >= @pBasTarih
            GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end
            UNION ALL
            SELECT REHBERID,
                   SUM(case when ISNULL(K.BORC,0)>0 and EKSTREDEKULLAN=1 then K.DOVIZ_TUTARI else K.BORC end) AS BORC,
                   SUM(case when ISNULL(K.ALACAK,0)>0 and EKSTREDEKULLAN=1 then K.DOVIZ_TUTARI else K.ALACAK end) AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM KASA K
            WHERE TUR not between 60 and 79 AND ISLEMTARIHI >= @pBasTarih
            GROUP BY K.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end
            UNION ALL
            SELECT CH.REHBERID,
                   BORC   = sum(Case when CH.ISLEM in(140,131,132,133,134,137) then (case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TUTAR,0)end) else 0 end),
                   ALACAK = sum(Case when CH.ISLEM in(130,141) then (case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else isnull(C.TUTAR,0)end) else 0 end),
                   KUR    = case when CH.EKSTREDEKULLAN=1 then CH.KUR else isnull(C.KUR,''TL'')end,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID
            WHERE CH.ISLEM in(130,131,132,134,137,140,141) and CH.TARIH >= @pBasTarih
            GROUP BY CH.REHBERID,CH.ISLEM,CH.EKSTREDEKULLAN,case when CH.EKSTREDEKULLAN=1 then CH.KUR else isnull(C.KUR,''TL'')end
            UNION ALL
            SELECT C.REHBERID, BORC = 0, ALACAK = 0,
                   KUR = case when C.EKSTREDEKULLAN=1 then C.DOVIZ_KURU else isnull(C.KUR,''TL'') end,
                   TAKIPTE = SUM(Case when C.TUR in(131,132,133,134,137) then (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end)-sum(Case when C.TUR in(130) then (case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end),
                   IRSALIYE = 0
            FROM CEKLER C
            WHERE C.CEKSENET IN (101,121) AND C.TUR IN (130,131,132,133,134,135,138)
                  AND EXISTS(SELECT * FROM CEKHAREKET CH WHERE CH.CEKSENETLERID = C.ID)
            GROUP BY C.REHBERID,C.EKSTREDEKULLAN,C.DOVIZ_KURU,isnull(C.KUR,''TL'')
            UNION ALL
            SELECT REHBERID, 0 AS BORC,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TUTARI ELSE TUTAR END) AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM SENETLER S
            WHERE TUR = 24 AND TARIH >= @pBasTarih
            GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR END
            UNION ALL
            SELECT REHBERID,
                   SUM(CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_TUTARI ELSE TUTAR END) AS BORC,
                   0 AS ALACAK,
                   CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end as KUR,
                   TAKIPTE = 0, IRSALIYE = 0
            FROM SENETLER S
            WHERE TUR = 34 AND TARIH >= @pBasTarih
            GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN S.DOVIZ_KURU else KUR end
        ) as asd
        group by REHBERID,KUR
    ) AS DSA
        INNER JOIN REHBER R ON DSA.REHBERID=R.ID
         left outer join REHBER P on R.ID = P.BAGID and
             1 = CASE WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 1 THEN 1
                      WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 0 AND isnull(P.STATU,1) = 1 THEN 1
                      ELSE 0 END ';
    END
    ELSE
    BEGIN
        -- SQLMemo: normal. P join = ilgili (yetkili) arama; @IlgiliArama app'te Param.
        SET @SQL = N'
    SELECT ' + @Top + @SelectList + N'
    FROM REHBER R
         left outer join REHBER P on R.ID = P.BAGID and
             1 = CASE WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 1 THEN 1
                      WHEN ' + CAST(@IlgiliArama AS NVARCHAR(2)) + N' = 0 AND isnull(P.STATU,1) = 1 THEN 1
                      ELSE 0 END ';
    END;

    -- --------- ortak trailing join'ler (SorguyaTabloEkle) ----
    SET @SQL = @SQL + N'
        LEFT OUTER JOIN REHBER R2 WITH (NOLOCK) ON R2.ID = R.TEMSILCI
        OUTER APPLY ( SELECT top 1 RB.BILGI FROM REHBERBILGI RB WITH (NOLOCK)
                      INNER JOIN REHBERAYAR RA WITH (NOLOCK) ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10
                      WHERE RB.YER_ID = R.ID ) X1 ';

    -- @Mod=3/5: Son/Sik -> KULLANICI_ARAMA inner join (MODUL bazli, 1:1 unique KULID,MODUL,KAYITID)
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
        SET @SQL = @SQL + N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = R.ID AND KA.KULID = '
                 + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' ';

    -- --------- ortak WHERE cekirdegi (SorguyaTabloEkle) ------
    SET @SQL = @SQL + N' where R.GRUP<>334 and R.GRUP<>335 and R.ID > 1 ';

    -- --------- @Mod bazli WHERE alt-kumeleri -----------------
    IF @Mod = 4
    BEGIN
        -- JvTimer1Timer: tum arama kutulari
        IF @AraFirma IS NOT NULL AND @AraFirma <> N''
            SET @SQL = @SQL + N' and ( R.FIRMA LIKE N''%'' + @pFirma + N''%'' OR X1.BILGI LIKE N''%'' + @pFirma + N''%'' ) ';
        IF @AraYetkili IS NOT NULL AND @AraYetkili <> N''
            SET @SQL = @SQL + N' and P.FIRMA LIKE N''%'' + @pYetkili + N''%'' ';
        IF @AraKod IS NOT NULL AND @AraKod <> N''
            SET @SQL = @SQL + N' and R.KOD LIKE N''%'' + @pKod + N''%'' ';

        IF @AksiyonFrame = 1 AND @Potansiyel = 0
            SET @SQL = @SQL + N' and R.GRUP = 1 ';
        ELSE
        BEGIN
            IF @GrupID IS NOT NULL AND @GrupID > 0
                SET @SQL = @SQL + N' and R.GRUP = ' + CAST(@GrupID AS NVARCHAR(20)) + N' ';
            ELSE
                SET @SQL = @SQL + N' and R.GRUP<>334 and R.GRUP<>335 ';
            IF @Potansiyel = 0
                SET @SQL = @SQL + N' and R.GRUP > 1 ';
        END;

        IF @BolgeID IS NOT NULL AND @BolgeID > 0
            SET @SQL = @SQL + N' and R.BOLGE = ' + CAST(@BolgeID AS NVARCHAR(20)) + N' ';
        IF @Arailler IS NOT NULL AND @Arailler <> N''
            SET @SQL = @SQL + N' and X1.BILGI = @pIller ';   -- eski kodda X.BILGI (X join yoktu=latent bug); X1'e maplendi
        IF @TemsilciAd IS NOT NULL AND @TemsilciAd <> N''
        BEGIN
            IF @TemsilciID IS NOT NULL AND @TemsilciID > 0
                SET @SQL = @SQL + N' and R.TEMSILCI = ' + CAST(@TemsilciID AS NVARCHAR(20)) + N' ';
            ELSE
                SET @SQL = @SQL + N' and R2.FIRMA like @pTemsilci + N''%'' ';
        END;
        IF @Pasifler = 0
            SET @SQL = @SQL + N' and R.DURUM > 0 ';
        IF @SubeList IS NOT NULL AND @SubeList <> N''
            SET @SQL = @SQL + N' and R.SUBEID in(' + @SubeList + N') ';
        IF @KategoriID IS NOT NULL AND @KategoriID > 0
            SET @SQL = @SQL + N' and R.KATEGORI = ' + CAST(@KategoriID AS NVARCHAR(20)) + N' ';
        IF @SinifID IS NOT NULL AND @SinifID > 0
            SET @SQL = @SQL + N' and R.SINIF = ' + CAST(@SinifID AS NVARCHAR(20)) + N' ';
        IF @AraOzelKod IS NOT NULL AND @AraOzelKod <> N''
            SET @SQL = @SQL + N' and R.OZELKOD like @pOzelKod + N''%'' ';
        IF @TekSubeTum = 1
            SET @SQL = @SQL + N' AND R.TEMSILCI = ' + CAST(ISNULL(@KulId,0) AS NVARCHAR(20)) + N' ';
        ELSE IF @TekSubeTum = 10
            SET @SQL = @SQL + N' AND R.SUBEID = ' + CAST(ISNULL(@SubeId,0) AS NVARCHAR(20)) + N' ';
        IF @EkipmanFiltre = 1
            SET @SQL = @SQL + N' and R.ID in (select distinct REHBERID from EKIPMANREHBER) ';

        -- BA analiz where (ComboCariAnaliz 1..4)
        IF @AnalizWhere IN (1,3)
            SET @SQL = @SQL + N' and isnull(R.ID,'''')<>'''' and ((ISNULL(TOPLAM_BORC,0.0) - ISNULL(TOPLAM_ALACAK,0.0)) > 1.0 OR TAKIPTE > 1.0 OR IRSALIYE > 1.0) ';
        ELSE IF @AnalizWhere IN (2,4)
            SET @SQL = @SQL + N' and isnull(R.ID,'''')<>'''' and (ISNULL(TOPLAM_ALACAK,0.0) - ISNULL(TOPLAM_BORC,0.0)) > 1.0 ';
    END
    ELSE IF @Mod = 1
    BEGIN
        -- LabelTumKayitlarClick: TOP yok, sinirli filtre
        IF @Pasifler = 0
            SET @SQL = @SQL + N' and R.DURUM > 0 ';
        IF @SubeList IS NOT NULL AND @SubeList <> N''
            SET @SQL = @SQL + N' and R.SUBEID in(' + @SubeList + N') ';
        IF @AksiyonFrame = 1
            SET @SQL = @SQL + N' and R.GRUP = 1 ';
        ELSE
            SET @SQL = @SQL + N' and R.GRUP > 1 ';
        SET @SQL = @SQL + N' and R.GRUP <> 334 ';
    END
    ELSE IF @Mod IN (3, 5)
    BEGIN
        -- LabelSonArananlarClick / LabelSikArananlarClick: DURUM filtresi YOK (eski davranis)
        IF @SubeList IS NOT NULL AND @SubeList <> N''
            SET @SQL = @SQL + N' and R.SUBEID in(' + @SubeList + N') ';
        IF @AksiyonFrame = 1
            SET @SQL = @SQL + N' and R.GRUP = 1 ';
        ELSE
            SET @SQL = @SQL + N' and R.GRUP > 1 ';
        SET @SQL = @SQL + N' and R.GRUP <> 334 ';
    END;

    -- --------- CRM sarmalama (CheckDetay) --------------------
    IF @CRM = 1
        SET @SQL = N' select * from ( ' + @SQL + N' ) as cc ';

    -- --------- ORDER BY --------------------------------------
    -- CRM sarmalamasi (yukarida) sorguyu 'select * from (...) as cc' icine
    --   aliyor; dis kapsamda KA takma adi YOK ve KA kolonlari select
    --   listesinde de yok. Sarmalanmis halde KA.* ile siralamak
    --   "The multi-part identifier KA.DEGISTIRMETARIHI could not be bound"
    --   veriyordu (Cari liste + Detay + Son Arananlar, 09.08.2026).
    --   Sarmalanmissa siralama iliskili alt sorguyla yapilir (cc.ID uzerinden);
    --   sonuc kumesinin BICIMI DEGISMEZ.
    DECLARE @OrdSon NVARCHAR(MAX) = N'KA.DEGISTIRMETARIHI';
    DECLARE @OrdSik NVARCHAR(MAX) = N'KA.SAY';
    IF @CRM = 1 AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        DECLARE @KaFiltre NVARCHAR(200) =
            N' where KA2.KAYITID = cc.ID and KA2.KULID = ' + CAST(@KulId AS NVARCHAR(20)) +
            N' and KA2.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @OrdSon = N'(select KA2.DEGISTIRMETARIHI from KULLANICI_ARAMA KA2' + @KaFiltre;
        SET @OrdSik = N'(select KA2.SAY from KULLANICI_ARAMA KA2' + @KaFiltre;
    END;

    -- @KulId/@Modul yoksa KA join'i de eklenmemistir; KA ile siralamak patlar.
    IF @Mod = 5 AND (@KulId IS NULL OR @Modul IS NULL)
        SET @SQL = @SQL + N' ORDER BY 1 ';
    ELSE IF @Mod = 3 AND (@KulId IS NULL OR @Modul IS NULL)
        SET @SQL = @SQL + N' ORDER BY 1 ';
    ELSE IF @Mod = 5
        SET @SQL = @SQL + N' ORDER BY ' + @OrdSon + N' DESC ';
    ELSE IF @Mod = 3
        SET @SQL = @SQL + N' ORDER BY ' + @OrdSik + N' DESC ';
    ELSE IF @Mod = 1
        SET @SQL = @SQL + N' ORDER BY 1 ';
    ELSE IF @Mod = 4
    BEGIN
        IF @Variant = 1
            SET @SQL = @SQL + N' ORDER BY KUR ';
        ELSE IF @OrderCol = 1
            SET @SQL = @SQL + N' ORDER BY KOD ';
        ELSE
            SET @SQL = @SQL + N' ORDER BY FIRMA ';
    END;

    EXEC sp_executesql @SQL,
         N'@pFirma NVARCHAR(200), @pYetkili NVARCHAR(200), @pKod NVARCHAR(100), @pOzelKod NVARCHAR(100), @pIller NVARCHAR(200), @pTemsilci NVARCHAR(200), @pBasTarih DATETIME',
         @pFirma = @AraFirma, @pYetkili = @AraYetkili, @pKod = @AraKod, @pOzelKod = @AraOzelKod,
         @pIller = @Arailler, @pTemsilci = @TemsilciAd, @pBasTarih = @BASTARIH;
END;
GO

-- ---- PROCEDURE: sp_prog_demirbas_liste_json2  (kaynak: GenDepoUpdate86) ----
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
GO

-- ---- PROCEDURE: sp_prog_dokuman_liste_json2  (kaynak: GenDepoUpdate83) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Dokuman_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mod        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod') AS INT), 3);
    DECLARE @KlasorId   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KlasorId') AS INT);
    DECLARE @TabNo      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TabNo') AS INT);
    DECLARE @TamYetki   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TamYetki') AS BIT), 0);
    DECLARE @GD         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.GD') AS INT), 1);
    DECLARE @Kullanan   INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kullanan') AS INT), 0);
    DECLARE @AraDokuman NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraDokuman'), N'');
    DECLARE @AraKonu    NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraKonu'), N'');
    DECLARE @AraAnahtar NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraAnahtar'), N'');
    DECLARE @AraKurum   NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraKurum'), N'');
    DECLARE @AraSorumlu NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.AraSorumlu'), N'');
    DECLARE @AraLokasyon NVARCHAR(200)= NULLIF(JSON_VALUE(@Kosullar,'$.AraLokasyon'), N'');
    DECLARE @Bolum      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Bolum') AS INT);
    -- SON/SIK ARANAN (KULLANICI_ARAMA): 0 = kapali, 1 = Son (tarih), 2 = Sik (kullanim).
    --   Modul = MODUL_Dokuman (32), Kul = oturum kullanicisi. Eksikse otomatik kapanir.
    DECLARE @AramaModu    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AramaModu') AS INT), 0);
    DECLARE @AramaModulID INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul')     AS INT), 0);
    DECLARE @AramaKul     INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kul')       AS INT), 0);
    IF @AramaModulID <= 0 OR @AramaKul <= 0 SET @AramaModu = 0;

    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @Kategori   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Kategori') AS INT);
    DECLARE @Pasif      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @TarihVar   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihVar') AS BIT), 0);
    DECLARE @TarihBas   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);

    -- Bolum/Modul/Kategori: 0 => filtre yok (orijinal 'EditValue > 0' kosulu)
    IF @Bolum    = 0 SET @Bolum    = NULL;
    IF @Modul    = 0 SET @Modul    = NULL;
    IF @Kategori = 0 SET @Kategori = NULL;

    -- Klasor agaci BIR KEZ maddelestirilir. Onceki halde rekursif CTE dort ayri
    --   skaler alt sorguda (KLASORAD) referans ediliyordu; her referans plan
    --   tarafina index spool (worktable) koyup bellek grant'ini sisiriyordu.
    IF OBJECT_ID('tempdb..#Dizin') IS NOT NULL DROP TABLE #Dizin;
    ;WITH Dizin AS
    (
        SELECT ID, USTID, AD = CAST(AD AS NVARCHAR(260))
        FROM DOKUMANKLASOR
        WHERE USTID = 0
        UNION ALL
        SELECT A.ID, A.USTID, AD = CAST(V.AD + N'\' + A.AD AS NVARCHAR(260))
        FROM DOKUMANKLASOR A
        INNER JOIN Dizin V ON V.ID = A.USTID
    )
    SELECT ID, AD INTO #Dizin FROM Dizin OPTION (MAXRECURSION 0);
    CREATE UNIQUE CLUSTERED INDEX IX_Dizin ON #Dizin(ID);

    -- ---------- arm1: DTIP=1  (DOKUMAN D) ----------
    SELECT
        D.*, DTIP = 1, KISAYOLID = 0,
        Firma.FIRMA AS KURUM, Lokasyon.ACIKLAMA AS LOKASYONAD, Sorumlu.FIRMA AS SORUMLUAD,
        EXT = N'.' + I.BELGETURU, I.SURUM, I.BOYUT,
        KLASORAD      = (SELECT AD    FROM #Dizin WHERE ID = D.KLASOR),
        ONAYLAYACAKAD = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAYLAYACAK),
        ONAYLAYANAD   = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAY),
        EKLEYENAD     = (SELECT FIRMA FROM REHBER WHERE ID = D.EKLEYEN),
        DEGISTIRENAD  = (SELECT FIRMA FROM REHBER WHERE ID = D.DEGISTIREN),
        -- SON/SIK ARANAN siralama kolonlari (KULLANICI_ARAMA). ORDER BY YOK: siralama
        --   GRID'den yapilir (kullanicinin kayitli grid siralamasi bozulmasin). Bu kolonlar
        --   normal listede de dolar: "en son ne zaman actim / kac kez actim".
        SONERISIM = (SELECT MAX(KA.DEGISTIRMETARIHI) FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul),
        ERISIMSAY = (SELECT MAX(KA.SAY)              FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul)
    FROM DOKUMAN D
        INNER JOIN IMAJ I ON I.ID = (SELECT TOP 1 ID FROM IMAJ WHERE YERI = 1 AND YER_ID = D.ID ORDER BY ID DESC)
        LEFT OUTER JOIN REHBER   Firma    ON Firma.ID    = D.REHBERID
        LEFT OUTER JOIN LOKASYON Lokasyon ON Lokasyon.ID = D.LOKASYON
        LEFT OUTER JOIN REHBER   Sorumlu  ON Sorumlu.ID  = I.REHBERID
    WHERE (
        (   -- Mod=1 klasor-agac
            @Mod = 1
            AND D.KLASOR = @KlasorId
            AND ( @TamYetki = 1
                  OR ( D.GIZLILIKDERECESI <= @GD
                       AND EXISTS (SELECT 1 FROM DOKUMANYETKI DY
                                    WHERE DY.YERI = 321 AND DY.YERID = D.ID AND DY.GOR = 1
                                      AND (DY.REHBERID = 0 OR DY.REHBERID = @Kullanan)) ) )
        )
        OR
        (   -- Mod=2 arama-formu
            @Mod = 2
            AND (@AraDokuman  IS NULL OR D.AD             LIKE N'%' + @AraDokuman  + N'%')
            AND (@AraKonu     IS NULL OR D.KONU           LIKE N'%' + @AraKonu     + N'%')
            AND (@AraAnahtar  IS NULL OR D.ANAHTAR        LIKE N'%' + @AraAnahtar  + N'%')
            AND (@AraKurum    IS NULL OR Firma.FIRMA      LIKE N'%' + @AraKurum    + N'%')
            AND (@AraSorumlu  IS NULL OR Sorumlu.FIRMA    LIKE N'%' + @AraSorumlu  + N'%')
            AND (@AraLokasyon IS NULL OR Lokasyon.ACIKLAMA LIKE N'%' + @AraLokasyon + N'%')
            AND (@Bolum       IS NULL OR D.BOLUM    = @Bolum)
            AND (@Modul       IS NULL OR D.MODUL    = @Modul)
            AND (@Kategori    IS NULL OR D.KATEGORI = @Kategori)
            AND (@Pasif       = 1     OR D.DURUM    = 1)
            AND (@TamYetki    = 1     OR D.GIZLILIKDERECESI <= @GD)
            AND (@TarihVar    = 0     OR (D.TARIH >= @TarihBas AND D.TARIH <= @TarihBit))
        )
        OR @Mod = 3   -- Mod=3 tum-kayitlar
        )
        AND (@AramaModu = 0
             OR EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA
                         WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID
                           AND KA.KULID = @AramaKul))

    UNION ALL

    -- ---------- arm2: DTIP=0  (DOKUMANKISAYOL DK) ----------
    SELECT
        D.*, DTIP = 0, KISAYOLID = DK.ID,
        Firma.FIRMA AS KURUM, Lokasyon.ACIKLAMA AS LOKASYONAD, Sorumlu.FIRMA AS SORUMLUAD,
        EXT = CASE WHEN D.AD LIKE N'%.%'
                   THEN N'.' + REVERSE(SUBSTRING(REVERSE(ISNULL(D.AD, N'.')), 1,
                                CHARINDEX(N'.', REVERSE(ISNULL(D.AD, N'.')), 1) - 1))
                   ELSE N'' END,
        I.SURUM, I.BOYUT,
        KLASORAD      = (SELECT AD    FROM #Dizin WHERE ID = D.KLASOR),
        ONAYLAYACAKAD = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAYLAYACAK),
        ONAYLAYANAD   = (SELECT FIRMA FROM REHBER WHERE ID = I.ONAY),
        EKLEYENAD     = (SELECT FIRMA FROM REHBER WHERE ID = D.EKLEYEN),
        DEGISTIRENAD  = (SELECT FIRMA FROM REHBER WHERE ID = D.DEGISTIREN),
        -- SON/SIK ARANAN siralama kolonlari (KULLANICI_ARAMA). ORDER BY YOK: siralama
        --   GRID'den yapilir (kullanicinin kayitli grid siralamasi bozulmasin). Bu kolonlar
        --   normal listede de dolar: "en son ne zaman actim / kac kez actim".
        SONERISIM = (SELECT MAX(KA.DEGISTIRMETARIHI) FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul),
        ERISIMSAY = (SELECT MAX(KA.SAY)              FROM KULLANICI_ARAMA KA
                      WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID AND KA.KULID = @AramaKul)
    FROM DOKUMANKISAYOL DK
        INNER JOIN DOKUMAN D ON DK.DOKUMANID = D.ID
        INNER JOIN IMAJ I ON I.ID = (SELECT TOP 1 ID FROM IMAJ WHERE YERI = 1 AND YER_ID = D.ID ORDER BY ID DESC)
        LEFT OUTER JOIN REHBER   Firma    ON Firma.ID    = D.REHBERID
        LEFT OUTER JOIN LOKASYON Lokasyon ON Lokasyon.ID = D.LOKASYON
        LEFT OUTER JOIN REHBER   Sorumlu  ON Sorumlu.ID  = I.REHBERID
    WHERE (
        (   -- Mod=1 klasor-agac (arm2: kisayol yeri/yer_id)
            @Mod = 1
            AND DK.YER = @TabNo AND DK.YER_ID = @KlasorId
        )
        OR
        (   -- Mod=2 arama-formu (arm1 ile ayni filtre)
            @Mod = 2
            AND (@AraDokuman  IS NULL OR D.AD             LIKE N'%' + @AraDokuman  + N'%')
            AND (@AraKonu     IS NULL OR D.KONU           LIKE N'%' + @AraKonu     + N'%')
            AND (@AraAnahtar  IS NULL OR D.ANAHTAR        LIKE N'%' + @AraAnahtar  + N'%')
            AND (@AraKurum    IS NULL OR Firma.FIRMA      LIKE N'%' + @AraKurum    + N'%')
            AND (@AraSorumlu  IS NULL OR Sorumlu.FIRMA    LIKE N'%' + @AraSorumlu  + N'%')
            AND (@AraLokasyon IS NULL OR Lokasyon.ACIKLAMA LIKE N'%' + @AraLokasyon + N'%')
            AND (@Bolum       IS NULL OR D.BOLUM    = @Bolum)
            AND (@Modul       IS NULL OR D.MODUL    = @Modul)
            AND (@Kategori    IS NULL OR D.KATEGORI = @Kategori)
            AND (@Pasif       = 1     OR D.DURUM    = 1)
            AND (@TamYetki    = 1     OR D.GIZLILIKDERECESI <= @GD)
            AND (@TarihVar    = 0     OR (D.TARIH >= @TarihBas AND D.TARIH <= @TarihBit))
        )
        OR @Mod = 3   -- Mod=3 tum-kayitlar
        )
        AND (@AramaModu = 0
             OR EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA
                         WHERE KA.KAYITID = D.ID AND KA.MODUL = @AramaModulID
                           AND KA.KULID = @AramaKul))
    -- Tum join'ler benzersiz anahtar uzerinde arama (REHBER/LOKASYON/IMAJ PK).
    -- LOOP JOIN: hash/sort tamponu istemez -> bellek grant'i minimuma iner.
    -- Bu sorgu SQL Express'te 78 MB grant isteyip RESOURCE_SEMAPHORE'da donuyordu.
    OPTION (LOOP JOIN, MAXDOP 1);
END;
GO

-- ---- PROCEDURE: sp_prog_fattransfer_liste_json2  (kaynak: GenDepoUpdate116) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_FatTransfer_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                          -- ek kolonlar (FatTransfer'de BOS)
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);-- 1=Tum,3=Sik,4=Filtre,5=Son
    DECLARE @BasTrh     DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.BasTrh') AS DATETIME);
    DECLARE @BitTrh     DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.BitTrh') AS DATETIME);
    DECLARE @TeslimEden INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TeslimEden') AS INT);         -- EditTeslimEden.Tag -> FB.SATICIKODU (opsiyonel)
    DECLARE @TeslimAlan INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TeslimAlan') AS INT);         -- EditTeslimAlan.Tag -> FB.REHBERID (opsiyonel)
    DECLARE @TransferNo NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.TransferNo');                          -- AraTransferNo -> FB.FATURANO LIKE (opsiyonel)
    DECLARE @OzelKod    NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.OzelKod');                             -- AraOzelKod -> FB.OZELKOD LIKE (opsiyonel)
    DECLARE @UretimEmir NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.UretimEmirNo');                        -- AraUretimEmirNo -> URETIMEMRI.EMIRNO LIKE (opsiyonel)
    DECLARE @Stok       NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Stok');                                -- AraStok (opsiyonel; FATURA/STOKLAR join tetikler)
    DECLARE @Kod        NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.Kod');                                 -- AraKod -> STOKLAR.KOD veya URUNNO LIKE (opsiyonel; ayni join)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE ESKI ISTEMCI SQL'i ILE BIREBIR =================
    DECLARE @Bas DATETIME = ISNULL(@BasTrh, CAST(CAST(GETDATE() AS DATE) AS DATETIME));
    DECLARE @Bit DATETIME = ISNULL(@BitTrh, DATEADD(SECOND,-1,CAST(CAST(GETDATE()+1 AS DATE) AS DATETIME)));

    -- @Mod=3(Sik)/5(Son): KULLANICI_ARAMA gecmisi (1:1 join; unique KULID,MODUL,KAYITID)
    DECLARE @KaJoin BIT = CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
                               THEN 1 ELSE 0 END;

    -- Taban SELECT (SQLMemo ile BIREBIR). @SelectList (BOS) KAYNAK kolonundan sonra eklenir.
    DECLARE @SQL NVARCHAR(MAX) = N'
    select FB.ID,FATURATARIH,FATURANO,FB.TUR,FB.SUBEID,FB.DETAYBOLUMU,CIKISDEPO,GIRISDEPO,GIRISSUBE,Giris.DEPOADI GIRISDEPOSU, Cikis.DEPOADI CIKISDEPOSU,
    TESLIMALAN=R1.FIRMA,TESLIMEDEN=R2.FIRMA,FB.OZELKOD,FB.YETKIKODU,FB.ACIKLAMA,
    KAYNAK=  case  when exists(select F2.ID from SIPARISDETAY F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI =435 and F1.FATBASID=FB.ID)) then ''Talepten'' end,
    HEDEF =  case  when exists(select 1 from FATBASLIK U (NOLOCK) where U.TUR=6 and U.YERI=134 and U.YERID=FB.ID) then N''' + NCHAR(220) + N'retim Fi' + NCHAR(351) + N'i'' end'
    + @SelectList + N'
    from FATBASLIK FB (NOLOCK)
    inner join DEPOLAR Giris on Giris.ID = GIRISDEPO  inner join DEPOLAR Cikis on Cikis.ID = CIKISDEPO
    left Outer Join REHBER R1 on FB.REHBERID =R1.ID
    left outer join REHBER R2 on FB.SATICIKODU=R2.ID ';

    -- AraStok/AraKod (opsiyonel): FATURA + STOKLAR join'i ekle (orijinal SQLMemo.Add ile ayni)
    IF (@Stok IS NOT NULL AND @Stok <> N'') OR (@Kod IS NOT NULL AND @Kod <> N'')
        SET @SQL = @SQL + N' inner join FATURA FT on FT.FATBASID=FB.ID '
                        + N' left outer join STOKLAR S on FT.URUNID=S.ID ';

    -- Son/Sik: KULLANICI_ARAMA 1:1 join (KAYITID = FB.ID)
    IF @KaJoin = 1
        SET @SQL = @SQL + N' inner join KULLANICI_ARAMA KA on KA.KAYITID = FB.ID and KA.KULID = '
                        + CAST(@KulId AS NVARCHAR(20)) + N' and KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' ';

    -- WHERE (orijinal: FB.TUR=20 + tarih araligi her zaman)
    SET @SQL = @SQL + N' where FB.TUR =20 '
                    + N' and FATURATARIH>=@pBas and FATURATARIH<=@pBit ';

    IF @TeslimEden IS NOT NULL
        SET @SQL = @SQL + N' and FB.SATICIKODU = ' + CAST(@TeslimEden AS NVARCHAR(20)) + N' ';   -- Teslim Eden
    IF @TeslimAlan IS NOT NULL
        SET @SQL = @SQL + N' and FB.REHBERID = ' + CAST(@TeslimAlan AS NVARCHAR(20)) + N' ';      -- Teslim Alan
    IF @TransferNo IS NOT NULL AND @TransferNo <> N''
        SET @SQL = @SQL + N' and FB.FATURANO like N''%'' + @pTransferNo + N''%'' ';               -- Transfer No
    IF @OzelKod IS NOT NULL AND @OzelKod <> N''
        SET @SQL = @SQL + N' and FB.OZELKOD like N''%'' + @pOzelKod + N''%'' ';                    -- Ozel Kod
    IF @UretimEmir IS NOT NULL AND @UretimEmir <> N''
        SET @SQL = @SQL + N' and FB.DETAYBOLUMU like N''%'' + @pUretimEmir + N''%'' ';             -- Uretim Emir No (FATBASLIK.DETAYBOLUMU)
    IF @Stok IS NOT NULL AND @Stok <> N''
        SET @SQL = @SQL + N' and S.STOKADI like N''%'' + @pStok + N''%'' ';
    IF @Kod IS NOT NULL AND @Kod <> N''
        SET @SQL = @SQL + N' and (S.KOD like N''%'' + @pKod + N''%'' OR S.URUNNO like N''%'' + @pKod + N''%'') ';  -- AraKod: kod veya urunno

    -- Siralama: Son/Sik -> KA anahtari; degilse orijinal FATURATARIH desc
    IF @KaJoin = 1
    BEGIN
        IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
        ELSE        SET @OrderBy = N'KA.SAY DESC';
    END;
    IF @OrderBy IS NULL OR @OrderBy = N''
        SET @OrderBy = N'FATURATARIH desc';
    SET @SQL = @SQL + N' order by ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pBas DATETIME, @pBit DATETIME, @pStok NVARCHAR(200), @pKod NVARCHAR(100), @pTransferNo NVARCHAR(100), @pOzelKod NVARCHAR(100), @pUretimEmir NVARCHAR(100)',
         @pBas = @Bas, @pBit = @Bit, @pStok = @Stok, @pKod = @Kod,
         @pTransferNo = @TransferNo, @pOzelKod = @OzelKod, @pUretimEmir = @UretimEmir;
END;
GO

-- ---- PROCEDURE: sp_prog_gorev_liste_json2  (kaynak: GenDepoUpdate85) ----
-- ============================================================
-- GenDepoUpdate85.sql
-- sp_Prog_Gorev_Liste_Json2 : bellek grant'i duzeltmesi (istenen 12,2 MB)
--
-- GenDepoUpdate83 (Dokuman) / 84 (Stok Talep) ile AYNI SINIF hata, daha kucuk
--   olcekte: SQL Express'te sorgu-bellek semaforu ~10 MB'a dustugunde bu istek de
--   karsilanamaz ve Gorev listesi acilirken ekran RESOURCE_SEMAPHORE'da donar.
--
-- KOK NEDEN: "LEFT JOIN GOREVYORUM GY" KOSULSUZ duruyordu. Gorev basina yorum
--   sayisi kadar satir uretiyor, bunu "SELECT DISTINCT" topluyordu (tum kolonlar
--   uzerinde hash/sort). GY yalnizca OPSIYONEL @Ara metin aramasinda kullaniliyor.
--   GOREVKULLANICI GK join'i @AtananID'ye bagli olsa da o da 1:N - filtre aktifken
--   ayni cogaltmayi yapiyordu.
--
-- COZUM: iki join de kaldirildi, filtreler EXISTS'e cevrildi, DISTINCT kaldirildi.
--   EXISTS satir cogaltmaz; sonuc kumesi ayni, DISTINCT'e gerek kalmaz.
-- ============================================================
-- ============================================================
-- sp_Prog_Gorev_Liste_Json2 — tek JSON parametre versiyonu (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Gorev'de bos);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   Tipli sp_Prog_Gorev_Liste ile GOVDE BIREBIR; sadece imza + parametre-cozumleme farkli.
--   @Kosullar = '{"Mod":4,"Ara":"...","BasTarih":"2026-01-01",...}' -> JSON_VALUE + TRY_CAST.
--   Absent key -> NULL (filtre yok). Bool'lar 0/1 sayi (TRY_CAST AS BIT).
--   DISTINCT + Son/Sik siralama tuzagi (@SonSikCol) korunur.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Gorev_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList   NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')  AS INT), 0);
    DECLARE @Mod          SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')   AS SMALLINT), 4);
    DECLARE @Pasif        BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @Ara          NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Ara');
    DECLARE @Tarih        BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Tarih') AS BIT), 0);
    DECLARE @BasTarih     NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.BasTarih');
    DECLARE @BitTarih     NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.BitTarih');
    DECLARE @FirmaID      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.FirmaID')     AS INT);
    DECLARE @OlusturanID  INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.OlusturanID') AS INT);
    DECLARE @AtananID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.AtananID')    AS INT);
    DECLARE @GorevID      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GorevID')     AS INT);
    DECLARE @KulId        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId')       AS INT);
    DECLARE @Modul        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul')       AS INT);
    DECLARE @OrderBy      NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
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
    SELECT ' + @Top + N'
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
        INNER JOIN GOREVLISTE GL on G.LISTEID=GL.ID '
    -- GOREVYORUM ve GOREVKULLANICI ARTIK JOIN DEGIL - ikisi de 1:N, satir cogaltiyordu.
    --   Onceki halde "LEFT JOIN GOREVYORUM GY" KOSULSUZ duruyordu (yalnizca opsiyonel
    --   @Ara metin aramasi icin gerekli) ve cogalan satirlari SELECT DISTINCT topluyordu.
    --   DISTINCT tum kolonlar uzerinde hash/sort demek: 12,2 MB bellek grant'i.
    --   Filtreler asagida EXISTS'e cevrildi; bkz. GenDepoUpdate83/84 ayni sinif hata.
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
        SET @SQL = @SQL + N' AND (G.KONUSU LIKE N''%'' + @pAra + N''%''
                                  OR EXISTS (SELECT 1 FROM GOREVYORUM GY
                                              WHERE GY.GOREVID = G.ID
                                                AND GY.YORUM LIKE N''%'' + @pAra + N''%'')) ';

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
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM GOREVKULLANICI GK
                                          WHERE GK.LISTGOREVID = G.ID AND GK.TUR = 11
                                            AND GK.REHBERID = ' + CAST(@AtananID AS NVARCHAR(20)) + N') ';
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
GO

-- ---- PROCEDURE: sp_prog_log_liste_json2  (kaynak: GenDepoUpdate144) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Log_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',  
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent/bos key -> NULL. ----
    DECLARE @TarihBas   DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATE);
    DECLARE @TarihBit   DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATE);
    DECLARE @Kullanici  NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.Kullanici'), N'');
    DECLARE @Modul      NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.Modul'),     N'');
    DECLARE @KayitNo    NVARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar,'$.KayitNo'),   N'');
    DECLARE @Istasyon   NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Istasyon'),  N'');
    DECLARE @Ara        NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.Ara'),       N'');
    DECLARE @IcerikAra  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IcerikAra')  AS BIT), 0);
    DECLARE @Ekleme     BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Ekleme')     AS BIT), 0);
    DECLARE @Degistirme BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Degistirme') AS BIT), 0);
    DECLARE @Silme      BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Silme')      AS BIT), 0);

    -- Tarih araligi YALNIZ genel arama (Ara) ve Kayit No bosken uygulanir:
    -- onlar girilince aramanin/kaydin TUM gecmisi gelsin (eski davranis birebir).
    DECLARE @TarihUygula BIT = CASE WHEN @KayitNo IS NULL AND @Ara IS NULL THEN 1 ELSE 0 END;
    DECLARE @Bas DATETIME2(0) = CASE WHEN @TarihUygula = 1 THEN CAST(@TarihBas AS DATETIME2(0)) END;
    -- Bitis: gun sonu -> ertesi gunun basi (< karsilastirmasi, saat bilgisi kaybolmaz)
    DECLARE @Bit DATETIME2(0) = CASE WHEN @TarihUygula = 1 AND @TarihBit IS NOT NULL
                                     THEN CAST(DATEADD(DAY, 1, @TarihBit) AS DATETIME2(0)) END;
    -- Hicbir islem tipi secili degilse -> TUMU
    DECLARE @TipHepsi BIT = CASE WHEN @Ekleme = 0 AND @Degistirme = 0 AND @Silme = 0 THEN 1 ELSE 0 END;
    -- LIKE deseni: %deger% (ozel karakter kacisi: [ -> [[])
    DECLARE @KullaniciL NVARCHAR(210) = N'%' + REPLACE(@Kullanici, N'[', N'[[]') + N'%';
    DECLARE @KayitNoL   NVARCHAR(60)  = N'%' + REPLACE(@KayitNo,   N'[', N'[[]') + N'%';
    DECLARE @IstasyonL  NVARCHAR(110) = N'%' + REPLACE(@Istasyon,  N'[', N'[[]') + N'%';
    DECLARE @AraL       NVARCHAR(210) = N'%' + REPLACE(@Ara,       N'[', N'[[]') + N'%';

    -- Master (USTKAYITID) + islem tipi + GUN bazinda GRUPLU.
    SELECT
        TARIH = MAX(L.TARIH),
        GUN   = CAST(L.TARIH AS date),
        KAYITNO = L.USTKAYITID,
        USTTABLOID = L.USTTABLOID,
        L.ISLEMTIPI,
        -- ISLEM adi: EKLEME satirlarinda kaydin NASIL olustugu ALTISLEMTIPI'de olabilir
        --   (GenDepoUpdate143): 3=Kopyalama, 5=Donusum. Grup icindeki KART satirinin
        --   (TABLOID=USTTABLOID) alt tipi belirleyicidir.
        ISLEM = CASE
                  WHEN L.ISLEMTIPI = 1 AND MAX(CASE WHEN L.TABLOID = L.USTTABLOID
                                                    THEN L.ALTISLEMTIPI END) = 3
                       THEN N'Kopyalama'
                  WHEN L.ISLEMTIPI = 1 AND MAX(CASE WHEN L.TABLOID = L.USTTABLOID
                                                    THEN L.ALTISLEMTIPI END) = 5
                       THEN N'D' + NCHAR(246) + N'n' + NCHAR(252) + NCHAR(351) + NCHAR(252) + N'm'
                  WHEN L.ISLEMTIPI = 0 THEN N'Silme'
                  WHEN L.ISLEMTIPI = 1 THEN N'Ekleme'
                  WHEN L.ISLEMTIPI = 2 THEN N'De' + NCHAR(287) + N'i' + NCHAR(351) + N'tirme'
                  ELSE N'?' END,
        FIRMA = MAX(ISNULL(R.FIRMA, CAST(L.KULLANICIID AS varchar(20)))),
        PCADI = MAX(L.ISTASYON),
        ANAHTAR = MAX(CASE WHEN L.USTTABLOID IN (108,109) THEN N'Tahakkuk'
                           ELSE COALESCE(T.MODUL, T.TABLOADI, CAST(L.USTTABLOID AS varchar(20))) END),
        -- Kod/Ad: once kaydin KENDI referansi (kart: KAYITID=USTKAYITID, TABLOID=USTTABLOID),
        -- yoksa bagli cari/IK (REHBERID) veya stok (STOKID) - LOGREFERANS'tan (guncel).
        -- Cek/Senet (315/316/318/319): kart kendi muhasebe kodu yerine borclu/alacakli CARI
        -- (REHBERID) kod/adi gelsin -> LRk atlanir, LRc (cari) oncelikli.
        -- Uretim Fisi (144), Konsinye (209/219), Banka Odeme/Tahsilat (482/483) de ayni:
        -- once CARI (REHBERID); cari yoksa uretilen stok (LRuf).
        -- COLLATE DATABASE_DEFAULT: LOGREFERANS (depo) ile STOKLAR (ana DB) collation farki.
        -- KOD/AD YALNIZ kart satirindan (TABLOID=USTTABLOID); detay satirlari MAX'e karismasin.
        KOD = MAX(CASE WHEN L.USTTABLOID = 485 THEN N'Opsiyon'
                       WHEN L.TABLOID = L.USTTABLOID THEN
                         COALESCE(CASE WHEN L.USTTABLOID IN (315,316,318,319,144,209,219,482,483) THEN NULL
                                       ELSE NULLIF(LRk.KOD, N'') COLLATE DATABASE_DEFAULT END,
                                  NULLIF(LRc.KOD, N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RL.KOD,  N'') COLLATE DATABASE_DEFAULT,
                                  CASE WHEN L.USTTABLOID IN (144,482,483)
                                       THEN NULLIF(LRk.KOD, N'') COLLATE DATABASE_DEFAULT END,
                                  NULLIF(LRs.KOD,  N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RS.KOD,   N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(LRuf.KOD, N'') COLLATE DATABASE_DEFAULT)
                       WHEN L.USTTABLOID IN (144,209,219) THEN
                         COALESCE(NULLIF(LRcb.KOD, N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RL.KOD,   N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(LRuf.KOD, N'') COLLATE DATABASE_DEFAULT)
                       ELSE
                         COALESCE(CASE WHEN L.USTTABLOID NOT IN (315,316,318,319,144,209,219,482,483)
                                       THEN NULLIF(LRk.KOD, N'') COLLATE DATABASE_DEFAULT END,
                                  NULLIF(RL.KOD, N'') COLLATE DATABASE_DEFAULT,
                                  NULLIF(RS.KOD, N'') COLLATE DATABASE_DEFAULT)
                  END),
        AD = MAX(CASE WHEN L.USTTABLOID = 485 THEN NULLIF(AYS.SEKSIYON, N'') COLLATE DATABASE_DEFAULT
                      WHEN L.TABLOID = L.USTTABLOID THEN
                        COALESCE(CASE WHEN L.USTTABLOID IN (315,316,318,319,144,209,219,482,483) THEN NULL
                                      ELSE NULLIF(LRk.AD, N'') COLLATE DATABASE_DEFAULT END,
                                 NULLIF(LRc.AD, N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RL.AD,  N'') COLLATE DATABASE_DEFAULT,
                                 CASE WHEN L.USTTABLOID IN (144,482,483)
                                      THEN NULLIF(LRk.AD, N'') COLLATE DATABASE_DEFAULT END,
                                 NULLIF(LRs.AD,  N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RS.AD,   N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(LRuf.AD, N'') COLLATE DATABASE_DEFAULT)
                      WHEN L.USTTABLOID IN (144,209,219) THEN
                        COALESCE(NULLIF(LRcb.AD, N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RL.AD,   N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(LRuf.AD, N'') COLLATE DATABASE_DEFAULT)
                      ELSE
                        COALESCE(CASE WHEN L.USTTABLOID NOT IN (315,316,318,319,144,209,219,482,483)
                                      THEN NULLIF(LRk.AD, N'') COLLATE DATABASE_DEFAULT END,
                                 NULLIF(RL.AD, N'') COLLATE DATABASE_DEFAULT,
                                 NULLIF(RS.AD, N'') COLLATE DATABASE_DEFAULT)
                 END),
        ADET = COUNT(*)
    FROM ISLEMLOG L
        LEFT JOIN REHBER   R ON R.ID = L.KULLANICIID
        LEFT JOIN TABLOLAR T ON T.TABLOID = L.USTTABLOID
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = L.USTKAYITID AND TABLOID = L.USTTABLOID ORDER BY ID DESC) LRk
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = L.REHBERID AND TABLOID IN (71,73,74) ORDER BY ID DESC) LRc
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = L.STOKID AND TABLOID = 88 ORDER BY ID DESC) LRs
        -- CANLI fallback: LOGREFERANS (cache) bu cariyi/stogu henuz icermiyorsa
        -- ad/kod dogrudan REHBER/STOKLAR'dan gelsin.
        OUTER APPLY (SELECT TOP 1 AD = FIRMA,   KOD FROM REHBER
                     WHERE ID = L.REHBERID AND L.REHBERID > 0) RL
        OUTER APPLY (SELECT TOP 1 AD = STOKADI, KOD FROM STOKLAR
                     WHERE ID = L.STOKID AND L.STOKID > 0) RS
        -- Opsiyon/ayar (485): KAYITID=BOLUM. SEKSIYON = opsiyon bolumu -> AD; KOD sabit 'Opsiyon'.
        OUTER APPLY (SELECT TOP 1 SEKSIYON, AD FROM AYARADI
                     WHERE BOLUM = L.KAYITID AND L.USTTABLOID = 485) AYS
        -- Belge (FATBASLIK) tabanli gruplar (144/209/219): grupta KART satiri yoksa
        -- KOD/AD yine belge CARIsinden gelsin -> canli FATBASLIK.REHBERID -> LOGREFERANS.
        OUTER APPLY (SELECT TOP 1 REHBERID FROM FATBASLIK
                     WHERE ID = L.USTKAYITID AND L.USTTABLOID IN (144,209,219)) FB
        OUTER APPLY (SELECT TOP 1 AD, KOD FROM LOGREFERANS
                     WHERE KAYITID = FB.REHBERID AND TABLOID IN (71,73,74) ORDER BY ID DESC) LRcb
        -- Uretim Fisi (144): uretilen stok = detay (FATURA) ADET>0 olan URUNID
        OUTER APPLY (SELECT TOP 1 KOD = s.KOD, AD = s.STOKADI
                     FROM FATURA f JOIN STOKLAR s ON s.ID = f.URUNID
                     WHERE L.USTTABLOID = 144 AND f.FATBASID = L.USTKAYITID AND f.ADET > 0
                     ORDER BY f.ID) LRuf
    WHERE (@Bas IS NULL OR L.TARIH >= @Bas)
      AND (@Bit IS NULL OR L.TARIH <  @Bit)
      AND (@Kullanici IS NULL OR ISNULL(R.FIRMA, CAST(L.KULLANICIID AS varchar(20))) LIKE @KullaniciL)
      AND (@Modul     IS NULL OR T.MODUL = @Modul)
      AND (@KayitNo   IS NULL OR CAST(L.USTKAYITID AS varchar(20)) LIKE @KayitNoL)
      AND (@Istasyon  IS NULL OR L.ISTASYON LIKE @IstasyonL)
      AND (@Ara IS NULL
           OR (@IcerikAra = 1
               -- "Icerikten Ara": log JSON (BILGI) icinde detayli arama (yavas)
               AND CAST(DECOMPRESS(L.BILGI) AS nvarchar(max)) LIKE @AraL)
           OR (@IcerikAra = 0
               -- Varsayilan: LOGREFERANS KOD/AD (hizli, indeksli, silinmis kayit dahil).
               -- Uc kaynak: kartin kendi kaydi / bagli cari-IK / bagli stok.
               AND EXISTS (SELECT 1 FROM LOGREFERANS r
                           WHERE ((r.KAYITID = L.USTKAYITID AND r.TABLOID = L.USTTABLOID)
                               OR (r.KAYITID = L.REHBERID   AND r.TABLOID IN (71,73,74))
                               OR (r.KAYITID = L.STOKID     AND r.TABLOID = 88))
                             AND (r.AD LIKE @AraL OR r.KOD LIKE @AraL))))
      AND (@TipHepsi = 1
           OR (@Ekleme = 1 AND L.ISLEMTIPI = 1)
           OR (@Degistirme = 1 AND L.ISLEMTIPI = 2)
           OR (@Silme = 1 AND L.ISLEMTIPI = 0))
    GROUP BY CAST(L.TARIH AS date), L.USTKAYITID, L.USTTABLOID, L.ISLEMTIPI
    ORDER BY MAX(L.TARIH) DESC;
END
GO

-- ---- PROCEDURE: sp_prog_servis_liste_json2  (kaynak: GenDepoUpdate122) ----
-- ============================================================
-- GenDepoUpdate122.sql
-- sp_Prog_Servis_Liste_Json2 : + RehberId filtresi
--
-- Cari ekranina eklenen "Servis" alt sekmesi YALNIZ O CARININ servislerini
--   gosterir. Mevcut @Musteri parametresi cari ADI uzerinden LIKE arar -
--   ayni adin gectigi baska carileri de getirir, ad degisince kirilir.
--   @RehberId kimlik uzerinden kesin filtredir.
--
-- Diger tum davranis aynen korundu; parametre gonderilmezse (0/NULL) sorgu
--   eskisi gibi calisir.
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Servis_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SelectList     NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN           INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);
    DECLARE @Mod            SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Pasif          BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @ServisNo       NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.ServisNo');
    DECLARE @ServisNoId     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.ServisNoId') AS INT);
    DECLARE @ServisNoLike   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.ServisNoLike') AS BIT), 0);
    DECLARE @KategoriAd     NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.KategoriAd');
    DECLARE @Konusu         NVARCHAR(250) = JSON_VALUE(@Kosullar,'$.Konusu');
    DECLARE @Urun           NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Urun');
    DECLARE @Musteri        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Musteri');
    -- Belirli bir cariye ait servisler (cari ekranindaki Servis alt sekmesi).
    --   @Musteri AD uzerinden LIKE arar; bu KIMLIK uzerinden kesin filtredir.
    DECLARE @RehberId       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.RehberId') AS INT);
    DECLARE @SeriNo         NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.SeriNo');
    DECLARE @SeriNoLike     BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SeriNoLike') AS BIT), 0);
    DECLARE @SubeYetkiList  NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');
    DECLARE @cbListe        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.cbListe') AS INT);
    DECLARE @Kullanan       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Kullanan') AS INT);
    DECLARE @SubeID         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeID') AS INT);
    DECLARE @Durum          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Durum') AS INT);
    DECLARE @DurumVar       BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.DurumVar') AS BIT), 0);
    DECLARE @SorumluTag     INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SorumluTag') AS INT), 0);
    DECLARE @Kapali         BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kapali') AS BIT), 0);
    DECLARE @Tamamlanan     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Tamamlanan') AS INT);
    DECLARE @KapaliTarih    NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.KapaliTarih');
    DECLARE @TarihBas       NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.TarihBas');
    DECLARE @TarihBit       NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.TarihBit');
    DECLARE @KulId          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    DECLARE @KaJoin BIT = CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
                               THEN 1 ELSE 0 END;

    -- SERVIS_USER (kullanici EK ALAN tablosu) kolonlari MUSTERIDEN MUSTERIYE DEGISIR.
    --   Eskiden burada bir musterinin alanlari (MARKA, TIP1, KASANO...) SABIT yaziliydi ->
    --   o alanlar olmayan musteride "Invalid column name 'MARKA'" ile liste hic acilmiyordu.
    --   Cozum: kolon listesi metadata'dan URETILIR (ID + audit kolonlari haric). Tablo yoksa
    --   ya da ek alan yoksa liste bos kalir, sorgu yine calisir.
    DECLARE @UserCols NVARCHAR(MAX) = N'';
    IF OBJECT_ID('dbo.SERVIS_USER','U') IS NOT NULL
        SELECT @UserCols = @UserCols + N', SU0.' + QUOTENAME(c.name)
        FROM sys.columns c
        WHERE c.object_id = OBJECT_ID('dbo.SERVIS_USER')
          AND c.name NOT IN ('ID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI')
        ORDER BY c.column_id;

    -- ===== ON SUZME (PERF) ==========================================================
    -- ESKI YAPI: butun SERVIS tablosu (or. 34.000 satir) icin ~15 correlated subquery +
    --   8 join + DISTINCT hesaplanip SONRA disarida filtrelenip TOP aliniyordu. Kapali
    --   servis listesi bu yuzden 5-12 sn suruyordu; TopN=100 hic limitsizden bile yavasti
    --   (row-goal ile kotu plan). DISTINCT de gereksizdi: cogaltan join yok (FATBASLIK ve
    --   REHBERILETISIM tekil, SERVISBILGI zaten ROW_NUMBER=1).
    -- YENI YAPI: SERVIS uzerindeki TUM filtreler + TOP en icteki taramaya indirilir; pahali
    --   alt sorgular yalniz SECILEN satirlar icin hesaplanir. Filtreler SERVIS'in kendi
    --   kolonlarina (ya da EXISTS ile hareket/rehber tablolarina) dokundugu icin bu guvenli.
    -- Sayfalama (TSayfaliListe) TOP'u buyuterek ayni sorguyu tekrar cagirir -> ON SUZMEDE
    --   deterministik ORDER BY (ID DESC = en yeni servis) sart; eskiden ORDER BY yoktu ve
    --   hangi 100 kaydin gelecegi belirsizdi.
    DECLARE @Filt NVARCHAR(MAX) = N'';

    IF @ServisNo IS NOT NULL AND @ServisNo <> N''
    BEGIN
        SET @Filt = @Filt + N' AND ((SV0.SERVISNO ' + CASE WHEN @ServisNoLike = 1 THEN N'LIKE' ELSE N'=' END + N' @pServisNo)';
        IF @ServisNoId IS NOT NULL AND @ServisNoId <> 0
            SET @Filt = @Filt + N' OR (SV0.ID = ' + CAST(@ServisNoId AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N')';
    END;

    IF @SeriNo IS NOT NULL AND @SeriNo <> N''
        SET @Filt = @Filt + N' AND SV0.SERINO ' + CASE WHEN @SeriNoLike = 1 THEN N'LIKE' ELSE N'=' END + N' @pSeriNo ';

    IF @KategoriAd IS NOT NULL AND @KategoriAd <> N''
        SET @Filt = @Filt + N' AND (SELECT AD FROM KATEGORI K WHERE K.ID = SV0.EKIPMANID) = @pKategoriAd ';

    IF @Konusu IS NOT NULL AND @Konusu <> N''
        SET @Filt = @Filt + N' AND SV0.KONUSU LIKE N''%'' + @pKonusu + N''%'' ';

    IF @Urun IS NOT NULL AND @Urun <> N''
        SET @Filt = @Filt + N' AND (SELECT AD FROM EKIPMANLAR E WHERE E.ID = SV0.EKIPMANID) LIKE N''%'' + @pUrun + N''%'' ';

    IF @Musteri IS NOT NULL AND @Musteri <> N''
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM REHBER RM WHERE RM.ID = SV0.REHBERID AND RM.FIRMA LIKE N''%'' + @pMusteri + N''%'') ';

    IF ISNULL(@RehberId, 0) > 0
        SET @Filt = @Filt + N' AND SV0.REHBERID = ' + CAST(@RehberId AS NVARCHAR(20)) + N' ';

    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @Filt = @Filt + N' AND SV0.SUBEID IN (' + @SubeYetkiList + N') ';

    IF @cbListe = 1
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE ISNULL(SH.BITISSEC,0)=0 AND SH.SERVISID=SV0.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 2
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 5
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.PERSONEL IN '
                          + N' (SELECT R.ID FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                          + N'  WHERE ROL.DEPARTMAN=(SELECT ROL.DEPARTMAN FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                          + N'  WHERE R.ID=' + CAST(@Kullanan AS NVARCHAR(20)) + N'))) ';
    ELSE IF @cbListe = 8
        SET @Filt = @Filt + N' AND SV0.SUBEID=' + CAST(@SubeID AS NVARCHAR(20)) + N' ';

    IF @DurumVar = 1
        SET @Filt = @Filt + N' AND SV0.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' ';

    IF @DurumVar = 1 AND @SorumluTag > 0
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 0 AND @SorumluTag > 0
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 1 AND @SorumluTag = 0
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N') ';

    -- Ac/kapali: servis no ya da seri no ile arama yapiliyorsa uygulanmaz (eski davranis).
    IF (@ServisNo IS NULL OR @ServisNo = N'') AND (@SeriNo IS NULL OR @SeriNo = N'')
    BEGIN
        IF @Kapali = 1
        BEGIN
            IF @Tamamlanan = 1
                SET @Filt = @Filt + N' AND ((ISNULL(SV0.ACKAPA,0)=0) OR (CAST(SV0.BASLAMATARIHI AS DATE)=CAST(GETDATE() AS DATE))) ';
            ELSE IF @Tamamlanan = 19000
                SET @Filt = @Filt + N' AND ((ISNULL(SV0.ACKAPA,0)=0) OR (SV0.BASLAMATARIHI BETWEEN @pTarihBas AND @pTarihBit)) ';
            ELSE
                SET @Filt = @Filt + N' AND ((ISNULL(SV0.ACKAPA,0)=0) OR (SV0.BASLAMATARIHI >= @pKapaliTarih)) ';
        END
        ELSE
            SET @Filt = @Filt + N' AND SV0.ACKAPA = 0 ';
    END;

    -- Son/Sik Aranan (Mod 3/5): kayit kumesi KULLANICI_ARAMA ile sinirli -> on suzmeye de
    --   ayni kisit girer, siralama/join disarida kalir (kucuk kume, maliyet yok).
    IF @KaJoin = 1
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA0 WHERE KA0.KAYITID = SV0.ID AND KA0.KULID = '
                          + CAST(@KulId AS NVARCHAR(20)) + N' AND KA0.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';

    -- Mod 3/5 siralamasi KULLANICI_ARAMA'ya bagli -> on suzmede TOP UYGULANMAZ (yanlis
    --   kayitlar secilirdi); orada TOP eskisi gibi en distadir.
    DECLARE @OnTop NVARCHAR(30) = CASE WHEN @TopN > 0 AND @KaJoin = 0
                                       THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                       ELSE N'' END;
    DECLARE @OnSira NVARCHAR(60) = CASE WHEN @OnTop <> N'' THEN N' ORDER BY SV0.ID DESC ' ELSE N'' END;
    -- ================================================================================

    SET @SQL = N'
    SELECT ' + @Top + N' S.* ' + ISNULL(@SelectList, N'') + N'
    FROM (
        SELECT
            SV.ID,
            SV.BASLAMATARIHI,
            SV.REHBERID,
            SV.SERVISNO,
            SV.KONUSU,
            SV.DURUM,
            SV.MUS_ILGILI,
            SV.BITISTARIHI,
            SV.SERINO,
            SV.KASA,
            SV.FIYAT_LISTESI,
            SV.OZELKOD,
            SV.YETKIKODU,
            SV.NOTLAR,
            SV.EKIPMANREHBERID,
            SV.DEPO,
            SV.LOKASYONID,
            SV.PLANLANAN_MATRAHI,
            SV.PLANLANAN_TUTAR,
            SV.PLANLANAN_KUR,
            SV.PLANLANAN_DOVIZ_TUTARI,
            SV.PLANLANAN_DOVIZ_KURU,
            SV.PLANLANAN_KDV_TUTARI,
            SV.UYGULANAN_MATRAHI,
            SV.UYGULANAN_TUTAR,
            SV.UYGULANAN_KUR,
            SV.UYGULANAN_DOVIZ_TUTARI,
            SV.UYGULANAN_DOVIZ_KURU,
            SV.UYGULANAN_KDV_TUTARI,
            SV.SORUMLU,
            SV.KABUL_EDEN,
            SV.KABUL_SEKLI,
            SV.TESLIM_ALAN,
            SV.TESLIM_EDEN,
            SV.TESLIM_TARIHI,
            SV.TESLIM_SEKLI,
            SV.TESLIM_KARGO_NO,
            SV.ONAYSEKLI,
            SV.ONAYTARIHI,
            SV.ONAYLAYAN,
            SV.ONAYALAN,
            SV.SUBEID,
            SV.EKLEYEN,
            SV.EKLEMETARIHI,
            SV.DEGISTIREN,
            SV.DEGISTIRMETARIHI,
            SV.KAPSAM,
            SV.DETAYBOLUMU,
            SV.ACIL,
            SV.DISSERVIS,
            SV.TARIH,
            SV.EKIPMANID,
            SV.TESLIMNOTU,
            SV.ACKAPA,
            SV.DEMIRBAS,
            SV.YERI,
            SV.YERID,
            SV.TURU,
            SV.ONAYLAYACAK,
            SV.DISONAY,
            SV.SERVISADRESI,
            SV.KOCANNO,
            SV.SERVISSERI,
            SV.ONEMLI,
            SV.PROJEID,
            SV.GIRISKAYNAK,
            SV.YILDIZ,
            SH.BASLAMA,
            SH.BITIS,
            SH.TOPLAM_SURE,
            SH.CALISMA_SURESI,
            SORUN_TIPI = SL.AD,
            SORUN_ACIKLAMA = SB.ACIKLAMA,
            SORUN_SONUCU = SB.COZUM,
            KABUL_EDENAD = R7.FIRMA,
            KATEGORIAD = CASE WHEN SV.DEMIRBAS = 1 THEN (SELECT STOKADI FROM DEMIRBAS_URUN DU INNER JOIN DEMIRBAS D ON D.KATEGORIID = DU.ID WHERE D.ID = SV.EKIPMANID) ELSE (SELECT AD FROM KATEGORI K WHERE K.ID = SV.EKIPMANID) END,
            EKIPMANAD = CASE WHEN SV.DEMIRBAS = 1 THEN (SELECT DEMIRBASADI FROM DEMIRBAS D WHERE D.ID = SV.EKIPMANID) ELSE (SELECT AD FROM EKIPMANLAR E WHERE E.ID = SV.EKIPMANID) END,
            R1.FIRMA,
            SORUMLUAD = CASE
                            WHEN SV.DURUM = 0
                                THEN (SELECT DISTINCT R.FIRMA FROM SERVISHAREKET SH2 INNER JOIN REHBER R ON SH2.PERSONEL = R.ID WHERE SH2.SERVISID = SV.ID)
                            WHEN ISNULL(SV.DURUM, 0) <> 0
                                THEN (SELECT TOP 1 R.FIRMA FROM SERVISHAREKET SH2 INNER JOIN REHBER R ON SH2.PERSONEL = R.ID WHERE SH2.SERVISID = SV.ID AND SH2.DURUM = SV.DURUM ORDER BY SH2.BASLAMA DESC)
                            ELSE ''''
                        END,
            RP.FIRMA AS MUS_ILGILIAD,
            LOKASYON = (SELECT ACIKLAMA FROM LOKASYON L WHERE L.ID = SV.LOKASYONID),
            ONAYLAYANAD = (SELECT R5.FIRMA FROM REHBER R5 WHERE R5.GRUP = 334 AND R5.ID = SV.DISONAY),
            TESLIM_ALANAD = (SELECT R5.FIRMA FROM REHBER R5 WHERE R5.GRUP = 334 AND R5.ID = SV.TESLIM_ALAN),
            ONAYSEKLIAD = (SELECT ANAHTAR FROM GENINI G WHERE BOLUM = -3005 AND G.DEGER = SV.ONAYSEKLI),
            FB.FATURATARIH,
            FB.FATURANO,
            FB.FATURA_TUTARI,
            SERVIS_ADRESI = RI.AD' + @UserCols + N'
        FROM (SELECT ' + @OnTop + N' SV0.*
                FROM SERVIS SV0
               WHERE 1 = 1 ' + @Filt + @OnSira + N') SV
        LEFT JOIN SERVIS_USER SU0 ON SU0.ID = SV.ID
        -- V_Servis_Hareket_Ozet gorunumu TUM SERVISHAREKET kayitlarini GROUP BY ile ozetler
        --   ve her grup icin IKI SKALER UDF (fn_TarihFarkiFormatli/2) calistirir. LEFT JOIN
        --   edilince optimizer gorunumun TAMAMINI uretiyordu -> 34.000 servis x 2 UDF =
        --   listenin asil maliyeti. OUTER APPLY ayni hesabi YALNIZ secilen satirlar icin yapar.
        OUTER APPLY (SELECT BASLAMA = MIN(SH1.BASLAMA),
                            BITIS   = MAX(SH1.BITIS),
                            TOPLAM_SURE    = dbo.fn_TarihFarkiFormatli(MIN(SH1.BASLAMA), MAX(SH1.BITIS)),
                            CALISMA_SURESI = dbo.fn_TarihFarkiFormatli2(SUM(CONVERT(FLOAT,(SH1.BITIS - SH1.BASLAMA))))
                       FROM SERVISHAREKET SH1
                      WHERE SH1.SERVISID = SV.ID
                        AND SH1.BASLAMA IS NOT NULL AND SH1.BITIS IS NOT NULL) SH
        LEFT JOIN REHBER R1 ON R1.ID = SV.REHBERID
        LEFT JOIN REHBER RP ON RP.ID = SV.MUS_ILGILI AND RP.GRUP = 334
        LEFT JOIN FATBASLIK FB ON FB.SERVISID = SV.ID AND FB.TUR IN (15, 16)
        -- ROW_NUMBER li turetilmis tablo da TUM SERVISBILGI icin hesaplaniyordu; ilk satiri
        --   satir-basina getiren APPLY ayni sonucu index seek ile verir.
        OUTER APPLY (SELECT TOP 1 SB2.ACIKLAMA, SB2.COZUM, SB2.SERVISLISTEID
                       FROM SERVISBILGI SB2
                      WHERE SB2.SERVISID = SV.ID AND SB2.SERVISTUR = 210
                      ORDER BY SB2.ID) SB
        LEFT JOIN SERVISLISTE SL ON SL.ID = SB.SERVISLISTEID
        LEFT JOIN REHBERILETISIM RI ON RI.REHBERID = SV.REHBERID AND RI.ID = SV.SERVISADRESI
        LEFT JOIN REHBER R7 ON R7.ID = SV.EKLEYEN
    ) S
    LEFT JOIN SERVIS_USER SU ON SU.ID = S.ID '
    + CASE WHEN @KaJoin = 1
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = S.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';
    -- NOT: Filtreler artik ON SUZMEDE (yukaridaki @Filt); burada TEKRARLANMAZ.
    --   Disarida kalan tek sey Son/Sik Aranan siralamasi icin KULLANICI_ARAMA join'i.

    IF @KaJoin = 1
    BEGIN
        IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
        ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    END;

    -- Mod 4 (normal filtre): on suzme ID DESC ile TOP aldigi icin dista da AYNI sira
    --   verilmeli; yoksa turetilmis tablonun sirasi garanti degildir ve sayfa buyudukce
    --   (TSayfaliListe) grid'deki satir sirasi oynayabilir.
    IF (@OrderBy IS NULL OR @OrderBy = N'') AND @KaJoin = 0
        SET @OrderBy = N'S.ID DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pServisNo NVARCHAR(50), @pKategoriAd NVARCHAR(150), @pKonusu NVARCHAR(250), @pUrun NVARCHAR(200), @pMusteri NVARCHAR(200), @pSeriNo NVARCHAR(50), @pTarihBas NVARCHAR(20), @pTarihBit NVARCHAR(20), @pKapaliTarih NVARCHAR(20)',
         @pServisNo = @ServisNo, @pKategoriAd = @KategoriAd, @pKonusu = @Konusu, @pUrun = @Urun,
         @pMusteri = @Musteri, @pSeriNo = @SeriNo, @pTarihBas = @TarihBas, @pTarihBit = @TarihBit, @pKapaliTarih = @KapaliTarih;
END;
GO

-- ---- PROCEDURE: sp_prog_stokhizmetara_hizmet_json2  (kaynak: GenDepoUpdate67) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokHizmetAra_Hizmet_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FiyatAdi   INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.FiyatAdi') AS INT), 0);
    DECLARE @Satis      BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Satis') AS BIT), 1);
    DECLARE @AdetBirimi INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AdetBirimi') AS INT), 0);
    DECLARE @Kod        NVARCHAR(100)= JSON_VALUE(@Kosullar,'$.Kod');
    DECLARE @Ad         NVARCHAR(150)= JSON_VALUE(@Kosullar,'$.Ad');
    DECLARE @Barkod     NVARCHAR(50) = JSON_VALUE(@Kosullar,'$.Barkod');
    DECLARE @SubeVar    BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeVar') AS BIT), 0);
    DECLARE @SubeID     INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeID') AS INT), 0);
    -- Mod: 4=normal/filtre, 5=Son Aranan (tarih desc), 6=Sik Aranan (SAY desc).
    --   KULLANICI_ARAMA.MODUL hizmette MODUL_Hizmet(248002) - stok listesinden AYRI liste.
    DECLARE @Mod        SMALLINT     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod') AS SMALLINT), 4);
    DECLARE @KulId      INT          = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT          = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);

    DECLARE @sFiyat  NVARCHAR(20) = CAST(@FiyatAdi AS NVARCHAR(20));
    DECLARE @sBirimi NVARCHAR(20) = CAST(@AdetBirimi AS NVARCHAR(20));
    DECLARE @Gelirmi NVARCHAR(1)  = CAST(@Satis AS NVARCHAR(1));   -- 1=cikis/gelir, 0=giris/gider
    DECLARE @Satis01 NVARCHAR(1)  = CAST(@Satis AS NVARCHAR(1));
    DECLARE @Varsayilan NVARCHAR(1) = CASE WHEN @Satis = 1 THEN N'3' ELSE N'2' END;
    DECLARE @SonAranan BIT = CASE WHEN @Mod IN (5,6) AND @KulId IS NOT NULL AND @Modul IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @SikAranan BIT = CASE WHEN @Mod = 6 AND @KulId IS NOT NULL AND @Modul IS NOT NULL THEN 1 ELSE 0 END;
    -- Son/Sik modunda metin filtresi de HESAPPLANI baslik satirlari da devre disi (sadece aranmis hizmetler)
    IF @SonAranan = 1 BEGIN SET @Kod = NULL; SET @Ad = NULL; SET @Barkod = NULL; END;
    DECLARE @AramaBos BIT = CASE WHEN @SonAranan = 1 THEN 0
                                 WHEN (@Kod IS NULL OR @Kod = N'') AND (@Ad IS NULL OR @Ad = N'') AND (@Barkod IS NULL OR @Barkod = N'') THEN 1 ELSE 0 END;
    -- KULLANICI_ARAMA join (Son/Sik): MASRAFGELIR.ID = KA.KAYITID
    DECLARE @JKA NVARCHAR(300) = CASE WHEN @SonAranan = 1
        THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID=M.ID AND KA.KULID=' + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL=' + CAST(@Modul AS NVARCHAR(20)) + N' ' ELSE N'' END;

    DECLARE @SQL NVARCHAR(MAX) = N'';

    -- HESAPPLANI baslik satirlari (yalnizca arama bos iken)
    IF @AramaBos = 1
        SET @SQL = @SQL +
        N' SELECT ID, KOD=HESAPKODU,
              ROOTKOD = CASE WHEN HESAPKODU = REVERSE(SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1))) THEN ''.''
                        ELSE REVERSE(SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1))) END,
              AD=HESAPADI, TUR=N''Başlık'', KALAN=NULL, FIYAT=NULL, KUR=NULL, STOKMARKA=NULL, STOKMODEL=NULL,
              KDV=NULL, OTVYUZDE=NULL, OTVMIKTAR=NULL, KDVDURUM=NULL, PAKET=CAST(0 AS SMALLINT), IZLEME=CAST(0 AS SMALLINT),
              BIRIM=NULL, STOKGRUBU=NULL, MASRAFID=NULL, OZELKOD=NULL
           FROM HESAPPLANI WHERE VARSAYILAN = ' + @Varsayilan + N'
           UNION ALL ';

    -- MASRAFGELIR (hizmet/baslik) + FIYATLAR
    SET @SQL = @SQL +
        N' SELECT M.ID, KOD=M.KOD,
              ROOTKOD = CASE WHEN M.KOD = REVERSE(SUBSTRING(REVERSE(M.KOD),CHARINDEX(''.'',REVERSE(M.KOD),1)+1,LEN(M.KOD)-(CHARINDEX(''.'',REVERSE(M.KOD),1)-1))) THEN ''.''
                        ELSE REVERSE(SUBSTRING(REVERSE(M.KOD),CHARINDEX(''.'',REVERSE(M.KOD),1)+1,LEN(M.KOD)-(CHARINDEX(''.'',REVERSE(M.KOD),1)-1))) END,
              M.AD, TUR = CASE WHEN M.BASLIK=0 THEN N''Hizmet'' ELSE N''Başlık'' END, KALAN=NULL,
              FIYAT = CASE WHEN M.BASLIK=1 THEN NULL ELSE ISNULL(F.FIYAT,-1) END,
              KUR   = CASE WHEN M.BASLIK=1 THEN NULL ELSE F.KUR END,
              STOKMARKA=NULL, STOKMODEL=NULL,
              KDV = CASE WHEN M.BASLIK=1 THEN NULL ELSE M.KDV END, OTVYUZDE=NULL, OTVMIKTAR=NULL,
              KDVDURUM = CASE WHEN M.BASLIK=1 THEN NULL ELSE F.KDVDURUM END,
              PAKET=CAST(0 AS SMALLINT), IZLEME=CAST(0 AS SMALLINT),
              BIRIM = CASE WHEN M.BASLIK=1 THEN NULL ELSE ISNULL(M.BIRIM,' + @sBirimi + N') END,
              STOKGRUBU=NULL, MASRAFID=NULL, OZELKOD=M.OZELKOD
           FROM MASRAFGELIR M
              LEFT OUTER JOIN FIYATLAR F ON M.ID=F.HIZMETID AND F.FIYATADI=' + @sFiyat + N' AND F.PAKETID=0 AND F.SATIS=' + @Satis01 + @JKA + N'
           WHERE GELIRMI=' + @Gelirmi + N' AND DURUM>0 ';

    IF @Kod    IS NOT NULL AND @Kod    <> N'' SET @SQL = @SQL + N' AND M.KOD LIKE N''%'' + @pKod + N''%'' ';
    IF @Ad     IS NOT NULL AND @Ad     <> N'' SET @SQL = @SQL + N' AND M.AD LIKE N''%'' + @pAd + N''%'' ';
    IF @Barkod IS NOT NULL AND @Barkod <> N'' SET @SQL = @SQL + N' AND ISNULL(M.BARKOD,N'''') LIKE N''%'' + @pBarkod + N''%'' ';
    IF @SubeVar = 1 SET @SQL = @SQL + N' AND M.SUBEID IN (0,' + CAST(@SubeID AS NVARCHAR(20)) + N') ';

    SET @SQL = @SQL + CASE WHEN @SikAranan = 1 THEN N' ORDER BY KA.SAY DESC, KA.DEGISTIRMETARIHI DESC '
                           WHEN @SonAranan = 1 THEN N' ORDER BY KA.DEGISTIRMETARIHI DESC '
                           ELSE N' ORDER BY 2 ' END;

    EXEC sp_executesql @SQL,
         N'@pKod NVARCHAR(100), @pAd NVARCHAR(150), @pBarkod NVARCHAR(50)',
         @pKod = @Kod, @pAd = @Ad, @pBarkod = @Barkod;
END;
GO

-- ---- PROCEDURE: sp_prog_stokhizmetara_stok_json2  (kaynak: GenDepoUpdate67) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokHizmetAra_Stok_Json2
    @Baslik   NVARCHAR(MAX) = N'',    -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi)
    @Kosullar NVARCHAR(MAX)           -- filtreler (JSON)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler ----
    DECLARE @SelectList  NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @Depo        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Depo') AS INT), 0);
    DECLARE @FiyatAdi    INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.FiyatAdi') AS INT), 0);
    DECLARE @RehberID    INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.RehberID') AS INT), 0);
    DECLARE @Satis       BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Satis') AS BIT), 1);   -- 1=cikis(satis), 0=giris(alis)
    DECLARE @Dil         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Dil') AS INT), -1);
    DECLARE @CariDoviz   NVARCHAR(10)  = ISNULL(JSON_VALUE(@Kosullar,'$.CariDoviz'), N'TL');
    DECLARE @AdetBirimi  INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AdetBirimi') AS INT), 0);
    DECLARE @TopN        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 200);
    DECLARE @Mod         SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod') AS SMALLINT), 4);
    DECLARE @KulId       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @Kod         NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.Kod');
    DECLARE @Ad          NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.Ad');
    DECLARE @Barkod      NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.Barkod');
    DECLARE @Serino      NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.Serino');
    DECLARE @Lotno       NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.Lotno');
    DECLARE @GrubuID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GrubuID') AS INT);
    DECLARE @OzellikID   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.OzellikID') AS INT);
    DECLARE @MarkaID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.MarkaID') AS INT);
    DECLARE @ModelID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.ModelID') AS INT);
    DECLARE @IcerikID    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.IcerikID') AS INT);
    DECLARE @KategoriID  INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KategoriID') AS INT);
    DECLARE @KategoriArama BIT         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KategoriArama') AS BIT), 0);
    DECLARE @Esdeger     NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.Esdeger');   -- csv int id (app-uretimi, guvenilir)
    DECLARE @BuFirma     BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.BuFirma') AS BIT), 0);
    DECLARE @Olmayanlar  BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Olmayanlar') AS BIT), 0);
    DECLARE @Sayim       BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Sayim') AS BIT), 0);
    DECLARE @SayimID     INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SayimID') AS INT), 0);
    DECLARE @Birim2Getir BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Birim2Getir') AS BIT), 1); -- sayim/recete disinda BIRIM2 branch

    DECLARE @sDepo   NVARCHAR(20)  = CAST(@Depo AS NVARCHAR(20));
    DECLARE @sFiyat  NVARCHAR(20)  = CAST(@FiyatAdi AS NVARCHAR(20));
    DECLARE @sDil    NVARCHAR(20)  = CAST(@Dil AS NVARCHAR(20));
    DECLARE @sBirimi NVARCHAR(20)  = CAST(@AdetBirimi AS NVARCHAR(20));
    DECLARE @Top     NVARCHAR(30)  = CASE WHEN @TopN > 0 THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') ' ELSE N'' END;
    DECLARE @SonAranan BIT = CASE WHEN @Mod IN (5,6) AND @KulId IS NOT NULL AND @Modul IS NOT NULL THEN 1 ELSE 0 END;
    -- Mod=6 -> SIK Aranan: ayni KULLANICI_ARAMA join'i, siralama SAY (kullanim adedi) desc
    DECLARE @SikAranan BIT = CASE WHEN @Mod = 6 AND @KulId IS NOT NULL AND @Modul IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @HasBarkod BIT = CASE WHEN @Barkod IS NOT NULL AND @Barkod <> N'' AND @SonAranan = 0 THEN 1 ELSE 0 END;

    -- ---- Ortak filtre (WHERE eklentileri; iki branch de kullanir) ----
    DECLARE @Filt NVARCHAR(MAX) = N'';
    IF @SonAranan = 0
    BEGIN
        IF @KategoriArama = 0
        BEGIN
            IF @Kod    IS NOT NULL AND @Kod    <> N'' SET @Filt = @Filt + N' AND (S.KOD LIKE N''%'' + @pKod + N''%'' OR S.URUNNO LIKE N''%'' + @pKod + N''%'') ';
            IF @Ad     IS NOT NULL AND @Ad     <> N'' SET @Filt = @Filt + N' AND S.STOKADI LIKE N''%'' + @pAd + N''%'' ';
            IF @HasBarkod = 1                         SET @Filt = @Filt + N' AND ( STB.BARKOD LIKE N''%'' + @pBarkod + N''%'' OR @pBarkod LIKE REPLACE(REPLACE(REPLACE(STB.BARKOD,''O'',''_''),''P'',''_''),''Q'',''_'') ) ';
            -- SERI NO: STOKSERILOT.SERINO (STOKIZLEME'de SERINO kolonu YOK; SERILOTID FK).
            IF @Serino IS NOT NULL AND @Serino <> N'' SET @Filt = @Filt + N' AND S.ID IN (SELECT SSL.STOKID FROM STOKSERILOT SSL WHERE SSL.SERINO LIKE N''%'' + @pSerino + N''%'') ';
            -- LOT NO: STOKSERILOT.LOTNO (+LOTNO_EX serbest alan).
            IF @Lotno  IS NOT NULL AND @Lotno  <> N'' SET @Filt = @Filt + N' AND S.ID IN (SELECT SSL2.STOKID FROM STOKSERILOT SSL2 WHERE SSL2.LOTNO LIKE N''%'' + @pLotno + N''%'' OR SSL2.LOTNO_EX LIKE N''%'' + @pLotno + N''%'') ';
            IF @GrubuID   > 0 SET @Filt = @Filt + N' AND S.GRUBU='   + CAST(@GrubuID   AS NVARCHAR(20)) + N' ';
            IF @OzellikID > 0 SET @Filt = @Filt + N' AND S.OZELLIK=' + CAST(@OzellikID AS NVARCHAR(20)) + N' ';
            IF @MarkaID   > 0 SET @Filt = @Filt + N' AND S.MARKA='   + CAST(@MarkaID   AS NVARCHAR(20)) + N' ';
            IF @ModelID   > 0 SET @Filt = @Filt + N' AND S.MODEL='   + CAST(@ModelID   AS NVARCHAR(20)) + N' ';
            IF @IcerikID  > 0 SET @Filt = @Filt + N' AND S.ICERIK='  + CAST(@IcerikID  AS NVARCHAR(20)) + N' ';
        END
        ELSE IF @KategoriID > 0
            SET @Filt = @Filt + N' AND S.KATEGORI=' + CAST(@KategoriID AS NVARCHAR(20)) + N' ';

        IF @Esdeger IS NOT NULL AND @Esdeger <> N''
            SET @Filt = @Filt + N' AND S.ID IN (' + @Esdeger + N') ';
        IF @Sayim = 1
            SET @Filt = @Filt + N' AND S.KULLANIM=1 AND S.ID NOT IN (SELECT SSK.STOKID FROM STOKSAYIMKALEMLERI SSK WHERE SSK.SAYIMID=' + CAST(@SayimID AS NVARCHAR(20)) + N') ';
    END;

    -- SifirGelmesin (cikis + olmayanlar kapali -> sadece stogu olan)
    DECLARE @Sifir NVARCHAR(MAX) = N'';
    IF @Satis = 1 AND @Olmayanlar = 0
        SET @Sifir = N' AND ISNULL((SELECT SUM(KALAN) FROM STOKDURUM SD WHERE SD.STOKID=S.ID AND SD.DEPOID=' + @sDepo + N'),0) > 0 ';

    -- Join eklentileri (PERF: sadece gerekince)
    DECLARE @JBuFirma NVARCHAR(300) = CASE WHEN @BuFirma = 1
        THEN N' INNER JOIN ISORTAGI IO ON S.ID=IO.STOKID AND IO.REHBERID=' + CAST(@RehberID AS NVARCHAR(20)) + N' ' ELSE N'' END;
    DECLARE @JKA NVARCHAR(300) = CASE WHEN @SonAranan = 1
        THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID=S.ID AND KA.KULID=' + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL=' + CAST(@Modul AS NVARCHAR(20)) + N' ' ELSE N'' END;
    DECLARE @Satis01 NVARCHAR(1) = CAST(@Satis AS NVARCHAR(1));
    DECLARE @MasrafKol NVARCHAR(40) = CASE WHEN @Satis = 0 THEN N' S.MASRAFID AS MASRAFID,' ELSE N' S.GELIRID AS MASRAFID,' END;
    DECLARE @GENINIJ NVARCHAR(MAX) =
        N' LEFT OUTER JOIN GENINI StokMarka ON StokMarka.DEGER=S.MARKA AND StokMarka.DIL=' + @sDil + N' AND StokMarka.BOLUM=-2701 ' +
        N' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER=S.MODEL AND StokModel.DIL=' + @sDil + N' AND StokModel.BOLUM=CAST(''-2701''+CAST(S.MARKA AS VARCHAR(10)) AS INT) ' +
        N' LEFT OUTER JOIN GENINI StokGrubu ON S.GRUBU=StokGrubu.DEGER AND StokGrubu.DIL=' + @sDil + N' AND StokGrubu.BOLUM=-2704 ';

    -- ---- BRANCH 1: ANABIRIM ----
    DECLARE @B1 NVARCHAR(MAX) =
        N' SELECT ' + @Top + N'
            S.ID, S.KOD, S.URUNNO, AD=STOKADI, TUR=''Stok'',
            KALAN=ISNULL((SELECT SUM(KALAN) FROM STOKDURUM SD WHERE SD.STOKID=S.ID AND SD.DEPOID=' + @sDepo + N'),0),
            FIYAT=ISNULL(SF.FIYAT,-1), KUR=ISNULL(SF.KUR,@pDoviz),
            STOKMARKA=StokMarka.ANAHTAR, STOKMODEL=StokModel.ANAHTAR,
            KDV=S.KDV, S.OTVYUZDE, S.OTVMIKTAR, KDVDURUM=SF.KDVDURUM,
            PAKET=ISNULL(S.PAKET,0), IZLEME=ISNULL(S.IZLEME,0),
            BIRIM=ISNULL(S.ANABIRIM,' + @sBirimi + N'), STOKGRUBU=StokGrubu.ANAHTAR,' + @MasrafKol + N' S.OZELKOD ' + @SelectList + N'
          FROM STOKLAR S (NOLOCK)
            LEFT OUTER JOIN STOKFIYAT SF (NOLOCK) ON S.ID=SF.STOKID AND SF.BIRIM=S.ANABIRIM AND SF.FIYATADI=' + @sFiyat + N' AND SF.PAKETID=0 AND SF.SATIS=' + @Satis01 + N' ' +
            @GENINIJ + @JBuFirma + @JKA +
            CASE WHEN @HasBarkod = 1 THEN N' INNER JOIN STOKBARKOD STB ON S.ID=STB.STOKID AND S.ANABIRIM=STB.BARKODBIRIMI ' ELSE N'' END +
        N' WHERE S.DURUM=1 ' + @Sifir + @Filt;

    -- ---- BRANCH 2: BIRIM2 (alt birim; sadece BIRIM2<>ANABIRIM olanlar) ----
    -- Son Aranan tek-select (UNION sonrasi KA.tarih ORDER edilemez) -> branch2 kapali
    DECLARE @B2 NVARCHAR(MAX) = N'';
    IF @Sayim = 0 AND @Birim2Getir = 1 AND @SonAranan = 0
        SET @B2 =
        N' UNION ALL SELECT ' + @Top + N'
            S.ID, KOD=S.KOD+''#'', S.URUNNO, AD=STOKADI, TUR=''Stok'',
            KALAN=ISNULL((SELECT ROUND(SUM(KALAN)/S.BIRIM2MIKTAR,0,1) FROM STOKDURUM SD WHERE SD.STOKID=S.ID AND SD.DEPOID=' + @sDepo + N'),0),
            FIYAT=ISNULL(SF.FIYAT,-1), KUR=ISNULL(SF.KUR,@pDoviz),
            STOKMARKA=StokMarka.ANAHTAR, STOKMODEL=StokModel.ANAHTAR,
            KDV=S.KDV, S.OTVYUZDE, S.OTVMIKTAR, KDVDURUM=SF.KDVDURUM,
            PAKET=ISNULL(S.PAKET,0), IZLEME=ISNULL(S.IZLEME,0),
            BIRIM=ISNULL(S.BIRIM2,' + @sBirimi + N'), STOKGRUBU=StokGrubu.ANAHTAR,' + @MasrafKol + N' S.OZELKOD ' + @SelectList + N'
          FROM STOKLAR S (NOLOCK)
            LEFT OUTER JOIN STOKFIYAT SF (NOLOCK) ON S.ID=SF.STOKID AND SF.BIRIM=S.BIRIM2 AND SF.FIYATADI=' + @sFiyat + N' AND SF.PAKETID=0 AND SF.SATIS=' + @Satis01 + N' ' +
            @GENINIJ + @JBuFirma + @JKA +
            CASE WHEN @HasBarkod = 1 THEN N' INNER JOIN STOKBARKOD STB ON S.ID=STB.STOKID AND S.BIRIM2=STB.BARKODBIRIMI ' ELSE N'' END +
        N' WHERE S.DURUM=1 AND (S.ANABIRIM <> ISNULL(S.BIRIM2,S.ANABIRIM)) ' + @Sifir + @Filt;

    -- ---- ORDER ----
    DECLARE @Order NVARCHAR(150) = CASE WHEN @SikAranan = 1 THEN N' ORDER BY KA.SAY DESC, KA.DEGISTIRMETARIHI DESC '
                                        WHEN @SonAranan = 1 THEN N' ORDER BY KA.DEGISTIRMETARIHI DESC '
                                        ELSE N' ORDER BY 2 ' END;

    DECLARE @SQL NVARCHAR(MAX) = @B1 + @B2 + @Order;

    EXEC sp_executesql @SQL,
         N'@pKod NVARCHAR(100), @pAd NVARCHAR(150), @pBarkod NVARCHAR(50), @pSerino NVARCHAR(50), @pLotno NVARCHAR(50), @pDoviz NVARCHAR(10)',
         @pKod = @Kod, @pAd = @Ad, @pBarkod = @Barkod, @pSerino = @Serino, @pLotno = @Lotno, @pDoviz = @CariDoviz;
END;
GO

-- ---- PROCEDURE: sp_prog_stoktalep_liste_json2  (kaynak: GenDepoUpdate84) ----
-- ============================================================
-- GenDepoUpdate84.sql
-- sp_Prog_StokTalep_Liste_Json2 : bellek grant'i duzeltmesi (istenen 283,4 MB)
--
-- GenDepoUpdate83 (Dokuman listesi) ile AYNI SINIF hata. Plan cache taramasinda
--   bu sorgu 283,4 MB "istenen" bellekle listenin BASINDA cikti; gereken minimum
--   yalnizca 7,5 MB. SQL Express'te sorgu-bellek semaforu 10 MB civarina dustugunde
--   bu istek karsilanamaz ve Stok Talep listesi acilirken program KILITLENIR
--   (RESOURCE_SEMAPHORE, timeout yok, hata da vermez).
--
-- KOK NEDEN: "LEFT OUTER JOIN SIPARISDETAY SD" KOSULSUZ duruyordu. Talep basina
--   detay satiri kadar satir uretiyor, bunu da "SELECT DISTINCT TOP (200)" topluyordu.
--   DISTINCT tum kolonlar (genis satir) uzerinde hash/sort demek. SD'ye gercekte
--   yalnizca iki yerde ihtiyac vardi:
--     1) opsiyonel AraKod/AraStok filtresi (STOKLAR join'i zaten kosulluydu),
--     2) KAYNAK kolonunun 'Uretimden' kosulu.
--   Ikisi de EXISTS ile satir cogaltmadan ifade edilebiliyor.
--
-- YAN FAYDA - GIZLI KAYIT COGALTMA HATASI: DISTINCT satirlari birlestirirken
--   KAYNAK degeri detay satirina gore degistigi icin ayni talep hem KAYNAK=''
--   hem KAYNAK='Uretimden' ile IKI KEZ listelenebiliyordu. EXISTS'e gecince
--   talep basina tek satir kalir.
--
-- COZUM: SD join'i tamamen kaldirildi, AraKod/AraStok ve KAYNAK EXISTS'e cevrildi,
--   DISTINCT kaldirildi.
--
-- NOT (duzeltilmedi, bilgi): SELECT listesinde "PROJEKOD=(...)" korele alt sorgusu
--   UC KEZ birebir tekrar ediyor. Kolon sayisi/sirasi degisirse istemci tarafi
--   etkilenebilecegi icin dokunulmadi.
-- ============================================================
-- ============================================================
-- sp_Prog_StokTalep_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR); @Kosullar = filtreler (JSON).
--   @Kosullar = '{"Mod":4,"TarihBas":"2026-01-01",...}' -> JSON_VALUE ile yerel degiskenlere.
--   Amac: sp_Prog_StokTalep_Liste (tipli-param) ile PARITE (ayni sonuc kumesi).
--   Govde tipli-param SP ile BIREBIR aynidir; sadece parametre alimi JSON'a cevrildi.
--   @Mod: 1=Tum (TOP yok), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.DEGISTIRMETARIHI)
--   PK: SIPARIS.ID (S.ID). Belge turu S.TUR=105 (Stok Talep).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokTalep_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR); StokTalep'te genelde ''
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 200);
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Pasif      BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);   -- StokTalep'te no-op (imza uyumu)
    DECLARE @TarihBas   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    -- Yeni filtreler (Sube filtreleri kaldirildi: S.SUBE/S.GIRISSUBE kolonlari SIPARIS'te yok, bozuktu)
    DECLARE @TalepEden    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.TalepEden') AS INT);   -- S.SATICIKODU (REHBER/personel)
    DECLARE @CikisDepo    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.CikisDepo') AS INT);   -- S.CIKISDEPO
    DECLARE @GirisDepo    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GirisDepo') AS INT);   -- S.GIRISDEPO
    DECLARE @TalepNo      NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.TalepNo');                       -- S.SIPARISNO LIKE
    DECLARE @OzelKod      NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.OzelKod');                       -- S.OZELKOD LIKE
    DECLARE @UretimEmirNo NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.UretimEmirNo');                  -- URETIMEMRI.EMIRNO LIKE (EXISTS)
    DECLARE @Kod          NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.Kod');                            -- AraKod -> STOKLAR.KOD veya URUNNO LIKE (detay uzerinden EXISTS)
    DECLARE @Stok         NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Stok');                           -- AraStok -> STOKLAR.STOKADI LIKE (detay uzerinden EXISTS)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    -- DISTINCT + ORDER BY kurali: KA sort kolonu SELECT listesinde olmali (yoksa hata)
    DECLARE @KaCol NVARCHAR(60) = CASE WHEN @Mod = 3 THEN N', KA.SAY'
                                       WHEN @Mod = 5 THEN N', KA.DEGISTIRMETARIHI'
                                       ELSE N'' END;

    SET @SQL = N'
    SELECT ' + @Top + N' S.ID,S.DURUM,
    TALEPTARIH=S.SIPARISTARIH, TALEPNO=S.SIPARISNO,
    S.DETAYBOLUMU,
    TALEPEDENAD=(SELECT FIRMA FROM REHBER R WHERE S.SATICIKODU = R.ID),
    TALEPEDENBIRIM=(select DEPARTMAN=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 ) from ROLLER ROL where ROL.ID=S.BOLUM),
    BIRIMONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLAYACAK = R.ID),
    BIRIMONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLAYAN = R.ID),
    TALEPONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYACAK = R.ID),
    TALEPONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYAN = R.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    S.ACIKLAMA,S.OZELKOD,
    GIRISDEPOSU=(select DEPOADI from DEPOLAR D where D.ID=S.GIRISDEPO),
    S.TIPI,S.REHBERID,S.TUR,S.SUBEID,
    S.ONAYLAYACAK,S.ONAYLAYAN,
    KAYNAK= case when (S.TUR=105) and exists (
                    select 1 from SIPARISDETAY SD2
                     where SD2.SIPARISID = S.ID
                       and exists (select 1 from SIPARISDETAY X
                                    inner join URETIMEMRIDETAY UED on UED.ID = SD2.YERID
                                    where X.YERI = 467 and X.YERID = UED.ID))
                 then ''Üretimden'' else '''' end,
    HEDEF=  case when (S.TUR=105)and(435 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then ''Transfer'' end'
    + @SelectList + @KaCol + N'
    from SIPARIS S (NOLOCK) inner join REHBER R on R.ID = S.REHBERID '
    -- SIPARISDETAY/STOKLAR ARTIK JOIN DEGIL: bkz. asagidaki AraKod/AraStok EXISTS'leri.
    --   Onceki halde "LEFT OUTER JOIN SIPARISDETAY SD" KOSULSUZ duruyordu; talep basina
    --   detay satiri kadar satir uretiyor, bunu da DISTINCT topluyordu. Genis satirlarda
    --   (TOP 200 x tum kolonlar) bu, 283 MB bellek grant'i demekti -> SQL Express'te
    --   RESOURCE_SEMAPHORE'da sonsuz bekleme.
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 (unique KULID,MODUL,KAYITID)
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = S.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' where S.TUR=105 ';

    -- Tarih araligi (Filtre modunda; Tum/Son/Sik'te app NULL gonderir) - parametreli
    IF @TarihBas IS NOT NULL
        SET @SQL = @SQL + N' and SIPARISTARIH >= @pTarihBas ';
    IF @TarihBit IS NOT NULL
        SET @SQL = @SQL + N' and SIPARISTARIH <= @pTarihBit ';

    -- Talep Eden / Cikis Depo / Giris Depo (secili degilse app 0/NULL gonderir) - guvenli int cast
    IF @TalepEden IS NOT NULL AND @TalepEden > 0
        SET @SQL = @SQL + N' and S.SATICIKODU = ' + CAST(@TalepEden AS NVARCHAR(20)) + N' ';
    IF @CikisDepo IS NOT NULL AND @CikisDepo > 0
        SET @SQL = @SQL + N' and S.CIKISDEPO = ' + CAST(@CikisDepo AS NVARCHAR(20)) + N' ';
    IF @GirisDepo IS NOT NULL AND @GirisDepo > 0
        SET @SQL = @SQL + N' and S.GIRISDEPO = ' + CAST(@GirisDepo AS NVARCHAR(20)) + N' ';

    -- Talep No / Ozel Kod / Uretim Emir No (LIKE) - parametreli (SQL injection guvenli)
    IF @TalepNo IS NOT NULL AND @TalepNo <> N''
        SET @SQL = @SQL + N' and S.SIPARISNO LIKE @pTalepNo ';
    IF @OzelKod IS NOT NULL AND @OzelKod <> N''
        SET @SQL = @SQL + N' and S.OZELKOD LIKE @pOzelKod ';
    -- Uretim Emir No: StokTalep'te SIPARIS.DETAYBOLUMU alaninda DOGRUDAN tutuluyor
    IF @UretimEmirNo IS NOT NULL AND @UretimEmirNo <> N''
        SET @SQL = @SQL + N' and S.DETAYBOLUMU LIKE @pUretimEmirNo ';
    -- AraKod / AraStok: detay satirlarinda urun arama. JOIN yerine EXISTS - satir
    --   cogaltmaz, dolayisiyla DISTINCT'e de gerek kalmaz.
    IF @Kod IS NOT NULL AND @Kod <> N''
        SET @SQL = @SQL + N' and exists (select 1 from SIPARISDETAY SDK
                                          inner join STOKLAR STK on STK.ID = SDK.URUNID
                                          where SDK.SIPARISID = S.ID
                                            and (STK.KOD LIKE @pKod OR STK.URUNNO LIKE @pKod)) ';
    IF @Stok IS NOT NULL AND @Stok <> N''
        SET @SQL = @SQL + N' and exists (select 1 from SIPARISDETAY SDS
                                          inner join STOKLAR STK on STK.ID = SDS.URUNID
                                          where SDS.SIPARISID = S.ID
                                            and STK.STOKADI LIKE @pStok) ';

    -- Son/Sik siralamasi (KULLANICI_ARAMA); aksi halde orijinal: SIPARISTARIH desc
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    ELSE IF @OrderBy IS NULL OR @OrderBy = N'' SET @OrderBy = N'SIPARISTARIH desc';

    SET @SQL = @SQL + N' order by ' + @OrderBy;

    -- LIKE degerleri: '%' + deger + '%' (parametreli gonderilir)
    DECLARE @pTalepNoV      NVARCHAR(200) = N'%' + ISNULL(@TalepNo, N'')      + N'%';
    DECLARE @pOzelKodV      NVARCHAR(200) = N'%' + ISNULL(@OzelKod, N'')      + N'%';
    DECLARE @pUretimEmirNoV NVARCHAR(200) = N'%' + ISNULL(@UretimEmirNo, N'') + N'%';
    DECLARE @pKodV          NVARCHAR(200) = N'%' + ISNULL(@Kod, N'')          + N'%';
    DECLARE @pStokV         NVARCHAR(200) = N'%' + ISNULL(@Stok, N'')         + N'%';

    EXEC sp_executesql @SQL,
         N'@pTarihBas DATETIME, @pTarihBit DATETIME, @pTalepNo NVARCHAR(200), @pOzelKod NVARCHAR(200), @pUretimEmirNo NVARCHAR(200), @pKod NVARCHAR(200), @pStok NVARCHAR(200)',
         @pTarihBas = @TarihBas, @pTarihBit = @TarihBit,
         @pTalepNo = @pTalepNoV, @pOzelKod = @pOzelKodV, @pUretimEmirNo = @pUretimEmirNoV, @pKod = @pKodV, @pStok = @pStokV;
END;
GO

-- ---- PROCEDURE: sp_prog_uretim_liste_json2  (kaynak: GenDepoUpdate116) ----
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
        FB.YERI, FB.YERID,   -- kaynak belge bagi (or. YERI=134 transfer)

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
        DURUMNEREDEN = case when FB.YERI = 134 then N''Transfer''
                            when (415 in (select YERI from FATURA where FATBASID=FB.ID)) then N''Sipari' + NCHAR(351) + N'ten''
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

-- ---- PROCEDURE: sp_prog_uretimemri_liste_json2  (kaynak: GenDepoUpdate86) ----
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
