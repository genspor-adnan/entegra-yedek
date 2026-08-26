-- Belge okuma/liste ve seri-lot uyumluluk API'leri

CREATE OR REPLACE FUNCTION public.fn_api_belge_getir_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_belgeid integer := NULLIF(j->>'BelgeId', '')::integer;
  v_baslik jsonb;
  v_satirlar jsonb;
BEGIN
  IF COALESCE(v_belgeid, 0) <= 0 THEN
    RAISE EXCEPTION 'BelgeId zorunlu.' USING ERRCODE='P0001';
  END IF;

  SELECT to_jsonb(x)
    INTO v_baslik
  FROM (
    SELECT fb.id, fb.tur, fb.tipi, fb.durum, fb.tarih, fb.faturatarih,
           fb.faturano, fb.faturaseri, fb.kocanno,
           fb.rehberid, r.kod AS carikod, r.firma AS cariad,
           fb.baslik, fb.adres, fb.ilce, fb.il, fb.vd, fb.vno,
           fb.kdvdurum, fb.kur, fb.doviz_cinsi, fb.dovizkur, fb.rapordoviz, fb.faturadovizi,
           fb.fatura_matrahi, fb.kdv_tutari, fb.ekvergi, fb.fatura_tutari, fb.doviz_tutari,
           fb.fatura_maliyeti_ort, fb.girisdepo, gd.depoadi AS girisdepoad,
           fb.cikisdepo, cd.depoadi AS cikisdepoad,
           fb.projeid, p.projekodu, fb.saticikodu, sr.firma AS saticiad,
           fb.subeid, fb.servisid, fb.vade, fb.aciklama, fb.ozelkod, fb.ozelkod2,
           fb.efaturadurum, fb.fiyat_listesi,
           fb.ekleyen, fb.eklemetarihi, fb.degistiren, fb.degistirmetarihi,
           (SELECT count(*) FROM fatura d WHERE d.fatbasid = fb.id) AS satirsay
    FROM fatbaslik fb
    LEFT JOIN rehber r ON r.id = fb.rehberid
    LEFT JOIN depolar gd ON gd.id = fb.girisdepo
    LEFT JOIN depolar cd ON cd.id = fb.cikisdepo
    LEFT JOIN projeler p ON p.id = fb.projeid
    LEFT JOIN rehber sr ON sr.id = fb.saticikodu
    WHERE fb.id = v_belgeid
  ) x;

  IF v_baslik IS NULL THEN
    RAISE EXCEPTION 'Belge bulunamadi.' USING ERRCODE='P0001';
  END IF;

  SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY x.sira, x.id), '[]'::jsonb)
    INTO v_satirlar
  FROM (
    SELECT f.id, f.fatbasid, f.sira, f.tur, f.urunid, f.stokid,
           CASE WHEN f.tur = 0 THEN mg.kod ELSE st.kod END AS kod,
           CASE WHEN f.tur = 0 THEN mg.ad ELSE st.stokadi END AS ad,
           CASE WHEN f.tur = 0 THEN '' ELSE st.urunno END AS urunno,
           f.aciklama, f.adet, f.miktar, f.birim, f.birimfiyat,
           f.iskonto, f.iskonto2, f.tutar, f.kdv, f.kdvdahilfiyat,
           f.kdvmuhafiyeti, f.kur, f.doviz_kuru, f.doviz_birimfiyat,
           f.dovizkurdegeri, f.doviz_tutari, f.otvyuzde, f.otvmiktar,
           f.masrafid, f.projeid, p.projekodu, f.saticikodu, sr.firma AS saticiad,
           f.izleme, f.girdepo, f.cikdepo, f.ozelkod, f.ozelkod2, f.pozno,
           f.yeri, f.yerid, f.iadefaturaid, f.iadeadet, f.ekipmanid,
           f.uretimplandetayid,
           (SELECT count(*) FROM stokizleme si WHERE si.baslikid = f.fatbasid AND si.satirid = f.id) AS izlemsay,
           f.subeid, f.ekleyen, f.eklemetarihi
    FROM fatura f
    LEFT JOIN stoklar st ON f.tur <> 0 AND st.id = f.urunid
    LEFT JOIN masrafgelir mg ON f.tur = 0 AND mg.id = f.urunid
    LEFT JOIN projeler p ON p.id = f.projeid
    LEFT JOIN rehber sr ON sr.id = f.saticikodu
    WHERE f.fatbasid = v_belgeid
  ) x;

  RETURN jsonb_build_object('Sonuc', 1, 'Baslik', v_baslik, 'Satirlar', v_satirlar)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_belge_liste_json(kosullar text DEFAULT '{}', baslik text DEFAULT '')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_tur integer := NULLIF(j->>'Tur', '')::integer;
  v_rehberid integer := COALESCE(NULLIF(j->>'RehberId', '')::integer, 0);
  v_subeid integer := NULLIF(j->>'SubeId', '')::integer;
  v_durum integer := NULLIF(j->>'Durum', '')::integer;
  v_bastarih date := NULLIF(j->>'BasTarih', '')::date;
  v_bittarih date := NULLIF(j->>'BitTarih', '')::date;
  v_belgeno text := NULLIF(j->>'BelgeNo', '');
  v_aciklama text := NULLIF(j->>'Aciklama', '');
  v_sayfa integer := GREATEST(COALESCE(NULLIF(j->>'Sayfa','')::integer, 1), 1);
  v_sayfaboyu integer := COALESCE(NULLIF(j->>'SayfaBoyu','')::integer, 0);
  v_atla integer;
  v_data jsonb;
BEGIN
  v_atla := (v_sayfa - 1) * CASE WHEN v_sayfaboyu > 0 THEN v_sayfaboyu ELSE 0 END;

  WITH turler AS (
    SELECT value::integer AS tur
    FROM jsonb_array_elements_text(COALESCE(j->'Turler','[]'::jsonb))
    WHERE value ~ '^[0-9]+$'
    UNION
    SELECT v_tur WHERE v_tur IS NOT NULL
  ),
  q AS (
    SELECT fb.id, fb.tur, fb.tipi, fb.durum, fb.faturatarih, fb.faturano, fb.faturaseri,
           fb.rehberid, r.kod AS carikod, r.firma AS cariad,
           fb.fatura_matrahi, fb.kdv_tutari, fb.ekvergi, fb.fatura_tutari, fb.doviz_tutari,
           fb.kur, fb.doviz_cinsi, fb.dovizkur, fb.subeid, fb.aciklama, fb.ozelkod, fb.ozelkod2,
           fb.efaturadurum,
           (SELECT count(*) FROM fatura d WHERE d.fatbasid = fb.id) AS satirsay,
           fb.ekleyen, fb.eklemetarihi, fb.degistiren, fb.degistirmetarihi
    FROM fatbaslik fb
    LEFT JOIN rehber r ON r.id = fb.rehberid
    WHERE (NOT EXISTS (SELECT 1 FROM turler) OR fb.tur IN (SELECT tur FROM turler))
      AND (v_bastarih IS NULL OR fb.faturatarih::date >= v_bastarih)
      AND (v_bittarih IS NULL OR fb.faturatarih::date <= v_bittarih)
      AND (v_rehberid = 0 OR fb.rehberid = v_rehberid)
      AND (v_subeid IS NULL OR fb.subeid = v_subeid)
      AND (v_durum IS NULL OR fb.durum = v_durum)
      AND (v_belgeno IS NULL OR fb.faturano ILIKE '%' || v_belgeno || '%')
      AND (v_aciklama IS NULL OR fb.aciklama ILIKE '%' || v_aciklama || '%')
    ORDER BY fb.faturatarih DESC NULLS LAST, fb.id DESC
    OFFSET v_atla
    LIMIT CASE WHEN v_sayfaboyu > 0 THEN v_sayfaboyu ELSE NULL END
  )
  SELECT COALESCE(jsonb_agg(to_jsonb(q)), '[]'::jsonb) INTO v_data FROM q;

  RETURN jsonb_build_object('Sonuc', 1, 'Data', v_data)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_belge_ekalan_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_ekran text := NULLIF(j->>'Ekran', '');
  v_tablo text := upper(NULLIF(j->>'Tablo', ''));
  v_kayitid bigint := NULLIF(j->>'KayitId', '')::bigint;
  v_reg regclass;
  v_degerler jsonb := '{}'::jsonb;
  v_alanlar jsonb := '[]'::jsonb;
BEGIN
  IF v_ekran IS NULL OR v_tablo IS NULL OR v_kayitid IS NULL THEN
    RAISE EXCEPTION 'Ekran, Tablo ve KayitId zorunlu.' USING ERRCODE='P0001';
  END IF;
  IF v_tablo NOT IN ('FATBASLIK','FATURA','SIPARIS','SIPARISDETAY') THEN
    RAISE EXCEPTION 'Tablo beyaz listede degil.' USING ERRCODE='P0001';
  END IF;

  v_reg := to_regclass('public.' || lower(v_tablo));
  IF v_reg IS NULL THEN
    RAISE EXCEPTION 'Tablo bulunamadi.' USING ERRCODE='P0001';
  END IF;

  IF to_regclass('public.alanlar') IS NOT NULL THEN
    SELECT COALESCE(jsonb_agg(to_jsonb(a) ORDER BY a.id), '[]'::jsonb)
      INTO v_alanlar
    FROM alanlar a
    WHERE lower(a.ekranadi) = lower(v_ekran)
      AND upper(a.tablo) = v_tablo;
  END IF;

  EXECUTE format('SELECT to_jsonb(t) FROM %s t WHERE id = $1', v_reg)
    INTO v_degerler
    USING v_kayitid;

  RETURN jsonb_build_object('Sonuc', 1, 'KayitId', v_kayitid, 'Alanlar', v_alanlar, 'Degerler', COALESCE(v_degerler,'{}'::jsonb))::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_belge_serilot_yaz_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_belgeid integer := NULLIF(j->>'BelgeId','')::integer;
  v_satirid integer := NULLIF(j->>'SatirId','')::integer;
  v_urunid integer := NULLIF(j->>'UrunId','')::integer;
  v_belgetur integer := NULLIF(j->>'BelgeTur','')::integer;
  v_payload jsonb;
  v_sonuc jsonb;
BEGIN
  IF COALESCE(v_belgeid,0) <= 0 OR COALESCE(v_satirid,0) <= 0 OR COALESCE(v_urunid,0) <= 0 OR v_belgetur IS NULL THEN
    RAISE EXCEPTION 'BelgeId, SatirId, UrunId ve BelgeTur zorunlu.' USING ERRCODE='P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM fatura WHERE id = v_satirid AND fatbasid = v_belgeid) THEN
    RAISE EXCEPTION 'Belge satiri bulunamadi.' USING ERRCODE='P0001';
  END IF;

  v_payload := jsonb_build_object(
    'belge', jsonb_build_object(
      'tur', v_belgetur,
      'baslikId', v_belgeid,
      'satirId', v_satirid,
      'islemTip', COALESCE(NULLIF(j->>'IslemTip','')::integer, 0)
    ),
    'stokId', v_urunid,
    'izlemTur', COALESCE(NULLIF(j->>'IzlemTur','')::integer, 0),
    'girDepo', COALESCE(NULLIF(j->>'GirisDepo','')::integer, 0),
    'cikDepo', COALESCE(NULLIF(j->>'CikisDepo','')::integer, 0),
    'stokHareketi', COALESCE(NULLIF(j->>'StokDurumDegis','')::integer, 1),
    'kaynakSatirId', COALESCE(NULLIF(j->>'KaynakSatirId','')::integer, 0),
    'kullaniciId', COALESCE(NULLIF(j#>>'{Oturum,KulId}','')::integer, 0),
    'satirlar', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'seriNo', COALESCE(x->>'SeriNo',''),
        'lotNo', COALESCE(x->>'LotNo',''),
        'urt', x->>'Urt',
        'skt', x->>'Skt',
        'adet', COALESCE(x->>'Kalan', x->>'Adet', x->>'Durum'),
        'izlemId', COALESCE(x->>'IzlemId','0'),
        'serilotId', COALESCE(x->>'SeriLotId','0')
      ))
      FROM jsonb_array_elements(COALESCE(j->'SeriLot','[]'::jsonb)) x
    ), '[]'::jsonb)
  );

  v_sonuc := public.fn_prog_izleme_yaz_json(v_payload::text)::jsonb;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'SatirId', v_satirid,
    'Silinen', 0,
    'Yazilan', COALESCE(NULLIF(v_sonuc->>'Yazilan','')::integer, 0),
    'ToplamAdet', COALESCE(NULLIF(v_sonuc->>'ToplamAdet','')::numeric, 0)
  )::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_belge_serilot_yaz_ic(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql
AS $$
  SELECT public.fn_api_belge_serilot_yaz_json($1);
$$;

