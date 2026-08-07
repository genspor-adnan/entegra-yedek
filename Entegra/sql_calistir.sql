SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @reh INT = (SELECT TOP 1 REHBERID FROM FATBASLIK WHERE TUR=14 ORDER BY ID DESC);
DECLARE @urun INT = (SELECT TOP 1 ID FROM STOKLAR WHERE DURUM=1 ORDER BY ID);
DECLARE @urun2 INT = (SELECT TOP 1 ID FROM STOKLAR WHERE DURUM=1 AND ID<>@urun ORDER BY ID);
SELECT 'Girdi' AS x, @reh AS Rehber, @urun AS Urun1, @urun2 AS Urun2;

BEGIN TRAN;
-- A) YENI belge + 2 satir
DECLARE @j NVARCHAR(MAX) = N'{"SatirModu":"delta","Oturum":{"KulId":7,"SubeId":-1},
 "Baslik":{"ID":0,"Tur":14,"Tipi":1,"Tarih":"2026-08-08","FaturaTarih":"2026-08-08",
   "RehberId":' + CAST(@reh AS varchar(20)) + N',"CikisDepo":1,"KdvDurum":"Hariç","Kur":"TL","Aciklama":"API testi"},
 "Satirlar":[{"Sira":1,"UrunId":' + CAST(@urun AS varchar(20)) + N',"Adet":2.75,"BirimFiyat":150,"Kdv":20,"Iskonto":10,"Iskonto2":5},
             {"Sira":2,"UrunId":' + CAST(@urun2 AS varchar(20)) + N',"Adet":1,"BirimFiyat":100,"Kdv":20}]}';
SELECT 'A) yeni belge' AS x;
EXEC dbo.sp_Api_Belge_Kaydet_Json @j;

DECLARE @bid INT = (SELECT TOP 1 ID FROM FATBASLIK ORDER BY ID DESC);
SELECT 'Yazilan satirlar' AS x, ID, URUNID, ADET, BIRIMFIYAT, ISKONTO, ISKONTO2, TUTAR, KDVDAHILFIYAT FROM FATURA WHERE FATBASID=@bid ORDER BY ID;
SELECT 'Baslik' AS x, ID, FATURANO, FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI FROM FATBASLIK WHERE ID=@bid;

-- B) ayni belgeye delta: 1 satir guncelle, 1 satir sil, 1 satir ekle
DECLARE @s1 INT = (SELECT TOP 1 ID FROM FATURA WHERE FATBASID=@bid ORDER BY ID);
DECLARE @s2 INT = (SELECT TOP 1 ID FROM FATURA WHERE FATBASID=@bid ORDER BY ID DESC);
SET @j = N'{"SatirModu":"delta","Oturum":{"KulId":7},
 "Baslik":{"ID":' + CAST(@bid AS varchar(20)) + N',"Aciklama":"API testi - guncel"},
 "Satirlar":[{"Sira":1,"ID":' + CAST(@s1 AS varchar(20)) + N',"UrunId":' + CAST(@urun AS varchar(20)) + N',"Adet":5,"BirimFiyat":150,"Kdv":20},
             {"Sira":2,"ID":' + CAST(@s2 AS varchar(20)) + N',"Sil":true},
             {"Sira":3,"UrunId":' + CAST(@urun2 AS varchar(20)) + N',"Adet":3,"BirimFiyat":50,"Kdv":10}]}';
SELECT 'B) delta guncelle/sil/ekle' AS x;
EXEC dbo.sp_Api_Belge_Kaydet_Json @j;
SELECT 'B sonrasi satirlar' AS x, ID, URUNID, ADET, BIRIMFIYAT, TUTAR FROM FATURA WHERE FATBASID=@bid ORDER BY ID;
SELECT 'B sonrasi baslik' AS x, ACIKLAMA, FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI FROM FATBASLIK WHERE ID=@bid;

ROLLBACK;
SELECT 'ROLLBACK sonrasi' AS x, (SELECT COUNT(*) FROM FATBASLIK WHERE ACIKLAMA LIKE 'API testi%') AS KalanBelge;
