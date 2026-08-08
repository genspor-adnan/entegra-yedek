SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @reh INT = (SELECT TOP 1 REHBERID FROM FATBASLIK WHERE TUR=11 ORDER BY ID DESC);
DECLARE @masraf INT = (SELECT TOP 1 ID FROM MASRAFGELIR WHERE DURUM>0 AND BASLIK=0 ORDER BY ID);
SELECT 'Girdi' AS x, @reh AS Rehber, @masraf AS MasrafId;
BEGIN TRAN;
-- 1) Ubelgegiris.FaturaOlustur: BASLIK-ONLY cagri
DECLARE @j1 NVARCHAR(MAX) = N'{"SatirModu":"delta","Oturum":{"KulId":2,"SubeId":-1},
 "Baslik":{"Tur":11,"Tipi":1,"Tarih":"2026-08-08 00:00:00","FaturaTarih":"2026-08-08 00:00:00",
  "RehberId":' + CAST(@reh AS varchar(20)) + N',"FaturaNo":"TEST-UB-1","GirisDepo":1,"KdvDurum":"Hariç",
  "Kur":"TL","RaporDoviz":"TL","FaturaDovizi":"TL","DovizCinsi":"TL","DovizKur":1,
  "Unvan":"Bizim Firma","Adres":"Adres 1","Ilce":"Kadıköy","Il":"İstanbul","Vd":"Kozyatağı","Vno":"1234567890",
  "FiyatListesi":1,"EkstredeKullan":false,"AcikKapali":true,"EkVergi":0,"Durum":0,"Aciklama":"UB testi"}}';
EXEC dbo.sp_Api_Belge_Kaydet_Json @j1;
DECLARE @bid INT = (SELECT TOP 1 ID FROM FATBASLIK ORDER BY ID DESC);
SELECT 'Baslik yazildi' AS x, ID, TUR, FATURANO, BASLIK, ADRES, IL, VD, VNO, FIYAT_LISTESI, ACIK_KAPALI, KDVDURUM
FROM FATBASLIK WHERE ID=@bid;

-- 2) BelgeSatirlariniYaz: ayni belgeye 2 satir (masraf kalemi, TUR=0)
DECLARE @j2 NVARCHAR(MAX) = N'{"SatirModu":"delta","Oturum":{"KulId":2,"SubeId":-1},
 "Baslik":{"ID":' + CAST(@bid AS varchar(20)) + N'},
 "Satirlar":[{"Sira":1,"Tur":0,"UrunId":' + CAST(@masraf AS varchar(20)) + N',"MasrafId":' + CAST(@masraf AS varchar(20)) +
 N',"Aciklama":"kalem 1","Adet":1,"Miktar":1,"Birim":51,"BirimFiyat":100,"Tutar":100,"Kdv":20,"Kur":"TL","DovizKuru":"TL"},
             {"Sira":2,"Tur":0,"UrunId":' + CAST(@masraf AS varchar(20)) + N',"MasrafId":' + CAST(@masraf AS varchar(20)) +
 N',"Aciklama":"kalem 2","Adet":2,"Miktar":2,"Birim":51,"BirimFiyat":50,"Tutar":100,"Kdv":10,"Kur":"TL","DovizKuru":"TL"}]}';
EXEC dbo.sp_Api_Belge_Kaydet_Json @j2;

SELECT 'Satirlar' AS x, ID, TUR, URUNID, STOKID, MASRAFID, ADET, BIRIMFIYAT, TUTAR, KDV FROM FATURA WHERE FATBASID=@bid ORDER BY ID;
SELECT 'Baslik toplamlari' AS x, FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI, DOVIZ_TUTARI FROM FATBASLIK WHERE ID=@bid;
ROLLBACK;
SELECT 'Rollback sonrasi' AS x, COUNT(*) AS Kalan FROM FATBASLIK WHERE FATURANO='TEST-UB-1';
