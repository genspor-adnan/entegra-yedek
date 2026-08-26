-- Mesajlasma liste/yoklama program fonksiyonlari
-- MSSQL 07_Mesajlasma.sql sp_Prog_Mesaj_* cekirdek PG portu.

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_avatar(p_rehberid integer)
RETURNS bytea
LANGUAGE sql STABLE
AS $$
  SELECT resim FROM rehber WHERE id = $1;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_avatar_toplu(p_idler text DEFAULT '')
RETURNS TABLE(id integer, resim bytea)
LANGUAGE sql STABLE
AS $$
  WITH ids AS (
    SELECT value::integer AS id
    FROM regexp_split_to_table(COALESCE($1,''), ',') AS value
    WHERE value ~ '^[0-9]+$'
  )
  SELECT r.id, r.resim
  FROM rehber r
  JOIN ids i ON i.id = r.id
  WHERE r.resim IS NOT NULL;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_gecmis_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  mesajid bigint,
  gonderenid integer,
  gonderen varchar,
  benimmi integer,
  tarih timestamp,
  metin text,
  silindi integer,
  yanitid bigint,
  yanitmetin text,
  dosyaid integer,
  dosyaadi varchar,
  dosyaboyut bigint
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_kulid integer := COALESCE(NULLIF(j->>'KulId','')::integer, 0);
  v_kanalid integer := NULLIF(j->>'KanalId','')::integer;
  v_onceki bigint := NULLIF(j->>'OncekiId','')::bigint;
  v_sonraki bigint := NULLIF(j->>'SonrakiId','')::bigint;
  v_topn integer := COALESCE(NULLIF(j->>'TopN','')::integer, 50);
  v_baslangic bigint;
BEGIN
  IF v_kulid <= 0 OR COALESCE(v_kanalid,0) <= 0 THEN
    RAISE EXCEPTION 'KulId ve KanalId zorunlu.' USING ERRCODE='P0001';
  END IF;

  SELECT u.baslangicid INTO v_baslangic
  FROM mesajkanaluye u
  WHERE u.kanalid = v_kanalid AND u.rehberid = v_kulid AND u.ayrilmatarihi IS NULL;

  IF v_baslangic IS NULL THEN
    RAISE EXCEPTION 'Bu sohbetin uyesi degilsiniz.' USING ERRCODE='P0001';
  END IF;

  RETURN QUERY
  SELECT m.id, m.gonderenid, r.firma::varchar,
         CASE WHEN m.gonderenid = v_kulid THEN 1 ELSE 0 END,
         m.tarih,
         CASE WHEN COALESCE(m.silindi,0)=1 THEN NULL ELSE m.metin END,
         COALESCE(m.silindi,0)::integer,
         m.yanitid,
         left(ym.metin, 80)::text,
         m.dosyaid,
         m.dosyaadi,
         m.dosyaboyut
  FROM mesaj m
  LEFT JOIN rehber r ON r.id = m.gonderenid
  LEFT JOIN mesaj ym ON ym.id = m.yanitid
  WHERE m.kanalid = v_kanalid
    AND m.id > v_baslangic
    AND (v_onceki IS NULL OR m.id < v_onceki)
    AND (v_sonraki IS NULL OR m.id > v_sonraki)
    AND NOT EXISTS (SELECT 1 FROM mesajgizli g WHERE g.mesajid = m.id AND g.rehberid = v_kulid)
  ORDER BY CASE WHEN v_sonraki IS NULL THEN m.id END DESC,
           CASE WHEN v_sonraki IS NOT NULL THEN m.id END ASC
  LIMIT CASE WHEN v_topn > 0 THEN v_topn ELSE NULL END;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_icerik_ara_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  mesajid bigint,
  kanalid integer,
  tur smallint,
  kanaladi text,
  karsiid integer,
  resimvar integer,
  grupdosyaid integer,
  gonderen varchar,
  benimmi integer,
  tarih timestamp,
  metin text
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_kulid integer := COALESCE(NULLIF(j->>'KulId','')::integer, 0);
  v_ara text := NULLIF(j->>'Ara','');
  v_topn integer := COALESCE(NULLIF(j->>'TopN','')::integer, 100);
BEGIN
  IF v_kulid <= 0 THEN RAISE EXCEPTION 'KulId zorunlu.' USING ERRCODE='P0001'; END IF;
  IF COALESCE(v_ara,'') = '' THEN RAISE EXCEPTION 'Aranacak metin zorunlu.' USING ERRCODE='P0001'; END IF;

  RETURN QUERY
  SELECT m.id, k.id, k.tur,
         (CASE WHEN k.tur = 2 THEN k.adi ELSE kr.firma END)::text AS kanaladi,
         CASE WHEN k.tur = 1 THEN kr.id END AS karsiid,
         CASE WHEN k.tur = 1 THEN CASE WHEN kr.resim IS NULL THEN 0 ELSE 1 END
              WHEN k.dosyaid IS NOT NULL THEN 1 ELSE 0 END AS resimvar,
         CASE WHEN k.tur = 2 THEN k.dosyaid END AS grupdosyaid,
         g.firma::varchar,
         CASE WHEN m.gonderenid = v_kulid THEN 1 ELSE 0 END AS benimmi,
         m.tarih,
         left(m.metin, 200)::text
  FROM mesajkanaluye u
  JOIN mesajkanal k ON k.id = u.kanalid AND k.durum = 1
  JOIN mesaj m ON m.kanalid = k.id AND m.id > u.baslangicid AND COALESCE(m.silindi,0)=0
  LEFT JOIN rehber g ON g.id = m.gonderenid
  LEFT JOIN LATERAL (
    SELECT r.id, r.firma, r.resim
    FROM mesajkanaluye u2
    JOIN rehber r ON r.id = u2.rehberid
    WHERE u2.kanalid = k.id AND u2.rehberid <> v_kulid AND u2.ayrilmatarihi IS NULL
    ORDER BY r.firma
    LIMIT 1
  ) kr ON true
  WHERE u.rehberid = v_kulid
    AND u.ayrilmatarihi IS NULL
    AND m.metin ILIKE '%' || v_ara || '%'
    AND NOT EXISTS (SELECT 1 FROM mesajgizli gz WHERE gz.mesajid = m.id AND gz.rehberid = v_kulid)
  ORDER BY m.id DESC
  LIMIT CASE WHEN v_topn > 0 THEN v_topn ELSE NULL END;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_kanal_liste_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  kanalid integer,
  tur smallint,
  adi text,
  karsiid integer,
  resimvar integer,
  grupdosyaid integer,
  uyesayisi integer,
  uyeler text,
  sonmesaj text,
  songonderen varchar,
  sontarih timestamp,
  okunmamis integer,
  bildirim integer,
  yonetici integer,
  favori integer
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_kulid integer := COALESCE(NULLIF(j->>'KulId','')::integer, 0);
  v_ara text := NULLIF(j->>'Ara','');
  v_topn integer := COALESCE(NULLIF(j->>'TopN','')::integer, 100);
  v_okunmamis integer := COALESCE(NULLIF(j->>'YalnizOkunmamis','')::integer, 0);
  v_favori integer := COALESCE(NULLIF(j->>'YalnizFavori','')::integer, 0);
  v_grup integer := COALESCE(NULLIF(j->>'YalnizGrup','')::integer, 0);
BEGIN
  IF v_kulid <= 0 THEN RAISE EXCEPTION 'KulId zorunlu.' USING ERRCODE='P0001'; END IF;

  RETURN QUERY
  SELECT k.id, k.tur,
         (CASE WHEN k.tur = 2 THEN k.adi ELSE kr.firma END)::text AS adi,
         CASE WHEN k.tur = 1 THEN kr.id END AS karsiid,
         CASE WHEN k.tur = 1 THEN CASE WHEN kr.resim IS NULL THEN 0 ELSE 1 END
              WHEN k.dosyaid IS NOT NULL THEN 1 ELSE 0 END AS resimvar,
         CASE WHEN k.tur = 2 THEN k.dosyaid END AS grupdosyaid,
         (SELECT count(*)::integer FROM mesajkanaluye x WHERE x.kanalid=k.id AND x.ayrilmatarihi IS NULL) AS uyesayisi,
         CASE WHEN k.tur = 2 THEN (
           SELECT string_agg(CASE WHEN u3.rehberid=v_kulid THEN 'Siz' ELSE r2.firma END, ', ' ORDER BY CASE WHEN u3.rehberid=v_kulid THEN 1 ELSE 0 END, r2.firma)
           FROM mesajkanaluye u3 JOIN rehber r2 ON r2.id=u3.rehberid
           WHERE u3.kanalid=k.id AND u3.ayrilmatarihi IS NULL
         ) END AS uyeler,
         left(CASE WHEN COALESCE(sm.silindi,0)=1 THEN '(bu mesaj silindi)'
                   ELSE COALESCE(sm.metin, CASE WHEN sm.dosyaid IS NOT NULL THEN '[dosya] ' || COALESCE(sm.dosyaadi,'') END) END, 120)::text AS sonmesaj,
         sg.firma::varchar AS songonderen,
         sm.tarih AS sontarih,
         a.adet AS okunmamis,
         u.bildirim::integer,
         u.rol::integer,
         u.favori::integer
  FROM mesajkanaluye u
  JOIN mesajkanal k ON k.id = u.kanalid AND k.durum = 1
  LEFT JOIN LATERAL (
    SELECT m.*
    FROM mesaj m
    WHERE m.kanalid = k.id
      AND m.id > u.baslangicid
      AND NOT EXISTS (SELECT 1 FROM mesajgizli g WHERE g.mesajid=m.id AND g.rehberid=v_kulid)
    ORDER BY m.id DESC
    LIMIT 1
  ) sm ON true
  LEFT JOIN rehber sg ON sg.id = sm.gonderenid
  LEFT JOIN LATERAL (
    SELECT r.id, r.firma, r.resim
    FROM mesajkanaluye u2 JOIN rehber r ON r.id=u2.rehberid
    WHERE u2.kanalid=k.id AND u2.rehberid<>v_kulid AND u2.ayrilmatarihi IS NULL
    ORDER BY r.firma
    LIMIT 1
  ) kr ON true
  CROSS JOIN LATERAL (
    SELECT count(*)::integer AS adet
    FROM mesaj m
    WHERE m.kanalid=k.id
      AND m.id > u.sonokumaid
      AND m.id > u.baslangicid
      AND COALESCE(m.silindi,0)=0
      AND m.gonderenid <> v_kulid
      AND NOT EXISTS (SELECT 1 FROM mesajgizli g WHERE g.mesajid=m.id AND g.rehberid=v_kulid)
  ) a
  WHERE u.rehberid = v_kulid
    AND u.ayrilmatarihi IS NULL
    AND (k.tur = 2 OR sm.id IS NOT NULL)
    AND (v_okunmamis = 0 OR a.adet > 0)
    AND (v_favori = 0 OR u.favori = 1)
    AND (v_grup = 0 OR k.tur = 2)
    AND (v_ara IS NULL OR (k.tur=2 AND k.adi ILIKE '%'||v_ara||'%') OR (k.tur=1 AND kr.firma ILIKE '%'||v_ara||'%'))
  ORDER BY COALESCE(sm.tarih, k.olusturmatarihi) DESC
  LIMIT CASE WHEN v_topn > 0 THEN v_topn ELSE NULL END;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_kisi_bilgi_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  rehberid integer,
  adsoyad varchar,
  kod varchar,
  bolum text,
  departman text,
  gorev text,
  eposta text,
  telefon text,
  sube varchar
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_kulid integer := COALESCE(NULLIF(j->>'KulId','')::integer, 0);
  v_rehberid integer := COALESCE(NULLIF(j->>'RehberId','')::integer, 0);
BEGIN
  IF v_kulid <= 0 THEN RAISE EXCEPTION 'KulId zorunlu.' USING ERRCODE='P0001'; END IF;
  IF v_rehberid <= 0 THEN RAISE EXCEPTION 'RehberId zorunlu.' USING ERRCODE='P0001'; END IF;

  RETURN QUERY
  SELECT r.id, r.firma, r.kod, NULL::text, NULL::text, NULL::text,
         NULL::text, NULL::text, s.firma::varchar
  FROM rehber r
  LEFT JOIN rehber s ON s.id = r.subeid
  WHERE r.id = v_rehberid;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_kisi_liste_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  rehberid integer,
  adi varchar,
  kod varchar,
  resimvar integer,
  kanalid integer
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_kulid integer := COALESCE(NULLIF(j->>'KulId','')::integer, 0);
  v_ara text := NULLIF(j->>'Ara','');
  v_topn integer := COALESCE(NULLIF(j->>'TopN','')::integer, 200);
BEGIN
  IF v_kulid <= 0 THEN RAISE EXCEPTION 'KulId zorunlu.' USING ERRCODE='P0001'; END IF;

  RETURN QUERY
  WITH benim AS (
    SELECT u.kanalid
    FROM mesajkanaluye u
    JOIN mesajkanal k ON k.id=u.kanalid AND k.tur=1 AND k.durum=1
    WHERE u.rehberid=v_kulid AND u.ayrilmatarihi IS NULL
      AND EXISTS (
        SELECT 1 FROM mesaj m
        WHERE m.kanalid=u.kanalid AND m.id > u.baslangicid
          AND NOT EXISTS (SELECT 1 FROM mesajgizli g WHERE g.mesajid=m.id AND g.rehberid=v_kulid)
      )
  ),
  karsi AS (
    SELECT u.rehberid, min(u.kanalid)::integer AS kanalid
    FROM mesajkanaluye u JOIN benim b ON b.kanalid=u.kanalid
    WHERE u.rehberid<>v_kulid AND u.ayrilmatarihi IS NULL
    GROUP BY u.rehberid
  )
  SELECT r.id, r.firma, r.kod,
         CASE WHEN r.resim IS NULL THEN 0 ELSE 1 END AS resimvar,
         kr.kanalid
  FROM rehber r
  LEFT JOIN karsi kr ON kr.rehberid = r.id
  WHERE r.id <> v_kulid
    AND COALESCE(r.durum,1) = 1
    AND (v_ara IS NULL OR r.firma ILIKE '%'||v_ara||'%' OR r.kod ILIKE '%'||v_ara||'%')
  ORDER BY r.firma
  LIMIT CASE WHEN v_topn > 0 THEN v_topn ELSE NULL END;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_uye_liste_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  rehberid integer,
  adi varchar,
  kod varchar,
  rol integer,
  ben integer,
  resimvar integer
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_kulid integer := COALESCE(NULLIF(j->>'KulId','')::integer, 0);
  v_kanalid integer := COALESCE(NULLIF(j->>'KanalId','')::integer, 0);
BEGIN
  IF v_kulid <= 0 THEN RAISE EXCEPTION 'KulId zorunlu.' USING ERRCODE='P0001'; END IF;
  IF v_kanalid <= 0 THEN RAISE EXCEPTION 'KanalId zorunlu.' USING ERRCODE='P0001'; END IF;
  IF NOT EXISTS (
    SELECT 1
    FROM mesajkanaluye ux
    WHERE ux.kanalid=v_kanalid AND ux.rehberid=v_kulid AND ux.ayrilmatarihi IS NULL
  ) THEN
    RAISE EXCEPTION 'Bu sohbetin uyesi degilsiniz.' USING ERRCODE='P0001';
  END IF;

  RETURN QUERY
  SELECT r.id, r.firma, r.kod, u.rol::integer,
         CASE WHEN r.id=v_kulid THEN 1 ELSE 0 END,
         CASE WHEN r.resim IS NULL THEN 0 ELSE 1 END
  FROM mesajkanaluye u
  JOIN rehber r ON r.id = u.rehberid
  WHERE u.kanalid = v_kanalid AND u.ayrilmatarihi IS NULL
  ORDER BY u.rol DESC, r.firma;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_mesaj_yokla_json(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_kulid integer := COALESCE(NULLIF(j->>'KulId','')::integer, 0);
  v_sonid bigint := 0;
  v_okunmamis integer := 0;
  v_sesli integer := 0;
  v_kanallar jsonb := '[]'::jsonb;
BEGIN
  IF v_kulid <= 0 THEN RAISE EXCEPTION 'KulId zorunlu.' USING ERRCODE='P0001'; END IF;

  WITH k AS (
    SELECT u.kanalid, mk.sonmesajid, u.bildirim,
           (
             SELECT count(*)::integer
             FROM mesaj m
             WHERE m.kanalid=u.kanalid
               AND m.id > u.sonokumaid
               AND m.id > u.baslangicid
               AND COALESCE(m.silindi,0)=0
               AND m.gonderenid<>v_kulid
               AND NOT EXISTS (SELECT 1 FROM mesajgizli g WHERE g.mesajid=m.id AND g.rehberid=v_kulid)
           ) AS adet
    FROM mesajkanaluye u
    JOIN mesajkanal mk ON mk.id=u.kanalid AND mk.durum=1
    WHERE u.rehberid=v_kulid AND u.ayrilmatarihi IS NULL
  )
  SELECT COALESCE(max(sonmesajid),0),
         COALESCE(sum(adet),0)::integer,
         COALESCE(sum(CASE WHEN bildirim=1 THEN adet ELSE 0 END),0)::integer,
         COALESCE(jsonb_agg(jsonb_build_object('KanalId', kanalid, 'SonMesajId', sonmesajid, 'Okunmamis', adet, 'Bildirim', bildirim) ORDER BY kanalid) FILTER (WHERE adet > 0), '[]'::jsonb)
    INTO v_sonid, v_okunmamis, v_sesli, v_kanallar
  FROM k;

  RETURN jsonb_build_object('SonId', v_sonid, 'Okunmamis', v_okunmamis, 'Sesli', v_sesli, 'Kanallar', v_kanallar)::text;
END;
$$;
