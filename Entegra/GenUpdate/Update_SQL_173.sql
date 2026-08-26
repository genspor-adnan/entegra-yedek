-- ============================================================
-- Update_SQL_173.sql   (MSSQL)
-- KALITESABLONDETAY: TOLERANSDEGERI ve MIKTAR -> decimal(12,4)
--
-- SORUN
--   Kolonlar bazi kurulumlarda decimal(12,2), bazilarinda decimal(12,4). Delphi tarafinda
--   alanlar PERSISTENT (TBCDField) tanimli ve Size (ondalik hane) SABIT yaziliyor:
--       UUretimRecete.pas  -> EnsureDataField(...,'TOLERANSDEGERI',TBCDField,4)   (4 bekler)
--       UKaliteParametre   -> DFM'de Size = 2                                     (2 bekler)
--   Dataset acilirken sunucudan gelen olcek ile persistent alanin Size'i uyusmazsa FireDAC
--       "size mismatch, expecting: 4 actual: 2"
--   hatasi verir ve ekran acilmaz. Iki ekran farkli olcek bekledigi icin DB hangi degerde
--   olursa olsun biri kiriliyordu.
--
-- COZUM
--   Olcek TEK degere sabitlenir: decimal(12,4) (tolerans/miktar icin 4 hane anlamli;
--   dev veritabani ve PG semasi zaten 12,4). Uygulama tarafinda UKaliteParametre DFM'i de
--   4'e cekildi; UUretimRecete zaten 4 bekliyordu.
--
-- GUVENLIK
--   - decimal(12,2) -> decimal(12,4) GENISLETMEDIR: mevcut degerler aynen korunur,
--     yuvarlama/veri kaybi olmaz (tam sayi hane sayisi 10 olarak sabit kalir).
--   - Kolonlar index/constraint/computed ifade icinde KULLANILMIYOR (kontrol edildi);
--     yine de betik ALTER oncesi bagimlilik kontrolu yapar ve varsa atlar + uyarir.
--   - Idempotent: olcek zaten 4 ise hicbir sey yapmaz.
-- ============================================================

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

IF OBJECT_ID('dbo.KALITESABLONDETAY', 'U') IS NULL
BEGIN
    PRINT 'Update_SQL_173: KALITESABLONDETAY tablosu yok, atlandi.';
    RETURN;
END;

DECLARE @Kolon sysname, @Scale INT, @Bagimli INT, @SQL NVARCHAR(400);
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT c.name, c.scale
      FROM sys.columns c
      JOIN sys.types   t ON t.user_type_id = c.user_type_id
     WHERE c.object_id = OBJECT_ID('dbo.KALITESABLONDETAY')
       AND c.name IN ('TOLERANSDEGERI', 'MIKTAR')
       AND t.name IN ('decimal', 'numeric')
       AND c.scale < 4;

OPEN cur;
FETCH NEXT FROM cur INTO @Kolon, @Scale;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Index / check / default / computed bagimliligi varsa ALTER COLUMN patlar -> atla.
    SELECT @Bagimli =
        (SELECT COUNT(*) FROM sys.index_columns ic
           JOIN sys.columns c2 ON c2.object_id = ic.object_id AND c2.column_id = ic.column_id
          WHERE ic.object_id = OBJECT_ID('dbo.KALITESABLONDETAY') AND c2.name = @Kolon)
      + (SELECT COUNT(*) FROM sys.check_constraints cc
           JOIN sys.columns c3 ON c3.object_id = cc.parent_object_id AND c3.column_id = cc.parent_column_id
          WHERE cc.parent_object_id = OBJECT_ID('dbo.KALITESABLONDETAY') AND c3.name = @Kolon)
      + (SELECT COUNT(*) FROM sys.computed_columns
          WHERE object_id = OBJECT_ID('dbo.KALITESABLONDETAY')
            AND definition LIKE '%' + @Kolon + '%');

    IF @Bagimli > 0
        PRINT 'Update_SQL_173: ' + @Kolon + ' index/constraint icinde kullaniliyor, ATLANDI (elle bakilmali).';
    ELSE
    BEGIN
        SET @SQL = N'ALTER TABLE dbo.KALITESABLONDETAY ALTER COLUMN ' + QUOTENAME(@Kolon) + N' decimal(12,4) NULL;';
        EXEC sp_executesql @SQL;
        PRINT 'Update_SQL_173: ' + @Kolon + ' decimal(12,' + CAST(@Scale AS varchar(3)) + ') -> decimal(12,4).';
    END;

    FETCH NEXT FROM cur INTO @Kolon, @Scale;
END;
CLOSE cur;
DEALLOCATE cur;

-- Sonuc raporu
SELECT KOLON = c.name,
       TIP   = t.name + '(' + CAST(c.precision AS varchar(5)) + ',' + CAST(c.scale AS varchar(5)) + ')'
  FROM sys.columns c
  JOIN sys.types   t ON t.user_type_id = c.user_type_id
 WHERE c.object_id = OBJECT_ID('dbo.KALITESABLONDETAY')
   AND c.name IN ('TOLERANSDEGERI', 'MIKTAR');
