-- ============================================================
-- fn_prog_alissatis_irsfatfiskons_json2 — MSSQL sp_Prog_AlisSatis_IrsFatFisKons_Json2 PG portu
--   Fatura/Irsaliye/Fis/Konsinye liste (UFaturalar.Liste_SP_Cagir seam).
--   @Baslik (EkAlanlar) YOK SAYILIR (dokuman/pdks/stok deseni; sabit RETURNS TABLE'a ek-kolon eklenemez).
--   Dinamik: @Stok filtresi FATURA FT + STOKLAR ST join ekler; WHERE (tur/tarih/sube/faturano/baslik/cari/aciklama/stok),
--     ORDER faturatarih DESC, TOP->LIMIT, DISTINCT.
--   MSSQL->PG: #SubeIDs temp+fn_SplitString -> regex-guarded inline IN, ISNULL->COALESCE, LIKE(CI)->ILIKE quote_literal,
--     convert(float,x)->x::double precision, FATURATARIH+VADE(gun) -> +make_interval(days=>vade), N''->text-lit.
--   Her kolon RETURNS tipine EXPLICIT cast. Turkce durum stringleri (Siparişten/Faturaya...) birebir korunur.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_alissatis_irsfatfiskons_json2(text, text);
CREATE FUNCTION public.fn_prog_alissatis_irsfatfiskons_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, durum smallint, odemeplani smallint, faturatarih timestamp, faturano varchar, faturaseri varchar,
    tipi smallint, senaryo smallint, rehberid integer, tur smallint, subeid smallint, sanal smallint, baslik varchar,
    fatura_matrahi numeric, kdv_tutari numeric, fatura_tutari numeric, kur varchar, fatura_maliyeti_ort numeric,
    ortkaroran numeric, ortkar numeric, aciklama varchar, ozelkod varchar, ozelkod2 varchar, carikod varchar,
    cariad varchar, doviz_cinsi varchar, dovizkur numeric, doviz_tutari numeric, doviz_fatura_matrahi double precision,
    doviz_kdv_tutari double precision, girisdepo smallint, cikisdepo smallint, cikisdepoadi varchar, irsaliyeno varchar,
    saticikodu integer, detaybolumu varchar, saticiadi varchar, vade smallint, vadetarih timestamp,
    durumnereden text, durumnereye text, teslimtarihi text, fatura_gon_tarihi timestamp, zarfid integer, zarf varchar,
    isemridurum integer, yazdirildi smallint, onaylayacak integer, onaylayan integer, efaturadurum smallint, efaturasonuc smallint
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 100);
    v_tur       int  := NULLIF(j->>'Tur','')::int;
    v_start     timestamp := NULLIF(j->>'StartDate','')::timestamp;
    v_end       timestamp := NULLIF(j->>'EndDate','')::timestamp;
    v_subeids   text := NULLIF(j->>'SubeIDList','');
    v_faturano  text := NULLIF(j->>'Faturano','');
    v_arabaslik text := NULLIF(j->>'Baslik','');
    v_carifirma text := NULLIF(j->>'CariFirma','');
    v_aciklama  text := NULLIF(j->>'Aciklama','');
    v_stok      text := NULLIF(j->>'Stok','');
    v_stokfiltre boolean := (v_stok IS NOT NULL AND v_stok <> 'ALL');
    q text; w text := ' WHERE F.TUR = ' || COALESCE(v_tur, 0) || ' ';
BEGIN
    -- DISTINCT yalniz stok filtresi (FATURA/STOKLAR detay join'i) satir cogalttiginda gerekli.
    -- MSSQL tarafinda kosulsuz DISTINCT tam listede buyuk bellek grant'i istiyordu; iki motor
    -- ayni davransin diye burada da kosullu.
    q := 'SELECT ' || CASE WHEN v_stokfiltre THEN 'DISTINCT ' ELSE '' END || '
        F.ID::integer, F.DURUM::smallint, F.ODEMEPLANI::smallint, F.FATURATARIH::timestamp,
        F.FATURANO::varchar, F.FATURASERI::varchar, F.TIPI::smallint, F.SENARYO::smallint,
        F.REHBERID::integer, F.TUR::smallint, F.SUBEID::smallint, F.SANAL::smallint, F.BASLIK::varchar,
        F.FATURA_MATRAHI::numeric, F.KDV_TUTARI::numeric, F.FATURA_TUTARI::numeric, F.KUR::varchar,
        F.FATURA_MALIYETI_ORT::numeric,
        round((F.FATURA_MATRAHI-F.FATURA_MALIYETI_ORT)/nullif(F.FATURA_MALIYETI_ORT,0)*100.0,2)::numeric,
        (F.FATURA_MATRAHI-F.FATURA_MALIYETI_ORT)::numeric,
        F.ACIKLAMA::varchar, F.OZELKOD::varchar, F.OZELKOD2::varchar,
        R.KOD::varchar, R.FIRMA::varchar, F.RAPORDOVIZ::varchar, F.DOVIZKUR::numeric, F.DOVIZ_TUTARI::numeric,
        COALESCE(F.DOVIZ_TUTARI - F.DOVIZ_TUTARI*(F.KDV_TUTARI::double precision/nullif(F.FATURA_TUTARI::double precision,0)),0)::double precision,
        COALESCE(F.DOVIZ_TUTARI*(F.KDV_TUTARI::double precision/nullif(F.FATURA_TUTARI::double precision,0)),0)::double precision,
        F.GIRISDEPO::smallint, F.CIKISDEPO::smallint,
        (CASE WHEN F.TUR IN (10,11,12,109) THEN DGIR.DEPOADI ELSE DCIK.DEPOADI END)::varchar,
        F.IRSALIYENO::varchar, F.SATICIKODU::integer, F.DETAYBOLUMU::varchar, SATICIBILGI.FIRMA::varchar,
        F.VADE::smallint, (F.FATURATARIH + make_interval(days => F.VADE::int))::timestamp,
        (CASE
            WHEN exists(select 1 from SIPARISDETAY F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (406,407,409,410,429,473) and F1.FATBASID=F.ID)) then ''Siparişten''
            WHEN exists(select 1 from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (408,410,411,424,427) and F1.FATBASID=F.ID)) then ''İrsaliyeden''
            WHEN exists(select 1 from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (461,462,464,468,472) and F1.FATBASID=F.ID)) then ''Konsinyeden''
            WHEN exists(select 1 from FATURA F2 where F2.ID in (select F1.YERID from FATURA F1 where F1.YERI in (425,426) and F1.FATBASID=F.ID)) then ''Üretimden''
            ELSE '''' END)::text,
        (CASE
            WHEN (F.TUR=10) and (408 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''
            WHEN (F.TUR=10) and (427 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Fişe''
            WHEN (F.TUR=14) and (411 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''
            WHEN (F.TUR=14) and (424 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Fişe''
            WHEN (F.TUR=109) and (461 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''
            WHEN (F.TUR=119) and (462 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Faturaya''
            WHEN (F.TUR=119) and (468 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''İrsaliyeye''
            WHEN (F.TUR=119) and (472 in (select YERI from FATURA where YERID in (select ID from FATURA where FATBASID=F.ID))) then ''Fişe''
            ELSE '''' END)::text,
        ''''::text,
        F.FATURA_GON_TARIHI::timestamp, F.ZARFID::integer,
        (select B.AD from BELGEZARFI B where B.ID=F.ZARFID)::varchar,
        COALESCE((select I.DURUM from ISEMRI I where I.YERI=F.TUR and I.YERID=F.ID),-1)::integer,
        F.YAZDIRILDI::smallint, 0::integer, 0::integer, F.EFATURADURUM::smallint, F.EFATURASONUC::smallint
    FROM FATBASLIK F
        INNER JOIN REHBER R ON R.ID = F.REHBERID
        LEFT JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID
        LEFT JOIN DEPOLAR DCIK ON DCIK.ID=F.CIKISDEPO
        LEFT JOIN DEPOLAR DGIR ON DGIR.ID=F.GIRISDEPO ';

    IF v_stokfiltre THEN
        q := q || ' LEFT JOIN FATURA FT ON FT.FATBASID = F.ID LEFT JOIN STOKLAR ST ON FT.URUNID = ST.ID ';
    END IF;

    -- WHERE (tur her zaman; digerleri kosullu, ILIKE quote_literal)
    IF v_start IS NOT NULL AND v_end IS NOT NULL THEN
        w := w || ' AND F.FATURATARIH BETWEEN ' || quote_literal(v_start) || ' AND ' || quote_literal(v_end) || ' ';
    END IF;
    IF v_subeids IS NOT NULL AND v_subeids ~ '^[0-9,\- ]+$' THEN
        w := w || ' AND F.SUBEID IN (' || v_subeids || ') ';
    END IF;
    IF v_faturano IS NOT NULL AND v_faturano <> 'ALL' THEN
        w := w || ' AND F.FATURANO ILIKE ' || quote_literal('%'||v_faturano||'%') || ' ';
    END IF;
    IF v_arabaslik IS NOT NULL AND v_arabaslik <> 'ALL' THEN
        w := w || ' AND F.BASLIK ILIKE ' || quote_literal('%'||v_arabaslik||'%') || ' ';
    END IF;
    IF v_carifirma IS NOT NULL AND v_carifirma <> 'ALL' THEN
        w := w || ' AND (R.FIRMA ILIKE ' || quote_literal('%'||v_carifirma||'%')
              || ' OR F.BASLIK ILIKE ' || quote_literal('%'||v_carifirma||'%')
              || ' OR EXISTS (SELECT 1 FROM REHBERBILGI RB WHERE RB.YER_ID = R.ID AND RB.YERI = 2'
              || '   AND RB.ETIKET = ' || quote_literal('Fatura Başlığı')
              || '   AND RB.BILGI ILIKE ' || quote_literal('%'||v_carifirma||'%') || ')) ';
    END IF;
    IF v_aciklama IS NOT NULL AND v_aciklama <> 'ALL' THEN
        w := w || ' AND F.ACIKLAMA ILIKE ' || quote_literal('%'||v_aciklama||'%') || ' ';
    END IF;
    IF v_stokfiltre THEN
        w := w || ' AND (ST.STOKADI ILIKE ' || quote_literal('%'||v_stok||'%')
              || ' OR ST.KOD ILIKE ' || quote_literal('%'||v_stok||'%')
              || ' OR ST.URUNNO ILIKE ' || quote_literal('%'||v_stok||'%') || ') ';
    END IF;

    -- TopN=0 => sinir yok (TAM liste); LIMIT 0 bos kume dondururdu
    q := q || w || ' ORDER BY 4 DESC LIMIT ' ||
         CASE WHEN v_topn > 0 THEN v_topn::text ELSE 'ALL' END;
    RETURN QUERY EXECUTE q;
END $$;
