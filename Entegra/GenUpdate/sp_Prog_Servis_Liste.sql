-- ============================================================
-- sp_Prog_Servis_Liste — Servis liste ekrani sunucu-tarafi listeleme (UServisListeDlg)
--   sp_Prog_Stok_Liste deseninin Servis karsiligi.
--   PARITE: eski JvTimer sorgusu 'select * from VServisListesi S where 1=1' + Delphi'de
--   kurulan filtreleri kullaniyordu. Sonuc kumesi BIREBIR ayni tutulur -> SELECT S.*
--   dogrudan VServisListesi view'inden gelir (kolonlar/DISTINCT view'in kendi tanimindan).
--   Metin filtreleri parametreli (plan reuse + enjeksiyon guvenli); sayisal filtreler int cast.
--   @Mod: 1=Tum (TOP yok), 3=Sik Aranan (KA.SAY), 4=Filtre, 5=Son Aranan (KA.tarih)
--   @Pasif: Servis'te aktif/pasif bayragi YOK -> kullanilmaz (sablon simetrisi icin var). Kapali
--           kayit filtresi @Kapali/@Tamamlanan uzerinden yonetilir (S.ACKAPA).
--   @SelectList: ek (ozel) alanlar - ',[Cap]=Field,...' (S.* sonrasina eklenir)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Servis_Liste
    @SelectList     NVARCHAR(MAX) = N'',     -- ',[Cap]=Field,...' (ek alan SELECT)
    @TopN           INT           = 0,       -- 0 = TOP yok (Servis eski sorgusu limitsizdi)
    @Mod            SMALLINT      = 4,        -- 1=Tum 3=Sik 4=Filtre 5=Son
    @Pasif          BIT           = 0,        -- rezerve (kullanilmaz - Servis'te aktif/pasif yok)
    @ServisNo       NVARCHAR(50)  = NULL,     -- EditNo.Text (SERVISNO LIKE, sayisal ise +ID)
    @ServisNoId     INT           = NULL,     -- StrToIntDef(EditNo,0); <>0 ise OR S.ID = bu
    @KategoriAd     NVARCHAR(150) = NULL,     -- EditKategori.Text (guard: Tag>0 => Ad<>'')
    @Konusu         NVARCHAR(250) = NULL,     -- AraKonusu.Text (LIKE %..%)
    @Urun           NVARCHAR(200) = NULL,     -- editUrun.Text (EKIPMANLAR.AD LIKE %..%)
    @Musteri        NVARCHAR(200) = NULL,     -- AraMusteri.Text (FIRMA LIKE %..%)
    @SeriNo         NVARCHAR(50)  = NULL,     -- EditSerino.Text (SERINO LIKE ..%)
    @SubeYetkiList  NVARCHAR(MAX) = NULL,     -- SubeVarmi ise YetkiliSubeleriGetir(30,Gorme)
    @cbListe        INT           = NULL,     -- 1=Aktif 2=Ilgili 5=Departman 8=Sube (9=Butun -> filtre yok)
    @Kullanan       INT           = NULL,     -- oturum kullanicisi (REHBER.ID)
    @SubeID         INT           = NULL,     -- @cbListe=8 icin sube
    @Durum          INT           = NULL,     -- AraDurumu.EditValue
    @DurumVar       BIT           = 0,        -- AraDurumu.Text<>''
    @SorumluTag     INT           = 0,        -- EditSorumlu.Tag
    @Kapali         BIT           = 0,        -- CheckKapali.Checked
    @Tamamlanan     INT           = NULL,     -- ComboTamamlanan.EditValue (1=bugun,19000=aralik,else=son X gun)
    @KapaliTarih    NVARCHAR(20)  = NULL,     -- son X gun: app'te hesaplanan (BugunTrh-EditValue) yyyy-mm-dd
    @TarihBas       NVARCHAR(20)  = NULL,     -- @Tamamlanan=19000 aralik basi (yyyy-mm-dd)
    @TarihBit       NVARCHAR(20)  = NULL,     -- @Tamamlanan=19000 aralik sonu (yyyy-mm-dd)
    @KulId          INT           = NULL,     -- @Mod=3/5 icin KULLANICI_ARAMA.KULID
    @Modul          INT           = NULL,     -- @Mod=3/5 icin MODUL.MODULID (Servis=30)
    @OrderBy        NVARCHAR(200) = NULL      -- opsiyonel siralama (Son/Sik icinde set edilir)
AS
BEGIN
    SET NOCOUNT ON;

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
