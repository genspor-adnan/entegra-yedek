-- ============================================================================
-- fn_api_cari_sil_json / fn_api_ik_sil_json
-- Kaynak: GenUpdate/_Konsolide_66_169/04_Silme_API.sql
--
-- sp_Api_Modul_Sil_Ic(71/73) PG portu.
-- Not: GENINI tablosunda ID kolonu yok; mevcut log altyapısı satır ID'sine
-- dayandığı için GENINI satırları loglanmadan temizlenir.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_rehber_sil_ic(kosullar text DEFAULT '{}', p_modul integer DEFAULT 71)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kayitid integer := NULLIF(j->>'KayitId', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_tur integer := CASE WHEN p_modul = 73 THEN 73 ELSE 71 END;
  v_n integer := 0;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_toplam integer := 0;
BEGIN
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM rehber WHERE id = v_kayitid) THEN
    RAISE EXCEPTION 'Rehber kaydi bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (SELECT 1 FROM kullanici k JOIN roller r ON r.id = k.rolid WHERE k.rehberid = v_kayitid AND COALESCE(r.ty,0)=1) THEN
    RAISE EXCEPTION 'Yonetici kullanici silinemez.' USING ERRCODE = 'P0001';
  END IF;

  IF p_modul = 71 THEN
    IF EXISTS (SELECT 1 FROM kasa WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait kasa/plan verisi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM fatbaslik WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait fatura verisi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM cekler WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait cek verisi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM senetler WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait senet verisi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM pers_hareket WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu karta ait personel bilgisi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM bankahesaplar WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait banka hesabi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM projeler WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait proje var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM aktiviteler WHERE musteriid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait aktivite var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM teklif WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait teklif var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM siparis WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait siparis var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM servis WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait servis kaydi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM sozlesmeler WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait sozlesme var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM satinalma WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait satinalma kaydi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM uretimemri WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait uretim emri var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM isemri WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu cariye ait is emri var, silinemez.' USING ERRCODE='P0001'; END IF;
  ELSE
    IF EXISTS (SELECT 1 FROM kasa WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu personele ait kasa hareketi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM fatbaslik WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu personele ait belge var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM pers_hareket WHERE rehberid = v_kayitid AND COALESCE(tur,0)<>1) THEN RAISE EXCEPTION 'Bu personele ait hareket kaydi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM bankahesaplar WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu personele ait banka hesabi var, silinemez.' USING ERRCODE='P0001'; END IF;
    IF EXISTS (SELECT 1 FROM servis WHERE rehberid = v_kayitid) THEN RAISE EXCEPTION 'Bu personele ait servis kaydi var, silinemez.' USING ERRCODE='P0001'; END IF;
  END IF;

  v_n := public.fn_api_log_yaz_ic('REHBER', 'ID=@pB', v_kayitid, NULL, v_tur, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic('REHBERBILGI', 'YERI=1 AND YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID=@pB)', v_kayitid, NULL, 76, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBERILETISIM', 'REHBERID=@pB', v_kayitid, NULL, 75, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBERBILGIRESIM', 'REHBERBILGIID IN (SELECT ID FROM REHBERBILGI WHERE YERI IN (1,2,3) AND YER_ID=@pB)', v_kayitid, NULL, 516, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF p_modul = 71 THEN
    v_n := public.fn_api_log_yaz_ic('REHBERBILGI', 'YERI IN (2,3) AND YER_ID=@pB', v_kayitid, NULL, 76, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  ELSE
    v_n := public.fn_api_log_yaz_ic('REHBERBILGI', 'YERI=3 AND YER_ID=@pB', v_kayitid, NULL, 86, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
    v_n := public.fn_api_log_yaz_ic('REHBERBILGI', 'YERI=2 AND YER_ID=@pB', v_kayitid, NULL, 76, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  END IF;
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic('IMAJ',
    CASE WHEN p_modul = 71
      THEN 'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID=@pB))'
      ELSE 'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID=@pB))' END,
    v_kayitid, NULL, 42, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic('DOKUMAN',
    CASE WHEN p_modul = 71
      THEN 'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID=@pB)'
      ELSE 'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID=@pB)' END,
    v_kayitid, NULL, 321, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic('GOREVYORUM',
    CASE WHEN p_modul = 71 THEN 'TUR=71 AND GOREVID=@pB' ELSE 'TUR=73 AND GOREVID=@pB' END,
    v_kayitid, NULL, 210, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  v_n := public.fn_api_log_yaz_ic('IMAJ', 'YERI=71 AND YER_ID=@pB', v_kayitid, NULL, 42, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF p_modul = 73 THEN
    v_n := public.fn_api_log_yaz_ic('PERS_HAREKET', 'REHBERID=@pB', v_kayitid, NULL, 78, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  v_n := public.fn_api_log_yaz_ic('KULLANICI', 'REHBERID=@pB', v_kayitid, NULL, 52, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBERALIAS', 'REHBERID=@pB', v_kayitid, NULL, 513, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBERTEMSILCI', 'REHBERID=@pB', v_kayitid, NULL, 514, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBERPERSONEL', 'REHBERID=@pB', v_kayitid, NULL, 515, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBERBILGI', 'YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID=@pB))', v_kayitid, NULL, 76, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBERILETISIM', 'REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID=@pB)', v_kayitid, NULL, 75, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);
  v_n := public.fn_api_log_yaz_ic('REHBER', 'GRUP=334 AND BAGID=@pB', v_kayitid, NULL, 71, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF to_regclass('public.rehber_user') IS NOT NULL THEN
    v_n := public.fn_api_log_yaz_ic('REHBER_USER', 'ID=@pB', v_kayitid, NULL, 504, v_tur, v_kayitid, v_kulid, v_subeid, v_ip, v_ist, v_kayitid, 0, 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
  END IF;

  DELETE FROM rehberbilgiresim WHERE rehberbilgiid IN (SELECT id FROM rehberbilgi WHERE yeri IN (1,2,3) AND yer_id = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehberbilgi WHERE yeri = 1 AND yer_id IN (SELECT id FROM rehberiletisim WHERE rehberid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehberiletisim WHERE rehberid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF p_modul = 71 THEN
    DELETE FROM rehberbilgi WHERE yeri IN (2,3) AND yer_id = v_kayitid;
  ELSE
    DELETE FROM rehberbilgi WHERE yeri IN (2,3) AND yer_id = v_kayitid;
  END IF;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM imaj WHERE yeri = 1 AND yer_id IN (
    SELECT id FROM dokuman WHERE modul = 210 AND modulid IN (
      SELECT id FROM gorevyorum WHERE tur = v_tur AND gorevid = v_kayitid
    )
  );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM gorevyorum WHERE tur = v_tur AND gorevid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM gorevyorum WHERE tur = v_tur AND gorevid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM imaj WHERE yeri = 71 AND yer_id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF p_modul = 73 THEN
    DELETE FROM pers_hareket WHERE rehberid = v_kayitid AND tur = 1;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM kullanici WHERE rehberid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehberalias WHERE rehberid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehbertemsilci WHERE rehberid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehberpersonel WHERE rehberid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehberbilgi WHERE yer_id IN (SELECT id FROM rehberiletisim WHERE rehberid IN (SELECT id FROM rehber WHERE grup = 334 AND bagid = v_kayitid));
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehberiletisim WHERE rehberid IN (SELECT id FROM rehber WHERE grup = 334 AND bagid = v_kayitid);
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  DELETE FROM rehber WHERE grup = 334 AND bagid = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  IF to_regclass('public.rehber_user') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.rehber_user WHERE id = $1' USING v_kayitid;
    GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;
  END IF;

  DELETE FROM genini
   WHERE bolum IN (
     SELECT CAST('-100' || v.n::text || v_kayitid::text AS bigint)
       FROM (VALUES(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69)) AS v(n)
   );
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  DELETE FROM rehber WHERE id = v_kayitid;
  GET DIAGNOSTICS v_silinen = ROW_COUNT; v_toplam := v_toplam + v_silinen;

  RETURN jsonb_build_object('Sonuc', 1, 'Modul', v_tur, 'KayitId', v_kayitid, 'SilinenSatir', v_toplam, 'Loglanan', v_loglanan)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_cari_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  RETURN public.fn_api_rehber_sil_ic(kosullar, 71);
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_ik_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  RETURN public.fn_api_rehber_sil_ic(kosullar, 73);
END;
$$;
