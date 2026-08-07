SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#K') IS NOT NULL DROP TABLE #K;
CREATE TABLE #K (ID INT PRIMARY KEY, EskiMat MONEY, EskiKdv MONEY, EskiTop MONEY,
                 YeniMat MONEY, YeniKdv MONEY, YeniTop MONEY, Kapsam NVARCHAR(10) COLLATE DATABASE_DEFAULT);
INSERT #K (ID,EskiMat,EskiKdv,EskiTop)
SELECT TOP 600 FB.ID, ISNULL(FB.FATURA_MATRAHI,0), ISNULL(FB.KDV_TUTARI,0), ISNULL(FB.FATURA_TUTARI,0)
FROM FATBASLIK FB WHERE EXISTS(SELECT 1 FROM FATURA F WHERE F.FATBASID=FB.ID) AND ISNULL(FB.FATURA_MATRAHI,0)<>0
ORDER BY FB.ID DESC;
DECLARE @id INT, @j NVARCHAR(200); DECLARE @R TABLE (S NVARCHAR(MAX));
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT ID FROM #K;
OPEN c; FETCH NEXT FROM c INTO @id;
WHILE @@FETCH_STATUS=0 BEGIN
  SET @j = N'{"BelgeId":' + CAST(@id AS varchar(20)) + N',"Yaz":0}';
  DELETE @R; INSERT @R EXEC dbo.sp_Api_Belge_ToplamHesapla_Json @j;
  UPDATE K SET YeniMat=J.Matrah, YeniKdv=J.Kdv, YeniTop=J.Toplam, Kapsam=J.Kapsam
  FROM #K K CROSS APPLY (SELECT TOP 1 S FROM @R) X
    CROSS APPLY OPENJSON(X.S) WITH (Matrah MONEY, Kdv MONEY, Toplam MONEY, Kapsam NVARCHAR(10)) J
  WHERE K.ID=@id;
  FETCH NEXT FROM c INTO @id; END
CLOSE c; DEALLOCATE c;

SELECT 'Toplam belge' AS Olcut, COUNT(*) AS Adet FROM #K
UNION ALL SELECT 'Kapsam ICI', COUNT(*) FROM #K WHERE Kapsam='ici'
UNION ALL SELECT 'Kapsam DISI (yazilmaz)', COUNT(*) FROM #K WHERE Kapsam='disi'
UNION ALL SELECT 'ICI: matrah ayni (<=1 krs)', COUNT(*) FROM #K WHERE Kapsam='ici' AND ABS(EskiMat-YeniMat)<=0.01
UNION ALL SELECT 'ICI: matrah 1-5 krs',       COUNT(*) FROM #K WHERE Kapsam='ici' AND ABS(EskiMat-YeniMat) BETWEEN 0.011 AND 0.05
UNION ALL SELECT 'ICI: matrah >1 TL',         COUNT(*) FROM #K WHERE Kapsam='ici' AND ABS(EskiMat-YeniMat)>1
UNION ALL SELECT 'ICI: KDV ayni',             COUNT(*) FROM #K WHERE Kapsam='ici' AND ABS(EskiKdv-YeniKdv)<=0.01
UNION ALL SELECT 'ICI: KDV >1 TL',            COUNT(*) FROM #K WHERE Kapsam='ici' AND ABS(EskiKdv-YeniKdv)>1
UNION ALL SELECT 'ICI: toplam ayni',          COUNT(*) FROM #K WHERE Kapsam='ici' AND ABS(EskiTop-YeniTop)<=0.01
UNION ALL SELECT 'ICI: toplam >1 TL',         COUNT(*) FROM #K WHERE Kapsam='ici' AND ABS(EskiTop-YeniTop)>1;
SELECT TOP 5 'ICI ama farkli' AS x, ID, EskiMat, YeniMat, EskiKdv, YeniKdv, EskiTop, YeniTop
FROM #K WHERE Kapsam='ici' AND ABS(EskiMat-YeniMat)>1 ORDER BY ABS(EskiMat-YeniMat) DESC;
DROP TABLE #K;
