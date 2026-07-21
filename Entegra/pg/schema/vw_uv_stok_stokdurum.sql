CREATE OR REPLACE VIEW public.uv_stok_stokdurum AS
SELECT
    stokdepoid,
    urunid,
    SUM(CASE WHEN netmiktar > 0 THEN netmiktar ELSE 0 END)  AS giren,
    SUM(CASE WHEN netmiktar < 0 THEN -netmiktar ELSE 0 END) AS cikan,
    SUM(netmiktar)                                          AS kalan
FROM (
    -- girenler
    SELECT
        fb.girisdepo AS stokdepoid,
        f.urunid,
        CASE
            WHEN (fb.tur = 6) AND (f.miktar >= 0) THEN f.miktar   -- uretim
            WHEN (fb.tur = 6) AND (f.miktar < 0)  THEN 0          -- uretim
            ELSE f.miktar
        END AS netmiktar
    FROM fatbaslik fb
        INNER JOIN fatura f ON f.fatbasid = fb.id
    WHERE f.stokdurumdegis = 1
      AND COALESCE(fb.durum, 1) <> 6
      AND COALESCE(fb.girisdepo, 0) > 0

    UNION ALL

    -- cikanlar
    SELECT
        fb.cikisdepo AS stokdepoid,
        f.urunid,
        CASE
            WHEN (fb.tur = 6) AND (f.miktar > 0)  THEN 0          -- uretim
            WHEN (fb.tur = 6) AND (f.miktar <= 0) THEN f.miktar   -- uretim
            ELSE -f.miktar
        END AS netmiktar
    FROM fatbaslik fb
        INNER JOIN fatura f ON f.fatbasid = fb.id
    WHERE f.stokdurumdegis = 1
      AND COALESCE(fb.durum, 1) <> 6
      AND COALESCE(fb.cikisdepo, 0) > 0
) AS asd
GROUP BY stokdepoid, urunid;
