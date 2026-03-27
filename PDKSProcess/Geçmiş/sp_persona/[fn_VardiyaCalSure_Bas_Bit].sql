
/****** Object:  UserDefinedFunction [dbo].[fn_VardiyaCalSure_Bas_Bit]    Script Date: 10/18/2010 11:37:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--SELECT dbo.fn_VardiyaAdi_Bas_Bit ('123','2010-10-11 08:30:00' ,'2010-10-11 08:30:00') 
ALTER         function [dbo].[fn_VardiyaCalSure_Bas_Bit] ( @PERKOD VARCHAR(20),@GIRIS DATETIME, @CIKIS DATETIME )
returns varchar(1000)
as 
begin
	declare @VardiyaCikis varchar(20)
		IF (
		SELECT COUNT(*) FROM PERS_VARDIYA WHERE 
		PERKOD=@PERKOD
		AND  CONVERT(DATETIME,VARDIYA_BASTARIH,120) <=   CONVERT(DATETIME,@GIRIS,120)
		AND  CONVERT(DATETIME,VARDIYA_BITTARIH,120) >=   CONVERT(DATETIME,@GIRIS,120)
		AND  ISNULL(GUN,'')=(select dbo.fn_gunadi(@GIRIS))
		 ) = 0 
		 
	SELECT top 1 @VardiyaCikis = DAKIKA
	 FROM dbo.PERS_VARDIYA WHERE PERKOD=@PERKOD
    AND  CONVERT(DATETIME,VARDIYA_BASTARIH,120) <=   CONVERT(DATETIME,@GIRIS,120)
    AND  CONVERT(DATETIME,VARDIYA_BITTARIH,120) >=   CONVERT(DATETIME,@GIRIS,120)
    AND ISNULL(GUN,'')=''
 	order by 
	abs ( dbo.fn_Dakikatarihten( @GIRIS ) - dbo.fn_Dakika( BASSA )) +
	abs ( datediff( mi, @GIRIS, @CIKIS ) + dbo.fn_Dakikatarihten( @GIRIS ) - (dbo.fn_Dakika( BASSA )  + dbo.fn_Dakika( DAKIKA ) ) )
	
	ELSE
	
	SELECT top 1 @VardiyaCikis = DAKIKA
	 FROM dbo.PERS_VARDIYA WHERE PERKOD=@PERKOD
    AND  CONVERT(DATETIME,VARDIYA_BASTARIH,120) <=   CONVERT(DATETIME,@GIRIS,120)
    AND  CONVERT(DATETIME,VARDIYA_BITTARIH,120) >=   CONVERT(DATETIME,@GIRIS,120)
    AND GUN= (select dbo.fn_gunadi(@GIRIS))
 	order by 
	abs ( dbo.fn_Dakikatarihten( @GIRIS ) - dbo.fn_Dakika( BASSA )) +
	abs ( datediff( mi, @GIRIS, @CIKIS ) + dbo.fn_Dakikatarihten( @GIRIS ) - (dbo.fn_Dakika( BASSA )  + dbo.fn_Dakika( DAKIKA ) ) )
	
	return @VardiyaCikis
end










GO


