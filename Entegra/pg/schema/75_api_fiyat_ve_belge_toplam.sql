-- ============================================================================
-- Gerçek PG API portlari - kucuk/idempotent parcalar
-- Kaynak: GenUpdate/_Konsolide_66_169
--
-- 1) sp_Api_Fiyat_EksikleriEkle_Json
-- 2) sp_Api_Belge_ToplamHesapla_Json
--
-- Bu dosya 74_api_eksik_koruma_ve_teklif.sql dosyasindaki koruma/stub
-- fonksiyonlarini, gercek PG govdesi hazir olan API'ler icin override eder.
-- ============================================================================

-- ============================================================
-- EKSIK FIYAT SATIRLARI
-- Girdi: {"Dil":0,"Kur":"TL"}
-- Cikti: {"Sonuc":1,"Stok":n,"Hizmet":n}
-- Idempotent: ayni fiyat satiri varsa tekrar eklemez.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_api_fiyat_eksikleriekle_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_dil integer := COALESCE(NULLIF(j->>'Dil', '')::integer, 0);
  v_kur varchar(5) := COALESCE(NULLIF(j->>'Kur', ''), 'TL');
  v_stok integer := 0;
  v_hizmet integer := 0;
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS pg_temp.tmp_api_fiyat_ad(
    fiyatadi integer NOT NULL,
    satis smallint NOT NULL,
    PRIMARY KEY (fiyatadi, satis)
  ) ON COMMIT DROP;

  TRUNCATE TABLE pg_temp.tmp_api_fiyat_ad;

  INSERT INTO pg_temp.tmp_api_fiyat_ad(fiyatadi, satis)
  SELECT DISTINCT g.deger::integer, 1::smallint
  FROM genini g
  WHERE g.bolum = -1007 AND g.dil = v_dil AND g.deger IS NOT NULL
  UNION
  SELECT DISTINCT g.deger::integer, 0::smallint
  FROM genini g
  WHERE g.bolum = -1008 AND g.dil = v_dil AND g.deger IS NOT NULL;

  IF NOT EXISTS (SELECT 1 FROM pg_temp.tmp_api_fiyat_ad) THEN
    INSERT INTO pg_temp.tmp_api_fiyat_ad(fiyatadi, satis)
    SELECT DISTINCT g.deger::integer, 1::smallint
    FROM genini g
    WHERE g.bolum = -1007 AND g.deger IS NOT NULL
    UNION
    SELECT DISTINCT g.deger::integer, 0::smallint
    FROM genini g
    WHERE g.bolum = -1008 AND g.deger IS NOT NULL
    ON CONFLICT DO NOTHING;
  END IF;

  INSERT INTO stokfiyat(stokid, fiyatadi, birim, fiyat, kur, kdvdurum, paketid, satis)
  SELECT s.id, a.fiyatadi, b.birim, -1.0, v_kur, 0, 0, a.satis
  FROM stoklar s
  CROSS JOIN pg_temp.tmp_api_fiyat_ad a
  CROSS JOIN LATERAL (
    SELECT s.anabirim AS birim
    UNION
    SELECT s.birim2 WHERE COALESCE(s.birim2, 0) <> COALESCE(s.anabirim, 0)
  ) b
  WHERE b.birim IS NOT NULL
    AND NOT EXISTS (
      SELECT 1
      FROM stokfiyat sf
      WHERE sf.stokid = s.id
        AND sf.birim = b.birim
        AND sf.fiyatadi = a.fiyatadi
        AND sf.satis = a.satis
    );
  GET DIAGNOSTICS v_stok = ROW_COUNT;

  INSERT INTO fiyatlar(hizmetid, fiyatadi, fiyat, kur, kdvdurum, paketid, satis)
  SELECT h.id, a.fiyatadi, -1.0, v_kur, 0, 0, a.satis
  FROM masrafgelir h
  CROSS JOIN pg_temp.tmp_api_fiyat_ad a
  WHERE NOT EXISTS (
    SELECT 1
    FROM fiyatlar f
    WHERE f.hizmetid = h.id
      AND f.fiyatadi = a.fiyatadi
      AND f.satis = a.satis
  );
  GET DIAGNOSTICS v_hizmet = ROW_COUNT;

  RETURN jsonb_build_object('Sonuc', 1, 'Stok', v_stok, 'Hizmet', v_hizmet)::text;
END;
$$;

-- ============================================================
-- BELGE/SIPARIS DURUM HESAPLA - ic hesaplayici
-- MSSQL sp_Api_Belge_Durum_Yaz_Ic portu.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_api_belge_durum_yaz_ic(
  p_belgeid integer,
  p_kaynak text DEFAULT 'siparis',
  p_yaz integer DEFAULT 1
)
RETURNS TABLE(
  tur integer,
  durum integer,
  oncekidurum integer,
  satir integer,
  tamamlanan integer,
  kismi integer,
  acik integer,
  neden text,
  yazildi integer
)
LANGUAGE plpgsql AS $$
DECLARE
  v_yeri integer[];
BEGIN
  neden := '';
  yazildi := 0;
  satir := 0;
  tamamlanan := 0;
  kismi := 0;
  acik := 0;

  IF lower(COALESCE(p_kaynak, 'siparis')) = 'siparis' THEN
    SELECT s.tur, COALESCE(s.durum, 0)
      INTO tur, oncekidurum
    FROM siparis s
    WHERE s.id = p_belgeid;
  ELSE
    SELECT fb.tur, COALESCE(fb.durum, 0)
      INTO tur, oncekidurum
    FROM fatbaslik fb
    WHERE fb.id = p_belgeid;
  END IF;

  IF tur IS NULL THEN
    RAISE EXCEPTION 'Kayit bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  durum := oncekidurum;

  IF oncekidurum NOT IN (0, 1, 2, 9) THEN
    neden := 'durum korumali (' || oncekidurum::text || ')';
  END IF;

  IF neden = '' THEN
    SELECT ARRAY_AGG(DISTINCT r.donusumturu)
      INTO v_yeri
    FROM public.fn_prog_belgedonusum_rota() r
    WHERE r.kaynaktur = tur
      AND r.kaynakdetaytablo = CASE WHEN lower(COALESCE(p_kaynak, 'siparis')) = 'siparis'
                                    THEN 'SIPARISDETAY' ELSE 'FATURA' END
      AND r.kalanhedeftablo = 'FATURA';

    IF COALESCE(array_length(v_yeri, 1), 0) = 0 THEN
      neden := CASE WHEN lower(COALESCE(p_kaynak, 'siparis')) = 'siparis'
                    THEN 'siparis turu kapsam disi'
                    ELSE 'belge turu kapsam disi' END;
    END IF;
  END IF;

  IF neden = '' THEN
    IF lower(COALESCE(p_kaynak, 'siparis')) = 'siparis' THEN
      WITH s AS (
        SELECT sd.id AS satirid,
               COALESCE(sd.adet, 0)::numeric AS adet,
               COALESCE((
                 SELECT SUM(COALESCE(f.adet, 0))
                 FROM fatura f
                 WHERE f.yerid = sd.id AND f.yeri = ANY(v_yeri)
               ), 0)::numeric AS cikan
        FROM siparisdetay sd
        WHERE sd.siparisid = p_belgeid AND COALESCE(sd.adet, 0) > 0
      )
      SELECT COUNT(*)::integer,
             COALESCE(SUM(CASE WHEN adet - cikan <= 0 THEN 1 ELSE 0 END), 0)::integer,
             COALESCE(SUM(CASE WHEN cikan <= 0 THEN 1 ELSE 0 END), 0)::integer,
             COALESCE(SUM(CASE WHEN cikan > 0 AND adet - cikan > 0 THEN 1 ELSE 0 END), 0)::integer
        INTO satir, tamamlanan, acik, kismi
      FROM s;
    ELSE
      WITH s AS (
        SELECT fd.id AS satirid,
               COALESCE(fd.adet, 0)::numeric AS adet,
               COALESCE((
                 SELECT SUM(COALESCE(f.adet, 0))
                 FROM fatura f
                 WHERE f.yerid = fd.id AND f.yeri = ANY(v_yeri)
               ), 0)::numeric AS cikan
        FROM fatura fd
        WHERE fd.fatbasid = p_belgeid AND COALESCE(fd.adet, 0) > 0
      )
      SELECT COUNT(*)::integer,
             COALESCE(SUM(CASE WHEN adet - cikan <= 0 THEN 1 ELSE 0 END), 0)::integer,
             COALESCE(SUM(CASE WHEN cikan <= 0 THEN 1 ELSE 0 END), 0)::integer,
             COALESCE(SUM(CASE WHEN cikan > 0 AND adet - cikan > 0 THEN 1 ELSE 0 END), 0)::integer
        INTO satir, tamamlanan, acik, kismi
      FROM s;
    END IF;

    IF satir = 0 THEN
      neden := 'adetli satir yok';
    ELSIF satir = tamamlanan THEN
      durum := 9;
    ELSIF acik = satir THEN
      durum := CASE WHEN oncekidurum = 2 THEN 2 ELSE 0 END;
    ELSE
      durum := 1;
    END IF;
  END IF;

  IF p_yaz = 1 AND neden = '' AND durum <> oncekidurum THEN
    IF lower(COALESCE(p_kaynak, 'siparis')) = 'siparis' THEN
      UPDATE siparis SET durum = fn_api_belge_durum_yaz_ic.durum WHERE id = p_belgeid;
    ELSE
      UPDATE fatbaslik SET durum = fn_api_belge_durum_yaz_ic.durum WHERE id = p_belgeid;
    END IF;
    yazildi := 1;
  END IF;

  RETURN NEXT;
END;
$$;

-- ============================================================
-- BELGE/SIPARIS DURUM HESAPLA
-- Girdi: {"BelgeId":123,"Kaynak":"siparis|belge","Yaz":1}
-- Cikti: MSSQL API ile ayni JSON anahtarlari.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_api_belge_durumhesapla_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_belgeid integer := NULLIF(j->>'BelgeId', '')::integer;
  v_kaynak text := lower(COALESCE(NULLIF(j->>'Kaynak', ''), 'siparis'));
  v_yaz integer := COALESCE(NULLIF(j->>'Yaz', '')::integer, 1);
  r record;
BEGIN
  IF v_belgeid IS NULL OR v_belgeid <= 0 THEN
    RAISE EXCEPTION 'BelgeId zorunlu.' USING ERRCODE = 'P0001';
  END IF;
  IF v_kaynak NOT IN ('siparis', 'belge') THEN
    RAISE EXCEPTION 'Kaynak "siparis" ya da "belge" olmali.' USING ERRCODE = 'P0001';
  END IF;

  SELECT *
    INTO r
  FROM public.fn_api_belge_durum_yaz_ic(v_belgeid, v_kaynak, v_yaz);

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'Kaynak', v_kaynak,
    'Tur', r.tur,
    'Kapsam', CASE WHEN COALESCE(r.neden, '') = '' THEN 'ici' ELSE 'disi' END,
    'Neden', COALESCE(r.neden, ''),
    'Durum', r.durum,
    'OncekiDurum', r.oncekidurum,
    'Yazildi', r.yazildi,
    'Satir', r.satir,
    'Tamamlanan', r.tamamlanan,
    'Kismi', r.kismi,
    'Acik', r.acik
  )::text;
END;
$$;

-- ============================================================
-- KAYNAK BELGE DURUM GUNCELLE/LISTELE
-- MSSQL sp_Prog_Belge_KaynakDurum_Json portu.
--
-- Girdi:
--   {"belgeId":123}
--   {"belgeId":123,"listele":1}
--   {"kaynaklar":[{"kaynak":"siparis","baslikId":11}]}
--
-- Uyumluluk: Kaynaklar alani MSSQL'deki gibi JSON metni olarak doner.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_prog_belge_kaynakdurum_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_belgeid integer := COALESCE(NULLIF(j->>'belgeId', '')::integer, 0);
  v_listele integer := COALESCE(NULLIF(j->>'listele', '')::integer, 0);
  r record;
  k record;
  v_kaynaklar text;
  v_guncellenen integer;
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS pg_temp.tmp_kaynakdurum_k(
    kaynak text NOT NULL,
    baslikid integer NOT NULL,
    PRIMARY KEY (kaynak, baslikid)
  ) ON COMMIT DROP;

  CREATE TEMP TABLE IF NOT EXISTS pg_temp.tmp_kaynakdurum_sonuc(
    kaynak text NOT NULL,
    baslikid integer NOT NULL,
    durum integer,
    oncekidurum integer,
    yazildi integer
  ) ON COMMIT DROP;

  TRUNCATE TABLE pg_temp.tmp_kaynakdurum_k;
  TRUNCATE TABLE pg_temp.tmp_kaynakdurum_sonuc;

  IF v_belgeid > 0 THEN
    INSERT INTO pg_temp.tmp_kaynakdurum_k(kaynak, baslikid)
    SELECT DISTINCT
           CASE WHEN rota.kaynakdetaytablo = 'SIPARISDETAY' THEN 'siparis' ELSE 'belge' END AS kaynak,
           CASE WHEN rota.kaynakdetaytablo = 'SIPARISDETAY' THEN sd.siparisid ELSE fk.fatbasid END AS baslikid
    FROM fatura f
    INNER JOIN public.fn_prog_belgedonusum_rota() rota ON rota.donusumturu = f.yeri
    LEFT JOIN siparisdetay sd ON rota.kaynakdetaytablo = 'SIPARISDETAY' AND sd.id = f.yerid
    LEFT JOIN fatura fk       ON rota.kaynakdetaytablo = 'FATURA'       AND fk.id = f.yerid
    WHERE f.fatbasid = v_belgeid
      AND COALESCE(f.yerid, 0) > 0
      AND COALESCE(CASE WHEN rota.kaynakdetaytablo = 'SIPARISDETAY' THEN sd.siparisid ELSE fk.fatbasid END, 0) > 0
    ON CONFLICT DO NOTHING;
  END IF;

  IF jsonb_typeof(j->'kaynaklar') = 'array' THEN
    INSERT INTO pg_temp.tmp_kaynakdurum_k(kaynak, baslikid)
    SELECT DISTINCT lower(x->>'kaynak'), NULLIF(x->>'baslikId', '')::integer
    FROM jsonb_array_elements(j->'kaynaklar') x
    WHERE COALESCE(NULLIF(x->>'baslikId', '')::integer, 0) > 0
      AND lower(COALESCE(x->>'kaynak', '')) IN ('siparis', 'belge')
    ON CONFLICT DO NOTHING;
  END IF;

  IF v_listele = 1 THEN
    SELECT COALESCE(
             jsonb_agg(jsonb_build_object('kaynak', kaynak, 'baslikId', baslikid) ORDER BY kaynak, baslikid)::text,
             '[]'
           )
      INTO v_kaynaklar
    FROM pg_temp.tmp_kaynakdurum_k;

    RETURN jsonb_build_object('Sonuc', 1, 'Kaynaklar', v_kaynaklar)::text;
  END IF;

  FOR k IN SELECT kaynak, baslikid FROM pg_temp.tmp_kaynakdurum_k ORDER BY kaynak, baslikid LOOP
    SELECT *
      INTO r
    FROM public.fn_api_belge_durum_yaz_ic(k.baslikid, k.kaynak, 1);

    INSERT INTO pg_temp.tmp_kaynakdurum_sonuc(kaynak, baslikid, durum, oncekidurum, yazildi)
    VALUES (k.kaynak, k.baslikid, r.durum, r.oncekidurum, r.yazildi);
  END LOOP;

  SELECT COUNT(*)::integer
    INTO v_guncellenen
  FROM pg_temp.tmp_kaynakdurum_sonuc
  WHERE yazildi = 1;

  SELECT COALESCE(
           jsonb_agg(
             jsonb_build_object(
               'Kaynak', kaynak,
               'BaslikId', baslikid,
               'Durum', durum,
               'OncekiDurum', oncekidurum,
               'Yazildi', yazildi
             )
             ORDER BY kaynak, baslikid
           )::text,
           '[]'
         )
    INTO v_kaynaklar
  FROM pg_temp.tmp_kaynakdurum_sonuc;

  RETURN jsonb_build_object('Sonuc', 1, 'Guncellenen', COALESCE(v_guncellenen, 0), 'Kaynaklar', v_kaynaklar)::text;
END;
$$;

-- ============================================================
-- BELGE TOPLAM HESAPLA
-- Girdi: {"BelgeId":123,"Yaz":1,"Zorla":0}
-- Cikti: MSSQL API ile ayni JSON anahtarlari.
--
-- Not: Gelen e-belge ve uretim fisi varsayilan olarak yazilmaz; hesap sonucu
-- JSON olarak doner. Yazmak icin Zorla=1 gerekir.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_api_belge_toplamhesapla_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_belgeid integer := NULLIF(j->>'BelgeId', '')::integer;
  v_yaz integer := COALESCE(NULLIF(j->>'Yaz', '')::integer, 1);
  v_zorla integer := COALESCE(NULLIF(j->>'Zorla', '')::integer, 0);
  v_tur integer;
  v_tipi integer;
  v_ekvergi numeric := 0;
  v_rapordoviz varchar(10) := 'TL';
  v_faturadovizi varchar(10) := 'TL';
  v_efatdurum integer := 0;
  v_neden text := '';
  v_matrah numeric := 0;
  v_kdv numeric := 0;
  v_toplam numeric := 0;
  v_doviz numeric := 0;
  v_maliyet numeric := 0;
  v_yazildi integer := 0;
BEGIN
  IF v_belgeid IS NULL OR v_belgeid <= 0 THEN
    RAISE EXCEPTION 'BelgeId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  SELECT fb.tur,
         COALESCE(fb.tipi, 0),
         COALESCE(fb.ekvergi, 0),
         COALESCE(fb.rapordoviz, 'TL'),
         COALESCE(fb.faturadovizi, 'TL'),
         COALESCE(fb.efaturadurum, 0)
    INTO v_tur, v_tipi, v_ekvergi, v_rapordoviz, v_faturadovizi, v_efatdurum
  FROM fatbaslik fb
  WHERE fb.id = v_belgeid;

  IF v_tur IS NULL THEN
    RAISE EXCEPTION 'Belge bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  IF v_efatdurum <> 0 THEN
    v_neden := 'gelen e-belge';
  ELSIF v_tur = 6 THEN
    v_neden := 'uretim fisi';
  END IF;

  SELECT MAX(CASE WHEN d.tur = 4 THEN d.deger END)
    INTO v_matrah
  FROM public.fn_prg_faturadiptoplami(v_belgeid) d;

  IF v_matrah IS NULL THEN
    SELECT SUM(d.deger)
      INTO v_matrah
    FROM public.fn_prg_faturadiptoplami(v_belgeid) d
    WHERE d.tur = 1;
  END IF;

  SELECT SUM(d.deger), SUM(d.doviztutari)
    INTO v_toplam, v_doviz
  FROM public.fn_prg_faturadiptoplami(v_belgeid) d
  WHERE d.tur = 20;

  v_matrah := COALESCE(v_matrah, 0);
  v_toplam := COALESCE(v_toplam, 0);

  IF v_tipi IN (4, 7, 8) THEN
    SELECT SUM(d.deger)
      INTO v_kdv
    FROM public.fn_prg_faturadiptoplami(v_belgeid) d
    WHERE d.tur = 15;
    v_kdv := COALESCE(v_kdv, 0);
    v_matrah := v_matrah - ABS(v_ekvergi);
  ELSE
    v_kdv := v_toplam - v_matrah;
  END IF;

  IF v_rapordoviz = 'TL' AND v_faturadovizi = 'TL' THEN
    v_doviz := v_toplam;
  END IF;
  v_doviz := COALESCE(v_doviz, v_toplam);

  SELECT COALESCE(ROUND(SUM(f.miktar * COALESCE(som.birimmaliyet, 0.0))::numeric, 2), 0.0)
    INTO v_maliyet
  FROM fatura f
  LEFT JOIN stok_ort_maliyet som ON som.faturaid = f.id
  WHERE f.fatbasid = v_belgeid;
  v_maliyet := COALESCE(v_maliyet, 0);

  IF v_yaz = 1 AND (v_neden = '' OR v_zorla = 1) THEN
    UPDATE fatbaslik
       SET fatura_matrahi = v_matrah,
           kdv_tutari = v_kdv,
           fatura_tutari = v_toplam,
           doviz_tutari = v_doviz,
           fatura_maliyeti_ort = v_maliyet
     WHERE id = v_belgeid;
    v_yazildi := 1;
  END IF;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'Kapsam', CASE WHEN v_neden = '' THEN 'ici' ELSE 'disi' END,
    'Neden', v_neden,
    'Yazildi', v_yazildi,
    'Matrah', v_matrah,
    'Kdv', v_kdv,
    'Toplam', v_toplam,
    'Doviz', v_doviz,
    'Maliyet', v_maliyet,
    'EkVergi', v_ekvergi
  )::text;
END;
$$;
