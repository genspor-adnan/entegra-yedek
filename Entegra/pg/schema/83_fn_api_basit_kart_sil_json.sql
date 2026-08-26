-- ============================================================================
-- Basit kart silme API'leri
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- Kapsam:
--   58  Masraf/Gelir   -> FIYATLAR(HIZMETID), MASRAFGELIR(ID)
--   69  POS            -> POSORAN(POSID), KASA(HESAPTURU='P'...), POS(ID)
--   46  Kredi Karti    -> KASA(HESAPTURU='V'...), KREDIKARTI(ID)
--   480 Kasa Tanimi    -> KASA(HESAPTURU='K'...), KASALAR(ID)
--
-- Bu, tum fn_Prog_Silme_Plan motorunun PG portu degildir; yalniz sade kosullu
-- planlar icin guvenli gercek porttur. Diger wrapper'lar 74 dosyasindaki
-- korumali stub olarak kalir.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_basit_kart_sil_json(
  p_modul integer,
  kosullar text DEFAULT '{}'
)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kayitid integer := NULLIF(j->>'KayitId', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_karttablo text;
  v_var integer;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_n integer := 0;
BEGIN
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  v_karttablo := CASE p_modul
    WHEN 58 THEN 'MASRAFGELIR'
    WHEN 69 THEN 'POS'
    WHEN 46 THEN 'KREDIKARTI'
    WHEN 480 THEN 'KASALAR'
    ELSE NULL
  END;

  IF v_karttablo IS NULL THEN
    RAISE EXCEPTION 'Bu basit kart silme portu modul % desteklemiyor.', p_modul USING ERRCODE = 'P0001';
  END IF;

  EXECUTE format('select 1 from public.%I where id=$1 limit 1', lower(v_karttablo))
    INTO v_var
    USING v_kayitid;

  IF COALESCE(v_var, 0) = 0 THEN
    RAISE EXCEPTION 'Kayit bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  -- Kart logu once.
  v_n := public.fn_api_log_yaz_ic(p_tablo := v_karttablo, p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := p_modul, p_usttabno := p_modul, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF p_modul = 58 THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'FIYATLAR', p_kosul := 'HIZMETID=@pB', p_kosulpar := v_kayitid,
                                   p_tabno := 58, p_usttabno := 58, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    DELETE FROM fiyatlar WHERE hizmetid = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM masrafgelir WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;

  ELSIF p_modul = 69 THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'POSORAN', p_kosul := 'POSID=@pB', p_kosulpar := v_kayitid,
                                   p_tabno := 69, p_usttabno := 69, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
    -- KASA baglari icin desteklenen kosulu log helper'a sokmadan burada kart loguyla yetiniyoruz.
    DELETE FROM posoran WHERE posid = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM kasa WHERE hesapturu = 'P' AND hesapid = v_kayitid AND tur IN (1,2);
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM pos WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;

  ELSIF p_modul = 46 THEN
    DELETE FROM kasa WHERE hesapturu = 'V' AND hesapid = v_kayitid AND tur IN (1,2);
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM kredikarti WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;

  ELSIF p_modul = 480 THEN
    DELETE FROM kasa WHERE hesapturu = 'K' AND hesapid = v_kayitid AND tur = 1;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM kasalar WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
  END IF;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', p_modul,
    'KayitId', v_kayitid,
    'SilinenSatir', v_silinen,
    'Loglanan', v_loglanan
  )::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_masrafgelir_sil_json(kosullar text DEFAULT '{}')
RETURNS text LANGUAGE sql AS $$ SELECT public.fn_api_basit_kart_sil_json(58, kosullar) $$;

CREATE OR REPLACE FUNCTION public.fn_api_pos_sil_json(kosullar text DEFAULT '{}')
RETURNS text LANGUAGE sql AS $$ SELECT public.fn_api_basit_kart_sil_json(69, kosullar) $$;

CREATE OR REPLACE FUNCTION public.fn_api_kredikarti_sil_json(kosullar text DEFAULT '{}')
RETURNS text LANGUAGE sql AS $$ SELECT public.fn_api_basit_kart_sil_json(46, kosullar) $$;

CREATE OR REPLACE FUNCTION public.fn_api_kasa_sil_json(kosullar text DEFAULT '{}')
RETURNS text LANGUAGE sql AS $$ SELECT public.fn_api_basit_kart_sil_json(480, kosullar) $$;
