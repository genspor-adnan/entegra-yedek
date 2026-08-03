-- ============================================================================
-- fn_prg_servis_belgeler (PG portu) — MSSQL: dbo.sp_Prg_Servis_Belgeler(@ServisID)
-- Servis'e bagli belge listesi: TEKLIF + SIPARIS + FATBASLIK union.
-- Cagri: UServisListeDlg TabServisBelge EXEC -> PgSqlCevir -> select * from fn(...).
-- CONCAT hem MSSQL hem PG'de var. NOT: duz SELECT, differential kolay.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prg_servis_belgeler(integer);
DROP FUNCTION IF EXISTS fn_prg_servis_belgeler(varchar);
CREATE OR REPLACE FUNCTION fn_prg_servis_belgeler(p_servisid integer)
RETURNS TABLE("TUR" integer,"ID" integer,"TARIH" timestamp,"BELGENO" varchar(50),"TUTAR" numeric,
  "KUR" varchar(6),"ACIKLAMA" varchar(500),"FIRMA" varchar(750),"KAYNAK" varchar(50),"HEDEF" varchar(100))
LANGUAGE sql AS $$
  -- TEKLIF
  SELECT 80::int AS TUR, T.ID::int, T.TARIH::timestamp, T.TEKLIFNO::varchar(50),
    T.DOVIZ_TUTARI::numeric, T.DOVIZ_KURU::varchar(6), T.ACIKLAMA::varchar(500),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=T.REHBERID)::varchar(750) AS FIRMA,
    ''::varchar(50) AS KAYNAK,
    CONCAT(
      CASE WHEN 412 IN (SELECT YERI FROM SIPARISDETAY WHERE YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID=T.ID)) THEN 'Verilen Siparişi ' ELSE '' END,
      CASE WHEN 413 IN (SELECT YERI FROM SIPARISDETAY WHERE YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID=T.ID)) THEN 'Alınan Siparişi' ELSE '' END
    )::varchar(100) AS HEDEF
  FROM TEKLIF T WHERE T.SERVISID=p_servisid

  UNION ALL
  -- SIPARIS
  SELECT S.TUR::int, S.ID::int, S.TARIH::timestamp, S.SIPARISNO::varchar(50),
    S.SIPARIS_TUTARI::numeric, S.KUR::varchar(6), S.ACIKLAMA::varchar(500),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=S.REHBERID)::varchar(750),
    (CASE WHEN (S.TUR=9)AND(412 IN (SELECT YERI FROM SIPARISDETAY WHERE SIPARISID=S.ID)) THEN 'Teklifden'
          WHEN (S.TUR=19)AND(413 IN (SELECT YERI FROM SIPARISDETAY WHERE SIPARISID=S.ID)) THEN 'Teklifden'
          ELSE '' END)::varchar(50),
    (CASE WHEN (S.TUR=9)AND(407 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID=S.ID))) THEN 'Faturaya'
          WHEN (S.TUR=9)AND(406 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID=S.ID))) THEN 'İrsaliyeye'
          WHEN (S.TUR=19)AND(410 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID=S.ID))) THEN 'Faturaya'
          WHEN (S.TUR=19)AND(409 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID=S.ID))) THEN 'İrsaliyeye'
          WHEN (S.TUR=19)AND(415 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID=S.ID))) THEN 'Üretim Fişine'
          WHEN (S.TUR=19)AND(420 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID=S.ID))) THEN 'Üretim Fişine'
          ELSE '' END)::varchar(100)
  FROM SIPARIS S WHERE S.SERVISID=p_servisid

  UNION ALL
  -- FATBASLIK
  SELECT F.TUR::int, F.ID::int, F.TARIH::timestamp, F.FATURANO::varchar(50),
    F.FATURA_TUTARI::numeric, F.KUR::varchar(6), F.ACIKLAMA::varchar(500),
    (SELECT R.FIRMA FROM REHBER R WHERE R.ID=F.REHBERID)::varchar(750),
    (CASE WHEN (F.TUR=10)AND(406 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Siparişten'
          WHEN (F.TUR=14)AND(409 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Siparişten'
          WHEN (F.TUR=11)AND(407 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Siparişten'
          WHEN (F.TUR=11)AND(408 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'İrsaliyeden'
          WHEN (F.TUR=15)AND(410 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Siparişten'
          WHEN (F.TUR=15)AND(411 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'İrsaliyeden'
          WHEN (F.TUR=11)AND(461 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Konsinyeden'
          WHEN (F.TUR=15)AND(462 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Konsinyeden'
          WHEN (F.TUR=15)AND(426 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Üretimden'
          WHEN (F.TUR=14)AND(425 IN (SELECT YERI FROM FATURA WHERE FATBASID=F.ID)) THEN 'Üretimden'
          ELSE '' END)::varchar(50),
    (CASE WHEN (F.TUR=10)AND(408 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM FATURA WHERE FATBASID=F.ID))) THEN 'Faturaya'
          WHEN (F.TUR=14)AND(411 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM FATURA WHERE FATBASID=F.ID))) THEN 'Faturaya'
          WHEN (F.TUR=109)AND(461 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM FATURA WHERE FATBASID=F.ID))) THEN 'Faturaya'
          WHEN (F.TUR=119)AND(462 IN (SELECT YERI FROM FATURA WHERE YERID IN (SELECT ID FROM FATURA WHERE FATBASID=F.ID))) THEN 'Faturaya'
          ELSE '' END)::varchar(100)
  FROM FATBASLIK F WHERE F.SERVISID=p_servisid;
$$;

-- varchar imza (app bazen ftWideString bind eder) -> integer body'ye delege
DROP FUNCTION IF EXISTS fn_prg_servis_belgeler(varchar);
CREATE OR REPLACE FUNCTION fn_prg_servis_belgeler(p_servisid varchar)
RETURNS TABLE("TUR" integer,"ID" integer,"TARIH" timestamp,"BELGENO" varchar(50),"TUTAR" numeric,
  "KUR" varchar(6),"ACIKLAMA" varchar(500),"FIRMA" varchar(750),"KAYNAK" varchar(50),"HEDEF" varchar(100))
LANGUAGE sql AS $w$
  SELECT * FROM fn_prg_servis_belgeler(nullif(p_servisid,'')::integer);
$w$;
