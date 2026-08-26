-- Gentegre PG migration
-- Eski/tipli sp_Prog_*_Liste adlari icin Json2 fonksiyonlarina uyumluluk wrapper'lari.
-- Destructive degildir; mevcut Json2 donus semasini kullanarak ayni RETURNS TABLE yapisini uretir.

DO $$
DECLARE
  r record;
  v_result text;
BEGIN
  FOR r IN
    SELECT *
    FROM (VALUES
      ('fn_prog_demirbas_liste',   'fn_prog_demirbas_liste_json2'),
      ('fn_prog_gorev_liste',      'fn_prog_gorev_liste_json2'),
      ('fn_prog_servis_liste',     'fn_prog_servis_liste_json2'),
      ('fn_prog_stoktalep_liste',  'fn_prog_stoktalep_liste_json2'),
      ('fn_prog_uretimemri_liste', 'fn_prog_uretimemri_liste_json2')
    ) AS x(wrapper_name, target_name)
  LOOP
    SELECT pg_get_function_result(p.oid)
      INTO v_result
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname = r.target_name
      AND pg_get_function_arguments(p.oid) = 'baslik text DEFAULT ''''::text, kosullar text DEFAULT ''{}''::text';

    IF v_result IS NULL THEN
      RAISE NOTICE 'Atlandi: hedef fonksiyon bulunamadi: %', r.target_name;
      CONTINUE;
    END IF;

    EXECUTE format(
      'CREATE OR REPLACE FUNCTION public.%I(baslik text DEFAULT '''', kosullar text DEFAULT ''{}'')
       RETURNS %s
       LANGUAGE sql STABLE AS $fn$
         SELECT * FROM public.%I(baslik, kosullar);
       $fn$;',
      r.wrapper_name,
      v_result,
      r.target_name
    );
  END LOOP;
END;
$$;
