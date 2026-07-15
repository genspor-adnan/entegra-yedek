-- ============================================================
-- sp_Prog_Demirbas_Liste — Demirbas liste ekrani sunucu-tarafi listeleme (UDemirbasListeDlg)
--   sp_Prog_Stok_Liste deseninin Demirbas karsiligi (STOK pilotu sablon alindi).
--   Eski JvTimer1Timer sorgusu SQLMemo (DFM statik) + nested TOP + convert iceriyordu
--   ve metin filtreleri string-concat ile kuruluyordu. Burada: sorgu BIREBIR SQLMemo
--   (grid ZIMMETLIADI/MODELAD/KATEGORIADI alanlarina bagli -> ayni kolon kumesi),
--   metin filtreleri parametreli (plan reuse + enjeksiyon guvenli). Yetki kisitlari
--   (sube/kullanici/kategori) app tarafinda hesaplanip tipli parametre olarak gelir.
--   @Mod: 1=Tum (TOP yok), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.DEGISTIRMETARIHI)
--   @Pasif: 0=sadece aktif (DURUM<30), 1=hepsi   (@DurumID set ise onceliklidir)
--   NOT: orijinal SQLMemo, kategori filtresini DU.STOKADI (DEMIRBAS_KATEGORI'de OLMAYAN kolon)
--        uzerinde kuruyordu -> her kategori aramasinda "Invalid column name" hatasi veriyordu.
--        Burada goruntulenen kolonla (KATEGORIADI = DU.AD) TUTARLI olacak sekilde DU.AD uzerinden
--        filtrelenir; kategori filtresi BOS iken sonuc kumesi BIREBIR aynidir.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Demirbas_Liste
    @SelectList     NVARCHAR(MAX) = N'',     -- ',[Cap]=Field,...' (ek alan SELECT)
    @TopN           INT           = 0,       -- 0 = TOP yok (Tum/Filtre)
    @Mod            SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @Pasif          BIT           = 0,        -- 0=aktif(DURUM<30) 1=hepsi
    -- Demirbas filtreleri
    @DurumID        INT           = NULL,     -- AraDurumu (NULL=secilmedi)
    @KategoriAdi    NVARCHAR(200) = NULL,
    @LokasyonAdi    NVARCHAR(200) = NULL,
    @ZimmetAlanAdi  NVARCHAR(200) = NULL,
    @DemirbasNo     NVARCHAR(100) = NULL,
    @DemirbasAdi    NVARCHAR(200) = NULL,
    @SeriNo         NVARCHAR(100) = NULL,
    -- Yetki kisitlari (app tarafinda hesaplanip gelir)
    @SubeYetkiList  NVARCHAR(MAX) = NULL,     -- SubeVarmi ise yetkili sube id listesi (virgullu)
    @KullaniciKisit SMALLINT      = 0,        -- ModulYetki_TekSubeTum.Demirbas: 0=yok 1=kendi 5=departman 10=sube
    @KullaniciId    INT           = NULL,     -- @KullaniciKisit 1/5 icin (Kullanan)
    @SubeId         INT           = NULL,     -- @KullaniciKisit 10 icin
    @KategoriYetki  SMALLINT      = 1,        -- 1=hepsi 0=hicbiri 2=parcali
    @RolId          INT           = NULL,     -- @KategoriYetki 2 icin
    -- Son/Sik (KULLANICI_ARAMA)
    @KulId          INT           = NULL,     -- @Mod=3/5 icin kullanici
    @Modul          INT           = NULL,     -- @Mod=3/5 icin MODUL (Demirbas=28)
    @OrderBy        NVARCHAR(200) = NULL      -- NULL/'' -> D.EKLEMETARIHI DESC
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    -- SELECT + FROM (SQLMemo runtime sorgusu BIREBIR; nested TOP + convert native)
    SET @SQL = N'
    SELECT ' + @Top + N'
        D.*,
        ZIMMETLIADI = R.FIRMA,
        LOKASYONADI = L.ACIKLAMA,
        KATEGORIADI = DU.AD,
        StokModel.ANAHTAR AS MODELAD,
        KALBITTARIH = (SELECT MAX(GECERLILIKTARIHI) FROM KALIBRASYON K WHERE K.DEMIRBASID = D.ID)
        ' + @SelectList + N'
    FROM DEMIRBAS D
        LEFT OUTER JOIN DEMIRBAS_KATEGORI AS DU ON DU.ID = D.KATEGORIID
        LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = D.MODEL
             AND StokModel.BOLUM = CONVERT(INT, ''-2804'' + CONVERT(VARCHAR(10), D.MARKA))
        LEFT OUTER JOIN REHBER AS R ON R.ID = D.REHBERID
        LEFT OUTER JOIN LOKASYON AS L ON L.ID = (SELECT TOP 1 LOKASYONID
                                                 FROM DEMIRBAS_TUTANAK DT
                                                     INNER JOIN DEMIRBAS_TUTANAK_DETAY DTD
                                                          ON DT.ID = DTD.TUTANAKID AND DTD.DEMIRBASID = D.ID
                                                 ORDER BY ID DESC) '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = D.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';

    -- Durum / Pasif  (AraDurumu set ise oncelikli; degilse pasif kapaliyken DURUM<30)
    IF @DurumID IS NOT NULL
        SET @SQL = @SQL + N' AND D.DURUM = ' + CAST(@DurumID AS NVARCHAR(20)) + N' ';
    ELSE IF @Pasif = 0
        SET @SQL = @SQL + N' AND D.DURUM < 30 ';

    -- Metin filtreleri (parametreli)
    IF @KategoriAdi IS NOT NULL AND @KategoriAdi <> N''
        SET @SQL = @SQL + N' AND DU.AD LIKE N''%'' + @pKategoriAdi + N''%'' ';
    IF @LokasyonAdi IS NOT NULL AND @LokasyonAdi <> N''
        SET @SQL = @SQL + N' AND L.ACIKLAMA LIKE N''%'' + @pLokasyonAdi + N''%'' ';
    IF @ZimmetAlanAdi IS NOT NULL AND @ZimmetAlanAdi <> N''
        SET @SQL = @SQL + N' AND R.FIRMA LIKE N''%'' + @pZimmetAlanAdi + N''%'' ';
    IF @DemirbasNo IS NOT NULL AND @DemirbasNo <> N''
        SET @SQL = @SQL + N' AND D.DEMIRBASNO LIKE N''%'' + @pDemirbasNo + N''%'' ';
    IF @DemirbasAdi IS NOT NULL AND @DemirbasAdi <> N''
        SET @SQL = @SQL + N' AND D.DEMIRBASADI LIKE N''%'' + @pDemirbasAdi + N''%'' ';
    IF @SeriNo IS NOT NULL AND @SeriNo <> N''
        SET @SQL = @SQL + N' AND D.SERINO LIKE N''%'' + @pSeriNo + N''%'' ';

    -- Sube yetkisi (SubeVarmi ise) - int listesi, guvenli
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND D.SUBEID IN (' + @SubeYetkiList + N') ';

    -- Kullanici kisiti (TamYetkili degilse; app 0 gonderir -> no-op)
    IF @KullaniciKisit = 1 AND @KullaniciId IS NOT NULL
        SET @SQL = @SQL + N' AND D.REHBERID = ' + CAST(@KullaniciId AS NVARCHAR(20)) + N' ';
    ELSE IF @KullaniciKisit = 5 AND @KullaniciId IS NOT NULL
        SET @SQL = @SQL + N' AND D.REHBERID IN (SELECT RB.ID FROM REHBER RB
                                 INNER JOIN ROLLER ROL ON RB.SINIF = ROL.ID
                                 WHERE ROL.DEPARTMAN = (SELECT ROL2.DEPARTMAN FROM REHBER RB2
                                                        INNER JOIN ROLLER ROL2 ON RB2.SINIF = ROL2.ID
                                                        WHERE RB2.ID = ' + CAST(@KullaniciId AS NVARCHAR(20)) + N')) ';
    ELSE IF @KullaniciKisit = 10 AND @SubeId IS NOT NULL
        SET @SQL = @SQL + N' AND D.SUBEID = ' + CAST(@SubeId AS NVARCHAR(20)) + N' ';

    -- Kategori yetkisi (TamYetkili degilse; app 1 gonderir -> no-op)
    IF @KategoriYetki = 0
        SET @SQL = @SQL + N' AND D.KATEGORIID = 0 ';
    ELSE IF @KategoriYetki = 2 AND @RolId IS NOT NULL
        SET @SQL = @SQL + N' AND D.KATEGORIID IN (SELECT CAST(ISNULL(Y.BILGI,0) AS INT)
                                 FROM YETKIEK Y WHERE Y.ROLID = ' + CAST(@RolId AS NVARCHAR(20)) + N'
                                   AND Y.MODULID = 280105) ';

    -- Siralama (Son/Sik icin KULLANICI_ARAMA; digerlerinde EKLEMETARIHI desc)
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    ELSE IF @OrderBy IS NULL OR @OrderBy = N'' SET @OrderBy = N'D.EKLEMETARIHI DESC';

    SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pKategoriAdi NVARCHAR(200), @pLokasyonAdi NVARCHAR(200), @pZimmetAlanAdi NVARCHAR(200),
           @pDemirbasNo NVARCHAR(100), @pDemirbasAdi NVARCHAR(200), @pSeriNo NVARCHAR(100)',
         @pKategoriAdi = @KategoriAdi, @pLokasyonAdi = @LokasyonAdi, @pZimmetAlanAdi = @ZimmetAlanAdi,
         @pDemirbasNo = @DemirbasNo, @pDemirbasAdi = @DemirbasAdi, @pSeriNo = @SeriNo;
END;
