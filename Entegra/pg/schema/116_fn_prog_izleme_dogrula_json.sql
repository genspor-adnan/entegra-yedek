-- Gentegre PG migration
-- MSSQL sp_Prog_Izleme_Dogrula_Json portu.
-- Salt-okuma dogrulama: seri/lot secimi, adet uyumu, kaynak/depo bakiye ve lot tarih uyari kontrolu.

CREATE OR REPLACE FUNCTION public.fn_prog_izleme_dogrula_json(kosullar text DEFAULT '{}')
RETURNS TABLE(kod text, serilotid integer, mesaj text)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
  v_donusumturu integer := NULLIF(j->>'donusumTuru','')::integer;
  v_stokid integer := NULLIF(j->>'stokId','')::integer;
  v_izlemtur integer := COALESCE(NULLIF(j->>'izlemTur','')::integer, 0);
  v_depoid integer := NULLIF(j->>'depoId','')::integer;
  v_gerekli numeric := NULLIF(j->>'gerekliAdet','')::numeric;
  v_hedefsatir integer := NULLIF(j #>> '{belge,satirId}','')::integer;
  v_kaynaksatir integer := NULLIF(j #>> '{kaynak,satirId}','')::integer;
  v_kaynakdetay text;
BEGIN
  IF v_donusumturu IS NOT NULL THEN
    SELECT r.kaynakdetaytablo
      INTO v_kaynakdetay
    FROM public.fn_prog_belgedonusum_rota() r
    WHERE r.donusumturu = v_donusumturu
    LIMIT 1;
  END IF;

  RETURN QUERY
  WITH secim AS (
    SELECT (x->>'serilotId')::integer AS serilotid,
           COALESCE(NULLIF(x->>'adet','')::numeric, 0) AS adet
    FROM jsonb_array_elements(COALESCE(j->'secim', '[]'::jsonb)) x
  ),
  yeni AS (
    SELECT NULLIF(x->>'seriNo','')::text AS serino,
           NULLIF(x->>'lotNo','')::text AS lotno,
           NULLIF(x->>'skt','')::timestamp AS skt,
           NULLIF(x->>'urt','')::timestamp AS urt,
           COALESCE(NULLIF(x->>'adet','')::numeric, 0) AS adet
    FROM jsonb_array_elements(COALESCE(j->'yeni', '[]'::jsonb)) x
  ),
  toplam AS (
    SELECT COALESCE((SELECT SUM(adet) FROM secim), 0)
         + COALESCE((SELECT SUM(adet) FROM yeni), 0) AS adet
  ),
  sorun AS (
    SELECT 1 AS sira, 'SECIM_YOK'::text AS kod, NULL::integer AS serilotid,
           '"' || COALESCE((SELECT stokadi FROM public.stoklar WHERE id = v_stokid), '?')
           || '" izlemeli bir urun; seri/lot secimi yapilmali.' AS mesaj
    WHERE v_izlemtur > 0
      AND NOT EXISTS (SELECT 1 FROM secim)
      AND NOT EXISTS (SELECT 1 FROM yeni)

    UNION ALL
    SELECT 2, 'ADET_GECERSIZ', s.serilotid,
           'Seri/lot icin gecersiz adet: ' || round(s.adet, 3)::text
    FROM secim s
    WHERE COALESCE(s.adet, 0) <= 0

    UNION ALL
    SELECT 3, 'MUKERRER_LOT', s.serilotid,
           'Ayni seri/lot birden fazla kez gonderildi.'
    FROM secim s
    GROUP BY s.serilotid
    HAVING COUNT(*) > 1

    UNION ALL
    SELECT 4, 'ADET_UYUMSUZ', NULL::integer,
           'Secilen seri/lot toplami (' || round(t.adet, 3)::text
           || ') satir adediyle (' || round(v_gerekli, 3)::text || ') ayni degil.'
    FROM toplam t
    WHERE v_gerekli IS NOT NULL AND v_gerekli > 0
      AND abs(t.adet - v_gerekli) > 0.0001

    UNION ALL
    SELECT 5, 'LOT_KALAN_YETERSIZ', s.serilotid,
           'Kaynak belgede bu seri/lot icin yeterli kalan yok (mevcut: '
           || round(COALESCE(k.kalan, 0), 3)::text
           || ', istenen: ' || round(s.adet, 3)::text || ').'
    FROM secim s
    LEFT JOIN LATERAL (
      SELECT SUM(abs(COALESCE(si.kalan, 0)))::numeric AS kalan
      FROM public.stokizleme si
      WHERE si.satirid = v_kaynaksatir
        AND si.serilotid = s.serilotid
    ) k ON true
    WHERE v_kaynakdetay = 'FATURA'
      AND COALESCE(v_kaynaksatir, 0) > 0
      AND COALESCE(k.kalan, 0) + 0.0001 < s.adet

    UNION ALL
    SELECT 6, 'LOT_KALAN_YETERSIZ', s.serilotid,
           'Depoda bu seri/lot icin yeterli kalan yok (mevcut: '
           || round(COALESCE(d.mevcut, 0)::numeric, 3)::text
           || ', istenen: ' || round(s.adet, 3)::text || ').'
    FROM secim s
    LEFT JOIN LATERAL (
      SELECT COALESCE(sdi.kalan, 0)
             - COALESCE((
                 SELECT SUM(COALESCE(dd.adet, 0))
                 FROM public.stokizlemedepo dd
                 INNER JOIN public.stokizleme si2 ON si2.id = dd.izlemid
                 WHERE si2.satirid = v_hedefsatir
                   AND si2.serilotid = s.serilotid
                   AND dd.depoid = v_depoid
               ), 0) AS mevcut
      FROM public.stokdurumizleme sdi
      WHERE sdi.stokid = v_stokid
        AND sdi.depoid = v_depoid
        AND sdi.serilotid = s.serilotid
    ) d ON true
    WHERE COALESCE(v_kaynakdetay, 'SIPARISDETAY') = 'SIPARISDETAY'
      AND COALESCE(v_depoid, 0) > 0
      AND COALESCE(d.mevcut, 0) + 0.0001 < s.adet

    UNION ALL
    SELECT 7, 'LOT_TARIH_UYUSMAZ', ssl.id,
           '"' || y.lotno || '" lot numarasi daha once farkli tarihlerle girilmis (SKT: '
           || COALESCE(to_char(ssl.skt, 'DD.MM.YYYY'), '-')
           || ', URT: ' || COALESCE(to_char(ssl.urt, 'DD.MM.YYYY'), '-') || ').'
    FROM yeni y
    INNER JOIN public.stokserilot ssl
      ON ssl.stokid = v_stokid AND ssl.lotno = y.lotno
    WHERE COALESCE(y.lotno, '') <> ''
      AND (COALESCE(ssl.skt, timestamp '1990-01-01') <> COALESCE(y.skt, timestamp '1990-01-01')
        OR COALESCE(ssl.urt, timestamp '1990-01-01') <> COALESCE(y.urt, timestamp '1990-01-01'))
  )
  SELECT s.kod, s.serilotid, s.mesaj
  FROM sorun s
  ORDER BY s.sira;
END;
$$;
