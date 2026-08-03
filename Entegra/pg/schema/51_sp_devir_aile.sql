-- ============================================================================
-- Yil-sonu devir proc-lari (PG portu, MUTASYON: INSERT INTO KASA)
-- MSSQL: Sp_Prg_Devir_{POS,Banka,Kasa,KK,Kredi} (@BasTar,@AktarilacakYil,@Kur,@DevirleriAl)
-- Cagri: UYilSonuDevirIslemleri EXEC -> PgSqlCevir -> select fn_prg_devir_x(...)
-- Her biri: Acilis devri (yil basi) + Kapanis devri (onceki yil sonu) KASA'ya insert.
--   Kaynak: KASA (ISLEMTARIHI>=BasTar, YEAR<Yil, TUR<>60-79, HESAPTURU=X, TUR<>(devirlerial?0:2))
--   grupla HESAPID,KUR,SUBEID; HAVING SUM(BORC)-SUM(ALACAK)<>0.
--   MSSQL insert kolon listesindeki "K.HESAPID" yazim hatasi -> PG'de HESAPID.
-- RETURNS integer (select fn(...) ile calisir). Yalniz yil-sonu kapanista kullanici tetikler.
-- NOT: birebir port; canli veriyle dogrulanmali.
-- ============================================================================

-- ---------------------------------------------------------------- POS ('P')
DROP FUNCTION IF EXISTS fn_prg_devir_pos(timestamp, integer, varchar, integer);
CREATE OR REPLACE FUNCTION fn_prg_devir_pos(p_bastar timestamp, p_yil integer, p_kur varchar, p_devirlerial integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE v_yb timestamp := (p_yil::text||'-01-01 00:00')::timestamp;
        v_ys timestamp := ((p_yil-1)::text||'-12-31 23:59')::timestamp;
        v_ac varchar := p_yil::text||' Yılı Açılış Devri';
        v_ka varchar := (p_yil-1)::text||' Yılı Kapanış Devri';
BEGIN
  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_yb, v_yb, HESAPID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    coalesce(KUR,p_kur), 'P', v_ac, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (SELECT K.HESAPID, K.BORC AS BORC, K.ALACAK AS ALACAK, K.KUR AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
        FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
          AND K.HESAPTURU='P' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)) X
  WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;

  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_ys, v_ys, HESAPID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    coalesce(KUR,p_kur), 'P', v_ka, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (SELECT K.HESAPID, K.ALACAK AS BORC, K.BORC AS ALACAK, K.KUR AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
        FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
          AND K.HESAPTURU='P' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)) X
  WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;
  RETURN 0;
END $$;

-- ---------------------------------------------------------------- Banka ('B')  [swap OUTER]
DROP FUNCTION IF EXISTS fn_prg_devir_banka(timestamp, integer, varchar, integer);
CREATE OR REPLACE FUNCTION fn_prg_devir_banka(p_bastar timestamp, p_yil integer, p_kur varchar, p_devirlerial integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE v_yb timestamp := (p_yil::text||'-01-01 00:00')::timestamp;
        v_ys timestamp := ((p_yil-1)::text||'-12-31 23:59')::timestamp;
        v_ac varchar := p_yil::text||' Yılı Açılış Devri';
        v_ka varchar := (p_yil-1)::text||' Yılı Kapanış Devri';
BEGIN
  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_yb, v_yb, HESAPID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    coalesce(KUR,p_kur), 'B', v_ac, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (SELECT K.HESAPID, K.BORC AS BORC, K.ALACAK AS ALACAK, K.KUR AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
        FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
          AND K.HESAPTURU='B' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)) X
  WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;

  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_ys, v_ys, HESAPID,
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    coalesce(KUR,p_kur), 'B', v_ka, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (SELECT K.HESAPID, K.BORC AS BORC, K.ALACAK AS ALACAK, K.KUR AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
        FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
          AND K.HESAPTURU='B' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)) X
  WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;
  RETURN 0;
END $$;

-- ---------------------------------------------------------------- Kredi ('R')  [ISLEMTARIHI> strict, swap OUTER]
DROP FUNCTION IF EXISTS fn_prg_devir_kredi(timestamp, integer, varchar, integer);
CREATE OR REPLACE FUNCTION fn_prg_devir_kredi(p_bastar timestamp, p_yil integer, p_kur varchar, p_devirlerial integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE v_yb timestamp := (p_yil::text||'-01-01 00:00:00')::timestamp;
        v_ys timestamp := ((p_yil-1)::text||'-12-31 23:59:59')::timestamp;
        v_ac varchar := p_yil::text||' Yılı Açılış Devri';
        v_ka varchar := (p_yil-1)::text||' Yılı Kapanış Devri';
BEGIN
  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_yb, v_yb, K.HESAPID,
    (CASE WHEN SUM(K.BORC-K.ALACAK)>0 THEN SUM(K.BORC-K.ALACAK) ELSE 0 END),
    (CASE WHEN SUM(K.ALACAK-K.BORC)>0 THEN SUM(K.ALACAK-K.BORC) ELSE 0 END),
    coalesce(K.KUR,p_kur), 'R', v_ac, coalesce(K.SUBEID,-1),
    (CASE WHEN SUM(K.BORC-K.ALACAK)>0 THEN SUM(K.BORC-K.ALACAK) ELSE SUM(K.ALACAK-K.BORC) END), coalesce(K.KUR,p_kur)
  FROM KASA K WHERE K.ISLEMTARIHI>p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
    AND K.HESAPTURU='R' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)
  GROUP BY K.HESAPID, coalesce(K.KUR,p_kur), coalesce(K.SUBEID,-1);

  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_ys, v_ys, K.HESAPID,
    (CASE WHEN SUM(K.ALACAK-K.BORC)>0 THEN SUM(K.ALACAK-K.BORC) ELSE 0 END),
    (CASE WHEN SUM(K.BORC-K.ALACAK)>0 THEN SUM(K.BORC-K.ALACAK) ELSE 0 END),
    coalesce(K.KUR,p_kur), 'R', v_ka, coalesce(K.SUBEID,-1),
    (CASE WHEN SUM(K.BORC-K.ALACAK)>0 THEN SUM(K.BORC-K.ALACAK) ELSE SUM(K.ALACAK-K.BORC) END), coalesce(K.KUR,p_kur)
  FROM KASA K WHERE K.ISLEMTARIHI>p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
    AND K.HESAPTURU='R' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)
  GROUP BY K.HESAPID, coalesce(K.KUR,p_kur), coalesce(K.SUBEID,-1);
  RETURN 0;
END $$;

-- ---------------------------------------------------------------- KK ('V')  [inner swap + EKSTREDEKULLAN]
DROP FUNCTION IF EXISTS fn_prg_devir_kk(timestamp, integer, varchar, integer);
CREATE OR REPLACE FUNCTION fn_prg_devir_kk(p_bastar timestamp, p_yil integer, p_kur varchar, p_devirlerial integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE v_yb timestamp := (p_yil::text||'-01-01 00:00')::timestamp;
        v_ys timestamp := ((p_yil-1)::text||'-12-31 23:59')::timestamp;
        v_ac varchar := p_yil::text||' Yılı Açılış Devri';
        v_ka varchar := (p_yil-1)::text||' Yılı Kapanış Devri';
BEGIN
  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_yb, v_yb, HESAPID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    coalesce(KUR,p_kur), 'V', v_ac, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (SELECT K.HESAPID,
          (CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END) AS BORC,
          (CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END) AS ALACAK,
          (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END) AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
        FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
          AND K.HESAPTURU='V' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)) X
  WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;

  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_ys, v_ys, HESAPID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    coalesce(KUR,p_kur), 'V', v_ka, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (SELECT K.HESAPID,
          (CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END) AS BORC,
          (CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END) AS ALACAK,
          (CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END) AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
        FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
          AND K.HESAPTURU='V' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)) X
  WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;
  RETURN 0;
END $$;

-- ---------------------------------------------------------------- Kasa ('K')  [KASA + FATBASLIK masraf, swap OUTER]
DROP FUNCTION IF EXISTS fn_prg_devir_kasa(timestamp, integer, varchar, integer);
CREATE OR REPLACE FUNCTION fn_prg_devir_kasa(p_bastar timestamp, p_yil integer, p_kur varchar, p_devirlerial integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE v_yb timestamp := (p_yil::text||'-01-01 00:00')::timestamp;
        v_ys timestamp := ((p_yil-1)::text||'-12-31 23:59')::timestamp;
        v_ac varchar := p_yil::text||' Yılı Açılış Devri';
        v_ka varchar := (p_yil-1)::text||' Yılı Kapanış Devri';
BEGIN
  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_yb, v_yb, HESAPID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    coalesce(KUR,p_kur), 'K', v_ac, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (
    SELECT K.HESAPID, K.BORC AS BORC, K.ALACAK AS ALACAK, K.KUR AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
    FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
      AND K.HESAPTURU='K' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)
    UNION ALL
    SELECT F.KASA AS HESAPID,
      (CASE WHEN F.TUR IN (17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END) AS BORC,
      (CASE WHEN F.TUR IN (13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END) AS ALACAK,
      (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END) AS KUR, coalesce(F.SUBEID,-1) AS SUBEID
    FROM FATBASLIK F WHERE F.FATURATARIH>=p_bastar AND extract(year from F.FATURATARIH)<p_yil AND F.TUR IN (13,17)
      AND F.REHBERID=0 AND coalesce(F.KASA,0)>0
  ) X WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;

  INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,HESAPID,BORC,ALACAK,KUR,HESAPTURU,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU)
  SELECT 2, v_ys, v_ys, HESAPID,
    (CASE WHEN SUM(ALACAK-BORC)>0 THEN SUM(ALACAK-BORC) ELSE 0 END),
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE 0 END),
    coalesce(KUR,p_kur), 'K', v_ka, SUBEID,
    (CASE WHEN SUM(BORC-ALACAK)>0 THEN SUM(BORC-ALACAK) ELSE SUM(ALACAK-BORC) END), coalesce(KUR,p_kur)
  FROM (
    SELECT K.HESAPID, K.BORC AS BORC, K.ALACAK AS ALACAK, K.KUR AS KUR, coalesce(K.SUBEID,-1) AS SUBEID
    FROM KASA K WHERE K.ISLEMTARIHI>=p_bastar AND extract(year from K.ISLEMTARIHI)<p_yil AND K.TUR NOT BETWEEN 60 AND 79
      AND K.HESAPTURU='K' AND K.TUR<>(CASE WHEN p_devirlerial=0 THEN 2 ELSE 0 END)
    UNION ALL
    SELECT F.KASA AS HESAPID,
      (CASE WHEN F.TUR IN (17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END) AS BORC,
      (CASE WHEN F.TUR IN (13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END) AS ALACAK,
      (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END) AS KUR, coalesce(F.SUBEID,-1) AS SUBEID
    FROM FATBASLIK F WHERE F.FATURATARIH>=p_bastar AND extract(year from F.FATURATARIH)<p_yil AND F.TUR IN (13,17)
      AND F.REHBERID=0 AND coalesce(F.KASA,0)>0
  ) X WHERE HESAPID>0 GROUP BY HESAPID,KUR,SUBEID HAVING (SUM(BORC)-SUM(ALACAK))<>0;
  RETURN 0;
END $$;
