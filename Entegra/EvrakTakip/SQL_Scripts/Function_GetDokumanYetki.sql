ALTER FUNCTION [dbo].[fn_GetDokumanYetki]
( @Yetki_Tur AS char , -- "G"ör "E"kle "S"il "D"eğiştir
  @Dokuman_ID AS int ,
  @Rehber_ID AS int 
)
RETURNS int
AS
BEGIN
	-- routine body goes here, e.g.
	-- SELECT 'Navicat for SQL Server'
	declare @DefYetki bit = 0
	declare @SONUC int=0
	if @Rehber_ID<>0
	  BEGIN
    	select @DefYetki = R.TY from KULLANICI K left join ROLLER R on K.ROLID=R.ID
			      where K.REHBERID=@Rehber_ID
		END
	if @DefYetki=1
	 SET @SONUC= 1
  else
	  BEGIN
		 if @Yetki_Tur = 'G'
		  select @SONUC = GOR FROM DOKUMANYETKI WHERE YERID=@Dokuman_ID AND REHBERID=@Rehber_ID
		 else	
		 if @Yetki_Tur = 'E'
		  select @SONUC = EKLE FROM DOKUMANYETKI WHERE YERID=@Dokuman_ID AND REHBERID=@Rehber_ID
		 else	
		 if @Yetki_Tur = 'S'
		  select @SONUC =  SIL FROM DOKUMANYETKI WHERE YERID=@Dokuman_ID AND REHBERID=@Rehber_ID
		 else	
		 if @Yetki_Tur = 'D'
		  select @SONUC =  DEGISTIR FROM DOKUMANYETKI WHERE YERID=@Dokuman_ID AND REHBERID=@Rehber_ID
		 else	
		   SELECT @SONUC=0		  
		END
	
	RETURN @SONUC
END