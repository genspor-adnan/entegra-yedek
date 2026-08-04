-- ============================================================
-- fn_prog_banka_liste_json2 — MSSQL sp_Prog_Banka_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- Banka/kredi liste. 3 dal UNION ALL: taksitli(1,11) / rotatif(2) / cek-kocan(31).
--   baslik = @Baslik (EkAlanlar) YOK SAYILIR (dokuman/pdks/stok deseni; sabit RETURNS
--     TABLE'a ek-kolon eklenemez -> superset base kolonlar doner).
--   kosullar = JSON filtreler. @Mod 3=Sik / 5=Son -> KULLANICI_ARAMA; 1/11/2/31 dal filtresi.
-- MSSQL->PG:
--   JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, bit->smallint(=1 kalir),
--   GETDATE->now(), @PTARIH+1/-1 -> +/- interval '1 day', DATEDIFF(day,a,b)->(b::date-a::date),
--   LIKE(MSSQL CI)->ILIKE + quote_literal('%'||v||'%'), money->numeric.
--   /*KA*/ (KA_SIRA kolon enjeksiyonu) -> RETURN edilmez; Son/Sik siralamasi disaridaki
--     wrapper'da q.id ile korele subquery (demirbas deseni). /*FLT*/ = metin + Son/Sik EXISTS.
--   dbo.fn_RotatifFaizHesapla PG'de YOKTU -> ayni dosyada public.fn_rotatiffaizhesapla portu.
-- USING: $1=@PTARIH  $2=@PDURUM  $3=@PTARIH+1  $4=@PTARIH-1 (metin/int filtre inline).
-- VERI: krediler/plankredi BOS -> DIFFERENTIAL VACUOUS, smoke-only.
-- ============================================================

-- ---- bagimlilik: rotatif faiz hesabi (MSSQL dbo.fn_RotatifFaizHesapla portu) ----
CREATE OR REPLACE FUNCTION public.fn_rotatiffaizhesapla(
    p_krediid int, p_bastar timestamp, p_bittar timestamp, p_kasaid int DEFAULT 0)
RETURNS numeric
LANGUAGE sql STABLE AS $rf$
    SELECT SUM(ROUND((1.05 * a.tutar * (a.oran/100.0) * a.gunsay / 360.0)::numeric, 2))
    FROM (
        SELECT
            CASE WHEN k.borc > 0.0 THEN k.borc ELSE -1.0*k.alacak END AS tutar,
            kr.oran,
            (
                (CASE WHEN p_bittar > kr.bittarih THEN kr.bittarih ELSE p_bittar END)::date
                -
                (CASE
                   WHEN k.plantarihi <= p_bastar AND k.plantarihi <= kr.bastarih
                        THEN (CASE WHEN p_bastar > kr.bastarih THEN p_bastar ELSE kr.bastarih END)
                   WHEN k.plantarihi >  p_bastar AND k.plantarihi <= kr.bastarih THEN kr.bastarih
                   WHEN k.plantarihi <= p_bastar AND k.plantarihi >  kr.bastarih THEN p_bastar
                   ELSE k.plantarihi
                 END)::date
            ) AS gunsay
        FROM kasa k
            JOIN kredirotatiffaiz kr ON k.hesapid = kr.krediid
        WHERE k.hesapturu = 'R'
          AND k.hesapid = p_krediid
          AND k.plantarihi <= kr.bittarih
          AND p_bastar <= kr.bittarih
          AND p_bittar >= kr.bastarih
          AND (p_kasaid = 0 OR p_kasaid = k.id)
    ) a
$rf$;

-- ---- ana liste fonksiyonu ----
DROP FUNCTION IF EXISTS public.fn_prog_banka_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_banka_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, kredikodu varchar, adi varchar, sozlesmeno varchar, genelkreditipi smallint,
    kur varchar, alinistarihi timestamp, kapanistarihi timestamp, durum smallint,
    kreditaksit integer, odenentaksit integer, kalantaksit integer,
    toplam_tutar numeric, toplam_anapara numeric, toplam_gider numeric,
    odenen_tutar numeric, odenen_anapara numeric, odenen_gider numeric,
    kalan_tutar numeric, kalan_anapara numeric, kalan_gider numeric,
    bankaadi varchar, subeadi varchar, logo text, bankaticarihesapid integer, hesapkur varchar,
    krediteminat smallint, kredilimitsuretipi smallint, kredilimitsure timestamp,
    kredilimit numeric, kredikullanimsure smallint, kredieklimitvar smallint, revizyontarihi timestamp
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_selectlist text := '';                                     -- @Baslik (EkAlanlar) YOK SAYILIR (superset base kolonlar)
    v_topn   int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);     -- SAYFALI liste: 0 = LIMIT yok
    v_mod    int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_pasif  int  := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_trh    timestamp := NULLIF(j->>'Trh','')::timestamp;
    v_kod    text := NULLIF(j->>'Kod','');
    v_kulid  int  := NULLIF(j->>'KulId','')::int;
    v_modul  int  := NULLIF(j->>'Modul','')::int;
    v_orderby text := NULLIF(j->>'OrderBy','');
    v_pdurum int := CASE WHEN v_pasif = 1 THEN 0 ELSE 1 END;
    v_ptarih timestamp := COALESCE(v_trh, now());
    v_flt   text := '';        -- her dalin WHERE'ine eklenen ek kosullar (/*FLT*/)
    v_body  text; q text;
BEGIN
    -- Son/Sik: kullanicinin actigi krediler (KULLANICI_ARAMA) suzgeci
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_flt := v_flt || ' AND EXISTS (SELECT 1 FROM kullanici_arama ka WHERE ka.kayitid=kr.id AND ka.kulid='
                 || v_kulid || ' AND ka.modul=' || v_modul || ') ';
    END IF;
    -- Metin filtresi (ILIKE, quote_literal -> enjeksiyon guvenli)
    IF v_kod IS NOT NULL THEN
        v_flt := v_flt || ' AND (kr.kredikodu ILIKE ' || quote_literal('%'||v_kod||'%')
                 || ' OR kr.adi ILIKE ' || quote_literal('%'||v_kod||'%')
                 || ' OR kr.sozlesmeno ILIKE ' || quote_literal('%'||v_kod||'%') || ') ';
    END IF;

    v_body :=
    -- ---------------------------------------------------- taksitli (1,11)
    'select
        kr.id::integer AS id, kr.kredikodu::varchar AS kredikodu, kr.adi::varchar AS adi,
        kr.sozlesmeno::varchar AS sozlesmeno, kr.genelkreditipi::smallint AS genelkreditipi,
        kr.kur::varchar AS kur, kr.alinistarihi::timestamp AS alinistarihi,
        kr.kapanistarihi::timestamp AS kapanistarihi, kr.durum::smallint AS durum,
        count(p.id)::integer AS kreditaksit,
        sum(case when p.odenmis=1 and p.tarih<=$1 then 1 else 0 end)::integer AS odenentaksit,
        sum(case when p.odenmis=1 and p.tarih<=$1 then 0 else 1 end)::integer AS kalantaksit,
        coalesce(sum(p.taksit),0)::numeric AS toplam_tutar,
        coalesce(sum(p.anapara),0)::numeric AS toplam_anapara,
        coalesce(sum(p.faiz+p.kkdf+p.bsmv),0)::numeric AS toplam_gider,
        sum(case when p.odenmis=1 and p.tarih<=$1 then p.taksit else 0.0 end)::numeric AS odenen_tutar,
        sum(case when p.odenmis=1 and p.tarih<=$1 then p.anapara else 0.0 end)::numeric AS odenen_anapara,
        sum(case when p.odenmis=1 and p.tarih<=$1 then p.faiz+p.kkdf+p.bsmv else 0.0 end)::numeric AS odenen_gider,
        sum(case when p.odenmis=1 and p.tarih<=$1 then 0.0 else p.taksit end)::numeric AS kalan_tutar,
        sum(case when p.odenmis=1 and p.tarih<=$1 then 0.0 else p.anapara end)::numeric AS kalan_anapara,
        sum(case when p.odenmis=1 and p.tarih<=$1 then 0.0 else p.faiz+p.kkdf+p.bsmv end)::numeric AS kalan_gider,
        b.bankaadi::varchar AS bankaadi, bs.subeadi::varchar AS subeadi, null::text AS logo,
        kr.bankaticarihesapid::integer AS bankaticarihesapid, bh.kur::varchar AS hesapkur,
        kr.krediteminat::smallint AS krediteminat, kr.kredilimitsuretipi::smallint AS kredilimitsuretipi,
        kr.kredilimitsure::timestamp AS kredilimitsure, kr.kredilimit::numeric AS kredilimit,
        kr.kredikullanimsure::smallint AS kredikullanimsure, kr.kredieklimitvar::smallint AS kredieklimitvar,
        kr.revizyontarihi::timestamp AS revizyontarihi
    from krediler kr
        left join plankredi p on p.krediid=kr.id
        inner join bankahesaplar bh on bh.id=kr.bankaticarihesapid
        inner join bankasubeler bs on bh.bankasubelerid=bs.id
        inner join bankalar b on b.bankakodu=bs.bankakodu
    where kr.durum>=$2 and kr.genelkreditipi in (1,11)
        and kr.alinistarihi<=$3 ' || v_flt || '
    group by kr.id, kr.kredikodu, kr.adi, kr.sozlesmeno, kr.genelkreditipi, kr.kur,
        kr.alinistarihi, kr.kapanistarihi, kr.kreditaksit, kr.taksittutari, kr.durum, kr.subeid,
        b.bankaadi, bs.subeadi, kr.bankaticarihesapid, bh.kur, kr.krediteminat,
        kr.kredilimitsuretipi, kr.kredilimitsure, kr.kredilimit, kr.kredikullanimsure,
        kr.kredieklimitvar, kr.revizyontarihi
    union all
    -- ---------------------------------------------------- rotatif (2)
    select
        kr.id::integer, kr.kredikodu::varchar, kr.adi::varchar, kr.sozlesmeno::varchar,
        kr.genelkreditipi::smallint, kr.kur::varchar, kr.alinistarihi::timestamp,
        kr.kapanistarihi::timestamp, kr.durum::smallint,
        0::integer, 0::integer, 0::integer,
        (coalesce(sum(ks.borc),0) + fn_rotatiffaizhesapla(kr.id, timestamp ''2000-01-01 00:00'', $4, 0))::numeric,
        coalesce(sum(ks.borc),0)::numeric,
        fn_rotatiffaizhesapla(kr.id, timestamp ''2000-01-01 00:00'', $4, 0)::numeric,
        (coalesce(sum(ks.alacak),0) + (select coalesce(sum(k.borc),0.0) from kasa k where k.tur=32 and k.yeri=47 and k.yerid=kr.id))::numeric,
        coalesce(sum(ks.alacak),0)::numeric,
        (select coalesce(sum(k.borc),0.0) from kasa k where k.tur=32 and k.yeri=47 and k.yerid=kr.id)::numeric,
        (coalesce(sum(ks.borc-ks.alacak),0) + fn_rotatiffaizhesapla(kr.id, timestamp ''2000-01-01 00:00'', $4, 0)
            - (select coalesce(sum(k.borc),0.0) from kasa k where k.tur=32 and k.yeri=47 and k.yerid=kr.id))::numeric,
        coalesce(sum(ks.borc-ks.alacak),0)::numeric,
        (fn_rotatiffaizhesapla(kr.id, timestamp ''2000-01-01 00:00'', $4, 0)
            - (select coalesce(sum(k.borc),0.0) from kasa k where k.tur=32 and k.yeri=47 and k.yerid=kr.id))::numeric,
        b.bankaadi::varchar, bs.subeadi::varchar, null::text,
        kr.bankaticarihesapid::integer, bh.kur::varchar,
        kr.krediteminat::smallint, kr.kredilimitsuretipi::smallint, kr.kredilimitsure::timestamp,
        kr.kredilimit::numeric, kr.kredikullanimsure::smallint, kr.kredieklimitvar::smallint,
        kr.revizyontarihi::timestamp
    from krediler kr
        left outer join kasa ks on ks.hesapturu=''R'' and ks.hesapid=kr.id and ks.tur<>2 and ks.islemtarihi<=$3
        inner join bankahesaplar bh on bh.id=kr.bankaticarihesapid
        inner join bankasubeler bs on bh.bankasubelerid=bs.id
        inner join bankalar b on b.bankakodu=bs.bankakodu
    where kr.durum>=$2 and kr.genelkreditipi=2 ' || v_flt || '
    group by kr.id, kr.kredikodu, kr.adi, kr.sozlesmeno, kr.genelkreditipi, kr.kur,
        kr.alinistarihi, kr.kapanistarihi, kr.kreditaksit, kr.taksittutari, kr.durum, kr.subeid,
        b.bankaadi, bs.subeadi, kr.bankaticarihesapid, bh.kur, kr.krediteminat,
        kr.kredilimitsuretipi, kr.kredilimitsure, kr.kredilimit, kr.kredikullanimsure,
        kr.kredieklimitvar, kr.revizyontarihi
    union all
    -- ---------------------------------------------------- cek kocan (31)
    select
        kr.id::integer, kr.kredikodu::varchar, kr.adi::varchar, kr.sozlesmeno::varchar,
        kr.genelkreditipi::smallint, kr.kur::varchar, kr.alinistarihi::timestamp,
        kr.kapanistarihi::timestamp, kr.durum::smallint,
        0::integer, 0::integer, 0::integer,
        0::numeric, 0::numeric, 0::numeric, 0::numeric, 0::numeric, 0::numeric,
        0::numeric, 0::numeric, 0::numeric,
        b.bankaadi::varchar, bs.subeadi::varchar, null::text,
        kr.bankaticarihesapid::integer, bh.kur::varchar,
        kr.krediteminat::smallint, kr.kredilimitsuretipi::smallint, kr.kredilimitsure::timestamp,
        kr.kredilimit::numeric, kr.kredikullanimsure::smallint, kr.kredieklimitvar::smallint,
        kr.revizyontarihi::timestamp
    from krediler kr
        left outer join kasa ks on ks.hesapturu=''R'' and ks.hesapid=kr.id and ks.tur<>2 and ks.islemtarihi<=$3
        inner join bankahesaplar bh on bh.id=kr.bankaticarihesapid
        inner join bankasubeler bs on bh.bankasubelerid=bs.id
        inner join bankalar b on b.bankakodu=bs.bankakodu
    where kr.durum>=$2 and kr.genelkreditipi=31 ' || v_flt || '
    group by kr.id, kr.kredikodu, kr.adi, kr.sozlesmeno, kr.genelkreditipi, kr.kur,
        kr.alinistarihi, kr.kapanistarihi, kr.kreditaksit, kr.taksittutari, kr.durum, kr.subeid,
        b.bankaadi, bs.subeadi, kr.bankaticarihesapid, bh.kur, kr.krediteminat,
        kr.kredilimitsuretipi, kr.kredilimitsure, kr.kredilimit, kr.kredikullanimsure,
        kr.kredieklimitvar, kr.revizyontarihi';

    -- Siralama: Son/Sik -> q.id korele KULLANICI_ARAMA (KA_SIRA yerine), degilse OrderBy
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        q := 'SELECT * FROM (' || v_body || ') q ORDER BY (SELECT '
             || CASE WHEN v_mod = 5 THEN 'max(ka.degistirmetarihi)' ELSE 'max(ka.say)' END
             || ' FROM kullanici_arama ka WHERE ka.kayitid=q.id AND ka.kulid=' || v_kulid
             || ' AND ka.modul=' || v_modul || ') DESC';
    ELSIF v_orderby IS NOT NULL AND v_orderby <> '' THEN
        q := v_body || ' ORDER BY ' || v_orderby;
    ELSE
        q := v_body;
    END IF;

    -- SAYFALI liste (TSayfaliListe): MSSQL TOP (n) karsiligi. Govde UNION ALL oldugundan
    -- LIMIT en dista olmali; siralamasiz dalda da sarmalanir ki LIMIT tum birlesime uygulansin.
    IF v_topn > 0 THEN
        IF q = v_body THEN q := 'SELECT * FROM (' || v_body || ') q'; END IF;
        q := q || ' LIMIT ' || v_topn;
    END IF;

    RETURN QUERY EXECUTE q
        USING v_ptarih, v_pdurum, v_ptarih + interval '1 day', v_ptarih - interval '1 day';
END $$;
