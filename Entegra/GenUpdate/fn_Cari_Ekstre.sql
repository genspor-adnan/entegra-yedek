-- ============================================================================
-- fn_Cari_Ekstre  (MSSQL)
--   Cari ekstre (normal): KASA + FATBASLIK (8,11,12,13,15,16,17) + cek + senet,
--   kur bazinda yuruyen bakiye ve devir satiri. @TurDurum: 1 = TUR 61/71, 0 = digerleri.
--   ILETISIMAD (Update_SQL_212): KASA/FATBASLIK satirinda REHBERILETID ->
--   REHBERILETISIM.AD; cek/senet NULL.
--   REFERANS: dev BILIM'deki guncel tanim (14.10.2026). Daha once GenUpdate'te yoktu;
--   musterilere degisiklik Update_SQL_N ile (canli tanima yama) gider - bu dosya
--   tam metin icin kaynaktir, dogrudan musteriye calistirilmaz.
-- ============================================================================
CREATE OR ALTER FUNCTION [dbo].[fn_Cari_Ekstre]( @RehberID int, @BasTar datetime, @BitTar datetime,@TurDurum int)
RETURNS @TOPLAM TABLE
       ( [SIRANO] [int] IDENTITY(1,1) NOT NULL,
       [CEKID] [int] NULL,
       [TARIH] [datetime] NULL,
       [AKSIYONTARIH] [datetime] NULL,
       [NO] [nvarchar](20) NULL,
       [TUR] [smallint] NULL,
       [BASLIK] [nvarchar](250) NULL,
       [TURAD] [nvarchar](50) NULL,
       [REHBERID] [int] NULL,
       [KOD] [nvarchar](20) NULL,
       [AD] [nvarchar](150) NULL,
       [ACIKLAMA] [nvarchar](500) NULL,
       [HESAPID] [int] NULL,
       [HESAPKODU] [nvarchar](100) NULL,
       [HESAPADI] [nvarchar](250) NULL,
       [DURUM] [smallint] NULL,
       [BORC] [money] NULL,
       [ALACAK] [money] NULL,
       [KUR] [nvarchar](6) NULL,
       [YERELKUR] [money] NULL,
       [MASRAFID] [int] NULL,
       [MASRAFKOD] [nvarchar](50) NULL,
       [MASRAFAD] [nvarchar](200) NULL,
       [BORCBAKIYE] [money] NULL,
       [ALACAKBAKIYE] [money] NULL,
       [YERELTUTAR] [money] NULL,
       [YERELBAKIYE] [money] NULL,
       [SUBEID] [int] NULL ,
       [VADETARIHI] [datetime] NULL,
       [ADET] [float] NULL,
       [BIRIM] [nvarchar](30) NULL,
       [BIRIMFIYAT] [money] NULL, [ILETISIMAD] [nvarchar](100) NULL
       
       )
AS
BEGIN
declare @BgnTrh datetime set @BgnTrh = GETDATE()
INSERT @TOPLAM

SELECT  CEKID,TARIH,AKSIYONTARIH,[NO],TUR,
              BASLIK,TURAD,REHBERID,KOD,AD,ACIKLAMA,HESAPID,HESAPKODU,HESAPADI,DURUM,BORC,ALACAK,KUR,YERELKUR,
             MASRAFID,MASRAFKOD,MASRAFAD,BORCBAKIYE,ALACAKBAKIYE,
             YERELTUTAR,YERELBAKIYE,SUBEID,VADETARIHI,ADET,BIRIM,BIRIMFIYAT,ILETISIMAD FROM (

select CEKID,TARIH,AKSIYONTARIH,[NO],TUR,TURDURUM=CASE WHEN TUR IN (61,71) THEN 1 ELSE 0 END,
              BASLIK,TURAD,REHBERID,KOD,AD,ACIKLAMA,HESAPID,HESAPKODU,HESAPADI,DURUM,BORC,ALACAK,KUR,YERELKUR,
             MASRAFID,MASRAFKOD,MASRAFAD,BORCBAKIYE,ALACAKBAKIYE,
             YERELTUTAR,YERELBAKIYE,SUBEID,VADETARIHI,ADET,BIRIM,BIRIMFIYAT,ILETISIMAD

from (

Select 
       CEKID=K.ID, 
       ISLEMTARIHI AS TARIH,PLANTARIHI as AKSIYONTARIH,BELGENO as NO, K.TUR,'' as BASLIK,
       TURAD  =     case when K.TUR like '26__' then (select top 1 ANAHTAR + ' tahsilatı ' from GENINI where BOLUM=-2329 and 2600+DEGER=K.TUR)
                                when K.TUR like '36__' then (select top 1 ANAHTAR + ' ödemesi ' from GENINI where BOLUM=-2329 and 3600+DEGER=K.TUR)
                        else (select top 1 ANAHTAR from GENINI where BOLUM=-1005 and DEGER=K.TUR)end, 
       K.REHBERID,
       KOD          = case when K.REHBERID=0 then M.KOD else R.KOD end,
       AD           = case when K.REHBERID=0 then M.AD else R.FIRMA end, 
       K.ACIKLAMA, HESAPID,
       HESAPKODU=case HESAPTURU when 'B' then (select HESAPKODU from BANKAHESAPLAR BH where BH.ID=K.HESAPID)
                                               when 'H' then (select KASAKODU from KASALAR K2 where K2.ID=K.HESAPID)+isnull(' ('+ (select ADI from PARA_KUPON PK where PK.ID=K.CEKSENETID)+')','')
                                               when 'K' then (select KASAKODU from KASALAR K2 where K2.ID=K.HESAPID)
                                               when 'P' then (select KODU from POS P where P.ID=K.HESAPID)
                                               when 'V' then (select KODU from KREDIKARTI KK where KK.ID=K.HESAPID) end,
       HESAPADI=case HESAPTURU  when 'B' then (select HESAPADI from BANKAHESAPLAR BH where BH.ID=K.HESAPID)
                                               when 'H' then (select KASAADI from KASALAR K2 where K2.ID=K.HESAPID)+isnull(' ('+ (select ADI from PARA_KUPON PK where PK.ID=K.CEKSENETID)+')','')
                                               when 'K' then (select KASAADI from KASALAR K2 where K2.ID=K.HESAPID)
                                               when 'P' then (select ADI from POS P where P.ID=K.HESAPID)
                                               when 'V' then (select ADI from KREDIKARTI KK where KK.ID=K.HESAPID) end,
       K.DURUM,

         
       BORC   = case when EKSTREDEKULLAN=1 AND BORC>0   then K.DOVIZ_TUTARI else K.BORC end,
       ALACAK = case when EKSTREDEKULLAN=1 AND ALACAK>0 then K.DOVIZ_TUTARI else K.ALACAK end,
       KUR          = case when EKSTREDEKULLAN=1 then K.DOVIZ_KURU else K.KUR end,
       YERELKUR=
                    ABS(
                    case when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND BORC>0 then K.DOVIZ_TUTARI when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND ALACAK>0 THEN -1*K.DOVIZ_TUTARI else K.BORC-K.ALACAK end
                    / 
                    CASE WHEN ((case when EKSTREDEKULLAN=1 AND BORC>0 then K.DOVIZ_TUTARI else K.BORC end)-(case when EKSTREDEKULLAN=1 AND ALACAK>0 then K.DOVIZ_TUTARI else K.ALACAK end))=0 THEN 1
                    ELSE ((case when EKSTREDEKULLAN=1 AND BORC>0 then K.DOVIZ_TUTARI else K.BORC end)-(case when EKSTREDEKULLAN=1 AND ALACAK>0 then K.DOVIZ_TUTARI else K.ALACAK end)) END
                    )
                    ,

       K.MASRAFID, MASRAFKOD=M.KOD, MASRAFAD=M.AD,BORCBAKIYE=0,ALACAKBAKIYE=0 ,
       YERELTUTAR = case when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND BORC>0   THEN K.DOVIZ_TUTARI 
                                    when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND ALACAK>0 THEN -1*K.DOVIZ_TUTARI 
                                    when K.TUR=88 then K.DOVIZ_TUTARI 
                                    when K.TUR=98 then -1*K.DOVIZ_TUTARI 
                      else K.BORC-K.ALACAK end,

       YERELBAKIYE= 0,
       K.SUBEID,VADETARIHI=ISLEMTARIHI,
       ADET=1.0,BIRIM='',BIRIMFIYAT=0.0,ILETISIMAD=(select RI.AD from REHBERILETISIM RI where RI.ID=K.REHBERILETID)

       From 
             KASA K (NOLOCK)
                    left outer join REHBER R on 
                           K.REHBERID=R.ID 
                    left outer join KASALAR KS on 
                           KS.ID= K.HESAPID 
                    left outer join MASRAFGELIR M on 
                           M.ID=K.MASRAFID
       Where 
                    K.REHBERID=@RehberID
             and year(K.ISLEMTARIHI) >= year(@Bastar) and year(K.ISLEMTARIHI) <= year(@Bittar) AND K.ISLEMTARIHI<=@Bittar
             and ((K.TUR in (49,61,71))or(K.TUR not between 40 and 79))

UNION ALL

       Select CEKID=F.ID, FATURATARIH as TARIH, FATURATARIH AS AKSIYONTARIH, FATURANO as NO, F.TUR,F.BASLIK,
       TURAD=(select top 1 ANAHTAR from GENINI where BOLUM='-1005' and DEGER=F.TUR),
       F.REHBERID, R.KOD, R.FIRMA AS AD, F.ACIKLAMA, HESAPID=null, HESAPKODU=null, HESAPADI=null,F.DURUM,
       BORC=case when F.TUR in (8,11,12,13) then 0.0 WHEN TIPI=5 THEN 0.0 else (case when EKSTREDEKULLAN=1 then DOVIZ_TUTARI else FATURA_TUTARI end) end ,
       ALACAK=case when F.TUR in (15,16,17) then 0.0 WHEN TIPI=5 THEN 0.0 else (case when EKSTREDEKULLAN=1 then DOVIZ_TUTARI else FATURA_TUTARI end) end,
       KUR = case when EKSTREDEKULLAN=1 then DOVIZ_CINSI else KUR end,
       YERELKUR= 
       CASE WHEN F.TIPI=5 THEN DOVIZKUR ELSE 
       ABS(
       (case when F.RAPORDOVIZ = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (15,16,17) then F.DOVIZ_TUTARI 
               when F.RAPORDOVIZ = (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) then -1*F.DOVIZ_TUTARI
               when F.RAPORDOVIZ <>(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (15,16,17) then F.FATURA_TUTARI 
               when F.RAPORDOVIZ <>(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) then -1*F.FATURA_TUTARI
       end)/

       CASE WHEN ((case when F.TUR in (8,11,12,13) then 0.0 else (case when EKSTREDEKULLAN=1 then DOVIZ_TUTARI else FATURA_TUTARI end) end)-

       (case when F.TUR in (15,16,17) then 0.0 else (case when EKSTREDEKULLAN=1 then DOVIZ_TUTARI else FATURA_TUTARI end) end))=0 THEN 1 ELSE
       ((case when F.TUR in (8,11,12,13) then 0.0 else (case when EKSTREDEKULLAN=1 then DOVIZ_TUTARI else FATURA_TUTARI end) end)-
       (case when F.TUR in (15,16,17) then 0.0 else (case when EKSTREDEKULLAN=1 then DOVIZ_TUTARI else FATURA_TUTARI end) end))
       END
       )
       END,

       F.MASRAFID, MASRAFKOD=M.KOD, MASRAFAD=M.AD,BORCBAKIYE=0,ALACAKBAKIYE=0 ,
       YERELTUTAR = 
                    case when F.RAPORDOVIZ =  (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (15,16,17) then F.DOVIZ_TUTARI 
                            when F.RAPORDOVIZ =  (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) then -1*F.DOVIZ_TUTARI
                           when F.RAPORDOVIZ <> (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (15,16,17) then F.FATURA_TUTARI 
                            when F.RAPORDOVIZ <> (SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) then -1*F.FATURA_TUTARI
       end,
       YERELBAKIYE= 0,
       F.SUBEID, VADETARIHI=F.FATURATARIH+isnull(F.VADE,0),
       ADET=1.0,BIRIM='',BIRIMFIYAT=0.0,ILETISIMAD=(select RI.AD from REHBERILETISIM RI where RI.ID=F.REHBERILETID)
       From FATBASLIK F (NOLOCK)
       inner join REHBER R on F.REHBERID=R.ID and F.TUR in (8,11,12,13,15,16,17) and isnull(F.DURUM,0)<>6
       left outer join MASRAFGELIR M on M.ID=F.MASRAFID
       Where F.REHBERID=@RehberID
       and year(FATURATARIH) >= year(@Bastar) and year(FATURATARIH)<=year(@Bittar) and FATURATARIH<=@Bittar

---- Çek
UNION ALL

       Select CEKID=C.ID ,CH.TARIH, VADE as AKSIYONTARIH, MAKBUZNO as NO, 
	   --TUR=case when CH.ISLEM in(130,141) then 23 else 33 end,
	TUR=case when CH.ISLEM between 130 and 139 and CEKSENET=101 then 23 
	when CH.ISLEM between 140 and 149 and CEKSENET=103 then 33 
	when CH.ISLEM between 130 and 139 and CEKSENET=121 then 24 
	when CH.ISLEM between 140 and 149 and CEKSENET=321 then 34 
	else 0 end,	   
	   '',
       TURAD=(select top 1 ANAHTAR from GENINI where BOLUM=-1005 and DEGER=(case when CH.ISLEM between 130 and 139 and CEKSENET=101 then 23 
	when CH.ISLEM between 140 and 149 and CEKSENET=103 then 33 
	when CH.ISLEM between 130 and 139 and CEKSENET=121 then 24 
	when CH.ISLEM between 140 and 149 and CEKSENET=321 then 34 
	else 0 end)and DIL=-1),
       CH.REHBERID,R.KOD, R.FIRMA AS AD, ACIKLAMA='Serino:'+convert(nvarchar(20),C.SERINO)+' '+rtrim(isnull(CH.ACIKLAMA,'')),
       HESAPID=CH.BANKAHESAPLARID, HESAPKODU=BH.HESAPKODU, HESAPADI=BH.HESAPADI,C.DURUM,
       BORC=Case when CH.ISLEM in(140,131,132,133,134,137) then CH.TUTAR else 0.0 end,
       ALACAK=Case when CH.ISLEM in(130,141) then CH.TUTAR else 0.0 end,
       KUR=CH.KUR,
       YERELKUR = CH.DOVIZ_TUTARI/CH.TUTAR,
       C.MASRAFID, MASRAFKOD=M.KOD, MASRAFAD=M.AD,BORCBAKIYE=0,ALACAKBAKIYE=0 ,
       YERELTUTAR = case when CH.ISLEM in(140,131,132,133,134,137) then CH.DOVIZ_TUTARI
                         else -1*CH.DOVIZ_TUTARI end,
       YERELBAKIYE = 0,
       C.SUBEID, VADETARIHI=VADE,
       ADET=1.0,BIRIM='',BIRIMFIYAT=0.0,ILETISIMAD=CAST(NULL AS nvarchar(100))
       From CEKLER C (NOLOCK) inner join
       CEKHAREKET CH on C.ID=CH.CEKSENETLERID
       left outer join REHBER R on CH.REHBERID=R.ID
       left outer join BANKAHESAPLAR BH on CH.BANKAHESAPLARID=BH.ID
       left outer join MASRAFGELIR M on M.ID=C.MASRAFID
       Where CH.ISLEM in(130,131,132,134,137,140,141)
       and CH.REHBERID=@RehberID
       and year(CH.TARIH) >= year(@Bastar) and year(CH.TARIH) <= year(@Bittar) AND CH.TARIH <= @Bittar

---- Senet

UNION ALL

Select 
       CEKID=C.ID ,TARIH, VADE as AKSIYONTARIH, MAKBUZNO as NO,C.TUR,'', TURAD=(select top 1 ANAHTAR from GENINI where BOLUM='-1005' and DEGER=C.TUR),
       C.REHBERID,R.KOD, R.FIRMA AS AD, ACIKLAMA=rtrim(NOTLAR), HESAPID=null, HESAPKODU=null, HESAPADI=null,C.DURUM,
       BORC=Case when C.TUR=34 then (case when EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end,
       ALACAK=Case when C.TUR=24 then (case when EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end,
       KUR=case when EKSTREDEKULLAN=1 then C.DOVIZ_KURU else isnull(C.KUR,'TL') end,
       YERELKUR=
                    ABS(
                    (case when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=34 then C.DOVIZ_TUTARI
                    when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=24 then -1*C.DOVIZ_TUTARI
                    when DOVIZ_KURU<>(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=34 then C.TUTAR when DOVIZ_KURU<>(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=24 then -1*C.TUTAR
                    end)/
                    ((Case when C.TUR=34 then (case when EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end)-
                    (Case when C.TUR=24 then (case when EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else isnull(C.TUTAR,0)end) else 0 end))
                    )
                    ,
       C.MASRAFID, MASRAFKOD=M.KOD, MASRAFAD=M.AD,BORCBAKIYE=0,ALACAKBAKIYE=0 ,
       YERELTUTAR = case when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=34 then C.DOVIZ_TUTARI when DOVIZ_KURU=(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=24 then -1*C.DOVIZ_TUTARI
       when DOVIZ_KURU<>(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=34 then C.TUTAR when DOVIZ_KURU<>(SELECT ANAHTAR FROM GENINI WHERE BOLUM=-10135) AND C.TUR=24 then -1*C.TUTAR
       end,
       YERELBAKIYE= 0,
       C.SUBEID, VADETARIHI=VADE,
       ADET=1.0,BIRIM='',BIRIMFIYAT=0.0,ILETISIMAD=CAST(NULL AS nvarchar(100))
From 
       SENETLER C (NOLOCK)
             inner join REHBER R on 
                    C.REHBERID=R.ID 
             left outer join MASRAFGELIR M on 
                    M.ID=C.MASRAFID
Where
             C.REHBERID=@RehberID
       and year(C.TARIH) >= year(@Bastar) and year(C.TARIH) <= year(@Bittar) and C.TARIH <= @Bittar
) as x

) AS Y

WHERE 
             TURDURUM = @TurDurum

ORDER BY kur, 2


declare @CurID int, @BB money, @AB money,@YB money ,@Kur nvarchar(5)
declare CrsKur cursor for select distinct KUR from @TOPLAM
open CrsKur
fetch next from CrsKur into @Kur
while @@FETCH_STATUS = 0
begin
set @AB=0
set @BB=0
set @YB=0
declare Crs cursor for select SIRANO from @TOPLAM where KUR=@Kur order by SIRANO
open Crs
fetch next from Crs into @CurID
while @@FETCH_STATUS = 0
begin
select
@AB=case when TUR IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) then @AB else @AB+ALACAK-BORC end , 
@BB=case when TUR IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) then @BB else @BB+BORC-ALACAK end ,
@YB=case when TUR IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) then @YB else @YB+YERELTUTAR end
from @TOPLAM where SIRANO=@CurID
update @TOPLAM set
ALACAKBAKIYE= case when @AB>0 then @AB else 0 end,
BORCBAKIYE = case when @BB>0 then @BB else 0 end ,
YERELBAKIYE = case when @YB<>0 then @YB else 0 end
where SIRANO=@CurID
fetch next from Crs into @CurID
End
close Crs
deallocate Crs
fetch next from CrsKur into @Kur
End
close CrsKur
deallocate CrsKur





insert into @TOPLAM(CEKID,TARIH,AKSIYONTARIH,NO,TUR,BASLIK,TURAD,REHBERID,KOD,AD,ACIKLAMA,HESAPID,HESAPKODU,
HESAPADI,DURUM,BORC,ALACAK,YERELTUTAR,KUR,YERELKUR,MASRAFID,MASRAFKOD,MASRAFAD,BORCBAKIYE,ALACAKBAKIYE,YERELBAKIYE,SUBEID,VADETARIHI)
select CEKID=0,TARIH=@Bastar,AKSIYONTARIH=@Bastar,NO=null,TUR=2,BASLIK='',TURAD='Devir',REHBERID=0,
KOD='',AD='',ACIKLAMA='Devir',HESAPID=null,HESAPKODU=null,HESAPADI=null,DURUM=1,
BORC=sum(BORC),ALACAK=sum(ALACAK),
SUM(YERELTUTAR) AS YERELTUTAR,

KUR,YERELKUR=NULL,
MASRAFID=0,MASRAFKOD='',MASRAFAD='',
BORCBAKIYE=case when sum(BORC-ALACAK)>0 then sum(BORC-ALACAK) else 0 end,
ALACAKBAKIYE=case when sum(ALACAK-BORC)>0 then sum(ALACAK-BORC) else 0 end,
YERELBAKIYE=case when sum(YERELTUTAR)>0 then sum(YERELTUTAR) else 0 end,
SUBEID,VADETARIHI=@Bastar
from @TOPLAM
where ((TUR in (40,42,49,61,71))or(TUR not between 40 and 79)) and TARIH < @Bastar
group by KUR,SUBEID

delete from @Toplam where TARIH<@Bastar

RETURN

END
