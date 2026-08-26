-- ============================================================================
-- fn_api_stok_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- sp_Api_Modul_Sil_Ic(88) / fn_Prog_Silme_Plan(88) PG portu.
-- STOKLAR_USER bazı kurulumlarda yok; opsiyonel ele alınır.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_stok_sil_json(kosullar text DEFAULT '{}')
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
  IF NOT EXISTS (SELECT 1 FROM stoklar WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Stok bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (SELECT 1 FROM stoksayimkalemleri WHERE stokid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu stok sayimda kullanilmis, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM fatura WHERE tur = 1 AND urunid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu stok faturada kullanilmis, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM siparisdetay WHERE tur = 1 AND urunid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu stok sipariste kullanilmis, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM teklifdetay WHERE tur = 1 AND urunid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu stok teklifte kullanilmis, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM stokizleme WHERE stokid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu stokun lot/seri hareketi var, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM uretimrecete WHERE stokid = v_kayitid) THEN
    RAISE EXCEPTION 'Bu stok uretim recetesinde kullanilmis, silinemez.' USING ERRCODE = 'P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM stokdurum WHERE stokid = v_kayitid AND COALESCE(kalan, 0) <> 0) THEN
    RAISE EXCEPTION 'Bu stokun depo bakiyesi var, silinemez.' USING ERRCODE = 'P0001';
  END IF;

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKLAR', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist,
                                 p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ', p_kosul := 'YERI BETWEEN 71 AND 72 AND YER_ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'IMAJ', p_kosul := 'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID=@pB))', p_kosulpar := v_kayitid,
                                 p_tabno := 42, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'DOKUMAN', p_kosul := 'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID=@pB)', p_kosulpar := v_kayitid,
                                 p_tabno := 321, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'GOREVYORUM', p_kosul := 'TUR=88 AND GOREVID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 210, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKFIYAT', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 346, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'ISORTAGI', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKESDEGER', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 344, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKBARKOD', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 340, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKBOYUTKOMBINASYON', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 342, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKSEVIYE', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKMUHASEBE', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKCEVRIM', p_kosul := 'STOKID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'EKIPMANLAR', p_kosul := 'URUNID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'PAKETDETAY', p_kosul := 'PAKETID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'PAKETDETAY', p_kosul := 'URUNID=@pB AND STOK=1', p_kosulpar := v_kayitid,
                                 p_tabno := 88, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic(p_tablo := 'REHBERBILGI', p_kosul := 'YERI=88 AND YER_ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := 76, p_usttabno := 88, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid,
                                 p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.stoklar_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'STOKLAR_USER', p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                   p_tabno := 508, p_usttabno := 88, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid,
                                   p_ip := v_ip, p_istasyon := v_ist, p_stokid := v_kayitid,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  DELETE FROM imaj WHERE yeri BETWEEN 71 AND 72 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM imaj WHERE yeri = 1 AND yer_id IN (
    SELECT id FROM dokuman WHERE modul = 210 AND modulid IN (
      SELECT id FROM gorevyorum WHERE tur = 88 AND gorevid = v_kayitid
    )
  );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM dokuman WHERE modul = 210 AND modulid IN (
    SELECT id FROM gorevyorum WHERE tur = 88 AND gorevid = v_kayitid
  );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM gorevyorum WHERE tur = 88 AND gorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM stokfiyat WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM isortagi WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM stokesdeger WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM stokbarkod WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM stokboyutkombinasyon WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM stokseviye WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM stokmuhasebe WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM stokcevrim WHERE stokid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM ekipmanlar WHERE urunid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM paketdetay WHERE paketid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM paketdetay WHERE urunid = v_kayitid AND stok = 1;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehberbilgi WHERE yeri = 88 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.stoklar_user') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.stoklar_user WHERE id = $1' USING v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM stoklar WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', 88,
    'KayitId', v_kayitid,
    'SilinenSatir', v_toplam,
    'Loglanan', v_loglanan
  )::text;
END;
$$;
