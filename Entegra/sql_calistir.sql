SET NOCOUNT ON;
-- 1) REGRESYON: 400 belgede ISKONTO2=0 oldugu icin sonuc DEGISMEMELI
IF OBJECT_ID('tempdb..#Sonra') IS NOT NULL DROP TABLE #Sonra;
SELECT B.BelgeId, T.TUR, T.ACIKLAMA, ROUND(T.DEGER,4) AS DEGER, ROUND(T.DOVIZTUTARI,4) AS DVZ
INTO #Sonra
FROM (SELECT DISTINCT BelgeId FROM dbo.ZZ_DipToplam_Once) B
CROSS APPLY dbo.fn_Api_Belge_DipToplam(B.BelgeId) T;

SELECT 'Once satir' AS x, COUNT(*) AS Adet FROM dbo.ZZ_DipToplam_Once
UNION ALL SELECT 'Sonra satir', COUNT(*) FROM #Sonra
UNION ALL SELECT 'Yalniz ONCE de', COUNT(*) FROM (SELECT * FROM dbo.ZZ_DipToplam_Once EXCEPT SELECT * FROM #Sonra) a
UNION ALL SELECT 'Yalniz SONRA da', COUNT(*) FROM (SELECT * FROM #Sonra EXCEPT SELECT * FROM dbo.ZZ_DipToplam_Once) b;

-- 2) SENTETIK: ISKONTO2'li belge -> KDV tabani artik ikinci iskontoyu dusuyor mu
SET XACT_ABORT ON;
DECLARE @reh INT = (SELECT TOP 1 REHBERID FROM FATBASLIK WHERE TUR=14 ORDER BY ID DESC);
DECLARE @urun INT = (SELECT TOP 1 ID FROM STOKLAR WHERE DURUM=1 ORDER BY ID);
BEGIN TRAN;
DECLARE @j NVARCHAR(MAX) = N'{"Oturum":{"KulId":7},"Baslik":{"Tur":14,"Tipi":1,"Tarih":"2026-08-08",
 "RehberId":' + CAST(@reh AS varchar(20)) + N',"CikisDepo":1,"KdvDurum":"Hariç","Kur":"TL","Aciklama":"ISK2 testi"},
 "Satirlar":[{"Sira":1,"UrunId":' + CAST(@urun AS varchar(20)) + N',"Adet":2.75,"BirimFiyat":150,"Kdv":20,"Iskonto":10,"Iskonto2":5}]}';
EXEC dbo.sp_Api_Belge_Kaydet_Json @j;
DECLARE @bid INT = (SELECT TOP 1 ID FROM FATBASLIK ORDER BY ID DESC);
SELECT 'Dip toplam' AS x, TUR, ACIKLAMA, ROUND(DEGER,2) AS DEGER FROM dbo.fn_Api_Belge_DipToplam(@bid) ORDER BY TUR;
SELECT 'Baslik' AS x, FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI FROM FATBASLIK WHERE ID=@bid;
SELECT 'Beklenen' AS x, CAST(352.69 AS money) AS Matrah, CAST(70.54 AS money) AS Kdv, CAST(423.23 AS money) AS Toplam;
ROLLBACK;
DROP TABLE dbo.ZZ_DipToplam_Once;
