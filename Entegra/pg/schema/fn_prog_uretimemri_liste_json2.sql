-- ============================================================
-- fn_prog_uretimemri_liste_json2 — MSSQL sp_Prog_UretimEmri_Liste_Json2 PG portu
--   Uretim emri liste. U.* + 6 hesapli kolon (stokkodu/stokadi/urunno/projekodu/anakaynakad/firmaad).
--   @Baslik (EkAlanlar) YOK SAYILIR (dokuman/pdks/stok deseni; sabit RETURNS TABLE'a ek-kolon eklenemez).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join, WHERE (text-ILIKE/tarih/pasif), ORDER, TOP->LIMIT.
--   MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, TOP(N)->LIMIT N,
--     LIKE(CI)->ILIKE quote_literal, U.ID(int) LIKE -> u.id::text ILIKE, bit/tinyint->smallint(=1 kalir).
--   Metin/tarih filtre quote_literal inline (SP-birebir, param-juggling yok). uretimemri BOS -> smoke/vacuous.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_uretimemri_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_uretimemri_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, bastar timestamp, bittar timestamp, onay smallint, aciklama varchar(200),
    durum smallint, ozelkod varchar(20), yetkikodu varchar(10), ekleyen smallint, eklemetarihi timestamp,
    degistiren smallint, degistirmetarihi timestamp, yeri integer, yerid integer, subeid smallint,
    miktar double precision, onaylayan integer, stokid integer, adet double precision, birim integer,
    receteid integer, maliyethesaplama smallint, uretimplanid integer, uretimplandetayid integer,
    onaylayacak integer, projeid integer, emirno varchar(20), emirturu smallint, talepeden integer,
    taleptarihi timestamp, anakaynak smallint, termintarihi timestamp, kocanno varchar(10),
    serino varchar(10), rehberid integer, rehberiletid integer, siparis_no varchar(20),
    stokkodu varchar, stokadi varchar, urunno varchar, projekodu varchar, anakaynakad varchar, firmaad varchar
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_pasif     int  := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_uretimid  text := NULLIF(j->>'UretimID','');
    v_stokkodu  text := NULLIF(j->>'StokKodu','');
    v_stokadi   text := NULLIF(j->>'StokAdi','');
    v_detayurun text := NULLIF(j->>'DetayUrun','');
    v_bastar    text := NULLIF(j->>'BasTar','');
    v_bittar    text := NULLIF(j->>'BitTar','');
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := COALESCE(NULLIF(j->>'OrderBy',''), 'u.bastar');
    q text; w text := ' WHERE 1=1 '; joinka text := ''; ordr text; lim text := '';
BEGIN
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;

    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi 1:1 join
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=u.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- Metin filtreleri (ILIKE, quote_literal). U.ID integer -> u.id::text.
    IF v_uretimid IS NOT NULL THEN
        w := w || ' AND (u.id::text ILIKE '||quote_literal('%'||v_uretimid||'%')
                      ||' OR u.emirno ILIKE '||quote_literal('%'||v_uretimid||'%')||') ';
    END IF;
    IF v_stokkodu IS NOT NULL THEN
        w := w || ' AND (s.kod ILIKE '||quote_literal('%'||v_stokkodu||'%')
                      ||' OR s.urunno ILIKE '||quote_literal('%'||v_stokkodu||'%')||') ';
    END IF;
    IF v_stokadi IS NOT NULL THEN
        w := w || ' AND s.stokadi ILIKE '||quote_literal('%'||v_stokadi||'%')||' ';
    END IF;
    IF v_detayurun IS NOT NULL THEN
        w := w || ' AND EXISTS (SELECT 1 FROM uretimemridetay ued
                       INNER JOIN stoklar s2 ON s2.id=ued.urunid
                       WHERE ued.uretimemriid=u.id
                         AND (s2.kod ILIKE '||quote_literal('%'||v_detayurun||'%')
                              ||' OR s2.urunno ILIKE '||quote_literal('%'||v_detayurun||'%')||')) ';
    END IF;

    -- Tarih filtreleri (quote_literal inline)
    IF v_bastar IS NOT NULL THEN w := w || ' AND u.bastar >= '||quote_literal(v_bastar)||'::timestamp '; END IF;
    IF v_bittar IS NOT NULL THEN w := w || ' AND u.bastar <= '||quote_literal(v_bittar)||'::timestamp '; END IF;

    -- Pasif kapaliyken sadece aktif (eski: U.DURUM > 0)
    IF v_pasif = 0 THEN w := w || ' AND u.durum > 0 '; END IF;

    -- Son/Sik siralamasi (KULLANICI_ARAMA)
    IF v_mod = 5 THEN ordr := 'ka.degistirmetarihi DESC';
    ELSIF v_mod = 3 THEN ordr := 'ka.say DESC';
    ELSE ordr := v_orderby; END IF;

    q := 'SELECT u.*,
            s.kod::varchar AS stokkodu, s.stokadi::varchar AS stokadi, s.urunno::varchar AS urunno,
            p.projekodu::varchar AS projekodu, l.aciklama::varchar AS anakaynakad, r.firma::varchar AS firmaad
          FROM uretimemri u
            LEFT OUTER JOIN stoklar s ON s.id = u.stokid
            LEFT OUTER JOIN projeler p ON p.id = u.projeid
            LEFT OUTER JOIN lokasyon l ON l.id = u.anakaynak
            LEFT OUTER JOIN rehber r ON r.id = u.rehberid '
         || joinka || w || ' ORDER BY ' || ordr || lim;
    RETURN QUERY EXECUTE q;
END $$;
