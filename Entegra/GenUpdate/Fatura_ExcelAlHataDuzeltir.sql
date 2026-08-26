-- ============================================================
-- GenDepoUpdate170.sql
-- QUOTED_IDENTIFIER varsayilanini ve stok Excel aktarim yordamini duzelt
--
-- SORUN:
--   "Excel'den veri al" gibi UYGULAMA ICI AD-HOC (duz) SQL yazan yollar
--   ana baglanti (Tablo.FDCnn) uzerinden calisir ve bu oturum
--   QUOTED_IDENTIFIER = OFF ile aciliyordu. STOKFIYAT (ve QI ON gerektiren
--   nesnesi olan diger tablolar) uzerinde INSERT/UPDATE/DELETE su hatayi verir:
--     "UPDATE failed because the following SET options have incorrect
--      settings: 'QUOTED_IDENTIFIER'. ... indexed views / computed columns /
--      filtered indexes ..."
--   Ayrica sp_Prog_Irs_Fat_Satir_Ekleme yordami QI OFF ile olusturuldugunda,
--   FATBASLIK tablosundaki filtreli indeks nedeniyle yordam icindeki UPDATE
--   ayni hatayi verir.
--
-- COZUM (exe gerektirmez):
--   Sunucunun 'user options' varsayilanina QUOTED_IDENTIFIER (256) bitini ekle.
--   Boylece YENI oturumlar QI ON gelir; uygulama bu varsayilani izledigi icin
--   ad-hoc DML de artik gecer.
--   sp_Prog_Irs_Fat_Satir_Ekleme yordamini da mevcut govdesini koruyarak
--   QUOTED_IDENTIFIER ON ile yeniden kaydet.
--
-- KAPSAM / UYARILAR:
--   * INSTANCE genelidir (bu SQL Server'daki tum yeni oturumlar). ERP'ye ayrilmis
--     sunucuda guvenli.
--   * Yalniz YENI baglantilar etkilenir -> uygulama YENIDEN BASLATILMALI.
--   * Uygulama/ODBC baglantisi QI'yi ACIKCA OFF'a set ediyorsa bu ayar ezilir;
--     o durumda STOKFIYAT'taki QI-gerektiren nesneyi QI-notr esdegeriyle
--     degistirmek gerekir (filtered index -> normal index vb.).
--   * Yetki: ALTER SETTINGS (sysadmin/serveradmin) gerekir.
--   * MSSQL'e ozeldir; GenUpdate komutu olarak dagitilirken #pg ETIKETI ALMAZ.
--
-- DOGRULAMA (uygulama restart'i sonrasi, uygulamanin baglantisindan):
--     DBCC USEROPTIONS;   -- 'quoted_identifier' satiri 'SET' olmali
--
-- GERI ALMA:  betik eski degeri PRINT eder; gerekirse:
--     EXEC sp_configure 'user options', <eski_deger>; RECONFIGURE;
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

DECLARE @uo  int = (SELECT CONVERT(int, value_in_use) FROM sys.configurations WHERE name = N'user options');
DECLARE @qi  int = 256;   -- QUOTED_IDENTIFIER biti

PRINT 'Mevcut user options degeri : ' + CONVERT(varchar(20), @uo)
    + '  (QUOTED_IDENTIFIER ' + CASE WHEN (@uo & @qi) = @qi THEN 'ON' ELSE 'OFF' END + ')';

IF (@uo & @qi) = @qi
BEGIN
    PRINT 'QUOTED_IDENTIFIER zaten varsayilan ON - degisiklik yapilmadi.';
END
ELSE
BEGIN
    DECLARE @new int = @uo | @qi;

    BEGIN TRY
        EXEC sp_configure N'user options', @new;
        RECONFIGURE;
        PRINT 'Yeni user options degeri   : ' + CONVERT(varchar(20), @new) + '  (QUOTED_IDENTIFIER ON)';
        PRINT 'TAMAM. Uygulamayi YENIDEN BASLATIN; sonra DBCC USEROPTIONS ile dogrulayin.';
        PRINT 'Geri almak icin: EXEC sp_configure ''user options'', ' + CONVERT(varchar(20), @uo) + '; RECONFIGURE;';
    END TRY
    BEGIN CATCH
        PRINT '*** HATA: ' + ERROR_MESSAGE();
        PRINT '    (Yetki: ALTER SETTINGS / sysadmin gerekir.)';
    END CATCH
END;

-- sp_Prog_Irs_Fat_Satir_Ekleme yordamini QUOTED_IDENTIFIER ON ile yeniden kaydet.
-- FATBASLIK.IX_FATBASLIK_SERVISID filtreli indeksi nedeniyle yordamin UPDATE
-- deyimi, yordam OFF ile olusturulmussa hata 1934 ile durur.
-- Yordam govdesi korunur; yalnizca CREATE ifadesi ALTER'a cevrilerek yeniden calistirilir.

DECLARE @NesneId int = OBJECT_ID(N'dbo.sp_Prog_Irs_Fat_Satir_Ekleme', N'P');

IF @NesneId IS NULL
    THROW 50001, N'dbo.sp_Prog_Irs_Fat_Satir_Ekleme bulunamadi.', 1;

IF EXISTS
(
    SELECT 1
    FROM sys.sql_modules
    WHERE object_id = @NesneId
      AND uses_quoted_identifier = 0
)
BEGIN
    DECLARE @Tanim nvarchar(max) = OBJECT_DEFINITION(@NesneId);
    DECLARE @Konum int = CHARINDEX(N'CREATE PROC', @Tanim);
    DECLARE @Aranan nvarchar(20) = N'CREATE PROC';
    DECLARE @Yeni nvarchar(20) = N'ALTER PROC';

    IF @Konum = 0
    BEGIN
        SET @Konum = CHARINDEX(N'CREATE PROCEDURE', @Tanim);
        SET @Aranan = N'CREATE PROCEDURE';
        SET @Yeni = N'ALTER PROCEDURE';
    END;

    IF @Konum = 0
        THROW 50002, N'Yordam taniminda CREATE PROC/PROCEDURE bulunamadi.', 1;

    SET @Tanim = STUFF(@Tanim, @Konum, LEN(@Aranan), @Yeni);
    EXEC sys.sp_executesql @Tanim;
END;

IF EXISTS
(
    SELECT 1
    FROM sys.sql_modules
    WHERE object_id = OBJECT_ID(N'dbo.sp_Prog_Irs_Fat_Satir_Ekleme', N'P')
      AND uses_quoted_identifier = 0
)
    THROW 50003, N'Yordam QUOTED_IDENTIFIER ON ile kaydedilemedi.', 1;

PRINT N'sp_Prog_Irs_Fat_Satir_Ekleme: QUOTED_IDENTIFIER ON.';
