-- ============================================================
-- fn_prog_cek_liste_json2 — MSSQL sp_Prog_Cek_Liste_Json2 PG portu
--   Cek/Senet liste. Govde eski UCekListeFrame.YenileTusClick ile BIREBIR;
--   parametreler tek JSON (@Kosullar). @Baslik (EkAlanlar) YOK SAYILIR
--   (Cek'te zaten bos; sabit RETURNS TABLE'a ek-kolon eklenemez -> superset dondur).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA EXISTS (Son/Sik) + KA_SIRA order, metin/islem/vade/sube WHERE.
--   MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, TOP1..ORDER->..LIMIT 1,
--     LIKE(CI)->ILIKE quote_literal, IN(list)->guard ~ '^[0-9, -]+$', getdate yok, bit yok.
--   Metin filtre quote_literal (param-juggling yok, injection guvenli); islem/sube app-int-list guard.
--   TUZAK: SP SELECT'inde BORCLU ve HESAPNO kolonlari IKI kez geciyor (mukerrer ad).
--     PG RETURNS TABLE mukerrer ad kabul etmez -> 2. kopyalar borclu2/hesapno2 olarak adlandirildi
--     (ayni C.BORCLU / C.HESAPNO degeri; grid ilk kopyaya baglanir, 2.si zararsiz).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_cek_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_cek_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id smallint, kod varchar, tutar numeric, kur varchar, tur smallint,
    durum smallint, makbuzno varchar, cirolu smallint, odemeyeri varchar, hesapno varchar,
    serino bigint, doviz_tutari numeric, doviz_kuru varchar, borclu varchar, iban varchar,
    vkno varchar, baskasinin smallint, borclu2 varchar, vade timestamp, carikod varchar,
    cariunvan varchar, hesapid integer, rehberid integer, hesapno2 varchar, bankaadi varchar,
    subeadi varchar, sonislem smallint, ceksenet smallint, sonislemyeri text, belgeno varchar,
    islemtarih timestamp, bankahesapkodu varchar, bankahesapno varchar, bankasubelerid integer, masrafid smallint
)
LANGUAGE plpgsql STABLE AS $fn$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_ceksenet  int  := COALESCE(NULLIF(j->>'CekSenet','')::int, 0);   -- HER ZAMAN: WHERE ceksenet=@CekSenet
    v_arakod    text := NULLIF(j->>'AraKod','');
    v_serino    text := NULLIF(j->>'SeriNo','');
    v_islemlist text := NULLIF(j->>'IslemTurleri','');
    v_vadebas   date := NULLIF(j->>'VadeBas','')::date;
    v_vadebit   date := NULLIF(j->>'VadeBit','')::date;
    v_subelist  text := NULLIF(j->>'SubeYetkiList','');
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := NULLIF(j->>'OrderBy','');
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);   -- SAYFALI liste: 0 = LIMIT yok
    q text; w text := ''; ordr text := ''; ka_where text := '';
BEGIN
    -- Son/Sik (KULLANICI_ARAMA): EXISTS suzgec + KA_SIRA siralama anahtari (order'da korelasyonlu subquery)
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        ka_where := 'ka.kayitid=c.id AND ka.kulid=' || v_kulid || ' AND ka.modul=' || v_modul;
        w := w || ' AND EXISTS (SELECT 1 FROM kullanici_arama ka WHERE ' || ka_where || ') ';
    END IF;

    -- Metin filtreleri (ILIKE, quote_literal). Orijinal: prefix LIKE (KOD/FIRMA), SERINO %..%.
    IF v_arakod IS NOT NULL THEN
        w := w || ' AND ((r1.kod ILIKE ' || quote_literal(v_arakod||'%')
              || ' OR r1.firma ILIKE ' || quote_literal(v_arakod||'%') || ')'
              || ' OR (r2.kod ILIKE ' || quote_literal(v_arakod||'%')
              || ' OR r2.firma ILIKE ' || quote_literal(v_arakod||'%') || ')) ';
    END IF;
    IF v_serino IS NOT NULL THEN
        w := w || ' AND c.serino::text ILIKE ' || quote_literal('%'||v_serino||'%') || ' ';
    END IF;

    -- Islem turleri: virgullu int list (yalniz rakam/virgul/bosluk/eksi -> guvenli)
    IF v_islemlist IS NOT NULL AND v_islemlist ~ '^[0-9, -]+$' THEN
        w := w || ' AND ch.islem IN (' || v_islemlist || ') ';
    END IF;

    -- Vade araligi (parametre yerine inline sabit; date cast)
    IF v_vadebas IS NOT NULL THEN w := w || ' AND c.vade >= ' || quote_literal(v_vadebas::text) || ' '; END IF;
    IF v_vadebit IS NOT NULL THEN w := w || ' AND c.vade <= ' || quote_literal(v_vadebit::text) || ' '; END IF;

    -- Sube yetki listesi (app-uretimi int-listesi; guvenli guard)
    IF v_subelist IS NOT NULL AND v_subelist ~ '^[0-9, -]+$' THEN
        w := w || ' AND c.subeid IN (' || v_subelist || ') ';
    END IF;

    q := 'SELECT c.id, c.kod, c.tutar, c.kur, c.tur, c.durum, ch.belgeno::varchar AS makbuzno,
            c.cirolu, c.odemeyeri, c.hesapno, c.serino, c.doviz_tutari, c.doviz_kuru, c.borclu, c.iban,
            c.vkno, c.baskasinin, c.borclu AS borclu2, c.vade, r1.kod::varchar AS carikod,
            r1.firma::varchar AS cariunvan, c.hesapid, c.rehberid, c.hesapno AS hesapno2, b.bankaadi::varchar,
            bs.subeadi::varchar, ch.islem AS sonislem, c.ceksenet,
            (CASE WHEN COALESCE(r2.firma,''-'')<>''-'' THEN r2.firma ELSE bhson.hesapadi END)::text AS sonislemyeri,
            ch.belgeno::varchar AS belgeno, ch.tarih AS islemtarih, bh2.hesapkodu::varchar AS bankahesapkodu,
            bh2.hesapno::varchar AS bankahesapno, bh2.bankasubelerid, c.masrafid
          FROM cekler c
            INNER JOIN cekhareket ch ON ch.id=(SELECT ch1.id FROM cekhareket ch1 WHERE ch1.ceksenetlerid=c.id ORDER BY ch1.tarih DESC LIMIT 1)
            LEFT OUTER JOIN rehber r1 ON c.rehberid=r1.id
            LEFT OUTER JOIN bankasubeler bs ON bs.id=c.bankasubelerid
            LEFT OUTER JOIN bankalar b ON b.bankakodu=bs.bankakodu
            LEFT OUTER JOIN rehber r2 ON ch.rehberid=r2.id
            LEFT OUTER JOIN bankahesaplar bhson ON ch.bankahesaplarid=bhson.id
            LEFT OUTER JOIN bankahesaplar bh2 ON c.hesapid=bh2.id
          WHERE c.ceksenet=' || v_ceksenet || w;

    -- Siralama: Son/Sik -> korelasyonlu KA_SIRA (max say / max degistirmetarihi) DESC
    IF v_mod IN (3,5) AND ka_where <> '' THEN
        ordr := ' ORDER BY (SELECT ' || CASE WHEN v_mod = 5 THEN 'max(ka.degistirmetarihi)' ELSE 'max(ka.say)' END
              || ' FROM kullanici_arama ka WHERE ' || ka_where || ') DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := ' ORDER BY ' || v_orderby;
    END IF;

    -- SAYFALI liste (TSayfaliListe): MSSQL TOP (n) karsiligi
    IF v_topn > 0 THEN ordr := ordr || ' LIMIT ' || v_topn; END IF;

    RETURN QUERY EXECUTE q || ordr;
END $fn$;
