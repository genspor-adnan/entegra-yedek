/*
  241105 - E-Belge Menüsü (UFaturalar).
  TUR=1: yalnız görme yetkisi. Rollere HAK verilmez; varsayılan kapalıdır.
  Mevcut modül/yetki kayıtları korunur; tekrar çalıştırılabilir.
  L, yalnız Satış Belgeleri (2411) lisanslıysa aynı lisans deseninde üretilir.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
IF NOT EXISTS (SELECT 1 FROM dbo.MODUL WITH (UPDLOCK, HOLDLOCK) WHERE MODULID = 241105)
BEGIN
    DECLARE @Sid nvarchar(200), @L nvarchar(1000);
    SELECT TOP 1 @Sid = master.dbo.fn_varbintohexstr(
        HASHBYTES('MD5', CONVERT(nvarchar(23), schemadate, 121)))
    FROM sys.sysservers ORDER BY srvid;

    IF EXISTS (SELECT 1 FROM dbo.fn_ModulListesi() WHERE MODULID = 2411)
        SET @L = CONVERT(nvarchar(1000), HASHBYTES('SHA1', @Sid + N'241105'));

    PRINT N'241105 E-Belge Menüsü ekleniyor; rollere otomatik yetki verilmeyecek.';
    INSERT INTO dbo.MODUL (MODULID, MODULADI, ACIKLAMA, TUR, L)
    VALUES (241105, N'E-Belge Menüsü', N'Fatura listesindeki e-Belge menüsünü gösterir.', 1, @L);
END
ELSE
    PRINT N'241105 zaten tanımlı; mevcut tanım ve rol yetkileri korundu.';
COMMIT TRANSACTION;
GO
