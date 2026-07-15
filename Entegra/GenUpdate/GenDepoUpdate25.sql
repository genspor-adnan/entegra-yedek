-- ============================================================
-- GenDepoUpdate25 : sp_Prog_Fisler_Liste_Json2  (2-param JSON, guncel)
--   Liste ekrani sunucu-tarafi listeleme SP'si. ANA DB baglantisindan.
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: GenDepoUpdate4 (KULLANICI_ARAMA).
-- ============================================================

-- ============================================================
-- sp_Prog_Fisler_Liste_Json2 — Fis listesi (2 PARAM JSON, MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Fisler'de BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   Govde = eski TFislerListeFrame.JvTimer1Timer sorgusuyla BIREBIR:
--     base 'select distinct FB.* from FATBASLIK FB' + kosullu FATURA/STOKLAR join
--     + where FB.TUR=@Tur + tarih araligi + sube/depo/tipi/stok suzgecleri.
--   AMod: 1=Tum, 3=Sik Aranan, 4=Filtre/normal, 5=Son Aranan.
--     Mod 1/4 = normal suzgecli liste (parite hedefi).
--     Mod 3/5 = Son/Sik: FB.TUR + KULLANICI_ARAMA EXISTS + KA_SIRA order (yeni islev);
--       tarih/depo/tipi/stok suzgecleri UYGULANMAZ (Son/Sik gecmis tum tarihleri kapsar).
--   Son/Sik: KULLANICI_ARAMA (MODUL_Fisler=240141), PK = FATBASLIK.ID (FB.ID).
--   NOT: eski kod 'FB.SUBE' kolonuna referans veriyordu (FATBASLIK'ta YOK -> SubeVarmi
--     iken hata verirdi, tek-sube kurulumda DORMANT). Burada gercek kolon FB.SUBEID
--     kullanildi (gelistirici niyeti = fisi subeye gore suz).
--   CALISTIRMA: ANA DB baglantisindan (BILIM / GENTEGREDB ...).
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: KULLANICI_ARAMA (GenDepoUpdate4).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Fisler_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                        -- sablon uyumu (Fisler'de ek alan yok)
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);   -- sablon uyumu (uygulanmaz)
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Tur        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Tur') AS INT), 0);
    DECLARE @FaturaJoin BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.FaturaJoin') AS BIT), 0);
    DECLARE @TarihBas   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit   DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    DECLARE @SubeId     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeId') AS INT);
    DECLARE @DepoId     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.DepoId') AS INT);
    DECLARE @Tipi       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Tipi') AS INT);
    DECLARE @StokAra    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.StokAra');
    DECLARE @Kod        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Kod');    -- AraKod -> STOKLAR.KOD veya URUNNO LIKE (FATURA/STOKLAR join)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= GOVDE = eski JvTimer1Timer sorgusu ile BIREBIR =================
    DECLARE @KaCol NVARCHAR(MAX) = N'';   -- SELECT'e eklenecek KA_SIRA kolonu (Son/Sik)
    DECLARE @Join  NVARCHAR(MAX) = N'';   -- kosullu FATURA/STOKLAR join
    DECLARE @Filt  NVARCHAR(MAX) = N'';   -- WHERE'e eklenecek ek kosullar

    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        -- Son(5)/Sik(3): kullanicinin actigi fisler (KULLANICI_ARAMA) — suzgec + siralama anahtari.
        --   Tarih/depo/tipi/stok suzgecleri UYGULANMAZ (gecmis tum kayitlar), yalniz FB.TUR korunur.
        SET @KaCol = N', KA_SIRA = (SELECT '
            + CASE WHEN @Mod = 5 THEN N'MAX(KA.DEGISTIRMETARIHI)' ELSE N'MAX(KA.SAY)' END
            + N' FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = FB.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = FB.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';
    END
    ELSE
    BEGIN
        -- Tum(1)/Filtre(4): eski JvTimer1Timer suzgecleri BIREBIR.
        IF @FaturaJoin = 1 OR (@Kod IS NOT NULL AND @Kod <> N'')
            SET @Join = N' inner join FATURA FT on FT.FATBASID=FB.ID left outer join STOKLAR S on FT.URUNID=S.ID ';
        IF @TarihBas IS NOT NULL
            SET @Filt = @Filt + N' AND FB.FATURATARIH >= @pTarihBas ';
        IF @TarihBit IS NOT NULL
            SET @Filt = @Filt + N' AND FB.FATURATARIH <= @pTarihBit ';
        IF @SubeId IS NOT NULL AND @SubeId > 0
            SET @Filt = @Filt + N' AND FB.SUBEID = ' + CAST(@SubeId AS NVARCHAR(20)) + N' ';
        IF @DepoId IS NOT NULL AND @DepoId > 0
            SET @Filt = @Filt + CASE WHEN @Tur = 3 THEN N' AND FB.GIRISDEPO = ' ELSE N' AND FB.CIKISDEPO = ' END
                       + CAST(@DepoId AS NVARCHAR(20)) + N' ';
        IF @Tipi IS NOT NULL AND @Tipi > 0
            SET @Filt = @Filt + N' AND FB.TIPI = ' + CAST(@Tipi AS NVARCHAR(20)) + N' ';
        IF @StokAra IS NOT NULL AND @StokAra <> N''
            SET @Filt = @Filt + N' AND S.STOKADI LIKE N''%'' + @pStokAra + N''%'' ';
        IF @Kod IS NOT NULL AND @Kod <> N''
            SET @Filt = @Filt + N' AND (S.KOD LIKE N''%'' + @pKod + N''%'' OR S.URUNNO LIKE N''%'' + @pKod + N''%'') ';  -- AraKod: kod veya urunno
    END

    DECLARE @SQL NVARCHAR(MAX) = N'
    select distinct FB.*/*KA*/ from FATBASLIK FB/*JOIN*/
    where FB.TUR = ' + CAST(@Tur AS NVARCHAR(20)) + N'/*FLT*/';

    SET @SQL = REPLACE(@SQL, N'/*KA*/',   @KaCol);
    SET @SQL = REPLACE(@SQL, N'/*JOIN*/', @Join);
    SET @SQL = REPLACE(@SQL, N'/*FLT*/',  @Filt);

    -- Siralama: Son/Sik -> KA_SIRA; aksi halde OrderBy (yoksa eski varsayilan FATURATARIH desc)
    IF @Mod IN (3, 5)
        SET @SQL = @SQL + N' ORDER BY KA_SIRA DESC';
    ELSE IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;
    ELSE
        SET @SQL = @SQL + N' ORDER BY FB.FATURATARIH DESC';

    EXEC sp_executesql @SQL,
         N'@pTarihBas DATETIME, @pTarihBit DATETIME, @pStokAra NVARCHAR(200), @pKod NVARCHAR(200)',
         @pTarihBas = @TarihBas, @pTarihBit = @TarihBit, @pStokAra = @StokAra, @pKod = @Kod;
END;
