-- ============================================================
-- PDKS yardimci zaman-fonksiyonlari — MSSQL dbo.fn_* portlari
--   fn_prog_pdks_liste_json2'nin bagimliliklari. MSSQL->PG:
--   SUBSTRING/CHARINDEX->split_part, DATEPART->EXTRACT, DATEDIFF(mi)->EXTRACT(EPOCH)/60,
--   ROUND(x/60,0,1)=int-div, CONVERT(Time)->::time, DatePart(dw)=1(Pazar)->EXTRACT(DOW)=0.
-- ============================================================

-- HH:MM -> dakika
CREATE OR REPLACE FUNCTION public.fn_dakika(saat varchar) RETURNS int
LANGUAGE sql IMMUTABLE AS $$
  SELECT COALESCE(split_part(saat, ':', 1)::int, 0) * 60 + COALESCE(NULLIF(split_part(saat, ':', 2), '')::int, 0)
$$;

-- timestamp -> gun-ici dakika
CREATE OR REPLACE FUNCTION public.fn_dakikatarihten(tarih timestamp) RETURNS int
LANGUAGE sql IMMUTABLE AS $$
  SELECT EXTRACT(HOUR FROM tarih)::int * 60 + EXTRACT(MINUTE FROM tarih)::int
$$;

-- dakika -> "HH:MM" (isaretli)
CREATE OR REPLACE FUNCTION public.fn_saatolarak(dakika int) RETURNS varchar
LANGUAGE sql IMMUTABLE AS $$
  SELECT (CASE WHEN dakika < 0 THEN '-' ELSE '' END)
       || lpad((abs(dakika) / 60)::text, 2, '0') || ':'
       || lpad((abs(dakika) % 60)::text, 2, '0')
$$;

-- giris farki (vardiya giris str, pdks giris)
CREATE OR REPLACE FUNCTION public.fn_girfark(oldgiris varchar, giris timestamp) RETURNS varchar
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE sonuc varchar; ergec varchar; d1 int; d2 int;
BEGIN
  IF EXTRACT(DOW FROM giris) <> 0 THEN
    IF giris::time <> TIME '00:00:00' THEN
      d1 := fn_dakika(oldgiris);
      d2 := fn_dakikatarihten(giris);
      IF (d1 - d2) < 0 THEN
        sonuc := fn_saatolarak(d2 - d1); ergec := ' GEÇ';
      ELSIF (d2 - d1) = 0 THEN
        sonuc := '00:00'; ergec := 'ZAMANINDA';
      ELSE
        sonuc := fn_saatolarak(d1 - d2); ergec := ' ERKEN';
      END IF;
      RETURN sonuc || ergec;
    END IF;
    RETURN '00:00';
  END IF;
  RETURN '00:00';
END $$;

-- calisma farki (vardiya calsure str, calsure str)
CREATE OR REPLACE FUNCTION public.fn_calfark(varcalsure varchar, calsure varchar) RETURNS varchar
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE sonuc varchar; dcal int; dvar int;
BEGIN
  dcal := fn_dakika(calsure);
  dvar := fn_dakika(varcalsure);
  IF dcal - dvar < 0 THEN
    IF fn_saatolarak(dvar - dcal) <> '00:00'
      THEN sonuc := fn_saatolarak(dvar - dcal) || ' -';
      ELSE sonuc := fn_saatolarak(dvar - dcal);
    END IF;
  ELSIF (dvar - dcal) = 0 THEN
    sonuc := '00:00';
  ELSE
    IF fn_saatolarak(dcal - dvar) <> '00:00'
      THEN sonuc := fn_saatolarak(dcal - dvar) || ' +';
      ELSE sonuc := fn_saatolarak(dcal - dvar);
    END IF;
  END IF;
  RETURN sonuc;
END $$;

-- cikis farki (vardiya giris str, mola str, pdks giris, pdks cikis)
CREATE OR REPLACE FUNCTION public.fn_cikfark(oldgiris varchar, dakika varchar, giris timestamp, cikis timestamp) RETURNS varchar
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE sonuc varchar; ergec varchar; calsure int; gircikfark int;
BEGIN
  calsure := fn_dakika(oldgiris) + fn_dakika(dakika);
  gircikfark := (EXTRACT(EPOCH FROM (cikis - giris)) / 60)::int + fn_dakikatarihten(giris);
  IF calsure - gircikfark < 0 THEN
    sonuc := fn_saatolarak(gircikfark - calsure); ergec := ' GEÇ';
  ELSIF (gircikfark - calsure) = 0 THEN
    sonuc := '00:00'; ergec := 'ZAMANINDA';
  ELSE
    sonuc := fn_saatolarak(calsure - gircikfark); ergec := ' ERKEN';
  END IF;
  RETURN sonuc || ergec;
END $$;
