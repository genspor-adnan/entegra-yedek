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

-- isnull(a,b): MSSQL 2-arg null-degistir -> coalesce. anycompatible (PG 13+): iki arg FARKLI
--   ama uyumlu tip olabilir (or. smallint + integer -> integer). anyelement ISE ayni tipi
--   zorlar (isnull(smallint,1) -> "function isnull(smallint,integer) does not exist"). MSSQL
--   isnull hedef-tipe implicit cast yapar -> anycompatible bu davranisa en yakin.
DROP FUNCTION IF EXISTS public.isnull(anyelement, anyelement);
CREATE OR REPLACE FUNCTION public.isnull(anycompatible, anycompatible) RETURNS anycompatible
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

-- scope_identity(): MSSQL son eklenen IDENTITY -> PG lastval() (oturumdaki son sequence
--   degeri). 'insert ...; select scope_identity()' deseninde calisir (identity sequence
--   kullanir). ~180 cagri SIFIR kod degisikligiyle calisir. NOT: @@IDENTITY (@@ ile) fonksiyon
--   OLAMAZ -> o 4 site elle (lastval/DbKimlikAl).
CREATE OR REPLACE FUNCTION public.scope_identity() RETURNS bigint
  LANGUAGE sql AS $$ SELECT lastval() $$;

-- ---- MSSQL tip ADLARI icin DOMAIN'ler (CAST/CONVERT uyumu) ----
-- 'cast(x as datetime)'/'convert(datetime,x)' PG'de calissin diye. money/bit PG'de NATIVE
--   (domain OLAMAZ); nvarchar(n)/nchar(n)/bit -> convert-sweep'te varchar/char/smallint'e eslenir.
DO $$ BEGIN
  IF to_regtype('datetime') IS NULL THEN CREATE DOMAIN datetime AS timestamp; END IF;
  IF to_regtype('datetime2') IS NULL THEN CREATE DOMAIN datetime2 AS timestamp; END IF;
  IF to_regtype('smalldatetime') IS NULL THEN CREATE DOMAIN smalldatetime AS timestamp; END IF;
  IF to_regtype('tinyint') IS NULL THEN CREATE DOMAIN tinyint AS smallint; END IF;
  IF to_regtype('smallmoney') IS NULL THEN CREATE DOMAIN smallmoney AS numeric(10,4); END IF;
END $$;

-- DAY/MONTH/YEAR (MSSQL tarih parcasi fonksiyonlari) -> extract. Nested DATEADD/DAY idiom + her yerde.
CREATE OR REPLACE FUNCTION public.day(timestamp)   RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(day from $1)::int $$;
CREATE OR REPLACE FUNCTION public.month(timestamp) RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(month from $1)::int $$;
CREATE OR REPLACE FUNCTION public.year(timestamp)  RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(year from $1)::int $$;
-- timestamptz + date asiri yuklemeleri (now()/getutcdate()/date kolon):
CREATE OR REPLACE FUNCTION public.day(timestamptz)   RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(day from $1)::int $$;
CREATE OR REPLACE FUNCTION public.month(timestamptz) RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(month from $1)::int $$;
CREATE OR REPLACE FUNCTION public.year(timestamptz)  RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(year from $1)::int $$;
CREATE OR REPLACE FUNCTION public.day(date)   RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(day from $1)::int $$;
CREATE OR REPLACE FUNCTION public.month(date) RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(month from $1)::int $$;
CREATE OR REPLACE FUNCTION public.year(date)  RETURNS int LANGUAGE sql IMMUTABLE AS $$ SELECT extract(year from $1)::int $$;
