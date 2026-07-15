-- ============================================================
-- GenDepoUpdate8 : sp_Prog_Proje_Liste_Json2  (2-param JSON, guncel)
--   Liste ekrani sunucu-tarafi listeleme SP'si. ANA DB baglantisindan.
--   IDEMPOTENT: CREATE OR ALTER. BAGIMLILIK: GenDepoUpdate4 (KULLANICI_ARAMA).
-- ============================================================

-- ============================================================
-- sp_Prog_Proje_Liste_Json2 — tek JSON parametre (MSSQL-ONLY)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR); @Kosullar = filtreler (JSON).
--   @Kosullar = '{"Mod":4,"Pasif":0,...}' -> JSON_VALUE ile yerel degiskenlere (tipli).
--   sp_Prog_Proje_Liste (tipli-param) ile AYNI sonuc kumesi/govde; sadece imza JSON.
--   Amac: JSON vs tipli-param paritesi (Teklif pilotu deseni: sp_Prog_Teklif_Liste_Json2).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Proje_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)              -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList     NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN           INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')   AS INT), 0);
    DECLARE @Mod            SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')    AS SMALLINT), 4);
    DECLARE @Pasif          BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif')  AS BIT), 0);
    DECLARE @Firma          NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.Firma');
    DECLARE @ProjeKodu      NVARCHAR(100) = JSON_VALUE(@Kosullar,'$.ProjeKodu');
    DECLARE @ProjeAdi       NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.ProjeAdi');
    DECLARE @Yetkili        NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.Yetkili');
    DECLARE @Konusu         NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Konusu');
    DECLARE @Sorumlu        INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Sorumlu') AS INT), 0);
    DECLARE @Turu           INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Turu')    AS INT), 0);
    DECLARE @Asama          INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Asama')   AS INT), 0);
    DECLARE @Sonuc          INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Sonuc')   AS INT), 0);
    DECLARE @TarihBas       DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit       DATETIME      = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    DECLARE @KendiKul       INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KendiKul')  AS INT), 0);
    DECLARE @KendiSube      INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KendiSube') AS INT), 0);
    DECLARE @SubeYetkiList  NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');
    DECLARE @KulId          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId') AS INT);
    DECLARE @Modul          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);
    DECLARE @OrderBy        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.OrderBy');

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;

    SET @SQL = N'
    SELECT ' + @Top + N'
        P.ID,LOKAL_FIRMA_ID,P.REHBERID,PROJEKODU,BASLAMATARIHI,BITISTARIHI,KONUSU,TURU,P.DURUM,ASAMA,PRJ_SORUMLUSU_ID,PRJ_ASAMA_SORUMLUSU_ID,
        ILGILI,LISTEFIYATI,LISTEKUR,SATISFIYATI,SATISKUR,P.EKLEYEN,P.EKLEMETARIHI,P.DEGISTIREN,P.DEGISTIRMETARIHI,
        SONUC,SONUCACIKLAMA,DETAYBOLUMU,TIPI,APLIKASYON,PROJEADI,OLASILIK,
        P.SUBEID, GOOGLEOLAYID,GOOGLEHESAPID,CARIID,SEBEBI,KAYIPFIYATI,KAYIPKUR,P.GIRISKAYNAK,RAKIP,
        NOTLAR=(Select top 1 GY.YORUM from GOREVYORUM GY where P.ID=GY.GOREVID and GY.TUR=70 order by GY.TARIH desc),
        ALANRAKIP=(select FIRMA from REHBER RR where P.CARIID=RR.ID),
        FIRMA= CASE WHEN LEN(LTRIM(RTRIM(R1.FIRMA)))-LEN(REPLACE(LTRIM(RTRIM(R1.FIRMA)),'' '',''''))<2 THEN R1.FIRMA ELSE SUBSTRING(R1.FIRMA, 0, CHARINDEX('' '', R1.FIRMA, CHARINDEX('' '', R1.FIRMA, 0)+1)) END,
        ProjeTipi.ANAHTAR PROJETIPI,
        ADSOYAD = RP.FIRMA,
        SORUMLUAD=(select top 1 FIRMA from REHBER RSOR where RSOR.ID=P.PRJ_SORUMLUSU_ID),
        ASAMASORUMLU=(select top 1 FIRMA from REHBER R5 inner join PROJEASAMA PA on R5.ID=PA.REHBERID where PA.PROJEID=P.ID and PA.ASAMA=P.ASAMA),
        BASLAMAAY=month(P.BASLAMATARIHI),
        BASLAMAYIL=year(P.BASLAMATARIHI),
        BITISAY=month(P.BITISTARIHI),
        BITISYIL=year(P.BITISTARIHI),
        DOSYAVAR = CASE WHEN (Select top 1 COUNT(ID) from GOREVYORUM GY where P.ID=GY.GOREVID and GY.TUR=70 and GOREVID=1 )>0 then 1 else 0 end,
        SONAKTIVITEKONUSU = (SELECT TOP 1 KONUSU FROM GOREVLER A WHERE PROJEID = P.ID and ACKAPA=1 ORDER BY BITISTARIHI DESC ),
        SONAKTIVITETARIHI = convert(DateTime,(SELECT TOP 1 BITISTARIHI FROM GOREVLER A WHERE PROJEID = P.ID and ACKAPA=1 ORDER BY BITISTARIHI DESC),103),
        SONSATBELGETARIHI = convert(DateTime,(SELECT TOP 1 TARIH FROM FATBASLIK F WHERE F.PROJEID = P.ID AND F.TUR in (10,11,12,14,15,16) ORDER BY TARIH DESC ),103),
        SONSATTUTARI = (SELECT TOP 1 FATURA_TUTARI FROM FATBASLIK F WHERE F.PROJEID = P.ID AND F.TUR in (10,11,12,14,15,16) ORDER BY TARIH DESC ),
        SONTEKLIFDURUMU=(select top 1 DURUM from TEKLIF T where T.PROJEID = P.ID order by TARIH desc),
        SONTEKLIFTUTARI=(select top 1 TEKLIF_MATRAHI from TEKLIF T where T.PROJEID = P.ID order by TARIH desc),
        SONTEKLIFKUR=(select top 1 KUR from TEKLIF T where T.PROJEID = P.ID order by TARIH desc),
        SONTEKLIFTARIHI=convert(DateTime,(select top 1 TARIH from TEKLIF T where T.PROJEID = P.ID order by TARIH desc),103)
        ' + @SelectList + N'
    FROM PROJELER P
        inner join REHBER R1 on R1.ID=P.REHBERID
        left outer join REHBER RP on RP.ID=P.ILGILI
        LEFT OUTER JOIN GENINI ProjeTipi ON ProjeTipi.DIL=-1 and ProjeTipi.DEGER = P.TIPI AND ProjeTipi.BOLUM=convert(int,''-2112''+convert(varchar(10),P.TURU)) '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = P.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE P.MODUL=11 ';

    -- checkKapaliGoster kapaliyken kapali projeler haric
    IF @Pasif = 0
        SET @SQL = @SQL + N' AND P.DURUM <> 2 ';

    -- Tarih araligi (checkTarih) - BASLAMATARIHI uzerinde
    IF @TarihBas IS NOT NULL
        SET @SQL = @SQL + N' AND P.BASLAMATARIHI >= @pTarihBas ';
    IF @TarihBit IS NOT NULL
        SET @SQL = @SQL + N' AND P.BASLAMATARIHI <= @pTarihBit ';

    -- Metin filtreleri (parametreli) - orijinaldeki ISNULL(...,'') LIKE '%x%' desenini korur
    IF @Firma IS NOT NULL AND @Firma <> N''
        SET @SQL = @SQL + N' AND ISNULL(R1.FIRMA,N'''') LIKE N''%'' + @pFirma + N''%'' ';
    IF @ProjeKodu IS NOT NULL AND @ProjeKodu <> N''
        SET @SQL = @SQL + N' AND ISNULL(P.PROJEKODU,N'''') LIKE N''%'' + @pProjeKodu + N''%'' ';
    IF @ProjeAdi IS NOT NULL AND @ProjeAdi <> N''
        SET @SQL = @SQL + N' AND ISNULL(P.PROJEADI,N'''') LIKE N''%'' + @pProjeAdi + N''%'' ';
    IF @Yetkili IS NOT NULL AND @Yetkili <> N''
        SET @SQL = @SQL + N' AND ISNULL(RP.FIRMA,N'''') LIKE N''%'' + @pYetkili + N''%'' ';
    IF @Konusu IS NOT NULL AND @Konusu <> N''
        SET @SQL = @SQL + N' AND ISNULL(P.KONUSU,N'''') LIKE N''%'' + @pKonusu + N''%'' ';

    -- Sayisal filtreler (int cast - guvenli)
    IF @Sorumlu > 0
        SET @SQL = @SQL + N' AND P.PRJ_SORUMLUSU_ID = ' + CAST(@Sorumlu AS NVARCHAR(20)) + N' ';
    IF @Turu > 0
        SET @SQL = @SQL + N' AND P.TURU = ' + CAST(@Turu AS NVARCHAR(20)) + N' ';
    IF @Asama > 0
        SET @SQL = @SQL + N' AND P.ASAMA = ' + CAST(@Asama AS NVARCHAR(20)) + N' ';
    IF @Sonuc > 0
        SET @SQL = @SQL + N' AND P.SONUC = ' + CAST(@Sonuc AS NVARCHAR(20)) + N' ';

    -- Modul yetkisi (ModulYetki_TekSubeTum.Proje: 1=kendi, 10=kendi sube)
    IF @KendiKul > 0
        SET @SQL = @SQL + N' AND P.PRJ_SORUMLUSU_ID = ' + CAST(@KendiKul AS NVARCHAR(20)) + N' ';
    IF @KendiSube > 0
        SET @SQL = @SQL + N' AND P.SUBEID = ' + CAST(@KendiSube AS NVARCHAR(20)) + N' ';

    -- Sube yetkisi (SubeVarmi) - orijinal: P.SUBEID in(list) (leading 0 YOK)
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND P.SUBEID in (' + @SubeYetkiList + N') ';

    -- Son/Sik aranan siralamasi (KULLANICI_ARAMA); yoksa app @OrderBy (SATISKUR)
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pFirma NVARCHAR(150), @pProjeKodu NVARCHAR(100), @pProjeAdi NVARCHAR(200),
           @pYetkili NVARCHAR(150), @pKonusu NVARCHAR(200), @pTarihBas DATETIME, @pTarihBit DATETIME',
         @pFirma = @Firma, @pProjeKodu = @ProjeKodu, @pProjeAdi = @ProjeAdi,
         @pYetkili = @Yetkili, @pKonusu = @Konusu, @pTarihBas = @TarihBas, @pTarihBit = @TarihBit;
END;
