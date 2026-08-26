DECLARE @Kosullar nvarchar(max)=N'{"Mod":0,"Sayfa":0,"TopN":100,"Pasifler":1,"Arama":"","Sirala":"","SubeList":"1","TekSubeTum":10,"SubeId":1,"KulId":1}';
EXEC dbo.sp_Prog_Cari_Liste_Json2 @Kosullar, 1;
