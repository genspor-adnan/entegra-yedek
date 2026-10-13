/*
  Update_SQL_210 - Gentegre AI aktarimi: STOKDURUM ve LOKASYON degisiklik izlemeye eklendi.

  Web'de stok bakiyesi (stok_durum) Delphi STOKDURUM'un aynasidir: yalniz bu
  yilin hareketi aktarildigi icin satirlardan hesaplanamaz (GentegreAI/dokuman/18).
  LOKASYON: uretim recetesi operasyonlarinin kaynagi (makine) -> web is merkezi.
  sp_Aktarim_Hazirla yalniz tablo listesi genisletilerek yeniden tanimlanir.

  BU BETIK HICBIR AYARI DEGISTIRMEZ. CT acik kurumda bir kez daha cagrilir:
     EXEC dbo.sp_Aktarim_Hazirla @Ac = 1
*/
CREATE OR ALTER PROCEDURE dbo.sp_Aktarim_Hazirla
  @Ac        bit = 1,          -- 1 ac, 0 kapat
  @SaklaGun  int = 7           -- CT saklama suresi (gun)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Tablolar TABLE (AD sysname PRIMARY KEY);
  INSERT INTO @Tablolar (AD) VALUES
    ('DEPOLAR'), ('DOVIZ'), ('SRMMERKEZI'), ('PROJELER'),
    ('REHBER'), ('REHBERBILGI'), ('REHBERILETISIM'),
    ('STOKLAR'), ('STOKBARKOD'), ('STOKFIYAT'), ('STOKSERILOT'),
    ('MASRAFGELIR'), ('FIYATLAR'),
    ('KASALAR'), ('BANKAHESAPLAR'), ('KREDIKARTI'), ('POS'), ('KREDILER'),
    ('FATBASLIK'), ('FATURA'), ('KASA'), ('STOKIZLEME'),
    -- 209: uretim receteleri (urun agaci) - tanim, tumu aktarilir
    ('URETIMRECETE'), ('URETIMRECETEDETAY'), ('URETIMRECETEOPR'),
    -- 210: stok bakiyesi (web stok_durum Delphi'nin aynasi) + is merkezi kaynagi
    ('STOKDURUM'), ('LOKASYON');

  DECLARE @Sonuc TABLE (TABLO sysname, DURUM varchar(60));
  DECLARE @Ad sysname, @Sql nvarchar(max);

  IF @Ac = 1
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.change_tracking_databases WHERE database_id = DB_ID())
    BEGIN
      SET @Sql = N'ALTER DATABASE ' + QUOTENAME(DB_NAME()) + N' SET CHANGE_TRACKING = ON '
               + N'(CHANGE_RETENTION = ' + CAST(@SaklaGun AS nvarchar(10)) + N' DAYS, AUTO_CLEANUP = ON)';
      EXEC (@Sql);
      INSERT INTO @Sonuc VALUES ('(veritabani)', 'CT acildi');
    END
    ELSE
      INSERT INTO @Sonuc VALUES ('(veritabani)', 'CT zaten acik');

    DECLARE k CURSOR LOCAL FAST_FORWARD FOR SELECT AD FROM @Tablolar;
    OPEN k; FETCH NEXT FROM k INTO @Ad;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      IF OBJECT_ID(N'dbo.' + @Ad, N'U') IS NULL
        INSERT INTO @Sonuc VALUES (@Ad, 'tablo yok - atlandi');
      ELSE IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.' + @Ad) AND is_primary_key = 1)
        INSERT INTO @Sonuc VALUES (@Ad, 'PK YOK - CT acilamaz');
      ELSE IF EXISTS (SELECT 1 FROM sys.change_tracking_tables WHERE object_id = OBJECT_ID(N'dbo.' + @Ad))
        INSERT INTO @Sonuc VALUES (@Ad, 'zaten acik');
      ELSE
      BEGIN
        SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Ad) + N' ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF)';
        EXEC (@Sql);
        INSERT INTO @Sonuc VALUES (@Ad, 'acildi');
      END
      FETCH NEXT FROM k INTO @Ad;
    END
    CLOSE k; DEALLOCATE k;

    -- Salt okur rol: ajan login'i bu role eklenir (SELECT + VIEW CHANGE TRACKING).
    IF DATABASE_PRINCIPAL_ID('gentegre_aktarim_okur') IS NULL
      EXEC (N'CREATE ROLE gentegre_aktarim_okur');
    DECLARE g CURSOR LOCAL FAST_FORWARD FOR
      SELECT AD FROM @Tablolar WHERE OBJECT_ID(N'dbo.' + AD, N'U') IS NOT NULL;
    OPEN g; FETCH NEXT FROM g INTO @Ad;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @Sql = N'GRANT SELECT, VIEW CHANGE TRACKING ON dbo.' + QUOTENAME(@Ad) + N' TO gentegre_aktarim_okur';
      EXEC (@Sql);
      FETCH NEXT FROM g INTO @Ad;
    END
    CLOSE g; DEALLOCATE g;
    INSERT INTO @Sonuc VALUES ('(rol)', 'gentegre_aktarim_okur yetkileri verildi');
  END
  ELSE
  BEGIN
    -- KAPAT: once tablolar, sonra veritabani (tersi hata verir).
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
      SELECT t.AD FROM @Tablolar t
       WHERE EXISTS (SELECT 1 FROM sys.change_tracking_tables c WHERE c.object_id = OBJECT_ID(N'dbo.' + t.AD));
    OPEN c; FETCH NEXT FROM c INTO @Ad;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @Sql = N'ALTER TABLE dbo.' + QUOTENAME(@Ad) + N' DISABLE CHANGE_TRACKING';
      EXEC (@Sql);
      INSERT INTO @Sonuc VALUES (@Ad, 'kapatildi');
      FETCH NEXT FROM c INTO @Ad;
    END
    CLOSE c; DEALLOCATE c;
    -- Baska (aktarim disi) tabloda CT aciksa veritabani duzeyi kapatilmaz.
    IF EXISTS (SELECT 1 FROM sys.change_tracking_databases WHERE database_id = DB_ID())
       AND NOT EXISTS (SELECT 1 FROM sys.change_tracking_tables)
    BEGIN
      SET @Sql = N'ALTER DATABASE ' + QUOTENAME(DB_NAME()) + N' SET CHANGE_TRACKING = OFF';
      EXEC (@Sql);
      INSERT INTO @Sonuc VALUES ('(veritabani)', 'CT kapatildi');
    END
  END

  SELECT TABLO, DURUM FROM @Sonuc;
END
GO
