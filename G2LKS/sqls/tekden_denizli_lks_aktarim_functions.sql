if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_DevKat]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_DevKat]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFCariKod]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFCariKod]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFIsk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFIsk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFIslemKdvKodu]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFIslemKdvKodu]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFIslemMuhKodu]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFIslemMuhKodu]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFIslemOzelKodu]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFIslemOzelKodu]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFKdv]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFKdv]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFLogoOzelKodu]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFLogoOzelKodu]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFToplam]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFToplam]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_G2L_SFTutar]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_G2L_SFTutar]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO







/*
-- select dbo.fn_G2L_DevKat('27827',31,1)

*/

CREATE        FUNCTION fn_G2L_DevKat(@dosyano  VARCHAR(10),@gelisno  SMALLINT,@kartno   SMALLINT)
returns varchar(10)
AS
BEGIN
DECLARe @kdvdurum VARCHAR(10),
	@kat	MONEY

select 
	@kdvdurum = KDVDURUM
from 
	FATBASLIK 
WHERE 
	@dosyano = DOSYANO AND
	@gelisno = GELISNO AND
	@kartno = KARTNO

	If @kdvdurum = 'Dahil'
	Begin
		SELECT
			@kat = ROUND(SUM((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*20)/100),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End
	Else
	Begin
		SELECT
			@kat = ROUND(SUM((TUTAR*20)/100),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End

	Return(convert(varchar(10),@kat))
END









GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




-- select dbo.fn_G2L_SFCariKod('619328')


CREATE        FUNCTION fn_G2L_SFCariKod(@dosyano VARCHAR(15),@gelisno INT, @kartno INT)
returns VARCHAR(20)
AS
BEGIN
DECLARe @kime VARCHAR(10),
	@carikod VARCHAR(30)

	

	SELECT 
		@carikod = REFERANSKOD
	FROM
		GELISLER
	WHERE
		DOSYANO = @dosyano AND
		GELISNO = @gelisno



	Return(@carikod)
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO






/*
-- select dbo.fn_G2L_SFIsk('55819',2,1)

*/

CREATE       FUNCTION fn_G2L_SFIsk(@dosyano  VARCHAR(10),@gelisno  SMALLINT,@kartno   SMALLINT)
returns varchar(10)
AS
BEGIN
DECLARe @kdvdurum VARCHAR(10),
	@kdv	MONEY

select 
	@kdvdurum = KDVDURUM
from 
	FATBASLIK 
WHERE 
	@dosyano = DOSYANO AND
	@gelisno = GELISNO AND
	@kartno = KARTNO

	If @kdvdurum = 'Dahil'
	Begin
		SELECT
			@kdv = ROUND(SUM((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End
	Else
	Begin
		SELECT
			@kdv = ROUND(SUM((TUTAR*KDV)/100),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End

	Return(convert(varchar(10),@kdv))
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO






-- select dbo.fn_G2L_SFIslemOzelKodu('A.01')

CREATE        FUNCTION fn_G2L_SFIslemKdvKodu(@kod varchar(15))
returns VARCHAR(20)
AS
BEGIN
DECLARe @kdvkodu VARCHAR(20)
	
	SELECT
		@kdvkodu = CASE KDV 
			WHEN 8 THEN '391.001.0001'
				ELSE '391.001.0002'
			END
	FROM
		ISLEMLER
	WHERE
		KOD = @kod


	Return(@kdvkodu)
END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




-- select dbo.fn_G2L_SFIslemMuhKodu('A.01')

CREATE      FUNCTION fn_G2L_SFIslemMuhKodu(@kod varchar(15))
returns VARCHAR(20)
AS
BEGIN
DECLARe @muhkodu VARCHAR(10)
	
	SELECT
		@muhkodu = MUHKODU
	FROM
		ISLEMLER
	WHERE
		KOD = @kod


	Return(@muhkodu)
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO






-- select dbo.fn_G2L_SFIslemMuhKodu('A.01')

CREATE        FUNCTION fn_G2L_SFIslemOzelKodu(@kod varchar(15))
returns VARCHAR(20)
AS
BEGIN
DECLARe @ozelkodu VARCHAR(20)
	
	SELECT
		@ozelkodu = OZELKOD
	FROM
		ISLEMLER
	WHERE
		KOD = @kod


	Return(@ozelkodu)
END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO





/*

 select dbo.fn_G2L_SFKdv('00015',3,1)
 select dbo.fn_G2L_SFKdv('00015',5,1)

-- select dbo.fn_G2L_SFKdv('55819',2,1)

*/

CREATE      FUNCTION fn_G2L_SFKdv(@dosyano  VARCHAR(10),@gelisno  SMALLINT,@kartno   SMALLINT)
returns varchar(10)
AS
BEGIN
DECLARe @kdvdurum VARCHAR(10),
	@kdv	MONEY

select 
	@kdvdurum = KDVDURUM
from 
	FATBASLIK 
WHERE 
	@dosyano = DOSYANO AND
	@gelisno = GELISNO AND
	@kartno = KARTNO

	If @kdvdurum = 'Dahil'
	Begin
		SELECT
			@kdv = ROUND(((SUM(TUTAR)*8)/108),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End
	Else
	Begin
		SELECT
			@kdv = ROUND(SUM((TUTAR*KDV)/100),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End

	Return(convert(varchar(10),@kdv))
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



-- select dbo.fn_G2L_SFLogo÷zelKodu()

CREATE     FUNCTION fn_G2L_SFLogoOzelKodu()
returns VARCHAR(20)
AS
BEGIN
DECLARe @ozelkod VARCHAR(10)
	
	SELECT
		@ozelkod = DEGER
	FROM
		GENOTIPINI
	WHERE
		BOLUM = 'MuhasebeLogo' AND
		ANAHTAR = 'Logo÷zelKodu'


	Return(@ozelkod)
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO






-- select dbo.fn_G2L_SFToplam('55819',4,1)

CREATE       FUNCTION fn_G2L_SFToplam(@dosyano VARCHAR(15),@gelisno int, @kartno INT)
returns varchar(10)
AS
BEGIN
DECLARe @kdvdurum VARCHAR(10),
	@tutar	MONEY


select 
	@kdvdurum = KDVDURUM
from 
	FATBASLIK 
WHERE 
	@dosyano = DOSYANO AND
	@gelisno = GELISNO AND
	@kartno = KARTNO

	If @kdvdurum = 'Dahil'
	Begin
		SELECT
			@tutar = ROUND(SUM(TUTAR),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno	
	End
	Else
	Begin
		SELECT
			@tutar = ROUND(SUM(TUTAR+((TUTAR*KDV)/100)),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End
	


	Return(convert(varchar(10),@tutar))
END








GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO





-- select dbo.fn_G2L_SFTutar'55819','2','2'

CREATE      FUNCTION fn_G2L_SFTutar(@dosyano VARCHAR(15),@gelisno INT,@kartno INT)
returns varchar(10)
AS
BEGIN
DECLARe @kdvdurum VARCHAR(10),
	@tutar	MONEY

select 
	@kdvdurum = KDVDURUM
from 
	FATBASLIK 
WHERE 
	@dosyano = DOSYANO AND
	@gelisno = GELISNO AND
	@kartno = KARTNO

	If @kdvdurum = 'Dahil'
	Begin
		SELECT
			@tutar = ROUND((SUM(TUTAR)-((SUM(TUTAR)*8)/108)+SUM((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100)),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End
	Else
	Begin
		SELECT
			@tutar = ROUND(SUM(TUTAR),2)
		FROM
			FATURA
		WHERE
			DOSYANO = @dosyano AND
			GELISNO = @gelisno AND
			KARTNO = @kartno		
	End

	Return(convert(varchar(10),@tutar))
END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

