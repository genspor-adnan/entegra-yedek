-- ============================================================================
-- fn_api_kasahareket_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- KASA hareketi silme PG portu. Belge/plan/cek-senet yan etkileri MSSQL
-- prosedüründeki sıraya göre uygulanır; testler transaction/rollback ile yapılır.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_kasahareket_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_id bigint := NULLIF(j->>'KayitId', '')::bigint;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_tur integer;
  v_hesapid integer;
  v_rehberid integer;
  v_faturaid integer;
  v_ceksenetid integer;
  v_krediid integer;
  v_geridonusid integer;
  v_yeri integer;
  v_yerid integer;
  v_aciklama text;
  v_n integer := 0;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_toplam integer := 0;
  v_kasaid bigint;
  v_sonrakiid bigint;
  v_yeridz integer;
  v_adim integer := 0;
  v_islem integer;
  v_sonislem integer;
BEGIN
  IF v_id IS NULL OR v_id <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  SELECT COALESCE(tur, 0), COALESCE(hesapid, 0), COALESCE(rehberid, 0),
         COALESCE(faturaid, 0), COALESCE(ceksenetid, 0), COALESCE(krediid, 0),
         COALESCE(geridonusid, -1), COALESCE(yeri, 0), COALESCE(yerid, 0),
         COALESCE(aciklama, '')
    INTO v_tur, v_hesapid, v_rehberid, v_faturaid, v_ceksenetid, v_krediid,
         v_geridonusid, v_yeri, v_yerid, v_aciklama
    FROM kasa
   WHERE id = v_id;

  IF v_tur IS NULL THEN
    RAISE EXCEPTION 'Kasa hareketi bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  IF v_tur IN (22, 32) THEN
    IF v_geridonusid = -9 AND v_yeri = 30 AND v_yerid > 0 THEN
      v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK', p_kosul := 'ID=@pB', p_kosulpar := v_yerid,
                                     p_tabno := 30, p_usttabno := 43, p_ustid := v_id,
                                     p_kulid := v_kulid, p_subeid := v_subeid,
                                     p_ip := v_ip, p_istasyon := v_ist,
                                     p_islemtipi := 0::smallint);
      v_loglanan := v_loglanan + COALESCE(v_n, 0);

      v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK_USER', p_kosul := 'ID=@pB', p_kosulpar := v_yerid,
                                     p_tabno := 502, p_usttabno := 43, p_ustid := v_id,
                                     p_kulid := v_kulid, p_subeid := v_subeid,
                                     p_ip := v_ip, p_istasyon := v_ist,
                                     p_islemtipi := 0::smallint);
      v_loglanan := v_loglanan + COALESCE(v_n, 0);

      DELETE FROM fatbaslik WHERE id = v_yerid;
      GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

    ELSIF v_tur = 32 THEN
      v_n := public.fn_api_log_yaz_ic(p_tablo := 'KASA', p_kosul := 'YERID=@pB', p_kosulpar := v_id,
                                     p_tabno := 43, p_usttabno := 43, p_ustid := v_id,
                                     p_kulid := v_kulid, p_subeid := v_subeid,
                                     p_ip := v_ip, p_istasyon := v_ist,
                                     p_islemtipi := 0::smallint);
      v_loglanan := v_loglanan + COALESCE(v_n, 0);
      DELETE FROM kasa WHERE yerid = v_id;
      GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

      v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK', p_kosul := 'KASA=@pB', p_kosulpar := v_id,
                                     p_tabno := 30, p_usttabno := 30, p_ustid := v_id,
                                     p_kulid := v_kulid, p_subeid := v_subeid,
                                     p_ip := v_ip, p_istasyon := v_ist,
                                     p_islemtipi := 0::smallint);
      v_loglanan := v_loglanan + COALESCE(v_n, 0);
      v_n := public.fn_api_log_yaz_ic(p_tablo := 'FATBASLIK_USER', p_kosul := 'ID IN (SELECT ID FROM FATBASLIK WHERE KASA=@pB)', p_kosulpar := v_id,
                                     p_tabno := 502, p_usttabno := 30, p_ustid := v_id,
                                     p_kulid := v_kulid, p_subeid := v_subeid,
                                     p_ip := v_ip, p_istasyon := v_ist,
                                     p_islemtipi := 0::smallint);
      v_loglanan := v_loglanan + COALESCE(v_n, 0);
      DELETE FROM fatbaslik WHERE kasa = v_id;
      GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
    END IF;

  ELSIF v_tur = 31 AND position('AVANS' in upper(v_aciklama)) > 0 THEN
    DELETE FROM planavans WHERE kasaid = v_id;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  ELSIF v_tur IN (35, 350) THEN
    DELETE FROM plankredikarti WHERE kasaid = v_id;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  ELSIF ((v_tur BETWEEN 40 AND 50) OR v_tur IN (57, 65, 75, 87)) AND v_geridonusid > -1 THEN
    IF v_tur IN (40, 42) THEN
      DELETE FROM planmaas pm
       WHERE pm.yerid = v_rehberid
         AND pm.durum IN (v_id, v_geridonusid)
         AND EXISTS (
           SELECT 1 FROM kasa k
           JOIN kasalar ks ON ks.id = k.hesapid
            WHERE k.id = pm.durum AND ks.kasatur = 196
         );
      GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
    END IF;

    v_n := public.fn_api_log_yaz_ic(p_tablo := 'KASA', p_kosul := 'ID=@pB', p_kosulpar := v_geridonusid,
                                   p_tabno := 43, p_usttabno := 43, p_ustid := v_geridonusid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
    DELETE FROM kasa WHERE id = v_geridonusid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  ELSIF v_tur IN (51, 52, 53, 54) THEN
    v_islem := CASE WHEN v_tur IN (51, 52) THEN 136 ELSE 143 END;
    DELETE FROM cekhareket WHERE ceksenetlerid = v_ceksenetid AND islem = v_islem;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

    SELECT islem INTO v_sonislem
      FROM cekhareket
     WHERE ceksenetlerid = v_ceksenetid
     ORDER BY tarih DESC
     LIMIT 1;

    IF v_sonislem IS NOT NULL THEN
      UPDATE cekler SET durum = 1, tur = v_sonislem WHERE id = v_ceksenetid;
    ELSE
      UPDATE cekler SET durum = 1 WHERE id = v_ceksenetid;
    END IF;

  ELSIF v_tur IN (58, 59) THEN
    v_kasaid := v_id;
    WHILE v_kasaid > 0 AND v_adim < 100 LOOP
      SELECT COALESCE(yerid, 0), COALESCE(geridonusid, 0)
        INTO v_yeridz, v_sonrakiid
        FROM kasa
       WHERE id = v_kasaid;

      IF NOT FOUND THEN
        EXIT;
      END IF;

      IF v_yeridz > 0 THEN
        UPDATE plankredi SET odenmis = 0 WHERE id = v_yeridz;
      END IF;

      v_n := public.fn_api_log_yaz_ic(p_tablo := 'KASA', p_kosul := 'ID=@pB', p_kosulpar := v_kasaid,
                                     p_tabno := 43, p_usttabno := 43, p_ustid := v_id,
                                     p_kulid := v_kulid, p_subeid := v_subeid,
                                     p_ip := v_ip, p_istasyon := v_ist,
                                     p_islemtipi := 0::smallint);
      v_loglanan := v_loglanan + COALESCE(v_n, 0);
      DELETE FROM kasa WHERE id = v_kasaid;
      GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

      v_kasaid := v_sonrakiid;
      v_adim := v_adim + 1;
    END LOOP;
  END IF;

  IF v_tur NOT IN (58, 59)
     AND (
       v_tur IN (0,1,2,13,17,21,22,25,26,28,29,31,32,35,36,38,39,51,52,53,54,
                 57,58,59,61,65,91,95,71,75,81,87,88,98,125,350)
       OR (v_tur BETWEEN 40 AND 50)
       OR v_tur > 2600
     ) THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'KASA', p_kosul := 'ID=@pB', p_kosulpar := v_id,
                                   p_tabno := 43, p_usttabno := 43, p_ustid := v_id,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    DELETE FROM kasa WHERE id = v_id;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'KayitId', v_id,
    'Tur', v_tur,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan,
    'FaturaId', v_faturaid
  )::text;
END;
$$;
