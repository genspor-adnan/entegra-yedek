-- ============================================================
-- Update_SQL_185.sql   (MSSQL)
-- Ihracat fatura geneli navlun/sigorta alanlari
--
-- Navlun ve sigorta satir bazli FATURA_USER.IHRACAT JSON'undan
-- FATBASLIK_USER baslik kolonlarina tasinir. 0.00 gecerli degerdir;
-- hazirlama denetimi NULL olup olmamasina bakar.
-- ============================================================

IF OBJECT_ID('dbo.FATBASLIK_USER','U') IS NULL
BEGIN
  CREATE TABLE dbo.FATBASLIK_USER(
    ID int not null,
    SEVKBILGISI nvarchar(max) null,
    EKLEYEN int null,
    EKLEMETARIHI datetime null constraint DF_FATBASLIK_USER_EKLEMETARIHI default(getdate()),
    DEGISTIREN int null,
    DEGISTIRMETARIHI datetime null,
    constraint PK_FATBASLIK_USER primary key clustered(ID),
    constraint FK_FATBASLIK_USER_FATBASLIK foreign key(ID) references dbo.FATBASLIK(ID)
  );
END

IF COL_LENGTH('dbo.FATBASLIK_USER', 'NAVLUN_TUTARI') IS NULL
    ALTER TABLE dbo.FATBASLIK_USER ADD NAVLUN_TUTARI decimal(18,4) NULL;
IF COL_LENGTH('dbo.FATBASLIK_USER', 'SIGORTA_TUTARI') IS NULL
    ALTER TABLE dbo.FATBASLIK_USER ADD SIGORTA_TUTARI decimal(18,4) NULL;
GO

IF OBJECT_ID('dbo.FATURA_USER','U') IS NOT NULL
BEGIN
    ;WITH Satir AS (
        SELECT F.FATBASID,
               Navlun = TRY_CONVERT(decimal(18,4), REPLACE(COALESCE(
                   NULLIF(JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.NavlunTutari'), ''),
                   NULLIF(JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.NavlunTutar'), '')
               ), ',', '.')),
               Sigorta = TRY_CONVERT(decimal(18,4), REPLACE(COALESCE(
                   NULLIF(JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.SigortaTutari'), ''),
                   NULLIF(JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.SigortaTutar'), '')
               ), ',', '.')),
               Sira = ROW_NUMBER() OVER (
                   PARTITION BY F.FATBASID
                   ORDER BY ISNULL(F.SIRA, 2147483647), F.ID)
        FROM dbo.FATURA_USER FU
        INNER JOIN dbo.FATURA F ON F.ID = FU.ID
        INNER JOIN dbo.FATBASLIK FB ON FB.ID = F.FATBASID
        WHERE FB.SENARYO = 3
          AND ISJSON(CAST(FU.IHRACAT AS nvarchar(max))) = 1
          AND (JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.NavlunTutari') IS NOT NULL
            OR JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.NavlunTutar') IS NOT NULL
            OR JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.SigortaTutari') IS NOT NULL
            OR JSON_VALUE(CAST(FU.IHRACAT AS nvarchar(max)), '$.SigortaTutar') IS NOT NULL)
    ),
    Kaynak AS (
        SELECT FATBASID, Navlun, Sigorta
        FROM Satir
        WHERE Sira = 1
    )
    MERGE dbo.FATBASLIK_USER AS T
    USING Kaynak AS S ON S.FATBASID = T.ID
    WHEN MATCHED THEN
        UPDATE SET
          NAVLUN_TUTARI = COALESCE(T.NAVLUN_TUTARI, S.Navlun),
          SIGORTA_TUTARI = COALESCE(T.SIGORTA_TUTARI, S.Sigorta),
          DEGISTIRMETARIHI = CASE WHEN T.NAVLUN_TUTARI IS NULL OR T.SIGORTA_TUTARI IS NULL THEN GETDATE() ELSE T.DEGISTIRMETARIHI END
    WHEN NOT MATCHED BY TARGET AND (S.Navlun IS NOT NULL OR S.Sigorta IS NOT NULL) THEN
        INSERT (ID, NAVLUN_TUTARI, SIGORTA_TUTARI, EKLEYEN, EKLEMETARIHI)
        VALUES (S.FATBASID, S.Navlun, S.Sigorta, 1, GETDATE());
END

PRINT 'Update_SQL_185: FATBASLIK_USER navlun/sigorta kolonlari hazirlandi.';
