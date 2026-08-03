IF OBJECT_ID('dbo.sp_Prg_Servis_Belgeler','P') IS NOT NULL DROP PROC dbo.sp_Prg_Servis_Belgeler;
GO
CREATE PROC dbo.sp_Prg_Servis_Belgeler(@ServisID int) AS BEGIN
SET NOCOUNT ON;
select TUR=80,ID,TARIH,BELGENO=TEKLIFNO,TUTAR=DOVIZ_TUTARI,KUR=DOVIZ_KURU,ACIKLAMA,
	FIRMA=(select R.FIRMA from REHBER R where R.ID=T.REHBERID),
	KAYNAK='',
	HEDEF = CONCAT(case when 412 in (select YERI from SIPARISDETAY where YERID in (select ID from TEKLIFDETAY where TEKLIFID=T.ID)) then 'Verilen Sipariş ' else '' end 
		  , case when 413 in (select YERI from SIPARISDETAY where YERID in (select ID from TEKLIFDETAY where TEKLIFID=T.ID)) then 'Alınan Sipariş' else '' end) 
from TEKLIF T where SERVISID=@ServisID

union all

select TUR,ID,TARIH,BELGENO=SIPARISNO,TUTAR=SIPARIS_TUTARI,KUR,ACIKLAMA,
	FIRMA=(select R.FIRMA from REHBER R where R.ID=S.REHBERID),
	KAYNAK = case when (S.TUR=9)and(412 in (select YERI from SIPARISDETAY where SIPARISID=S.ID)) then 'Teklifden'
			when (S.TUR=19)and(413 in (select YERI from SIPARISDETAY where SIPARISID=S.ID)) then 'Teklifden'
			else '' end, 
	HEDEF = case 
			when (S.TUR=9)and(407 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then 'Faturaya'
			when (S.TUR=9)and(406 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then 'İrsaliyeye'
			when (S.TUR=19)and(410 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then 'Faturaya'
			when (S.TUR=19)and(409 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then 'İrsaliyeye'
			when (S.TUR=19)and(415 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then 'Üretim Fişine'
			when (S.TUR=19)and(420 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=S.ID))) then 'Üretim Fişine'
			else '' end   
from SIPARIS S where SERVISID=@ServisID

union all 

select TUR,ID,TARIH,BELGENO=FATURANO,TUTAR=FATURA_TUTARI,KUR,ACIKLAMA,
	FIRMA=(select R.FIRMA from REHBER R where R.ID=F.REHBERID),
	KAYNAK = case 
			when (F.TUR=10)and(406 in (select YERI from FATURA where FATBASID=F.ID)) then 'Siparişten'
			when (F.TUR=14)and(409 in (select YERI from FATURA where FATBASID=F.ID)) then 'Siparişten'
			when (F.TUR=11)and(407 in (select YERI from FATURA where FATBASID=F.ID)) then 'Siparişten'
			when (F.TUR=11)and(408 in (select YERI from FATURA where FATBASID=F.ID)) then 'İrsaliyeden'
			when (F.TUR=15)and(410 in (select YERI from FATURA where FATBASID=F.ID)) then 'Siparişten'
			when (F.TUR=15)and(411 in (select YERI from FATURA where FATBASID=F.ID)) then 'İrsaliyeden'
			when (F.TUR=11)and(461 in (select YERI from FATURA where FATBASID=F.ID)) then 'Konsinyeden'
			when (F.TUR=15)and(462 in (select YERI from FATURA where FATBASID=F.ID)) then 'Konsinyeden'
			when (F.TUR=15)and(426 in (select YERI from FATURA where FATBASID=F.ID)) then 'Üretimden'
			when (F.TUR=14)and(425 in (select YERI from FATURA where FATBASID=F.ID)) then 'Üretimden'
			else '' end,  
	HEDEF = case 
			when (F.TUR=10)and(408 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then 'Faturaya'
			when (F.TUR=14)and(411 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then 'Faturaya'
			when (F.TUR=109)and(461 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then 'Faturaya'
			when (F.TUR=119)and(462 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then 'Faturaya'
			else '' end
from FATBASLIK F where SERVISID=@ServisID
END
GO
