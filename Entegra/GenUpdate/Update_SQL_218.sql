/*
  Update_SQL_218 - Acilista modul sekmeleri ara ara kayboluyor (lisans @Sid uyusmazligi).

  SEBEP: Lisans kapisi fn_ModulListesi, MODUL.L'yi
    HashBytes('SHA1', @Sid + MODULID),  @Sid = MD5(convert(nvarchar(23), schemadate))
  ile karsilastirir. Fonksiyon STIL 0 kullaniyor (ay adi oturum diline bagli:
  "Jan" / "Oca"); exe ise lisans kontrolunde (Utablo, ServerSidNumber) L'yi
  STIL 121 ile yaziyor (lisans_dil_bagimsiz.sql, commit e3ed7e6). O betik
  musterilere hic gonderilmedigi icin fonksiyon stil 0'da kaldi:
    - periyodik lisans kontrolu (Ops_SonrakiLsnsCtrlTarihi) gelince exe L'yi
      stil 121 ile yeniden yazar -> fonksiyon eslesmez -> hic sekme gorunmez;
    - elle duzeltme (L'yi stil 0 ile yeniden hesaplama) bir sonraki lisans
      kontrolune kadar idare eder; sorun "ara ara" tekrarlar.

  COZUM: fonksiyon da stil 121'e alinir (dilden bagimsiz, exe ile ayni ifade):
    1) MODUL.L yedegi (MODUL_L_YEDEK, yoksa).
    2) fn_ModulListesi tanimindaki convert(nvarchar(23),schemadate) -> ,121
       (yalniz o ifade degisir; fonksiyonun geri kalanina dokunulmaz).
    3) L'si STIL 0 @Sid ile (Ingilizce ya da Turkce oturum) yazilmis satirlar
       stil 121'e cevrilir. Bos L (lisanssiz modul) ve zaten stil 121 olan
       satirlara dokunulmaz -> lisanslanan modul kumesi degismez.
    4) GENINI -10092 (saklanan sunucu @Sid'i) stil 0 ise stil 121'e esitlenir;
       yoksa exe "sunucu degisti" sanip -1009x ayarlarini (kurum kodu dahil)
       silerdi.

  Tekrar calistirilabilir. Tek batch (GO yok): GenUpdate komutu olarak da
  oldugu gibi calisir. Uygulandiktan sonra program kapatilip acilir; yeni exe
  gerekmez.
*/
SET NOCOUNT ON;

DECLARE @Dil sysname = @@LANGUAGE;
DECLARE @Sid121 nvarchar(200), @Sid0En nvarchar(200), @Sid0Tr nvarchar(200);

SELECT TOP 1 @Sid121 = master.dbo.fn_varbintohexstr(HashBytes('MD5', convert(nvarchar(23), schemadate, 121)))
  FROM sys.sysservers ORDER BY srvid;
SET LANGUAGE us_english;
SELECT TOP 1 @Sid0En = master.dbo.fn_varbintohexstr(HashBytes('MD5', convert(nvarchar(23), schemadate)))
  FROM sys.sysservers ORDER BY srvid;
SET LANGUAGE Turkish;
SELECT TOP 1 @Sid0Tr = master.dbo.fn_varbintohexstr(HashBytes('MD5', convert(nvarchar(23), schemadate)))
  FROM sys.sysservers ORDER BY srvid;
SET LANGUAGE @Dil;   -- oturum diline geri don

-- 1) yedek
IF OBJECT_ID('dbo.MODUL_L_YEDEK','U') IS NULL
  SELECT MODULID, L INTO dbo.MODUL_L_YEDEK FROM dbo.MODUL;

-- 2) fonksiyonu stil 121'e al
DECLARE @Tanim nvarchar(max) = OBJECT_DEFINITION(OBJECT_ID('dbo.fn_ModulListesi'));
IF @Tanim IS NULL
  PRINT N'fn_ModulListesi yok - fonksiyon adimi atlandi.';
ELSE IF @Tanim LIKE N'%schemadate,121%' OR @Tanim LIKE N'%schemadate, 121%'
  PRINT N'fn_ModulListesi zaten stil 121.';
ELSE
BEGIN
  DECLARE @Yeni nvarchar(max) = REPLACE(REPLACE(@Tanim,
    N'convert(nvarchar(23),schemadate)',  N'convert(nvarchar(23),schemadate,121)'),
    N'convert(nvarchar(23), schemadate)', N'convert(nvarchar(23), schemadate,121)');
  IF @Yeni = @Tanim
    RAISERROR(N'fn_ModulListesi icinde beklenen schemadate ifadesi bulunamadi; fonksiyon elle kontrol edilmeli.', 16, 1);
  ELSE
  BEGIN
    SET @Yeni = STUFF(@Yeni, CHARINDEX(N'CREATE', @Yeni), 6, N'ALTER');
    EXEC sp_executesql @Yeni;
    PRINT N'fn_ModulListesi stil 121 yapildi.';
  END
END

-- 3) stil 0 ile yazilmis lisans satirlarini stil 121'e cevir
UPDATE dbo.MODUL
   SET L = HashBytes('SHA1', @Sid121 + convert(nvarchar(20), MODULID))
 WHERE ISNULL(L, '') <> ''
   AND (   L = HashBytes('SHA1', @Sid0En + convert(nvarchar(20), MODULID))
        OR L = HashBytes('SHA1', @Sid0Tr + convert(nvarchar(20), MODULID)));
PRINT N'Stil 121''e cevrilen lisans satiri: ' + CAST(@@ROWCOUNT AS nvarchar(10));

-- 4) saklanan sunucu @Sid'i stil 0 ise esitle
UPDATE dbo.GENINI SET ANAHTAR = @Sid121
 WHERE BOLUM = -10092 AND ANAHTAR IN (@Sid0En, @Sid0Tr);
