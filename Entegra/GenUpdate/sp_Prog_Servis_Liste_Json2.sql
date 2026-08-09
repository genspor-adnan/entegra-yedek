CREATE OR ALTER PROCEDURE dbo.sp_Prog_Servis_Liste_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SelectList     NVARCHAR(MAX) = ISNULL(@Baslik, N'');
    DECLARE @TopN           INT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.TopN') AS INT), 0);
    DECLARE @Mod            SMALLINT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Mod')  AS SMALLINT), 4);
    DECLARE @Pasif          BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Pasif') AS BIT), 0);
    DECLARE @ServisNo       NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.ServisNo');
    DECLARE @ServisNoId     INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.ServisNoId') AS INT);
    DECLARE @ServisNoLike   BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.ServisNoLike') AS BIT), 0);
    DECLARE @KategoriAd     NVARCHAR(150) = JSON_VALUE(@Kosullar,'$.KategoriAd');
    DECLARE @Konusu         NVARCHAR(250) = JSON_VALUE(@Kosullar,'$.Konusu');
    DECLARE @Urun           NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Urun');
    DECLARE @Musteri        NVARCHAR(200) = JSON_VALUE(@Kosullar,'$.Musteri');
    -- Belirli bir cariye ait servisler (cari ekranindaki Servis alt sekmesi).
    --   @Musteri AD uzerinden LIKE arar; bu KIMLIK uzerinden kesin filtredir.
    DECLARE @RehberId       INT           = TRY_CAST(JSON_VALUE(@Kosullar,'$.RehberId') AS INT);
    DECLARE @SeriNo         NVARCHAR(50)  = JSON_VALUE(@Kosullar,'$.SeriNo');
    DECLARE @SeriNoLike     BIT           = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.SeriNoLike') AS BIT), 0);
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

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @Top NVARCHAR(30) = CASE WHEN @TopN > 0
                                     THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                     ELSE N'' END;
    DECLARE @KaJoin BIT = CASE WHEN @Mod IN (3, 5) AND @KulId IS NOT NULL AND @Modul IS NOT NULL
                               THEN 1 ELSE 0 END;

    -- SERVIS_USER (kullanici EK ALAN tablosu) kolonlari MUSTERIDEN MUSTERIYE DEGISIR.
    --   Eskiden burada bir musterinin alanlari (MARKA, TIP1, KASANO...) SABIT yaziliydi ->
    --   o alanlar olmayan musteride "Invalid column name 'MARKA'" ile liste hic acilmiyordu.
    --   Cozum: kolon listesi metadata'dan URETILIR (ID + audit kolonlari haric). Tablo yoksa
    --   ya da ek alan yoksa liste bos kalir, sorgu yine calisir.
    DECLARE @UserCols NVARCHAR(MAX) = N'';
    IF OBJECT_ID('dbo.SERVIS_USER','U') IS NOT NULL
        SELECT @UserCols = @UserCols + N', SU0.' + QUOTENAME(c.name)
        FROM sys.columns c
        WHERE c.object_id = OBJECT_ID('dbo.SERVIS_USER')
          AND c.name NOT IN ('ID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI')
        ORDER BY c.column_id;

    -- ===== ON SUZME (PERF) ==========================================================
    -- ESKI YAPI: butun SERVIS tablosu (or. 34.000 satir) icin ~15 correlated subquery +
    --   8 join + DISTINCT hesaplanip SONRA disarida filtrelenip TOP aliniyordu. Kapali
    --   servis listesi bu yuzden 5-12 sn suruyordu; TopN=100 hic limitsizden bile yavasti
    --   (row-goal ile kotu plan). DISTINCT de gereksizdi: cogaltan join yok (FATBASLIK ve
    --   REHBERILETISIM tekil, SERVISBILGI zaten ROW_NUMBER=1).
    -- YENI YAPI: SERVIS uzerindeki TUM filtreler + TOP en icteki taramaya indirilir; pahali
    --   alt sorgular yalniz SECILEN satirlar icin hesaplanir. Filtreler SERVIS'in kendi
    --   kolonlarina (ya da EXISTS ile hareket/rehber tablolarina) dokundugu icin bu guvenli.
    -- Sayfalama (TSayfaliListe) TOP'u buyuterek ayni sorguyu tekrar cagirir -> ON SUZMEDE
    --   deterministik ORDER BY (ID DESC = en yeni servis) sart; eskiden ORDER BY yoktu ve
    --   hangi 100 kaydin gelecegi belirsizdi.
    DECLARE @Filt NVARCHAR(MAX) = N'';

    IF @ServisNo IS NOT NULL AND @ServisNo <> N''
    BEGIN
        SET @Filt = @Filt + N' AND ((SV0.SERVISNO ' + CASE WHEN @ServisNoLike = 1 THEN N'LIKE' ELSE N'=' END + N' @pServisNo)';
        IF @ServisNoId IS NOT NULL AND @ServisNoId <> 0
            SET @Filt = @Filt + N' OR (SV0.ID = ' + CAST(@ServisNoId AS NVARCHAR(20)) + N')';
        SET @Filt = @Filt + N')';
    END;

    IF @SeriNo IS NOT NULL AND @SeriNo <> N''
        SET @Filt = @Filt + N' AND SV0.SERINO ' + CASE WHEN @SeriNoLike = 1 THEN N'LIKE' ELSE N'=' END + N' @pSeriNo ';

    IF @KategoriAd IS NOT NULL AND @KategoriAd <> N''
        SET @Filt = @Filt + N' AND (SELECT AD FROM KATEGORI K WHERE K.ID = SV0.EKIPMANID) = @pKategoriAd ';

    IF @Konusu IS NOT NULL AND @Konusu <> N''
        SET @Filt = @Filt + N' AND SV0.KONUSU LIKE N''%'' + @pKonusu + N''%'' ';

    IF @Urun IS NOT NULL AND @Urun <> N''
        SET @Filt = @Filt + N' AND (SELECT AD FROM EKIPMANLAR E WHERE E.ID = SV0.EKIPMANID) LIKE N''%'' + @pUrun + N''%'' ';

    IF @Musteri IS NOT NULL AND @Musteri <> N''
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM REHBER RM WHERE RM.ID = SV0.REHBERID AND RM.FIRMA LIKE N''%'' + @pMusteri + N''%'') ';

    IF ISNULL(@RehberId, 0) > 0
        SET @Filt = @Filt + N' AND SV0.REHBERID = ' + CAST(@RehberId AS NVARCHAR(20)) + N' ';

    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @Filt = @Filt + N' AND SV0.SUBEID IN (' + @SubeYetkiList + N') ';

    IF @cbListe = 1
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE ISNULL(SH.BITISSEC,0)=0 AND SH.SERVISID=SV0.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 2
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 5
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.PERSONEL IN '
                          + N' (SELECT R.ID FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                          + N'  WHERE ROL.DEPARTMAN=(SELECT ROL.DEPARTMAN FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                          + N'  WHERE R.ID=' + CAST(@Kullanan AS NVARCHAR(20)) + N'))) ';
    ELSE IF @cbListe = 8
        SET @Filt = @Filt + N' AND SV0.SUBEID=' + CAST(@SubeID AS NVARCHAR(20)) + N' ';

    IF @DurumVar = 1
        SET @Filt = @Filt + N' AND SV0.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' ';

    IF @DurumVar = 1 AND @SorumluTag > 0
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 0 AND @SorumluTag > 0
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 1 AND @SorumluTag = 0
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=SV0.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N') ';

    -- Ac/kapali: servis no ya da seri no ile arama yapiliyorsa uygulanmaz (eski davranis).
    IF (@ServisNo IS NULL OR @ServisNo = N'') AND (@SeriNo IS NULL OR @SeriNo = N'')
    BEGIN
        IF @Kapali = 1
        BEGIN
            IF @Tamamlanan = 1
                SET @Filt = @Filt + N' AND ((ISNULL(SV0.ACKAPA,0)=0) OR (CAST(SV0.BASLAMATARIHI AS DATE)=CAST(GETDATE() AS DATE))) ';
            ELSE IF @Tamamlanan = 19000
                SET @Filt = @Filt + N' AND ((ISNULL(SV0.ACKAPA,0)=0) OR (SV0.BASLAMATARIHI BETWEEN @pTarihBas AND @pTarihBit)) ';
            ELSE
                SET @Filt = @Filt + N' AND ((ISNULL(SV0.ACKAPA,0)=0) OR (SV0.BASLAMATARIHI >= @pKapaliTarih)) ';
        END
        ELSE
            SET @Filt = @Filt + N' AND SV0.ACKAPA = 0 ';
    END;

    -- Son/Sik Aranan (Mod 3/5): kayit kumesi KULLANICI_ARAMA ile sinirli -> on suzmeye de
    --   ayni kisit girer, siralama/join disarida kalir (kucuk kume, maliyet yok).
    IF @KaJoin = 1
        SET @Filt = @Filt + N' AND EXISTS (SELECT 1 FROM KULLANICI_ARAMA KA0 WHERE KA0.KAYITID = SV0.ID AND KA0.KULID = '
                          + CAST(@KulId AS NVARCHAR(20)) + N' AND KA0.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N') ';

    -- Mod 3/5 siralamasi KULLANICI_ARAMA'ya bagli -> on suzmede TOP UYGULANMAZ (yanlis
    --   kayitlar secilirdi); orada TOP eskisi gibi en distadir.
    DECLARE @OnTop NVARCHAR(30) = CASE WHEN @TopN > 0 AND @KaJoin = 0
                                       THEN N'TOP (' + CAST(@TopN AS NVARCHAR(20)) + N') '
                                       ELSE N'' END;
    DECLARE @OnSira NVARCHAR(60) = CASE WHEN @OnTop <> N'' THEN N' ORDER BY SV0.ID DESC ' ELSE N'' END;
    -- ================================================================================

    SET @SQL = N'
    SELECT ' + @Top + N' S.* ' + ISNULL(@SelectList, N'') + N'
    FROM (
        SELECT
            SV.ID,
            SV.BASLAMATARIHI,
            SV.REHBERID,
            SV.SERVISNO,
            SV.KONUSU,
            SV.DURUM,
            SV.MUS_ILGILI,
            SV.BITISTARIHI,
            SV.SERINO,
            SV.KASA,
            SV.FIYAT_LISTESI,
            SV.OZELKOD,
            SV.YETKIKODU,
            SV.NOTLAR,
            SV.EKIPMANREHBERID,
            SV.DEPO,
            SV.LOKASYONID,
            SV.PLANLANAN_MATRAHI,
            SV.PLANLANAN_TUTAR,
            SV.PLANLANAN_KUR,
            SV.PLANLANAN_DOVIZ_TUTARI,
            SV.PLANLANAN_DOVIZ_KURU,
            SV.PLANLANAN_KDV_TUTARI,
            SV.UYGULANAN_MATRAHI,
            SV.UYGULANAN_TUTAR,
            SV.UYGULANAN_KUR,
            SV.UYGULANAN_DOVIZ_TUTARI,
            SV.UYGULANAN_DOVIZ_KURU,
            SV.UYGULANAN_KDV_TUTARI,
            SV.SORUMLU,
            SV.KABUL_EDEN,
            SV.KABUL_SEKLI,
            SV.TESLIM_ALAN,
            SV.TESLIM_EDEN,
            SV.TESLIM_TARIHI,
            SV.TESLIM_SEKLI,
            SV.TESLIM_KARGO_NO,
            SV.ONAYSEKLI,
            SV.ONAYTARIHI,
            SV.ONAYLAYAN,
            SV.ONAYALAN,
            SV.SUBEID,
            SV.EKLEYEN,
            SV.EKLEMETARIHI,
            SV.DEGISTIREN,
            SV.DEGISTIRMETARIHI,
            SV.KAPSAM,
            SV.DETAYBOLUMU,
            SV.ACIL,
            SV.DISSERVIS,
            SV.TARIH,
            SV.EKIPMANID,
            SV.TESLIMNOTU,
            SV.ACKAPA,
            SV.DEMIRBAS,
            SV.YERI,
            SV.YERID,
            SV.TURU,
            SV.ONAYLAYACAK,
            SV.DISONAY,
            SV.SERVISADRESI,
            SV.KOCANNO,
            SV.SERVISSERI,
            SV.ONEMLI,
            SV.PROJEID,
            SV.GIRISKAYNAK,
            SV.YILDIZ,
            SH.BASLAMA,
            SH.BITIS,
            SH.TOPLAM_SURE,
            SH.CALISMA_SURESI,
            SORUN_TIPI = SL.AD,
            SORUN_ACIKLAMA = SB.ACIKLAMA,
            SORUN_SONUCU = SB.COZUM,
            KABUL_EDENAD = R7.FIRMA,
            KATEGORIAD = CASE WHEN SV.DEMIRBAS = 1 THEN (SELECT STOKADI FROM DEMIRBAS_URUN DU INNER JOIN DEMIRBAS D ON D.KATEGORIID = DU.ID WHERE D.ID = SV.EKIPMANID) ELSE (SELECT AD FROM KATEGORI K WHERE K.ID = SV.EKIPMANID) END,
            EKIPMANAD = CASE WHEN SV.DEMIRBAS = 1 THEN (SELECT DEMIRBASADI FROM DEMIRBAS D WHERE D.ID = SV.EKIPMANID) ELSE (SELECT AD FROM EKIPMANLAR E WHERE E.ID = SV.EKIPMANID) END,
            R1.FIRMA,
            SORUMLUAD = CASE
                            WHEN SV.DURUM = 0
                                THEN (SELECT DISTINCT R.FIRMA FROM SERVISHAREKET SH2 INNER JOIN REHBER R ON SH2.PERSONEL = R.ID WHERE SH2.SERVISID = SV.ID)
                            WHEN ISNULL(SV.DURUM, 0) <> 0
                                THEN (SELECT TOP 1 R.FIRMA FROM SERVISHAREKET SH2 INNER JOIN REHBER R ON SH2.PERSONEL = R.ID WHERE SH2.SERVISID = SV.ID AND SH2.DURUM = SV.DURUM ORDER BY SH2.BASLAMA DESC)
                            ELSE ''''
                        END,
            RP.FIRMA AS MUS_ILGILIAD,
            LOKASYON = (SELECT ACIKLAMA FROM LOKASYON L WHERE L.ID = SV.LOKASYONID),
            ONAYLAYANAD = (SELECT R5.FIRMA FROM REHBER R5 WHERE R5.GRUP = 334 AND R5.ID = SV.DISONAY),
            TESLIM_ALANAD = (SELECT R5.FIRMA FROM REHBER R5 WHERE R5.GRUP = 334 AND R5.ID = SV.TESLIM_ALAN),
            ONAYSEKLIAD = (SELECT ANAHTAR FROM GENINI G WHERE BOLUM = -3005 AND G.DEGER = SV.ONAYSEKLI),
            FB.FATURATARIH,
            FB.FATURANO,
            FB.FATURA_TUTARI,
            SERVIS_ADRESI = RI.AD' + @UserCols + N'
        FROM (SELECT ' + @OnTop + N' SV0.*
                FROM SERVIS SV0
               WHERE 1 = 1 ' + @Filt + @OnSira + N') SV
        LEFT JOIN SERVIS_USER SU0 ON SU0.ID = SV.ID
        -- V_Servis_Hareket_Ozet gorunumu TUM SERVISHAREKET kayitlarini GROUP BY ile ozetler
        --   ve her grup icin IKI SKALER UDF (fn_TarihFarkiFormatli/2) calistirir. LEFT JOIN
        --   edilince optimizer gorunumun TAMAMINI uretiyordu -> 34.000 servis x 2 UDF =
        --   listenin asil maliyeti. OUTER APPLY ayni hesabi YALNIZ secilen satirlar icin yapar.
        OUTER APPLY (SELECT BASLAMA = MIN(SH1.BASLAMA),
                            BITIS   = MAX(SH1.BITIS),
                            TOPLAM_SURE    = dbo.fn_TarihFarkiFormatli(MIN(SH1.BASLAMA), MAX(SH1.BITIS)),
                            CALISMA_SURESI = dbo.fn_TarihFarkiFormatli2(SUM(CONVERT(FLOAT,(SH1.BITIS - SH1.BASLAMA))))
                       FROM SERVISHAREKET SH1
                      WHERE SH1.SERVISID = SV.ID
                        AND SH1.BASLAMA IS NOT NULL AND SH1.BITIS IS NOT NULL) SH
        LEFT JOIN REHBER R1 ON R1.ID = SV.REHBERID
        LEFT JOIN REHBER RP ON RP.ID = SV.MUS_ILGILI AND RP.GRUP = 334
        LEFT JOIN FATBASLIK FB ON FB.SERVISID = SV.ID AND FB.TUR IN (15, 16)
        -- ROW_NUMBER li turetilmis tablo da TUM SERVISBILGI icin hesaplaniyordu; ilk satiri
        --   satir-basina getiren APPLY ayni sonucu index seek ile verir.
        OUTER APPLY (SELECT TOP 1 SB2.ACIKLAMA, SB2.COZUM, SB2.SERVISLISTEID
                       FROM SERVISBILGI SB2
                      WHERE SB2.SERVISID = SV.ID AND SB2.SERVISTUR = 210
                      ORDER BY SB2.ID) SB
        LEFT JOIN SERVISLISTE SL ON SL.ID = SB.SERVISLISTEID
        LEFT JOIN REHBERILETISIM RI ON RI.REHBERID = SV.REHBERID AND RI.ID = SV.SERVISADRESI
        LEFT JOIN REHBER R7 ON R7.ID = SV.EKLEYEN
    ) S
    LEFT JOIN SERVIS_USER SU ON SU.ID = S.ID '
    + CASE WHEN @KaJoin = 1
           THEN N' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID = S.ID AND KA.KULID = '
                + CAST(@KulId AS NVARCHAR(20)) + N' AND KA.MODUL = ' + CAST(@Modul AS NVARCHAR(20)) + N' '
           ELSE N'' END
    + N' WHERE 1 = 1 ';
    -- NOT: Filtreler artik ON SUZMEDE (yukaridaki @Filt); burada TEKRARLANMAZ.
    --   Disarida kalan tek sey Son/Sik Aranan siralamasi icin KULLANICI_ARAMA join'i.

    IF @KaJoin = 1
    BEGIN
        IF @Mod = 5 SET @OrderBy = N'KA.DEGISTIRMETARIHI DESC';
        ELSE IF @Mod = 3 SET @OrderBy = N'KA.SAY DESC';
    END;

    -- Mod 4 (normal filtre): on suzme ID DESC ile TOP aldigi icin dista da AYNI sira
    --   verilmeli; yoksa turetilmis tablonun sirasi garanti degildir ve sayfa buyudukce
    --   (TSayfaliListe) grid'deki satir sirasi oynayabilir.
    IF (@OrderBy IS NULL OR @OrderBy = N'') AND @KaJoin = 0
        SET @OrderBy = N'S.ID DESC';

    IF @OrderBy IS NOT NULL AND @OrderBy <> N''
        SET @SQL = @SQL + N' ORDER BY ' + @OrderBy;

    EXEC sp_executesql @SQL,
         N'@pServisNo NVARCHAR(50), @pKategoriAd NVARCHAR(150), @pKonusu NVARCHAR(250), @pUrun NVARCHAR(200), @pMusteri NVARCHAR(200), @pSeriNo NVARCHAR(50), @pTarihBas NVARCHAR(20), @pTarihBit NVARCHAR(20), @pKapaliTarih NVARCHAR(20)',
         @pServisNo = @ServisNo, @pKategoriAd = @KategoriAd, @pKonusu = @Konusu, @pUrun = @Urun,
         @pMusteri = @Musteri, @pSeriNo = @SeriNo, @pTarihBas = @TarihBas, @pTarihBit = @TarihBit, @pKapaliTarih = @KapaliTarih;
END;
GO

IF OBJECT_ID(N'dbo.sp_Prog_Servis_Liste', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Prog_Servis_Liste;
GO



