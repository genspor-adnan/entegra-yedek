-- ============================================================================
-- Log / audit API PG portu
-- Kaynak: GenUpdate/_Konsolide_66_169/08_Log_Audit.sql
--
-- Bu port depo.islemlog.bilgi alanini jsonb olarak yazar.
-- Dinamik kosul guvenlik notu:
--   MSSQL sp_Api_Log_Yaz_Ic ham @Kosul metnini dinamik SQL'e koyuyordu.
--   PG portu sadece konsolide scriptlerde kullanilan basit, parametreli
--   kosul desenlerini kabul eder. Desteklenmeyen kosulda islem durur.
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS depo.islemlog_id_seq;
SELECT setval('depo.islemlog_id_seq', GREATEST(COALESCE((SELECT MAX(id) FROM depo.islemlog), 0), 1), true);
ALTER TABLE depo.islemlog ALTER COLUMN id SET DEFAULT nextval('depo.islemlog_id_seq');

CREATE SEQUENCE IF NOT EXISTS depo.logreferans_id_seq;
SELECT setval('depo.logreferans_id_seq', GREATEST(COALESCE((SELECT MAX(id) FROM depo.logreferans), 0), 1), true);

CREATE OR REPLACE FUNCTION public.fn_api_log_where_expr(p_kosul text, p_kayitid bigint)
RETURNS text
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  k text := lower(regexp_replace(COALESCE(p_kosul, ''), '\s+', '', 'g'));
BEGIN
  IF p_kayitid IS NOT NULL THEN
    RETURN 't.id = $1';
  END IF;

  IF k IN ('id=@pb', 'id=@pkayit') THEN RETURN 't.id = $1'; END IF;
  IF k = 'fatbasid=@pb' THEN RETURN 't.fatbasid = $1'; END IF;
  IF k = 'siparisid=@pb' THEN RETURN 't.siparisid = $1'; END IF;
  IF k = 'baslikid=@pb' THEN RETURN 't.baslikid = $1'; END IF;
  IF k = 'satirid=@pb' THEN RETURN 't.satirid = $1'; END IF;
  IF k = 'stokid=@pb' THEN RETURN 't.stokid = $1'; END IF;
  IF k = 'yerid=@pb' THEN RETURN 't.yerid = $1'; END IF;
  IF k = 'kasa=@pb' THEN RETURN 't.kasa = $1'; END IF;
  IF k = 'hizmetid=@pb' THEN RETURN 't.hizmetid = $1'; END IF;
  IF k = 'kasaid=@pb' THEN RETURN 't.kasaid = $1'; END IF;
  IF k = 'posid=@pb' THEN RETURN 't.posid = $1'; END IF;
  IF k = 'servisid=@pb' THEN RETURN 't.servisid = $1'; END IF;
  IF k = 'teklifid=@pb' THEN RETURN 't.teklifid = $1'; END IF;
  IF k = 'uretimemriid=@pb' THEN RETURN 't.uretimemriid = $1'; END IF;
  IF k = 'uretimreceteid=@pb' THEN RETURN 't.uretimreceteid = $1'; END IF;
  IF k = 'projeid=@pb' THEN RETURN 't.projeid = $1'; END IF;
  IF k = 'demirbasid=@pb' THEN RETURN 't.demirbasid = $1'; END IF;
  IF k = 'ceksenetlerid=@pb' THEN RETURN 't.ceksenetlerid = $1'; END IF;
  IF k = 'dokumanid=@pb' THEN RETURN 't.dokumanid = $1'; END IF;
  IF k = 'yer_id=@pb' THEN RETURN 't.yer_id = $1'; END IF;
  IF k = 'yeri=1andyer_id=@pb' THEN RETURN 't.yeri = 1 AND t.yer_id = $1'; END IF;
  IF k = 'yeri=18andyer_id=@pb' THEN RETURN 't.yeri = 18 AND t.yer_id = $1'; END IF;
  IF k = 'yeri=21andyer_id=@pb' THEN RETURN 't.yeri = 21 AND t.yer_id = $1'; END IF;
  IF k = 'yeribetween71and72andyer_id=@pb' THEN RETURN 't.yeri BETWEEN 71 AND 72 AND t.yer_id = $1'; END IF;
  IF k = 'paketid=@pb' THEN RETURN 't.paketid = $1'; END IF;
  IF k = 'urunid=@pbandstok=1' THEN RETURN 't.urunid = $1 AND t.stok = 1'; END IF;
  IF k = 'yeri=88andyer_id=@pb' THEN RETURN 't.yeri = 88 AND t.yer_id = $1'; END IF;
  IF k = 'yeri=71andyer_id=@pb' THEN RETURN 't.yeri = 71 AND t.yer_id = $1'; END IF;
  IF k = 'yeri=70andyer_id=@pb' THEN RETURN 't.yeri = 70 AND t.yer_id = $1'; END IF;
  IF k = 'yeri=1andyer_idin(selectidfromrehberiletisimwhererehberid=@pb)' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.rehberiletisim WHERE rehberid = $1)';
  END IF;
  IF k = 'rehberid=@pb' THEN RETURN 't.rehberid = $1'; END IF;
  IF k = 'rehberbilgiidin(selectidfromrehberbilgiwhereyeriin(1,2,3)andyer_id=@pb)' THEN
    RETURN 't.rehberbilgiid IN (SELECT id FROM public.rehberbilgi WHERE yeri IN (1,2,3) AND yer_id = $1)';
  END IF;
  IF k = 'yeriin(2,3)andyer_id=@pb' THEN RETURN 't.yeri IN (2,3) AND t.yer_id = $1'; END IF;
  IF k = 'yeri=3andyer_id=@pb' THEN RETURN 't.yeri = 3 AND t.yer_id = $1'; END IF;
  IF k = 'yeri=2andyer_id=@pb' THEN RETURN 't.yeri = 2 AND t.yer_id = $1'; END IF;
  IF k = 'yer_idin(selectidfromrehberiletisimwhererehberidin(selectidfromrehberwheregrup=334andbagid=@pb))' THEN
    RETURN 't.yer_id IN (SELECT id FROM public.rehberiletisim WHERE rehberid IN (SELECT id FROM public.rehber WHERE grup = 334 AND bagid = $1))';
  END IF;
  IF k = 'rehberidin(selectidfromrehberwheregrup=334andbagid=@pb)' THEN
    RETURN 't.rehberid IN (SELECT id FROM public.rehber WHERE grup = 334 AND bagid = $1)';
  END IF;
  IF k = 'grup=334andbagid=@pb' THEN RETURN 't.grup = 334 AND t.bagid = $1'; END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=210andmodulidin(selectidfromgorevyorumwheretur=71andgorevid=@pb))' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 71 AND gorevid = $1))';
  END IF;
  IF k = 'modul=210andmodulidin(selectidfromgorevyorumwheretur=71andgorevid=@pb)' THEN
    RETURN 't.modul = 210 AND t.modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 71 AND gorevid = $1)';
  END IF;
  IF k = 'tur=71andgorevid=@pb' THEN RETURN 't.tur = 71 AND t.gorevid = $1'; END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=210andmodulidin(selectidfromgorevyorumwheretur=73andgorevid=@pb))' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 73 AND gorevid = $1))';
  END IF;
  IF k = 'modul=210andmodulidin(selectidfromgorevyorumwheretur=73andgorevid=@pb)' THEN
    RETURN 't.modul = 210 AND t.modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 73 AND gorevid = $1)';
  END IF;
  IF k = 'tur=73andgorevid=@pb' THEN RETURN 't.tur = 73 AND t.gorevid = $1'; END IF;
  IF k = 'urunid=@pb' THEN RETURN 't.urunid = $1'; END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=210andmodulidin(selectidfromgorevyorumwheretur=88andgorevid=@pb))' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 88 AND gorevid = $1))';
  END IF;
  IF k = 'modul=210andmodulidin(selectidfromgorevyorumwheretur=88andgorevid=@pb)' THEN
    RETURN 't.modul = 210 AND t.modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 88 AND gorevid = $1)';
  END IF;
  IF k = 'tur=88andgorevid=@pb' THEN RETURN 't.tur = 88 AND t.gorevid = $1'; END IF;
  IF k = 'yeri=321andyerid=@pb' THEN RETURN 't.yeri = 321 AND t.yerid = $1'; END IF;
  IF k = 'yeri=321andyer_id=@pb' THEN RETURN 't.yeri = 321 AND t.yer_id = $1'; END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=210andmodulidin(selectidfromgorevyorumwheretur=18andgorevid=@pb))' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 18 AND gorevid = $1))';
  END IF;
  IF k = 'modul=210andmodulidin(selectidfromgorevyorumwheretur=18andgorevid=@pb)' THEN
    RETURN 't.modul = 210 AND t.modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 18 AND gorevid = $1)';
  END IF;
  IF k = 'tur=18andgorevid=@pb' THEN RETURN 't.tur = 18 AND t.gorevid = $1'; END IF;
  IF k = 'yeri=83andyer_id=@pb' THEN RETURN 't.yeri = 83 AND t.yer_id = $1'; END IF;
  IF k = 'tur=12andlistgorevid=@pb' THEN RETURN 't.tur = 12 AND t.listgorevid = $1'; END IF;
  IF k = 'idin(selectidfromservishareketwhereservisid=@pb)' THEN RETURN 't.id IN (SELECT id FROM public.servishareket WHERE servisid = $1)'; END IF;
  IF k = 'belgetur=99andbaslikid=@pb' THEN RETURN 't.belgetur = 99 AND t.baslikid = $1'; END IF;
  IF k = 'durum=0andbelgetur=99andbaslikid=@pb' THEN RETURN 't.durum = 0 AND t.belgetur = 99 AND t.baslikid = $1'; END IF;
  IF k = 'fatbasidin(selectidfromfatbaslikwheretur=7andanakayitid=@pb)' THEN RETURN 't.fatbasid IN (SELECT id FROM public.fatbaslik WHERE tur = 7 AND anakayitid = $1)'; END IF;
  IF k = 'tur=7andanakayitid=@pb' THEN RETURN 't.tur = 7 AND t.anakayitid = $1'; END IF;
  IF k = 'tur=142andgorevidin(selectidfromuretimoperasyonwhereuretimemriid=@pb)' THEN
    RETURN 't.tur = 142 AND t.gorevid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1)';
  END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=210andmodulidin(selectidfromgorevyorumwheretur=142andgorevidin(selectidfromuretimoperasyonwhereuretimemriid=@pb)))' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 142 AND gorevid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1)))';
  END IF;
  IF k = 'modul=210andmodulidin(selectidfromgorevyorumwheretur=142andgorevidin(selectidfromuretimoperasyonwhereuretimemriid=@pb))' THEN
    RETURN 't.modul = 210 AND t.modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 142 AND gorevid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1))';
  END IF;
  IF k = 'uretimolcumidin(selectidfromuretimolcumwhereoperasyonpersonelidin(selectidfromuretimoperasyonpersonelwhereoperasyonidin(selectidfromuretimoperasyonwhereuretimemriid=@pb)))' THEN
    RETURN 't.uretimolcumid IN (SELECT id FROM public.uretimolcum WHERE operasyonpersonelid IN (SELECT id FROM public.uretimoperasyonpersonel WHERE operasyonid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1)))';
  END IF;
  IF k = 'operasyonpersonelidin(selectidfromuretimoperasyonpersonelwhereoperasyonidin(selectidfromuretimoperasyonwhereuretimemriid=@pb))' THEN
    RETURN 't.operasyonpersonelid IN (SELECT id FROM public.uretimoperasyonpersonel WHERE operasyonid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1))';
  END IF;
  IF k = 'operasyonidin(selectidfromuretimoperasyonwhereuretimemriid=@pb)' THEN
    RETURN 't.operasyonid IN (SELECT id FROM public.uretimoperasyon WHERE uretimemriid = $1)';
  END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=210andmodulidin(selectidfromgorevyorumwheretur=83andgorevid=@pb))' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 83 AND gorevid = $1))';
  END IF;
  IF k = 'modul=210andmodulidin(selectidfromgorevyorumwheretur=83andgorevid=@pb)' THEN
    RETURN 't.modul = 210 AND t.modulid IN (SELECT id FROM public.gorevyorum WHERE tur = 83 AND gorevid = $1)';
  END IF;
  IF k = 'tur=83andgorevid=@pb' THEN RETURN 't.tur = 83 AND t.gorevid = $1'; END IF;
  IF k = 'gorevid=@pb' THEN RETURN 't.gorevid = $1'; END IF;
  IF k = 'tur=1andid=@pb' THEN RETURN 't.tur = 1 AND t.id = $1'; END IF;
  IF k = 'tur=11andlistgorevid=@pb' THEN RETURN 't.tur = 11 AND t.listgorevid = $1'; END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=33andmodulid=@pb)' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 33 AND modulid = $1)';
  END IF;
  IF k = 'modul=33andmodulid=@pb' THEN RETURN 't.modul = 33 AND t.modulid = $1'; END IF;
  IF k = 'yeri=1andyer_idin(selectidfromdokumanwheremodul=210andmodulidin(selectidfromgorevyorumwheregorevid=@pb))' THEN
    RETURN 't.yeri = 1 AND t.yer_id IN (SELECT id FROM public.dokuman WHERE modul = 210 AND modulid IN (SELECT id FROM public.gorevyorum WHERE gorevid = $1))';
  END IF;
  IF k = 'modul=210andmodulidin(selectidfromgorevyorumwheregorevid=@pb)' THEN
    RETURN 't.modul = 210 AND t.modulid IN (SELECT id FROM public.gorevyorum WHERE gorevid = $1)';
  END IF;
  IF k = 'idin(selectidfromfaturawherefatbasid=@pb)' THEN RETURN 't.id IN (SELECT id FROM public.fatura WHERE fatbasid = $1)'; END IF;
  IF k = 'idin(selectidfromfatbaslikwherekasa=@pb)' THEN RETURN 't.id IN (SELECT id FROM public.fatbaslik WHERE kasa = $1)'; END IF;
  IF k = 'izlemidin(selectidfromstokizlemewherebaslikid=@pb)' THEN RETURN 't.izlemid IN (SELECT id FROM public.stokizleme WHERE baslikid = $1)'; END IF;

  RAISE EXCEPTION 'PG log portu bu kosulu desteklemiyor: %', COALESCE(p_kosul, '')
    USING ERRCODE = 'P0001';
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_log_yaz_ic(
  p_tablo text,
  p_kosul text DEFAULT NULL,
  p_kosulpar bigint DEFAULT NULL,
  p_kayitid bigint DEFAULT NULL,
  p_tabno integer DEFAULT NULL,
  p_usttabno integer DEFAULT 0,
  p_ustid bigint DEFAULT 0,
  p_kulid integer DEFAULT 0,
  p_subeid integer DEFAULT 0,
  p_ip varchar DEFAULT NULL,
  p_istasyon varchar DEFAULT NULL,
  p_rehberid bigint DEFAULT 0,
  p_stokid bigint DEFAULT 0,
  p_islemtipi smallint DEFAULT 0
)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  v_tablo text := lower(p_tablo);
  v_reg regclass;
  v_where text;
  v_param bigint;
  v_sql text;
  v_yazilan integer := 0;
  v_ustt integer := CASE WHEN COALESCE(p_usttabno, 0) = 0 THEN p_tabno ELSE p_usttabno END;
  v_rehkendi boolean := false;
  v_stkkendi boolean := false;
BEGIN
  IF p_tablo IS NULL OR p_tabno IS NULL THEN
    RAISE EXCEPTION 'Tablo ve TabNo zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  SELECT to_regclass('public.' || quote_ident(v_tablo)) INTO v_reg;
  IF v_reg IS NULL THEN
    RAISE EXCEPTION 'Tablo bulunamadi: %', p_tablo USING ERRCODE = 'P0001';
  END IF;

  IF COALESCE(p_rehberid, 0) = 0 AND p_tabno IN (71, 73, 74) THEN
    v_rehkendi := true;
  END IF;
  IF COALESCE(p_stokid, 0) = 0 AND p_tabno = 88 THEN
    v_stkkendi := true;
  END IF;

  v_param := COALESCE(p_kayitid, p_kosulpar);
  v_where := public.fn_api_log_where_expr(p_kosul, p_kayitid);

  v_sql := format($fmt$
    INSERT INTO depo.islemlog(
      ip, istasyon, kullaniciid, subeid, islemtipi, altislemtipi,
      usttabloid, ustkayitid, tabloid, kayitid, rehberid, stokid, bilgi
    )
    SELECT
      $2::varchar(45),
      $3::varchar(64),
      NULLIF($4, 0),
      NULLIF($5, 0)::smallint,
      $6::smallint,
      $6::smallint,
      $7,
      CASE WHEN COALESCE($8, 0) = 0 THEN COALESCE((to_jsonb(t)->>'id')::bigint, 0) ELSE $8 END,
      $9,
      COALESCE((to_jsonb(t)->>'id')::bigint, 0),
      NULLIF(
        CASE WHEN $10 THEN COALESCE((to_jsonb(t)->>'id')::bigint, 0)
             ELSE COALESCE(NULLIF($11, 0),
                           NULLIF((to_jsonb(t)->>'rehberid')::bigint, 0),
                           NULLIF((to_jsonb(t)->>'cariid')::bigint, 0),
                           CASE WHEN $7 IN (71,73,74) THEN NULLIF($8, 0) END)
        END, 0),
      NULLIF(
        CASE WHEN $12 THEN COALESCE((to_jsonb(t)->>'id')::bigint, 0)
             ELSE COALESCE(NULLIF($13, 0),
                           NULLIF((to_jsonb(t)->>'stokid')::bigint, 0),
                           NULLIF((to_jsonb(t)->>'urunid')::bigint, 0),
                           CASE WHEN $7 = 88 THEN NULLIF($8, 0) END)
        END, 0),
      to_jsonb(t)
    FROM %s t
    WHERE %s
  $fmt$, v_reg::text, v_where);

  EXECUTE v_sql
    USING v_param,
          LEFT(COALESCE(p_ip, ''), 45),
          LEFT(COALESCE(p_istasyon, ''), 64),
          COALESCE(p_kulid, 0),
          COALESCE(p_subeid, 0),
          COALESCE(p_islemtipi, 0),
          v_ustt,
          COALESCE(p_ustid, 0),
          p_tabno,
          v_rehkendi,
          COALESCE(p_rehberid, 0),
          v_stkkendi,
          COALESCE(p_stokid, 0);

  GET DIAGNOSTICS v_yazilan = ROW_COUNT;
  RETURN v_yazilan;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_log_kayitsil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_yazilan integer;
BEGIN
  v_yazilan := public.fn_api_log_yaz_ic(
    p_tablo    := NULLIF(j->>'Tablo', ''),
    p_kayitid  := NULLIF(j->>'KayitId', '')::bigint,
    p_tabno    := NULLIF(j->>'TabNo', '')::integer,
    p_usttabno := COALESCE(NULLIF(j->>'UstTabNo', '')::integer, 0),
    p_ustid    := COALESCE(NULLIF(j->>'UstId', '')::bigint, 0),
    p_kulid    := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0),
    p_subeid   := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0),
    p_ip       := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45),
    p_istasyon := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64),
    p_rehberid := COALESCE(NULLIF(j->>'RehberId', '')::bigint, 0),
    p_stokid   := COALESCE(NULLIF(j->>'StokId', '')::bigint, 0),
    p_islemtipi := 0::smallint
  );

  RETURN jsonb_build_object('Sonuc', 1, 'Yazilan', v_yazilan)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_log_detaysil_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_yazilan integer;
BEGIN
  v_yazilan := public.fn_api_log_yaz_ic(
    p_tablo    := NULLIF(j->>'Tablo', ''),
    p_kosul    := NULLIF(j->>'Kosul', ''),
    p_kosulpar := COALESCE(NULLIF(j->>'KosulPar', '')::bigint,
                           NULLIF(j->>'UstId', '')::bigint,
                           NULLIF(j->>'KayitId', '')::bigint),
    p_tabno    := NULLIF(j->>'TabNo', '')::integer,
    p_usttabno := COALESCE(NULLIF(j->>'UstTabNo', '')::integer, 0),
    p_ustid    := COALESCE(NULLIF(j->>'UstId', '')::bigint, 0),
    p_kulid    := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0),
    p_subeid   := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0),
    p_ip       := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45),
    p_istasyon := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64),
    p_rehberid := COALESCE(NULLIF(j->>'RehberId', '')::bigint, 0),
    p_stokid   := COALESCE(NULLIF(j->>'StokId', '')::bigint, 0),
    p_islemtipi := 0::smallint
  );

  RETURN jsonb_build_object('Sonuc', 1, 'Yazilan', v_yazilan)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_log_kaynak_isaretle(
  p_tabno integer,
  p_kayitid bigint,
  p_alttip smallint,
  p_kaynakid bigint,
  p_kaynaktabno integer DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  v_alan text := CASE WHEN p_alttip = 5 THEN '_DonusumKaynak' ELSE '_KopyaKaynak' END;
  v_id bigint;
BEGIN
  IF COALESCE(p_kayitid, 0) <= 0 OR COALESCE(p_kaynakid, 0) <= 0 THEN
    RETURN;
  END IF;

  SELECT id INTO v_id
  FROM depo.islemlog
  WHERE tabloid = p_tabno AND kayitid = p_kayitid AND islemtipi = 1
  ORDER BY id DESC
  LIMIT 1;

  IF v_id IS NULL THEN RETURN; END IF;

  UPDATE depo.islemlog
     SET altislemtipi = p_alttip,
         bilgi = COALESCE(bilgi, '{}'::jsonb)
                   || jsonb_build_object(v_alan, p_kaynakid::text,
                                         '_KaynakTablo', COALESCE(p_kaynaktabno, p_tabno)::text)
   WHERE id = v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_log_kaynak_isaretle_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
BEGIN
  PERFORM public.fn_api_log_kaynak_isaretle(
    NULLIF(j->>'TabNo', '')::integer,
    NULLIF(j->>'KayitId', '')::bigint,
    NULLIF(j->>'AltTip', '')::smallint,
    NULLIF(j->>'KaynakId', '')::bigint,
    NULLIF(j->>'KaynakTabNo', '')::integer
  );
  RETURN jsonb_build_object('Sonuc', 1)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_api_belge_tabno(p_tur integer, p_detay integer DEFAULT 0)
RETURNS integer
LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE
    WHEN COALESCE(p_detay, 0) = 0 THEN
      CASE
        WHEN p_tur IN (3,12)     THEN 106
        WHEN p_tur IN (4,16)     THEN 107
        WHEN p_tur = 20          THEN 134
        WHEN p_tur = 6           THEN 144
        WHEN p_tur = 10          THEN 104
        WHEN p_tur = 14          THEN 105
        WHEN p_tur IN (8,110)    THEN 214
        WHEN p_tur = 109         THEN 209
        WHEN p_tur = 119         THEN 219
        WHEN p_tur IN (9,11,13)  THEN 28
        WHEN p_tur IN (19,15,17) THEN 29
        ELSE 30
      END
    ELSE
      CASE
        WHEN p_tur IN (3,12,4,16,20)     THEN 330
        WHEN p_tur = 6                   THEN 145
        WHEN p_tur = 9                   THEN 131
        WHEN p_tur IN (10,11,13,8,109)   THEN 130
        WHEN p_tur = 19                  THEN 133
        WHEN p_tur IN (14,15,17,110,119) THEN 132
        ELSE 130
      END
  END;
$$;
