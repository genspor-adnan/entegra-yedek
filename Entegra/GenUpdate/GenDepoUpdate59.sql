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

    SET @SQL = N'
    SELECT ' + @Top + N' S.* ' + ISNULL(@SelectList, N'') + N'
    FROM (
        SELECT DISTINCT
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
            SU0.MARKA,
            SU0.TIP1,
            SU0.TIP2,
            SU0.GIRISTIPI,
            SU0.KORDONTIPI,
            SU0.GARANTI,
            SU0.IBRAZTARIHI,
            SU0.TEditGarantiFisNo,
            SU0.MusteriAdı,
            SU0.ReferansNo,
            SU0.Adres_,
            SU0.Adres2_,
            SU0.CepTel,
            SU0.E_posta,
            SU0.TEKNISYEN_KODU,
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
            SERVIS_ADRESI = RI.AD,
            SU0.KASANO
        FROM '
    + CASE WHEN (@ServisNo IS NOT NULL AND @ServisNo <> N'') OR (@SeriNo IS NOT NULL AND @SeriNo <> N'')
           THEN N'(SELECT TOP (' + CAST(CASE WHEN @TopN > 0 THEN @TopN ELSE 200 END AS NVARCHAR(20)) + N') *
                   FROM SERVIS SV0
                   WHERE (1 = 0' +
                CASE WHEN @ServisNo IS NOT NULL AND @ServisNo <> N''
                     THEN CASE WHEN @ServisNoLike = 1
                               THEN N' OR SV0.SERVISNO LIKE @pServisNo'
                               ELSE N' OR SV0.SERVISNO = @pServisNo'
                          END
                     ELSE N''
                END +
                CASE WHEN @ServisNoId IS NOT NULL AND @ServisNoId <> 0
                     THEN N' OR SV0.ID = ' + CAST(@ServisNoId AS NVARCHAR(20))
                     ELSE N''
                END +
                CASE WHEN @SeriNo IS NOT NULL AND @SeriNo <> N''
                     THEN CASE WHEN @SeriNoLike = 1
                               THEN N' OR SV0.SERINO LIKE @pSeriNo'
                               ELSE N' OR SV0.SERINO = @pSeriNo'
                          END
                     ELSE N''
                END + N')
                   ORDER BY SV0.ID DESC) SV '
           ELSE N'SERVIS SV '
      END
    + N'
        LEFT JOIN SERVIS_USER SU0 ON SU0.ID = SV.ID
        LEFT JOIN V_Servis_Hareket_Ozet SH ON SH.SERVISID = SV.ID
        LEFT JOIN REHBER R1 ON R1.ID = SV.REHBERID
        LEFT JOIN REHBER RP ON RP.ID = SV.MUS_ILGILI AND RP.GRUP = 334
        LEFT JOIN FATBASLIK FB ON FB.SERVISID = SV.ID AND FB.TUR IN (15, 16)
        LEFT JOIN (SELECT *, SIRANO = ROW_NUMBER() OVER (PARTITION BY SB2.SERVISID ORDER BY SB2.ID) FROM SERVISBILGI SB2 WHERE SB2.SERVISTUR = 210) SB ON SB.SIRANO = 1 AND SB.SERVISID = SV.ID
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

    IF @ServisNo IS NOT NULL AND @ServisNo <> N''
    BEGIN
        SET @SQL = @SQL + N' AND ((S.SERVISNO ' + CASE WHEN @ServisNoLike = 1 THEN N'LIKE' ELSE N'=' END + N' @pServisNo)';
        IF @ServisNoId IS NOT NULL AND @ServisNoId <> 0
            SET @SQL = @SQL + N' OR (S.ID = ' + CAST(@ServisNoId AS NVARCHAR(20)) + N')';
        SET @SQL = @SQL + N')';
    END;

    IF @KategoriAd IS NOT NULL AND @KategoriAd <> N''
        SET @SQL = @SQL + N' AND (SELECT AD FROM KATEGORI K WHERE K.ID = S.EKIPMANID) = @pKategoriAd ';

    IF @Konusu IS NOT NULL AND @Konusu <> N''
        SET @SQL = @SQL + N' AND S.KONUSU LIKE N''%'' + @pKonusu + N''%'' ';

    IF @Urun IS NOT NULL AND @Urun <> N''
        SET @SQL = @SQL + N' AND (SELECT AD FROM EKIPMANLAR E WHERE E.ID = S.EKIPMANID) LIKE N''%'' + @pUrun + N''%'' ';

    IF @Musteri IS NOT NULL AND @Musteri <> N''
        SET @SQL = @SQL + N' AND FIRMA LIKE N''%'' + @pMusteri + N''%'' ';

    IF @SubeYetkiList IS NOT NULL AND @SubeYetkiList <> N''
        SET @SQL = @SQL + N' AND S.SUBEID IN (' + @SubeYetkiList + N') ';

    IF @SeriNo IS NOT NULL AND @SeriNo <> N''
        SET @SQL = @SQL + N' AND S.SERINO ' + CASE WHEN @SeriNoLike = 1 THEN N'LIKE' ELSE N'=' END + N' @pSeriNo ';

    IF @cbListe = 1
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE ISNULL(SH.BITISSEC,0)=0 AND SH.SERVISID=S.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 2
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.PERSONEL=' + CAST(@Kullanan AS NVARCHAR(20)) + N') ';
    ELSE IF @cbListe = 5
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.PERSONEL IN '
                        + N' (SELECT R.ID FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                        + N'  WHERE ROL.DEPARTMAN=(SELECT ROL.DEPARTMAN FROM REHBER R INNER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
                        + N'  WHERE R.ID=' + CAST(@Kullanan AS NVARCHAR(20)) + N'))) ';
    ELSE IF @cbListe = 8
        SET @SQL = @SQL + N' AND S.SUBEID=' + CAST(@SubeID AS NVARCHAR(20)) + N' ';

    IF @DurumVar = 1
        SET @SQL = @SQL + N' AND S.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' ';

    IF @DurumVar = 1 AND @SorumluTag > 0
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N' AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 0 AND @SorumluTag > 0
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.PERSONEL=' + CAST(@SorumluTag AS NVARCHAR(20)) + N') ';
    ELSE IF @DurumVar = 1 AND @SorumluTag = 0
        SET @SQL = @SQL + N' AND EXISTS (SELECT 1 FROM vServisHareket SH WHERE SH.SERVISID=S.ID AND SH.DURUM=' + CAST(@Durum AS NVARCHAR(20)) + N') ';

    IF (@ServisNo IS NULL OR @ServisNo = N'') AND (@SeriNo IS NULL OR @SeriNo = N'')
    BEGIN
        IF @Kapali = 1
        BEGIN
            IF @Tamamlanan = 1
                SET @SQL = @SQL + N' AND ((ISNULL(S.ACKAPA,0)=0) OR (ROUND(CAST(BASLAMATARIHI AS FLOAT),0,1)=ROUND(CAST(GETDATE() AS FLOAT),0,1))) ';
            ELSE IF @Tamamlanan = 19000
                SET @SQL = @SQL + N' AND ((ISNULL(S.ACKAPA,0)=0) OR (BASLAMATARIHI BETWEEN @pTarihBas AND @pTarihBit)) ';
            ELSE
                SET @SQL = @SQL + N' AND ((ISNULL(S.ACKAPA,0)=0) OR (BASLAMATARIHI >= @pKapaliTarih)) ';
        END
        ELSE
            SET @SQL = @SQL + N' AND S.ACKAPA = 0 ';
    END;

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
GO

IF OBJECT_ID(N'dbo.sp_Prog_Servis_Liste', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_Prog_Servis_Liste;
GO



