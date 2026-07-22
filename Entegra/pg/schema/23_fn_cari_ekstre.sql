-- ============================================================
-- fn_cari_ekstre — MSSQL dbo.fn_Cari_Ekstre PG portu
--   Cari (hesap) ekstresi: KASA + FATBASLIK + CEKHAREKET + SENETLER
--   hareketlerinin UNION ALL'i, ardindan KUR bazinda yuruyen bakiye,
--   sonra KUR/SUBEID bazinda "Devir" (acilis) satiri + @BasTar oncesi silme.
--
-- MSSQL cursor (per-KUR, per-SIRANO akumulasyon) yerine WINDOW fonksiyonu:
--   @AB clamplenmeden birikir; yalniz SAKLANAN kolon clamplenir
--   (ALACAKBAKIYE = case when @AB>0 then @AB else 0). Bu saf window sum:
--     run_ab = SUM(CASE WHEN tur IN(60,62..79) THEN 0 ELSE alacak-borc END)
--                OVER (PARTITION BY kur ORDER BY sirano ROWS UNBOUNDED PRECEDING)
--   alacakbakiye = GREATEST(run_ab,0) ; borcbakiye = GREATEST(run_bb,0)
--   yerelbakiye  = run_yb  (MSSQL: case when @YB<>0 then @YB else 0 = @YB).
--
--   sirano = MSSQL IDENTITY sirasi = INSERT SELECT'in ORDER BY KUR, TARIH
--   sirasi. Bakiye kolonlari PARTITION BY kur oldugundan KUR string
--   siralamasi (collation) sonucu etkilemez; kur icinde TARIH sirasi belirler.
--
-- MSSQL->PG cevrim notlari:
--   money->numeric; top 1 ... -> (SELECT ... LIMIT 1); isnull->coalesce;
--   string + -> || ; isnull(' ('+x+')','') -> coalesce(' ('||x||')','');
--   year(x) -> EXTRACT(YEAR FROM x); getdate()->now() (kullanilmiyor);
--   K.TUR like '26__' -> K.TUR::text LIKE '26__' (smallint->text);
--   F.FATURATARIH+isnull(F.VADE,0) -> F.FATURATARIH + (COALESCE(F.VADE,0)||' days')::interval;
--   NOLOCK kaldirildi. TURAD literalleri UTF-8: 'tahsilatı ' / 'ödemesi ' / 'Devir'.
--   SENETLER'de NOTLAR kolonu yok -> unqualified NOTLAR joinli REHBER.NOTLAR'a
--   baglanir (MSSQL ile ayni), acikca R.NOTLAR yazildi.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_cari_ekstre(int, timestamp, timestamp, int);
CREATE FUNCTION public.fn_cari_ekstre(
    p_rehberid int,
    p_bastar   timestamp,
    p_bittar   timestamp,
    p_turdurum int
)
RETURNS TABLE(
    sirano       integer,
    cekid        integer,
    tarih        timestamp,
    aksiyontarih timestamp,
    no           varchar,
    tur          smallint,
    baslik       varchar,
    turad        varchar,
    rehberid     integer,
    kod          varchar,
    ad           varchar,
    aciklama     varchar,
    hesapid      integer,
    hesapkodu    varchar,
    hesapadi     varchar,
    durum        smallint,
    borc         numeric,
    alacak       numeric,
    kur          varchar,
    yerelkur     numeric,
    masrafid     integer,
    masrafkod    varchar,
    masrafad     varchar,
    borcbakiye   numeric,
    alacakbakiye numeric,
    yereltutar   numeric,
    yerelbakiye  numeric,
    subeid       integer,
    vadetarihi   timestamp,
    adet         double precision,
    birim        varchar,
    birimfiyat   numeric
)
LANGUAGE plpgsql AS $$
#variable_conflict use_column
BEGIN
    DROP TABLE IF EXISTS tmp_toplam;
    CREATE TEMP TABLE tmp_toplam (
        sirano       bigint,
        cekid        integer,
        tarih        timestamp,
        aksiyontarih timestamp,
        no           varchar,
        tur          smallint,
        baslik       varchar,
        turad        varchar,
        rehberid     integer,
        kod          varchar,
        ad           varchar,
        aciklama     varchar,
        hesapid      integer,
        hesapkodu    varchar,
        hesapadi     varchar,
        durum        smallint,
        borc         numeric,
        alacak       numeric,
        kur          varchar,
        yerelkur     numeric,
        masrafid     integer,
        masrafkod    varchar,
        masrafad     varchar,
        borcbakiye   numeric,
        alacakbakiye numeric,
        yereltutar   numeric,
        yerelbakiye  numeric,
        subeid       integer,
        vadetarihi   timestamp,
        adet         double precision,
        birim        varchar,
        birimfiyat   numeric
    ) ON COMMIT DROP;

    -- ---- 1) Hareketleri topla (UNION ALL), TURDURUM filtrele, SIRANO ata ----
    INSERT INTO tmp_toplam (
        sirano, cekid, tarih, aksiyontarih, no, tur, baslik, turad, rehberid, kod, ad, aciklama,
        hesapid, hesapkodu, hesapadi, durum, borc, alacak, kur, yerelkur, masrafid, masrafkod, masrafad,
        borcbakiye, alacakbakiye, yereltutar, yerelbakiye, subeid, vadetarihi, adet, birim, birimfiyat)
    SELECT
        row_number() OVER (ORDER BY x.kur, x.tarih),
        x.cekid, x.tarih, x.aksiyontarih, x.no, x.tur, x.baslik, x.turad, x.rehberid, x.kod, x.ad, x.aciklama,
        x.hesapid, x.hesapkodu, x.hesapadi, x.durum, x.borc, x.alacak, x.kur, x.yerelkur, x.masrafid, x.masrafkod, x.masrafad,
        x.borcbakiye, x.alacakbakiye, x.yereltutar, x.yerelbakiye, x.subeid, x.vadetarihi, x.adet, x.birim, x.birimfiyat
    FROM (

        -- ============ KASA ============
        SELECT
            K.ID AS cekid,
            K.ISLEMTARIHI AS tarih,
            K.PLANTARIHI AS aksiyontarih,
            K.BELGENO AS no,
            K.TUR AS tur,
            '' AS baslik,
            CASE WHEN K.TUR::text LIKE '26__' THEN (SELECT ANAHTAR || ' tahsilatı ' FROM genini WHERE BOLUM=-2329 AND 2600+DEGER=K.TUR LIMIT 1)
                 WHEN K.TUR::text LIKE '36__' THEN (SELECT ANAHTAR || ' ödemesi ' FROM genini WHERE BOLUM=-2329 AND 3600+DEGER=K.TUR LIMIT 1)
                 ELSE (SELECT ANAHTAR FROM genini WHERE BOLUM=-1005 AND DEGER=K.TUR LIMIT 1) END AS turad,
            K.REHBERID AS rehberid,
            CASE WHEN K.REHBERID=0 THEN M.KOD ELSE R.KOD END AS kod,
            CASE WHEN K.REHBERID=0 THEN M.AD ELSE R.FIRMA END AS ad,
            K.ACIKLAMA AS aciklama,
            K.HESAPID AS hesapid,
            CASE K.HESAPTURU
                 WHEN 'B' THEN (SELECT HESAPKODU FROM bankahesaplar BH WHERE BH.ID=K.HESAPID)
                 WHEN 'H' THEN (SELECT KASAKODU FROM kasalar K2 WHERE K2.ID=K.HESAPID) || COALESCE(' ('|| (SELECT ADI FROM para_kupon PK WHERE PK.ID=K.CEKSENETID) ||')','')
                 WHEN 'K' THEN (SELECT KASAKODU FROM kasalar K2 WHERE K2.ID=K.HESAPID)
                 WHEN 'P' THEN (SELECT KODU FROM pos P WHERE P.ID=K.HESAPID)
                 WHEN 'V' THEN (SELECT KODU FROM kredikarti KK WHERE KK.ID=K.HESAPID) END AS hesapkodu,
            CASE K.HESAPTURU
                 WHEN 'B' THEN (SELECT HESAPADI FROM bankahesaplar BH WHERE BH.ID=K.HESAPID)
                 WHEN 'H' THEN (SELECT KASAADI FROM kasalar K2 WHERE K2.ID=K.HESAPID) || COALESCE(' ('|| (SELECT ADI FROM para_kupon PK WHERE PK.ID=K.CEKSENETID) ||')','')
                 WHEN 'K' THEN (SELECT KASAADI FROM kasalar K2 WHERE K2.ID=K.HESAPID)
                 WHEN 'P' THEN (SELECT ADI FROM pos P WHERE P.ID=K.HESAPID)
                 WHEN 'V' THEN (SELECT ADI FROM kredikarti KK WHERE KK.ID=K.HESAPID) END AS hesapadi,
            K.DURUM AS durum,
            CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0   THEN K.DOVIZ_TUTARI ELSE K.BORC END AS borc,
            CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END AS alacak,
            CASE WHEN K.EKSTREDEKULLAN=1 THEN K.DOVIZ_KURU ELSE K.KUR END AS kur,
            ABS(
                (CASE WHEN K.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND K.BORC>0   THEN K.DOVIZ_TUTARI
                      WHEN K.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND K.ALACAK>0 THEN -1*K.DOVIZ_TUTARI
                      ELSE K.BORC-K.ALACAK END)
                /
                CASE WHEN ((CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)-(CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END))=0 THEN 1
                     ELSE ((CASE WHEN K.EKSTREDEKULLAN=1 AND K.BORC>0 THEN K.DOVIZ_TUTARI ELSE K.BORC END)-(CASE WHEN K.EKSTREDEKULLAN=1 AND K.ALACAK>0 THEN K.DOVIZ_TUTARI ELSE K.ALACAK END)) END
            ) AS yerelkur,
            K.MASRAFID AS masrafid, M.KOD AS masrafkod, M.AD AS masrafad, 0 AS borcbakiye, 0 AS alacakbakiye,
            CASE WHEN K.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND K.BORC>0   THEN K.DOVIZ_TUTARI
                 WHEN K.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND K.ALACAK>0 THEN -1*K.DOVIZ_TUTARI
                 WHEN K.TUR=88 THEN K.DOVIZ_TUTARI
                 WHEN K.TUR=98 THEN -1*K.DOVIZ_TUTARI
                 ELSE K.BORC-K.ALACAK END AS yereltutar,
            0 AS yerelbakiye,
            K.SUBEID AS subeid,
            K.ISLEMTARIHI AS vadetarihi,
            1.0 AS adet, '' AS birim, 0.0 AS birimfiyat
        FROM kasa K
            LEFT JOIN rehber R      ON K.REHBERID=R.ID
            LEFT JOIN kasalar KS    ON KS.ID=K.HESAPID
            LEFT JOIN masrafgelir M ON M.ID=K.MASRAFID
        WHERE K.REHBERID=p_rehberid
            AND EXTRACT(YEAR FROM K.ISLEMTARIHI) >= EXTRACT(YEAR FROM p_bastar)
            AND EXTRACT(YEAR FROM K.ISLEMTARIHI) <= EXTRACT(YEAR FROM p_bittar)
            AND K.ISLEMTARIHI <= p_bittar
            AND ((K.TUR IN (49,61,71)) OR (K.TUR NOT BETWEEN 40 AND 79))

        UNION ALL

        -- ============ FATBASLIK (fatura) ============
        SELECT
            F.ID, F.FATURATARIH, F.FATURATARIH, F.FATURANO, F.TUR, F.BASLIK,
            (SELECT ANAHTAR FROM genini WHERE BOLUM=-1005 AND DEGER=F.TUR LIMIT 1),
            F.REHBERID, R.KOD, R.FIRMA, F.ACIKLAMA,
            NULL::int, NULL::varchar, NULL::varchar, F.DURUM,
            CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 WHEN F.TIPI=5 THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END,
            CASE WHEN F.TUR IN (15,16,17) THEN 0.0 WHEN F.TIPI=5 THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END,
            CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_CINSI ELSE F.KUR END,
            CASE WHEN F.TIPI=5 THEN F.DOVIZKUR ELSE
                ABS(
                    (CASE WHEN F.RAPORDOVIZ=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (15,16,17)  THEN F.DOVIZ_TUTARI
                          WHEN F.RAPORDOVIZ=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) THEN -1*F.DOVIZ_TUTARI
                          WHEN F.RAPORDOVIZ<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (15,16,17)  THEN F.FATURA_TUTARI
                          WHEN F.RAPORDOVIZ<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) THEN -1*F.FATURA_TUTARI END)
                    /
                    CASE WHEN ((CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)-(CASE WHEN F.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END))=0 THEN 1
                         ELSE ((CASE WHEN F.TUR IN (8,11,12,13) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)-(CASE WHEN F.TUR IN (15,16,17) THEN 0.0 ELSE (CASE WHEN F.EKSTREDEKULLAN=1 THEN F.DOVIZ_TUTARI ELSE F.FATURA_TUTARI END) END)) END
                ) END,
            F.MASRAFID, M.KOD, M.AD, 0, 0,
            CASE WHEN F.RAPORDOVIZ=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (15,16,17)  THEN F.DOVIZ_TUTARI
                 WHEN F.RAPORDOVIZ=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) THEN -1*F.DOVIZ_TUTARI
                 WHEN F.RAPORDOVIZ<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (15,16,17)  THEN F.FATURA_TUTARI
                 WHEN F.RAPORDOVIZ<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND F.TUR IN (8,11,12,13) THEN -1*F.FATURA_TUTARI END,
            0,
            F.SUBEID,
            F.FATURATARIH + (COALESCE(F.VADE,0)::text || ' days')::interval,
            1.0, '', 0.0
        FROM fatbaslik F
            INNER JOIN rehber R      ON F.REHBERID=R.ID AND F.TUR IN (8,11,12,13,15,16,17) AND COALESCE(F.DURUM,0)<>6
            LEFT JOIN  masrafgelir M ON M.ID=F.MASRAFID
        WHERE F.REHBERID=p_rehberid
            AND EXTRACT(YEAR FROM F.FATURATARIH) >= EXTRACT(YEAR FROM p_bastar)
            AND EXTRACT(YEAR FROM F.FATURATARIH) <= EXTRACT(YEAR FROM p_bittar)
            AND F.FATURATARIH <= p_bittar

        UNION ALL

        -- ============ CEKLER / CEKHAREKET (cek) ============
        SELECT
            C.ID, CH.TARIH, C.VADE, C.MAKBUZNO,
            (CASE WHEN CH.ISLEM BETWEEN 130 AND 139 AND C.CEKSENET=101 THEN 23
                  WHEN CH.ISLEM BETWEEN 140 AND 149 AND C.CEKSENET=103 THEN 33
                  WHEN CH.ISLEM BETWEEN 130 AND 139 AND C.CEKSENET=121 THEN 24
                  WHEN CH.ISLEM BETWEEN 140 AND 149 AND C.CEKSENET=321 THEN 34
                  ELSE 0 END)::smallint,
            '',
            (SELECT ANAHTAR FROM genini WHERE BOLUM=-1005 AND DEGER=(CASE WHEN CH.ISLEM BETWEEN 130 AND 139 AND C.CEKSENET=101 THEN 23
                  WHEN CH.ISLEM BETWEEN 140 AND 149 AND C.CEKSENET=103 THEN 33
                  WHEN CH.ISLEM BETWEEN 130 AND 139 AND C.CEKSENET=121 THEN 24
                  WHEN CH.ISLEM BETWEEN 140 AND 149 AND C.CEKSENET=321 THEN 34
                  ELSE 0 END) AND DIL=-1 LIMIT 1),
            CH.REHBERID, R.KOD, R.FIRMA,
            'Serino:'||C.SERINO::text||' '||rtrim(COALESCE(CH.ACIKLAMA,'')),
            CH.BANKAHESAPLARID, BH.HESAPKODU, BH.HESAPADI, C.DURUM,
            CASE WHEN CH.ISLEM IN (140,131,132,133,134,137) THEN CH.TUTAR ELSE 0.0 END,
            CASE WHEN CH.ISLEM IN (130,141) THEN CH.TUTAR ELSE 0.0 END,
            CH.KUR,
            CH.DOVIZ_TUTARI/CH.TUTAR,
            C.MASRAFID, M.KOD, M.AD, 0, 0,
            CASE WHEN CH.ISLEM IN (140,131,132,133,134,137) THEN CH.DOVIZ_TUTARI ELSE -1*CH.DOVIZ_TUTARI END,
            0,
            C.SUBEID, C.VADE,
            1.0, '', 0.0
        FROM cekler C
            INNER JOIN cekhareket CH  ON C.ID=CH.CEKSENETLERID
            LEFT JOIN  rehber R       ON CH.REHBERID=R.ID
            LEFT JOIN  bankahesaplar BH ON CH.BANKAHESAPLARID=BH.ID
            LEFT JOIN  masrafgelir M  ON M.ID=C.MASRAFID
        WHERE CH.ISLEM IN (130,131,132,134,137,140,141)
            AND CH.REHBERID=p_rehberid
            AND EXTRACT(YEAR FROM CH.TARIH) >= EXTRACT(YEAR FROM p_bastar)
            AND EXTRACT(YEAR FROM CH.TARIH) <= EXTRACT(YEAR FROM p_bittar)
            AND CH.TARIH <= p_bittar

        UNION ALL

        -- ============ SENETLER (senet) ============
        SELECT
            C.ID, C.TARIH, C.VADE, C.MAKBUZNO, C.TUR, '',
            (SELECT ANAHTAR FROM genini WHERE BOLUM=-1005 AND DEGER=C.TUR LIMIT 1),
            C.REHBERID, R.KOD, R.FIRMA,
            rtrim(R.NOTLAR),
            NULL::int, NULL::varchar, NULL::varchar, C.DURUM,
            CASE WHEN C.TUR=34 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE COALESCE(C.TUTAR,0) END) ELSE 0 END,
            CASE WHEN C.TUR=24 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE COALESCE(C.TUTAR,0) END) ELSE 0 END,
            CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_KURU ELSE COALESCE(C.KUR,'TL') END,
            ABS(
                (CASE WHEN C.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=34 THEN C.DOVIZ_TUTARI
                      WHEN C.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=24 THEN -1*C.DOVIZ_TUTARI
                      WHEN C.DOVIZ_KURU<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=34 THEN C.TUTAR
                      WHEN C.DOVIZ_KURU<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=24 THEN -1*C.TUTAR END)
                /
                ((CASE WHEN C.TUR=34 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE COALESCE(C.TUTAR,0) END) ELSE 0 END)-(CASE WHEN C.TUR=24 THEN (CASE WHEN C.EKSTREDEKULLAN=1 THEN C.DOVIZ_TUTARI ELSE COALESCE(C.TUTAR,0) END) ELSE 0 END))
            ),
            C.MASRAFID, M.KOD, M.AD, 0, 0,
            CASE WHEN C.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=34 THEN C.DOVIZ_TUTARI
                 WHEN C.DOVIZ_KURU=(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=24 THEN -1*C.DOVIZ_TUTARI
                 WHEN C.DOVIZ_KURU<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=34 THEN C.TUTAR
                 WHEN C.DOVIZ_KURU<>(SELECT ANAHTAR FROM genini WHERE BOLUM=-10135) AND C.TUR=24 THEN -1*C.TUTAR END,
            0,
            C.SUBEID, C.VADE,
            1.0, '', 0.0
        FROM senetler C
            INNER JOIN rehber R      ON C.REHBERID=R.ID
            LEFT JOIN  masrafgelir M ON M.ID=C.MASRAFID
        WHERE C.REHBERID=p_rehberid
            AND EXTRACT(YEAR FROM C.TARIH) >= EXTRACT(YEAR FROM p_bastar)
            AND EXTRACT(YEAR FROM C.TARIH) <= EXTRACT(YEAR FROM p_bittar)
            AND C.TARIH <= p_bittar

    ) AS x
    WHERE (CASE WHEN x.tur IN (61,71) THEN 1 ELSE 0 END) = p_turdurum;

    -- ---- 2) KUR bazinda yuruyen bakiye (cursor -> window sum) ----
    UPDATE tmp_toplam t SET
        alacakbakiye = GREATEST(s.run_ab, 0),
        borcbakiye   = GREATEST(s.run_bb, 0),
        yerelbakiye  = s.run_yb
    FROM (
        SELECT sirano,
            SUM(CASE WHEN tur IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) THEN 0 ELSE alacak-borc END)
                OVER (PARTITION BY kur ORDER BY sirano ROWS UNBOUNDED PRECEDING) AS run_ab,
            SUM(CASE WHEN tur IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) THEN 0 ELSE borc-alacak END)
                OVER (PARTITION BY kur ORDER BY sirano ROWS UNBOUNDED PRECEDING) AS run_bb,
            SUM(CASE WHEN tur IN (60,62,63,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79) THEN 0 ELSE yereltutar END)
                OVER (PARTITION BY kur ORDER BY sirano ROWS UNBOUNDED PRECEDING) AS run_yb
        FROM tmp_toplam
    ) s
    WHERE t.sirano = s.sirano;

    -- ---- 3) Devir (acilis) satiri: KUR/SUBEID bazinda @BasTar oncesi toplam ----
    INSERT INTO tmp_toplam (
        sirano, cekid, tarih, aksiyontarih, no, tur, baslik, turad, rehberid, kod, ad, aciklama,
        hesapid, hesapkodu, hesapadi, durum, borc, alacak, yereltutar, kur, yerelkur, masrafid, masrafkod, masrafad,
        borcbakiye, alacakbakiye, yerelbakiye, subeid, vadetarihi)
    SELECT
        (SELECT COALESCE(MAX(sirano),0) FROM tmp_toplam) + row_number() OVER (ORDER BY kur, subeid),
        0, p_bastar, p_bastar, NULL, 2, '', 'Devir', 0, '', '', 'Devir',
        NULL, NULL, NULL, 1, sum(borc), sum(alacak), sum(yereltutar), kur, NULL, 0, '', '',
        CASE WHEN sum(borc-alacak)>0 THEN sum(borc-alacak) ELSE 0 END,
        CASE WHEN sum(alacak-borc)>0 THEN sum(alacak-borc) ELSE 0 END,
        CASE WHEN sum(yereltutar)>0  THEN sum(yereltutar)  ELSE 0 END,
        subeid, p_bastar
    FROM tmp_toplam
    WHERE ((tur IN (40,42,49,61,71)) OR (tur NOT BETWEEN 40 AND 79)) AND tarih < p_bastar
    GROUP BY kur, subeid;

    -- ---- 4) @BasTar oncesi hareketleri sil (Devir tarih=@BasTar, korunur) ----
    DELETE FROM tmp_toplam WHERE tarih < p_bastar;

    -- ---- 5) Sonuc ----
    RETURN QUERY
    SELECT
        t.sirano::integer, t.cekid, t.tarih, t.aksiyontarih, t.no, t.tur, t.baslik, t.turad, t.rehberid, t.kod, t.ad, t.aciklama,
        t.hesapid, t.hesapkodu, t.hesapadi, t.durum, t.borc, t.alacak, t.kur, t.yerelkur, t.masrafid, t.masrafkod, t.masrafad,
        t.borcbakiye, t.alacakbakiye, t.yereltutar, t.yerelbakiye, t.subeid, t.vadetarihi, t.adet, t.birim, t.birimfiyat
    FROM tmp_toplam t
    ORDER BY t.sirano;
END;
$$;
