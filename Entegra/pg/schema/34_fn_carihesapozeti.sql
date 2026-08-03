-- fn_CariHesapOzeti PG portu (MSSQL multi-statement TVF karsiligi).
--   Cari icin (bu yil) KASA+FATBASLIK+CEK/CEKHAREKET+SENET BORC/ALACAK toplami, KUR'a gore.
--   DURUM=1 gercek toplam, DURUM=2 sifir-fallback; DURUM'a gore TOP 1 (satir yoksa sifir doner).
--   arg3 double precision: cagiranlar hem double (fatura tutari) hem int-literal (0) geciyor
--   (int->double implicit). money -> numeric.
CREATE OR REPLACE FUNCTION public.fn_carihesapozeti(
  p_rehberid integer, p_kur varchar, p_faturatutar double precision)
RETURNS TABLE(borc numeric, alacak numeric, kur varchar, faturatutari numeric)
AS $$
declare v_yil int := extract(year from now())::int;
begin
  return query
  select X.borc, X.alacak, X.kur::varchar, X.faturatutar
  from (
    select 1 as durum,
           coalesce(sum(AA.borc),0.0) as borc,
           coalesce(sum(AA.alacak),0.0) as alacak,
           AA.kur as kur,
           p_faturatutar::numeric as faturatutar
    from (
        -- KASA
        select
          case when coalesce(K.ekstredekullan,0)=1 and K.borc>0   then K.doviz_tutari else K.borc   end as borc,
          case when coalesce(K.ekstredekullan,0)=1 and K.alacak>0 then K.doviz_tutari else K.alacak end as alacak,
          case when coalesce(K.ekstredekullan,0)=1 then K.doviz_kuru else K.kur end as kur
        from KASA K
        where K.tur not between 60 and 79 and K.rehberid=p_rehberid
          and extract(year from K.islemtarihi)=v_yil
      union all
        -- FATBASLIK
        select
          case when F.tur in (8,11,12,13) then 0.0 else (case when coalesce(F.ekstredekullan,0)=1 then F.doviz_tutari else F.fatura_tutari end) end,
          case when F.tur in (15,16,17)   then 0.0 else (case when coalesce(F.ekstredekullan,0)=1 then F.doviz_tutari else F.fatura_tutari end) end,
          case when coalesce(F.ekstredekullan,0)=1 then F.doviz_cinsi else F.kur end
        from FATBASLIK F
        where coalesce(F.durum,0)<>6 and F.tur in (8,11,12,13,15,16,17) and F.rehberid=p_rehberid
          and extract(year from F.faturatarih)=v_yil
      union all
        -- CEK
        select
          case when CH.islem in(140,131,132,133,134,137) then (case when coalesce(C.ekstredekullan,0)=1 then C.doviz_tutari else coalesce(C.tutar,0) end) else 0 end,
          case when CH.islem in(130,141)                 then (case when coalesce(C.ekstredekullan,0)=1 then C.doviz_tutari else coalesce(C.tutar,0) end) else 0 end,
          case when coalesce(C.ekstredekullan,0)=1 then C.doviz_kuru else coalesce(C.kur,'TL') end
        from CEKLER C inner join CEKHAREKET CH on C.id=CH.ceksenetlerid
        where CH.islem in(130,131,132,134,137,140,141) and CH.rehberid=p_rehberid
          and extract(year from C.tarih)=v_yil
      union all
        -- SENET
        select
          case when C.tur=34 then (case when coalesce(C.ekstredekullan,0)=1 then C.doviz_tutari else coalesce(C.tutar,0) end) else 0 end,
          case when C.tur=24 then (case when coalesce(C.ekstredekullan,0)=1 then C.doviz_tutari else coalesce(C.tutar,0) end) else 0 end,
          case when coalesce(C.ekstredekullan,0)=1 then C.doviz_kuru else coalesce(C.kur,'TL') end
        from SENETLER C
        where C.rehberid=p_rehberid
    ) AA
    where AA.kur=p_kur
    group by AA.kur
    union all
    select 2, 0, 0, p_kur, p_faturatutar::numeric
  ) X
  order by X.durum
  limit 1;
end $$ language plpgsql stable;
