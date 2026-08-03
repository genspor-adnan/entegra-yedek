DROP PROCEDURE IF EXISTS public.sp_prog_fatura_stokdetay(integer, integer);

CREATE PROCEDURE public.sp_prog_fatura_stokdetay(
    p_fatbasid integer,
    p_min_kolon_sayisi integer DEFAULT 6
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_kolon_sayisi integer;
    v_count integer;
    v_detaybolumu text;
    v_urun record;
    v_etiket record;
    v_col text;
    v_resim_col text;
BEGIN
    DROP TABLE IF EXISTS pg_temp.rehberbilgiview;

    CREATE TEMP TABLE rehberbilgiview(
        "ID" integer GENERATED ALWAYS AS IDENTITY,
        "SIRA" integer NULL,
        "ETIKET" varchar(100) NULL,
        "KONU" varchar(50) NULL,
        "GIRIS" integer NULL
    ) ON COMMIT PRESERVE ROWS;

    SELECT COUNT(*)
      INTO v_kolon_sayisi
    FROM stoklar s
    INNER JOIN fatura td ON s.id = td.urunid AND td.tur = 1
    WHERE td.fatbasid = p_fatbasid
      AND coalesce(s.detaybolumu, '') <> ''
    GROUP BY s.detaybolumu
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    v_kolon_sayisi := coalesce(v_kolon_sayisi, 0);
    IF v_kolon_sayisi < p_min_kolon_sayisi THEN
        v_kolon_sayisi := p_min_kolon_sayisi;
    END IF;

    v_count := 0;
    WHILE v_count < v_kolon_sayisi LOOP
        EXECUTE format(
            'ALTER TABLE pg_temp.rehberbilgiview ADD COLUMN %I varchar(1000) NULL, ADD COLUMN %I bytea NULL',
            'Ürün' || (v_count + 1)::text,
            'Resim' || (v_count + 1)::text
        );
        v_count := v_count + 1;
    END LOOP;

    INSERT INTO pg_temp.rehberbilgiview("SIRA", "ETIKET", "KONU", "GIRIS")
    SELECT ra.sira, ra.etiket, ra.bolum, ra.giris
    FROM rehberayar ra
    WHERE ra.yeri = 88
      AND ra.bolum IN (
          SELECT DISTINCT s.detaybolumu
          FROM stoklar s
          WHERE coalesce(s.detaybolumu, '') <> ''
            AND s.id IN (SELECT t.urunid FROM fatura t WHERE t.tur = 1 AND t.fatbasid = p_fatbasid)
      )
    ORDER BY ra.bolum;

    INSERT INTO pg_temp.rehberbilgiview("SIRA", "ETIKET", "KONU", "GIRIS")
    SELECT DISTINCT -1, 'Ürün Adı', s.detaybolumu, -1
    FROM stoklar s
    WHERE coalesce(s.detaybolumu, '') <> ''
      AND s.id IN (SELECT t.urunid FROM fatura t WHERE t.tur = 1 AND t.fatbasid = p_fatbasid);

    INSERT INTO pg_temp.rehberbilgiview("SIRA", "ETIKET", "KONU", "GIRIS")
    SELECT DISTINCT 2147483640, 'Fiyatı', s.detaybolumu, 2147483640
    FROM stoklar s
    WHERE coalesce(s.detaybolumu, '') <> ''
      AND s.id IN (SELECT t.urunid FROM fatura t WHERE t.tur = 1 AND t.fatbasid = p_fatbasid);

    FOR v_detaybolumu IN
        SELECT s.detaybolumu
        FROM stoklar s
        WHERE coalesce(s.detaybolumu, '') <> ''
          AND s.id IN (SELECT t.urunid FROM fatura t WHERE t.tur = 1 AND t.fatbasid = p_fatbasid)
        GROUP BY s.detaybolumu
        ORDER BY COUNT(*) DESC
    LOOP
        FOR v_urun IN
            SELECT t.urunid,
                   'Ürün' || row_number() OVER(ORDER BY t.urunid)::text AS kolonadi,
                   s.stokadi,
                   t.tutar::text || t.kur AS urunfiyat
            FROM stoklar s
            INNER JOIN fatura t ON t.tur = 1 AND t.urunid = s.id
            WHERE t.fatbasid = p_fatbasid
              AND s.detaybolumu = v_detaybolumu
        LOOP
            v_col := v_urun.kolonadi;
            v_resim_col := replace(v_col, 'Ürün', 'Resim');

            EXECUTE format('UPDATE pg_temp.rehberbilgiview SET %I = $1 WHERE "KONU" = $2 AND "SIRA" = -1 AND "ETIKET" = $3', v_col)
            USING v_urun.stokadi, v_detaybolumu, 'Ürün Adı';

            EXECUTE format('UPDATE pg_temp.rehberbilgiview SET %I = $1 WHERE "KONU" = $2 AND "SIRA" = 2147483640 AND "ETIKET" = $3', v_col)
            USING v_urun.urunfiyat, v_detaybolumu, 'Fiyatı';

            FOR v_etiket IN
                SELECT rb2.etiket, rb2.bilgi, rb2.sira
                FROM rehberbilgi rb2
                INNER JOIN rehberayar ra2 ON rb2.sira = ra2.sira AND rb2.etiket = ra2.etiket
                WHERE ra2.bolum = v_detaybolumu
                  AND rb2.yeri = 88
                  AND rb2.yer_id = v_urun.urunid
            LOOP
                EXECUTE format('UPDATE pg_temp.rehberbilgiview SET %I = $1 WHERE "KONU" = $2 AND "SIRA" = $3 AND "ETIKET" = $4', v_col)
                USING v_etiket.bilgi, v_detaybolumu, v_etiket.sira, v_etiket.etiket;
            END LOOP;

            FOR v_etiket IN
                SELECT rb2.etiket, rb2.bilgi, rb2.sira, rr.resim
                FROM rehberbilgi rb2
                INNER JOIN rehberayar ra2 ON rb2.sira = ra2.sira AND rb2.etiket = ra2.etiket
                LEFT OUTER JOIN rehberbilgiresim rr ON rb2.id = rr.rehberbilgiid
                WHERE ra2.bolum = v_detaybolumu
                  AND rb2.yeri = 88
                  AND rb2.yer_id = v_urun.urunid
            LOOP
                EXECUTE format('UPDATE pg_temp.rehberbilgiview SET %I = $1 WHERE "KONU" = $2 AND "SIRA" = $3 AND "ETIKET" = $4', v_resim_col)
                USING v_etiket.resim, v_detaybolumu, v_etiket.sira, v_etiket.etiket;
            END LOOP;
        END LOOP;
    END LOOP;
END;
$$;
