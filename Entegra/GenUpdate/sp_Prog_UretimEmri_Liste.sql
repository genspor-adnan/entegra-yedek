-- ============================================================
-- sp_Prog_UretimEmri_Liste — Uretim Emirleri liste ekrani sunucu-tarafi listeleme
--   (UUretimEmriListeDlg). sp_Prog_Stok_Liste deseninin URETIMEMRI karsiligi.
--   Eski JvTimer sorgusu (SELECT U.*, S.KOD AS STOKKODU ... ORDER BY U.BASTAR)
--   BIREBIR korunur; metin/tarih filtreleri parametreli (plan reuse + enjeksiyon guvenli).
--   @Mod: 1=Tum (filtresiz), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.tarih)
--   @Pasif: 0=sadece aktif (U.DURUM>0), 1=hepsi  (eski: CheckPasifler.Checked=1 -> hepsi)
--   @TopN: 0 = TOP yok (Tum/Filtre paritesi - eski sorguda TOP yoktu)
--   @SelectList: ek (ozel) alanlar - ',[Cap]=Field,...'
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_UretimEmri_Liste
    @SelectList     NVARCHAR(MAX) = N'',     -- ',[Cap]=Field,...' (ek alan SELECT)
    @TopN           INT           = 0,       -- 0 = TOP yok (eski sorgu TOP'suzdu)
    @Mod            SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @Pasif          BIT           = 0,        -- 0=aktif (DURUM>0) 1=hepsi
    @UretimID       NVARCHAR(50)  = NULL,     -- EditUretimID: U.ID / U.EMIRNO LIKE
    @StokKodu       NVARCHAR(50)  = NULL,     -- EditStokKodu: S.KOD / S.URUNNO LIKE
    @StokAdi        NVARCHAR(150) = NULL,     -- EditStokAdi: S.STOKADI LIKE
    @DetayUrun      NVARCHAR(50)  = NULL,     -- EditUretimNo (Opr.Urun Kod/No): detay EXISTS
    @BasTar         DATETIME      = NULL,     -- DateBas: U.BASTAR >=
    @BitTar         DATETIME      = NULL,     -- DateBitis: U.BASTAR <=
    @KulId          INT           = NULL,     -- @Mod=3/5 icin kullanici (KULLANICI_ARAMA)
    @Modul          INT           = NULL,     -- @Mod=3/5 icin MODUL (Uretim=33)
    @OrderBy        NVARCHAR(200) = N'U.BASTAR'  -- eski parite: ORDER BY U.BASTAR
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    -- SELECT: eski sorgu ile BIREBIR (U.* + joined alias'lar)
    SET @SQL = N'
    SELECT ' + @Top + N'
        U.*,
        S.KOD AS STOKKODU, S.STOKADI, S.URUNNO,
        P.PROJEKODU,
        L.ACIKLAMA AS ANAKAYNAKAD,
        R.FIRMA AS FIRMAAD
        ' + @SelectList + N'
    FROM URETIMEMRI U
        LEFT JOIN STOKLAR S ON S.ID = U.STOKID
        LEFT JOIN PROJELER P ON P.ID = U.PROJEID
        LEFT JOIN LOKASYON L ON L.ID = U.ANAKAYNAK
        LEFT JOIN REHBER R ON R.ID = U.REHBERID '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = U.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';

    -- Metin filtreleri (parametreli). @Mod=1 (Tum) -> app bos gonderir, filtre uygulanmaz.
    IF @UretimID IS NOT NULL AND @UretimID <> N''
        SET @SQL = @SQL + N' AND (U.ID LIKE N''%'' + @pUretimID + N''%'' OR U.EMIRNO LIKE N''%'' + @pUretimID + N''%'') ';
    IF @StokKodu IS NOT NULL AND @StokKodu <> N''
        SET @SQL = @SQL + N' AND (S.KOD LIKE N''%'' + @pStokKodu + N''%'' OR S.URUNNO LIKE N''%'' + @pStokKodu + N''%'') ';
    IF @StokAdi IS NOT NULL AND @StokAdi <> N''
        SET @SQL = @SQL + N' AND S.STOKADI LIKE N''%'' + @pStokAdi + N''%'' ';
    IF @DetayUrun IS NOT NULL AND @DetayUrun <> N''
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM URETIMEMRIDETAY UED
                                         INNER JOIN STOKLAR S2 ON S2.ID = UED.URUNID
                                         WHERE UED.URETIMEMRIID = U.ID
                                           AND (S2.KOD LIKE N''%'' + @pDetayUrun + N''%''
                                                OR S2.URUNNO LIKE N''%'' + @pDetayUrun + N''%'')) ';

    -- Tarih filtreleri (parametreli)
    IF @BasTar IS NOT NULL
        SET @SQL = @SQL + N' AND U.BASTAR >= @pBasTar ';
    IF @BitTar IS NOT NULL
        SET @SQL = @SQL + N' AND U.BASTAR <= @pBitTar ';

    -- Pasif: kapaliyken sadece aktif (eski: CheckPasifler kapali -> U.DURUM>0)
    IF @Pasif = 0
        SET @SQL = @SQL + N' AND U.DURUM > 0 ';

    -- Son/Sik aranan siralamasi (KULLANICI_ARAMA)
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pUretimID NVARCHAR(50), @pStokKodu NVARCHAR(50), @pStokAdi NVARCHAR(150),
           @pDetayUrun NVARCHAR(50), @pBasTar DATETIME, @pBitTar DATETIME',
         @pUretimID = @UretimID, @pStokKodu = @StokKodu, @pStokAdi = @StokAdi,
         @pDetayUrun = @DetayUrun, @pBasTar = @BasTar, @pBitTar = @BitTar;
END;
