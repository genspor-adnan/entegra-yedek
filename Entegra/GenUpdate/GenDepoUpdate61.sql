-- GenDepoUpdate61: ANA DB'de EKSIK depo synonym'lerini kurar.
-- Belirti: silme/degistirme yapiliyor, GENDEPO.dbo.LOG<yyyy> DOLUYOR, ama Log/Info
-- ekrani BOS. Sebep: yazma yolu depoya DOGRUDAN baglanir (ULog.LogBaglantisi),
-- okuma yolu ise ANA baglantidan niteliksiz 'FROM ISLEMLOG' sorgular -> ana DB'de
-- synonym yoksa sorgu patlar ve ekran sessizce bos kalir (UInfo except bloğu).
-- Tetikleyen senaryo: format/yeniden kurulum ya da DB restore sonrasi ana DB'nin
-- GENINI versiyon no'su zaten ileride oldugu icin kurulum komutlari hic gelmez.
-- Idempotent: var olan synonym'e/tabloya DOKUNMAZ, sadece EKSIK olani kurar.
SET NOCOUNT ON;

DECLARE @depo   sysname,
        @sql    nvarchar(max),
        @ad     sysname,
        @kurulan int = 0,
        @errmsg nvarchar(2048);

BEGIN TRY
  -- Depo DB adi: GENINI BOLUM=-24120 (Ops_FaturaOpsiyon_DepoDBAdi), ANAHTAR kolonu.
  SELECT TOP 1 @depo = NULLIF(LTRIM(RTRIM(ANAHTAR)), '')
  FROM dbo.GENINI WHERE BOLUM = -24120;
  IF @depo IS NULL SET @depo = N'GENDEPO';

  IF DB_ID(@depo) IS NULL
  BEGIN
    RAISERROR('GenDepoUpdate61: depo DB (%s) YOK - synonym kurulmadi.', 10, 1, @depo) WITH NOWAIT;
    RETURN;
  END

  DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT ad FROM (VALUES ('EBELGE'), ('EBELGEMESAJ'), ('EBELGEKUYRUK'),
                           ('ISLEMLOG'), ('LOGREFERANS'), ('LOGCOZUM'),
                           ('SNAPSHOT'), ('DOSYA')) AS S(ad);
  OPEN cur;
  FETCH NEXT FROM cur INTO @ad;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Ana DB'de ayni adda nesne YOKSA ve depoda hedef VARSA kur.
    IF OBJECT_ID('dbo.' + QUOTENAME(@ad)) IS NULL
       AND OBJECT_ID(QUOTENAME(@depo) + '.dbo.' + QUOTENAME(@ad)) IS NOT NULL
    BEGIN
      SET @sql = N'CREATE SYNONYM dbo.' + QUOTENAME(@ad) +
                 N' FOR ' + QUOTENAME(@depo) + N'.dbo.' + QUOTENAME(@ad) + N';';
      EXEC(@sql);
      SET @kurulan = @kurulan + 1;
      RAISERROR('GenDepoUpdate61: synonym dbo.%s -> %s olusturuldu.', 10, 1, @ad, @depo) WITH NOWAIT;
    END
    FETCH NEXT FROM cur INTO @ad;
  END
  CLOSE cur; DEALLOCATE cur;

  -- ISLEMLOG view'i depoda yoksa LOG<yyyy> tablolarindan (yeniden) uret.
  IF OBJECT_ID(QUOTENAME(@depo) + '.dbo.ISLEMLOG') IS NULL
  BEGIN
    SET @sql = N'USE ' + QUOTENAME(@depo) + N';
DECLARE @u nvarchar(max) = N'''';
SELECT @u = @u + CASE WHEN @u = N'''' THEN N'''' ELSE N'' UNION ALL '' END +
  N''SELECT ID,TARIH,IP,ISTASYON,KULLANICIID,SUBEID,ISLEMTIPI,ALTISLEMTIPI,'' +
  N''USTTABLOID,USTKAYITID,TABLOID,KAYITID,REHBERID,STOKID,BILGI FROM dbo.'' + name
FROM sys.tables WHERE name LIKE ''LOG[0-9][0-9][0-9][0-9]'' ORDER BY name;
IF @u <> N'''' EXEC(N''CREATE OR ALTER VIEW dbo.ISLEMLOG AS '' + @u);';
    EXEC(@sql);
    RAISERROR('GenDepoUpdate61: %s.dbo.ISLEMLOG view yeniden uretildi.', 10, 1, @depo) WITH NOWAIT;

    -- View yeni olustuysa synonym de eksik kalmis olabilir; tekrar dene.
    IF OBJECT_ID('dbo.ISLEMLOG') IS NULL
       AND OBJECT_ID(QUOTENAME(@depo) + '.dbo.ISLEMLOG') IS NOT NULL
    BEGIN
      SET @sql = N'CREATE SYNONYM dbo.ISLEMLOG FOR ' + QUOTENAME(@depo) + N'.dbo.ISLEMLOG;';
      EXEC(@sql);
      SET @kurulan = @kurulan + 1;
    END
  END

  RAISERROR('GenDepoUpdate61: TAMAM - %d synonym kuruldu (depo: %s).', 10, 1, @kurulan, @depo) WITH NOWAIT;
END TRY
BEGIN CATCH
  IF CURSOR_STATUS('local', 'cur') >= 0 BEGIN CLOSE cur; DEALLOCATE cur; END
  SET @errmsg = ERROR_MESSAGE();
  RAISERROR('GenDepoUpdate61: HATA: %s', 16, 1, @errmsg) WITH NOWAIT;
END CATCH

-- Sonuc raporu (ana DB'de calistirilmali).
SELECT NESNE = s.ad,
       ANA_DB = CASE WHEN OBJECT_ID('dbo.' + QUOTENAME(s.ad), 'SN') IS NOT NULL THEN 'SYNONYM'
                     WHEN OBJECT_ID('dbo.' + QUOTENAME(s.ad))       IS NOT NULL THEN 'YEREL NESNE'
                     ELSE 'YOK' END,
       COZULUYOR = CASE WHEN OBJECT_ID('dbo.' + QUOTENAME(s.ad)) IS NULL THEN 'HAYIR' ELSE 'EVET' END
FROM (VALUES ('EBELGE'), ('EBELGEMESAJ'), ('EBELGEKUYRUK'), ('ISLEMLOG'),
             ('LOGREFERANS'), ('LOGCOZUM'), ('SNAPSHOT'), ('DOSYA')) AS s(ad);
