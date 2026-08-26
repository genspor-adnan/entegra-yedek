-- ======================================================================
-- KONSOLIDE UPDATE 08 - LOG / AUDIT
-- ======================================================================
-- 5 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- PROCEDURE: sp_api_log_detaysil_json  (kaynak: GenDepoUpdate71) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Log_DetaySil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Tablo sysname       = JSON_VALUE(@Kosullar, '$.Tablo');
    DECLARE @Kosul NVARCHAR(MAX) = JSON_VALUE(@Kosullar, '$.Kosul');
    DECLARE @TabNo INT           = TRY_CAST(JSON_VALUE(@Kosullar, '$.TabNo') AS INT);
    IF @Tablo IS NULL OR @TabNo IS NULL OR NULLIF(LTRIM(RTRIM(ISNULL(@Kosul, N''))), N'') IS NULL
        THROW 51001, N'Tablo, TabNo ve Kosul zorunlu.', 1;
    DECLARE @UstTabNo INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.UstTabNo') AS INT), 0);
    DECLARE @UstId    BIGINT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.UstId')    AS BIGINT), 0);
    DECLARE @RehberId BIGINT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS BIGINT), 0);
    DECLARE @StokId   BIGINT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.StokId')   AS BIGINT), 0);
    DECLARE @KulId    INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip       VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Istasyon VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    DECLARE @n INT;
    EXEC dbo.sp_Api_Log_Yaz_Ic
        @Tablo    = @Tablo,
        @Kosul    = @Kosul,
        @TabNo    = @TabNo,
        @UstTabNo = @UstTabNo, @UstId = @UstId,
        @KulId    = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Istasyon,
        @RehberId = @RehberId, @StokId = @StokId,
        @Yazilan  = @n OUTPUT;

    SELECT (SELECT 1 AS Sonuc, @n AS Yazilan FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_log_kayitsil_json  (kaynak: GenDepoUpdate71) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Log_KayitSil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Tablo   sysname = JSON_VALUE(@Kosullar, '$.Tablo');
    DECLARE @TabNo   INT     = TRY_CAST(JSON_VALUE(@Kosullar, '$.TabNo')   AS INT);
    DECLARE @KayitId BIGINT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);
    IF @Tablo IS NULL OR @TabNo IS NULL OR @KayitId IS NULL
        THROW 51001, N'Tablo, TabNo ve KayitId zorunlu.', 1;
    DECLARE @UstTabNo INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.UstTabNo') AS INT), 0);
    DECLARE @UstId    BIGINT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.UstId')    AS BIGINT), 0);
    DECLARE @RehberId BIGINT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS BIGINT), 0);
    DECLARE @StokId   BIGINT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.StokId')   AS BIGINT), 0);
    DECLARE @KulId    INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip       VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Istasyon VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    DECLARE @n INT;
    EXEC dbo.sp_Api_Log_Yaz_Ic
        @Tablo    = @Tablo,
        @KayitId  = @KayitId,
        @TabNo    = @TabNo,
        @UstTabNo = @UstTabNo, @UstId = @UstId,
        @KulId    = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Istasyon,
        @RehberId = @RehberId, @StokId = @StokId,
        @Yazilan  = @n OUTPUT;

    SELECT (SELECT 1 AS Sonuc, @n AS Yazilan FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_log_kaynak_isaretle  (kaynak: GenDepoUpdate143) ----
-- ============================================================
-- 1) IZ BIRAKICI: son "ekleme" log satirini isaretler
--    @AltTip: 3 = kopya, 5 = donusum
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Log_Kaynak_Isaretle
    @TabNo       INT,
    @KayitId     BIGINT,
    @AltTip      TINYINT,
    @KaynakId    BIGINT,
    @KaynakTabNo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@KayitId, 0) <= 0 OR ISNULL(@KaynakId, 0) <= 0 RETURN;

    DECLARE @LogTablo sysname, @Yil INT = YEAR(GETDATE());
    EXEC dbo.sp_Api_Log_YilTablosu @Yil = @Yil, @Tablo = @LogTablo OUTPUT;
    IF OBJECT_ID(@LogTablo, 'U') IS NULL RETURN;

    DECLARE @Alan NVARCHAR(30) = CASE WHEN @AltTip = 5 THEN N'_DonusumKaynak' ELSE N'_KopyaKaynak' END;

    -- Son EKLEME satiri (ayni islemde yazilan kart satiri) isaretlenir.
    DECLARE @SQL NVARCHAR(MAX) = N'
    ;WITH S AS (
        SELECT TOP 1 ID, ALTISLEMTIPI, BILGI
        FROM ' + @LogTablo + N'
        WHERE TABLOID = @t AND KAYITID = @k AND ISLEMTIPI = 1
        ORDER BY ID DESC
    )
    UPDATE S
       SET ALTISLEMTIPI = @a,
           BILGI = CASE
                     WHEN BILGI IS NULL THEN NULL
                     ELSE COMPRESS(
                            JSON_MODIFY(
                              JSON_MODIFY(CAST(DECOMPRESS(BILGI) AS nvarchar(max)),
                                          ''$.' + @Alan + N''', CAST(@s AS nvarchar(20))),
                              ''$._KaynakTablo'', CAST(ISNULL(@kt, @t) AS nvarchar(20))))
                   END;';

    EXEC sp_executesql @SQL,
         N'@t INT, @k BIGINT, @a TINYINT, @s BIGINT, @kt INT',
         @t = @TabNo, @k = @KayitId, @a = @AltTip, @s = @KaynakId, @kt = @KaynakTabNo;
END
GO

-- ---- PROCEDURE: sp_api_log_yaz_ic  (kaynak: GenDepoUpdate157) ----
-- ---- dbo.sp_Api_Log_Yaz_Ic ----

-- ---- dbo.sp_Api_Log_Yaz_Ic  (1 yer) ----

CREATE OR ALTER PROCEDURE dbo.sp_Api_Log_Yaz_Ic
    @Tablo    sysname,
    @Kosul    NVARCHAR(MAX) = NULL,
    -- @Kosul icinde kullanilabilecek TEK parametre: @pB (ust kayit/belge ID'si).
    --   Boylece kosul metni sabit kalir, deger parametreyle baglanir (birlestirme yok).
    @KosulPar BIGINT        = NULL,
    @KayitId  BIGINT        = NULL,
    @TabNo    INT,
    @UstTabNo INT           = 0,
    @UstId    BIGINT        = 0,
    @KulId    INT           = 0,
    @SubeId   INT           = 0,
    @Ip       VARCHAR(45)   = NULL,
    @Istasyon VARCHAR(64)   = NULL,
    @RehberId BIGINT        = 0,
    @StokId   BIGINT        = 0,
    -- 0 = liSil (varsayilan), 1 = liEkle, 2 = liDegistir (ULog.TLogIslem ile ayni)
    @IslemTipi TINYINT      = 0,
    @Yazilan  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Yazilan = 0;

    DECLARE @oid INT = OBJECT_ID(@Tablo);
    IF @oid IS NULL
        THROW 51002, N'Tablo bulunamadi.', 1;

    DECLARE @LogTablo sysname;
    DECLARE @Yil INT = YEAR(GETDATE());
    EXEC dbo.sp_Api_Log_YilTablosu @Yil = @Yil, @Tablo = @LogTablo OUTPUT;

    -- ---- BILGI JSON ifadesi: kolon basina  ,"AD":"deger"  (NULL/bos ve blob HARIC) ----
    -- DIKKAT: "SELECT @v = @v + ..." birikimli atama JOIN + ORDER BY ile
    --   BELIRSIZDIR (SQL Server garanti vermez). Ifade FOR XML PATH ile kurulur.
    DECLARE @Parca NVARCHAR(MAX) =
    (
        SELECT N' + CASE WHEN ' + QUOTENAME(c.name) + N' IS NULL THEN N'''' ELSE ' +
               N'N'',"' + STRING_ESCAPE(c.name, 'json') + N'":"'' + STRING_ESCAPE(' +
               CASE
                 WHEN t.name = 'date'                    THEN N'CONVERT(nvarchar(10), ' + QUOTENAME(c.name) + N', 23)'
                 WHEN t.name IN ('datetime','datetime2','smalldatetime','datetimeoffset')
                                                         THEN N'CONVERT(nvarchar(19), ' + QUOTENAME(c.name) + N', 120)'
                 WHEN t.name = 'time'                    THEN N'CONVERT(nvarchar(8),  ' + QUOTENAME(c.name) + N', 108)'
                 WHEN t.name IN ('float','real')         THEN N'CONVERT(nvarchar(50), ' + QUOTENAME(c.name) + N')'
                 WHEN t.name IN ('money','smallmoney','decimal','numeric')
                                                         THEN N'CONVERT(nvarchar(50), CAST(' + QUOTENAME(c.name) + N' AS decimal(38,6)))'
                 WHEN t.name = 'bit'                     THEN N'CASE WHEN ' + QUOTENAME(c.name) + N' = 1 THEN N''True'' ELSE N''False'' END'
                 WHEN t.name = 'uniqueidentifier'        THEN N'CONVERT(nvarchar(36), ' + QUOTENAME(c.name) + N')'
                 ELSE N'CAST(' + QUOTENAME(c.name) + N' AS nvarchar(max))'
               END +
               N', ''json'') + N''"'' END'
        FROM sys.columns c
            JOIN sys.types t ON t.user_type_id = c.user_type_id
        WHERE c.object_id = @oid
          AND t.name NOT IN ('varbinary','binary','image','text','ntext','xml',
                             'geography','geometry','hierarchyid','sql_variant','timestamp')
          AND c.generated_always_type = 0
          AND c.is_hidden = 0
        ORDER BY c.column_id
        FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)');
    SET @Parca = STUFF(ISNULL(@Parca, N''), 1, 3, N'');   -- bastaki ' + ' at

    IF DATALENGTH(@Parca) = 0 RETURN;

    DECLARE @IdVar BIT = CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = @oid AND name = 'ID')
                              THEN 1 ELSE 0 END;

    -- Satirin KENDI varlik kolonlari (ULog.LogVarlikIDleri ile ayni oncelik).
    --   Bunlar olmadan UInfo silme satirinda cari/stok KOD-AD cozulemiyordu.
--   Tablo iki kolonu da tasiyabilir (FATURA'da hem STOKID hem URUNID var) ve
--   biri NULL olabilir -> ULog gibi SIRAYLA denenir, ilk dolu olan alinir.
--   NOT: COALESCE tek argumanla SOZDIZIMI HATASI verir -> kolon sayisi 1 ise
--   sarmalanmaz, 0 ise NULL yazilir.
    DECLARE @RehIfade NVARCHAR(400), @StkIfade NVARCHAR(400);
    DECLARE @RehLst NVARCHAR(400) =
        (SELECT STRING_AGG(N'NULLIF(CAST(' + QUOTENAME(x.name) + N' AS bigint), 0)', N', ')
                  WITHIN GROUP (ORDER BY x.sira)
           FROM (SELECT c.name, sira = CASE c.name WHEN 'REHBERID' THEN 0 ELSE 1 END
                   FROM sys.columns c
                  WHERE c.object_id = @oid AND c.name IN ('REHBERID','CARIID')) x);
    DECLARE @StkLst NVARCHAR(400) =
        (SELECT STRING_AGG(N'NULLIF(CAST(' + QUOTENAME(x.name) + N' AS bigint), 0)', N', ')
                  WITHIN GROUP (ORDER BY x.sira)
           FROM (SELECT c.name, sira = CASE c.name WHEN 'STOKID' THEN 0 ELSE 1 END
                   FROM sys.columns c
                  WHERE c.object_id = @oid AND c.name IN ('STOKID','URUNID')) x);
    -- Kolon SAYISI ile karar ver: uretilen ifade zaten virgul iceriyor
    --   (NULLIF(..., 0)), o yuzden virgul saymak YANLIS olur.
    DECLARE @RehAdet INT = (SELECT COUNT(*) FROM sys.columns c
                             WHERE c.object_id = @oid AND c.name IN ('REHBERID','CARIID'));
    DECLARE @StkAdet INT = (SELECT COUNT(*) FROM sys.columns c
                             WHERE c.object_id = @oid AND c.name IN ('STOKID','URUNID'));
    SET @RehIfade = CASE WHEN @RehAdet = 0 THEN N'NULL'
                         WHEN @RehAdet = 1 THEN @RehLst
                         ELSE N'COALESCE(' + @RehLst + N')' END;
    SET @StkIfade = CASE WHEN @StkAdet = 0 THEN N'NULL'
                         WHEN @StkAdet = 1 THEN @StkLst
                         ELSE N'COALESCE(' + @StkLst + N')' END;
    DECLARE @KayitIfade NVARCHAR(100) = CASE WHEN @IdVar = 1 THEN N'CAST([ID] AS bigint)' ELSE N'CAST(0 AS bigint)' END;

    DECLARE @Where NVARCHAR(MAX) =
        CASE WHEN NULLIF(LTRIM(RTRIM(ISNULL(@Kosul, N''))), N'') IS NOT NULL THEN @Kosul
             WHEN @IdVar = 1 AND @KayitId IS NOT NULL THEN N'[ID] = @pKayit'
             ELSE N'1=0' END;

    -- REHBERID / STOKID turetimi (ULog.LogYaz kurali)
    DECLARE @UstT INT = CASE WHEN ISNULL(@UstTabNo, 0) = 0 THEN @TabNo ELSE @UstTabNo END;
    DECLARE @Reh BIGINT = NULLIF(ISNULL(@RehberId, 0), 0);
    DECLARE @Stk BIGINT = NULLIF(ISNULL(@StokId, 0), 0);
    DECLARE @RehKendi BIT = 0, @StkKendi BIT = 0;
    IF @Reh IS NULL
    BEGIN
        IF @TabNo IN (71, 73, 74) SET @RehKendi = 1;            -- kartin kendisi -> KAYITID
        ELSE IF @UstT IN (71, 73, 74) SET @Reh = NULLIF(@UstId, 0);
    END
    IF @Stk IS NULL
    BEGIN
        IF @TabNo = 88 SET @StkKendi = 1;
        ELSE IF @UstT = 88 SET @Stk = NULLIF(@UstId, 0);
    END

    DECLARE @sql NVARCHAR(MAX) = N'
INSERT INTO ' + @LogTablo + N' (IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,ALTISLEMTIPI,
        USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI)
SELECT @pIp, @pIst, @pKul, @pSub, @pTip, @pTip,
       @pUstT,
       CASE WHEN ISNULL(@pUstId,0) = 0 THEN ' + @KayitIfade + N' ELSE @pUstId END,
       @pTabNo, ' + @KayitIfade + N',
       NULLIF(CASE WHEN @pRehKendi = 1 THEN ' + @KayitIfade + N'
                   ELSE COALESCE(@pReh, ' + @RehIfade + N') END, 0),
       NULLIF(CASE WHEN @pStkKendi = 1 THEN ' + @KayitIfade + N'
                   ELSE COALESCE(@pStk, ' + @StkIfade + N') END, 0),
       COMPRESS(CAST(N''{'' + ISNULL(STUFF(' + @Parca + N', 1, 1, N''''), N'''') + N''}'' AS nvarchar(max)))
FROM ' + QUOTENAME(OBJECT_SCHEMA_NAME(@oid)) + N'.' + QUOTENAME(OBJECT_NAME(@oid)) + N'
WHERE ' + @Where + N';
SET @pN = @@ROWCOUNT;';

    EXEC sp_executesql @sql,
        N'@pIp varchar(45), @pIst varchar(64), @pKul int, @pSub int, @pUstT int, @pUstId bigint,
          @pTabNo int, @pReh bigint, @pStk bigint, @pRehKendi bit, @pStkKendi bit,
          @pKayit bigint, @pB bigint, @pTip tinyint, @pN int OUTPUT',
        @pIp = @Ip, @pIst = @Istasyon, @pKul = @KulId, @pSub = @SubeId,
        @pUstT = @UstT, @pUstId = @UstId, @pTabNo = @TabNo,
        @pReh = @Reh, @pStk = @Stk, @pRehKendi = @RehKendi, @pStkKendi = @StkKendi,
        @pKayit = @KayitId, @pB = @KosulPar, @pTip = @IslemTipi, @pN = @Yazilan OUTPUT;
END
GO

-- ---- PROCEDURE: sp_api_log_yiltablosu  (kaynak: GenDepoUpdate71) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Log_YilTablosu
    @Yil   INT,
    @Tablo sysname OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @depo sysname = dbo.fn_Api_DepoDBAdi();
    DECLARE @lt   sysname = N'LOG' + CAST(@Yil AS nvarchar(4));
    SET @Tablo = QUOTENAME(@depo) + N'.dbo.' + QUOTENAME(@lt);

    IF OBJECT_ID(@Tablo, 'U') IS NOT NULL RETURN;

    -- DDL ULog.LogYilTablosu ile birebir ayni
    DECLARE @ddl NVARCHAR(MAX) = N'
USE ' + QUOTENAME(@depo) + N';
CREATE TABLE dbo.' + QUOTENAME(@lt) + N'(
  ID bigint IDENTITY(1,1) NOT NULL,
  TARIH datetime2(0) NOT NULL CONSTRAINT DF_' + @lt + N'_TARIH DEFAULT(SYSDATETIME()),
  IP varchar(45) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL,
  ISTASYON varchar(64) COLLATE SQL_Latin1_General_CP1254_CI_AS NULL, KULLANICIID int NULL,
  SUBEID smallint NULL, ISLEMTIPI tinyint NOT NULL, ALTISLEMTIPI tinyint NULL,
  USTTABLOID int NULL, USTKAYITID bigint NULL,
  TABLOID int NULL, KAYITID bigint NULL,
  REHBERID bigint NULL, STOKID bigint NULL,
  BILGI varbinary(max) NULL,
  CONSTRAINT PK_' + @lt + N' PRIMARY KEY CLUSTERED (ID));
CREATE INDEX IX_' + @lt + N'_UST    ON dbo.' + QUOTENAME(@lt) + N'(USTTABLOID,USTKAYITID);
CREATE INDEX IX_' + @lt + N'_KAYIT  ON dbo.' + QUOTENAME(@lt) + N'(TABLOID,KAYITID);
CREATE INDEX IX_' + @lt + N'_REHBER ON dbo.' + QUOTENAME(@lt) + N'(REHBERID);
CREATE INDEX IX_' + @lt + N'_STOK   ON dbo.' + QUOTENAME(@lt) + N'(STOKID);
CREATE INDEX IX_' + @lt + N'_TARIH  ON dbo.' + QUOTENAME(@lt) + N'(TARIH);';
    EXEC (@ddl);
END
GO
