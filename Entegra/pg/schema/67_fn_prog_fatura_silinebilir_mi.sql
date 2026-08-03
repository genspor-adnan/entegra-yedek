-- ============================================================================
-- fn_prog_fatura_silinebilir_mi (PG portu) -- MSSQL: dbo.sp_Prog_Fatura_Silinebilir_Mi
--   Fatura/irsaliye/fis/konsinye/uretim SILME on-kontrolu. p_satirid>0 tek satir; =0 tum.
--   Kontroller: EBELGE(oncelik) / KULLANIM / IZLEME / UTSBILDIRIM / DONUSUM.
--   p_kilitkaldirildi=1 -> e-belge engelini atla. Kolon adlari lowercase (FieldByName CI okur).
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prog_fatura_silinebilir_mi(integer, integer);
DROP FUNCTION IF EXISTS fn_prog_fatura_silinebilir_mi(integer, integer, integer);
CREATE OR REPLACE FUNCTION fn_prog_fatura_silinebilir_mi(p_fatbasid integer DEFAULT 0, p_satirid integer DEFAULT 0, p_kilitkaldirildi integer DEFAULT 0)
RETURNS TABLE(silinebilir integer, neden varchar, belgead varchar, belgetarih timestamp, belgeno varchar)
LANGUAGE sql AS $$
  WITH satirlar AS (
    SELECT F.ID AS satirid, F.FATBASID AS fatbasid, F.URUNID AS urunid, F.IZLEME AS izleme, F.ADET AS adet,
           FB.TUR AS tur, FB.FATURATARIH AS faturatarih, FB.EFATURADURUM AS efaturadurum
    FROM FATURA F
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE (p_satirid > 0 AND F.ID = p_satirid)
       OR (p_satirid = 0 AND F.FATBASID = p_fatbasid)
  )
  SELECT x.silinebilir, x.neden, x.belgead, x.belgetarih, x.belgeno FROM (
    -- 0) EBELGE: islem goren e-fatura/e-arsiv (EFATURADURUM 2/52) silinemez (override haric)
    SELECT 0 AS silinebilir, 'EBELGE'::varchar AS neden,
      NULL::varchar AS belgead, NULL::timestamp AS belgetarih, NULL::varchar AS belgeno, 0 AS sira
    FROM satirlar S
    WHERE p_kilitkaldirildi = 0 AND S.efaturadurum IN (2,52)

    UNION ALL
    -- 1) KULLANIM
    SELECT 0, 'KULLANIM'::varchar,
      (SELECT AD FROM ISLEMTURLERI I WHERE I.TUR = FB2.TUR LIMIT 1)::varchar,
      FB2.FATURATARIH::timestamp, FB2.FATURANO::varchar, 1
    FROM satirlar S
    INNER JOIN FATURA F2    ON F2.URUNID = S.urunid
    INNER JOIN FATBASLIK FB2 ON FB2.ID = F2.FATBASID
    WHERE S.izleme = 0
      AND S.tur IN (3,6,101,102,10,11,12,20,99)
      AND NOT (S.tur = 6 AND S.adet < 0)
      AND (FB2.TUR IN (4,14,15,16,20,119) OR (FB2.TUR = 6 AND F2.ADET < 0))
      -- GUN bazinda AYNI GUN DAHIL (>=): saat kayit ani, fiziksel akis degil. Kendi belgesi haric.
      AND FB2.FATURATARIH::date >= S.faturatarih::date
      AND FB2.ID <> S.fatbasid

    UNION ALL
    -- 2) IZLEME
    SELECT 0, 'IZLEME'::varchar,
      (SELECT AD FROM ISLEMTURLERI I WHERE I.TUR = SI1.BELGETUR LIMIT 1)::varchar,
      FBz.FATURATARIH::timestamp, FBz.FATURANO::varchar, 2
    FROM satirlar S
    INNER JOIN STOKIZLEME SI1 ON SI1.SERILOTID IN
         (SELECT SERILOTID FROM STOKIZLEME SI2 WHERE SI2.SATIRID = S.satirid)
    INNER JOIN FATURA Fz    ON Fz.ID = SI1.SATIRID
    INNER JOIN FATBASLIK FBz ON FBz.ID = SI1.BASLIKID
    WHERE S.izleme <> 0
      AND S.tur IN (3,6,101,102,10,11,12,20,99)
      AND NOT (S.tur = 6 AND S.adet < 0)
      AND SI1.BELGETUR IN (4,14,15,16,20,101,119)
      -- KULLANIM ile ayni: gun bazinda, ayni gun dahil, kendi belgesi haric.
      AND FBz.FATURATARIH::date >= S.faturatarih::date
      AND FBz.ID <> S.fatbasid

    UNION ALL
    -- 3) UTS BILDIRIM
    SELECT 0, 'UTSBILDIRIM'::varchar, NULL::varchar, NULL::timestamp, NULL::varchar, 3
    FROM satirlar S
    INNER JOIN STOKIZLEME SI ON SI.STOKID = S.urunid AND SI.SATIRID = S.satirid
    WHERE S.izleme <> 0
      AND coalesce(SI.YER,0) > 0 AND coalesce(SI.YERID,0) > 0

    UNION ALL
    -- 4) DONUSUM
    SELECT 0, 'DONUSUM'::varchar, NULL::varchar, NULL::timestamp, NULL::varchar, 4
    FROM satirlar S
    INNER JOIN FATURA FD ON FD.YERID = S.satirid
      AND ((S.tur = 10  AND FD.YERI = 408)
        OR (S.tur = 14  AND FD.YERI = 411)
        OR (S.tur = 109 AND FD.YERI = 469)
        OR (S.tur = 119 AND FD.YERI IN (462,468)))
    WHERE S.tur IN (10,14,109,119)

    UNION ALL
    -- 99) ENGEL YOK
    SELECT 1, ''::varchar, NULL::varchar, NULL::timestamp, NULL::varchar, 99
  ) x
  ORDER BY x.sira
  LIMIT 1;
$$;
