-- ============================================================
-- fn_prg_fiyatgetir_stok / _hizmet — MSSQL sp_Prg_FiyatGetir_Stok/_Hizmet PG portu
-- ------------------------------------------------------------
-- Secili urun/hizmet + cari icin FIYAT/KUR (STOKFIYAT/FIYATLAR) ve ISKONTO (KAMPANYACARI kademe).
-- Kademe onceligi ORDER BY kategori DESC + LIMIT 1: urun-ozel > kategori(agac) > genel > yok(0).
--   Stok: urun=kampanyaid -1, kategori=-2 (KATEGORI AGACI - recursive), genel=-3.
--   Hizmet: urun=kampanyaid -11, genel=-13 (kategori agaci YOK).
-- fn_Atasi (son '.' oncesi ust-kod) inline: strpos(reverse)/left; nokta yoksa ''.
-- MSSQL exec cagrisi app'te 'exec sp_...' yapildi -> PgExecCevir 'select * from fn_...' cevirir.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prg_fiyatgetir_stok(int, int, int, int, int);
CREATE FUNCTION public.fn_prg_fiyatgetir_stok(
    p_rehberid int, p_urunid int, p_fiyatadi int, p_birim int DEFAULT 0, p_paket int DEFAULT 0)
RETURNS TABLE(fiyat numeric, kur varchar, iskonto numeric)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_kod varchar;
BEGIN
    SELECT k.kod INTO v_kod
    FROM stoklar s INNER JOIN kategori k ON s.kategori=k.id
    WHERE s.id=p_urunid;

    RETURN QUERY
    WITH RECURSIVE agac AS (
        SELECT r.id, r.kod,
               CASE WHEN strpos(reverse(r.kod),'.')=0 THEN ''
                    ELSE left(r.kod, length(r.kod)-strpos(reverse(r.kod),'.')) END AS anakod
        FROM kategori r WHERE r.kod = v_kod
        UNION ALL
        SELECT r1.id, r1.kod,
               CASE WHEN strpos(reverse(r1.kod),'.')=0 THEN ''
                    ELSE left(r1.kod, length(r1.kod)-strpos(reverse(r1.kod),'.')) END
        FROM kategori r1 INNER JOIN agac a ON a.anakod = r1.kod
    )
    SELECT
        (SELECT sf.fiyat FROM stokfiyat sf
           WHERE sf.stokid=p_urunid AND sf.fiyatadi=p_fiyatadi AND sf.birim=p_birim AND sf.paketid=p_paket
           LIMIT 1)::numeric,
        (SELECT sf.kur FROM stokfiyat sf
           WHERE sf.stokid=p_urunid AND sf.fiyatadi=p_fiyatadi AND sf.birim=p_birim AND sf.paketid=p_paket
           LIMIT 1)::varchar,
        x.miktar::numeric
    FROM (
        SELECT -100 AS kategori, 0.0::numeric AS miktar
        UNION ALL
        SELECT -1, kc.miktar FROM kampanyacari kc
          WHERE kc.rehberid=p_rehberid AND kc.kampanyaid=-3
        UNION ALL
        SELECT 0, k.miktar FROM agac a INNER JOIN kampanyacari k ON a.id=k.urunid
          WHERE k.kampanyaid=-2 AND k.rehberid=p_rehberid
        UNION ALL
        SELECT s.kategori, k1.miktar
          FROM stoklar s INNER JOIN kampanyacari k1 ON s.id=k1.urunid
          WHERE s.id=p_urunid AND k1.rehberid=p_rehberid AND k1.kampanyaid=-1
    ) x
    ORDER BY x.kategori DESC
    LIMIT 1;
END $$;

DROP FUNCTION IF EXISTS public.fn_prg_fiyatgetir_hizmet(int, int, int, int, int);
CREATE FUNCTION public.fn_prg_fiyatgetir_hizmet(
    p_rehberid int, p_urunid int, p_fiyatadi int, p_masrafgelirid int DEFAULT 0, p_paket int DEFAULT 0)
RETURNS TABLE(fiyat numeric, kur varchar, iskonto numeric)
LANGUAGE sql STABLE AS $$
    SELECT
        (SELECT f.fiyat FROM fiyatlar f
           WHERE f.hizmetid=p_urunid AND f.fiyatadi=p_fiyatadi AND f.satis=p_masrafgelirid AND f.paketid=p_paket
           LIMIT 1)::numeric,
        (SELECT f.kur FROM fiyatlar f
           WHERE f.hizmetid=p_urunid AND f.fiyatadi=p_fiyatadi AND f.satis=p_masrafgelirid AND f.paketid=p_paket
           LIMIT 1)::varchar,
        x.miktar::numeric
    FROM (
        SELECT -100 AS kategori, 0.0::numeric AS miktar
        UNION ALL
        SELECT -1, kc.miktar FROM kampanyacari kc
          WHERE kc.rehberid=p_rehberid AND kc.kampanyaid=-13
        UNION ALL
        SELECT 0, k1.miktar FROM masrafgelir mg INNER JOIN kampanyacari k1 ON mg.id=k1.urunid
          WHERE mg.id=p_masrafgelirid AND k1.rehberid=p_rehberid AND k1.kampanyaid=-11
    ) x
    ORDER BY x.kategori DESC
    LIMIT 1;
$$;
