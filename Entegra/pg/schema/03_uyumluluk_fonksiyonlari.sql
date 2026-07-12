-- ============================================================
-- 03_uyumluluk_fonksiyonlari.sql — MSSQL fonksiyonlarinin PG karsiliklari
-- ------------------------------------------------------------
-- FONKSIYON-SEKLINDEKI MSSQL yerlesikleri PG'de FONKSIYON olarak tanimlanir ->
--   kod tabanindaki TUM cagrilari (hooked VE raw) SIFIR degisiklikle calisir.
--   (Sozdizimi olanlar -- TOP, [ident], WITH(NOLOCK), CONVERT, DATEADD, '+' concat --
--    fonksiyon olamaz; onlar PgSqlCevir/seam ile.)
-- MSSQL'de bu adlar yerlesik oldugundan bu dosya YALNIZ PG'de calisir; MSSQL etkilenmez.
-- ============================================================

-- getdate()/getutcdate()/sysdatetime(): MSSQL datetime (tz'siz) -> now()::timestamp
CREATE OR REPLACE FUNCTION public.getdate() RETURNS timestamp
  LANGUAGE sql STABLE AS $$ SELECT now()::timestamp $$;
CREATE OR REPLACE FUNCTION public.sysdatetime() RETURNS timestamp
  LANGUAGE sql STABLE AS $$ SELECT now()::timestamp $$;
CREATE OR REPLACE FUNCTION public.getutcdate() RETURNS timestamp
  LANGUAGE sql STABLE AS $$ SELECT (now() AT TIME ZONE 'UTC')::timestamp $$;

-- isnull(a,b): MSSQL 2-arg null-degistir -> coalesce. anyelement (ayni tip; MSSQL de tip
--   uyumu ister). Karisik tip (nvarchar,int) nadir -> o cagrida CAST gerekebilir.
CREATE OR REPLACE FUNCTION public.isnull(anyelement, anyelement) RETURNS anyelement
  LANGUAGE sql IMMUTABLE AS $$ SELECT coalesce($1, $2) $$;

-- charindex(needle, haystack [, start]): 1-tabanli konum, yoksa 0.
--   MSSQL arg sirasi (needle, haystack); PG strpos(haystack, needle).
CREATE OR REPLACE FUNCTION public.charindex(text, text) RETURNS integer
  LANGUAGE sql IMMUTABLE AS $$ SELECT strpos($2, $1) $$;
CREATE OR REPLACE FUNCTION public.charindex(text, text, integer) RETURNS integer
  LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE WHEN strpos(substr($2, $3), $1) = 0 THEN 0
                ELSE strpos(substr($2, $3), $1) + $3 - 1 END $$;

-- len(x): MSSQL LEN (sagdaki bosluklari saymaz) -> length(rtrim). (Cogu yerde tam sayi
--   arg de gelir; text'e cast edilir.)
CREATE OR REPLACE FUNCTION public.len(text) RETURNS integer
  LANGUAGE sql IMMUTABLE AS $$ SELECT length(rtrim($1)) $$;
