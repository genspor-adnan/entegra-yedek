-- ============================================================
-- fn_iskontolarstrolarak — MSSQL dbo.fn_IskontolarStrOlarak PG portu (skaler UDF)
--   Fatura satiri iskonto zincirini string uretir ('+10+5' gibi), bas '+' atilir.
--   MSSQL: SELECT @v=@v+'+'+convert(varchar,ISKONTO) FROM ... (satir-uzeri running concat) -> PG string_agg.
--   convert(varchar(5),x) -> round(x::numeric,2)::text (format ~yakin; display string).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_iskontolarstrolarak(int, int);
CREATE FUNCTION public.fn_iskontolarstrolarak(p_yeri int, p_yerid int)
RETURNS varchar
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v1 text := ''; v2 text := ''; i1 double precision; i2 double precision; s text;
BEGIN
  IF p_yeri IN (3,4,8,10,11,12,14,15,16,109,110,119) THEN
    SELECT ISKONTO, ISKONTO2 INTO i1, i2 FROM FATURA WHERE ID = p_yerid;
    -- IskStr1 (TUR=1)
    IF COALESCE(i1,0) <> 0 AND EXISTS(SELECT 1 FROM ISKONTOLAR WHERE YERI=p_yeri AND YERID=p_yerid AND TUR=1) THEN
      v1 := COALESCE((SELECT string_agg('+'||round(ISKONTO::numeric,2)::text, '') FROM ISKONTOLAR WHERE YERI=p_yeri AND YERID=p_yerid AND TUR=1), '');
    ELSIF COALESCE(i1,0) <> 0 THEN
      v1 := '+'||round(i1::numeric,2)::text;
    ELSE
      v1 := '';
    END IF;
    -- IskStr2 (TUR=2)
    IF COALESCE(i2,0) <> 0 AND EXISTS(SELECT 1 FROM ISKONTOLAR WHERE YERI=p_yeri AND YERID=p_yerid AND TUR=2) THEN
      v2 := COALESCE((SELECT string_agg('+'||round(ISKONTO::numeric,2)::text, '') FROM ISKONTOLAR WHERE YERI=p_yeri AND YERID=p_yerid AND TUR=2), '');
    ELSIF COALESCE(i2,0) <> 0 THEN
      v2 := '+'||round(i2::numeric,2)::text;
    ELSIF v1 = '' THEN
      v2 := '+0';
    ELSE
      v2 := '';
    END IF;
  END IF;
  s := v1 || v2;
  IF length(s) >= 1 THEN RETURN substring(s from 2); ELSE RETURN ''; END IF;
END $$;
