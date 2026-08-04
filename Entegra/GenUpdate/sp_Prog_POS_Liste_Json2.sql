-- ============================================================
-- sp_Prog_POS_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; POS'ta BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER + guvenilir SubeYetkiList).
--   POS liste ekrani (UPOSListeFrame) sunucu-tarafi listeleme. Govde eski
--   TPOSListeFrame.YenileClick sorgusuyla BIREBIR; sadece parametre alimi JSON.
--   @Kosullar ornek: '{"Mod":4,"SubeYetkiList":"1,2,5","KulId":1,"Modul":2521}'
--   Sube filtresi (SubeVarmi) app tarafinda YetkiliSubeleriGetir(25,Gorme) ile
--   uretilir; SubeYetkiList tam-sayi listesi (GUVENILIR, @Baslik gibi) enjekte edilir.
--   Son/Sik: KULLANICI_ARAMA (MODUL_POS=2521), PK = POS.ID.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_POS_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                        -- sablon uyumu (POS'ta ek alan yok)
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);   -- 0 = TOP yok
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @SubeList   NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');                      -- tam-sayi listesi (GUVENILIR; yalniz SubeVarmi)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= GOVDE = eski YenileClick sorgusu ile BIREBIR =================
    DECLARE @KaCol NVARCHAR(MAX) = N'';   -- SELECT'e eklenecek KA_SIRA kolonu (Son/Sik)
    DECLARE @Filt  NVARCHAR(MAX) = N'';   -- WHERE'e eklenecek ek kosullar (Son/Sik EXISTS)
    DECLARE @Sube  NVARCHAR(MAX) = N'';   -- WHERE'e eklenecek sube-yetki suzgeci

    -- Son/Sik: kullanicinin actigi POS'lar (KULLANICI_ARAMA) — suzgec + siralama anahtari
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        SET @KaCol = N', KA_SIRA = (SELECT '
            + CASE WHEN @Mod = 5 THEN N'MAX(KA.DEGISTIRMETARIHI)' ELSE N'MAX(KA.SAY)' END
            + N' FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = P.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = P.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';
    END

    -- Sube-yetki suzgeci (app-uretimi tam-sayi listesi; eski: and P.SUBEID in(...))
    IF @SubeList IS NOT NULL AND @SubeList <> N''
        SET @Sube = N' AND P.SUBEID IN (' + @SubeList + N') ';

    -- SAYFALI liste (TSayfaliListe): @TopN>0 -> TOP (n). 0 = TOP yok (eski davranis).
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    DECLARE @SQL NVARCHAR(MAX) = N'
    select ' + @Top + N'P.*,B.LOGO,B.BANKAADI,BS.SUBEADI/*KA*/ from POS P
        inner join BANKAHESAPLAR BH ON  BH.ID = P.BANKAHESAPID
        inner join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID
        inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU
    Where 1=1 /*SUBE*//*FLT*/';

    SET @SQL = REPLACE(@SQL, N'/*KA*/',   @KaCol);
    SET @SQL = REPLACE(@SQL, N'/*SUBE*/', @Sube);
    SET @SQL = REPLACE(@SQL, N'/*FLT*/',  @Filt);

    -- Siralama
    IF @Mod IN (3, 5)
        SET @SQL = @SQL + N' ORDER BY KA_SIRA DESC';
    ELSE IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL;
END;
