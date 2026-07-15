-- ============================================================
-- GenDepoUpdate12 : sp_Prog_Servis_Liste_Json2  (2-param JSON, guncel)
--   Liste ekrani sunucu-tarafi listeleme SP'si. ANA DB baglantisindan.
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: GenDepoUpdate4 (KULLANICI_ARAMA).
-- ============================================================

-- ============================================================
-- sp_Prog_Servis_Liste_Json2 — Servis liste (2 PARAM JSON, MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   Tipli sp_Prog_Servis_Liste'nin JSON esdegeri. GOVDE, tipli SP ile BIREBIR.
--   @SelectList = ISNULL(@Baslik, N''); diger tum param -> JSON_VALUE(@Kosullar,'$.<ad>') + cast.
--   Amac: JSON vs tipli-param parite (Teklif pilotu ile ayni desen).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Servis_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList     NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN           INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);
    DECLARE @Mod            SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Pasif          BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @ServisNo       NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.ServisNo');
    DECLARE @ServisNoId     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.ServisNoId') AS INT);
    DECLARE @KategoriAd     NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.KategoriAd');
    DECLARE @Konusu         NVARCHAR(250) = JSON_VALUE(@Kosullar,'$.Konusu');
    DECLARE @Urun           NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Urun');
    DECLARE @Musteri        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Musteri');
    DECLARE @SeriNo         NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.SeriNo');
    DECLARE @SubeYetkiList  NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');
    DECLARE @cbListe        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.cbListe') AS INT);
    DECLARE @Kullanan       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Kullanan') AS INT);
    DECLARE @SubeID         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeID') AS INT);
    DECLARE @Durum          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Durum') AS INT);
    DECLARE @DurumVar       BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.DurumVar') AS BIT), 0);
    DECLARE @SorumluTag     INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SorumluTag') AS INT), 0);
    DECLARE @Kapali         BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kapali') AS BIT), 0);
    DECLARE @Tamamlanan     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Tamamlanan') AS INT);
    DECLARE @KapaliTarih    NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.KapaliTarih');
    DECLARE @TarihBas       NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.TarihBas');
    DECLARE @TarihBit       NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.TarihBit');
    DECLARE @KulId          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    -- @Mod=3/5 icin KULLANICI_ARAMA join'i kurulacak mi? (ORDER BY da bu bayraga bagli)
    DECLARE @KaJoin BIT = CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
                               THEN 1 ELSE 0 END;

    SET @SQL = N'
    SELECT ' + @Top + N' S.* ' + @SelectList + N'
    FROM VServisListesi S '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join (unique KULID,MODUL,KAYITID)
    + CASE WHEN @KaJoin = 1
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = S.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';

    -- EditNo: SERVISNO LIKE (+ sayisal ise S.ID). Bu filtre varsa asagidaki ACKAPA blogu atlanir.
    IF @ServisNo IS NOT NULL AND @ServisNo <> N''
    BEGIN
        SET @SQL = @SQL + N' AND ((S.SERVISNO LIKE @pServisNo + N''%'')';
        IF @ServisNoId IS NOT NULL AND @ServisNoId <> 0
            SET @SQL = @SQL + N' OR (S.ID = ' + CAST(@ServisNoId AS NVARCHAR(20)) + N')';
        SET @SQL = @SQL + N')';
    END;

    -- EditKategori (Tag>0 iken Text = kategori adi ile esitlik)
    IF @KategoriAd IS NOT NULL AND @KategoriAd <> N''
        SET @SQL = @SQL + N' AND (SELECT AD FROM KATEGORI K WHERE K.ID = S.EKIPMANID) = @pKategoriAd ';

    -- AraKonusu
    IF @Konusu IS NOT NULL AND @Konusu <> N''
        SET @SQL = @SQL + N' AND S.KONUSU LIKE N''%'' + @pKonusu + N''%'' ';

    -- editUrun (ekipman adi)
    IF @Urun IS NOT NULL AND @Urun <> N''
        SET @SQL = @SQL + N' AND (SELECT AD FROM EKIPMANLAR E WHERE E.ID = S.EKIPMANID) LIKE N''%'' + @pUrun + N''%'' ';

    -- AraMusteri (FIRMA - view kolonu)
    IF @Musteri IS NOT NULL AND @Musteri <> N''
        SET @SQL = @SQL + N' AND FIRMA LIKE N''%'' + @pMusteri + N''%'' ';

    -- Sube yetkisi (SubeVarmi ise app @SubeYetkiList gonderir)
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND S.SUBEID IN (' + @SubeYetkiList + N') ';

    -- EditSerino
    IF @SeriNo IS NOT NULL AND @SeriNo <> N''
        SET @SQL = @SQL + N' AND S.SERINO LIKE @pSeriNo + N''%'' ';

    -- cbListe (personel/departman/sube kapsami)
    IF @cbListe = 1        -- Aktif Servislerim (biten hareketi olmayan)
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE ISNULL(SH.BITISSEC,0)=0 AND SH.SERVISID=S.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 2   -- Ilgili Olduklarim (tum servislerim)
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 5   -- Departman Servisleri
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.PERSONEL IN '
                        + N' (SELECT R.ID FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                        + N'  WHERE ROL.DEPARTMAN=(SELECT ROL.DEPARTMAN FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                        + N'  WHERE R.ID=' + CAST(@Kullanan AS NVARCHAR(20)) + N'))) ';
    ELSE IF @cbListe = 8   -- Sube Servislerim
        SET @SQL = @SQL + N' AND S.SUBEID=' + CAST(@SubeID AS NVARCHAR(20)) + N' ';

    -- AraDurumu (dogrudan S.DURUM esitligi)
    IF @DurumVar = 1
        SET @SQL = @SQL + N' AND S.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' ';

    -- AraDurumu + EditSorumlu kombinasyonu (hareket bazli EXISTS)
    IF @DurumVar = 1 AND @SorumluTag > 0
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 0 AND @SorumluTag > 0
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 1 AND @SorumluTag = 0
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N') ';

    -- Kapali/tarih blogu: yalnizca ServisNo bosken (no araması gecmise de bakar)
    IF @ServisNo IS NULL OR @ServisNo = N''
    BEGIN
        IF @Kapali = 1
        BEGIN
            IF @Tamamlanan = 1            -- bugun
                SET @SQL = @SQL + N' AND ((ISNULL(S.ACKAPA,0)=0) OR (ROUND(CAST(BASLAMATARIHI AS FLOAT),0,1)=ROUND(CAST(GETDATE() AS FLOAT),0,1))) ';
            ELSE IF @Tamamlanan = 19000   -- iki tarih arasi
                SET @SQL = @SQL + N' AND ((ISNULL(S.ACKAPA,0)=0) OR (BASLAMATARIHI BETWEEN @pTarihBas AND @pTarihBit)) ';
            ELSE                          -- son 1 ay / 1 yil vb.
                SET @SQL = @SQL + N' AND ((ISNULL(S.ACKAPA,0)=0) OR (BASLAMATARIHI >= @pKapaliTarih)) ';
        END
        ELSE
            SET @SQL = @SQL + N' AND S.ACKAPA = 0 ';
    END;

    -- Son/Sik aranan siralamasi (yalnizca KA join kuruldugunda)
    IF @KaJoin = 1
    BEGIN
        IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
        ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    END;

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pServisNo NVARCHAR(50), @pKategoriAd NVARCHAR(150), @pKonusu NVARCHAR(250), @pUrun NVARCHAR(200), @pMusteri NVARCHAR(200), @pSeriNo NVARCHAR(50), @pTarihBas NVARCHAR(20), @pTarihBit NVARCHAR(20), @pKapaliTarih NVARCHAR(20)',
         @pServisNo = @ServisNo, @pKategoriAd = @KategoriAd, @pKonusu = @Konusu, @pUrun = @Urun,
         @pMusteri = @Musteri, @pSeriNo = @SeriNo, @pTarihBas = @TarihBas, @pTarihBit = @TarihBit, @pKapaliTarih = @KapaliTarih;
END;
