-- ============================================================
-- GenDepoUpdate31 : sp_Prog_AlisSatis_Siparis_Json2  (SELF-CONTAINED - TEK SP)
--   ANA DB. Siparis liste. @Baslik (SELECT ek kolon) + @Kosullar (JSON). Wrapper KALDIRILDI.
--   Kullanilmayan sp_Prog_AlisSatis_Siparis DROP edilir.
--   PERF: metin filtreleri PARAMETRELI (REPLACE-concat degil) -> plan tekrar-kullanimi.
--   DEPLOY: UTF-8 (sqlcmd -f 65001) SART - Turkce literaller.
--   IDEMPOTENT: CREATE OR ALTER + DROP IF EXISTS. SET QUOTED_IDENTIFIER ON.
-- ============================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
    DECLARE @SubeIDList NVARCHAR(MAX) = ISNULL(JSON_VALUE(@Kosullar,'$.SubeIDList'), N'');
    DECLARE @Faturano   NVARCHAR(100) = ISNULL(JSON_VALUE(@Kosullar,'$.Faturano'),  N'');
    DECLARE @AraBaslik  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Baslik'),    N'');
    DECLARE @CariFirma  NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.CariFirma'), N'');
    DECLARE @Aciklama   NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Aciklama'),  N'');
    DECLARE @Stok       NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.Stok'),      N'');

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
''Servisden''    when (F.TUR=9)and(428 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Talepten''    when (F.TUR=101)and(465 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Üretimden''    else '''' end,   DURUMNEREYE = case  	when (F.TUR=9)and(407 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''     	when (F.TUR=9)and(406 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye''   	when (F.TUR=101)and(428 in (select YERI from SIPARISDETAY where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Siparişe''   	when (F.TUR=19)and(410 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''    	when (F.TUR=19)and(409 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye''    when (F.TUR=19)and(473 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Fişe''     	when (F.TUR=19)and(429 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Konsinyeye''  	when (F.TUR=19)and(415 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine''  	when (F.TUR=19)and(420 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine''  	else '''' end,     TESLIMTARIHI =(Select Min(TESLIMTARIHI) from SIPARISDETAY Where SIPARISID=F.ID ), FATURA_GON_TARIHI=null,  ZARFID=null,ZARF=null,ISEMRIDURUM=isnull((select I.DURUM from ISEMRI I where I.YERI=F.TUR and I.YERID=F.ID),-1),F.YAZDIRILDI,  F.ONAYLAYACAK,F.ONAYLAYAN,EFATURADURUM=0 ';

    DECLARE @SQL NVARCHAR(MAX) = '
        SELECT DISTINCT TOP (' + CAST(@TopN AS NVARCHAR) + ') ' + @BaseSelect +
        CASE WHEN @Baslik IS NOT NULL AND @Baslik <> '' THEN   @Baslik ELSE '' END + '
from SIPARIS F (NOLOCK) inner join REHBER R on R.ID = F.REHBERID  
INNER JOIN SIPARISDETAY SD ON F.ID = SD.SIPARISID 
LEFT OUTER JOIN STOKLAR ST ON ST.ID = SD.URUNID 
LEFT OUTER JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID 
LEFT OUTER JOIN DEPOLAR D ON D.ID=F.CIKISDEPO
        WHERE F.TUR = @Tur';

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

    SET @SQL += ' ORDER BY F.SIPARISTARIH DESC';

    EXEC sp_executesql
        @SQL,
        N'@Tur SMALLINT, @StartDate DATETIME, @EndDate DATETIME, @Baslik NVARCHAR(MAX), @SubeIDList NVARCHAR(MAX),
          @Faturano NVARCHAR(50), @AraBaslik NVARCHAR(150), @CariFirma NVARCHAR(100), @Aciklama NVARCHAR(100), @Stok NVARCHAR(150)',
        @Tur, @StartDate, @EndDate, @Baslik, @SubeIDList,
        @Faturano, @AraBaslik, @CariFirma, @Aciklama, @Stok;

    DROP TABLE #SubeIDs;
END
GO
IF OBJECT_ID('dbo.sp_Prog_AlisSatis_Siparis','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Prog_AlisSatis_Siparis;
GO
PRINT 'sp_Prog_AlisSatis_Siparis_Json2: self-contained + parametreli filtreler; sp_Prog_AlisSatis_Siparis kaldirildi';
