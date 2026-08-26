-- Rehber/Cari/IK temel kaydet API'leri
-- Mevcut PG REHBER kolonlari uzerinden temel kart insert/update yapar.
-- Iletisim/adres/vergi alanlari icin REHBER sadeleştirme migration'i ayridir.

CREATE OR REPLACE FUNCTION public.fn_api_rehber_kaydet_ic(kosullar text DEFAULT '{}', p_tabno integer DEFAULT 71)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  k jsonb := COALESCE(j->'Kart', '{}'::jsonb);
  v_id integer := NULLIF(k->>'ID','')::integer;
  v_yeni integer := CASE WHEN COALESCE(NULLIF(k->>'ID','')::integer, 0) = 0 THEN 1 ELSE 0 END;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}','')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}','')::integer, 1);
  v_kod text := NULLIF(k->>'Kod','');
  v_firma text := NULLIF(k->>'Firma','');
  v_grup integer := NULLIF(k->>'Grup','')::integer;
  v_log integer := 0;
BEGIN
  IF v_yeni = 0 AND NOT EXISTS (SELECT 1 FROM rehber WHERE id = v_id) THEN
    RAISE EXCEPTION 'Kart bulunamadi.' USING ERRCODE='P0001';
  END IF;

  IF v_yeni = 1 AND COALESCE(v_firma, '') = '' THEN
    RAISE EXCEPTION 'Yeni kartta Kart.Firma zorunlu.' USING ERRCODE='P0001';
  END IF;

  IF v_kod IS NOT NULL AND EXISTS (SELECT 1 FROM rehber WHERE kod = left(v_kod,20) AND id <> COALESCE(v_id,0)) THEN
    RAISE EXCEPTION 'Bu cari kodu zaten kullaniliyor.' USING ERRCODE='P0001';
  END IF;

  IF v_yeni = 1 THEN
    INSERT INTO rehber(
      kod, firma, statu, grup, kategori, sinif, durum, temsilci, notlar,
      ozelkod, yetkikodu, ozel, bolge, muhkodu, bagid, sektor, altbolge,
      peryot, altsektor, posta, eposta, temas, efatura, konum,
      giriskaynak, ekleyen, eklemetarihi, subeid
    )
    VALUES (
      left(COALESCE(v_kod,''),20),
      left(v_firma,120),
      NULLIF(k->>'Statu','')::integer,
      COALESCE(v_grup, CASE WHEN p_tabno = 73 THEN 73 ELSE 0 END),
      NULLIF(k->>'Kategori','')::integer,
      NULLIF(k->>'Sinif','')::integer,
      COALESCE(NULLIF(k->>'Durum','')::integer, 1),
      NULLIF(k->>'Temsilci','')::integer,
      left(COALESCE(k->>'Notlar',''),1000),
      left(COALESCE(k->>'OzelKod',''),20),
      left(COALESCE(k->>'YetkiKodu',''),10),
      left(COALESCE(k->>'Ozel',''),10),
      NULLIF(k->>'Bolge','')::integer,
      left(COALESCE(k->>'MuhKodu',''),20),
      NULLIF(k->>'BagId','')::integer,
      NULLIF(k->>'Sektor','')::integer,
      NULLIF(k->>'AltBolge','')::integer,
      NULLIF(k->>'Peryot','')::integer,
      NULLIF(k->>'AltSektor','')::integer,
      NULLIF(k->>'Posta','')::integer,
      NULLIF(k->>'Eposta','')::integer,
      NULLIF(k->>'Temas','')::integer,
      NULLIF(k->>'EFatura','')::integer,
      left(COALESCE(k->>'Konum',''),50),
      COALESCE(NULLIF(k->>'GirisKaynak','')::integer, 0),
      v_kulid,
      now(),
      v_subeid
    )
    RETURNING id INTO v_id;
  ELSE
    UPDATE rehber
       SET kod = COALESCE(left(v_kod,20), kod),
           firma = COALESCE(left(v_firma,120), firma),
           statu = COALESCE(NULLIF(k->>'Statu','')::integer, statu),
           grup = COALESCE(v_grup, grup),
           kategori = COALESCE(NULLIF(k->>'Kategori','')::integer, kategori),
           sinif = COALESCE(NULLIF(k->>'Sinif','')::integer, sinif),
           durum = COALESCE(NULLIF(k->>'Durum','')::integer, durum),
           temsilci = COALESCE(NULLIF(k->>'Temsilci','')::integer, temsilci),
           notlar = COALESCE(left(NULLIF(k->>'Notlar',''),1000), notlar),
           ozelkod = COALESCE(left(NULLIF(k->>'OzelKod',''),20), ozelkod),
           yetkikodu = COALESCE(left(NULLIF(k->>'YetkiKodu',''),10), yetkikodu),
           ozel = COALESCE(left(NULLIF(k->>'Ozel',''),10), ozel),
           bolge = COALESCE(NULLIF(k->>'Bolge','')::integer, bolge),
           muhkodu = COALESCE(left(NULLIF(k->>'MuhKodu',''),20), muhkodu),
           bagid = COALESCE(NULLIF(k->>'BagId','')::integer, bagid),
           sektor = COALESCE(NULLIF(k->>'Sektor','')::integer, sektor),
           altbolge = COALESCE(NULLIF(k->>'AltBolge','')::integer, altbolge),
           peryot = COALESCE(NULLIF(k->>'Peryot','')::integer, peryot),
           altsektor = COALESCE(NULLIF(k->>'AltSektor','')::integer, altsektor),
           posta = COALESCE(NULLIF(k->>'Posta','')::integer, posta),
           eposta = COALESCE(NULLIF(k->>'Eposta','')::integer, eposta),
           temas = COALESCE(NULLIF(k->>'Temas','')::integer, temas),
           efatura = COALESCE(NULLIF(k->>'EFatura','')::integer, efatura),
           konum = COALESCE(left(NULLIF(k->>'Konum',''),50), konum),
           degistiren = v_kulid,
           degistirmetarihi = now()
     WHERE id = v_id;
  END IF;

  v_log := public.fn_api_log_yaz_ic('REHBER', 'ID=@pB', v_id, NULL,
            p_tabno, p_tabno, v_id, v_kulid, v_subeid, NULL, NULL,
            v_id, 0, CASE WHEN v_yeni = 1 THEN 1 ELSE 2 END::smallint);

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'KayitId', v_id,
    'Yeni', v_yeni,
    'TabNo', p_tabno,
    'Loglanan', COALESCE(v_log,0)
  )::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_cari_kaydet_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql
AS $$
  SELECT public.fn_api_rehber_kaydet_ic($1, 71);
$$;

CREATE OR REPLACE FUNCTION public.fn_api_ik_kaydet_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql
AS $$
  SELECT public.fn_api_rehber_kaydet_ic($1, 73);
$$;

