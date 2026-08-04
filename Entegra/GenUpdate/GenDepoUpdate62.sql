-- ============================================================
-- GenDepoUpdate62: cari/IK kart DETAY tablolari icin TABLOLAR kayitlari
--
-- Neden: cari/IK silmede artik resim(IMAJ), yorum/medya, alias, temsilci, ilgili
--   personel ve ilgili-kisi fotografi da LOGLANIP siliniyor. "Geri Al" (LogGeriAl)
--   ISLEMLOG'daki TABLOID'yi TABLOLAR.TABLOADI ile tabloya cevirir -> bu satirlar
--   YOKSA geri alma o detaylari ATLAR (kotusu: yanlis tabloya yazma riski).
--
-- Idempotent (MERGE). Ana (musteri) DB'de calisir.
-- ============================================================
SET NOCOUNT ON;

IF OBJECT_ID('dbo.TABLOLAR', 'U') IS NOT NULL
BEGIN
    MERGE dbo.TABLOLAR AS T
    USING (VALUES
        (513, 'REHBERALIAS',      N'Alias',              N'Cari'),
        (514, 'REHBERTEMSILCI',   N'Temsilci',           N'Cari'),
        (515, 'REHBERPERSONEL',   N'Ilgili Personel',    N'Cari'),
        (516, 'REHBERBILGIRESIM', N'Resim',              N'Cari')
    ) AS S(TABLOID, TABLOADI, GORUNUM, MODUL)
       ON T.TABLOID = S.TABLOID
    WHEN MATCHED THEN
        UPDATE SET TABLOADI = S.TABLOADI,
                   GORUNUM  = S.GORUNUM,
                   MODUL    = S.MODUL
    WHEN NOT MATCHED THEN
        INSERT (TABLOID, TABLOADI, GORUNUM, MODUL)
        VALUES (S.TABLOID, S.TABLOADI, S.GORUNUM, S.MODUL);

    RAISERROR('GenDepoUpdate62: TABLOLAR kayitlari (513-516) hazir.', 10, 1) WITH NOWAIT;
END
ELSE
    RAISERROR('GenDepoUpdate62: TABLOLAR tablosu YOK - atlandi.', 10, 1) WITH NOWAIT;

-- Dogrulama
SELECT TABLOID, TABLOADI, GORUNUM, MODUL
FROM dbo.TABLOLAR WHERE TABLOID BETWEEN 513 AND 516 ORDER BY TABLOID;
