-- ============================================================================
-- fn_api_dokuman_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- Plan:
--   IMAJ(YERI=1,YER_ID=ID) -> DOKUMANYETKI -> REHBERBILGI -> DOKUMANGECMIS
--   -> DOKUMANILGILI -> DOKUMANBILDIRIM -> DOKUMANKISAYOL -> DOKUMAN
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_dokuman_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kayitid integer := NULLIF(j->>'KayitId', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_n integer := 0;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_toplam integer := 0;
BEGIN
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM dokuman WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Dokuman bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (SELECT 1 FROM dokumankisayol WHERE dokumanid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu dokumanin kisayolu var, once kisayollari kaldirin.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM sozlesmeler WHERE yeri = 321 AND yer_id = v_kayitid) THEN
    RAISE EXCEPTION 'Bu dokumana bagli sozlesme var, silinemez.' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'DOKUMAN', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 321, p_usttabno := 321, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ', p_kosul := 'YERI=1 AND YER_ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := 321, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'DOKUMANYETKI', p_kosul := 'YERI=321 AND YERID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 321, p_usttabno := 321, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'REHBERBILGI', p_kosul := 'YERI=321 AND YER_ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 76, p_usttabno := 321, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'DOKUMANGECMIS', p_kosul := 'DOKUMANID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 374, p_usttabno := 321, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM imaj WHERE yeri = 1 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokumanyetki WHERE yeri = 321 AND yerid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM rehberbilgi WHERE yeri = 321 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokumangecmis WHERE dokumanid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokumanilgili WHERE dokumanid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokumanbildirim WHERE dokumanid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokumankisayol WHERE dokumanid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 321,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
