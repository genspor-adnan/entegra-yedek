-- ============================================================
-- Yeni tasarim: YILLIK tablolar  GENDEPO.dbo.LOG<yyyy>  (LOG2026, LOG2027 ...)
-- Okuma icin birlesim VIEW  GENDEPO.dbo.ISLEMLOG (tum LOG<yyyy> UNION ALL).
-- Ana DB'de synonym ISLEMLOG -> GENDEPO.dbo.ISLEMLOG (view).
--
-- Yillik tablolari VE view'i UYGULAMA (ULog) ihtiyac halinde olusturur/genisletir
-- (yil dondugunde otomatik). Bu script yalnizca:
--   1) eski ISLEMLOG TABLOSUNU kaldirir (view adi bosalsin),
--   2) ana DB synonym'ini garanti eder.
-- ============================================================

-- 1) Eski GENDEPO.dbo.ISLEMLOG TABLOSU (artik view olacak)
EXEC('USE GENDEPO; IF OBJECT_ID(''dbo.ISLEMLOG'',''U'') IS NOT NULL DROP TABLE dbo.ISLEMLOG;');

-- 2) Ana DB synonym (view''e cozer; ilk log yazildiginda view olusur)
IF NOT EXISTS(SELECT 1 FROM sys.synonyms WHERE name='ISLEMLOG')
    CREATE SYNONYM dbo.ISLEMLOG FOR GENDEPO.dbo.ISLEMLOG;

-- Kontrol
SELECT SYNONYM=name, HEDEF=base_object_name FROM sys.synonyms WHERE name='ISLEMLOG';
SELECT YIL_TABLO=name FROM GENDEPO.sys.tables
WHERE name LIKE 'LOG[0-9][0-9][0-9][0-9]' ORDER BY name;
