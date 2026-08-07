SET NOCOUNT ON;
-- B) TAM donusmus satiri tekrar donusturmeye calis -> RED, HICBIR SEY YAZILMAMALI
DECLARE @sid INT = 156939;  -- kalan=0 (onceki testte dogrulandi)
DECLARE @urun INT = (SELECT URUNID FROM SIPARISDETAY WHERE ID=@sid);
DECLARE @hed INT = (SELECT TOP 1 ID FROM FATBASLIK WHERE TUR=14 ORDER BY ID DESC);
DECLARE @satirOnce INT = (SELECT COUNT(*) FROM FATURA WHERE FATBASID=@hed);
SELECT 'Once' AS x, @sid AS Satir, (SELECT Kalan FROM dbo.fn_Api_Donusum_Kalan(2,409,@sid,0)) AS Kalan,
       @satirOnce AS HedefSatirSayisi;

DECLARE @j NVARCHAR(MAX) = N'{"Kaynak":2,"DonusumTuru":409,"HedefBelgeId":' + CAST(@hed AS varchar(20)) +
  N',"Oturum":{"KulId":7},"Satirlar":[{"Sira":1,"KaynakSatirId":' + CAST(@sid AS varchar(20)) +
  N',"UrunId":' + CAST(@urun AS varchar(20)) + N',"Adet":1,"BirimFiyat":100,"Kdv":20}]}';
BEGIN TRY
  EXEC dbo.sp_Api_Donusum_Uygula_Json @j;
  SELECT 'HATA: red edilmedi' AS x;
END TRY
BEGIN CATCH
  SELECT 'Beklenen RED' AS x, ERROR_NUMBER() AS No, LEFT(ERROR_MESSAGE(),140) AS Mesaj;
END CATCH
SELECT 'Sonra (yazim olmamali)' AS x, (SELECT COUNT(*) FROM FATURA WHERE FATBASID=@hed) AS HedefSatirSayisi;

-- C) Coklu satir: biri gecerli biri asiri -> TOPTAN RED
DECLARE @ok INT = (SELECT TOP 1 SD.ID FROM SIPARISDETAY SD CROSS APPLY dbo.fn_Api_Donusum_Kalan(2,409,SD.ID,0) K
                   WHERE K.Donusen=0 AND K.Kalan>0 ORDER BY SD.ID DESC);
DECLARE @okUrun INT = (SELECT URUNID FROM SIPARISDETAY WHERE ID=@ok);
SET @j = N'{"Kaynak":2,"DonusumTuru":409,"HedefBelgeId":' + CAST(@hed AS varchar(20)) +
  N',"Oturum":{"KulId":7},"Satirlar":[{"Sira":1,"KaynakSatirId":' + CAST(@ok AS varchar(20)) +
  N',"UrunId":' + CAST(@okUrun AS varchar(20)) + N',"Adet":1,"BirimFiyat":100,"Kdv":20},' +
  N'{"Sira":2,"KaynakSatirId":' + CAST(@sid AS varchar(20)) + N',"UrunId":' + CAST(@urun AS varchar(20)) +
  N',"Adet":1,"BirimFiyat":100,"Kdv":20}]}';
BEGIN TRY
  EXEC dbo.sp_Api_Donusum_Uygula_Json @j;
  SELECT 'HATA: red edilmedi' AS x;
END TRY
BEGIN CATCH
  SELECT 'C) coklu - beklenen RED' AS x, ERROR_NUMBER() AS No, LEFT(ERROR_MESSAGE(),140) AS Mesaj;
END CATCH
SELECT 'C sonrasi (yazim olmamali)' AS x, (SELECT COUNT(*) FROM FATURA WHERE FATBASID=@hed) AS HedefSatirSayisi,
       (SELECT COUNT(*) FROM FATURA WHERE YERI=409 AND YERID=@ok) AS GecerliSatirYazildiMi;
