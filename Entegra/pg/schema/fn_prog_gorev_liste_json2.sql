-- ============================================================
-- fn_prog_gorev_liste_json2 — MSSQL sp_Prog_Gorev_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- Gorev (task) liste ekrani. Iki param: @Baslik (SELECT ek kolonlari, Gorev'de BOS/
--   GUVENILIR) + @Kosullar (JSON filtreler). MSSQL SP TAMAMEN dinamik SQL kurar.
--
-- PG UYARLAMA NOTU: app 'SELECT * FROM fn_prog_gorev_liste_json2(:Baslik,:Kosullar)'
--   cagirir -> PG fonksiyonu SABIT RETURNS TABLE yapisina sahip olmali; dinamik
--   @Baslik ile kolon sayisi degistirilemez. Gorev'de @Baslik daima bos oldugundan
--   govdede KULLANILMAZ (parite korunur). Son/Sik siralama kolonlari (SON_ARAMA/
--   SIK_ARAMA) her zaman RETURNS TABLE'da vardir (superset); Mod 3/5 disinda NULL.
--
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, bit->smallint,
--   convert(bit,case..)->(case..)::smallint, TOP1 subquery->ORDER BY..LIMIT 1,
--   TOP N->LIMIT N, LIKE(CI)->ILIKE + quote_literal('%'||x||'%'), getdate yok.
--   fn_GorevVerilenKisiler inline: GOREVKULLANICI GK JOIN KULLANICI KL uzerinden
--   KOD'lari ' - ' ile birlestir + MSSQL'in ' -' kuyruk kirpma quirk'i korunur.
--   Metin filtreler quote_literal (injection yok); int filtreler ::int inline;
--   @OrderBy app-uretimi -> whitelist guard (~ '^[A-Za-z0-9_ ,.]+$').
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_gorev_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_gorev_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, ackapa smallint, listeid integer, listeadi varchar, konusu varchar,
    turu text, ekleyen integer, rehberid integer, cariad text, mus_ilgili text,
    atanan1 text, baslamatarihi timestamp, bitistarihi timestamp,
    tekrar_bit smallint, animsat_bit smallint, bayrak smallint, durum smallint,
    eklemetarihi timestamp, projekodu text, ekleyenad text,
    son_arama timestamp, sik_arama integer
)
LANGUAGE plpgsql STABLE AS $fn$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_pasif     int  := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_ara       text := NULLIF(j->>'Ara','');
    v_tarih     int  := COALESCE(NULLIF(j->>'Tarih','')::int, 0);
    v_bastarih  text := NULLIF(j->>'BasTarih','');
    v_bittarih  text := NULLIF(j->>'BitTarih','');
    v_firmaid   int  := NULLIF(j->>'FirmaID','')::int;
    v_olustid   int  := NULLIF(j->>'OlusturanID','')::int;
    v_atananid  int  := NULLIF(j->>'AtananID','')::int;
    v_gorevid   int  := NULLIF(j->>'GorevID','')::int;
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := NULLIF(j->>'OrderBy','');
    v_sonsik    text;
    v_sql       text;
BEGIN
    -- Son/Sik siralama kolonlari: yalniz Mod 3/5 + KulId + Modul varsa KA'dan; yoksa NULL
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_sonsik := ' ka.degistirmetarihi::timestamp as son_arama, ka.say::int as sik_arama ';
    ELSE
        v_sonsik := ' null::timestamp as son_arama, null::int as sik_arama ';
    END IF;

    v_sql := '
    SELECT DISTINCT
        g.id::int, g.ackapa::smallint, g.listeid::int, gl.adi::varchar, g.konusu::varchar,
        (select anahtar from genini where bolum=-21044 and dil=-1 and deger=g.turu limit 1)::text as turu,
        g.ekleyen::int, g.rehberid::int,
        (select r.firma from rehber r where r.id=g.rehberid)::text as cariad,
        (select r.firma from rehber r where r.id=g.mus_ilgili)::text as mus_ilgili,
        (select case when count(*)=0 then '''' else string_agg(kl.kod, '' - '' order by gk2.id) || '' -'' end
              from gorevkullanici gk2 inner join kullanici kl on gk2.rehberid=kl.rehberid
              where gk2.listgorevid=g.id)::text as atanan1,
        g.baslamatarihi::timestamp, g.bitistarihi::timestamp,
        (case when g.tekrarid>0 then 1 else 0 end)::smallint as tekrar_bit,
        (case when g.animsat>0 then 1 else 0 end)::smallint as animsat_bit,
        g.bayrak::smallint, g.durum::smallint, g.eklemetarihi::timestamp,
        (select p.projekodu from projeler p where p.id=g.projeid)::text as projekodu,
        (select r.firma from rehber r where r.id=g.ekleyen)::text as ekleyenad,
        ' || v_sonsik || '
    FROM gorevler g
        inner join gorevliste gl on g.listeid=gl.id
        left join gorevyorum gy on g.id=gy.gorevid ';

    -- @AtananID: GOREVKULLANICI join (WHERE filtresi icin)
    IF v_atananid IS NOT NULL AND v_atananid > 0 THEN
        v_sql := v_sql || ' left join gorevkullanici gk on gk.listgorevid=g.id and gk.tur=11 ';
    END IF;

    -- @Mod 3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) 1:1 join
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_sql := v_sql || ' inner join kullanici_arama ka on ka.kayitid = g.id and ka.kulid = '
               || v_kulid || ' and ka.modul = ' || v_modul || ' ';
    END IF;

    v_sql := v_sql || ' where 1=1 ';

    -- Pasif=0: sadece acik gorevler
    IF v_pasif = 0 THEN
        v_sql := v_sql || ' and g.ackapa = 0 ';
    END IF;

    -- Metin arama (KONUSU / GOREVYORUM.YORUM)
    IF v_ara IS NOT NULL THEN
        v_sql := v_sql || ' and (g.konusu ILIKE ' || quote_literal('%'||v_ara||'%')
               || ' or gy.yorum ILIKE ' || quote_literal('%'||v_ara||'%') || ') ';
    END IF;

    -- Tarih araligi (BASLAMATARIHI) - orijinaldeki > ve < ile birebir
    IF v_tarih = 1 AND v_bastarih IS NOT NULL AND v_bittarih IS NOT NULL THEN
        v_sql := v_sql || ' and g.baslamatarihi > ' || quote_literal(v_bastarih||' 00:00') || ' ';
        v_sql := v_sql || ' and g.baslamatarihi < ' || quote_literal(v_bittarih||' 23:59') || ' ';
    END IF;

    -- Sayisal filtreler (int inline)
    IF v_firmaid IS NOT NULL AND v_firmaid > 0 THEN
        v_sql := v_sql || ' and g.rehberid = ' || v_firmaid || ' ';
    END IF;
    IF v_olustid IS NOT NULL AND v_olustid > 0 THEN
        v_sql := v_sql || ' and g.ekleyen = ' || v_olustid || ' ';
    END IF;
    IF v_atananid IS NOT NULL AND v_atananid > 0 THEN
        v_sql := v_sql || ' and gk.rehberid = ' || v_atananid || ' ';
    END IF;
    IF v_gorevid IS NOT NULL AND v_gorevid > 0 THEN
        v_sql := v_sql || ' and g.id = ' || v_gorevid || ' ';
    END IF;

    -- Son/Sik aranan siralamasi (KULLANICI_ARAMA); DISTINCT icin SELECT alias'lari
    IF v_mod = 5 THEN
        v_orderby := 'son_arama desc';
    ELSIF v_mod = 3 THEN
        v_orderby := 'sik_arama desc';
    END IF;

    -- @OrderBy app-uretimi -> whitelist guard (kolon adi/ASC/DESC/virgul); aksi halde atla
    IF v_orderby IS NOT NULL AND v_orderby ~ '^[A-Za-z0-9_ ,.]+$' THEN
        v_sql := v_sql || ' order by ' || v_orderby;
    END IF;

    -- @Top (yalniz TopN>0)
    IF v_topn > 0 THEN
        v_sql := v_sql || ' limit ' || v_topn;
    END IF;

    RETURN QUERY EXECUTE v_sql;
END $fn$;
