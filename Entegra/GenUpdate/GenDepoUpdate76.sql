-- ============================================================
-- GenDepoUpdate76.sql
-- API E grubu (okuma):
--   dbo.sp_Api_Belge_Getir_Json  : tek belge - 2 sonuc kumesi (baslik + satirlar)
--   dbo.sp_Api_Belge_Liste_Json  : belge listesi - sayfali
--
-- YERINE GECER
--   Getir : TM_FATBASLIK (@ID ile tek belge) + TM_FaturaDetay ikilisi.
--           Mobil bugun IKI cagri yapiyor; artik tek cagri, iki sonuc kumesi.
--   Liste : TM_FATBASLIK + TM_SiparisAlinan (%88 ayni kod).
--
-- DUZELTILEN KUSURLAR
--   1) SELECT * yok. TM_FaturaDetay "F.*" ile FATURA'nin tum kolonlarini
--      donduruyordu; tabloya kolon eklenince istemcide kolon sirasi kayiyordu.
--      Burada kolon listesi ACIK ve bu belgede sabit.
--   2) Sayfalama var (Sayfa/SayfaBoyu; 0 = sinirsiz). TM'de yoktu - liste tum
--      tabloyu donduruyordu (musteriler SQL Express).
--   3) Tarih parametreleri gercek DATE (TM'de VARCHAR(10) idi; istemcinin
--      kultur ayarina gore yorumlaniyordu).
--   4) ORDER BY konumsal degil, kolon adiyla (TM: "order by 2").
--
-- KOLON SOZLESMESI: her iki sonuc kumesinde de Fields[0] = ID.
--   Yeni kolonlar daima SELECT'in SONUNA eklenir (Delphi konumsal erisim).
--
-- GIRDI (Getir): {"BelgeId":5567}
-- GIRDI (Liste): {"Tur":14,"Turler":[14,15],"BasTarih":"2026-01-01",
--                 "BitTarih":"2026-12-31","RehberId":0,"SubeId":-1,"Durum":null,
--                 "BelgeNo":"","Aciklama":"","Sayfa":1,"SayfaBoyu":100,
--                 "Sirala":"TARIH_DESC"}
--   Turler verilirse Tur yok sayilir. Sirala: TARIH_DESC (varsayilan) |
--   TARIH_ASC | NO_DESC | NO_ASC | TUTAR_DESC  (beyaz liste; ham SQL DEGIL)
-- HATA: 51001 girdi, 51002 belge bulunamadi
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Getir_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    IF @BelgeId IS NULL OR @BelgeId <= 0 THROW 51001, N'BelgeId zorunlu.', 1;
    IF NOT EXISTS (SELECT 1 FROM FATBASLIK WHERE ID = @BelgeId)
        THROW 51002, N'Belge bulunamadi.', 1;

    -- ---- 1. sonuc kumesi: BASLIK ----
    SELECT F.ID,
           F.TUR, F.TIPI, F.DURUM,
           DURUMAD = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2403 AND DEGER = F.DURUM),
           F.TARIH, F.FATURATARIH, F.FATURANO, F.FATURASERI, F.KOCANNO,
           F.REHBERID, CARIKOD = R.KOD, CARIAD = R.FIRMA,
           F.BASLIK, F.ADRES, F.ILCE, F.IL, F.VD, F.VNO,
           F.KDVDURUM, F.KUR, F.DOVIZ_CINSI, F.DOVIZKUR, F.RAPORDOVIZ, F.FATURADOVIZI,
           F.FATURA_MATRAHI, F.KDV_TUTARI, F.EKVERGI, F.FATURA_TUTARI, F.DOVIZ_TUTARI,
           F.FATURA_MALIYETI_ORT,
           F.GIRISDEPO, GIRISDEPOAD = (SELECT TOP 1 D.DEPOADI FROM DEPOLAR D WHERE D.ID = F.GIRISDEPO),
           F.CIKISDEPO, CIKISDEPOAD = (SELECT TOP 1 D.DEPOADI FROM DEPOLAR D WHERE D.ID = F.CIKISDEPO),
           F.PROJEID, PROJEKODU = (SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID = F.PROJEID),
           F.SATICIKODU, SATICIAD = (SELECT TOP 1 R2.FIRMA FROM REHBER R2 WHERE R2.ID = F.SATICIKODU),
           F.SUBEID, F.SERVISID, F.VADE, F.ACIKLAMA, F.OZELKOD, F.OZELKOD2,
           F.EFATURADURUM, F.FIYAT_LISTESI,
           F.EKLEYEN, F.EKLEMETARIHI, F.DEGISTIREN, F.DEGISTIRMETARIHI,
           SATIRSAY = (SELECT COUNT(*) FROM FATURA D WHERE D.FATBASID = F.ID)
    FROM FATBASLIK F
        LEFT OUTER JOIN REHBER R ON R.ID = F.REHBERID
    WHERE F.ID = @BelgeId;

    -- ---- 2. sonuc kumesi: SATIRLAR ----
    SELECT F.ID,
           F.FATBASID, F.SIRA, F.TUR, F.URUNID, F.STOKID,
           KOD = CASE WHEN F.TUR = 0 THEN MG.KOD ELSE ST.KOD END,
           AD  = CASE WHEN F.TUR = 0 THEN MG.AD  ELSE ST.STOKADI END,
           URUNNO = CASE WHEN F.TUR = 0 THEN N'' ELSE ST.URUNNO END,
           F.ACIKLAMA,
           F.ADET, F.MIKTAR, F.BIRIM,
           BIRIMAD = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2702 AND DIL = -1 AND DEGER = F.BIRIM),
           BIRIM2MIKTAR = CASE WHEN F.TUR = 0 THEN F.MIKTAR
                               ELSE F.MIKTAR / NULLIF(ST.BIRIM2MIKTAR, 0) END,
           BIRIM2AD = (SELECT TOP 1 ANAHTAR FROM GENINI
                        WHERE BOLUM = -2702 AND DIL = -1
                          AND DEGER = CASE WHEN F.TUR = 0 THEN F.BIRIM ELSE ST.BIRIM2 END),
           F.BIRIMFIYAT, F.ISKONTO, F.ISKONTO2, F.TUTAR, F.KDV,
           KDVTUTAR = F.KDVDAHILFIYAT - F.TUTAR,
           F.KDVDAHILFIYAT, F.KDVMUHAFIYETI,
           F.KUR, F.DOVIZ_KURU, F.DOVIZ_BIRIMFIYAT, F.DOVIZKURDEGERI, F.DOVIZ_TUTARI,
           F.OTVYUZDE, F.OTVMIKTAR,
           F.MASRAFID, F.PROJEID,
           PROJEKODU = (SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID = F.PROJEID),
           F.SATICIKODU,
           SATICIAD = (SELECT TOP 1 R.FIRMA FROM REHBER R WHERE R.ID = F.SATICIKODU),
           F.IZLEME, F.GIRDEPO, F.CIKDEPO, F.OZELKOD, F.OZELKOD2, F.POZNO,
           F.YERI, F.YERID, F.IADEFATURAID, F.IADEADET,
           F.EKIPMANID,
           EKIPMANAD = (SELECT TOP 1 E.AD FROM EKIPMANLAR E
                          INNER JOIN EKIPMANREHBER ER ON E.ID = ER.EKIPMANID
                         WHERE ER.ID = F.EKIPMANID),
           EKIPMANSERINO = (SELECT TOP 1 ER.SERINO FROM EKIPMANREHBER ER WHERE ER.ID = F.EKIPMANID),
           F.URETIMPLANDETAYID,
           RESIM   = CASE WHEN ST.RESIM IS NULL THEN 0 ELSE 1 END,
           IZLEMSAY = (SELECT COUNT(*) FROM STOKIZLEME SI
                        WHERE SI.BASLIKID = F.FATBASID AND SI.SATIRID = F.ID),
           F.SUBEID, F.EKLEYEN, F.EKLEMETARIHI
    FROM FATURA F
        LEFT OUTER JOIN STOKLAR ST     ON ST.ID = F.URUNID AND F.TUR <> 0
        LEFT OUTER JOIN MASRAFGELIR MG ON MG.ID = F.URUNID AND F.TUR = 0
    WHERE F.FATBASID = @BelgeId
    ORDER BY F.SIRA, F.ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Liste_Json
    @Kosullar NVARCHAR(MAX),
    @Baslik   NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tur       INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tur') AS INT);
    DECLARE @BasTarih  DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BasTarih') AS DATE);
    DECLARE @BitTarih  DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BitTarih') AS DATE);
    DECLARE @RehberId  INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT), 0);
    DECLARE @SubeId    INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.SubeId') AS INT);
    DECLARE @Durum     INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.Durum') AS INT);
    DECLARE @BelgeNo   NVARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar, '$.BelgeNo'),  N'');
    DECLARE @Aciklama  NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar, '$.Aciklama'), N'');
    DECLARE @Sayfa     INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Sayfa') AS INT), 1);
    DECLARE @SayfaBoyu INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.SayfaBoyu') AS INT), 0);
    DECLARE @Sirala    NVARCHAR(20) = UPPER(ISNULL(JSON_VALUE(@Kosullar, '$.Sirala'), N'TARIH_DESC'));

    IF @Sayfa < 1 SET @Sayfa = 1;
    -- Siralama BEYAZ LISTE (ham SQL kabul edilmez)
    IF @Sirala NOT IN (N'TARIH_DESC', N'TARIH_ASC', N'NO_DESC', N'NO_ASC', N'TUTAR_DESC')
        SET @Sirala = N'TARIH_DESC';

    DECLARE @T TABLE (Tur INT PRIMARY KEY);
    INSERT @T (Tur) SELECT DISTINCT CAST(value AS INT)
      FROM OPENJSON(@Kosullar, '$.Turler') WHERE ISNUMERIC(value) = 1;
    IF NOT EXISTS (SELECT 1 FROM @T) AND @Tur IS NOT NULL INSERT @T (Tur) VALUES (@Tur);

    DECLARE @Atla INT = (@Sayfa - 1) * CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 0 END;

    SELECT F.ID,
           F.TUR, F.TIPI, F.DURUM,
           DURUMAD = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2403 AND DEGER = F.DURUM),
           F.FATURATARIH, F.FATURANO, F.FATURASERI,
           F.REHBERID, CARIKOD = R.KOD, CARIAD = R.FIRMA,
           F.FATURA_MATRAHI, F.KDV_TUTARI, F.EKVERGI, F.FATURA_TUTARI, F.DOVIZ_TUTARI,
           F.KUR, F.DOVIZ_CINSI, F.DOVIZKUR,
           F.SUBEID, F.ACIKLAMA, F.OZELKOD, F.OZELKOD2, F.EFATURADURUM,
           SATIRSAY = (SELECT COUNT(*) FROM FATURA D WHERE D.FATBASID = F.ID),
           F.EKLEYEN, F.EKLEMETARIHI, F.DEGISTIREN, F.DEGISTIRMETARIHI
    FROM FATBASLIK F
        LEFT OUTER JOIN REHBER R ON R.ID = F.REHBERID
    WHERE (NOT EXISTS (SELECT 1 FROM @T) OR F.TUR IN (SELECT Tur FROM @T))
      AND (@BasTarih IS NULL OR CAST(F.FATURATARIH AS date) >= @BasTarih)
      AND (@BitTarih IS NULL OR CAST(F.FATURATARIH AS date) <= @BitTarih)
      AND (@RehberId = 0    OR F.REHBERID = @RehberId)
      AND (@SubeId   IS NULL OR F.SUBEID  = @SubeId)
      AND (@Durum    IS NULL OR F.DURUM   = @Durum)
      AND (@BelgeNo  IS NULL OR F.FATURANO LIKE N'%' + @BelgeNo + N'%')
      AND (@Aciklama IS NULL OR F.ACIKLAMA LIKE N'%' + @Aciklama + N'%')
    ORDER BY
        CASE WHEN @Sirala = N'TARIH_DESC' THEN F.FATURATARIH END DESC,
        CASE WHEN @Sirala = N'TARIH_ASC'  THEN F.FATURATARIH END ASC,
        CASE WHEN @Sirala = N'NO_DESC'    THEN F.FATURANO END DESC,
        CASE WHEN @Sirala = N'NO_ASC'     THEN F.FATURANO END ASC,
        CASE WHEN @Sirala = N'TUTAR_DESC' THEN F.FATURA_TUTARI END DESC,
        F.ID DESC
    OFFSET @Atla ROWS
    FETCH NEXT CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 2147483647 END ROWS ONLY;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_Getir_Json TO gentegre_api;
GRANT EXECUTE ON dbo.sp_Api_Belge_Liste_Json TO gentegre_api;
GO
