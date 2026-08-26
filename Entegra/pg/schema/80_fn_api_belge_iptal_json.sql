-- ============================================================================
-- fn_api_belge_iptal_json
-- Kaynak: GenUpdate/_Konsolide_66_169/01_Belge_API.sql
--
-- Bagimli dosyalar:
--   75_api_fiyat_ve_belge_toplam.sql  -> fn_api_belge_durum_yaz_ic
--   77_izleme_sequence_trigger.sql    -> STOKIZLEME bakiye triggerlari
--   79_log_audit_api.sql              -> fn_api_log_yaz_ic, fn_api_belge_tabno
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_belge_iptal_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_belgeid integer := NULLIF(j->>'BelgeId', '')::integer;
  v_tur integer := NULLIF(j->>'Tur', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_siparis boolean := false;
  v_durum integer;
  v_loglanan integer := 0;
  v_n integer := 0;
  v_detay integer := 0;
  v_izleme integer := 0;
  v_tabkart integer;
  v_tabdet integer;
  k record;
  r record;
  v_kaynakdurum jsonb := '[]'::jsonb;
BEGIN
  IF v_belgeid IS NULL OR v_belgeid <= 0 THEN
    RAISE EXCEPTION 'BelgeId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  IF v_tur IS NULL THEN
    SELECT s.tur, COALESCE(s.durum, 0), true
      INTO v_tur, v_durum, v_siparis
    FROM siparis s
    WHERE s.id = v_belgeid;

    IF v_tur IS NULL THEN
      SELECT fb.tur, COALESCE(fb.durum, 0), false
        INTO v_tur, v_durum, v_siparis
      FROM fatbaslik fb
      WHERE fb.id = v_belgeid;
    END IF;
  ELSE
    IF v_tur IN (9, 19, 101, 105) THEN
      v_siparis := true;
      SELECT COALESCE(s.durum, 0) INTO v_durum FROM siparis s WHERE s.id = v_belgeid;
    ELSE
      SELECT COALESCE(fb.durum, 0) INTO v_durum FROM fatbaslik fb WHERE fb.id = v_belgeid;
    END IF;
  END IF;

  IF v_tur IS NULL OR v_durum IS NULL THEN
    RAISE EXCEPTION 'Belge bulunamadi.' USING ERRCODE = 'P0001';
  END IF;
  IF v_durum = 6 THEN
    RAISE EXCEPTION 'Belge zaten iptal edilmis.' USING ERRCODE = 'P0001';
  END IF;

  CREATE TEMP TABLE IF NOT EXISTS pg_temp.tmp_belge_iptal_kaynak(
    belgeid integer NOT NULL,
    siparis boolean NOT NULL,
    PRIMARY KEY (belgeid, siparis)
  ) ON COMMIT DROP;
  TRUNCATE TABLE pg_temp.tmp_belge_iptal_kaynak;

  IF NOT v_siparis THEN
    INSERT INTO pg_temp.tmp_belge_iptal_kaynak(belgeid, siparis)
    SELECT DISTINCT s.id, true
    FROM fatura f
    INNER JOIN public.fn_prog_belgedonusum_rota() rota
      ON rota.donusumturu = f.yeri AND rota.kaynakdetaytablo = 'SIPARISDETAY'
    INNER JOIN siparisdetay sd ON sd.id = f.yerid
    INNER JOIN siparis s ON s.id = sd.siparisid
    WHERE f.fatbasid = v_belgeid
    ON CONFLICT DO NOTHING;

    INSERT INTO pg_temp.tmp_belge_iptal_kaynak(belgeid, siparis)
    SELECT DISTINCT fb.id, false
    FROM fatura f
    INNER JOIN public.fn_prog_belgedonusum_rota() rota
      ON rota.donusumturu = f.yeri AND rota.kaynakdetaytablo = 'FATURA'
    INNER JOIN fatura f2 ON f2.id = f.yerid
    INNER JOIN fatbaslik fb ON fb.id = f2.fatbasid
    WHERE f.fatbasid = v_belgeid
    ON CONFLICT DO NOTHING;
  END IF;

  IF v_siparis THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'SIPARIS', p_kosul := 'ID=@pB',
                                   p_kosulpar := v_belgeid, p_tabno := 91,
                                   p_usttabno := 91, p_ustid := v_belgeid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_rehberid := 0, p_stokid := 0, p_islemtipi := 2::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    v_n := public.fn_api_log_yaz_ic(p_tablo := 'SIPARISDETAY', p_kosul := 'SIPARISID=@pB',
                                   p_kosulpar := v_belgeid, p_tabno := 92,
                                   p_usttabno := 91, p_ustid := v_belgeid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_rehberid := 0, p_stokid := 0, p_islemtipi := 2::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    UPDATE siparis
       SET durum = 6,
           siparis_matrahi = 0,
           kdv_tutari = 0,
           ekvergi = 0,
           siparis_tutari = 0,
           doviz_tutari = 0
     WHERE id = v_belgeid;

    UPDATE siparisdetay
       SET birimfiyat = 0,
           tutar = 0,
           doviz_tutari = 0,
           doviz_birimfiyat = 0,
           adet = 0,
           miktar = 0
     WHERE siparisid = v_belgeid;
    GET DIAGNOSTICS v_detay = ROW_COUNT;
  ELSE
    v_tabkart := public.fn_api_belge_tabno(v_tur, 0);
    v_tabdet := public.fn_api_belge_tabno(v_tur, 1);

    v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK', p_kosul := 'ID=@pB',
                                   p_kosulpar := v_belgeid, p_tabno := v_tabkart,
                                   p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_rehberid := 0, p_stokid := 0, p_islemtipi := 2::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATURA', p_kosul := 'FATBASID=@pB',
                                   p_kosulpar := v_belgeid, p_tabno := v_tabdet,
                                   p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_rehberid := 0, p_stokid := 0, p_islemtipi := 2::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKIZLEME', p_kosul := 'BASLIKID=@pB',
                                   p_kosulpar := v_belgeid, p_tabno := 367,
                                   p_usttabno := v_tabkart, p_ustid := v_belgeid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_rehberid := 0, p_stokid := 0, p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    UPDATE fatbaslik
       SET durum = 6,
           fatura_maliyeti_ort = 0,
           fatura_matrahi = 0,
           kdv_tutari = 0,
           ekvergi = 0,
           fatura_tutari = 0,
           doviz_tutari = 0
     WHERE id = v_belgeid;

    DELETE FROM stokizleme
    WHERE belgetur = v_tur AND baslikid = v_belgeid;
    GET DIAGNOSTICS v_izleme = ROW_COUNT;

    DELETE FROM stokizlemedepo d
    WHERE NOT EXISTS (SELECT 1 FROM stokizleme si WHERE si.id = d.izlemid);

    UPDATE fatura
       SET birimfiyat = 0,
           tutar = 0,
           doviz_tutari = 0,
           doviz_birimfiyat = 0,
           stokdurumdegis = 0,
           adet = 0,
           miktar = 0,
           yeri = 0,
           yerid = 0
     WHERE fatbasid = v_belgeid;
    GET DIAGNOSTICS v_detay = ROW_COUNT;
  END IF;

  FOR k IN SELECT belgeid, siparis FROM pg_temp.tmp_belge_iptal_kaynak LOOP
    BEGIN
      SELECT * INTO r
      FROM public.fn_api_belge_durum_yaz_ic(k.belgeid, CASE WHEN k.siparis THEN 'siparis' ELSE 'belge' END, 1);

      v_kaynakdurum := v_kaynakdurum || jsonb_build_array(jsonb_build_object('BelgeId', k.belgeid, 'Durum', r.durum));
    EXCEPTION WHEN OTHERS THEN
      -- Kaynak silinmis/kapsam disi olabilir; iptali bozma.
      NULL;
    END;
  END LOOP;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'Tur', v_tur,
    'Detay', v_detay,
    'Izleme', v_izleme,
    'Loglanan', v_loglanan,
    'KaynakDurum', v_kaynakdurum
  )::text;
END;
$$;
