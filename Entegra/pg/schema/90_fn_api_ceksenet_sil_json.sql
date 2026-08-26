-- ============================================================================
-- fn_api_ceksenet_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- Modul JSON'dan gelir (315/316/318/319); gelmezse 315 varsayilir.
-- Plan: IMAJ(YERI=21) -> CEKHAREKET -> CEKLER.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_ceksenet_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_modul integer := COALESCE(NULLIF(j->>'Modul', '')::integer, 315);
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
  IF v_modul NOT IN (315,316,318,319) THEN
    RAISE EXCEPTION 'Cek/senet modulu gecersiz: %', v_modul USING ERRCODE = 'P0001';
  END IF;
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM cekler WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Cek/senet bulunamadi.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (
    SELECT 1
      FROM cekhareket
     WHERE ceksenetlerid = v_kayitid
     GROUP BY ceksenetlerid
    HAVING COUNT(*) > 1
  ) THEN
    RAISE EXCEPTION 'Bu cek/senet hareket gormus, silinemez.' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'CEKLER', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := v_modul, p_usttabno := v_modul, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ', p_kosul := 'YERI=21 AND YER_ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := v_modul, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'CEKHAREKET', p_kosul := 'CEKSENETLERID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 317, p_usttabno := v_modul, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM imaj WHERE yeri = 21 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM cekhareket WHERE ceksenetlerid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM cekler WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', v_modul,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
