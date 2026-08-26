-- Gentegre PG migration
-- MSSQL sp_Prog_SiradakiNo_Ic output-param cekirdegi icin PG uyumluluk wrapper'i.
-- PG'de sonuc tek satir RETURNS TABLE olarak doner; transaction rollback ile geri alinabilir.

CREATE OR REPLACE FUNCTION public.fn_prog_siradakino_ic(
    p_tablo     text,
    p_alan      text,
    p_kapsam    text    DEFAULT '',
    p_kosul     text    DEFAULT NULL,
    p_baslangic bigint  DEFAULT 1,
    p_adet      integer DEFAULT 1,
    p_dijit     integer DEFAULT 0,
    p_rezerve   boolean DEFAULT true,
    p_dogrula   boolean DEFAULT true
)
RETURNS TABLE(ilkno bigint, sonno bigint, no text, anahtar text)
LANGUAGE sql VOLATILE AS $$
  SELECT *
  FROM public.fn_prog_siradakino(
    p_tablo, p_alan, p_kapsam, p_kosul, p_baslangic,
    p_adet, p_dijit, p_rezerve, p_dogrula
  );
$$;
