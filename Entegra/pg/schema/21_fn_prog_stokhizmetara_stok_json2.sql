-- ============================================================
-- fn_prog_stokhizmetara_stok_json2 — MSSQL sp_Prog_StokHizmetAra_Stok_Json2 PG portu
-- ------------------------------------------------------------
-- StokHizmetAra "Stok" sekmesi listesi. 2 param: baslik = ek-kolon fragmenti / KULLANILMAZ
--   (PG sabit RETURNS TABLE); kosullar = JSON filtreler.
-- 2 dal: B1=ANABIRIM (her zaman), B2=BIRIM2 (Sayim=0 & Birim2Getir=1 & SonAranan=0; alt birim).
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, LIKE(CI)->ILIKE,
--   TOP(N)->LIMIT N, CAST('-2701'+CAST(MARKA AS VARCHAR)AS INT)->('-2701'||marka::text)::int,
--   ROUND(x,0,1)[trunc]->trunc(x), REPLACE zinciri aynen. bit->0/1 int.
-- Metin filtreleri PARAMETRELI: $1=Kod $2=Ad $3=Barkod $4=Serino $5=CariDoviz $6=Lotno (injection yok).
--   B1 WHERE'de $1..$4 "IS NOT DISTINCT FROM" ile ANCHOR (SonAranan'da filtre yokken de USING
--   sayisi sabit kalsin diye); $5 KUR'da her dalda gomulu. Sayisal/liste degerler int-cast inline.
-- Kolonlar RETURNS tipine EXPLICIT ::cast (UNION dal tip-cakismasi guvencesi). 20 kolon.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_stokhizmetara_stok_json2(text, text);
CREATE FUNCTION public.fn_prog_stokhizmetara_stok_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, kod varchar, urunno varchar, ad varchar, tur varchar,
    kalan numeric, fiyat numeric, kur varchar, stokmarka varchar, stokmodel varchar,
    kdv integer, otvyuzde smallint, otvmiktar numeric, kdvdurum smallint,
    paket smallint, izleme smallint, birim integer, stokgrubu varchar,
    masrafid integer, ozelkod varchar
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
    v_depo      int  := COALESCE(NULLIF(j->>'Depo', '')::int, 0);
    v_fiyatadi  int  := COALESCE(NULLIF(j->>'FiyatAdi', '')::int, 0);
    v_rehberid  int  := COALESCE(NULLIF(j->>'RehberID', '')::int, 0);
    v_satis     int  := COALESCE(NULLIF(j->>'Satis', '')::int, 1);
    v_dil       int  := COALESCE(NULLIF(j->>'Dil', '')::int, -1);
    v_caridoviz text := COALESCE(NULLIF(j->>'CariDoviz', ''), 'TL');
    v_adetbirim int  := COALESCE(NULLIF(j->>'AdetBirimi', '')::int, 0);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN', '')::int, 200);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod', '')::int, 4);
    v_kulid     int  := NULLIF(j->>'KulId', '')::int;
    v_modul     int  := NULLIF(j->>'Modul', '')::int;
    v_kod       text := NULLIF(j->>'Kod', '');
    v_ad        text := NULLIF(j->>'Ad', '');
    v_barkod    text := NULLIF(j->>'Barkod', '');
    v_serino    text := NULLIF(j->>'Serino', '');
    v_lotno     text := NULLIF(j->>'Lotno', '');
    v_grubuid   int  := NULLIF(j->>'GrubuID', '')::int;
    v_ozellikid int  := NULLIF(j->>'OzellikID', '')::int;
    v_markaid   int  := NULLIF(j->>'MarkaID', '')::int;
    v_modelid   int  := NULLIF(j->>'ModelID', '')::int;
    v_icerikid  int  := NULLIF(j->>'IcerikID', '')::int;
    v_kategoriid int := NULLIF(j->>'KategoriID', '')::int;
    v_kategoriara int := COALESCE(NULLIF(j->>'KategoriArama', '')::int, 0);
    v_esdeger   text := NULLIF(j->>'Esdeger', '');       -- csv int id (app-uretimi, guvenilir)
    v_bufirma   int  := COALESCE(NULLIF(j->>'BuFirma', '')::int, 0);
    v_olmayan   int  := COALESCE(NULLIF(j->>'Olmayanlar', '')::int, 0);
    v_sayim     int  := COALESCE(NULLIF(j->>'Sayim', '')::int, 0);
    v_sayimid   int  := COALESCE(NULLIF(j->>'SayimID', '')::int, 0);
    v_birim2get int  := COALESCE(NULLIF(j->>'Birim2Getir', '')::int, 1);

    v_sonaranan boolean := (v_mod = 5 AND v_kulid IS NOT NULL AND v_modul IS NOT NULL);
    v_hasbarkod boolean;
    v_top       text := CASE WHEN v_topn > 0 THEN ' LIMIT ' || v_topn ELSE '' END;
    v_filt      text := '';
    v_sifir     text := '';
    v_jgenini   text;
    v_jbufirma  text := '';
    v_jka       text := '';
    v_masrafkol text;
    v_stgun     text;   -- STOKDURUM alt-sorgu (kalan; depoya gore)
    v_b1 text; v_b2 text := ''; v_order text; v_sql text;
BEGIN
    v_hasbarkod := (v_barkod IS NOT NULL AND NOT v_sonaranan);

    -- ---- Ortak filtre (WHERE eklentileri; iki dal da kullanir) ----
    IF NOT v_sonaranan THEN
        IF v_kategoriara = 0 THEN
            v_filt := v_filt || ' AND ($1::text IS NULL OR (s.kod ILIKE ''%''||$1||''%'' OR s.urunno ILIKE ''%''||$1||''%''))';
            v_filt := v_filt || ' AND ($2::text IS NULL OR s.stokadi ILIKE ''%''||$2||''%'')';
            IF v_hasbarkod THEN
                v_filt := v_filt || ' AND (stb.barkod ILIKE ''%''||$3||''%'' OR $3 ILIKE replace(replace(replace(stb.barkod,''O'',''_''),''P'',''_''),''Q'',''_''))';
            END IF;
            -- SERI NO: stokserilot.serino (stokizleme'de serino kolonu YOK; serilotid FK).
            IF v_serino IS NOT NULL THEN
                v_filt := v_filt || ' AND s.id IN (SELECT ssl.stokid FROM stokserilot ssl WHERE ssl.serino ILIKE ''%''||$4||''%'')';
            END IF;
            -- LOT NO: stokserilot.lotno (+lotno_ex serbest alan). $6 parametresi.
            IF v_lotno IS NOT NULL THEN
                v_filt := v_filt || ' AND s.id IN (SELECT ssl2.stokid FROM stokserilot ssl2 WHERE ssl2.lotno ILIKE ''%''||$6||''%'' OR ssl2.lotno_ex ILIKE ''%''||$6||''%'')';
            END IF;
            IF v_grubuid   > 0 THEN v_filt := v_filt || ' AND s.grubu='   || v_grubuid;   END IF;
            IF v_ozellikid > 0 THEN v_filt := v_filt || ' AND s.ozellik=' || v_ozellikid; END IF;
            IF v_markaid   > 0 THEN v_filt := v_filt || ' AND s.marka='   || v_markaid;   END IF;
            IF v_modelid   > 0 THEN v_filt := v_filt || ' AND s.model='   || v_modelid;   END IF;
            IF v_icerikid  > 0 THEN v_filt := v_filt || ' AND s.icerik='  || v_icerikid;  END IF;
        ELSIF v_kategoriid > 0 THEN
            v_filt := v_filt || ' AND s.kategori=' || v_kategoriid;
        END IF;

        IF v_esdeger IS NOT NULL THEN
            v_filt := v_filt || ' AND s.id IN (' || v_esdeger || ')';
        END IF;
        IF v_sayim = 1 THEN
            v_filt := v_filt || ' AND s.kullanim=1 AND s.id NOT IN (SELECT ssk.stokid FROM stoksayimkalemleri ssk WHERE ssk.sayimid=' || v_sayimid || ')';
        END IF;
    END IF;

    -- $1..$4 ANCHOR (SonAranan/kategori dallarinda filtre olmasa da USING sayisi sabit kalsin)
    v_filt := v_filt || ' AND ($1 IS NOT DISTINCT FROM $1) AND ($2 IS NOT DISTINCT FROM $2)'
                     || ' AND ($3 IS NOT DISTINCT FROM $3) AND ($4 IS NOT DISTINCT FROM $4)';

    -- SifirGelmesin (cikis + olmayanlar kapali -> sadece stogu olan)
    v_stgun := '(SELECT COALESCE(SUM(sd.kalan),0) FROM stokdurum sd WHERE sd.stokid=s.id AND sd.depoid=' || v_depo || ')';
    IF v_satis = 1 AND v_olmayan = 0 THEN
        v_sifir := ' AND ' || v_stgun || ' > 0';
    END IF;

    -- Join eklentileri
    IF v_bufirma = 1 THEN
        v_jbufirma := ' INNER JOIN isortagi io ON s.id=io.stokid AND io.rehberid=' || v_rehberid;
    END IF;
    IF v_sonaranan THEN
        v_jka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=s.id AND ka.kulid=' || v_kulid || ' AND ka.modul=' || v_modul;
    END IF;
    v_masrafkol := CASE WHEN v_satis = 0 THEN ' s.masrafid::integer' ELSE ' s.gelirid::integer' END;
    v_jgenini :=
        ' LEFT OUTER JOIN genini stokmarka ON stokmarka.deger=s.marka AND stokmarka.dil=' || v_dil || ' AND stokmarka.bolum=-2701'
     || ' LEFT OUTER JOIN genini stokmodel ON stokmodel.deger=s.model AND stokmodel.dil=' || v_dil || ' AND stokmodel.bolum=(''-2701''||s.marka::text)::int'
     || ' LEFT OUTER JOIN genini stokgrubu ON s.grubu=stokgrubu.deger AND stokgrubu.dil=' || v_dil || ' AND stokgrubu.bolum=-2704';

    -- ---- BRANCH 1: ANABIRIM ----
    v_b1 :=
        'SELECT s.id::integer, s.kod::varchar, s.urunno::varchar, s.stokadi::varchar, ''Stok''::varchar,'
        || ' ' || v_stgun || '::numeric,'
        || ' COALESCE(sf.fiyat,-1)::numeric, COALESCE(sf.kur,$5)::varchar,'
        || ' stokmarka.anahtar::varchar, stokmodel.anahtar::varchar,'
        || ' s.kdv::integer, s.otvyuzde::smallint, s.otvmiktar::numeric, sf.kdvdurum::smallint,'
        || ' COALESCE(s.paket,0)::smallint, COALESCE(s.izleme,0)::smallint,'
        || ' COALESCE(s.anabirim,' || v_adetbirim || ')::integer, stokgrubu.anahtar::varchar,'
        || v_masrafkol || ', s.ozelkod::varchar'
        || ' FROM stoklar s'
        || ' LEFT OUTER JOIN stokfiyat sf ON s.id=sf.stokid AND sf.birim=s.anabirim AND sf.fiyatadi=' || v_fiyatadi || ' AND sf.paketid=0 AND sf.satis=' || v_satis
        || v_jgenini || v_jbufirma || v_jka
        || CASE WHEN v_hasbarkod THEN ' INNER JOIN stokbarkod stb ON s.id=stb.stokid AND s.anabirim=stb.barkodbirimi' ELSE '' END
        || ' WHERE s.durum=1' || v_sifir || v_filt;

    -- ---- BRANCH 2: BIRIM2 (alt birim) ----
    IF v_sayim = 0 AND v_birim2get = 1 AND NOT v_sonaranan THEN
        v_b2 :=
            ' UNION ALL SELECT s.id::integer, (s.kod||''#'')::varchar, s.urunno::varchar, s.stokadi::varchar, ''Stok''::varchar,'
            || ' trunc(' || v_stgun || '/NULLIF(s.birim2miktar,0))::numeric,'
            || ' COALESCE(sf.fiyat,-1)::numeric, COALESCE(sf.kur,$5)::varchar,'
            || ' stokmarka.anahtar::varchar, stokmodel.anahtar::varchar,'
            || ' s.kdv::integer, s.otvyuzde::smallint, s.otvmiktar::numeric, sf.kdvdurum::smallint,'
            || ' COALESCE(s.paket,0)::smallint, COALESCE(s.izleme,0)::smallint,'
            || ' COALESCE(s.birim2,' || v_adetbirim || ')::integer, stokgrubu.anahtar::varchar,'
            || v_masrafkol || ', s.ozelkod::varchar'
            || ' FROM stoklar s'
            || ' LEFT OUTER JOIN stokfiyat sf ON s.id=sf.stokid AND sf.birim=s.birim2 AND sf.fiyatadi=' || v_fiyatadi || ' AND sf.paketid=0 AND sf.satis=' || v_satis
            || v_jgenini || v_jbufirma || v_jka
            || CASE WHEN v_hasbarkod THEN ' INNER JOIN stokbarkod stb ON s.id=stb.stokid AND s.birim2=stb.barkodbirimi' ELSE '' END
            || ' WHERE s.durum=1 AND (s.anabirim <> COALESCE(s.birim2,s.anabirim))' || v_sifir || v_filt;
    END IF;

    -- ---- ORDER ----
    v_order := CASE WHEN v_sonaranan THEN ' ORDER BY ka.degistirmetarihi DESC' ELSE ' ORDER BY 2' END;

    v_sql := v_b1 || v_b2 || v_order || v_top;

    RETURN QUERY EXECUTE v_sql USING v_kod, v_ad, v_barkod, v_serino, v_caridoviz, v_lotno;
END $$;
