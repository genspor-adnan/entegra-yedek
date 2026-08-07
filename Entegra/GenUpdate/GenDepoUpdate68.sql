-- ============================================================
-- GenDepoUpdate68.sql
-- API 1. dalga: belge dip toplami TEK kaynaktan.
--
-- Bugun ayni isi 9 ayri yer kendi formuluyle yapiyor (UFaturaWizard,
--   Ubelgegiris, UEBelgeGelen, UHizliGiris, UHizliGunsonuDlg, UImport,
--   UReplikasyon, UGiderPusulasi + mobil TM_FATURAGir).
--   Karsilastirma ve kararlar: SP/TOPLAM_FORMUL_KARSILASTIRMA.md
--
-- 1) dbo.fn_Api_Belge_DipToplam   : KANONIK formul (SP_PRG_FaturaDipToplami
--    govdesinin TVF hali). SP cagrisi "INSERT EXEC cannot be nested" hatasi
--    verdigi icin baska SP'lerden kullanilabilsin diye TVF'e alindi.
-- 2) dbo.SP_PRG_FaturaDipToplami  : artik TVF'i okur (davranis AYNI;
--    200 belge / 1230 satirda birebir dogrulandi).
-- 3) dbo.sp_Api_Belge_ToplamHesapla_Json : FATBASLIK toplamlarini yazar.
--
-- KARARLAR (07.08.2026):
--   1) TUTAR kolonu ISKONTO2'yi ICERIR (carpimsal iskonto).
--   2) KDV Dahil belgede FATURA_MATRAHI = NET MATRAH.
--   3) Tutar hesabi ADET uzerinden; maliyet MIKTAR ile kalir.
--   4) DOVIZ_TUTARI TL belgede TL toplam yazar (0 degil).
--   5) Iskonto her yerde carpimsal.
--
-- 08.08.2026 DUZELTME - KDV tabani ISKONTO2:
--   TUR=5 (KDV) dalinin tabani yalnizca ISKONTO'yu dusuyordu; TUR=3 (Iskonto)
--   dali ise hem ISKONTO hem ISKONTO2 uyguluyordu. Sonuc: ikinci iskontolu
--   satirda matrah ikinci iskontolu, KDV tabani iskontosuz kaliyor ve KDV/genel
--   toplam FAZLA cikiyordu (bkz. SP/TOPLAM_FORMUL_KARSILASTIRMA.md §7).
--   Karar 1 ("TUTAR ISKONTO2'yi icerir") ile tutarli hale getirildi: TUR=5
--   blogundaki 7 taban ifadesine *(100-ISKONTO2)/100 eklendi.
--   Hicbir musteri DB'sinde ISKONTO2 dolu satir yok -> yururlukteki hicbir
--   belge etkilenmez; degisiklik ikinci iskonto kullanilinca devreye girer.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

    IF @Yaz = 1 AND (@Neden = N'' OR @Zorla = 1)
        UPDATE FATBASLIK
           SET FATURA_MATRAHI      = @Matrah,
               KDV_TUTARI          = @Kdv,
               FATURA_TUTARI       = @Toplam,
               DOVIZ_TUTARI        = @Doviz,
               FATURA_MALIYETI_ORT = @Maliyet
         WHERE ID = @BelgeId;

    SELECT (SELECT 1        AS Sonuc,
                   @BelgeId AS BelgeId,
                   CASE WHEN @Neden = N'' THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden   AS Neden,
                   CASE WHEN @Yaz = 1 AND (@Neden = N'' OR @Zorla = 1) THEN 1 ELSE 0 END AS Yazildi,
                   @Matrah  AS Matrah,
                   @Kdv     AS Kdv,
                   @Toplam  AS Toplam,
                   @Doviz   AS Doviz,
                   @Maliyet AS Maliyet,
                   @EkVergi AS EkVergi
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_ToplamHesapla_Json TO gentegre_api;
GO
