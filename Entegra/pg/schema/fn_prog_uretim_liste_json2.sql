-- ============================================================
-- fn_prog_uretim_liste_json2 — MSSQL sp_Prog_Uretim_Liste_Json2 PG portu
--   Uretim liste (FATBASLIK.TUR=6). PK=FATBASLIK.ID. Son/Sik: KULLANICI_ARAMA (Modul app'ten).
--   @Baslik (EkAlanlar/@SelectList) YOK SAYILIR (dokuman/pdks/stok/fattransfer deseni;
--     sabit RETURNS TABLE'a ek-kolon eklenemez -> SP'nin sabit SELECT'ini superset olarak donduruyoruz;
--     Uretim'de app zaten '' gonderiyor).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join, @Mod=4 WHERE (tarih/UretimID/UretimNo/StokKodu/StokAdi/SubeID), ORDER, TOP->LIMIT.
--   MSSQL->PG:
--     JSON_VALUE->(kosullar::jsonb)->>'X'+NULLIF+::cast; ISNULL/TRY_CAST->COALESCE/NULLIF::cast; bit/tinyint->smallint.
--     LIKE(CI)->ILIKE+quote_literal('%'||v||'%'); int filtre (SubeID) inline ::int (SP-birebir, injection yok).
--     FB.ID LIKE -> fb.id::text ILIKE. YEAR/MONTH->EXTRACT(...)::int.
--     DATEADD(SECOND,86399,CAST(DATE))->date_trunc('day',x)+interval '86399 sec' (gun sonu).
--     NCHAR(351)='ş', NCHAR(304)='İ' -> literal Turkce.
--     dbo.fn_TarihFarkiFormatli -> companion public.fn_tarihfarkiformatli (bu dosyada porti; GENINI -10138 format).
--   Differential: PG ekspert'te FATBASLIK TUR=6 = 0 satir -> VACUOUS (veri yok).
-- ============================================================

-- ---- Companion: fn_TarihFarkiFormatli (SURE kolonu) ----
CREATE OR REPLACE FUNCTION public.fn_tarihfarkiformatli(baslangic timestamp, bitis timestamp)
RETURNS varchar
LANGUAGE plpgsql STABLE AS $$
DECLARE
    fark double precision;
    fmt  int;
    sonuc varchar;
    days int; hours int; minutes int;
BEGIN
    IF baslangic IS NULL OR bitis IS NULL THEN RETURN NULL; END IF;
    fark := EXTRACT(EPOCH FROM (bitis - baslangic)) / 86400.0;   -- gun cinsinden fark (MSSQL float tarih farki)
    fmt  := COALESCE((SELECT deger FROM genini WHERE bolum = -10138 LIMIT 1), 1);
    IF fark < 0.0 THEN
        IF fmt = 1 THEN sonuc := '000g 00s 00d';
        ELSIF fmt = 2 THEN sonuc := '0.00 gün';
        ELSIF fmt = 3 THEN sonuc := '0.00 saat';
        ELSIF fmt = 4 THEN sonuc := '0 dakika';
        END IF;
    ELSE
        IF fmt = 1 THEN
            days    := floor(fark)::int;
            hours   := floor((fark*24) - (days*24))::int;
            minutes := floor((fark*24*60) - ((days*24*60) + (hours*60)))::int;
            sonuc :=
                CASE WHEN days < 10 THEN '00'||days::text WHEN days < 100 THEN '0'||days::text ELSE days::text END || 'g ' ||
                CASE WHEN hours < 10 THEN '0'||hours::text ELSE hours::text END || 's ' ||
                CASE WHEN minutes < 10 THEN '0'||minutes::text ELSE minutes::text END || 'd';
        ELSIF fmt = 2 THEN sonuc := to_char(round(fark::numeric, 2), 'FM990.00')||' gün';
        ELSIF fmt = 3 THEN sonuc := to_char(round((fark*24)::numeric, 2), 'FM990.00')||' saat';
        ELSIF fmt = 4 THEN sonuc := floor(fark*24*60)::int::text||' dakika';
        END IF;
    END IF;
    RETURN sonuc;
END $$;

-- ---- Ana liste fonksiyonu ----
DROP FUNCTION IF EXISTS public.fn_prog_uretim_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_uretim_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, tur smallint, tarih timestamp, faturatarih timestamp, faturano varchar,
    rehberid integer, sayfa smallint, stokisk double precision, fatura_matrahi numeric, fatura_tutari numeric,
    kur varchar, ozelkod varchar, ozelkod2 varchar, detaybolumu varchar,
    tplmaliyetson double precision, tplmaliyetort double precision, doviz_cinsi varchar,
    satis numeric, kar double precision, dovizkur numeric, kdv_tutari numeric, doviz_tutari numeric,
    girisdepo smallint, cikisdepo smallint, girisdepoad text, cikisdepoad text,
    subeid smallint, aciklama varchar, stokadi varchar, kod varchar, urunno varchar,
    bolum smallint, projekodu varchar, sure varchar,
    baslama_yil integer, baslama_ay integer, bitis_yil integer, bitis_ay integer,
    carikod text, cariad text, istasyonadi text, lokasyonadi text, sorumluadi text, onaylayanadi text,
    durumnereden text, durumnereye text
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_datebas   timestamp := NULLIF(j->>'DateBas','')::timestamp;
    v_datebitis timestamp := NULLIF(j->>'DateBitis','')::timestamp;
    v_uretimid  text := NULLIF(j->>'UretimID','');
    v_uretimno  text := NULLIF(j->>'UretimNo','');
    v_stokkodu  text := NULLIF(j->>'StokKodu','');
    v_stokadi   text := NULLIF(j->>'StokAdi','');
    v_subeid    int  := NULLIF(j->>'SubeID','')::int;
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := NULLIF(j->>'OrderBy','');
    q text; joinka text := ''; w text := ' WHERE fb.tur=6 '; ordr text; lim text := '';
BEGIN
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;

    -- @Mod=3(Sik)/5(Son): KULLANICI_ARAMA 1:1 join (KAYITID=FB.ID)
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=fb.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- Arama-kutusu filtreleri SADECE @Mod=4 icin (SP-birebir)
    IF v_mod = 4 THEN
        IF v_datebas IS NOT NULL THEN
            w := w || ' AND fb.tarih > '||quote_literal(v_datebas)||' ';
        END IF;
        IF v_datebitis IS NOT NULL THEN
            w := w || ' AND fb.tarih < '||quote_literal(date_trunc('day', v_datebitis) + interval '86399 seconds')||' ';
        END IF;
        IF v_uretimid IS NOT NULL THEN w := w || ' AND fb.id::text ILIKE '||quote_literal('%'||v_uretimid||'%')||' '; END IF;
        IF v_uretimno IS NOT NULL THEN w := w || ' AND fb.faturano ILIKE '||quote_literal('%'||v_uretimno||'%')||' '; END IF;
        IF v_stokkodu IS NOT NULL THEN w := w || ' AND s.kod ILIKE '||quote_literal('%'||v_stokkodu||'%')||' '; END IF;
        IF v_stokadi  IS NOT NULL THEN w := w || ' AND s.stokadi ILIKE '||quote_literal('%'||v_stokadi||'%')||' '; END IF;
        IF v_subeid   IS NOT NULL THEN w := w || ' AND fb.subeid = '||v_subeid||' '; END IF;
    END IF;

    -- Siralama: Son/Sik SP belirler; digerlerinde app'ten @OrderBy
    IF v_mod = 5 THEN ordr := 'ka.degistirmetarihi DESC';
    ELSIF v_mod = 3 THEN ordr := 'ka.say DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := v_orderby;
    ELSE ordr := 'fb.tarih DESC'; END IF;

    q := 'SELECT fb.id::integer, fb.tur::smallint, fb.tarih::timestamp, fb.faturatarih::timestamp, fb.faturano::varchar,
             fb.rehberid::integer, fb.sayfa::smallint, fb.stokisk::double precision,
             fb.fatura_matrahi::numeric, fb.fatura_tutari::numeric, fb.kur::varchar,
             fb.ozelkod::varchar, fb.ozelkod2::varchar, fb.detaybolumu::varchar,
             (fb.fatura_matrahi*fb.stokisk)::double precision AS tplmaliyetson,
             (fb.fatura_tutari*fb.stokisk)::double precision AS tplmaliyetort,
             fb.doviz_cinsi::varchar,
             fb.ekvergi::numeric AS satis,
             (((fb.ekvergi-fb.fatura_tutari)/nullif(fb.fatura_tutari,0))*100.0)::double precision AS kar,
             fb.dovizkur::numeric, fb.kdv_tutari::numeric, fb.doviz_tutari::numeric,
             fb.girisdepo::smallint, fb.cikisdepo::smallint,
             (SELECT d.depoadi FROM depolar d WHERE d.id=fb.girisdepo)::text AS girisdepoad,
             (SELECT d.depoadi FROM depolar d WHERE d.id=fb.cikisdepo)::text AS cikisdepoad,
             fb.subeid::smallint, fb.aciklama::varchar,
             s.stokadi::varchar, s.kod::varchar, s.urunno::varchar, fb.bolum::smallint, p.projekodu::varchar,
             public.fn_tarihfarkiformatli(fb.tarih, fb.faturatarih)::varchar AS sure,
             EXTRACT(YEAR FROM fb.tarih)::int AS baslama_yil,
             EXTRACT(MONTH FROM fb.tarih)::int AS baslama_ay,
             EXTRACT(YEAR FROM fb.faturatarih)::int AS bitis_yil,
             EXTRACT(MONTH FROM fb.faturatarih)::int AS bitis_ay,
             (SELECT r.kod FROM rehber r WHERE r.id=fb.rehberid)::text AS carikod,
             (SELECT r.firma FROM rehber r WHERE r.id=fb.rehberid)::text AS cariad,
             (SELECT l.aciklama FROM lokasyon l WHERE l.id=fb.isyeri)::text AS istasyonadi,
             (SELECT l.aciklama FROM lokasyon l WHERE l.id=fb.lokasyon)::text AS lokasyonadi,
             (SELECT r.firma FROM rehber r WHERE r.id=fb.saticikodu)::text AS sorumluadi,
             (SELECT r.firma FROM rehber r WHERE r.id=fb.onaylayan)::text AS onaylayanadi,
             (CASE WHEN (415 IN (SELECT yeri FROM fatura WHERE fatbasid=fb.id)) THEN ''Siparişten''
                   WHEN (420 IN (SELECT yeri FROM fatura WHERE fatbasid=fb.id)) THEN ''Siparişten'' ELSE '''' END)::text AS durumnereden,
             (CASE WHEN (426 IN (SELECT yeri FROM fatura WHERE yerid IN (SELECT id FROM fatura WHERE fatbasid=fb.id))) THEN ''Faturaya''
                   WHEN (425 IN (SELECT yeri FROM fatura WHERE yerid IN (SELECT id FROM fatura WHERE fatbasid=fb.id))) THEN ''İrsaliyeye'' ELSE '''' END)::text AS durumnereye
          FROM fatbaslik fb
            LEFT JOIN stoklar s ON s.id=fb.aktiviteid
            LEFT OUTER JOIN projeler p ON p.id=fb.projeid '
         || joinka || w || ' ORDER BY ' || ordr || lim;
    RETURN QUERY EXECUTE q;
END $$;
