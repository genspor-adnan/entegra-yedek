-- ============================================================================
-- fn_api_cari_klonla_json / fn_api_ik_klonla_json
-- Kaynak: GenUpdate/_Konsolide_66_169/05_Kart_Kaydet_POS.sql
--
-- sp_Api_Rehber_Klonla_Ic(71/73) PG portu.
-- Kart, iletişimler ve iletişim bilgi satırları kopyalanır.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_rehber_klonla_ic(kosullar text DEFAULT '{}', p_tabno integer DEFAULT 71)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kaynakid integer := NULLIF(j->>'KaynakId', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, -1);
  v_yenikod varchar(50) := NULLIF(j->>'Kod', '');
  v_yeniad varchar(200) := NULLIF(j->>'Firma', '');
  v_kok varchar(50);
  v_i integer := 1;
  v_yeniid integer;
  v_eski_ilet integer;
  v_yeni_ilet integer;
BEGIN
  IF v_kaynakid IS NULL OR NOT EXISTS (SELECT 1 FROM rehber WHERE id = v_kaynakid) THEN
    RAISE EXCEPTION 'Kaynak kart bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  IF COALESCE(v_yenikod, '') = '' THEN
    SELECT COALESCE(kod, '') INTO v_kok FROM rehber WHERE id = v_kaynakid;
    IF COALESCE(v_kok, '') <> '' THEN
      v_yenikod := LEFT(v_kok, 17) || '_K1';
      WHILE EXISTS (SELECT 1 FROM rehber WHERE kod = v_yenikod) AND v_i < 100 LOOP
        v_i := v_i + 1;
        v_yenikod := LEFT(v_kok, GREATEST(1, 20 - (2 + length(v_i::text)))) || '_K' || v_i::text;
      END LOOP;
    END IF;
  END IF;

  INSERT INTO rehber(
    kod, firma, statu, grup, kategori, sinif, durum, temsilci, notlar, ozelkod,
    yetkikodu, ozel, ekleyen, eklemetarihi, subeid, bolge, muhkodu, bagid,
    sektor, altbolge, peryot, altsektor, posta, eposta, temas, efatura, konum
  )
  SELECT
    v_yenikod,
    COALESCE(v_yeniad, LEFT(COALESCE(r.firma, ''), 180) || ' (KOPYA)'),
    r.statu, r.grup, r.kategori, r.sinif, r.durum, r.temsilci, r.notlar, r.ozelkod,
    r.yetkikodu, r.ozel, v_kulid, now(), v_subeid, r.bolge, r.muhkodu, r.bagid,
    r.sektor, r.altbolge, r.peryot, r.altsektor, r.posta, r.eposta, r.temas, r.efatura, r.konum
  FROM rehber r
  WHERE r.id = v_kaynakid
  RETURNING id INTO v_yeniid;

  FOR v_eski_ilet IN
    SELECT id FROM rehberiletisim WHERE rehberid = v_kaynakid ORDER BY id
  LOOP
    INSERT INTO rehberiletisim(rehberid, ad, varsayilan, aktif, ekleyen, eklemetarihi, subeid)
    SELECT v_yeniid, ad, varsayilan, aktif, v_kulid, now(), v_subeid
      FROM rehberiletisim
     WHERE id = v_eski_ilet
    RETURNING id INTO v_yeni_ilet;

    INSERT INTO rehberbilgi(modul, yeri, yer_id, sira, etiket, bilgi, ekleyen, eklemetarihi, subeid)
    SELECT modul, yeri, v_yeni_ilet, sira, etiket, bilgi, v_kulid, now(), v_subeid
      FROM rehberbilgi
     WHERE yeri = 1 AND yer_id = v_eski_ilet;
  END LOOP;

  PERFORM public.fn_api_log_yaz_ic(
    p_tablo := 'REHBER',
    p_kosul := 'ID=@pB',
    p_kosulpar := v_yeniid,
    p_tabno := p_tabno,
    p_usttabno := p_tabno,
    p_ustid := v_yeniid,
    p_kulid := v_kulid,
    p_subeid := v_subeid,
    p_rehberid := v_yeniid,
    p_islemtipi := 1::smallint
  );

  PERFORM public.fn_api_log_kaynak_isaretle(
    p_tabno := p_tabno,
    p_kayitid := v_yeniid,
    p_alttip := 3::smallint,
    p_kaynakid := v_kaynakid,
    p_kaynaktabno := p_tabno
  );

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'KaynakId', v_kaynakid,
    'KayitId', v_yeniid,
    'Kod', (SELECT kod FROM rehber WHERE id = v_yeniid)
  )::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_cari_klonla_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  RETURN public.fn_api_rehber_klonla_ic(kosullar, 71);
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_ik_klonla_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  RETURN public.fn_api_rehber_klonla_ic(kosullar, 73);
END;
$$;
