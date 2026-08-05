SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================
-- GenDepoUpdate63 (musteri uygulama)
--   sp_Prog_StokHizmetAra_Stok_Json2 duzeltme + ek:
--   1) SERI NO aramasi HATALIYDI: SERINO kolonu artik STOKIZLEME'de degil
--      (izleme refactor'unda STOKSERILOT'a tasindi; STOKIZLEME.SERILOTID FK).
--      Eski filtre "SBI.SERINO" calisir calismaz "Invalid column name" veriyordu.
--      Yeni filtre STOKSERILOT.SERINO uzerinden (LIKE, kismi arama).
--   2) Detayli aramaya LOT NO eklendi (JSON $.Lotno; STOKSERILOT.LOTNO/LOTNO_EX).
--   Uygulama build'i de gerekir (UStokHizmetAra: EditLotno + JSON Lotno).
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
    DECLARE @Lotno       NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.Lotno');
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
            -- SERI NO: STOKSERILOT.SERINO (STOKIZLEME'de SERINO kolonu YOK; SERILOTID FK).
            IF @Serino IS NOT NULL AND @Serino <> N'' SET @Filt = @Filt + N' AND S.ID IN (SELECT SSL.STOKID FROM STOKSERILOT SSL WHERE SSL.SERINO LIKE N''%'' + @pSerino + N''%'') ';
            -- LOT NO: STOKSERILOT.LOTNO (+LOTNO_EX serbest alan).
            IF @Lotno  IS NOT NULL AND @Lotno  <> N'' SET @Filt = @Filt + N' AND S.ID IN (SELECT SSL2.STOKID FROM STOKSERILOT SSL2 WHERE SSL2.LOTNO LIKE N''%'' + @pLotno + N''%'' OR SSL2.LOTNO_EX LIKE N''%'' + @pLotno + N''%'') ';
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
         N'@pKod NVARCHAR(100), @pAd NVARCHAR(150), @pBarkod NVARCHAR(50), @pSerino NVARCHAR(50), @pLotno NVARCHAR(50), @pDoviz NVARCHAR(10)',
         @pKod = @Kod, @pAd = @Ad, @pBarkod = @Barkod, @pSerino = @Serino, @pLotno = @Lotno, @pDoviz = @CariDoviz;
END;
GO
