-- ============================================================
-- sp_Prog_Cek_Liste_Json2 — tek JSON parametre (MSSQL-ONLY)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Cek'te BOS);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   UCekListeFrame.YenileTusClick (eski dinamik SQL) ile BIREBIR ayni sonuc kumesi;
--   sadece parametre alimi JSON + Son/Sik icin KULLANICI_ARAMA (MODUL_Cek=2551).
--   @Kosullar ornek:
--     {"Mod":4,"CekSenet":101,"AraKod":"","SeriNo":"","IslemTurleri":"0,130,131",
--      "VadeBas":"2026-01-01","VadeBit":"2026-12-31","SubeYetkiList":"1,2","KulId":1,"Modul":2551}
--   NOT: eski akista taban sorgu DFM'de (TabCekler.SQL); burada govdede AYNEN gomulu.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Cek_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL / varsayilan. ----
    DECLARE @SelectList NVARCHAR(MAX) = ISNULL(@Baslik, N'');                                        -- sablon uyumu (Cek'te ek alan yok)
    DECLARE @TopN       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);  -- sablon uyumu (uygulanmaz)
    DECLARE @Mod        SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @CekSenet   INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CekSenet') AS INT), 0);  -- HER ZAMAN: Where CEKSENET=@CekSenet
    DECLARE @AraKod     NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.AraKod');
    DECLARE @SeriNo     NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.SeriNo');
    DECLARE @IslemList  NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.IslemTurleri');                      -- virgullu int list (yalniz rakam+virgul)
    DECLARE @VadeBas    DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.VadeBas') AS DATE);
    DECLARE @VadeBit    DATE          = TRY_CAST(JSON_VALUE(@Kosullar,'$.VadeBit') AS DATE);
    DECLARE @SubeList   NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');                     -- virgullu int list (yalniz rakam+virgul)
    DECLARE @KulId      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy    NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= GOVDE: eski YenileTusClick akisiyla BIREBIR =================
    DECLARE @KaCol NVARCHAR(MAX) = N'';   -- SELECT'e eklenecek KA_SIRA kolonu (Son/Sik)
    DECLARE @Filt  NVARCHAR(MAX) = N'';   -- WHERE'e eklenecek ek kosullar

    -- Son/Sik: kullanicinin actigi cekler (KULLANICI_ARAMA) — suzgec + siralama anahtari
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        SET @KaCol = N', KA_SIRA = (SELECT '
            + CASE WHEN @Mod = 5 THEN N'MAX(KA.DEGISTIRMETARIHI)' ELSE N'MAX(KA.SAY)' END
            + N' FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = C.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA WHERE KA.KAYITID = C.ID AND KA.KULID = '
            + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';
    END

    -- Metin filtreleri (parametreli - enjeksiyon guvenli). Orijinal: prefix LIKE (KOD/FIRMA), SERINO icin %..%.
    IF @AraKod IS NOT NULL AND @AraKod <> N''
        SET @Filt = @Filt + N' AND ((R1.KOD LIKE @pKod + N''%'' OR R1.FIRMA LIKE @pKod + N''%'')'
                          + N' OR (R2.KOD LIKE @pKod + N''%'' OR R2.FIRMA LIKE @pKod + N''%'')) ';
    IF @SeriNo IS NOT NULL AND @SeriNo <> N''
        SET @Filt = @Filt + N' AND C.SERINO LIKE N''%'' + @pSeri + N''%'' ';

    -- Islem turleri: virgullu int list -> CH.ISLEM in (...). Yalniz rakam/virgul/bosluk/eksi -> guvenli enjeksiyon.
    IF @IslemList IS NOT NULL AND @IslemList <> N'' AND @IslemList NOT LIKE N'%[^0-9, -]%'
        SET @Filt = @Filt + N' AND CH.ISLEM IN (' + @IslemList + N') ';

    -- Vade araligi (yalniz CheckVadeGor -> app bu anahtarlari o zaman gonderir)
    IF @VadeBas IS NOT NULL SET @Filt = @Filt + N' AND VADE >= @pVadeBas ';
    IF @VadeBit IS NOT NULL SET @Filt = @Filt + N' AND VADE <= @pVadeBit ';

    -- Sube yetki listesi (yalniz SubeVarmi). Yalniz rakam/virgul/bosluk/eksi -> guvenli.
    IF @SubeList IS NOT NULL AND @SubeList <> N'' AND @SubeList NOT LIKE N'%[^0-9, -]%'
        SET @Filt = @Filt + N' AND C.SUBEID IN (' + @SubeList + N') ';

    DECLARE @SQL NVARCHAR(MAX) = N'
    SELECT C.ID,C.KOD,C.TUTAR,C.KUR, C.TUR,C.DURUM,MAKBUZNO=CH.BELGENO,C.CIROLU,C.ODEMEYERI,C.HESAPNO,C.SERINO,
    C.DOVIZ_TUTARI,C.DOVIZ_KURU,C.BORCLU,C.IBAN,C.VKNO,C.BASKASININ,C.BORCLU, C.VADE,
    CARIKOD = R1.KOD, CARIUNVAN=R1.FIRMA,C.HESAPID,C.REHBERID,
    C.HESAPNO, B.BANKAADI, BS.SUBEADI,SONISLEM=CH.ISLEM, C.CEKSENET,
    SONISLEMYERI=case when isnull(R2.FIRMA,''-'')<>''-'' then R2.FIRMA else BHSON.HESAPADI end,
    CH.BELGENO,ISLEMTARIH=CH.TARIH, BANKAHESAPKODU = BH2.HESAPKODU, BANKAHESAPNO = BH2.HESAPNO, BH2.BANKASUBELERID,C.MASRAFID/*KA*/
    FROM CEKLER C
      inner join CEKHAREKET CH on CH.ID=(select top 1 CH1.ID from CEKHAREKET CH1 where CH1.CEKSENETLERID=C.ID order by CH1.TARIH desc)
      left outer join REHBER R1 ON C.REHBERID=R1.ID
      left outer join BANKASUBELER BS ON BS.ID = C.BANKASUBELERID
      left outer join BANKALAR B ON B.BANKAKODU = BS.BANKAKODU
      left outer join REHBER R2 on CH.REHBERID=R2.ID
      left outer join BANKAHESAPLAR BHSON on CH.BANKAHESAPLARID=BHSON.ID
      left outer join BANKAHESAPLAR BH2 on C.HESAPID=BH2.ID
    Where CEKSENET = @pCekSenet /*FLT*/';

    -- Son/Sik suzgeci + KA_SIRA kolonu enjeksiyonu
    SET @SQL = REPLACE(@SQL, N'/*KA*/',  @KaCol);
    SET @SQL = REPLACE(@SQL, N'/*FLT*/', @Filt);

    -- Siralama
    IF @Mod IN (3, 5)
        SET @SQL = @SQL + N' ORDER BY KA_SIRA DESC';
    ELSE IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pCekSenet INT, @pKod NVARCHAR(200), @pSeri NVARCHAR(200), @pVadeBas DATE, @pVadeBit DATE',
         @pCekSenet = @CekSenet, @pKod = @AraKod, @pSeri = @SeriNo, @pVadeBas = @VadeBas, @pVadeBit = @VadeBit;
END;
