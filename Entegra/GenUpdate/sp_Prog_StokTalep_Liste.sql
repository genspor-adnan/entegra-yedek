-- ============================================================
-- sp_Prog_StokTalep_Liste — Stok Talep liste ekrani sunucu-tarafi listeleme (UStokTalepListe)
--   sp_Prog_Stok_Liste deseninin Stok Talep karsiligi. Kaynak: UStokTalepListe.SQLMemo
--   (JvTimer1Timer'in kurdugu sorgu) BIREBIR reprodukte edilir; sadece TOP / KA join /
--   siralama / ek-filtre parcalari dinamiklestirildi (plan reuse + enjeksiyon guvenli).
--   Sonuc kumesi orijinalle AYNI (ayni kolonlar, DISTINCT, 3x PROJEKOD dahil).
--   @Mod: 1=Tum (TOP yok), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.DEGISTIRMETARIHI)
--   @Modul: Son/Sik icin KULLANICI_ARAMA.MODUL — Stok Talep = 2709 (MODUL 'Stoktan Talep')
--   PK: SIPARIS.ID (S.ID). Belge turu S.TUR=105 (Stok Talep).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_StokTalep_Liste
    @SelectList     NVARCHAR(MAX) = N'',     -- ',[Cap]=Field,...' (ek alan SELECT); StokTalep'te genelde ''
    @TopN           INT           = 200,     -- 0 = TOP yok (Tum mod)
    @Mod            SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @Pasif          BIT           = 0,        -- StokTalep'te aktif/pasif kavrami yok (no-op; imza uyumu icin)
    @TarihBas       DATETIME      = NULL,     -- SIPARISTARIH >= (Filtre modunda dolu; Tum/Son/Sik'te NULL)
    @TarihBit       DATETIME      = NULL,     -- SIPARISTARIH <=
    @SubeCikis      INT           = NULL,     -- S.SUBE  (ComboSubeCikis; secili degilse NULL)
    @SubeGiris      INT           = NULL,     -- S.GIRISSUBE (ComboSubeGiris; secili degilse NULL)
    @KulId          INT           = NULL,     -- @Mod=3/5 icin kullanici (KULLANICI_ARAMA.KULID)
    @Modul          INT           = NULL,     -- @Mod=3/5 icin KULLANICI_ARAMA.MODUL (StokTalep=2709)
    @OrderBy        NVARCHAR(200) = NULL      -- NULL/'' ise SIPARISTARIH desc (orijinal siralama)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    -- DISTINCT + ORDER BY kurali: KA sort kolonu SELECT listesinde olmali (yoksa hata)
    DECLARE @KaCol NVARCHAR(60) = CASE WHEN @Mod = 3 THEN N', KA.SAY'
                                       WHEN @Mod = 5 THEN N', KA.DEGISTIRMETARIHI'
                                       ELSE N'' END;

    SET @SQL = N'
    SELECT DISTINCT ' + @Top + N' S.ID,S.DURUM,
    TALEPTARIH=SIPARISTARIH, TALEPNO=SIPARISNO,
    DETAYBOLUMU,
    TALEPEDENAD=(SELECT FIRMA FROM REHBER R WHERE S.SATICIKODU = R.ID),
    TALEPEDENBIRIM=(select DEPARTMAN=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 ) from ROLLER ROL where ROL.ID=S.BOLUM),
    BIRIMONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLAYACAK = R.ID),
    BIRIMONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.BIRIMONAYLAYAN = R.ID),
    TALEPONAYLAYACAKAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYACAK = R.ID),
    TALEPONAYLAYANAD=(SELECT FIRMA FROM REHBER R WHERE S.ONAYLAYAN = R.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    PROJEKOD=(SELECT PROJEKODU FROM PROJELER P WHERE S.PROJEID = P.ID),
    S.ACIKLAMA,S.OZELKOD,
    GIRISDEPOSU=(select DEPOADI from DEPOLAR D where D.ID=S.GIRISDEPO),
    S.TIPI,S.REHBERID,S.TUR,S.SUBEID,
    S.ONAYLAYACAK,S.ONAYLAYAN,
    KAYNAK= case when (S.TUR=105)and(467 in (select YERI from SIPARISDETAY where YERID in (select ID from URETIMEMRIDETAY UED where SD.YERID=UED.ID))) then ''Üretimden'' else '''' end,
    HEDEF=  case when (S.TUR=105)and(435 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then ''Transfer'' end'
    + @SelectList + @KaCol + N'
    from SIPARIS S (NOLOCK) inner join REHBER R on R.ID = S.REHBERID
    LEFT OUTER JOIN SIPARISDETAY SD ON S.ID = SD.SIPARISID '
    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 (unique KULID,MODUL,KAYITID)
    + CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = S.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' where S.TUR=105 ';

    -- Tarih araligi (Filtre modunda; Tum/Son/Sik'te app NULL gonderir) - parametreli
    IF @TarihBas IS NOT NULL
        SET @SQL = @SQL + N' and SIPARISTARIH >= @pTarihBas ';
    IF @TarihBit IS NOT NULL
        SET @SQL = @SQL + N' and SIPARISTARIH <= @pTarihBit ';

    -- Sube filtreleri (secili degilse app NULL gonderir) - guvenli int cast
    IF @SubeCikis IS NOT NULL AND @SubeCikis >= 0
        SET @SQL = @SQL + N' and S.SUBE = ' + CAST(@SubeCikis AS NVARCHAR(20)) + N' ';
    IF @SubeGiris IS NOT NULL AND @SubeGiris >= 0
        SET @SQL = @SQL + N' and S.GIRISSUBE = ' + CAST(@SubeGiris AS NVARCHAR(20)) + N' ';

    -- Son/Sik siralamasi (KULLANICI_ARAMA); aksi halde orijinal: SIPARISTARIH desc
    IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
    ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    ELSE IF @OrderBy IS NULL OR @OrderBy = N'' SET @OrderBy = N'SIPARISTARIH desc';

    SET @SQL = @SQL + N' order by ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pTarihBas DATETIME, @pTarihBit DATETIME',
         @pTarihBas = @TarihBas, @pTarihBit = @TarihBit;
END;
