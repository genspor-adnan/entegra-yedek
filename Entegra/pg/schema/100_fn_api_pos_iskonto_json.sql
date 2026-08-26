-- ============================================================================
-- fn_api_pos_iskonto_json
-- Kaynak: GenUpdate/_Konsolide_66_169/05_Kart_Kaydet_POS.sql
--
-- POS iskonto PG portu. FatTablo yalniz pg_temp gecici tablo olabilir.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_pos_iskonto_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_fat regclass := public.fn_api_pos_temp_regclass(j->>'FatTablo');
  v_adisyon integer := COALESCE(NULLIF(j->>'AdisyonId', '')::integer, 0);
  v_oran numeric := COALESCE(NULLIF(j->>'Oran', '')::numeric, 0);
  v_sql text;
BEGIN
  IF v_fat IS NULL THEN
    RAISE EXCEPTION 'Gecici tablo bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  v_sql := format(
    'UPDATE %s
        SET iskonto = $1,
            tutar = adet * birimfiyat * ((100.0 - $1) / 100.0),
            doviz_tutari = adet * birimfiyat * ((100.0 - $1) / 100.0)',
    v_fat::text
  );
  EXECUTE v_sql USING v_oran;

  IF v_adisyon > 0 THEN
    UPDATE fatura
       SET iskonto = v_oran,
           tutar = adet * birimfiyat * ((100.0 - v_oran) / 100.0)
     WHERE fatbasid = v_adisyon;

    UPDATE fatbaslik fb
       SET kdv_tutari = (
             SELECT CASE WHEN fb.kdvdurum = 'Hariç'
                         THEN COALESCE(ROUND(SUM(f.tutar * (f.kdv / 100.0)), 2), 0.0)
                         ELSE ROUND(COALESCE(SUM(f.tutar - (f.tutar / (1 + (f.kdv / 100.0)))), 0.0), 2)
                    END
               FROM fatura f
              WHERE f.fatbasid = fb.id
           ),
           fatura_tutari = (
             SELECT CASE WHEN fb.kdvdurum = 'Hariç'
                         THEN COALESCE(SUM(ROUND(f.tutar * (1 + (f.kdv / 100.0)), 2)), 0.0)
                         ELSE COALESCE(SUM(ROUND(f.tutar, 2)), 0.0)
                    END
               FROM fatura f
              WHERE f.fatbasid = fb.id
           )
     WHERE fb.id = v_adisyon;
  END IF;

  RETURN jsonb_build_object('Sonuc', 1, 'AdisyonId', v_adisyon, 'Oran', v_oran)::text;
END;
$$;
