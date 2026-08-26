-- ============================================================================
-- fn_api_belge_siparis_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- MSSQL tarafinda genel modul silme motoru (modul 91) kullanilir.
-- PG portu siparis icin ayni sirayi acik yazar:
--   REHBERBILGI -> IMAJ/DOKUMAN/GOREVYORUM -> SIPARISDETAY -> SIPARIS_USER -> SIPARIS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_belge_siparis_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kayitid integer := COALESCE(NULLIF(j->>'KayitId', '')::integer, NULLIF(j->>'BelgeId', '')::integer);
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_tur integer;
  v_neden varchar;
  v_n integer := 0;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_toplam integer := 0;
BEGIN
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  SELECT tur INTO v_tur FROM siparis WHERE id = v_kayitid;
  IF v_tur IS NULL THEN
    RAISE EXCEPTION 'Siparis bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  SELECT neden INTO v_neden
  FROM public.fn_prog_siparis_silinebilir_mi(v_kayitid, 0)
  WHERE COALESCE(silinebilir, 1) = 0
  LIMIT 1;

  IF v_neden IS NOT NULL THEN
    RAISE EXCEPTION 'Siparis silinemez: %', v_neden USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SIPARIS', p_kayitid := v_kayitid,
                                 p_tabno := 91, p_usttabno := 91, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'SIPARISDETAY', p_kosul := 'SIPARISID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 92, p_usttabno := 91, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  DELETE FROM rehberbilgi WHERE yeri IN (130,131) AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM imaj
  WHERE yeri = 1
    AND yer_id IN (
      SELECT id FROM dokuman
      WHERE modul = 210
        AND modulid IN (SELECT id FROM gorevyorum WHERE tur = 91 AND gorevid = v_kayitid)
    );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman
  WHERE modul = 210
    AND modulid IN (SELECT id FROM gorevyorum WHERE tur = 91 AND gorevid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevyorum WHERE tur = 91 AND gorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM siparisdetay WHERE siparisid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.siparis_user') IS NOT NULL THEN
    DELETE FROM siparis_user WHERE id = v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM siparis WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'KayitId', v_kayitid,
    'Modul', 91,
    'Silinen', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
