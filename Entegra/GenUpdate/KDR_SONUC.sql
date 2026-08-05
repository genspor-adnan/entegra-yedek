/* ============================================================================
   KDR_SONUC.sql  —  MUSTERI ANA veritabaninda calistirilir

   "KDR_SONUÇ" karar destek raporunun DOGRU sorgusunu DOKUMLER tablosuna yazar
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

   4) KOLON ADLARI ASCII olmali: ekrandaki tile bilesenleri Delphi'de KDR_BORCLULAR,
      KDR_ALINAN_CEK, KDR_KREDILER... diye adlandirilmistir (bilesen adi Turkce harf
      ICEREMEZ). Kod FindComponent(alan_adi) ile eslestirdiginden kolon adi 'KDR_BORÇLULAR'
      olursa eslesme OLMAZ ve tile BOS/0 kalir. Kolon adlari ASCII'ye cevrildi;
      metin literalleri (or. 'Konsinye Çıkış') Turkce KALIR - onlar veriyle karsilastirilir.

   NOT: Dosya UTF-8 (BOM) kodludur. sqlcmd ile calistirirken  -f 65001  ZORUNLU:
        sqlcmd -S SUNUCU -d MUSTERIDB -U sa -P *** -C -f 65001 -i KDR_SONUC.sql
        (BOM tek basina yetmez; verilmezse Turkce harfler yeniden bozulur.)

   Idempotent: tekrar calistirmak zararsizdir.
============================================================================ */
SET NOCOUNT ON;

DECLARE @Rapor  sysname       = N'KDR_SONUC';
DECLARE @Grubu  nvarchar(200) = N'Karar Destek Raporları';
DECLARE @Sql    nvarchar(max) = N'declare
	@DonemBasi DATETIME,
	@DonemSonu DATETIME

Set @DonemBasi = :PDonemBas 
Set @DonemSonu = :PDonemSon

select
KDR_POS=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=SUM(ALACAK-BORC)*(select top 1 D.SATIS from DOVIZ D where D.CINSI=K1.KUR order by D.TARIH desc)
                           from POS K inner join KASA K1 on K.ID=K1.HESAPID
                           where K1.ISLEMTARIHI BETWEEN @DonemBasi AND @DonemSonu AND K1.HESAPTURU=''P''
                           group by K1.KUR)as X),0.0),
KDR_ALINAN_CEK=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=SUM(CASE WHEN DOVIZ_KURU = ''TL'' THEN CONVERT(FLOAT,DOVIZ_TUTARI)WHEN C.KUR = ''TL'' THEN convert(float,C.TUTAR) END)
from CEKLER C inner join REHBER R on C.REHBERID=R.ID
where C.TUR in (130,132,133,134,135,138) AND C.CEKSENET = 101 AND C.TARIH <= @DonemSonu)as X),0.0),
KDR_ALINAN_SENET=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=SUM(CASE WHEN DOVIZ_KURU = ''TL'' THEN CONVERT(FLOAT,DOVIZ_TUTARI)WHEN C.KUR = ''TL'' THEN convert(float,C.TUTAR) END)
from CEKLER C inner join REHBER R on C.REHBERID=R.ID
where C.TUR in (130,132,133,134,135,138) AND C.CEKSENET = 121 AND C.TARIH <= @DonemSonu)as X),0.0),
KDR_KASA=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=convert(float,(SUM(ALACAK-BORC)*(select top 1 D.SATIS from DOVIZ D where D.CINSI=K1.KUR order by D.TARIH desc)))
                           from KASALAR K inner join KASA K1 on K.ID=K1.HESAPID
                           where K1.ISLEMTARIHI BETWEEN @DonemBasi AND @DonemSonu AND K1.HESAPTURU=''K''
                           group by K.KASAKODU,K.KASAADI,K1.KUR)as X),0.0),
KDR_STOK=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=DRM.KALAN*(ISNULL((SELECT TOP 1 SOM.BIRIMMALIYET FROM STOK_ORT_MALIYET SOM INNER JOIN (SELECT TOP 1 SM.STOKID,SM.BIRIMMALIYET,FB.TUR,SM.DEPOID,FB.CIKISDEPO,NUM=ROW_NUMBER() OVER(PARTITION BY STOKID ORDER BY SM.TARIH desc) FROM STOK_ORT_MALIYET SM INNER JOIN FATBASLIK FB ON FB.ID = SM.FATBASID WHERE SM.STOKID = DRM.URUNID AND SM.DEPOID = CASE WHEN DRM.DEPO = (SELECT ID FROM DEPOLAR WHERE DEPOADI = ''Konsinye Çıkış'') THEN 1 ELSE DRM.DEPO END ORDER BY SM.TARIH DESC) AS X ON X.STOKID = SOM.STOKID AND CASE WHEN X.BIRIMMALIYET = 0 THEN 1 ELSE X.DEPOID END = SOM.DEPOID  WHERE SOM.TARIH <= @DonemSonu ORDER BY SOM.TARIH DESC,X.NUM DESC),0))
                           from STOKLAR S inner join 
                                                      (SELECT DEPO,URUNID,
                                                                             GIREN=round(SUM(CASE WHEN NETMIKTAR > 0.0 THEN NETMIKTAR ELSE 0.0 END),2), 
                                                                             CIKAN=round(SUM(CASE WHEN NETMIKTAR < 0.0 THEN -1.0*NETMIKTAR ELSE 0.0 END),2), 
                                                                             KALAN=round(SUM(NETMIKTAR),2)
                                                      FROM( SELECT DEPO=GIRISDEPO,F.URUNID, CASE WHEN (FB.TUR = 6) AND (F.MIKTAR >= 0) THEN F.MIKTAR WHEN (FB.TUR = 6) AND (F.MIKTAR < 0) THEN 0 ELSE F.MIKTAR END AS NETMIKTAR
                                                                                                        FROM dbo.FATBASLIK AS FB INNER JOIN dbo.FATURA AS F ON F.FATBASID = FB.ID  
                                                                                                        WHERE (F.STOKDURUMDEGIS = 1) AND (ISNULL(FB.DURUM, 1) <> 6)  AND (ISNULL(FB.GIRISDEPO, 0) > 0) and F.TUR=1 AND FB.FATURATARIH <= @DonemSonu
                                                                                                        UNION ALL
                                                                                                        SELECT DEPO=CIKISDEPO,F.URUNID, CASE WHEN (FB.TUR = 6) AND (F.MIKTAR > 0) THEN 0 WHEN (FB.TUR = 6) AND (F.MIKTAR <= 0) THEN F.MIKTAR ELSE - F.MIKTAR END AS NETMIKTAR
                                                                                                        FROM dbo.FATBASLIK AS FB INNER JOIN dbo.FATURA AS F ON F.FATBASID = FB.ID 
                                                                                                        WHERE (F.STOKDURUMDEGIS = 1) AND (ISNULL(FB.DURUM, 1) <> 6)  AND (ISNULL(FB.CIKISDEPO, 0) > 0) and F.TUR=1 AND FB.FATURATARIH <= @DonemSonu
                                                                             ) AS ASD GROUP BY URUNID,DEPO
                                                      HAVING SUM(NETMIKTAR)<>0.0
                                                      )as DRM on S.ID=DRM.URUNID --left join 
                                                      --(select STOKID,BIRIMMALIYET,NUM=ROW_NUMBER() OVER(PARTITION BY STOKID ORDER BY TARIH desc) from STOK_ORT_MALIYET SM)as Mlt on Mlt.STOKID=S.ID
                           where --Mlt.NUM=1 and 
                                  S.DURUM=1 AND S.TIPI NOT IN (SELECT DEGER FROM GENINI G WHERE G.DEGER=S.TIPI AND BOLUM=-2703 AND G.DEGER LIKE ''%-%''))as X),0.0),
KDR_ALACAKLILAR=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      SELECT KALAN=-1.0*convert(float,(BAKIYE*(select top 1 D.SATIS from DOVIZ D where D.CINSI=XXX.KUR order by D.TARIH desc)))  
                           FROM ( select  DISTINCT R.SUBEID,R.KOD ,R.FIRMA,cast(TOPLAM_BORC as float) AS BORC ,cast(TOPLAM_ALACAK as float) AS ALACAK,KUR ,BAKIYE=TOPLAM_BORC-TOPLAM_ALACAK 
                                        FROM(  select
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
                                  INNER JOIN REHBER R ON     DSA.REHBERID=R.ID
								  LEFT JOIN REHBER_USER RU ON RU.ID = R.ID
                           where  ISNULL(RU.KDR_Disi,''False'') = ''False'' and R.ID > 0 and isnull(R.ID,'''')<>'''' and R.GRUP<>335 
                           AND TOPLAM_BORC<=TOPLAM_ALACAK
   ) AS XXX )as X),0.0),
--KREDİLER
KDR_KREDILER=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=convert(float,(sum(case when P.ODENMIS=1 and P.TARIH<=@DonemSonu then 0.0 else P.TAKSIT end)*(select top 1 D.SATIS from DOVIZ D where D.CINSI=KR.KUR order by D.TARIH desc)))
                           from KREDILER KR left join PLANKREDI P on P.KREDIID=KR.ID
                           where KR.DURUM>0 and GENELKREDITIPI=1 and exists(select 1 from PLANKREDI P2 where P2.KREDIID=KR.ID and P2.TARIH<=@DonemSonu)
                           GROUP BY KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KREDITAKSIT
                           union all
                           select KALAN=convert(float,(isnull(sum(BORC),0)-isnull(sum(ALACAK),0)*(select top 1 D.SATIS from DOVIZ D where D.CINSI=KR.KUR order by D.TARIH desc)))
                           from KREDILER KR left outer join KASA KS on HESAPTURU=''R'' and KS.HESAPID=KR.ID
                           where KR.DURUM>0 and KS.TUR<>2 and GENELKREDITIPI=2 and KS.ISLEMTARIHI<=@DonemSonu
                           GROUP BY KR.ID,KREDIKODU,ADI,SOZLESMENO,GENELKREDITIPI,KR.KUR,ALINISTARIHI,KAPANISTARIHI,KREDITAKSIT)as X),0.0),
KDR_KREDI_KARTI=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=convert(float,(SUM(ALACAK-BORC)*(select top 1 D.SATIS from DOVIZ D where D.CINSI=K1.KUR order by D.TARIH desc)))
                           from KREDIKARTI K inner join KASA K1 on K.ID=K1.HESAPID
                           where K1.ISLEMTARIHI BETWEEN @DonemBasi AND @DonemSonu and K1.HESAPTURU=''V''
                           group by K.KODU,K.ADI,K1.KUR)as X),0.0),
KDR_VERILEN_CEK=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=SUM(CASE WHEN DOVIZ_KURU = ''TL'' THEN CONVERT(FLOAT,DOVIZ_TUTARI)WHEN C.KUR = ''TL'' THEN convert(float,C.TUTAR) END)
from CEKLER C inner join REHBER R on C.REHBERID=R.ID
where C.TUR in (140) AND C.CEKSENET = 103 AND C.TARIH <= @DonemSonu)as X),0.0),
KDR_VERILEN_SENET=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=SUM(CASE WHEN DOVIZ_KURU = ''TL'' THEN CONVERT(FLOAT,DOVIZ_TUTARI)WHEN C.KUR = ''TL'' THEN convert(float,C.TUTAR) END)
from CEKLER C inner join REHBER R on C.REHBERID=R.ID
where C.TUR in (140) AND C.CEKSENET = 321 AND C.TARIH <= @DonemSonu)as X),0.0),
KDR_BORCLULAR=isnull((select SUM(isnull(KALAN,0.0)) from
                    (      SELECT KALAN=convert(float,(BAKIYE*(select top 1 D.SATIS from DOVIZ D where D.CINSI=XXX.KUR order by D.TARIH desc)))  
                           FROM (
                           select  DISTINCT R.SUBEID,R.KOD ,R.FIRMA,cast(TOPLAM_BORC as float) AS BORC ,cast(TOPLAM_ALACAK as float) AS ALACAK,KUR ,BAKIYE=TOPLAM_BORC-TOPLAM_ALACAK 

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
                                  INNER JOIN REHBER R ON     DSA.REHBERID=R.ID
								  LEFT JOIN REHBER_USER RU ON RU.ID = R.ID
                           where  ISNULL(RU.KDR_Disi,''False'') = ''False'' and R.ID > 0 and isnull(R.ID,'''')<>'''' and R.GRUP<>335  
                           AND TOPLAM_BORC>=TOPLAM_ALACAK
                              ) AS XXX       )as X),0.0),
KDR_BANKA = isnull((select SUM(isnull(KALAN,0.0)) from
                    (      select KALAN=SUM(ALACAK-BORC)*(select top 1 D.SATIS from DOVIZ D where D.CINSI=K1.KUR order by D.TARIH desc)
                           from BANKAHESAPLAR K inner join KASA K1 on K.ID=K1.HESAPID
                           where K1.ISLEMTARIHI BETWEEN @DonemBasi AND @DonemSonu and K1.HESAPTURU=''B'' AND ISNULL(ONLINEHESAPHAREKETI,0) = 0
                           group by K1.KUR)as X),0.0)';

IF EXISTS (SELECT 1 FROM DOKUMLER WHERE RAPORADI = @Rapor)
BEGIN
    UPDATE DOKUMLER SET [SQL] = @Sql WHERE RAPORADI = @Rapor;
    PRINT 'KDR_SONUÇ guncellendi.';
END
ELSE
BEGIN
    INSERT INTO DOKUMLER (RAPORADI, GRUBU, [SQL], VARSAYILAN, SAYAC)
    VALUES (@Rapor, @Grubu, @Sql, 0, 0);
    PRINT 'KDR_SONUÇ eklendi.';
END

-- Dogrulama
SELECT RAPOR = RAPORADI,
       SORU_ISARETI = LEN(CAST([SQL] AS nvarchar(max))) - LEN(REPLACE(CAST([SQL] AS nvarchar(max)),'?','')),
       -- Filtre ON'da mi WHERE'de mi? ON'da kalirsa LEFT JOIN satiri elemez (bkz. yukarida 3. madde).
       KDR_DISI_ON_KALDI = CASE WHEN CAST([SQL] AS nvarchar(max)) LIKE N'%R.ID AND ISNULL(RU.KDR_Disi%' THEN 'EVET (HATALI)' ELSE 'hayir (dogru)' END,
       DURUM = CASE WHEN CAST([SQL] AS nvarchar(max)) LIKE N'%?%' THEN 'BOZUK!' ELSE 'TAMAM' END
FROM DOKUMLER WHERE RAPORADI = @Rapor;