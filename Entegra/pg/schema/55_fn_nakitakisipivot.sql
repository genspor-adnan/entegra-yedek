-- ============================================================================
-- fn_nakitakisipivot (PG portu, TVF-per-engine)
-- MSSQL: fn_NakitAkisiPivot (@BitTar). Cok-parcali nakit akis kaynagi + Devir(tarih-basi kumulatif).
-- DOVIZ SATIS = bugunku kur (D.TARIH::date=current_date). GETDATE()->now()/current_date.
-- Devir cursor -> her distinct TARIH icin SUM(TUTAR where TARIH<d). NOT: birebir; differential dogrula.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_nakitakisipivot(timestamp);
CREATE OR REPLACE FUNCTION fn_nakitakisipivot(p_bittar timestamp)
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
    -- Butce (planlanan)
    SELECT (CASE WHEN M.GELIRMI=0 THEN 'Gider' ELSE 'Gelir' END)::varchar(50),
      (coalesce(M.KOD,'')||' '||coalesce(rtrim(M.AD),''))::varchar(200),
      make_date(B.YIL::int, B.AY::int, B.GUN::int)::timestamp,
      (CASE WHEN M.GELIRMI=0 THEN -1*B.PLANLANAN ELSE B.PLANLANAN END)::numeric
    FROM BUTCE B INNER JOIN MASRAFGELIR M ON M.ID=B.MASRAFID
    WHERE B.GOR=1
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)>=DATE '2014-01-01'
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)<=DATE '2015-01-01'
      AND make_date(B.YIL::int,B.AY::int,B.GUN::int)::timestamp>now()
    UNION ALL
    -- Alinan Cekler
    SELECT 'Gelir', 'Alınan Çekler', C.VADE::date::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN C.TUTAR
            ELSE C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR IN (130,133,138) AND C.CEKSENET=101
    UNION ALL
    -- Alinan Senetler
    SELECT 'Gelir', 'Alınan Senetler', C.VADE::date::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN C.TUTAR
            ELSE C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR IN (130,133,138) AND C.CEKSENET=121
    UNION ALL
    -- Verilen Cekler
    SELECT 'Gider', 'Verilen Çekler', C.VADE::date::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN -1*C.TUTAR
            ELSE -1*C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE (C.TUR BETWEEN 140 AND 149 OR (coalesce(C.CIROLU,0)=1 AND C.TUR BETWEEN 130 AND 139)) AND C.CEKSENET=103
    UNION ALL
    -- Verilen Senetler
    SELECT 'Gider', 'Verilen Senetler', C.VADE::date::timestamp,
      (CASE WHEN coalesce(C.KUR,'')='TL' THEN -1*C.TUTAR
            ELSE -1*C.TUTAR*(SELECT D.SATIS FROM DOVIZ D WHERE D.TARIH::date=current_date AND D.CINSI=C.KUR LIMIT 1) END)::numeric
    FROM CEKLER C WHERE C.TUR BETWEEN 140 AND 149 AND C.CEKSENET=321
    UNION ALL
    -- Tahsilat Plani (KASA TUR=61)
    SELECT 'Gelir', 'Tahsilat Planı', PLANTARIHI::date::timestamp, ABS(BORC-ALACAK)::numeric FROM KASA WHERE TUR=61
    UNION ALL
    -- Odeme Plani (KASA TUR=71)
    SELECT 'Gider', 'Ödeme Planı', PLANTARIHI::date::timestamp, (-1*ABS(BORC-ALACAK))::numeric FROM KASA WHERE TUR=71
    UNION ALL
    -- Kredi Odeme Plani
    SELECT 'Gider', 'Kredi Ödeme Planı', TARIH::date::timestamp, (-1*TAKSIT)::numeric FROM PLANKREDI
    UNION ALL
    -- POS Tahsilat Plani (KASA TUR=25 bugun)
    SELECT 'Gelir', 'POS Tahsilat Planı', (K.ISLEMTARIHI::date + 1)::timestamp,
      (SELECT CASE WHEN coalesce(PO.KOMISYON,0)=0 THEN 1*ABS(K1.BORC-K1.ALACAK)
                   ELSE ABS(K1.BORC-K1.ALACAK)-(ABS(K1.BORC-K1.ALACAK)/100.0)*PO.KOMISYON END
       FROM KASA K1 INNER JOIN POS P ON K1.HESAPID=P.ID
            LEFT JOIN POSORAN PO ON P.ID=PO.POSID AND K1.KREDIID=PO.AY
       WHERE K1.ID=K.ID)::numeric
    FROM KASA K WHERE K.TUR=25 AND K.ISLEMTARIHI::date=current_date
    UNION ALL
    -- Kredi Karti Odeme Plani
    SELECT 'Gider', 'Kredi Kartı Ödeme Planı', SOT::date::timestamp, (-1*TUTAR)::numeric FROM PLANKREDIKARTI
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
