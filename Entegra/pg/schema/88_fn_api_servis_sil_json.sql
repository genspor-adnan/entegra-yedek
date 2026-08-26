-- ============================================================================
-- fn_api_servis_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- sp_Api_Modul_Sil_Ic(83) / fn_Prog_Silme_Plan(83) PG portu.
-- SERVIS_USER ve SERVISHAREKET_USER bazı kurulumlarda yok; opsiyonel ele alınır.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_servis_sil_json(kosullar text DEFAULT '{}')
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
  IF NOT EXISTS (SELECT 1 FROM servis WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Servis bulunamadi.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM fatbaslik WHERE servisid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu servisten belge olusturulmus, silinemez.' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVIS', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 83, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ', p_kosul := 'YERI=83 AND YER_ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVISDETAY', p_kosul := 'SERVISID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 183, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVISBILGI', p_kosul := 'SERVISID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 183, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVISDETAYPERSONEL', p_kosul := 'SERVISID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 430, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVISASAMA', p_kosul := 'SERVISID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 183, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'GOREVKULLANICI', p_kosul := 'TUR=12 AND LISTGOREVID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 183, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.servishareket_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVISHAREKET_USER', p_kosul := 'ID IN (SELECT ID FROM SERVISHAREKET WHERE SERVISID=@pB)', p_kosulpar := v_kayitid,
                                   p_tabno := 183, p_usttabno := 83, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVISHAREKET', p_kosul := 'SERVISID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 183, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(
           p_tablo := 'IMAJ',
           p_kosul := 'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID=@pB))',
           p_kosulpar := v_kayitid,
           p_tabno := 42, p_usttabno := 83, p_ustid := v_kayitid,
           p_kulid := v_kulid, p_subeid := v_subeid,
           p_ip := v_ip, p_istasyon := v_ist,
           p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(
           p_tablo := 'DOKUMAN',
           p_kosul := 'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID=@pB)',
           p_kosulpar := v_kayitid,
           p_tabno := 321, p_usttabno := 83, p_ustid := v_kayitid,
           p_kulid := v_kulid, p_subeid := v_subeid,
           p_ip := v_ip, p_istasyon := v_ist,
           p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'GOREVYORUM', p_kosul := 'TUR=83 AND GOREVID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 210, p_usttabno := 83, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.servis_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'SERVIS_USER', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                   p_tabno := 83, p_usttabno := 83, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  DELETE FROM imaj WHERE yeri = 83 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM servisdetay WHERE servisid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM servisbilgi WHERE servisid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM servisdetaypersonel WHERE servisid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM servisasama WHERE servisid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevkullanici WHERE tur = 12 AND listgorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.servishareket_user') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.servishareket_user WHERE id IN (SELECT id FROM public.servishareket WHERE servisid = $1)' USING v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM servishareket WHERE servisid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM imaj
   WHERE yeri = 1
     AND yer_id IN (
       SELECT id FROM dokuman
        WHERE modul = 210
          AND modulid IN (SELECT id FROM gorevyorum WHERE tur = 83 AND gorevid = v_kayitid)
     );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman
   WHERE modul = 210
     AND modulid IN (SELECT id FROM gorevyorum WHERE tur = 83 AND gorevid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevyorum WHERE tur = 83 AND gorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.servis_user') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.servis_user WHERE id = $1' USING v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM servis WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 83,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
