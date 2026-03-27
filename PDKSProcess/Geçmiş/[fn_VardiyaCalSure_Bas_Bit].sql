USE [UNIMEDPERSONA]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_VardiyaCalSure_Bas_Bit]    Script Date: 09/25/2010 13:54:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER         function [dbo].[fn_VardiyaCalSure_Bas_Bit] ( @PERKOD VARCHAR(20),@GIRIS DATETIME, @CIKIS DATETIME )
returns varchar(1000)
as 
begin
	declare @VardiyaCikis varchar(20)
	SELECT top 1 @VardiyaCikis = DAKIKA
  FROM dbo.PERS_VARDIYA WHERE PERKOD=@PERKOD
    AND  CONVERT(DATETIME,VARDIYA_BASTARIH,120) <= 
  CONVERT(DATETIME,GETDATE(),120)
  AND
  CONVERT(DATETIME,VARDIYA_BITTARIH,120) >= 
  CONVERT(DATETIME,GETDATE(),120)
 	order by 
abs ( dbo.fn_Dakikatarihten( @GIRIS ) - dbo.fn_Dakika( BASSA )) +
abs ( datediff( mi, @GIRIS, @CIKIS ) + dbo.fn_Dakikatarihten( @GIRIS ) - (dbo.fn_Dakika( BASSA )  + dbo.fn_Dakika( DAKIKA ) ) )
	return @VardiyaCikis
end





GO


