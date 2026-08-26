-- ============================================================================
-- fn_api_uretimemri_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- sp_Api_Modul_Sil_Ic(140) / fn_Prog_Silme_Plan(140) PG portu.
-- _USER tabloları bazı PG kopyalarında yok; varsa opsiyonel silinir/loglanır.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_uretimemri_sil_json(kosullar text DEFAULT '{}')
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
  IF NOT EXISTS (SELECT 1 FROM uretimemri WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Uretim emri bulunamadi.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (
    SELECT 1
      FROM fatbaslik
     WHERE tur = 6
       AND yeri = 142
       AND yerid IN (SELECT id FROM uretimoperasyon WHERE uretimemriid = v_kayitid)
  ) THEN
    RAISE EXCEPTION 'Bu uretim emrinden uretim fisi olusturulmus, silinemez.' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMEMRI', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 140, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ',
                                 p_kosul := 'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB)))',
                                 p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'DOKUMAN',
                                 p_kosul := 'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB))',
                                 p_kosulpar := v_kayitid,
                                 p_tabno := 321, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'GOREVYORUM',
                                 p_kosul := 'TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB)',
                                 p_kosulpar := v_kayitid,
                                 p_tabno := 210, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOLCUMDETAY',
                                 p_kosul := 'URETIMOLCUMID IN (SELECT ID FROM URETIMOLCUM WHERE OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB)))',
                                 p_kosulpar := v_kayitid,
                                 p_tabno := 525, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOLCUM',
                                 p_kosul := 'OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB))',
                                 p_kosulpar := v_kayitid,
                                 p_tabno := 524, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.uretimoperasonpersonel_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOPERASONPERSONEL_USER',
                                   p_kosul := 'ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB))',
                                   p_kosulpar := v_kayitid,
                                   p_tabno := 526, p_usttabno := 140, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  IF to_regclass('public.uretimoperasyonpersonel_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOPERASYONPERSONEL_USER',
                                   p_kosul := 'ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB))',
                                   p_kosulpar := v_kayitid,
                                   p_tabno := 511, p_usttabno := 140, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOPERASYONPERSONEL',
                                 p_kosul := 'OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID=@pB)',
                                 p_kosulpar := v_kayitid,
                                 p_tabno := 146, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOPERASYONMALIYET', p_kosul := 'URETIMEMRIID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 522, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOPERASYONFASON', p_kosul := 'URETIMEMRIID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 523, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMOPERASYON', p_kosul := 'URETIMEMRIID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 142, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMEMRIDETAY', p_kosul := 'URETIMEMRIID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 141, p_usttabno := 140, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.uretimemri_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'URETIMEMRI_USER', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                   p_tabno := 510, p_usttabno := 140, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  DELETE FROM imaj
   WHERE yeri = 1
     AND yer_id IN (
       SELECT id FROM dokuman
        WHERE modul = 210
          AND modulid IN (
            SELECT id FROM gorevyorum
             WHERE tur = 142
               AND gorevid IN (SELECT id FROM uretimoperasyon WHERE uretimemriid = v_kayitid)
          )
     );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman
   WHERE modul = 210
     AND modulid IN (
       SELECT id FROM gorevyorum
        WHERE tur = 142
          AND gorevid IN (SELECT id FROM uretimoperasyon WHERE uretimemriid = v_kayitid)
     );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevyorum WHERE tur = 142 AND gorevid IN (SELECT id FROM uretimoperasyon WHERE uretimemriid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimolcumdetay
   WHERE uretimolcumid IN (
     SELECT id FROM uretimolcum
      WHERE operasyonpersonelid IN (
        SELECT id FROM uretimoperasyonpersonel
         WHERE operasyonid IN (SELECT id FROM uretimoperasyon WHERE uretimemriid = v_kayitid)
      )
   );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimolcum
   WHERE operasyonpersonelid IN (
     SELECT id FROM uretimoperasyonpersonel
      WHERE operasyonid IN (SELECT id FROM uretimoperasyon WHERE uretimemriid = v_kayitid)
   );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.uretimoperasonpersonel_user') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.uretimoperasonpersonel_user WHERE id IN (SELECT id FROM public.uretimoperasyonpersonel WHERE operasyonid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1))' USING v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  IF to_regclass('public.uretimoperasyonpersonel_user') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.uretimoperasyonpersonel_user WHERE id IN (SELECT id FROM public.uretimoperasyonpersonel WHERE operasyonid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1))' USING v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM uretimoperasyonpersonel WHERE operasyonid IN (SELECT id FROM uretimoperasyon WHERE uretimemriid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimoperasyonmaliyet WHERE uretimemriid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimoperasyonfason WHERE uretimemriid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimoperasyon WHERE uretimemriid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM uretimemridetay WHERE uretimemriid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.uretimemri_user') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.uretimemri_user WHERE id = $1' USING v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM uretimemri WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 140,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
