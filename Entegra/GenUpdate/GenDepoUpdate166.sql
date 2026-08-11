-- ============================================================
-- GenDepoUpdate166.sql
-- ESKI MESAJLASMA KALINTILARI SILINIYOR
--
--   MESAJLOG / MESAJLOGKULLANICI / MESAJLAR: TCP tabanli eski sohbet denemesinden
--   kalma tablolar. Uygulama tarafi (UAnaGirisSayfasiFrame'deki TChatWindow /
--   TFileSendInfo, UAnaForm'daki MsgClient, Ortak/UMsjlar2 birimi) KALDIRILDI;
--   yeni mesajlasma MESAJKANAL / MESAJKANALUYE / MESAJ uzerinden yuruyor
--   (GenDepoUpdate145 ve sonrasi).
--
--   Bu tablolara yazan/okuyan kod kalmadi. Kurulumlarda icerik genelde bostur
--   (gelistirme veritabaninda 2 satir vardi, hicbir yerde gosterilmiyordu).
--
-- DIKKAT: geri donusu yok. Musteride veri saklanmasi isteniyorsa bu betik
--   atlanabilir; uygulama bu tablolar olmadan da calisir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Once bagimli FK'lar (varsa), sonra tablolar
IF OBJECT_ID('dbo.MESAJLOGKULLANICI') IS NOT NULL
BEGIN
    DECLARE @Sql NVARCHAR(MAX) = N'';
    SELECT @Sql = @Sql + N'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.'
                       + QUOTENAME(OBJECT_NAME(parent_object_id))
                       + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' + CHAR(13)
      FROM sys.foreign_keys
     WHERE referenced_object_id IN (OBJECT_ID('dbo.MESAJLOG'), OBJECT_ID('dbo.MESAJLOGKULLANICI'),
                                    OBJECT_ID('dbo.MESAJLAR'));
    IF LEN(@Sql) > 0 EXEC sp_executesql @Sql;
END
GO

IF OBJECT_ID('dbo.MESAJLOGKULLANICI') IS NOT NULL DROP TABLE dbo.MESAJLOGKULLANICI;
IF OBJECT_ID('dbo.MESAJLOG')          IS NOT NULL DROP TABLE dbo.MESAJLOG;
IF OBJECT_ID('dbo.MESAJLAR')          IS NOT NULL DROP TABLE dbo.MESAJLAR;
GO

-- TABLOLAR kaydi (UInfo/log adlandirmasi) varsa temizle
DELETE FROM dbo.TABLOLAR
 WHERE TABLOADI IN (N'MESAJLOG', N'MESAJLOGKULLANICI', N'MESAJLAR');
GO
