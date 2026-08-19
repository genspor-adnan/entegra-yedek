-- ============================================================================
--  Gentegre AI — belge dip toplami
--  024_fn_belge_diptoplam.sql
--
--  Delphi'deki SP_PRG_FaturaDipToplami / fn_Api_Belge_DipToplam formulunun
--  Gentegre AI semasina portu. Satirlar: Toplam(1) / OTV(2) / Iskonto(3) /
--  Ara Toplam(4) / KDV(5) / Beyan(6) / Tevkifat(7) / Ek Vergi(8) / Stopaj(9) /
--  KDV Toplam(10) / Genel Toplam(11).
--
--  MATEMATIK SADELESTIRILMEDI: pass sirasi ve her CASE dali kaynakla bire-bir.
--  Kabul olcutu (plan F1-05) ayni faturanin Delphi ve web'de KURUSU KURUSUNA
--  ayni cikmasi; formulu "temizlemek" bu olcutu bozar.
--
--  GOC TUZAGI: 014 gocu FATURADOVIZI'ni NULL yerine '' olarak tasidi. COALESCE
--    bos string'i yakalamaz; belge "dovizli" sayilip doviz_kuru = 0'a bolunuyor ve
--    toplam 0 cikiyordu (10 belge). Bu yuzden her yerde COALESCE(NULLIF(x,''),'TL').
--
--  Sema eslemesi: FATBASLIK->belge, FATURA->belge_satir, ADET->adet,
--    BIRIMFIYAT->birim_fiyat, KDVDURUM->kdv_durum, FATURADOVIZI->belge_dovizi,
--    RAPORDOVIZ->rapor_dovizi, DOVIZKUR->doviz_kuru (baslik),
--    FATURA.DOVIZ_KURU->belge_satir.doviz_cinsi (satirda para birimi KODU),
--    KDVMUHAFIYETI->kdv_muafiyeti, OTVMIKTAR->otv_miktar (023'te eklendi),
--    GENINI BOLUM -24002 -> kod_liste.eski_bolum = -24002 (iskonto yuvarlama hanesi).
-- ============================================================================
\set ON_ERROR_STOP on

DROP FUNCTION IF EXISTS public.fn_belge_diptoplam(int);
CREATE FUNCTION public.fn_belge_diptoplam(p_belge_id int)
-- Cikti adlari "d_" onekli: RETURNS TABLE kolonlari belge / belge_satir
--   kolonlariyla ayni adi tasirsa PL/pgSQL "column reference is ambiguous" verir
--   (doviz_kuru hem baslikta hem cikti listesinde vardi).
RETURNS TABLE(
    d_tur           float,
    d_aciklama      varchar,
    d_deger         float,
    d_doviz_tutari  float,
    d_kur           varchar,
    d_rapor_dovizi  varchar,
    d_doviz_kuru    float,
    d_kdv_muafiyeti smallint,
    d_belge_dovizi  varchar
)
LANGUAGE plpgsql AS $$
#variable_conflict use_column
DECLARE
    v_sayi int;
    -- Iskonto yuzdesinin yuvarlanacagi hane (eski GENINI BOLUM -24002).
    v_isk_hane int;
BEGIN
    v_isk_hane := coalesce((select kd.deger from public.kod_deger kd
                              join public.kod_liste kl on kl.id = kd.liste_id
                             where kl.eski_bolum = -24002 limit 1), 2);

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
        tur, aciklama, deger, doviztutari, kur, rapordoviz, dovizkur, COALESCE(kdvmuhafiyeti,0), COALESCE(NULLIF(faturadovizi,''),'TL')
    FROM (
        SELECT
            1 AS tur, 'Toplam' AS aciklama,
            ROUND(CAST(SUM(CASE
                        WHEN COALESCE(NULLIF(FB.belge_dovizi,''),'TL') = 'TL' THEN
                            CASE WHEN kdv_durum ='Dahil' THEN (birim_fiyat*adet)*(100.0/(100.0+kdv)) ELSE (birim_fiyat*adet) END
                        ELSE
                            (CASE WHEN kdv_durum ='Dahil' THEN ((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*adet)*(100.0/(100.0+kdv)) ELSE ((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*adet) end)*FB.doviz_kuru
                    END) AS numeric(15,6)),2) AS deger,
            ROUND((CASE WHEN kdv_durum ='Dahil' THEN SUM(((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*adet)*(100.0/(100.0+kdv))) ELSE SUM(((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*adet)) end)::numeric,2) AS doviztutari,
            FB.kur AS kur,
            FB.rapor_dovizi AS rapordoviz,
            FB.doviz_kuru AS dovizkur,
            0 AS kdvmuhafiyeti,
            FB.belge_dovizi AS faturadovizi
        FROM
            public.belge FB INNER JOIN public.belge_satir F ON FB.id = F.BELGE_ID
        WHERE
            FB.id = p_belge_id
        GROUP BY FB.kur, kdv_durum, FB.rapor_dovizi, FB.doviz_tutari, FB.doviz_kuru, FB.belge_dovizi

        UNION ALL

        SELECT
            2 AS tur, 'ÖTV' AS aciklama,
            SUM(CASE WHEN otv_yuzde = 0 THEN round((adet*otv_miktar)::numeric,2) ELSE round((otv_miktar*(round((F.birim_fiyat*F.adet)::numeric,2)/100.0))::numeric,2)  END) AS deger,
            SUM(CASE WHEN otv_yuzde = 0 THEN round((adet*otv_miktar)::numeric,2) ELSE round((otv_miktar*(round((F.doviz_birim_fiyat*F.adet)::numeric,2)/100.0))::numeric,2)  END) AS doviztutari,
            FB.kur AS kur,
            FB.rapor_dovizi AS rapordoviz,
            FB.doviz_kuru AS dovizkur,
            kdv_muafiyeti AS kdvmuhafiyeti,
            COALESCE(NULLIF(FB.belge_dovizi,''),'TL') AS faturadovizi
        FROM
            public.belge FB INNER JOIN public.belge_satir F ON FB.id = F.BELGE_ID
        WHERE
            FB.id = p_belge_id
        GROUP BY FB.kur, kdv, otv_yuzde, otv_miktar, FB.kdv_durum, FB.rapor_dovizi, kdv_muafiyeti, FB.doviz_kuru, COALESCE(kdv_muafiyeti,0), FB.belge_dovizi
        HAVING ( SUM(CASE WHEN otv_yuzde =0 THEN round((adet*otv_miktar)::numeric,2) ELSE round((otv_miktar*(round((F.birim_fiyat*F.adet)::numeric,2)/100.0))::numeric,2)  END) ) > 0.01

        UNION ALL

        SELECT
            3 AS tur,
            'İskonto(%' || case
                                when SUM(round((birim_fiyat*adet)::numeric,2))=0.0 then '0'
                                else round((100.0*(
                                                    (SUM(round((birim_fiyat*adet)::numeric,2))-sum(round((round((birim_fiyat*adet)::numeric,2)*((100.0-iskonto)/100.0)*((100.0-iskonto2)/100.0))::numeric,2)))
                                                    )/(
                                                    SUM(round((birim_fiyat*adet)::numeric,2))
                                                    ))::numeric,2)::text
                            end || ')' AS aciklama,
            ROUND((CASE WHEN kdv_durum='Dahil' THEN  SUM((((birim_fiyat*adet)/(1+(kdv/100.0))) *ROUND(iskonto::numeric,v_isk_hane)/100.0))
                    ELSE sum( (birim_fiyat*adet))-sum(((birim_fiyat*adet)*((100.0-ROUND(iskonto::numeric,v_isk_hane)) / 100)*((100.0-ROUND(iskonto2::numeric,v_isk_hane)) / 100)))
                    END)::numeric,2) AS deger,
            ROUND((CASE WHEN kdv_durum='Dahil' THEN  SUM(((((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*adet)/(1+(kdv/100.0))) *ROUND(iskonto::numeric,v_isk_hane)/100.0))
                    ELSE sum(((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*adet))-sum((((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*adet)*((100.0-ROUND(iskonto::numeric,v_isk_hane)) / 100)*((100.0-ROUND(iskonto2::numeric,v_isk_hane)) / 100)))
                    END)::numeric,2) AS doviztutari,
            FB.kur AS kur,
            FB.rapor_dovizi AS rapordoviz,
            FB.doviz_kuru AS dovizkur,
            0 AS kdvmuhafiyeti,
            COALESCE(NULLIF(FB.belge_dovizi,''),'TL') AS faturadovizi
        FROM
            public.belge FB INNER JOIN public.belge_satir F ON FB.id = F.BELGE_ID
                         
        WHERE
            FB.id = p_belge_id
        GROUP BY FB.kur, kdv_durum, FB.rapor_dovizi, FB.doviz_tutari, FB.matrah, FB.doviz_kuru, FB.belge_dovizi
    ) AS X;

    -- ---- Ara Toplam (4) ----
    v_sayi := COALESCE((SELECT count(*) from tmp_toplam where tur in (2,3)),0);
    IF v_sayi > 0 THEN
        INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
        SELECT
            4 AS tur, 'Ara Toplam' AS aciklama,
            sum(CASE WHEN tur=2 THEN deger WHEN tur=3 then -deger else 0.0 end) AS deger,
            sum(CASE WHEN tur in (1,2) THEN doviztutari WHEN tur=3 then -doviztutari else 0.0 end) AS doviztutari,
            (select KUR from public.belge where ID=p_belge_id) AS kur,
            (select rapor_dovizi from public.belge where ID=p_belge_id) AS doviz_kuru,
            (select b2.doviz_kuru from public.belge b2 where b2.id = p_belge_id) AS dovizkur,
            0 AS kdvmuhafiyeti,
            (select COALESCE(NULLIF(belge_dovizi,''),'TL') from public.belge where ID=p_belge_id) AS faturadovizi
        FROM
            tmp_toplam
        WHERE
            tur in (1,2,3) and v_sayi > 0;
    END IF;

    -- ---- kdv (5) / Beyan (6) / Tevkifat (7) / Ek Vergi (8) / Stopaj (9) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
        SELECT
            5 AS tur, 'kdv%'||kdv::text AS aciklama,
            CASE
                        WHEN COALESCE(NULLIF(FB.belge_dovizi,''),'TL')  = 'TL' THEN
                            ROUND(SUM(CASE WHEN kdv_durum ='Dahil' THEN tutar-(tutar*(100.0/(100.0+kdv)))
                            when otv_miktar>0.0 then  ((tutar+((CASE WHEN F.otv_yuzde =0 THEN (adet*otv_miktar) ELSE (otv_miktar*((F.birim_fiyat*F.adet)/100.0))  END)))*kdv/100.0)
                            ELSE CAST((kdv*((((F.birim_fiyat*adet)*(100.0-ROUND(iskonto::numeric,v_isk_hane))/100))/100.0)) AS numeric(18,6)) END)::numeric,2)
                        ELSE
                            ROUND((SUM(CASE WHEN kdv_durum ='Dahil' THEN ((doviz_birim_fiyat*adet)*(100.0-ROUND(iskonto::numeric,v_isk_hane))/100)-((((doviz_birim_fiyat*adet)*(100.0-ROUND(iskonto::numeric,v_isk_hane))/100))*(100.0/(100.0+kdv)))
                                    when otv_miktar>0.0 then (((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_tutari else F.tutar/NULLIF(FB.doviz_kuru,0) end)+
                                    ((CASE WHEN F.otv_yuzde =0 THEN adet*otv_miktar ELSE (otv_miktar*(((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*F.adet)/100.0))  END)))*kdv/100.0)
                                    ELSE CAST((kdv*((case when F.doviz_cinsi=FB.rapor_dovizi then ((doviz_birim_fiyat*adet)*(100.0-ROUND(iskonto::numeric,v_isk_hane))/100) else F.tutar/NULLIF(FB.doviz_kuru,0) end)/100.0)) AS numeric(18,6))  END)::numeric),2)* FB.doviz_kuru
                    END AS deger,
            ROUND((SUM(CASE WHEN kdv_durum ='Dahil' THEN ((doviz_birim_fiyat*adet)*(100.0-ROUND(iskonto::numeric,v_isk_hane))/100)-(((doviz_birim_fiyat*adet)*(100.0-ROUND(iskonto::numeric,v_isk_hane))/100)*(100.0/(100.0+kdv)))
                                    when otv_miktar>0.0 then (((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_tutari else F.tutar/NULLIF(FB.doviz_kuru,0) end)+
                                    ((CASE WHEN F.otv_yuzde =0 THEN adet*otv_miktar ELSE (otv_miktar*(((case when F.doviz_cinsi=FB.rapor_dovizi then F.doviz_birim_fiyat else F.birim_fiyat/NULLIF(FB.doviz_kuru,0) end)*F.adet)/100.0))  END)))*kdv/100.0)
                                    ELSE CAST((kdv*((case when F.doviz_cinsi=FB.rapor_dovizi then ((doviz_birim_fiyat*adet)*(100.0-ROUND(iskonto::numeric,v_isk_hane))/100) else F.tutar/NULLIF(FB.doviz_kuru,0) end)/100.0)) AS numeric(18,6))  END)
                                    )::numeric
                                    ,2) AS doviztutari,
            FB.kur AS kur,
            FB.rapor_dovizi AS doviz_kuru,
            FB.doviz_kuru AS dovizkur,
            COALESCE(kdv_muafiyeti,0) AS kdvmuhafiyeti,
            COALESCE(NULLIF(FB.belge_dovizi,''),'TL') AS faturadovizi
        FROM
            public.belge FB INNER JOIN public.belge_satir F ON FB.id = F.BELGE_ID
                         
        WHERE
            FB.id = p_belge_id
        GROUP BY FB.kur, kdv, FB.kdv_durum, FB.rapor_dovizi, kdv_muafiyeti, FB.doviz_kuru, COALESCE(kdv_muafiyeti,0), belge_dovizi

    UNION ALL

        SELECT
            6 AS tur,
            CASE WHEN COALESCE(kdv_muafiyeti,0)=0   THEN 'kdv%'||kdv::text
                                   WHEN COALESCE(kdv_muafiyeti,0)=90 then 'kdv%'||kdv::text||' Beyan(9/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=70 then 'kdv%'||kdv::text||' Beyan(7/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=50 then 'kdv%'||kdv::text||' Beyan(5/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=30 then 'kdv%'||kdv::text||' Beyan(3/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=20 then 'kdv%'||kdv::text||' Beyan(2/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=100 then 'kdv%'||kdv::text||' Beyan(Tam)'
            end AS aciklama,
            SUM(round((CASE WHEN kdv_durum ='Dahil' THEN tutar-round((tutar*(100.0/(100.0+((kdv*(100.0-COALESCE(kdv_muafiyeti,0))/100.0)))))::numeric,2)
                         ELSE round(((kdv*(100.0-COALESCE(kdv_muafiyeti,0))/100.0)*(tutar/100.0))::numeric,2)  END)::numeric,2)) AS deger,
            (SUM(round((CASE WHEN kdv_durum ='Dahil' THEN round((tutar-(tutar*(100.0/(100.0+((kdv*(100.0-COALESCE(kdv_muafiyeti,0))/100.0))))))::numeric,2)
                                ELSE round(((kdv*(100-COALESCE(kdv_muafiyeti,0))/100.0)*(tutar/100.0))::numeric,2)  END)::numeric,2))/NULLIF(FB.doviz_kuru,0)) AS doviztutari,
            FB.kur AS kur,
            FB.rapor_dovizi AS doviz_kuru,
            FB.doviz_kuru AS dovizkur,
            kdv_muafiyeti AS kdvmuhafiyeti,
            COALESCE(NULLIF(FB.belge_dovizi,''),'TL') AS faturadovizi
        FROM
            public.belge FB INNER JOIN public.belge_satir F ON FB.id = F.BELGE_ID
        WHERE
            FB.id = p_belge_id and COALESCE(kdv_muafiyeti,0)>0
        GROUP BY FB.kur, kdv, FB.kdv_durum, FB.rapor_dovizi, kdv_muafiyeti, FB.doviz_kuru, COALESCE(kdv_muafiyeti,0), belge_dovizi

    UNION ALL

        SELECT
            7 AS tur,
            CASE WHEN COALESCE(kdv_muafiyeti,0)=0   THEN 'kdv%'||kdv::text
                                   WHEN COALESCE(kdv_muafiyeti,0)=90 then 'kdv%'||kdv::text||' Tevkifat(9/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=70 then 'kdv%'||kdv::text||' Tevkifat(7/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=50 then 'kdv%'||kdv::text||' Tevkifat(5/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=20 then 'kdv%'||kdv::text||' Tevkifat(2/10)'
                                    WHEN COALESCE(kdv_muafiyeti,0)=30 then 'kdv%'||kdv::text||' Tevkifat(3/10)'
                                   WHEN COALESCE(kdv_muafiyeti,0)=100 then 'kdv%'||kdv::text||' Tevkifat(Tam)'
            end AS aciklama,
            SUM(round((CASE WHEN kdv_durum ='Dahil' THEN tutar-round((tutar*(100.0/(100.0+((kdv*(COALESCE(kdv_muafiyeti,0))/100.0)))))::numeric,2)
                            ELSE round(((kdv*(COALESCE(kdv_muafiyeti,0))/100.0)*(tutar/100.0))::numeric,2)  END)::numeric,2)) AS deger,
            (SUM(round((CASE WHEN kdv_durum ='Dahil' THEN tutar-round((tutar*(100.0/(100.0+((kdv*(COALESCE(kdv_muafiyeti,0))/100.0)))))::numeric,2)
                                ELSE round(((kdv*(COALESCE(kdv_muafiyeti,0))/100.0)*(tutar/100.0))::numeric,2)  END)::numeric,2))/NULLIF(FB.doviz_kuru,0)) AS doviztutari,
            FB.kur AS kur,
            FB.rapor_dovizi AS doviz_kuru,
            FB.doviz_kuru AS dovizkur,
            kdv_muafiyeti AS kdvmuhafiyeti,
            COALESCE(NULLIF(FB.belge_dovizi,''),'TL') AS faturadovizi
        FROM
            public.belge FB INNER JOIN public.belge_satir F ON FB.id = F.BELGE_ID
        WHERE
            FB.id = p_belge_id and COALESCE(kdv_muafiyeti,0)>0
        GROUP BY FB.kur, kdv, FB.kdv_durum, FB.rapor_dovizi, kdv_muafiyeti, FB.doviz_kuru, COALESCE(kdv_muafiyeti,0), belge_dovizi
        HAVING SUM(round((CASE WHEN kdv_durum ='Dahil' THEN round((tutar-(tutar*(100.0/(100.0+((kdv*(COALESCE(kdv_muafiyeti,0))/100.0))))))::numeric,2)
                        ELSE round(((kdv*(COALESCE(kdv_muafiyeti,0))/100.0)*(tutar/100.0))::numeric,2) END)::numeric,2)) > 0.0

    UNION ALL

    SELECT
        case when ek_vergi < 0 then 9 else 8 end AS tur,
        case when ek_vergi < 0 then 'Stopaj' else 'Ek Vergi' end AS aciklama,
        ek_vergi AS deger,
        round((ek_vergi / NULLIF(FB.doviz_kuru,0))::numeric,2) AS doviztutari, FB.kur AS kur, FB.rapor_dovizi AS doviz_kuru, FB.doviz_kuru AS dovizkur, NULL AS kdvmuhafiyeti, COALESCE(NULLIF(FB.belge_dovizi,''),'TL') AS faturadovizi
    FROM
        public.belge FB
    WHERE
        FB.id = p_belge_id
        AND COALESCE(ek_vergi,0.0)<>0.0;

    -- ---- kdv Toplam (15) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
    SELECT 15 AS tur, 'kdv Toplam' AS aciklama,
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
            (select KUR from public.belge where ID=p_belge_id) AS kur,
            (select rapor_dovizi from public.belge where ID=p_belge_id) AS doviz_kuru,
            (select b2.doviz_kuru from public.belge b2 where b2.id = p_belge_id) AS dovizkur,
            0 AS kdvmuhafiyeti,
            (select COALESCE(NULLIF(belge_dovizi,''),'TL') from public.belge where ID=p_belge_id) AS faturadovizi
    FROM tmp_toplam;

    -- ---- Genel Toplam (20) ----
    INSERT INTO tmp_toplam (tur,aciklama,deger,doviztutari,kur,doviz_kuru,dovizkur,kdvmuhafiyeti,faturadovizi)
    SELECT 20 AS tur, 'Genel Toplam' AS aciklama,
             round(SUM( CASE
                   WHEN tur=1 AND COALESCE(NULLIF(faturadovizi,''),'TL')  = 'TL' THEN round(deger::numeric,2)
                   WHEN tur=1 AND doviz_kuru <> 'TL' THEN doviztutari*dovizkur
                   WHEN tur=2 THEN round(deger::numeric,2)
                   WHEN tur=3 AND COALESCE(NULLIF(faturadovizi,''),'TL')  = 'TL' THEN -1*COALESCE(round(deger::numeric,2),0.0)
                   WHEN tur=3 AND doviz_kuru <> 'TL'  THEN -1*(doviztutari*dovizkur)
                   WHEN tur=4 THEN 0.0
                   WHEN tur=5 and kdvmuhafiyeti=0 AND COALESCE(NULLIF(faturadovizi,''),'TL') = 'TL' THEN round(deger::numeric,2)
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
            (select KUR from public.belge where ID=p_belge_id) AS kur,
            (select rapor_dovizi from public.belge where ID=p_belge_id) AS doviz_kuru,
            (select b2.doviz_kuru from public.belge b2 where b2.id = p_belge_id) AS dovizkur,
            0 AS kdvmuhafiyeti,
            (select COALESCE(NULLIF(belge_dovizi,''),'TL') from public.belge where ID=p_belge_id) AS faturadovizi
    FROM tmp_toplam;

    -- ---- Final SELECT ----
    RETURN QUERY
    SELECT X2.tur, X2.aciklama, SUM(X2.deger)::float AS deger, SUM(X2.doviztutari)::float AS doviztutari, X2.kur, X2.doviz_kuru, X2.dovizkur, X2.kdvmuhafiyeti, X2.faturadovizi FROM (
    SELECT  T.tur AS tur, T.aciklama AS aciklama,
                 CASE
                                WHEN T.aciklama LIKE 'Ara Toplam%' AND COALESCE(NULLIF(T.faturadovizi,''),'TL') = 'TL'
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
