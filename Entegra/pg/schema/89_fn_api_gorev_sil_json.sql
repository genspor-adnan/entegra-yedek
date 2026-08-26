-- ============================================================================
-- fn_api_gorev_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- sp_Api_Modul_Sil_Ic(33) / fn_Prog_Silme_Plan(33) PG portu.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_gorev_sil_json(kosullar text DEFAULT '{}')
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
  IF NOT EXISTS (SELECT 1 FROM gorevler WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Gorev bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'GOREVLER', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 33, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ', p_kosul := 'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=33 AND MODULID=@pB)', p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'DOKUMAN', p_kosul := 'MODUL=33 AND MODULID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 321, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'ANIMSAT', p_kosul := 'TUR=1 AND ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 33, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ', p_kosul := 'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE GOREVID=@pB))', p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'DOKUMAN', p_kosul := 'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE GOREVID=@pB)', p_kosulpar := v_kayitid,
                                 p_tabno := 321, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'GOREVYORUM', p_kosul := 'GOREVID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 210, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'GOREVKULLANICI', p_kosul := 'TUR=11 AND LISTGOREVID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 33, p_usttabno := 33, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM imaj WHERE yeri = 1 AND yer_id IN (SELECT id FROM dokuman WHERE modul = 33 AND modulid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman WHERE modul = 33 AND modulid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM animsat WHERE tur = 1 AND id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM imaj
   WHERE yeri = 1
     AND yer_id IN (
       SELECT id FROM dokuman
        WHERE modul = 210
          AND modulid IN (SELECT id FROM gorevyorum WHERE gorevid = v_kayitid)
     );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman
   WHERE modul = 210
     AND modulid IN (SELECT id FROM gorevyorum WHERE gorevid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevyorum WHERE gorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevkullanici WHERE tur = 11 AND listgorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevler WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 33,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
