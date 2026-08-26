-- Gentegre PG migration
-- MSSQL sp_Prog_UretimFisi_Olustur_Json portu.
-- KANONIK belge kaydet API'sini kullanir, ardindan uretim fisine ozgu FATBASLIK alanlarini yazar.

CREATE OR REPLACE FUNCTION public.fn_prog_uretimfisi_olustur_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_tarih timestamp := COALESCE(NULLIF(j->>'tarih','')::timestamp, now());
  v_yeri integer := NULLIF(j->>'yeri','')::integer;
  v_yerid integer := NULLIF(j->>'yerId','')::integer;
  v_receteid integer := NULLIF(j->>'receteId','')::integer;
  v_girisdepo integer := COALESCE(NULLIF(j->>'girisDepo','')::integer, 0);
  v_cikisdepo integer := COALESCE(NULLIF(j->>'cikisDepo','')::integer, 0);
  v_miktar numeric := COALESCE(NULLIF(j->>'miktar','')::numeric, 1);
  v_subeid integer := COALESCE(NULLIF(j->>'subeId','')::integer, 0);
  v_kulid integer := COALESCE(NULLIF(j->>'kullaniciId','')::integer, 0);
  v_kur text := COALESCE(NULLIF(j->>'kur',''), 'TL');
  v_kod text;
  v_ad text;
  v_stokid integer;
  v_birim integer;
  v_baslik jsonb;
  v_satirlar jsonb;
  v_payload jsonb;
  v_sonuc jsonb;
  v_belgeid integer;
BEGIN
  IF COALESCE(v_receteid, 0) <= 0 THEN
    RETURN jsonb_build_object('Sonuc', 0, 'BelgeId', 0, 'Mesaj', 'Recete belirtilmedi.')::text;
  END IF;

  SELECT ur.kod, ur.ad, ur.stokid,
         COALESCE((SELECT s.anabirim FROM public.stoklar s WHERE s.id = ur.stokid), 0)
    INTO v_kod, v_ad, v_stokid, v_birim
  FROM public.uretimrecete ur
  WHERE ur.id = v_receteid;

  IF v_stokid IS NULL THEN
    RETURN jsonb_build_object('Sonuc', 0, 'BelgeId', 0, 'Mesaj', 'Recete bulunamadi.')::text;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.uretimrecetedetay WHERE uretimreceteid = v_receteid) THEN
    RETURN jsonb_build_object('Sonuc', 0, 'BelgeId', 0, 'Mesaj', 'Recetenin detay satirlari yok.')::text;
  END IF;

  v_baslik := jsonb_build_object(
    'Tur', 6,
    'Tipi', 1,
    'RehberId', 0,
    'Tarih', v_tarih,
    'FaturaTarih', v_tarih,
    'GirisDepo', v_girisdepo,
    'CikisDepo', v_cikisdepo,
    'KdvDurum', 'Muaf',
    'Kur', v_kur,
    'RaporDoviz', v_kur,
    'FaturaDovizi', v_kur,
    'SubeId', v_subeid,
    'Aciklama', left(COALESCE(v_kod, '') || ' - ' || COALESCE(v_ad, ''), 200)
  );

  SELECT COALESCE(jsonb_agg(
           jsonb_build_object(
             'Sira', x.sira,
             'UrunId', x.urunid,
             'Tur', COALESCE(x.tur, 1),
             'Adet', COALESCE(x.adet, 0) * v_miktar,
             'Miktar', COALESCE(x.miktar, 0) * v_miktar,
             'Birim', COALESCE(x.birim, 0),
             'BirimFiyat', 0,
             'Tutar', 0,
             'DovizBirimFiyat', 0,
             'DovizTutari', 0,
             'Kdv', COALESCE(s.kdv, 0),
             'Aciklama', x.aciklama,
             'MasrafId', x.masrafid,
             'Izleme', COALESCE(s.izleme, 0),
             'StokDurumDegis', 1,
             'Yeri', 139,
             'YerId', x.id
           )
           ORDER BY x.id
         ), '[]'::jsonb)
    INTO v_satirlar
  FROM public.uretimrecetedetay x
  LEFT JOIN public.stoklar s ON s.id = x.urunid
  WHERE x.uretimreceteid = v_receteid;

  v_payload := jsonb_build_object(
    'Baslik', v_baslik,
    'Satirlar', v_satirlar,
    'SatirModu', 'delta',
    'Oturum', jsonb_build_object('KulId', v_kulid, 'SubeId', v_subeid)
  );

  v_sonuc := public.fn_api_belge_kaydet_json(v_payload::text)::jsonb;
  v_belgeid := NULLIF(v_sonuc->>'BelgeId','')::integer;

  IF COALESCE(v_belgeid, 0) = 0 THEN
    RETURN jsonb_build_object('Sonuc', 0, 'BelgeId', 0, 'Mesaj', 'Uretim fisi olusturulamadi.')::text;
  END IF;

  UPDATE public.fatbaslik
     SET yeri = COALESCE(v_yeri, yeri)::smallint,
         yerid = COALESCE(v_yerid, yerid),
         anakayitid = v_receteid,
         aktiviteid = v_stokid,
         stokisk = v_miktar,
         sayfa = COALESCE(v_birim, 0)::smallint,
         lokasyon = 0,
         isyeri = 0
   WHERE id = v_belgeid;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'BelgeNo', v_sonuc->>'BelgeNo',
    'SatirSayisi', (SELECT COUNT(*) FROM public.fatura WHERE fatbasid = v_belgeid)
  )::text;
END;
$$;
