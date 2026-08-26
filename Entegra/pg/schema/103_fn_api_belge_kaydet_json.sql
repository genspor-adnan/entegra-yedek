-- ============================================================================
-- fn_api_belge_kaydet_json
-- Kaynak: GenUpdate/_Konsolide_66_169/01_Belge_API.sql
--
-- PG belge kaydet cekirdegi:
--   - FATBASLIK ekle/guncelle
--   - FATURA satir ekle/guncelle/sil, SatirModu=tam temizlik
--   - dip toplam yazma
--   - ISLEMLOG kart/satir loglari
--
-- Not: SeriLot JSON bu ilk cekirdekte bilincli olarak yazilmaz; izlem yazma
-- fonksiyonlari ayri portludur ve sonraki adimda baglanacaktir.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_api_belge_kaydet_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  b jsonb := COALESCE(j->'Baslik', '{}'::jsonb);
  v_satirmodu text := lower(COALESCE(NULLIF(j->>'SatirModu', ''), 'delta'));
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, -1);
  v_belgeid integer := NULLIF(b->>'ID', '')::integer;
  v_yeni boolean := COALESCE(v_belgeid, 0) = 0;
  v_tur integer := NULLIF(b->>'Tur', '')::integer;
  v_rehberid integer := NULLIF(b->>'RehberId', '')::integer;
  v_belgeno varchar(50) := NULLIF(b->>'FaturaNo', '');
  v_tabkart integer;
  v_tabdetay integer;
  v_logn integer := 0;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_satir jsonb;
  v_satirid integer;
  v_yenisatirid integer;
  v_sil integer;
  v_tutar numeric;
  v_sonuc_satirlar jsonb := '[]'::jsonb;
  v_toplam jsonb := '{}'::jsonb;
BEGIN
  IF v_satirmodu NOT IN ('delta','tam') THEN
    RAISE EXCEPTION 'SatirModu "delta" ya da "tam" olmali.' USING ERRCODE='P0001';
  END IF;

  IF v_yeni AND (v_tur IS NULL OR v_rehberid IS NULL) THEN
    RAISE EXCEPTION 'Yeni belgede Baslik.Tur ve Baslik.RehberId zorunlu.' USING ERRCODE='P0001';
  END IF;
  IF NOT v_yeni AND NOT EXISTS (SELECT 1 FROM fatbaslik WHERE id = v_belgeid) THEN
    RAISE EXCEPTION 'Belge bulunamadi.' USING ERRCODE='P0001';
  END IF;

  IF v_yeni THEN
    IF v_belgeno IS NULL THEN
      v_belgeno := 'PGB' || right(to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS'), 17);
    END IF;

    INSERT INTO fatbaslik(
      tarih, tur, tipi, rehberid, projeid, faturatarih, faturano, faturaseri,
      girisdepo, cikisdepo, kdvdurum, kur, doviz_cinsi, dovizkur, rapordoviz,
      faturadovizi, baslik, adres, ilce, il, vd, vno, fiyat_listesi,
      ekstredekullan, acik_kapali, masrafid, ekvergi, aciklama, ozelkod,
      ozelkod2, durum, vade, subeid, kocanno, senaryo, efaturadurum,
      efaturasonuc, aktiviteid, rehberiletid, servisid, detaybolumu,
      saticikodu, ekleyen, eklemetarihi, giriskaynak
    )
    VALUES (
      COALESCE(NULLIF(b->>'Tarih','')::timestamp, now()),
      v_tur,
      COALESCE(NULLIF(b->>'Tipi','')::integer, 1),
      v_rehberid,
      COALESCE(NULLIF(b->>'ProjeId','')::integer, 0),
      COALESCE(NULLIF(b->>'FaturaTarih','')::timestamp, NULLIF(b->>'Tarih','')::timestamp, now()),
      v_belgeno,
      b->>'FaturaSeri',
      COALESCE(NULLIF(b->>'GirisDepo','')::integer, 0),
      COALESCE(NULLIF(b->>'CikisDepo','')::integer, 0),
      COALESCE(NULLIF(b->>'KdvDurum',''), 'Hariç'),
      COALESCE(NULLIF(b->>'Kur',''), 'TL'),
      COALESCE(NULLIF(b->>'DovizCinsi',''), 'TL'),
      COALESCE(NULLIF(b->>'DovizKur','')::numeric, 1),
      COALESCE(NULLIF(b->>'RaporDoviz',''), 'TL'),
      COALESCE(NULLIF(b->>'FaturaDovizi',''), 'TL'),
      b->>'Unvan',
      b->>'Adres',
      b->>'Ilce',
      b->>'Il',
      b->>'Vd',
      b->>'Vno',
      NULLIF(b->>'FiyatListesi','')::integer,
      COALESCE(NULLIF(b->>'EkstredeKullan','')::integer, 0),
      COALESCE(NULLIF(b->>'AcikKapali','')::integer, 0),
      NULLIF(b->>'MasrafId','')::integer,
      COALESCE(NULLIF(b->>'EkVergi','')::numeric, 0),
      COALESCE(b->>'Aciklama', ''),
      COALESCE(b->>'OzelKod', ''),
      COALESCE(b->>'OzelKod2', ''),
      COALESCE(NULLIF(b->>'Durum','')::integer, 0),
      COALESCE(NULLIF(b->>'Vade','')::integer, 0),
      v_subeid,
      COALESCE(NULLIF(b->>'KocanNo','')::integer, 0),
      COALESCE(NULLIF(b->>'Senaryo','')::integer, 1),
      COALESCE(NULLIF(b->>'EFaturaDurum','')::integer, 0),
      COALESCE(NULLIF(b->>'EFaturaSonuc','')::integer, 0),
      COALESCE(NULLIF(b->>'AktiviteId','')::integer, -1),
      NULLIF(b->>'RehberIletId','')::integer,
      COALESCE(NULLIF(b->>'ServisId','')::integer, -1),
      b->>'DetayBolumu',
      NULLIF(b->>'SaticiKodu','')::integer,
      v_kulid,
      now(),
      1
    )
    RETURNING id INTO v_belgeid;

    v_tabkart := public.fn_api_belge_tabno(v_tur, 0);
    v_logn := public.fn_api_log_yaz_ic('FATBASLIK','ID=@pB',v_belgeid,NULL,v_tabkart,v_tabkart,v_belgeid,v_kulid,v_subeid,NULL,NULL,v_rehberid,0,1::smallint);
    v_loglanan := v_loglanan + COALESCE(v_logn, 0);
  ELSE
    UPDATE fatbaslik SET
      tarih = COALESCE(NULLIF(b->>'Tarih','')::timestamp, tarih),
      tur = COALESCE(NULLIF(b->>'Tur','')::integer, tur),
      tipi = COALESCE(NULLIF(b->>'Tipi','')::integer, tipi),
      rehberid = COALESCE(NULLIF(b->>'RehberId','')::integer, rehberid),
      projeid = COALESCE(NULLIF(b->>'ProjeId','')::integer, projeid),
      faturatarih = COALESCE(NULLIF(b->>'FaturaTarih','')::timestamp, faturatarih),
      faturano = COALESCE(NULLIF(b->>'FaturaNo',''), faturano),
      faturaseri = COALESCE(NULLIF(b->>'FaturaSeri',''), faturaseri),
      girisdepo = COALESCE(NULLIF(b->>'GirisDepo','')::integer, girisdepo),
      cikisdepo = COALESCE(NULLIF(b->>'CikisDepo','')::integer, cikisdepo),
      kdvdurum = COALESCE(NULLIF(b->>'KdvDurum',''), kdvdurum),
      kur = COALESCE(NULLIF(b->>'Kur',''), kur),
      doviz_cinsi = COALESCE(NULLIF(b->>'DovizCinsi',''), doviz_cinsi),
      dovizkur = COALESCE(NULLIF(b->>'DovizKur','')::numeric, dovizkur),
      rapordoviz = COALESCE(NULLIF(b->>'RaporDoviz',''), rapordoviz),
      faturadovizi = COALESCE(NULLIF(b->>'FaturaDovizi',''), faturadovizi),
      baslik = COALESCE(b->>'Unvan', baslik),
      adres = COALESCE(b->>'Adres', adres),
      ilce = COALESCE(b->>'Ilce', ilce),
      il = COALESCE(b->>'Il', il),
      vd = COALESCE(b->>'Vd', vd),
      vno = COALESCE(b->>'Vno', vno),
      aciklama = COALESCE(b->>'Aciklama', aciklama),
      ozelkod = COALESCE(b->>'OzelKod', ozelkod),
      ozelkod2 = COALESCE(b->>'OzelKod2', ozelkod2),
      durum = COALESCE(NULLIF(b->>'Durum','')::integer, durum),
      vade = COALESCE(NULLIF(b->>'Vade','')::integer, vade),
      degistiren = v_kulid,
      degistirmetarihi = now()
    WHERE id = v_belgeid;

    SELECT tur, rehberid, faturano INTO v_tur, v_rehberid, v_belgeno FROM fatbaslik WHERE id = v_belgeid;
    v_tabkart := public.fn_api_belge_tabno(v_tur, 0);
    v_logn := public.fn_api_log_yaz_ic('FATBASLIK','ID=@pB',v_belgeid,NULL,v_tabkart,v_tabkart,v_belgeid,v_kulid,v_subeid,NULL,NULL,v_rehberid,0,2::smallint);
    v_loglanan := v_loglanan + COALESCE(v_logn, 0);
  END IF;

  SELECT tur, rehberid INTO v_tur, v_rehberid FROM fatbaslik WHERE id = v_belgeid;
  v_tabkart := public.fn_api_belge_tabno(v_tur, 0);
  v_tabdetay := public.fn_api_belge_tabno(v_tur, 1);

  IF v_satirmodu = 'tam' THEN
    DELETE FROM fatura f
     WHERE f.fatbasid = v_belgeid
       AND f.id NOT IN (
         SELECT COALESCE(NULLIF(x.value->>'ID','')::integer, 0)
           FROM jsonb_array_elements(COALESCE(j->'Satirlar','[]'::jsonb)) x
          WHERE COALESCE(NULLIF(x.value->>'ID','')::integer, 0) > 0
       );
    GET DIAGNOSTICS v_silinen = ROW_COUNT;
  END IF;

  FOR v_satir IN SELECT value FROM jsonb_array_elements(COALESCE(j->'Satirlar','[]'::jsonb))
  LOOP
    v_satirid := COALESCE(NULLIF(v_satir->>'ID','')::integer, 0);
    v_sil := COALESCE(NULLIF(v_satir->>'Sil','')::integer, 0);
    v_tutar := COALESCE(NULLIF(v_satir->>'Tutar','')::numeric,
                        ROUND(ROUND(COALESCE(NULLIF(v_satir->>'BirimFiyat','')::numeric, 0) * COALESCE(NULLIF(v_satir->>'Adet','')::numeric, 0), 2)
                              * (100.0 - COALESCE(NULLIF(v_satir->>'Iskonto','')::numeric, 0))
                              * (100.0 - COALESCE(NULLIF(v_satir->>'Iskonto2','')::numeric, 0)) / 10000.0, 2));

    IF v_sil = 1 AND v_satirid > 0 THEN
      v_logn := public.fn_api_log_yaz_ic('FATURA','ID=@pB',v_satirid,NULL,v_tabdetay,v_tabkart,v_belgeid,v_kulid,v_subeid,NULL,NULL,v_rehberid,COALESCE(NULLIF(v_satir->>'UrunId','')::integer,0),0::smallint);
      v_loglanan := v_loglanan + COALESCE(v_logn, 0);
      DELETE FROM stokizleme WHERE baslikid = v_belgeid AND satirid = v_satirid;
      DELETE FROM fatura WHERE id = v_satirid AND fatbasid = v_belgeid;
      GET DIAGNOSTICS v_logn = ROW_COUNT;
      v_silinen := v_silinen + COALESCE(v_logn,0);
      v_sonuc_satirlar := v_sonuc_satirlar || jsonb_build_array(jsonb_build_object('ID', v_satirid, 'Islem', 'sil'));
    ELSIF v_satirid > 0 THEN
      UPDATE fatura SET
        tur = COALESCE(NULLIF(v_satir->>'Tur','')::integer, tur),
        urunid = COALESCE(NULLIF(v_satir->>'UrunId','')::integer, urunid),
        stokid = CASE WHEN COALESCE(NULLIF(v_satir->>'Tur','')::integer, tur) = 0 THEN 0 ELSE COALESCE(NULLIF(v_satir->>'UrunId','')::integer, urunid) END,
        aciklama = COALESCE(v_satir->>'Aciklama', aciklama),
        adet = COALESCE(NULLIF(v_satir->>'Adet','')::numeric, adet),
        miktar = COALESCE(NULLIF(v_satir->>'Miktar','')::numeric, COALESCE(NULLIF(v_satir->>'Adet','')::numeric, miktar)),
        birim = COALESCE(NULLIF(v_satir->>'Birim','')::integer, birim),
        birimfiyat = COALESCE(NULLIF(v_satir->>'BirimFiyat','')::numeric, birimfiyat),
        tutar = v_tutar,
        kur = COALESCE(NULLIF(v_satir->>'Kur',''), kur),
        iskonto = COALESCE(NULLIF(v_satir->>'Iskonto','')::numeric, iskonto),
        iskonto2 = COALESCE(NULLIF(v_satir->>'Iskonto2','')::numeric, iskonto2),
        kdv = COALESCE(NULLIF(v_satir->>'Kdv','')::integer, kdv),
        masrafid = COALESCE(NULLIF(v_satir->>'MasrafId','')::integer, masrafid),
        ozelkod = COALESCE(v_satir->>'OzelKod', ozelkod),
        ozelkod2 = COALESCE(v_satir->>'OzelKod2', ozelkod2),
        doviz_tutari = COALESCE(NULLIF(v_satir->>'DovizTutari','')::numeric, doviz_tutari),
        doviz_kuru = COALESCE(NULLIF(v_satir->>'DovizKuru',''), doviz_kuru),
        doviz_birimfiyat = COALESCE(NULLIF(v_satir->>'DovizBirimFiyat','')::numeric, doviz_birimfiyat),
        dovizkurdegeri = COALESCE(NULLIF(v_satir->>'DovizKurDegeri','')::numeric, dovizkurdegeri),
        projeid = COALESCE(NULLIF(v_satir->>'ProjeId','')::integer, projeid),
        izleme = COALESCE(NULLIF(v_satir->>'Izleme','')::integer, izleme),
        degistiren = v_kulid,
        degistirmetarihi = now()
      WHERE id = v_satirid AND fatbasid = v_belgeid;
      v_logn := public.fn_api_log_yaz_ic('FATURA','ID=@pB',v_satirid,NULL,v_tabdetay,v_tabkart,v_belgeid,v_kulid,v_subeid,NULL,NULL,v_rehberid,COALESCE(NULLIF(v_satir->>'UrunId','')::integer,0),2::smallint);
      v_loglanan := v_loglanan + COALESCE(v_logn, 0);
      v_sonuc_satirlar := v_sonuc_satirlar || jsonb_build_array(jsonb_build_object('ID', v_satirid, 'Islem', 'guncelle'));
    ELSE
      INSERT INTO fatura(
        fatbasid, rehberid, tur, urunid, stokid, aciklama, adet, miktar, birim,
        birimfiyat, tutar, kur, iskonto, iskonto2, kdv, masrafid, ozelkod,
        ozelkod2, doviz_tutari, doviz_kuru, doviz_birimfiyat, dovizkurdegeri,
        projeid, izleme, subeid, ekleyen, eklemetarihi, girdepo, cikdepo,
        stokdurumdegis, giriskaynak, yeri, yerid, pozno, ekipmanid, mf,
        muhkodu, kasa, otvyuzde, otvmiktar, izlemekodu, vade, kampanyaid,
        kdvmuhafiyeti, validfrom, validto
      )
      SELECT
        v_belgeid, v_rehberid,
        COALESCE(NULLIF(v_satir->>'Tur','')::integer, 1),
        COALESCE(NULLIF(v_satir->>'UrunId','')::integer, 0),
        CASE WHEN COALESCE(NULLIF(v_satir->>'Tur','')::integer, 1) = 0 THEN 0 ELSE COALESCE(NULLIF(v_satir->>'UrunId','')::integer, 0) END,
        COALESCE(v_satir->>'Aciklama',''),
        COALESCE(NULLIF(v_satir->>'Adet','')::numeric, 0),
        COALESCE(NULLIF(v_satir->>'Miktar','')::numeric, COALESCE(NULLIF(v_satir->>'Adet','')::numeric, 0)),
        COALESCE(NULLIF(v_satir->>'Birim','')::integer, 0),
        COALESCE(NULLIF(v_satir->>'BirimFiyat','')::numeric, 0),
        v_tutar,
        COALESCE(NULLIF(v_satir->>'Kur',''), 'TL'),
        COALESCE(NULLIF(v_satir->>'Iskonto','')::numeric, 0),
        COALESCE(NULLIF(v_satir->>'Iskonto2','')::numeric, 0),
        COALESCE(NULLIF(v_satir->>'Kdv','')::integer, 0),
        COALESCE(NULLIF(v_satir->>'MasrafId','')::integer, 0),
        COALESCE(v_satir->>'OzelKod',''),
        COALESCE(v_satir->>'OzelKod2',''),
        COALESCE(NULLIF(v_satir->>'DovizTutari','')::numeric, 0),
        COALESCE(NULLIF(v_satir->>'DovizKuru',''), 'TL'),
        COALESCE(NULLIF(v_satir->>'DovizBirimFiyat','')::numeric, 0),
        COALESCE(NULLIF(v_satir->>'DovizKurDegeri','')::numeric, 1),
        COALESCE(NULLIF(v_satir->>'ProjeId','')::integer, 0),
        COALESCE(NULLIF(v_satir->>'Izleme','')::integer, 0),
        v_subeid, v_kulid, now(),
        COALESCE((SELECT girisdepo FROM fatbaslik WHERE id = v_belgeid), 0),
        COALESCE((SELECT cikisdepo FROM fatbaslik WHERE id = v_belgeid), 0),
        COALESCE(NULLIF(v_satir->>'StokDurumDegis','')::integer, 1),
        1,
        NULLIF(v_satir->>'Yeri','')::integer,
        NULLIF(v_satir->>'YerId','')::integer,
        NULLIF(v_satir->>'PozNo','')::integer,
        NULLIF(v_satir->>'EkipmanId','')::integer,
        NULLIF(v_satir->>'Mf','')::numeric,
        v_satir->>'MuhKodu',
        NULLIF(v_satir->>'Kasa','')::integer,
        NULLIF(v_satir->>'OtvYuzde','')::numeric,
        NULLIF(v_satir->>'OtvMiktar','')::numeric,
        v_satir->>'IzlemeKodu',
        NULLIF(v_satir->>'Vade','')::integer,
        NULLIF(v_satir->>'KampanyaId','')::integer,
        NULLIF(v_satir->>'KdvMuafiyeti','')::integer,
        now(),
        '9999-12-31'::timestamp
      RETURNING id INTO v_yenisatirid;

      v_logn := public.fn_api_log_yaz_ic('FATURA','ID=@pB',v_yenisatirid,NULL,v_tabdetay,v_tabkart,v_belgeid,v_kulid,v_subeid,NULL,NULL,v_rehberid,COALESCE(NULLIF(v_satir->>'UrunId','')::integer,0),1::smallint);
      v_loglanan := v_loglanan + COALESCE(v_logn, 0);
      v_sonuc_satirlar := v_sonuc_satirlar || jsonb_build_array(jsonb_build_object('ID', v_yenisatirid, 'Islem', 'ekle'));
    END IF;
  END LOOP;

  v_toplam := public.fn_api_belge_toplamhesapla_json(jsonb_build_object('BelgeId', v_belgeid, 'Yaz', 1)::text)::jsonb;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'BelgeNo', (SELECT faturano FROM fatbaslik WHERE id = v_belgeid),
    'Yeni', CASE WHEN v_yeni THEN 1 ELSE 0 END,
    'SilinenSatir', v_silinen,
    'Loglanan', v_loglanan,
    'Satirlar', v_sonuc_satirlar,
    'Toplam', v_toplam
  )::text;
END;
$$;
