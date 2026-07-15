-- ============================================================
-- GenDepoUpdate21 : sp_Prog_KrediKarti_Liste_Json2  (2-param JSON, guncel)
--   Liste ekrani sunucu-tarafi listeleme SP'si. ANA DB baglantisindan.
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: GenDepoUpdate4 (KULLANICI_ARAMA).
-- ============================================================

-- ============================================================
-- sp_Prog_KrediKarti_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; KrediKarti'da BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   Eski istemci-tarafi KREDIKARTI listeleme sorgusu (UKrediKartiListeFrame.YenileClick)
--   ile BIREBIR ayni govde; sadece sube-yetki filtresi + Son/Sik KULLANICI_ARAMA eklendi.
--   @Kosullar ornek: '{"Mod":4,"SubeYetkiList":"1,2,3","KulId":1,"Modul":253130}'
--   Amac: JSON vs istemci-taban paritesi (Banka pilotu deseninin KrediKarti karsiligi).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_KrediKarti_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                        -- ek SELECT alanlari (KrediKarti'da bos)
    DECLARE @TopN          INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);   -- sablon uyumu (uygulanmaz)
    DECLARE @Mod           SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @KulId         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy       NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');
    DECLARE @SubeYetkiList NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');  -- integer-liste (app/GUVENILIR); bos/absent = sube filtresi yok

    -- Son/Sik: kullanicinin actigi kartlar (KULLANICI_ARAMA) — suzgec + siralama anahtari
    DECLARE @KaCol NVARCHAR(MAX) = N'';   -- SELECT'e eklenecek KA_SIRA kolonu
    DECLARE @Filt  NVARCHAR(MAX) = N'';   -- WHERE'e eklenecek ek kosullar
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        SET @KaCol = N', KA_SIRA = (SELECT '
            + CASE WHEN @Mod = 5 THEN N'MAX(KA.DEGISTIRMETARIHI)' ELSE N'MAX(KA.SAY)' END
            + N' FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = KK.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = KK.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';
    END

    -- Sube yetki filtresi (yalniz SubeVarmi -> app SubeYetkiList gonderir); integer-liste, GUVENILIR
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @Filt = @Filt + N' AND KK.SUBEID IN (' + @SubeYetkiList + N') ';

    -- ================= GOVDE ESKI ISTEMCI-TABAN SORGUSU ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX) = N'
    select KK.*,CAST(SKTAY as varchar(2))+''/''+CAST(SKTYIL as varchar(2)) as SKT1,B.LOGO,B.BANKAADI,BS.SUBEADI' + @SelectList + N'/*KA*/
    from KREDIKARTI KK
        left  join BANKAHESAPLAR BH ON  BH.ID = KK.BANKAHESAPID
        left join BANKASUBELER BS ON BH.BANKASUBELERID=BS.ID
        left join BANKALAR B on B.BANKAKODU=BS.BANKAKODU
    Where 1=1 /*FLT*/';

    -- Son/Sik suzgeci + KA_SIRA kolonu enjeksiyonu
    SET @SQL = REPLACE(@SQL, N'/*KA*/',  @KaCol);
    SET @SQL = REPLACE(@SQL, N'/*FLT*/', @Filt);

    -- Siralama
    IF @Mod IN (3, 5)
        SET @SQL = @SQL + N' ORDER BY KA_SIRA DESC';
    ELSE IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL;
END;
