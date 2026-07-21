-- ============================================================
-- fn_prog_ik_liste_json2 — IK (personel / aday) liste, PG portu
--   MSSQL kaynak: dbo.sp_Prog_IK_Liste_Json2 (GenUpdate/sp_Prog_IK_Liste_Json2.sql)
--   2 param: baslik = ham SELECT ek-kolon fragmenti (IK'da genelde BOS -> PG'de
--            sabit-imzali fonksiyon oldugundan ek kolon DONDURULEMEZ, gorulmezden gelinir),
--            kosullar = filtre JSON (Aday/Mod/Firma/UcretAlt ...).
--   Govde sp_executesql'i birebir yansitir: dinamik WHERE/FROM/ORDER, ardindan
--   sabit 23-kolon disari-sarma (outer wrapper) ile RETURNS TABLE eslesir.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_prog_ik_liste_json2(
    baslik   text DEFAULT '',
    kosullar text DEFAULT '{}'
)
RETURNS TABLE(
    id          integer,
    kod         text,
    vkno        text,
    adsoyad     text,
    cinsiyet    text,
    dyeri       text,
    uyrugu      text,
    dtarihi     timestamp without time zone,
    sektor      text,
    departman   text,
    gorevi      text,
    ogrenim     text,
    giristarihi timestamp without time zone,
    cikistarihi timestamp without time zone,
    ilcead      text,
    ilad        text,
    subeid      smallint,
    sube        text,
    notlar      text,
    durum       smallint,
    durumad     text,
    ozelkod     text,
    bagid       integer
)
LANGUAGE plpgsql
STABLE
AS $function$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);

    -- ---- JSON -> yerel degiskenler (absent -> NULL; ISNULL olanlar varsayilana) ----
    v_aday      int := COALESCE(NULLIF(j->>'Aday','')::int, 0);
    v_topn      int := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod       int := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_pasif     int := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_dil       int := COALESCE(NULLIF(j->>'Dil','')::int, -1);
    v_ilgili    int := COALESCE(NULLIF(j->>'IlgiliArama','')::int, 0);
    v_firma     text := NULLIF(j->>'Firma','');
    v_kod       text := NULLIF(j->>'Kod','');
    v_cinsiyet  int := NULLIF(j->>'Cinsiyet','')::int;
    v_ogrenim   int := NULLIF(j->>'Ogrenim','')::int;
    v_sektor    int := NULLIF(j->>'Sektor','')::int;
    v_departman int := NULLIF(j->>'Departman','')::int;
    v_gorev     int := NULLIF(j->>'Gorev','')::int;
    v_dil1      int := NULLIF(j->>'Dil1','')::int;
    v_dil2      int := NULLIF(j->>'Dil2','')::int;
    v_il        int := NULLIF(j->>'Il','')::int;
    v_uyruk     int := NULLIF(j->>'Uyruk','')::int;
    v_ucretalt  numeric := NULLIF(j->>'UcretAlt','')::numeric;
    v_ucretust  numeric := NULLIF(j->>'UcretUst','')::numeric;
    v_subeyetki text := NULLIF(j->>'SubeYetkiList','');
    v_teksube   int := COALESCE(NULLIF(j->>'TekSubeTum','')::int, 0);
    v_kulid     int := NULLIF(j->>'KulId','')::int;
    v_subeid    int := NULLIF(j->>'SubeId','')::int;
    v_modul     int := NULLIF(j->>'Modul','')::int;

    pdil text := v_dil::text;      -- @pDil inline
    pil  text := v_ilgili::text;   -- @pIlgili inline

    v_sel      text;
    v_frm      text;
    v_whr      text;
    v_ordsel   text := '';
    v_ord      text;
    v_distinct text := '';
    v_ka       boolean := false;
    v_inner    text;
    v_sql      text;
BEGIN
    IF v_aday = 0 THEN
        -- ---------- PERSONEL (GRUP=335) ----------
        v_sel :=
          'R.ID::int AS id, R.KOD::text AS kod,'
        ||'(SELECT rb.BILGI FROM REHBERBILGI rb WHERE rb.YERI=3 AND rb.YER_ID=R.ID AND rb.SIRA=22 LIMIT 1)::text AS vkno,'
        ||'R.FIRMA::text AS adsoyad,'
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-23355 AND g.DEGER=R.STATU AND g.DIL='||pdil||' LIMIT 1)::text AS cinsiyet,'
        ||'(SELECT il.ILADI FROM ILCELER ic JOIN ILLER il ON il.ILNO=ic.ILNO WHERE ic.ILCENO=R.BOLGE LIMIT 1)::text AS dyeri,'
        ||'(SELECT il.ILADI FROM ILLER il WHERE il.ILNO=R.ALTBOLGE LIMIT 1)::text AS uyrugu,'
        ||'R.DTARIH::timestamp AS dtarihi,'
        || chr(39)||chr(39)||'::text AS sektor,'  -- SEKTOR='' (bos metin)
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-2251 AND g.DEGER=ROL.DEPARTMAN AND g.DIL='||pdil||' LIMIT 1)::text AS departman,'
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-2252 AND g.DEGER=ROL.GOREVID AND g.DIL='||pdil||' LIMIT 1)::text AS gorevi,'
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-2255 AND g.DEGER=R.KATEGORI AND g.DIL='||pdil||' LIMIT 1)::text AS ogrenim,'
        ||'(SELECT ph.TARIH FROM PERS_HAREKET ph WHERE ph.REHBERID=R.ID AND ph.TUR=1 LIMIT 1)::timestamp AS giristarihi,'
        ||'(SELECT ph.TARIH FROM PERS_HAREKET ph WHERE ph.REHBERID=R.ID AND ph.TUR=99 LIMIT 1)::timestamp AS cikistarihi,'
        ||'(SELECT rb.BILGI FROM REHBERBILGI rb JOIN REHBERILETISIM ri ON ri.REHBERID=R.ID AND ri.VARSAYILAN=1 JOIN REHBERAYAR ra ON ra.YERI=1 AND ra.SIRA=rb.SIRA AND ra.YERI=rb.YERI WHERE rb.YER_ID=ri.ID AND ra.VARSAYILAN=6 LIMIT 1)::text AS ilcead,'
        ||'(SELECT rb.BILGI FROM REHBERBILGI rb JOIN REHBERILETISIM ri ON ri.REHBERID=R.ID AND ri.VARSAYILAN=1 JOIN REHBERAYAR ra ON ra.YERI=1 AND ra.SIRA=rb.SIRA AND ra.YERI=rb.YERI WHERE rb.YER_ID=ri.ID AND ra.VARSAYILAN=8 LIMIT 1)::text AS ilad,'
        ||'R.SUBEID::smallint AS subeid,'
        ||'(SELECT r2.FIRMA FROM REHBER r2 WHERE r2.ID=R.SUBEID LIMIT 1)::text AS sube,'
        ||'(SELECT gy.YORUM FROM GOREVYORUM gy WHERE R.ID=gy.GOREVID AND gy.TUR=11 ORDER BY gy.TARIH DESC LIMIT 1)::text AS notlar,'
        ||'R.DURUM::smallint AS durum,'
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-2201 AND g.DEGER=R.DURUM AND g.DIL='||pdil||' LIMIT 1)::text AS durumad,'
        ||'R.OZELKOD::text AS ozelkod, R.BAGID::int AS bagid';

        v_frm :=
          'FROM REHBER R '
        ||'LEFT OUTER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
        ||'LEFT OUTER JOIN REHBER P ON R.ID=P.BAGID AND P.GRUP=334 AND '
        ||'1 = CASE WHEN '||pil||'=1 THEN 1 WHEN '||pil||'=0 AND COALESCE(P.STATU,1)=1 THEN 1 ELSE 0 END ';

        v_whr := ' WHERE R.ID > 0 AND R.GRUP=335 ';
    ELSE
        -- ---------- ADAY (GRUP=5, DISTINCT) ----------
        v_distinct := 'DISTINCT ';
        v_sel :=
          'R.ID::int AS id, R.KOD::text AS kod,'
        ||'(SELECT rb.BILGI FROM REHBERBILGI rb WHERE rb.YERI=3 AND rb.YER_ID=R.ID AND rb.SIRA=22 LIMIT 1)::text AS vkno,'
        ||'R.FIRMA::text AS adsoyad,'
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-23355 AND g.DEGER=R.STATU AND g.DIL='||pdil||' LIMIT 1)::text AS cinsiyet,'
        ||'(SELECT il.ILADI FROM ILCELER ic JOIN ILLER il ON il.ILNO=ic.ILNO WHERE ic.ILCENO=R.BOLGE LIMIT 1)::text AS dyeri,'
        ||'(SELECT il.ILADI FROM ILLER il WHERE il.ILNO=R.ALTBOLGE LIMIT 1)::text AS uyrugu,'
        ||'R.DTARIH::timestamp AS dtarihi,'
        ||'(SELECT g.ANAHTAR FROM GENINI g JOIN PERS_DENEYIM pd ON g.DEGER=pd.SEKTOR AND pd.TUR=0 WHERE pd.REHBERID=R.ID AND g.BOLUM=-2204 AND g.DIL='||pdil||' ORDER BY pd.BASVURUTARIHI DESC LIMIT 1)::text AS sektor,'
        ||'(SELECT g.ANAHTAR FROM GENINI g JOIN PERS_DENEYIM pd ON g.DEGER=pd.DEPARTMAN AND pd.TUR=0 WHERE pd.REHBERID=R.ID AND g.BOLUM=-2206 AND g.DIL='||pdil||' ORDER BY pd.BASVURUTARIHI DESC LIMIT 1)::text AS departman,'
        ||'(SELECT g.ANAHTAR FROM GENINI g JOIN PERS_DENEYIM pd ON g.DEGER=pd.GOREV AND pd.TUR=0 WHERE pd.REHBERID=R.ID AND g.BOLUM=-2205 AND g.DIL='||pdil||' ORDER BY pd.BASVURUTARIHI DESC LIMIT 1)::text AS gorevi,'
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-2255 AND g.DEGER=R.KATEGORI AND g.DIL='||pdil||' LIMIT 1)::text AS ogrenim,'
        ||'(SELECT pd.BASVURUTARIHI FROM PERS_DENEYIM pd WHERE pd.REHBERID=R.ID AND pd.TUR=0 ORDER BY pd.BASVURUTARIHI DESC LIMIT 1)::timestamp AS giristarihi,'
        ||'(SELECT pd.BASLAMATARIHI FROM PERS_DENEYIM pd WHERE pd.REHBERID=R.ID AND pd.TUR=0 ORDER BY pd.BASVURUTARIHI DESC LIMIT 1)::timestamp AS cikistarihi,'
        ||'(SELECT ic.ILCEADI FROM PERS_DENEYIM pd JOIN ILCELER ic ON pd.IL=ic.ILNO AND pd.ILCE=ic.ILCENO WHERE pd.REHBERID=R.ID AND pd.TUR=0 ORDER BY pd.BASVURUTARIHI DESC LIMIT 1)::text AS ilcead,'
        ||'(SELECT il.ILADI FROM PERS_DENEYIM pd JOIN ILCELER ic ON pd.IL=ic.ILNO AND pd.ILCE=ic.ILCENO JOIN ILLER il ON il.ILNO=ic.ILNO WHERE pd.REHBERID=R.ID AND pd.TUR=0 ORDER BY pd.BASVURUTARIHI DESC LIMIT 1)::text AS ilad,'
        ||'R.SUBEID::smallint AS subeid,'
        ||'(SELECT r2.FIRMA FROM REHBER r2 WHERE r2.ID=R.SUBEID LIMIT 1)::text AS sube,'
        ||'(SELECT gy.YORUM FROM GOREVYORUM gy WHERE R.ID=gy.GOREVID AND gy.TUR=11 ORDER BY gy.TARIH DESC LIMIT 1)::text AS notlar,'
        ||'R.DURUM::smallint AS durum,'
        ||'(SELECT g.ANAHTAR FROM GENINI g WHERE g.BOLUM=-2201 AND g.DEGER=R.DURUM AND g.DIL='||pdil||' LIMIT 1)::text AS durumad,'
        ||'R.OZELKOD::text AS ozelkod, R.BAGID::int AS bagid';

        v_frm :=
          'FROM REHBER R '
        ||'LEFT OUTER JOIN ROLLER ROL ON R.SINIF=ROL.ID '
        ||'LEFT OUTER JOIN REHBER P ON R.ID=P.BAGID AND P.GRUP=334 AND '
        ||'1 = CASE WHEN '||pil||'=1 THEN 1 WHEN '||pil||'=0 AND COALESCE(P.STATU,1)=1 THEN 1 ELSE 0 END '
        ||'LEFT OUTER JOIN PERS_DENEYIM PD ON R.ID=PD.REHBERID ';

        v_whr := ' WHERE R.ID > 0 AND R.GRUP=5 ';
    END IF;

    -- Pasif kapali -> sadece aktif
    IF v_pasif = 0 THEN
        v_whr := v_whr || ' AND R.DURUM > 0 ';
    END IF;

    -- Sube yetkisi (tum modlar) - digit/virgul listesi (injection guard)
    IF v_subeyetki IS NOT NULL AND v_subeyetki <> '' AND v_subeyetki ~ '^[0-9, ]+$' THEN
        v_whr := v_whr || ' AND R.SUBEID IN (' || v_subeyetki || ') ';
    END IF;

    -- Tek sube / temsilci (yalniz Filtre=4)
    IF v_mod = 4 THEN
        IF v_teksube = 1  AND v_kulid  IS NOT NULL THEN
            v_whr := v_whr || ' AND R.TEMSILCI = ' || v_kulid || ' ';
        END IF;
        IF v_teksube = 10 AND v_subeid IS NOT NULL THEN
            v_whr := v_whr || ' AND R.SUBEID = ' || v_subeid || ' ';
        END IF;
    END IF;

    -- Alan filtreleri (yalniz Filtre=4)
    IF v_mod = 4 THEN
        IF v_firma IS NOT NULL AND v_firma <> '' THEN
            v_whr := v_whr || ' AND R.FIRMA ILIKE ' || quote_literal('%'||v_firma||'%') || ' ';
        END IF;

        IF v_aday = 0 THEN
            IF v_kod IS NOT NULL AND v_kod <> '' THEN
                v_whr := v_whr || ' AND R.KOD ILIKE ' || quote_literal('%'||v_kod||'%') || ' ';
            END IF;
        ELSE
            IF v_cinsiyet  IS NOT NULL THEN v_whr := v_whr || ' AND R.STATU = '    || v_cinsiyet  || ' '; END IF;
            IF v_ogrenim   IS NOT NULL THEN v_whr := v_whr || ' AND R.KATEGORI = ' || v_ogrenim   || ' '; END IF;
            IF v_sektor    IS NOT NULL THEN v_whr := v_whr || ' AND PD.SEKTOR = '  || v_sektor    || ' '; END IF;
            IF v_departman IS NOT NULL THEN v_whr := v_whr || ' AND PD.DEPARTMAN = '|| v_departman || ' '; END IF;
            IF v_gorev     IS NOT NULL THEN v_whr := v_whr || ' AND PD.GOREV = '   || v_gorev     || ' '; END IF;
            IF v_dil1      IS NOT NULL THEN v_whr := v_whr || ' AND EXISTS(SELECT 1 FROM PERS_DIL DIL WHERE DIL.REHBERID=R.ID AND DIL.DIL=' || v_dil1 || ') '; END IF;
            IF v_dil2      IS NOT NULL THEN v_whr := v_whr || ' AND EXISTS(SELECT 1 FROM PERS_DIL DIL WHERE DIL.REHBERID=R.ID AND DIL.DIL=' || v_dil2 || ') '; END IF;
            IF v_il        IS NOT NULL THEN v_whr := v_whr || ' AND PD.IL = '       || v_il       || ' '; END IF;
            IF v_uyruk     IS NOT NULL THEN v_whr := v_whr || ' AND R.ALTBOLGE = '  || v_uyruk    || ' '; END IF;
            IF v_ucretalt  IS NOT NULL AND v_ucretust IS NOT NULL THEN
                v_whr := v_whr || ' AND PD.TUR=0 AND PD.UCRET_ALT BETWEEN ' || v_ucretalt || ' AND ' || v_ucretust || ' ';
            END IF;
        END IF;
    END IF;

    -- Mod 3(Sik)/5(Son): KULLANICI_ARAMA join (1:1 unique KULID,MODUL,KAYITID)
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_ka := true;
        v_frm := v_frm || ' INNER JOIN KULLANICI_ARAMA KA ON KA.KAYITID=R.ID AND KA.KULID='
                       || v_kulid || ' AND KA.MODUL=' || v_modul || ' ';
        IF v_mod = 5 THEN
            v_ordsel := ', KA.DEGISTIRMETARIHI AS ordkey';
        ELSE
            v_ordsel := ', KA.SAY AS ordkey';
        END IF;
    END IF;

    -- Siralama (outer wrapper alias 'q' uzerinden)
    IF v_mod = 1 THEN
        v_ord := 'q.id';
    ELSIF v_mod IN (3,5) AND v_ka THEN
        v_ord := 'q.ordkey DESC';
    ELSE
        IF v_aday = 0 AND v_kod IS NOT NULL AND v_kod <> '' THEN
            v_ord := 'q.subeid, q.kod';
        ELSE
            v_ord := 'q.subeid, q.adsoyad';
        END IF;
    END IF;

    v_inner := 'SELECT ' || v_distinct || v_sel || v_ordsel || ' ' || v_frm || v_whr;

    v_sql := 'SELECT q.id,q.kod,q.vkno,q.adsoyad,q.cinsiyet,q.dyeri,q.uyrugu,q.dtarihi,'
          || 'q.sektor,q.departman,q.gorevi,q.ogrenim,q.giristarihi,q.cikistarihi,'
          || 'q.ilcead,q.ilad,q.subeid,q.sube,q.notlar,q.durum,q.durumad,q.ozelkod,q.bagid '
          || 'FROM (' || v_inner || ') q ORDER BY ' || v_ord;

    IF v_topn > 0 THEN
        v_sql := v_sql || ' LIMIT ' || v_topn;
    END IF;

    RETURN QUERY EXECUTE v_sql;
END
$function$;
