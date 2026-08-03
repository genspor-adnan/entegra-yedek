-- ============================================================================
-- fn_prg_teklifdiptoplami  (PG portu, TVF-per-engine)
-- MSSQL orijinali: dbo.SP_PRG_TeklifDipToplami (@TEKLIFID, @ALTERNATIFNO)
--   NOT: @ALTERNATIFNO orijinal SP'de KULLANILMIYOR; imza uyumu icin var.
-- Cagri: UTeklifWizard TOPLAMLAR -> EXEC SP -> PgSqlCevir -> select * from fn(...)
-- Teklif dip toplamlari: Toplam / Iskonto / Ara Toplam / KDV / KDV Toplam / Genel Toplam
-- ============================================================================
DROP FUNCTION IF EXISTS fn_prg_teklifdiptoplami(integer, integer);

CREATE OR REPLACE FUNCTION fn_prg_teklifdiptoplami(p_teklifid integer, p_alternatifno integer DEFAULT 1)
RETURNS TABLE(
  "TUR"          smallint,
  "ACIKLAMA"     varchar(255),
  "DEGER"        double precision,
  "KUR"          varchar(5),
  "DOVIZTUTARI"  double precision,
  "DOVIZ_KURU"   varchar(5),
  "SECILENTUTAR" double precision,
  "SECILENKUR"   varchar(5)
)
LANGUAGE plpgsql
AS $func$
DECLARE
  v_teklif_dovizi varchar(5);
  v_cariduviz     varchar(5);
  v_sayi          integer;
BEGIN
  DROP TABLE IF EXISTS pg_temp._tdt;
  CREATE TEMP TABLE _tdt (
    TUR         smallint,
    ACIKLAMA    varchar(255),
    DEGER       double precision,
    DOVIZTUTARI double precision,
    KUR         varchar(5),
    DOVIZ_KURU  varchar(5)
  ) ON COMMIT DROP;

  -- ---- TUR=1 Toplam + TUR=3 Iskonto ----------------------------------------
  INSERT INTO _tdt (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU)
  SELECT TUR,ACIKLAMA,DEGER,DOVIZDEGER,KUR,DOVIZ_KURU FROM (

    SELECT
      1::smallint AS TUR, 'Toplam'::varchar AS ACIKLAMA,
      CASE WHEN FB.KDVDURUM='Dahil'
           THEN SUM(round(round((F.BIRIMFIYAT*F.ADET)::numeric,2)*(100.0/(100.0+F.KDV)),2))
           ELSE SUM(round((F.BIRIMFIYAT*F.ADET)::numeric,2)) END AS DEGER,
      CASE WHEN FB.KDVDURUM='Dahil'
           THEN SUM(round(round(((CASE WHEN F.DOVIZ_KURU=FB.DOVIZ_KURU THEN F.DOVIZ_BIRIMFIYAT ELSE F.BIRIMFIYAT/FB.DOVIZKUR END)*F.ADET)::numeric,2)*(100.0/(100.0+F.KDV)),2))
           ELSE SUM(round(((CASE WHEN F.DOVIZ_KURU=FB.DOVIZ_KURU THEN F.DOVIZ_BIRIMFIYAT ELSE F.BIRIMFIYAT/FB.DOVIZKUR END)*F.ADET)::numeric,2)) END AS DOVIZDEGER,
      FB.KUR, FB.DOVIZ_KURU
    FROM TEKLIF FB INNER JOIN TEKLIFDETAY F ON FB.ID=F.TEKLIFID
    WHERE FB.ID=p_teklifid
    GROUP BY FB.KUR, FB.KDVDURUM, FB.DOVIZ_KURU, FB.DOVIZKUR

    UNION ALL

    SELECT
      3::smallint AS TUR,
      ('İskonto(%' ||
        CASE WHEN SUM(round(round((F.BIRIMFIYAT*F.ADET)::numeric,2)*((100.0-F.ISKONTO::numeric)/100.0)*((100.0-F.ISKONTO2::numeric)/100.0),2)) = SUM(round((F.BIRIMFIYAT*F.ADET)::numeric,2)) THEN '0'
             WHEN SUM(round((F.BIRIMFIYAT*F.ADET)::numeric,2))=0.0 THEN '0'
             ELSE round( 100*((SUM(round((F.BIRIMFIYAT*F.ADET)::numeric,2)) - SUM(round(round((F.BIRIMFIYAT*F.ADET)::numeric,2)*((100.0-F.ISKONTO::numeric)/100.0)*((100.0-F.ISKONTO2::numeric)/100.0),2))) / SUM(round((F.BIRIMFIYAT*F.ADET)::numeric,2))), 0)::int::text
        END || ')')::varchar AS ACIKLAMA,
      CASE WHEN FB.KDVDURUM='Dahil'
           THEN SUM(round(round(round((F.BIRIMFIYAT*F.ADET)::numeric,2)/(1+(F.KDV/100.0)),2)*F.ISKONTO::numeric/100.0,2))
           ELSE SUM(round((F.BIRIMFIYAT*F.ADET)::numeric,2)) - SUM(round(round((F.BIRIMFIYAT*F.ADET)::numeric,2)*((100.0-F.ISKONTO::numeric)/100.0)*((100.0-F.ISKONTO2::numeric)/100.0),2)) END AS DEGER,
      CASE WHEN FB.KDVDURUM='Dahil'
           THEN SUM(round(round(round(((CASE WHEN F.DOVIZ_KURU=FB.DOVIZ_KURU THEN F.DOVIZ_BIRIMFIYAT ELSE F.BIRIMFIYAT/FB.DOVIZKUR END)*F.ADET)::numeric,2)/(1+(F.KDV/100.0)),2)*F.ISKONTO::numeric/100.0,2))
           ELSE SUM(round(((CASE WHEN F.DOVIZ_KURU=FB.DOVIZ_KURU THEN F.DOVIZ_BIRIMFIYAT ELSE F.BIRIMFIYAT/FB.DOVIZKUR END)*F.ADET)::numeric,2)) - SUM(round(round(((CASE WHEN F.DOVIZ_KURU=FB.DOVIZ_KURU THEN F.DOVIZ_BIRIMFIYAT ELSE F.BIRIMFIYAT/FB.DOVIZKUR END)*F.ADET)::numeric,2)*((100.0-F.ISKONTO::numeric)/100.0)*((100.0-F.ISKONTO2::numeric)/100.0),2)) END AS DOVIZDEGER,
      FB.KUR, FB.DOVIZ_KURU
    FROM TEKLIF FB INNER JOIN TEKLIFDETAY F ON FB.ID=F.TEKLIFID
    WHERE FB.ID=p_teklifid
    GROUP BY FB.KUR, FB.KDVDURUM, FB.DOVIZ_KURU, FB.DOVIZKUR
  ) X;

  -- ---- TUR=4 Ara Toplam ----------------------------------------------------
  SELECT coalesce((SELECT count(*) FROM _tdt WHERE TUR IN (2,3)),0) INTO v_sayi;
  IF v_sayi>0 THEN
    INSERT INTO _tdt (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU)
    SELECT 4, 'Ara Toplam',
      SUM(CASE WHEN TUR=2 THEN DEGER WHEN TUR=3 THEN -DEGER ELSE 0.0 END),
      SUM(CASE WHEN TUR IN (1,2) THEN DOVIZTUTARI WHEN TUR=3 THEN -DOVIZTUTARI ELSE 0.0 END),
      (SELECT KUR FROM TEKLIF WHERE ID=p_teklifid),
      (SELECT DOVIZ_KURU FROM TEKLIF WHERE ID=p_teklifid)
    FROM _tdt WHERE TUR IN (1,2,3);
  END IF;

  -- ---- TUR=5 KDV satirlari -------------------------------------------------
  INSERT INTO _tdt (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU)
  SELECT 5, 'KDV%'||F.KDV::text,
    SUM(CASE WHEN FB.KDVDURUM='Dahil' THEN F.TUTAR-round((F.TUTAR*(100.0/(100.0+F.KDV)))::numeric,2)
                                      ELSE round((F.KDV*(F.TUTAR/100.0))::numeric,2) END),
    SUM(round((F.KDV*(CASE WHEN F.DOVIZ_KURU=FB.DOVIZ_KURU THEN F.DOVIZ_TUTARI ELSE F.TUTAR/FB.DOVIZKUR END)/100.0)::numeric,2)),
    FB.KUR, FB.DOVIZ_KURU
  FROM TEKLIF FB INNER JOIN TEKLIFDETAY F ON FB.ID=F.TEKLIFID
  WHERE FB.ID=p_teklifid
  GROUP BY FB.KUR, F.KDV, FB.KDVDURUM, FB.DOVIZ_KURU, FB.DOVIZKUR;

  -- ---- TUR=15 KDV Toplam ---------------------------------------------------
  INSERT INTO _tdt (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU)
  SELECT 15,'KDV Toplam',
    round(SUM(CASE WHEN TUR=5 THEN round(DEGER::numeric,2) WHEN TUR=6 THEN round(DEGER::numeric,2) ELSE 0.0 END),2),
    round(SUM(CASE WHEN TUR=5 THEN round(DOVIZTUTARI::numeric,2) WHEN TUR=6 THEN round(DOVIZTUTARI::numeric,2) ELSE 0.0 END),2),
    (SELECT KUR FROM TEKLIF WHERE ID=p_teklifid),
    (SELECT DOVIZ_KURU FROM TEKLIF WHERE ID=p_teklifid)
  FROM _tdt;

  -- ---- TUR=20 Genel Toplam -------------------------------------------------
  INSERT INTO _tdt (TUR,ACIKLAMA,DEGER,DOVIZTUTARI,KUR,DOVIZ_KURU)
  SELECT 20,'Genel Toplam',
    round(SUM(CASE WHEN TUR=1 THEN round(DEGER::numeric,2) WHEN TUR=2 THEN round(DEGER::numeric,2)
                   WHEN TUR=3 THEN -1*coalesce(round(DEGER::numeric,2),0.0) WHEN TUR=4 THEN 0.0
                   WHEN TUR=5 THEN round(DEGER::numeric,2) WHEN TUR=6 THEN round(DEGER::numeric,2)
                   WHEN TUR=7 THEN 0.0 WHEN TUR=8 THEN round(DEGER::numeric,2) WHEN TUR=9 THEN round(DEGER::numeric,2) END),2),
    round(SUM(CASE WHEN TUR=1 THEN round(DOVIZTUTARI::numeric,2) WHEN TUR=2 THEN round(DOVIZTUTARI::numeric,2)
                   WHEN TUR=3 THEN -1*coalesce(round(DOVIZTUTARI::numeric,2),0.0) WHEN TUR=4 THEN 0.0
                   WHEN TUR=5 THEN round(DOVIZTUTARI::numeric,2) WHEN TUR=6 THEN round(DOVIZTUTARI::numeric,2)
                   WHEN TUR=7 THEN 0.0 WHEN TUR=8 THEN round(DOVIZTUTARI::numeric,2) WHEN TUR=9 THEN round(DOVIZTUTARI::numeric,2) END),2),
    (SELECT KUR FROM TEKLIF WHERE ID=p_teklifid),
    (SELECT DOVIZ_KURU FROM TEKLIF WHERE ID=p_teklifid)
  FROM _tdt;

  -- ---- Sonuc (Ara Toplam yeniden hesap + secilen doviz) --------------------
  SELECT TEKLIF_DOVIZI INTO v_teklif_dovizi FROM TEKLIF WHERE ID=p_teklifid;
  SELECT coalesce(ANAHTAR,'TL') INTO v_cariduviz FROM GENINI WHERE BOLUM=-10135 LIMIT 1;
  IF v_cariduviz IS NULL THEN v_cariduviz:='TL'; END IF;

  RETURN QUERY
  SELECT
    XXX.TUR::smallint,
    XXX.ACIKLAMA::varchar(255),
    (SUM(XXX.DEGER))::double precision AS DEGER,
    XXX.KUR::varchar(5),
    (SUM(XXX.DOVIZDEGER))::double precision AS DOVIZTUTARI,
    XXX.DOVIZ_KURU::varchar(5),
    (CASE WHEN v_teklif_dovizi<>v_cariduviz THEN SUM(XXX.DOVIZDEGER) ELSE SUM(XXX.DEGER) END)::double precision AS SECILENTUTAR,
    (CASE WHEN v_teklif_dovizi<>v_cariduviz THEN XXX.DOVIZ_KURU ELSE XXX.KUR END)::varchar(5) AS SECILENKUR
  FROM (
    SELECT T.TUR, T.ACIKLAMA,
      CASE WHEN T.ACIKLAMA LIKE 'Ara Toplam%'
           THEN round( ((SELECT SUM(coalesce(round(DEGER::numeric,2),0.0)) FROM _tdt WHERE ACIKLAMA='Toplam')
                        + coalesce((SELECT SUM(round(DEGER::numeric,2)) FROM _tdt WHERE ACIKLAMA LIKE 'ÖTV%'),0.0)
                        - coalesce((SELECT SUM(round(DEGER::numeric,2)) FROM _tdt WHERE ACIKLAMA LIKE 'İsk%'),0.0)),2)
           ELSE SUM(coalesce(round(T.DEGER::numeric,2),0)) END AS DEGER,
      CASE WHEN T.ACIKLAMA LIKE 'Ara Toplam%'
           THEN round( ((SELECT SUM(round(DOVIZTUTARI::numeric,2)) FROM _tdt WHERE ACIKLAMA='Toplam')
                        + coalesce((SELECT SUM(round(DOVIZTUTARI::numeric,2)) FROM _tdt WHERE ACIKLAMA LIKE 'ÖTV%'),0.0)
                        - coalesce((SELECT SUM(coalesce(round(DOVIZTUTARI::numeric,2),0.0)) FROM _tdt WHERE ACIKLAMA LIKE 'İsk%'),0.0)),2)
           ELSE SUM(round(T.DOVIZTUTARI::numeric,2)) END AS DOVIZDEGER,
      T.KUR, T.DOVIZ_KURU
    FROM _tdt T
    GROUP BY T.TUR, T.ACIKLAMA, T.KUR, T.DOVIZ_KURU
  ) XXX
  GROUP BY XXX.TUR, XXX.ACIKLAMA, XXX.KUR, XXX.DOVIZ_KURU
  ORDER BY XXX.TUR;

END;
$func$;
