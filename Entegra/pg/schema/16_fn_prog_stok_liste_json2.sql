-- ============================================================
-- fn_prog_stok_liste_json2 — MSSQL sp_Prog_Stok_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- Stok liste (2 param: baslik = SELECT ek-kolon fragmenti / app-uretimi-GUVENILIR;
--   kosullar = JSON filtreler). @Mod 1=Tum 2=CokKullanilan 3=Sik 4=Filtre 5=Son.
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, TOP(N)->LIMIT N,
--   LIKE (MSSQL CI)-> ILIKE (PG deterministic collation), N'%'+x+'%' -> '%'||x||'%',
--   CONVERT(INT,'-2701'+CONVERT(VARCHAR,S.MARKA)) -> ('-2701'||s.marka::text)::int,
--   TOP1 skaler subquery -> LIMIT 1, bit/tinyint -> smallint(int). Kolonlar lowercase.
-- DINAMIK SQL: baslik (ek kolon) select-list'e enjekte edilir; metin filtreleri (StokAdi/
--   Kod/Barkod) $1/$2/$3 ile PARAMETRELI (injection yok), sayisal/liste degerler int-cast
--   sonrasi inline (SP ile birebir). RETURN QUERY EXECUTE ... USING.
-- TUZAK/LIMIT: RETURNS TABLE sabit 26 kolon. baslik BOS iken (varsayilan) birebir calisir.
--   baslik DOLU ise ek kolonlar RETURNS TABLE'a sigmaz (PG RETURNS TABLE dinamik olamaz) ->
--   cagiran taraf eslesen kolon tanimiyla cagirmali; base-kolon senaryosu tam desteklenir.
-- Her kolon RETURNS tipine EXPLICIT ::cast (dal/tablo tip cakismasi guvencesi).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_stok_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_stok_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, kod varchar, stokadi varchar, ad varchar, tipi smallint, marka smallint,
    grubu smallint, ozellik smallint, icerik smallint, ozelkod varchar, subeid smallint,
    urunno varchar, muhkodu varchar, anabirim smallint, birim2 smallint,
    birim2miktar double precision, minstok integer, kdv smallint, durum smallint,
    hucre varchar, izleme smallint, bildirim smallint, notlar varchar,
    stokmodel varchar, sdkalan double precision, recetevar integer
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
    v_selectlist    text := '';  -- @Baslik (EkAlanlar) YOK SAYILIR: PG sabit RETURNS TABLE'a ek-kolon eklenemez;
                                 -- app her zaman non-bos EkAlanlar gonderir -> enjeksiyon kolon-sayisi bozar/patlar.
                                 -- Base kolonlar doner; kullanici-ozel alanlar grid'de bos (pilot). (dokuman/pdks deseni)
    v_topn          int  := COALESCE(NULLIF(j->>'TopN', '')::int, 200);
    v_mod           int  := COALESCE(NULLIF(j->>'Mod', '')::int, 4);
    v_pasif         int  := COALESCE(NULLIF(j->>'Pasif', '')::int, 0);
    v_stokadi       text := NULLIF(j->>'StokAdi', '');
    v_kod           text := NULLIF(j->>'Kod', '');
    v_kategoriid    int  := NULLIF(j->>'KategoriID', '')::int;
    v_markaid       int  := NULLIF(j->>'MarkaID', '')::int;
    v_modelid       int  := NULLIF(j->>'ModelID', '')::int;
    v_grubuid       int  := NULLIF(j->>'GrubuID', '')::int;
    v_subeid        int  := NULLIF(j->>'SubeID', '')::int;
    v_barkod        text := NULLIF(j->>'Barkod', '');
    v_subeyetkilist text := NULLIF(j->>'SubeYetkiList', '');
    v_cokkullanbolum int := NULLIF(j->>'CokKullanBolum', '')::int;
    v_kulid         int  := NULLIF(j->>'KulId', '')::int;
    v_modul         int  := NULLIF(j->>'Modul', '')::int;
    v_orderby       text := NULLIF(j->>'OrderBy', '');
    v_sql           text;
BEGIN
    -- ---- SELECT (sabit kolonlar, RETURNS tipine explicit cast) ----
    v_sql :=
        'SELECT'
        || ' s.id::integer, s.kod::varchar, s.stokadi::varchar, k.ad::varchar, s.tipi::smallint,'
        || ' s.marka::smallint, s.grubu::smallint, s.ozellik::smallint, s.icerik::smallint,'
        || ' s.ozelkod::varchar, s.subeid::smallint, s.urunno::varchar, s.muhkodu::varchar,'
        || ' s.anabirim::smallint, s.birim2::smallint, s.birim2miktar::double precision,'
        || ' s.minstok::integer, s.kdv::smallint, s.durum::smallint, s.hucre::varchar,'
        || ' s.izleme::smallint, s.bildirim::smallint, s.notlar::varchar,'
        || ' (SELECT g.anahtar FROM genini g'
        || '    WHERE g.dil < 0 AND g.deger = s.model'
        || '      AND g.bolum = (''-2701'' || s.marka::text)::int LIMIT 1)::varchar AS stokmodel,'
        || ' (SELECT sum(sd.kalan) FROM stokdurum sd WHERE sd.stokid = s.id)::double precision AS sdkalan,'
        || ' COALESCE((SELECT 1 FROM uretimrecete ur WHERE ur.stokid = s.id LIMIT 1), 0)::integer AS recetevar';

    -- ---- @Baslik: ek kolon fragmenti (app-uretimi/guvenilir) ----
    IF v_selectlist <> '' THEN
        v_sql := v_sql || ', ' || v_selectlist;
    END IF;

    v_sql := v_sql || ' FROM stoklar s LEFT OUTER JOIN kategori k ON k.id = s.kategori';

    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi 1:1 join
    IF v_mod IN (3, 5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_sql := v_sql
            || ' INNER JOIN kullanici_arama ka ON ka.kayitid = s.id'
            || ' AND ka.kulid = ' || v_kulid || ' AND ka.modul = ' || v_modul;
    END IF;

    v_sql := v_sql || ' WHERE 1 = 1';

    -- Pasif kapaliyken sadece aktif
    IF v_pasif = 0 THEN
        v_sql := v_sql || ' AND s.durum = 1';
    END IF;

    -- Sube yetkisi (app-uretimi liste)
    IF v_subeyetkilist IS NOT NULL AND v_subeyetkilist <> '' THEN
        v_sql := v_sql || ' AND s.subeid IN (0,' || v_subeyetkilist || ')';
    END IF;

    -- @Mod=2: Cok Kullanilanlar (GENINI) - EXISTS
    IF v_mod = 2 AND v_cokkullanbolum IS NOT NULL THEN
        v_sql := v_sql
            || ' AND EXISTS (SELECT 1 FROM genini g WHERE g.bolum = ' || v_cokkullanbolum
            || ' AND g.anahtar = s.kod AND g.dil = -1)';
    END IF;

    -- Metin filtreleri (PARAMETRELI $1/$2 - her zaman gomulu, NULL ise no-op)
    v_sql := v_sql || ' AND ($1::text IS NULL OR s.stokadi ILIKE ''%''||$1||''%'')';
    v_sql := v_sql || ' AND ($2::text IS NULL OR (s.kod ILIKE ''%''||$2||''%'' OR s.urunno ILIKE ''%''||$2||''%''))';

    -- Sayisal filtreler (int-cast sonrasi inline)
    IF v_kategoriid IS NOT NULL AND v_kategoriid > 0 THEN
        v_sql := v_sql || ' AND s.kategori = ' || v_kategoriid;
    END IF;
    IF v_markaid IS NOT NULL AND v_markaid > 0 THEN
        v_sql := v_sql || ' AND s.marka = ' || v_markaid;
    END IF;
    IF v_modelid IS NOT NULL AND v_modelid > 0 THEN
        v_sql := v_sql || ' AND s.model = ' || v_modelid;
    END IF;
    IF v_grubuid IS NOT NULL AND v_grubuid > 0 THEN
        v_sql := v_sql || ' AND s.grubu = ' || v_grubuid;
    END IF;
    IF v_subeid IS NOT NULL AND v_subeid < 1 THEN
        v_sql := v_sql || ' AND s.subeid = ' || v_subeid;
    END IF;

    -- Barkod ($3 anchor: her dalda gomulu tutulur -> USING sayisi sabit)
    IF v_barkod IS NULL THEN
        v_sql := v_sql || ' AND $3 IS NOT DISTINCT FROM $3';
    ELSIF upper(v_barkod) = 'NULL' THEN
        v_sql := v_sql || ' AND NOT EXISTS (SELECT 1 FROM stokbarkod sb WHERE sb.stokid = s.id) AND $3 IS NOT DISTINCT FROM $3';
    ELSIF upper(v_barkod) = 'NOT NULL' THEN
        v_sql := v_sql || ' AND EXISTS (SELECT 1 FROM stokbarkod sb WHERE sb.stokid = s.id) AND $3 IS NOT DISTINCT FROM $3';
    ELSE
        v_sql := v_sql || ' AND EXISTS (SELECT 1 FROM stokbarkod sb WHERE sb.stokid = s.id AND sb.barkod ILIKE $3||''%'')';
    END IF;

    -- Son/Sik siralamasi (KULLANICI_ARAMA)
    IF v_mod = 5 THEN
        v_orderby := 'ka.degistirmetarihi desc';
    ELSIF v_mod = 3 THEN
        v_orderby := 'ka.say desc';
    END IF;

    IF v_orderby IS NOT NULL AND v_orderby <> '' THEN
        v_sql := v_sql || ' ORDER BY ' || v_orderby;
    END IF;

    -- TOP (N) -> LIMIT N
    IF v_topn > 0 THEN
        v_sql := v_sql || ' LIMIT ' || v_topn;
    END IF;

    RETURN QUERY EXECUTE v_sql USING v_stokadi, v_kod, v_barkod;
END $$;
