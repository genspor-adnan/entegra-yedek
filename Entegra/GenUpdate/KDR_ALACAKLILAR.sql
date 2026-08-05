/* ============================================================================
   KDR_ALACAKLILAR.sql  —  MUSTERI ANA veritabaninda calistirilir

   "KDR_ALACAKLILAR" karar destek raporunun DOGRU sorgusunu DOKUMLER tablosuna yazar
   (varsa gunceller, yoksa ekler).

   BU SURUMDE DUZELTILEN 3 SORUN:
   1) TURKCE HARF KAYBI: metindeki Turkce harfler bazi kurulumlarda '?' olmustu
      (KDR_ALINAN_?EK, KDR_KRED?LER, 'Konsinye ??k??'). '?' ODBC'de PARAMETRE
      ISARETI oldugu icin FireDAC her '?' icin parametre bekliyor, uygulama
      beklenen sayida vermedigi icin
         "COUNT field incorrect or syntax error"
      hatasi olusuyor ve ekran hic acilmiyordu. Ayrica bozuk KOLON ADLARI
      ekrandaki tile bilesenleriyle eslesmedigi icin degerler bos kaliyordu.
   2) KDR_BORCLULAR'da 'R.KDR_Disi' yaziyordu; bu kolon REHBER'de DEGIL
      REHBER_USER tablosundadir -> "Invalid column name 'KDR_Disi'" ile rapor
      hic calismiyordu. Diger iki rapordaki gibi REHBER_USER join'i eklendi.
   3) KDR_Disi ("karar destek raporlarina dahil etme") filtresi LEFT JOIN'in
      ON kismindaydi: LEFT JOIN'de ON kosulu satiri ELEMEZ, sadece eslesmeyi
      engeller -> isaretli cariler raporda gorunmeye devam ediyordu. Kosul
      WHERE'e tasindi, artik gercekten haric tutuluyor.

   NOT: Dosya UTF-8 (BOM) kodludur. sqlcmd ile calistirirken  -f 65001  ZORUNLU:
        sqlcmd -S SUNUCU -d MUSTERIDB -U sa -P *** -C -f 65001 -i KDR_ALACAKLILAR.sql
        (BOM tek basina yetmez; verilmezse Turkce harfler yeniden bozulur.)

   Idempotent: tekrar calistirmak zararsizdir.
============================================================================ */
SET NOCOUNT ON;

DECLARE @Rapor  sysname       = N'KDR_ALACAKLILAR';
DECLARE @Grubu  nvarchar(200) = N'Karar Destek Raporları';
DECLARE @Sql    nvarchar(max) = N'declare 
	@DonemBasi DATETIME,
	@DonemSonu DATETIME

Set @DonemBasi = :PDonemBas 
Set @DonemSonu = :PDonemSon

SELECT 
       XXX.KOD,XXX.FIRMA,BAKIYE=-1.0*convert(float,BAKIYE),KUR,TLKARSILIK=-1.0*convert(float,(BAKIYE*(select top 1 D.SATIS from DOVIZ D where D.CINSI=XXX.KUR order by D.TARIH desc)))  
FROM (
select  DISTINCT R.KOD ,R.FIRMA,KUR ,BAKIYE=TOPLAM_BORC-TOPLAM_ALACAK 

 FROM(
    select
		REHBERID,TOPLAM_BORC=SUM(isnull(BORC,0)),TOPLAM_ALACAK=SUM(isnull(ALACAK,0)),KUR=isnull(KUR,''TL'')
	from (
	   SELECT
		REHBERID,
		SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) AS BORC,
		0 AS ALACAK,
		CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KUR
		FROM FATBASLIK F
		WHERE  isnull(F.DURUM,0)<>6 and (F.TUR in (15,16,17)) 
		AND FATURATARIH BETWEEN @DonemBasi AND @DonemSonu
		GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end

	UNION ALL

		SELECT REHBERID,
		0 AS BORC,
		SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) AS FATURA_ALACAK, -- alınan fatura BORCA YAZ
		CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end as KUR
		FROM FATBASLIK F
		WHERE  isnull(F.DURUM,0)<>6 and (F.TUR in (8,11,12,13)) 
		AND FATURATARIH BETWEEN @DonemBasi AND @DonemSonu 
		GROUP BY F.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_CINSI else KUR end

	UNION ALL

		SELECT REHBERID,
		SUM(case when ISNULL(K.BORC,0)>0 and EKSTREDEKULLAN=1 then K.DOVIZ_TUTARI else K.BORC end) AS  BORC,
		SUM(case when ISNULL(K.ALACAK,0)>0 and EKSTREDEKULLAN=1 then K.DOVIZ_TUTARI else K.ALACAK end) AS ALACAK,
		CASE WHEN EKSTREDEKULLAN=1  THEN DOVIZ_KURU else KUR end as KUR
		FROM KASA K
		WHERE TUR not between 60 and 79 
		AND ISLEMTARIHI BETWEEN @DonemBasi AND @DonemSonu
		GROUP BY K.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end

	UNION ALL
		SELECT CH.REHBERID,
		BORC=SUM(Case when CH.ISLEM in(140,131,132,133,134,137) then (CASE WHEN c.EKSTREDEKULLAN=1 THEN c.DOVIZ_TUTARI ELSE c.TUTAR END) else 0.0 end),
		ALACAK=SUM(Case when CH.ISLEM in(130,141) then (CASE WHEN c.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE c.TUTAR END) else 0.0 end),
		CASE WHEN c.EKSTREDEKULLAN=1 THEN C.DOVIZ_KURU else c.KUR end as KUR
		FROM CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID
		WHERE CH.ISLEM in(130,131,132,134,137,140,141) 
		AND CH.TARIH BETWEEN @DonemBasi AND @DonemSonu
		GROUP BY CH.REHBERID,CASE WHEN c.EKSTREDEKULLAN=1 THEN c.DOVIZ_KURU else c.KUR end

	UNION ALL

		SELECT REHBERID,
		0 AS BORC,
		SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE TUTAR END) AS ALACAK,
		CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end as KUR
		FROM SENETLER S
		WHERE TUR = 24   
		AND TARIH BETWEEN @DonemBasi AND @DonemSonu
		GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR END

	UNION ALL

		SELECT REHBERID,SUM(CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_TUTARI ELSE TUTAR END) AS
		BORC,0 AS ALACAK,
		CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end as KUR
		FROM SENETLER S
		WHERE TUR = 34  
		AND TARIH BETWEEN @DonemBasi AND @DonemSonu
		GROUP BY S.REHBERID,CASE WHEN EKSTREDEKULLAN=1 THEN DOVIZ_KURU else KUR end

		) as asd
	group by REHBERID,KUR) AS DSA
  INNER JOIN REHBER R ON 	DSA.REHBERID=R.ID
  LEFT JOIN REHBER_USER RU ON RU.ID = R.ID
   
 where  ISNULL(RU.KDR_Disi,''False'') = ''False'' and isnull(R.ID,'''')<>'''' and R.ID > 0 and TOPLAM_BORC<TOPLAM_ALACAK  and R.GRUP<>335       
   ) AS XXX       
 ORDER BY KUR,XXX.FIRMA';

IF EXISTS (SELECT 1 FROM DOKUMLER WHERE RAPORADI = @Rapor)
BEGIN
    UPDATE DOKUMLER SET [SQL] = @Sql WHERE RAPORADI = @Rapor;
    PRINT 'KDR_ALACAKLILAR guncellendi.';
END
ELSE
BEGIN
    INSERT INTO DOKUMLER (RAPORADI, GRUBU, [SQL], VARSAYILAN, SAYAC)
    VALUES (@Rapor, @Grubu, @Sql, 0, 0);
    PRINT 'KDR_ALACAKLILAR eklendi.';
END

-- Dogrulama
SELECT RAPOR = RAPORADI,
       SORU_ISARETI = LEN(CAST([SQL] AS nvarchar(max))) - LEN(REPLACE(CAST([SQL] AS nvarchar(max)),'?','')),
       -- Filtre ON'da mi WHERE'de mi? ON'da kalirsa LEFT JOIN satiri elemez (bkz. yukarida 3. madde).
       KDR_DISI_ON_KALDI = CASE WHEN CAST([SQL] AS nvarchar(max)) LIKE N'%R.ID AND ISNULL(RU.KDR_Disi%' THEN 'EVET (HATALI)' ELSE 'hayir (dogru)' END,
       DURUM = CASE WHEN CAST([SQL] AS nvarchar(max)) LIKE N'%?%' THEN 'BOZUK!' ELSE 'TAMAM' END
FROM DOKUMLER WHERE RAPORADI = @Rapor;