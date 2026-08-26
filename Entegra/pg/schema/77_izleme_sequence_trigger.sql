-- ============================================================================
-- Izleme sequence + trigger katmani
-- Kaynak: GenUpdate/_Konsolide_66_169/03_Izleme_SeriLot.sql
--
-- PG'de STOKIZLEME/STOKSERILOT id kolonlari seed sonrasi default/sequence
-- tasimamis olabilir. Yazma API'leri icin once identity benzeri default kurulur.
--
-- Triggerlar:
--   1) STOKIZLEMEDEPO insert/update/delete -> STOKDURUMIZLEME delta bakiyesi
--   2) STOKIZLEME delete -> depo hareketlerini parent silinmeden geri al
--   3) STOKIZLEME insert/update/delete -> DONUSID kaynak kaydin KALAN degeri
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS public.stokizleme_id_seq;
SELECT setval('public.stokizleme_id_seq', GREATEST(COALESCE((SELECT MAX(id) FROM public.stokizleme), 0), 1), true);

CREATE SEQUENCE IF NOT EXISTS public.stokserilot_id_seq;
SELECT setval('public.stokserilot_id_seq', GREATEST(COALESCE((SELECT MAX(id) FROM public.stokserilot), 0), 1), true);

CREATE OR REPLACE FUNCTION public.fn_izleme_bakiye_delta(
  p_stokid integer,
  p_depoid integer,
  p_serilotid integer,
  p_delta numeric
)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF COALESCE(p_stokid, 0) <= 0 OR COALESCE(p_depoid, 0) <= 0
     OR COALESCE(p_serilotid, 0) <= 0 OR COALESCE(p_delta, 0) = 0 THEN
    RETURN;
  END IF;

  INSERT INTO public.stokdurumizleme(stokid, depoid, serilotid, kalan)
  VALUES (p_stokid, p_depoid, p_serilotid, 0)
  ON CONFLICT (stokid, depoid, serilotid) DO NOTHING;

  UPDATE public.stokdurumizleme
     SET kalan = COALESCE(kalan, 0) + p_delta
   WHERE stokid = p_stokid
     AND depoid = p_depoid
     AND serilotid = p_serilotid;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_stokizlemedepo_bakiye_delta()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  si record;
BEGIN
  IF TG_OP IN ('UPDATE', 'DELETE') THEN
    SELECT stokid, serilotid INTO si
    FROM public.stokizleme
    WHERE id = OLD.izlemid;

    -- Parent STOKIZLEME once silindiyse bakiye, trg_stokizleme_before_delete
    -- tarafindan geri alinmistir; burada parent bulunamaz ve tekrar dusulmez.
    IF FOUND THEN
      PERFORM public.fn_izleme_bakiye_delta(si.stokid, OLD.depoid, si.serilotid, (-1 * COALESCE(OLD.adet, 0))::numeric);
    END IF;
  END IF;

  IF TG_OP IN ('INSERT', 'UPDATE') THEN
    SELECT stokid, serilotid INTO si
    FROM public.stokizleme
    WHERE id = NEW.izlemid;

    IF FOUND THEN
      PERFORM public.fn_izleme_bakiye_delta(si.stokid, NEW.depoid, si.serilotid, COALESCE(NEW.adet, 0)::numeric);
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_stokizlemedepo_bakiye_delta ON public.stokizlemedepo;
CREATE TRIGGER tg_stokizlemedepo_bakiye_delta
AFTER INSERT OR UPDATE OR DELETE ON public.stokizlemedepo
FOR EACH ROW EXECUTE FUNCTION public.trg_stokizlemedepo_bakiye_delta();

CREATE OR REPLACE FUNCTION public.trg_stokizleme_before_delete_bakiye()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  d record;
BEGIN
  -- MSSQL akisi parent STOKIZLEME'yi once siler. Depo satirlari hala dururken
  -- hareketler geri alinmazsa STOKDURUMIZLEME eksik/fazla kalir.
  FOR d IN
    SELECT depoid, SUM(COALESCE(adet, 0)) AS adet
    FROM public.stokizlemedepo
    WHERE izlemid = OLD.id
    GROUP BY depoid
  LOOP
    PERFORM public.fn_izleme_bakiye_delta(OLD.stokid, d.depoid, OLD.serilotid, (-1 * COALESCE(d.adet, 0))::numeric);
  END LOOP;

  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS tg_stokizleme_before_delete_bakiye ON public.stokizleme;
CREATE TRIGGER tg_stokizleme_before_delete_bakiye
BEFORE DELETE ON public.stokizleme
FOR EACH ROW EXECUTE FUNCTION public.trg_stokizleme_before_delete_bakiye();

CREATE OR REPLACE FUNCTION public.trg_izlemorjinalyap()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_ids integer[];
BEGIN
  WITH etkilenen AS (
    SELECT OLD.donusid AS id WHERE TG_OP IN ('UPDATE', 'DELETE') AND COALESCE(OLD.donusid, 0) > 0
    UNION
    SELECT NEW.donusid AS id WHERE TG_OP IN ('INSERT', 'UPDATE') AND COALESCE(NEW.donusid, 0) > 0
  )
  SELECT ARRAY_AGG(DISTINCT id) INTO v_ids FROM etkilenen;

  IF COALESCE(array_length(v_ids, 1), 0) > 0 THEN
    UPDATE public.stokizleme o
       SET kalan = COALESCE(o.adet, 0) - COALESCE(d.toplamadet, 0)
      FROM unnest(v_ids) e(id)
      LEFT JOIN (
        SELECT s.donusid AS id, SUM(COALESCE(s.adet, 0)) AS toplamadet
        FROM public.stokizleme s
        WHERE COALESCE(s.donusid, 0) = ANY(v_ids)
        GROUP BY s.donusid
      ) d ON d.id = e.id
     WHERE o.id = e.id;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_izlemorjinalyap ON public.stokizleme;
CREATE TRIGGER tg_izlemorjinalyap
AFTER INSERT OR UPDATE OR DELETE ON public.stokizleme
FOR EACH ROW EXECUTE FUNCTION public.trg_izlemorjinalyap();

-- Salt okuma bakiye kontrol raporu. MSSQL sp_Prog_Izleme_BakiyeKontrol portu.
DROP FUNCTION IF EXISTS public.fn_prog_izleme_bakiyekontrol(integer, numeric, integer);
CREATE FUNCTION public.fn_prog_izleme_bakiyekontrol(
  p_ayrinti integer DEFAULT 0,
  p_esik numeric DEFAULT 0.0001,
  p_ustsinir integer DEFAULT 200
)
RETURNS TABLE(
  stokid integer,
  depoid integer,
  serilotid integer,
  hareket numeric,
  bakiye numeric,
  fark numeric
)
LANGUAGE sql STABLE AS $$
  WITH hareket AS (
    SELECT si.stokid, d.depoid, si.serilotid, SUM(COALESCE(d.adet, 0))::numeric AS hareket
    FROM public.stokizlemedepo d
    INNER JOIN public.stokizleme si ON si.id = d.izlemid
    GROUP BY si.stokid, d.depoid, si.serilotid
  ),
  k AS (
    SELECT COALESCE(h.stokid, s.stokid) AS stokid,
           COALESCE(h.depoid, s.depoid) AS depoid,
           COALESCE(h.serilotid, s.serilotid) AS serilotid,
           COALESCE(h.hareket, 0)::numeric AS hareket,
           COALESCE(s.kalan, 0)::numeric AS bakiye,
           (COALESCE(s.kalan, 0) - COALESCE(h.hareket, 0))::numeric AS fark
    FROM hareket h
    FULL JOIN public.stokdurumizleme s
      ON s.stokid = h.stokid AND s.depoid = h.depoid AND s.serilotid = h.serilotid
  )
  SELECT k.stokid, k.depoid, k.serilotid, k.hareket, k.bakiye, k.fark
  FROM k
  WHERE p_ayrinti <> 0 AND ABS(k.fark) > p_esik
  ORDER BY ABS(k.fark) DESC
  LIMIT p_ustsinir;
$$;
