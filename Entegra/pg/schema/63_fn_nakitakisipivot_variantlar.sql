-- ============================================================================
-- fn_nakitakisipivot_aylik / fn_nakitakisipivot_haftalik (PG portu, TVF-per-engine)
-- MSSQL: fn_NakitAkisiPivot_Aylik / _Haftalik (@BitTar).
-- Taban fonksiyon 55_fn_nakitakisipivot.sql ile BIREBIR AYNI; TEK fark: NON-Likit
-- kaynaklarin TARIH kolonu tarih-kovasina (bucket) yuvarlanir.
--   AYLIK   : X'in ay-sonu   = (date_trunc('month',X)::date + 1 ay - 1 gun)
--   HAFTALIK: X'in hafta-sonu = ilk gelecek Pazar (MSSQL DATEFIRST=7,
--             DATEPART(WEEKDAY,X)=1 => Pazar). PG: extract(dow)=0 => Pazar.
-- Likit Kasa/Banka satirlari TARIH=current_date olarak KALIR (yuvarlanmaz).
-- Devir CTE (tarih-basi kumulatif) tabandaki ile ayni; differential dogrula.
-- ============================================================================

-- ============================================================================
-- AYLIK
-- ============================================================================
DROP FUNCTION IF EXISTS fn_nakitakisipivot_aylik(timestamp);
CREATE OR REPLACE FUNCTION fn_nakitakisipivot_aylik(p_bittar timestamp)
RETURNS TABLE("GRUP" varchar(50),"TUR" varchar(200),"TARIH" timestamp,"TUTAR" numeric)
LANGUAGE sql AS $$
WITH agg AS (
  SELECT GRUP, TUR, TARIH, SUM(TUTAR)::numeric AS TUTAR
  FROM (
    -- Likit: Kasa
    SELECT ' Likit'::varchar(50) AS GRUP, 'Kasa'::varchar(200) AS TUR, current_date::timestamp AS TARIH,
      (CASE WHEN coalesce(K1.KUR,'')='TL' THEN K1.BAKIYE
            ELSE K1.BAKIYE*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=K1.KUR LIMIT 1) END)::numeric AS TUTAR
    FROM KASALAR K1
    UNION ALL
    -- Likit: Banka
    SELECT ' Likit', 'Banka', current_date::timestamp,
      (CASE WHEN coalesce(K1.KUR,'')='TL' THEN K1.BAKIYE
            ELSE K1.BAKIYE*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=K1.KUR LIMIT 1) END)::numeric
    FROM BANKAHESAPLAR K1
    UNION ALL
    -- Butce (planlanan) -- AY-SONU
    SELECT (CASE WHEN M.GELIRMI=0 THEN 'Gider' ELSE 'Gelir' END)::varchar(50),
      (coalesce(M.KOD,'')||' '||coalesce(rtrim(M.AD),''))::varchar(200),
      (date_trunc('month', make_date(B.YIL::int, B.AY::int, B.GUN::int))::date + interval '1 month' - interval '1 day')::timestamp,
      (CASE WHEN M.GELIRMI=0 THEN -1*B.PLANLANAN ELSE B.PLANLANAN END)::numeric
    FROM BUTCE B INNER JOIN MASRAFGELIR M ON M.ID=B.MASRAFID
    WHERE B.GOR=1
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)>=DATE '2014-01-01'
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)<=DATE '2015-01-01'
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)::timestamp>now()
    UNION ALL
    -- Alinan Cekler -- AY-SONU
    SELECT 'Gelir', 'Alınan Çekler', (date_trunc('month', C.VADE)::date + interval '1 month' - interval '1 day')::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN C.TUTAR
            ELSE C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR IN (130,133,138) AND C.CEKSENET=101
    UNION ALL
    -- Alinan Senetler -- AY-SONU
    SELECT 'Gelir', 'Alınan Senetler', (date_trunc('month', C.VADE)::date + interval '1 month' - interval '1 day')::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN C.TUTAR
            ELSE C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR IN (130,133,138) AND C.CEKSENET=121
    UNION ALL
    -- Verilen Cekler -- AY-SONU
    SELECT 'Gider', 'Verilen Çekler', (date_trunc('month', C.VADE)::date + interval '1 month' - interval '1 day')::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN -1*C.TUTAR
            ELSE -1*C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE (C.TUR BETWEEN 140 AND 149 OR (coalesce(C.CIROLU,0)=1 AND C.TUR BETWEEN 130 AND 139)) AND C.CEKSENET=103
    UNION ALL
    -- Verilen Senetler -- AY-SONU
    SELECT 'Gider', 'Verilen Senetler', (date_trunc('month', C.VADE)::date + interval '1 month' - interval '1 day')::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN -1*C.TUTAR
            ELSE -1*C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR BETWEEN 140 AND 149 AND C.CEKSENET=321
    UNION ALL
    -- Tahsilat Plani (KASA TUR=61) -- AY-SONU
    SELECT 'Gelir', 'Tahsilat Planı', (date_trunc('month', PLANTARIHI)::date + interval '1 month' - interval '1 day')::timestamp, ABS(BORC-ALACAK)::numeric FROM KASA WHERE TUR=61
    UNION ALL
    -- Odeme Plani (KASA TUR=71) -- AY-SONU
    SELECT 'Gider', 'Ödeme Planı', (date_trunc('month', PLANTARIHI)::date + interval '1 month' - interval '1 day')::timestamp, (-1*ABS(BORC-ALACAK))::numeric FROM KASA WHERE TUR=71
    UNION ALL
    -- Kredi Odeme Plani -- AY-SONU
    SELECT 'Gider', 'Kredi Ödeme Planı', (date_trunc('month', TARIH)::date + interval '1 month' - interval '1 day')::timestamp, (-1*TAKSIT)::numeric FROM PLANKREDI
    UNION ALL
    -- POS Tahsilat Plani (KASA TUR=25 bugun) -- AY-SONU (X = ISLEMTARIHI+1)
    SELECT 'Gelir', 'POS Tahsilat Planı', (date_trunc('month', (K.ISLEMTARIHI::date + 1))::date + interval '1 month' - interval '1 day')::timestamp,
      (SELECT CASE WHEN coalesce(PO.KOMISYON,0)=0 THEN 1*ABS(K1.BORC-K1.ALACAK)
                   ELSE ABS(K1.BORC-K1.ALACAK)-(ABS(K1.BORC-K1.ALACAK)/100.0)*PO.KOMISYON END
       FROM KASA K1 INNER JOIN POS P ON K1.HESAPID=P.ID
            LEFT JOIN POSORAN PO ON P.ID=PO.POSID AND K1.KREDIID=PO.AY
       WHERE K1.ID=K.ID)::numeric
    FROM KASA K WHERE K.TUR=25 AND K.ISLEMTARIHI::date=current_date
    UNION ALL
    -- Kredi Karti Odeme Plani -- AY-SONU
    SELECT 'Gider', 'Kredi Kartı Ödeme Planı', (date_trunc('month', SOT)::date + interval '1 month' - interval '1 day')::timestamp, (-1*TUTAR)::numeric FROM PLANKREDIKARTI
  ) X
  WHERE TARIH>=current_date::timestamp AND TARIH<=p_bittar
  GROUP BY GRUP, TUR, TARIH
),
devir AS (
  SELECT ' Devir'::varchar(50) AS GRUP, ' Devir'::varchar(200) AS TUR, d.TARIH,
    coalesce((SELECT SUM(a.TUTAR) FROM agg a WHERE a.TARIH<d.TARIH AND a.GRUP<>' Devir'),0.0)::numeric AS TUTAR
  FROM (SELECT DISTINCT TARIH FROM agg) d
)
SELECT GRUP, TUR, TARIH, TUTAR FROM agg
UNION ALL
SELECT GRUP, TUR, TARIH, TUTAR FROM devir;
$$;

-- ============================================================================
-- HAFTALIK
-- ============================================================================
DROP FUNCTION IF EXISTS fn_nakitakisipivot_haftalik(timestamp);
CREATE OR REPLACE FUNCTION fn_nakitakisipivot_haftalik(p_bittar timestamp)
RETURNS TABLE("GRUP" varchar(50),"TUR" varchar(200),"TARIH" timestamp,"TUTAR" numeric)
LANGUAGE sql AS $$
WITH agg AS (
  SELECT GRUP, TUR, TARIH, SUM(TUTAR)::numeric AS TUTAR
  FROM (
    -- Likit: Kasa
    SELECT ' Likit'::varchar(50) AS GRUP, 'Kasa'::varchar(200) AS TUR, current_date::timestamp AS TARIH,
      (CASE WHEN coalesce(K1.KUR,'')='TL' THEN K1.BAKIYE
            ELSE K1.BAKIYE*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=K1.KUR LIMIT 1) END)::numeric AS TUTAR
    FROM KASALAR K1
    UNION ALL
    -- Likit: Banka
    SELECT ' Likit', 'Banka', current_date::timestamp,
      (CASE WHEN coalesce(K1.KUR,'')='TL' THEN K1.BAKIYE
            ELSE K1.BAKIYE*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=K1.KUR LIMIT 1) END)::numeric
    FROM BANKAHESAPLAR K1
    UNION ALL
    -- Butce (planlanan) -- HAFTA-SONU (Pazar)
    SELECT (CASE WHEN M.GELIRMI=0 THEN 'Gider' ELSE 'Gelir' END)::varchar(50),
      (coalesce(M.KOD,'')||' '||coalesce(rtrim(M.AD),''))::varchar(200),
      (CASE WHEN extract(dow from make_date(B.YIL::int, B.AY::int, B.GUN::int))=0 THEN make_date(B.YIL::int, B.AY::int, B.GUN::int)
            ELSE make_date(B.YIL::int, B.AY::int, B.GUN::int) + ((7 - extract(dow from make_date(B.YIL::int, B.AY::int, B.GUN::int)))::int) END)::timestamp,
      (CASE WHEN M.GELIRMI=0 THEN -1*B.PLANLANAN ELSE B.PLANLANAN END)::numeric
    FROM BUTCE B INNER JOIN MASRAFGELIR M ON M.ID=B.MASRAFID
    WHERE B.GOR=1
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)>=DATE '2014-01-01'
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)<=DATE '2015-01-01'
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)::timestamp>now()
    UNION ALL
    -- Alinan Cekler -- HAFTA-SONU
    SELECT 'Gelir', 'Alınan Çekler',
      (CASE WHEN extract(dow from C.VADE)=0 THEN C.VADE::date ELSE C.VADE::date + ((7 - extract(dow from C.VADE))::int) END)::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN C.TUTAR
            ELSE C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR IN (130,133,138) AND C.CEKSENET=101
    UNION ALL
    -- Alinan Senetler -- HAFTA-SONU
    SELECT 'Gelir', 'Alınan Senetler',
      (CASE WHEN extract(dow from C.VADE)=0 THEN C.VADE::date ELSE C.VADE::date + ((7 - extract(dow from C.VADE))::int) END)::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN C.TUTAR
            ELSE C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR IN (130,133,138) AND C.CEKSENET=121
    UNION ALL
    -- Verilen Cekler -- HAFTA-SONU
    SELECT 'Gider', 'Verilen Çekler',
      (CASE WHEN extract(dow from C.VADE)=0 THEN C.VADE::date ELSE C.VADE::date + ((7 - extract(dow from C.VADE))::int) END)::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN -1*C.TUTAR
            ELSE -1*C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE (C.TUR BETWEEN 140 AND 149 OR (coalesce(C.CIROLU,0)=1 AND C.TUR BETWEEN 130 AND 139)) AND C.CEKSENET=103
    UNION ALL
    -- Verilen Senetler -- HAFTA-SONU
    SELECT 'Gider', 'Verilen Senetler',
      (CASE WHEN extract(dow from C.VADE)=0 THEN C.VADE::date ELSE C.VADE::date + ((7 - extract(dow from C.VADE))::int) END)::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN -1*C.TUTAR
            ELSE -1*C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR BETWEEN 140 AND 149 AND C.CEKSENET=321
    UNION ALL
    -- Tahsilat Plani (KASA TUR=61) -- HAFTA-SONU
    SELECT 'Gelir', 'Tahsilat Planı',
      (CASE WHEN extract(dow from PLANTARIHI)=0 THEN PLANTARIHI::date ELSE PLANTARIHI::date + ((7 - extract(dow from PLANTARIHI))::int) END)::timestamp,
      ABS(BORC-ALACAK)::numeric FROM KASA WHERE TUR=61
    UNION ALL
    -- Odeme Plani (KASA TUR=71) -- HAFTA-SONU
    SELECT 'Gider', 'Ödeme Planı',
      (CASE WHEN extract(dow from PLANTARIHI)=0 THEN PLANTARIHI::date ELSE PLANTARIHI::date + ((7 - extract(dow from PLANTARIHI))::int) END)::timestamp,
      (-1*ABS(BORC-ALACAK))::numeric FROM KASA WHERE TUR=71
    UNION ALL
    -- Kredi Odeme Plani -- HAFTA-SONU
    SELECT 'Gider', 'Kredi Ödeme Planı',
      (CASE WHEN extract(dow from TARIH)=0 THEN TARIH::date ELSE TARIH::date + ((7 - extract(dow from TARIH))::int) END)::timestamp,
      (-1*TAKSIT)::numeric FROM PLANKREDI
    UNION ALL
    -- POS Tahsilat Plani (KASA TUR=25 bugun) -- HAFTA-SONU (X = ISLEMTARIHI+1)
    SELECT 'Gelir', 'POS Tahsilat Planı',
      (CASE WHEN extract(dow from (K.ISLEMTARIHI::date + 1))=0 THEN (K.ISLEMTARIHI::date + 1)
            ELSE (K.ISLEMTARIHI::date + 1) + ((7 - extract(dow from (K.ISLEMTARIHI::date + 1)))::int) END)::timestamp,
      (SELECT CASE WHEN coalesce(PO.KOMISYON,0)=0 THEN 1*ABS(K1.BORC-K1.ALACAK)
                   ELSE ABS(K1.BORC-K1.ALACAK)-(ABS(K1.BORC-K1.ALACAK)/100.0)*PO.KOMISYON END
       FROM KASA K1 INNER JOIN POS P ON K1.HESAPID=P.ID
            LEFT JOIN POSORAN PO ON P.ID=PO.POSID AND K1.KREDIID=PO.AY
       WHERE K1.ID=K.ID)::numeric
    FROM KASA K WHERE K.TUR=25 AND K.ISLEMTARIHI::date=current_date
    UNION ALL
    -- Kredi Karti Odeme Plani -- HAFTA-SONU
    SELECT 'Gider', 'Kredi Kartı Ödeme Planı',
      (CASE WHEN extract(dow from SOT)=0 THEN SOT::date ELSE SOT::date + ((7 - extract(dow from SOT))::int) END)::timestamp,
      (-1*TUTAR)::numeric FROM PLANKREDIKARTI
  ) X
  WHERE TARIH>=current_date::timestamp AND TARIH<=p_bittar
  GROUP BY GRUP, TUR, TARIH
),
devir AS (
  SELECT ' Devir'::varchar(50) AS GRUP, ' Devir'::varchar(200) AS TUR, d.TARIH,
    coalesce((SELECT SUM(a.TUTAR) FROM agg a WHERE a.TARIH<d.TARIH AND a.GRUP<>' Devir'),0.0)::numeric AS TUTAR
  FROM (SELECT DISTINCT TARIH FROM agg) d
)
SELECT GRUP, TUR, TARIH, TUTAR FROM agg
UNION ALL
SELECT GRUP, TUR, TARIH, TUTAR FROM devir;
$$;
