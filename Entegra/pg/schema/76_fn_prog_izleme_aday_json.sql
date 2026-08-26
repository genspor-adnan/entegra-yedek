-- ============================================================================
-- fn_prog_izleme_aday_json
-- Kaynak: GenUpdate/_Konsolide_66_169/03_Izleme_SeriLot.sql
--
-- Seri/lot/SKT/URT seçim ekranı için aday listesi.
-- Salt-okuma fonksiyondur; yazma/aktarma fn_prog_izleme_yaz_json ve
-- fn_prog_izleme_aktar_json portları ayrıca ele alınmalıdır.
-- ============================================================================

DROP FUNCTION IF EXISTS public.fn_prog_izleme_aday_json(text);
CREATE FUNCTION public.fn_prog_izleme_aday_json(kosullar text DEFAULT '{}')
RETURNS TABLE(
  serilotid integer,
  serino varchar,
  lotno varchar,
  skt timestamp,
  urt timestamp,
  mevcut numeric,
  secili integer,
  secilenadet numeric,
  kaynakizlemid integer
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_mod text := lower(COALESCE(NULLIF(j->>'mod', ''), 'donusum'));
  v_stokid integer := NULLIF(j->>'stokId', '')::integer;
  v_izlemtur integer := NULLIF(j->>'izlemTur', '')::integer;
  v_depoid integer := NULLIF(j->>'depoId', '')::integer;
  v_donusumturu integer := NULLIF(j->>'donusumTuru', '')::integer;
  v_hedefbaslik integer := NULLIF(j#>>'{belge,baslikId}', '')::integer;
  v_hedefsatir integer := NULLIF(j#>>'{belge,satirId}', '')::integer;
  v_kaynakbaslik integer := NULLIF(j#>>'{kaynak,baslikId}', '')::integer;
  v_kaynaksatir integer := NULLIF(j#>>'{kaynak,satirId}', '')::integer;
  v_yontem text;
  v_yontemdis text := lower(NULLIF(j->>'yontem', ''));
  v_kaynakdetay text;
BEGIN
  IF v_stokid IS NULL OR v_stokid <= 0 THEN
    RAISE EXCEPTION 'stokId zorunlu.' USING ERRCODE = 'P0001';
  END IF;
  IF v_mod NOT IN ('donusum', 'cikis', 'giris') THEN
    RAISE EXCEPTION 'mod "donusum", "cikis" ya da "giris" olmali. (Sayim ayri akistir.)' USING ERRCODE = 'P0001';
  END IF;
  IF v_yontemdis IS NOT NULL AND v_yontemdis NOT IN ('tasima', 'depo', 'kendi') THEN
    RAISE EXCEPTION 'yontem "tasima", "depo" ya da "kendi" olmali.' USING ERRCODE = 'P0001';
  END IF;

  IF v_yontemdis IS NOT NULL THEN
    v_yontem := v_yontemdis;
  ELSIF v_mod = 'donusum' THEN
    IF v_donusumturu IS NULL THEN
      RAISE EXCEPTION 'mod=donusum icin donusumTuru zorunlu.' USING ERRCODE = 'P0001';
    END IF;
    IF v_kaynaksatir IS NULL OR v_kaynaksatir <= 0 THEN
      RAISE EXCEPTION 'mod=donusum icin kaynak.satirId zorunlu.' USING ERRCODE = 'P0001';
    END IF;

    SELECT r.kaynakdetaytablo
      INTO v_kaynakdetay
    FROM public.fn_prog_belgedonusum_rota() r
    WHERE r.donusumturu = v_donusumturu;

    IF v_kaynakdetay IS NULL THEN
      RAISE EXCEPTION 'Bilinmeyen donusum turu: %', v_donusumturu USING ERRCODE = 'P0001';
    END IF;

    v_yontem := CASE WHEN v_kaynakdetay = 'FATURA' THEN 'tasima' ELSE 'depo' END;
  ELSIF v_mod = 'cikis' THEN
    v_yontem := 'depo';
  ELSE
    v_yontem := 'kendi';
  END IF;

  IF v_yontem = 'depo' AND (v_depoid IS NULL OR v_depoid <= 0) THEN
    RAISE EXCEPTION 'Depodan secim icin gecerli depoId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  IF v_yontem = 'tasima' THEN
    RETURN QUERY
    WITH secili AS (
      SELECT si.serilotid, SUM(COALESCE(si.adet, 0))::numeric AS adet, MIN(si.id) AS izlemid
      FROM stokizleme si
      WHERE COALESCE(v_hedefsatir, 0) > 0
        AND si.baslikid = v_hedefbaslik
        AND si.satirid = v_hedefsatir
        AND COALESCE(si.serilotid, 0) > 0
      GROUP BY si.serilotid
    )
    SELECT si.serilotid,
           ssl.serino,
           ssl.lotno,
           ssl.skt,
           ssl.urt,
           (ABS(COALESCE(si.kalan, 0)) + COALESCE(k.kendi, 0))::numeric AS mevcut,
           CASE WHEN s.serilotid IS NULL THEN 0 ELSE 1 END AS secili,
           COALESCE(ABS(s.adet), 0)::numeric AS secilenadet,
           si.id AS kaynakizlemid
    FROM stokizleme si
    INNER JOIN stokserilot ssl ON ssl.id = si.serilotid
    LEFT JOIN secili s ON s.serilotid = si.serilotid
    LEFT JOIN LATERAL (
      SELECT SUM(ABS(COALESCE(h.adet, 0)))::numeric AS kendi
      FROM stokizleme h
      WHERE COALESCE(v_hedefsatir, 0) > 0
        AND h.satirid = v_hedefsatir
        AND h.donusid = si.id
    ) k ON TRUE
    WHERE si.satirid = v_kaynaksatir
      AND si.baslikid = COALESCE(NULLIF(v_kaynakbaslik, 0), si.baslikid)
      AND (ABS(COALESCE(si.kalan, 0)) + COALESCE(k.kendi, 0) > 0.0001 OR s.serilotid IS NOT NULL)
    ORDER BY ssl.skt, ssl.lotno, ssl.serino;

  ELSIF v_yontem = 'depo' THEN
    RETURN QUERY
    WITH secili AS (
      SELECT si.serilotid, SUM(COALESCE(si.adet, 0))::numeric AS adet, MIN(si.id) AS izlemid
      FROM stokizleme si
      WHERE COALESCE(v_hedefsatir, 0) > 0
        AND si.baslikid = v_hedefbaslik
        AND si.satirid = v_hedefsatir
        AND COALESCE(si.serilotid, 0) > 0
      GROUP BY si.serilotid
    )
    SELECT sdi.serilotid,
           ssl.serino,
           ssl.lotno,
           ssl.skt,
           ssl.urt,
           (COALESCE(sdi.kalan, 0) - COALESCE(k.kendi, 0))::numeric AS mevcut,
           CASE WHEN s.serilotid IS NULL THEN 0 ELSE 1 END AS secili,
           COALESCE(ABS(s.adet), 0)::numeric AS secilenadet,
           NULL::integer AS kaynakizlemid
    FROM stokdurumizleme sdi
    INNER JOIN stokserilot ssl ON ssl.id = sdi.serilotid
    LEFT JOIN secili s ON s.serilotid = sdi.serilotid
    LEFT JOIN LATERAL (
      SELECT SUM(COALESCE(d.adet, 0))::numeric AS kendi
      FROM stokizlemedepo d
      INNER JOIN stokizleme si2 ON si2.id = d.izlemid
      WHERE si2.satirid = v_hedefsatir
        AND si2.serilotid = sdi.serilotid
        AND d.depoid = v_depoid
    ) k ON TRUE
    WHERE sdi.stokid = v_stokid
      AND sdi.depoid = v_depoid
      AND (COALESCE(sdi.kalan, 0) - COALESCE(k.kendi, 0) > 0.0001 OR s.serilotid IS NOT NULL)
    ORDER BY ssl.skt, ssl.lotno, ssl.serino;

  ELSE
    RETURN QUERY
    SELECT si.serilotid,
           ssl.serino,
           ssl.lotno,
           ssl.skt,
           ssl.urt,
           SUM(COALESCE(si.adet, 0))::numeric AS mevcut,
           1 AS secili,
           SUM(COALESCE(si.adet, 0))::numeric AS secilenadet,
           MIN(si.id) AS kaynakizlemid
    FROM stokizleme si
    INNER JOIN stokserilot ssl ON ssl.id = si.serilotid
    WHERE si.baslikid = v_hedefbaslik
      AND si.satirid = v_hedefsatir
      AND (v_izlemtur IS NULL OR si.izlemtur = v_izlemtur)
    GROUP BY si.serilotid, ssl.serino, ssl.lotno, ssl.skt, ssl.urt
    ORDER BY ssl.skt, ssl.lotno, ssl.serino;
  END IF;
END;
$$;
