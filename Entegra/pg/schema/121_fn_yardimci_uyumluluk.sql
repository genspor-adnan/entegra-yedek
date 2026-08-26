-- Gentegre PG migration
-- Konsolide SQL'de FUNCTION olarak tanimli kalan yardimci nesneler icin PG uyumluluk katmani.
-- Bu dosyadaki fonksiyonlar okuma/hesaplama/plan dondurur; kendileri delete/update yapmaz.

CREATE OR REPLACE FUNCTION public.fn_api_belge_diptoplam(p_fatbasid integer)
RETURNS TABLE(
  tur double precision,
  aciklama varchar,
  deger double precision,
  doviztutari double precision,
  kur varchar,
  doviz_kuru varchar,
  dovizkur double precision,
  kdvmuhafiyeti smallint,
  faturadovizi varchar
)
LANGUAGE sql STABLE AS $$
  SELECT * FROM public.fn_prg_faturadiptoplami(p_fatbasid);
$$;

CREATE OR REPLACE FUNCTION public.fn_api_depodbadi()
RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'depo')
              THEN 'depo' ELSE 'public' END::text;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_gecicitablogecerli(p_ad text)
RETURNS smallint
LANGUAGE plpgsql STABLE AS $$
BEGIN
  IF p_ad IS NULL OR length(p_ad) < 3 THEN RETURN 0; END IF;
  IF left(p_ad, 2) <> '##' THEN RETURN 0; END IF;
  IF p_ad ~ '[^0-9A-Za-z_#]' THEN RETURN 0; END IF;
  -- MSSQL global temp tablo kontrolu. PG pilotta global temp yok; local temp adi verilirse
  -- sadece guvenli ad bilgisini 1 saymak yerine gercek varlik da aranir.
  IF to_regclass('pg_temp.' || quote_ident(p_ad)) IS NULL THEN RETURN 0; END IF;
  RETURN 1;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_donusum_esleme()
RETURNS TABLE(
  donusumturu integer,
  kaynaktablo text,
  kaynakdetay text,
  kaynakbaglanti text,
  kaynaktur integer,
  kaynaktip integer,
  hedeftur integer,
  hedeftablo text,
  destek integer
)
LANGUAGE sql STABLE AS $$
  SELECT r.donusumturu,
         r.kaynakbasliktablo,
         r.kaynakdetaytablo,
         r.kaynakbaglanti,
         r.kaynaktur,
         CASE r.kaynakbasliktablo WHEN 'TEKLIF' THEN 1 WHEN 'SIPARIS' THEN 2 ELSE 3 END,
         r.hedeftur,
         r.hedefbasliktablo,
         r.destek
  FROM public.fn_prog_belgedonusum_rota() r;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_kalankod()
RETURNS TABLE(grup text, kod integer)
LANGUAGE sql STABLE AS $$
  SELECT *
  FROM (VALUES
    ('ALIS_SIP',406),('ALIS_SIP',407),('ALIS_SIP',478),
    ('ALIS_IRS',408),('ALIS_IRS',427),
    ('SATIS_SIP',409),('SATIS_SIP',410),('SATIS_SIP',473),('SATIS_SIP',429),
    ('SATIS_IRS',411),('SATIS_IRS',424),
    ('TRANSFER',414),('TRANSFER',435),
    ('GELEN_KON',461),
    ('GIDEN_KON',468),('GIDEN_KON',462),('GIDEN_KON',472),
    ('URETIM_HED',415),('URETIM_HED',420),
    ('URETIM_KAY',425),('URETIM_KAY',426),
    ('TALEP_SIP',428),
    ('TEKLIF_SIP',412),('TEKLIF_SIP',413)
  ) AS k(grup,kod);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_donusum_donusenadet(
  p_kaynakdetaytablo text,
  p_satirid integer
)
RETURNS numeric
LANGUAGE sql STABLE AS $$
  SELECT (
    COALESCE((
      SELECT SUM(abs(COALESCE(f.adet, 0)))::numeric
      FROM public.fatura f
      INNER JOIN public.fn_prog_belgedonusum_rota() r
        ON r.donusumturu = f.yeri
       AND r.kaynakdetaytablo = p_kaynakdetaytablo
       AND r.kalanhedeftablo = 'FATURA'
      WHERE f.yerid = p_satirid
    ), 0)
    +
    COALESCE((
      SELECT SUM(abs(COALESCE(sd.adet, 0)))::numeric
      FROM public.siparisdetay sd
      INNER JOIN public.fn_prog_belgedonusum_rota() r
        ON r.donusumturu = sd.yeri
       AND r.kaynakdetaytablo = p_kaynakdetaytablo
       AND r.kalanhedeftablo = 'SIPARISDETAY'
      WHERE sd.yerid = p_satirid
    ), 0)
  )::numeric(18,6);
$$;

CREATE OR REPLACE FUNCTION public.fn_api_donusum_kalan(
  p_kaynak integer,
  p_donusumturu integer,
  p_satirid integer,
  p_hedefuretim boolean DEFAULT false
)
RETURNS TABLE(adet numeric, donusen numeric, kalan numeric)
LANGUAGE sql STABLE AS $$
  SELECT td.adet::numeric(18,6),
         (COALESCE((SELECT SUM(f1.adet) FROM public.siparisdetay f1 WHERE f1.yeri = p_donusumturu AND f1.yerid = td.id), 0)
        + COALESCE((SELECT SUM(f1.adet) FROM public.siparisdetay f1 WHERE f1.yeri = 416 AND f1.yerid = td.id), 0))::numeric(18,6),
         (td.adet
        - COALESCE((SELECT SUM(f1.adet) FROM public.siparisdetay f1 WHERE f1.yeri = p_donusumturu AND f1.yerid = td.id), 0)
        - COALESCE((SELECT SUM(f1.adet) FROM public.siparisdetay f1 WHERE f1.yeri = 416 AND f1.yerid = td.id), 0))::numeric(18,6)
  FROM public.teklifdetay td
  WHERE p_kaynak = 1 AND td.id = p_satirid

  UNION ALL
  SELECT sd.adet::numeric(18,6),
         (abs(COALESCE((SELECT SUM(f1.adet) FROM public.siparisdetay f1 WHERE f1.yeri = p_donusumturu AND f1.yerid = sd.id), 0))
        + abs(CASE WHEN p_hedefuretim
              THEN COALESCE((SELECT SUM(u1.adet) FROM public.uretimemridetay u1 WHERE u1.urunid = sd.urunid AND u1.yeri = p_donusumturu AND u1.yerid = sd.id), 0)
              ELSE COALESCE((SELECT SUM(f1.adet) FROM public.fatura f1 WHERE f1.urunid = sd.urunid AND f1.yeri = p_donusumturu AND f1.yerid = sd.id), 0)
            END))::numeric(18,6),
         (sd.adet - (
          abs(COALESCE((SELECT SUM(f1.adet) FROM public.siparisdetay f1 WHERE f1.yeri = p_donusumturu AND f1.yerid = sd.id), 0))
        + abs(CASE WHEN p_hedefuretim
              THEN COALESCE((SELECT SUM(u1.adet) FROM public.uretimemridetay u1 WHERE u1.urunid = sd.urunid AND u1.yeri = p_donusumturu AND u1.yerid = sd.id), 0)
              ELSE COALESCE((SELECT SUM(f1.adet) FROM public.fatura f1 WHERE f1.urunid = sd.urunid AND f1.yeri = p_donusumturu AND f1.yerid = sd.id), 0)
            END)))::numeric(18,6)
  FROM public.siparisdetay sd
  WHERE p_kaynak = 2 AND sd.id = p_satirid

  UNION ALL
  SELECT f.adet::numeric(18,6),
         (COALESCE((SELECT SUM(f1.adet) FROM public.fatura f1 WHERE (f1.yeri = p_donusumturu OR (p_donusumturu = 411 AND f1.yeri = 424)) AND f1.yerid = f.id), 0)
        + COALESCE((SELECT SUM(f1.adet) FROM public.fatura f1 WHERE f1.yeri = 416 AND f1.yerid = f.id), 0))::numeric(18,6),
         (f.adet
        - COALESCE((SELECT SUM(f1.adet) FROM public.fatura f1 WHERE (f1.yeri = p_donusumturu OR (p_donusumturu = 411 AND f1.yeri = 424)) AND f1.yerid = f.id), 0)
        - COALESCE((SELECT SUM(f1.adet) FROM public.fatura f1 WHERE f1.yeri = 416 AND f1.yerid = f.id), 0))::numeric(18,6)
  FROM public.fatura f
  WHERE p_kaynak = 3 AND f.id = p_satirid;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_kalan(
  p_donusumturu integer,
  p_satirid integer
)
RETURNS TABLE(adet numeric, donusen numeric, kalan numeric)
LANGUAGE sql STABLE AS $$
  SELECT sd.adet::numeric(18,6),
         d.donusen::numeric(18,6),
         (sd.adet - d.donusen)::numeric(18,6)
  FROM public.fn_prog_belgedonusum_rota() r
  INNER JOIN public.siparisdetay sd ON sd.id = p_satirid
  CROSS JOIN LATERAL (
    SELECT (COALESCE((SELECT SUM(abs(f.adet)) FROM public.fatura f
                      WHERE r.kalanhedeftablo = 'FATURA'
                        AND f.yerid = p_satirid
                        AND f.yeri IN (SELECT k.kod FROM public.fn_prog_belgedonusum_kalankod() k WHERE k.grup = r.kalangrubu)), 0)
          + COALESCE((SELECT SUM(abs(s2.adet)) FROM public.siparisdetay s2
                      WHERE r.kalanhedeftablo = 'SIPARISDETAY'
                        AND s2.yerid = p_satirid
                        AND s2.yeri IN (SELECT k.kod FROM public.fn_prog_belgedonusum_kalankod() k WHERE k.grup = r.kalangrubu)), 0))::numeric AS donusen
  ) d
  WHERE r.donusumturu = p_donusumturu AND r.kaynakdetaytablo = 'SIPARISDETAY'

  UNION ALL
  SELECT f0.adet::numeric(18,6),
         d.donusen::numeric(18,6),
         (f0.adet - d.donusen)::numeric(18,6)
  FROM public.fn_prog_belgedonusum_rota() r
  INNER JOIN public.fatura f0 ON f0.id = p_satirid
  CROSS JOIN LATERAL (
    SELECT COALESCE((SELECT SUM(abs(f.adet)) FROM public.fatura f
                     WHERE f.yerid = p_satirid
                       AND f.yeri IN (SELECT k.kod FROM public.fn_prog_belgedonusum_kalankod() k WHERE k.grup = r.kalangrubu)), 0)::numeric AS donusen
  ) d
  WHERE r.donusumturu = p_donusumturu AND r.kaynakdetaytablo = 'FATURA';
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_yorumtabno(p_belgetur integer)
RETURNS integer
LANGUAGE sql STABLE AS $$
  SELECT CASE p_belgetur
    WHEN 9 THEN 91 WHEN 19 THEN 92 WHEN 10 THEN 104 WHEN 14 THEN 105
    WHEN 11 THEN 28 WHEN 15 THEN 29 WHEN 12 THEN 106 WHEN 16 THEN 107
    WHEN 20 THEN 134 WHEN 6 THEN 144 WHEN 109 THEN 209 WHEN 119 THEN 219
    WHEN 101 THEN 463 WHEN 105 THEN 464 ELSE NULL END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_donusum_kaynakdonusebilirmi(
  p_belgetablo text,
  p_belgeid integer
)
RETURNS smallint
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_durum integer;
BEGIN
  IF upper(COALESCE(p_belgetablo,'')) = 'SIPARIS' THEN
    SELECT COALESCE(durum, 0) INTO v_durum FROM public.siparis WHERE id = p_belgeid;
  ELSE
    SELECT COALESCE(durum, 0) INTO v_durum FROM public.fatbaslik WHERE id = p_belgeid;
  END IF;
  IF v_durum IS NULL OR v_durum = 6 THEN RETURN 0; END IF;
  RETURN 1;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_izleme_depoaday(
  p_stokid integer,
  p_depoid integer,
  p_hedefsatirid integer DEFAULT 0
)
RETURNS TABLE(serilotid integer, serino varchar, lotno varchar, skt timestamp, urt timestamp, mevcut numeric)
LANGUAGE sql STABLE AS $$
  SELECT sdi.serilotid,
         ssl.serino,
         ssl.lotno,
         ssl.skt,
         ssl.urt,
         (COALESCE(sdi.kalan, 0) - COALESCE(k.kendi, 0))::numeric(18,6) AS mevcut
  FROM public.stokdurumizleme sdi
  INNER JOIN public.stokserilot ssl ON ssl.id = sdi.serilotid
  LEFT JOIN LATERAL (
    SELECT SUM(COALESCE(d.adet, 0)) AS kendi
    FROM public.stokizlemedepo d
    INNER JOIN public.stokizleme si ON si.id = d.izlemid
    WHERE COALESCE(p_hedefsatirid, 0) > 0
      AND si.satirid = p_hedefsatirid
      AND si.serilotid = sdi.serilotid
      AND d.depoid = p_depoid
  ) k ON true
  WHERE sdi.stokid = p_stokid
    AND sdi.depoid = p_depoid
    AND COALESCE(sdi.kalan, 0) - COALESCE(k.kendi, 0) > 0.0001;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_detay()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, tabloid integer)
LANGUAGE sql STABLE AS $$
  SELECT * FROM (VALUES
    (71,900,'REHBER','ID={ID}',71),
    (73,900,'REHBER','ID={ID}',73),
    (83,900,'SERVIS','ID={ID}',83),
    (97,900,'TEKLIF','ID={ID}',97),
    (91,900,'SIPARIS','ID={ID}',91),
    (18,900,'DEMIRBAS','ID={ID}',18),
    (321,900,'DOKUMAN','ID={ID}',321),
    (70,900,'PROJELER','ID={ID}',70),
    (170,900,'PROJELER','ID={ID}',170),
    (33,900,'GOREVLER','ID={ID}',33),
    (480,900,'KASAADI','ID={ID}',480),
    (58,900,'MASRAF','ID={ID}',58),
    (315,900,'CEKSENETLER','ID={ID}',315),
    (316,900,'CEKSENETLER','ID={ID}',316),
    (318,900,'CEKSENETLER','ID={ID}',318),
    (319,900,'CEKSENETLER','ID={ID}',319)
  ) AS t(modul,sira,tablo,kosul,tabloid);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_detay_ek()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, tabloid integer)
LANGUAGE sql STABLE AS $$
  SELECT * FROM (VALUES
    (88,900,'STOKLAR','ID={ID}',88),
    (520,900,'STOKSAYIM','ID={ID}',520),
    (140,900,'URETIMEMRI','ID={ID}',140),
    (138,900,'URETIMRECETE','ID={ID}',138)
  ) AS t(modul,sira,tablo,kosul,tabloid);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_plan(p_modul integer)
RETURNS TABLE(sira integer, tablo text, kosul text, tabloid integer)
LANGUAGE sql STABLE AS $$
  SELECT d.sira, d.tablo, d.kosul, d.tabloid FROM public.fn_prog_silme_detay() d WHERE d.modul = p_modul
  UNION ALL
  SELECT d.sira, d.tablo, d.kosul, d.tabloid FROM public.fn_prog_silme_detay_ek() d WHERE d.modul = p_modul;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_engel()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, mesaj text)
LANGUAGE sql STABLE AS $$
  SELECT * FROM (VALUES
    (71,20,'KASA','SELECT 1 FROM KASA WHERE REHBERID={ID}','Bu cariye ait kasa/plan verisi var, silinemez.'),
    (71,30,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE REHBERID={ID}','Bu cariye ait fatura verisi var, silinemez.'),
    (83,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE SERVISID={ID}','Bu servisten belge olusturulmus, silinemez.'),
    (97,10,'SIPARISDETAY','SELECT 1 FROM SIPARISDETAY SD INNER JOIN fn_prog_belgedonusum_rota() R ON R.DonusumTuru=SD.YERI AND R.KaynakDetayTablo=''TEKLIFDETAY'' WHERE SD.YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID={ID})','Bu teklif siparise donusturulmus, silinemez.'),
    (91,10,'FATURA','SELECT 1 FROM FATURA F INNER JOIN fn_prog_belgedonusum_rota() R ON R.DonusumTuru=F.YERI AND R.KaynakDetayTablo=''SIPARISDETAY'' WHERE F.YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID={ID})','Bu siparis belgeye donusturulmus, silinemez.'),
    (70,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE PROJEID={ID}','Bu projeye ait belge var, silinemez.'),
    (170,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE PROJEID={ID}','Bu firsata ait belge var, silinemez.')
  ) AS t(modul,sira,tablo,kosul,mesaj);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_engel_ek()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, mesaj text)
LANGUAGE sql STABLE AS $$
  SELECT * FROM (VALUES
    (88,20,'FATURA','SELECT 1 FROM FATURA WHERE TUR=1 AND URUNID={ID}','Bu stok faturada kullanilmis, silinemez.'),
    (88,30,'SIPARISDETAY','SELECT 1 FROM SIPARISDETAY WHERE TUR=1 AND URUNID={ID}','Bu stok sipariste kullanilmis, silinemez.'),
    (88,50,'STOKIZLEME','SELECT 1 FROM STOKIZLEME WHERE STOKID={ID}','Bu stokun lot/seri hareketi var, silinemez.'),
    (140,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE TUR=6 AND YERI=142 AND YERID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})','Bu uretim emrinden uretim fisi olusturulmus, silinemez.'),
    (138,20,'URETIMEMRI','SELECT 1 FROM URETIMEMRI WHERE RECETEID={ID}','Bu recete uretim emrinde kullanilmis, silinemez.')
  ) AS t(modul,sira,tablo,kosul,mesaj);
$$;
