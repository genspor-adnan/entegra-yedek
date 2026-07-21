-- ============================================================
-- fn_prg_faturadiptoplami — MSSQL dbo.SP_PRG_FaturaDipToplami(@FATBASID) PG portu
--   Fatura dip toplam satirlari (Toplam / OTV / Iskonto / Ara Toplam / KDV /
--   Beyan / Tevkifat / Ek Vergi / Stopaj / KDV Toplam / Genel Toplam).
--   @Tablo tablo-degiskeni -> TEMP TABLE tmp_toplam (ON COMMIT DROP).
--   Pass sirasi ve HER CASE dali MSSQL ile BIRE-BIR korunmustur (matematik sadelestirilmedi).
-- MSSQL->PG cevrim notlari:
--   ISNULL->COALESCE; CONVERT(VARCHAR,KDV)->KDV::text; CAST(x AS decimal(p,s))->x::numeric(p,s);
--   ROUND(expr,n): PG'de round(double,int) YOK -> her 2-argli round argumani (...)::numeric;
--   /FB.DOVIZKUR -> /NULLIF(FB.DOVIZKUR,0) (PG'de 0'a bolme crash eder, MSSQL error; NULL'a cevrildi);
--   != -> <>; @SAYI -> v_sayi; LIKE aynen (ic literal eslesme, ILIKE DEGIL).
--   ACIKLAMA literalleri UTF-8: 'OTV'->'ÖTV', 'Iskonto'->'İskonto' (LIKE 'ÖTV%'/'İsk%' eslesmesi icin ic-tutarli).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prg_faturadiptoplami(int);
CREATE FUNCTION public.fn_prg_faturadiptoplami(p_fatbasid int)
RETURNS TABLE(
    tur float,
    aciklama varchar,
    deger float,
    doviztutari float,
    kur varchar,
    doviz_kuru varchar,
    dovizkur float,
    kdvmuhafiyeti smallint,
    faturadovizi varchar
)
LANGUAGE plpgsql AS $$
#variable_conflict use_column
DECLARE
    v_sayi int;
BEGIN
    DROP TABLE IF EXISTS tmp_toplam;
    CREATE TEMP TABLE tmp_toplam (
        tur           float,
        aciklama      varchar(255),
        deger         float,
        doviztutari   float,
        kur           varchar(5),
        doviz_kuru    varchar(5),
        dovizkur      float,
        kdvmuhafiyeti smallint,
        faturadovizi  varchar(5)
    ) ON COMMIT DROP;

    -- ---- Pass A: Toplam (1) / OTV (2) / Iskonto (3) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
    SELECT
        tur, aciklama, deger, doviztutari, kur, rapordoviz, dovizkur, COALESCE(kdvmuhafiyeti,0), COALESCE(faturadovizi,'TL')
    FROM (
        SELECT
            1 AS tur, 'Toplam' AS aciklama,
            ROUND(CAST(SUM(CASE
                        WHEN COALESCE(FB.FATURADOVIZI,'TL') = 'TL' THEN
                            CASE WHEN KDVDURUM ='Dahil' THEN (BIRIMFIYAT*ADET)*(100.0/(100.0+KDV)) ELSE (BIRIMFIYAT*ADET) END
                        ELSE
                            (CASE WHEN KDVDURUM ='Dahil' THEN ((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)*(100.0/(100.0+KDV)) ELSE ((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET) end)*FB.DOVIZKUR
                    END) AS numeric(15,6)),2) AS deger,
            ROUND((CASE WHEN KDVDURUM ='Dahil' THEN SUM(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)*(100.0/(100.0+KDV))) ELSE SUM(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)) end)::numeric,2) AS doviztutari,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS rapordoviz,
            FB.DOVIZKUR AS dovizkur,
            0 AS kdvmuhafiyeti,
            FB.FATURADOVIZI AS faturadovizi
        FROM
            FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
        WHERE
            FB.ID = p_fatbasid
        GROUP BY FB.KUR, KDVDURUM, FB.RAPORDOVIZ, FB.DOVIZ_TUTARI, FB.DOVIZKUR, FB.FATURADOVIZI

        UNION ALL

        SELECT
            2 AS tur, 'ÖTV' AS aciklama,
            SUM(CASE WHEN OTVYUZDE = 0 THEN round((ADET*OTVMIKTAR)::numeric,2) ELSE round((OTVMIKTAR*(round((F.BIRIMFIYAT*F.ADET)::numeric,2)/100.0))::numeric,2)  END) AS deger,
            SUM(CASE WHEN OTVYUZDE = 0 THEN round((ADET*OTVMIKTAR)::numeric,2) ELSE round((OTVMIKTAR*(round((F.DOVIZ_BIRIMFIYAT*F.ADET)::numeric,2)/100.0))::numeric,2)  END) AS doviztutari,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS rapordoviz,
            FB.DOVIZKUR AS dovizkur,
            KDVMUHAFIYETI AS kdvmuhafiyeti,
            COALESCE(FB.FATURADOVIZI,'TL') AS faturadovizi
        FROM
            FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
        WHERE
            FB.ID = p_fatbasid
        GROUP BY FB.KUR, KDV, OTVYUZDE, OTVMIKTAR, FB.KDVDURUM, FB.RAPORDOVIZ, KDVMUHAFIYETI, FB.DOVIZKUR, COALESCE(KDVMUHAFIYETI,0), FB.FATURADOVIZI
        HAVING ( SUM(CASE WHEN OTVYUZDE =0 THEN round((ADET*OTVMIKTAR)::numeric,2) ELSE round((OTVMIKTAR*(round((F.BIRIMFIYAT*F.ADET)::numeric,2)/100.0))::numeric,2)  END) ) > 0.01

        UNION ALL

        SELECT
            3 AS tur,
            'İskonto(%' || case
                                when SUM(round((BIRIMFIYAT*ADET)::numeric,2))=0.0 then '0'
                                else round((100.0*(
                                                    (SUM(round((BIRIMFIYAT*ADET)::numeric,2))-sum(round((round((BIRIMFIYAT*ADET)::numeric,2)*((100.0-ISKONTO)/100.0)*((100.0-ISKONTO2)/100.0))::numeric,2)))
                                                    )/(
                                                    SUM(round((BIRIMFIYAT*ADET)::numeric,2))
                                                    ))::numeric,2)::text
                            end || ')' AS aciklama,
            ROUND((CASE WHEN KDVDURUM='Dahil' THEN  SUM((((BIRIMFIYAT*ADET)/(1+(KDV/100.0))) *ROUND(ISKONTO::numeric,G.DEGER)/100.0))
                    ELSE sum( (BIRIMFIYAT*ADET))-sum(((BIRIMFIYAT*ADET)*((100.0-ROUND(ISKONTO::numeric,G.DEGER)) / 100)*((100.0-ROUND(ISKONTO2::numeric,G.DEGER)) / 100)))
                    END)::numeric,2) AS deger,
            ROUND((CASE WHEN KDVDURUM='Dahil' THEN  SUM(((((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)/(1+(KDV/100.0))) *ROUND(ISKONTO::numeric,G.DEGER)/100.0))
                    ELSE sum(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET))-sum((((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*ADET)*((100.0-ROUND(ISKONTO::numeric,G.DEGER)) / 100)*((100.0-ROUND(ISKONTO2::numeric,G.DEGER)) / 100)))
                    END)::numeric,2) AS doviztutari,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS rapordoviz,
            FB.DOVIZKUR AS dovizkur,
            0 AS kdvmuhafiyeti,
            COALESCE(FB.FATURADOVIZI,'TL') AS faturadovizi
        FROM
            FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
                         LEFT JOIN GENINI G ON G.BOLUM = -24002
        WHERE
            FB.ID = p_fatbasid
        GROUP BY FB.KUR, KDVDURUM, FB.RAPORDOVIZ, FB.DOVIZ_TUTARI, FATURA_MATRAHI, FB.DOVIZKUR, FB.FATURADOVIZI
    ) AS X;

    -- ---- Ara Toplam (4) ----
    v_sayi := COALESCE((SELECT count(*) from tmp_toplam where tur in (2,3)),0);
    IF v_sayi > 0 THEN
        INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
        SELECT
            4 AS tur, 'Ara Toplam' AS aciklama,
            sum(CASE WHEN tur=2 THEN deger WHEN tur=3 then -deger else 0.0 end) AS deger,
            sum(CASE WHEN tur in (1,2) THEN doviztutari WHEN tur=3 then -doviztutari else 0.0 end) AS doviztutari,
            (select KUR from FATBASLIK where ID=p_fatbasid) AS kur,
            (select RAPORDOVIZ from FATBASLIK where ID=p_fatbasid) AS doviz_kuru,
            (select DOVIZKUR from FATBASLIK where ID=p_fatbasid) AS dovizkur,
            0 AS kdvmuhafiyeti,
            (select COALESCE(FATURADOVIZI,'TL') from FATBASLIK where ID=p_fatbasid) AS faturadovizi
        FROM
            tmp_toplam
        WHERE
            tur in (1,2,3) and v_sayi > 0;
    END IF;

    -- ---- KDV (5) / Beyan (6) / Tevkifat (7) / Ek Vergi (8) / Stopaj (9) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
        SELECT
            5 AS tur, 'KDV%'||KDV::text AS aciklama,
            CASE
                        WHEN COALESCE(FB.FATURADOVIZI,'TL')  = 'TL' THEN
                            ROUND(SUM(CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-(TUTAR*(100.0/(100.0+KDV)))
                            when OTVMIKTAR>0.0 then  ((TUTAR+((CASE WHEN F.OTVYUZDE =0 THEN (ADET*OTVMIKTAR) ELSE (OTVMIKTAR*((F.BIRIMFIYAT*F.ADET)/100.0))  END)))*KDV/100.0)
                            ELSE CAST((KDV*((((F.BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO::numeric,G.DEGER))/100))/100.0)) AS numeric(18,6)) END)::numeric,2)
                        ELSE
                            ROUND((SUM(CASE WHEN KDVDURUM ='Dahil' THEN ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO::numeric,G.DEGER))/100)-((((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO::numeric,G.DEGER))/100))*(100.0/(100.0+KDV)))
                                    when OTVMIKTAR>0.0 then (((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_TUTARI else F.TUTAR/NULLIF(FB.DOVIZKUR,0) end)+
                                    ((CASE WHEN F.OTVYUZDE =0 THEN ADET*OTVMIKTAR ELSE (OTVMIKTAR*(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*F.ADET)/100.0))  END)))*KDV/100.0)
                                    ELSE CAST((KDV*((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO::numeric,G.DEGER))/100) else F.TUTAR/NULLIF(FB.DOVIZKUR,0) end)/100.0)) AS numeric(18,6))  END)::numeric),2)* FB.DOVIZKUR
                    END AS deger,
            ROUND((SUM(CASE WHEN KDVDURUM ='Dahil' THEN ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO::numeric,G.DEGER))/100)-(((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO::numeric,G.DEGER))/100)*(100.0/(100.0+KDV)))
                                    when OTVMIKTAR>0.0 then (((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_TUTARI else F.TUTAR/NULLIF(FB.DOVIZKUR,0) end)+
                                    ((CASE WHEN F.OTVYUZDE =0 THEN ADET*OTVMIKTAR ELSE (OTVMIKTAR*(((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then F.DOVIZ_BIRIMFIYAT else F.BIRIMFIYAT/NULLIF(FB.DOVIZKUR,0) end)*F.ADET)/100.0))  END)))*KDV/100.0)
                                    ELSE CAST((KDV*((case when F.DOVIZ_KURU=FB.RAPORDOVIZ then ((DOVIZ_BIRIMFIYAT*ADET)*(100.0-ROUND(ISKONTO::numeric,G.DEGER))/100) else F.TUTAR/NULLIF(FB.DOVIZKUR,0) end)/100.0)) AS numeric(18,6))  END)
                                    )::numeric
                                    ,2) AS doviztutari,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS doviz_kuru,
            DOVIZKUR AS dovizkur,
            COALESCE(KDVMUHAFIYETI,0) AS kdvmuhafiyeti,
            COALESCE(FB.FATURADOVIZI,'TL') AS faturadovizi
        FROM
            FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
                         LEFT JOIN GENINI G ON G.BOLUM = -24002
        WHERE
            FB.ID = p_fatbasid
        GROUP BY FB.KUR, KDV, FB.KDVDURUM, FB.RAPORDOVIZ, KDVMUHAFIYETI, FB.DOVIZKUR, COALESCE(KDVMUHAFIYETI,0), FATURADOVIZI

    UNION ALL

        SELECT
            6 AS tur,
            CASE WHEN COALESCE(KDVMUHAFIYETI,0)=0   THEN 'KDV%'||KDV::text
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=90 then 'KDV%'||KDV::text||' Beyan(9/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=70 then 'KDV%'||KDV::text||' Beyan(7/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=50 then 'KDV%'||KDV::text||' Beyan(5/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=30 then 'KDV%'||KDV::text||' Beyan(3/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=20 then 'KDV%'||KDV::text||' Beyan(2/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=100 then 'KDV%'||KDV::text||' Beyan(Tam)'
            end AS aciklama,
            SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+((KDV*(100.0-COALESCE(KDVMUHAFIYETI,0))/100.0)))))::numeric,2)
                         ELSE round(((KDV*(100.0-COALESCE(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))::numeric,2)  END)::numeric,2)) AS deger,
            (SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN round((TUTAR-(TUTAR*(100.0/(100.0+((KDV*(100.0-COALESCE(KDVMUHAFIYETI,0))/100.0))))))::numeric,2)
                                ELSE round(((KDV*(100-COALESCE(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))::numeric,2)  END)::numeric,2))/NULLIF(FB.DOVIZKUR,0)) AS doviztutari,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS doviz_kuru,
            FB.DOVIZKUR AS dovizkur,
            KDVMUHAFIYETI AS kdvmuhafiyeti,
            COALESCE(FB.FATURADOVIZI,'TL') AS faturadovizi
        FROM
            FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
        WHERE
            FB.ID = p_fatbasid and COALESCE(KDVMUHAFIYETI,0)>0
        GROUP BY FB.KUR, KDV, FB.KDVDURUM, FB.RAPORDOVIZ, KDVMUHAFIYETI, FB.DOVIZKUR, COALESCE(KDVMUHAFIYETI,0), FATURADOVIZI

    UNION ALL

        SELECT
            7 AS tur,
            CASE WHEN COALESCE(KDVMUHAFIYETI,0)=0   THEN 'KDV%'||KDV::text
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=90 then 'KDV%'||KDV::text||' Tevkifat(9/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=70 then 'KDV%'||KDV::text||' Tevkifat(7/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=50 then 'KDV%'||KDV::text||' Tevkifat(5/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=20 then 'KDV%'||KDV::text||' Tevkifat(2/10)'
                                    WHEN COALESCE(KDVMUHAFIYETI,0)=30 then 'KDV%'||KDV::text||' Tevkifat(3/10)'
                                   WHEN COALESCE(KDVMUHAFIYETI,0)=100 then 'KDV%'||KDV::text||' Tevkifat(Tam)'
            end AS aciklama,
            SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+((KDV*(COALESCE(KDVMUHAFIYETI,0))/100.0)))))::numeric,2)
                            ELSE round(((KDV*(COALESCE(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))::numeric,2)  END)::numeric,2)) AS deger,
            (SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN TUTAR-round((TUTAR*(100.0/(100.0+((KDV*(COALESCE(KDVMUHAFIYETI,0))/100.0)))))::numeric,2)
                                ELSE round(((KDV*(COALESCE(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))::numeric,2)  END)::numeric,2))/NULLIF(FB.DOVIZKUR,0)) AS doviztutari,
            FB.KUR AS kur,
            FB.RAPORDOVIZ AS doviz_kuru,
            FB.DOVIZKUR AS dovizkur,
            KDVMUHAFIYETI AS kdvmuhafiyeti,
            COALESCE(FB.FATURADOVIZI,'TL') AS faturadovizi
        FROM
            FATBASLIK FB INNER JOIN FATURA F ON FB.ID = F.FATBASID
        WHERE
            FB.ID = p_fatbasid and COALESCE(KDVMUHAFIYETI,0)>0
        GROUP BY FB.KUR, KDV, FB.KDVDURUM, FB.RAPORDOVIZ, KDVMUHAFIYETI, FB.DOVIZKUR, COALESCE(KDVMUHAFIYETI,0), FATURADOVIZI
        HAVING SUM(round((CASE WHEN KDVDURUM ='Dahil' THEN round((TUTAR-(TUTAR*(100.0/(100.0+((KDV*(COALESCE(KDVMUHAFIYETI,0))/100.0))))))::numeric,2)
                        ELSE round(((KDV*(COALESCE(KDVMUHAFIYETI,0))/100.0)*(TUTAR/100.0))::numeric,2) END)::numeric,2)) > 0.0

    UNION ALL

    SELECT
        case when EKVERGI < 0 then 9 else 8 end AS tur,
        case when EKVERGI < 0 then 'Stopaj' else 'Ek Vergi' end AS aciklama,
        EKVERGI AS deger,
        round((EKVERGI / NULLIF(FB.DOVIZKUR,0))::numeric,2) AS doviztutari, FB.KUR AS kur, FB.RAPORDOVIZ AS doviz_kuru, FB.DOVIZKUR AS dovizkur, NULL AS kdvmuhafiyeti, COALESCE(FB.FATURADOVIZI,'TL') AS faturadovizi
    FROM
        FATBASLIK FB
    WHERE
        FB.ID = p_fatbasid
        AND COALESCE(EKVERGI,0.0)<>0.0;

    -- ---- KDV Toplam (15) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
    SELECT 15 AS tur, 'KDV Toplam' AS aciklama,
             round(SUM( CASE
                   WHEN tur=5 and kdvmuhafiyeti=0 THEN round(deger::numeric,2)
                   WHEN tur=6 THEN round(deger::numeric,2)
                   WHEN tur=7 THEN 0.0
                   else 0.0
             END)::numeric,2) AS deger,
             round(SUM( CASE
                   WHEN tur=5 and kdvmuhafiyeti=0 THEN round(doviztutari::numeric,2)
                   WHEN tur=6 THEN round(doviztutari::numeric,2)
                   WHEN tur=7 THEN 0.0
                   else 0.0
             END)::numeric,2) AS doviztutari,
            (select KUR from FATBASLIK where ID=p_fatbasid) AS kur,
            (select RAPORDOVIZ from FATBASLIK where ID=p_fatbasid) AS doviz_kuru,
            (select DOVIZKUR from FATBASLIK where ID=p_fatbasid) AS dovizkur,
            0 AS kdvmuhafiyeti,
            (select COALESCE(FATURADOVIZI,'TL') from FATBASLIK where ID=p_fatbasid) AS faturadovizi
    FROM tmp_toplam;

    -- ---- Genel Toplam (20) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
    SELECT 20 AS tur, 'Genel Toplam' AS aciklama,
             round(SUM( CASE
                   WHEN tur=1 AND COALESCE(faturadovizi,'TL')  = 'TL' THEN round(deger::numeric,2)
                   WHEN tur=1 AND doviz_kuru <> 'TL' THEN doviztutari*dovizkur
                   WHEN tur=2 THEN round(deger::numeric,2)
                   WHEN tur=3 AND COALESCE(faturadovizi,'TL')  = 'TL' THEN -1*COALESCE(round(deger::numeric,2),0.0)
                   WHEN tur=3 AND doviz_kuru <> 'TL'  THEN -1*(doviztutari*dovizkur)
                   WHEN tur=4 THEN 0.0
                   WHEN tur=5 and kdvmuhafiyeti=0 AND faturadovizi = 'TL' THEN round(deger::numeric,2)
                   WHEN tur=5 and kdvmuhafiyeti=0 AND doviz_kuru <> 'TL' THEN doviztutari*dovizkur
                   WHEN tur=6 THEN round(deger::numeric,2)
                   WHEN tur=7 THEN 0.0
                   WHEN tur=8 THEN round(deger::numeric,2)
                   WHEN tur=9 THEN round(deger::numeric,2)
                   else 0.0
             END)::numeric,2) AS deger,
             round(SUM( CASE
                 WHEN tur=1 THEN round(doviztutari::numeric,2)
                   WHEN tur=2 THEN  round(doviztutari::numeric,2)
                   WHEN tur=3 THEN -1*COALESCE(round(doviztutari::numeric,2),0.0)
                   WHEN tur=4 THEN 0.0
                   WHEN tur=5 and kdvmuhafiyeti=0 THEN round(doviztutari::numeric,2)
                   WHEN tur=6 THEN round(doviztutari::numeric,2)
                   WHEN tur=7 THEN 0.0
                 WHEN tur=8 THEN round(doviztutari::numeric,2)
                   WHEN tur=9 THEN round(doviztutari::numeric,2)
                   else 0.0
             END)::numeric,2) AS doviztutari,
            (select KUR from FATBASLIK where ID=p_fatbasid) AS kur,
            (select RAPORDOVIZ from FATBASLIK where ID=p_fatbasid) AS doviz_kuru,
            (select DOVIZKUR from FATBASLIK where ID=p_fatbasid) AS dovizkur,
            0 AS kdvmuhafiyeti,
            (select COALESCE(FATURADOVIZI,'TL') from FATBASLIK where ID=p_fatbasid) AS faturadovizi
    FROM tmp_toplam;

    -- ---- Final SELECT ----
    RETURN QUERY
    SELECT X2.tur, X2.aciklama, SUM(X2.deger)::float AS deger, SUM(X2.doviztutari)::float AS doviztutari, X2.kur, X2.doviz_kuru, X2.dovizkur, X2.kdvmuhafiyeti, X2.faturadovizi FROM (
    SELECT  T.tur AS tur, T.aciklama AS aciklama,
                 CASE
                                WHEN T.aciklama LIKE 'Ara Toplam%' AND T.faturadovizi = 'TL'
                                       THEN round(( (SELECT SUM(COALESCE(round(deger::numeric,2),0.0)) FROM tmp_toplam WHERE aciklama='Toplam')
                                       + COALESCE((SELECT SUM(round(deger::numeric,2)) FROM tmp_toplam WHERE aciklama LIKE 'ÖTV%'),0.0)
                                       - COALESCE((SELECT SUM(round(deger::numeric,2)) FROM tmp_toplam WHERE aciklama LIKE 'İsk%'),0.0) )::numeric,2)
                                WHEN T.aciklama LIKE 'Ara Toplam%' AND T.doviz_kuru <> 'TL' THEN
                                        round((round(( (SELECT SUM(round(doviztutari::numeric,2)) FROM tmp_toplam WHERE aciklama='Toplam')
                                       + COALESCE((SELECT SUM(round(doviztutari::numeric,2)) FROM tmp_toplam WHERE aciklama LIKE 'ÖTV%'),0.0)
                                       - COALESCE((SELECT SUM(COALESCE(round(doviztutari::numeric,2),0.0)) FROM tmp_toplam WHERE aciklama LIKE 'İsk%'),0.0) )::numeric,2)*T.dovizkur)::numeric,2)
                                ELSE SUM(COALESCE(round(T.deger::numeric,2),0))
                            END AS deger,
                 CASE WHEN T.aciklama LIKE 'Ara Toplam%'
                                       THEN round(( (SELECT SUM(round(doviztutari::numeric,2)) FROM tmp_toplam WHERE aciklama='Toplam')
                                       + COALESCE((SELECT SUM(round(doviztutari::numeric,2)) FROM tmp_toplam WHERE aciklama LIKE 'ÖTV%'),0.0)
                                       - COALESCE((SELECT SUM(COALESCE(round(doviztutari::numeric,2),0.0)) FROM tmp_toplam WHERE aciklama LIKE 'İsk%'),0.0) )::numeric,2)
                                       ELSE SUM(round(T.doviztutari::numeric,2)) END AS doviztutari,
                 T.kur AS kur,
                 T.doviz_kuru AS doviz_kuru, T.dovizkur AS dovizkur, T.kdvmuhafiyeti AS kdvmuhafiyeti, T.faturadovizi AS faturadovizi FROM tmp_toplam T
                 GROUP BY T.tur, T.aciklama, T.kur, T.doviz_kuru, T.dovizkur, T.kdvmuhafiyeti, T.faturadovizi
    ) AS X2
    GROUP BY X2.tur, X2.aciklama, X2.kur, X2.doviz_kuru, X2.dovizkur, X2.kdvmuhafiyeti, X2.faturadovizi;
END;
$$;
