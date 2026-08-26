-- Gentegre PG migration
-- MSSQL sp_Prog_Kayit_Silinebilir_Mi icin uyumluluk on-kontrolu.
-- Not: Asil silme fonksiyonlari kendi is kurali kontrollerini yine yapar.

CREATE OR REPLACE FUNCTION public.fn_prog_kayit_silinebilir_mi(
  p_modul integer,
  p_kayitid bigint
)
RETURNS TABLE(silinebilir integer, neden text, mesaj text)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  r record;
BEGIN
  IF COALESCE(p_kayitid, 0) <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE='P0001';
  END IF;

  -- Siparis
  IF p_modul = 91 THEN
    SELECT x.silinebilir, x.neden, x.belgead, x.belgetarih, x.belgeno
      INTO r
    FROM public.fn_prog_siparis_silinebilir_mi(p_kayitid::integer, 0) x
    WHERE COALESCE(x.silinebilir, 1) = 0
    LIMIT 1;

    IF FOUND THEN
      RETURN QUERY SELECT 0, r.neden::text,
        COALESCE(NULLIF(r.belgead::text, ''), 'Kayit silinemez') ||
        CASE WHEN r.belgeno IS NULL THEN '' ELSE ' (' || r.belgeno::text || ')' END;
      RETURN;
    END IF;
  END IF;

  -- Teklif
  IF p_modul = 97 THEN
    SELECT x.silinebilir, x.neden, x.belgead, x.belgetarih, x.belgeno
      INTO r
    FROM public.fn_prog_teklif_silinebilir_mi(p_kayitid::integer, 0) x
    WHERE COALESCE(x.silinebilir, 1) = 0
    LIMIT 1;

    IF FOUND THEN
      RETURN QUERY SELECT 0, r.neden::text,
        COALESCE(NULLIF(r.belgead::text, ''), 'Kayit silinemez') ||
        CASE WHEN r.belgeno IS NULL THEN '' ELSE ' (' || r.belgeno::text || ')' END;
      RETURN;
    END IF;
  END IF;

  RETURN QUERY SELECT 1, NULL::text, ''::text;
END;
$$;
