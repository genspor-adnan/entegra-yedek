-- API yetki/kurulum kontrolu
-- Kalici GRANT/REVOKE yapmaz. Uzak sunucuda role/grant karari ayrica verilmelidir.

DO $$
DECLARE
  v_api_count integer;
  v_stub_count integer;
BEGIN
  SELECT count(*)
    INTO v_api_count
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND p.proname LIKE 'fn_api_%';

  SELECT count(*)
    INTO v_stub_count
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND p.proname LIKE 'fn_api_%'
    AND p.proname <> 'fn_api_pg_henuz_portlanmadi'
    AND pg_get_functiondef(p.oid) LIKE '%fn_api_pg_henuz_portlanmadi%';

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gentegre_api') THEN
    RAISE NOTICE 'gentegre_api role exists. Review explicit GRANT policy before production use.';
  ELSE
    RAISE NOTICE 'gentegre_api role not found. No privilege changes made.';
  END IF;

  RAISE NOTICE 'fn_api count: %, stub api count: %', v_api_count, v_stub_count;

  IF v_stub_count > 0 THEN
    RAISE EXCEPTION 'PG API port has % stub function(s).', v_stub_count;
  END IF;
END
$$;

