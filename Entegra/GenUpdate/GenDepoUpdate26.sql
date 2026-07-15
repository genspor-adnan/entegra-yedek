-- ============================================================
-- GenDepoUpdate26 : sp_Prog_FatTransfer_Liste_Json2  (2-param JSON, guncel)
--   Liste ekrani sunucu-tarafi listeleme SP'si. ANA DB baglantisindan.
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: GenDepoUpdate4 (KULLANICI_ARAMA).
-- ============================================================

-- ============================================================
-- sp_Prog_FatTransfer_Liste_Json2 — Fatura Transfer liste (2 PARAM JSON, MSSQL-ONLY)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; FatTransfer'de BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   Eski istemci-tarafi TFatTransferListeDlg.JvTimer1Timer dinamik SQL'inin (SQLMemo taban +
--   append filtreler) yerine gecer. Satir kumesi BIREBIR korunur (parite dogrulandi).
--   PK = FATBASLIK.ID. Son/Sik: KULLANICI_ARAMA (MODUL_FatTransfer=2711), KAYITID=FB.ID.
--   Filtreler (hepsi opsiyonel, absent=filtre yok):
--     TeslimEden=FB.SATICIKODU (REHBER id), TeslimAlan=FB.REHBERID (REHBER id),
--     TransferNo=FB.FATURANO LIKE, OzelKod=FB.OZELKOD LIKE, UretimEmirNo=FB.DETAYBOLUMU LIKE, Stok=STOKLAR.STOKADI LIKE.
--   @Kosullar ornek:
--     '{"Mod":4,"BasTrh":"2026-07-14T00:00:00","BitTrh":"2026-07-14T23:59:59",
--       "TeslimAlan":123,"TransferNo":"TRF-1","OzelKod":"OK","UretimEmirNo":"UE-1","Stok":"vida","KulId":1,"Modul":2711}'
-- ============================================================
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
    KAYNAK=  case  when exists(select F2.ID from SIPARISDETAY F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI =435 and F1.FATBASID=FB.ID)) then ''Talepten'' end'
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
