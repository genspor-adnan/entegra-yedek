-- Gentegre PG migration
-- MSSQL sp_Prog_Izleme_BakiyeOnar / GeriAl portu.
-- Geri alinabilir onarim: once eski/yeni bakiye IZLEMEBAKIYEONARIM'a yazilir.

CREATE TABLE IF NOT EXISTS public.izlemebakiyeonarim (
  id bigserial PRIMARY KEY,
  partiid integer NOT NULL,
  kullaniciid integer,
  stokid integer NOT NULL,
  depoid integer NOT NULL,
  serilotid integer NOT NULL,
  eskikalan double precision,
  yenikalan double precision NOT NULL,
  fark double precision NOT NULL,
  gerialindi smallint NOT NULL DEFAULT 0,
  tarih timestamp NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_izlemebakiyeonarim_parti
  ON public.izlemebakiyeonarim(partiid, gerialindi);

CREATE OR REPLACE FUNCTION public.fn_prog_izleme_bakiyeonar(
  p_uygula integer DEFAULT 0,
  p_esik numeric DEFAULT 0.0001,
  p_stokid integer DEFAULT NULL,
  p_depoid integer DEFAULT NULL,
  p_gecersizdepodahil integer DEFAULT 0,
  p_hareketsizsifirla integer DEFAULT 0,
  p_kullaniciid integer DEFAULT NULL
)
RETURNS TABLE(
  mod text,
  etkilenen integer,
  ekleneceksatir integer,
  guncelleneceksatir integer,
  enbuyukfark double precision,
  partiid integer,
  gerialmakomutu text
)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_partiid integer;
BEGIN
  IF to_regclass('pg_temp.tmp_izleme_bakiye_onar_aday') IS NOT NULL THEN
    DROP TABLE pg_temp.tmp_izleme_bakiye_onar_aday;
  END IF;

  CREATE TEMP TABLE tmp_izleme_bakiye_onar_aday ON COMMIT DROP AS
  WITH hareket AS (
    SELECT si.stokid, d.depoid, si.serilotid, SUM(COALESCE(d.adet, 0))::double precision AS hareket
    FROM public.stokizlemedepo d
    INNER JOIN public.stokizleme si ON si.id = d.izlemid
    GROUP BY si.stokid, d.depoid, si.serilotid
  ),
  k AS (
    SELECT COALESCE(s.stokid, h.stokid) AS stokid,
           COALESCE(s.depoid, h.depoid) AS depoid,
           COALESCE(s.serilotid, h.serilotid) AS serilotid,
           s.kalan::double precision AS eskikalan,
           COALESCE(h.hareket, 0)::double precision AS yenikalan,
           (COALESCE(s.kalan, 0) - COALESCE(h.hareket, 0))::double precision AS fark,
           CASE WHEN s.stokid IS NULL THEN 0 ELSE 1 END AS satirvar,
           CASE WHEN h.stokid IS NULL THEN 0 ELSE 1 END AS hareketvar
    FROM public.stokdurumizleme s
    FULL JOIN hareket h
      ON h.stokid = s.stokid AND h.depoid = s.depoid AND h.serilotid = s.serilotid
  )
  SELECT *
  FROM k
  WHERE abs(COALESCE(k.eskikalan, 0) - k.yenikalan) >= p_esik
    AND (p_stokid IS NULL OR k.stokid = p_stokid)
    AND (p_depoid IS NULL OR k.depoid = p_depoid)
    AND (COALESCE(p_gecersizdepodahil, 0) = 1 OR COALESCE(k.depoid, 0) <> 0)
    AND (COALESCE(p_hareketsizsifirla, 0) = 1 OR k.hareketvar = 1);

  IF COALESCE(p_uygula, 0) = 0 THEN
    RETURN QUERY
    SELECT 'KURU CALISMA - hicbir sey yazilmadi'::text,
           COUNT(*)::integer,
           COALESCE(SUM(CASE WHEN satirvar = 0 THEN 1 ELSE 0 END), 0)::integer,
           COALESCE(SUM(CASE WHEN satirvar = 1 THEN 1 ELSE 0 END), 0)::integer,
           MAX(abs(fark))::double precision,
           0::integer,
           NULL::text
    FROM pg_temp.tmp_izleme_bakiye_onar_aday;
    RETURN;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_temp.tmp_izleme_bakiye_onar_aday) THEN
    RETURN QUERY SELECT 'Onarilacak kayit yok'::text, 0, 0, 0, 0::double precision, 0, NULL::text;
    RETURN;
  END IF;

  SELECT COALESCE(MAX(o.partiid), 0) + 1
    INTO v_partiid
  FROM public.izlemebakiyeonarim o;

  INSERT INTO public.izlemebakiyeonarim
    (partiid, kullaniciid, stokid, depoid, serilotid, eskikalan, yenikalan, fark)
  SELECT v_partiid, p_kullaniciid, stokid, depoid, serilotid, eskikalan, yenikalan, fark
  FROM pg_temp.tmp_izleme_bakiye_onar_aday;

  INSERT INTO public.stokdurumizleme(stokid, depoid, serilotid, kalan)
  SELECT stokid, depoid, serilotid, yenikalan
  FROM pg_temp.tmp_izleme_bakiye_onar_aday
  WHERE satirvar = 0
  ON CONFLICT (stokid, depoid, serilotid) DO UPDATE SET kalan = EXCLUDED.kalan;

  UPDATE public.stokdurumizleme s
     SET kalan = a.yenikalan
  FROM pg_temp.tmp_izleme_bakiye_onar_aday a
  WHERE a.satirvar = 1
    AND s.stokid = a.stokid
    AND s.depoid = a.depoid
    AND s.serilotid = a.serilotid;

  RETURN QUERY
  SELECT 'UYGULANDI'::text,
         COUNT(*)::integer,
         COALESCE(SUM(CASE WHEN satirvar = 0 THEN 1 ELSE 0 END), 0)::integer,
         COALESCE(SUM(CASE WHEN satirvar = 1 THEN 1 ELSE 0 END), 0)::integer,
         MAX(abs(fark))::double precision,
         v_partiid,
         ('SELECT * FROM public.fn_prog_izleme_bakiyeonar_gerial(' || v_partiid::text || ');')::text
  FROM pg_temp.tmp_izleme_bakiye_onar_aday;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_izleme_bakiyeonar_gerial(p_partiid integer)
RETURNS TABLE(mod text, partiid integer, satir integer)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_say integer;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.izlemebakiyeonarim
    WHERE izlemebakiyeonarim.partiid = p_partiid
      AND gerialindi = 0
  ) THEN
    RETURN QUERY SELECT 'Geri alinacak parti yok ya da zaten geri alinmis'::text, p_partiid, 0;
    RETURN;
  END IF;

  DELETE FROM public.stokdurumizleme s
  USING public.izlemebakiyeonarim o
  WHERE o.partiid = p_partiid
    AND o.gerialindi = 0
    AND o.eskikalan IS NULL
    AND s.stokid = o.stokid
    AND s.depoid = o.depoid
    AND s.serilotid = o.serilotid;

  UPDATE public.stokdurumizleme s
     SET kalan = o.eskikalan
  FROM public.izlemebakiyeonarim o
  WHERE o.partiid = p_partiid
    AND o.gerialindi = 0
    AND o.eskikalan IS NOT NULL
    AND s.stokid = o.stokid
    AND s.depoid = o.depoid
    AND s.serilotid = o.serilotid;

  UPDATE public.izlemebakiyeonarim
     SET gerialindi = 1
   WHERE izlemebakiyeonarim.partiid = p_partiid
     AND gerialindi = 0;

  GET DIAGNOSTICS v_say = ROW_COUNT;

  RETURN QUERY SELECT 'GERI ALINDI'::text, p_partiid, v_say;
END;
$$;
