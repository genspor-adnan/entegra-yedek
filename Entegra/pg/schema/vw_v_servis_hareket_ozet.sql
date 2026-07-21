-- V_Servis_Hareket_Ozet -> public.v_servis_hareket_ozet
-- MSSQL kaynak: dbo.V_Servis_Hareket_Ozet
-- NOT: MSSQL view iki skaler fonksiyona baglidir:
--   fn_TarihFarkiFormatli(baslangic, bitis), fn_TarihFarkiFormatli2(fark)
-- Bu fonksiyonlar PG'de yok; ayni bicimlendirme mantigi view icine inline edildi.
-- Bicim (GENINI BOLUM=-10138 DEGER, varsayilan 1):
--   1 = 'DDDg HHs MMd', 2 = 'x.xx gun', 3 = 'x.xx saat', 4 = 'x dakika'
-- MSSQL datetime farki (float, gun) = EXTRACT(EPOCH FROM interval)/86400.
CREATE OR REPLACE VIEW public.v_servis_hareket_ozet AS
SELECT
    s.servisid,
    s.baslama,
    s.bitis,
    -- TOPLAM_SURE = fn_TarihFarkiFormatli(MIN(BASLAMA), MAX(BITIS))
    CASE
        WHEN s.toplam_fark < 0.0 THEN
            CASE f.fmt
                WHEN 1 THEN '000g 00s 00d'
                WHEN 2 THEN '0.00 gün'
                WHEN 3 THEN '0.00 saat'
                WHEN 4 THEN '0 dakika'
            END
        ELSE
            CASE f.fmt
                WHEN 1 THEN lpad(tc.d::text, 3, '0') || 'g '
                          || lpad(tc.h::text, 2, '0') || 's '
                          || lpad(tc.m::text, 2, '0') || 'd'
                WHEN 2 THEN to_char(round(s.toplam_fark::numeric, 2), 'FM9999999990.00') || ' gün'
                WHEN 3 THEN to_char(round((s.toplam_fark * 24)::numeric, 2), 'FM9999999990.00') || ' saat'
                WHEN 4 THEN round((s.toplam_fark * 24 * 60)::numeric)::int::text || ' dakika'
            END
    END AS toplam_sure,
    -- CALISMA_SURESI = fn_TarihFarkiFormatli2(SUM(BITIS-BASLAMA))
    CASE
        WHEN s.calisma_fark < 0.0 THEN
            CASE f.fmt
                WHEN 1 THEN '000g 00s 00d'
                WHEN 2 THEN '0.00 gün'
                WHEN 3 THEN '0.00 saat'
                WHEN 4 THEN '0 dakika'
            END
        ELSE
            CASE f.fmt
                WHEN 1 THEN lpad(cc.d::text, 3, '0') || 'g '
                          || lpad(cc.h::text, 2, '0') || 's '
                          || lpad(cc.m::text, 2, '0') || 'd'
                WHEN 2 THEN to_char(round(s.calisma_fark::numeric, 2), 'FM9999999990.00') || ' gün'
                WHEN 3 THEN to_char(round((s.calisma_fark * 24)::numeric, 2), 'FM9999999990.00') || ' saat'
                WHEN 4 THEN round((s.calisma_fark * 24 * 60)::numeric)::int::text || ' dakika'
            END
    END AS calisma_suresi
FROM (
    SELECT
        sh1.servisid,
        MIN(sh1.baslama) AS baslama,
        MAX(sh1.bitis)   AS bitis,
        EXTRACT(EPOCH FROM (MAX(sh1.bitis) - MIN(sh1.baslama))) / 86400.0 AS toplam_fark,
        SUM(EXTRACT(EPOCH FROM (sh1.bitis - sh1.baslama)) / 86400.0)      AS calisma_fark
    FROM public.servishareket sh1
    WHERE sh1.baslama IS NOT NULL AND sh1.bitis IS NOT NULL
    GROUP BY sh1.servisid
) s
CROSS JOIN LATERAL (
    SELECT COALESCE((SELECT deger FROM public.genini WHERE bolum = -10138 LIMIT 1), 1) AS fmt
) f
-- Gun/saat/dakika bilesenleri (MSSQL convert(int) = yuvarlama -> round(numeric))
CROSS JOIN LATERAL (
    SELECT y.d, y.h,
           round((s.toplam_fark * 24 * 60 - (y.d * 24 * 60 + y.h * 60))::numeric)::int AS m
    FROM (
        SELECT x.d,
               round((s.toplam_fark * 24 - x.d * 24)::numeric)::int AS h
        FROM (SELECT round(s.toplam_fark::numeric)::int AS d) x
    ) y
) tc
CROSS JOIN LATERAL (
    SELECT y.d, y.h,
           round((s.calisma_fark * 24 * 60 - (y.d * 24 * 60 + y.h * 60))::numeric)::int AS m
    FROM (
        SELECT x.d,
               round((s.calisma_fark * 24 - x.d * 24)::numeric)::int AS h
        FROM (SELECT round(s.calisma_fark::numeric)::int AS d) x
    ) y
) cc;
