-- ============================================================
-- fn_prog_dokuman_liste_json2 — MSSQL sp_Prog_Dokuman_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- Dokuman liste: iki kol (arm1 DTIP=1 DOKUMAN, arm2 DTIP=0 DOKUMANKISAYOL) tek
--   WITH RECURSIVE dizin (ozyinelemeli klasor-yol) paylasir. @Mod 1/2/3.
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, TOP1->LIMIT1,
--   N'%'+x+'%' LIKE (CI)-> '%'||x||'%' ILIKE, WITH oz.->WITH RECURSIVE, REVERSE/CHARINDEX
--   (charindex shim), bit->smallint(int). Kolon adlari lowercase.
-- #variable_conflict use_column: OUT-param adlari (id/klasor/ad...) sorgu kolonlarina cakismasin.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_dokuman_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_dokuman_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, belgeno varchar(50), durum smallint, yon smallint, kategori smallint,
    ad varchar(300), konu varchar(200), tur smallint, bolum smallint, lokasyon integer,
    rehberid integer, ilgiliid integer, modul integer, bagi integer, klasor integer,
    gecerlilik_tarihi timestamp, eskiklasor integer, ekleyen integer, eklemetarihi timestamp,
    degistiren integer, degistirmetarihi timestamp, subeid smallint, gizlilikderecesi smallint,
    gizliliksuresi timestamp, modulid integer, modulproje integer, rehberiletisimid integer,
    tip integer, tipbilgisi varchar(50), demirbasid integer, arsivsuresi_yedek timestamp,
    arsivsuresi integer, arsivsuretipi smallint, anahtar text, tarih timestamp,
    dtip int, kisayolid integer, kurum varchar(120), lokasyonad varchar(100), sorumluad varchar(120),
    ext text, surum varchar(30), boyut numeric, klasorad varchar(260),
    onaylayacakad varchar(120), onaylayanad varchar(120), ekleyenad varchar(120), degistirenad varchar(120)
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_mod        int := COALESCE(NULLIF(j->>'Mod','')::int, 3);
    v_klasorid   int := NULLIF(j->>'KlasorId','')::int;
    v_tabno      int := NULLIF(j->>'TabNo','')::int;
    v_tamyetki   int := COALESCE(NULLIF(j->>'TamYetki','')::int, 0);
    v_gd         int := COALESCE(NULLIF(j->>'GD','')::int, 1);
    v_kullanan   int := COALESCE(NULLIF(j->>'Kullanan','')::int, 0);
    v_aradok     text := NULLIF(j->>'AraDokuman','');
    v_arakonu    text := NULLIF(j->>'AraKonu','');
    v_araanahtar text := NULLIF(j->>'AraAnahtar','');
    v_arakurum   text := NULLIF(j->>'AraKurum','');
    v_arasorumlu text := NULLIF(j->>'AraSorumlu','');
    v_aralok     text := NULLIF(j->>'AraLokasyon','');
    v_bolum      int := NULLIF(NULLIF(j->>'Bolum',''), '0')::int;
    v_modul      int := NULLIF(NULLIF(j->>'Modul',''), '0')::int;
    v_kategori   int := NULLIF(NULLIF(j->>'Kategori',''), '0')::int;
    v_pasif      int := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_tarihvar   int := COALESCE(NULLIF(j->>'TarihVar','')::int, 0);
    v_tarihbas   timestamp := NULLIF(j->>'TarihBas','')::timestamp;
    v_tarihbit   timestamp := NULLIF(j->>'TarihBit','')::timestamp;
BEGIN
    RETURN QUERY
    WITH RECURSIVE dizin AS (
        SELECT k0.id, k0.ustid, CAST(k0.ad AS varchar(260)) AS ad
        FROM dokumanklasor k0 WHERE k0.ustid = 0
        UNION ALL
        SELECT a.id, a.ustid, CAST(v.ad || '\' || a.ad AS varchar(260))
        FROM dokumanklasor a INNER JOIN dizin v ON v.id = a.ustid
    )
    -- arm1: DTIP=1 (DOKUMAN)
    SELECT DISTINCT
        d.*, 1 AS dtip, 0 AS kisayolid,
        firma.firma AS kurum, lok.aciklama AS lokasyonad, sorumlu.firma AS sorumluad,
        ('.' || i.belgeturu)::text AS ext, i.surum, i.boyut,
        (SELECT dz.ad    FROM dizin  dz WHERE dz.id = d.klasor) AS klasorad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = i.onaylayacak) AS onaylayacakad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = i.onay) AS onaylayanad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = d.ekleyen) AS ekleyenad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = d.degistiren) AS degistirenad
    FROM dokuman d
        INNER JOIN imaj i ON i.id = (SELECT i2.id FROM imaj i2 WHERE i2.yeri = 1 AND i2.yer_id = d.id ORDER BY i2.id DESC LIMIT 1)
        LEFT OUTER JOIN rehber   firma   ON firma.id   = d.rehberid
        LEFT OUTER JOIN lokasyon lok     ON lok.id     = d.lokasyon
        LEFT OUTER JOIN rehber   sorumlu ON sorumlu.id = i.rehberid
        LEFT OUTER JOIN dokumanyetki dy  ON dy.yeri = 321 AND dy.yerid = d.id
    WHERE
        ( v_mod = 1
          AND d.klasor = v_klasorid
          AND ( v_tamyetki = 1
                OR ( d.gizlilikderecesi <= v_gd AND dy.gor = 1
                     AND (dy.rehberid = 0 OR dy.rehberid = v_kullanan) ) ) )
        OR
        ( v_mod = 2
          AND (v_aradok     IS NULL OR d.ad             ILIKE '%'||v_aradok||'%')
          AND (v_arakonu    IS NULL OR d.konu           ILIKE '%'||v_arakonu||'%')
          AND (v_araanahtar IS NULL OR d.anahtar        ILIKE '%'||v_araanahtar||'%')
          AND (v_arakurum   IS NULL OR firma.firma      ILIKE '%'||v_arakurum||'%')
          AND (v_arasorumlu IS NULL OR sorumlu.firma    ILIKE '%'||v_arasorumlu||'%')
          AND (v_aralok     IS NULL OR lok.aciklama     ILIKE '%'||v_aralok||'%')
          AND (v_bolum      IS NULL OR d.bolum    = v_bolum)
          AND (v_modul      IS NULL OR d.modul    = v_modul)
          AND (v_kategori   IS NULL OR d.kategori = v_kategori)
          AND (v_pasif      = 1     OR d.durum    = 1)
          AND (v_tamyetki   = 1     OR d.gizlilikderecesi <= v_gd)
          AND (v_tarihvar   = 0     OR (d.tarih >= v_tarihbas AND d.tarih <= v_tarihbit)) )
        OR v_mod = 3

    UNION ALL

    -- arm2: DTIP=0 (DOKUMANKISAYOL)
    SELECT DISTINCT
        d.*, 0 AS dtip, dk.id AS kisayolid,
        firma.firma AS kurum, lok.aciklama AS lokasyonad, sorumlu.firma AS sorumluad,
        (CASE WHEN d.ad LIKE '%.%'
              THEN '.' || reverse(substring(reverse(COALESCE(d.ad,'.')) FROM 1 FOR charindex('.', reverse(COALESCE(d.ad,'.')), 1) - 1))
              ELSE '' END)::text AS ext,
        i.surum, i.boyut,
        (SELECT dz.ad    FROM dizin  dz WHERE dz.id = d.klasor) AS klasorad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = i.onaylayacak) AS onaylayacakad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = i.onay) AS onaylayanad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = d.ekleyen) AS ekleyenad,
        (SELECT r.firma  FROM rehber r  WHERE r.id = d.degistiren) AS degistirenad
    FROM dokumankisayol dk
        INNER JOIN dokuman d ON dk.dokumanid = d.id
        INNER JOIN imaj i ON i.id = (SELECT i2.id FROM imaj i2 WHERE i2.yeri = 1 AND i2.yer_id = d.id ORDER BY i2.id DESC LIMIT 1)
        LEFT OUTER JOIN rehber   firma   ON firma.id   = d.rehberid
        LEFT OUTER JOIN lokasyon lok     ON lok.id     = d.lokasyon
        LEFT OUTER JOIN rehber   sorumlu ON sorumlu.id = i.rehberid
    WHERE
        ( v_mod = 1 AND dk.yer = v_tabno AND dk.yer_id = v_klasorid )
        OR
        ( v_mod = 2
          AND (v_aradok     IS NULL OR d.ad             ILIKE '%'||v_aradok||'%')
          AND (v_arakonu    IS NULL OR d.konu           ILIKE '%'||v_arakonu||'%')
          AND (v_araanahtar IS NULL OR d.anahtar        ILIKE '%'||v_araanahtar||'%')
          AND (v_arakurum   IS NULL OR firma.firma      ILIKE '%'||v_arakurum||'%')
          AND (v_arasorumlu IS NULL OR sorumlu.firma    ILIKE '%'||v_arasorumlu||'%')
          AND (v_aralok     IS NULL OR lok.aciklama     ILIKE '%'||v_aralok||'%')
          AND (v_bolum      IS NULL OR d.bolum    = v_bolum)
          AND (v_modul      IS NULL OR d.modul    = v_modul)
          AND (v_kategori   IS NULL OR d.kategori = v_kategori)
          AND (v_pasif      = 1     OR d.durum    = 1)
          AND (v_tamyetki   = 1     OR d.gizlilikderecesi <= v_gd)
          AND (v_tarihvar   = 0     OR (d.tarih >= v_tarihbas AND d.tarih <= v_tarihbit)) )
        OR v_mod = 3;
END $$;
