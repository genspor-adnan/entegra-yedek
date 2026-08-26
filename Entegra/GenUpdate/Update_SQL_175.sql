-- ============================================================
-- Update_SQL_175.sql   (MSSQL)
-- KALITESABLONDETAY: eksik SURE ve SIRA kolonlarini ekle
--
-- SORUN
--   Kalite sablonu detay tablosu bazi kurulumlarda SURE ve SIRA kolonlarini TASIMIYOR.
--   Uygulama ise bu kolonlari kullaniyor:
--       UUretimRecete.pas:852   EnsureDataField(TabSablonDetay,'SURE',TSQLTimeStampField)
--       UUretimRecete.pas:1114  insert into KALITESABLONDETAY (... SURE ... SIRA ...)
--   Kolon yoksa uretim recetesi ekraninda dataset acilirken
--       TabloYenile error [TabSablonDetay]: Field 'SURE' not found
--   hatasi aliniyor ve sablon detaylari hic listelenmiyor.
--
-- COZUM
--   Kolonlari dev/PG semasindaki tipleriyle ekle: SURE smalldatetime NULL, SIRA smallint NULL.
--   Mevcut satirlar NULL kalir (SURE zaten opsiyonel sure bilgisi; SIRA sirasiz kabul edilir).
--
-- GUVENLIK
--   - Yalnizca kolon YOKSA eklenir (idempotent, veri kaybi yok, NULL kolon).
--   - Tablo yoksa betik sessizce atlar.
-- ============================================================

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

IF OBJECT_ID('dbo.KALITESABLONDETAY', 'U') IS NULL
BEGIN
    PRINT 'Update_SQL_175: KALITESABLONDETAY tablosu yok, atlandi.';
    RETURN;
END;

IF COL_LENGTH('dbo.KALITESABLONDETAY', 'SURE') IS NULL
BEGIN
    ALTER TABLE dbo.KALITESABLONDETAY ADD SURE smalldatetime NULL;
    PRINT 'Update_SQL_175: SURE kolonu eklendi.';
END
ELSE
    PRINT 'Update_SQL_175: SURE kolonu zaten var.';

IF COL_LENGTH('dbo.KALITESABLONDETAY', 'SIRA') IS NULL
BEGIN
    ALTER TABLE dbo.KALITESABLONDETAY ADD SIRA smallint NULL;
    PRINT 'Update_SQL_175: SIRA kolonu eklendi.';
END
ELSE
    PRINT 'Update_SQL_175: SIRA kolonu zaten var.';

-- Sonuc
SELECT KOLON = c.name,
       TIP   = t.name +
               CASE WHEN t.name IN ('decimal','numeric')
                    THEN '(' + CAST(c.precision AS varchar(5)) + ',' + CAST(c.scale AS varchar(5)) + ')'
                    ELSE '' END
  FROM sys.columns c
  JOIN sys.types   t ON t.user_type_id = c.user_type_id
 WHERE c.object_id = OBJECT_ID('dbo.KALITESABLONDETAY')
   AND c.name IN ('SURE', 'SIRA');
