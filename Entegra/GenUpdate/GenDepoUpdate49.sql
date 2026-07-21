-- ============================================================
-- GenDepoUpdate49 (musteri uygulama)
--   Belge Donusum KAYNAK listesi standart-sistem SP'si (ListeSPJson @Baslik+@Kosullar):
--     sp_Prog_BelgeDonusum_Kaynak_Json2
--   UBelgeDonusum'daki 3 inline dalin (TEKLIF / SIPARIS / FATBASLIK) karsiligi; @Kaynak (1/2/3).
--   DINAMIK SQL (sp_executesql, parametreli): EN/BOY/YUZEY/SAYI kolonlari OPSIYONEL
--   (EnBoyHesaplamaAktif) -> her musteride YOK; @EnBoy=1 iken kolon-listesine eklenir
--   (deferred parse -> feature-off DB'de hata vermez). Izleme detay aramasi STOKSERILOT
--   join ile (STOKIZLEME.IZLEM/SKT ESKI sema; artik SERILOTID -> STOKSERILOT.SERINO/SKT).
--   Tum dialect SP govdesinde; PG icin ayri fonksiyon (frame vmPG'de Exit).
--
--   @Kosullar: Kaynak, CbTur, DonusumTuru, HedefBaslikTur, HedefUretim(bit),
--     EnBoy(bit = EnBoyHesaplamaAktif AND DonusumTuru<>StokTalepTransfer),
--     TarihBas/Bit, RehID, BelgeNo/StokKod/UrunNo/StokAd/Barkod,
--     KalmayanGoster/GizlenenGoster(bit), IzlemeTur(0-4),
--     Serino/SktTarih/Karekod/BoyutPattern (izleme alt-aramasi; STOKSERILOT.SERINO/SKT).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Kaynak_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak       INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kaynak') AS INT), 0);
    DECLARE @CbTur        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CbTur') AS INT), 0);
    DECLARE @DonusumTuru  INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.DonusumTuru') AS INT), 0);
    DECLARE @HedefBaslikTur INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.HedefBaslikTur') AS INT), 0);
    DECLARE @HedefUretim  BIT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.HedefUretim') AS BIT), 0);
    DECLARE @EnBoy        BIT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.EnBoy') AS BIT), 0);
    DECLARE @TarihBas     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    DECLARE @RehID        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.RehID') AS INT), 0);
    DECLARE @BelgeNo      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.BelgeNo'), N'');
    DECLARE @StokKod      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.StokKod'), N'');
    DECLARE @UrunNo       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.UrunNo'), N'');
    DECLARE @StokAd       NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.StokAd'), N'');
    DECLARE @Barkod       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Barkod'), N'');
    DECLARE @KalmayanGoster BIT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KalmayanGoster') AS BIT), 0);
    DECLARE @GizlenenGoster BIT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.GizlenenGoster') AS BIT), 0);
    DECLARE @IzlemeTur    INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IzlemeTur') AS INT), 0);
    DECLARE @Serino       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Serino'), N'');
    DECLARE @SktTarih     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.SktTarih') AS DATETIME);
    DECLARE @Karekod      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Karekod'), N'');
    DECLARE @BoyutPattern NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.BoyutPattern'), N'');

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @prm NVARCHAR(MAX) = N'@CbTur int,@DonusumTuru int,@HedefBaslikTur int,@HedefUretim bit,
        @TarihBas datetime,@TarihBit datetime,@RehID int,@BelgeNo nvarchar(100),@StokKod nvarchar(100),
        @UrunNo nvarchar(100),@StokAd nvarchar(200),@Barkod nvarchar(100),@KalmayanGoster bit,
        @GizlenenGoster bit,@IzlemeTur int,@Serino nvarchar(100),@SktTarih datetime,@Karekod nvarchar(100),
        @BoyutPattern nvarchar(200)';

    -- ortak izleme detay filtresi (STOKSERILOT); <D> = detay tablo aliasi (SD veya F)
    -- IZLEM(eski)->SSL.SERINO, SKT->SSL.SKT. serino/karekod/boyut=SERINO, skt=SKT.
    DECLARE @izl NVARCHAR(MAX) = N'
          AND (@IzlemeTur=0 OR ST.IZLEME=@IzlemeTur)
          AND (@Serino IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE N''%''+@Serino+N''%''))
          AND (@SktTarih IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SKT=@SktTarih))
          AND (@Karekod IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE N''%''+@Karekod+N''%''))
          AND (@BoyutPattern IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE @BoyutPattern))';

    -- =====================================================================
    -- KAYNAK 1: TEKLIF  (izleme orijinalde YOK)
    -- =====================================================================
    IF @Kaynak = 1
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=S.ID, SATIRID=SD.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA, S.TARIH,
            BELGENO=S.TEKLIFNO, ST.KOD, ST.STOKADI, ST.ANABIRIM, SD.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
            SD.ADET, SD.MIKTAR, SD.BIRIM, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
            SD.DOVIZ_BIRIMFIYAT, SD.DOVIZ_KURU, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI, SD.MASRAFID, SD.MERKEZID, SD.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=428 AND F1.YERID=SD.ID),0.0),
            IADE=0.0,
            KALAN=SD.ADET-ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                         -ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=416 AND F1.YERID=SD.ID),0.0),
            SD.TESLIMTARIHI,
            SATICI=S.HAZIRLAYAN,
            SD.PROJEID, SD.POZNO, ST.URUNNO,
            DETAY_OZELKOD=SD.OZELKOD, DETAY_OZELKOD2=SD.OZELKOD2,
            BASLIK_OZELKOD=S.OZELKOD, BASLIK_OZELKOD2=CAST(NULL AS NVARCHAR(50)),
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=SD.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID) THEN 1 ELSE 0 END'
          + CASE WHEN @EnBoy=1 THEN N', SD.EN, SD.BOY, SD.YUZEY, SD.SAYI' ELSE N'' END + N'
        FROM TEKLIF S
            INNER JOIN TEKLIFDETAY SD ON S.ID=SD.TEKLIFID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.TARIH >= @TarihBas AND S.TARIH <= @TarihBit
          AND (@RehID = 0 OR @HedefBaslikTur = 9 OR R.ID=@RehID)
          AND (@BelgeNo IS NULL OR S.TEKLIFNO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1 OR SD.ADET > ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID))';
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 2: SIPARIS
    -- =====================================================================
    IF @Kaynak = 2
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=S.ID, SATIRID=SD.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA,
            TARIH=S.SIPARISTARIH, BELGENO=S.SIPARISNO, ST.KOD, ST.STOKADI, ST.ANABIRIM, SD.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
            SD.ADET, SD.MIKTAR, SD.BIRIM, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
            SD.DOVIZ_BIRIMFIYAT, SD.DOVIZ_KURU, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI, SD.MASRAFID, SD.MERKEZID, SD.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                   + CASE WHEN @HedefUretim=1
                          THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                          ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END,
            IADE=0.0,
            KALAN=SD.ADET-(ABS(ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0))
                   + ABS(CASE WHEN @HedefUretim=1
                          THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                          ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END)),
            SD.TESLIMTARIHI, S.REHBERILETID, SEVK=(SELECT AD FROM REHBERILETISIM WHERE ID=S.REHBERILETID),
            SATICI=S.SATICIKODU, DEPOAD=(SELECT DEPOADI FROM DEPOLAR WHERE ID=CASE WHEN S.TUR=19 THEN S.CIKISDEPO ELSE S.GIRISDEPO END),
            SD.PROJEID, SD.POZNO, ST.URUNNO, S.DETAYBOLUMU,
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=SD.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=S.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID) THEN 1 ELSE 0 END,
            DETAY_OZELKOD=SD.OZELKOD, DETAY_OZELKOD2=SD.OZELKOD2,
            BASLIK_OZELKOD=S.OZELKOD, BASLIK_OZELKOD2=S.OZELKOD2'
          + CASE WHEN @EnBoy=1 THEN N', SD.EN, SD.BOY, SD.YUZEY, SD.SAYI' ELSE N'' END + N'
        FROM SIPARIS S
            INNER JOIN SIPARISDETAY SD ON S.ID=SD.SIPARISID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.SIPARISTARIH >= @TarihBas AND S.SIPARISTARIH <= @TarihBit
          AND (@RehID = 0 OR @CbTur = 101 OR R.ID=@RehID)
          AND S.TUR=@CbTur
          AND (@BelgeNo IS NULL OR S.SIPARISNO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1
               OR SD.ADET > ABS(ISNULL((SELECT SUM(S1.ADET) FROM SIPARISDETAY S1 WHERE S1.YERI=@DonusumTuru AND S1.YERID=SD.ID),0.0))
                          + ABS(CASE WHEN @HedefBaslikTur=66
                                 THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                                 ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=S.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID))'
          + REPLACE(@izl, N'<D>', N'SD');
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 3: FATBASLIK
    -- =====================================================================
    IF @Kaynak = 3
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=FB.ID, SATIRID=F.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA,
            TARIH=FB.FATURATARIH, BELGENO=FB.FATURANO, ST.KOD, ST.STOKADI, ST.ANABIRIM, F.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, F.KDV, F.KUR, F.DOVIZ_KURU,
            F.ADET, F.MIKTAR, F.BIRIM, F.BIRIMFIYAT, F.ISKONTO, F.ISKONTO2, F.TUTAR,
            F.DOVIZ_BIRIMFIYAT, F.DOVIZ_KURU, F.DOVIZKURDEGERI, F.DOVIZ_TUTARI, F.MASRAFID, F.MERKEZID, F.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0),
            IADE=ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=416 AND F1.YERID=F.ID),0.0),
            KALAN=F.ADET-ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0)
                        -ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=416 AND F1.YERID=F.ID),0.0),
            TESLIMTARIHI=FB.FATURATARIH,
            SATICI=FB.SATICIKODU, DEPOAD=(SELECT DEPOADI FROM DEPOLAR WHERE ID=CASE WHEN FB.TUR IN (10,11,12,119) THEN FB.GIRISDEPO ELSE FB.CIKISDEPO END),
            F.PROJEID, F.POZNO, ST.URUNNO, FB.DETAYBOLUMU,
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=F.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=FB.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=F.ID) THEN 1 ELSE 0 END,
            DETAY_OZELKOD=F.OZELKOD, DETAY_OZELKOD2=F.OZELKOD2,
            BASLIK_OZELKOD=FB.OZELKOD, BASLIK_OZELKOD2=FB.OZELKOD2'
          + CASE WHEN @EnBoy=1 THEN N', F.EN, F.BOY, F.YUZEY, F.SAYI' ELSE N'' END + N'
        FROM FATBASLIK FB
            INNER JOIN FATURA F ON FB.ID=F.FATBASID
            INNER JOIN STOKLAR ST ON F.TUR=1 AND F.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=FB.REHBERID
        WHERE FB.FATURATARIH >= @TarihBas AND FB.FATURATARIH <= @TarihBit
          AND (@RehID = 0 OR R.ID=@RehID)
          AND FB.TUR=@CbTur
          AND (@BelgeNo IS NULL OR FB.FATURANO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1 OR F.ADET > ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=FB.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=F.ID))'
          + REPLACE(@izl, N'<D>', N'F');
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END
END
