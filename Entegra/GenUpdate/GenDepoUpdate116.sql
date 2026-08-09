-- ============================================================
-- GenDepoUpdate116.sql
-- KAYNAK/HEDEF sutunlari: transfer <-> uretim fisi bagi listelerde gorunsun
--
-- Transfer bir uretim fisine donusturulunce bag FATBASLIK.YERI = 134
--   (TabNo_TRANSFER) / YERID = transfer belge ID'sinde tutuluyor. Iki liste de
--   bu bagi gostermiyordu:
--     - transfer listesinde HEDEF sutunu YOKTU
--     - uretim listesinde KAYNAK (DURUMNEREDEN) transfer dalini bilmiyordu
--
-- Ayrica uretim listesi YERI/YERID kolonlarini DONDURMUYORDU; "Kaynak Belgeyi
--   Ac" menusunun kaynak transferi acabilmesi icin bunlar gerekli.
--
--   sp_Prog_FatTransfer_Liste_Json2 : + HEDEF  ("Uretim Fisi")
--   sp_Prog_Uretim_Liste_Json2      : DURUMNEREDEN'e "Transfer" dali,
--                                     + YERI, YERID
-- ============================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

-- ============================================================
-- sp_Prog_UretimEmri_Liste_Json2 — tek JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR); @Kosullar = filtreler (JSON).
--   sp_Prog_UretimEmri_Liste (tipli) deseninin Json2 karsiligi. GOVDE tipli SP ile BIREBIR.
--   @Kosullar = '{"Mod":4,"BasTar":"2026-01-01",...}' -> JSON_VALUE ile yerel degiskenlere.
--   Absent key -> NULL (filtre uygulanmaz). Bool'lar 0/1 sayi (TRY_CAST AS BIT).
-- ============================================================
