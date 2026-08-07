SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#D') IS NOT NULL DROP TABLE #D;
CREATE TABLE #D (ID INT PRIMARY KEY, Tur INT, Eski INT, Yeni INT, Kapsam NVARCHAR(10) COLLATE DATABASE_DEFAULT,
                 Neden NVARCHAR(60) COLLATE DATABASE_DEFAULT, Satir INT, Tamamlanan INT, Kismi INT, Acik INT);
INSERT #D (ID,Tur,Eski) SELECT TOP 800 ID, TUR, ISNULL(DURUM,0) FROM SIPARIS ORDER BY ID DESC;
DECLARE @id INT, @j NVARCHAR(200); DECLARE @R TABLE (S NVARCHAR(MAX));
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT ID FROM #D;
OPEN c; FETCH NEXT FROM c INTO @id;
WHILE @@FETCH_STATUS=0 BEGIN
  SET @j = N'{"BelgeId":' + CAST(@id AS varchar(20)) + N',"Kaynak":"siparis","Yaz":0}';
  DELETE @R; INSERT @R EXEC dbo.sp_Api_Belge_DurumHesapla_Json @j;
  UPDATE D SET Yeni=J.Durum, Kapsam=J.Kapsam, Neden=J.Neden, Satir=J.Satir, Tamamlanan=J.Tamamlanan, Kismi=J.Kismi, Acik=J.Acik
  FROM #D D CROSS APPLY (SELECT TOP 1 S FROM @R) X
    CROSS APPLY OPENJSON(X.S) WITH (Durum INT, Kapsam NVARCHAR(10), Neden NVARCHAR(60), Satir INT, Tamamlanan INT, Kismi INT, Acik INT) J
  WHERE D.ID=@id; FETCH NEXT FROM c INTO @id; END
CLOSE c; DEALLOCATE c;

SELECT 'Siparis' AS Olcut, COUNT(*) AS Adet FROM #D
UNION ALL SELECT 'Kapsam ici', COUNT(*) FROM #D WHERE Kapsam='ici'
UNION ALL SELECT 'Durum AYNI', COUNT(*) FROM #D WHERE Kapsam='ici' AND Eski=Yeni
UNION ALL SELECT 'Durum FARKLI', COUNT(*) FROM #D WHERE Kapsam='ici' AND Eski<>Yeni
UNION ALL SELECT '  0 -> 9 (tamamlanmis ama isaretlenmemis)', COUNT(*) FROM #D WHERE Kapsam='ici' AND Eski=0 AND Yeni=9
UNION ALL SELECT '  0 -> 1', COUNT(*) FROM #D WHERE Kapsam='ici' AND Eski=0 AND Yeni=1
UNION ALL SELECT '  1 -> 9', COUNT(*) FROM #D WHERE Kapsam='ici' AND Eski=1 AND Yeni=9
UNION ALL SELECT '  9 -> 1 (geri alma!)', COUNT(*) FROM #D WHERE Kapsam='ici' AND Eski=9 AND Yeni=1
UNION ALL SELECT '  9 -> 0', COUNT(*) FROM #D WHERE Kapsam='ici' AND Eski=9 AND Yeni=0;
SELECT 'Kapsam disi nedenleri' AS x, Neden, COUNT(*) AS Adet FROM #D WHERE Kapsam='disi' GROUP BY Neden ORDER BY COUNT(*) DESC;
SELECT TOP 6 'FARK ORNEK' AS x, ID, Tur, Eski, Yeni, Satir, Tamamlanan, Kismi, Acik FROM #D WHERE Kapsam='ici' AND Eski<>Yeni ORDER BY ID DESC;
DROP TABLE #D;
