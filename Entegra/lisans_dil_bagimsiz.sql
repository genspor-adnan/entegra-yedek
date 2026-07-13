-- ============================================================
-- lisans_dil_bagimsiz.sql
--   fn_ModulListesi @Sid'ini DIL-BAGIMSIZ yapar (convert stil 121) + re-lisans.
--   SEBEP: @Sid = MD5(convert(nvarchar(23),schemadate)) stil-0 -> ay adi @@LANGUAGE'a
--   bagli ("Jan" vs "Oca") -> oturum dili degisince (ADO Turkce -> FireDAC Ingilizce)
--   tum lisanslar kirildi. Stil 121 (yyyy-mm-dd...) dilden BAGIMSIZ -> kalici cozum.
--   HER MUSTERI DB'sinde BIR KEZ calistir, sonra uygulamayi yeniden baslat.
--   ONEMLI: Lisanslama araci da ayni @Sid'i (convert ...,121) kullanmali.
-- ============================================================

-- 0) YEDEK (geri donus icin)
IF OBJECT_ID('dbo.MODUL_L_YEDEK') IS NULL
    SELECT MODULID, L INTO dbo.MODUL_L_YEDEK FROM dbo.MODUL;
GO

-- 1) Fonksiyonu dil-bagimsiz yap (tek degisiklik: schemadate convert -> ,121)
ALTER FUNCTION [dbo].[fn_ModulListesi]()

RETURNS @MODULLER TABLE 
(MODULID int, ROOTKOD int, TUR int, MODULADI nvarchar(200), ACIKLAMA nvarchar(300))
AS
BEGIN
declare @Sid nvarchar(200)
select top 1 @Sid=master.dbo.fn_varbintohexstr(HashBytes('MD5',(convert(nvarchar(23),schemadate,121)))) FROM sys.sysservers order by srvid
insert into @MODULLER(MODULID, ROOTKOD, TUR, MODULADI, ACIKLAMA)
select 
	M.MODULID,
	ROOTKOD=case LEN(M.MODULID)
		when 2 then '0' 
		when 4 then substring(CONVERT(varchar(4),M.MODULID),1,2) 
		when 6 then substring(CONVERT(varchar(6),M.MODULID),1,4) 
		when 8 then substring(CONVERT(varchar(8),M.MODULID),1,6) 
		when 10 then substring(CONVERT(varchar(10),M.MODULID),1,8) 
		when 12 then substring(CONVERT(varchar(12),M.MODULID),1,10) 
		when 14 then substring(CONVERT(varchar(14),M.MODULID),1,12)
		end ,
	M.TUR,
	M.MODULADI,
	M.ACIKLAMA
from 
	MODUL M 
where 
	convert(nvarchar(1000),M.L)=convert(nvarchar(1000),HashBytes('SHA1', @Sid+convert(nvarchar(20),MODULID)))

union all

select
	MODULID=convert(int,(convert(nvarchar(4),M.MODULID)+convert(nvarchar(10),D.ID))),
	ROOTKOD=convert(nvarchar(4),M.MODULID),
	TUR=1,
	MODULADI=D.RAPORADI,
	ACIKLAMA=D.ACIKLAMA
from 
	MODUL M inner join
	DOKUMLER D on 
		M.DOKUMTUR=D.MODUL
where 
	convert(nvarchar(1000),M.L)=convert(nvarchar(1000),HashBytes('SHA1', @Sid+convert(nvarchar(20),MODULID))) and 
	LEN(M.MODULID)=4 and M.MODULID like '__99' 

union all

select 
	MODULID=convert(bigint,(convert(varchar(4),M.MODULID)+convert(varchar(10),-R.ID))),
	ROOTKOD=M.MODULID,
	TUR=1,
	MODULADI=R.FIRMA,
	ACIKLAMA=null
from 
	MODUL M inner join 
	REHBER R on 
		R.ID<0 and R.DURUM>0
where 
	convert(nvarchar(1000),M.L)=convert(nvarchar(1000),HashBytes('SHA1', @Sid+convert(nvarchar(20),MODULID))) and 
	LEN(M.MODULID)=4 and M.MODULID like '__98' 

union all

select 
	MODULID=convert(bigint,(convert(varchar(4),M.MODULID)+convert(varchar(10),'0'))),
	ROOTKOD=M.MODULID,
	TUR=1,
	MODULADI='Ortak',
	ACIKLAMA=null
from 
	MODUL M 
where 
	LEN(M.MODULID)=4 and M.MODULID like '__98'

union all

select 
	MODULID='220150'+convert(nvarchar(5),G.DEGER),
	ROOTKOD=M.MODULID,
	TUR=1,
	MODULADI=G.ANAHTAR+' Ekstresi',
	ACIKLAMA=null
from 
	MODUL M inner join GENINI G on G.BOLUM=-2200 and M.MODULID=220150 and G.DIL=-1  
where 
	convert(nvarchar(1000),M.L)=convert(nvarchar(1000),HashBytes('SHA1', @Sid+convert(nvarchar(20),MODULID))) 

union all

SELECT 
   MODULID = CONVERT(VARCHAR(20), M.MODULID) +  CONVERT(VARCHAR(20), D.ID),
    ROOTKOD = M.MODULID,
    TUR = 1,
    MODULADI = D.DEPOADI,
    ACIKLAMA = NULL
FROM 
    MODUL M 
INNER JOIN 
    DEPOLAR D ON D.DURUM > 0
where 
	convert(nvarchar(1000),M.L)=convert(nvarchar(1000),HashBytes('SHA1', @Sid+convert(nvarchar(20),MODULID))) and 
	LEN(M.MODULID)=4 and
	M.MODULID = '2470' 

order by 1

Return 

end
GO

-- 2) RE-LISANS (stil 121 @Sid ile).
--    * KISITLI musteri : WHERE L IS NOT NULL KALSIN (yalniz hakli moduller).
--    * TAM lisansli     : WHERE satirini KALDIR (tum moduller).
DECLARE @Sid nvarchar(200);
SELECT TOP 1 @Sid = master.dbo.fn_varbintohexstr(HashBytes('MD5', convert(nvarchar(23), schemadate, 121)))
    FROM sys.sysservers ORDER BY srvid;
UPDATE dbo.MODUL
    SET L = HashBytes('SHA1', @Sid + convert(nvarchar(20), MODULID))
    WHERE L IS NOT NULL;   -- << KISITLI: birak | TAM lisansli: bu satiri sil
GO

-- 3) DOGRULAMA: 11 degil yuzlerce donmeli
SELECT COUNT(*) AS MODUL_SAYISI FROM dbo.fn_ModulListesi();
SELECT TUR, COUNT(*) AS ADET FROM dbo.fn_ModulListesi() GROUP BY TUR ORDER BY TUR;
