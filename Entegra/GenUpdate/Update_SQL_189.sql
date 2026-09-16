-- Update_SQL_189.sql
-- Stok Opsiyon 'Raf Omru Zorunlu' (-27017): izlem girisinde URT<->SKT'nin karttaki raf
-- omruyle esitlenmesi artik opsiyonel. GENINI degeri opsiyon formundan yazilir;
-- okunmadiginda varsayilan TRUE (eski davranis). Burada yalniz AYARADI (LOGCOZUM
-- 'Ayar No' cozumu) satiri eklenir - idempotent.
-- Ayrica Alis/Satis Opsiyon 'Satiri Adeti Kadar Bol Menusu Gozuksun' (-24122) ve
-- eksik kalmis 'Belge No Sayac' (-24121) satirlari.

IF OBJECT_ID('dbo.AYARADI','U') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.AYARADI WHERE BOLUM = -27017)
  INSERT INTO dbo.AYARADI(BOLUM, AD, SEKSIYON) VALUES (-27017, N'Raf Ömrü Zorunlu', N'Stok');
IF OBJECT_ID('dbo.AYARADI','U') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.AYARADI WHERE BOLUM = -24122)
  INSERT INTO dbo.AYARADI(BOLUM, AD, SEKSIYON) VALUES (-24122, N'Satırı Adeti Kadar Böl Menüsü Gözüksün', N'Fatura');
IF OBJECT_ID('dbo.AYARADI','U') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.AYARADI WHERE BOLUM = -24121)
  INSERT INTO dbo.AYARADI(BOLUM, AD, SEKSIYON) VALUES (-24121, N'Fatura Opsiyon / Belge No Sayac', N'Fatura');
GO
