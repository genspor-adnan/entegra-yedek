/*
  URETIMOPERASONPERSONEL_USER yazim hatali eski ek-alan tablosunu
  URETIMOPERASYONPERSONEL_USER tablosuna tasir.

  Kayitlar silinmez: hedef tablo varsa eksik kolonlar eklenir ve sadece hedefte
  olmayan ID'ler tasinir. Hedef yoksa fiziksel tablo yeniden adlandirilir.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
  BEGIN TRAN;

  IF OBJECT_ID(N'dbo.URETIMOPERASONPERSONEL_USER', N'U') IS NOT NULL
  BEGIN
    IF OBJECT_ID(N'dbo.URETIMOPERASYONPERSONEL_USER', N'U') IS NULL
    BEGIN
      EXEC sys.sp_rename N'dbo.URETIMOPERASONPERSONEL_USER',
                         N'URETIMOPERASYONPERSONEL_USER';
      PRINT N'Eski ek-alan tablosu veri kaybi olmadan yeniden adlandirildi.';
    END
    ELSE
    BEGIN
      DECLARE @Sql nvarchar(max) = N'';
      DECLARE @Kolonlar nvarchar(max);
      DECLARE @KaynakKolonlar nvarchar(max);

      /* Eski tabloda olup hedefte bulunmayan ek-alan kolonlarini ayni tipte ekle. */
      SELECT @Sql = @Sql + N'ALTER TABLE dbo.URETIMOPERASYONPERSONEL_USER ADD ' +
        QUOTENAME(C.name) + N' ' +
        CASE T.name
          WHEN N'nvarchar' THEN N'nvarchar(' + CASE WHEN C.max_length = -1 THEN N'max' ELSE CONVERT(nvarchar(10), C.max_length / 2) END + N')'
          WHEN N'nchar'    THEN N'nchar('    + CONVERT(nvarchar(10), C.max_length / 2) + N')'
          WHEN N'varchar'  THEN N'varchar('  + CASE WHEN C.max_length = -1 THEN N'max' ELSE CONVERT(nvarchar(10), C.max_length) END + N')'
          WHEN N'char'     THEN N'char('     + CONVERT(nvarchar(10), C.max_length) + N')'
          WHEN N'decimal'  THEN N'decimal('  + CONVERT(nvarchar(10), C.precision) + N',' + CONVERT(nvarchar(10), C.scale) + N')'
          WHEN N'numeric'  THEN N'numeric('  + CONVERT(nvarchar(10), C.precision) + N',' + CONVERT(nvarchar(10), C.scale) + N')'
          ELSE T.name
        END + N' NULL;' + CHAR(13) + CHAR(10)
      FROM sys.columns C
      INNER JOIN sys.types T ON T.user_type_id = C.user_type_id
      WHERE C.object_id = OBJECT_ID(N'dbo.URETIMOPERASONPERSONEL_USER')
        AND C.is_identity = 0 AND C.is_computed = 0
        AND NOT EXISTS (
          SELECT 1 FROM sys.columns H
          WHERE H.object_id = OBJECT_ID(N'dbo.URETIMOPERASYONPERSONEL_USER')
            AND H.name = C.name
        );

      IF @Sql <> N'' EXEC sys.sp_executesql @Sql;

      SELECT @Kolonlar = STUFF((
        SELECT N',' + QUOTENAME(C.name)
        FROM sys.columns C
        WHERE C.object_id = OBJECT_ID(N'dbo.URETIMOPERASYONPERSONEL_USER')
          AND C.is_identity = 0 AND C.is_computed = 0
          AND EXISTS (
            SELECT 1 FROM sys.columns E
            WHERE E.object_id = OBJECT_ID(N'dbo.URETIMOPERASONPERSONEL_USER')
              AND E.name = C.name
          )
        ORDER BY C.column_id
        FOR XML PATH(N''), TYPE).value(N'.', N'nvarchar(max)'), 1, 1, N'');

      SELECT @KaynakKolonlar = STUFF((
        SELECT N',E.' + QUOTENAME(C.name)
        FROM sys.columns C
        WHERE C.object_id = OBJECT_ID(N'dbo.URETIMOPERASYONPERSONEL_USER')
          AND C.is_identity = 0 AND C.is_computed = 0
          AND EXISTS (
            SELECT 1 FROM sys.columns E
            WHERE E.object_id = OBJECT_ID(N'dbo.URETIMOPERASONPERSONEL_USER')
              AND E.name = C.name
          )
        ORDER BY C.column_id
        FOR XML PATH(N''), TYPE).value(N'.', N'nvarchar(max)'), 1, 1, N'');

      IF ISNULL(@Kolonlar, N'') = N''
        THROW 51200, N'Ek-alan tablosunda tasinacak ortak kolon bulunamadi.', 1;

      SET @Sql = N'INSERT INTO dbo.URETIMOPERASYONPERSONEL_USER (' + @Kolonlar + N') ' +
                 N'SELECT ' + @KaynakKolonlar + N' FROM dbo.URETIMOPERASONPERSONEL_USER E ' +
                 N'WHERE NOT EXISTS (SELECT 1 FROM dbo.URETIMOPERASYONPERSONEL_USER H WHERE H.ID=E.ID);';
      EXEC sys.sp_executesql @Sql;

      DROP TABLE dbo.URETIMOPERASONPERSONEL_USER;
      PRINT N'Ek-alan verileri tasindi; yazim hatali eski tablo kaldirildi.';
    END;
  END
  ELSE
    PRINT N'Yazim hatali eski tablo bulunamadi; islem gerekmedi.';

  COMMIT;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  THROW;
END CATCH;
GO
