-- ======================================================================
-- KONSOLIDE UPDATE 01 - BELGE API (kaydet/getir/toplam/durum/serilot/klonla/numara)
-- ======================================================================
-- 25 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- FUNCTION: fn_api_belge_diptoplam  (kaynak: GenDepoUpdate68) ----
-- ============================================================
-- fn_Api_Belge_DipToplam — belge dip toplam kumesi (KANONIK FORMUL)
-- ------------------------------------------------------------
-- Govde SP_PRG_FaturaDipToplami'den AYNEN alinmistir; tek fark sonucun
--   RETURNS @T tablosuna yazilmasi. Amac: formulun TEK kopyasi olsun ve
--   baska SP'ler icinden cagrilabilsin (SP cagrisi "INSERT EXEC cannot be
--   nested" hatasi veriyordu).
-- SP_PRG_FaturaDipToplami artik bu TVF'i okur (davranis degismez).
-- TUR: 1=Toplam 2=OTV 3=Iskonto 4=Ara Toplam 5/6/7=KDV satirlari
--      8=Ek Vergi 9=Stopaj 15=KDV Toplam 20=Genel Toplam
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Api_Belge_DipToplam (@FATBASID INT)
RETURNS @T TABLE (
    TUR           FLOAT NULL,
    ACIKLAMA      VARCHAR(255) NULL,
    DEGER         FLOAT NULL,
    DOVIZTUTARI   FLOAT NULL,
    KUR           VARCHAR(5) NULL,
    DOVIZ_KURU    VARCHAR(5) NULL,
    DOVIZKUR      FLOAT NULL,
    KDVMUHAFIYETI SMALLINT NULL,
    FATURADOVIZI  VARCHAR(5) NULL
)
AS
BEGIN
 
declare @Tablo as table (
       [TUR] float NULL,
       [ACIKLAMA] VARCHAR(255) NULL,
       [DEGER] FLOAT NULL,
       [DOVIZTUTARI] FLOAT NULL,
       [KUR] VARCHAR(5) NULL,
       [DOVIZ_KURU] VARCHAR(5) NULL,
	   [DOVIZKUR] FLOAT NULL,
       [KDVMUHAFIYETI] SMALLINT NULL,
	   [FATURADOVIZI] VARCHAR(5) NULL
)

INSERT INTO @Tablo (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI)
SELECT
	TUR, ACIKLAMA, DEGER,DOVIZTUTARI,KUR,RAPORDOVIZ,DOVIZKUR,ISNULL(KDVMUHAFIYETI,0),ISNULL(FATURADOVIZI,'TL')
FROM
(
	SELECT
		TUR=1,'Toplam' AS ACIKLAMA,
		DEGER = ROUND(CAST(SUM(CASE 
					WHEN ISNULL(FB.FATURADOVIZI,'TL') = 'TL' THEN
						CASE WHEN KDVDURUM ='Dahil' THEN (BIRIMFIYAT*ADET)*(100.0/(100.0+KDV)) ELSE (BIRIMFIYAT*ADET) END
					ELSE
						(CASE WHEN KDVDURUM ='Dahil' THEN ((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*ADET)*(100.0/(100.0+KDV)) ELSE ((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*ADET) end)*FB.DOVIZKUR
				END)AS decimal(18,6)),2),
		DOVIZTUTARI =  ROUND((CASE WHEN KDVDURUM ='Dahil' THEN SUM(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*ADET)*(100.0/(100.0+KDV))) ELSE SUM(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*ADET)) end) ,2),	
		FB.KUR,
		FB.RAPORDOVIZ,
		FB.DOVIZKUR,
		KDVMUHAFIYETI=0,
		FB.FATURADOVIZI
	FROM
		FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
	WHERE
		FB.ID = @FATBASID
	GROUP BY FB.KUR, KDVDURUM, FB.RAPORDOVIZ,FB.DOVIZ_TUTARI,FB.DOVIZKUR,FATURADOVIZI

UNION ALL

	SELECT
		TUR=2, ACIKLAMA = 'ÖTV',
		DEGER = SUM(CASE WHEN OTVYUZDE = 0 THEN round((ADET*OTVMIKTAR),2) ELSE round((OTVMIKTAR*(round((F.BIRIMFIYAT*F.ADET),2)/100.0)),2)  END),
		DOVIZTUTARI = SUM(CASE WHEN OTVYUZDE = 0 THEN round((ADET*OTVMIKTAR),2) ELSE round((OTVMIKTAR*(round((F.DOVIZ_BIRIMFIYAT*F.ADET),2)/100.0)),2)  END),
		FB.KUR,
		FB.RAPORDOVIZ,
		FB.DOVIZKUR,
		KDVMUHAFIYETI,
		ISNULL(FB.FATURADOVIZI,'TL') AS FATURADOVIZI
	FROM
		FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
	WHERE
		FB.ID = @FATBASID
	GROUP BY FB.KUR     ,KDV ,OTVYUZDE,OTVMIKTAR, FB.KDVDURUM, FB.RAPORDOVIZ,KDVMUHAFIYETI,FB.DOVIZKUR,isnull(KDVMUHAFIYETI,0),FB.FATURADOVIZI
	HAVING ( SUM(CASE WHEN OTVYUZDE =0 THEN round(ADET*OTVMIKTAR,2) ELSE round((OTVMIKTAR*(round((F.BIRIMFIYAT*F.ADET),2)/100.0)),2)  END) ) > 0.01

UNION ALL

	SELECT
		TUR=3, ACIKLAMA = 'İskonto(%'+case --when sum(round((round((BIRIMFIYAT*ADET),2)*((100.0-ISKONTO)/100.0)*((100.0-ISKONTO2)/100.0)),2))=SUM(round((BIRIMFIYAT*ADET),2)) then '0'
									when SUM(round((BIRIMFIYAT*ADET),2))=0.0 then '0'
									else Convert(varchar(25),round((100.0*(  
																		(SUM(round((BIRIMFIYAT*ADET),2))-sum(round((round((BIRIMFIYAT*ADET),2)*((100.0-ISKONTO)/100.0)*((100.0-ISKONTO2)/100.0)),2)))
																		)/( 
																		SUM(round((BIRIMFIYAT*ADET),2))
																		)),2)) 
									end+')' ,
		DEGER =        ROUND(CASE WHEN KDVDURUM='Dahil' THEN  SUM((((BIRIMFIYAT*ADET)/(1+(KDV/100.0))) *ROUND(ISKONTO,G.DEGER)/100.0)) 
							ELSE sum( (BIRIMFIYAT*ADET))-sum(((BIRIMFIYAT*ADET)*((100.0-ROUND(ISKONTO,G.DEGER)) / 100)*((100.0-ROUND(ISKONTO2,G.DEGER)) / 100))) 
							END,2),
		DOVIZTUTARI =  ROUND(CASE WHEN KDVDURUM='Dahil' THEN  SUM(((((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*ADET)/(1+(KDV/100.0))) *ROUND(ISKONTO,G.DEGER)/100.0)) 
							ELSE sum(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*ADET))-sum((((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*ADET)*((100.0-ROUND(ISKONTO,G.DEGER)) / 100)*((100.0-ROUND(ISKONTO2,G.DEGER)) / 100)))
							END,2),
		FB.KUR,
		FB.RAPORDOVIZ,
		FB.DOVIZKUR,
		0,
		ISNULL(FB.FATURADOVIZI,'TL') AS FATURADOVIZI
	FROM
		FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
				     LEFT JOIN GENINI G ON G.BOLUM = -24002
	WHERE
		FB.ID = @FATBASID
	GROUP BY FB.KUR     ,KDVDURUM, FB.RAPORDOVIZ,FB.DOVIZ_TUTARI,FATURA_MATRAHI,FB.DOVIZKUR,FB.FATURADOVIZI
	--HAVING ( CASE WHEN KDVDURUM='Dahil' THEN  SUM(round((round((round((BIRIMFIYAT*ADET),2)/(1+(KDV/100.0))),2) *ISKONTO/100.0),2)) ELSE SUM((round((BIRIMFIYAT*ADET),2)- TUTAR)) END ) > 0.01

) AS X


DECLARE @SAYI INT

SET @SAYI = isnull((SELECT count(*) from @Tablo where TUR in (2,3)),0)
if @SAYI>0 BEGIN
	INSERT INTO @Tablo (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI)
	SELECT
		TUR=4, ACIKLAMA = 'Ara Toplam',
		DEGER =  sum(CASE WHEN TUR=2 THEN DEGER WHEN TUR=3 then -DEGER else 0.0 end),
		DOVIZTUTARI = sum(CASE WHEN TUR in (1,2) THEN DOVIZTUTARI WHEN TUR=3 then -DOVIZTUTARI else 0.0 end),
		KUR=(select KUR from FATBASLIK where ID=@FATBASID),
		RAPORDOVIZ=(select RAPORDOVIZ from FATBASLIK where ID=@FATBASID),
		DOVIZKUR=(select DOVIZKUR from FATBASLIK where ID=@FATBASID),
		KDVMUHAFIYETI=0,
		FATURADOVIZI=(select ISNULL(FATURADOVIZI,'TL') from FATBASLIK where ID=@FATBASID)
	FROM
		@Tablo
	WHERE
		TUR in (1,2,3) and @SAYI > 0
END

INSERT INTO @Tablo (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI)
	SELECT
		TUR=5,ACIKLAMA = 'KDV%'+CONVERT(VARCHAR(25),KDV),
		DEGER = CASE 
					WHEN ISNULL(FB.FATURADOVIZI,'TL')  = 'TL' THEN
						ROUND(SUM(CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-(TUTAR*(100.0/(100.0+KDV)))
						when OTVMIKTAR>0.0 then  ((TUTAR+((CASE WHEN F.OTVYUZDE =0 THEN (ADET*OTVMIKTAR) ELSE (OTVMIKTAR*((F.BIRIMFIYAT*F.ADET)/100.0))  END)))*KDV/100.0)
						ELSE CAST((KDV*((((F.BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO,G.DEGER))/100*(100.0-ROUND(ISKONTO2,G.DEGER))/100))/100.0)) AS decimal(18,6)) END),2)
					ELSE
						ROUND((SUM(CASE WHEN KDVDURUM ='Dahil' THEN ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO,G.DEGER))/100*(100.0-ROUND(ISKONTO2,G.DEGER))/100)-((((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO,G.DEGER))/100*(100.0-ROUND(ISKONTO2,G.DEGER))/100))*(100.0/(100.0+KDV))) 
								when OTVMIKTAR>0.0 then (((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_TUTARI else F.TUTAR/FB.DOVIZKUR end)+
								((CASE WHEN F.OTVYUZDE =0 THEN ADET*OTVMIKTAR ELSE (OTVMIKTAR*(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*F.ADET)/100.0))  END)))*KDV/100.0)
								ELSE CAST((KDV*((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO,G.DEGER))/100*(100.0-ROUND(ISKONTO2,G.DEGER))/100) else F.TUTAR/FB.DOVIZKUR end)/100.0)) AS decimal(18,6))  END)),2)* FB.DOVIZKUR
				END,
		DOVIZTUTARI = ROUND((SUM(CASE WHEN KDVDURUM ='Dahil' THEN ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO,G.DEGER))/100*(100.0-ROUND(ISKONTO2,G.DEGER))/100)-(((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO,G.DEGER))/100*(100.0-ROUND(ISKONTO2,G.DEGER))/100)*(100.0/(100.0+KDV))) 
								when OTVMIKTAR>0.0 then (((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_TUTARI else F.TUTAR/FB.DOVIZKUR end)+
								((CASE WHEN F.OTVYUZDE =0 THEN ADET*OTVMIKTAR ELSE (OTVMIKTAR*(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/FB.DOVIZKUR end)*F.ADET)/100.0))  END)))*KDV/100.0)
								ELSE CAST((KDV*((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO,G.DEGER))/100*(100.0-ROUND(ISKONTO2,G.DEGER))/100) else F.TUTAR/FB.DOVIZKUR end)/100.0)) AS decimal(18,6))  END)
								),2),
		FB.KUR,
		FB.RAPORDOVIZ,
		DOVIZKUR,
		isnull(KDVMUHAFIYETI,0),
		ISNULL(FB.FATURADOVIZI,'TL') AS FATURADOVIZI
	FROM
		FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
					 LEFT JOIN GENINI G ON G.BOLUM = -24002
	WHERE
		FB.ID = @FATBASID
	GROUP BY FB.KUR,KDV,FB.KDVDURUM,FB.RAPORDOVIZ,KDVMUHAFIYETI,FB.DOVIZKUR,isnull(KDVMUHAFIYETI,0),FATURADOVIZI

UNION ALL

	SELECT
		TUR=6,ACIKLAMA = CASE WHEN isnull(KDVMUHAFIYETI,0)=0  THEN 'KDV%'+CONVERT(VARCHAR(25),KDV)
								   WHEN isnull(KDVMUHAFIYETI,0)=90 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Beyan(9/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=70 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Beyan(7/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=50 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Beyan(5/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=30 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Beyan(3/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=20 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Beyan(2/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=100 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Beyan(Tam)'
		end,
		DEGER = SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0))))),2) 
						 ELSE round(((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0)),2)  END),2)),
		DOVIZTUTARI = (SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN round(TUTAR-(TUTAR*(100.0/(100.0+((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0))))),2) 
								ELSE round(((KDV*(100-isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0)),2)  END),2))/FB.DOVIZKUR),
		FB.KUR,
		FB.RAPORDOVIZ,
		FB.DOVIZKUR,
		KDVMUHAFIYETI,
		ISNULL(FB.FATURADOVIZI,'TL') AS FATURADOVIZI
	FROM
		FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
	WHERE
		FB.ID = @FATBASID and isnull(KDVMUHAFIYETI,0)>0
	GROUP BY FB.KUR     ,KDV , FB.KDVDURUM, FB.RAPORDOVIZ,KDVMUHAFIYETI,FB.DOVIZKUR,isnull(KDVMUHAFIYETI,0),FATURADOVIZI
	--HAVING SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0))))),2) 
	--				ELSE round(((KDV*(100.0-isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0)),2)  END),2)) > 0.0

UNION ALL

	SELECT
		TUR=7,ACIKLAMA = CASE WHEN isnull(KDVMUHAFIYETI,0)=0  THEN 'KDV%'+CONVERT(VARCHAR(25),KDV)
								   WHEN isnull(KDVMUHAFIYETI,0)=90 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Tevkifat(9/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=70 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Tevkifat(7/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=50 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Tevkifat(5/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=20 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Tevkifat(2/10)'
									WHEN isnull(KDVMUHAFIYETI,0)=30 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Tevkifat(3/10)'
								   WHEN isnull(KDVMUHAFIYETI,0)=100 then 'KDV%'+CONVERT(VARCHAR(25),KDV)+' Tevkifat(Tam)'
		end,
		DEGER = SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+((KDV*(isnull(KDVMUHAFIYETI,0))/100.0))))),2) 
						ELSE round(((KDV*(isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0)),2)  END),2)),
		DOVIZTUTARI = (SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+((KDV*(isnull(KDVMUHAFIYETI,0))/100.0))))),2) 
								ELSE round(((KDV*(isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0)),2)  END),2))/FB.DOVIZKUR),
		FB.KUR,
		FB.RAPORDOVIZ,
		FB.DOVIZKUR,
		KDVMUHAFIYETI,
		ISNULL(FB.FATURADOVIZI,'TL') AS FATURADOVIZI
	FROM
		FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
	WHERE
		FB.ID = @FATBASID and isnull(KDVMUHAFIYETI,0)>0
	GROUP BY FB.KUR     ,KDV , FB.KDVDURUM, FB.RAPORDOVIZ,KDVMUHAFIYETI,FB.DOVIZKUR,isnull(KDVMUHAFIYETI,0),FATURADOVIZI
	HAVING SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN round(TUTAR-(TUTAR*(100.0/(100.0+((KDV*(isnull(KDVMUHAFIYETI,0))/100.0))))),2) 
					ELSE round(((KDV*(isnull(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0)),2) END),2)) > 0.0

UNION ALL

SELECT
	TUR= case when EKVERGI < 0 then 9 else 8 end,
	ACIKLAMA = case when EKVERGI < 0 then 'Stopaj' else 'Ek Vergi' end,
	DEGER = EKVERGI,
	DOVIZTUTARI = round((EKVERGI / FB.DOVIZKUR),2), FB.KUR, FB.RAPORDOVIZ, FB.DOVIZKUR, KDVMUHAFIYETI=NULL,ISNULL(FB.FATURADOVIZI,'TL') AS FATURADOVIZI
FROM
	FATBASLIK FB
WHERE
	FB.ID = @FATBASID
	AND ISNULL(EKVERGI,0.0)<>0.0

INSERT INTO @Tablo (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI)
SELECT TUR=15,ACIKLAMA='KDV Toplam' ,
         DEGER = round(SUM( CASE
               WHEN TUR=5 and KDVMUHAFIYETI=0 THEN round(DEGER,2) 
               WHEN TUR=6 THEN round(DEGER,2)
               WHEN TUR=7 THEN 0.0 
			   else 0.0
         END),2),
         DOVIZTUTARI = round(SUM( CASE
               WHEN TUR=5 and KDVMUHAFIYETI=0 THEN round(DOVIZTUTARI,2)  
               WHEN TUR=6 THEN round(DOVIZTUTARI,2)
               WHEN TUR=7 THEN 0.0 
			   else 0.0 
         END),2),
		KUR=(select KUR from FATBASLIK where ID=@FATBASID),
		RAPORDOVIZ=(select RAPORDOVIZ from FATBASLIK where ID=@FATBASID),
		DOVIZKUR=(select DOVIZKUR from FATBASLIK where ID=@FATBASID),
		KDVMUHAFIYETI=0,
		FATURADOVIZI=(select ISNULL(FATURADOVIZI,'TL') from FATBASLIK where ID=@FATBASID)
FROM @Tablo 


INSERT INTO @Tablo (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI)
SELECT TUR=20,ACIKLAMA='Genel Toplam' ,
         DEGER = round(SUM( CASE
               WHEN TUR=1 AND ISNULL(FATURADOVIZI,'TL')  = 'TL' THEN round(DEGER,2)
			   WHEN TUR=1 AND DOVIZ_KURU != 'TL' THEN DOVIZTUTARI*DOVIZKUR
               WHEN TUR=2 THEN round(DEGER,2)
               WHEN TUR=3 AND ISNULL(FATURADOVIZI,'TL')  = 'TL' THEN -1*isnull(round(DEGER,2),0.0)
			   WHEN TUR=3 AND DOVIZ_KURU != 'TL'  THEN -1*(DOVIZTUTARI*DOVIZKUR)
               WHEN TUR=4 THEN 0.0 
               WHEN TUR=5 and KDVMUHAFIYETI=0 AND FATURADOVIZI = 'TL' THEN round(DEGER,2) 
			   WHEN TUR=5 and KDVMUHAFIYETI=0 AND DOVIZ_KURU != 'TL' THEN DOVIZTUTARI*DOVIZKUR
               WHEN TUR=6 THEN round(DEGER,2)
               WHEN TUR=7 THEN 0.0 
               WHEN TUR=8 THEN round(DEGER,2)
               WHEN TUR=9 THEN round(DEGER,2)
			   else 0.0
         END),2),
         DOVIZTUTARI = round(SUM( CASE
             WHEN TUR=1 THEN round(DOVIZTUTARI,2)
               WHEN TUR=2 THEN  round(DOVIZTUTARI,2)
               WHEN TUR=3 THEN -1*isnull(round(DOVIZTUTARI,2),0.0)
               WHEN TUR=4 THEN 0.0 
               WHEN TUR=5 and KDVMUHAFIYETI=0 THEN round(DOVIZTUTARI,2)  
               WHEN TUR=6 THEN round(DOVIZTUTARI,2)
               WHEN TUR=7 THEN 0.0 
             WHEN TUR=8 THEN round(DOVIZTUTARI,2)
               WHEN TUR=9 THEN round(DOVIZTUTARI,2) 
			   else 0.0 
         END),2),
		KUR=(select KUR from FATBASLIK where ID=@FATBASID),
		RAPORDOVIZ=(select RAPORDOVIZ from FATBASLIK where ID=@FATBASID),
		DOVIZKUR=(select DOVIZKUR from FATBASLIK where ID=@FATBASID),
		KDVMUHAFIYETI=0,
		FATURADOVIZI=(select ISNULL(FATURADOVIZI,'TL') from FATBASLIK where ID=@FATBASID)
FROM @Tablo 

INSERT INTO @T (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI)
SELECT TUR,ACIKLAMA,SUM(DEGER) AS DEGER,SUM(DOVIZTUTARI) AS DOVIZTUTARI,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI FROM (
SELECT  TUR,ACIKLAMA,
             DEGER	=		CASE 
								WHEN ACIKLAMA LIKE 'Ara Toplam%' AND FATURADOVIZI = 'TL'
                                       THEN round(( (SELECT SUM(isnull(round(DEGER,2),0.0)) FROM @Tablo WHERE ACIKLAMA='Toplam') 
                                       + ISNULL((SELECT SUM(round(DEGER,2)) FROM @Tablo WHERE ACIKLAMA LIKE 'ÖTV%'),0.0) 
                                       - ISNULL((SELECT SUM(round(DEGER,2)) FROM @Tablo WHERE ACIKLAMA LIKE 'İsk%'),0.0) ),2)
								 --WHEN ACIKLAMA = 'Genel Toplam' AND DOVIZ_KURU != 'TL' THEN ROUND(SUM(DOVIZTUTARI) * DOVIZKUR,2)
                                WHEN ACIKLAMA LIKE 'Ara Toplam%' AND DOVIZ_KURU != 'TL' THEN
										ROUND((round(( (SELECT SUM(round(DOVIZTUTARI,2)) FROM @Tablo WHERE ACIKLAMA='Toplam') 
                                       + ISNULL((SELECT SUM(round(DOVIZTUTARI,2)) FROM @Tablo WHERE ACIKLAMA LIKE 'ÖTV%'),0.0)  
                                       - ISNULL((SELECT SUM(isnull(round(DOVIZTUTARI,2),0.0)) FROM @Tablo WHERE ACIKLAMA LIKE 'İsk%'),0.0) ),2))*DOVIZKUR,2)
								ELSE SUM(isnull(round(DEGER,2),0)) 
							END,
             DOVIZTUTARI =	CASE WHEN ACIKLAMA LIKE 'Ara Toplam%'
                                       THEN round(( (SELECT SUM(round(DOVIZTUTARI,2)) FROM @Tablo WHERE ACIKLAMA='Toplam') 
                                       + ISNULL((SELECT SUM(round(DOVIZTUTARI,2)) FROM @Tablo WHERE ACIKLAMA LIKE 'ÖTV%'),0.0)  
                                       - ISNULL((SELECT SUM(isnull(round(DOVIZTUTARI,2),0.0)) FROM @Tablo WHERE ACIKLAMA LIKE 'İsk%'),0.0) ),2)
                                       ELSE SUM(round(DOVIZTUTARI,2)) END,
             KUR,
             DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI FROM @Tablo
			 GROUP BY TUR,ACIKLAMA,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI 
) AS XXX
GROUP BY TUR,ACIKLAMA,KUR,DOVIZ_KURU,DOVIZKUR,KDVMUHAFIYETI,FATURADOVIZI


    RETURN;
END
GO

-- ---- FUNCTION: fn_api_belge_tabno  (kaynak: GenDepoUpdate80) ----
-- ============================================================
-- fn_Api_Belge_TabNo : belge TUR'unden ISLEMLOG TABLOID esleme
--   @Detay = 0 -> kart (FATBASLIK), 1 -> detay (FATURA) TabNo'su
--   Esleme TTablo.FaturaSil (Utablo.pas) ve sp_Api_Belge_Sil_Json ile AYNI.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Api_Belge_TabNo (@Tur INT, @Detay BIT)
RETURNS INT
AS
BEGIN
    IF @Detay = 0
        RETURN CASE WHEN @Tur IN (3,12)     THEN 106   -- giris fisi
                    WHEN @Tur IN (4,16)     THEN 107   -- cikis fisi
                    WHEN @Tur = 20          THEN 134   -- stok transfer
                    WHEN @Tur = 6           THEN 144   -- uretim fisi
                    WHEN @Tur = 10          THEN 104   -- gelen irsaliye
                    WHEN @Tur = 14          THEN 105   -- giden irsaliye
                    WHEN @Tur IN (8,110)    THEN 214   -- gider pusulasi
                    WHEN @Tur = 109         THEN 209   -- gelen konsinye
                    WHEN @Tur = 119         THEN 219   -- giden konsinye
                    WHEN @Tur IN (9,11,13)  THEN 28    -- gelen fatura/siparis
                    WHEN @Tur IN (19,15,17) THEN 29    -- giden fatura/siparis
                    ELSE 30 END;

    RETURN CASE WHEN @Tur IN (3,12,4,16,20)      THEN 330
                WHEN @Tur = 6                    THEN 145
                WHEN @Tur = 9                    THEN 131
                WHEN @Tur IN (10,11,13,8,109)    THEN 130
                WHEN @Tur = 19                   THEN 133
                WHEN @Tur IN (14,15,17,110,119)  THEN 132
                ELSE 130 END;
END
GO

-- ---- PROCEDURE: sp_api_belge_durum_yaz_ic  (kaynak: GenDepoUpdate157) ----
-- ---- dbo.sp_Api_Belge_Durum_Yaz_Ic ----

-- ---- dbo.sp_Api_Belge_Durum_Yaz_Ic  (3 yer) ----

-- ---- 2) DURUM HESABI ----------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Durum_Yaz_Ic
    @BelgeId     INT,
    @Kaynak      NVARCHAR(10) = N'siparis',
    @Yaz         BIT = 1,
    @Tur         INT OUTPUT,
    @Durum       INT OUTPUT,
    @OncekiDurum INT OUTPUT,
    @Satir       INT OUTPUT,
    @Tamamlanan  INT OUTPUT,
    @Kismi       INT OUTPUT,
    @Acik        INT OUTPUT,
    @Neden       NVARCHAR(60) OUTPUT,
    @Yazildi     BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Neden = N''; SET @Yazildi = 0;
    SET @Satir = 0; SET @Tamamlanan = 0; SET @Kismi = 0; SET @Acik = 0;

    IF @Kaynak = N'siparis'
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM SIPARIS   WHERE ID = @BelgeId;
    ELSE
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL THROW 51002, N'Kayit bulunamadi.', 1;
    SET @Durum = @OncekiDurum;

    -- Yeniden hesaplanabilir durumlar: Taslak(0) / Kismi(1) / Onay(2) / Tamamlandi(9)
    --   IPTAL(6) ve diger ozel durumlar KORUNUR (otomatik degismez).
    IF @OncekiDurum NOT IN (0, 1, 2, 9)
        SET @Neden = N'durum korumali (' + CAST(@OncekiDurum AS nvarchar(10)) + N')';

    -- Bu belge turunden CIKAN donusum kodlari: ROTA MATRISINDEN (elle liste YOK)
    DECLARE @Yeri TABLE (K INT PRIMARY KEY);
    IF DATALENGTH(@Neden) = 0
    BEGIN
        INSERT @Yeri (K)
        SELECT DISTINCT R.DonusumTuru
        FROM dbo.fn_Prog_BelgeDonusum_Rota() R
        WHERE R.KaynakTur = @Tur
          AND R.KaynakDetayTablo = CASE WHEN @Kaynak = N'siparis' THEN 'SIPARISDETAY' ELSE 'FATURA' END
          AND R.KalanHedefTablo = 'FATURA';

        IF NOT EXISTS (SELECT 1 FROM @Yeri)
            SET @Neden = CASE WHEN @Kaynak = N'siparis' THEN N'siparis turu kapsam disi'
                              ELSE N'belge turu kapsam disi' END;
    END

    IF DATALENGTH(@Neden) = 0
    BEGIN
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6), Cikan DECIMAL(18,6));
        IF @Kaynak = N'siparis'
            INSERT @S SELECT SD.ID, ISNULL(SD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = SD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM SIPARISDETAY SD WHERE SD.SIPARISID = @BelgeId AND ISNULL(SD.ADET,0) > 0;
        ELSE
            INSERT @S SELECT FD.ID, ISNULL(FD.ADET,0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET,0)) FROM FATURA F
                           WHERE F.YERID = FD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM FATURA FD WHERE FD.FATBASID = @BelgeId AND ISNULL(FD.ADET,0) > 0;

        SELECT @Satir      = COUNT(*),
               @Tamamlanan = ISNULL(SUM(CASE WHEN Adet - Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Acik       = ISNULL(SUM(CASE WHEN Cikan <= 0 THEN 1 ELSE 0 END), 0),
               @Kismi      = ISNULL(SUM(CASE WHEN Cikan > 0 AND Adet - Cikan > 0 THEN 1 ELSE 0 END), 0)
        FROM @S;

        IF @Satir = 0                SET @Neden = N'adetli satir yok';
        ELSE IF @Satir = @Tamamlanan SET @Durum = 9;                       -- Tamamlandi
        -- Hic donusum yoksa: ONAY(2) korunur, digerlerinde TASLAK(0)
        ELSE IF @Acik = @Satir       SET @Durum = CASE WHEN @OncekiDurum = 2 THEN 2 ELSE 0 END;
        ELSE                         SET @Durum = 1;                       -- Kismi
    END

    IF @Yaz = 1 AND DATALENGTH(@Neden) = 0 AND @Durum <> @OncekiDurum
    BEGIN
        IF @Kaynak = N'siparis' UPDATE SIPARIS   SET DURUM = @Durum WHERE ID = @BelgeId;
        ELSE                    UPDATE FATBASLIK SET DURUM = @Durum WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END
END
GO

-- ---- PROCEDURE: sp_api_belge_durumhesapla_json  (kaynak: GenDepoUpdate157) ----
-- ---- dbo.sp_Api_Belge_DurumHesapla_Json ----

-- ---- dbo.sp_Api_Belge_DurumHesapla_Json  (1 yer) ----

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_DurumHesapla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @BelgeId INT          = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Kaynak  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kaynak'), N'siparis'));
    DECLARE @Yaz     BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Yaz') AS BIT), 1);
    IF @BelgeId IS NULL OR @BelgeId <= 0 THROW 51001, N'BelgeId zorunlu.', 1;
    IF @Kaynak NOT IN (N'siparis', N'belge') THROW 51001, N'Kaynak "siparis" ya da "belge" olmali.', 1;

    DECLARE @Tur INT, @Durum INT, @Onceki INT, @Satir INT, @Tam INT, @Kis INT, @Acik INT,
            @Neden NVARCHAR(60), @Yazildi BIT;
    EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @BelgeId, @Kaynak = @Kaynak, @Yaz = @Yaz,
         @Tur = @Tur OUTPUT, @Durum = @Durum OUTPUT, @OncekiDurum = @Onceki OUTPUT,
         @Satir = @Satir OUTPUT, @Tamamlanan = @Tam OUTPUT, @Kismi = @Kis OUTPUT,
         @Acik = @Acik OUTPUT, @Neden = @Neden OUTPUT, @Yazildi = @Yazildi OUTPUT;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Kaynak AS Kaynak, @Tur AS Tur,
                   CASE WHEN DATALENGTH(@Neden) = 0 THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden AS Neden, @Durum AS Durum, @Onceki AS OncekiDurum, @Yazildi AS Yazildi,
                   @Satir AS Satir, @Tam AS Tamamlanan, @Kis AS Kismi, @Acik AS Acik
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_belge_ekalan_json  (kaynak: GenDepoUpdate157) ----
-- ---- dbo.sp_Api_Belge_EkAlan_Json ----

-- ---- dbo.sp_Api_Belge_EkAlan_Json  (1 yer) ----

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_EkAlan_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ekran   VARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar, '$.Ekran'), '');
    DECLARE @Tablo   NVARCHAR(50) = NULLIF(JSON_VALUE(@Kosullar, '$.Tablo'), N'');
    DECLARE @KayitId BIGINT       = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);

    IF @Ekran IS NULL OR @Tablo IS NULL OR @KayitId IS NULL
        THROW 51001, N'Ekran, Tablo ve KayitId zorunlu.', 1;
    -- Tablo BEYAZ LISTE (ham ad dinamik SQL'e gidecegi icin)
    IF @Tablo NOT IN (N'FATBASLIK', N'FATURA', N'SIPARIS', N'SIPARISDETAY')
        THROW 51001, N'Tablo beyaz listede degil.', 1;
    IF OBJECT_ID(@Tablo, 'U') IS NULL
        THROW 51002, N'Tablo bulunamadi.', 1;

    -- ---- 1. sonuc kumesi: alan tanimlari ----
    SELECT A.ID, A.ALANADI, A.CAPTION, A.TUR, A.[SQL], A.DEGER, A.KONUM, A.TAG,
           GENISLIK = A.WIDTH, YUKSEKLIK = A.HEIGHT,
           SIRA = ROW_NUMBER() OVER (ORDER BY A.[TOP], A.[LEFT], A.ID)
    FROM ALANLAR A
    WHERE A.EKRANADI = @Ekran AND A.TABLO = @Tablo AND A.TUR IN (1, 3, 4, 7)
      AND EXISTS (SELECT 1 FROM sys.columns C
                   WHERE C.object_id = OBJECT_ID(@Tablo) AND C.name = A.ALANADI)
    ORDER BY A.[TOP], A.[LEFT], A.ID;

    -- ---- 2. sonuc kumesi: degerler (tek satir JSON) ----
    --   Kolon adlari QUOTENAME ile kacirilir; KayitId PARAMETREYLE baglanir.
    -- DIKKAT: "SELECT @v = @v + ..." birikimli atama JOIN + ORDER BY ile
    --   BELIRSIZDIR (SQL Server garanti vermez; testte yalniz SON satir geldi).
    --   Ifade FOR XML PATH ile deterministik kuruluyor.
    DECLARE @Parca NVARCHAR(MAX) =
    (
        SELECT N' + CASE WHEN ' + QUOTENAME(C.name) + N' IS NULL THEN N'''' ELSE ' +
               N'N'',"' + STRING_ESCAPE(C.name, 'json') + N'":"'' + STRING_ESCAPE(' +
               CASE
                 WHEN T.name = 'date' THEN N'CONVERT(nvarchar(10), ' + QUOTENAME(C.name) + N', 23)'
                 WHEN T.name IN ('datetime','datetime2','smalldatetime','datetimeoffset')
                                      THEN N'CONVERT(nvarchar(19), ' + QUOTENAME(C.name) + N', 120)'
                 WHEN T.name = 'time' THEN N'CONVERT(nvarchar(8), ' + QUOTENAME(C.name) + N', 108)'
                 WHEN T.name IN ('float','real') THEN N'CONVERT(nvarchar(50), ' + QUOTENAME(C.name) + N')'
                 WHEN T.name IN ('money','smallmoney','decimal','numeric')
                                      THEN N'CONVERT(nvarchar(50), CAST(' + QUOTENAME(C.name) + N' AS decimal(38,6)))'
                 WHEN T.name = 'bit'  THEN N'CASE WHEN ' + QUOTENAME(C.name) + N' = 1 THEN N''True'' ELSE N''False'' END'
                 ELSE N'CAST(' + QUOTENAME(C.name) + N' AS nvarchar(max))'
               END +
               N', ''json'') + N''"'' END'
        FROM ALANLAR A
            INNER JOIN sys.columns C ON C.object_id = OBJECT_ID(@Tablo) AND C.name = A.ALANADI
            INNER JOIN sys.types   T ON T.user_type_id = C.user_type_id
        WHERE A.EKRANADI = @Ekran AND A.TABLO = @Tablo AND A.TUR IN (1, 3, 4, 7)
          AND T.name NOT IN ('varbinary','binary','image','text','ntext','xml',
                             'geography','geometry','hierarchyid','sql_variant','timestamp')
          AND C.generated_always_type = 0 AND C.is_hidden = 0
        ORDER BY A.[TOP], A.[LEFT], A.ID
        FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)');
    SET @Parca = STUFF(ISNULL(@Parca, N''), 1, 3, N'');   -- bastaki ' + ' at

    IF DATALENGTH(@Parca) = 0
    BEGIN
        SELECT (SELECT 1 AS Sonuc, @KayitId AS KayitId, N'{}' AS Degerler
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    DECLARE @sql NVARCHAR(MAX) = N'
SELECT (SELECT 1 AS Sonuc, @pId AS KayitId,
               JSON_QUERY(N''{'' + ISNULL(STUFF(' + @Parca + N', 1, 1, N''''), N'''') + N''}'') AS Degerler
        FROM ' + QUOTENAME(@Tablo) + N' WHERE [ID] = @pId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;';
    EXEC sp_executesql @sql, N'@pId bigint', @pId = @KayitId;
END
GO

-- ---- PROCEDURE: sp_api_belge_getir_json  (kaynak: GenDepoUpdate76) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Getir_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    IF @BelgeId IS NULL OR @BelgeId <= 0 THROW 51001, N'BelgeId zorunlu.', 1;
    IF NOT EXISTS (SELECT 1 FROM FATBASLIK WHERE ID = @BelgeId)
        THROW 51002, N'Belge bulunamadi.', 1;

    -- ---- 1. sonuc kumesi: BASLIK ----
    SELECT F.ID,
           F.TUR, F.TIPI, F.DURUM,
           DURUMAD = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2403 AND DEGER = F.DURUM),
           F.TARIH, F.FATURATARIH, F.FATURANO, F.FATURASERI, F.KOCANNO,
           F.REHBERID, CARIKOD = R.KOD, CARIAD = R.FIRMA,
           F.BASLIK, F.ADRES, F.ILCE, F.IL, F.VD, F.VNO,
           F.KDVDURUM, F.KUR, F.DOVIZ_CINSI, F.DOVIZKUR, F.RAPORDOVIZ, F.FATURADOVIZI,
           F.FATURA_MATRAHI, F.KDV_TUTARI, F.EKVERGI, F.FATURA_TUTARI, F.DOVIZ_TUTARI,
           F.FATURA_MALIYETI_ORT,
           F.GIRISDEPO, GIRISDEPOAD = (SELECT TOP 1 D.DEPOADI FROM DEPOLAR D WHERE D.ID = F.GIRISDEPO),
           F.CIKISDEPO, CIKISDEPOAD = (SELECT TOP 1 D.DEPOADI FROM DEPOLAR D WHERE D.ID = F.CIKISDEPO),
           F.PROJEID, PROJEKODU = (SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID = F.PROJEID),
           F.SATICIKODU, SATICIAD = (SELECT TOP 1 R2.FIRMA FROM REHBER R2 WHERE R2.ID = F.SATICIKODU),
           F.SUBEID, F.SERVISID, F.VADE, F.ACIKLAMA, F.OZELKOD, F.OZELKOD2,
           F.EFATURADURUM, F.FIYAT_LISTESI,
           F.EKLEYEN, F.EKLEMETARIHI, F.DEGISTIREN, F.DEGISTIRMETARIHI,
           SATIRSAY = (SELECT COUNT(*) FROM FATURA D WHERE D.FATBASID = F.ID)
    FROM FATBASLIK F
        LEFT OUTER JOIN REHBER R ON R.ID = F.REHBERID
    WHERE F.ID = @BelgeId;

    -- ---- 2. sonuc kumesi: SATIRLAR ----
    SELECT F.ID,
           F.FATBASID, F.SIRA, F.TUR, F.URUNID, F.STOKID,
           KOD = CASE WHEN F.TUR = 0 THEN MG.KOD ELSE ST.KOD END,
           AD  = CASE WHEN F.TUR = 0 THEN MG.AD  ELSE ST.STOKADI END,
           URUNNO = CASE WHEN F.TUR = 0 THEN N'' ELSE ST.URUNNO END,
           F.ACIKLAMA,
           F.ADET, F.MIKTAR, F.BIRIM,
           BIRIMAD = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2702 AND DIL = -1 AND DEGER = F.BIRIM),
           BIRIM2MIKTAR = CASE WHEN F.TUR = 0 THEN F.MIKTAR
                               ELSE F.MIKTAR / NULLIF(ST.BIRIM2MIKTAR, 0) END,
           BIRIM2AD = (SELECT TOP 1 ANAHTAR FROM GENINI
                        WHERE BOLUM = -2702 AND DIL = -1
                          AND DEGER = CASE WHEN F.TUR = 0 THEN F.BIRIM ELSE ST.BIRIM2 END),
           F.BIRIMFIYAT, F.ISKONTO, F.ISKONTO2, F.TUTAR, F.KDV,
           KDVTUTAR = F.KDVDAHILFIYAT - F.TUTAR,
           F.KDVDAHILFIYAT, F.KDVMUHAFIYETI,
           F.KUR, F.DOVIZ_KURU, F.DOVIZ_BIRIMFIYAT, F.DOVIZKURDEGERI, F.DOVIZ_TUTARI,
           F.OTVYUZDE, F.OTVMIKTAR,
           F.MASRAFID, F.PROJEID,
           PROJEKODU = (SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID = F.PROJEID),
           F.SATICIKODU,
           SATICIAD = (SELECT TOP 1 R.FIRMA FROM REHBER R WHERE R.ID = F.SATICIKODU),
           F.IZLEME, F.GIRDEPO, F.CIKDEPO, F.OZELKOD, F.OZELKOD2, F.POZNO,
           F.YERI, F.YERID, F.IADEFATURAID, F.IADEADET,
           F.EKIPMANID,
           EKIPMANAD = (SELECT TOP 1 E.AD FROM EKIPMANLAR E
                          INNER JOIN EKIPMANREHBER ER ON E.ID = ER.EKIPMANID
                         WHERE ER.ID = F.EKIPMANID),
           EKIPMANSERINO = (SELECT TOP 1 ER.SERINO FROM EKIPMANREHBER ER WHERE ER.ID = F.EKIPMANID),
           F.URETIMPLANDETAYID,
           RESIM   = CASE WHEN ST.RESIM IS NULL THEN 0 ELSE 1 END,
           IZLEMSAY = (SELECT COUNT(*) FROM STOKIZLEME SI
                        WHERE SI.BASLIKID = F.FATBASID AND SI.SATIRID = F.ID),
           F.SUBEID, F.EKLEYEN, F.EKLEMETARIHI
    FROM FATURA F
        LEFT OUTER JOIN STOKLAR ST     ON ST.ID = F.URUNID AND F.TUR <> 0
        LEFT OUTER JOIN MASRAFGELIR MG ON MG.ID = F.URUNID AND F.TUR = 0
    WHERE F.FATBASID = @BelgeId
    ORDER BY F.SIRA, F.ID;
END
GO

-- ---- PROCEDURE: sp_api_belge_iptal_json  (kaynak: GenDepoUpdate132) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Iptal_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Tur     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tur')     AS INT);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip      VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist     VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @BelgeId IS NULL OR @BelgeId <= 0
        THROW 51001, N'BelgeId zorunlu.', 1;

    -- Siparis mi belge mi? (Tur verilmediyse iki tablodan da ara)
    DECLARE @Siparis BIT = 0, @Durum INT;
    IF @Tur IS NULL
    BEGIN
        SELECT @Tur = TUR, @Durum = ISNULL(DURUM,0), @Siparis = 1 FROM SIPARIS WHERE ID = @BelgeId;
        IF @Tur IS NULL
            SELECT @Tur = TUR, @Durum = ISNULL(DURUM,0), @Siparis = 0 FROM FATBASLIK WHERE ID = @BelgeId;
    END
    ELSE
    BEGIN
        IF @Tur IN (9, 19, 101, 105)
        BEGIN
            SET @Siparis = 1;
            SELECT @Durum = ISNULL(DURUM,0) FROM SIPARIS WHERE ID = @BelgeId;
        END
        ELSE
            SELECT @Durum = ISNULL(DURUM,0) FROM FATBASLIK WHERE ID = @BelgeId;
    END

    IF @Tur IS NULL OR @Durum IS NULL
        THROW 51002, N'Belge bulunamadi.', 1;
    IF @Durum = 6
        THROW 51200, N'Belge zaten iptal edilmiş.', 1;

    -- ---- KAYNAK BAGLARI: YERI/YERID SIFIRLANMADAN ONCE al ----
    --   (iptal sonrasi kaynak siparis/irsaliye durumu yeniden hesaplanacak)
    DECLARE @Kaynak TABLE (BelgeId INT PRIMARY KEY, Siparis BIT);
    IF @Siparis = 0
    BEGIN
        INSERT @Kaynak (BelgeId, Siparis)
        SELECT DISTINCT S.ID, 1
        FROM FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'SIPARISDETAY'
             INNER JOIN SIPARISDETAY SD ON SD.ID = F.YERID
             INNER JOIN SIPARIS S       ON S.ID = SD.SIPARISID
        WHERE F.FATBASID = @BelgeId;

        INSERT @Kaynak (BelgeId, Siparis)
        SELECT DISTINCT FB.ID, 0
        FROM FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'FATURA'
             INNER JOIN FATURA F2    ON F2.ID = F.YERID
             INNER JOIN FATBASLIK FB ON FB.ID = F2.FATBASID
        WHERE F.FATBASID = @BelgeId
          AND FB.ID NOT IN (SELECT BelgeId FROM @Kaynak);
    END

    DECLARE @Loglanan INT = 0, @n INT = 0, @Detay INT = 0, @Izleme INT = 0;

    BEGIN TRAN;

    -- ---- 1) LOG (degistirme) - iptal ONCESI anlik goruntu ----
    IF @Siparis = 1
    BEGIN
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'SIPARIS', @Kosul = N'ID=@pB', @KosulPar = @BelgeId,
             @TabNo = 91, @UstTabNo = 91, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'SIPARISDETAY', @Kosul = N'SIPARISID=@pB', @KosulPar = @BelgeId,
             @TabNo = 92, @UstTabNo = 91, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
    END
    ELSE
    BEGIN
        DECLARE @TabKart INT = dbo.fn_Api_Belge_TabNo(@Tur, 0);
        DECLARE @TabDet  INT = dbo.fn_Api_Belge_TabNo(@Tur, 1);
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @Kosul = N'ID=@pB', @KosulPar = @BelgeId,
             @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @Kosul = N'FATBASID=@pB', @KosulPar = @BelgeId,
             @TabNo = @TabDet, @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 2, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
        -- Silinecek izleme satirlari SILME logu olarak yazilir (Geri Al'a temel)
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKIZLEME',
             @Kosul = N'BASLIKID=@pB', @KosulPar = @BelgeId,
             @TabNo = 367, @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 0, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n,0);
    END

    -- ---- 2) IPTAL (davranis eskisiyle AYNI) ----
    IF @Siparis = 1
    BEGIN
        UPDATE SIPARIS
           SET DURUM = 6, SIPARIS_MATRAHI = 0, KDV_TUTARI = 0, EKVERGI = 0,
               SIPARIS_TUTARI = 0, DOVIZ_TUTARI = 0
         WHERE ID = @BelgeId;

        UPDATE SIPARISDETAY
           SET BIRIMFIYAT = 0, TUTAR = 0, DOVIZ_TUTARI = 0, DOVIZ_BIRIMFIYAT = 0,
               ADET = 0, MIKTAR = 0
         WHERE SIPARISID = @BelgeId;
        SET @Detay = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        UPDATE FATBASLIK
           SET DURUM = 6, FATURA_MALIYETI_ORT = 0, FATURA_MATRAHI = 0, KDV_TUTARI = 0,
               EKVERGI = 0, FATURA_TUTARI = 0, DOVIZ_TUTARI = 0
         WHERE ID = @BelgeId;

        -- Izleme satirlari ONCE silinir: STOKIZLEME DELETE tetigi stogu
        --   STOKIZLEMEDEPO'dan okuyup iade eder (bkz. GenDepoUpdate125).
        DELETE FROM STOKIZLEME WHERE BELGETUR = @Tur AND BASLIKID = @BelgeId;
        SET @Izleme = @@ROWCOUNT;

        UPDATE FATURA
           SET BIRIMFIYAT = 0, TUTAR = 0, DOVIZ_TUTARI = 0, DOVIZ_BIRIMFIYAT = 0,
               STOKDURUMDEGIS = 0, ADET = 0, MIKTAR = 0, YERI = 0, YERID = 0
         WHERE FATBASID = @BelgeId;
        SET @Detay = @@ROWCOUNT;
    END

    COMMIT;

    -- ---- 3) KAYNAK DURUMLARINI YENIDEN HESAPLA (bag koptu, kalan degisti) ----
    DECLARE @KId INT, @KSip BIT, @t2 INT, @d2 INT, @o2 INT, @s2 INT, @tm2 INT,
            @k2 INT, @a2 INT, @n2 NVARCHAR(60), @y2 BIT;
    DECLARE @Sonuc TABLE (BelgeId INT, Durum INT);
    DECLARE @KKaynak NVARCHAR(10);   -- EXEC parametresi IFADE alamaz
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT BelgeId, Siparis FROM @Kaynak;
    OPEN cur; FETCH NEXT FROM cur INTO @KId, @KSip;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @KKaynak = CASE WHEN @KSip = 1 THEN N'siparis' ELSE N'belge' END;
        BEGIN TRY
            EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic
                 @BelgeId = @KId,
                 @Kaynak = @KKaynak,
                 @Yaz = 1,
                 @Tur = @t2 OUTPUT, @Durum = @d2 OUTPUT, @OncekiDurum = @o2 OUTPUT,
                 @Satir = @s2 OUTPUT, @Tamamlanan = @tm2 OUTPUT, @Kismi = @k2 OUTPUT,
                 @Acik = @a2 OUTPUT, @Neden = @n2 OUTPUT, @Yazildi = @y2 OUTPUT;
            INSERT @Sonuc VALUES (@KId, @d2);
        END TRY
        BEGIN CATCH
            -- kaynak silinmis/kapsam disi olabilir - iptali bozma
        END CATCH
        FETCH NEXT FROM cur INTO @KId, @KSip;
    END
    CLOSE cur; DEALLOCATE cur;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Tur AS Tur, @Detay AS Detay,
                   @Izleme AS Izleme, @Loglanan AS Loglanan,
                   (SELECT BelgeId, Durum FROM @Sonuc FOR JSON PATH) AS KaynakDurum
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_belge_kaydet_json  (kaynak: GenDepoUpdate88) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Kaydet_Json
    @Kosullar    NVARCHAR(MAX),
    -- Cagiran SP icinden yeni belge ID'sini almak icin. Bu SP kendi icinde
    --   INSERT...EXEC kullaniyor (sp_BelgeNoGetir), bu yuzden disaridan
    --   INSERT...EXEC ile sarmalanamaz -> OUTPUT parametresi.
    --   Tek parametreyle cagiran mevcut kod ETKILENMEZ.
    @BelgeIdOut  INT = NULL OUTPUT,
    -- Bu SP bir BASKA SP icinden cagrildiginda kendi sonuc setini istemciye
    --   GONDERMEMELI: uygulama Q.Open ile ILK result set'i okur ve dis SP'nin
    --   sonucu yerine bunu alir. Donusumde tam olarak bu oldu - ApiSonucInt
    --   'HedefBaslikId' bulamayip 0 dondu, kullaniciya BOS UYARI cikti.
    --   Varsayilan 1: tek basina cagiran mevcut kod etkilenmez.
    @SonucDondur BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SatirModu NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));
    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    IF @SatirModu NOT IN (N'delta', N'tam') THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    -- ---- Baslik alanlari ----
    DECLARE @BelgeId   INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ID') AS INT);
    DECLARE @Tur       INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tur') AS INT);
    DECLARE @Tipi      INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tipi') AS INT);
    DECLARE @Tarih     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tarih') AS DATETIME);
    DECLARE @FatTarih  DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FaturaTarih') AS DATETIME);
    DECLARE @RehberId  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberId') AS INT);
    DECLARE @GirisDepo INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.GirisDepo') AS INT);
    DECLARE @CikisDepo INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.CikisDepo') AS INT);
    DECLARE @KdvDurum  NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.KdvDurum');
    DECLARE @Kur       NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.Kur');
    DECLARE @DovizCins NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.DovizCinsi');
    DECLARE @DovizKur  MONEY         = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.DovizKur') AS MONEY);
    DECLARE @RaporDvz  NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.RaporDoviz');
    DECLARE @Aciklama  NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Baslik.Aciklama');
    DECLARE @OzelKod   NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.OzelKod');
    DECLARE @OzelKod2  NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.OzelKod2');
    DECLARE @ProjeId   INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ProjeId') AS INT);
    DECLARE @Vade      INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Vade') AS INT);
    DECLARE @FaturaNo  NVARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar, '$.Baslik.FaturaNo'), N'');
    DECLARE @FatSeri   NVARCHAR(20)  = NULLIF(JSON_VALUE(@Kosullar, '$.Baslik.FaturaSeri'), N'');
    DECLARE @Durum     INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Durum') AS INT);
    -- yeni (opsiyonel)
    DECLARE @Unvan     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Unvan');
    DECLARE @Adres     NVARCHAR(150) = JSON_VALUE(@Kosullar, '$.Baslik.Adres');
    DECLARE @Ilce      NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Ilce');
    DECLARE @Il        NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Il');
    DECLARE @Vd        NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Vd');
    DECLARE @Vno       NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Vno');
    DECLARE @FiyatLst  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FiyatListesi') AS INT);
    DECLARE @EkstreKul BIT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EkstredeKullan') AS BIT);
    DECLARE @AcikKapali BIT     = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.AcikKapali') AS BIT);
    DECLARE @MasrafId  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.MasrafId') AS INT);
    DECLARE @FatDoviz  NVARCHAR(10)  = JSON_VALUE(@Kosullar, '$.Baslik.FaturaDovizi');
    DECLARE @EkVergi   MONEY    = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EkVergi') AS MONEY);

    -- Baslikta ID DISINDA alan gonderilmis mi? (Ubelgegiris'in 2. cagrisi gibi
    --   "sadece satir yaz" isteklerinde gereksiz "degistirme" logu olusmasin.)
    --   DIKKAT: @Tur/@BelgeNo asagida UPDATE sonrasi tablodan YENIDEN okunuyor;
    --   bu bayrak MUTLAKA o ezilmeden once hesaplanmali.
    DECLARE @BaslikAlanVar BIT =
        CASE WHEN @Tarih IS NOT NULL OR @Tur IS NOT NULL OR @Tipi IS NOT NULL
                  OR @RehberId IS NOT NULL OR @FatTarih IS NOT NULL OR @FaturaNo IS NOT NULL
                  OR @FatSeri IS NOT NULL OR @GirisDepo IS NOT NULL OR @CikisDepo IS NOT NULL
                  OR @KdvDurum IS NOT NULL OR @Kur IS NOT NULL OR @DovizCins IS NOT NULL
                  OR @DovizKur IS NOT NULL OR @RaporDvz IS NOT NULL OR @Aciklama IS NOT NULL
                  OR @OzelKod IS NOT NULL OR @OzelKod2 IS NOT NULL OR @ProjeId IS NOT NULL
                  OR @Vade IS NOT NULL OR @Durum IS NOT NULL OR @Unvan IS NOT NULL
                  OR @Adres IS NOT NULL OR @Ilce IS NOT NULL OR @Il IS NOT NULL
                  OR @Vd IS NOT NULL OR @Vno IS NOT NULL OR @FiyatLst IS NOT NULL
                  OR @EkstreKul IS NOT NULL OR @AcikKapali IS NOT NULL OR @MasrafId IS NOT NULL
                  OR @FatDoviz IS NOT NULL OR @EkVergi IS NOT NULL
             THEN 1 ELSE 0 END;

    DECLARE @Yeni BIT = CASE WHEN ISNULL(@BelgeId, 0) = 0 THEN 1 ELSE 0 END;
    IF @Yeni = 1 AND (@Tur IS NULL OR @RehberId IS NULL)
        THROW 51001, N'Yeni belgede Baslik.Tur ve Baslik.RehberId zorunlu.', 1;
    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM FATBASLIK WHERE ID = @BelgeId)
        THROW 51002, N'Belge bulunamadi.', 1;

    -- ---- Satirlar ----
    DECLARE @S TABLE (
        Sira INT PRIMARY KEY, SatirId INT, Sil BIT, UrunId INT, Tur INT,
        Adet DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
        BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6), Kdv INT,
        Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
        Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), Izleme INT,
        SeriLot NVARCHAR(MAX), Islem NVARCHAR(10) NULL, YeniId INT NULL,
        -- ---- Donusum akisi icin ek satir alanlari (opsiyonel) ----
        --   Yeri/YerId DONUSUM BAGIDIR: hedef satir hangi donusum turuyle
        --   hangi kaynak satirdan uretildi. Kalan hesabi buna dayanir.
        Yeri INT NULL, YerId INT NULL, PozNo INT NULL, StokDurumDegis INT NULL,
        EkipmanId INT NULL, Mf DECIMAL(18,6) NULL, MuhKodu NVARCHAR(50) NULL, Kasa INT NULL,
        OtvYuzde FLOAT NULL, OtvMiktar DECIMAL(18,6) NULL, IzlemeKodu NVARCHAR(50) NULL,
        Vade INT NULL, KampanyaId INT NULL, KdvMuafiyeti INT NULL);
    INSERT @S (Sira, SatirId, Sil, UrunId, Tur, Adet, Miktar, Birim, BirimFiyat, Tutar, Kdv,
               Iskonto, Iskonto2, Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, DovizTutari,
               Aciklama, ProjeId, MasrafId, OzelKod, OzelKod2, Izleme, SeriLot,
               Yeri, YerId, PozNo, StokDurumDegis, EkipmanId, Mf, MuhKodu, Kasa,
               OtvYuzde, OtvMiktar, IzlemeKodu, Vade, KampanyaId, KdvMuafiyeti)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
           ISNULL(J.ID, 0), ISNULL(J.Sil, 0), ISNULL(J.UrunId, 0), ISNULL(J.Tur, 1),
           ISNULL(J.Adet, 0), ISNULL(J.Miktar, ISNULL(J.Adet, 0)), ISNULL(J.Birim, 0),
           ISNULL(J.BirimFiyat, 0), J.Tutar, ISNULL(J.Kdv, 0),
           ISNULL(J.Iskonto, 0), ISNULL(J.Iskonto2, 0),
           ISNULL(J.Kur, N'TL'), ISNULL(J.DovizKuru, N'TL'),
           ISNULL(J.DovizBirimFiyat, 0), ISNULL(J.DovizKurDegeri, 1), ISNULL(J.DovizTutari, 0),
           ISNULL(J.Aciklama, N''), ISNULL(J.ProjeId, 0), ISNULL(J.MasrafId, 0),
           ISNULL(J.OzelKod, N''), ISNULL(J.OzelKod2, N''), ISNULL(J.Izleme, 0), J.SeriLot,
           J.Yeri, J.YerId, J.PozNo, J.StokDurumDegis, J.EkipmanId, J.Mf,
           J.MuhKodu, J.Kasa, J.OtvYuzde, J.OtvMiktar, J.IzlemeKodu, J.Vade,
           J.KampanyaId, J.KdvMuafiyeti
    FROM OPENJSON(@Kosullar, '$.Satirlar')
         WITH (Sira INT, ID INT, Sil BIT, UrunId INT, Tur INT, Adet DECIMAL(18,6),
               Miktar DECIMAL(18,6), Birim INT, BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6),
               Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
               DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
               Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT, OzelKod NVARCHAR(50),
               OzelKod2 NVARCHAR(50), Izleme INT,
                   Yeri INT, YerId INT, PozNo INT, StokDurumDegis INT, EkipmanId INT,
                   Mf DECIMAL(18,6),
                   MuhKodu NVARCHAR(50), Kasa INT, OtvYuzde FLOAT, OtvMiktar DECIMAL(18,6),
                   IzlemeKodu NVARCHAR(50), Vade INT, KampanyaId INT, KdvMuafiyeti INT,
                   SeriLot NVARCHAR(MAX) AS JSON) J;

    UPDATE @S SET Tutar = ROUND(ROUND(BirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE Tutar IS NULL;

    -- ---- Donusum akisinin ihtiyac duydugu ek baslik alanlari ----
    --   Hepsi OPSIYONEL; gonderilmezse eski davranis aynen korunur.
    DECLARE @KocanNo      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.KocanNo')      AS INT);
    DECLARE @Senaryo      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Senaryo')      AS INT);
    DECLARE @EFatDurum    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EFaturaDurum') AS INT);
    DECLARE @EFatSonuc    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.EFaturaSonuc') AS INT);
    DECLARE @AktiviteId   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.AktiviteId')   AS INT);
    DECLARE @RehberIletId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberIletId') AS INT);
    DECLARE @ServisId     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ServisId')     AS INT);
    DECLARE @SaticiKodu   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SaticiKodu')   AS INT);
    DECLARE @DetayBolumu  NVARCHAR(MAX) = JSON_VALUE(@Kosullar, '$.Baslik.DetayBolumu');

    DECLARE @BelgeNo NVARCHAR(50) = @FaturaNo, @SilinenSatir INT = 0;
    DECLARE @TabKart INT, @TabDetay INT, @LogN INT, @Loglanan INT = 0;

    BEGIN TRY
        BEGIN TRAN;

        IF @Yeni = 1
        BEGIN
            IF @BelgeNo IS NULL
            BEGIN
                DECLARE @Kocan INT = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                              WHERE TUR = @Tur AND SUBEID = -1
                                                AND CAST(BASLANGICTARIHI AS date) <= CAST(GETDATE() AS date)
                                              ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
                DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
                INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @Tur, @SubeID = -1,
                                                    @Kocanno = @Kocan, @BTarihi = @Tarih;
                SELECT TOP 1 @BelgeNo = BelgeNo, @FatSeri = ISNULL(@FatSeri, BelgeSeri) FROM @BN;
            END

            INSERT INTO FATBASLIK (TARIH, TUR, TIPI, REHBERID, PROJEID, FATURATARIH,
                                   FATURANO, FATURASERI, GIRISDEPO, CIKISDEPO,
                                   KDVDURUM, KUR, DOVIZ_CINSI, DOVIZKUR, RAPORDOVIZ, FATURADOVIZI,
                                   BASLIK, ADRES, ILCE, IL, VD, VNO,
                                   FIYAT_LISTESI, EKSTREDEKULLAN, ACIK_KAPALI, MASRAFID, EKVERGI,
                                   ACIKLAMA, OZELKOD, OZELKOD2, DURUM, VADE, SUBEID,
                                   KOCANNO, SENARYO, EFATURADURUM, EFATURASONUC, AKTIVITEID,
                                   REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
                                   EKLEYEN, EKLEMETARIHI, GIRISKAYNAK)
            VALUES (ISNULL(@Tarih, GETDATE()), @Tur, ISNULL(@Tipi, 1), @RehberId, ISNULL(@ProjeId, 0),
                    ISNULL(@FatTarih, ISNULL(@Tarih, GETDATE())),
                    @BelgeNo, @FatSeri, ISNULL(@GirisDepo, 0), ISNULL(@CikisDepo, 0),
                    ISNULL(@KdvDurum, N'Hariç'), ISNULL(@Kur, N'TL'), ISNULL(@DovizCins, N'TL'),
                    ISNULL(@DovizKur, 1), ISNULL(@RaporDvz, N'TL'), ISNULL(@FatDoviz, N'TL'),
                    @Unvan, @Adres, @Ilce, @Il, @Vd, @Vno,
                    @FiyatLst, ISNULL(@EkstreKul, 0), ISNULL(@AcikKapali, 0), @MasrafId, ISNULL(@EkVergi, 0),
                    ISNULL(@Aciklama, N''), ISNULL(@OzelKod, N''), ISNULL(@OzelKod2, N''),
                    ISNULL(@Durum, 0), ISNULL(@Vade, 0), @SubeId,
                    ISNULL(@KocanNo, 0), ISNULL(@Senaryo, 1),
                    -- K3/K4: EFATURADURUM ve EFATURASONUC varsayilani 0.
                    ISNULL(@EFatDurum, 0), ISNULL(@EFatSonuc, 0), ISNULL(@AktiviteId, -1),
                    @RehberIletId, ISNULL(@ServisId, -1), @DetayBolumu, @SaticiKodu,
                    @KulId, GETDATE(), 1);
            SET @BelgeId = CAST(SCOPE_IDENTITY() AS INT);
            -- ISLEMLOG: kart EKLEME
            SET @TabKart = dbo.fn_Api_Belge_TabNo(@Tur, 0);
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @BelgeId,
                 @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @BelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
            SET @Loglanan = @Loglanan + @LogN;
        END
        ELSE
        BEGIN
            UPDATE FATBASLIK
               SET TARIH        = COALESCE(@Tarih, TARIH),
                   TUR          = COALESCE(@Tur, TUR),
                   TIPI         = COALESCE(@Tipi, TIPI),
                   REHBERID     = COALESCE(@RehberId, REHBERID),
                   PROJEID      = COALESCE(@ProjeId, PROJEID),
                   FATURATARIH  = COALESCE(@FatTarih, FATURATARIH),
                   FATURANO     = COALESCE(@FaturaNo, FATURANO),
                   FATURASERI   = COALESCE(@FatSeri, FATURASERI),
                   GIRISDEPO    = COALESCE(@GirisDepo, GIRISDEPO),
                   CIKISDEPO    = COALESCE(@CikisDepo, CIKISDEPO),
                   KDVDURUM     = COALESCE(@KdvDurum, KDVDURUM),
                   KUR          = COALESCE(@Kur, KUR),
                   DOVIZ_CINSI  = COALESCE(@DovizCins, DOVIZ_CINSI),
                   DOVIZKUR     = COALESCE(@DovizKur, DOVIZKUR),
                   RAPORDOVIZ   = COALESCE(@RaporDvz, RAPORDOVIZ),
                   FATURADOVIZI = COALESCE(@FatDoviz, FATURADOVIZI),
                   BASLIK       = COALESCE(@Unvan, BASLIK),
                   ADRES        = COALESCE(@Adres, ADRES),
                   ILCE         = COALESCE(@Ilce, ILCE),
                   IL           = COALESCE(@Il, IL),
                   VD           = COALESCE(@Vd, VD),
                   VNO          = COALESCE(@Vno, VNO),
                   FIYAT_LISTESI  = COALESCE(@FiyatLst, FIYAT_LISTESI),
                   EKSTREDEKULLAN = COALESCE(@EkstreKul, EKSTREDEKULLAN),
                   ACIK_KAPALI    = COALESCE(@AcikKapali, ACIK_KAPALI),
                   MASRAFID     = COALESCE(@MasrafId, MASRAFID),
                   EKVERGI      = COALESCE(@EkVergi, EKVERGI),
                   ACIKLAMA     = COALESCE(@Aciklama, ACIKLAMA),
                   OZELKOD      = COALESCE(@OzelKod, OZELKOD),
                   OZELKOD2     = COALESCE(@OzelKod2, OZELKOD2),
                   DURUM        = COALESCE(@Durum, DURUM),
                   VADE         = COALESCE(@Vade, VADE),
                   DEGISTIREN   = @KulId,
                   DEGISTIRMETARIHI = GETDATE()
             WHERE ID = @BelgeId;
            SELECT @BelgeNo = FATURANO, @Tur = TUR FROM FATBASLIK WHERE ID = @BelgeId;
            -- ISLEMLOG: kart DEGISTIRME. Yalniz baslik alani gonderilmis cagrilarda
            --   (Ubelgegiris'in 2. cagrisi gibi "sadece satir yaz") gereksiz satir
            --   olusmasin diye, baslikta ID disinda alan varsa loglanir.
            IF @BaslikAlanVar = 1
            BEGIN
                SET @TabKart = dbo.fn_Api_Belge_TabNo(@Tur, 0);
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @BelgeId,
                     @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 2, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
            END
        END

        DECLARE @HGir INT, @HCik INT;
        SELECT @HGir = ISNULL(GIRISDEPO, 0), @HCik = ISNULL(CIKISDEPO, 0),
               @Tur = TUR, @RehberId = REHBERID
        FROM FATBASLIK WHERE ID = @BelgeId;

        IF @SatirModu = N'tam'
        BEGIN
            DELETE FROM STOKIZLEME
             WHERE BASLIKID = @BelgeId
               AND SATIRID IN (SELECT ID FROM FATURA WHERE FATBASID = @BelgeId
                                AND ID NOT IN (SELECT SatirId FROM @S WHERE SatirId > 0));
            DELETE FROM FATURA
             WHERE FATBASID = @BelgeId
               AND ID NOT IN (SELECT SatirId FROM @S WHERE SatirId > 0);
            SET @SilinenSatir = @SilinenSatir + @@ROWCOUNT;
        END

        SET @TabKart  = dbo.fn_Api_Belge_TabNo(@Tur, 0);
        SET @TabDetay = dbo.fn_Api_Belge_TabNo(@Tur, 1);

        DECLARE @Sira INT, @SatirId INT, @Sil BIT, @UrunId INT, @SeriLot NVARCHAR(MAX);
        DECLARE @sl1 INT, @sl2 INT;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Sira, SatirId, Sil, UrunId, SeriLot FROM @S ORDER BY Sira;
        OPEN c; FETCH NEXT FROM c INTO @Sira, @SatirId, @Sil, @UrunId, @SeriLot;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @Sil = 1 AND @SatirId > 0
            BEGIN
                -- ISLEMLOG: satir SILME - SILMEDEN ONCE (Geri Al buna bagli)
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @SatirId,
                     @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 0, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
                DELETE FROM STOKIZLEME WHERE BASLIKID = @BelgeId AND SATIRID = @SatirId;
                DELETE FROM FATURA WHERE ID = @SatirId AND FATBASID = @BelgeId;
                SET @SilinenSatir = @SilinenSatir + @@ROWCOUNT;
                UPDATE @S SET Islem = N'sil' WHERE Sira = @Sira;
            END
            ELSE IF @SatirId > 0
            BEGIN
                UPDATE F
                   SET F.TUR = S.Tur, F.URUNID = S.UrunId,
                       -- STOKID yalniz STOK satirinda (Tur<>0); masraf/gelir satirinda UrunId
                       -- bir MASRAFGELIR ID'sidir, stok referansina yazilmaz.
                       F.STOKID = CASE WHEN S.Tur = 0 THEN 0 ELSE S.UrunId END,
                       F.ACIKLAMA = S.Aciklama, F.ADET = S.Adet, F.MIKTAR = S.Miktar,
                       F.BIRIM = S.Birim, F.BIRIMFIYAT = S.BirimFiyat, F.TUTAR = S.Tutar,
                       F.KUR = S.Kur, F.ISKONTO = S.Iskonto, F.ISKONTO2 = S.Iskonto2,
                       F.KDV = S.Kdv, F.MASRAFID = S.MasrafId, F.OZELKOD = S.OzelKod,
                       F.OZELKOD2 = S.OzelKod2, F.DOVIZ_TUTARI = S.DovizTutari,
                       F.DOVIZ_KURU = S.DovizKuru, F.DOVIZ_BIRIMFIYAT = S.DovizBirimFiyat,
                       F.DOVIZKURDEGERI = S.DovizKurDegeri, F.PROJEID = S.ProjeId,
                       F.IZLEME = S.Izleme, F.DEGISTIREN = @KulId, F.DEGISTIRMETARIHI = GETDATE()
                FROM FATURA F INNER JOIN @S S ON S.Sira = @Sira
                WHERE F.ID = @SatirId AND F.FATBASID = @BelgeId;
                UPDATE @S SET Islem = N'guncelle', YeniId = @SatirId WHERE Sira = @Sira;
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @SatirId,
                     @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 2, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
            END
            ELSE
            BEGIN
                INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, STOKID, ACIKLAMA, ADET, MIKTAR,
                                    BIRIM, BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV, MASRAFID,
                                    OZELKOD, OZELKOD2, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT,
                                    DOVIZKURDEGERI, PROJEID, IZLEME, SUBEID, EKLEYEN, EKLEMETARIHI,
                                    GIRDEPO, CIKDEPO, STOKDURUMDEGIS, GIRISKAYNAK,
                                    YERI, YERID, POZNO, EKIPMANID, MF, MUHKODU, KASA,
                                    OTVYUZDE, OTVMIKTAR, IZLEMEKODU, VADE, KAMPANYAID,
                                    KDVMUHAFIYETI)
                SELECT @BelgeId, @RehberId, S.Tur, S.UrunId,
                       CASE WHEN S.Tur = 0 THEN 0 ELSE S.UrunId END,
                       S.Aciklama, S.Adet, S.Miktar,
                       S.Birim, S.BirimFiyat, S.Tutar, S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                       S.OzelKod, S.OzelKod2, S.DovizTutari, S.DovizKuru, S.DovizBirimFiyat,
                       S.DovizKurDegeri, S.ProjeId, S.Izleme, @SubeId, @KulId, GETDATE(),
                       @HGir, @HCik, ISNULL(S.StokDurumDegis, 1), 1,
                       S.Yeri, S.YerId, S.PozNo, S.EkipmanId, S.Mf, S.MuhKodu, S.Kasa,
                       S.OtvYuzde, S.OtvMiktar, S.IzlemeKodu, S.Vade, S.KampanyaId,
                       S.KdvMuafiyeti
                FROM @S S WHERE S.Sira = @Sira;
                SET @SatirId = CAST(SCOPE_IDENTITY() AS INT);
                UPDATE @S SET Islem = N'ekle', YeniId = @SatirId WHERE Sira = @Sira;
                EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @SatirId,
                     @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @BelgeId,
                     @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
                SET @Loglanan = @Loglanan + @LogN;
            END

            IF @Sil = 0 AND @SeriLot IS NOT NULL AND @SatirId > 0
                EXEC dbo.sp_Api_Belge_SeriLot_Yaz_Ic
                     @BelgeId = @BelgeId, @SatirId = @SatirId, @UrunId = @UrunId,
                     @BelgeTur = @Tur, @SeriLotJson = @SeriLot,
                     @GirisDepo = @HGir, @CikisDepo = @HCik, @KulId = @KulId,
                     @Silinen = @sl1 OUTPUT, @Yazilan = @sl2 OUTPUT;

            FETCH NEXT FROM c INTO @Sira, @SatirId, @Sil, @UrunId, @SeriLot;
        END
        CLOSE c; DEALLOCATE c;

        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkV MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @BelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkV OUTPUT,
             @Neden = @TNeden OUTPUT, @Yazildi = @TYazildi OUTPUT;

        SET @BelgeIdOut = @BelgeId;
        COMMIT;

        IF @SonucDondur = 1
            SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @BelgeNo AS BelgeNo, @Yeni AS Yeni,
                           @SilinenSatir AS SilinenSatir, @Loglanan AS Loglanan,
                           (SELECT Sira, ISNULL(YeniId, SatirId) AS ID, Islem
                              FROM @S ORDER BY Sira FOR JSON PATH) AS Satirlar,
                           (SELECT @Matrah AS Matrah, @Kdv AS Kdv, @Toplam AS Toplam,
                                   @Doviz AS Doviz, @TNeden AS Neden
                              FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Toplam
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ---- PROCEDURE: sp_api_belge_klonla_json  (kaynak: GenDepoUpdate140) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Klonla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KaynakId INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakId') AS INT);
    DECLARE @Tarih    DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tarih')    AS DATETIME);
    DECLARE @RehberId INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT);
    DECLARE @KulId    INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @KaynakId IS NULL OR @KaynakId <= 0
        THROW 51001, N'KaynakId zorunlu.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.FATBASLIK WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak belge bulunamadi.', 1;

    SET @Tarih = ISNULL(@Tarih, GETDATE());

    DECLARE @Tur INT = (SELECT TUR FROM dbo.FATBASLIK WHERE ID = @KaynakId);

    -- Lot/seri izlemli satir varsa klonlanmaz: klon yeni stok hareketi uretir,
    --   kaynagin lot/serisi ikinci kez cikamaz. (Ayni kural eskiden UI'daydi.)
    IF EXISTS (SELECT 1 FROM dbo.FATURA WHERE FATBASID = @KaynakId AND ISNULL(IZLEME, 0) <> 0)
        THROW 51200, N'Belge içeriğinde izlem bilgisi aktif ürünler var, bu işlem gerçekleştirilemez.', 1;

    ------------------------------------------------------------------ BASLIK
    DECLARE @Baslik NVARCHAR(MAX) =
    (
        SELECT
            Tur            = FB.TUR,
            Tipi           = FB.TIPI,
            Tarih          = CONVERT(NVARCHAR(19), @Tarih, 126),
            FaturaTarih    = CONVERT(NVARCHAR(19), @Tarih, 126),
            RehberId       = ISNULL(@RehberId, FB.REHBERID),
            GirisDepo      = FB.GIRISDEPO,
            CikisDepo      = FB.CIKISDEPO,
            KdvDurum       = FB.KDVDURUM,
            Kur            = FB.KUR,
            DovizCinsi     = FB.DOVIZ_CINSI,
            DovizKur       = FB.DOVIZKUR,
            RaporDoviz     = FB.RAPORDOVIZ,
            FaturaDovizi   = FB.FATURADOVIZI,
            Aciklama       = FB.ACIKLAMA,
            OzelKod        = FB.OZELKOD,
            OzelKod2       = FB.OZELKOD2,
            ProjeId        = FB.PROJEID,
            Vade           = FB.VADE,
            Durum          = 0,                    -- klon TASLAK baslar
            Unvan          = FB.BASLIK,
            Adres          = FB.ADRES,
            Ilce           = FB.ILCE,
            Il             = FB.IL,
            Vd             = FB.VD,
            Vno            = FB.VNO,
            FiyatListesi   = FB.FIYAT_LISTESI,
            EkstredeKullan = FB.EKSTREDEKULLAN,
            AcikKapali     = FB.ACIK_KAPALI,
            MasrafId       = FB.MASRAFID,
            EkVergi        = FB.EKVERGI,
            Senaryo        = FB.SENARYO,
            EFaturaDurum   = 0,
            EFaturaSonuc   = 0,
            RehberIletId   = FB.REHBERILETID,
            SaticiKodu     = FB.SATICIKODU,
            DetayBolumu    = FB.DETAYBOLUMU
        FROM dbo.FATBASLIK FB
        WHERE FB.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    ------------------------------------------------------------------ SATIRLAR
    DECLARE @Satirlar NVARCHAR(MAX) =
    (
        SELECT
            Sira            = ROW_NUMBER() OVER (ORDER BY ISNULL(F.SIRA, F.ID), F.ID),
            UrunId          = F.URUNID,
            Tur             = F.TUR,
            Adet            = F.ADET,
            Miktar          = F.MIKTAR,
            Birim           = F.BIRIM,
            BirimFiyat      = F.BIRIMFIYAT,
            Tutar           = F.TUTAR,
            Kdv             = F.KDV,
            Iskonto         = F.ISKONTO,
            Iskonto2        = F.ISKONTO2,
            Kur             = F.KUR,
            DovizKuru       = F.DOVIZ_KURU,
            DovizBirimFiyat = F.DOVIZ_BIRIMFIYAT,
            DovizKurDegeri  = F.DOVIZKURDEGERI,
            DovizTutari     = F.DOVIZ_TUTARI,
            Aciklama        = F.ACIKLAMA,
            ProjeId         = F.PROJEID,
            MasrafId        = F.MASRAFID,
            OzelKod         = F.OZELKOD,
            OzelKod2        = F.OZELKOD2,
            Izleme          = 0,                   -- lot/seri klona tasinmaz
            PozNo           = F.POZNO,
            EkipmanId       = F.EKIPMANID,
            Mf              = F.MF,
            MuhKodu         = F.MUHKODU,
            Kasa            = F.KASA,
            -- OTVYUZDE bu tabloda BIT: FOR JSON true/false uretir, kaydet API'si
            --   FLOAT bekler -> 'nvarchar to float' hatasi. Sayiya cevir.
            OtvYuzde        = CAST(F.OTVYUZDE AS INT),
            OtvMiktar       = F.OTVMIKTAR,
            Vade            = F.VADE,
            KampanyaId      = F.KAMPANYAID,
            KdvMuafiyeti    = F.KDVMUHAFIYETI
        FROM dbo.FATURA F
        WHERE F.FATBASID = @KaynakId
        ORDER BY ISNULL(F.SIRA, F.ID), F.ID
        FOR JSON PATH
    );

    IF @Satirlar IS NULL
        THROW 51201, N'Kaynak belgede satır yok, kopyalanacak içerik bulunamadı.', 1;

    ------------------------------------------------------------------ KAYDET
    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    -- @SonucDondur=0 : Kaydet kendi sonuc setini GONDERMEZ; istemci bu SP'nin
    --   sonucunu okur (ic ice cagrida ilk result set tuzagi).
    EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @J, @BelgeIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0
        THROW 51202, N'Klon belge oluşturulamadı.', 1;

    -- ISLEMLOG izi: bu belge KOPYA (ALTISLEMTIPI=3), kaynagi @KaynakId.
    --   TabNo belge turune gore cozulur (log kart satiri hangi TABLOID ile yazildiysa).
    DECLARE @LogTabNo INT = (SELECT TOP 1 TABLOID FROM dbo.ISLEMLOG
                              WHERE KAYITID = @YeniId AND ISLEMTIPI = 1 ORDER BY ID DESC);
    IF @LogTabNo IS NOT NULL
        EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = @LogTabNo, @KayitId = @YeniId,
             @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = @LogTabNo;

    SELECT Sonuc    = 1,
           KaynakId = @KaynakId,
           BelgeId  = @YeniId,
           BelgeNo  = (SELECT FATURANO FROM dbo.FATBASLIK WHERE ID = @YeniId),
           Tur      = @Tur,
           Satir    = (SELECT COUNT(*) FROM dbo.FATURA WHERE FATBASID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_belge_liste_json  (kaynak: GenDepoUpdate76) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Liste_Json
    @Kosullar NVARCHAR(MAX),
    @Baslik   NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tur       INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tur') AS INT);
    DECLARE @BasTarih  DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BasTarih') AS DATE);
    DECLARE @BitTarih  DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BitTarih') AS DATE);
    DECLARE @RehberId  INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT), 0);
    DECLARE @SubeId    INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.SubeId') AS INT);
    DECLARE @Durum     INT  = TRY_CAST(JSON_VALUE(@Kosullar, '$.Durum') AS INT);
    DECLARE @BelgeNo   NVARCHAR(50)  = NULLIF(JSON_VALUE(@Kosullar, '$.BelgeNo'),  N'');
    DECLARE @Aciklama  NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar, '$.Aciklama'), N'');
    DECLARE @Sayfa     INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Sayfa') AS INT), 1);
    DECLARE @SayfaBoyu INT  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.SayfaBoyu') AS INT), 0);
    DECLARE @Sirala    NVARCHAR(20) = UPPER(ISNULL(JSON_VALUE(@Kosullar, '$.Sirala'), N'TARIH_DESC'));

    IF @Sayfa < 1 SET @Sayfa = 1;
    -- Siralama BEYAZ LISTE (ham SQL kabul edilmez)
    IF @Sirala NOT IN (N'TARIH_DESC', N'TARIH_ASC', N'NO_DESC', N'NO_ASC', N'TUTAR_DESC')
        SET @Sirala = N'TARIH_DESC';

    DECLARE @T TABLE (Tur INT PRIMARY KEY);
    INSERT @T (Tur) SELECT DISTINCT CAST(value AS INT)
      FROM OPENJSON(@Kosullar, '$.Turler') WHERE ISNUMERIC(value) = 1;
    IF NOT EXISTS (SELECT 1 FROM @T) AND @Tur IS NOT NULL INSERT @T (Tur) VALUES (@Tur);

    DECLARE @Atla INT = (@Sayfa - 1) * CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 0 END;

    SELECT F.ID,
           F.TUR, F.TIPI, F.DURUM,
           DURUMAD = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2403 AND DEGER = F.DURUM),
           F.FATURATARIH, F.FATURANO, F.FATURASERI,
           F.REHBERID, CARIKOD = R.KOD, CARIAD = R.FIRMA,
           F.FATURA_MATRAHI, F.KDV_TUTARI, F.EKVERGI, F.FATURA_TUTARI, F.DOVIZ_TUTARI,
           F.KUR, F.DOVIZ_CINSI, F.DOVIZKUR,
           F.SUBEID, F.ACIKLAMA, F.OZELKOD, F.OZELKOD2, F.EFATURADURUM,
           SATIRSAY = (SELECT COUNT(*) FROM FATURA D WHERE D.FATBASID = F.ID),
           F.EKLEYEN, F.EKLEMETARIHI, F.DEGISTIREN, F.DEGISTIRMETARIHI
    FROM FATBASLIK F
        LEFT OUTER JOIN REHBER R ON R.ID = F.REHBERID
    WHERE (NOT EXISTS (SELECT 1 FROM @T) OR F.TUR IN (SELECT Tur FROM @T))
      AND (@BasTarih IS NULL OR CAST(F.FATURATARIH AS date) >= @BasTarih)
      AND (@BitTarih IS NULL OR CAST(F.FATURATARIH AS date) <= @BitTarih)
      AND (@RehberId = 0    OR F.REHBERID = @RehberId)
      AND (@SubeId   IS NULL OR F.SUBEID  = @SubeId)
      AND (@Durum    IS NULL OR F.DURUM   = @Durum)
      AND (@BelgeNo  IS NULL OR F.FATURANO LIKE N'%' + @BelgeNo + N'%')
      AND (@Aciklama IS NULL OR F.ACIKLAMA LIKE N'%' + @Aciklama + N'%')
    ORDER BY
        CASE WHEN @Sirala = N'TARIH_DESC' THEN F.FATURATARIH END DESC,
        CASE WHEN @Sirala = N'TARIH_ASC'  THEN F.FATURATARIH END ASC,
        CASE WHEN @Sirala = N'NO_DESC'    THEN F.FATURANO END DESC,
        CASE WHEN @Sirala = N'NO_ASC'     THEN F.FATURANO END ASC,
        CASE WHEN @Sirala = N'TUTAR_DESC' THEN F.FATURA_TUTARI END DESC,
        F.ID DESC
    OFFSET @Atla ROWS
    FETCH NEXT CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 2147483647 END ROWS ONLY;
END
GO

-- ---- PROCEDURE: sp_api_belge_serilot_yaz_ic  (kaynak: GenDepoUpdate78) ----
-- ============================================================
-- Seri/lot: ic yardimci (sonuc kumesi DONDURMEZ)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_SeriLot_Yaz_Ic
    @BelgeId        INT,
    @SatirId        INT,
    @UrunId         INT,
    @BelgeTur       INT,
    @SeriLotJson    NVARCHAR(MAX),
    @IslemTip       INT = 0,
    @IzlemTur       INT = 0,
    @GirisDepo      INT = 0,
    @CikisDepo      INT = 0,
    @StokDurumDegis BIT = 1,
    @KaynakSatirId  INT = 0,
    @KulId          INT = 0,
    @Silinen        INT OUTPUT,
    @Yazilan        INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Silinen = 0; SET @Yazilan = 0;

    DECLARE @S TABLE (Sira INT PRIMARY KEY, SeriNo NVARCHAR(100), LotNo NVARCHAR(100),
                      Urt DATE, Skt DATE, Kalan FLOAT, Durum FLOAT, IzlemId INT,
                      SeriLotId INT NULL, YeniIzlem INT NULL);
    INSERT @S (Sira, SeriNo, LotNo, Urt, Skt, Kalan, Durum, IzlemId)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
           ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''),
           ISNULL(J.Urt, '1990-01-01'), ISNULL(J.Skt, '1990-01-01'),
           ISNULL(J.Kalan, 0), ISNULL(J.Durum, 0), ISNULL(J.IzlemId, 0)
    FROM OPENJSON(ISNULL(@SeriLotJson, N'[]'))
         WITH (Sira INT, SeriNo NVARCHAR(100), LotNo NVARCHAR(100),
               Urt DATE, Skt DATE, Kalan FLOAT, Durum FLOAT, IzlemId INT) J;

    SELECT @Silinen = COUNT(*) FROM STOKIZLEME
     WHERE STOKID = @UrunId AND BASLIKID = @BelgeId AND SATIRID = @SatirId;
    DELETE FROM STOKIZLEME
     WHERE STOKID = @UrunId AND BASLIKID = @BelgeId AND SATIRID = @SatirId;

    IF NOT EXISTS (SELECT 1 FROM @S) RETURN;

    UPDATE S SET SeriLotId = X.ID
    FROM @S S
    CROSS APPLY (SELECT TOP 1 SL.ID FROM STOKSERILOT SL
                  WHERE SL.STOKID = @UrunId AND SL.SERINO = S.SeriNo AND SL.LOTNO = S.LotNo
                  ORDER BY SL.ID) X;

    DECLARE @Sira INT, @Yeni INT;
    DECLARE cS CURSOR LOCAL FAST_FORWARD FOR SELECT Sira FROM @S WHERE SeriLotId IS NULL ORDER BY Sira;
    OPEN cS; FETCH NEXT FROM cS INTO @Sira;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO STOKSERILOT (STOKID, SERINO, LOTNO, URT, SKT)
        SELECT @UrunId, SeriNo, LotNo, Urt, Skt FROM @S WHERE Sira = @Sira;
        SET @Yeni = CAST(SCOPE_IDENTITY() AS INT);
        UPDATE @S SET SeriLotId = @Yeni WHERE Sira = @Sira;
        FETCH NEXT FROM cS INTO @Sira;
    END
    CLOSE cS; DEALLOCATE cS;

    DECLARE @Kalan FLOAT, @Fark FLOAT, @DonusId INT, @SeriLotId INT, @IzlemId INT, @DepoKalan FLOAT;
    DECLARE cI CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Kalan, Durum, IzlemId, SeriLotId FROM @S ORDER BY Sira;
    OPEN cI; FETCH NEXT FROM cI INTO @Sira, @Kalan, @Fark, @DonusId, @SeriLotId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Fark    = CASE WHEN @BelgeTur = 99 THEN @Kalan - @Fark ELSE @Kalan END;
        SET @DonusId = CASE WHEN @KaynakSatirId > 0 THEN ISNULL(@DonusId, 0) ELSE 0 END;

        INSERT INTO STOKIZLEME (STOKID, BELGETUR, BASLIKID, SATIRID, IZLEMTUR,
                                KALAN, ADET, EKLEYEN, DONUSID, SERILOTID)
        VALUES (@UrunId, @BelgeTur, @BelgeId, @SatirId, @IzlemTur,
                @Fark, @Kalan, @KulId, @DonusId, @SeriLotId);
        SET @IzlemId = CAST(SCOPE_IDENTITY() AS INT);
        SET @Yazilan = @Yazilan + 1;

        SET @DepoKalan = @Kalan;
        IF @StokDurumDegis = 0 OR @BelgeTur = 99 SET @DepoKalan = 0;

        IF @BelgeTur IN (4, 14, 15, 16, 119, 20, 101)
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @CikisDepo, -1.0 * @DepoKalan);
        ELSE
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @GirisDepo, @DepoKalan);

        IF @BelgeTur IN (119, 20)
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @GirisDepo, @DepoKalan);
        ELSE IF @BelgeTur = 109 AND @IslemTip = 2
            INSERT INTO STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) VALUES (@IzlemId, @CikisDepo, -1.0 * @DepoKalan);

        FETCH NEXT FROM cI INTO @Sira, @Kalan, @Fark, @DonusId, @SeriLotId;
    END
    CLOSE cI; DEALLOCATE cI;
END
GO

-- ---- PROCEDURE: sp_api_belge_serilot_yaz_json  (kaynak: GenDepoUpdate78) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_SeriLot_Yaz_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @SatirId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SatirId') AS INT);
    DECLARE @UrunId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.UrunId')  AS INT);
    DECLARE @BelgeTur INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeTur') AS INT);
    DECLARE @IslemTip INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.IslemTip') AS INT), 0);
    DECLARE @IzlemTur INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.IzlemTur') AS INT), 0);
    DECLARE @GirisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GirisDepo') AS INT), 0);
    DECLARE @CikisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.CikisDepo') AS INT), 0);
    DECLARE @KaynakSatirId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakSatirId') AS INT), 0);
    DECLARE @StokDurumDegis BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.StokDurumDegis') AS BIT), 1);
    DECLARE @KulId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);
    DECLARE @SeriLot NVARCHAR(MAX) = JSON_QUERY(@Kosullar, '$.SeriLot');

    IF @BelgeId IS NULL OR @SatirId IS NULL OR @UrunId IS NULL OR @BelgeTur IS NULL
        THROW 51001, N'BelgeId, SatirId, UrunId ve BelgeTur zorunlu.', 1;
    IF NOT EXISTS (SELECT 1 FROM FATURA WHERE ID = @SatirId AND FATBASID = @BelgeId)
        THROW 51002, N'Belge satiri bulunamadi.', 1;

    DECLARE @Sil INT, @Yaz INT;
    BEGIN TRY
        BEGIN TRAN;
        EXEC dbo.sp_Api_Belge_SeriLot_Yaz_Ic
             @BelgeId = @BelgeId, @SatirId = @SatirId, @UrunId = @UrunId, @BelgeTur = @BelgeTur,
             @SeriLotJson    = @SeriLot,
             @IslemTip       = @IslemTip,
             @IzlemTur       = @IzlemTur,
             @GirisDepo      = @GirisDepo,
             @CikisDepo      = @CikisDepo,
             @StokDurumDegis = @StokDurumDegis,
             @KaynakSatirId  = @KaynakSatirId,
             @KulId          = @KulId,
             @Silinen = @Sil OUTPUT, @Yazilan = @Yaz OUTPUT;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @SatirId AS SatirId,
                   @Sil AS Silinen, @Yaz AS Yazilan
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_belge_siparis_kaydet_json  (kaynak: GenDepoUpdate113) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Siparis_Kaydet_Json
    @Kosullar     NVARCHAR(MAX),
    @BelgeIdOut   INT = NULL OUTPUT,
    @SonucDondur  BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BelgeId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ID') AS INT);
    DECLARE @Yeni     BIT = CASE WHEN ISNULL(@BelgeId, 0) > 0 THEN 0 ELSE 1 END;
    DECLARE @SatirModu NVARCHAR(10) =
        LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));

    IF @SatirModu NOT IN (N'delta', N'tam')
        THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    -- ---------- Baslik alanlari ----------
    DECLARE @Tur      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tur')      AS INT);
    DECLARE @Tipi     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tipi')     AS INT);
    DECLARE @RehberId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberId') AS INT);
    DECLARE @Tarih    DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Tarih') AS DATETIME);
    DECLARE @STarih   DATETIME = COALESCE(
        TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SiparisTarih') AS DATETIME),
        TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FaturaTarih')  AS DATETIME), @Tarih);
    DECLARE @BelgeNo  NVARCHAR(50) = COALESCE(
        JSON_VALUE(@Kosullar, '$.Baslik.SiparisNo'), JSON_VALUE(@Kosullar, '$.Baslik.FaturaNo'));
    DECLARE @BelgeSeri NVARCHAR(50) = COALESCE(
        JSON_VALUE(@Kosullar, '$.Baslik.SiparisSeri'), JSON_VALUE(@Kosullar, '$.Baslik.FaturaSeri'));
    DECLARE @KocanNo  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.KocanNo') AS INT);
    DECLARE @GirisDepo INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.GirisDepo') AS INT);
    DECLARE @CikisDepo INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.CikisDepo') AS INT);
    DECLARE @KdvDurum NVARCHAR(20) = JSON_VALUE(@Kosullar, '$.Baslik.KdvDurum');
    DECLARE @Kur      NVARCHAR(10) = JSON_VALUE(@Kosullar, '$.Baslik.Kur');
    DECLARE @RaporDoviz NVARCHAR(10) = JSON_VALUE(@Kosullar, '$.Baslik.RaporDoviz');
    DECLARE @DovizCinsi NVARCHAR(10) = COALESCE(
        JSON_VALUE(@Kosullar, '$.Baslik.DovizCinsi'), JSON_VALUE(@Kosullar, '$.Baslik.FaturaDovizi'));
    DECLARE @DovizKur MONEY = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.DovizKur') AS MONEY);
    DECLARE @SubeId   INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SubeId') AS INT);
    DECLARE @Aciklama NVARCHAR(255) = JSON_VALUE(@Kosullar, '$.Baslik.Aciklama');
    DECLARE @AktiviteId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.AktiviteId') AS INT);
    DECLARE @RehberIletId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.RehberIletId') AS INT);
    DECLARE @ServisId    INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ServisId') AS INT);
    DECLARE @DetayBolumu INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.DetayBolumu') AS INT);
    DECLARE @SaticiKodu  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.SaticiKodu') AS INT);
    DECLARE @ProjeId     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.ProjeId') AS INT);
    DECLARE @Vade        INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Vade') AS INT);
    DECLARE @FiyatListesi INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.FiyatListesi') AS INT);
    DECLARE @Unvan  NVARCHAR(255) = JSON_VALUE(@Kosullar, '$.Baslik.Unvan');
    DECLARE @Adres  NVARCHAR(255) = JSON_VALUE(@Kosullar, '$.Baslik.Adres');
    DECLARE @Ilce   NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Ilce');
    DECLARE @Il     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Il');
    DECLARE @Vd     NVARCHAR(100) = JSON_VALUE(@Kosullar, '$.Baslik.Vd');
    DECLARE @Vno    NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Baslik.Vno');
    DECLARE @OzelKod NVARCHAR(50) = JSON_VALUE(@Kosullar, '$.Baslik.OzelKod');
    DECLARE @Durum  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Baslik.Durum') AS INT);
    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId') AS INT), 0);

    IF @Yeni = 1 AND (@Tur IS NULL OR ISNULL(@RehberId, 0) = 0)
        THROW 51001, N'Yeni siparis icin Baslik.Tur ve Baslik.RehberId zorunlu.', 1;
    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM SIPARIS WHERE ID = @BelgeId)
        THROW 51002, N'Siparis bulunamadi.', 1;

    -- ---------- Satirlar ----------
    DECLARE @S TABLE (
        Sira INT PRIMARY KEY, SatirId INT, Sil BIT, UrunId INT, Tur INT,
        Adet DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
        BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6), Kdv INT,
        Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
        Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        OzelKod NVARCHAR(50) COLLATE DATABASE_DEFAULT,
        OzelKod2 NVARCHAR(50) COLLATE DATABASE_DEFAULT,
        Izleme INT, Yeri INT, YerId INT, PozNo INT, EkipmanId INT,
        Mf DECIMAL(18,6), MuhKodu NVARCHAR(50) COLLATE DATABASE_DEFAULT, Kasa INT,
        OtvYuzde FLOAT, OtvMiktar DECIMAL(18,6),
        IzlemeKodu NVARCHAR(50) COLLATE DATABASE_DEFAULT, Vade INT, KampanyaId INT,
        TeslimTarihi DATETIME, YeniId INT NULL);

    INSERT @S (Sira, SatirId, Sil, UrunId, Tur, Adet, Miktar, Birim, BirimFiyat, Tutar,
               Kdv, Iskonto, Iskonto2, Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri,
               DovizTutari, Aciklama, ProjeId, MasrafId, OzelKod, OzelKod2, Izleme,
               Yeri, YerId, PozNo, EkipmanId, Mf, MuhKodu, Kasa, OtvYuzde, OtvMiktar,
               IzlemeKodu, Vade, KampanyaId, TeslimTarihi)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT 1))), J.SatirId,
           ISNULL(J.Sil, 0), J.UrunId, ISNULL(J.Tur, 1), J.Adet,
           ISNULL(J.Miktar, J.Adet), ISNULL(J.Birim, 0), ISNULL(J.BirimFiyat, 0), J.Tutar,
           ISNULL(J.Kdv, 0), ISNULL(J.Iskonto, 0), ISNULL(J.Iskonto2, 0),
           J.Kur, J.DovizKuru, ISNULL(J.DovizBirimFiyat, 0), ISNULL(J.DovizKurDegeri, 1),
           J.DovizTutari, J.Aciklama, J.ProjeId, J.MasrafId, J.OzelKod, J.OzelKod2,
           ISNULL(J.Izleme, 0), J.Yeri, J.YerId, J.PozNo, J.EkipmanId, J.Mf, J.MuhKodu,
           J.Kasa, J.OtvYuzde, J.OtvMiktar, J.IzlemeKodu, J.Vade, J.KampanyaId,
           J.TeslimTarihi
    FROM OPENJSON(@Kosullar, '$.Satirlar')
         WITH (Sira INT '$.Sira', SatirId INT '$.SatirId', Sil BIT '$.Sil',
               UrunId INT '$.UrunId', Tur INT '$.Tur',
               Adet DECIMAL(18,6) '$.Adet', Miktar DECIMAL(18,6) '$.Miktar',
               Birim INT '$.Birim', BirimFiyat DECIMAL(18,6) '$.BirimFiyat',
               Tutar DECIMAL(18,6) '$.Tutar', Kdv INT '$.Kdv',
               Iskonto FLOAT '$.Iskonto', Iskonto2 FLOAT '$.Iskonto2',
               Kur NVARCHAR(10) '$.Kur', DovizKuru NVARCHAR(10) '$.DovizKuru',
               DovizBirimFiyat DECIMAL(18,6) '$.DovizBirimFiyat',
               DovizKurDegeri MONEY '$.DovizKurDegeri',
               DovizTutari DECIMAL(18,6) '$.DovizTutari',
               Aciklama NVARCHAR(250) '$.Aciklama', ProjeId INT '$.ProjeId',
               MasrafId INT '$.MasrafId', OzelKod NVARCHAR(50) '$.OzelKod',
               OzelKod2 NVARCHAR(50) '$.OzelKod2', Izleme INT '$.Izleme',
               Yeri INT '$.Yeri', YerId INT '$.YerId', PozNo INT '$.PozNo',
               EkipmanId INT '$.EkipmanId', Mf DECIMAL(18,6) '$.Mf',
               MuhKodu NVARCHAR(50) '$.MuhKodu', Kasa INT '$.Kasa',
               OtvYuzde FLOAT '$.OtvYuzde', OtvMiktar DECIMAL(18,6) '$.OtvMiktar',
               IzlemeKodu NVARCHAR(50) '$.IzlemeKodu', Vade INT '$.Vade',
               KampanyaId INT '$.KampanyaId', TeslimTarihi DATETIME '$.TeslimTarihi') J;

    -- Tutar gonderilmediyse ayni formul (sp_Api_Belge_Kaydet_Json ile birebir)
    UPDATE @S SET Tutar = ROUND(ROUND(BirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE Tutar IS NULL;
    UPDATE @S SET DovizTutari = ROUND(ROUND(DovizBirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE DovizTutari IS NULL;

    -- ---------- Baslik yaz ----------
    IF @Yeni = 1
    BEGIN
        INSERT INTO SIPARIS
            (TUR, TIPI, REHBERID, TARIH, SIPARISTARIH, SIPARISNO, SIPARISSERI, KOCANNO,
             GIRISDEPO, CIKISDEPO, KDVDURUM, KUR, RAPORDOVIZ, DOVIZ_CINSI, DOVIZKUR,
             SUBEID, ACIKLAMA, AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU,
             SATICIKODU, PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO,
             OZELKOD, DURUM, EKLEYEN, EKLEMETARIHI)
        VALUES
            (@Tur, ISNULL(@Tipi, 1), @RehberId, ISNULL(@Tarih, GETDATE()),
             ISNULL(@STarih, GETDATE()), @BelgeNo, @BelgeSeri, @KocanNo,
             @GirisDepo, @CikisDepo, @KdvDurum, @Kur, @RaporDoviz, @DovizCinsi,
             ISNULL(@DovizKur, 1), @SubeId, @Aciklama, @AktiviteId, @RehberIletId,
             @ServisId, @DetayBolumu, @SaticiKodu, @ProjeId, @Vade, @FiyatListesi,
             @Unvan, @Adres, @Ilce, @Il, @Vd, @Vno, @OzelKod, ISNULL(@Durum, 0),
             @KulId, GETDATE());
        SET @BelgeId = CAST(SCOPE_IDENTITY() AS INT);
    END
    ELSE
        -- Gonderilmeyen alana DOKUNULMAZ (COALESCE ile mevcut deger korunur).
        UPDATE SIPARIS
           SET TIPI = COALESCE(@Tipi, TIPI), REHBERID = COALESCE(@RehberId, REHBERID),
               TARIH = COALESCE(@Tarih, TARIH), SIPARISTARIH = COALESCE(@STarih, SIPARISTARIH),
               SIPARISNO = COALESCE(@BelgeNo, SIPARISNO),
               SIPARISSERI = COALESCE(@BelgeSeri, SIPARISSERI),
               KOCANNO = COALESCE(@KocanNo, KOCANNO),
               GIRISDEPO = COALESCE(@GirisDepo, GIRISDEPO),
               CIKISDEPO = COALESCE(@CikisDepo, CIKISDEPO),
               KDVDURUM = COALESCE(@KdvDurum, KDVDURUM), KUR = COALESCE(@Kur, KUR),
               RAPORDOVIZ = COALESCE(@RaporDoviz, RAPORDOVIZ),
               DOVIZ_CINSI = COALESCE(@DovizCinsi, DOVIZ_CINSI),
               DOVIZKUR = COALESCE(@DovizKur, DOVIZKUR),
               ACIKLAMA = COALESCE(@Aciklama, ACIKLAMA),
               PROJEID = COALESCE(@ProjeId, PROJEID), VADE = COALESCE(@Vade, VADE),
               DURUM = COALESCE(@Durum, DURUM),
               DEGISTIREN = @KulId, DEGISTIRMETARIHI = GETDATE()
         WHERE ID = @BelgeId;

    -- ---------- Satirlar yaz ----------
    IF @SatirModu = N'tam'
        DELETE FROM SIPARISDETAY
         WHERE SIPARISID = @BelgeId
           AND ID NOT IN (SELECT ISNULL(SatirId, 0) FROM @S WHERE ISNULL(Sil, 0) = 0);

    DELETE SD FROM SIPARISDETAY SD
     INNER JOIN @S S ON S.SatirId = SD.ID
     WHERE SD.SIPARISID = @BelgeId AND S.Sil = 1;

    UPDATE SD
       SET SD.URUNID = S.UrunId, SD.TUR = S.Tur, SD.ADET = S.Adet, SD.MIKTAR = S.Miktar,
           SD.BIRIM = S.Birim, SD.BIRIMFIYAT = S.BirimFiyat, SD.TUTAR = S.Tutar,
           SD.KDV = S.Kdv, SD.ISKONTO = S.Iskonto, SD.ISKONTO2 = S.Iskonto2,
           SD.KUR = S.Kur, SD.DOVIZ_KURU = S.DovizKuru,
           SD.DOVIZ_BIRIMFIYAT = S.DovizBirimFiyat, SD.DOVIZKURDEGERI = S.DovizKurDegeri,
           SD.DOVIZ_TUTARI = S.DovizTutari, SD.ACIKLAMA = S.Aciklama,
           SD.PROJEID = S.ProjeId, SD.MASRAFID = S.MasrafId, SD.OZELKOD = S.OzelKod,
           SD.OZELKOD2 = S.OzelKod2, SD.IZLEME = S.Izleme,
           SD.YERI = COALESCE(S.Yeri, SD.YERI), SD.YERID = COALESCE(S.YerId, SD.YERID),
           SD.POZNO = S.PozNo, SD.EKIPMANID = S.EkipmanId, SD.MF = S.Mf,
           SD.MUHKODU = S.MuhKodu, SD.KASA = S.Kasa, SD.OTVYUZDE = S.OtvYuzde,
           SD.OTVMIKTAR = S.OtvMiktar, SD.IZLEMEKODU = S.IzlemeKodu, SD.VADE = S.Vade,
           SD.KAMPANYAID = S.KampanyaId,
           SD.TESLIMTARIHI = COALESCE(S.TeslimTarihi, SD.TESLIMTARIHI),
           SD.DEGISTIREN = @KulId, SD.DEGISTIRMETARIHI = GETDATE()
      FROM SIPARISDETAY SD INNER JOIN @S S ON S.SatirId = SD.ID
     WHERE SD.SIPARISID = @BelgeId AND ISNULL(S.Sil, 0) = 0;

    INSERT INTO SIPARISDETAY
        (SIPARISID, REHBERID, TUR, URUNID, ACIKLAMA, ADET, BIRIM, MIKTAR, BIRIMFIYAT,
         TUTAR, ISKONTO, ISKONTO2, KDV, MASRAFID, OZELKOD, OZELKOD2, MUHKODU, KASA,
         KUR, IZLEMEKODU, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT, DOVIZKURDEGERI,
         IZLEME, MF, YERI, YERID, POZNO, EKIPMANID, OTVYUZDE, OTVMIKTAR, VADE,
         PROJEID, KAMPANYAID, TESLIMTARIHI, SUBEID, EKLEYEN, EKLEMETARIHI)
    SELECT @BelgeId, @RehberId, S.Tur, S.UrunId, S.Aciklama, S.Adet, S.Birim, S.Miktar,
           S.BirimFiyat, S.Tutar, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId, S.OzelKod,
           S.OzelKod2, S.MuhKodu, S.Kasa, S.Kur, S.IzlemeKodu, S.DovizTutari,
           S.DovizKuru, S.DovizBirimFiyat, S.DovizKurDegeri, S.Izleme, S.Mf,
           S.Yeri, S.YerId, S.PozNo, S.EkipmanId, S.OtvYuzde, S.OtvMiktar, S.Vade,
           S.ProjeId, S.KampanyaId, S.TeslimTarihi, @SubeId, @KulId, GETDATE()
    FROM @S S
    WHERE ISNULL(S.Sil, 0) = 0 AND ISNULL(S.SatirId, 0) = 0;

    -- Yeni satirlarin ID'lerini sira ile geri esle (cagiran eslesme kurabilsin)
    ;WITH Y AS (
        SELECT SD.ID, sn = ROW_NUMBER() OVER (ORDER BY SD.ID)
        FROM SIPARISDETAY SD
        WHERE SD.SIPARISID = @BelgeId
          AND SD.EKLEMETARIHI >= DATEADD(SECOND, -5, GETDATE())
          AND NOT EXISTS (SELECT 1 FROM @S X WHERE X.SatirId = SD.ID)
    ), K AS (
        SELECT S.Sira, sn = ROW_NUMBER() OVER (ORDER BY S.Sira)
        FROM @S S WHERE ISNULL(S.Sil, 0) = 0 AND ISNULL(S.SatirId, 0) = 0
    )
    UPDATE S SET S.YeniId = Y.ID
      FROM @S S INNER JOIN K ON K.Sira = S.Sira INNER JOIN Y ON Y.sn = K.sn;

    -- ---------- Toplamlar ----------
    --   Uygulamanin kullandigi ayni formul: SP_PRG_Siparis_DipToplami.
    --   TUR 4 = Ara Toplam (matrah), 15 = KDV toplam, 20 = Genel toplam.
    --   Kolon sirasi SP'nin DONDURDUGU sirayla ayni olmali (INSERT ... EXEC
    --   ada gore degil KONUMA gore eslesir): TUR, ACIKLAMA, DEGER, KUR,
    --   DOVIZTUTARI, DOVIZ_KURU.
    DECLARE @T TABLE (TUR TINYINT, ACIKLAMA VARCHAR(255) COLLATE DATABASE_DEFAULT,
                      DEGER FLOAT, KUR VARCHAR(5) COLLATE DATABASE_DEFAULT,
                      DOVIZTUTARI FLOAT, DOVIZ_KURU VARCHAR(5) COLLATE DATABASE_DEFAULT);
    INSERT @T EXEC dbo.SP_PRG_Siparis_DipToplami @SIPARISID = @BelgeId;

    UPDATE SIPARIS
       SET SIPARIS_MATRAHI = ISNULL((SELECT TOP 1 DEGER FROM @T WHERE TUR = 4), 0),
           KDV_TUTARI      = ISNULL((SELECT TOP 1 DEGER FROM @T WHERE TUR = 15), 0),
           SIPARIS_TUTARI  = ISNULL((SELECT TOP 1 DEGER FROM @T WHERE TUR = 20), 0),
           DOVIZ_TUTARI    = ISNULL((SELECT TOP 1 DOVIZTUTARI FROM @T WHERE TUR = 20), 0)
     WHERE ID = @BelgeId;

    SET @BelgeIdOut = @BelgeId;

    IF @SonucDondur = 1
        SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Yeni AS YeniBelge,
                       (SELECT Sira, SatirId = ISNULL(SatirId, YeniId) FROM @S
                        WHERE ISNULL(Sil, 0) = 0 ORDER BY Sira FOR JSON PATH) AS Satirlar
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_belge_siparis_klonla_json  (kaynak: GenDepoUpdate142) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Siparis_Klonla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KaynakId INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakId') AS INT);
    DECLARE @Tarih    DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tarih')    AS DATETIME);
    DECLARE @RehberId INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT);
    DECLARE @KulId    INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @KaynakId IS NULL OR @KaynakId <= 0
        THROW 51001, N'KaynakId zorunlu.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.SIPARIS WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak sipariş bulunamadı.', 1;

    SET @Tarih = ISNULL(@Tarih, GETDATE());
    DECLARE @Tur INT = (SELECT TUR FROM dbo.SIPARIS WHERE ID = @KaynakId);

    -- SIPARIS NUMARASI: siparis kaydet API'si numara URETMEZ (cagirandan bekler;
    --   fatura tarafinda Kaydet kendi uretiyor). Eski Pascal yolu da burada
    --   SiradakiBelgeNumarasi cagiriyordu -> ayni isi klon SP'si yapar.
    DECLARE @Kocan INT = ISNULL((SELECT TOP 1 KOCANNO FROM dbo.KOCANAYARLARI
                                  WHERE TUR = @Tur AND SUBEID = @SubeId
                                    AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                  ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
    DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
    INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @Tur, @SubeID = @SubeId,
                                        @Kocanno = @Kocan, @BTarihi = @Tarih;
    DECLARE @No NVARCHAR(50), @Seri NVARCHAR(50);
    SELECT TOP 1 @No = BelgeNo, @Seri = BelgeSeri FROM @BN;

    -- Lot/seri izlemli satir varsa klonlanmaz (fatura klonuyla ayni kural).
    IF EXISTS (SELECT 1 FROM dbo.SIPARISDETAY WHERE SIPARISID = @KaynakId AND ISNULL(IZLEME, 0) <> 0)
        THROW 51200, N'Belge içeriğinde izlem bilgisi aktif ürünler var, bu işlem gerçekleştirilemez.', 1;

    ------------------------------------------------------------------ BASLIK
    DECLARE @Baslik NVARCHAR(MAX) =
    (
        SELECT
            Tur           = S.TUR,
            Tipi          = S.TIPI,
            Tarih         = CONVERT(NVARCHAR(19), @Tarih, 126),
            SiparisTarih  = CONVERT(NVARCHAR(19), @Tarih, 126),
            SiparisNo     = @No,
            SiparisSeri   = @Seri,
            KocanNo       = NULLIF(@Kocan, 0),
            RehberId      = ISNULL(@RehberId, S.REHBERID),
            GirisDepo     = S.GIRISDEPO,
            CikisDepo     = S.CIKISDEPO,
            KdvDurum      = S.KDVDURUM,
            Kur           = S.KUR,
            DovizCinsi    = S.DOVIZ_CINSI,
            DovizKur      = S.DOVIZKUR,
            RaporDoviz    = S.RAPORDOVIZ,
            Aciklama      = S.ACIKLAMA,
            OzelKod       = S.OZELKOD,
            ProjeId       = S.PROJEID,
            Vade          = S.VADE,
            Durum         = 0,                     -- klon TASLAK baslar
            Unvan         = S.BASLIK,
            Adres         = S.ADRES,
            Ilce          = S.ILCE,
            Il            = S.IL,
            Vd            = S.VD,
            Vno           = S.VNO,
            FiyatListesi  = S.FIYAT_LISTESI,
            SubeId        = S.SUBEID,
            AktiviteId    = S.AKTIVITEID,
            RehberIletId  = S.REHBERILETID,
            SaticiKodu    = S.SATICIKODU,
            DetayBolumu   = S.DETAYBOLUMU
        FROM dbo.SIPARIS S
        WHERE S.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    ------------------------------------------------------------------ SATIRLAR
    DECLARE @Satirlar NVARCHAR(MAX) =
    (
        SELECT
            Sira            = ROW_NUMBER() OVER (ORDER BY SD.ID),
            UrunId          = SD.URUNID,
            Tur             = SD.TUR,
            Adet            = SD.ADET,
            Miktar          = SD.MIKTAR,
            Birim           = SD.BIRIM,
            BirimFiyat      = SD.BIRIMFIYAT,
            Tutar           = SD.TUTAR,
            Kdv             = SD.KDV,
            Iskonto         = SD.ISKONTO,
            Iskonto2        = SD.ISKONTO2,
            Kur             = SD.KUR,
            DovizKuru       = SD.DOVIZ_KURU,
            DovizBirimFiyat = SD.DOVIZ_BIRIMFIYAT,
            DovizKurDegeri  = SD.DOVIZKURDEGERI,
            DovizTutari     = SD.DOVIZ_TUTARI,
            Aciklama        = SD.ACIKLAMA,
            ProjeId         = SD.PROJEID,
            MasrafId        = SD.MASRAFID,
            OzelKod         = SD.OZELKOD,
            OzelKod2        = SD.OZELKOD2,
            Izleme          = 0,                   -- lot/seri klona tasinmaz
            PozNo           = SD.POZNO,
            EkipmanId       = SD.EKIPMANID,
            Mf              = SD.MF,
            MuhKodu         = SD.MUHKODU,
            Kasa            = SD.KASA,
            -- OTVYUZDE bu tabloda BIT: FOR JSON true/false uretir, kaydet API'si
            --   FLOAT bekler -> 'nvarchar to float' hatasi. Sayiya cevir.
            OtvYuzde        = CAST(SD.OTVYUZDE AS INT),
            OtvMiktar       = SD.OTVMIKTAR,
            Vade            = SD.VADE,
            KampanyaId      = SD.KAMPANYAID,
            TeslimTarihi    = SD.TESLIMTARIHI
        FROM dbo.SIPARISDETAY SD
        WHERE SD.SIPARISID = @KaynakId
        ORDER BY SD.ID
        FOR JSON PATH
    );

    IF @Satirlar IS NULL
        THROW 51201, N'Kaynak siparişte satır yok, kopyalanacak içerik bulunamadı.', 1;

    ------------------------------------------------------------------ KAYDET
    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    EXEC dbo.sp_Api_Belge_Siparis_Kaydet_Json @Kosullar = @J,
         @BelgeIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0
        THROW 51202, N'Klon sipariş oluşturulamadı.', 1;

    -- ISLEMLOG izi: bu belge KOPYA (ALTISLEMTIPI=3), kaynagi @KaynakId.
    --   TabNo belge turune gore cozulur (log kart satiri hangi TABLOID ile yazildiysa).
    DECLARE @LogTabNo INT = (SELECT TOP 1 TABLOID FROM dbo.ISLEMLOG
                              WHERE KAYITID = @YeniId AND ISLEMTIPI = 1 ORDER BY ID DESC);
    IF @LogTabNo IS NOT NULL
        EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = @LogTabNo, @KayitId = @YeniId,
             @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = @LogTabNo;

    SELECT Sonuc    = 1,
           KaynakId = @KaynakId,
           BelgeId  = @YeniId,
           BelgeNo  = (SELECT SIPARISNO FROM dbo.SIPARIS WHERE ID = @YeniId),
           Tur      = @Tur,
           Satir    = (SELECT COUNT(*) FROM dbo.SIPARISDETAY WHERE SIPARISID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_belge_toplam_yaz_ic  (kaynak: GenDepoUpdate157) ----
-- ---- dbo.sp_Api_Belge_Toplam_Yaz_Ic ----

-- ---- dbo.sp_Api_Belge_Toplam_Yaz_Ic  (1 yer) ----

-- ============================================================
-- Toplam: hesap + yazma (sonuc kumesi DONDURMEZ)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Toplam_Yaz_Ic
    @BelgeId  INT,
    @Yaz      BIT = 1,
    @Zorla    BIT = 0,
    @Matrah   MONEY OUTPUT,
    @Kdv      MONEY OUTPUT,
    @Toplam   MONEY OUTPUT,
    @Doviz    MONEY OUTPUT,
    @Maliyet  MONEY OUTPUT,
    @EkVergi  MONEY OUTPUT,
    @Neden    NVARCHAR(60) OUTPUT,
    @Yazildi  BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Neden = N''; SET @Yazildi = 0;

    DECLARE @Tur INT, @Tipi INT, @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10), @EFatDurum INT;
    SELECT @Tur          = TUR,
           @Tipi         = ISNULL(TIPI, 0),
           @EkVergi      = ISNULL(EKVERGI, 0),
           @RaporDoviz   = ISNULL(RAPORDOVIZ, N'TL'),
           @FaturaDovizi = ISNULL(FATURADOVIZI, N'TL'),
           @EFatDurum    = ISNULL(EFATURADURUM, 0)
    FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL THROW 51002, N'Belge bulunamadi.', 1;

    -- Kapsam: gelen e-belge ve uretim fisinde formul gecersiz (bkz. GenDepoUpdate68)
    IF @EFatDurum <> 0 SET @Neden = N'gelen e-belge';
    ELSE IF @Tur = 6   SET @Neden = N'uretim fisi';

    SELECT @Matrah = CAST(MAX(CASE WHEN TUR = 4 THEN DEGER END) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId);
    IF @Matrah IS NULL
        SELECT @Matrah = CAST(SUM(DEGER) AS MONEY)
        FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 1;

    SELECT @Toplam = CAST(SUM(DEGER) AS MONEY),
           @Doviz  = CAST(SUM(DOVIZTUTARI) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 20;

    SET @Matrah = ISNULL(@Matrah, 0);
    SET @Toplam = ISNULL(@Toplam, 0);

    IF @Tipi IN (4, 7, 8)
    BEGIN
        SELECT @Kdv = CAST(SUM(DEGER) AS MONEY) FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 15;
        SET @Kdv    = ISNULL(@Kdv, 0);
        SET @Matrah = @Matrah - ABS(@EkVergi);
    END
    ELSE
        SET @Kdv = @Toplam - @Matrah;

    IF @RaporDoviz = N'TL' AND @FaturaDovizi = N'TL' SET @Doviz = @Toplam;
    SET @Doviz = ISNULL(@Doviz, @Toplam);

    SELECT @Maliyet = CAST(ISNULL(ROUND(SUM(F.MIKTAR * ISNULL(SOM.BIRIMMALIYET, 0.0)), 2), 0.0) AS MONEY)
    FROM FATURA F LEFT OUTER JOIN STOK_ORT_MALIYET SOM ON F.ID = SOM.FATURAID
    WHERE F.FATBASID = @BelgeId;
    SET @Maliyet = ISNULL(@Maliyet, 0);

    IF @Yaz = 1 AND (DATALENGTH(@Neden) = 0 OR @Zorla = 1)
    BEGIN
        UPDATE FATBASLIK
           SET FATURA_MATRAHI = @Matrah, KDV_TUTARI = @Kdv, FATURA_TUTARI = @Toplam,
               DOVIZ_TUTARI = @Doviz, FATURA_MALIYETI_ORT = @Maliyet
         WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END
END
GO

-- ---- PROCEDURE: sp_api_belge_toplamhesapla_json  (kaynak: GenDepoUpdate157) ----
-- ---- dbo.sp_Api_Belge_ToplamHesapla_Json ----

-- ---- dbo.sp_Api_Belge_ToplamHesapla_Json  (2 yer) ----

-- ---- dbo.sp_Api_Belge_ToplamHesapla_Json  (1 yer) ----


-- ============================================================
-- sp_Api_Belge_ToplamHesapla_Json
-- GIRDI : {"BelgeId":5567,"Yaz":1,"Zorla":0}
--         Yaz=0   -> yalniz hesapla, yazma
--         Zorla=1 -> kapsam disi belgede de YAZ (asagiya bak)
--
-- KAPSAM: Dip toplam formulu satirin BIRIMFIYAT*ADET degerinden hesaplar,
--   TUTAR kolonunu kullanmaz. Iki belge sinifinda bu gecersizdir:
--     1) GELEN e-Belge (EFATURADURUM <> 0): toplamlar tedarikcinin UBL'inden
--        gelir; satir BIRIMFIYAT/ADET eksik ya da farkli olcekte olabilir.
--        Ornek olcum (BILIM, 400 belge): 303 gelen e-belgenin 38'inde yeniden
--        hesap tutmadi.
--     2) URETIM FISI (TUR=6): birim fiyat yoktur, TUTAR maliyetten gelir;
--        yeniden hesap 0 uretir.
--   Bu belgelerde hesap YAPILIR ama YAZILMAZ; JSON'da Kapsam='disi' ve Neden
--   doner. Yazmak icin acikca Zorla=1 gerekir.
-- CIKTI : {"Sonuc":1,"BelgeId":..,"Matrah":..,"Kdv":..,"Toplam":..,
--          "Doviz":..,"Maliyet":..,"EkVergi":..}
-- HATA  : 51001 BelgeId eksik/gecersiz, 51002 belge bulunamadi
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_ToplamHesapla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Yaz     BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Yaz') AS BIT), 1);
    DECLARE @Zorla   BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Zorla') AS BIT), 0);

    IF @BelgeId IS NULL OR @BelgeId <= 0
        THROW 51001, N'BelgeId zorunlu.', 1;

    DECLARE @Tur INT, @Tipi INT, @EkVergi MONEY, @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10);
    DECLARE @EFatDurum INT, @Neden NVARCHAR(60) = N'';
    SELECT @EFatDurum = ISNULL(EFATURADURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;
    SELECT @Tur          = TUR,
           @Tipi         = ISNULL(TIPI, 0),
           @EkVergi      = ISNULL(EKVERGI, 0),
           @RaporDoviz   = ISNULL(RAPORDOVIZ, N'TL'),
           @FaturaDovizi = ISNULL(FATURADOVIZI, N'TL')
    FROM FATBASLIK WHERE ID = @BelgeId;

    IF @Tur IS NULL
        THROW 51002, N'Belge bulunamadi.', 1;

    -- Kapsam kontrolu (yukaridaki KAPSAM notu)
    IF @EFatDurum <> 0 SET @Neden = N'gelen e-belge';
    ELSE IF @Tur = 6   SET @Neden = N'uretim fisi';

    DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY;

    -- Matrah: once "Ara Toplam" (TUR=4: Toplam + OTV - Iskonto), yoksa "Toplam" (TUR=1).
    --   KDV Dahil belgede TVF zaten brutu ayirip NET matrah uretir (karar 2).
    SELECT @Matrah = CAST(MAX(CASE WHEN TUR = 4 THEN DEGER END) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId);
    IF @Matrah IS NULL
        SELECT @Matrah = CAST(SUM(DEGER) AS MONEY)
        FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 1;

    -- Genel Toplam (TUR=20). EKVERGI/stopaj bu toplama TVF icinde TUR=8/9
    --   satirlariyla ZATEN dahildir - burada TEKRAR eklenmez.
    SELECT @Toplam = CAST(SUM(DEGER) AS MONEY),
           @Doviz  = CAST(SUM(DOVIZTUTARI) AS MONEY)
    FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 20;

    SET @Matrah = ISNULL(@Matrah, 0);
    SET @Toplam = ISNULL(@Toplam, 0);

    -- KDV: stopajli belgelerde (TIPI 4/7/8 - serbest meslek makbuzu vb.) KDV
    --   dogrudan "KDV Toplam" satirindan alinir ve matrahtan stopaj dusulur
    --   (UFaturaWizard.FaturaTutarHesapla ile ayni kural); digerlerinde
    --   KDV = Genel Toplam - Matrah.
    IF @Tipi IN (4, 7, 8)
    BEGIN
        SELECT @Kdv = CAST(SUM(DEGER) AS MONEY)
        FROM dbo.fn_Api_Belge_DipToplam(@BelgeId) WHERE TUR = 15;
        SET @Kdv    = ISNULL(@Kdv, 0);
        SET @Matrah = @Matrah - ABS(@EkVergi);
    END
    ELSE
        SET @Kdv = @Toplam - @Matrah;

    -- Karar 4: TL belgede DOVIZ_TUTARI = TL toplam.
    IF @RaporDoviz = N'TL' AND @FaturaDovizi = N'TL'
        SET @Doviz = @Toplam;
    SET @Doviz = ISNULL(@Doviz, @Toplam);

    -- Ortalama maliyet: stok hareketi miktari (MIKTAR) uzerinden.
    SELECT @Maliyet = CAST(ISNULL(ROUND(SUM(F.MIKTAR * ISNULL(SOM.BIRIMMALIYET, 0.0)), 2), 0.0) AS MONEY)
    FROM FATURA F
        LEFT OUTER JOIN STOK_ORT_MALIYET SOM ON F.ID = SOM.FATURAID
    WHERE F.FATBASID = @BelgeId;
    SET @Maliyet = ISNULL(@Maliyet, 0);

    IF @Yaz = 1 AND (DATALENGTH(@Neden) = 0 OR @Zorla = 1)
        UPDATE FATBASLIK
           SET FATURA_MATRAHI      = @Matrah,
               KDV_TUTARI          = @Kdv,
               FATURA_TUTARI       = @Toplam,
               DOVIZ_TUTARI        = @Doviz,
               FATURA_MALIYETI_ORT = @Maliyet
         WHERE ID = @BelgeId;

    SELECT (SELECT 1        AS Sonuc,
                   @BelgeId AS BelgeId,
                   CASE WHEN DATALENGTH(@Neden) = 0 THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden   AS Neden,
                   CASE WHEN @Yaz = 1 AND (DATALENGTH(@Neden) = 0 OR @Zorla = 1) THEN 1 ELSE 0 END AS Yazildi,
                   @Matrah  AS Matrah,
                   @Kdv     AS Kdv,
                   @Toplam  AS Toplam,
                   @Doviz   AS Doviz,
                   @Maliyet AS Maliyet,
                   @EkVergi AS EkVergi
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_belgenogetir  (kaynak: GenDepoUpdate136) ----
CREATE OR ALTER PROCEDURE [dbo].[sp_BelgeNoGetir]
(
    @IslemTur INT,
    @SubeID   INT,
    @Kocanno  INT      = 0,
    @BTarihi  DATETIME = '2000-01-01'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BELGENO TABLE (KOCANNO INT, BELGESERI NVARCHAR(5), BELGENO NVARCHAR(20));

    DECLARE @AKocanno INT, @ABelgeseri NVARCHAR(5), @ABelgeno NVARCHAR(20), @UstTur INT,
            @Dijitsay INT, @BaslaNo NVARCHAR(25), @BasTarihi DATETIME;
    DECLARE @sqlCommand NVARCHAR(200), @NextValue INT;

    -- Sayac acik mi? (GENINI -24121)
    DECLARE @Sayac BIT = CASE WHEN ISNULL((SELECT TOP 1 DEGER FROM dbo.GENINI WHERE BOLUM = -24121), 0) = 1
                              THEN 1 ELSE 0 END;
    DECLARE @Kapsam NVARCHAR(80), @Kosul NVARCHAR(1000), @Basla BIGINT, @Yeni BIGINT;
    -- Cekirdek OUTPUT parametreli cagrilir: "INSERT ... EXEC" ic ice olamaz.
    DECLARE @SonNo BIGINT, @NoStr NVARCHAR(40);

    SET @Dijitsay = 0;

    SELECT @UstTur = CASE
        WHEN @IslemTur IN (21,22,23,24,25,26,27,28,29,88,130,141,142) THEN -101
        WHEN @IslemTur IN (31,32,33,34,35,36,37,38,98,125,131,137,140) THEN -102
        WHEN @IslemTur IN (40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
                           132,133,134,135,136,138,139,143,144,145,146,147,148,149) THEN -103
        ELSE @IslemTur END;

    IF @Kocanno IN (0, -99)
        SET @AKocanno = (SELECT TOP 1 KOCANNO FROM KOCANAYARLARI WHERE SUBEID = @SubeID AND TUR = @UstTur);
    ELSE
        SET @AKocanno = @Kocanno;

    ----------------------------------------------------------------- -3333: ID tabanli (degismedi)
    IF @AKocanno = -3333
    BEGIN
        SET @ABelgeseri = '';
        IF @UstTur IN (3, 4, 6, 8, 10, 11, 12, 14, 15, 16, 20, 39, 110, 116, 119, 222)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM FATBASLIK;
        ELSE IF @UstTur IN (9, 19, 101, 105)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM SIPARIS;
        ELSE IF @UstTur = 83
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM SERVIS;
        ELSE IF @UstTur IN (80, 81)
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM TEKLIF;
        ELSE IF @UstTur = 250
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM DOKUMAN;
        ELSE
            SELECT @ABelgeno = CONVERT(NVARCHAR(20), MAX(ID) + 1) FROM KASA;
    END
    ELSE IF @AKocanno <> 0
    BEGIN
        SELECT @ABelgeseri = SERINO, @BaslaNo = BASLANGICNO, @Dijitsay = LEN(BASLANGICNO),
               @BasTarihi = BASLANGICTARIHI
          FROM KOCANAYARLARI
         WHERE SUBEID = @SubeID AND TUR = @UstTur AND KOCANNO = @AKocanno;

        SET @Basla  = ISNULL(TRY_CAST(@BaslaNo AS BIGINT), 1);
        SET @Kapsam = N'T' + CAST(@UstTur AS NVARCHAR(10)) + N'|K' + CAST(@AKocanno AS NVARCHAR(10));
        -- Tarih suzgeci sayaca da GECER: tohumlama eski davranisla ayni MAX'i bulsun.
        DECLARE @TrhLit NVARCHAR(30) = N'''' + CONVERT(NVARCHAR(23), ISNULL(@BasTarihi, '19000101'), 126) + N'''';

        ------------------------------------------------------------- FATBASLIK
        IF @UstTur IN (3, 4, 6, 8, 10, 11, 12, 14, 15, 16, 20, 39, 110, 116, 119, 222)
        BEGIN
            SET @Kosul = N'FATURATARIH >= ' + @TrhLit + N' AND TUR = ' + CAST(@UstTur AS NVARCHAR(10)) +
                         N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) + N' AND ISNUMERIC(FATURANO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'FATBASLIK', 'FATURANO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), FATURANO)) + 1)
                                          FROM FATBASLIK
                                         WHERE FATURATARIH >= @BasTarihi AND TUR = @UstTur
                                           AND KOCANNO = @AKocanno AND ISNUMERIC(FATURANO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- SIPARIS
        ELSE IF @UstTur IN (9, 19, 101, 105)
        BEGIN
            SET @Kosul = N'SIPARISTARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(SIPARISNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'SIPARIS', 'SIPARISNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), SIPARISNO)) + 1)
                                          FROM SIPARIS
                                         WHERE SIPARISTARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(SIPARISNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- SERVIS
        ELSE IF @UstTur = 83
        BEGIN
            SET @Kosul = N'TARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(SERVISNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'SERVIS', 'SERVISNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), SERVISNO)) + 1)
                                          FROM SERVIS
                                         WHERE TARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(SERVISNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- TEKLIF
        ELSE IF @UstTur IN (80, 81)
        BEGIN
            SET @Kosul = N'TARIH >= ' + @TrhLit + N' AND KOCANNO = ' + CAST(@AKocanno AS NVARCHAR(10)) +
                         N' AND ISNUMERIC(TEKLIFNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'TEKLIF', 'TEKLIFNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), TEKLIFNO)) + 1)
                                          FROM TEKLIF
                                         WHERE TARIH >= @BasTarihi AND KOCANNO = @AKocanno
                                           AND ISNUMERIC(TEKLIFNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- URETIM EMRI
        ELSE IF @UstTur = 166
        BEGIN
            SET @Kosul = N'TALEPTARIHI >= ' + @TrhLit + N' AND ISNUMERIC(EMIRNO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'URETIMEMRI', 'EMIRNO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), EMIRNO)) + 1)
                                          FROM URETIMEMRI
                                         WHERE TALEPTARIHI >= @BasTarihi AND ISNUMERIC(EMIRNO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- DOKUMAN
        ELSE IF @UstTur = 250
        BEGIN
            SET @Kosul = N'EKLEMETARIHI >= ' + @TrhLit + N' AND ISNUMERIC(BELGENO) = 1';
            IF @Sayac = 1
            BEGIN
                EXEC dbo.sp_Prog_SiradakiNo_Ic 'DOKUMAN', 'BELGENO', @Kapsam, @Kosul, @Basla, 1, 0, 1, 1,
                     @Yeni OUTPUT, @SonNo OUTPUT, @NoStr OUTPUT;
                SET @ABelgeno = CONVERT(NVARCHAR(20), @Yeni);
            END
            ELSE
                SET @ABelgeno = ISNULL((SELECT CONVERT(NVARCHAR(20), MAX(CONVERT(DECIMAL(24,0), BELGENO)) + 1)
                                          FROM DOKUMAN
                                         WHERE EKLEMETARIHI >= @BasTarihi AND ISNUMERIC(BELGENO) = 1), @BaslaNo);
        END
        ------------------------------------------------------------- KASA/CEK/SENET: SEQUENCE (zaten atomik)
        ELSE IF @UstTur IN (-103, -102, -101)
        BEGIN
            SET @sqlCommand = N'select @NextValue = NEXT VALUE FOR dbo.seq_' + CONVERT(NVARCHAR(20), @AKocanno);
            EXECUTE sp_executesql @sqlCommand, N'@AKocanno int, @NextValue int OUTPUT',
                    @AKocanno = @AKocanno, @NextValue = @NextValue OUTPUT;
            SET @ABelgeno = CONVERT(NVARCHAR(20), @NextValue);
        END
    END

    WHILE LEN(@ABelgeno) < @Dijitsay
        SET @ABelgeno = '0' + @ABelgeno;

    INSERT INTO @BELGENO (KOCANNO, BELGESERI, BELGENO)
    VALUES (@AKocanno, @ABelgeseri, @ABelgeno);

    SELECT * FROM @BELGENO;
END
GO

-- ---- PROCEDURE: sp_prg_faturadiptoplami  (kaynak: GenDepoUpdate68) ----
-- ============================================================
-- SP_PRG_FaturaDipToplami — geriye donuk govde; formul artik TVF'te.
--   Delphi (UFaturaWizard.TOPLAMLAR) bu SP'yi cagirmaya devam eder.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.SP_PRG_FaturaDipToplami (@FATBASID INT)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TUR, ACIKLAMA, DEGER, DOVIZTUTARI, KUR, DOVIZ_KURU, DOVIZKUR, KDVMUHAFIYETI, FATURADOVIZI
    FROM dbo.fn_Api_Belge_DipToplam(@FATBASID);
END
GO

-- ---- PROCEDURE: sp_prog_belge_kaynakdurum_json  (kaynak: GenDepoUpdate101) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Belge_KaynakDurum_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.belgeId') AS INT);
    -- listele=1: HESAPLAMAZ, yalniz kaynak listesini dondurur. SILME yolunda
    --   kullanilir: hedef silinince YERI/YERID bagi kaybolur, bu yuzden cagiran
    --   silmeden ONCE listeyi alir, silme sonrasi "kaynaklar" ile geri gonderir.
    DECLARE @Listele BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.listele') AS BIT), 0);

    DECLARE @K TABLE (Kaynak NVARCHAR(10), BaslikId INT, PRIMARY KEY (Kaynak, BaslikId));

    -- ---------- 1) Hedef belgenin satirlarindaki baglardan ----------
    IF ISNULL(@BelgeId, 0) > 0
        INSERT @K (Kaynak, BaslikId)
        SELECT DISTINCT
               CASE WHEN R.KaynakDetayTablo = 'SIPARISDETAY' THEN N'siparis' ELSE N'belge' END,
               CASE WHEN R.KaynakDetayTablo = 'SIPARISDETAY' THEN SD.SIPARISID ELSE FK.FATBASID END
        FROM dbo.FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R ON R.DonusumTuru = F.YERI
             LEFT JOIN dbo.SIPARISDETAY SD ON R.KaynakDetayTablo = 'SIPARISDETAY' AND SD.ID = F.YERID
             LEFT JOIN dbo.FATURA      FK ON R.KaynakDetayTablo = 'FATURA'       AND FK.ID = F.YERID
        WHERE F.FATBASID = @BelgeId
          AND ISNULL(F.YERID, 0) > 0
          AND ISNULL(CASE WHEN R.KaynakDetayTablo = 'SIPARISDETAY' THEN SD.SIPARISID ELSE FK.FATBASID END, 0) > 0;

    -- ---------- 2) Cagiranin dogrudan verdikleri (silme yolu) ----------
    INSERT @K (Kaynak, BaslikId)
    SELECT DISTINCT LOWER(J.Kaynak), J.BaslikId
    FROM OPENJSON(@Kosullar, '$.kaynaklar')
         WITH (Kaynak NVARCHAR(10) '$.kaynak', BaslikId INT '$.baslikId') J
    WHERE ISNULL(J.BaslikId, 0) > 0
      AND LOWER(ISNULL(J.Kaynak, N'')) IN (N'siparis', N'belge')
      AND NOT EXISTS (SELECT 1 FROM @K K2
                      WHERE K2.Kaynak = LOWER(J.Kaynak) AND K2.BaslikId = J.BaslikId);

    IF @Listele = 1
    BEGIN
        SELECT (SELECT 1 AS Sonuc,
                       ISNULL((SELECT Kaynak AS kaynak, BaslikId AS baslikId
                               FROM @K FOR JSON PATH), N'[]') AS Kaynaklar
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- 3) Her kaynak icin yeniden hesapla ----------
    DECLARE @Sonuc TABLE (Kaynak NVARCHAR(10), BaslikId INT, Durum INT,
                          OncekiDurum INT, Yazildi BIT);

    DECLARE @Kay NVARCHAR(10), @Bid INT;
    DECLARE @Tur INT, @Durum INT, @Onceki INT, @Satir INT, @Tam INT, @Kis INT,
            @Acik INT, @Neden NVARCHAR(60), @Yazildi BIT;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Kaynak, BaslikId FROM @K;
    OPEN c; FETCH NEXT FROM c INTO @Kay, @Bid;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @Bid, @Kaynak = @Kay, @Yaz = 1,
             @Tur = @Tur OUTPUT, @Durum = @Durum OUTPUT, @OncekiDurum = @Onceki OUTPUT,
             @Satir = @Satir OUTPUT, @Tamamlanan = @Tam OUTPUT, @Kismi = @Kis OUTPUT,
             @Acik = @Acik OUTPUT, @Neden = @Neden OUTPUT, @Yazildi = @Yazildi OUTPUT;

        INSERT @Sonuc (Kaynak, BaslikId, Durum, OncekiDurum, Yazildi)
        VALUES (@Kay, @Bid, @Durum, @Onceki, @Yazildi);

        FETCH NEXT FROM c INTO @Kay, @Bid;
    END
    CLOSE c; DEALLOCATE c;

    SELECT (SELECT 1 AS Sonuc,
                   (SELECT COUNT(*) FROM @Sonuc WHERE Yazildi = 1) AS Guncellenen,
                   (SELECT Kaynak, BaslikId, Durum, OncekiDurum, Yazildi
                    FROM @Sonuc FOR JSON PATH) AS Kaynaklar
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_prog_siradakino  (kaynak: GenDepoUpdate135) ----
-- ORTAK CAGRI YUZU: cekirdegi cagirir, tek satirlik sonuc doner (app/Pascal bunu kullanir).
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo
    @Tablo     sysname,
    @Alan      sysname,
    @Kapsam    NVARCHAR(80)   = N'',
    @Kosul     NVARCHAR(1000) = NULL,
    @Baslangic BIGINT         = 1,
    @Adet      INT            = 1,
    @Dijit     INT            = 0,
    @Rezerve   BIT            = 1,
    @Dogrula   BIT            = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ilk BIGINT, @Son BIGINT, @No NVARCHAR(40), @Anahtar NVARCHAR(200);
    EXEC dbo.sp_Prog_SiradakiNo_Ic @Tablo, @Alan, @Kapsam, @Kosul, @Baslangic, @Adet,
         @Dijit, @Rezerve, @Dogrula, @Ilk OUTPUT, @Son OUTPUT, @No OUTPUT, @Anahtar OUTPUT;
    SELECT ILKNO = @Ilk, SONNO = @Son, NO = @No, ANAHTAR = @Anahtar;
END
GO

-- ---- PROCEDURE: sp_prog_siradakino_ayarla  (kaynak: GenDepoUpdate135) ----
-- ============================================================
-- AYARLA: yonetici. Sayaci kurar/duzeltir (@Deger = son kullanilan numara).
--   @Deger NULL ise gercek tablodan MAX ile yeniden tohumlar.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo_Ayarla
    @Tablo  sysname,
    @Alan   sysname,
    @Kapsam NVARCHAR(80)   = N'',
    @Kosul  NVARCHAR(1000) = NULL,
    @Deger  BIGINT         = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(@Tablo) IS NULL       THROW 51301, N'Sayac icin tablo bulunamadi.', 1;
    IF COL_LENGTH(@Tablo, @Alan) IS NULL THROW 51302, N'Sayac icin kolon bulunamadi.', 1;

    DECLARE @Anahtar NVARCHAR(200) = @Tablo + N'.' + @Alan +
                                     CASE WHEN ISNULL(@Kapsam, N'') = N'' THEN N'' ELSE N'|' + @Kapsam END;

    IF @Deger IS NULL
    BEGIN
        DECLARE @SQL NVARCHAR(MAX) =
            N'SELECT @m = ISNULL(MAX(TRY_CAST(' + QUOTENAME(@Alan) + N' AS BIGINT)), 0) FROM ' + @Tablo +
            CASE WHEN ISNULL(@Kosul, N'') = N'' THEN N'' ELSE N' WHERE ' + @Kosul END;
        EXEC sp_executesql @SQL, N'@m BIGINT OUTPUT', @m = @Deger OUTPUT;
    END

    UPDATE dbo.SAYAC SET SONNO = @Deger, KAPSAM = @Kapsam, GUNCELLEME = GETDATE()
     WHERE ANAHTAR = @Anahtar;

    IF @@ROWCOUNT = 0
        INSERT INTO dbo.SAYAC (ANAHTAR, TABLOADI, ALANADI, KAPSAM, SONNO, GUNCELLEME)
        VALUES (@Anahtar, @Tablo, @Alan, @Kapsam, @Deger, GETDATE());

    SELECT ANAHTAR = @Anahtar, SONNO = @Deger;
END
GO

-- ---- PROCEDURE: sp_prog_siradakino_iade  (kaynak: GenDepoUpdate135) ----
-- ============================================================
-- IADE: belge kaydedilmediyse SON numarayi geri ver (bosluk olusmasin).
--   Yalnizca iade edilen numara sayacin son degeriyse geri alinir; arada baska
--   kullanici numara aldiysa dokunulmaz (o zaman bosluk kacinilmazdir).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo_Iade
    @Tablo  sysname,
    @Alan   sysname,
    @Kapsam NVARCHAR(80) = N'',
    @No     BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Anahtar NVARCHAR(200) = @Tablo + N'.' + @Alan +
                                     CASE WHEN ISNULL(@Kapsam, N'') = N'' THEN N'' ELSE N'|' + @Kapsam END;
    DECLARE @Alindi BIT = 0;

    UPDATE dbo.SAYAC
       SET SONNO = SONNO - 1, GUNCELLEME = GETDATE(), @Alindi = 1
     WHERE ANAHTAR = @Anahtar AND SONNO = @No;

    SELECT IADE = @Alindi;
END
GO

-- ---- PROCEDURE: sp_prog_siradakino_ic  (kaynak: GenDepoUpdate135) ----
-- ============================================================
-- SIRADAKI NUMARA (atomik)
--   @Tablo/@Alan : numaranin tutuldugu gercek tablo/kolon (tohumlama + dogrulama icin)
--   @Kapsam      : ayni kolonun bagimsiz sayaclari (ornek 'T14|S-1|K1401')
--   @Kosul       : tohumlama/dogrulama WHERE'i (kocan/tarih/tur suzgeci) - opsiyonel
--   @Baslangic   : kocan baslangic numarasi (BASLANGICNO)
--   @Adet        : blok tahsis (toplu satir ekleme)
--   @Dijit       : sifir dolgusu (000123)
--   @Rezerve     : 1 = kalici tahsis (atomik), 0 = sadece bak (eski davranis, yarissiz DEGIL)
--   @Dogrula     : 1 = tahsis edilen numara tabloda varsa atla (eski kodla birlikte yasarken)
-- CIKTI: ILKNO, SONNO, NO (dolgulu metin)
-- ============================================================
-- CEKIRDEK: result set DONDURMEZ, OUTPUT parametre verir.
--   Neden: SQL Server'da "INSERT ... EXEC" IC ICE OLAMAZ. sp_BelgeNoGetir gibi
--   cagiranlar sonucu tabloya almak zorunda kalmasin diye cekirdek ayrildi.
CREATE OR ALTER PROCEDURE dbo.sp_Prog_SiradakiNo_Ic
    @Tablo     sysname,
    @Alan      sysname,
    @Kapsam    NVARCHAR(80)   = N'',
    @Kosul     NVARCHAR(1000) = NULL,
    @Baslangic BIGINT         = 1,
    @Adet      INT            = 1,
    @Dijit     INT            = 0,
    @Rezerve   BIT            = 1,
    @Dogrula   BIT            = 1,
    @Ilk       BIGINT         OUTPUT,
    @Son       BIGINT         OUTPUT,
    @No        NVARCHAR(40)   OUTPUT,
    @AnahtarOut NVARCHAR(200) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID(@Tablo) IS NULL
        THROW 51301, N'Sayac icin tablo bulunamadi.', 1;
    IF COL_LENGTH(@Tablo, @Alan) IS NULL
        THROW 51302, N'Sayac icin kolon bulunamadi.', 1;
    IF ISNULL(@Adet, 0) < 1 SET @Adet = 1;

    DECLARE @Anahtar NVARCHAR(200) = @Tablo + N'.' + @Alan +
                                     CASE WHEN ISNULL(@Kapsam, N'') = N'' THEN N'' ELSE N'|' + @Kapsam END;
    DECLARE @Nerede NVARCHAR(1010) = CASE WHEN ISNULL(@Kosul, N'') = N'' THEN N'' ELSE N' WHERE ' + @Kosul END;
    DECLARE @SQL NVARCHAR(MAX), @Mevcut BIGINT;
    SET @AnahtarOut = @Anahtar;

    ------------------------------------------------------------------ tohumlama
    -- Sayac yoksa GERCEK tablodan MAX ile kurulur -> eski verilerle carpismaz.
    IF NOT EXISTS (SELECT 1 FROM dbo.SAYAC WHERE ANAHTAR = @Anahtar)
    BEGIN
        SET @SQL = N'SELECT @m = ISNULL(MAX(TRY_CAST(' + QUOTENAME(@Alan) + N' AS BIGINT)), 0) FROM ' +
                   @Tablo + @Nerede;
        BEGIN TRY
            EXEC sp_executesql @SQL, N'@m BIGINT OUTPUT', @m = @Mevcut OUTPUT;
        END TRY
        BEGIN CATCH
            SET @Mevcut = 0;   -- kolon metin/karisik ise tohum @Baslangic'ten
        END CATCH

        DECLARE @Tohum BIGINT = CASE WHEN ISNULL(@Mevcut, 0) > @Baslangic - 1
                                     THEN @Mevcut ELSE @Baslangic - 1 END;

        -- Es zamanli ilk cagriya dayanikli: varsa dokunma.
        INSERT INTO dbo.SAYAC (ANAHTAR, TABLOADI, ALANADI, KAPSAM, SONNO, GUNCELLEME)
        SELECT @Anahtar, @Tablo, @Alan, @Kapsam, @Tohum, GETDATE()
        WHERE NOT EXISTS (SELECT 1 FROM dbo.SAYAC WITH (UPDLOCK, HOLDLOCK) WHERE ANAHTAR = @Anahtar);
    END

    ------------------------------------------------------------------ tahsis
    DECLARE @C TABLE (ILK BIGINT, SON BIGINT);

    IF @Rezerve = 1
    BEGIN
        -- TEK deyim: okuma+yazma atomik, ayrica transaction gerekmez.
        UPDATE dbo.SAYAC
           SET SONNO = SONNO + @Adet,
               GUNCELLEME = GETDATE()
        OUTPUT deleted.SONNO + 1, inserted.SONNO INTO @C (ILK, SON)
        WHERE ANAHTAR = @Anahtar;
    END
    ELSE
    BEGIN
        -- Sadece bak (eski davranis): yazmaz, dolayisiyla yarisi COZMEZ.
        INSERT @C (ILK, SON)
        SELECT SONNO + 1, SONNO + @Adet FROM dbo.SAYAC WHERE ANAHTAR = @Anahtar;
    END

    SELECT @Ilk = ILK, @Son = SON FROM @C;

    ------------------------------------------------------------------ carpisma kontrolu
    -- Eski kod yollari hala max()+1 ile yaziyor olabilir; tahsis edilen numara
    -- gercekten kullanilmissa bir sonrakine gec (en fazla 1000 deneme).
    IF @Dogrula = 1 AND @Rezerve = 1 AND @Adet = 1
    BEGIN
        DECLARE @Var BIT = 1, @Deneme INT = 0;
        WHILE @Var = 1 AND @Deneme < 1000
        BEGIN
            SET @Var = 0;
            SET @SQL = N'SELECT @v = 1 WHERE EXISTS (SELECT 1 FROM ' + @Tablo +
                       N' WHERE TRY_CAST(' + QUOTENAME(@Alan) + N' AS BIGINT) = @n' +
                       CASE WHEN ISNULL(@Kosul, N'') = N'' THEN N'' ELSE N' AND (' + @Kosul + N')' END + N')';
            BEGIN TRY
                EXEC sp_executesql @SQL, N'@n BIGINT, @v BIT OUTPUT', @n = @Ilk, @v = @Var OUTPUT;
            END TRY
            BEGIN CATCH
                SET @Var = 0;
            END CATCH

            IF ISNULL(@Var, 0) = 1
            BEGIN
                UPDATE dbo.SAYAC SET SONNO = SONNO + 1, GUNCELLEME = GETDATE()
                 OUTPUT inserted.SONNO INTO @C (SON)          -- (bilgi amacli)
                 WHERE ANAHTAR = @Anahtar AND SONNO = @Son;

                SET @Ilk = @Ilk + 1;
                SET @Son = @Son + 1;
                SET @Deneme = @Deneme + 1;
            END
        END
    END

    ------------------------------------------------------------------ cikti
    SET @No = CAST(@Ilk AS NVARCHAR(40));
    IF ISNULL(@Dijit, 0) > LEN(@No)
        SET @No = REPLICATE(N'0', @Dijit - LEN(@No)) + @No;
END
GO

-- ---- PROCEDURE: sp_prog_uretimfisi_olustur_json  (kaynak: GenDepoUpdate115) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_UretimFisi_Olustur_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tarih     DATETIME = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.tarih') AS DATETIME), GETDATE());
    DECLARE @Yeri      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.yeri')      AS INT);
    DECLARE @YerId     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.yerId')     AS INT);
    DECLARE @ReceteId  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.receteId')  AS INT);
    DECLARE @GirisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.girisDepo') AS INT), 0);
    DECLARE @CikisDepo INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.cikisDepo') AS INT), 0);
    DECLARE @Miktar    DECIMAL(18,6) = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.miktar') AS DECIMAL(18,6)), 1);
    DECLARE @SubeId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.subeId') AS INT), 0);
    DECLARE @KulId     INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.kullaniciId') AS INT), 0);
    DECLARE @Kur       NVARCHAR(10) = ISNULL(JSON_VALUE(@Kosullar, '$.kur'), N'TL');

    IF ISNULL(@ReceteId, 0) <= 0
    BEGIN
        SELECT (SELECT 0 AS Sonuc, 0 AS BelgeId, N'Recete belirtilmedi.' AS Mesaj
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Recete ----------
    DECLARE @Kod NVARCHAR(50), @Ad NVARCHAR(255), @StokId INT, @Birim INT;
    SELECT @Kod = UR.KOD, @Ad = UR.AD, @StokId = UR.STOKID,
           @Birim = ISNULL((SELECT S.ANABIRIM FROM STOKLAR S WHERE S.ID = UR.STOKID), 0)
    FROM URETIMRECETE UR WHERE UR.ID = @ReceteId;

    IF @StokId IS NULL
    BEGIN
        SELECT (SELECT 0 AS Sonuc, 0 AS BelgeId, N'Recete bulunamadi.' AS Mesaj
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM URETIMRECETEDETAY WHERE URETIMRECETEID = @ReceteId)
    BEGIN
        SELECT (SELECT 0 AS Sonuc, 0 AS BelgeId, N'Recetenin detay satirlari yok.' AS Mesaj
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Belge no ----------
    -- Kolon sirasi sp_BelgeNoGetir'in DONDURDUGU sirayla ayni olmali
    --   (INSERT ... EXEC ada gore degil KONUMA gore eslesir).
    DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
    DECLARE @BelgeNo NVARCHAR(50), @BelgeSeri NVARCHAR(50), @KocanNo INT = 0;
    INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = 6, @SubeID = -1,
                                        @Kocanno = @KocanNo, @BTarihi = @Tarih;
    SELECT TOP 1 @BelgeNo = BelgeNo, @BelgeSeri = BelgeSeri FROM @BN;

    -- ---------- Kaydet JSON ----------
    --   FIYATLAR 0: birim fiyat / tutar / doviz alanlari sifir gonderiliyor.
    DECLARE @Baslik NVARCHAR(MAX) =
        (SELECT 6 AS Tur, 1 AS Tipi, 0 AS RehberId,
                @Tarih AS Tarih, @Tarih AS FaturaTarih,
                @BelgeNo AS FaturaNo, @BelgeSeri AS FaturaSeri,
                @GirisDepo AS GirisDepo, @CikisDepo AS CikisDepo,
                N'Muaf' AS KdvDurum, @Kur AS Kur, @Kur AS RaporDoviz,
                @SubeId AS SubeId,
                LEFT(ISNULL(@Kod, N'') + N' - ' + ISNULL(@Ad, N''), 200) AS Aciklama
         FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    DECLARE @Satirlar NVARCHAR(MAX) =
        (SELECT ROW_NUMBER() OVER (ORDER BY URD.ID)        AS Sira,
                URD.URUNID                                  AS UrunId,
                ISNULL(URD.TUR, 1)                          AS Tur,
                CAST(ISNULL(URD.ADET, 0)   * @Miktar AS decimal(18,6)) AS Adet,
                CAST(ISNULL(URD.MIKTAR, 0) * @Miktar AS decimal(18,6)) AS Miktar,
                ISNULL(URD.BIRIM, 0)                        AS Birim,
                CAST(0 AS decimal(18,6))                    AS BirimFiyat,
                CAST(0 AS decimal(18,6))                    AS Tutar,
                CAST(0 AS decimal(18,6))                    AS DovizBirimFiyat,
                CAST(0 AS decimal(18,6))                    AS DovizTutari,
                ISNULL(S.KDV, 0)                            AS Kdv,
                URD.ACIKLAMA                                AS Aciklama,
                URD.MASRAFID                                AS MasrafId,
                ISNULL(S.IZLEME, 0)                         AS Izleme,
                1                                           AS StokDurumDegis,
                139                                         AS Yeri,   -- TabNo_URETIMRECETEDETAY
                URD.ID                                      AS YerId
         FROM URETIMRECETEDETAY URD
              LEFT JOIN STOKLAR S ON S.ID = URD.URUNID
         WHERE URD.URETIMRECETEID = @ReceteId
         ORDER BY URD.ID
         FOR JSON PATH);

    DECLARE @Json NVARCHAR(MAX) =
        N'{"Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar +
        N',"SatirModu":"delta","Oturum":{"KulId":' + CAST(@KulId AS nvarchar(12)) + N'}}';

    DECLARE @BelgeId INT;
    EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @Json, @BelgeIdOut = @BelgeId OUTPUT,
         @SonucDondur = 0;

    IF ISNULL(@BelgeId, 0) = 0
        THROW 51200, N'Uretim fisi olusturulamadi.', 1;

    -- ---------- Uretim fisine OZGU baslik alanlari ----------
    --   Kaydet bunlari bilmez; anlamlari eski akistan AYNEN devralindi.
    UPDATE FATBASLIK
       SET YERI       = @Yeri,
           YERID      = @YerId,
           ANAKAYITID = @ReceteId,     -- hangi receteden uretildi
           AKTIVITEID = @StokId,       -- recetenin urunu
           STOKISK    = @Miktar,       -- uretim miktari
           SAYFA      = @Birim,        -- urunun ana birimi
           LOKASYON   = 0, ISYERI = 0
     WHERE ID = @BelgeId;

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @BelgeNo AS BelgeNo,
                   (SELECT COUNT(*) FROM FATURA WHERE FATBASID = @BelgeId) AS SatirSayisi
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- TRIGGER: trg_fatura_masrafid_guncelle  (kaynak: GenDepoUpdate87) ----
-- ============================================================
-- FATURA: masraf/gelir satirinda MASRAFID bos ise URUNID ile doldur.
--   Eski hali: SELECT @FATBASID=I.FATBASID, ... FROM inserted I  -> tek satir.
-- ============================================================
CREATE OR ALTER TRIGGER [dbo].[Trg_Fatura_MasrafID_Guncelle]
ON [dbo].[FATURA]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Set bazli: eklenen TUM satirlar islenir. Kosul eskisiyle ayni
    --   (MASRAFID bos VE TUR = 0, yani masraf/gelir satiri).
    UPDATE F
       SET MASRAFID = F.URUNID
      FROM FATURA F
           INNER JOIN inserted I ON I.ID = F.ID
     WHERE ISNULL(I.MASRAFID, 0) = 0
       AND ISNULL(I.TUR, 0) = 0;
END
GO
