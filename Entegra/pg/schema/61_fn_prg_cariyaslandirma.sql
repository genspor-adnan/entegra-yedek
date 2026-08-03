-- ============================================================================
-- fn_prg_cariyaslandirma (PG portu, TVF-per-engine)
-- MSSQL: Sp_Prg_CariYaslandirma (@RehberID,@Bittar,@Kur)
-- Cari yaslandirma (FIFO borc<->alacak eslestirme, gecikme gunu/tutari).
-- MSSQL 2x ##temp (tmpAlacaklar/tmpBorclar) 4-kaynak union (KASA+FATBASLIK+CEK+SENET),
--   kumulatif window (SUM OVER ORDER BY dateadd(ms,ISLEMID,VADE)), sonra "Kalan Borc/Alacak"
--   dengeleme satiri, sonra kumulatif-ortusme JOIN'i + lag() ile ODENENTUTAR.
-- Bu portta hepsi tek SQL sorgusu (CTE): alac/borc base -> window -> tot -> dengeleme UNION
--   -> FIFO join -> lag(ODENENTUTAR) -> REHBER join.
-- Diyalekt: dateadd(ms,ISLEMID,VADE) -> VADE + ISLEMID*interval '1 millisecond';
--   TUR like '26__' -> TUR::text LIKE; top 1 -> LIMIT 1; isnull->coalesce; + concat -> ||;
--   VADE-GETDATE() -> (VADE::date - now()::date); ODEMETARIHI-VADESONU -> (::date - ::date);
--   window ORDER BY NULLS FIRST (MSSQL NULL en kucuk). EKSTREDEKULLAN bit->smallint (=1).
-- NOT: SENETLER pilot PG'de bos; birebiri canli veriyle differential dogrula.
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prg_cariyaslandirma(integer, timestamp, varchar);
CREATE OR REPLACE FUNCTION fn_prg_cariyaslandirma(p_rehberid integer, p_bittar timestamp, p_kur varchar)
RETURNS TABLE(
  "KOD" varchar(20), "FIRMA" varchar(100),
  "ISLEMTARIHI" timestamp, "VADESONU" timestamp, "ODEMETARIHI" timestamp,
  "GECIKENGUNSAYISI" integer,
  "ISLEMTURU" varchar(250), "ISLEMACIKLAMA" varchar(500),
  "ODEMETURU" varchar(250), "ODEMEACIKLAMA" varchar(500),
  "BORCTUTARI" numeric, "ODEMETUTARI" numeric, "ODENENTUTAR" numeric,
  "GECIKENTUTAR" numeric, "AGIRLIKLIGECIKME" numeric)
LANGUAGE sql AS $$
WITH
-- ===== ALACAKLAR (odemeler) =====
alac_src AS (
  -- KASA
  SELECT K.ID::integer AS ISLEMID, K.ISLEMTARIHI::timestamp AS TARIH, K.BELGENO::varchar AS no,
    (CASE WHEN K.TUR::text LIKE '26__' THEN (SELECT g.ANAHTAR||' tahsilatı ' FROM GENINI g WHERE g.BOLUM=-2329 AND 2600+g.DEGER=K.TUR LIMIT 1)
          WHEN K.TUR::text LIKE '36__' THEN (SELECT g.ANAHTAR||' ödemesi ' FROM GENINI g WHERE g.BOLUM=-2329 AND 3600+g.DEGER=K.TUR LIMIT 1)
          ELSE (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=K.TUR LIMIT 1) END)::varchar AS TURAD,
    K.ACIKLAMA::varchar AS ACIKLAMA,
    (CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END)::numeric AS ALACAK,
    (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END)::varchar AS KUR,
    K.ISLEMTARIHI::timestamp AS VADE
  FROM KASA K
  WHERE K.REHBERID=p_rehberid AND K.ALACAK-K.BORC>0.0 AND K.ISLEMTARIHI<=p_bittar
    AND ((K.TUR IN (49)) OR (K.TUR NOT BETWEEN 40 AND 79)) AND K.TUR<>2
    AND p_kur = (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END)
  UNION ALL
  -- FATBASLIK
  SELECT F.ID::integer, F.FATURATARIH::timestamp, F.FATURANO::varchar,
    (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=F.TUR LIMIT 1)::varchar,
    (CASE WHEN F.TIPI=2 THEN 'IADE '||coalesce(F.ACIKLAMA,'')
          WHEN EXISTS(SELECT 1 FROM FATURA fa WHERE fa.FATBASID=F.ID
                        AND fa.ID IN (SELECT fb.YERID FROM FATURA fb WHERE fb.REHBERID=p_rehberid AND fb.YERI IN (416,417)))
            THEN 'IADESI VAR '||coalesce(F.ACIKLAMA,'')
          ELSE coalesce(F.ACIKLAMA,'') END)::varchar,
    (CASE WHEN F.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)::numeric,
    (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END)::varchar,
    (F.FATURATARIH + coalesce(F.VADE,0)*interval '1 day')::timestamp
  FROM FATBASLIK F INNER JOIN REHBER R ON F.REHBERID=R.ID AND F.TUR IN (8,11,12,13,15,16,17) AND coalesce(F.DURUM,0)<>6
  WHERE F.FATURA_TUTARI<>0.0
    AND (CASE WHEN F.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END) > 0.0
    AND F.REHBERID=p_rehberid AND F.FATURATARIH<=p_bittar
    AND p_kur = (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END)
  UNION ALL
  -- CEK (CEKHAREKET)
  SELECT CH.ID::integer, CH.TARIH::timestamp, C.MAKBUZNO::varchar,
    (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=(CASE WHEN CH.ISLEM IN (130,141) THEN 23 ELSE 33 END) AND g.DIL=-1 LIMIT 1)::varchar,
    ((CASE WHEN CH.ISLEM IN (137,141) THEN 'IADE '
           WHEN C.ID IN (SELECT CH1.CEKSENETLERID FROM CEKHAREKET CH1 WHERE CH1.TARIH<=p_bittar AND CH1.ISLEM IN (137,141)) THEN 'IADESI VAR '
           ELSE '' END) || 'Serino:'||C.SERINO::varchar||' '||rtrim(coalesce(CH.ACIKLAMA,'')))::varchar,
    (CASE WHEN CH.ISLEM IN (130,141) THEN (CASE WHEN CH.EKSTREDEKULLAN=1 THEN CH.TUTAR ELSE coalesce(C.TUTAR,0) END) ELSE 0.0 END)::numeric,
    (CASE WHEN CH.EKSTREDEKULLAN=1 THEN CH.KUR ELSE coalesce(C.KUR,'TL') END)::varchar,
    C.VADE::timestamp
  FROM CEKLER C INNER JOIN CEKHAREKET CH ON C.ID=CH.CEKSENETLERID
  WHERE CH.ISLEM IN (130,131,132,134,137,140,141) AND C.TUTAR<>0.0 AND CH.REHBERID=p_rehberid AND CH.TARIH<=p_bittar
    AND p_kur = (CASE WHEN CH.EKSTREDEKULLAN=1 THEN CH.KUR ELSE coalesce(C.KUR,'TL') END)
  UNION ALL
  -- SENET
  SELECT C.ID::integer, C.TARIH::timestamp, C.MAKBUZNO::varchar,
    (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=C.TUR LIMIT 1)::varchar,
    C.ACIKLAMA::varchar,
    (CASE WHEN C.TUR=24 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0.0 END)::numeric,
    (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_KURU ELSE coalesce(C.KUR,'TL') END)::varchar,
    C.VADE::timestamp
  FROM SENETLER C
  WHERE C.REHBERID=p_rehberid AND C.TUTAR<>0.0
    AND (CASE WHEN C.TUR=24 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0.0 END) > 0.0
    AND C.TARIH<=p_bittar
    AND p_kur = (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_KURU ELSE coalesce(C.KUR,'TL') END)
),
alac AS (SELECT * FROM alac_src WHERE ALACAK>0.0),
alac_win AS (
  SELECT
    (TARIH + ISLEMID*interval '1 millisecond')::timestamp AS ISLEMTARIHI,
    (VADE  + ISLEMID*interval '1 millisecond')::timestamp AS VADESONU,
    TURAD AS ISLEMTURU, no AS BELGENO, ACIKLAMA, ALACAK, KUR,
    SUM(CASE WHEN ALACAK>0.0 THEN ALACAK ELSE 0.0 END)
      OVER (ORDER BY VADE + ISLEMID*interval '1 millisecond' NULLS FIRST) AS KUMULATIFALACAK,
    VADE
  FROM alac
),
-- ===== BORCLAR =====
borc_src AS (
  -- KASA
  SELECT K.ID::integer AS ISLEMID, K.ISLEMTARIHI::timestamp AS TARIH, K.BELGENO::varchar AS no,
    (CASE WHEN K.TUR::text LIKE '26__' THEN (SELECT g.ANAHTAR||' tahsilatı ' FROM GENINI g WHERE g.BOLUM=-2329 AND 2600+g.DEGER=K.TUR LIMIT 1)
          WHEN K.TUR::text LIKE '36__' THEN (SELECT g.ANAHTAR||' ödemesi ' FROM GENINI g WHERE g.BOLUM=-2329 AND 3600+g.DEGER=K.TUR LIMIT 1)
          ELSE (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=K.TUR LIMIT 1) END)::varchar AS TURAD,
    K.ACIKLAMA::varchar AS ACIKLAMA,
    (CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)::numeric AS BORC,
    (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END)::varchar AS KUR,
    K.ISLEMTARIHI::timestamp AS VADE
  FROM KASA K
  WHERE K.REHBERID=p_rehberid AND K.BORC-K.ALACAK>0.0 AND K.ISLEMTARIHI<=p_bittar
    AND ((K.TUR IN (49)) OR (K.TUR NOT BETWEEN 40 AND 79)) AND K.TUR<>2
    AND p_kur = (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END)
  UNION ALL
  -- FATBASLIK
  SELECT F.ID::integer, F.FATURATARIH::timestamp, F.FATURANO::varchar,
    (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=F.TUR LIMIT 1)::varchar,
    (CASE WHEN F.TIPI=2 THEN 'IADE '||coalesce(F.ACIKLAMA,'')
          WHEN EXISTS(SELECT 1 FROM FATURA fa WHERE fa.FATBASID=F.ID
                        AND fa.ID IN (SELECT fb.YERID FROM FATURA fb WHERE fb.REHBERID=p_rehberid AND fb.YERI IN (416,417)))
            THEN 'IADESI VAR '||coalesce(F.ACIKLAMA,'')
          ELSE coalesce(F.ACIKLAMA,'') END)::varchar,
    (CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)::numeric,
    (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END)::varchar,
    (F.FATURATARIH + coalesce(F.VADE,0)*interval '1 day')::timestamp
  FROM FATBASLIK F INNER JOIN REHBER R ON F.REHBERID=R.ID AND F.TUR IN (8,11,12,13,15,16,17) AND coalesce(F.DURUM,0)<>6
  WHERE F.FATURA_TUTARI<>0.0
    AND (CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END) > 0.0
    AND F.REHBERID=p_rehberid AND F.FATURATARIH<=p_bittar
    AND p_kur = (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END)
  UNION ALL
  -- CEK (CEKHAREKET)
  SELECT CH.ID::integer, CH.TARIH::timestamp, C.MAKBUZNO::varchar,
    (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=(CASE WHEN CH.ISLEM IN (130,141) THEN 23 ELSE 33 END) AND g.DIL=-1 LIMIT 1)::varchar,
    ((CASE WHEN CH.ISLEM IN (137,141) THEN 'IADE '
           WHEN C.ID IN (SELECT CH1.CEKSENETLERID FROM CEKHAREKET CH1 WHERE CH1.TARIH<=p_bittar AND CH1.ISLEM IN (137,141)) THEN 'IADESI VAR '
           ELSE '' END) || 'Serino:'||C.SERINO::varchar||' '||rtrim(coalesce(CH.ACIKLAMA,'')))::varchar,
    (CASE WHEN CH.ISLEM IN (140,131,132,133,134,137) THEN (CASE WHEN CH.EKSTREDEKULLAN=1 THEN CH.TUTAR ELSE coalesce(C.TUTAR,0) END) ELSE 0.0 END)::numeric,
    (CASE WHEN CH.EKSTREDEKULLAN=1 THEN CH.KUR ELSE coalesce(C.KUR,'TL') END)::varchar,
    C.VADE::timestamp
  FROM CEKLER C INNER JOIN CEKHAREKET CH ON C.ID=CH.CEKSENETLERID
  WHERE CH.ISLEM IN (130,131,132,134,137,140,141) AND C.TUTAR<>0.0
    AND (CASE WHEN CH.ISLEM IN (140,131,132,133,134,137) THEN (CASE WHEN CH.EKSTREDEKULLAN=1 THEN CH.TUTAR ELSE coalesce(C.TUTAR,0) END) ELSE 0.0 END) > 0.0
    AND CH.REHBERID=p_rehberid AND CH.TARIH<=p_bittar
    AND p_kur = (CASE WHEN CH.EKSTREDEKULLAN=1 THEN CH.KUR ELSE coalesce(C.KUR,'TL') END)
  UNION ALL
  -- SENET
  SELECT C.ID::integer, C.TARIH::timestamp, C.MAKBUZNO::varchar,
    (SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-1005 AND g.DEGER=C.TUR LIMIT 1)::varchar,
    rtrim(C.ACIKLAMA)::varchar,
    (CASE WHEN C.TUR=34 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0.0 END)::numeric,
    (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_KURU ELSE coalesce(C.KUR,'TL') END)::varchar,
    C.VADE::timestamp
  FROM SENETLER C
  WHERE C.REHBERID=p_rehberid AND C.TUTAR<>0.0
    AND (CASE WHEN C.TUR=34 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE coalesce(C.TUTAR,0) END) ELSE 0.0 END) > 0.0
    AND C.TARIH<=p_bittar
    AND p_kur = (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_KURU ELSE coalesce(C.KUR,'TL') END)
),
borc AS (SELECT * FROM borc_src WHERE BORC>0.0),
borc_win AS (
  SELECT
    (TARIH + ISLEMID*interval '1 millisecond')::timestamp AS ISLEMTARIHI,
    (VADE  + ISLEMID*interval '1 millisecond')::timestamp AS VADESONU,
    TURAD AS ISLEMTURU, no AS BELGENO, ACIKLAMA, BORC, KUR,
    SUM(CASE WHEN BORC>0.0 THEN BORC ELSE 0.0 END)
      OVER (ORDER BY VADE + ISLEMID*interval '1 millisecond' NULLS FIRST) AS KUMULATIFBORC,
    VADE
  FROM borc
),
-- ===== TOPLAMLAR + DENGELEME =====
tot AS (
  SELECT coalesce((SELECT SUM(BORC) FROM borc_win),0.0) AS totborc,
         coalesce((SELECT SUM(ALACAK) FROM alac_win),0.0) AS totalac
),
alac_all AS (
  SELECT ISLEMTARIHI, VADESONU, ISLEMTURU, BELGENO, ACIKLAMA, ALACAK, KUR, KUMULATIFALACAK, VADE FROM alac_win
  UNION ALL
  SELECT p_bittar, p_bittar, 'Kalan Borç'::varchar, '-'::varchar, 'Kalan Borç'::varchar,
         (t.totborc - t.totalac)::numeric, p_kur, t.totborc, NULL::timestamp
  FROM tot t WHERE t.totborc > t.totalac
),
borc_all AS (
  SELECT ISLEMTARIHI, VADESONU, ISLEMTURU, BELGENO, ACIKLAMA, BORC, KUR, KUMULATIFBORC, VADE FROM borc_win
  UNION ALL
  SELECT p_bittar, p_bittar, 'Kalan Alacak'::varchar, '-'::varchar, 'Kalan Alacak'::varchar,
         (t.totalac - t.totborc)::numeric, p_kur, t.totalac, NULL::timestamp
  FROM tot t WHERE t.totborc < t.totalac
),
-- ===== FIFO ORTUSME JOIN =====
joined AS (
  SELECT
    B.ISLEMTARIHI AS B_ISLEMTARIHI, B.VADESONU AS B_VADESONU,
    (B.ISLEMTURU||'('||B.BELGENO||')')::varchar AS ISLEMTURU,
    B.ACIKLAMA AS ISLEMACIKLAMA, B.BORC AS BORCTUTARI,
    A.ISLEMTARIHI AS ODEMETARIHI,
    (A.ISLEMTURU||'('||A.BELGENO||')')::varchar AS ODEMETURU,
    A.ACIKLAMA AS ODEMEACIKLAMA, A.ALACAK AS ODEMETUTARI,
    (CASE WHEN A.KUMULATIFALACAK < B.KUMULATIFBORC THEN A.KUMULATIFALACAK ELSE B.KUMULATIFBORC END) AS mincum,
    coalesce(A.VADE, B.VADE) AS VADE
  FROM alac_all A JOIN borc_all B
    ON B.KUMULATIFBORC - B.BORC < A.KUMULATIFALACAK
   AND A.KUMULATIFALACAK - A.ALACAK < B.KUMULATIFBORC
),
odn AS (
  SELECT j.*,
    (j.mincum - coalesce(lag(j.mincum) OVER (ORDER BY j.mincum), 0.0))::numeric AS ODENENTUTAR
  FROM joined j
)
SELECT
  R.KOD::varchar(20), R.FIRMA::varchar(100),
  (CASE WHEN o.ISLEMTURU='Kalan Alacak(-)' THEN o.ODEMETARIHI ELSE o.B_ISLEMTARIHI END)::timestamp AS ISLEMTARIHI,
  (CASE WHEN o.ODEMETURU='Kalan Borç(-)' OR o.ISLEMTURU='Kalan Alacak(-)' THEN o.VADE ELSE o.B_VADESONU END)::timestamp AS VADESONU,
  o.ODEMETARIHI::timestamp,
  (CASE WHEN o.ODEMETURU='Kalan Borç(-)' OR o.ISLEMTURU='Kalan Alacak(-)'
        THEN (o.VADE::date - now()::date)
        ELSE (o.ODEMETARIHI::date - o.B_VADESONU::date) END)::integer AS GECIKENGUNSAYISI,
  o.ISLEMTURU, o.ISLEMACIKLAMA, o.ODEMETURU, o.ODEMEACIKLAMA,
  o.BORCTUTARI::numeric, o.ODEMETUTARI::numeric, o.ODENENTUTAR::numeric,
  (CASE WHEN o.ODEMETURU='Kalan Borç(-)'  AND (o.VADE::date - now()::date) <= 0 THEN o.ODENENTUTAR
        WHEN o.ISLEMTURU='Kalan Alacak(-)' AND (o.VADE::date - now()::date) <= 0 THEN o.ODENENTUTAR
        ELSE 0.0 END)::numeric AS GECIKENTUTAR,
  (o.ODENENTUTAR * (o.ODEMETARIHI::date -
     (CASE WHEN o.ODEMETURU='Kalan Borç(-)' OR o.ISLEMTURU='Kalan Alacak(-)' THEN o.VADE ELSE o.B_VADESONU END)::date))::numeric AS AGIRLIKLIGECIKME
FROM odn o INNER JOIN REHBER R ON R.ID = p_rehberid;
$$;
