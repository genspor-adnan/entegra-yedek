-- ============================================================================
-- fn_api_stoksayim_sil_json / fn_api_stok_sayim_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- sp_Api_Modul_Sil_Ic(520) / fn_Prog_Silme_Plan(520) PG portu.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_stoksayim_sil_json(kosullar text DEFAULT '{}')
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
  IF NOT EXISTS (SELECT 1 FROM stoksayim WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Stok sayim bulunamadi.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM stoksayimkalemleri WHERE sayimid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu sayimin kalemleri var, once kalemleri silin.' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKSAYIM', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 520, p_usttabno := 520, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKIZLEME', p_kosul := 'BELGETUR=99 AND BASLIKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 367, p_usttabno := 520, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKLOKASYON', p_kosul := 'DURUM=0 AND BELGETUR=99 AND BASLIKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 520, p_usttabno := 520, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATURA', p_kosul := 'FATBASID IN (SELECT ID FROM FATBASLIK WHERE TUR=7 AND ANAKAYITID=@pB)', p_kosulpar := v_kayitid,
                                 p_tabno := 132, p_usttabno := 520, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK', p_kosul := 'TUR=7 AND ANAKAYITID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 29, p_usttabno := 520, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM stokizleme WHERE belgetur = 99 AND baslikid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM stoklokasyon WHERE durum = 0 AND belgetur = 99 AND baslikid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM fatura WHERE fatbasid IN (SELECT id FROM fatbaslik WHERE tur = 7 AND anakayitid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM fatbaslik WHERE tur = 7 AND anakayitid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM stoksayim WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 520,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_stok_sayim_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  RETURN public.fn_api_stoksayim_sil_json(kosullar);
END;
$$;
