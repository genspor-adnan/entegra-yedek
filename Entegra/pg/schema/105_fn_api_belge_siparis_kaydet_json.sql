-- fn_api_belge_siparis_kaydet_json
-- MSSQL: sp_Api_Belge_Siparis_Kaydet_Json
-- PG cekirdek port: SIPARIS + SIPARISDETAY insert/update/delete, toplam yazma, log.
-- Not: Seri/lot izleme detaylari bu fonksiyonda bilerek yazilmaz; izlemli satirlar icin ayri API gerekir.

CREATE OR REPLACE FUNCTION public.fn_api_belge_siparis_kaydet_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  b jsonb := COALESCE(j->'Baslik', '{}'::jsonb);
  v_belgeid integer := NULLIF(b->>'ID', '')::integer;
  v_yeni integer := CASE WHEN COALESCE(NULLIF(b->>'ID', '')::integer, 0) > 0 THEN 0 ELSE 1 END;
  v_satirmodu text := lower(COALESCE(NULLIF(j->>'SatirModu', ''), 'delta'));
  v_tur integer := NULLIF(b->>'Tur', '')::integer;
  v_rehberid integer := NULLIF(b->>'RehberId', '')::integer;
  v_subeid integer := COALESCE(NULLIF(b->>'SubeId', '')::integer, NULLIF(j #>> '{Oturum,SubeId}', '')::integer, 1);
  v_kulid integer := COALESCE(NULLIF(j #>> '{Oturum,KulId}', '')::integer, 0);
  v_belgeno varchar(10) := COALESCE(NULLIF(b->>'SiparisNo', ''), NULLIF(b->>'FaturaNo', ''));
  v_log integer := 0;
  v_silinen integer := 0;
  v_toplam jsonb := '{}'::jsonb;
  v_s jsonb;
  v_satirid integer;
  v_sira integer := 0;
  v_tutar numeric;
  v_doviztutar numeric;
  v_logtab integer;
BEGIN
  IF v_satirmodu NOT IN ('delta', 'tam') THEN
    RAISE EXCEPTION 'SatirModu "delta" ya da "tam" olmali.';
  END IF;

  IF v_yeni = 1 AND (v_tur IS NULL OR COALESCE(v_rehberid, 0) = 0) THEN
    RAISE EXCEPTION 'Yeni siparis icin Baslik.Tur ve Baslik.RehberId zorunlu.';
  END IF;

  IF v_yeni = 0 THEN
    IF NOT EXISTS (SELECT 1 FROM siparis WHERE id = v_belgeid) THEN
      RAISE EXCEPTION 'Siparis bulunamadi.';
    END IF;
    SELECT tur, rehberid, siparisno INTO v_tur, v_rehberid, v_belgeno FROM siparis WHERE id = v_belgeid;
  END IF;

  IF v_belgeno IS NULL THEN
    v_belgeno := 'PGS' || right(to_char(clock_timestamp(), 'YYYYMMDDHH24MISSMS'), 7);
  END IF;

  IF v_yeni = 1 THEN
    INSERT INTO siparis(
      tarih, tur, tipi, rehberid, projeid, aktiviteid, siparistarih, kocanno,
      siparisno, siparisseri, girisdepo, cikisdepo, kdvdurum, kur, rapordoviz,
      doviz_cinsi, dovizkur, subeid, aciklama, rehberiletid, servisid,
      detaybolumu, saticikodu, vade, fiyat_listesi, baslik, adres, ilce, il,
      vd, vno, ozelkod, ozelkod2, durum, ekleyen, eklemetarihi, giriskaynak
    )
    VALUES (
      COALESCE(NULLIF(b->>'Tarih','')::timestamp, now()),
      v_tur,
      COALESCE(NULLIF(b->>'Tipi','')::integer, 1),
      v_rehberid,
      COALESCE(NULLIF(b->>'ProjeId','')::integer, 0),
      COALESCE(NULLIF(b->>'AktiviteId','')::integer, -1),
      COALESCE(NULLIF(b->>'SiparisTarih','')::timestamp, NULLIF(b->>'FaturaTarih','')::timestamp, NULLIF(b->>'Tarih','')::timestamp, now()),
      COALESCE(NULLIF(b->>'KocanNo','')::integer, 0),
      left(v_belgeno, 10),
      left(COALESCE(b->>'SiparisSeri', b->>'FaturaSeri', ''), 5),
      COALESCE(NULLIF(b->>'GirisDepo','')::integer, 0),
      COALESCE(NULLIF(b->>'CikisDepo','')::integer, 0),
      left(COALESCE(NULLIF(b->>'KdvDurum',''), 'Hariç'), 5),
      left(COALESCE(NULLIF(b->>'Kur',''), 'TL'), 5),
      left(COALESCE(NULLIF(b->>'RaporDoviz',''), 'TL'), 5),
      left(COALESCE(NULLIF(b->>'DovizCinsi',''), NULLIF(b->>'FaturaDovizi',''), 'TL'), 6),
      COALESCE(NULLIF(b->>'DovizKur','')::numeric, 1),
      v_subeid,
      COALESCE(b->>'Aciklama', ''),
      NULLIF(b->>'RehberIletId','')::integer,
      COALESCE(NULLIF(b->>'ServisId','')::integer, -1),
      left(COALESCE(b->>'DetayBolumu',''), 20),
      NULLIF(b->>'SaticiKodu','')::integer,
      COALESCE(NULLIF(b->>'Vade','')::integer, 0),
      NULLIF(b->>'FiyatListesi','')::integer,
      left(COALESCE(b->>'Unvan',''), 100),
      b->>'Adres',
      left(COALESCE(b->>'Ilce',''), 50),
      left(COALESCE(b->>'Il',''), 50),
      left(COALESCE(b->>'Vd',''), 50),
      left(COALESCE(b->>'Vno',''), 50),
      left(COALESCE(b->>'OzelKod',''), 20),
      left(COALESCE(b->>'OzelKod2',''), 20),
      COALESCE(NULLIF(b->>'Durum','')::integer, 0),
      v_kulid,
      now(),
      1
    )
    RETURNING id INTO v_belgeid;
  ELSE
    UPDATE siparis
       SET tipi = COALESCE(NULLIF(b->>'Tipi','')::integer, tipi),
           rehberid = COALESCE(NULLIF(b->>'RehberId','')::integer, rehberid),
           tarih = COALESCE(NULLIF(b->>'Tarih','')::timestamp, tarih),
           siparistarih = COALESCE(NULLIF(b->>'SiparisTarih','')::timestamp, NULLIF(b->>'FaturaTarih','')::timestamp, siparistarih),
           siparisno = COALESCE(left(NULLIF(COALESCE(b->>'SiparisNo', b->>'FaturaNo'), ''), 10), siparisno),
           siparisseri = COALESCE(left(NULLIF(COALESCE(b->>'SiparisSeri', b->>'FaturaSeri'), ''), 5), siparisseri),
           kocanno = COALESCE(NULLIF(b->>'KocanNo','')::integer, kocanno),
           girisdepo = COALESCE(NULLIF(b->>'GirisDepo','')::integer, girisdepo),
           cikisdepo = COALESCE(NULLIF(b->>'CikisDepo','')::integer, cikisdepo),
           kdvdurum = COALESCE(left(NULLIF(b->>'KdvDurum',''), 5), kdvdurum),
           kur = COALESCE(left(NULLIF(b->>'Kur',''), 5), kur),
           rapordoviz = COALESCE(left(NULLIF(b->>'RaporDoviz',''), 5), rapordoviz),
           doviz_cinsi = COALESCE(left(NULLIF(COALESCE(b->>'DovizCinsi', b->>'FaturaDovizi'), ''), 6), doviz_cinsi),
           dovizkur = COALESCE(NULLIF(b->>'DovizKur','')::numeric, dovizkur),
           aciklama = COALESCE(b->>'Aciklama', aciklama),
           projeid = COALESCE(NULLIF(b->>'ProjeId','')::integer, projeid),
           vade = COALESCE(NULLIF(b->>'Vade','')::integer, vade),
           durum = COALESCE(NULLIF(b->>'Durum','')::integer, durum),
           degistiren = v_kulid,
           degistirmetarihi = now()
     WHERE id = v_belgeid;
  END IF;

  IF v_satirmodu = 'tam' THEN
    DELETE FROM siparisdetay sd
     WHERE sd.siparisid = v_belgeid
       AND NOT EXISTS (
         SELECT 1
           FROM jsonb_array_elements(COALESCE(j->'Satirlar', '[]'::jsonb)) x
          WHERE COALESCE(NULLIF(x->>'Sil','')::integer, 0) = 0
            AND COALESCE(NULLIF(x->>'SatirId','')::integer, 0) = sd.id
       );
    GET DIAGNOSTICS v_silinen = ROW_COUNT;
  END IF;

  FOR v_s IN SELECT value FROM jsonb_array_elements(COALESCE(j->'Satirlar', '[]'::jsonb))
  LOOP
    v_sira := v_sira + 1;
    v_satirid := NULLIF(v_s->>'SatirId', '')::integer;

    IF COALESCE(NULLIF(v_s->>'Sil','')::integer, 0) = 1 THEN
      IF COALESCE(v_satirid, 0) > 0 THEN
        DELETE FROM siparisdetay WHERE siparisid = v_belgeid AND id = v_satirid;
        v_silinen := v_silinen + 1;
      END IF;
      CONTINUE;
    END IF;

    v_tutar := COALESCE(NULLIF(v_s->>'Tutar','')::numeric,
      round((round((COALESCE(NULLIF(v_s->>'BirimFiyat','')::numeric,0) * COALESCE(NULLIF(v_s->>'Adet','')::numeric,0))::numeric, 2)
        * (100.0 - COALESCE(NULLIF(v_s->>'Iskonto','')::numeric,0))
        * (100.0 - COALESCE(NULLIF(v_s->>'Iskonto2','')::numeric,0)) / 10000.0)::numeric, 2)
    );

    v_doviztutar := COALESCE(NULLIF(v_s->>'DovizTutari','')::numeric,
      round((round((COALESCE(NULLIF(v_s->>'DovizBirimFiyat','')::numeric,0) * COALESCE(NULLIF(v_s->>'Adet','')::numeric,0))::numeric, 2)
        * (100.0 - COALESCE(NULLIF(v_s->>'Iskonto','')::numeric,0))
        * (100.0 - COALESCE(NULLIF(v_s->>'Iskonto2','')::numeric,0)) / 10000.0)::numeric, 2)
    );

    IF COALESCE(v_satirid, 0) > 0 THEN
      UPDATE siparisdetay
         SET urunid = NULLIF(v_s->>'UrunId','')::integer,
             tur = COALESCE(NULLIF(v_s->>'Tur','')::integer, 1),
             adet = COALESCE(NULLIF(v_s->>'Adet','')::numeric, 0),
             miktar = COALESCE(NULLIF(v_s->>'Miktar','')::numeric, NULLIF(v_s->>'Adet','')::numeric, 0),
             birim = COALESCE(NULLIF(v_s->>'Birim','')::integer, 0),
             birimfiyat = COALESCE(NULLIF(v_s->>'BirimFiyat','')::numeric, 0),
             tutar = v_tutar,
             kdv = COALESCE(NULLIF(v_s->>'Kdv','')::integer, 0),
             iskonto = COALESCE(NULLIF(v_s->>'Iskonto','')::double precision, 0),
             iskonto2 = COALESCE(NULLIF(v_s->>'Iskonto2','')::double precision, 0),
             kur = left(COALESCE(NULLIF(v_s->>'Kur',''), 'TL'), 5),
             doviz_kuru = left(COALESCE(NULLIF(v_s->>'DovizKuru',''), NULLIF(b->>'RaporDoviz',''), 'TL'), 5),
             doviz_birimfiyat = COALESCE(NULLIF(v_s->>'DovizBirimFiyat','')::numeric, 0),
             dovizkurdegeri = COALESCE(NULLIF(v_s->>'DovizKurDegeri','')::numeric, 1),
             doviz_tutari = v_doviztutar,
             aciklama = v_s->>'Aciklama',
             projeid = NULLIF(v_s->>'ProjeId','')::integer,
             masrafid = NULLIF(v_s->>'MasrafId','')::integer,
             ozelkod = left(COALESCE(v_s->>'OzelKod',''), 20),
             ozelkod2 = left(COALESCE(v_s->>'OzelKod2',''), 20),
             izleme = COALESCE(NULLIF(v_s->>'Izleme','')::integer, 0),
             yeri = NULLIF(v_s->>'Yeri','')::integer,
             yerid = NULLIF(v_s->>'YerId','')::integer,
             pozno = NULLIF(v_s->>'PozNo','')::integer,
             ekipmanid = NULLIF(v_s->>'EkipmanId','')::integer,
             mf = NULLIF(v_s->>'Mf','')::numeric,
             muhkodu = left(COALESCE(v_s->>'MuhKodu',''), 25),
             kasa = NULLIF(v_s->>'Kasa','')::integer,
             otvyuzde = COALESCE(NULLIF(v_s->>'OtvYuzde','')::integer, 0),
             otvmiktar = COALESCE(NULLIF(v_s->>'OtvMiktar','')::numeric, 0),
             izlemekodu = left(COALESCE(v_s->>'IzlemeKodu',''), 15),
             vade = NULLIF(v_s->>'Vade','')::integer,
             kampanyaid = NULLIF(v_s->>'KampanyaId','')::integer,
             teslimtarihi = NULLIF(v_s->>'TeslimTarihi','')::timestamp,
             degistiren = v_kulid,
             degistirmetarihi = now()
       WHERE siparisid = v_belgeid AND id = v_satirid;
    ELSE
      INSERT INTO siparisdetay(
        siparisid, rehberid, tur, urunid, aciklama, adet, birim, miktar, birimfiyat,
        tutar, iskonto, iskonto2, kdv, masrafid, ozelkod, ozelkod2, muhkodu, kasa,
        kur, izlemekodu, doviz_tutari, doviz_kuru, doviz_birimfiyat, dovizkurdegeri,
        izleme, mf, yeri, yerid, pozno, ekipmanid, otvyuzde, otvmiktar, vade,
        projeid, kampanyaid, teslimtarihi, subeid, ekleyen, eklemetarihi, giriskaynak
      )
      VALUES (
        v_belgeid, v_rehberid, COALESCE(NULLIF(v_s->>'Tur','')::integer, 1),
        NULLIF(v_s->>'UrunId','')::integer, v_s->>'Aciklama',
        COALESCE(NULLIF(v_s->>'Adet','')::numeric, 0),
        COALESCE(NULLIF(v_s->>'Birim','')::integer, 0),
        COALESCE(NULLIF(v_s->>'Miktar','')::numeric, NULLIF(v_s->>'Adet','')::numeric, 0),
        COALESCE(NULLIF(v_s->>'BirimFiyat','')::numeric, 0),
        v_tutar,
        COALESCE(NULLIF(v_s->>'Iskonto','')::double precision, 0),
        COALESCE(NULLIF(v_s->>'Iskonto2','')::double precision, 0),
        COALESCE(NULLIF(v_s->>'Kdv','')::integer, 0),
        NULLIF(v_s->>'MasrafId','')::integer,
        left(COALESCE(v_s->>'OzelKod',''), 20),
        left(COALESCE(v_s->>'OzelKod2',''), 20),
        left(COALESCE(v_s->>'MuhKodu',''), 25),
        NULLIF(v_s->>'Kasa','')::integer,
        left(COALESCE(NULLIF(v_s->>'Kur',''), 'TL'), 5),
        left(COALESCE(v_s->>'IzlemeKodu',''), 15),
        v_doviztutar,
        left(COALESCE(NULLIF(v_s->>'DovizKuru',''), NULLIF(b->>'RaporDoviz',''), 'TL'), 5),
        COALESCE(NULLIF(v_s->>'DovizBirimFiyat','')::numeric, 0),
        COALESCE(NULLIF(v_s->>'DovizKurDegeri','')::numeric, 1),
        COALESCE(NULLIF(v_s->>'Izleme','')::integer, 0),
        NULLIF(v_s->>'Mf','')::numeric,
        NULLIF(v_s->>'Yeri','')::integer,
        NULLIF(v_s->>'YerId','')::integer,
        NULLIF(v_s->>'PozNo','')::integer,
        NULLIF(v_s->>'EkipmanId','')::integer,
        COALESCE(NULLIF(v_s->>'OtvYuzde','')::integer, 0),
        COALESCE(NULLIF(v_s->>'OtvMiktar','')::numeric, 0),
        NULLIF(v_s->>'Vade','')::integer,
        NULLIF(v_s->>'ProjeId','')::integer,
        NULLIF(v_s->>'KampanyaId','')::integer,
        NULLIF(v_s->>'TeslimTarihi','')::timestamp,
        v_subeid, v_kulid, now(), 1
      )
      RETURNING id INTO v_satirid;
    END IF;
  END LOOP;

  WITH t AS (
    SELECT * FROM public.fn_prg_siparis_diptoplami(v_belgeid)
  )
  UPDATE siparis
     SET siparis_matrahi = COALESCE((SELECT deger FROM t WHERE tur = 4 LIMIT 1), 0),
         kdv_tutari = COALESCE((SELECT deger FROM t WHERE tur = 15 LIMIT 1), 0),
         siparis_tutari = COALESCE((SELECT deger FROM t WHERE tur = 20 LIMIT 1), 0),
         doviz_tutari = COALESCE((SELECT doviztutari FROM t WHERE tur = 20 LIMIT 1), 0)
   WHERE id = v_belgeid;

  SELECT jsonb_build_object(
           'Matrah', COALESCE(siparis_matrahi,0),
           'Kdv', COALESCE(kdv_tutari,0),
           'Toplam', COALESCE(siparis_tutari,0),
           'Doviz', COALESCE(doviz_tutari,0)
         )
    INTO v_toplam
    FROM siparis
   WHERE id = v_belgeid;

  v_logtab := public.fn_api_belge_tabno(v_tur, 0);
  v_log := v_log + public.fn_api_log_yaz_ic(p_tablo := 'SIPARIS', p_kayitid := v_belgeid,
            p_tabno := v_logtab, p_usttabno := v_logtab, p_ustid := v_belgeid,
            p_kulid := v_kulid, p_subeid := v_subeid, p_rehberid := v_rehberid,
            p_islemtipi := CASE WHEN v_yeni = 1 THEN 1 ELSE 2 END::smallint);
  v_log := v_log + public.fn_api_log_yaz_ic(p_tablo := 'SIPARISDETAY', p_kosul := 'SIPARISID=@pB',
            p_kosulpar := v_belgeid, p_tabno := public.fn_api_belge_tabno(v_tur, 1),
            p_usttabno := v_logtab, p_ustid := v_belgeid, p_kulid := v_kulid,
            p_subeid := v_subeid, p_rehberid := v_rehberid,
            p_islemtipi := CASE WHEN v_yeni = 1 THEN 1 ELSE 2 END::smallint);

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'BelgeId', v_belgeid,
    'BelgeNo', (SELECT siparisno FROM siparis WHERE id = v_belgeid),
    'Yeni', v_yeni,
    'Satir', (SELECT count(*) FROM siparisdetay WHERE siparisid = v_belgeid),
    'SilinenSatir', v_silinen,
    'Toplam', v_toplam,
    'Loglanan', v_log
  )::text;
END;
$$;
