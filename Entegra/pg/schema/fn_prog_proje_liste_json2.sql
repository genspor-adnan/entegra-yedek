-- ============================================================
-- fn_prog_proje_liste_json2 — MSSQL sp_Prog_Proje_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- Proje liste ekrani (MODUL=11). Iki param: @Baslik (app-uretimi SELECT ek-kolon
--   fragmenti) + @Kosullar (JSON filtreler). MSSQL SP govdeyi tamamen dinamik kurar.
--
-- PG UYARLAMA NOTU: app 'SELECT * FROM fn_prog_proje_liste_json2(:Baslik,:Kosullar)'
--   cagirir -> fonksiyon SABIT RETURNS TABLE yapisina sahip olmali; @Baslik ile kolon
--   SAYISI degistirilemez. Bu yuzden @Baslik param kabul edilir ama govdede KULLANILMAZ
--   (14/16/17_*_json2 ile ayni desen); SP'nin sabit SELECT'inin (base + hesapli) TUM
--   kolonlari superset RETURNS TABLE olarak dondurulur.
--
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, bit->smallint(=1),
--   TOP N->LIMIT N, TOP1 subquery->ORDER BY..LIMIT 1, LIKE(CI)->ILIKE,
--   N'%'+x+'%'->quote_literal('%'||x||'%'), convert(int,'-2112'+convert(varchar,x))->
--   ('-2112'||x::text)::int, month/year->extract, convert(datetime,x,103)->x::timestamp,
--   len(...)-len(replace(...))->char_length farki, charindex->position, substring(x,0,n)->
--   substr(x,1,n-1). Metin filtreler quote_literal (injection yok); int filtreler ::int
--   parse edilip inline (SP-birebir); SubeYetkiList app-uretimi int-listesi guard'li inline.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_proje_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_proje_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, lokal_firma_id integer, rehberid integer, projekodu varchar,
    baslamatarihi timestamp, bitistarihi timestamp, konusu varchar, turu smallint,
    durum smallint, asama smallint, prj_sorumlusu_id integer, prj_asama_sorumlusu_id integer,
    ilgili integer, listefiyati numeric, listekur varchar, satisfiyati numeric, satiskur varchar,
    ekleyen integer, eklemetarihi timestamp, degistiren integer, degistirmetarihi timestamp,
    sonuc smallint, sonucaciklama varchar, detaybolumu varchar, tipi integer, aplikasyon smallint,
    projeadi varchar, olasilik smallint, subeid smallint, googleolayid varchar,
    googlehesapid smallint, cariid integer, sebebi smallint, kayipfiyati numeric,
    kayipkur varchar, giriskaynak smallint, rakip varchar,
    notlar text, alanrakip text, firma text, projetipi varchar, adsoyad text,
    sorumluad text, asamasorumlu text,
    baslamaay integer, baslamayil integer, bitisay integer, bitisyil integer, dosyavar integer,
    sonaktivitekonusu text, sonaktivitetarihi timestamp, sonsatbelgetarihi timestamp,
    sonsattutari numeric, sonteklifdurumu smallint, sontekliftutari numeric,
    sonteklifkur varchar, sontekliftarihi timestamp
)
LANGUAGE plpgsql STABLE AS $fn$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn        int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod         int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_pasif       int  := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_firma       text := NULLIF(j->>'Firma','');
    v_projekodu   text := NULLIF(j->>'ProjeKodu','');
    v_projeadi    text := NULLIF(j->>'ProjeAdi','');
    v_yetkili     text := NULLIF(j->>'Yetkili','');
    v_konusu      text := NULLIF(j->>'Konusu','');
    v_sorumlu     int  := COALESCE(NULLIF(j->>'Sorumlu','')::int, 0);
    v_turu        int  := COALESCE(NULLIF(j->>'Turu','')::int, 0);
    v_asama       int  := COALESCE(NULLIF(j->>'Asama','')::int, 0);
    v_sonuc       int  := COALESCE(NULLIF(j->>'Sonuc','')::int, 0);
    v_tarihbas    text := NULLIF(j->>'TarihBas','');
    v_tarihbit    text := NULLIF(j->>'TarihBit','');
    v_kendikul    int  := COALESCE(NULLIF(j->>'KendiKul','')::int, 0);
    v_kendisube   int  := COALESCE(NULLIF(j->>'KendiSube','')::int, 0);
    v_subelist    text := NULLIF(j->>'SubeYetkiList','');
    v_kulid       int  := NULLIF(j->>'KulId','')::int;
    v_modul       int  := NULLIF(j->>'Modul','')::int;
    v_orderby     text := NULLIF(j->>'OrderBy','');
    v_sql text;
BEGIN
    v_sql := '
    select
        p.id::int, p.lokal_firma_id::int, p.rehberid::int, p.projekodu::varchar,
        p.baslamatarihi::timestamp, p.bitistarihi::timestamp, p.konusu::varchar, p.turu::smallint,
        p.durum::smallint, p.asama::smallint, p.prj_sorumlusu_id::int, p.prj_asama_sorumlusu_id::int,
        p.ilgili::int, p.listefiyati::numeric, p.listekur::varchar, p.satisfiyati::numeric, p.satiskur::varchar,
        p.ekleyen::int, p.eklemetarihi::timestamp, p.degistiren::int, p.degistirmetarihi::timestamp,
        p.sonuc::smallint, p.sonucaciklama::varchar, p.detaybolumu::varchar, p.tipi::int, p.aplikasyon::smallint,
        p.projeadi::varchar, p.olasilik::smallint, p.subeid::smallint, p.googleolayid::varchar,
        p.googlehesapid::smallint, p.cariid::int, p.sebebi::smallint, p.kayipfiyati::numeric,
        p.kayipkur::varchar, p.giriskaynak::smallint, p.rakip::varchar,
        (select gy.yorum from gorevyorum gy where p.id=gy.gorevid and gy.tur=70 order by gy.tarih desc limit 1)::text as notlar,
        (select rr.firma from rehber rr where p.cariid=rr.id limit 1)::text as alanrakip,
        (case when char_length(btrim(r1.firma)) - char_length(replace(btrim(r1.firma),'' '','''')) < 2
              then r1.firma
              else substr(r1.firma, 1,
                     ( position('' '' in substr(r1.firma, position('' '' in r1.firma)+1)) + position('' '' in r1.firma) ) - 1 )
         end)::text as firma,
        projetipi.anahtar::varchar as projetipi,
        rp.firma::text as adsoyad,
        (select rsor.firma from rehber rsor where rsor.id=p.prj_sorumlusu_id limit 1)::text as sorumluad,
        (select r5.firma from rehber r5 inner join projeasama pa on r5.id=pa.rehberid where pa.projeid=p.id and pa.asama=p.asama limit 1)::text as asamasorumlu,
        extract(month from p.baslamatarihi)::int as baslamaay,
        extract(year  from p.baslamatarihi)::int as baslamayil,
        extract(month from p.bitistarihi)::int as bitisay,
        extract(year  from p.bitistarihi)::int as bitisyil,
        (case when (select count(gy.id) from gorevyorum gy where p.id=gy.gorevid and gy.tur=70 and gy.gorevid=1) > 0 then 1 else 0 end)::int as dosyavar,
        (select a.konusu from gorevler a where a.projeid=p.id and a.ackapa=1 order by a.bitistarihi desc limit 1)::text as sonaktivitekonusu,
        (select a.bitistarihi from gorevler a where a.projeid=p.id and a.ackapa=1 order by a.bitistarihi desc limit 1)::timestamp as sonaktivitetarihi,
        (select f.tarih from fatbaslik f where f.projeid=p.id and f.tur in (10,11,12,14,15,16) order by f.tarih desc limit 1)::timestamp as sonsatbelgetarihi,
        (select f.fatura_tutari from fatbaslik f where f.projeid=p.id and f.tur in (10,11,12,14,15,16) order by f.tarih desc limit 1)::numeric as sonsattutari,
        (select t.durum from teklif t where t.projeid=p.id order by t.tarih desc limit 1)::smallint as sonteklifdurumu,
        (select t.teklif_matrahi from teklif t where t.projeid=p.id order by t.tarih desc limit 1)::numeric as sontekliftutari,
        (select t.kur from teklif t where t.projeid=p.id order by t.tarih desc limit 1)::varchar as sonteklifkur,
        (select t.tarih from teklif t where t.projeid=p.id order by t.tarih desc limit 1)::timestamp as sontekliftarihi
    from projeler p
        inner join rehber r1 on r1.id=p.rehberid
        left outer join rehber rp on rp.id=p.ilgili
        left outer join genini projetipi on projetipi.dil=-1 and projetipi.deger = p.tipi
             and projetipi.bolum = (''-2112''||p.turu::text)::int ';

    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) - 1:1 join
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_sql := v_sql || ' inner join kullanici_arama ka on ka.kayitid = p.id and ka.kulid = '
               || v_kulid || ' and ka.modul = ' || v_modul || ' ';
    END IF;

    v_sql := v_sql || ' where p.modul=11 ';

    -- checkKapaliGoster kapaliyken kapali projeler haric
    IF v_pasif = 0 THEN
        v_sql := v_sql || ' and p.durum <> 2 ';
    END IF;

    -- Tarih araligi (BASLAMATARIHI uzerinde)
    IF v_tarihbas IS NOT NULL THEN
        v_sql := v_sql || ' and p.baslamatarihi >= ' || quote_literal(v_tarihbas) || ' ';
    END IF;
    IF v_tarihbit IS NOT NULL THEN
        v_sql := v_sql || ' and p.baslamatarihi <= ' || quote_literal(v_tarihbit) || ' ';
    END IF;

    -- Metin filtreleri (ISNULL(...,'') LIKE '%x%' -> ILIKE)
    IF v_firma IS NOT NULL THEN
        v_sql := v_sql || ' and r1.firma ILIKE ' || quote_literal('%'||v_firma||'%') || ' ';
    END IF;
    IF v_projekodu IS NOT NULL THEN
        v_sql := v_sql || ' and p.projekodu ILIKE ' || quote_literal('%'||v_projekodu||'%') || ' ';
    END IF;
    IF v_projeadi IS NOT NULL THEN
        v_sql := v_sql || ' and p.projeadi ILIKE ' || quote_literal('%'||v_projeadi||'%') || ' ';
    END IF;
    IF v_yetkili IS NOT NULL THEN
        v_sql := v_sql || ' and rp.firma ILIKE ' || quote_literal('%'||v_yetkili||'%') || ' ';
    END IF;
    IF v_konusu IS NOT NULL THEN
        v_sql := v_sql || ' and p.konusu ILIKE ' || quote_literal('%'||v_konusu||'%') || ' ';
    END IF;

    -- Sayisal filtreler
    IF v_sorumlu > 0 THEN
        v_sql := v_sql || ' and p.prj_sorumlusu_id = ' || v_sorumlu || ' ';
    END IF;
    IF v_turu > 0 THEN
        v_sql := v_sql || ' and p.turu = ' || v_turu || ' ';
    END IF;
    IF v_asama > 0 THEN
        v_sql := v_sql || ' and p.asama = ' || v_asama || ' ';
    END IF;
    IF v_sonuc > 0 THEN
        v_sql := v_sql || ' and p.sonuc = ' || v_sonuc || ' ';
    END IF;

    -- Modul yetkisi (1=kendi, 10=kendi sube)
    IF v_kendikul > 0 THEN
        v_sql := v_sql || ' and p.prj_sorumlusu_id = ' || v_kendikul || ' ';
    END IF;
    IF v_kendisube > 0 THEN
        v_sql := v_sql || ' and p.subeid = ' || v_kendisube || ' ';
    END IF;

    -- Sube yetkisi (app-uretimi int listesi) - guard'li inline
    IF v_subelist IS NOT NULL AND v_subelist ~ '^[0-9, ]+$' THEN
        v_sql := v_sql || ' and p.subeid in (' || v_subelist || ') ';
    END IF;

    -- Son/Sik siralamasi; yoksa app @OrderBy
    IF v_mod = 5 THEN
        v_sql := v_sql || ' order by ka.degistirmetarihi desc ';
    ELSIF v_mod = 3 THEN
        v_sql := v_sql || ' order by ka.say desc ';
    ELSIF v_orderby IS NOT NULL THEN
        v_sql := v_sql || ' order by ' || v_orderby || ' ';
    END IF;

    IF v_topn > 0 THEN
        v_sql := v_sql || ' limit ' || v_topn;
    END IF;

    RETURN QUERY EXECUTE v_sql;
END $fn$;
