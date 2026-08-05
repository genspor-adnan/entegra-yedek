-- ============================================================
-- fn_prog_alissatis_siparis_json2 — MSSQL sp_Prog_AlisSatis_Siparis_Json2 PG portu
--   Siparis/Satinalma-talebi liste (UFaturalar.Liste_SP_Cagir seam, @Tur 9/19/101).
--   @Baslik (EkAlanlar) YOK SAYILIR (sabit RETURNS TABLE'a ek-kolon eklenemez).
--   SIPARIS INNER JOIN SIPARISDETAY (satir cogaltir) -> DISTINCT; STOKLAR LEFT join her zaman.
--   MSSQL->PG: #SubeIDs -> regex-guarded inline IN, LIKE(CI)->ILIKE quote_literal, convert(float)->::double precision,
--     SIPARISTARIH+VADE(gun)->+make_interval, CAST(NULL AS smallint)->NULL::smallint.
--   NOT: kaynak SP kolon adi 'KURFATURA_MALIYETI_ORT' (F.KUR,KURFATURA...=0.0 -> tek kolon) — birebir korunur (grid FATURA_MALIYETI_ORT bos, MSSQL ile ayni).
--   Her kolon RETURNS tipine EXPLICIT cast; Turkce durum stringleri korunur.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_alissatis_siparis_json2(text, text);
CREATE FUNCTION public.fn_prog_alissatis_siparis_json2(p_baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, durum smallint, odemeplani smallint, faturatarih timestamp, faturano varchar, faturaseri varchar,
    tipi smallint, senaryo smallint, rehberid integer, tur smallint, subeid smallint, baslik varchar,
    fatura_matrahi numeric, kdv_tutari numeric, fatura_tutari numeric, kur varchar, kurfatura_maliyeti_ort numeric,
    ortkaroran numeric, ortkar numeric, aciklama varchar, ozelkod varchar, ozelkod2 varchar, carikod varchar,
    cariad varchar, doviz_cinsi varchar, dovizkur numeric, doviz_tutari numeric, doviz_fatura_matrahi numeric,
    doviz_kdv_tutari double precision, girisdepo smallint, cikisdepo smallint, cikisdepoadi varchar, irsaliyeno varchar,
    saticikodu integer, detaybolumu varchar, saticiadi varchar, vade smallint, vadetarih timestamp,
    durumnereden text, durumnereye text, teslimtarihi timestamp, fatura_gon_tarihi timestamp, zarfid integer, zarf varchar,
    isemridurum integer, yazdirildi smallint, onaylayacak integer, onaylayan integer, efaturadurum smallint
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
    -- SIPARISDETAY/STOKLAR join'i yalniz stok filtresinde gerekli (satir cogaltir -> DISTINCT).
    -- Diger dallarda join de DISTINCT de kaldirildi; detaysiz siparis dusmesin diye EXISTS eklenir.
    q := 'SELECT ' || CASE WHEN v_stokfiltre THEN 'DISTINCT ' ELSE '' END || '
        F.ID::integer, F.DURUM::smallint, F.ODEMEPLANI::smallint, F.SIPARISTARIH::timestamp,
        F.SIPARISNO::varchar, F.SIPARISSERI::varchar, F.TIPI::smallint, NULL::smallint,
        F.REHBERID::integer, F.TUR::smallint, F.SUBEID::smallint, F.BASLIK::varchar,
        (F.SIPARIS_TUTARI-F.KDV_TUTARI)::numeric, F.KDV_TUTARI::numeric, F.SIPARIS_TUTARI::numeric, F.KUR::varchar,
        0.0::numeric, 0.0::numeric, 0.0::numeric,
        F.ACIKLAMA::varchar, F.OZELKOD::varchar, F.OZELKOD2::varchar, R.KOD::varchar, R.FIRMA::varchar,
        F.RAPORDOVIZ::varchar, F.DOVIZKUR::numeric,
        (F.SIPARIS_TUTARI/nullif(F.DOVIZKUR,0.0))::numeric,
        ((F.SIPARIS_TUTARI-F.KDV_TUTARI)/nullif(F.DOVIZKUR,0.0))::numeric,
        (F.KDV_TUTARI::double precision/nullif(F.DOVIZKUR::double precision,0.0))::double precision,
        F.GIRISDEPO::smallint, F.CIKISDEPO::smallint, D.DEPOADI::varchar,
        F.IRSALIYENO::varchar, F.SATICIKODU::integer, F.DETAYBOLUMU::varchar, SATICIBILGI.FIRMA::varchar,
        F.VADE::smallint, (F.SIPARISTARIH + make_interval(days => F.VADE::int))::timestamp,
        (CASE
            WHEN (F.TUR=9)  and(412 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Teklifden''
            WHEN (F.TUR=19) and(413 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Teklifden''
            WHEN (F.TUR=9)  and(83  in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Servisden''
            WHEN (F.TUR=19) and(83  in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Servisden''
            WHEN (F.TUR=9)  and(428 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Talepten''
            WHEN (F.TUR=101)and(465 in (select YERI from SIPARISDETAY where SIPARISID=F.ID)) then ''Üretimden''
            ELSE '''' END)::text,
        (CASE
            WHEN (F.TUR=9)  and(407 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''
            WHEN (F.TUR=9)  and(406 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye''
            WHEN (F.TUR=101)and(428 in (select YERI from SIPARISDETAY where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Siparişe''
            WHEN (F.TUR=19) and(410 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Faturaya''
            WHEN (F.TUR=19) and(409 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''İrsaliyeye''
            WHEN (F.TUR=19) and(473 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Fişe''
            WHEN (F.TUR=19) and(429 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Konsinyeye''
            WHEN (F.TUR=19) and(415 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine''
            WHEN (F.TUR=19) and(420 in (select YERI from FATURA where YERID in (select ID from SIPARISDETAY where SIPARISID=F.ID))) then ''Üretim Fişine''
            ELSE '''' END)::text,
        (select min(TESLIMTARIHI) from SIPARISDETAY where SIPARISID=F.ID)::timestamp,
        NULL::timestamp, NULL::integer, NULL::varchar,
        COALESCE((select I.DURUM from ISEMRI I where I.YERI=F.TUR and I.YERID=F.ID),-1)::integer,
        F.YAZDIRILDI::smallint, F.ONAYLAYACAK::integer, F.ONAYLAYAN::integer, 0::smallint
    FROM SIPARIS F
        INNER JOIN REHBER R ON R.ID = F.REHBERID
        LEFT OUTER JOIN REHBER SATICIBILGI ON F.SATICIKODU = SATICIBILGI.ID
        LEFT OUTER JOIN DEPOLAR D ON D.ID=F.CIKISDEPO '
         || CASE WHEN v_stokfiltre
                 THEN ' INNER JOIN SIPARISDETAY SD ON F.ID = SD.SIPARISID
                        LEFT OUTER JOIN STOKLAR ST ON ST.ID = SD.URUNID '
                 ELSE '' END;

    IF NOT v_stokfiltre THEN   -- eski INNER JOIN'in suzme etkisi (detaysiz siparis listelenmez)
        w := w || ' AND EXISTS (SELECT 1 FROM SIPARISDETAY SD2 WHERE SD2.SIPARISID = F.ID) ';
    END IF;

    IF v_start IS NOT NULL AND v_end IS NOT NULL THEN
        w := w || ' AND F.SIPARISTARIH BETWEEN ' || quote_literal(v_start) || ' AND ' || quote_literal(v_end) || ' ';
    END IF;
    IF v_subeids IS NOT NULL AND v_subeids ~ '^[0-9,\- ]+$' THEN
        w := w || ' AND F.SUBEID IN (' || v_subeids || ') ';
    END IF;
    IF v_faturano IS NOT NULL AND v_faturano <> 'ALL' THEN
        w := w || ' AND F.SIPARISNO ILIKE ' || quote_literal('%'||v_faturano||'%') || ' ';
    END IF;
    IF v_arabaslik IS NOT NULL AND v_arabaslik <> 'ALL' THEN
        w := w || ' AND F.BASLIK ILIKE ' || quote_literal('%'||v_arabaslik||'%') || ' ';
    END IF;
    IF v_carifirma IS NOT NULL AND v_carifirma <> 'ALL' THEN
        w := w || ' AND R.FIRMA ILIKE ' || quote_literal('%'||v_carifirma||'%') || ' ';
    END IF;
    IF v_aciklama IS NOT NULL AND v_aciklama <> 'ALL' THEN
        w := w || ' AND F.ACIKLAMA ILIKE ' || quote_literal('%'||v_aciklama||'%') || ' ';
    END IF;
    IF v_stok IS NOT NULL AND v_stok <> 'ALL' THEN
        w := w || ' AND (ST.KOD ILIKE ' || quote_literal('%'||v_stok||'%')
              || ' OR ST.STOKADI ILIKE ' || quote_literal('%'||v_stok||'%')
              || ' OR ST.URUNNO ILIKE ' || quote_literal('%'||v_stok||'%') || ') ';
    END IF;

    -- TopN=0 => sinir yok (TAM liste); LIMIT 0 bos kume dondururdu
    q := q || w || ' ORDER BY 4 DESC LIMIT ' ||
         CASE WHEN v_topn > 0 THEN v_topn::text ELSE 'ALL' END;
    RETURN QUERY EXECUTE q;
END $$;
