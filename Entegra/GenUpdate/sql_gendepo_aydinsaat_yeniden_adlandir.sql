/*
  GENDEPO veritabanini AYDINSAAT_GENDEPO olarak yeniden adlandirir.
  MDF/LDF fiziksel ve mantiksal dosya adlari da yeni ada tasinir.
  FILESTREAM dizini bilincli olarak degistirilmez.
*/
USE master;
GO

SET NOCOUNT ON;
GO

DECLARE @Rc INT;

BEGIN TRY
  ALTER DATABASE [GENDEPO] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  ALTER DATABASE [GENDEPO] MODIFY FILE
  (NAME = N'GENDEPO', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\AYDINSAAT_GENDEPO.mdf');
  ALTER DATABASE [GENDEPO] MODIFY FILE
  (NAME = N'GENDEPO_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\AYDINSAAT_GENDEPO_log.ldf');

  ALTER DATABASE [GENDEPO] SET OFFLINE WITH ROLLBACK IMMEDIATE;

  EXEC @Rc = master..xp_cmdshell
    'cmd /c ren "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\GENDEPO.mdf" "AYDINSAAT_GENDEPO.mdf"',
    NO_OUTPUT;
  IF @Rc <> 0 THROW 51000, 'MDF dosyasi yeniden adlandirilamadi.', 1;

  EXEC @Rc = master..xp_cmdshell
    'cmd /c ren "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\GENDEPO_log.ldf" "AYDINSAAT_GENDEPO_log.ldf"',
    NO_OUTPUT;
  IF @Rc <> 0 THROW 51001, 'LDF dosyasi yeniden adlandirilamadi.', 1;

  ALTER DATABASE [GENDEPO] SET ONLINE;
  ALTER DATABASE [GENDEPO] MODIFY FILE (NAME = N'GENDEPO', NEWNAME = N'AYDINSAAT_GENDEPO');
  ALTER DATABASE [GENDEPO] MODIFY FILE (NAME = N'GENDEPO_log', NEWNAME = N'AYDINSAAT_GENDEPO_log');
  ALTER DATABASE [GENDEPO] MODIFY NAME = [AYDINSAAT_GENDEPO];
  ALTER DATABASE [AYDINSAAT_GENDEPO] SET MULTI_USER;
END TRY
BEGIN CATCH
  IF DB_ID(N'GENDEPO') IS NOT NULL
  BEGIN
    EXEC master..xp_cmdshell
      'cmd /c if exist "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\AYDINSAAT_GENDEPO.mdf" if not exist "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\GENDEPO.mdf" ren "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\AYDINSAAT_GENDEPO.mdf" "GENDEPO.mdf"',
      NO_OUTPUT;
    EXEC master..xp_cmdshell
      'cmd /c if exist "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\AYDINSAAT_GENDEPO_log.ldf" if not exist "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\GENDEPO_log.ldf" ren "C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\AYDINSAAT_GENDEPO_log.ldf" "GENDEPO_log.ldf"',
      NO_OUTPUT;

    ALTER DATABASE [GENDEPO] MODIFY FILE
    (NAME = N'GENDEPO', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\GENDEPO.mdf');
    ALTER DATABASE [GENDEPO] MODIFY FILE
    (NAME = N'GENDEPO_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\GENDEPO_log.ldf');
    ALTER DATABASE [GENDEPO] SET ONLINE;
    ALTER DATABASE [GENDEPO] SET MULTI_USER;
  END;
  THROW;
END CATCH;
GO

SELECT name, state_desc, user_access_desc
FROM sys.databases
WHERE name = N'AYDINSAAT_GENDEPO';

SELECT DB_NAME(database_id) AS Veritabani, name AS MantiksalAd, type_desc, physical_name
FROM sys.master_files
WHERE DB_NAME(database_id) = N'AYDINSAAT_GENDEPO';
GO
