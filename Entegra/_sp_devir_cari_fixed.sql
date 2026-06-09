ALTER PROC [dbo].[Sp_Prg_Devir_Cari] (@BasTar Datetime,@AktarilacakYil int,@Kur varchar(5),@IslemKur varchar(10),@DevirleriAl Bit)
AS BEGIN
SET NOCOUNT ON
--    EXEC Sp_Prg_Devir_Cari '2015-01-01', 2016,'TL','ALIS',1
Declare @Aciklama varchar(50)

declare @YilSonuTarihi datetime
declare @YilBasiTarihi datetime

set @YilSonuTarihi=CONVERT(varchar(4),@AktarilacakYil-1)+'-12-31 23:59:59'
set @YilBasiTarihi=CONVERT(varchar(4),@AktarilacakYil)+'-01-01 00:00:00'
set @Aciklama = convert(varchar(4),(@AktarilacakYil))+' Yılı Açılış Devri'

insert into KASA(TUR,PLANTARIHI,ISLEMTARIHI,REHBERID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
select 2,@YilBasiTarihi,@YilBasiTarihi,REHBERID,
BORC=case when SUM(BORC-ALACAK)>0 then SUM(BORC-ALACAK) else 0 end,
ALACAK=case when SUM(ALACAK-BORC)>0 then SUM(ALACAK-BORC) else 0 end,
KUR=isnull(KUR,@Kur),'',@Aciklama,SUBEID,
DOVIZ_TUTARI=(case when SUM(BORC-ALACAK)>0 then SUM(BORC-ALACAK) else SUM(ALACAK-BORC) end)*(case when isnull(KUR,@Kur)=@Kur then 1.0 
else ISNULL((SELECT TOP 1 case when @IslemKur='ALIS' THEN ISNULL(D.ALIS,0)
                                   when @IslemKur='SATIS' THEN ISNULL(D.SATIS,0) 
                                         when @IslemKur='EFALIS' THEN ISNULL(D.EFALIS,0)
                                         when @IslemKur='EFSATIS' THEN ISNULL(D.EFSATIS,0)
                                         END 

FROM DOVIZ D WHERE D.CINSI=KUR ORDER BY ABS(DATEDIFF(HOUR,@YilBasiTarihi,D.TARIH))),0)end),
-- SELECT * FROM DOVIZ
DOVIZ_KURU=@Kur

from(
                Select
                       K.REHBERID,
                       BORC = case when EKSTREDEKULLAN=1 AND BORC>0 then isnull(K.DOVIZ_TUTARI,0) else isnull(K.BORC,0) end,
                       ALACAK = case when EKSTREDEKULLAN=1 AND ALACAK>0 then isnull(K.DOVIZ_TUTARI,0) else isnull(K.ALACAK,0) end,
                       KUR = case when EKSTREDEKULLAN=1 then isnull(K.DOVIZ_KURU,'TL') else isnull(K.KUR,'TL') end,
                       SUBEID=isnull(K.SUBEID,-1)
                FROM KASA K--KASA
                where ISNULL(REHBERID,0)>0 and ((K.TUR in (49))or(K.TUR not between 40 and 79))
                               and ISLEMTARIHI >= @BasTar
                               and ISLEMTARIHI<@YilBasiTarihi
                               and K.TUR<>(case when @DevirleriAl=0 then 2 else 0 end)

                           -- CEKLER

                union all

                Select
                                  CH.REHBERID,
                                  BORC  = Case when CH.ISLEM in(140,131,132,133,134,137) then (case when CH.EKSTREDEKULLAN=1 then isnull(CH.TUTAR,0) else isnull(C.TUTAR,0)end) else 0 end,
                                  ALACAK= Case when CH.ISLEM in(130,141) then (case when CH.EKSTREDEKULLAN=1 then isnull(CH.TUTAR,0) else isnull(C.TUTAR,0)end) else 0 end,
                                  KUR   = case when CH.EKSTREDEKULLAN=1 then isnull(CH.KUR,'TL') else isnull(C.KUR,'TL')end,
                                  SUBEID=isnull(C.SUBEID,-1)
                from CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID--ÇEKLER
                where CH.ISLEM in(130,131,132,134,137,140,141) and
                              CH.TARIH >= @BasTar AND
                      CH.TARIH<@YilBasiTarihi

                           -- SENETLER

                union all

                Select
                                  S.REHBERID,
                                  BORC=Case when S.TUR=34 then (case when EKSTREDEKULLAN=1 then isnull(S.DOVIZ_TUTARI,0) else isnull(S.TUTAR,0)end) else 0 end,
                                  ALACAK=Case when S.TUR=24 then (case when EKSTREDEKULLAN=1 then isnull(S.DOVIZ_TUTARI,0) else isnull(S.TUTAR,0)end) else 0 end,
                                  KUR=case when EKSTREDEKULLAN=1 then isnull(S.DOVIZ_KURU,'TL') else isnull(S.KUR,'TL') end,
                                  SUBEID=isnull(S.SUBEID,-1)
                from SENETLER S--SENETLER
                where
                      S.TARIH >= @BasTar
                  and S.TARIH<@YilBasiTarihi


                union all

                           -- FATBASLIK

                SELECT
                                  F.REHBERID,
                                  BORC=case when F.TUR in (8,11,12,13) then 0.0 else (case when EKSTREDEKULLAN=1 then isnull(DOVIZ_TUTARI,0) else isnull(FATURA_TUTARI,0) end) end ,
                                  ALACAK=case when F.TUR in (15,16,17) then 0.0 else (case when EKSTREDEKULLAN=1 then isnull(DOVIZ_TUTARI,0) else isnull(FATURA_TUTARI,0) end) end,
                                  KUR = case when EKSTREDEKULLAN=1 then isnull(DOVIZ_CINSI,'TL') else isnull(KUR,'TL') end,
                                  SUBEID=isnull(F.SUBEID,-1)
                FROM FATBASLIK F--FATURALAR
                where F.TUR in (8,11,12,13,15,16,17) and isnull(F.DURUM,0)<>6 and
                               F.FATURATARIH >= @BasTar
                                   and F.FATURATARIH<@YilBasiTarihi

)as LST
where LST.REHBERID>0
group by LST.REHBERID,LST.KUR,LST.SUBEID
HAVING (SUM(BORC)-SUM(ALACAK))<> 0

set @Aciklama = convert(varchar(4),(@AktarilacakYil-1))+' Yılı Kapanış Devri'


insert into KASA(TUR,PLANTARIHI,ISLEMTARIHI,REHBERID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
select 2,@YilSonuTarihi,@YilSonuTarihi,REHBERID,
BORC=case when SUM(ALACAK-BORC)>0 then SUM(ALACAK-BORC) else 0 end,
ALACAK=case when SUM(BORC-ALACAK)>0 then SUM(BORC-ALACAK) else 0 end,
KUR=isnull(KUR,@Kur),'',@Aciklama,SUBEID,
DOVIZ_TUTARI=(case when SUM(BORC-ALACAK)>0 then SUM(BORC-ALACAK) else SUM(ALACAK-BORC) end)*(case when isnull(KUR,@Kur)=@Kur then 1.0 
else  ISNULL((SELECT TOP 1 case when @IslemKur='ALIS' THEN ISNULL(D.ALIS,0) 
                                   when @IslemKur='SATIS' THEN ISNULL(D.SATIS,0) 
                                         when @IslemKur='EFALIS' THEN ISNULL(D.EFALIS,0)
                                         when @IslemKur='EFSATIS' THEN ISNULL(D.EFSATIS,0)
                                         END  FROM DOVIZ D WHERE D.CINSI=KUR ORDER BY ABS(DATEDIFF(HOUR,@YilBasiTarihi,D.TARIH))),0)end),
DOVIZ_KURU=@Kur
from(
                Select K.REHBERID,
                       BORC = case when EKSTREDEKULLAN=1 AND BORC>0 then isnull(K.DOVIZ_TUTARI,0) else isnull(K.BORC,0) end,
                       ALACAK = case when EKSTREDEKULLAN=1 AND ALACAK>0 then isnull(K.DOVIZ_TUTARI,0) else isnull(K.ALACAK,0) end,
                       KUR = case when EKSTREDEKULLAN=1 then isnull(K.DOVIZ_KURU,'TL') else isnull(K.KUR,'TL') end,
                SUBEID=isnull(K.SUBEID,-1)
                FROM KASA K--KASA
                where ISNULL(REHBERID,0)>0 and ((K.TUR in (49))or(K.TUR not between 40 and 79))
                               and ISLEMTARIHI >= @BasTar
                               and ISLEMTARIHI<@YilBasiTarihi
                               and K.TUR<>(case when @DevirleriAl=0 then 2 else 0 end)


                union all

                Select CH.REHBERID,
                BORC  = Case when CH.ISLEM in(140,131,132,133,134,137) then (case when CH.EKSTREDEKULLAN=1 then isnull(CH.TUTAR,0) else isnull(C.TUTAR,0)end) else 0 end,
                           ALACAK= Case when CH.ISLEM in(130,141) then (case when CH.EKSTREDEKULLAN=1 then isnull(CH.TUTAR,0) else isnull(C.TUTAR,0)end) else 0 end,
                           KUR   = case when CH.EKSTREDEKULLAN=1 then isnull(CH.KUR,'TL') else isnull(C.KUR,'TL')end,
                SUBEID=isnull(C.SUBEID,-1)
                from CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID--ÇEKLER
                where CH.ISLEM in(130,131,132,134,137,140,141) and
                               CH.TARIH >= @BasTar
                               and CH.TARIH<@YilBasiTarihi--select * from KASA

                union all

                Select
                                  S.REHBERID,
                                  BORC=Case when S.TUR=34 then (case when EKSTREDEKULLAN=1 then isnull(S.DOVIZ_TUTARI,0) else isnull(S.TUTAR,0)end) else 0 end,
                                  ALACAK=Case when S.TUR=24 then (case when EKSTREDEKULLAN=1 then isnull(S.DOVIZ_TUTARI,0) else isnull(S.TUTAR,0)end) else 0 end,
                                  KUR=case when EKSTREDEKULLAN=1 then isnull(S.DOVIZ_KURU,'TL') else isnull(S.KUR,'TL') end,
                                  SUBEID=isnull(S.SUBEID,-1)
                from SENETLER S--SENETLER
                where
                               S.TARIH >= @BasTar
                               and S.TARIH<@YilBasiTarihi


                union all

                SELECT
                                  F.REHBERID,
                                  BORC=case when F.TUR in (8,11,12,13) then 0.0 else (case when EKSTREDEKULLAN=1 then isnull(DOVIZ_TUTARI,0) else isnull(FATURA_TUTARI,0) end) end ,
                                  ALACAK=case when F.TUR in (15,16,17) then 0.0 else (case when EKSTREDEKULLAN=1 then isnull(DOVIZ_TUTARI,0) else isnull(FATURA_TUTARI,0) end) end,
                                  KUR = case when EKSTREDEKULLAN=1 then isnull(DOVIZ_CINSI,'TL') else isnull(KUR,'TL') end,
                                  SUBEID=isnull(F.SUBEID,-1)
                FROM FATBASLIK F--FATURALAR
                where
                     F.FATURATARIH >= @BasTar
                     and F.FATURATARIH<@YilBasiTarihi  and isnull(F.DURUM,1)<>6
               -- group by F.REHBERID,case when isnull(F.DOVIZ_CINSI,'')<>'' then F.DOVIZ_CINSI else isnull(F.KUR,@Kur) end,isnull(F.SUBEID,-1)
)as LST
where LST.REHBERID>0
group by LST.REHBERID,LST.KUR,SUBEID
HAVING (SUM(BORC)-SUM(ALACAK))<> 0

end





