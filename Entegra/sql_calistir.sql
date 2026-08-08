SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @depo sysname = dbo.fn_Api_DepoDBAdi();
BEGIN TRAN;
DECLARE @n INT;
EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo='FATBASLIK', @KayitId=114043, @TabNo=29, @UstTabNo=29, @UstId=114043,
     @KulId=2, @Istasyon='REHTEST4', @Yazilan=@n OUTPUT;
EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo='FATURA', @Kosul=N'FATBASID = @pB', @KosulPar=114043, @TabNo=132,
     @UstTabNo=29, @UstId=114043, @KulId=2, @Istasyon='REHTEST4', @Yazilan=@n OUTPUT;
EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo='STOKIZLEME', @Kosul=N'BASLIKID = @pB', @KosulPar=114043, @TabNo=367,
     @UstTabNo=29, @UstId=114043, @KulId=2, @Istasyon='REHTEST4', @Yazilan=@n OUTPUT;
DECLARE @s NVARCHAR(MAX) = N'
SELECT ''YENI SILME LOGU'' AS x, TABLOID, KAYITID, REHBERID, STOKID FROM [' + @depo + N'].dbo.ISLEMLOG
 WHERE ISTASYON=''REHTEST4'' ORDER BY ID;
SELECT ''ESKI EKLEME LOGU'' AS x, TABLOID, KAYITID, REHBERID, STOKID
 FROM [' + @depo + N'].dbo.ISLEMLOG WHERE USTKAYITID=114043 AND ISLEMTIPI=1 ORDER BY ID;';
EXEC sp_executesql @s;
ROLLBACK;
