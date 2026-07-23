-- ============================================================
-- fn_prog_kontrol_adet_izlemsiz / _izlemli — MSSQL sp_Prog_Kontrol_Adet_* PG portu
-- ------------------------------------------------------------
-- Tarih-bazli stok cikis kontrolu (StokCikisYeterliMi). ASOF = su-anki kalan - (belge tarihinden
--   SONRAKI net hareketler) - (duzenlenen satirin etkisi). YETERLI = ASOF >= istenen adet.
-- izlemsiz: STOKDURUM/FATURA/FATBASLIK. izlemli: STOKDURUMIZLEME/STOKIZLEME/STOKIZLEMEDEPO + serilot.
-- App exec :URUNID,:DEPOID,:TARIH,:ADET,:SATIRID[,:SERILOTID] -> PgExecCevir -> fn(...) positional.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_kontrol_adet_izlemsiz(int, int, timestamp, double precision, int);
CREATE FUNCTION public.fn_prog_kontrol_adet_izlemsiz(
    p_urunid int, p_depoid int, p_tarih timestamp, p_adet double precision, p_satirid int DEFAULT 0)
RETURNS TABLE(yeterli integer, kalan double precision, istenen double precision)
LANGUAGE sql STABLE AS $$
  WITH k AS (
    SELECT
      COALESCE((SELECT sd.kalan FROM stokdurum sd WHERE sd.stokid=p_urunid AND sd.depoid=p_depoid), 0)::double precision AS kalannow,
      COALESCE((SELECT SUM(CASE WHEN fb.girisdepo=p_depoid THEN f.adet ELSE 0 END)
                     - SUM(CASE WHEN fb.cikisdepo=p_depoid THEN f.adet ELSE 0 END)
                FROM fatura f INNER JOIN fatbaslik fb ON fb.id=f.fatbasid
                WHERE f.urunid=p_urunid AND fb.faturatarih > p_tarih
                  AND (p_satirid<=0 OR f.id<>p_satirid)), 0)::double precision AS sonra,
      COALESCE((SELECT SUM(CASE WHEN fb.girisdepo=p_depoid THEN f.adet ELSE 0 END)
                     - SUM(CASE WHEN fb.cikisdepo=p_depoid THEN f.adet ELSE 0 END)
                FROM fatura f INNER JOIN fatbaslik fb ON fb.id=f.fatbasid
                WHERE p_satirid>0 AND f.id=p_satirid), 0)::double precision AS satiretki
  )
  SELECT (CASE WHEN (kalannow-sonra-satiretki) >= p_adet THEN 1 ELSE 0 END)::integer,
         (kalannow-sonra-satiretki)::double precision,
         p_adet::double precision
  FROM k;
$$;

DROP FUNCTION IF EXISTS public.fn_prog_kontrol_adet_izlemli(int, int, timestamp, double precision, int, int);
CREATE FUNCTION public.fn_prog_kontrol_adet_izlemli(
    p_urunid int, p_depoid int, p_tarih timestamp, p_adet double precision,
    p_satirid int DEFAULT 0, p_serilotid int DEFAULT 0)
RETURNS TABLE(yeterli integer, kalan double precision, istenen double precision)
LANGUAGE sql STABLE AS $$
  WITH k AS (
    SELECT
      COALESCE((SELECT SUM(sdi.kalan) FROM stokdurumizleme sdi
                WHERE sdi.stokid=p_urunid AND sdi.depoid=p_depoid
                  AND (p_serilotid<=0 OR sdi.serilotid=p_serilotid)), 0)::double precision AS kalannow,
      COALESCE((SELECT SUM(sd.adet)
                FROM stokizleme si INNER JOIN stokizlemedepo sd ON sd.izlemid=si.id
                     INNER JOIN fatbaslik fb ON fb.id=si.baslikid
                WHERE si.stokid=p_urunid AND sd.depoid=p_depoid AND fb.faturatarih > p_tarih
                  AND (p_serilotid<=0 OR si.serilotid=p_serilotid)
                  AND (p_satirid<=0 OR si.satirid<>p_satirid)), 0)::double precision AS sonra,
      COALESCE((SELECT SUM(sd.adet)
                FROM stokizleme si INNER JOIN stokizlemedepo sd ON sd.izlemid=si.id
                WHERE p_satirid>0 AND si.stokid=p_urunid AND sd.depoid=p_depoid AND si.satirid=p_satirid
                  AND (p_serilotid<=0 OR si.serilotid=p_serilotid)), 0)::double precision AS satiretki
  )
  SELECT (CASE WHEN (kalannow-sonra-satiretki) >= p_adet THEN 1 ELSE 0 END)::integer,
         (kalannow-sonra-satiretki)::double precision,
         p_adet::double precision
  FROM k;
$$;
