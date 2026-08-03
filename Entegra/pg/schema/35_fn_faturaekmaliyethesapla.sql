-- sp_FaturaEkMaliyetHesapla PG portu (MSSQL prosedur -> void fonksiyon).
--   Bagli faturalarin toplamini bu faturanin satirlarina TUTAR payina gore dagitir -> FATURA.EKMALIYET.
--   App 'exec sp_FaturaEkMaliyetHesapla &FatbasID' cagirir; PgExecCevir -> 'SELECT * FROM fn_...($1)'.
CREATE OR REPLACE FUNCTION public.fn_faturaekmaliyethesapla(p_fatbasid integer)
RETURNS void
AS $$
declare
  v_bagli_haric numeric; v_bagli_dahil numeric;
  v_fat_dahil   numeric; v_fat_haric   numeric;
begin
  -- Bagli faturalarin (BAGLIFATURAID=@FatBasID) haric/dahil toplami (+EKVERGI)
  select coalesce(sum(HaricToplam),0.0), coalesce(sum(DahilToplam),0.0)
    into v_bagli_haric, v_bagli_dahil
  from (
    select
      coalesce(case when FB.kdvdurum='Dahil'
                    then sum(F.tutar*100/(100+(F.kdv*(100.0-coalesce(F.kdvmuhafiyeti,0))/100.0)))
                    else sum(F.tutar) end, 0.0) + coalesce(FB.ekvergi,0.0) as HaricToplam,
      coalesce(case when FB.kdvdurum='Dahil'
                    then sum(F.tutar)
                    else sum(F.tutar*(1+((F.kdv*(100.0-coalesce(F.kdvmuhafiyeti,0))/100.0))/100.0)) end, 0.0) + coalesce(FB.ekvergi,0.0) as DahilToplam
    from FATBASLIK FB inner join FATURA F on F.fatbasid=FB.id
    where FB.baglifaturaid = p_fatbasid
    group by FB.kdvdurum, FB.id, FB.ekvergi
  ) asd;

  -- Bu faturanin (FATBASID=@FatBasID) haric/dahil toplami
  select coalesce(sum(ToplamFatTutariDahil),0.0), coalesce(sum(ToplamFatTutariHaric),0.0)
    into v_fat_dahil, v_fat_haric
  from (
    select
      case when FB.kdvdurum='Dahil' then sum(F.tutar) else 0 end as ToplamFatTutariDahil,
      case when FB.kdvdurum='Dahil' then 0 else sum(F.tutar) end as ToplamFatTutariHaric
    from FATBASLIK FB inner join FATURA F on F.fatbasid=FB.id
    where F.fatbasid = p_fatbasid
    group by FB.id, FB.kdvdurum
  ) sdf;

  if v_fat_dahil = 0 then
    update FATURA set ekmaliyet = (v_bagli_haric)*(nullif(tutar,0)/nullif(v_fat_haric,0))
    where fatbasid = p_fatbasid;
  else
    update FATURA set ekmaliyet = (v_bagli_dahil)*(nullif(tutar,0)/nullif(v_fat_dahil,0))
    where fatbasid = p_fatbasid;
  end if;
end $$ language plpgsql;
