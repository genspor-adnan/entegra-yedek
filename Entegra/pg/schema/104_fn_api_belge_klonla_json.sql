-- ============================================================================
-- fn_api_belge_klonla_json
-- Kaynak: GenUpdate/_Konsolide_66_169/01_Belge_API.sql
--
-- Belge klonlama PG portu. Izlemli satırlar klonlanmaz.
-- Yeni belge fn_api_belge_kaydet_json çekirdeği üzerinden oluşturulur.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_belge_klonla_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kaynakid integer := NULLIF(j->>'KaynakId', '')::integer;
  v_tarih timestamp := COALESCE(NULLIF(j->>'Tarih','')::timestamp, now());
  v_rehberid integer := NULLIF(j->>'RehberId','')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, -1);
  v_payload jsonb;
  v_sonuc jsonb;
  v_yeniid integer;
  v_tur integer;
  v_logtabno integer;
BEGIN
  IF v_kaynakid IS NULL OR v_kaynakid <= 0 THEN
    RAISE EXCEPTION 'KaynakId zorunlu.' USING ERRCODE='P0001';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM fatbaslik WHERE id = v_kaynakid) THEN
    RAISE EXCEPTION 'Kaynak belge bulunamadi.' USING ERRCODE='P0001';
  END IF;
  IF EXISTS (SELECT 1 FROM fatura WHERE fatbasid = v_kaynakid AND COALESCE(izleme,0) <> 0) THEN
    RAISE EXCEPTION 'Belge iceriginde izlem bilgisi aktif urunler var, bu islem gerceklestirilemez.' USING ERRCODE='P0001';
  END IF;

  SELECT fb.tur INTO v_tur FROM fatbaslik fb WHERE fb.id = v_kaynakid;

  SELECT jsonb_build_object(
    'SatirModu', 'tam',
    'Baslik', jsonb_build_object(
      'Tur', fb.tur,
      'Tipi', fb.tipi,
      'Tarih', to_char(v_tarih, 'YYYY-MM-DD"T"HH24:MI:SS'),
      'FaturaTarih', to_char(v_tarih, 'YYYY-MM-DD"T"HH24:MI:SS'),
      'RehberId', COALESCE(v_rehberid, fb.rehberid),
      'GirisDepo', fb.girisdepo,
      'CikisDepo', fb.cikisdepo,
      'KdvDurum', fb.kdvdurum,
      'Kur', fb.kur,
      'DovizCinsi', fb.doviz_cinsi,
      'DovizKur', fb.dovizkur,
      'RaporDoviz', fb.rapordoviz,
      'FaturaDovizi', fb.faturadovizi,
      'Aciklama', fb.aciklama,
      'OzelKod', fb.ozelkod,
      'OzelKod2', fb.ozelkod2,
      'ProjeId', fb.projeid,
      'Vade', fb.vade,
      'Durum', 0,
      'Unvan', fb.baslik,
      'Adres', fb.adres,
      'Ilce', fb.ilce,
      'Il', fb.il,
      'Vd', fb.vd,
      'Vno', fb.vno,
      'FiyatListesi', fb.fiyat_listesi,
      'EkstredeKullan', fb.ekstredekullan,
      'AcikKapali', fb.acik_kapali,
      'MasrafId', fb.masrafid,
      'EkVergi', fb.ekvergi,
      'Senaryo', fb.senaryo,
      'EFaturaDurum', 0,
      'EFaturaSonuc', 0,
      'RehberIletId', fb.rehberiletid,
      'SaticiKodu', fb.saticikodu,
      'DetayBolumu', fb.detaybolumu
    ),
    'Satirlar', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
        'Sira', q.klon_sira,
        'UrunId', q.urunid,
        'Tur', q.tur,
        'Adet', q.adet,
        'Miktar', q.miktar,
        'Birim', q.birim,
        'BirimFiyat', q.birimfiyat,
        'Tutar', q.tutar,
        'Kdv', q.kdv,
        'Iskonto', q.iskonto,
        'Iskonto2', q.iskonto2,
        'Kur', q.kur,
        'DovizKuru', q.doviz_kuru,
        'DovizBirimFiyat', q.doviz_birimfiyat,
        'DovizKurDegeri', q.dovizkurdegeri,
        'DovizTutari', q.doviz_tutari,
        'Aciklama', q.aciklama,
        'ProjeId', q.projeid,
        'MasrafId', q.masrafid,
        'OzelKod', q.ozelkod,
        'OzelKod2', q.ozelkod2,
        'Izleme', 0,
        'PozNo', q.pozno,
        'EkipmanId', q.ekipmanid,
        'Mf', q.mf,
        'MuhKodu', q.muhkodu,
        'Kasa', q.kasa,
        'OtvYuzde', q.otvyuzde,
        'OtvMiktar', q.otvmiktar,
        'Vade', q.vade,
        'KampanyaId', q.kampanyaid,
        'KdvMuafiyeti', q.kdvmuhafiyeti
      ) ORDER BY q.klon_sira)
      FROM (
        SELECT f.*, row_number() OVER (ORDER BY COALESCE(f.sira, f.id), f.id) AS klon_sira
        FROM fatura f
        WHERE f.fatbasid = v_kaynakid
      ) q
    ), '[]'::jsonb),
    'Oturum', jsonb_build_object('KulId', v_kulid, 'SubeId', v_subeid)
  )
  INTO v_payload
  FROM fatbaslik fb
  WHERE fb.id = v_kaynakid;

  IF jsonb_array_length(v_payload->'Satirlar') = 0 THEN
    RAISE EXCEPTION 'Kaynak belgede satir yok, kopyalanacak icerik bulunamadi.' USING ERRCODE='P0001';
  END IF;

  v_sonuc := public.fn_api_belge_kaydet_json(v_payload::text)::jsonb;
  v_yeniid := NULLIF(v_sonuc->>'BelgeId','')::integer;
  IF COALESCE(v_yeniid,0) = 0 THEN
    RAISE EXCEPTION 'Klon belge olusturulamadi.' USING ERRCODE='P0001';
  END IF;

  SELECT tabloid INTO v_logtabno
    FROM depo.islemlog
   WHERE kayitid = v_yeniid AND islemtipi = 1
   ORDER BY id DESC
   LIMIT 1;

  IF v_logtabno IS NOT NULL THEN
    PERFORM public.fn_api_log_kaynak_isaretle(v_logtabno, v_yeniid, 3::smallint, v_kaynakid, v_logtabno);
  END IF;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'KaynakId', v_kaynakid,
    'BelgeId', v_yeniid,
    'BelgeNo', (SELECT faturano FROM fatbaslik WHERE id = v_yeniid),
    'Tur', v_tur,
    'Satir', (SELECT count(*) FROM fatura WHERE fatbasid = v_yeniid)
  )::text;
END;
$$;
