-- =============================================================================
-- 64_fn_yaslandirma.sql
-- PG port of MSSQL scalar functions fn_AlacakliYaslandirma / fn_BorcluYaslandirma
-- FIFO cari yaslandirma: toplam odenen tutar cikarilir, kalan borcu (>0) olan
-- en eski hareket bulunur, o hareketin GUN (datediff gun) degeri text dondurulur.
--
-- Diyalekt notlari:
--   bit->smallint (EKSTREDEKULLAN), money->numeric, isnull->coalesce,
--   TOP 1 ... ORDER BY -> subquery ORDER BY ... LIMIT 1,
--   DATEDIFF(DAY,a,b) -> (b::date - a::date), GETDATE() -> now(), '+' -> '||'.
--
--   @Tarih: MSSQL'de int param, set @Yil = year(@Tarih). year(int) tam sayiyi
--   1900-01-01'den itibaren GUN sayisi olarak yorumlar. Birebir taklit:
--     v_yil := extract(year from (DATE '1900-01-01' + p_tarih * interval '1 day'))
--   (p_tarih'i duz yil VARSAYMA; year(2016) ~ 1905'e denk gelir, MSSQL ile ayni).
--
--   KALANBORC korelasyonu (asd.TARIH): SELECT listesindeki skaler alt-sorgu,
--   disaridaki ASD kumesinin TARIH'ine korele; PG'de dogrudan desteklenir.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- fn_AlacakliYaslandirma(@RehID INT, @Kur nvarchar(5), @Tarih int)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_alacakliyaslandirma(
    p_rehid   integer,
    p_kur     varchar,
    p_tarih   integer
) RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
    v_yil               integer;
    v_dil               integer := -1;
    v_toplamgidenpara   numeric;
    v_gun               integer;
BEGIN
    v_yil := extract(year from (DATE '1900-01-01' + p_tarih * interval '1 day'))::int;

    -- @ToplamGidenPara: odenen (giden) tutarlar toplami
    v_toplamgidenpara := coalesce((
        SELECT sum(Tutar) FROM (
            SELECT case when F.EKSTREDEKULLAN=1 then F.DOVIZ_TUTARI else F.FATURA_TUTARI end AS Tutar
            FROM FATBASLIK F
            WHERE extract(year from F.FATURATARIH) >= v_yil
              AND coalesce(F.DURUM,0) <> 6
              AND coalesce(F.DOVIZ_CINSI,F.KUR) = p_kur
              AND F.REHBERID = p_rehid
              AND F.TUR in (15,16,17)

            UNION ALL

            SELECT K.BORC AS Tutar
            FROM KASA K
            WHERE extract(year from K.ISLEMTARIHI) >= v_yil
              AND K.KUR = p_kur
              AND K.REHBERID = p_rehid
              AND K.TUR NOT BETWEEN 60 AND 79
              AND K.BORC > 0.0
              AND NOT EXISTS (SELECT 1 FROM KASA K1
                              WHERE K.ID = K1.ID AND K1.TUR = 2
                                AND extract(year from K1.ISLEMTARIHI) > v_yil)

            UNION ALL

            SELECT case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else coalesce(C.TUTAR,0) end AS Tutar
            FROM CEKLER C inner join CEKHAREKET CH on C.ID = CH.CEKSENETLERID
            WHERE extract(year from CH.TARIH) >= v_yil
              AND coalesce(C.DOVIZ_KURU::varchar,C.KUR) = p_kur
              AND CH.REHBERID = p_rehid
              AND CH.ISLEM in (131,132,133,134,137,140)

            UNION ALL

            SELECT case when S.EKSTREDEKULLAN=1 then S.DOVIZ_TUTARI else coalesce(S.TUTAR,0) end AS Tutar
            FROM SENETLER S
            WHERE extract(year from S.TARIH) >= v_yil
              AND coalesce(S.DOVIZ_KURU::varchar,S.KUR) = p_kur
              AND S.REHBERID = p_rehid
              AND S.TUR = 34
        ) ads
    ), 0);

    -- Kalan borcu (>0) olan en eski hareketin GUN degeri
    SELECT (now()::date - asd.TARIH::date) INTO v_gun
    FROM (
        SELECT F.FATURATARIH AS TARIH
        FROM FATBASLIK F inner join GENINI G on F.TUR=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from F.FATURATARIH) >= v_yil
          AND coalesce(F.DURUM,0) <> 6
          AND coalesce(F.DOVIZ_CINSI,F.KUR) = p_kur
          AND F.REHBERID = p_rehid
          AND F.TUR in (8,11,12,13)

        UNION ALL

        SELECT K.ISLEMTARIHI AS TARIH
        FROM KASA K inner join GENINI G on K.TUR=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from K.ISLEMTARIHI) >= v_yil
          AND K.KUR = p_kur
          AND K.REHBERID = p_rehid
          AND K.TUR NOT BETWEEN 60 AND 79
          AND K.ALACAK > 0.0
          AND NOT EXISTS (SELECT 1 FROM KASA K1
                          WHERE K.ID = K1.ID AND K1.TUR = 2
                            AND extract(year from K1.ISLEMTARIHI) > v_yil)

        UNION ALL

        SELECT CH.TARIH AS TARIH
        FROM CEKLER C inner join CEKHAREKET CH on C.ID = CH.CEKSENETLERID
                      inner join GENINI G on CH.ISLEM=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from CH.TARIH) >= v_yil
          AND coalesce(C.DOVIZ_KURU::varchar,C.KUR) = p_kur
          AND CH.REHBERID = p_rehid
          AND CH.ISLEM in (130,141)

        UNION ALL

        SELECT S.TARIH AS TARIH
        FROM SENETLER S inner join GENINI G on S.TUR=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from S.TARIH) >= v_yil
          AND coalesce(S.DOVIZ_KURU::varchar,S.KUR) = p_kur
          AND S.REHBERID = p_rehid
          AND S.TUR = 24
    ) asd
    WHERE (
        (SELECT sum(TUTAR) FROM (
            SELECT case when F.EKSTREDEKULLAN=1 then F.DOVIZ_TUTARI else F.FATURA_TUTARI end AS TUTAR
            FROM FATBASLIK F
            WHERE extract(year from F.FATURATARIH) >= v_yil
              AND coalesce(F.DURUM,0) <> 6
              AND F.FATURATARIH <= asd.TARIH
              AND coalesce(F.DOVIZ_CINSI,F.KUR) = p_kur
              AND F.REHBERID = p_rehid
              AND F.TUR in (8,11,12,13)

            UNION ALL

            SELECT K.ALACAK AS TUTAR
            FROM KASA K
            WHERE extract(year from K.ISLEMTARIHI) >= v_yil
              AND K.ISLEMTARIHI <= asd.TARIH
              AND K.KUR = p_kur
              AND K.REHBERID = p_rehid
              AND K.TUR NOT BETWEEN 60 AND 79
              AND K.ALACAK > 0.0
              AND NOT EXISTS (SELECT 1 FROM KASA K1
                              WHERE K.ID = K1.ID AND K1.TUR = 2
                                AND extract(year from K1.ISLEMTARIHI) > v_yil)

            UNION ALL

            SELECT case when C.EKSTREDEKULLAN=1 then C.DOVIZ_TUTARI else coalesce(C.TUTAR,0) end AS TUTAR
            FROM CEKLER C inner join CEKHAREKET CH on C.ID = CH.CEKSENETLERID
            WHERE extract(year from CH.TARIH) >= v_yil
              AND C.TARIH <= asd.TARIH
              AND coalesce(C.DOVIZ_KURU::varchar,C.KUR) = p_kur
              AND CH.REHBERID = p_rehid
              AND CH.ISLEM in (130,141)

            UNION ALL

            SELECT case when S.EKSTREDEKULLAN=1 then S.DOVIZ_TUTARI else coalesce(S.TUTAR,0) end AS TUTAR
            FROM SENETLER S
            WHERE extract(year from S.TARIH) >= v_yil
              AND S.TARIH <= asd.TARIH
              AND coalesce(S.DOVIZ_KURU::varchar,S.KUR) = p_kur
              AND S.REHBERID = p_rehid
              AND S.TUR = 24
        ) aaa) - coalesce(v_toplamgidenpara,0)
    ) > 0
    ORDER BY asd.TARIH
    LIMIT 1;

    RETURN v_gun::varchar;
END;
$$;

-- -----------------------------------------------------------------------------
-- fn_BorcluYaslandirma(@RehID INT, @Kur nvarchar(5), @Tarih int)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_borcluyaslandirma(
    p_rehid   integer,
    p_kur     varchar,
    p_tarih   integer
) RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
    v_yil               integer;
    v_dil               integer := -1;
    v_toplamgelenpara   numeric;
    v_gun               integer;
BEGIN
    v_yil := extract(year from (DATE '1900-01-01' + p_tarih * interval '1 day'))::int;

    -- @ToplamGelenPara: tahsil edilen (gelen) tutarlar toplami
    v_toplamgelenpara := coalesce((
        SELECT sum(Tutar) FROM (
            SELECT case when F.EKSTREDEKULLAN=1 then F.DOVIZ_TUTARI else F.FATURA_TUTARI end AS Tutar
            FROM FATBASLIK F
            WHERE extract(year from F.FATURATARIH) >= v_yil
              AND coalesce(F.DURUM,0) <> 6
              AND coalesce(F.DOVIZ_CINSI,F.KUR) = p_kur
              AND F.REHBERID = p_rehid
              AND F.TUR in (8,11,12,13)

            UNION ALL

            SELECT K.ALACAK AS Tutar
            FROM KASA K
            WHERE extract(year from K.ISLEMTARIHI) >= v_yil
              AND K.KUR = p_kur
              AND K.REHBERID = p_rehid
              AND K.TUR NOT BETWEEN 60 AND 79
              AND K.ALACAK > 0.0

            UNION ALL

            SELECT case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else coalesce(C.TUTAR,0) end AS Tutar
            FROM CEKLER C inner join CEKHAREKET CH on C.ID = CH.CEKSENETLERID
            WHERE extract(year from CH.TARIH) >= v_yil
              AND coalesce(case when CH.EKSTREDEKULLAN=1 then CH.KUR else coalesce(C.KUR,'') end,'') = p_kur
              AND CH.REHBERID = p_rehid
              AND CH.ISLEM in (130,141)

            UNION ALL

            SELECT case when S.EKSTREDEKULLAN=1 then S.DOVIZ_TUTARI else coalesce(S.TUTAR,0) end AS Tutar
            FROM SENETLER S
            WHERE extract(year from S.TARIH) >= v_yil
              AND coalesce(S.DOVIZ_KURU::varchar,S.KUR) = p_kur
              AND S.REHBERID = p_rehid
              AND S.TUR = 24
        ) ads
    ), 0);

    -- Kalan borcu (>0) olan en eski hareketin GUN degeri
    SELECT (now()::date - asd.TARIH::date) INTO v_gun
    FROM (
        SELECT F.FATURATARIH AS TARIH
        FROM FATBASLIK F inner join GENINI G on F.TUR=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from F.FATURATARIH) >= v_yil
          AND coalesce(F.DURUM,0) <> 6
          AND coalesce(F.DOVIZ_CINSI,F.KUR) = p_kur
          AND F.REHBERID = p_rehid
          AND F.TUR in (15,16,17)

        UNION ALL

        SELECT K.ISLEMTARIHI AS TARIH
        FROM KASA K inner join GENINI G on K.TUR=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from K.ISLEMTARIHI) >= v_yil
          AND K.KUR = p_kur
          AND K.REHBERID = p_rehid
          AND K.TUR NOT BETWEEN 60 AND 79
          AND K.BORC > 0.0
          AND NOT EXISTS (SELECT 1 FROM KASA K1
                          WHERE K.ID = K1.ID AND K1.TUR = 2
                            AND extract(year from K1.ISLEMTARIHI) > v_yil)

        UNION ALL

        SELECT CH.TARIH AS TARIH
        FROM CEKLER C inner join CEKHAREKET CH on C.ID = CH.CEKSENETLERID
                      inner join GENINI G on CH.ISLEM=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from CH.TARIH) >= v_yil
          AND coalesce(case when CH.EKSTREDEKULLAN=1 then CH.KUR else coalesce(C.KUR,'') end,'') = p_kur
          AND CH.REHBERID = p_rehid
          AND CH.ISLEM in (131,132,133,134,137,140)

        UNION ALL

        SELECT S.TARIH AS TARIH
        FROM SENETLER S inner join GENINI G on S.TUR=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
        WHERE extract(year from S.TARIH) >= v_yil
          AND coalesce(S.DOVIZ_KURU::varchar,S.KUR) = p_kur
          AND S.REHBERID = p_rehid
          AND S.TUR = 34
    ) asd
    WHERE (
        (SELECT sum(TUTAR) FROM (
            SELECT case when F.EKSTREDEKULLAN=1 then F.DOVIZ_TUTARI else F.FATURA_TUTARI end AS TUTAR
            FROM FATBASLIK F
            WHERE extract(year from F.FATURATARIH) >= v_yil
              AND coalesce(F.DURUM,0) <> 6
              AND F.FATURATARIH <= asd.TARIH
              AND coalesce(F.DOVIZ_CINSI,F.KUR) = p_kur
              AND F.REHBERID = p_rehid
              AND F.TUR in (15,16,17)

            UNION ALL

            SELECT K.BORC AS TUTAR
            FROM KASA K
            WHERE extract(year from K.ISLEMTARIHI) >= v_yil
              AND K.ISLEMTARIHI <= asd.TARIH
              AND K.KUR = p_kur
              AND K.REHBERID = p_rehid
              AND K.TUR NOT BETWEEN 60 AND 79
              AND K.BORC > 0.0
              AND NOT EXISTS (SELECT 1 FROM KASA K1
                              WHERE K.ID = K1.ID AND K1.TUR = 2
                                AND extract(year from K1.ISLEMTARIHI) > v_yil)

            UNION ALL

            SELECT case when CH.EKSTREDEKULLAN=1 then CH.TUTAR else coalesce(C.TUTAR,0) end AS TUTAR
            FROM CEKLER C inner join CEKHAREKET CH on C.ID = CH.CEKSENETLERID
            WHERE extract(year from CH.TARIH) >= v_yil
              AND CH.TARIH <= asd.TARIH
              AND coalesce(case when CH.EKSTREDEKULLAN=1 then CH.KUR else coalesce(C.KUR,'') end,'') = p_kur
              AND CH.REHBERID = p_rehid
              AND CH.ISLEM in (131,132,133,134,137,140)

            UNION ALL

            SELECT case when S.EKSTREDEKULLAN=1 then S.DOVIZ_TUTARI else coalesce(S.TUTAR,0) end AS TUTAR
            FROM SENETLER S inner join GENINI G on S.TUR=G.DEGER and G.BOLUM=-1005 and G.DIL=v_dil
            WHERE extract(year from S.TARIH) >= v_yil
              AND S.TARIH <= asd.TARIH
              AND coalesce(S.DOVIZ_KURU::varchar,S.KUR) = p_kur
              AND S.REHBERID = p_rehid
              AND S.TUR = 34
        ) aaa) - coalesce(v_toplamgelenpara,0)
    ) > 0
    ORDER BY asd.TARIH
    LIMIT 1;

    RETURN v_gun::varchar;
END;
$$;
