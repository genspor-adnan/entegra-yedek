-- ============================================================
-- GenDepoUpdate44 (musteri uygulama)
--   StokHizmetAra aramasi standart-sistem SP'leri (ListeSPJson @Baslik+@Kosullar):
--     sp_Prog_StokHizmetAra_Stok_Json2   (2-union stok; Mod5=Son Aranan)
--     sp_Prog_StokHizmetAra_Hizmet_Json2 (MASRAFGELIR/HESAPPLANI hizmet)
--   Uygulama build'i de gerekir (UStokHizmetAra.StokAra/HizmetAra -> ListeSPJson;
--   LabelSonAranan -> Mod5; BtnSec -> AramaKaydet(MODUL_Stok)).
--   CREATE OR ALTER PROC batch-basi olmali -> GO ile ayrilmistir.
-- ============================================================
-- ============================================================
-- sp_Prog_StokHizmetAra_Stok_Json2 — StokHizmetAra STOK aramasi (2 param: @Baslik + @Kosullar JSON)
--   UStokHizmetAra.StokAra inline SQL'inin standart-sistem karsiligi.
--   Iki UNION ALL branch: ANABIRIM satiri + BIRIM2 (alt birim) satiri.
--   Kolonlar app'in bekledigi ADLARLA birebir: ID,KOD,URUNNO,AD,TUR,KALAN,FIYAT,KUR,
--     STOKMARKA,STOKMODEL,KDV,OTVYUZDE,OTVMIKTAR,KDVDURUM,PAKET,IZLEME,BIRIM,STOKGRUBU,MASRAFID,OZELKOD.
--   @Mod: 4=Filtre/normal, 5=Son Aranan (KULLANICI_ARAMA: KulId+Modul, tarih desc).
--   PERF: TOP(N) sinir; text filtreleri sp_executesql PARAMETRELI (plan cache reuse,
--         literal-concat recompile'ini onler); STOKBARKOD/ISORTAGI join sadece gerekince;
--         Son Aranan'da KULLANICI_ARAMA join-first (az satir).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokHizmetAra_Stok_Json2
    @Baslik   NVARCHAR(MAX) = N'',    -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi)
    @Kosullar NVARCHAR(MAX)           -- filtreler (JSON)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler ----
    DECLARE @SelectList  NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @Depo        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Depo') AS INT), 0);
    DECLARE @FiyatAdi    INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.FiyatAdi') AS INT), 0);
    DECLARE @RehberID    INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.RehberID') AS INT), 0);
    DECLARE @Satis       BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Satis') AS BIT), 1);   -- 1=cikis(satis), 0=giris(alis)
    DECLARE @Dil         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Dil') AS INT), -1);
    DECLARE @CariDoviz   NVARCHAR(10)  = ISNULL(JSON_VALUE(@Kosullar,'$.CariDoviz'), N'TL');
    DECLARE @AdetBirimi  INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AdetBirimi') AS INT), 0);
    DECLARE @TopN        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 200);
    DECLARE @Mod         SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod') AS SMALLINT), 4);
    DECLARE @KulId       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @Kod         NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.Kod');
    DECLARE @Ad          NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.Ad');
    DECLARE @Barkod      NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.Barkod');
    DECLARE @Serino      NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.Serino');
    DECLARE @GrubuID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GrubuID') AS INT);
    DECLARE @OzellikID   INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.OzellikID') AS INT);
    DECLARE @MarkaID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.MarkaID') AS INT);
    DECLARE @ModelID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.ModelID') AS INT);
    DECLARE @IcerikID    INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.IcerikID') AS INT);
    DECLARE @KategoriID  INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KategoriID') AS INT);
    DECLARE @KategoriArama BIT         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KategoriArama') AS BIT), 0);
    DECLARE @Esdeger     NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.Esdeger');   -- csv int id (app-uretimi, guvenilir)
    DECLARE @BuFirma     BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.BuFirma') AS BIT), 0);
    DECLARE @Olmayanlar  BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Olmayanlar') AS BIT), 0);
    DECLARE @Sayim       BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Sayim') AS BIT), 0);
    DECLARE @SayimID     INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SayimID') AS INT), 0);
    DECLARE @Birim2Getir BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Birim2Getir') AS BIT), 1); -- sayim/recete disinda BIRIM2 branch

    DECLARE @sDepo   NVARCHAR(20)  = CAST(@Depo AS NVARCHAR(20));
    DECLARE @sFiyat  NVARCHAR(20)  = CAST(@FiyatAdi AS NVARCHAR(20));
    DECLARE @sDil    NVARCHAR(20)  = CAST(@Dil AS NVARCHAR(20));
    DECLARE @sBirimi NVARCHAR(20)  = CAST(@AdetBirimi AS NVARCHAR(20));
    DECLARE @Top     NVARCHAR(30)  = CASE WHEN @TopN > 0 THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') ' ELSE N'' END;
    DECLARE @SonAranan BIT = CASE WHEN @Mod = 5 AND @KulId IS NOT NULL AND @Modul IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @HasBarkod BIT = CASE WHEN @Barkod IS NOT NULL AND @Barkod <> N'' AND @SonAranan = 0 THEN 1 ELSE 0 END;

    -- ---- Ortak filtre (WHERE eklentileri; iki branch de kullanir) ----
    DECLARE @Filt NVARCHAR(MAX) = N'';
    IF @SonAranan = 0
    BEGIN
        IF @KategoriArama = 0
        BEGIN
            IF @Kod    IS NOT NULL AND @Kod    <> N'' SET @Filt = @Filt + N' AND (S.KOD LIKE N''%'' + @pKod + N''%'' OR S.URUNNO LIKE N''%'' + @pKod + N''%'') ';
            IF @Ad     IS NOT NULL AND @Ad     <> N'' SET @Filt = @Filt + N' AND S.STOKADI LIKE N''%'' + @pAd + N''%'' ';
            IF @HasBarkod = 1                         SET @Filt = @Filt + N' AND ( STB.BARKOD LIKE N''%'' + @pBarkod + N''%'' OR @pBarkod LIKE REPLACE(REPLACE(REPLACE(STB.BARKOD,''O'',''_''),''P'',''_''),''Q'',''_'') ) ';
            IF @Serino IS NOT NULL AND @Serino <> N'' SET @Filt = @Filt + N' AND S.ID IN (SELECT SBI.STOKID FROM STOKIZLEME SBI WHERE SBI.SERINO = @pSerino) ';
            IF @GrubuID   > 0 SET @Filt = @Filt + N' AND S.GRUBU='   + CAST(@GrubuID   AS NVARCHAR(20)) + N' ';
            IF @OzellikID > 0 SET @Filt = @Filt + N' AND S.OZELLIK=' + CAST(@OzellikID AS NVARCHAR(20)) + N' ';
            IF @MarkaID   > 0 SET @Filt = @Filt + N' AND S.MARKA='   + CAST(@MarkaID   AS NVARCHAR(20)) + N' ';
            IF @ModelID   > 0 SET @Filt = @Filt + N' AND S.MODEL='   + CAST(@ModelID   AS NVARCHAR(20)) + N' ';
            IF @IcerikID  > 0 SET @Filt = @Filt + N' AND S.ICERIK='  + CAST(@IcerikID  AS NVARCHAR(20)) + N' ';
        END
        ELSE IF @KategoriID > 0
            SET @Filt = @Filt + N' AND S.KATEGORI=' + CAST(@KategoriID AS NVARCHAR(20)) + N' ';

        IF @Esdeger IS NOT NULL AND @Esdeger <> N''
            SET @Filt = @Filt + N' AND S.ID IN (' + @Esdeger + N') ';
        IF @Sayim = 1
            SET @Filt = @Filt + N' AND S.KULLANIM=1 AND S.ID NOT IN (SELECT SSK.STOKID FROM STOKSAYIMKALEMLERI SSK WHERE SSK.SAYIMID=' + CAST(@SayimID AS NVARCHAR(20)) + N') ';
    END;

    -- SifirGelmesin (cikis + olmayanlar kapali -> sadece stogu olan)
    DECLARE @Sifir NVARCHAR(MAX) = N'';
    IF @Satis = 1 AND @Olmayanlar = 0
        SET @Sifir = N' AND ISNULL((SELECT SUM(KALAN) FROM STOKDURUM SD WHERE SD.STOKID=S.ID AND SD.DEPOID=' + @sDepo + N'),0) > 0 ';

    -- Join eklentileri (PERF: sadece gerekince)
    DECLARE @JBuFirma NVARCHAR(300) = CASE WHEN @BuFirma = 1
        THEN N' INNER JOIN ISORTAGI IO ON S.ID=IO.STOKID AND IO.REHBERID=' + CAST(@RehberID AS NVARCHAR(20)) + N' ' ELSE N'' END;
    DECLARE @JKA NVARCHAR(300) = CASE WHEN @SonAranan = 1
        THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID=S.ID AND KA.KULID=' + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL=' + CAST(@Modul AS NVARCHAR(20)) + N' ' ELSE N'' END;
    DECLARE @Satis01 NVARCHAR(1) = CAST(@Satis AS NVARCHAR(1));
    DECLARE @MasrafKol NVARCHAR(40) = CASE WHEN @Satis = 0 THEN N' S.MASRAFID AS MASRAFID,' ELSE N' S.GELIRID AS MASRAFID,' END;
    DECLARE @GENINIJ NVARCHAR(MAX) =
        N' LEFT OUTER JOIN GENINI StokMarka ON StokMarka.DEGER=S.MARKA AND StokMarka.DIL=' + @sDil + N' AND StokMarka.BOLUM=-2701 ' +
        N' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER=S.MODEL AND StokModel.DIL=' + @sDil + N' AND StokModel.BOLUM=CAST(''-2701''+CAST(S.MARKA AS VARCHAR(10)) AS INT) ' +
        N' LEFT OUTER JOIN GENINI StokGrubu ON S.GRUBU=StokGrubu.DEGER AND StokGrubu.DIL=' + @sDil + N' AND StokGrubu.BOLUM=-2704 ';

    -- ---- BRANCH 1: ANABIRIM ----
    DECLARE @B1 NVARCHAR(MAX) =
        N' SELECT ' + @Top + N'
            S.ID, S.KOD, S.URUNNO, AD=STOKADI, TUR=''Stok'',
            KALAN=ISNULL((SELECT SUM(KALAN) FROM STOKDURUM SD WHERE SD.STOKID=S.ID AND SD.DEPOID=' + @sDepo + N'),0),
            FIYAT=ISNULL(SF.FIYAT,-1), KUR=ISNULL(SF.KUR,@pDoviz),
            STOKMARKA=StokMarka.ANAHTAR, STOKMODEL=StokModel.ANAHTAR,
            KDV=S.KDV, S.OTVYUZDE, S.OTVMIKTAR, KDVDURUM=SF.KDVDURUM,
            PAKET=ISNULL(S.PAKET,0), IZLEME=ISNULL(S.IZLEME,0),
            BIRIM=ISNULL(S.ANABIRIM,' + @sBirimi + N'), STOKGRUBU=StokGrubu.ANAHTAR,' + @MasrafKol + N' S.OZELKOD ' + @SelectList + N'
          FROM STOKLAR S (NOLOCK)
            LEFT OUTER JOIN STOKFIYAT SF (NOLOCK) ON S.ID=SF.STOKID AND SF.BIRIM=S.ANABIRIM AND SF.FIYATADI=' + @sFiyat + N' AND SF.PAKETID=0 AND SF.SATIS=' + @Satis01 + N' ' +
            @GENINIJ + @JBuFirma + @JKA +
            CASE WHEN @HasBarkod = 1 THEN N' INNER JOIN STOKBARKOD STB ON S.ID=STB.STOKID AND S.ANABIRIM=STB.BARKODBIRIMI ' ELSE N'' END +
        N' WHERE S.DURUM=1 ' + @Sifir + @Filt;

    -- ---- BRANCH 2: BIRIM2 (alt birim; sadece BIRIM2<>ANABIRIM olanlar) ----
    -- Son Aranan tek-select (UNION sonrasi KA.tarih ORDER edilemez) -> branch2 kapali
    DECLARE @B2 NVARCHAR(MAX) = N'';
    IF @Sayim = 0 AND @Birim2Getir = 1 AND @SonAranan = 0
        SET @B2 =
        N' UNION ALL SELECT ' + @Top + N'
            S.ID, KOD=S.KOD+''#'', S.URUNNO, AD=STOKADI, TUR=''Stok'',
            KALAN=ISNULL((SELECT ROUND(SUM(KALAN)/S.BIRIM2MIKTAR,0,1) FROM STOKDURUM SD WHERE SD.STOKID=S.ID AND SD.DEPOID=' + @sDepo + N'),0),
            FIYAT=ISNULL(SF.FIYAT,-1), KUR=ISNULL(SF.KUR,@pDoviz),
            STOKMARKA=StokMarka.ANAHTAR, STOKMODEL=StokModel.ANAHTAR,
            KDV=S.KDV, S.OTVYUZDE, S.OTVMIKTAR, KDVDURUM=SF.KDVDURUM,
            PAKET=ISNULL(S.PAKET,0), IZLEME=ISNULL(S.IZLEME,0),
            BIRIM=ISNULL(S.BIRIM2,' + @sBirimi + N'), STOKGRUBU=StokGrubu.ANAHTAR,' + @MasrafKol + N' S.OZELKOD ' + @SelectList + N'
          FROM STOKLAR S (NOLOCK)
            LEFT OUTER JOIN STOKFIYAT SF (NOLOCK) ON S.ID=SF.STOKID AND SF.BIRIM=S.BIRIM2 AND SF.FIYATADI=' + @sFiyat + N' AND SF.PAKETID=0 AND SF.SATIS=' + @Satis01 + N' ' +
            @GENINIJ + @JBuFirma + @JKA +
            CASE WHEN @HasBarkod = 1 THEN N' INNER JOIN STOKBARKOD STB ON S.ID=STB.STOKID AND S.BIRIM2=STB.BARKODBIRIMI ' ELSE N'' END +
        N' WHERE S.DURUM=1 AND (S.ANABIRIM <> ISNULL(S.BIRIM2,S.ANABIRIM)) ' + @Sifir + @Filt;

    -- ---- ORDER ----
    DECLARE @Order NVARCHAR(100) = CASE WHEN @SonAranan = 1 THEN N' ORDER BY KA.DEGISTIRMETARIHI DESC ' ELSE N' ORDER BY 2 ' END;

    DECLARE @SQL NVARCHAR(MAX) = @B1 + @B2 + @Order;

    EXEC sp_executesql @SQL,
         N'@pKod NVARCHAR(100), @pAd NVARCHAR(150), @pBarkod NVARCHAR(50), @pSerino NVARCHAR(50), @pDoviz NVARCHAR(10)',
         @pKod = @Kod, @pAd = @Ad, @pBarkod = @Barkod, @pSerino = @Serino, @pDoviz = @CariDoviz;
END;
GO

-- ============================================================
-- sp_Prog_StokHizmetAra_Hizmet_Json2 — StokHizmetAra HIZMET aramasi (2 param: @Baslik + @Kosullar JSON)
--   UStokHizmetAra.HizmetAra inline SQL'inin standart-sistem karsiligi.
--   Kolonlar app'in bekledigi ADLARLA birebir (stok grid ile ayni + ROOTKOD):
--     ID,KOD,ROOTKOD,AD,TUR,KALAN,FIYAT,KUR,STOKMARKA,STOKMODEL,KDV,OTVYUZDE,OTVMIKTAR,
--     KDVDURUM,PAKET,IZLEME,BIRIM,STOKGRUBU,MASRAFID,OZELKOD.
--   @Satis: 1=cikis (GELIRMI=1, FIYAT SATIS=1, HESAPPLANI VARSAYILAN=3),
--           0=giris (GELIRMI=0, FIYAT SATIS=0, HESAPPLANI VARSAYILAN=2).
--   Arama metni (Kod/Ad/Barkod) BOS ise HESAPPLANI baslik satirlari UNION ile eklenir.
--   PERF: text filtreleri sp_executesql PARAMETRELI (plan cache reuse).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokHizmetAra_Hizmet_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FiyatAdi   INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.FiyatAdi') AS INT), 0);
    DECLARE @Satis      BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Satis') AS BIT), 1);
    DECLARE @AdetBirimi INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.AdetBirimi') AS INT), 0);
    DECLARE @Kod        NVARCHAR(100)= JSON_VALUE(@Kosullar,'$.Kod');
    DECLARE @Ad         NVARCHAR(150)= JSON_VALUE(@Kosullar,'$.Ad');
    DECLARE @Barkod     NVARCHAR(50) = JSON_VALUE(@Kosullar,'$.Barkod');
    DECLARE @SubeVar    BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeVar') AS BIT), 0);
    DECLARE @SubeID     INT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeID') AS INT), 0);

    DECLARE @sFiyat  NVARCHAR(20) = CAST(@FiyatAdi AS NVARCHAR(20));
    DECLARE @sBirimi NVARCHAR(20) = CAST(@AdetBirimi AS NVARCHAR(20));
    DECLARE @Gelirmi NVARCHAR(1)  = CAST(@Satis AS NVARCHAR(1));   -- 1=cikis/gelir, 0=giris/gider
    DECLARE @Satis01 NVARCHAR(1)  = CAST(@Satis AS NVARCHAR(1));
    DECLARE @Varsayilan NVARCHAR(1) = CASE WHEN @Satis = 1 THEN N'3' ELSE N'2' END;
    DECLARE @AramaBos BIT = CASE WHEN (@Kod IS NULL OR @Kod = N'') AND (@Ad IS NULL OR @Ad = N'') AND (@Barkod IS NULL OR @Barkod = N'') THEN 1 ELSE 0 END;

    DECLARE @SQL NVARCHAR(MAX) = N'';

    -- HESAPPLANI baslik satirlari (yalnizca arama bos iken)
    IF @AramaBos = 1
        SET @SQL = @SQL +
        N' SELECT ID, KOD=HESAPKODU,
              ROOTKOD = CASE WHEN HESAPKODU = REVERSE(SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1))) THEN ''.''
                        ELSE REVERSE(SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1))) END,
              AD=HESAPADI, TUR=N''Başlık'', KALAN=NULL, FIYAT=NULL, KUR=NULL, STOKMARKA=NULL, STOKMODEL=NULL,
              KDV=NULL, OTVYUZDE=NULL, OTVMIKTAR=NULL, KDVDURUM=NULL, PAKET=CAST(0 AS SMALLINT), IZLEME=CAST(0 AS SMALLINT),
              BIRIM=NULL, STOKGRUBU=NULL, MASRAFID=NULL, OZELKOD=NULL
           FROM HESAPPLANI WHERE VARSAYILAN = ' + @Varsayilan + N'
           UNION ALL ';

    -- MASRAFGELIR (hizmet/baslik) + FIYATLAR
    SET @SQL = @SQL +
        N' SELECT M.ID, KOD=M.KOD,
              ROOTKOD = CASE WHEN M.KOD = REVERSE(SUBSTRING(REVERSE(M.KOD),CHARINDEX(''.'',REVERSE(M.KOD),1)+1,LEN(M.KOD)-(CHARINDEX(''.'',REVERSE(M.KOD),1)-1))) THEN ''.''
                        ELSE REVERSE(SUBSTRING(REVERSE(M.KOD),CHARINDEX(''.'',REVERSE(M.KOD),1)+1,LEN(M.KOD)-(CHARINDEX(''.'',REVERSE(M.KOD),1)-1))) END,
              M.AD, TUR = CASE WHEN M.BASLIK=0 THEN N''Hizmet'' ELSE N''Başlık'' END, KALAN=NULL,
              FIYAT = CASE WHEN M.BASLIK=1 THEN NULL ELSE ISNULL(F.FIYAT,-1) END,
              KUR   = CASE WHEN M.BASLIK=1 THEN NULL ELSE F.KUR END,
              STOKMARKA=NULL, STOKMODEL=NULL,
              KDV = CASE WHEN M.BASLIK=1 THEN NULL ELSE M.KDV END, OTVYUZDE=NULL, OTVMIKTAR=NULL,
              KDVDURUM = CASE WHEN M.BASLIK=1 THEN NULL ELSE F.KDVDURUM END,
              PAKET=CAST(0 AS SMALLINT), IZLEME=CAST(0 AS SMALLINT),
              BIRIM = CASE WHEN M.BASLIK=1 THEN NULL ELSE ISNULL(M.BIRIM,' + @sBirimi + N') END,
              STOKGRUBU=NULL, MASRAFID=NULL, OZELKOD=M.OZELKOD
           FROM MASRAFGELIR M
              LEFT OUTER JOIN FIYATLAR F ON M.ID=F.HIZMETID AND F.FIYATADI=' + @sFiyat + N' AND F.PAKETID=0 AND F.SATIS=' + @Satis01 + N'
           WHERE GELIRMI=' + @Gelirmi + N' AND DURUM>0 ';

    IF @Kod    IS NOT NULL AND @Kod    <> N'' SET @SQL = @SQL + N' AND M.KOD LIKE N''%'' + @pKod + N''%'' ';
    IF @Ad     IS NOT NULL AND @Ad     <> N'' SET @SQL = @SQL + N' AND M.AD LIKE N''%'' + @pAd + N''%'' ';
    IF @Barkod IS NOT NULL AND @Barkod <> N'' SET @SQL = @SQL + N' AND ISNULL(M.BARKOD,N'''') LIKE N''%'' + @pBarkod + N''%'' ';
    IF @SubeVar = 1 SET @SQL = @SQL + N' AND M.SUBEID IN (0,' + CAST(@SubeID AS NVARCHAR(20)) + N') ';

    SET @SQL = @SQL + N' ORDER BY 2 ';

    EXEC sp_executesql @SQL,
         N'@pKod NVARCHAR(100), @pAd NVARCHAR(150), @pBarkod NVARCHAR(50)',
         @pKod = @Kod, @pAd = @Ad, @pBarkod = @Barkod;
END;
GO
