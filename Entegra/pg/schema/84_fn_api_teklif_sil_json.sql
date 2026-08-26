-- ============================================================================
-- fn_api_teklif_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
-- Plan:
--   IMAJ(YERI=80) -> IMAJ/DOKUMAN/GOREVYORUM yorum ekleri -> TEKLIFDETAY
--   -> TEKLIF_USER(varsa) -> TEKLIF
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_teklif_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kayitid integer := NULLIF(j->>'KayitId', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_neden varchar;
  v_n integer := 0;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_toplam integer := 0;
BEGIN
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM teklif WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Teklif bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  SELECT neden INTO v_neden
  FROM public.fn_prog_teklif_silinebilir_mi(v_kayitid, 0)
  WHERE COALESCE(silinebilir, 1) = 0
  LIMIT 1;

  IF v_neden IS NOT NULL THEN
    RAISE EXCEPTION 'Teklif silinemez: %', v_neden USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'TEKLIF', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 97, p_usttabno := 97, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'TEKLIFDETAY', p_kosul := 'TEKLIFID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 98, p_usttabno := 97, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM imaj WHERE yeri = 80 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM imaj
  WHERE yeri = 1
    AND yer_id IN (
      SELECT id FROM dokuman
      WHERE modul = 210
        AND modulid IN (SELECT id FROM gorevyorum WHERE tur = 97 AND gorevid = v_kayitid)
    );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman
  WHERE modul = 210
    AND modulid IN (SELECT id FROM gorevyorum WHERE tur = 97 AND gorevid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevyorum WHERE tur = 97 AND gorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM teklifdetay WHERE teklifid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.teklif_user') IS NOT NULL THEN
    DELETE FROM teklif_user WHERE id = v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM teklif WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 97,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
