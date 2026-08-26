-- ============================================================================
-- fn_api_uretimrecete_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- sp_Api_Modul_Sil_Ic(138) / fn_Prog_Silme_Plan(138) PG portu.
-- Plan: URETIMRECETEOPR -> URETIMRECETEDETAY -> URETIMRECETE.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_uretimrecete_sil_json(kosullar text DEFAULT '{}')
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
  IF NOT EXISTS (SELECT 1 FROM uretimrecete WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Uretim recetesi bulunamadi.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM fatbaslik WHERE tur = 6 AND yeri = 138 AND yerid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu receteden uretim fisi olusturulmus, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM uretimemri WHERE receteid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu recete uretim emrinde kullanilmis, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM uretimrecetedetay WHERE uretimreceteid = v_kayitid AND COALESCE(anaurun, 0) = 0) THEN
    RAISE EXCEPTION 'Once Recete detayini silin!' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMRECETE', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 138, p_usttabno := 138, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMRECETEOPR', p_kosul := 'URETIMRECETEID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 155, p_usttabno := 138, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMRECETEDETAY', p_kosul := 'URETIMRECETEID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 139, p_usttabno := 138, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM uretimreceteopr WHERE uretimreceteid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimrecetedetay WHERE uretimreceteid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimrecete WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 138,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
