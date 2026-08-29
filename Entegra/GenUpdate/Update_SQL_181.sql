-- ============================================================
-- Update_SQL_181.sql   (MSSQL)
-- UTS sorgu endpoint tanimlari: hatali ayrintili tekil urun adreslerini duzelt
--
-- Bazi kurulumlarda UTS_BILDIRIM_TUR.ADRESSORGU alani ID 1, 45 ve 52 icin
-- /UTS/uh/rest/ayrintiliTekilUrun/sorgula olarak kalmis. Bu durumda satis
-- faturasi/irsaliyesi satir bazli "UTS'den Kontrol" akisi tekil urun ve aski
-- sorgularini yanlis endpoint'e gonderiyor.
-- Idempotenttir; mevcut dogru veya ozel adreslere dokunmaz.
-- ============================================================

IF OBJECT_ID(N'dbo.UTS_BILDIRIM_TUR_Update181_Yedek', N'U') IS NULL
BEGIN
    SELECT *
      INTO dbo.UTS_BILDIRIM_TUR_Update181_Yedek
      FROM dbo.UTS_BILDIRIM_TUR
     WHERE ID IN (1, 45, 52);

    PRINT N'UTS_BILDIRIM_TUR_Update181_Yedek olusturuldu.';
END;

UPDATE dbo.UTS_BILDIRIM_TUR
   SET ADRESSORGU = CASE ID
                      WHEN 1  THEN N'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula/offset'
                      WHEN 45 THEN N'/UTS/uh/rest/tekilUrun/sorgula'
                      WHEN 52 THEN N'/UTS/uh/rest/bildirim/verme/askidakiler/offset'
                    END
 WHERE ID IN (1, 45, 52)
   AND (
        ADRESSORGU IS NULL
        OR LTRIM(RTRIM(ADRESSORGU)) = N''
        OR ADRESSORGU LIKE N'%ayrintiliTekilUrun%'
       );

PRINT N'UTS_BILDIRIM_TUR sorgu endpoint duzeltmesi uygulandi. Degisen satir: ' + CAST(@@ROWCOUNT AS nvarchar(20));
