-- ============================================================================
-- fn_api_stok_klonla_json
-- Kaynak: GenUpdate/_Konsolide_66_169/05_Kart_Kaydet_POS.sql
--
-- Stok klonlama PG portu. Yeni kart fn_api_stok_kaydet_json ile oluşturulur.
-- Barkod kopyalanmaz.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_stok_klonla_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kaynakid integer := NULLIF(j->>'KaynakId', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, -1);
  v_yenikod varchar(50) := NULLIF(j->>'Kod', '');
  v_yeniad varchar(200) := NULLIF(j->>'StokAdi', '');
  v_detay integer := COALESCE(NULLIF(j->>'Detay', '')::integer, 0);
  v_resim integer := COALESCE(NULLIF(j->>'Resim', '')::integer, 1);
  v_ekler integer := COALESCE(NULLIF(j->>'Ekler', '')::integer, 1);
  v_kok varchar(50);
  v_i integer := 1;
  v_payload jsonb;
  v_sonuc jsonb;
  v_yeniid integer;
BEGIN
  IF v_kaynakid IS NULL OR NOT EXISTS (SELECT 1 FROM stoklar WHERE id = v_kaynakid) THEN
    RAISE EXCEPTION 'Kaynak stok karti bulunamadi.' USING ERRCODE='P0001';
  END IF;

  IF COALESCE(v_yenikod, '') = '' THEN
    SELECT kod INTO v_kok FROM stoklar WHERE id = v_kaynakid;
    v_yenikod := LEFT(COALESCE(v_kok, ''), 47) || '_K1';
    WHILE EXISTS (SELECT 1 FROM stoklar WHERE kod = v_yenikod) AND v_i < 100 LOOP
      v_i := v_i + 1;
      v_yenikod := LEFT(COALESCE(v_kok, ''), GREATEST(1, 50 - (2 + length(v_i::text)))) || '_K' || v_i::text;
    END LOOP;
  END IF;

  SELECT jsonb_build_object(
    'SatirModu', 'tam',
    'Kart', jsonb_build_object(
      'Kod', v_yenikod,
      'StokAdi', COALESCE(v_yeniad, LEFT(COALESCE(s.stokadi, ''), 190) || ' (KOPYA)'),
      'Kategori', s.kategori, 'Tipi', s.tipi, 'Marka', s.marka, 'Model', s.model,
      'Grubu', s.grubu, 'Ozellik', s.ozellik, 'OzelKod', s.ozelkod, 'OzelKod2', s.ozelkod2,
      'MuhKodu', s.muhkodu, 'AnaBirim', s.anabirim, 'Birim2', s.birim2,
      'Birim2Miktar', s.birim2miktar, 'MinStok', s.minstok, 'Yeri', s.yeri,
      'UreticiId', s.ureticiid, 'SaticiId', s.saticiid, 'Kdv', s.kdv, 'EkVergi', s.ekvergi,
      'Durum', s.durum, 'Izleme', s.izleme, 'RafOmruSure', s.rafomru_sure,
      'RafOmruBirim', s.rafomru_birim, 'MasrafId', s.masrafid, 'GelirId', s.gelirid,
      'Notlar', s.notlar, 'YetkiKodu', s.yetkikodu, 'GarantiSuresi', s.garantisuresi,
      'Paket', s.paket, 'DetayBolumu', s.detaybolumu, 'Uretici', s.uretici, 'Icerik', s.icerik,
      'Isk2', s.isk2, 'Iskontosuz', s.iskontosuz, 'Kullanim', s.kullanim, 'Ekipman', s.ekipman,
      'OtvYuzde', s.otvyuzde, 'OtvMiktar', s.otvmiktar, 'MiktarSec', s.miktarsec,
      'InternetSatis', s.internet_satis, 'TeminSuresi', s.teminsuresi, 'Bildirim', s.bildirim,
      'UrunNo', s.urunno, 'Gtip', s.gtip, 'Hucre', s.hucre
    ),
    'Fiyatlar', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('FiyatAdi', f.fiyatadi, 'Birim', f.birim, 'Fiyat', f.fiyat, 'Kur', f.kur, 'KdvDurum', f.kdvdurum, 'PaketId', f.paketid, 'Satis', f.satis))
      FROM stokfiyat f WHERE f.stokid = v_kaynakid
    ), '[]'::jsonb),
    'Cevrimler', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('Adet1', c.adet1, 'Birim1', c.birim1, 'Adet2', c.adet2, 'Birim2', c.birim2))
      FROM stokcevrim c WHERE c.stokid = v_kaynakid
    ), '[]'::jsonb),
    'Seviyeler', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('DepoId', sv.depoid, 'Maksimum', sv.maksimum, 'Kritik', sv.kritik, 'Minimum', sv.minimum))
      FROM stokseviye sv WHERE sv.stokid = v_kaynakid
    ), '[]'::jsonb),
    'Oturum', jsonb_build_object('KulId', v_kulid, 'SubeId', v_subeid)
  )
  INTO v_payload
  FROM stoklar s
  WHERE s.id = v_kaynakid;

  v_sonuc := public.fn_api_stok_kaydet_json(v_payload::text)::jsonb;
  v_yeniid := NULLIF(v_sonuc->>'KayitId', '')::integer;
  IF COALESCE(v_yeniid, 0) = 0 THEN
    RAISE EXCEPTION 'Klon stok karti olusturulamadi.' USING ERRCODE='P0001';
  END IF;

  IF v_ekler = 1 THEN
    INSERT INTO isortagi(stokid, rehberid, iliski, ekleyen, eklemetarihi, subeid)
    SELECT v_yeniid, rehberid, iliski, v_kulid, now(), subeid
      FROM isortagi WHERE stokid = v_kaynakid;

    INSERT INTO stokesdeger(stokid, stokesdegerid, tur, aciklama, ekleyen, eklemetarihi, subeid)
    SELECT v_yeniid, stokesdegerid, tur, aciklama, v_kulid, now(), subeid
      FROM stokesdeger WHERE stokid = v_kaynakid;
  END IF;

  IF v_detay = 1 THEN
    INSERT INTO rehberbilgi(modul, yeri, yer_id, sira, etiket, bilgi, ekleyen, eklemetarihi, subeid)
    SELECT modul, yeri, v_yeniid, sira, etiket, bilgi, v_kulid, now(), subeid
      FROM rehberbilgi WHERE yeri = 88 AND yer_id = v_kaynakid;
  END IF;

  IF v_resim = 1 THEN
    INSERT INTO imaj(varsayilan, rehberid, yeri, yer_id, belgeadi, belge, aciklama,
                     belgeno, tur, icdis, durum, dosyaid, ekleyen, degistirmetarihi, subeid)
    SELECT varsayilan, v_yeniid, yeri, v_yeniid, belgeadi, belge, aciklama,
           belgeno, tur, icdis, durum, dosyaid, v_kulid, now(), subeid
      FROM imaj WHERE yeri = 88 AND yer_id = v_kaynakid;
  END IF;

  -- PAKET ICERIGI (paketdetay): stok bir PAKET ise bilesenleri kartin tanimidir ->
  --   kosulsuz klonlanir (eskiden hic kopyalanmiyordu, kopya kart bos paket geliyordu).
  --   urunid = kaynagin KENDISI olan satir (paket basligi) klonun kendisine baglanir.
  INSERT INTO paketdetay(paketid, urunid, birim, adet, stok, ekleyen, eklemetarihi, subeid, tur)
  SELECT v_yeniid,
         CASE WHEN urunid = v_kaynakid THEN v_yeniid ELSE urunid END,
         birim, adet, stok, v_kulid, now(), subeid, tur
    FROM paketdetay WHERE paketid = v_kaynakid;

  PERFORM public.fn_api_log_kaynak_isaretle(88, v_yeniid, 3::smallint, v_kaynakid, 88);

  RETURN jsonb_build_object('Sonuc', 1, 'KaynakId', v_kaynakid, 'KayitId', v_yeniid, 'Kod', (SELECT kod FROM stoklar WHERE id = v_yeniid))::text;
END;
$$;
