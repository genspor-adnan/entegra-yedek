-- ============================================================
-- GenDepoUpdate49 (musteri uygulama)
--   Belge Donusum KAYNAK listesi standart-sistem SP'si (ListeSPJson @Baslik+@Kosullar):
--     sp_Prog_BelgeDonusum_Kaynak_Json2
--   UBelgeDonusum'daki 3 inline dalin (TEKLIF / SIPARIS / FATBASLIK kaynak) karsiligi;
--   @Kaynak (1/2/3) ile dallanir. Tum MSSQL dialect (top1/isnull/CONVERT yok, tarih param)
--   SP govdesinde izole -> app engine-agnostic; PG icin ayri fonksiyon (frame vmPG'de Exit).
--   Uygulama build'i de gerekir (UBelgeDonusum.Listele -> ListeSPJson).
--
--   @Kosullar alanlari:
--     Kaynak       : 1=TEKLIF  2=SIPARIS  3=FATBASLIK (cbTur'den turetilir)
--     CbTur        : belge turu (S.TUR/FB.TUR filtresi + izleme BELGETUR)
--     DonusumTuru  : YERI kodu (DONUSEN/KALAN alt-sorgulari)
--     HedefBaslikTur: hedef baslik turu (GIZLE + Kalmayan alt-durumu 66=UretimEmri)
--     HedefUretim  : bit; SIPARIS dalinda hedef tablo URETIMEMRIDETAY(1) mi FATURA(0) mi
--     TarihBas/Bit : tarih araligi
--     RehID        : cari (0=yok); TEKLIF'te HedefBaslikTur<>9, SIPARIS'te CbTur<>101 iken
--     BelgeNo/StokKod/UrunNo/StokAd/Barkod : like filtreleri (Barkod app'te BarkodOku'lanmis)
--     KalmayanGoster/GizlenenGoster : bit
--     IzlemeTur    : 0=yok 1=serino 2=skt 3=karekod 4=boyut (SIPARIS/FATBASLIK)
--     Serino/SktTarih/Aciklama/Karekod/BoyutPattern : izleme alt-filtreleri
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
    DECLARE @Aciklama     NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.Aciklama'), N'');
    DECLARE @Karekod      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Karekod'), N'');
    DECLARE @BoyutPattern NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.BoyutPattern'), N'');

    -- =====================================================================
    -- KAYNAK 1: TEKLIF  (cbTur=99)  -- izleme filtresi orijinalde YOK (yorumlu)
    -- =====================================================================
    IF @Kaynak = 1
    BEGIN
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
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID) THEN 1 ELSE 0 END
        FROM TEKLIF S
            INNER JOIN TEKLIFDETAY SD ON S.ID=SD.TEKLIFID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.TARIH >= @TarihBas AND S.TARIH <= @TarihBit
          AND (@RehID = 0 OR @HedefBaslikTur = 9 OR R.ID=@RehID)
          AND (@BelgeNo IS NULL OR S.TEKLIFNO LIKE N'%'+@BelgeNo+N'%')
          AND (@StokKod IS NULL OR ST.KOD LIKE N'%'+@StokKod+N'%')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N'%'+@UrunNo+N'%')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N'%'+@StokAd+N'%')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N'%'+@Barkod+N'%'))
          AND (@KalmayanGoster=1 OR SD.ADET > ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID));
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 2: SIPARIS  (cbTur in 9,19,101,105)
    -- =====================================================================
    IF @Kaynak = 2
    BEGIN
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
            BASLIK_OZELKOD=S.OZELKOD, BASLIK_OZELKOD2=S.OZELKOD2
        FROM SIPARIS S
            INNER JOIN SIPARISDETAY SD ON S.ID=SD.SIPARISID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.SIPARISTARIH >= @TarihBas AND S.SIPARISTARIH <= @TarihBit
          AND (@RehID = 0 OR @CbTur = 101 OR R.ID=@RehID)
          AND S.TUR=@CbTur
          AND (@BelgeNo IS NULL OR S.SIPARISNO LIKE N'%'+@BelgeNo+N'%')
          AND (@StokKod IS NULL OR ST.KOD LIKE N'%'+@StokKod+N'%')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N'%'+@UrunNo+N'%')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N'%'+@StokAd+N'%')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N'%'+@Barkod+N'%'))
          AND (@KalmayanGoster=1
               OR SD.ADET > ABS(ISNULL((SELECT SUM(S1.ADET) FROM SIPARISDETAY S1 WHERE S1.YERI=@DonusumTuru AND S1.YERID=SD.ID),0.0))
                          + ABS(CASE WHEN @HedefBaslikTur=66
                                 THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                                 ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=S.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID))
          -- izleme tipi filtresi (STOKLAR.IZLEME). NOT: seri/SKT/aciklama alt-aramasi bu
          --   surumde YOK -> STOKIZLEME semasi degisti (IZLEM/SKT/ACIKLAMA kolonlari yok,
          --   SERILOTID'e tasindi); orijinal inline de bu sema'da kirikti. Gerekirse SERILOT
          --   join ile ayrica eklenir.
          AND (@IzlemeTur=0 OR ST.IZLEME=@IzlemeTur);
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 3: FATBASLIK  (cbTur in 6,10,14,109,110,119)
    --   DonusumStr: DonusumTuru=411 -> YERI in(411,424); degilse YERI=@DonusumTuru
    -- =====================================================================
    IF @Kaynak = 3
    BEGIN
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
            BASLIK_OZELKOD=FB.OZELKOD, BASLIK_OZELKOD2=FB.OZELKOD2
        FROM FATBASLIK FB
            INNER JOIN FATURA F ON FB.ID=F.FATBASID
            INNER JOIN STOKLAR ST ON F.TUR=1 AND F.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=FB.REHBERID
        WHERE FB.FATURATARIH >= @TarihBas AND FB.FATURATARIH <= @TarihBit
          AND (@RehID = 0 OR R.ID=@RehID)
          AND FB.TUR=@CbTur
          AND (@BelgeNo IS NULL OR FB.FATURANO LIKE N'%'+@BelgeNo+N'%')
          AND (@StokKod IS NULL OR ST.KOD LIKE N'%'+@StokKod+N'%')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N'%'+@UrunNo+N'%')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N'%'+@StokAd+N'%')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N'%'+@Barkod+N'%'))
          AND (@KalmayanGoster=1 OR F.ADET > ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=FB.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=F.ID))
          -- izleme tipi filtresi (STOKLAR.IZLEME); seri/SKT/aciklama alt-aramasi YOK (bkz KAYNAK 2 notu).
          AND (@IzlemeTur=0 OR ST.IZLEME=@IzlemeTur);
        RETURN;
    END
END
