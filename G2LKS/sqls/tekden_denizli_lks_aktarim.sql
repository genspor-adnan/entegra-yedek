if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2LKS_FaturalariListele]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2LKS_FaturalariListele]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SFKalemler]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SFKalemler]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SFKalemler_12092006]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SFKalemler_12092006]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SFKalemler_ISK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SFKalemler_ISK]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SFKalemler_OKAN]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SFKalemler_OKAN]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SFKalemler_ORJ]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SFKalemler_ORJ]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SatFat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SatFat]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SatFatAna]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SatFatAna]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SatFatAna_eskiORJ]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SatFatAna_eskiORJ]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SatFatBas]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SatFatBas]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[p_G2L_SatFatSon]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[p_G2L_SatFatSon]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO




/*
2007-06-07 17:30 DEÐÝÞTÝRME
-- Rehberdeki anakuruma göre filtreleme eklendi.
-- Kullanýcýya göre filtreleme eklendi
---------------------------
2006-11-17 15:00 OLUÞTURMA 
EMRE BAYTAR
Verilen tarih aralýðýnda kesilmiþ faturalarý listeler
p_G2LKS_FaturalariListele '','','','','2005-01-01','2007-12-05',0,0,0,999999,'False'
BELGETURU = 0: Hepsi, 1: Fatura , 2: Fiþ
*/
CREATE        PROC p_G2LKS_FaturalariListele 
	@KURUM VARCHAR(100),
	@REFERANS VARCHAR(100),
	@ANAKURUM VARCHAR(100),
	@KULLANICI VARCHAR(40),
	@BASLA SMALLDATETIME,
	@BITIS SMALLDATETIME,
	@BELGETURU SMALLINT,
	@AKTARILMIS INT ,
	@ILKFATNO INT,
	@SONFATNO INT,
	@TUMUSECILI VARCHAR(5)
AS 
BEGIN
DECLARE @BELGE VARCHAR(10)
SELECT @BELGE= CASE WHEN @BELGETURU = 0 THEN '%'
	            WHEN @BELGETURU = 1 THEN 'Fatura'
                    WHEN @BELGETURU = 2 THEN 'Fiþ'
	ELSE '%'
	END


	  SET @KURUM=@KURUM+'%'
	  SET @REFERANS=@REFERANS+'%'
	  SET @KULLANICI = @KULLANICI+'%'
	  SET @ANAKURUM = @ANAKURUM+'%'

	PRINT('KURUM:'+@KURUM)
	PRINT('REF:'+@KURUM)
	PRINT('KULL:'+@KURUM)
	PRINT('ANAKURM:'+@KURUM)
	PRINT('BELGE:'+@KURUM)

	IF @ILKFATNO = 0 SET @ILKFATNO = 0
	IF @SONFATNO = 0 SET @SONFATNO = 99999999

	
	SELECT
		SEC=@TUMUSECILI,
		K.DOSYANO,
		ADSOYAD = K.AD+' '+K.SOYAD ,
	        FB.GELISNO,
		G.KURUM,
		FB.FATURANO, 
		FB.FATURATARIH,
		FB.KARTNO,
		FATURA_TUTARI= ROUND(FB.FATURA_TUTARI,2),
		FB.LOTNO,
	        FB.KIME,
		MUHASEBEKODU = CASE WHEN FB.KIME = 'Katký' THEN '120.999' 
				    WHEN G.KURUM = 'MEMUR' THEN G.REFERANSKOD
			ELSE KR.MUHASEBEKODU
			END,
		MUHAKTAR = ISNULL(MUHAKTAR,0) ,
		G.REFERANS,
		AKTARMANOTU,
		AKTARMATARIHI,
		BELGE, 
		KULLANICIADI = ISNULL(KL.KULLANICIADI,''),
		ANAKURUM = ISNULL(R.ANAFIRMA,''),
-----------------------------------------------------------------------------------------
-- TOPLAM FATURA TUTARI
		TOPLAMFATURA = 
			(
			  SELECT SUM(FATURA_TUTARI) FROM 
						FATBASLIK FB INNER JOIN GELISLER G ON 
					FB.DOSYANO = G.DOSYANO AND
					FB.GELISNO = G.GELISNO
			     INNER JOIN KIMLIK K ON
					G.DOSYANO = K.DOSYANO
			     INNER JOIN KURUM KR ON 
					G.KURUM = KR.KURUM
	WHERE
		KIME NOT IN ('Sanal','Ýptal') AND
		ISNULL(G.KURUM,'') LIKE @KURUM AND
		ISNULL(G.REFERANS,'') LIKE @REFERANS AND
		FB.FATURATARIH BETWEEN @BASLA AND @BITIS AND
		ISNULL(MUHAKTAR,0) <= @AKTARILMIS AND
		ISNULL(BELGE,'') LIKE @BELGE AND
		CONVERT(INT,REPLACE(ISNULL(FB.FATURANO,'0'),'-','')) >= @ILKFATNO AND
		CONVERT(INT,REPLACE(ISNULL(FB.FATURANO,'0'),'-','')) <= @SONFATNO AND
		ISNULL(KL.KULLANICIADI,'') LIKE @KULLANICI AND
		ISNULL(R.ANAFIRMA,'') LIKE @ANAKURUM

			)
-- TOPLAM FATURA TUTARI
-------------------------------------------------------------------------------------------			    
	INTO #FaturalarTemp
	FROM
		FATBASLIK FB INNER JOIN GELISLER G ON 
					FB.DOSYANO = G.DOSYANO AND
					FB.GELISNO = G.GELISNO
			     INNER JOIN KIMLIK K ON
					G.DOSYANO = K.DOSYANO
			     INNER JOIN KURUM KR ON 
					G.KURUM = KR.KURUM
			     LEFT OUTER JOIN REHBER R ON
					G.REFERANSKOD = R.KOD
			     LEFT OUTER JOIN KULLAN KL ON
					KL.KULLANICI = FB.KULLANICI
	WHERE
		    ISNULL(KIME,'') NOT IN ('Sanal','Ýptal') 
		AND ISNULL(G.KURUM,'') LIKE @KURUM 
		AND ISNULL(G.REFERANS,'') LIKE @REFERANS 
		AND FB.FATURATARIH BETWEEN @BASLA AND @BITIS 
		AND ISNULL(MUHAKTAR,0) <= @AKTARILMIS 
		AND ISNULL(BELGE,'') LIKE @BELGE 
		AND CONVERT(INT,REPLACE(ISNULL(FB.FATURANO,'0'),'-','')) >= @ILKFATNO 
		AND CONVERT(INT,REPLACE(ISNULL(FB.FATURANO,'0'),'-','')) <= @SONFATNO 
		AND ISNULL(KL.KULLANICIADI,'') LIKE @KULLANICI 
		AND ISNULL(R.ANAFIRMA,'') LIKE @ANAKURUM

	ORDER BY FB.FATURANO
	
	  SELECT * FROM #FaturalarTemp
	
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

Verilen Fatura numarasýndaki kalemleri alýyoruz.

21 Aralýk 2005 Okan ÜNAL

p_G2L_SFKalemler '619328','C:\GEN2000\Fatura\TEKDEN_22.12.2005_faturalar.xml'

p_G2L_SFKalemler '55819','3','1',''



*/

CREATE                  PROC p_G2L_SFKalemler
@dosyano	VARCHAR(15),
@gelisno	INT,
@kartno		INT,
@filename	VARCHAR(200)

-- WITH ENCRYPTION
AS
BEGIN
DECLARE @sirano  SMALLINT,
	@kime 	VARCHAR(100),
	@trans	VARCHAR(8000)

DECLARE		@FS 		int,
		@OLEResult 	int,
		@FileID 	int
set @trans = ''
set @trans = '<TRANSACTIONS>'

-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------

DECLARE kalemler CURSOR FOR 
SELECT 
	SIRANO
FROM 
	FATURA
WHERE
	DOSYANO = @dosyano AND
	GELISNO = @gelisno AND
	KARTNO = @kartno
open kalemler
FETCH NEXT FROM kalemler INTO @sirano
WHILE @@FETCH_STATUS = 0
BEGIN

	select  
		@trans=	
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),BIRIMFIYAT*ADET)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <COST_DISTR>'+convert(varchar(10),((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100))+'</COST_DISTR> 
		  <DISCOUNT_DISTR>'+convert(varchar(10),((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100))+'</DISCOUNT_DISTR> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>0</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(varchar(10),((TUTAR*KDV)/(100+KDV)))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),(TUTAR-((TUTAR*KDV)/(100+KDV))))+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),(TUTAR-((TUTAR*KDV)/(100+KDV))))+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>
 <TRANSACTION>
	  <TYPE>2</TYPE> 
	  <MASTER_CODE /> 
	  <QUANTITY>0</QUANTITY> 
	  <TOTAL>'+convert(varchar(10),((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100))+'</TOTAL> 
	  <RC_XRATE>1</RC_XRATE> 
	  <DISCOUNT_RATE>'+CONVERT(varchar(10),ISKONTO)+'</DISCOUNT_RATE> 
	  <UNIT_CODE /> 
	  <UNIT_CONV1>0</UNIT_CONV1> 
	  <UNIT_CONV2>0</UNIT_CONV2> 
	  <BILLED>1</BILLED> 
	  <GENIUSFLDSLIST /> 
  </TRANSACTION>'		

from 
		FATURA 
	WHERE
		DOSYANO = @dosyano AND
		GELISNO = @gelisno AND
		KARTNO = @kartno AND
		SIRANO = @sirano
-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------
FETCH NEXT FROM kalemler INTO @sirano
END
close kalemler
deallocate kalemler


/*
-- 22.03.2007 Perþembe Günü Tamer Bey'in bilgisi ve talebiyle Kapatýlmýþtýr...
-- Devlet MEmurlarnýn %20 payý kalktýðý için.
-- %20 Devlet in ödediði Katký Payý Ekleniyor
IF EXISTS(
	select 
		KIME 
	FROM 
		FATBASLIK 
	WHERE
		DOSYANO = @dosyano AND
		GELISNO = @gelisno AND
		KARTNO = @kartno AND
		KIME IN ('EMEKLÝ SANDIÐI (DÝÐER)','EMEKLÝ SANDIÐI (KENDÝ)','KAMU')
	)
BEGIN

	select  
		@trans=	
		' <TRANSACTION>
		  <TYPE>3</TYPE> 
		  <MASTER_CODE>AAA</MASTER_CODE> 
		  <DETAIL_LEVEL>1</DETAIL_LEVEL> 
		  <DISCEXP_CALC>2</DISCEXP_CALC> 
		  <GL_CODE1>600.1.08.098</GL_CODE1> 
		  <GL_CODE2>391.001.0001</GL_CODE2> 
		  <QUANTITY>0</QUANTITY> 
		  <TOTAL>'+dbo.fn_G2L_DevKat(@dosyano,@gelisno, @kartno)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <DISCOUNT_RATE>19.996737</DISCOUNT_RATE> 
		  <UNIT_CODE /> 
		  <UNIT_CONV1>0</UNIT_CONV1> 
		  <UNIT_CONV2>0</UNIT_CONV2> 
		  <VAT_RATE>8</VAT_RATE> 
		  <VAT_AMOUNT>0.36</VAT_AMOUNT> 
		  <VAT_BASE>'+dbo.fn_G2L_DevKat(@dosyano,@gelisno, @kartno)+'</VAT_BASE> 
		  <TOTAL_NET>'+dbo.fn_G2L_DevKat(@dosyano,@gelisno, @kartno)+'</TOTAL_NET> 
		  <DATA_REFERENCE>96721</DATA_REFERENCE> 
		  </TRANSACTION>'

	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS

END
-- %20 Devlet in ödediði Katký Payý Ekleniyor
*/

SET @trans = '
			</TRANSACTIONS>'
print(@trans)
EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS


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

Verilen Fatura numarasýndaki kalemleri alýyoruz.

21 Aralýk 2005 Okan ÜNAL

p_G2L_SFKalemler '619328','C:\GEN2000\Fatura\TEKDEN_22.12.2005_faturalar.xml'

p_G2L_SFKalemler '55819','3','1',''


--------------------------------------------------------

%20 Paylý hale geçmeden önceki çalýþan halidir.

*/

create               PROC p_G2L_SFKalemler_12092006
@dosyano	VARCHAR(15),
@gelisno	INT,
@kartno		INT,
@filename	VARCHAR(200)

-- WITH ENCRYPTION
AS
BEGIN
DECLARE @sirano  SMALLINT,
	@trans	VARCHAR(8000)

DECLARE		@FS 		int,
		@OLEResult 	int,
		@FileID 	int
set @trans = ''
set @trans = '<TRANSACTIONS>'

-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------

DECLARE kalemler CURSOR FOR 
SELECT 
	SIRANO
FROM 
	FATURA
WHERE
	DOSYANO = @dosyano AND
	GELISNO = @gelisno AND
	KARTNO = @kartno
open kalemler
FETCH NEXT FROM kalemler INTO @sirano
WHILE @@FETCH_STATUS = 0
BEGIN

	select  
		@trans=	
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),BIRIMFIYAT*ADET)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <COST_DISTR>'+convert(varchar(10),((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100))+'</COST_DISTR> 
		  <DISCOUNT_DISTR>'+convert(varchar(10),((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100))+'</DISCOUNT_DISTR> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(varchar(10),((TUTAR*KDV)/(100+KDV)))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),(TUTAR-((TUTAR*KDV)/(100+KDV))))+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),(TUTAR-((TUTAR*KDV)/(100+KDV))))+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>
 <TRANSACTION>
	  <TYPE>2</TYPE> 
	  <MASTER_CODE /> 
	  <QUANTITY>0</QUANTITY> 
	  <TOTAL>'+convert(varchar(10),((((((BIRIMFIYAT/(100+KDV))*100)*ADET))*ISKONTO)/100))+'</TOTAL> 
	  <RC_XRATE>1</RC_XRATE> 
	  <DISCOUNT_RATE>'+CONVERT(varchar(10),ISKONTO)+'</DISCOUNT_RATE> 
	  <UNIT_CODE /> 
	  <UNIT_CONV1>0</UNIT_CONV1> 
	  <UNIT_CONV2>0</UNIT_CONV2> 
	  <BILLED>1</BILLED> 
	  <GENIUSFLDSLIST /> 
  </TRANSACTION>'		

from 
		FATURA 
	WHERE
		DOSYANO = @dosyano AND
		GELISNO = @gelisno AND
		KARTNO = @kartno AND
		SIRANO = @sirano
-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------
FETCH NEXT FROM kalemler INTO @sirano
END
close kalemler
deallocate kalemler

SET @trans = '
			</TRANSACTIONS>'
print(@trans)
EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS


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

Verilen Fatura numarasýndaki kalemleri alýyoruz.

21 Aralýk 2005 Okan ÜNAL

p_G2L_SFKalemler '619328','C:\GEN2000\Fatura\TEKDEN_22.12.2005_faturalar.xml'

p_G2L_SFKalemler '55819','3','1',''

*/

CREATE              PROC p_G2L_SFKalemler_ISK
@dosyano	VARCHAR(15),
@gelisno	INT,
@kartno		INT,
@filename	VARCHAR(200)

-- WITH ENCRYPTION
AS
BEGIN
DECLARE @sirano  SMALLINT,
	@trans	VARCHAR(8000)

DECLARE		@FS 		int,
		@OLEResult 	int,
		@FileID 	int
set @trans = ''
set @trans = '<TRANSACTIONS>'

-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------

DECLARE kalemler CURSOR FOR 
SELECT 
	SIRANO
FROM 
	FATURA
WHERE
	DOSYANO = @dosyano AND
	GELISNO = @gelisno AND
	KARTNO = @kartno
open kalemler
FETCH NEXT FROM kalemler INTO @sirano
WHILE @@FETCH_STATUS = 0
BEGIN

	select  
/*
		@trans=	
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(BIRIMFIYAT*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>'		
*/
	@trans=	CASE KDV 
		WHEN 0.0 THEN 
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(TUTAR*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),TUTAR)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>'	
	ELSE
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(TUTAR*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),TUTAR)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>
 <TRANSACTION>
  <TYPE>2</TYPE> 
  <MASTER_CODE /> 
  <QUANTITY>0</QUANTITY> 
  <TOTAL>'+CONVERT(VARCHAR(10),((BIRIMFIYAT*ADET)-(((BIRIMFIYAT*ADET)*ISKONTO)/100)))+'</TOTAL> 
  <RC_XRATE>1</RC_XRATE> 
  <DISCOUNT_RATE>'+CONVERT(VARCHAR(10),ISKONTO)+'</DISCOUNT_RATE> 
  <UNIT_CODE /> 
  <UNIT_CONV1>0</UNIT_CONV1> 
  <UNIT_CONV2>0</UNIT_CONV2> 
  <BILLED>1</BILLED> 
  <GENIUSFLDSLIST /> 
  </TRANSACTION>'

	END	



from 
		FATURA 
	WHERE
		DOSYANO = @dosyano AND
		GELISNO = @gelisno AND
		KARTNO = @kartno AND
		SIRANO = @sirano
-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
		
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------
FETCH NEXT FROM kalemler INTO @sirano
END
close kalemler
deallocate kalemler

SET @trans = '
			</TRANSACTIONS>'
print(@trans)
EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS


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

Verilen Fatura numarasýndaki kalemleri alýyoruz.

21 Aralýk 2005 Okan ÜNAL

p_G2L_SFKalemler '619328','C:\GEN2000\Fatura\TEKDEN_22.12.2005_faturalar.xml'

p_G2L_SFKalemler '55819','3','1',''

*/

CREATE              PROC p_G2L_SFKalemler_OKAN
@dosyano	VARCHAR(15),
@gelisno	INT,
@kartno		INT,
@filename	VARCHAR(200)

-- WITH ENCRYPTION
AS
BEGIN
DECLARE @sirano  SMALLINT,
	@trans	VARCHAR(8000)

DECLARE		@FS 		int,
		@OLEResult 	int,
		@FileID 	int
set @trans = ''
set @trans = '<TRANSACTIONS>'

-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------

DECLARE kalemler CURSOR FOR 
SELECT 
	SIRANO
FROM 
	FATURA
WHERE
	DOSYANO = @dosyano AND
	GELISNO = @gelisno AND
	KARTNO = @kartno
open kalemler
FETCH NEXT FROM kalemler INTO @sirano
WHILE @@FETCH_STATUS = 0
BEGIN

	select  
/*
		@trans=	
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(BIRIMFIYAT*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>'		
*/
	@trans=	CASE ISKONTO 
		WHEN 0.0 THEN 
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(TUTAR*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),TUTAR)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>'	
	ELSE
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(TUTAR*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),TUTAR)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>
 <TRANSACTION>
  <TYPE>2</TYPE> 
  <MASTER_CODE /> 
  <QUANTITY>0</QUANTITY> 
  <TOTAL>'+convert(varchar(10),(BIRIMFIYAT*ADET)-(((BIRIMFIYAT*ADET)*ISKONTO)/100))+'</TOTAL> 
  <RC_XRATE>1</RC_XRATE> 
  <DISCOUNT_RATE>'+CONVERT(VARCHAR(10),ISKONTO)+'</DISCOUNT_RATE> 
  <UNIT_CODE /> 
  <UNIT_CONV1>0</UNIT_CONV1> 
  <UNIT_CONV2>0</UNIT_CONV2> 
  <BILLED>1</BILLED> 
  <GENIUSFLDSLIST /> 
  </TRANSACTION>'

	END	



from 
		FATURA 
	WHERE
		DOSYANO = @dosyano AND
		GELISNO = @gelisno AND
		KARTNO = @kartno AND
		SIRANO = @sirano
-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
		
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------
FETCH NEXT FROM kalemler INTO @sirano
END
close kalemler
deallocate kalemler

SET @trans = '
			</TRANSACTIONS>'
print(@trans)
EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS


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

Verilen Fatura numarasýndaki kalemleri alýyoruz.

21 Aralýk 2005 Okan ÜNAL

p_G2L_SFKalemler '619328','C:\GEN2000\Fatura\TEKDEN_22.12.2005_faturalar.xml'

p_G2L_SFKalemler '55819','3','1',''


çalýþýyordu iskonto olaylarýna girmeden önceki hali...
*/

CREATE              PROC p_G2L_SFKalemler_ORJ
@dosyano	VARCHAR(15),
@gelisno	INT,
@kartno		INT,
@filename	VARCHAR(200)

-- WITH ENCRYPTION
AS
BEGIN
DECLARE @sirano  SMALLINT,
	@trans	VARCHAR(8000)

DECLARE		@FS 		int,
		@OLEResult 	int,
		@FileID 	int
set @trans = ''
set @trans = '<TRANSACTIONS>'

-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
	
	
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------

DECLARE kalemler CURSOR FOR 
SELECT 
	SIRANO
FROM 
	FATURA
WHERE
	DOSYANO = @dosyano AND
	GELISNO = @gelisno AND
	KARTNO = @kartno
open kalemler
FETCH NEXT FROM kalemler INTO @sirano
WHILE @@FETCH_STATUS = 0
BEGIN

	select  
/*
		@trans=	
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(BIRIMFIYAT*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),BIRIMFIYAT)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>'		
*/

		@trans=	
		'
		<TRANSACTION>
		  <TYPE>0</TYPE> 
		  <MASTER_CODE>'+DBO.fn_G2L_SFIslemMuhKodu(KOD)+'</MASTER_CODE> 
		  <GL_CODE1>'+DBO.fn_G2L_SFIslemOzelKodu(KOD)+'</GL_CODE1> 
		  <GL_CODE2>'+DBO.fn_G2L_SFIslemKDVKodu(KOD)+'</GL_CODE2> 
		  <QUANTITY>'+CONVERT(VARCHAR(10),ADET)+'</QUANTITY> 
		  <PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</PRICE> 
		  <TOTAL>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL> 
		  <RC_XRATE>1</RC_XRATE> 
		  <UNIT_CODE>ADET</UNIT_CODE> 
		  <UNIT_CONV1>1</UNIT_CONV1> 
		  <UNIT_CONV2>1</UNIT_CONV2> 
		  <VAT_INCLUDED>1</VAT_INCLUDED> 
		  <VAT_RATE>'+convert(varchar(5),KDV)+'</VAT_RATE> 
		  <VAT_AMOUNT>'+convert(VARCHAR(10),(TUTAR*KDV)/(100+KDV))+'</VAT_AMOUNT> 
		  <VAT_BASE>'+CONVERT(VARCHAR(10),TUTAR)+'</VAT_BASE> 
		  <BILLED>1</BILLED> 
		  <TOTAL_NET>'+CONVERT(VARCHAR(10),TUTAR)+'</TOTAL_NET> 
		  <DETAILS /> 
		  <EDT_CURR>160</EDT_CURR> 
		  <EDT_PRICE>'+CONVERT(VARCHAR(10),TUTAR)+'</EDT_PRICE> 
		  <GENIUSFLDSLIST />
</TRANSACTION>'		


from 
		FATURA 
	WHERE
		DOSYANO = @dosyano AND
		GELISNO = @gelisno AND
		KARTNO = @kartno AND
		SIRANO = @sirano
-------------------------------------------------------------------------------------------
-- Dosyay yadýr kalemi
	EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
	IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
	--Dosyayý Aç
	EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
	IF @OLEResult <> 0 PRINT 'OpenTextFile'
		
	EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
	IF @OLEResult <> 0 PRINT 'WriteLine'
	
	EXECUTE @OLEResult = sp_OADestroy @FileID
	EXECUTE @OLEResult = sp_OADestroy @FS
---------------------------------------------------------------------------------------------
FETCH NEXT FROM kalemler INTO @sirano
END
close kalemler
deallocate kalemler

SET @trans = '
			</TRANSACTIONS>'
print(@trans)
EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @trans
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS


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




-- p_G2L_SatFat '00015,3,1#00015,2,1#'

CREATE     PROC p_G2L_SatFat
@Sonuclar	VARCHAR(8000)

--WITH ENCRYPTION
AS
BEGIN

DECLARE		@FileName 	VARCHAR(200),
		@FS 		int,
		@OLEResult 	int,
		@FileID 	int,
		@fat		VARCHAR(2000),
		@faturano 	VARCHAR(10)

---------------------------------------------------------------------------------------------------------
-- parçalama ile ilgili tanýmlar

declare @Pos int ,
	@ek int, 
	@Bas int,
	@kont int , 
	@Son int,
	@Ara int,
	@parca varchar(20),
	@AraPos int ,
	@AraBas int

declare @dosyano varchar(10),
	@gelisno varchar(10),
	@kartno varchar(10)

-- parçalama ile ilgili tanýmlar bitiþi.	
--------------------------------------------------------------------------------------------------------

-- yeni bi dosya aç ve içine dosya baþlangýcýný basýnýz.

select @FileName = 'C:\GEN2000\fatura\TEKDEN-' +replace(convert(varchar(20),getdate(),120),':','-')+'-faturalar.xml'

print(@FileName)

SET @fat = '  <?xml version="1.0" encoding="ISO-8859-9" ?> 
 <SALES_INVOICES>'

EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @fat
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS

-------------------------------------------------------------------------------------------


	 set @Pos = 1 
	 set @Bas = 1
	 set @Son = 0
	 set @Kont = 0		



	while @Pos <> 0  and @Pos < len(@Sonuclar)
   	begin 
		set @kont = 1
		set @AraPos = 1
		set @AraBas = 1
		set @Ara = 1

		set @Pos=@Pos  + 1
	
		select @Pos  = charindex ( '#', @Sonuclar , @Pos  + 1 ) 
		
		set @parca = substring(@Sonuclar,@Bas,@Pos-@Bas)

		set @Bas = @Pos+1

		while @kont <= 3 -- (@AraPos % 3)= 0  and @AraPos < len(@parca)
		begin
			set @parca = @parca + ','
--			print(@parca)
			set @AraPos=@AraPos  + 1
			
			select @AraPos  = charindex ( ',', @parca , @AraPos  + 1 ) 
--			print('Arapos - '+convert(varchar(2),@AraPos))
--			print('Kont -'+convert(varchar(2),@kont))

			If @kont = 1
				set @dosyano = substring(@parca,@AraBas,@AraPos-@AraBas)
			Else If @kont = 2
				set @gelisno = substring(@parca,@AraBas,@AraPos-@AraBas)
			Else If @kont = 3
				set @kartno = substring(@parca,@AraBas,@AraPos-@AraBas)

			set @AraBas = @AraPos+1		
			set @kont = @kont + 1		
		end 

		print('Dosyano - '+@dosyano+', Geliþno - '+@gelisno+', Kartno - '+@kartno)

		-- bu kýsýmda fatura bilgileri için scriptler çalýþacak
		
		EXEC p_G2L_SatFatAna @dosyano,@gelisno,@kartno, @filename
		
		
		-- bu kýsýmda fatura bilgileri için scriptler çalýþacak
		set @parca = ''

	end


-------------------------------------------------------------------------------------------


SET @fat = '</SALES_INVOICES>'

EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @fat
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS



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







--   <GL_POSTED>1</GL_POSTED> -- muhasebeleþmiþ gibi gösteriyor.

--	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</GL_CODE> 
--	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,@kartno)+'</GL_CODE> 
-- 	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</GL_CODE> 
-- 	  <POST_FLAGS>247</POST_FLAGS> 
-- p_G2L_SatFatAna '55819','C:\GEN2000\Fatura\TEKDEN_22.12.2005_faturalar.xml'
-- 

CREATE                  PROc p_G2L_SatFatAna
@dosyano	VARCHAR(15),
@gelisno	INT,
@kartno		INT,
@filename	VARCHAR(200)
-- WIRH ENCRYPTION
AS
BEGIN
DECLARE	@SQL VARCHAR(8000),
	@payment VARCHAR(8000)

DECLARE		@FS 		int,
		@OLEResult int,
		@FileID 	int,
		@tutar	varchar(10),
		@isk	varchar(10),
		@isktut money

select @tutar = dbo.fn_G2L_SFTutar(@dosyano,@gelisno,@kartno)
select @isk = dbo.fn_G2L_SFIsk(@dosyano,@gelisno,@kartno)
select @isktut = convert(money,@tutar) - convert(money,@isk)

SELECT
--------------------------------------------------------------------------------------------------
@SQL = ' <INVOICE DBOP="INS">
  <TYPE>8</TYPE> 
  <DATE>'+convert(VARCHAR(10),FATURATARIH,103)+'</DATE> 
  <DOC_NUMBER>'+FATURANO+'</DOC_NUMBER> 
  <AUXIL_CODE>'+dbo.fn_G2L_SFLogoOzelKodu()+'</AUXIL_CODE> 
  <ARP_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</ARP_CODE> 
  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</GL_CODE> 
  <POST_FLAGS>244</POST_FLAGS> 
  <VAT_RATE>8</VAT_RATE> 
  <TOTAL_DISCOUNTS>'+convert(varchar(10),dbo.fn_G2L_SFIsk(@dosyano,@gelisno,@kartno))+'</TOTAL_DISCOUNTS>
  <TOTAL_DISCOUNTED>'+convert(varchar(10),@isktut)+'</TOTAL_DISCOUNTED> 
  <TOTAL_VAT>'+convert(varchar(10),dbo.fn_G2L_SFKdv(@dosyano,@gelisno,@kartno))+'</TOTAL_VAT> 
  <TOTAL_GROSS>'+convert(varchar(10),dbo.fn_G2L_SFTutar(@dosyano,@gelisno,@kartno))+'</TOTAL_GROSS> 
  <TOTAL_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TOTAL_NET> 
  <TC_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TC_NET> 
  <NOTES1>'+ISNULL(AD,'')+' '+ISNULL(SOYAD,'')+'</NOTES1> 
  <NOTES2>'+ISNULL(SICILNO,'')+'</NOTES2> 
  <NOTES3>'+ISNULL(KARNENO,'')+'</NOTES3> 
  <RC_XRATE>1</RC_XRATE> 
  <RC_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</RC_NET> 
  <VAT_INCLUDED_GRS>0</VAT_INCLUDED_GRS> 
  <DISPATCHES>
  <DISPATCH>
  <TYPE>7</TYPE> 
  <DATE>'+convert(VARCHAR(10),FATURATARIH,103)+'</DATE> 
  <DOC_NUMBER>'+FATURANO+'</DOC_NUMBER> 
  <AUXIL_CODE>'+dbo.fn_G2L_SFLogoOzelKodu()+'</AUXIL_CODE> 
  <ARP_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</ARP_CODE> 
  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</GL_CODE> 
  <INVOICED>1</INVOICED> 
  <TOTAL_DISCOUNTS>'+convert(varchar(10),dbo.fn_G2L_SFIsk(@dosyano,@gelisno,@kartno))+'</TOTAL_DISCOUNTS>
  <TOTAL_DISCOUNTED>'+convert(varchar(10),@isktut)+'</TOTAL_DISCOUNTED> 
  <TOTAL_VAT>'+convert(varchar(10),dbo.fn_G2L_SFKdv(@dosyano,@gelisno,@kartno))+'</TOTAL_VAT> 
  <TOTAL_GROSS>'+convert(varchar(10),dbo.fn_G2L_SFTutar(@dosyano,@gelisno,@kartno))+'</TOTAL_GROSS> 
  <TOTAL_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TOTAL_NET> 
  <RC_RATE>1</RC_RATE> 
  <RC_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</RC_NET> 
  </DISPATCH>
  </DISPATCHES>',



--------------------------------------------------------------------------------------------------
	@payment = 
		'<PAYMENT_LIST>
		 <PAYMENT>
		  <DATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</DATE> 
		  <MODULENR>4</MODULENR> 
		  <TRCODE>7</TRCODE> 
		  <TOTAL>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TOTAL> 
		  <PROCDATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</PROCDATE> 
		  <REPORTRATE>1</REPORTRATE> 
		  <DISCOUNT_DUEDATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</DISCOUNT_DUEDATE> 
		  <PAY_NO>1</PAY_NO> 
		  <DISCTRLIST /> 
		  <DISCTRDELLIST>0</DISCTRDELLIST> 		  </PAYMENT>
		  </PAYMENT_LIST>'

FROM	
	FATBASLIK FB
	INNER JOIN KIMLIK K
		ON K.DOSYANO = FB.DOSYANO
WHERE
	FB.DOSYANO = @dosyano AND
	GELISNO = @gelisno AND
	KARTNO = @kartno

print(@SQL)
print(@payment)


EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @filename, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @SQL
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS

-- bu kýsýmda fatura Transectionlarý için script çalýþacak

EXEC p_G2L_SFKalemler @dosyano,@gelisno,@kartno,@filename


-- bu kýsýmda fatura Transectionlarý için script çalýþacak


EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @payment
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, '  </INVOICE>'
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS
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

--	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</GL_CODE> 
--	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,@kartno)+'</GL_CODE> 
-- 	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</GL_CODE> 
-- 	  <POST_FLAGS>247</POST_FLAGS> 
-- p_G2L_SatFatAna '619328','C:\GEN2000\Fatura\TEKDEN_22.12.2005_faturalar.xml'

CREATE           PROc p_G2L_SatFatAna_eskiORJ
@dosyano	VARCHAR(15),
@gelisno	INT,
@kartno		INT,
@filename	VARCHAR(200)
-- WIRH ENCRYPTION
AS
BEGIN
DECLARE	@SQL VARCHAR(8000),
	@payment VARCHAR(8000)

DECLARE		@FS 		int,
		@OLEResult int,
		@FileID 	int


SELECT
	 @SQL = ' <INVOICE DBOP="INS">
	  <TYPE>7</TYPE> 
	  <DATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</DATE> 
	  <DOC_NUMBER>'+FATURANO+'</DOC_NUMBER> 
	  <AUXIL_CODE>'+dbo.fn_G2L_SFLogoOzelKodu()+'</AUXIL_CODE> 
	  <ARP_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</ARP_CODE> 
	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,kartno)+'</GL_CODE> 
	  <VAT_RATE>8</VAT_RATE> 
	  <TOTAL_DISCOUNTED>'+convert(varchar(10),dbo.fn_G2L_SFTutar(@dosyano,@gelisno,@kartno))+'</TOTAL_DISCOUNTED> 
	  <TOTAL_VAT>'+convert(varchar(10),dbo.fn_G2L_SFKdv(@dosyano,@gelisno,@kartno))+'</TOTAL_VAT> 
	  <TOTAL_GROSS>'+convert(varchar(10),dbo.fn_G2L_SFTutar(@dosyano,@gelisno,@kartno))+'</TOTAL_GROSS> 
	  <TOTAL_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TOTAL_NET> 
	  <NOTES1>'+ISNULL(AD,'')+' '+ISNULL(SOYAD,'')+'</NOTES1> 
	  <NOTES2>'+ISNULL(SICILNO,'')+'</NOTES2> 
	  <NOTES3>'+ISNULL(KARNENO,'')+'</NOTES3> 
	  <TC_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TC_NET>
	  <RC_XRATE>1</RC_XRATE>
	  <RC_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</RC_NET>
	  <VAT_INCLUDED_GRS>1</VAT_INCLUDED_GRS>
	 <DISPATCHES>
	 <DISPATCH>
	  <TYPE>7</TYPE> 
	  <DATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</DATE> 
	  <DOC_NUMBER>'+FATURANO+'</DOC_NUMBER> 
	  <ARP_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,@kartno)+'</ARP_CODE> 
	  <GL_CODE>'+dbo.fn_G2L_SFCariKod(@dosyano,@gelisno,@kartno)+'</GL_CODE> 
	  <INVOICED>1</INVOICED> 
	  <TOTAL_DISCOUNTED>'+convert(varchar(10),dbo.fn_G2L_SFTutar(@dosyano,@gelisno,@kartno))+'</TOTAL_DISCOUNTED> 
	  <TOTAL_VAT>'+convert(varchar(10),dbo.fn_G2L_SFKdv(@dosyano,@gelisno,@kartno))+'</TOTAL_VAT> 
	  <TOTAL_GROSS>'+convert(varchar(10),dbo.fn_G2L_SFTutar(@dosyano,@gelisno,@kartno))+'</TOTAL_GROSS> 
	  <TOTAL_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TOTAL_NET> 
	  <RC_RATE>1</RC_RATE> 
	  <RC_NET>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</RC_NET> 
	 </DISPATCH>
	 </DISPATCHES>',


	@payment = 
		'<PAYMENT_LIST>
		 <PAYMENT>
		  <DATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</DATE> 
		  <MODULENR>4</MODULENR> 
		  <TRCODE>7</TRCODE> 
		  <TOTAL>'+convert(varchar(10),dbo.fn_G2L_SFToplam(@dosyano,@gelisno,@kartno))+'</TOTAL> 
		  <PROCDATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</PROCDATE> 
		  <REPORTRATE>1</REPORTRATE> 
		  <DISCOUNT_DUEDATE>'+convert(VARCHAR(10),FATURATARIH,104)+'</DISCOUNT_DUEDATE> 
		  <PAY_NO>1</PAY_NO> 
		  <DISCTRLIST /> 
		  <DISCTRDELLIST>0</DISCTRDELLIST> 
		  </PAYMENT>
		  </PAYMENT_LIST>'

FROM	
	FATBASLIK FB
	INNER JOIN KIMLIK K
		ON K.DOSYANO = FB.DOSYANO
WHERE
	FB.DOSYANO = @dosyano AND
	GELISNO = @gelisno AND
	KARTNO = @kartno

print(@SQL)
print(@payment)


EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @filename, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @SQL
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS

-- bu kýsýmda fatura Transectionlarý için script çalýþacak

EXEC p_G2L_SFKalemler @dosyano,@gelisno,@kartno,@filename


-- bu kýsýmda fatura Transectionlarý için script çalýþacak


EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @payment
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, '  </INVOICE>'
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS
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



CREATE    PROC p_G2L_SatFatBas
@FileName 	VARCHAR(200)
--WITH ENCRYPTION
AS
BEGIN

DECLARE		@FS 		int,
		@OLEResult 	int,
		@FileID 	int,
		@fat		VARCHAR(2000)


SET @fat = '  <?xml version="1.0" encoding="ISO-8859-9" ?> 
 <SALES_INVOICES>'

EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @fat
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS

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


CREATE   PROC p_G2L_SatFatSon
@FileName	VARCHAR(200)
--WITH ENCRYPTION
AS
BEGIN

DECLARE		@FS 		int,
		@OLEResult 	int,
		@FileID 	int,
		@fat		VARCHAR(2000)


SET @fat = '</SALES_INVOICES>'


EXECUTE @OLEResult = sp_OACreate 'Scripting.FileSystemObject', @FS OUT
IF @OLEResult <> 0 PRINT 'Scripting.FileSystemObject'
--Dosyayý Aç
EXECUTE @OLEResult = sp_OAMethod @FS, 'OpenTextFile', @FileID OUT, @FileName, 8, 1
IF @OLEResult <> 0 PRINT 'OpenTextFile'


EXECUTE @OLEResult = sp_OAMethod @FileID, 'WriteLine', Null, @fat
IF @OLEResult <> 0 PRINT 'WriteLine'

EXECUTE @OLEResult = sp_OADestroy @FileID
EXECUTE @OLEResult = sp_OADestroy @FS

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

