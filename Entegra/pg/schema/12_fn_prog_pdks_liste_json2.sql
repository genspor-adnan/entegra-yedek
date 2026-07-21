-- ============================================================
-- fn_prog_pdks_liste_json2 — MSSQL sp_Prog_PDKS_Liste_Json2 PG portu
--   PDKS (personel giris/cikis) rapor listesi. Yardimcilar: fn_girfark/fn_saatolarak/
--   fn_calfark/fn_cikfark (11_fn_pdks_yardimci.sql).
-- MSSQL->PG: CONVERT(varchar,x,108)->to_char(x,'HH24:MI:SS'), DATEDIFF(mi,a,b)->
--   EXTRACT(EPOCH FROM b-a)/60, DATEADD(dd,0,DATEDIFF(dd,0,x))->date_trunc('day',x),
--   DATEPART(WEEKDAY,x)(Pazar=1)->EXTRACT(DOW)+1, CAST(x AS time)->x::time,
--   charindex->position, ISNULL->COALESCE, bit->int. pers_pdks su an BOS -> smoke-only.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_pdks_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_pdks_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id int, firma text, rehberid int, tarih timestamp, gunadi text,
    giris text, cikis text, mola text, subeid smallint, durum smallint, aciklama text,
    vargiriscikis text, girfark text, calsure text, calfark text, cikfark text
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_rehberid int := NULLIF(j->>'RehberID','')::int;
    v_tarihbas timestamp := NULLIF(j->>'TarihBas','')::timestamp;
    v_tarihbit timestamp := NULLIF(j->>'TarihBit','')::timestamp;
    v_giristur int := COALESCE(NULLIF(j->>'GirisTur','')::int, 0);
    v_cikistur int := COALESCE(NULLIF(j->>'CikisTur','')::int, 0);
    v_cikisnull int := COALESCE(NULLIF(j->>'CikisNull','')::int, 0);
    v_subeid int := NULLIF(j->>'SubeID','')::int;
    v_durum int := NULLIF(j->>'Durum','')::int;
BEGIN
    RETURN QUERY
    SELECT
        pp.id, r.firma::text, r.id AS rehberid, date_trunc('day', pp.giris) AS tarih, pv.gunadi::text,
        to_char(pp.giris, 'HH24:MI:SS') AS giris,
        to_char(pp.cikis, 'HH24:MI:SS') AS cikis,
        to_char(pp.mola,  'HH24:MI:SS') AS mola,
        pp.subeid, pp.durum, pp.aciklama::text,
        (to_char(pv.giris, 'HH24:MI:SS') || ' / ' || to_char(pv.cikis, 'HH24:MI:SS')) AS vargiriscikis,
        (CASE WHEN pp.durum <> 1 THEN ''
              ELSE COALESCE(fn_girfark(to_char(pv.giris,'HH24:MI:SS'), pp.giris), '00:00') END)::text AS girfark,
        (COALESCE(fn_saatolarak(
            (EXTRACT(EPOCH FROM ((pp.cikis - (EXTRACT(EPOCH FROM pp.mola::time)::int) * INTERVAL '1 second') - pp.giris)) / 60)::int
        ), '00:00'))::text AS calsure,
        (CASE WHEN position('*' in fn_saatolarak((EXTRACT(EPOCH FROM (pp.cikis - pp.giris))/60)::int)) = 0
              THEN fn_calfark(
                     fn_saatolarak((EXTRACT(EPOCH FROM (pv.cikis - pv.giris))/60)::int),
                     fn_saatolarak((EXTRACT(EPOCH FROM (pp.cikis - pp.giris))/60)::int))
              ELSE '00:00' END)::text AS calfark,
        (CASE WHEN pp.durum <> 1 THEN ''
              ELSE COALESCE(fn_cikfark(
                     to_char(pv.giris,'HH24:MI:SS'),
                     fn_saatolarak((EXTRACT(EPOCH FROM (pv.cikis - pv.giris))/60)::int),
                     pp.giris, pp.cikis), '00:00') END)::text AS cikfark
    FROM pers_pdks pp
    LEFT OUTER JOIN rehber r ON r.id = pp.rehberid
    LEFT OUTER JOIN pers_vardiyatanim pv ON
        pv.rehberid = CASE WHEN EXISTS(SELECT 1 FROM pers_vardiyatanim x WHERE x.rehberid = pp.rehberid)
                           THEN pp.rehberid ELSE -1 END
        AND pv.gun = EXTRACT(DOW FROM pp.giris)::int + 1
    WHERE pv.ay = 0
      AND (COALESCE(v_rehberid, 0) = 0 OR pp.rehberid = v_rehberid)
      AND (COALESCE(v_rehberid, 0) <> 0 OR pp.rehberid <> 0)
      AND (v_tarihbas IS NULL OR pp.giris >= v_tarihbas)
      AND (v_tarihbit IS NULL OR pp.giris <= v_tarihbit)
      AND (v_giristur = 0
           OR (v_giristur = 1 AND pv.giris::time > pp.giris::time AND pp.giris::time <> TIME '00:00')
           OR (v_giristur = 2 AND pv.giris::time < pp.giris::time))
      AND (v_cikistur = 0
           OR (v_cikistur = 1 AND pv.cikis::time > pp.cikis::time)
           OR (v_cikistur = 2 AND pv.cikis::time < pp.cikis::time))
      AND (v_cikisnull = 0 OR pp.cikis IS NOT NULL)
      AND (v_subeid IS NULL OR r.subeid = v_subeid)
      AND (v_durum  IS NULL OR pp.durum = v_durum)
    ORDER BY r.firma, pp.giris, pp.cikis;
END $$;
