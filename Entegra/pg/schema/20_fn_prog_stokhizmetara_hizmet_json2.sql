-- ============================================================
-- fn_prog_stokhizmetara_hizmet_json2 — MSSQL sp_Prog_StokHizmetAra_Hizmet_Json2 PG portu
-- ------------------------------------------------------------
-- StokHizmetAra "Hizmet" sekmesi listesi (2 param: baslik = ek-kolon fragmenti / KULLANILMAZ;
--   kosullar = JSON filtreler). AramaBos (Kod/Ad/Barkod hepsi bos) iken HESAPPLANI baslik
--   satirlari + MASRAFGELIR(hizmet)/FIYATLAR; aksi halde yalniz MASRAFGELIR filtreli.
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, LIKE(CI)->ILIKE,
--   N'%'+x+'%' -> '%'||x||'%', CHARINDEX('.',REVERSE(X)) -> strpos(reverse(X),'.'),
--   LEN->length, bit->smallint/int. Metin filtreleri $1/$2/$3 PARAMETRELI (injection yok).
-- ROOTKOD = KOD'un son '.' oncesi (kok kategori kodu); kok yoksa '.'.
-- Kolonlar RETURNS tipine EXPLICIT ::cast (UNION dal tip-cakismasi guvencesi).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_stokhizmetara_hizmet_json2(text, text);
CREATE FUNCTION public.fn_prog_stokhizmetara_hizmet_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, kod varchar, rootkod varchar, ad varchar, tur varchar,
    kalan numeric, fiyat numeric, kur varchar, stokmarka varchar, stokmodel varchar,
    kdv integer, otvyuzde smallint, otvmiktar numeric, kdvdurum smallint,
    paket smallint, izleme smallint, birim integer, stokgrubu varchar,
    masrafid integer, ozelkod varchar
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
    v_fiyatadi  int  := COALESCE(NULLIF(j->>'FiyatAdi', '')::int, 0);
    v_satis     int  := COALESCE(NULLIF(j->>'Satis', '')::int, 1);   -- 1=cikis/gelir, 0=giris/gider
    v_adetbirim int  := COALESCE(NULLIF(j->>'AdetBirimi', '')::int, 0);
    v_kod       text := NULLIF(j->>'Kod', '');
    v_ad        text := NULLIF(j->>'Ad', '');
    v_barkod    text := NULLIF(j->>'Barkod', '');
    v_subevar   int  := COALESCE(NULLIF(j->>'SubeVar', '')::int, 0);
    v_subeid    int  := COALESCE(NULLIF(j->>'SubeID', '')::int, 0);
    -- Mod: 4=normal/filtre, 5=Son Aranan (degistirmetarihi desc), 6=Sik Aranan (say desc).
    --   kullanici_arama.modul hizmette 248002 (Hizmetler) - stok listesinden AYRI liste.
    v_mod       int  := COALESCE(NULLIF(j->>'Mod', '')::int, 4);
    v_kulid     int  := NULLIF(j->>'KulId', '')::int;
    v_modul     int  := NULLIF(j->>'Modul', '')::int;
    v_sonaranan boolean := (COALESCE(NULLIF(j->>'Mod','')::int,4) IN (5,6)
                            AND NULLIF(j->>'KulId','') IS NOT NULL AND NULLIF(j->>'Modul','') IS NOT NULL);
    v_sikaranan boolean := (COALESCE(NULLIF(j->>'Mod','')::int,4) = 6
                            AND NULLIF(j->>'KulId','') IS NOT NULL AND NULLIF(j->>'Modul','') IS NOT NULL);
    v_jka       text := '';
    v_varsayilan int := CASE WHEN COALESCE(NULLIF(j->>'Satis','')::int,1) = 1 THEN 3 ELSE 2 END;
    v_aramabos  boolean := (COALESCE(NULLIF(j->>'Mod','')::int,4) NOT IN (5,6))
                           AND (NULLIF(j->>'Kod','') IS NULL) AND (NULLIF(j->>'Ad','') IS NULL)
                           AND (NULLIF(j->>'Barkod','') IS NULL);
    -- ROOTKOD ic-ifadesi (X icin): son '.' oncesi (tersten strpos)
    v_rk_h text := 'reverse(substring(reverse(h.hesapkodu), strpos(reverse(h.hesapkodu),''.'')+1,'
                   || ' length(h.hesapkodu)-(strpos(reverse(h.hesapkodu),''.'')-1)))';
    v_rk_m text := 'reverse(substring(reverse(m.kod), strpos(reverse(m.kod),''.'')+1,'
                   || ' length(m.kod)-(strpos(reverse(m.kod),''.'')-1)))';
    v_sql text := '';
BEGIN
    -- Son/Sik modu: metin filtresi devre disi, kullanici_arama join'i devrede (masrafgelir.id = ka.kayitid)
    IF v_sonaranan THEN
        v_kod := NULL; v_ad := NULL; v_barkod := NULL;
        v_jka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=m.id AND ka.kulid=' || v_kulid
                 || ' AND ka.modul=' || v_modul;
    END IF;

    -- HESAPPLANI baslik satirlari (yalnizca arama bos iken)
    IF v_aramabos THEN
        v_sql := v_sql ||
            'SELECT h.id::integer, h.hesapkodu::varchar,'
            || ' (CASE WHEN h.hesapkodu = ' || v_rk_h || ' THEN ''.'' ELSE ' || v_rk_h || ' END)::varchar,'
            || ' h.hesapadi::varchar, ''Başlık''::varchar,'
            || ' NULL::numeric, NULL::numeric, NULL::varchar, NULL::varchar, NULL::varchar,'
            || ' NULL::integer, NULL::smallint, NULL::numeric, NULL::smallint,'
            || ' 0::smallint, 0::smallint, NULL::integer, NULL::varchar, NULL::integer, NULL::varchar'
            || ' FROM hesapplani h WHERE h.varsayilan = ' || v_varsayilan
            || ' UNION ALL ';
    END IF;

    -- MASRAFGELIR (hizmet/baslik) + FIYATLAR
    v_sql := v_sql ||
        'SELECT m.id::integer, m.kod::varchar,'
        || ' (CASE WHEN m.kod = ' || v_rk_m || ' THEN ''.'' ELSE ' || v_rk_m || ' END)::varchar,'
        || ' m.ad::varchar,'
        || ' (CASE WHEN m.baslik=0 THEN ''Hizmet'' ELSE ''Başlık'' END)::varchar,'
        || ' NULL::numeric,'
        || ' (CASE WHEN m.baslik=1 THEN NULL ELSE COALESCE(f.fiyat,-1) END)::numeric,'
        || ' (CASE WHEN m.baslik=1 THEN NULL ELSE f.kur END)::varchar,'
        || ' NULL::varchar, NULL::varchar,'
        || ' (CASE WHEN m.baslik=1 THEN NULL ELSE m.kdv END)::integer,'
        || ' NULL::smallint, NULL::numeric,'
        || ' (CASE WHEN m.baslik=1 THEN NULL ELSE f.kdvdurum END)::smallint,'
        || ' 0::smallint, 0::smallint,'
        || ' (CASE WHEN m.baslik=1 THEN NULL ELSE COALESCE(m.birim,' || v_adetbirim || ') END)::integer,'
        || ' NULL::varchar, NULL::integer, m.ozelkod::varchar'
        || ' FROM masrafgelir m'
        || ' LEFT OUTER JOIN fiyatlar f ON m.id=f.hizmetid AND f.fiyatadi=' || v_fiyatadi
        || '   AND f.paketid=0 AND f.satis=' || v_satis
        || v_jka
        || ' WHERE m.gelirmi=' || v_satis || ' AND m.durum>0'
        || ' AND ($1::text IS NULL OR m.kod ILIKE ''%''||$1||''%'')'
        || ' AND ($2::text IS NULL OR m.ad ILIKE ''%''||$2||''%'')'
        || ' AND ($3::text IS NULL OR COALESCE(m.barkod,'''') ILIKE ''%''||$3||''%'')';

    IF v_subevar = 1 THEN
        v_sql := v_sql || ' AND m.subeid IN (0,' || v_subeid || ')';
    END IF;

    v_sql := v_sql || CASE WHEN v_sikaranan THEN ' ORDER BY ka.say DESC, ka.degistirmetarihi DESC'
                           WHEN v_sonaranan THEN ' ORDER BY ka.degistirmetarihi DESC'
                           ELSE ' ORDER BY 2' END;

    RETURN QUERY EXECUTE v_sql USING v_kod, v_ad, v_barkod;
END $$;
