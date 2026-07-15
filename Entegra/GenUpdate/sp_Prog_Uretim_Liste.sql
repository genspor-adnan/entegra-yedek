-- ============================================================
-- sp_Prog_Uretim_Liste - Uretim fisi liste ekrani sunucu-tarafi listeleme (UUretimListeDlg)
--   sp_Prog_Stok_Liste deseninin URETIMFISI (FATBASLIK TUR=6) karsiligi.
--   Kaynak sorgu BIREBIR UUretimListeDlg.dfm > SQLMemo.Text (calisan sorgu).
--   Filtreler eski JvTimer1Timer'daki string-birlestirmenin parametreli halidir
--   (plan reuse + enjeksiyon guvenli). Sonuc kumesi / kolon adlari ayni.
--   @Mod: 1=Tum (filtresiz), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.tarih)
--     - Eski kod: Sender=LabelTumKayitlar => filtresiz (Mod=1); aksi => filtreli (Mod=4).
--     - Son/Sik (3/5) YENI: KULLANICI_ARAMA gecmisi; arama-kutusu filtreleri UYGULANMAZ
--       (DateBas/DateBitis bugune default oldugundan gecmisi gizlerdi).
--   @Pasif: Uretim listesinde aktif/pasif ayrimi yok - imzada tutuldu (sablon), kullanilmaz.
--   @SelectList: ek (ozel) alanlar - Uretim'de kullanilmiyor (app '' gonderir).
--   @TopN: Uretim listesinde TOP yok - app 0 gonderir (0 = TOP yok).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Uretim_Liste
    @SelectList NVARCHAR(MAX) = N'',      -- ek (ozel) alanlar; Uretim'de bos
    @TopN       INT           = 0,        -- 0 = TOP yok (Uretim varsayilani)
    @Mod        SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @Pasif      BIT           = 1,        -- (rezerve - Uretim'de kullanilmaz)
    @DateBas    DATETIME      = NULL,     -- FB.TARIH > @DateBas
    @DateBitis  DATETIME      = NULL,     -- FB.TARIH < gun sonu(@DateBitis)
    @UretimID   NVARCHAR(50)  = NULL,     -- FB.ID LIKE %..%
    @UretimNo   NVARCHAR(50)  = NULL,     -- FB.FATURANO LIKE %..%
    @StokKodu   NVARCHAR(50)  = NULL,     -- S.KOD LIKE %..%
    @StokAdi    NVARCHAR(150) = NULL,     -- S.STOKADI LIKE %..%
    @SubeID     INT           = NULL,     -- FB.SUBEID = @SubeID (SubeVarmi ise)
    @KulId      INT           = NULL,     -- @Mod=3/5 icin kullanici (KULLANICI_ARAMA)
    @Modul      INT           = NULL,     -- @Mod=3/5 icin KULLANICI_ARAMA.MODUL
    @OrderBy    NVARCHAR(200) = NULL      -- or. 'FB.TARIH'; Son/Sik'te SP kendi belirler
AS
BEGIN
    SET NOCOUNT ON;

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
        DURUMNEREDEN = case when (415 in (select YERI from FATURA where FATBASID=FB.ID)) then N''Sipari' + NCHAR(351) + N'ten''
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

    EXEC sp_executesql @SQL,
         N'@pDateBas DATETIME, @pDateBitis DATETIME, @pUretimID NVARCHAR(50), @pUretimNo NVARCHAR(50), @pStokKodu NVARCHAR(50), @pStokAdi NVARCHAR(150)',
         @pDateBas = @DateBas, @pDateBitis = @DateBitis, @pUretimID = @UretimID,
         @pUretimNo = @UretimNo, @pStokKodu = @StokKodu, @pStokAdi = @StokAdi;
END;
