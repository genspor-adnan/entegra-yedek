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
            WHEN FB.TUR = 15 AND ISNULL(FB.SENARYO, 1) IN (1, 2, 3, 7, 8) THEN FB.SENARYO
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
END;
