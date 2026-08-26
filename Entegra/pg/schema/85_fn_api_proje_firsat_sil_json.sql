-- ============================================================================
-- fn_api_proje_sil_json / fn_api_firsat_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- Modul 70: PROJE
-- Modul 170: FIRSAT (fiziksel tablo PROJELER)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_proje_firsat_sil_ic(p_modul integer, kosullar text DEFAULT '{}')
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
  v_ad text := CASE WHEN p_modul = 170 THEN 'firsat' ELSE 'proje' END;
BEGIN
  IF p_modul NOT IN (70,170) THEN
    RAISE EXCEPTION 'Modul desteklenmiyor: %', p_modul USING ERRCODE = 'P0001';
  END IF;
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM projeler WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Kayit bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (SELECT 1 FROM fatbaslik WHERE projeid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu % ait belge var, silinemez.', v_ad USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM kasa WHERE projeid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu % ait kasa hareketi var, silinemez.', v_ad USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM cekhareket WHERE projeid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu % ait cek hareketi var, silinemez.', v_ad USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM gorevler WHERE projeid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu % ait is/gorev var, silinemez.', v_ad USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM teklif WHERE projeid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu % ait teklif var, silinemez.', v_ad USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM siparis WHERE projeid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu % ait siparis var, silinemez.', v_ad USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'PROJELER', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := p_modul, p_usttabno := p_modul, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'PROJEASAMA', p_kosul := 'PROJEID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 371, p_usttabno := p_modul, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM imaj WHERE yeri = p_modul AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM imaj
  WHERE yeri = 1
    AND yer_id IN (
      SELECT id FROM dokuman
      WHERE modul = 210
        AND modulid IN (SELECT id FROM gorevyorum WHERE tur = p_modul AND gorevid = v_kayitid)
    );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman
  WHERE modul = 210
    AND modulid IN (SELECT id FROM gorevyorum WHERE tur = p_modul AND gorevid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevyorum WHERE tur = p_modul AND gorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM rehberbilgi WHERE yeri = 70 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM projeasama WHERE projeid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM projeler WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', p_modul,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_proje_sil_json(kosullar text DEFAULT '{}')
RETURNS text LANGUAGE sql AS $$ SELECT public.fn_api_proje_firsat_sil_ic(70, kosullar) $$;

CREATE OR REPLACE FUNCTION public.fn_api_firsat_sil_json(kosullar text DEFAULT '{}')
RETURNS text LANGUAGE sql AS $$ SELECT public.fn_api_proje_firsat_sil_ic(170, kosullar) $$;
