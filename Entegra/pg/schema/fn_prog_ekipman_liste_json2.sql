-- ============================================================
-- fn_prog_ekipman_liste_json2 — MSSQL sp_Prog_Ekipman_Liste_Json2 PG portu
--   Ekipman liste (agac). Ozyinelemeli CTE (PagesList) -> ALTID(TreeID)+USTID(parent path)
--   + E2.* (EKIPMANLAR 18 kolon) + STOKLU + MARKAAD + MODELAD + KA_SIRA.
--   @Baslik (EkAlanlar) YOK SAYILIR (sabit RETURNS TABLE'a ek-kolon eklenemez; superset dondur).
--   Govde DINAMIK (RETURN QUERY EXECUTE): @Mod 3/5 -> KULLANICI_ARAMA EXISTS suzgeci + KA_SIRA,
--     SubeYetkiList -> IN() (app-int-list guard), ORDER BY KA_SIRA DESC NULLS LAST, USTID, AD, TOP->LIMIT.
--   MSSQL->PG: CHARINDEX->position, REVERSE/SUBSTRING/LEN->reverse/substring..from..for/length,
--     convert(bit,..)->::smallint, top1..->LIMIT 1, convert(int,'-2727'+..)->('-2727'||marka::text)::int,
--     CAST(datetime AS FLOAT)->extract(epoch from ..), isnull->coalesce.
--   NOT: MSSQL govdesi statik+guard; PG'de sablon deseni geregi dinamik. Sube LIKE-uyelik testi
--        IN() ile birebir esdeger (SubeYetkiList app-uretimi, ~'^[0-9, ]+$' guard).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_ekipman_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_ekipman_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    altid text, ustid text,
    -- EKIPMANLAR.* (18 kolon)
    id integer, urunid integer, ekipmantur smallint, kod varchar(25), ad varchar(100),
    aciklama varchar(1000), uygulamasuresi varchar(50), ekleyen integer, eklemetarihi timestamp,
    degistiren integer, degistirmetarihi timestamp, durum smallint, detaybolumu varchar(20),
    subeid smallint, kategori smallint, sahip smallint, marka smallint, model smallint,
    -- hesapli kolonlar
    stoklu smallint, markaad text, modelad text, ka_sira double precision
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn   int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);   -- sablon uyumu (agac sorgusunda TOP yok; LIMIT olarak uygulanir)
    v_mod    int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_subelist text := NULLIF(j->>'SubeYetkiList','');          -- app-uretimi int listesi (GUVENILIR; guard'li)
    v_kulid  int  := NULLIF(j->>'KulId','')::int;
    v_modul  int  := NULLIF(j->>'Modul','')::int;
    ka_sira_expr text := 'NULL::double precision';
    q text; w text := ' WHERE 1=1 '; lim text := '';
BEGIN
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;

    -- Sube-yetki suzgeci (yalniz SubeVarmi ise gonderilir; int-liste guard).
    IF v_subelist IS NOT NULL AND v_subelist ~ '^[0-9, ]+$' THEN
        w := w || ' AND e2.subeid IN ('||v_subelist||') ';
    END IF;

    -- Son/Sik (Mod 3/5): yalniz kullanicinin actigi ekipmanlar + KA_SIRA hesap kolonu.
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        w := w || ' AND EXISTS (SELECT 1 FROM kullanici_arama ka WHERE ka.kayitid=e2.id'
               || ' AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||') ';
        IF v_mod = 5 THEN
            ka_sira_expr := '(SELECT extract(epoch FROM max(ka.degistirmetarihi)) FROM kullanici_arama ka'
                         || ' WHERE ka.kayitid=e2.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||')';
        ELSE
            ka_sira_expr := '(SELECT CAST(max(ka.say) AS double precision) FROM kullanici_arama ka'
                         || ' WHERE ka.kayitid=e2.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||')';
        END IF;
    END IF;

    q := 'WITH RECURSIVE pageslist(ekipmanid, treeid) AS (
            SELECT e.id, e.id::varchar(254) AS treeid FROM ekipmanlar e
            UNION ALL
            SELECT ed.ekipmanid, (p.treeid||''.''||ed.ekipmanid::varchar(200))::varchar(254)
            FROM ekipmandetay ed INNER JOIN pageslist p ON ed.ustekipmanid=p.ekipmanid
          )
          SELECT
            p.treeid::text AS altid,
            (CASE WHEN position(''.'' in p.treeid)=0 THEN ''''
                  ELSE reverse(substring(reverse(p.treeid)
                         from position(''.'' in reverse(p.treeid))+1
                         for length(p.treeid)-(position(''.'' in reverse(p.treeid))-1)))
             END)::text AS ustid,
            e2.*,
            (CASE WHEN COALESCE(e2.urunid,0)<>0 THEN 1 ELSE 0 END)::smallint AS stoklu,
            (CASE WHEN e2.sahip=0 THEN (SELECT anahtar FROM genini WHERE bolum=-2727 AND deger=e2.marka AND dil=-1 LIMIT 1)
                  ELSE (SELECT anahtar FROM genini WHERE bolum=-2701 AND deger=e2.marka AND dil=-1 LIMIT 1) END)::text AS markaad,
            (CASE WHEN e2.sahip=0 THEN (SELECT anahtar FROM genini WHERE bolum=(''-2727''||e2.marka::text)::int AND deger=e2.model AND dil=-1 LIMIT 1)
                  ELSE (SELECT anahtar FROM genini WHERE bolum=(''-2701''||e2.marka::text)::int AND deger=e2.model AND dil=-1 LIMIT 1) END)::text AS modelad,
            '||ka_sira_expr||' AS ka_sira
          FROM pageslist p
            INNER JOIN ekipmanlar e2 ON e2.id=p.ekipmanid
          '||w||'
          ORDER BY ka_sira DESC NULLS LAST, ustid, ad'||lim;

    RETURN QUERY EXECUTE q;
END $$;
