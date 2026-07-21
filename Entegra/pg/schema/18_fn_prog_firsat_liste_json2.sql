-- ============================================================
-- fn_prog_firsat_liste_json2 — MSSQL sp_Prog_Firsat_Liste_Json2 PG portu
--   Firsat listesi (PROJELER MODUL=1). P.* + 20 hesapli kolon.
--   @Baslik (@SelectList / EkAlanlar) YOK SAYILIR (dokuman/pdks/demirbas deseni;
--     sabit RETURNS TABLE'a runtime ek-kolon eklenemez; superset dondurulur).
--   MSSQL SELECT'i once bir P-alt-kumesini, sonra hesapli kolonlari, sonra P.* getirir ->
--     ayni ad iki kez cikar; ADO/FireDAC ilk-eslesmeyi okur. PG'de ad-tekrari yasak, bu yuzden
--     ilk-eslesme semantigi korunur: fiziksel PROJELER kolonlari BIR kez + 20 hesapli kolon.
--     TEK cakisan ad = NOTLAR (fiziksel projeler.notlar VE hesapli GY.YORUM). MSSQL'de hesapli
--     olan ONCE gelir -> kazanir; burada da notlar = hesapli son GOREVYORUM (TUR=70) yorumu.
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join, WHERE (pasif/durum, text-ILIKE, sayisal, tarih,
--     TekSubeTum, SubeYetkiList), ORDER, TOP->LIMIT.
--   MSSQL->PG: CONVERT(INT,'-2112'+CONVERT(VARCHAR,P.TURU))->('-2112'||p.turu::text)::int,
--     TOP1..ORDER..->..ORDER..LIMIT 1, LIKE(CI)->ILIKE quote_literal, ISNULL->COALESCE,
--     month()/year()->EXTRACT. firsat (projeler modul=1) su an BOS -> smoke-only, differential VACUOUS.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_firsat_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_firsat_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, lokal_firma_id integer, rehberid integer, projekodu varchar, baslamatarihi timestamp,
    bitistarihi timestamp, konusu varchar, turu smallint, durum smallint, asama smallint,
    prj_sorumlusu_id integer, prj_asama_sorumlusu_id integer, ilgili integer, listefiyati numeric,
    listekur varchar, satisfiyati numeric, satiskur varchar, notlar text, ekleyen integer,
    eklemetarihi timestamp, degistiren integer, degistirmetarihi timestamp, sonuc smallint,
    sonucaciklama varchar, detaybolumu varchar, tipi integer, aplikasyon smallint, projeadi varchar,
    olasilik smallint, subeid smallint, googleolayid varchar, googlehesapid smallint, cariid integer,
    sebebi smallint, kayipfiyati numeric, kayipkur varchar, giriskaynak smallint, rakip varchar,
    modul smallint, yeri integer, yerid integer,
    projeid integer, alanrakip text, firma text, projetipi text, adsoyad text, sorumluad text,
    asamasorumlu text, baslamaay int, baslamayil int, bitisay int, bitisyil int, dosyavar int,
    sonaktivitekonusu text, sonaktivitetarihi timestamp, sonsatbelgetarihi timestamp,
    sonsattutari numeric, sonteklifdurumu smallint, sontekliftutari numeric, sonteklifkur text,
    sontekliftarihi timestamp
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_pasif     int  := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_firma     text := NULLIF(j->>'Firma','');
    v_projekodu text := NULLIF(j->>'ProjeKodu','');
    v_konusu    text := NULLIF(j->>'Konusu','');
    v_sorumluid int  := NULLIF(j->>'SorumluID','')::int;
    v_turu      int  := NULLIF(j->>'Turu','')::int;
    v_asama     int  := NULLIF(j->>'Asama','')::int;
    v_tarihbas  timestamp := NULLIF(j->>'TarihBas','')::timestamp;
    v_tarihbit  timestamp := NULLIF(j->>'TarihBit','')::timestamp;
    v_teksubetum int := NULLIF(j->>'TekSubeTum','')::int;
    v_subekisit int  := NULLIF(j->>'SubeKisit','')::int;
    v_subeyetki text := NULLIF(j->>'SubeYetkiList','');
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := NULLIF(j->>'OrderBy','');
    q text; w text := ' WHERE p.modul=1 '; joinka text := ''; ordr text := NULL; lim text := '';
BEGIN
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;

    -- @Mod=3(Sik)/5(Son): kullanici arama gecmisi (KULLANICI_ARAMA) 1:1 join
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=p.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- checkKapaliGoster kapali (Pasif=0): kapali firsatlari gizle
    IF v_pasif = 0 THEN w := w || ' AND p.durum <> 2 '; END IF;

    -- Metin filtreleri (ILIKE, quote_literal)
    IF v_firma     IS NOT NULL THEN w := w || ' AND COALESCE(r1.firma,'''') ILIKE '||quote_literal('%'||v_firma||'%')||' '; END IF;
    IF v_projekodu IS NOT NULL THEN w := w || ' AND COALESCE(p.projekodu,'''') ILIKE '||quote_literal('%'||v_projekodu||'%')||' '; END IF;
    IF v_konusu    IS NOT NULL THEN w := w || ' AND COALESCE(p.konusu,'''') ILIKE '||quote_literal('%'||v_konusu||'%')||' '; END IF;

    -- Sayisal filtreler (int inline, >0 guard)
    IF v_sorumluid IS NOT NULL AND v_sorumluid > 0 THEN w := w || ' AND p.prj_sorumlusu_id='||v_sorumluid||' '; END IF;
    IF v_turu      IS NOT NULL AND v_turu      > 0 THEN w := w || ' AND p.turu='||v_turu||' '; END IF;
    IF v_asama     IS NOT NULL AND v_asama     > 0 THEN w := w || ' AND p.asama='||v_asama||' '; END IF;

    -- Tarih araligi (checkTarih) - parametre juggling yerine literal cast
    IF v_tarihbas IS NOT NULL THEN w := w || ' AND p.baslamatarihi >= '||quote_literal(v_tarihbas::text)||'::timestamp '; END IF;
    IF v_tarihbit IS NOT NULL THEN w := w || ' AND p.baslamatarihi <= '||quote_literal(v_tarihbit::text)||'::timestamp '; END IF;

    -- ModulYetki_TekSubeTum.Proje (1=sadece kendi projeleri, 10=sadece kendi sube)
    IF v_teksubetum = 1 AND v_kulid IS NOT NULL THEN w := w || ' AND p.prj_sorumlusu_id='||v_kulid||' ';
    ELSIF v_teksubetum = 10 AND v_subekisit IS NOT NULL THEN w := w || ' AND p.subeid='||v_subekisit||' '; END IF;

    -- Sube yetkisi (app-uretimi int listesi; guvenli guard)
    IF v_subeyetki IS NOT NULL AND v_subeyetki ~ '^[0-9, ]+$' THEN w := w || ' AND p.subeid IN ('||v_subeyetki||') '; END IF;

    -- Son/Sik aranan siralamasi; yoksa app @OrderBy (or. p.satiskur)
    IF v_mod = 5 THEN ordr := 'ka.degistirmetarihi DESC';
    ELSIF v_mod = 3 THEN ordr := 'ka.say DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := v_orderby; END IF;

    q := 'SELECT
            p.id, p.lokal_firma_id, p.rehberid, p.projekodu, p.baslamatarihi, p.bitistarihi, p.konusu,
            p.turu, p.durum, p.asama, p.prj_sorumlusu_id, p.prj_asama_sorumlusu_id, p.ilgili, p.listefiyati,
            p.listekur, p.satisfiyati, p.satiskur,
            -- NOTLAR: hesapli (son GOREVYORUM TUR=70) - fiziksel projeler.notlar''i golgeler (MSSQL ilk-eslesme)
            (SELECT gy.yorum FROM gorevyorum gy WHERE p.id=gy.gorevid AND gy.tur=70 ORDER BY gy.tarih DESC LIMIT 1)::text AS notlar,
            p.ekleyen, p.eklemetarihi, p.degistiren, p.degistirmetarihi, p.sonuc, p.sonucaciklama,
            p.detaybolumu, p.tipi, p.aplikasyon, p.projeadi, p.olasilik, p.subeid, p.googleolayid,
            p.googlehesapid, p.cariid, p.sebebi, p.kayipfiyati, p.kayipkur, p.giriskaynak, p.rakip,
            p.modul, p.yeri, p.yerid,
            p.id AS projeid,
            (SELECT rr.firma FROM rehber rr WHERE p.cariid=rr.id LIMIT 1)::text AS alanrakip,
            (CASE WHEN length(btrim(r1.firma)) - length(replace(btrim(r1.firma),'' '','''')) < 2 THEN r1.firma
                  ELSE substr(r1.firma, 1,
                       (position('' '' in substr(r1.firma, position('' '' in r1.firma)+1)) + position('' '' in r1.firma)) - 1)
             END)::text AS firma,
            pt.anahtar::text AS projetipi,
            rp.firma::text AS adsoyad,
            (SELECT rsor.firma FROM rehber rsor WHERE rsor.id=p.prj_sorumlusu_id LIMIT 1)::text AS sorumluad,
            (SELECT r5.firma FROM rehber r5 INNER JOIN projeasama pa ON r5.id=pa.rehberid
                 WHERE pa.projeid=p.id AND pa.asama=p.asama LIMIT 1)::text AS asamasorumlu,
            EXTRACT(MONTH FROM p.baslamatarihi)::int AS baslamaay,
            EXTRACT(YEAR  FROM p.baslamatarihi)::int AS baslamayil,
            EXTRACT(MONTH FROM p.bitistarihi)::int AS bitisay,
            EXTRACT(YEAR  FROM p.bitistarihi)::int AS bitisyil,
            (CASE WHEN (SELECT count(gy.id) FROM gorevyorum gy WHERE p.id=gy.gorevid AND gy.tur=70 AND gy.gorevid=1) > 0
                  THEN 1 ELSE 0 END)::int AS dosyavar,
            (SELECT a.konusu FROM gorevler a WHERE a.projeid=p.id AND a.ackapa=1 ORDER BY a.bitistarihi DESC LIMIT 1)::text AS sonaktivitekonusu,
            (SELECT a.bitistarihi FROM gorevler a WHERE a.projeid=p.id AND a.ackapa=1 ORDER BY a.bitistarihi DESC LIMIT 1)::timestamp AS sonaktivitetarihi,
            (SELECT f.tarih FROM fatbaslik f WHERE f.projeid=p.id AND f.tur IN (10,11,12,14,15,16) ORDER BY f.tarih DESC LIMIT 1)::timestamp AS sonsatbelgetarihi,
            (SELECT f.fatura_tutari FROM fatbaslik f WHERE f.projeid=p.id AND f.tur IN (10,11,12,14,15,16) ORDER BY f.tarih DESC LIMIT 1)::numeric AS sonsattutari,
            (SELECT t.durum FROM teklif t WHERE t.projeid=p.id ORDER BY t.tarih DESC LIMIT 1)::smallint AS sonteklifdurumu,
            (SELECT t.teklif_matrahi FROM teklif t WHERE t.projeid=p.id ORDER BY t.tarih DESC LIMIT 1)::numeric AS sontekliftutari,
            (SELECT t.kur FROM teklif t WHERE t.projeid=p.id ORDER BY t.tarih DESC LIMIT 1)::text AS sonteklifkur,
            (SELECT t.tarih FROM teklif t WHERE t.projeid=p.id ORDER BY t.tarih DESC LIMIT 1)::timestamp AS sontekliftarihi
          FROM projeler p
            INNER JOIN rehber r1 ON r1.id=p.rehberid
            LEFT OUTER JOIN rehber rp ON rp.id=p.ilgili
            LEFT OUTER JOIN genini pt ON pt.dil=-1 AND pt.deger=p.tipi AND pt.bolum=(''-2112''||p.turu::text)::int '
         || joinka || w;
    IF ordr IS NOT NULL THEN q := q || ' ORDER BY ' || ordr; END IF;
    q := q || lim;
    RETURN QUERY EXECUTE q;
END $$;
