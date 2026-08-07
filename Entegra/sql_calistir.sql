SET NOCOUNT ON;
DECLARE @Baslik INT = 114010, @Satir INT = 3557475, @Urun INT = 142, @Tur INT = 119;
DECLARE @Once INT = (SELECT COUNT(*) FROM STOKSERILOT WHERE STOKID=@Urun);

-- YENI seri/lot (var olmayan) + duzgun Oturum JSON
DECLARE @j NVARCHAR(MAX) = N'{"BelgeId":114010,"SatirId":3557475,"UrunId":142,"BelgeTur":119,
 "IslemTip":1,"IzlemTur":2,"GirisDepo":11,"CikisDepo":1,"StokDurumDegis":true,"KaynakSatirId":0,
 "Oturum":{"KulId":7},
 "SeriLot":[{"Sira":1,"SeriNo":"TEST-API-1","LotNo":"LOT-API-1","Urt":"2026-01-01","Skt":"2027-01-01","Kalan":3,"Durum":0},
            {"Sira":2,"SeriNo":"","LotNo":"252067","Kalan":1,"Durum":0}]}';
EXEC dbo.sp_Api_Belge_SeriLot_Yaz_Json @j;

SELECT 'SONUC - STOKIZLEME' AS x, SI.ID, SI.SERILOTID, SL.SERINO, SL.LOTNO, SI.ADET, SI.KALAN, SI.EKLEYEN
FROM STOKIZLEME SI LEFT JOIN STOKSERILOT SL ON SL.ID=SI.SERILOTID
WHERE SI.BASLIKID=@Baslik AND SI.SATIRID=@Satir AND SI.STOKID=@Urun ORDER BY SI.ID;
SELECT 'SONUC - DEPO' AS x, SD.IZLEMID, SD.DEPOID, SD.ADET FROM STOKIZLEMEDEPO SD
WHERE SD.IZLEMID IN (SELECT ID FROM STOKIZLEME WHERE BASLIKID=@Baslik AND SATIRID=@Satir AND STOKID=@Urun) ORDER BY SD.IZLEMID, SD.DEPOID;
SELECT 'STOKSERILOT once/sonra' AS x, @Once AS Once_, (SELECT COUNT(*) FROM STOKSERILOT WHERE STOKID=@Urun) AS Sonra;

-- TEMIZLIK: test verisini geri al, orijinal tek satiri yeniden kur
DECLARE @g NVARCHAR(MAX) = N'{"BelgeId":114010,"SatirId":3557475,"UrunId":142,"BelgeTur":119,
 "IslemTip":1,"IzlemTur":2,"GirisDepo":11,"CikisDepo":1,"StokDurumDegis":true,"KaynakSatirId":0,
 "Oturum":{"KulId":0},
 "SeriLot":[{"Sira":1,"SeriNo":"","LotNo":"252067","Kalan":1,"Durum":0}]}';
EXEC dbo.sp_Api_Belge_SeriLot_Yaz_Json @g;
DELETE FROM STOKSERILOT WHERE STOKID=@Urun AND SERINO='TEST-API-1';
SELECT 'TEMIZLIK SONRASI' AS x, COUNT(*) AS IzlemSatir FROM STOKIZLEME WHERE BASLIKID=@Baslik AND SATIRID=@Satir AND STOKID=@Urun;
SELECT 'STOKSERILOT son' AS x, COUNT(*) AS Adet FROM STOKSERILOT WHERE STOKID=@Urun;
