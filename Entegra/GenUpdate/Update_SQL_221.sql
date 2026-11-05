/*
  Update_SQL_221 - Gentegre AI aktarimi: DEPO veritabaninda (<ANA>_GENDEPO) e-Belge
  tablolarinin degisiklik izlemesi (Change Tracking).

  Kullanici (05.11.2026): aktarilan "gonderilmis" faturanin e-Belge gorunumu yoktu;
  e-Belge gecmisi (EBELGE / EBELGEMESAJ) yalniz Delphi kapanirken bir kez tasiniyordu.
  Artik ajan surekli tasir (GentegreAI db/1265, dokuman/18 §11). EBELGE ana DB'de
  SYNONYM, asil tablo depo DB'sinde (ULog kurali: <ANA_DB_ADI>_GENDEPO) - Change
  Tracking CHANGETABLE synonym uzerinden calismaz, depo DB'sinde ayrica acilmali.

  BU BETIK HICBIR AYARI DEGISTIRMEZ (208 ile ayni ilke). Yalniz yordam tanimlar:
    sp_Aktarim_Depo_Hazirla @Ac = 1  - depo DB'sinde CT'yi acar (EBELGE, EBELGEMESAJ),
                                       salt okur rolu + ajan kullanicisini (login varsa) kurar
    sp_Aktarim_Depo_Hazirla @Ac = 0  - kapatir
  Ajan kurulumunda mssql_hazirla.sql, sp_Aktarim_Hazirla'dan sonra bunu cagirir.
  Depo DB'si yoksa (eski kurulum, GENDEPO hic kurulmamis) yalniz bilgi doner; ajan
  depo baglantisini acamayinca e-Belge adimini atlar.
*/
CREATE OR ALTER PROCEDURE dbo.sp_Aktarim_Depo_Hazirla
  @Ac        bit = 1,          -- 1 ac, 0 kapat
  @SaklaGun  int = 7,          -- CT saklama suresi (gun)
  @DepoDb    sysname = NULL    -- bos = <bu DB>_GENDEPO
AS
BEGIN
  SET NOCOUNT ON;
  IF @DepoDb IS NULL SET @DepoDb = DB_NAME() + N'_GENDEPO';
  IF DB_ID(@DepoDb) IS NULL
  BEGIN
    SELECT @DepoDb AS DEPO, 'depo veritabani yok - e-Belge gecmisi aktarilmaz' AS DURUM;
    RETURN;
  END

  -- Depo DB'sinde kosacak govde: dinamik USE ile. @Ac / @SaklaGun / login adi metne gomulur.
  DECLARE @Sql nvarchar(max) = N'USE ' + QUOTENAME(@DepoDb) + N';
  SET NOCOUNT ON;
  DECLARE @Tablolar TABLE (AD sysname PRIMARY KEY);
  INSERT INTO @Tablolar (AD) VALUES (''EBELGE''), (''EBELGEMESAJ'');
  DECLARE @Sonuc TABLE (TABLO sysname, DURUM varchar(60));
  DECLARE @Ad sysname, @S nvarchar(max);
  IF ' + CAST(@Ac AS nvarchar(1)) + N' = 1
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.change_tracking_databases WHERE database_id = DB_ID())
    BEGIN
      SET @S = N''ALTER DATABASE '' + QUOTENAME(DB_NAME()) + N'' SET CHANGE_TRACKING = ON (CHANGE_RETENTION = '
          + CAST(@SaklaGun AS nvarchar(10)) + N' DAYS, AUTO_CLEANUP = ON)'';
      EXEC (@S);
      INSERT INTO @Sonuc VALUES (''(depo)'', ''CT acildi'');
    END
    ELSE INSERT INTO @Sonuc VALUES (''(depo)'', ''CT zaten acik'');

    DECLARE k CURSOR LOCAL FAST_FORWARD FOR SELECT AD FROM @Tablolar;
    OPEN k; FETCH NEXT FROM k INTO @Ad;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF OBJECT_ID(N''dbo.'' + @Ad, N''U'') IS NULL
        INSERT INTO @Sonuc VALUES (@Ad, ''tablo yok - atlandi'');
      ELSE IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N''dbo.'' + @Ad) AND is_primary_key = 1)
        INSERT INTO @Sonuc VALUES (@Ad, ''PK YOK - CT acilamaz'');
      ELSE IF EXISTS (SELECT 1 FROM sys.change_tracking_tables WHERE object_id = OBJECT_ID(N''dbo.'' + @Ad))
        INSERT INTO @Sonuc VALUES (@Ad, ''zaten acik'');
      ELSE
      BEGIN
        SET @S = N''ALTER TABLE dbo.'' + QUOTENAME(@Ad) + N'' ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF)'';
        EXEC (@S);
        INSERT INTO @Sonuc VALUES (@Ad, ''acildi'');
      END
      FETCH NEXT FROM k INTO @Ad;
    END
    CLOSE k; DEALLOCATE k;

    IF DATABASE_PRINCIPAL_ID(''gentegre_aktarim_okur'') IS NULL EXEC (N''CREATE ROLE gentegre_aktarim_okur'');
    DECLARE g CURSOR LOCAL FAST_FORWARD FOR SELECT AD FROM @Tablolar WHERE OBJECT_ID(N''dbo.'' + AD, N''U'') IS NOT NULL;
    OPEN g; FETCH NEXT FROM g INTO @Ad;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @S = N''GRANT SELECT, VIEW CHANGE TRACKING ON dbo.'' + QUOTENAME(@Ad) + N'' TO gentegre_aktarim_okur'';
      EXEC (@S);
      FETCH NEXT FROM g INTO @Ad;
    END
    CLOSE g; DEALLOCATE g;
    -- Ajan girisi (mssql_hazirla.sql ana DB''de acar): depo DB''sinde kullanicisi + rol uyeligi.
    IF SUSER_ID(''gentegre_aktarim'') IS NOT NULL
    BEGIN
      IF DATABASE_PRINCIPAL_ID(''gentegre_aktarim'') IS NULL EXEC (N''CREATE USER gentegre_aktarim FOR LOGIN gentegre_aktarim'');
      IF IS_ROLEMEMBER(''gentegre_aktarim_okur'', ''gentegre_aktarim'') = 0 EXEC (N''ALTER ROLE gentegre_aktarim_okur ADD MEMBER gentegre_aktarim'');
      INSERT INTO @Sonuc VALUES (''(rol)'', ''gentegre_aktarim depo DB''''sinde salt okur'');
    END
    ELSE INSERT INTO @Sonuc VALUES (''(rol)'', ''gentegre_aktarim girisi yok - once mssql_hazirla.sql'');
  END
  ELSE
  BEGIN
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
      SELECT t.AD FROM @Tablolar t
       WHERE EXISTS (SELECT 1 FROM sys.change_tracking_tables x WHERE x.object_id = OBJECT_ID(N''dbo.'' + t.AD));
    OPEN c; FETCH NEXT FROM c INTO @Ad;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @S = N''ALTER TABLE dbo.'' + QUOTENAME(@Ad) + N'' DISABLE CHANGE_TRACKING'';
      EXEC (@S);
      INSERT INTO @Sonuc VALUES (@Ad, ''kapatildi'');
      FETCH NEXT FROM c INTO @Ad;
    END
    CLOSE c; DEALLOCATE c;
    IF EXISTS (SELECT 1 FROM sys.change_tracking_databases WHERE database_id = DB_ID())
       AND NOT EXISTS (SELECT 1 FROM sys.change_tracking_tables)
    BEGIN
      SET @S = N''ALTER DATABASE '' + QUOTENAME(DB_NAME()) + N'' SET CHANGE_TRACKING = OFF'';
      EXEC (@S);
      INSERT INTO @Sonuc VALUES (''(depo)'', ''CT kapatildi'');
    END
  END
  SELECT DB_NAME() AS DEPO, TABLO, DURUM FROM @Sonuc;';
  EXEC (@Sql);
END
GO
