-- fn_api_belge_donusum_json
-- MSSQL: sp_Api_Belge_Donusum_Json
-- PG cekirdek port: SIPARIS/FATBASLIK kaynaklarini FATBASLIK/FATURA hedefine donusturur.
-- Hedef belge/satir yazimi fn_api_belge_kaydet_json uzerinden yapilir.

CREATE OR REPLACE FUNCTION public.fn_api_belge_donusum_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_donusumturu integer := NULLIF(j->>'DonusumTuru', '')::integer;
  v_kaynakid integer := NULLIF(j->>'KaynakBelgeId', '')::integer;
  v_hedefid integer := COALESCE(NULLIF(j->>'HedefBelgeId', '')::integer, 0);
  v_tarih timestamp := COALESCE(NULLIF(j->>'Tarih','')::timestamp, now());
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 1);
  r record;
  h record;
  v_payload jsonb;
  v_rows jsonb;
  v_sonuc jsonb;
  v_kaynaktur integer;
  v_kaynakno text;
  v_kaynakdurum jsonb := '{}'::jsonb;
BEGIN
  IF v_donusumturu IS NULL THEN
    RAISE EXCEPTION 'DonusumTuru zorunlu.' USING ERRCODE='P0001';
  END IF;
  IF v_kaynakid IS NULL OR v_kaynakid <= 0 THEN
    RAISE EXCEPTION 'KaynakBelgeId zorunlu.' USING ERRCODE='P0001';
  END IF;

  SELECT *
    INTO r
  FROM public.fn_prog_belgedonusum_rota()
  WHERE donusumturu = v_donusumturu;

  IF r.donusumturu IS NULL THEN
    RAISE EXCEPTION 'Bilinmeyen donusum turu: %', v_donusumturu USING ERRCODE='P0001';
  END IF;
  IF COALESCE(r.destek, 0) = 0 THEN
    RAISE EXCEPTION 'Bu donusum turu (%) henuz sunucu tarafinda desteklenmiyor.', v_donusumturu USING ERRCODE='P0001';
  END IF;
  IF r.hedefbasliktablo <> 'FATBASLIK' OR r.hedefdetaytablo <> 'FATURA' THEN
    RAISE EXCEPTION 'Bu PG cekirdegi sadece FATBASLIK/FATURA hedefli donusumleri destekler.' USING ERRCODE='P0001';
  END IF;

  IF r.kaynakbasliktablo = 'SIPARIS' THEN
    SELECT s.tur, s.siparisno, s.tipi, s.rehberid, s.girisdepo, s.cikisdepo,
           s.kdvdurum, s.kur, s.doviz_cinsi, s.dovizkur, s.rapordoviz,
           s.projeid, s.vade, s.saticikodu, s.fiyat_listesi,
           s.baslik, s.adres, s.ilce, s.il, s.vd, s.vno
      INTO h
      FROM siparis s
     WHERE s.id = v_kaynakid;
  ELSIF r.kaynakbasliktablo = 'FATBASLIK' THEN
    SELECT fb.tur, fb.faturano AS siparisno, fb.tipi, fb.rehberid, fb.girisdepo, fb.cikisdepo,
           fb.kdvdurum, fb.kur, fb.doviz_cinsi, fb.dovizkur, fb.rapordoviz,
           fb.projeid, fb.vade, fb.saticikodu, fb.fiyat_listesi,
           fb.baslik, fb.adres, fb.ilce, fb.il, fb.vd, fb.vno
      INTO h
      FROM fatbaslik fb
     WHERE fb.id = v_kaynakid;
  ELSE
    RAISE EXCEPTION 'Kaynak tablo desteklenmiyor: %', r.kaynakbasliktablo USING ERRCODE='P0001';
  END IF;

  IF h.tur IS NULL THEN
    RAISE EXCEPTION 'Kaynak belge bulunamadi.' USING ERRCODE='P0001';
  END IF;
  IF h.tur <> r.kaynaktur THEN
    RAISE EXCEPTION 'Kaynak belge turu (%) bu donusum icin beklenenle (%) uyusmuyor.', h.tur, r.kaynaktur USING ERRCODE='P0001';
  END IF;
  IF v_hedefid > 0 AND NOT EXISTS (SELECT 1 FROM fatbaslik WHERE id = v_hedefid) THEN
    RAISE EXCEPTION 'Hedef belge bulunamadi.' USING ERRCODE='P0001';
  END IF;

  v_kaynaktur := h.tur;
  v_kaynakno := h.siparisno;

  IF r.kaynakdetaytablo = 'SIPARISDETAY' THEN
    WITH secili AS (
      SELECT DISTINCT value::integer AS id
      FROM jsonb_array_elements_text(COALESCE(j->'SatirIds', '[]'::jsonb))
      WHERE value ~ '^[0-9]+$'
    ),
    s AS (
      SELECT sd.*,
             (COALESCE(sd.adet,0)
              - COALESCE((SELECT sum(abs(f.adet)) FROM fatura f
                           WHERE f.yerid = sd.id AND f.yeri = v_donusumturu), 0))::numeric AS kalan
      FROM siparisdetay sd
      WHERE sd.siparisid = v_kaynakid
        AND (NOT EXISTS (SELECT 1 FROM secili) OR sd.id IN (SELECT id FROM secili))
    )
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
      'Sira', q.sira,
      'UrunId', q.urunid,
      'Tur', q.tur,
      'Adet', q.kalan * COALESCE(r.carpan, 1),
      'Miktar', CASE WHEN COALESCE(q.adet,0) = 0 THEN q.kalan ELSE round((COALESCE(q.miktar,q.adet) * q.kalan / q.adet)::numeric, 6) END,
      'Birim', q.birim,
      'BirimFiyat', q.birimfiyat,
      'Kdv', q.kdv,
      'Iskonto', q.iskonto,
      'Iskonto2', q.iskonto2,
      'Kur', q.kur,
      'DovizKuru', q.doviz_kuru,
      'DovizBirimFiyat', q.doviz_birimfiyat,
      'DovizKurDegeri', q.dovizkurdegeri,
      'Aciklama', q.aciklama,
      'ProjeId', q.projeid,
      'MasrafId', q.masrafid,
      'OzelKod', q.ozelkod,
      'OzelKod2', q.ozelkod2,
      'Izleme', q.izleme,
      'PozNo', q.pozno,
      'EkipmanId', q.ekipmanid,
      'Mf', q.mf,
      'MuhKodu', q.muhkodu,
      'Kasa', q.kasa,
      'OtvYuzde', q.otvyuzde,
      'OtvMiktar', q.otvmiktar,
      'Vade', q.vade,
      'KampanyaId', q.kampanyaid,
      'TeslimTarihi', q.teslimtarihi,
      'Yeri', v_donusumturu,
      'YerId', q.id
    ) ORDER BY q.sira), '[]'::jsonb)
    INTO v_rows
    FROM (
      SELECT s.*, row_number() OVER (ORDER BY s.id) AS sira
      FROM s
      WHERE s.kalan > 0.0001
    ) q;
  ELSIF r.kaynakdetaytablo = 'FATURA' THEN
    WITH secili AS (
      SELECT DISTINCT value::integer AS id
      FROM jsonb_array_elements_text(COALESCE(j->'SatirIds', '[]'::jsonb))
      WHERE value ~ '^[0-9]+$'
    ),
    s AS (
      SELECT f.*,
             (COALESCE(f.adet,0)
              - COALESCE((SELECT sum(abs(f2.adet)) FROM fatura f2
                           WHERE f2.yerid = f.id AND f2.yeri = v_donusumturu), 0))::numeric AS kalan
      FROM fatura f
      WHERE f.fatbasid = v_kaynakid
        AND (NOT EXISTS (SELECT 1 FROM secili) OR f.id IN (SELECT id FROM secili))
    )
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
      'Sira', q.sira,
      'UrunId', q.urunid,
      'Tur', q.tur,
      'Adet', q.kalan * COALESCE(r.carpan, 1),
      'Miktar', CASE WHEN COALESCE(q.adet,0) = 0 THEN q.kalan ELSE round((COALESCE(q.miktar,q.adet) * q.kalan / q.adet)::numeric, 6) END,
      'Birim', q.birim,
      'BirimFiyat', q.birimfiyat,
      'Kdv', q.kdv,
      'Iskonto', q.iskonto,
      'Iskonto2', q.iskonto2,
      'Kur', q.kur,
      'DovizKuru', q.doviz_kuru,
      'DovizBirimFiyat', q.doviz_birimfiyat,
      'DovizKurDegeri', q.dovizkurdegeri,
      'Aciklama', q.aciklama,
      'ProjeId', q.projeid,
      'MasrafId', q.masrafid,
      'OzelKod', q.ozelkod,
      'OzelKod2', q.ozelkod2,
      'Izleme', q.izleme,
      'PozNo', q.pozno,
      'EkipmanId', q.ekipmanid,
      'Mf', q.mf,
      'MuhKodu', q.muhkodu,
      'Kasa', q.kasa,
      'OtvYuzde', q.otvyuzde,
      'OtvMiktar', q.otvmiktar,
      'Vade', q.vade,
      'KampanyaId', q.kampanyaid,
      'TeslimTarihi', q.teslimtarihi,
      'Yeri', v_donusumturu,
      'YerId', q.id
    ) ORDER BY q.sira), '[]'::jsonb)
    INTO v_rows
    FROM (
      SELECT s.*, row_number() OVER (ORDER BY COALESCE(s.sira, s.id), s.id) AS sira
      FROM s
      WHERE s.kalan > 0.0001
    ) q;
  ELSE
    RAISE EXCEPTION 'Kaynak detay tablo desteklenmiyor: %', r.kaynakdetaytablo USING ERRCODE='P0001';
  END IF;

  IF jsonb_array_length(COALESCE(v_rows, '[]'::jsonb)) = 0 THEN
    RAISE EXCEPTION 'Donusturulecek kalan satir yok (belge tamamlanmis olabilir).' USING ERRCODE='P0001';
  END IF;

  v_payload := jsonb_build_object(
    'SatirModu', CASE WHEN v_hedefid > 0 THEN 'delta' ELSE 'tam' END,
    'Baslik', CASE WHEN v_hedefid > 0 THEN
      jsonb_build_object('ID', v_hedefid)
    ELSE
      jsonb_build_object(
        'Tur', r.hedeftur,
        'Tipi', h.tipi,
        'Tarih', to_char(v_tarih, 'YYYY-MM-DD"T"HH24:MI:SS'),
        'FaturaTarih', to_char(v_tarih, 'YYYY-MM-DD"T"HH24:MI:SS'),
        'RehberId', h.rehberid,
        'GirisDepo', h.girisdepo,
        'CikisDepo', h.cikisdepo,
        'KdvDurum', h.kdvdurum,
        'Kur', h.kur,
        'DovizCinsi', h.doviz_cinsi,
        'DovizKur', h.dovizkur,
        'RaporDoviz', h.rapordoviz,
        'FaturaDovizi', h.rapordoviz,
        'ProjeId', h.projeid,
        'Vade', h.vade,
        'SaticiKodu', h.saticikodu,
        'FiyatListesi', h.fiyat_listesi,
        'Durum', 0,
        'Unvan', h.baslik,
        'Adres', h.adres,
        'Ilce', h.ilce,
        'Il', h.il,
        'Vd', h.vd,
        'Vno', h.vno,
        'Aciklama', left(COALESCE(v_kaynakno,'') || ' nolu belgeden', 200)
      )
    END,
    'Satirlar', v_rows,
    'Oturum', jsonb_build_object('KulId', v_kulid, 'SubeId', v_subeid)
  );

  v_sonuc := public.fn_api_belge_kaydet_json(v_payload::text)::jsonb;
  v_hedefid := NULLIF(v_sonuc->>'BelgeId','')::integer;

  IF COALESCE(v_hedefid, 0) = 0 THEN
    RAISE EXCEPTION 'Hedef belge olusturulamadi.' USING ERRCODE='P0001';
  END IF;

  v_kaynakdurum := public.fn_prog_belge_kaynakdurum_json(jsonb_build_object('belgeId', v_hedefid)::text)::jsonb;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'DonusumTuru', v_donusumturu,
    'KaynakBelgeId', v_kaynakid,
    'HedefBelgeId', v_hedefid,
    'HedefBelgeNo', (SELECT faturano FROM fatbaslik WHERE id = v_hedefid),
    'HedefTur', r.hedeftur,
    'KaynakTur', v_kaynaktur,
    'Satir', jsonb_array_length(v_rows),
    'Loglanan', COALESCE(NULLIF(v_sonuc->>'Loglanan','')::integer, 0),
    'Toplam', v_sonuc->'Toplam',
    'KaynakDurum', v_kaynakdurum
  )::text;
END;
$$;

