-- ============================================================
-- LOG<yyyy>.TARIH -> datetime2(0) (saniye; ms KIRPILIR).
-- Mevcut (eski datetime2(3)) LOG tablolarini saniyeye cevirir. Yeni tablolar
-- ULog.LogYilTablosu / GenDepoKur5 zaten datetime2(0) olusturur.
-- GENDEPO'da calistir. TARIH indeksi bagimli oldugundan drop/alter/recreate.
-- Idempotent: yalniz scale<>0 olanlari cevirir. BUYUK tabloda tek seferlik yavas olabilir.
-- ============================================================
SET NOCOUNT ON;

DECLARE @t sysname, @sql nvarchar(max);
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
  SELECT t.name
  FROM sys.tables t
  JOIN sys.columns c ON c.object_id=t.object_id AND c.name='TARIH'
  WHERE t.name LIKE 'LOG[0-9][0-9][0-9][0-9]' AND c.scale <> 0;
OPEN cur; FETCH NEXT FROM cur INTO @t;
WHILE @@FETCH_STATUS=0
BEGIN
  IF EXISTS(SELECT 1 FROM sys.indexes WHERE name='IX_'+@t+'_TARIH' AND object_id=OBJECT_ID('dbo.'+@t))
    EXEC('DROP INDEX IX_'+@t+'_TARIH ON dbo.'+@t);
  EXEC('ALTER TABLE dbo.'+@t+' ALTER COLUMN TARIH datetime2(0) NOT NULL');
  EXEC('CREATE INDEX IX_'+@t+'_TARIH ON dbo.'+@t+'(TARIH)');
  PRINT @t + ' -> datetime2(0)';
  FETCH NEXT FROM cur INTO @t;
END
CLOSE cur; DEALLOCATE cur;

SELECT TABLO=t.name, TARIH_SCALE=c.scale
FROM sys.tables t JOIN sys.columns c ON c.object_id=t.object_id AND c.name='TARIH'
WHERE t.name LIKE 'LOG[0-9][0-9][0-9][0-9]';
