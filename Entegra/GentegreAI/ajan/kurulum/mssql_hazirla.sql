-- =============================================================================
--  GENTEGRE AKTARIM AJANI - MSSQL HAZIRLIĞI (müşteri sunucusunda, bir kez)
--
--  sqlcmd -I -f 65001 -S .\SQLEXPRESS -d <VERITABANI> -E -i mssql_hazirla.sql -v PAROLA="<güçlü parola>"
--  (-I: QUOTED_IDENTIFIER ON şart - Delphi veritabanında filtreli indeksler var)
--
--  1) Change Tracking'i veritabanında ve aktarılan tablolarda açar, salt okur
--     rolü kurar (Update_SQL_208..210'un yordamı; Delphi güncellemesiyle gelir).
--  2) Ajanın girişi: yalnız bu rol - SELECT + VIEW CHANGE TRACKING, YAZAMAZ.
--  Yeniden çalıştırılabilir: var olan giriş/kullanıcı yeniden açılmaz, parola değişir.
-- =============================================================================
SET NOCOUNT ON;

IF OBJECT_ID('dbo.sp_Aktarim_Hazirla') IS NULL
BEGIN
  RAISERROR('dbo.sp_Aktarim_Hazirla yok: önce Delphi güncellemesini (Update_SQL_208 ve sonrası) uygulayın.', 16, 1);
  RETURN;
END

EXEC dbo.sp_Aktarim_Hazirla @Ac = 1;

DECLARE @Sql nvarchar(max) =
  CASE WHEN SUSER_ID('gentegre_aktarim') IS NULL
       THEN N'CREATE LOGIN gentegre_aktarim WITH PASSWORD = N''$(PAROLA)'', CHECK_POLICY = ON, DEFAULT_DATABASE = ' + QUOTENAME(DB_NAME())
       ELSE N'ALTER LOGIN gentegre_aktarim WITH PASSWORD = N''$(PAROLA)''' END;
EXEC (@Sql);

IF DATABASE_PRINCIPAL_ID('gentegre_aktarim') IS NULL
  CREATE USER gentegre_aktarim FOR LOGIN gentegre_aktarim;

IF IS_ROLEMEMBER('gentegre_aktarim_okur', 'gentegre_aktarim') = 0
  ALTER ROLE gentegre_aktarim_okur ADD MEMBER gentegre_aktarim;

-- DEPO DB (<DB>_GENDEPO): e-Belge geçmişi (EBELGE / EBELGEMESAJ) için CT + ajan kullanıcısı (Update_SQL_221, 1265).
--   Yordam yoksa (Delphi güncellemesi 221'den eski) ya da depo DB'si yoksa e-Belge adımı aktarılmaz; ajan uyarır.
IF OBJECT_ID('dbo.sp_Aktarim_Depo_Hazirla') IS NOT NULL
  EXEC dbo.sp_Aktarim_Depo_Hazirla @Ac = 1;
ELSE
  PRINT 'UYARI: dbo.sp_Aktarim_Depo_Hazirla yok (Update_SQL_221) - e-Belge geçmişi (EBELGE) aktarılmayacak.';

EXEC dbo.sp_Aktarim_Durum;
PRINT 'Hazır: gentegre_aktarim girişi salt okur (gentegre_aktarim_okur).';
