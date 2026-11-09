/*
  Update_SQL_224 - TEKLIFDETAY / SIPARISDETAY / FATURA: EN, BOY, YUZEY, SAYI kolonlari

  Kullanici (06.11.2026): en-boy-m2 (Opsiyon > En/Boy hesaplama) kullanan musteride
  kolonlar elle eklenmisti; guncellemeye konsun. Tum DB'lerde olsun.
    EN, BOY, SAYI : decimal(12,6) NULL
    YUZEY         : decimal(24,6) NULL   (birim m2 = EN*BOY/1e6, ADET = YUZEY*SAYI)
  Update_SQL_223 (belge donusumunde bu alanlarin hedef satira gecmesi) kolonlar
  varsa calisir.

  Tekrar calistirilabilir: kolon zaten varsa (elle eklenmis olsa da) dokunulmaz.
  Yalniz NULL'lanabilir kolon ekler; veri degistirmez.
*/
SET NOCOUNT ON;

DECLARE @Tablolar TABLE (TABLO SYSNAME);
INSERT INTO @Tablolar VALUES (N'TEKLIFDETAY'), (N'SIPARISDETAY'), (N'FATURA');

DECLARE @Kolonlar TABLE (KOLON SYSNAME, TIP NVARCHAR(30));
INSERT INTO @Kolonlar VALUES (N'EN', N'decimal(12, 6)'), (N'BOY', N'decimal(12, 6)'),
                             (N'YUZEY', N'decimal(24, 6)'), (N'SAYI', N'decimal(12, 6)');

DECLARE @Tablo SYSNAME, @Kolon SYSNAME, @Tip NVARCHAR(30), @Sql NVARCHAR(400);
DECLARE K CURSOR LOCAL FAST_FORWARD FOR
    SELECT T.TABLO, C.KOLON, C.TIP
      FROM @Tablolar T CROSS JOIN @Kolonlar C
     WHERE OBJECT_ID(N'dbo.' + T.TABLO, N'U') IS NOT NULL
       AND COL_LENGTH(N'dbo.' + T.TABLO, C.KOLON) IS NULL;
OPEN K;
FETCH NEXT FROM K INTO @Tablo, @Kolon, @Tip;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Tablo) + N' ADD ' + QUOTENAME(@Kolon) + N' ' + @Tip + N' NULL';
    EXEC (@Sql);
    PRINT N'Eklendi: ' + @Tablo + N'.' + @Kolon;
    FETCH NEXT FROM K INTO @Tablo, @Kolon, @Tip;
END
CLOSE K;
DEALLOCATE K;
GO
