-- API uyumluluk wrapper'lari
-- Konsolide MSSQL'de bulunan ama PG portunda yeni cekirdek adlara tasinan
-- prosedur adlari icin ince sarmalayicilar.

CREATE OR REPLACE FUNCTION public.fn_api_belge_toplam_yaz_ic(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql
AS $$
  SELECT public.fn_api_belge_toplamhesapla_json($1);
$$;

CREATE OR REPLACE FUNCTION public.fn_api_donusum_siparistenbelge_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_siparisid integer := NULLIF(j->>'SiparisId', '')::integer;
  v_hedeftur integer := NULLIF(j->>'HedefTur', '')::integer;
  v_kaynaktur integer;
  v_donusumturu integer;
BEGIN
  IF COALESCE(v_siparisid, 0) <= 0 OR v_hedeftur IS NULL THEN
    RAISE EXCEPTION 'SiparisId ve HedefTur zorunlu.' USING ERRCODE='P0001';
  END IF;

  SELECT tur INTO v_kaynaktur FROM siparis WHERE id = v_siparisid;
  IF v_kaynaktur IS NULL THEN
    RAISE EXCEPTION 'Siparis bulunamadi.' USING ERRCODE='P0001';
  END IF;

  SELECT donusumturu
    INTO v_donusumturu
  FROM public.fn_prog_belgedonusum_rota()
  WHERE kaynakbasliktablo = 'SIPARIS'
    AND kaynaktur = v_kaynaktur
    AND hedeftur = v_hedeftur
  LIMIT 1;

  IF v_donusumturu IS NULL THEN
    RAISE EXCEPTION 'Bu siparis turu (%) hedef belge turune (%) donusturulemez.', v_kaynaktur, v_hedeftur USING ERRCODE='P0001';
  END IF;

  RETURN public.fn_api_belge_donusum_json(
    (j || jsonb_build_object('DonusumTuru', v_donusumturu, 'KaynakBelgeId', v_siparisid))::text
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_donusum_uygula_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
BEGIN
  -- Yeni PG cekirdegi kaynak belgeyi kendisi okuyup hedefe yazar.
  -- Eski Uygula API'sinden gelen modernlestirilmis cagri KaynakBelgeId tasiyorsa
  -- dogrudan ayni cekirdege aktarilir.
  IF COALESCE(NULLIF(j->>'KaynakBelgeId', '')::integer, 0) > 0 THEN
    RETURN public.fn_api_belge_donusum_json(kosullar);
  END IF;

  RAISE EXCEPTION 'PG icin Donusum_Uygula_Json yerine KaynakBelgeId iceren Belge_Donusum_Json kullanilmali.' USING ERRCODE='P0001';
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_donusum_kaynakiptalkontrol_ic(p_kaynak integer, p_satirids text DEFAULT '')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_iptal text;
BEGIN
  IF p_kaynak NOT IN (2, 3) THEN
    RETURN jsonb_build_object('Sonuc', 1)::text;
  END IF;

  IF p_kaynak = 2 THEN
    SELECT s.siparisno
      INTO v_iptal
    FROM siparisdetay sd
    JOIN siparis s ON s.id = sd.siparisid
    WHERE sd.id = ANY(string_to_array(COALESCE(p_satirids,''), ',')::integer[])
      AND COALESCE(s.durum, 0) = 6
    LIMIT 1;
  ELSE
    SELECT fb.faturano
      INTO v_iptal
    FROM fatura f
    JOIN fatbaslik fb ON fb.id = f.fatbasid
    WHERE f.id = ANY(string_to_array(COALESCE(p_satirids,''), ',')::integer[])
      AND COALESCE(fb.durum, 0) = 6
    LIMIT 1;
  END IF;

  IF v_iptal IS NOT NULL THEN
    RAISE EXCEPTION 'Kaynak belge iptal edilmis (%), donusturulemez.', v_iptal USING ERRCODE='P0001';
  END IF;

  RETURN jsonb_build_object('Sonuc', 1)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_donusum_kontrol_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kaynak integer := NULLIF(j->>'Kaynak', '')::integer;
  v_donusumturu integer := NULLIF(j->>'DonusumTuru', '')::integer;
  v_uygun integer := 1;
  v_rows jsonb := '[]'::jsonb;
BEGIN
  IF v_kaynak NOT IN (1,2,3) THEN
    RAISE EXCEPTION 'Kaynak 1 (teklif), 2 (siparis) ya da 3 (belge) olmali.' USING ERRCODE='P0001';
  END IF;
  IF v_donusumturu IS NULL THEN
    RAISE EXCEPTION 'DonusumTuru zorunlu.' USING ERRCODE='P0001';
  END IF;

  WITH s AS (
    SELECT NULLIF(x->>'SatirId','')::integer AS satirid,
           COALESCE(NULLIF(x->>'Adet','')::numeric, 0) AS adet
    FROM jsonb_array_elements(COALESCE(j->'Satirlar', '[]'::jsonb)) x
  ),
  k AS (
    SELECT s.satirid,
           s.adet,
           CASE
             WHEN v_kaynak = 2 THEN (
               SELECT COALESCE(sd.adet,0) - COALESCE((SELECT sum(abs(f.adet)) FROM fatura f WHERE f.yeri=v_donusumturu AND f.yerid=sd.id),0)
               FROM siparisdetay sd WHERE sd.id=s.satirid
             )
             WHEN v_kaynak = 3 THEN (
               SELECT COALESCE(f0.adet,0) - COALESCE((SELECT sum(abs(f1.adet)) FROM fatura f1 WHERE f1.yeri=v_donusumturu AND f1.yerid=f0.id),0)
               FROM fatura f0 WHERE f0.id=s.satirid
             )
             ELSE NULL
           END AS kalan
    FROM s
  )
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
           'SatirId', satirid,
           'Adet', adet,
           'Kalan', COALESCE(kalan,0),
           'Uygun', CASE WHEN kalan IS NOT NULL AND adet > 0 AND adet <= kalan + 0.0001 THEN 1 ELSE 0 END,
           'Neden', CASE
                      WHEN kalan IS NULL THEN 'kaynak satir bulunamadi'
                      WHEN adet <= 0 THEN 'adet sifir/negatif'
                      WHEN adet > kalan + 0.0001 THEN 'kalan yetersiz'
                      ELSE ''
                    END
         ) ORDER BY satirid), '[]'::jsonb),
         CASE WHEN bool_or(NOT (kalan IS NOT NULL AND adet > 0 AND adet <= kalan + 0.0001)) THEN 0 ELSE 1 END
    INTO v_rows, v_uygun
  FROM k;

  IF jsonb_array_length(v_rows) = 0 THEN
    RAISE EXCEPTION 'Satirlar bos olamaz.' USING ERRCODE='P0001';
  END IF;

  RETURN jsonb_build_object('Sonuc', 1, 'Uygun', COALESCE(v_uygun,1), 'Satirlar', v_rows)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_donusum_rapor_json(kosullar text DEFAULT '{}', baslik text DEFAULT '')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_data jsonb;
BEGIN
  SELECT COALESCE(jsonb_agg(to_jsonb(x)), '[]'::jsonb)
    INTO v_data
  FROM public.fn_prog_belgedonusum_kaynak_json2(baslik, kosullar) x;

  RETURN jsonb_build_object('Sonuc', 1, 'Data', v_data)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_kayit_sil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_modul integer := NULLIF(j->>'Modul', '')::integer;
BEGIN
  CASE v_modul
    WHEN 18  THEN RETURN public.fn_api_demirbas_sil_json(kosullar);
    WHEN 33  THEN RETURN public.fn_api_gorev_sil_json(kosullar);
    WHEN 46  THEN RETURN public.fn_api_kredikarti_sil_json(kosullar);
    WHEN 58  THEN RETURN public.fn_api_masrafgelir_sil_json(kosullar);
    WHEN 69  THEN RETURN public.fn_api_pos_sil_json(kosullar);
    WHEN 70  THEN RETURN public.fn_api_proje_sil_json(kosullar);
    WHEN 71  THEN RETURN public.fn_api_cari_sil_json(kosullar);
    WHEN 73  THEN RETURN public.fn_api_ik_sil_json(kosullar);
    WHEN 83  THEN RETURN public.fn_api_servis_sil_json(kosullar);
    WHEN 88  THEN RETURN public.fn_api_stok_sil_json(kosullar);
    WHEN 91  THEN RETURN public.fn_api_belge_siparis_sil_json(kosullar);
    WHEN 97  THEN RETURN public.fn_api_teklif_sil_json(kosullar);
    WHEN 138 THEN RETURN public.fn_api_uretimrecete_sil_json(kosullar);
    WHEN 140 THEN RETURN public.fn_api_uretimemri_sil_json(kosullar);
    WHEN 170 THEN RETURN public.fn_api_firsat_sil_json(kosullar);
    WHEN 315 THEN RETURN public.fn_api_ceksenet_sil_json(kosullar);
    WHEN 316 THEN RETURN public.fn_api_ceksenet_sil_json(kosullar);
    WHEN 318 THEN RETURN public.fn_api_ceksenet_sil_json(kosullar);
    WHEN 319 THEN RETURN public.fn_api_ceksenet_sil_json(kosullar);
    WHEN 321 THEN RETURN public.fn_api_dokuman_sil_json(kosullar);
    WHEN 480 THEN RETURN public.fn_api_kasa_sil_json(kosullar);
    WHEN 520 THEN RETURN public.fn_api_stoksayim_sil_json(kosullar);
    ELSE
      RAISE EXCEPTION 'Bu modul icin PG silme wrapper tanimli degil: %', v_modul USING ERRCODE='P0001';
  END CASE;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_modul_sil_ic(p_modul integer, kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql
AS $$
  SELECT public.fn_api_kayit_sil_json(
    (COALESCE(NULLIF($2,''), '{}')::jsonb || jsonb_build_object('Modul', $1))::text
  );
$$;

CREATE OR REPLACE FUNCTION public.fn_api_log_yiltablosu(p_yil integer DEFAULT NULL)
RETURNS text
LANGUAGE sql
AS $$
  SELECT jsonb_build_object(
    'Sonuc', 1,
    'Yil', COALESCE($1, EXTRACT(YEAR FROM now())::integer),
    'Tablo', 'depo.islemlog'
  )::text;
$$;

