-- ============================================================================
-- fn_api_stok_kaydet_json
-- Kaynak: GenUpdate/_Konsolide_66_169/05_Kart_Kaydet_POS.sql
--
-- Stok kartı PG portu. Kart alanları + Fiyatlar/Cevrimler/Seviyeler desteklenir.
-- SatirModu=tam ise koleksiyonlar tam yenilenir.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_stok_kaydet_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  k jsonb := COALESCE(j->'Kart', '{}'::jsonb);
  v_mod text := lower(COALESCE(NULLIF(j->>'SatirModu', ''), 'delta'));
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, -1);
  v_id integer := NULLIF(k->>'ID', '')::integer;
  v_yeni boolean := COALESCE(v_id, 0) = 0;
  v_kod varchar(50) := NULLIF(k->>'Kod', '');
  v_ad varchar(200) := NULLIF(k->>'StokAdi', '');
  v_n integer := 0;
  v_loglanan integer := 0;
  r jsonb;
BEGIN
  IF v_mod NOT IN ('delta', 'tam') THEN
    RAISE EXCEPTION 'SatirModu "delta" ya da "tam" olmali.' USING ERRCODE='P0001';
  END IF;
  IF NOT v_yeni AND NOT EXISTS (SELECT 1 FROM stoklar WHERE id = v_id) THEN
    RAISE EXCEPTION 'Stok karti bulunamadi.' USING ERRCODE='P0001';
  END IF;
  IF v_yeni AND (COALESCE(v_kod, '') = '' OR COALESCE(v_ad, '') = '') THEN
    RAISE EXCEPTION 'Yeni stokta Kart.Kod ve Kart.StokAdi zorunlu.' USING ERRCODE='P0001';
  END IF;
  IF v_kod IS NOT NULL AND EXISTS (SELECT 1 FROM stoklar WHERE kod = v_kod AND id <> COALESCE(v_id, 0)) THEN
    RAISE EXCEPTION 'Bu stok kodu zaten kullaniliyor.' USING ERRCODE='P0001';
  END IF;

  IF v_yeni THEN
    INSERT INTO stoklar(
      kod, stokadi, kategori, tipi, marka, model, grubu, ozellik, ozelkod, ozelkod2,
      muhkodu, anabirim, birim2, birim2miktar, minstok, yeri, ureticiid, saticiid,
      kdv, ekvergi, durum, izleme, rafomru_sure, rafomru_birim, masrafid, gelirid,
      notlar, yetkikodu, garantisuresi, paket, detaybolumu, uretici, icerik, isk2,
      iskontosuz, kullanim, ekipman, otvyuzde, otvmiktar, miktarsec, internet_satis,
      teminsuresi, bildirim, urunno, gtip, hucre, giriskaynak,
      ekleyen, eklemetarihi, subeid
    )
    VALUES (
      v_kod, v_ad,
      NULLIF(k->>'Kategori','')::integer,
      NULLIF(k->>'Tipi','')::integer,
      NULLIF(k->>'Marka','')::integer,
      NULLIF(k->>'Model','')::integer,
      NULLIF(k->>'Grubu','')::integer,
      NULLIF(k->>'Ozellik','')::integer,
      k->>'OzelKod',
      k->>'OzelKod2',
      k->>'MuhKodu',
      NULLIF(k->>'AnaBirim','')::integer,
      NULLIF(k->>'Birim2','')::integer,
      NULLIF(k->>'Birim2Miktar','')::numeric,
      NULLIF(k->>'MinStok','')::numeric,
      NULLIF(k->>'Yeri','')::integer,
      NULLIF(k->>'UreticiId','')::integer,
      NULLIF(k->>'SaticiId','')::integer,
      NULLIF(k->>'Kdv','')::integer,
      NULLIF(k->>'EkVergi','')::numeric,
      COALESCE(NULLIF(k->>'Durum','')::integer, 1),
      COALESCE(NULLIF(k->>'Izleme','')::integer, 0),
      NULLIF(k->>'RafOmruSure','')::integer,
      NULLIF(k->>'RafOmruBirim','')::integer,
      NULLIF(k->>'MasrafId','')::integer,
      NULLIF(k->>'GelirId','')::integer,
      k->>'Notlar',
      k->>'YetkiKodu',
      NULLIF(k->>'GarantiSuresi','')::integer,
      NULLIF(k->>'Paket','')::integer,
      k->>'DetayBolumu',
      NULLIF(k->>'Uretici','')::integer,
      NULLIF(k->>'Icerik','')::integer,
      NULLIF(k->>'Isk2','')::numeric,
      NULLIF(k->>'Iskontosuz','')::integer,
      NULLIF(k->>'Kullanim','')::integer,
      NULLIF(k->>'Ekipman','')::integer,
      NULLIF(k->>'OtvYuzde','')::numeric,
      NULLIF(k->>'OtvMiktar','')::numeric,
      NULLIF(k->>'MiktarSec','')::integer,
      NULLIF(k->>'InternetSatis','')::integer,
      NULLIF(k->>'TeminSuresi','')::integer,
      NULLIF(k->>'Bildirim','')::integer,
      k->>'UrunNo',
      k->>'Gtip',
      k->>'Hucre',
      COALESCE(NULLIF(k->>'GirisKaynak','')::integer, 0),
      v_kulid, now(), v_subeid
    )
    RETURNING id INTO v_id;
  ELSE
    UPDATE stoklar SET
      kod = COALESCE(v_kod, kod),
      stokadi = COALESCE(v_ad, stokadi),
      kategori = COALESCE(NULLIF(k->>'Kategori','')::integer, kategori),
      tipi = COALESCE(NULLIF(k->>'Tipi','')::integer, tipi),
      marka = COALESCE(NULLIF(k->>'Marka','')::integer, marka),
      model = COALESCE(NULLIF(k->>'Model','')::integer, model),
      grubu = COALESCE(NULLIF(k->>'Grubu','')::integer, grubu),
      ozellik = COALESCE(NULLIF(k->>'Ozellik','')::integer, ozellik),
      ozelkod = COALESCE(k->>'OzelKod', ozelkod),
      ozelkod2 = COALESCE(k->>'OzelKod2', ozelkod2),
      muhkodu = COALESCE(k->>'MuhKodu', muhkodu),
      anabirim = COALESCE(NULLIF(k->>'AnaBirim','')::integer, anabirim),
      birim2 = COALESCE(NULLIF(k->>'Birim2','')::integer, birim2),
      birim2miktar = COALESCE(NULLIF(k->>'Birim2Miktar','')::numeric, birim2miktar),
      minstok = COALESCE(NULLIF(k->>'MinStok','')::numeric, minstok),
      yeri = COALESCE(NULLIF(k->>'Yeri','')::integer, yeri),
      ureticiid = COALESCE(NULLIF(k->>'UreticiId','')::integer, ureticiid),
      saticiid = COALESCE(NULLIF(k->>'SaticiId','')::integer, saticiid),
      kdv = COALESCE(NULLIF(k->>'Kdv','')::integer, kdv),
      ekvergi = COALESCE(NULLIF(k->>'EkVergi','')::numeric, ekvergi),
      durum = COALESCE(NULLIF(k->>'Durum','')::integer, durum),
      izleme = COALESCE(NULLIF(k->>'Izleme','')::integer, izleme),
      rafomru_sure = COALESCE(NULLIF(k->>'RafOmruSure','')::integer, rafomru_sure),
      rafomru_birim = COALESCE(NULLIF(k->>'RafOmruBirim','')::integer, rafomru_birim),
      masrafid = COALESCE(NULLIF(k->>'MasrafId','')::integer, masrafid),
      gelirid = COALESCE(NULLIF(k->>'GelirId','')::integer, gelirid),
      notlar = COALESCE(k->>'Notlar', notlar),
      yetkikodu = COALESCE(k->>'YetkiKodu', yetkikodu),
      garantisuresi = COALESCE(NULLIF(k->>'GarantiSuresi','')::integer, garantisuresi),
      paket = COALESCE(NULLIF(k->>'Paket','')::integer, paket),
      detaybolumu = COALESCE(k->>'DetayBolumu', detaybolumu),
      uretici = COALESCE(NULLIF(k->>'Uretici','')::integer, uretici),
      icerik = COALESCE(NULLIF(k->>'Icerik','')::integer, icerik),
      isk2 = COALESCE(NULLIF(k->>'Isk2','')::numeric, isk2),
      iskontosuz = COALESCE(NULLIF(k->>'Iskontosuz','')::integer, iskontosuz),
      kullanim = COALESCE(NULLIF(k->>'Kullanim','')::integer, kullanim),
      ekipman = COALESCE(NULLIF(k->>'Ekipman','')::integer, ekipman),
      otvyuzde = COALESCE(NULLIF(k->>'OtvYuzde','')::numeric, otvyuzde),
      otvmiktar = COALESCE(NULLIF(k->>'OtvMiktar','')::numeric, otvmiktar),
      miktarsec = COALESCE(NULLIF(k->>'MiktarSec','')::integer, miktarsec),
      internet_satis = COALESCE(NULLIF(k->>'InternetSatis','')::integer, internet_satis),
      teminsuresi = COALESCE(NULLIF(k->>'TeminSuresi','')::integer, teminsuresi),
      bildirim = COALESCE(NULLIF(k->>'Bildirim','')::integer, bildirim),
      urunno = COALESCE(k->>'UrunNo', urunno),
      gtip = COALESCE(k->>'Gtip', gtip),
      hucre = COALESCE(k->>'Hucre', hucre),
      giriskaynak = COALESCE(NULLIF(k->>'GirisKaynak','')::integer, giriskaynak),
      degistiren = v_kulid,
      degistirmetarihi = now()
    WHERE id = v_id;
  END IF;

  IF v_mod = 'tam' OR j ? 'Fiyatlar' THEN
    DELETE FROM stokfiyat WHERE stokid = v_id;
    FOR r IN SELECT value FROM jsonb_array_elements(COALESCE(j->'Fiyatlar', '[]'::jsonb)) LOOP
      INSERT INTO stokfiyat(stokid, fiyatadi, birim, fiyat, kur, kdvdurum, paketid, satis, ekleyen, eklemetarihi)
      VALUES (v_id, NULLIF(r->>'FiyatAdi','')::integer, NULLIF(r->>'Birim','')::integer, NULLIF(r->>'Fiyat','')::numeric,
              r->>'Kur', NULLIF(r->>'KdvDurum','')::integer, NULLIF(r->>'PaketId','')::integer,
              NULLIF(r->>'Satis','')::integer, v_kulid, now());
    END LOOP;
  END IF;

  IF v_mod = 'tam' OR j ? 'Cevrimler' THEN
    DELETE FROM stokcevrim WHERE stokid = v_id;
    FOR r IN SELECT value FROM jsonb_array_elements(COALESCE(j->'Cevrimler', '[]'::jsonb)) LOOP
      INSERT INTO stokcevrim(stokid, adet1, birim1, adet2, birim2, ekleyen, eklemetarihi)
      VALUES (v_id, NULLIF(r->>'Adet1','')::numeric, NULLIF(r->>'Birim1','')::integer,
              NULLIF(r->>'Adet2','')::numeric, NULLIF(r->>'Birim2','')::integer, v_kulid, now());
    END LOOP;
  END IF;

  IF v_mod = 'tam' OR j ? 'Seviyeler' THEN
    DELETE FROM stokseviye WHERE stokid = v_id;
    FOR r IN SELECT value FROM jsonb_array_elements(COALESCE(j->'Seviyeler', '[]'::jsonb)) LOOP
      INSERT INTO stokseviye(stokid, depoid, maksimum, kritik, minimum, ekleyen, eklemetarihi)
      VALUES (v_id, NULLIF(r->>'DepoId','')::integer, NULLIF(r->>'Maksimum','')::numeric,
              NULLIF(r->>'Kritik','')::numeric, NULLIF(r->>'Minimum','')::numeric, v_kulid, now());
    END LOOP;
  END IF;

  v_n := public.fn_api_log_yaz_ic(
    p_tablo := 'STOKLAR', p_kosul := 'ID=@pB', p_kosulpar := v_id,
    p_tabno := 88, p_usttabno := 88, p_ustid := v_id,
    p_kulid := v_kulid, p_subeid := v_subeid,
    p_stokid := v_id,
    p_islemtipi := CASE WHEN v_yeni THEN 1 ELSE 2 END::smallint
  );
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  RETURN jsonb_build_object('Sonuc', 1, 'KayitId', v_id, 'Yeni', CASE WHEN v_yeni THEN 1 ELSE 0 END, 'Loglanan', v_loglanan)::text;
END;
$$;
