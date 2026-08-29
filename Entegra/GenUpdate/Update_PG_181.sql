-- ============================================================
-- Update_PG_181.sql   #pg   (PostgreSQL)
-- UTS sorgu endpoint tanimlari: hatali ayrintili tekil urun adreslerini duzelt
--
-- MSSQL Update_SQL_181 karsiligi. Idempotenttir; mevcut dogru veya ozel
-- adreslere dokunmaz.
-- ============================================================

DO $$
DECLARE
  v_count integer;
BEGIN
  IF to_regclass('public.uts_bildirim_tur') IS NULL THEN
    RAISE NOTICE 'uts_bildirim_tur bulunamadi, Update_PG_181 atlandi.';
    RETURN;
  END IF;

  IF to_regclass('public.uts_bildirim_tur_update181_yedek') IS NULL THEN
    CREATE TABLE public.uts_bildirim_tur_update181_yedek AS
      SELECT *
        FROM public.uts_bildirim_tur
       WHERE id IN (1, 45, 52);

    RAISE NOTICE 'uts_bildirim_tur_update181_yedek olusturuldu.';
  END IF;

  UPDATE public.uts_bildirim_tur
     SET adressorgu = CASE id
                        WHEN 1  THEN '/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula/offset'
                        WHEN 45 THEN '/UTS/uh/rest/tekilUrun/sorgula'
                        WHEN 52 THEN '/UTS/uh/rest/bildirim/verme/askidakiler/offset'
                      END
   WHERE id IN (1, 45, 52)
     AND (
          adressorgu IS NULL
          OR btrim(adressorgu) = ''
          OR adressorgu LIKE '%ayrintiliTekilUrun%'
         );

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'UTS_BILDIRIM_TUR sorgu endpoint duzeltmesi uygulandi. Degisen satir: %', v_count;
END $$;
