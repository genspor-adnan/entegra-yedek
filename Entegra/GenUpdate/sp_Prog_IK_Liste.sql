-- ============================================================
-- sp_Prog_IK_Liste — IK (personel / aday) liste ekrani sunucu-tarafi listeleme (UIKListeDlg)
--   sp_Prog_Stok_Liste deseninin IK karsiligi. Eski JvTimer/Label string-kurma
--   yollarinin (SQL_IK_Memo / SQL_IK_Aday memolari) tek SP'de toplanmis hali.
--   SELECT listesi/JOIN'ler ilgili memonun sorgusuyla BIREBIR (grid kolonlari degismez).
--
--   @Aday : 0 = personel (REHBER.GRUP=335, SQL_IK_Memo)  1 = aday (REHBER.GRUP=5, SQL_IK_Aday, DISTINCT)
--   @Mod  : 1=Tum (order by 1)  3=Sik (KA.SAY desc)  4=Filtre (JvTimer)  5=Son (KA.DEGISTIRMETARIHI desc)
--   @Pasif: 0 = sadece aktif (R.DURUM>0)   1 = hepsi
--   @Dil  : GENINI.DIL parametresi (eski memodaki DIL=-1 yerine; app runtime Dil degerini gecirir, coklu-dil kapaliyken -1)
--   @IlgiliArama: eski memo yerel degiskeni @ILGILIARAMA (0=normal; ilgili-kisi join CASE'inde kullanilir)
--
--   Alan filtreleri yalniz @Mod=4 (Filtre) icinde uygulanir (eski Tum/Son/Sik alan filtresi uygulamiyordu).
--   Metin filtreleri sp_executesql ile parametreli (enjeksiyon guvenli); sayisal/liste filtreleri int-cast inline.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_IK_Liste
    @Aday          BIT           = 0,
    @TopN          INT           = 0,        -- 0 = TOP yok (IK'da hep 0; Son/Sik icin sinir istenirse >0)
    @Mod           SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @Pasif         BIT           = 0,
    @Dil           INT           = -1,
    @IlgiliArama   INT           = 0,
    -- Filtreler (yalniz @Mod=4)
    @Firma         NVARCHAR(150) = NULL,     -- R.FIRMA LIKE (personel AraFirma / aday AraFirma2)
    @Kod           NVARCHAR(50)  = NULL,     -- R.KOD LIKE (yalniz personel)
    @Cinsiyet      INT           = NULL,     -- aday: R.STATU
    @Ogrenim       INT           = NULL,     -- aday: R.KATEGORI
    @Sektor        INT           = NULL,     -- aday: PD.SEKTOR
    @Departman     INT           = NULL,     -- aday: PD.DEPARTMAN
    @Gorev         INT           = NULL,     -- aday: PD.GOREV
    @Dil1          INT           = NULL,     -- aday: PERS_DIL exists
    @Dil2          INT           = NULL,     -- aday: PERS_DIL exists
    @Il            INT           = NULL,     -- aday: PD.IL
    @Uyruk         INT           = NULL,     -- aday: R.ALTBOLGE
    @UcretAlt      MONEY         = NULL,     -- aday: PD.UCRET_ALT between
    @UcretUst      MONEY         = NULL,
    -- Yetki / sube
    @SubeYetkiList NVARCHAR(MAX) = NULL,     -- SubeVarmi ise yetkili sube id listesi (virgullu)
    @TekSubeTum    SMALLINT      = 0,        -- ModulYetki_TekSubeTum.IK (1=sadece temsilci, 10=sadece sube) - yalniz @Mod=4
    @KulId         INT           = NULL,     -- Kullanan (TekSubeTum=1 + Mod 3/5 KULLANICI_ARAMA)
    @SubeId        INT           = NULL,     -- TekSubeTum=10
    @Modul         INT           = NULL      -- KULLANICI_ARAMA.MODUL (IK=34)
AS
BEGIN
    SET NOCOUNT ON;

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
