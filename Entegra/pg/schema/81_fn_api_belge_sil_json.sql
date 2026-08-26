-- ============================================================================
-- fn_api_belge_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- Bagimli dosyalar:
--   67_fn_prog_fatura_silinebilir_mi.sql
--   77_izleme_sequence_trigger.sql
--   79_log_audit_api.sql
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_belge_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_belgeid integer := NULLIF(j->>'BelgeId', '')::integer;
  v_kilit integer := COALESCE(NULLIF(j->>'KilitKaldirildi', '')::integer, 0);
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_tur integer;
  v_neden varchar;
  v_tabkart integer;
  v_tabdetay integer;
  v_sablonyeri integer;
  v_loglanan integer := 0;
  v_n integer := 0;
  v_silinensatir integer := 0;
BEGIN
  IF v_belgeid IS NULL OR v_belgeid <= 0 THEN
    RAISE EXCEPTION 'BelgeId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  SELECT tur INTO v_tur
  FROM fatbaslik
  WHERE id = v_belgeid;

  IF v_tur IS NULL THEN
    RAISE EXCEPTION 'Belge bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  SELECT neden INTO v_neden
  FROM public.fn_prog_fatura_silinebilir_mi(v_belgeid, 0, v_kilit)
  WHERE COALESCE(silinebilir, 1) = 0
  LIMIT 1;

  IF v_neden IS NOT NULL THEN
    RAISE EXCEPTION 'Belge silinemez: %', v_neden USING ERRCODE = 'P0001';
  END IF;

  v_tabkart := public.fn_api_belge_tabno(v_tur, 0);
  v_tabdetay := public.fn_api_belge_tabno(v_tur, 1);
  v_sablonyeri := CASE
    WHEN v_tur = 9 THEN 131
    WHEN v_tur IN (3,10,11,12) THEN 130
    WHEN v_tur IN (4,14,15,16) THEN 132
    WHEN v_tur = 19 THEN 133
    ELSE 0
  END;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK', p_kayitid := v_belgeid,
                                 p_tabno := v_tabkart, p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                 p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATURA', p_kosul := 'FATBASID = @pB', p_kosulpar := v_belgeid,
                                 p_tabno := v_tabdetay, p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                 p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.fatura_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATURA_USER',
                                   p_kosul := 'ID IN (SELECT ID FROM FATURA WHERE FATBASID = @pB)',
                                   p_kosulpar := v_belgeid,
                                   p_tabno := 503, p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                   p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKIZLEME', p_kosul := 'BASLIKID = @pB', p_kosulpar := v_belgeid,
                                 p_tabno := 367, p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                 p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKIZLEMEDEPO',
                                 p_kosul := 'IZLEMID IN (SELECT ID FROM STOKIZLEME WHERE BASLIKID = @pB)',
                                 p_kosulpar := v_belgeid,
                                 p_tabno := 375, p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                 p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.fatbaslik_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK_USER', p_kayitid := v_belgeid,
                                   p_tabno := 502, p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                   p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  -- Uretim fisi: baska yerde kullanilmayan seri/lot ana kayitlari
  IF v_tur = 6 THEN
    DELETE FROM stokserilot sl
    USING fatura f, stokizleme si
    WHERE si.baslikid = f.fatbasid
      AND si.satirid = f.id
      AND si.belgetur = 6
      AND sl.stokid = si.stokid
      AND sl.id = si.serilotid
      AND f.fatbasid = v_belgeid
      AND NOT EXISTS (
        SELECT 1
        FROM stokizleme si1
        WHERE si1.stokid = si.stokid AND si1.serilotid = sl.id AND si1.id <> si.id
      );
  END IF;

  DELETE FROM stokizleme WHERE baslikid = v_belgeid;
  DELETE FROM stokizlemedepo d
  WHERE NOT EXISTS (SELECT 1 FROM stokizleme si WHERE si.id = d.izlemid);

  IF to_regclass('public.stoklokasyon') IS NOT NULL THEN
    DELETE FROM stoklokasyon WHERE baslikid = v_belgeid;
  END IF;

  IF v_tur = 8 THEN
    UPDATE fatura t
       SET iadeadet = COALESCE(t.iadeadet, 0) - x.adet
      FROM (
        SELECT f.iadefaturaid AS id, SUM(COALESCE(f.adet, 0)) AS adet
        FROM fatura f
        WHERE f.fatbasid = v_belgeid AND COALESCE(f.iadefaturaid, 0) > 0
        GROUP BY f.iadefaturaid
      ) x
     WHERE x.id = t.id;
  END IF;

  DELETE FROM fatura WHERE fatbasid = v_belgeid;
  GET DIAGNOSTICS v_silinensatir = ROW_COUNT;

  IF v_sablonyeri > 0 AND to_regclass('public.rehberbilgi') IS NOT NULL THEN
    DELETE FROM rehberbilgi WHERE yeri = v_sablonyeri AND yer_id = v_belgeid;
  END IF;

  IF to_regclass('public.imaj') IS NOT NULL THEN
    DELETE FROM imaj WHERE yeri = 31 AND yer_id = v_belgeid;
  END IF;

  IF to_regclass('public.kasa') IS NOT NULL THEN
    DELETE FROM kasa WHERE tur IN (61, 71) AND faturaid = v_belgeid;
  END IF;

  DELETE FROM fatbaslik WHERE id = v_belgeid;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'Tur', v_tur,
    'SilinenSatir', v_silinensatir,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
