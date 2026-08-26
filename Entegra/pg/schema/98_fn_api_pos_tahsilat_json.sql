-- ============================================================================
-- fn_api_pos_tahsilat_json
-- Kaynak: GenUpdate/_Konsolide_66_169/05_Kart_Kaydet_POS.sql
--
-- POS tahsilat PG portu.
-- Not: MSSQL sp_BelgeNoGetir PG'de yok; kasa BELGENO icin yerel PGPOS-* seri
-- uretilir. Perakende=1 ise MSSQL gibi SATISKASA'ya yazar ve Idler'e 0 ekler.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_pos_tahsilat_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_rehid integer := COALESCE(NULLIF(j->>'RehId', '')::integer, 0);
  v_fattur integer := COALESCE(NULLIF(j->>'FatTur', '')::integer, 0);
  v_yerid integer := COALESCE(NULLIF(j->>'YerId', '')::integer, 0);
  v_faturaid integer := COALESCE(NULLIF(j->>'FaturaId', '')::integer, 0);
  v_masrafid integer := COALESCE(NULLIF(j->>'MasrafId', '')::integer, 0);
  v_kur varchar(5) := LEFT(COALESCE(NULLIF(j->>'Kur', ''), 'TL'), 5);
  v_perakende integer := COALESCE(NULLIF(j->>'Perakende', '')::integer, 0);
  v_kasatakip integer := COALESCE(NULLIF(j->>'KasaTakipTabNo', '')::integer, 0);
  v_giriskaynak integer := COALESCE(NULLIF(j->>'GirisKaynak', '')::integer, 0);
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_simdi timestamp := now();
  v_satir jsonb;
  v_tur integer;
  v_hesapid integer;
  v_musterihesapid integer;
  v_tutar numeric;
  v_hesapturu varchar(1);
  v_id bigint;
  v_idler text := '';
  v_adet integer := 0;
  v_belgeno varchar(50);
BEGIN
  IF jsonb_typeof(COALESCE(j->'Satirlar', '[]'::jsonb)) <> 'array' THEN
    RAISE EXCEPTION 'Satirlar dizi olmali.' USING ERRCODE = 'P0001';
  END IF;

  FOR v_satir IN SELECT value FROM jsonb_array_elements(COALESCE(j->'Satirlar', '[]'::jsonb))
  LOOP
    v_tur := COALESCE(NULLIF(v_satir->>'Tur', '')::integer, 0);
    v_hesapid := COALESCE(NULLIF(v_satir->>'HesapId', '')::integer, 0);
    v_musterihesapid := COALESCE(NULLIF(v_satir->>'MusteriHesapId', '')::integer, 0);
    v_tutar := COALESCE(NULLIF(v_satir->>'Tutar', '')::numeric, 0);
    v_hesapturu := LEFT(COALESCE(NULLIF(v_satir->>'HesapTuru', ''), 'K'), 1);

    IF v_tutar < 0.01 THEN
      CONTINUE;
    END IF;

    IF v_perakende = 1 THEN
      INSERT INTO satiskasa(tur, tarih, rehberid, hesapid, tutar, faturaid, ekleyen, subeid, aktar)
      VALUES (v_tur, v_simdi, v_rehid, v_hesapid, v_tutar, 0, v_kulid, v_subeid, 0);

      v_idler := v_idler || CASE WHEN v_idler = '' THEN '' ELSE ',' END || '0';
    ELSE
      v_belgeno := 'PGPOS-' || to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS') || '-' || (v_adet + 1)::text;

      INSERT INTO kasa(
        tur, plantarihi, islemtarihi, belgeno, rehberid, hesapid,
        borc, alacak, kur, doviz_tutari, doviz_kuru, hesapturu,
        masrafid, faturaid, musterihesapid,
        ekleyen, subeid, yeri, yerid, giriskaynak
      )
      VALUES (
        v_tur, v_simdi, v_simdi, v_belgeno, v_rehid, v_hesapid,
        0, v_tutar, v_kur, v_tutar, v_kur, v_hesapturu,
        CASE WHEN v_fattur > 0 THEN NULLIF(v_masrafid, 0) END,
        CASE WHEN v_fattur > 0 THEN NULLIF(v_faturaid, 0) END,
        CASE WHEN v_tur = 25 THEN NULLIF(v_musterihesapid, 0) END,
        v_kulid, v_subeid, v_kasatakip, v_yerid, v_giriskaynak
      )
      RETURNING id INTO v_id;

      v_idler := v_idler || CASE WHEN v_idler = '' THEN '' ELSE ',' END || v_id::text;
    END IF;

    v_adet := v_adet + 1;
  END LOOP;

  RETURN jsonb_build_object('Sonuc', 1, 'Idler', v_idler, 'Adet', v_adet)::text;
END;
$$;
