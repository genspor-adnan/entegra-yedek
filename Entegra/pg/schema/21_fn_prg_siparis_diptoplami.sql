-- ============================================================
-- fn_prg_siparis_diptoplami — MSSQL dbo.SP_PRG_Siparis_DipToplami(@SIPARISID) PG portu
--   Siparis dip toplam satirlari (Toplam / OTV / Iskonto / Ara Toplam / KDV /
--   Ek Vergi / Stopaj / KDV Toplam / Genel Toplam).
--   @Tablo tablo-degiskeni -> TEMP TABLE tmp_toplam (ON COMMIT DROP).
--   Pass sirasi ve HER CASE dali MSSQL ile BIRE-BIR korunmustur (matematik sadelestirilmedi).
-- MSSQL->PG cevrim notlari: fn_prg_faturadiptoplami ile ayni (round(...)::numeric, NULLIF(dovizkur,0),
--   ISNULL->COALESCE, CONVERT->::text, != -> <>, LIKE aynen, ACIKLAMA UTF-8 'ÖTV'/'İskonto').
--   RETURNS TABLE kolon SIRASI app'in bekledigi sira (tur,aciklama,deger,doviztutari,kur,doviz_kuru);
--   MSSQL final SELECT KUR ile DOVIZTUTARI'yi yer degistirmis dondurur -> burada ada gore hizalandi.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prg_siparis_diptoplami(int);
CREATE FUNCTION public.fn_prg_siparis_diptoplami(p_siparisid int)
RETURNS TABLE(
    tur smallint,
    aciklama varchar,
    deger float,
    doviztutari float,
    kur varchar,
    doviz_kuru varchar
)
LANGUAGE plpgsql AS $$
#variable_conflict use_column
DECLARE
    v_sayi int;
BEGIN
    DROP TABLE IF EXISTS tmp_toplam;
    CREATE TEMP TABLE tmp_toplam (
        tur         smallint,
        aciklama    varchar(255),
        deger       float,
        doviztutari float,
        kur         varchar(5),
        doviz_kuru  varchar(5)
    ) ON COMMIT DROP;

    -- ---- Pass A: Toplam (1) / OTV (2) / Iskonto (3) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru)
    SELECT
        tur, aciklama, deger, dovizdeger, kur, rapordoviz
    FROM (
        SELECT
                1 AS tur, 'Toplam' AS aciklama,
                CASE WHEN KDVDURUM ='Dahil' THEN SUM(round((round((BIRIMFIYAT*ADET)::numeric,2)*(100.0/(100.0+KDV)))::numeric,2)) ELSE SUM(round((BIRIMFIYAT*ADET)::numeric,2)) END AS deger,
                (CASE WHEN KDVDURUM ='Dahil' THEN SUM(round((round(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)::numeric,2)*(100.0/(100.0+KDV)))::numeric,2))
                    ELSE SUM(round(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)::numeric,2))end) AS dovizdeger,
                FB.KUR AS kur,
                FB.RAPORDOVIZ AS rapordoviz
        FROM
               SIPARIS FB INNER JOIN SIPARISDETAY F ON FB.ID = F.SIPARISID
        WHERE
               FB.ID = p_siparisid
        GROUP BY FB.KUR, KDVDURUM, FB.RAPORDOVIZ, FB.DOVIZKUR

        UNION ALL
        SELECT
                2 AS tur, 'ÖTV' AS aciklama,
                SUM(CASE WHEN OTVYUZDE = 0 THEN round((ADET*OTVMIKTAR)::numeric,2) ELSE round((OTVMIKTAR*(round((F.BIRIMFIYAT*F.ADET)::numeric,2)/100.0))::numeric,2)  END) AS deger,
                SUM(CASE WHEN OTVYUZDE = 0 THEN round((ADET*OTVMIKTAR)::numeric,2) ELSE
                     round((OTVMIKTAR*(round(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*F.ADET)::numeric,2)/100.0))::numeric,2)  END) AS dovizdeger,
                FB.KUR AS kur,
                FB.RAPORDOVIZ AS rapordoviz
        FROM
              SIPARIS FB INNER JOIN SIPARISDETAY F ON FB.ID = F.SIPARISID
        WHERE
               FB.ID = p_siparisid
        GROUP BY FB.KUR, KDV, OTVYUZDE, OTVMIKTAR, FB.KDVDURUM, FB.RAPORDOVIZ, FB.DOVIZKUR
        HAVING ( SUM(CASE WHEN OTVYUZDE =0 THEN ADET*OTVMIKTAR ELSE (OTVMIKTAR*((F.BIRIMFIYAT*F.ADET)/100.0))  END) ) > 0.01

        UNION ALL

        SELECT
            3 AS tur,
            'İskonto(%'|| case when sum(round((round((BIRIMFIYAT*ADET)::numeric,2)*((100.0-ISKONTO)/100.0)*((100.0-ISKONTO2)/100.0))::numeric,2))=SUM(round((BIRIMFIYAT*ADET)::numeric,2)) then '0'
                                when SUM(round((BIRIMFIYAT*ADET)::numeric,2))=0.0 then '0'
                                else round((100*(
                                                    (SUM(round((BIRIMFIYAT*ADET)::numeric,2))-sum(round((round((BIRIMFIYAT*ADET)::numeric,2)*((100.0-ISKONTO)/100.0)*((100.0-ISKONTO2)/100.0))::numeric,2)))
                                                    )/(
                                                    SUM(round((BIRIMFIYAT*ADET)::numeric,2))
                                                    ))::numeric,0)::text
                                end || ')' AS aciklama,
            CASE WHEN KDVDURUM='Dahil' THEN  SUM(round((round((round((BIRIMFIYAT*ADET)::numeric,2)/(1+(KDV/100.0)))::numeric,2) *ISKONTO/100.0)::numeric,2))
                    ELSE sum( round((BIRIMFIYAT*ADET)::numeric,2))-sum(round((round((BIRIMFIYAT*ADET)::numeric,2)*((100.0-ISKONTO) / 100)*((100.0-ISKONTO2) / 100))::numeric,2))
                    END AS deger,
            CASE WHEN KDVDURUM='Dahil' THEN  SUM(round((round((round(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)::numeric,2)/(1+(KDV/100.0)))::numeric,2) *ISKONTO/100.0)::numeric,2))
                    ELSE sum(round(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)::numeric,2))-sum(round((round(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)::numeric,2)*((100.0-ISKONTO) / 100)*((100.0-ISKONTO2) / 100))::numeric,2))
                    END AS dovizdeger,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS rapordoviz
        FROM
            SIPARIS FB INNER JOIN SIPARISDETAY F ON FB.ID = F.SIPARISID
        WHERE
            FB.ID = p_siparisid
        GROUP BY FB.KUR, KDVDURUM, FB.RAPORDOVIZ, FB.SIPARIS_TUTARI, SIPARIS_MATRAHI, FB.DOVIZKUR
    ) AS X;

    -- ---- Ara Toplam (4) ----
    v_sayi := COALESCE((SELECT count(*) from tmp_toplam where tur in (2,3)),0);
    IF v_sayi > 0 THEN
        INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru)
        SELECT
            4 AS tur, 'Ara Toplam' AS aciklama,
            sum(CASE WHEN tur=2 THEN deger WHEN tur=3 then -deger else 0.0 end) AS deger,
            sum(CASE WHEN tur in (1,2) THEN doviztutari WHEN tur=3 then -doviztutari else 0.0 end) AS dovizdeger,
            (select KUR from SIPARIS where ID=p_siparisid) AS kur,
            (select RAPORDOVIZ from SIPARIS where ID=p_siparisid) AS doviz_kuru
        FROM
            tmp_toplam
        WHERE
            tur in (1,2,3) and v_sayi > 0;
    END IF;

    -- ---- KDV (5) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru)
        SELECT
            5 AS tur, 'KDV%'||KDV::text AS aciklama,
            SUM(CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+KDV)))::numeric,2)
                            when OTVMIKTAR>0.0 then  round(((TUTAR+((CASE WHEN F.OTVYUZDE =0 THEN round((ADET*OTVMIKTAR)::numeric,2) ELSE round((OTVMIKTAR*(round((F.BIRIMFIYAT*F.ADET)::numeric,2)/100.0))::numeric,2)  END)))*KDV/100.0)::numeric,2)
                            ELSE round((KDV*(F.TUTAR/100.0))::numeric,2)  END) AS deger,
            (SUM(round((KDV*(case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_TUTARI else F.TUTAR/NULLIF(FB.DOVIZKUR,0) end)/100.0)::numeric,2))) AS dovizdeger,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS doviz_kuru
        FROM
            SIPARIS FB INNER JOIN SIPARISDETAY F ON FB.ID = F.SIPARISID
        WHERE
            FB.ID = p_siparisid
        GROUP BY FB.KUR, KDV, FB.KDVDURUM, FB.RAPORDOVIZ, FB.DOVIZKUR;

    -- ---- Ek Vergi (8) / Stopaj (9) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru)
    SELECT
        case when EKVERGI < 0 then 9 else 8 end AS tur,
        case when EKVERGI < 0 then 'Stopaj' else 'Ek Vergi' end AS aciklama,
        EKVERGI AS deger,
        round((EKVERGI / NULLIF(FB.DOVIZKUR,0))::numeric,2) AS dovizdeger, FB.KUR AS kur, FB.RAPORDOVIZ AS doviz_kuru
    FROM
        SIPARIS FB
    WHERE
        FB.ID = p_siparisid
        AND COALESCE(EKVERGI,0.0)<>0.0;

    -- ---- KDV Toplam (15) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru)
    SELECT 15 AS tur, 'KDV Toplam' AS aciklama,
             round(SUM( CASE
                   WHEN tur=5  THEN round(deger::numeric,2)
                   WHEN tur=6 THEN round(deger::numeric,2)
                   WHEN tur=7 THEN 0.0
                   else 0.0
             END)::numeric,2) AS deger,
             round(SUM( CASE
                   WHEN tur=5  THEN round(doviztutari::numeric,2)
                   WHEN tur=6 THEN round(doviztutari::numeric,2)
                   WHEN tur=7 THEN 0.0
                   else 0.0
             END)::numeric,2) AS doviztutari,
            (select KUR from SIPARIS where ID=p_siparisid) AS kur,
            (select RAPORDOVIZ from SIPARIS where ID=p_siparisid) AS doviz_kuru
    FROM tmp_toplam;

    -- ---- Genel Toplam (20) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru)
    SELECT 20 AS tur, 'Genel Toplam' AS aciklama,
             round(SUM( CASE
                 WHEN tur=1 THEN round(deger::numeric,2)
                   WHEN tur=2 THEN round(deger::numeric,2)
                   WHEN tur=3 THEN -1*COALESCE(round(deger::numeric,2),0.0)
                   WHEN tur=4 THEN 0.0
                   WHEN tur=5 THEN round(deger::numeric,2)
                   WHEN tur=6 THEN round(deger::numeric,2)
                   WHEN tur=7 THEN 0.0
                 WHEN tur=8 THEN round(deger::numeric,2)
                   WHEN tur=9 THEN round(deger::numeric,2)
             END)::numeric,2) AS deger,
             round(SUM( CASE
                 WHEN tur=1 THEN round(doviztutari::numeric,2)
                   WHEN tur=2 THEN  round(doviztutari::numeric,2)
                   WHEN tur=3 THEN -1*COALESCE(round(doviztutari::numeric,2),0.0)
                   WHEN tur=4 THEN 0.0
                   WHEN tur=5 THEN round(doviztutari::numeric,2)
                   WHEN tur=6 THEN round(doviztutari::numeric,2)
                   WHEN tur=7 THEN 0.0
                 WHEN tur=8 THEN round(doviztutari::numeric,2)
                   WHEN tur=9 THEN round(doviztutari::numeric,2)
             END)::numeric,2) AS dovizdeger,
            (select KUR from SIPARIS where ID=p_siparisid) AS kur,
            (select RAPORDOVIZ from SIPARIS where ID=p_siparisid) AS doviz_kuru
    FROM tmp_toplam;

    -- ---- Final SELECT (RETURNS TABLE sirasina hizali: tur,aciklama,deger,doviztutari,kur,doviz_kuru) ----
    RETURN QUERY
    SELECT  X2.tur,
            X2.aciklama,
            SUM(X2.deger)::float AS deger,
            SUM(X2.dovizdeger)::float AS doviztutari,
            X2.kur,
            X2.doviz_kuru
    FROM (
            SELECT  T.tur AS tur, T.aciklama AS aciklama,
                 CASE WHEN T.aciklama LIKE 'Ara Toplam%'
                                       THEN round(( (SELECT SUM(COALESCE(round(deger::numeric,2),0.0)) FROM tmp_toplam WHERE aciklama='Toplam')
                                       + COALESCE((SELECT SUM(round(deger::numeric,2)) FROM tmp_toplam WHERE aciklama LIKE 'ÖTV%'),0.0)
                                       - COALESCE((SELECT SUM(round(deger::numeric,2)) FROM tmp_toplam WHERE aciklama LIKE 'İsk%'),0.0) )::numeric,2)
                                       ELSE SUM(COALESCE(round(T.deger::numeric,2),0)) END AS deger,
                 CASE WHEN T.aciklama LIKE 'Ara Toplam%'
                                       THEN round(( (SELECT SUM(round(doviztutari::numeric,2)) FROM tmp_toplam WHERE aciklama='Toplam')
                                       + COALESCE((SELECT SUM(round(doviztutari::numeric,2)) FROM tmp_toplam WHERE aciklama LIKE 'ÖTV%'),0.0)
                                       - COALESCE((SELECT SUM(COALESCE(round(doviztutari::numeric,2),0.0)) FROM tmp_toplam WHERE aciklama LIKE 'İsk%'),0.0) )::numeric,2)
                                       ELSE SUM(round(T.doviztutari::numeric,2)) END AS dovizdeger,
                 T.kur AS kur,
                 T.doviz_kuru AS doviz_kuru FROM tmp_toplam T
                 GROUP BY T.tur, T.aciklama, T.kur, T.doviz_kuru
    ) AS X2
    GROUP BY X2.tur, X2.aciklama, X2.kur, X2.doviz_kuru;
END;
$$;
