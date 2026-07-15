-- ============================================================
-- sp_Prog_Kasalar_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Kasalar'da BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER + guvenilir SubeYetkiList).
--   Kasa tanim liste ekrani (UKasalarListeFrame) sunucu-tarafi listeleme. Govde eski
--   TKasalarListeFrame.YenileTusClick sorgusuyla BIREBIR (select * from KASALAR + sube filtresi + order by KASAKODU).
--   SUBE filtresi (SubeVarmi) app tarafinda uretilir:
--     - ComboSube = 0 (Tum Subeler)   -> SubeYetkiList = YetkiliSubeleriGetir(23,Gorme) -> SUBEID IN (...)
--     - ComboSube < 0 (belirli sube; REHBER.ID<0 negatif ID) -> SubeId -> SUBEID = @SubeId
--   (Eski kod ComboSube.EditValue >= 0 -> yetki listesi, < 0 -> tek sube; subeler NEGATIF ID.)
--   Son/Sik: KULLANICI_ARAMA (MODUL_Kasalar=2301), PK = KASALAR.ID.
--   @Kosullar ornek: '{"Mod":4,"SubeYetkiList":"-2,-3","KulId":1,"Modul":2301,"OrderBy":"KASAKODU"}'
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Kasalar_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                        -- sablon uyumu (Kasalar'da ek alan yok)
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);   -- sablon uyumu (uygulanmaz)
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @SubeList   NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');                      -- tam-sayi listesi (GUVENILIR; ComboSube=Tum)
    DECLARE @SubeId     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeId') AS INT);            -- tek sube (ComboSube=belirli, negatif ID)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = ISNULL(JSON_VALUE(@Kosullar,'$.OrderBy'), N'KASAKODU');       -- eski: order by KASAKODU

    -- ================= GOVDE = eski YenileTusClick sorgusu ile BIREBIR =================
    DECLARE @KaCol NVARCHAR(MAX) = N'';   -- SELECT'e eklenecek KA_SIRA kolonu (Son/Sik)
    DECLARE @Filt  NVARCHAR(MAX) = N'';   -- WHERE'e eklenecek ek kosullar (Son/Sik EXISTS)
    DECLARE @Sube  NVARCHAR(MAX) = N'';   -- WHERE'e eklenecek sube suzgeci

    -- Son/Sik: kullanicinin actigi kasalar (KULLANICI_ARAMA) — suzgec + siralama anahtari
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        SET @KaCol = N', KA_SIRA = (SELECT '
            + CASE WHEN @Mod = 5 THEN N'MAX(KA.DEGISTIRMETARIHI)' ELSE N'MAX(KA.SAY)' END
            + N' FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = K.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = K.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';
    END

    -- Sube suzgeci (yalniz SubeVarmi). app: ComboSube=Tum -> SubeYetkiList (integer-liste, GUVENILIR);
    --   ComboSube=belirli -> SubeId (integer, TRY_CAST guvenli). Yalniz biri gonderilir.
    IF @SubeList IS NOT NULL AND @SubeList <> N''
        SET @Sube = N' AND K.SUBEID IN (' + @SubeList + N') '
    ELSE IF @SubeId IS NOT NULL
        SET @Sube = N' AND K.SUBEID = ' + CAST(@SubeId AS NVARCHAR(20)) + N' ';

    DECLARE @SQL NVARCHAR(MAX) = N'
    select K.*' + @SelectList + N'/*KA*/ from KASALAR K
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
