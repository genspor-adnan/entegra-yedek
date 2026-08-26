-- Gentegre PG migration
-- MSSQL GenDepoUpdate87 trigger portlari.

CREATE OR REPLACE FUNCTION public.trg_fatura_masrafid_guncelle()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF COALESCE(NEW.masrafid, 0) = 0 AND COALESCE(NEW.tur, 0) = 0 THEN
    NEW.masrafid := NEW.urunid;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_fatura_masrafid_guncelle ON public.fatura;
CREATE TRIGGER trg_fatura_masrafid_guncelle
BEFORE INSERT ON public.fatura
FOR EACH ROW EXECUTE FUNCTION public.trg_fatura_masrafid_guncelle();

CREATE OR REPLACE FUNCTION public.trg_uretimemriuser_skt_guncelle()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_kategori integer;
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW.skt IS DISTINCT FROM OLD.skt
     AND NEW.urt IS NOT DISTINCT FROM OLD.urt THEN
    RETURN NEW;
  END IF;

  IF NEW.urt IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT s.kategori
    INTO v_kategori
  FROM public.uretimemri u
  INNER JOIN public.stoklar s ON s.id = u.stokid
  WHERE u.id = NEW.id;

  IF COALESCE(v_kategori, 0) = 7 THEN
    NEW.skt := NEW.urt + interval '5 year';
  ELSE
    NEW.skt := NULL;
  END IF;

  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF to_regclass('public.uretimemri_user') IS NOT NULL THEN
    DROP TRIGGER IF EXISTS trg_uretimemriuser_skt_guncelle ON public.uretimemri_user;
    CREATE TRIGGER trg_uretimemriuser_skt_guncelle
    BEFORE INSERT OR UPDATE ON public.uretimemri_user
    FOR EACH ROW EXECUTE FUNCTION public.trg_uretimemriuser_skt_guncelle();
  ELSE
    RAISE NOTICE 'uretimemri_user tablosu yok; trg_uretimemriuser_skt_guncelle kurulmadı.';
  END IF;
END;
$$;
