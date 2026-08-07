SET NOCOUNT ON;
-- A) TAM donusmus satir (Kalan=0) -> 1 adet istenirse RED
SELECT 'A) kalan=0 satirda 1 adet' AS x;
EXEC dbo.sp_Api_Donusum_Kontrol_Json N'{"Kaynak":2,"DonusumTuru":409,"Satirlar":[{"SatirId":156939,"Adet":1}]}';

-- B) Hic donusmemis satir bul, kalanina esit iste -> UYGUN
DECLARE @sid INT = (SELECT TOP 1 SD.ID FROM SIPARISDETAY SD
                    CROSS APPLY dbo.fn_Api_Donusum_Kalan(2,409,SD.ID,0) K
                    WHERE K.Donusen = 0 AND K.Kalan > 0 ORDER BY SD.ID DESC);
DECLARE @kal DECIMAL(18,6) = (SELECT Kalan FROM dbo.fn_Api_Donusum_Kalan(2,409,@sid,0));
SELECT 'B) test satiri' AS x, @sid AS SatirId, @kal AS Kalan;
DECLARE @j NVARCHAR(MAX) = N'{"Kaynak":2,"DonusumTuru":409,"Satirlar":[{"SatirId":' + CAST(@sid AS varchar(20)) + N',"Adet":' + CAST(@kal AS varchar(30)) + N'}]}';
EXEC dbo.sp_Api_Donusum_Kontrol_Json @j;

-- C) Ayni satirda kalandan fazla -> RED
SET @j = N'{"Kaynak":2,"DonusumTuru":409,"Satirlar":[{"SatirId":' + CAST(@sid AS varchar(20)) + N',"Adet":' + CAST(@kal + 0.5 AS varchar(30)) + N'}]}';
SELECT 'C) kalandan 0.5 fazla' AS x;
EXEC dbo.sp_Api_Donusum_Kontrol_Json @j;

-- D) Olmayan satir + gecerli satir birlikte -> toplu RED
SET @j = N'{"Kaynak":2,"DonusumTuru":409,"Satirlar":[{"SatirId":' + CAST(@sid AS varchar(20)) + N',"Adet":1},{"SatirId":-999,"Adet":1}]}';
SELECT 'D) biri olmayan satir' AS x;
EXEC dbo.sp_Api_Donusum_Kontrol_Json @j;

-- E) FATBASLIK kaynagi (Kaynak=3) TVF calisiyor mu
SELECT TOP 3 'E) Kaynak=3 ornek' AS x, F.ID, F.ADET, K.Donusen, K.Kalan
FROM FATURA F CROSS APPLY dbo.fn_Api_Donusum_Kalan(3, 411, F.ID, 0) K
WHERE EXISTS(SELECT 1 FROM FATURA F1 WHERE F1.YERI IN (411,424) AND F1.YERID=F.ID) ORDER BY F.ID DESC;
