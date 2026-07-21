-- ============================================================
-- fn_prog_stoktalep_liste_json2 — MSSQL sp_Prog_StokTalep_Liste_Json2 PG portu
--   Stok Talep liste (SIPARIS.TUR=105). PK=SIPARIS.ID. Son/Sik: KULLANICI_ARAMA join.
--   @Baslik (EkAlanlar) YOK SAYILIR (dokuman/pdks/fattransfer deseni; sabit RETURNS TABLE'a ek-kolon eklenemez).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join, opsiyonel STOKLAR join (Kod/Stok),
--     WHERE (tarih araligi/TalepEden/CikisDepo/GirisDepo/TalepNo/OzelKod/UretimEmirNo/Kod/Stok), ORDER, TOP->LIMIT.
--   MSSQL->PG: JSON_VALUE->->>+NULLIF, ISNULL/TRY_CAST->COALESCE/NULLIF::cast, bit/tinyint->smallint,
--     LIKE(CI)->ILIKE+quote_literal('%'||v||'%'), int filtre inline (SP-birebir), TOP->LIMIT.
--   DISTINCT+ORDER-BY-ka tuzagi: MSSQL @KaCol'u SELECT'e ekliyor; PG'de sabit RETURNS TABLE oldugundan
--     inner DISTINCT'e _srt sort-kolonu (mod 3/5) eklenip DIS SELECT ile projekte ediliyor.
--   SAPMA: MSSQL SELECT'te PROJEKOD 3x tekrar ediyor (kopyala-yapistir); PG RETURNS TABLE tekrar kolon
--     kabul etmez -> tek 'projekod' dondurulur (app zaten ilk kolonu okur). Bkz notes.
--   VERI: PG'de SIPARIS TUR=105 su an 0 satir -> differential VACUOUS, smoke-only.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_stoktalep_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_stoktalep_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, durum smallint, taleptarih timestamp, talepno varchar, detaybolumu varchar,
    talepedenad text, talepedenbirim text, birimonaylayacakad text, birimonaylayanad text,
    taleponaylayacakad text, taleponaylayanad text, projekod text,
    aciklama varchar, ozelkod varchar, girisdeposu text,
    tipi smallint, rehberid integer, tur smallint, subeid smallint,
    onaylayacak integer, onaylayan integer, kaynak text, hedef text
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn       int  := COALESCE(NULLIF(j->>'TopN','')::int, 200);
    v_mod        int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_tarihbas   timestamp := NULLIF(j->>'TarihBas','')::timestamp;
    v_tarihbit   timestamp := NULLIF(j->>'TarihBit','')::timestamp;
    v_talepeden  int  := NULLIF(j->>'TalepEden','')::int;
    v_cikisdepo  int  := NULLIF(j->>'CikisDepo','')::int;
    v_girisdepo  int  := NULLIF(j->>'GirisDepo','')::int;
    v_talepno    text := NULLIF(j->>'TalepNo','');
    v_ozelkod    text := NULLIF(j->>'OzelKod','');
    v_uretimemir text := NULLIF(j->>'UretimEmirNo','');
    v_kod        text := NULLIF(j->>'Kod','');
    v_stok       text := NULLIF(j->>'Stok','');
    v_kulid      int  := NULLIF(j->>'KulId','')::int;
    v_modul      int  := NULLIF(j->>'Modul','')::int;
    v_orderby    text := NULLIF(j->>'OrderBy','');
    q text; joinstok text := ''; joinka text := ''; w text := ' WHERE s.tur=105 ';
    srtcol text := ''; ordr text; lim text := '';
BEGIN
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;

    -- Kod/Stok filtresi STOKLAR join'i tetikler (SD.URUNID); DISTINCT dup'lari alir
    IF v_kod IS NOT NULL OR v_stok IS NOT NULL THEN
        joinstok := ' LEFT OUTER JOIN stoklar stk ON stk.id=sd.urunid ';
    END IF;

    -- @Mod=3(Sik)/5(Son): KULLANICI_ARAMA 1:1 join (KAYITID=S.ID)
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=s.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- WHERE filtreleri
    IF v_tarihbas IS NOT NULL THEN w := w || ' AND s.siparistarih>='||quote_literal(v_tarihbas)||' '; END IF;
    IF v_tarihbit IS NOT NULL THEN w := w || ' AND s.siparistarih<='||quote_literal(v_tarihbit)||' '; END IF;
    IF v_talepeden IS NOT NULL AND v_talepeden > 0 THEN w := w || ' AND s.saticikodu='||v_talepeden||' '; END IF;
    IF v_cikisdepo IS NOT NULL AND v_cikisdepo > 0 THEN w := w || ' AND s.cikisdepo='||v_cikisdepo||' '; END IF;
    IF v_girisdepo IS NOT NULL AND v_girisdepo > 0 THEN w := w || ' AND s.girisdepo='||v_girisdepo||' '; END IF;
    IF v_talepno IS NOT NULL THEN w := w || ' AND s.siparisno ILIKE '||quote_literal('%'||v_talepno||'%')||' '; END IF;
    IF v_ozelkod IS NOT NULL THEN w := w || ' AND s.ozelkod ILIKE '||quote_literal('%'||v_ozelkod||'%')||' '; END IF;
    -- Uretim Emir No: StokTalep'te SIPARIS.DETAYBOLUMU alaninda dogrudan tutuluyor
    IF v_uretimemir IS NOT NULL THEN w := w || ' AND s.detaybolumu ILIKE '||quote_literal('%'||v_uretimemir||'%')||' '; END IF;
    IF v_kod IS NOT NULL THEN w := w || ' AND (stk.kod ILIKE '||quote_literal('%'||v_kod||'%')||' OR stk.urunno ILIKE '||quote_literal('%'||v_kod||'%')||') '; END IF;
    IF v_stok IS NOT NULL THEN w := w || ' AND stk.stokadi ILIKE '||quote_literal('%'||v_stok||'%')||' '; END IF;

    -- DISTINCT+ORDER-BY tuzagi: mod 3/5'te ka sort kolonu inner DISTINCT'e eklenmeli
    IF v_mod = 5 THEN srtcol := ', ka.degistirmetarihi AS _srt'; ordr := '_srt DESC';
    ELSIF v_mod = 3 THEN srtcol := ', ka.say AS _srt'; ordr := '_srt DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := v_orderby;
    ELSE ordr := 'taleptarih desc'; END IF;

    q := 'SELECT id,durum,taleptarih,talepno,detaybolumu,talepedenad,talepedenbirim,
            birimonaylayacakad,birimonaylayanad,taleponaylayacakad,taleponaylayanad,projekod,
            aciklama,ozelkod,girisdeposu,tipi,rehberid,tur,subeid,onaylayacak,onaylayan,kaynak,hedef
          FROM ( SELECT DISTINCT
              s.id::integer AS id, s.durum::smallint AS durum,
              s.siparistarih::timestamp AS taleptarih, s.siparisno::varchar AS talepno,
              s.detaybolumu::varchar AS detaybolumu,
              (SELECT r2.firma FROM rehber r2 WHERE s.saticikodu=r2.id)::text AS talepedenad,
              (SELECT (SELECT anahtar FROM genini WHERE bolum=-2251 AND deger=rol.departman AND dil=-1)
                 FROM roller rol WHERE rol.id=s.bolum)::text AS talepedenbirim,
              (SELECT r3.firma FROM rehber r3 WHERE s.birimonaylayacak=r3.id)::text AS birimonaylayacakad,
              (SELECT r4.firma FROM rehber r4 WHERE s.birimonaylayan=r4.id)::text AS birimonaylayanad,
              (SELECT r5.firma FROM rehber r5 WHERE s.onaylayacak=r5.id)::text AS taleponaylayacakad,
              (SELECT r6.firma FROM rehber r6 WHERE s.onaylayan=r6.id)::text AS taleponaylayanad,
              (SELECT p.projekodu FROM projeler p WHERE s.projeid=p.id)::text AS projekod,
              s.aciklama::varchar AS aciklama, s.ozelkod::varchar AS ozelkod,
              (SELECT d.depoadi FROM depolar d WHERE d.id=s.girisdepo)::text AS girisdeposu,
              s.tipi::smallint AS tipi, s.rehberid::integer AS rehberid, s.tur::smallint AS tur,
              s.subeid::smallint AS subeid, s.onaylayacak::integer AS onaylayacak, s.onaylayan::integer AS onaylayan,
              (CASE WHEN (s.tur=105) AND (467 IN (SELECT yeri FROM siparisdetay WHERE yerid IN
                     (SELECT id FROM uretimemridetay ued WHERE sd.yerid=ued.id))) THEN ''Üretimden'' ELSE '''' END)::text AS kaynak,
              (CASE WHEN (s.tur=105) AND (435 IN (SELECT yeri FROM fatura WHERE yerid IN
                     (SELECT id FROM siparisdetay WHERE siparisid=s.id))) THEN ''Transfer'' END)::text AS hedef'
           || srtcol || '
            FROM siparis s
              INNER JOIN rehber r ON r.id=s.rehberid
              LEFT OUTER JOIN siparisdetay sd ON s.id=sd.siparisid '
           || joinstok || joinka || w || '
          ) t ORDER BY ' || ordr || lim;
    RETURN QUERY EXECUTE q;
END $$;
