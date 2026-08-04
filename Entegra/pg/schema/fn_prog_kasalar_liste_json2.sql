-- ============================================================
-- fn_prog_kasalar_liste_json2 — MSSQL sp_Prog_Kasalar_Liste_Json2 PG portu
--   Kasa tanim liste (UKasalarListeFrame). Govde eski YenileTusClick sorgusuyla
--   BIREBIR: select K.* from KASALAR + sube filtresi + order by KASAKODU.
--   @Baslik (EkAlanlar) YOK SAYILIR (Kasalar'da ek alan yok; sabit RETURNS TABLE).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join (Son/Sik), sube WHERE, ORDER (Son/Sik->ka).
--   MSSQL->PG: EXISTS+MAX(KA_SIRA) -> INNER JOIN + ORDER BY ka.say/ka.degistirmetarihi
--     (demirbas/stok deseni), ISNULL->COALESCE, SUBEID IN(int-list) guard '^[0-9, ]+$'.
--   KA_SIRA cikti kolonu EKLENMEZ (RETURNS TABLE = KASALAR.* birebir).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_kasalar_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_kasalar_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id smallint, kasakodu varchar(20), kasaadi varchar(50), kur varchar(3), ozelkod varchar(20),
    yetkikodu varchar(20), geridonushesapkodu varchar(50), hesapaciklama varchar(100), durum smallint,
    gunlukaksiyondagoster smallint, ekleyen integer, eklemetarihi timestamp, degistiren integer,
    degistirmetarihi timestamp, bakiye numeric, kasatur smallint, subeid smallint, muhaktar smallint,
    rehberid integer
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_subelist  text := NULLIF(j->>'SubeYetkiList','');
    v_subeid    int  := NULLIF(j->>'SubeId','')::int;
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := COALESCE(NULLIF(j->>'OrderBy',''), 'KASAKODU');
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);   -- SAYFALI liste: 0 = LIMIT yok
    q text; w text := ' WHERE 1=1 '; joinka text := ''; ordr text; lim text := '';
BEGIN
    -- Son/Sik: kullanicinin actigi kasalar (KULLANICI_ARAMA) — suzgec + siralama
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=k.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- Sube suzgeci: SubeYetkiList (app-uretimi int listesi, guard) veya SubeId (tek sube)
    IF v_subelist IS NOT NULL AND v_subelist ~ '^[0-9, -]+$' THEN
        w := w || ' AND k.subeid IN ('||v_subelist||') ';
    ELSIF v_subeid IS NOT NULL THEN
        w := w || ' AND k.subeid = '||v_subeid||' ';
    END IF;

    -- Siralama
    IF v_mod = 5 THEN ordr := 'ka.degistirmetarihi DESC';
    ELSIF v_mod = 3 THEN ordr := 'ka.say DESC';
    ELSE ordr := v_orderby; END IF;

    -- SAYFALI liste (TSayfaliListe): MSSQL TOP (n) karsiligi
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;

    q := 'SELECT k.* FROM kasalar k ' || joinka || w || ' ORDER BY ' || ordr || lim;
    RETURN QUERY EXECUTE q;
END $$;
