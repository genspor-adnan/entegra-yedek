-- PG sequence resync: MSSQL'den seed sonrasi identity/serial sequence'ler tablo max'inin
-- gerisinde kalir -> ilk INSERT'te "duplicate key value violates unique constraint" (or. pk_imaj).
-- Bu script her identity/serial kolonun sequence'ini o kolonun max degerine ceker.
-- Idempotent, guvenli. Calistir: docker + cloud (kural: db-degisiklik-docker-ve-cloud).
--   docker: docker exec -i -e PGPASSWORD=FETAGEN gentegre-pg psql -U postgres -d ekspert -f - < pg/tools/resync_sequences.sql
--   cloud : ... psql -h 46.36.201.170 -p 5432 -U gentegre -d ekspert -f - < pg/tools/resync_sequences.sql
DO $$
DECLARE r record; sq text; mx bigint; n int := 0;
BEGIN
  FOR r IN
    SELECT c.table_name AS tbl, c.column_name AS col
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema=c.table_schema AND t.table_name=c.table_name AND t.table_type='BASE TABLE'
    WHERE c.table_schema='public'
      AND (c.is_identity='YES' OR c.column_default LIKE 'nextval(%')
  LOOP
    sq := pg_get_serial_sequence('public.'||quote_ident(r.tbl), r.col);
    IF sq IS NULL THEN CONTINUE; END IF;
    EXECUTE format('SELECT max(%I) FROM %I', r.col, r.tbl) INTO mx;
    IF mx IS NOT NULL AND mx >= 1 THEN PERFORM setval(sq, mx); n := n + 1; END IF;
  END LOOP;
  RAISE NOTICE 'resync: % sequence set', n;
END $$;
