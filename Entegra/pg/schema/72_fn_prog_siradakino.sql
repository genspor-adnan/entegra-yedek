-- ============================================================
-- 72_fn_prog_siradakino.sql
-- MSSQL dbo.sp_Prog_SiradakiNo / _Iade / _Ayarla PG portu (GenDepoUpdate135)
--
-- Merkezi numara uretimi. MSSQL'de atomiklik "UPDATE ... OUTPUT" ile saglaniyor;
-- PG'de "UPDATE ... RETURNING" ayni isi yapar (satir kilidi tek deyimde).
--
-- MSSQL farklari:
--   * TRY_CAST yok  -> kolon '^\d+$' desenine uyuyorsa cast, degilse NULL
--   * sysname yok   -> text + to_regclass/information_schema dogrulamasi
--   * bit yok       -> boolean parametre (app tarafi 1/0 gonderirse ::int::boolean)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.SAYAC
(
    ANAHTAR     varchar(200) PRIMARY KEY,
    TABLOADI    varchar(128),
    ALANADI     varchar(128),
    KAPSAM      varchar(80),
    SONNO       bigint NOT NULL DEFAULT 0,
    GUNCELLEME  timestamp
);

-- GENINI opsiyonu (-24121): belge numarasi rezervasyonu; varsayilan KAPALI
--   Bool opsiyon deseni: ANAHTAR NULL, DEGER 0/1, DIL 0. (-24130 e-Fatura seri kurallari, DOLU)
INSERT INTO GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA)
SELECT -24121, NULL, 0, 0, NULL
WHERE NOT EXISTS (SELECT 1 FROM GENINI WHERE BOLUM = -24121);

DROP FUNCTION IF EXISTS public.fn_prog_siradakino(text, text, text, text, bigint, int, int, boolean, boolean);
CREATE FUNCTION public.fn_prog_siradakino(
    p_tablo     text,
    p_alan      text,
    p_kapsam    text    DEFAULT '',
    p_kosul     text    DEFAULT NULL,
    p_baslangic bigint  DEFAULT 1,
    p_adet      int     DEFAULT 1,
    p_dijit     int     DEFAULT 0,
    p_rezerve   boolean DEFAULT true,
    p_dogrula   boolean DEFAULT true)
RETURNS TABLE(ilkno bigint, sonno bigint, no text, anahtar text)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_anahtar text;
  v_nerede  text;
  v_mevcut  bigint;
  v_tohum   bigint;
  v_ilk     bigint;
  v_son     bigint;
  v_no      text;
  v_var     boolean;
  v_deneme  int := 0;
  v_adet    int := GREATEST(COALESCE(p_adet, 1), 1);
BEGIN
  IF to_regclass(p_tablo) IS NULL THEN
    RAISE EXCEPTION 'Sayac icin tablo bulunamadi: %', p_tablo USING ERRCODE = '51301';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = lower(p_tablo) AND column_name = lower(p_alan)) THEN
    RAISE EXCEPTION 'Sayac icin kolon bulunamadi: %.%', p_tablo, p_alan USING ERRCODE = '51302';
  END IF;

  v_anahtar := p_tablo || '.' || p_alan ||
               CASE WHEN COALESCE(p_kapsam, '') = '' THEN '' ELSE '|' || p_kapsam END;
  v_nerede  := CASE WHEN COALESCE(p_kosul, '') = '' THEN '' ELSE ' WHERE ' || p_kosul END;

  ------------------------------------------------------------------ tohumlama
  IF NOT EXISTS (SELECT 1 FROM public.SAYAC s WHERE s.ANAHTAR = v_anahtar) THEN
    BEGIN
      EXECUTE format(
        'SELECT COALESCE(MAX(CASE WHEN %1$I::text ~ ''^[0-9]+$'' THEN %1$I::text::bigint END), 0) FROM %2$s %3$s',
        lower(p_alan), p_tablo, v_nerede) INTO v_mevcut;
    EXCEPTION WHEN OTHERS THEN
      v_mevcut := 0;
    END;

    v_tohum := GREATEST(COALESCE(v_mevcut, 0), COALESCE(p_baslangic, 1) - 1);

    INSERT INTO public.SAYAC (ANAHTAR, TABLOADI, ALANADI, KAPSAM, SONNO, GUNCELLEME)
    VALUES (v_anahtar, p_tablo, p_alan, p_kapsam, v_tohum, now())
    -- OUT parametresi 'anahtar' ile kolon adi cakismasin diye kisit adiyla:
    ON CONFLICT ON CONSTRAINT sayac_pkey DO NOTHING;
  END IF;

  ------------------------------------------------------------------ tahsis
  IF p_rezerve THEN
    -- Tek deyim: satir kilidi + okuma/yazma atomik.
    UPDATE public.SAYAC s
       SET SONNO = s.SONNO + v_adet, GUNCELLEME = now()
     WHERE s.ANAHTAR = v_anahtar
    RETURNING s.SONNO - v_adet + 1, s.SONNO INTO v_ilk, v_son;
  ELSE
    SELECT s.SONNO + 1, s.SONNO + v_adet INTO v_ilk, v_son
      FROM public.SAYAC s WHERE s.ANAHTAR = v_anahtar;
  END IF;

  ------------------------------------------------------------------ carpisma kontrolu
  IF p_dogrula AND p_rezerve AND v_adet = 1 THEN
    LOOP
      EXIT WHEN v_deneme >= 1000;
      BEGIN
        EXECUTE format(
          'SELECT EXISTS (SELECT 1 FROM %2$s WHERE %1$I::text ~ ''^[0-9]+$'' AND %1$I::text::bigint = $1 %3$s)',
          lower(p_alan), p_tablo,
          CASE WHEN COALESCE(p_kosul, '') = '' THEN '' ELSE ' AND (' || p_kosul || ')' END)
        INTO v_var USING v_ilk;
      EXCEPTION WHEN OTHERS THEN
        v_var := false;
      END;

      EXIT WHEN NOT COALESCE(v_var, false);

      UPDATE public.SAYAC s SET SONNO = s.SONNO + 1, GUNCELLEME = now()
       WHERE s.ANAHTAR = v_anahtar AND s.SONNO = v_son;
      v_ilk := v_ilk + 1;
      v_son := v_son + 1;
      v_deneme := v_deneme + 1;
    END LOOP;
  END IF;

  ------------------------------------------------------------------ cikti
  v_no := v_ilk::text;
  IF COALESCE(p_dijit, 0) > length(v_no) THEN
    v_no := repeat('0', p_dijit - length(v_no)) || v_no;
  END IF;

  RETURN QUERY SELECT v_ilk, v_son, v_no, v_anahtar;
END $$;

-- ---- IADE: kaydedilmeyen belgenin numarasi geri verilir (sadece SON ise) ----
DROP FUNCTION IF EXISTS public.fn_prog_siradakino_iade(text, text, text, bigint);
CREATE FUNCTION public.fn_prog_siradakino_iade(
    p_tablo text, p_alan text, p_kapsam text DEFAULT '', p_no bigint DEFAULT 0)
RETURNS TABLE(iade smallint)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_anahtar text;
  v_say int;
BEGIN
  v_anahtar := p_tablo || '.' || p_alan ||
               CASE WHEN COALESCE(p_kapsam, '') = '' THEN '' ELSE '|' || p_kapsam END;

  UPDATE public.SAYAC s SET SONNO = s.SONNO - 1, GUNCELLEME = now()
   WHERE s.ANAHTAR = v_anahtar AND s.SONNO = p_no;
  GET DIAGNOSTICS v_say = ROW_COUNT;

  RETURN QUERY SELECT CASE WHEN v_say > 0 THEN 1 ELSE 0 END::smallint;
END $$;

-- ---- AYARLA: yonetici; sayaci kur/duzelt (p_deger NULL -> tablodan MAX) ----
DROP FUNCTION IF EXISTS public.fn_prog_siradakino_ayarla(text, text, text, text, bigint);
CREATE FUNCTION public.fn_prog_siradakino_ayarla(
    p_tablo text, p_alan text, p_kapsam text DEFAULT '',
    p_kosul text DEFAULT NULL, p_deger bigint DEFAULT NULL)
RETURNS TABLE(anahtar text, sonno bigint)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_anahtar text;
  v_deger   bigint := p_deger;
  v_nerede  text := CASE WHEN COALESCE(p_kosul, '') = '' THEN '' ELSE ' WHERE ' || p_kosul END;
BEGIN
  IF to_regclass(p_tablo) IS NULL THEN
    RAISE EXCEPTION 'Sayac icin tablo bulunamadi: %', p_tablo USING ERRCODE = '51301';
  END IF;

  v_anahtar := p_tablo || '.' || p_alan ||
               CASE WHEN COALESCE(p_kapsam, '') = '' THEN '' ELSE '|' || p_kapsam END;

  IF v_deger IS NULL THEN
    EXECUTE format(
      'SELECT COALESCE(MAX(CASE WHEN %1$I::text ~ ''^[0-9]+$'' THEN %1$I::text::bigint END), 0) FROM %2$s %3$s',
      lower(p_alan), p_tablo, v_nerede) INTO v_deger;
  END IF;

  INSERT INTO public.SAYAC (ANAHTAR, TABLOADI, ALANADI, KAPSAM, SONNO, GUNCELLEME)
  VALUES (v_anahtar, p_tablo, p_alan, p_kapsam, v_deger, now())
  ON CONFLICT ON CONSTRAINT sayac_pkey DO UPDATE SET SONNO = EXCLUDED.SONNO, GUNCELLEME = now();

  RETURN QUERY SELECT v_anahtar, v_deger;
END $$;
