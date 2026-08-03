-- fn_KaynakBelgeNolariStrOlarakGetir (MSSQL) PG portu: bir belgenin (FATBASLIK/SIPARIS) kaynak
--   belge numaralarini ', ' ile birlestirip string doner. @Yeri = belge turu, @YerID = baslik ID.
--   MSSQL `SELECT @v=@v+', '+col FROM(cok satir)` satir-birlestirme idiom'u -> PG string_agg.
--   SIPARIS/FATBASLIK ekraninda kaynak-belge kolonu. Ilk param smallint gelebilir (int'e implicit).
CREATE OR REPLACE FUNCTION public.fn_kaynakbelgenolaristrolarakgetir(p_yeri integer, p_yerid integer)
RETURNS varchar
LANGUAGE plpgsql STABLE
AS $$
DECLARE
  r varchar := '';
BEGIN
  if p_yeri = 11 then          -- Alis Fatura: 407 siparis, 408/461 fatbaslik
    select string_agg(no, ', ') into r from (
      select SIPARISNO as no from SIPARIS where ID in (select distinct SIPARISID from SIPARISDETAY where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=407))
      union all
      select FATURANO from FATBASLIK where ID in (select distinct FATBASID from FATURA where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=408))
      union all
      select FATURANO from FATBASLIK where ID in (select distinct FATBASID from FATURA where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=461))
    ) x;
  elsif p_yeri = 15 then       -- Satis Fatura: 405/410 siparis, 462/411 fatbaslik
    select string_agg(no, ', ') into r from (
      select SIPARISNO as no from SIPARIS where ID in (select distinct SIPARISID from SIPARISDETAY where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=405))
      union all
      select SIPARISNO from SIPARIS where ID in (select distinct SIPARISID from SIPARISDETAY where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=410))
      union all
      select FATURANO from FATBASLIK where ID in (select distinct FATBASID from FATURA where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=462))
      union all
      select FATURANO from FATBASLIK where ID in (select distinct FATBASID from FATURA where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=411))
    ) x;
  elsif p_yeri = 10 then       -- Alis Irsaliye: 406 siparis
    select string_agg(SIPARISNO, ', ') into r from SIPARIS where ID in (select distinct SIPARISID from SIPARISDETAY where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=406));
  elsif p_yeri = 14 then       -- Satis Irsaliye: 409 siparis
    select string_agg(SIPARISNO, ', ') into r from SIPARIS where ID in (select distinct SIPARISID from SIPARISDETAY where ID in (select distinct YERID from FATURA where FATBASID=p_yerid and YERI=409));
  elsif p_yeri = 9 then        -- Alis Siparis: 412 teklif
    select string_agg(TEKLIFNO, ', ') into r from TEKLIF where ID in (select distinct TEKLIFID from TEKLIFDETAY where ID in (select distinct YERID from SIPARISDETAY where SIPARISID=p_yerid and YERI=412));
  elsif p_yeri = 19 then       -- Satis Siparis: 413 teklif
    select string_agg(TEKLIFNO, ', ') into r from TEKLIF where ID in (select distinct TEKLIFID from TEKLIFDETAY where ID in (select distinct YERID from SIPARISDETAY where SIPARISID=p_yerid and YERI=413));
  end if;
  return coalesce(r, '');
END;
$$;
