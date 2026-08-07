-- ============================================================
-- GenDepoUpdate75.sql
-- API: sp_Api_Donusum_Rapor_Json -- donusturulebilir KAYNAK SATIRLARI listesi
--
-- YERINE GECER: TM_DonusumListeleri + TM_DonusumListeleriAlis +
--   TM_DonusumListeleriSatis (167 + 403 + 336 = 906 satir). Uc SP'de toplam
--   11 sabit "ekran" dali (Alis1-6, Satis1-5) vardi; her dal ayni kolon
--   kumesini uretiyor, yalnizca KAYNAK TABLO ve HEDEF YERI kodlari degisiyordu.
--   Ayrica her dal DONUSEN/KALAN formulunu KENDI icinde tekrarliyordu.
--   Burada tek govde: kaynak 3 dal (teklif/siparis/belge), kalan hesabi
--   fn_Api_Donusum_Kalan'dan (D grubunun ortak TVF'i).
--
-- ESKI EKRAN -> YENI PARAMETRE ESLEMESI
--   Alis1  : Kaynak=1 DonusumTuru=428  GizleKaynakTur=99 GizleHedefTur=9
--   Alis2  : Kaynak=2 DonusumTuru=428                    GizleHedefTur=9
--   Alis3  : Kaynak=3 DonusumTuru=469                    GizleHedefTur=10
--   Alis4  : Kaynak=2 DonusumTuru=406                    GizleHedefTur=10
--   Alis5  : Kaynak=3 DonusumTuru=408                    GizleHedefTur=11
--   Alis6  : Kaynak=2 DonusumTuru=407                    GizleHedefTur=11
--   Satis1 : Kaynak=1 DonusumTuru=413  GizleKaynakTur=99 GizleHedefTur=19
--   Satis2 : Kaynak=2 DonusumTuru=429                    GizleHedefTur=119
--   Satis3 : Kaynak=2 DonusumTuru=409                    GizleHedefTur=14
--   Satis4 : Kaynak=3 DonusumTuru=411                    GizleHedefTur=15
--   Satis5 : Kaynak=2 DonusumTuru=410                    GizleHedefTur=15
--   (416 = iade; kalan hesabinda TVF icinde zaten dusuluyor.)
--
-- GIRDI:
--   {"Kaynak":2,"DonusumTuru":409,"HedefUretim":false,
--    "BasTarih":"2026-01-01","BitTarih":"2026-12-31",
--    "GizleKaynakTur":0,"GizleHedefTur":14,
--    "KalmayanGoster":false,"GizlenenGoster":false,
--    "RehberId":0,"BelgeNo":"","StokKod":"","StokAd":"",
--    "Sayfa":1,"SayfaBoyu":200}
--   SayfaBoyu = 0 -> sinirsiz (TopN=0 kurali).
-- CIKTI: sonuc kumesi - Fields[0] = SATIRID (kaynak satir; donusumun anahtari)
--   SATIRID, BASLIKID, STOKID, REHBERID, FIRMA, TARIH, BELGENO, KOD, STOKADI,
--   URUNNO, ACIKLAMA, IZLEME, ANABIRIM, BIRIM, KDV, KUR, DOVIZ_KURU,
--   ADET, MIKTAR, BIRIMFIYAT, ISKONTO, ISKONTO2, TUTAR, DOVIZ_BIRIMFIYAT,
--   DOVIZKURDEGERI, DOVIZ_TUTARI, MASRAFID, PROJEID, PROJEKODU, POZNO,
--   OZELKOD, OZELKOD2, MUHKODU, TESLIMTARIHI, DONUSEN, KALAN, GIZLE
-- HATA: 51001 girdi
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_Rapor_Json
    @Kosullar NVARCHAR(MAX),
    @Baslik   NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kaynak')      AS INT);
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru') AS INT);
    DECLARE @HedefUretim BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefUretim') AS BIT), 0);
    DECLARE @BasTarih    DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BasTarih') AS DATE);
    DECLARE @BitTarih    DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BitTarih') AS DATE);
    DECLARE @GizKaynak   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GizleKaynakTur') AS INT), 0);
    DECLARE @GizHedef    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GizleHedefTur')  AS INT), 0);
    DECLARE @Kalmayan    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KalmayanGoster') AS BIT), 0);
    DECLARE @Gizlenen    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GizlenenGoster') AS BIT), 0);
    DECLARE @RehberId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT), 0);
    DECLARE @BelgeNo     NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.BelgeNo'), N'');
    DECLARE @StokKod     NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.StokKod'), N'');
    DECLARE @StokAd      NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar, '$.StokAd'),  N'');
    DECLARE @Sayfa       INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Sayfa')     AS INT), 1);
    DECLARE @SayfaBoyu   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.SayfaBoyu') AS INT), 0);

    IF @Kaynak IS NULL OR @Kaynak NOT IN (1,2,3) THROW 51001, N'Kaynak 1 (teklif), 2 (siparis) ya da 3 (belge) olmali.', 1;
    IF @DonusumTuru IS NULL                      THROW 51001, N'DonusumTuru zorunlu.', 1;
    IF @Sayfa < 1 SET @Sayfa = 1;

    DECLARE @Atla INT = (@Sayfa - 1) * CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 0 END;

    ;WITH Kay AS
    (
        -- 1) TEKLIF
        SELECT SATIRID = SD.ID, BASLIKID = S.ID, STOKID = ST.ID, REHBERID = R.ID,
               FIRMA = R.FIRMA, TARIH = CAST(S.TARIH AS datetime), BELGENO = CAST(S.TEKLIFNO AS nvarchar(50)),
               KOD = ST.KOD, STOKADI = ST.STOKADI, URUNNO = ST.URUNNO,
               ACIKLAMA = SD.ACIKLAMA, IZLEME = ST.IZLEME, ANABIRIM = ST.ANABIRIM,
               SD.BIRIM, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
               SD.ADET, SD.MIKTAR, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
               SD.DOVIZ_BIRIMFIYAT, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI,
               SD.MASRAFID, SD.PROJEID, SD.POZNO,
               OZELKOD = ST.OZELKOD, OZELKOD2 = ST.OZELKOD2, MUHKODU = ST.MUHKODU,
               TESLIMTARIHI = CAST(NULL AS datetime)
        FROM TEKLIF S
            INNER JOIN TEKLIFDETAY SD ON S.ID = SD.TEKLIFID
            INNER JOIN STOKLAR ST ON SD.TUR = 1 AND SD.URUNID = ST.ID
            INNER JOIN REHBER R ON R.ID = S.REHBERID
        WHERE @Kaynak = 1
          AND (@BasTarih IS NULL OR CAST(S.TARIH AS date) >= @BasTarih)
          AND (@BitTarih IS NULL OR CAST(S.TARIH AS date) <= @BitTarih)
          AND (@RehberId = 0 OR R.ID = @RehberId)
          AND (@BelgeNo IS NULL OR S.TEKLIFNO LIKE N'%' + @BelgeNo + N'%')

        UNION ALL

        -- 2) SIPARIS
        SELECT SD.ID, S.ID, ST.ID, R.ID,
               R.FIRMA, CAST(S.SIPARISTARIH AS datetime), CAST(S.SIPARISNO AS nvarchar(50)),
               ST.KOD, ST.STOKADI, ST.URUNNO,
               SD.ACIKLAMA, ST.IZLEME, ST.ANABIRIM,
               SD.BIRIM, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
               SD.ADET, SD.MIKTAR, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
               SD.DOVIZ_BIRIMFIYAT, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI,
               SD.MASRAFID, SD.PROJEID, SD.POZNO,
               ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU,
               CAST(SD.TESLIMTARIHI AS datetime)
        FROM SIPARIS S
            INNER JOIN SIPARISDETAY SD ON S.ID = SD.SIPARISID
            INNER JOIN STOKLAR ST ON SD.TUR = 1 AND SD.URUNID = ST.ID
            INNER JOIN REHBER R ON R.ID = S.REHBERID
        WHERE @Kaynak = 2
          AND (@BasTarih IS NULL OR CAST(S.SIPARISTARIH AS date) >= @BasTarih)
          AND (@BitTarih IS NULL OR CAST(S.SIPARISTARIH AS date) <= @BitTarih)
          AND (@RehberId = 0 OR R.ID = @RehberId)
          AND (@BelgeNo IS NULL OR S.SIPARISNO LIKE N'%' + @BelgeNo + N'%')

        UNION ALL

        -- 3) FATBASLIK
        SELECT F.ID, S.ID, ST.ID, R.ID,
               R.FIRMA, CAST(S.FATURATARIH AS datetime), CAST(S.FATURANO AS nvarchar(50)),
               ST.KOD, ST.STOKADI, ST.URUNNO,
               F.ACIKLAMA, ST.IZLEME, ST.ANABIRIM,
               F.BIRIM, F.KDV, F.KUR, F.DOVIZ_KURU,
               F.ADET, F.MIKTAR, F.BIRIMFIYAT, F.ISKONTO, F.ISKONTO2, F.TUTAR,
               F.DOVIZ_BIRIMFIYAT, F.DOVIZKURDEGERI, F.DOVIZ_TUTARI,
               F.MASRAFID, F.PROJEID, F.POZNO,
               ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU,
               CAST(NULL AS datetime)
        FROM FATBASLIK S
            INNER JOIN FATURA F ON S.ID = F.FATBASID
            INNER JOIN STOKLAR ST ON F.TUR = 1 AND F.URUNID = ST.ID
            INNER JOIN REHBER R ON R.ID = S.REHBERID
        WHERE @Kaynak = 3
          AND (@BasTarih IS NULL OR CAST(S.FATURATARIH AS date) >= @BasTarih)
          AND (@BitTarih IS NULL OR CAST(S.FATURATARIH AS date) <= @BitTarih)
          AND (@RehberId = 0 OR R.ID = @RehberId)
          AND (@BelgeNo IS NULL OR S.FATURANO LIKE N'%' + @BelgeNo + N'%')
    )
    SELECT K.SATIRID, K.BASLIKID, K.STOKID, K.REHBERID, K.FIRMA, K.TARIH, K.BELGENO,
           K.KOD, K.STOKADI, K.URUNNO, K.ACIKLAMA, K.IZLEME, K.ANABIRIM,
           BIRIM = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2702 AND DIL = -1 AND DEGER = K.BIRIM),
           K.KDV, K.KUR, K.DOVIZ_KURU,
           K.ADET, K.MIKTAR, K.BIRIMFIYAT, K.ISKONTO, K.ISKONTO2, K.TUTAR,
           K.DOVIZ_BIRIMFIYAT, K.DOVIZKURDEGERI, K.DOVIZ_TUTARI,
           K.MASRAFID, K.PROJEID,
           PROJEKODU = (SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID = K.PROJEID),
           K.POZNO, K.OZELKOD, K.OZELKOD2, K.MUHKODU, K.TESLIMTARIHI,
           DONUSEN = ISNULL(D.Donusen, 0),
           KALAN   = ISNULL(D.Kalan, 0),
           GIZLE   = CASE WHEN G.KAYNAKID IS NOT NULL THEN 1 ELSE 0 END
    FROM Kay K
        CROSS APPLY dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, K.SATIRID, @HedefUretim) D
        LEFT OUTER JOIN DONUSUMBILGISIGIZLE G
               ON G.KAYNAKID = K.SATIRID
              AND (@GizKaynak = 0 OR G.KAYNAKTUR = @GizKaynak)
              AND (@GizHedef  = 0 OR G.HEDEFTUR  = @GizHedef)
    WHERE (@Kalmayan = 1 OR ISNULL(D.Kalan, 0) > 0.0001)
      AND (@Gizlenen = 1 OR G.KAYNAKID IS NULL)
      AND (@StokKod IS NULL OR K.KOD     LIKE N'%' + @StokKod + N'%')
      AND (@StokAd  IS NULL OR K.STOKADI LIKE N'%' + @StokAd  + N'%')
    ORDER BY K.TARIH DESC, K.SATIRID
    OFFSET @Atla ROWS
    FETCH NEXT CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 2147483647 END ROWS ONLY;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Donusum_Rapor_Json TO gentegre_api;
GO
