-- ============================================================================
-- fn_api_pos_satis_json
-- Kaynak: GenUpdate/_Konsolide_66_169/05_Kart_Kaydet_POS.sql
--
-- POS satis PG portu. FatBasTablo/FatTablo icin yalniz pg_temp gecici tablo
-- kabul edilir.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_pos_temp_regclass(p_ad text)
RETURNS regclass
LANGUAGE plpgsql AS $$
DECLARE
  v_ad text := trim(COALESCE(p_ad, ''));
  v_reg regclass;
BEGIN
  IF v_ad = '' THEN
    RETURN NULL;
  END IF;

  v_ad := replace(v_ad, '"', '');
  IF position('.' in v_ad) = 0 THEN
    v_ad := 'pg_temp.' || v_ad;
  END IF;

  IF lower(v_ad) NOT LIKE 'pg_temp.%' THEN
    RETURN NULL;
  END IF;

  SELECT to_regclass(v_ad) INTO v_reg;
  RETURN v_reg;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_pos_satis_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_fatbas regclass := public.fn_api_pos_temp_regclass(j->>'FatBasTablo');
  v_fat regclass := public.fn_api_pos_temp_regclass(j->>'FatTablo');
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_satisid bigint;
  v_detay integer := 0;
  v_sql text;
BEGIN
  IF v_fatbas IS NULL OR v_fat IS NULL THEN
    RAISE EXCEPTION 'Gecici tablo bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  v_sql := format(
    'INSERT INTO satis(tarih, tur, rehberid, faturano, cikisdepo, ekleyen)
     SELECT faturatarih, tur, rehberid, faturano, cikisdepo, $1 FROM %s
     RETURNING id',
    v_fatbas::text
  );
  EXECUTE v_sql USING v_kulid INTO v_satisid;

  v_sql := format(
    'INSERT INTO satisdetay(satisid, urunid, adet, birim, miktar, birimfiyat, tutar, iskonto, iskonto2)
     SELECT $1, urunid, adet, birim, miktar, birimfiyat, tutar, iskonto, iskonto2 FROM %s',
    v_fat::text
  );
  EXECUTE v_sql USING v_satisid;
  GET DIAGNOSTICS v_detay = ROW_COUNT;

  RETURN jsonb_build_object('Sonuc', 1, 'SatisId', v_satisid, 'Detay', COALESCE(v_detay, 0))::text;
END;
$$;
