SET NOCOUNT ON;

IF OBJECT_ID('dbo.TABLOLAR', 'U') IS NOT NULL
BEGIN
    MERGE dbo.TABLOLAR AS T
    USING (VALUES
        (42,  'IMAJ',                 N'Medya',   N'Dok' + NCHAR(252) + N'man'),
        (75,  'REHBERILETISIM',       N'Ileti' + NCHAR(351) + N'im', N'Cari'),
        (76,  'REHBERBILGI',          N'Detay',   N'Cari'),
        (79,  'REHBERBILGI',          N'Ticari',  N'Cari'),
        (81,  'REHBERBILGI',          N'Ilgili',  N'Cari'),
        (108, 'FATBASLIK',            N'Alacak',  N'Tahakkuk'),
        (109, 'FATBASLIK',            N'Borc',    N'Tahakkuk'),
        (342, 'STOKBOYUTKOMBINASYON', N'Boyut',   N'Stok'),
        (344, 'STOKESDEGER',          N'E' + NCHAR(351) + N'de' + NCHAR(287) + N'er', N'Stok'),
        (370, 'REHBERBILGI',          N'Detay',   N'Stok')
    ) AS S(TABLOID, TABLOADI, GORUNUM, MODUL)
       ON T.TABLOID = S.TABLOID
    WHEN MATCHED THEN
        UPDATE SET TABLOADI = S.TABLOADI,
                   GORUNUM = S.GORUNUM,
                   MODUL = S.MODUL
    WHEN NOT MATCHED THEN
        INSERT (TABLOID, TABLOADI, GORUNUM, MODUL)
        VALUES (S.TABLOID, S.TABLOADI, S.GORUNUM, S.MODUL);

    SELECT TABLOID, TABLOADI, GORUNUM, MODUL
    FROM dbo.TABLOLAR
    WHERE TABLOID IN (42, 75, 76, 79, 81, 108, 109, 342, 344, 370)
    ORDER BY TABLOID;
END;
