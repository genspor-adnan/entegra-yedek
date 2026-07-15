-- ============================================================
-- sp_Prog_IK_Liste_Json2 — IK (personel / aday) liste, tek-JSON parametre (MSSQL)
--   IKI PARAM: @Baslik = SELECT ek kolonlari (ham SQL, GUVENILIR; IK'da genelde bos);
--              @Kosullar = filtreler (JSON: cast/parametreli DEGERLER).
--   sp_Prog_IK_Liste (tipli) ile PARITE: govde birebir, sadece giris tipli-param yerine JSON_VALUE.
--   @Kosullar = '{"Aday":0,"Mod":4,"Firma":"...","UcretAlt":1000,...}' -> yerel degiskenlere.
--   Absent key -> NULL; ISNULL'lu olanlar tipli SP varsayilanina duser.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_IK_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',   -- SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR)
    @Kosullar NVARCHAR(MAX)          -- filtreler (JSON: cast/parametreli DEGERLER)
AS
BEGIN
    SET NOCOUNT ON;

    -- ---- JSON -> yerel degiskenler (tipli). Absent key -> NULL. ----
    DECLARE @SelectList    NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @Aday          BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Aday')        AS BIT), 0);
    DECLARE @TopN          INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN')        AS INT), 0);
    DECLARE @Mod           SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')         AS SMALLINT), 4);
    DECLARE @Pasif         BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif')       AS BIT), 0);
    DECLARE @Dil           INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Dil')         AS INT), -1);
    DECLARE @IlgiliArama   INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IlgiliArama') AS INT), 0);
    -- Filtreler (yalniz @Mod=4)
    DECLARE @Firma         NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.Firma');
    DECLARE @Kod           NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.Kod');
    DECLARE @Cinsiyet      INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Cinsiyet')  AS INT);
    DECLARE @Ogrenim       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Ogrenim')   AS INT);
    DECLARE @Sektor        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Sektor')    AS INT);
    DECLARE @Departman     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Departman') AS INT);
    DECLARE @Gorev         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Gorev')     AS INT);
    DECLARE @Dil1          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Dil1')      AS INT);
    DECLARE @Dil2          INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Dil2')      AS INT);
    DECLARE @Il            INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Il')        AS INT);
    DECLARE @Uyruk         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Uyruk')     AS INT);
    DECLARE @UcretAlt      MONEY         = TRY_CAST(JSON_VALUE(@Kosullar,'$.UcretAlt')  AS MONEY);
    DECLARE @UcretUst      MONEY         = TRY_CAST(JSON_VALUE(@Kosullar,'$.UcretUst')  AS MONEY);
    -- Yetki / sube
    DECLARE @SubeYetkiList NVARCHAR(MAX) = JSON_VALUE(@Kosullar,'$.SubeYetkiList');
    DECLARE @TekSubeTum    SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TekSubeTum') AS SMALLINT), 0);
    DECLARE @KulId         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.KulId')  AS INT);
    DECLARE @SubeId        INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.SubeId') AS INT);
    DECLARE @Modul         INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT);

    -- ================= BURADAN ITIBAREN GOVDE TIPLI-PARAM SP ILE BIREBIR =================
    DECLARE @SQL      NVARCHAR(MAX);
    DECLARE @Sel      NVARCHAR(MAX);
    DECLARE @Frm      NVARCHAR(MAX);
    DECLARE @Whr      NVARCHAR(MAX) = N'';
    DECLARE @Ord      NVARCHAR(200) = N'';
    DECLARE @Top      NVARCHAR(30)  = CASE WHEN @TopN > 0
                                           THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                           ELSE N'' END;
    DECLARE @Distinct NVARCHAR(10)  = CASE WHEN @Aday = 1 THEN N'DISTINCT ' ELSE N'' END;

    IF @Aday = 0
    BEGIN
        -- ---- PERSONEL (SQL_IK_Memo, GRUP=335) : SELECT listesi BIREBIR ----
        SET @Sel = N'R.ID,R.KOD,VKNO=(select BILGI from REHBERBILGI where YERI=3 AND YER_ID=R.ID  AND SIRA=22)
,ADSOYAD=R.FIRMA,
CINSIYET=(select top 1 ANAHTAR from GENINI where BOLUM=-23355 and DEGER=R.STATU and DIL=@pDil),
DYERI= (select top 1 ILADI from ILILCE where ILCENO=R.BOLGE),
UYRUGU= (select top 1 ILADI from ILLER where ILNO=R.ALTBOLGE),
DTARIHI=R.DTARIH,
SEKTOR='''',
DEPARTMAN=(select top 1 ANAHTAR from GENINI where BOLUM=-2251 and DEGER=ROL.DEPARTMAN and DIL=@pDil),
GOREVI=(SELECT top 1 ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=@pDil ),
OGRENIM=(SELECT top 1 ANAHTAR FROM GENINI WHERE BOLUM=-2255 AND DEGER = R.KATEGORI AND DIL=@pDil ),
GIRISTARIHI=(select top 1 TARIH from PERS_HAREKET where REHBERID=R.ID  and TUR=1 ),
CIKISTARIHI=(select top 1 TARIH from PERS_HAREKET where REHBERID=R.ID  and TUR=99),
ILCEAD=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERILETISIM RI (nolock) ON RI.REHBERID=R.ID and RI.VARSAYILAN=1 INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=6),
ILAD=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERILETISIM RI (nolock) ON RI.REHBERID=R.ID and RI.VARSAYILAN=1 INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=1 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN=8),
R.SUBEID, SUBE = (select FIRMA from REHBER where ID=R.SUBEID),
NOTLAR=(Select top 1 GY.YORUM from GOREVYORUM GY where R.ID=GY.GOREVID and GY.TUR=11 order by GY.TARIH desc),
R.DURUM,
DURUMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2201 and DEGER=R.DURUM and DIL=@pDil),
R.OZELKOD,R.BAGID ';

        SET @Frm = N'FROM REHBER R
     left outer join ROLLER ROL on R.SINIF=ROL.ID
     left outer join REHBER P on R.ID = P.BAGID and P.GRUP=334 and
       1 = CASE WHEN @pIlgili = 1 THEN 1
                WHEN @pIlgili = 0 AND isnull(P.STATU,1) = 1 THEN 1
                ELSE 0 END ';

        SET @Whr = N' WHERE R.ID > 0 and R.GRUP=335 ';
    END
    ELSE
    BEGIN
        -- ---- ADAY (SQL_IK_Aday, GRUP=5, DISTINCT) : SELECT listesi BIREBIR ----
        SET @Sel = N'R.ID,R.KOD,VKNO=(select BILGI from REHBERBILGI where YERI=3 AND YER_ID=R.ID  AND SIRA=22)
,ADSOYAD=R.FIRMA,
CINSIYET=(select top 1 ANAHTAR from GENINI where BOLUM=-23355 and DEGER=R.STATU and DIL=@pDil),
DYERI= (select top 1 ILADI from ILILCE where ILCENO=R.BOLGE),
UYRUGU= (select top 1 ILADI from ILLER where ILNO=R.ALTBOLGE),
DTARIHI=R.DTARIH,
SEKTOR=(select top 1 ANAHTAR from GENINI G inner join PERS_DENEYIM PD on G.DEGER=PD.SEKTOR and TUR=0 where PD.REHBERID=R.ID and G.BOLUM=-2204 and G.DIL=@pDil order by PD.BASVURUTARIHI desc),
DEPARTMAN=(select top 1 ANAHTAR from GENINI G inner join PERS_DENEYIM PD on G.DEGER=PD.DEPARTMAN and TUR=0 where PD.REHBERID=R.ID and G.BOLUM=-2206 and G.DIL=@pDil order by PD.BASVURUTARIHI desc),
GOREVI=(SELECT top 1 ANAHTAR FROM GENINI G inner join PERS_DENEYIM PD on G.DEGER=PD.GOREV and TUR=0 where PD.REHBERID=R.ID and G.BOLUM=-2205 AND G.DIL=@pDil order by PD.BASVURUTARIHI desc),
OGRENIM=(SELECT top 1 ANAHTAR FROM GENINI WHERE BOLUM=-2255 AND DEGER = R.KATEGORI AND DIL=@pDil ),
GIRISTARIHI=(select top 1 BASVURUTARIHI from PERS_DENEYIM where REHBERID=R.ID  and TUR=0 order by BASVURUTARIHI desc),
CIKISTARIHI=(select top 1 BASLAMATARIHI from PERS_DENEYIM where REHBERID=R.ID  and TUR=0 order by BASVURUTARIHI desc),
ILCEAD=(select top 1 ILCEADI from PERS_DENEYIM PD inner join ILILCE II on PD.IL=II.ILNO and PD.ILCE=II.ILCENO where REHBERID=R.ID  and TUR=0 order by BASVURUTARIHI desc),
ILAD=(select top 1 ILADI from PERS_DENEYIM PD inner join ILILCE II on PD.IL=II.ILNO and PD.ILCE=II.ILCENO where REHBERID=R.ID  and TUR=0 order by BASVURUTARIHI desc),
R.SUBEID, SUBE = (select FIRMA from REHBER where ID=R.SUBEID),
NOTLAR=(Select top 1 GY.YORUM from GOREVYORUM GY where R.ID=GY.GOREVID and GY.TUR=11 order by GY.TARIH desc),
R.DURUM,
DURUMAD=(select top 1 ANAHTAR from GENINI where BOLUM=-2201 and DEGER=R.DURUM and DIL=@pDil),
R.OZELKOD,R.BAGID ';

        SET @Frm = N'FROM REHBER R
     left outer join ROLLER ROL on R.SINIF=ROL.ID
     left outer join REHBER P on R.ID = P.BAGID and P.GRUP=334 and
       1 = CASE WHEN @pIlgili = 1 THEN 1
                WHEN @pIlgili = 0 AND isnull(P.STATU,1) = 1 THEN 1
                ELSE 0 END
     left outer join PERS_DENEYIM PD on R.ID = PD.REHBERID ';

        SET @Whr = N' WHERE R.ID > 0 and R.GRUP=5 ';
    END

    -- @Baslik (ek SELECT kolonlari) - IK'da genelde bos; caller leading virgul verir (pilot ile ayni)
    SET @Sel = @Sel + @SelectList;

    -- Pasif: kapaliyken sadece aktif
    IF @Pasif = 0
        SET @Whr = @Whr + N' AND R.DURUM > 0 ';

    -- Sube yetkisi (SubeVarmi ise app @SubeYetkiList gonderir) - tum modlar
    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @Whr = @Whr + N' AND R.SUBEID IN (' + @SubeYetkiList + N') ';

    -- Tek sube / temsilci yetkisi (ModulYetki_TekSubeTum.IK) - yalniz Filtre (Mod=4), eski JvTimer gibi
    IF @Mod = 4
    BEGIN
        IF @TekSubeTum = 1  AND @KulId  IS NOT NULL
            SET @Whr = @Whr + N' AND R.TEMSILCI = ' + CAST(@KulId  AS NVARCHAR(20)) + N' ';
        IF @TekSubeTum = 10 AND @SubeId IS NOT NULL
            SET @Whr = @Whr + N' AND R.SUBEID = '   + CAST(@SubeId AS NVARCHAR(20)) + N' ';
    END

    -- Alan filtreleri (yalniz Filtre modu = 4)
    IF @Mod = 4
    BEGIN
        -- Firma (her iki modda R.FIRMA LIKE) - parametreli
        IF @Firma IS NOT NULL AND @Firma <> N''
            SET @Whr = @Whr + N' AND R.FIRMA LIKE N''%'' + @pFirma + N''%'' ';

        IF @Aday = 0
        BEGIN
            IF @Kod IS NOT NULL AND @Kod <> N''
                SET @Whr = @Whr + N' AND R.KOD LIKE N''%'' + @pKod + N''%'' ';
        END
        ELSE
        BEGIN
            IF @Cinsiyet  IS NOT NULL SET @Whr = @Whr + N' AND R.STATU = '     + CAST(@Cinsiyet  AS NVARCHAR(20)) + N' ';
            IF @Ogrenim   IS NOT NULL SET @Whr = @Whr + N' AND R.KATEGORI = '  + CAST(@Ogrenim   AS NVARCHAR(20)) + N' ';
            IF @Sektor    IS NOT NULL SET @Whr = @Whr + N' AND PD.SEKTOR = '   + CAST(@Sektor    AS NVARCHAR(20)) + N' ';
            IF @Departman IS NOT NULL SET @Whr = @Whr + N' AND PD.DEPARTMAN = '+ CAST(@Departman AS NVARCHAR(20)) + N' ';
            IF @Gorev     IS NOT NULL SET @Whr = @Whr + N' AND PD.GOREV = '    + CAST(@Gorev     AS NVARCHAR(20)) + N' ';
            IF @Dil1      IS NOT NULL SET @Whr = @Whr + N' AND exists(select 1 from PERS_DIL DIL where DIL.REHBERID=R.ID and DIL=' + CAST(@Dil1 AS NVARCHAR(20)) + N') ';
            IF @Dil2      IS NOT NULL SET @Whr = @Whr + N' AND exists(select 1 from PERS_DIL DIL where DIL.REHBERID=R.ID and DIL=' + CAST(@Dil2 AS NVARCHAR(20)) + N') ';
            IF @Il        IS NOT NULL SET @Whr = @Whr + N' AND PD.IL = '       + CAST(@Il        AS NVARCHAR(20)) + N' ';
            IF @Uyruk     IS NOT NULL SET @Whr = @Whr + N' AND R.ALTBOLGE = '  + CAST(@Uyruk     AS NVARCHAR(20)) + N' ';
            IF @UcretAlt  IS NOT NULL AND @UcretUst IS NOT NULL
                SET @Whr = @Whr + N' AND PD.TUR=0 and PD.UCRET_ALT between @pUcretAlt and @pUcretUst ';
        END
    END

    -- Mod 3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join (unique KULID,MODUL,KAYITID)
    IF @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
    BEGIN
        SET @Frm = @Frm + N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = R.ID AND KA.KULID = '
                 + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' ';
        -- Aday DISTINCT + siralama kolonu SELECT'te olmali (SQL Server 145 hatasi)
        IF @Aday = 1 AND @Mod = 5 SET @Sel = @Sel + N', KA.DEGISTIRMETARIHI ';
        IF @Aday = 1 AND @Mod = 3 SET @Sel = @Sel + N', KA.SAY ';
    END

    -- Siralama
    IF @Mod = 1
        SET @Ord = N'1';
    ELSE IF @Mod = 5
        SET @Ord = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3
        SET @Ord = N'KA.SAY DESC';
    ELSE  -- Mod 4 (Filtre)
    BEGIN
        IF @Aday = 0 AND @Kod IS NOT NULL AND @Kod <> N''
            SET @Ord = N'R.SUBEID, R.KOD';
        ELSE
            SET @Ord = N'R.SUBEID,R.FIRMA';
    END

    SET @SQL = N'SELECT ' + @Distinct + @Top + @Sel + N' ' + @Frm + @Whr
             + CASE WHEN @Ord <> N'' THEN N' ORDER BY ' + @Ord ELSE N'' END;

    EXEC sp_executesql @SQL,
         N'@pDil INT, @pIlgili INT, @pFirma NVARCHAR(150), @pKod NVARCHAR(50), @pUcretAlt MONEY, @pUcretUst MONEY',
         @pDil = @Dil, @pIlgili = @IlgiliArama, @pFirma = @Firma, @pKod = @Kod,
         @pUcretAlt = @UcretAlt, @pUcretUst = @UcretUst;
END;
