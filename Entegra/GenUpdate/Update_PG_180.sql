-- ============================================================
-- Update_PG_180.sql   #pg   (PostgreSQL)
-- Stok kart kopyalama: paket fiyat baglantisi yeni pakete tasinsin
--
-- MSSQL Update_SQL_180 karsiligi. fn_api_stok_klonla_json icine eksikse:
--   1) paketdetay klonlama blogu,
--   2) stokfiyat.paketid kaynak stoktan yeni stoga remap blogu
-- eklenir. Idempotenttir.
-- ============================================================

DO $$
DECLARE
  v_sql text;
  v_ek text := '';
  v_marker text := '  PERFORM public.fn_api_log_kaynak_isaretle';
BEGIN
  SELECT pg_get_functiondef('public.fn_api_stok_klonla_json(text)'::regprocedure)
    INTO v_sql;

  IF v_sql IS NULL THEN
    RAISE EXCEPTION 'fn_api_stok_klonla_json bulunamadi.';
  END IF;

  IF v_sql NOT LIKE '%PAKET FIYAT BAGLANTISI (Update_PG_180)%' THEN
    v_ek := v_ek || E'
  -- PAKET FIYAT BAGLANTISI (Update_PG_180): Kaydet API fiyatlari kaynak
  --   paketid ile eklediyse kopya paket fiyatlarini yeni pakete bagla.
  UPDATE stokfiyat SET paketid = v_yeniid
   WHERE stokid = v_yeniid AND paketid = v_kaynakid;
';
  END IF;

  IF v_sql NOT LIKE '%FROM paketdetay WHERE paketid = v_kaynakid%' THEN
    v_ek := v_ek || E'
  -- PAKET ICERIGI (Update_PG_177/180): stok bir PAKET ise bilesenleri
  --   kartin tanimidir; kopyaya da tasinir.
  INSERT INTO paketdetay(paketid, urunid, birim, adet, stok, ekleyen, eklemetarihi, subeid, tur)
  SELECT v_yeniid,
         CASE WHEN urunid = v_kaynakid THEN v_yeniid ELSE urunid END,
         birim, adet, stok, v_kulid, now(), subeid, tur
    FROM paketdetay WHERE paketid = v_kaynakid;
';
  END IF;

  IF v_ek = '' THEN
    RAISE NOTICE 'fn_api_stok_klonla_json zaten paket kopyalama duzeltmelerini iceriyor.';
    RETURN;
  END IF;

  IF position(v_marker in v_sql) = 0 THEN
    RAISE EXCEPTION 'fn_api_stok_klonla_json patch noktasi bulunamadi.';
  END IF;

  v_sql := replace(v_sql, v_marker, v_ek || E'\n' || v_marker);
  EXECUTE v_sql;
  RAISE NOTICE 'fn_api_stok_klonla_json paket kopyalama duzeltmesi uygulandi.';
END $$;
