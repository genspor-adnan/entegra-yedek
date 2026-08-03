-- ============================================================================
-- fn_prog_siparis_silinebilir_mi (PG portu) -- MSSQL: dbo.sp_Prog_Siparis_Silinebilir_Mi
--   Siparis SILME on-kontrolu. p_satirid>0 -> tek SIPARISDETAY; =0 -> p_siparisid tum detaylar.
--   Gerekli kontrol: DONUSUM (siparis satiri fatura/irsaliye/uretime donusmus). Kolonlar lowercase.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prog_siparis_silinebilir_mi(integer, integer);
CREATE OR REPLACE FUNCTION fn_prog_siparis_silinebilir_mi(p_siparisid integer DEFAULT 0, p_satirid integer DEFAULT 0)
RETURNS TABLE(silinebilir integer, neden varchar, belgead varchar, belgetarih timestamp, belgeno varchar)
LANGUAGE sql AS $$
  WITH satirlar AS (
    SELECT SD.ID AS satirid, S.TUR AS tur
    FROM SIPARISDETAY SD
    INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
    WHERE (p_satirid > 0 AND SD.ID = p_satirid)
       OR (p_satirid = 0 AND SD.SIPARISID = p_siparisid)
  )
  SELECT x.silinebilir, x.neden, x.belgead, x.belgetarih, x.belgeno FROM (
    -- DONUSUM: siparis satiri fatura/irsaliye/uretime donusturulmus
    SELECT 0 AS silinebilir, 'DONUSUM'::varchar AS neden,
      (SELECT AD FROM ISLEMTURLERI I WHERE I.TUR = FB.TUR LIMIT 1)::varchar AS belgead,
      FB.FATURATARIH::timestamp AS belgetarih, FB.FATURANO::varchar AS belgeno, 1 AS sira
    FROM satirlar S
    INNER JOIN FATURA F   ON F.YERID = S.satirid
      AND ((S.tur = 9  AND F.YERI IN (406,407))
        OR (S.tur = 19 AND F.YERI IN (409,410,415,420)))
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID

    UNION ALL
    SELECT 1, ''::varchar, NULL::varchar, NULL::timestamp, NULL::varchar, 99
  ) x
  ORDER BY x.sira
  LIMIT 1;
$$;
