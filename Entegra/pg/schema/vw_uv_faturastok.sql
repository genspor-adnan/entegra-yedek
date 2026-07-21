CREATE OR REPLACE VIEW public.uv_faturastok AS
SELECT stoklar.kod, stoklar.stokadi, fatura.*
FROM fatura
LEFT OUTER JOIN stoklar ON fatura.urunid = stoklar.id
WHERE fatura.tur = '1'
UNION ALL
SELECT masrafgelir.kod, masrafgelir.ad, fatura.*
FROM fatura
LEFT OUTER JOIN masrafgelir ON fatura.urunid = masrafgelir.id
WHERE fatura.tur = '0';
