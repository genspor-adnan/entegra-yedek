CREATE OR ALTER PROCEDURE dbo.sp_Prog_EBelge_GidenFatura
    @ID int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.FATBASLIK
        WHERE ID = @ID
          AND TUR IN (14, 15)
    )
        THROW 50001, 'Giden e-Fatura/e-Irsaliye kaydi bulunamadi.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.FATBASLIK
        WHERE ID = @ID
          AND ISNULL(DURUM, 0) = 6
    )
        THROW 50002, 'Iptal edilmis belge gonderilemez.', 1;

    /*
      Birinci sonuc kumesi: FATBASLIK ve giden e-belge bilgileri.
      TUR=14: Giden e-Irsaliye
      TUR=15: Giden e-Fatura
    */
    SELECT
        FB.ID,
        FB.TUR,
        BELGETURU = FB.TUR,
        BELGETURADI = CASE FB.TUR
            WHEN 14 THEN N'E-İrsaliye'
            WHEN 15 THEN N'E-Fatura'
        END,
        FB.FATURATARIH,
        VNO = REPLACE(LTRIM(RTRIM(ISNULL(FB.VNO, N''))), N' ', N''),
        FB.VD,
        BASLIK = COALESCE(NULLIF(FB.BASLIK, N''), R.FIRMA),
        CARIKOD = R.KOD,
        CARIUNVAN = R.FIRMA,
        FB.FATURA_MATRAHI,
        FB.FATURA_TUTARI,
        FB.KDV_TUTARI,
        FB.EKVERGI,
        FB.FATURASERI,
        FB.FATURANO,
        FB.KDVDURUM,
        SENARYO = CASE
            WHEN FB.EFATURADURUM IN (51, 52) THEN 6
            WHEN FB.EFATURADURUM IN (11, 12, 31, 32) THEN 4
            ELSE ISNULL(FB.SENARYO, 1)
        END,
        FB.IL,
        FB.ILCE,
        FB.ADRES,
        FB.ACIKLAMA,
        ACIKLAMA2 = ISNULL(FB.ACIKLAMA2, N''),
        KUR = ISNULL(NULLIF(FB.KUR, N''), N'TL'),
        FB.TIPI,
        FB.REHBERID,
        FB.DOVIZ_TUTARI,
        FB.DOVIZ_CINSI,
        FB.DOVIZKUR,
        FATURADOVIZI = ISNULL(NULLIF(FB.FATURADOVIZI, N''), N'TL'),
        FB.SUBEID,
        FB.GIRISDEPO,
        FB.CIKISDEPO,
        FB.IRSALIYENO,
        FB.IRSALIYETARIH,
        FB.EFATURADURUM,
        FB.EFATURASONUC,
        FB.EKLEYEN,
        FB.EKLEMETARIHI,
        FB.DEGISTIREN,
        FB.DEGISTIRMETARIHI,

        EBELGEID = EB.ID,
        EBDURUM = ISNULL(EB.DURUM, 0),
        EBUUID = ISNULL(EB.UUID, ''),
        EBBELGENO = ISNULL(EB.BELGENO, N''),
        GONDERICIALIAS = ISNULL(EB.GONDERICIALIAS, N''),
        ALICIALIAS = COALESCE(NULLIF(EB.ALICIALIAS, N''), RA.ALIAS, N''),
        EBELGEOLUSTU = CONVERT(bit, CASE WHEN EB.ID IS NULL THEN 0 ELSE 1 END),
        SONISLEMTURU = EH.ISLEMTURU,
        SONHTTPKODU = EH.HTTPKODU,
        SONSERVISKODU = EH.SERVISKODU,
        SONHATAKODU = EH.HATAKODU,
        SONHATAMESAJI = EH.HATAMESAJI,

        -- Eski sorguyu kullanan kodlarla uyumluluk alanlari.
        EiInvoiceId = EB.ID,
        EiCustomerId = R.ID,
        EiCustomerName = R.FIRMA,
        EiStatus = ISNULL(EB.DURUM, 0),
        EiInvoiceNo = ISNULL(EB.BELGENO, N''),
        EiIsIncomingInvoice = CONVERT(bit, 0),
        EiProviderStatus = EH.SERVISKODU,
        EiUuId = EB.UUID,
        EiInvoiceCreated = CONVERT(bit, CASE WHEN EB.ID IS NULL THEN 0 ELSE 1 END),
        EiAutomationInvoiceCreated = CONVERT(bit, 1),
        EiAutomationId = CONVERT(int, NULL),
        EiSysInvoiceNo = CONVERT(varchar(15), FB.ID),
        EiSysCustomerName = R.FIRMA,
        EiProviderDescription = EH.HATAMESAJI,
        EiRejectionReason = CASE WHEN ISNULL(EB.DURUM, 0) = 4 THEN EH.HATAMESAJI ELSE NULL END,
        EiIsEArchive = CONVERT(bit, CASE WHEN FB.EFATURADURUM IN (11, 12, 31, 32) THEN 1 ELSE 0 END),
        EiInvoiceKind = CASE
            WHEN FB.TUR = 14 THEN 7
            WHEN FB.EFATURADURUM IN (11, 12) THEN 2
            WHEN FB.EFATURADURUM IN (21, 22) THEN 3
            WHEN FB.EFATURADURUM IN (31, 32) THEN 4
            ELSE 1
        END,
        EiIsEWayBill = CONVERT(bit, CASE WHEN FB.TUR = 14 THEN 1 ELSE 0 END),
        CarrierName = CONVERT(nvarchar(100), N''),
        CarrierSurname = CONVERT(nvarchar(100), N''),
        CarrierIdentification = CONVERT(nvarchar(50), N''),
        IRSALIYE_YAZI = CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM dbo.FATURA F
                WHERE F.FATBASID = FB.ID
                  AND F.YERI = 411
            )
            THEN N'İRSALİYE YERİNE GEÇER'
            ELSE N''
        END,
        KURUM = CONVERT(nvarchar(150), N''),
        KURUMADRES = CONVERT(nvarchar(150), N''),
        ISLEMNO = CONVERT(nvarchar(50), N''),
        FB.HASTA,
        OPERASYONTARIHI = CONVERT(varchar(10), '')
    FROM dbo.FATBASLIK FB
    INNER JOIN dbo.REHBER R ON R.ID = FB.REHBERID
    OUTER APPLY
    (
        -- EBELGE.BELGETURU RAlias kodu tutar (140/141/150/151), FB.TUR ise 14/15
        -- gibi belge turu kodlari -- iki alan ayni deger uzayinda olmadigi icin
        -- filtre konulmaz; YON=1 (giden) ve son kayit yeterli.
        SELECT TOP (1) E.*
        FROM dbo.EBELGE E
        WHERE E.FATBASLIKID = FB.ID
          AND E.YON = 1
        ORDER BY E.ID DESC
    ) EB
    OUTER APPLY
    (
        SELECT TOP (1)
            H.ISLEMTURU,
            H.HTTPKODU,
            H.SERVISKODU,
            H.HATAKODU,
            H.HATAMESAJI
        FROM dbo.EBELGEMESAJ H
        WHERE H.EBELGEID = EB.ID
        ORDER BY H.ID DESC
    ) EH
    OUTER APPLY
    (
        SELECT TOP (1) A.ALIAS
        FROM dbo.REHBERALIAS A
        WHERE A.REHBERID = FB.REHBERID
          AND A.BELGETURU = FB.TUR
          AND A.AKTIF = 1
        ORDER BY A.VARSAYILAN DESC, A.ID
    ) RA
    WHERE FB.ID = @ID;

    /*
      Ikinci sonuc kumesi: FATURA kalemleri.
      UBL-TR InvoiceLine / DespatchLine olustururken kullanilir.
    */
    SELECT
        F.ID,
        F.FATBASID,
        SATIRNO = ROW_NUMBER() OVER
        (
            ORDER BY CASE WHEN ISNULL(F.SIRA, 0) = 0 THEN 2147483647 ELSE F.SIRA END, F.ID
        ),
        F.SIRA,
        F.TUR,
        F.URUNID,
        KOD = CASE
            WHEN F.TUR IN (1, 11) THEN S.KOD
            ELSE MG.KOD
        END,
        URUNNO = CASE
            WHEN F.TUR IN (1, 11) THEN S.URUNNO
            ELSE N''
        END,
        AD = CASE
            WHEN F.TUR IN (1, 11) THEN S.STOKADI
            ELSE MG.AD
        END,
        F.ACIKLAMA,
        BARKOD = CASE
            WHEN F.TUR IN (1, 11) THEN SB.BARKOD
            ELSE N''
        END,
        F.ADET,
        F.MF,
        F.BIRIM,
        BIRIMAD = BR.ANAHTAR,
        F.MIKTAR,
        F.BIRIMFIYAT,
        BRUTTUTAR = ISNULL(F.ADET, 0) * ISNULL(F.BIRIMFIYAT, 0),
        F.ISKONTO,
        F.ISKONTO2,
        ISKONTOTUTARI =
            (ISNULL(F.ADET, 0) * ISNULL(F.BIRIMFIYAT, 0)) - ISNULL(F.TUTAR, 0),
        F.TUTAR,
        F.KDV,
        KDVMATRAHI = ISNULL(F.TUTAR, 0),
        KDVTUTARI = CASE
            WHEN UPPER(ISNULL(FB.KDVDURUM, N'')) = N'DAHİL'
                THEN ISNULL(F.TUTAR, 0) -
                     (ISNULL(F.TUTAR, 0) / NULLIF(1 + (ISNULL(F.KDV, 0) / 100.0), 0))
            WHEN UPPER(ISNULL(FB.KDVDURUM, N'')) = N'MUAF'
                THEN 0
            ELSE ISNULL(F.TUTAR, 0) * ISNULL(F.KDV, 0) / 100.0
        END,
        F.OTVYUZDE,
        F.OTVMIKTAR,
        F.KUR,
        F.DOVIZ_BIRIMFIYAT,
        F.DOVIZ_TUTARI,
        F.DOVIZKURDEGERI,
        F.KDVMUHAFIYETI,
        F.OZELKOD,
        F.OZELKOD2,
        GTIP = CASE WHEN F.TUR IN (1, 11) THEN S.GTIP ELSE N'' END,
        SUTKODU = CASE WHEN F.TUR IN (1, 11) THEN S.SUTKODU ELSE N'' END,
        GMDN = CASE WHEN F.TUR IN (1, 11) THEN S.GMDN ELSE N'' END,
        MENSEIULKE = CASE WHEN F.TUR IN (1, 11) THEN S.MENSEIULKE ELSE NULL END
    FROM dbo.FATURA F
    INNER JOIN dbo.FATBASLIK FB ON FB.ID = F.FATBASID
    LEFT JOIN dbo.STOKLAR S
        ON F.TUR IN (1, 11)
       AND S.ID = F.URUNID
    LEFT JOIN dbo.MASRAFGELIR MG
        ON F.TUR NOT IN (1, 11)
       AND MG.ID = F.URUNID
    OUTER APPLY
    (
        SELECT TOP (1) G.ANAHTAR
        FROM dbo.GENINI G
        WHERE G.BOLUM = -2702
          AND G.DIL = -1
          AND G.DEGER = F.BIRIM
        ORDER BY G.SIRA
    ) BR
    OUTER APPLY
    (
        SELECT TOP (1) B.BARKOD
        FROM dbo.STOKBARKOD B
        WHERE B.STOKID = F.URUNID
          AND B.VARSAYILAN = 1
        ORDER BY B.ID
    ) SB
    WHERE F.FATBASID = @ID
    ORDER BY SATIRNO;
END;
