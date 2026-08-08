-- ============================================================
-- GenDepoUpdate85.sql
-- sp_Prog_Gorev_Liste_Json2 : bellek grant'i duzeltmesi (istenen 12,2 MB)
--
-- GenDepoUpdate83 (Dokuman) / 84 (Stok Talep) ile AYNI SINIF hata, daha kucuk
--   olcekte: SQL Express'te sorgu-bellek semaforu ~10 MB'a dustugunde bu istek de
--   karsilanamaz ve Gorev listesi acilirken ekran RESOURCE_SEMAPHORE'da donar.
--
-- KOK NEDEN: "LEFT JOIN GOREVYORUM GY" KOSULSUZ duruyordu. Gorev basina yorum
--   sayisi kadar satir uretiyor, bunu "SELECT DISTINCT" topluyordu (tum kolonlar
--   uzerinde hash/sort). GY yalnizca OPSIYONEL @Ara metin aramasinda kullaniliyor.
--   GOREVKULLANICI GK join'i @AtananID'ye bagli olsa da o da 1:N - filtre aktifken
--   ayni cogaltmayi yapiyordu.
--
-- COZUM: iki join de kaldirildi, filtreler EXISTS'e cevrildi, DISTINCT kaldirildi.
--   EXISTS satir cogaltmaz; sonuc kumesi ayni, DISTINCT'e gerek kalmaz.
-- ============================================================
-- ============================================================
-- sp_Prog_Gorev_Liste_Json2 — tek JSON parametre versiyonu (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; Gorev'de bos);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   Tipli sp_Prog_Gorev_Liste ile GOVDE BIREBIR; sadece imza + parametre-cozumleme farkli.
--   @Kosullar = '{"Mod":4,"Ara":"...","BasTarih":"2026-01-01",...}' -> JSON_VALUE + TRY_CAST.
--   Absent key -> NULL (filtre yok). Bool'lar 0/1 sayi (TRY_CAST AS BIT).
--   DISTINCT + Son/Sik siralama tuzagi (@SonSikCol) korunur.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Gorev_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList   NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN         INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')  AS INT), 0);
    DECLARE @Mod          SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')   AS SMALLINT), 4);
    DECLARE @Pasif        BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @Ara          NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Ara');
    DECLARE @Tarih        BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Tarih') AS BIT), 0);
    DECLARE @BasTarih     NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.BasTarih');
    DECLARE @BitTarih     NVARCHAR(20)  = JSON_VALUE(@Kosullar,'$.BitTarih');
    DECLARE @FirmaID      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.FirmaID')     AS INT);
    DECLARE @OlusturanID  INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.OlusturanID') AS INT);
    DECLARE @AtananID     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.AtananID')    AS INT);
    DECLARE @GorevID      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.GorevID')     AS INT);
    DECLARE @KulId        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId')       AS INT);
    DECLARE @Modul        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul')       AS INT);
    DECLARE @OrderBy      NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    -- Son/Sik: DISTINCT + ORDER BY icin siralama kolonlari SELECT'e alias ile eklenir
    -- (KA join ile ayni kosul: KA yoksa kolonlara referans verilmez)
    DECLARE @SonSikCol NVARCHAR(120) = CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
                                            THEN N', KA.DEGISTIRMETARIHI AS SON_ARAMA, KA.SAY AS SIK_ARAMA '
                                            ELSE N'' END;

    SET @SQL = N'
    SELECT ' + @Top + N'
        G.ID, G.ACKAPA,
        LISTEID=G.LISTEID, LISTEADI=GL.ADI,
        G.KONUSU,
        TURU=(SELECT top 1 ANAHTAR FROM GENINI where BOLUM=-21044 and DIL=-1 and DEGER=G.TURU),
        G.EKLEYEN,
        G.REHBERID,CARIAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.REHBERID),
        MUS_ILGILI = (SELECT FIRMA FROM REHBER R WHERE R.ID=G.MUS_ILGILI),
        ATANAN1=(SELECT [dbo].[fn_GorevVerilenKisiler](11, G.ID)),
        G.BASLAMATARIHI,G.BITISTARIHI,
        TEKRAR_BIT=convert(bit, (CASE WHEN TEKRARID>0 THEN 1 ELSE 0 END)),
        ANIMSAT_BIT=convert(bit, (CASE WHEN ANIMSAT>0 THEN 1 ELSE 0 END)),
        G.BAYRAK, G.DURUM, G.EKLEMETARIHI,
        PROJEKODU=(SELECT PROJEKODU FROM PROJELER P WHERE P.ID=G.PROJEID),
        EKLEYENAD=(SELECT FIRMA FROM REHBER R WHERE R.ID=G.EKLEYEN)
        ' + @SonSikCol + @SelectList + N'
    FROM GOREVLER G
        INNER JOIN GOREVLISTE GL on G.LISTEID=GL.ID '
    -- GOREVYORUM ve GOREVKULLANICI ARTIK JOIN DEGIL - ikisi de 1:N, satir cogaltiyordu.
    --   Onceki halde "LEFT JOIN GOREVYORUM GY" KOSULSUZ duruyordu (yalnizca opsiyonel
    --   @Ara metin aramasi icin gerekli) ve cogalan satirlari SELECT DISTINCT topluyordu.
    --   DISTINCT tum kolonlar uzerinde hash/sort demek: 12,2 MB bellek grant'i.
    --   Filtreler asagida EXISTS'e cevrildi; bkz. GenDepoUpdate83/84 ayni sinif hata.
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = G.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1=1 ';

    -- Pasif=0: sadece acik gorevler (CheckTamamlanan kapali -> ACKAPA=0)
    IF @Pasif = 0
        SET @SQL = @SQL + N' AND G.ACKAPA = 0 ';

    -- Metin arama (KONUSU / GOREVYORUM.YORUM) - parametreli
    IF @Ara IS NOT NULL AND @Ara <> N''
        SET @SQL = @SQL + N' AND (G.KONUSU LIKE N''%'' + @pAra + N''%''
                                  OR EXISTS (SELECT 1 FROM GOREVYORUM GY
                                              WHERE GY.GOREVID = G.ID
                                                AND GY.YORUM LIKE N''%'' + @pAra + N''%'')) ';

    -- Tarih araligi (BASLAMATARIHI) - orijinaldeki > ve < ile birebir
    IF @Tarih = 1 AND @BasTarih IS NOT NULL AND @BitTarih IS NOT NULL
    BEGIN
        SET @SQL = @SQL + N' AND G.BASLAMATARIHI >''' + @BasTarih + N' 00:00'' ';
        SET @SQL = @SQL + N' AND G.BASLAMATARIHI <''' + @BitTarih + N' 23:59'' ';
    END;

    -- Sayisal filtreler (guvenli - int cast)
    IF @FirmaID IS NOT NULL AND @FirmaID > 0
        SET @SQL = @SQL + N' AND G.REHBERID = ' + CAST(@FirmaID AS NVARCHAR(20)) + N' ';
    IF @OlusturanID IS NOT NULL AND @OlusturanID > 0
        SET @SQL = @SQL + N' AND G.EKLEYEN = ' + CAST(@OlusturanID AS NVARCHAR(20)) + N' ';
    IF @AtananID IS NOT NULL AND @AtananID > 0
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM GOREVKULLANICI GK
                                          WHERE GK.LISTGOREVID = G.ID AND GK.TUR = 11
                                            AND GK.REHBERID = ' + CAST(@AtananID AS NVARCHAR(20)) + N') ';
    IF @GorevID IS NOT NULL AND @GorevID > 0
        SET @SQL = @SQL + N' AND G.ID = ' + CAST(@GorevID AS NVARCHAR(20)) + N' ';

    -- Son/Sik aranan siralamasi (KULLANICI_ARAMA); DISTINCT icin SELECT alias'lari
    IF @Mod = 5 SET @OrderBy = N'SON_ARAMA DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'SIK_ARAMA DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pAra NVARCHAR(200)',
         @pAra = @Ara;
END;
