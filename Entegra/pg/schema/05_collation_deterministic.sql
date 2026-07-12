-- ============================================================
-- 05_collation_deterministic.sql — tr_ci (non-deterministic) -> varsayilan (deterministic)
-- ------------------------------------------------------------
-- Kullanici karari: PG non-deterministic collation LIKE'i desteklemez. tr_ci kolonlari
-- varsayilan (deterministic) collation'a alinir -> LIKE her yerde calisir. Bedel: '=' ve LIKE
-- case-SENSITIVE (MSSQL CI kaybi; pilotta kabul, gercek gecişte ILIKE/citext ile geri eklenir).
-- ============================================================
DO $$
DECLARE r record; n int := 0; e int := 0;
BEGIN
  FOR r IN
    SELECT n.nspname AS sch, c.relname AS tbl, a.attname AS col,
           format_type(a.atttypid, a.atttypmod) AS typ
    FROM pg_attribute a
    JOIN pg_class c ON c.oid = a.attrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_collation coll ON coll.oid = a.attcollation
    WHERE coll.collname = 'tr_ci' AND c.relkind = 'r' AND n.nspname IN ('public','depo')
  LOOP
    BEGIN
      EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE %s COLLATE pg_catalog."default"',
                     r.sch, r.tbl, r.col, r.typ);
      n := n + 1;
    EXCEPTION WHEN others THEN
      e := e + 1; RAISE NOTICE 'skip %.%.%: %', r.sch, r.tbl, r.col, SQLERRM;
    END;
  END LOOP;
  RAISE NOTICE 'Deterministic yapilan kolon: %, atlanan: %', n, e;
END $$;
