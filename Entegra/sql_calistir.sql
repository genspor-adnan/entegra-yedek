SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @reh INT = 1126, @masraf INT = (SELECT TOP 1 ID FROM MASRAFGELIR WHERE DURUM>0 AND BASLIK=0 ORDER BY ID);
DECLARE @depo sysname = dbo.fn_Api_DepoDBAdi();
BEGIN TRAN;
DECLARE @j1 NVARCHAR(MAX) = N'{"SatirModu":"delta","Oturum":{"KulId":2,"SubeId":-1},
 "Baslik":{"Tur":12,"Tipi":1,"Tarih":"2026-08-08 09:00:00","FaturaTarih":"2026-08-08 09:00:00",
  "RehberId":' + CAST(@reh AS varchar(20)) + N',"FaturaNo":"LOGTEST-2","GirisDepo":1,"KdvDurum":"Hariç","Kur":"TL"}}';
EXEC dbo.sp_Api_Belge_Kaydet_Json @j1;
DECLARE @bid INT = (SELECT TOP 1 ID FROM FATBASLIK ORDER BY ID DESC);
DECLARE @j2 NVARCHAR(MAX) = N'{"SatirModu":"delta","Oturum":{"KulId":2,"SubeId":-1},
 "Baslik":{"ID":' + CAST(@bid AS varchar(20)) + N'},
 "Satirlar":[{"Sira":1,"Tur":0,"UrunId":' + CAST(@masraf AS varchar(20)) + N',"MasrafId":' + CAST(@masraf AS varchar(20)) +
 N',"Adet":1,"BirimFiyat":100,"Kdv":20,"Kur":"TL"},
             {"Sira":2,"Tur":0,"UrunId":' + CAST(@masraf AS varchar(20)) + N',"MasrafId":' + CAST(@masraf AS varchar(20)) +
 N',"Adet":2,"BirimFiyat":50,"Kdv":10,"Kur":"TL"}]}';
EXEC dbo.sp_Api_Belge_Kaydet_Json @j2;
DECLARE @s NVARCHAR(MAX) = N'
SELECT ''LOGLAR'' AS x, ID, ISLEMTIPI, TABLOID, KAYITID, USTTABLOID, USTKAYITID, REHBERID
FROM [' + @depo + N'].dbo.ISLEMLOG WHERE USTKAYITID = ' + CAST(@bid AS varchar(20)) + N' ORDER BY ID;';
EXEC sp_executesql @s;
ROLLBACK;
