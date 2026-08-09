DROP FUNCTION IF EXISTS public.fn_prog_servis_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_servis_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, baslamatarihi timestamp, rehberid integer, servisno varchar, konusu varchar, durum smallint,
    mus_ilgili integer, bitistarihi timestamp, serino varchar, kasa smallint, fiyat_listesi smallint,
    ozelkod varchar, yetkikodu varchar, notlar varchar, ekipmanrehberid integer, depo smallint, lokasyonid integer,
    planlanan_matrahi numeric, planlanan_tutar numeric, planlanan_kur varchar, planlanan_doviz_tutari numeric,
    planlanan_doviz_kuru numeric, planlanan_kdv_tutari numeric, uygulanan_matrahi numeric, uygulanan_tutar numeric,
    uygulanan_kur varchar, uygulanan_doviz_tutari numeric, uygulanan_doviz_kuru numeric, uygulanan_kdv_tutari numeric,
    sorumlu integer, kabul_eden integer, kabul_sekli smallint, teslim_alan integer, teslim_eden integer,
    teslim_tarihi timestamp, teslim_sekli smallint, teslim_kargo_no varchar, onaysekli smallint, onaytarihi timestamp,
    onaylayan integer, onayalan integer, subeid smallint, ekleyen smallint, eklemetarihi timestamp, degistiren smallint,
    degistirmetarihi timestamp, kapsam smallint, detaybolumu varchar, acil smallint, disservis smallint, tarih timestamp,
    ekipmanid integer, teslimnotu varchar, ackapa smallint, demirbas smallint, yeri integer, yerid integer, turu smallint,
    onaylayacak integer, disonay integer, servisadresi integer, kocanno varchar, servisseri varchar, onemli smallint,
    projeid integer, giriskaynak smallint, yildiz smallint, baslama timestamp, bitis timestamp, toplam_sure text,
    calisma_suresi text, sorun_tipi varchar, sorun_aciklama varchar, sorun_sonucu varchar, kabul_edenad varchar,
    kategoriad varchar, ekipmanad varchar, firma varchar, sorumluad varchar, mus_ilgiliad varchar, lokasyon varchar,
    onaylayanad varchar, teslim_alanad varchar, onaysekliad varchar, faturatarih timestamp, faturano varchar,
    fatura_tutari numeric, servis_adresi varchar
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn int := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod int := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_servisno text := NULLIF(j->>'ServisNo','');
    v_servisnoid int := NULLIF(j->>'ServisNoId','')::int;
    v_servisnolike boolean := COALESCE(NULLIF(j->>'ServisNoLike','')::int, 0) <> 0;
    v_kategoriad text := NULLIF(j->>'KategoriAd','');
    v_konusu text := NULLIF(j->>'Konusu','');
    v_urun text := NULLIF(j->>'Urun','');
    v_musteri text := NULLIF(j->>'Musteri','');
    -- Cari ekranindaki Servis alt sekmesi: kimlik uzerinden kesin cari filtresi.
    v_rehberid int := NULLIF(j->>'RehberId','')::int;
    v_serinom text := NULLIF(j->>'SeriNo','');
    v_serinolike boolean := COALESCE(NULLIF(j->>'SeriNoLike','')::int, 0) <> 0;
    v_subeyetki text := NULLIF(j->>'SubeYetkiList','');
    v_cbliste int := NULLIF(j->>'cbListe','')::int;
    v_kullanan int := NULLIF(j->>'Kullanan','')::int;
    v_subeidf int := NULLIF(j->>'SubeID','')::int;
    v_durum int := NULLIF(j->>'Durum','')::int;
    v_durumvar int := COALESCE(NULLIF(j->>'DurumVar','')::int, 0);
    v_sorumlutag int := COALESCE(NULLIF(j->>'SorumluTag','')::int, 0);
    v_kapali int := COALESCE(NULLIF(j->>'Kapali','')::int, 0);
    v_tamamlanan int := NULLIF(j->>'Tamamlanan','')::int;
    v_kapalitarih text := NULLIF(j->>'KapaliTarih','');
    v_tarihbas text := NULLIF(j->>'TarihBas','');
    v_tarihbit text := NULLIF(j->>'TarihBit','');
    v_kulid int := NULLIF(j->>'KulId','')::int;
    v_modul int := NULLIF(j->>'Modul','')::int;
    v_orderby text := NULLIF(j->>'OrderBy','');
    v_limit int := CASE WHEN v_topn > 0 THEN v_topn ELSE 200 END;
    q text;
    base_sql text;
    w text := ' WHERE 1=1 ';   -- filtreler ON SUZMEYE tasindi; burada yalniz kajoin kaliyor
    joinka text := '';
    ordr text := '';
    lim text := '';
    kajoin boolean := false;
    -- ON SUZME (PERF): MSSQL ikizindeki ayni duzeltme. Filtreler ve LIMIT en icteki servis
    --   taramasina inmezse, TUM servis tablosu (or. 34.000 satir) icin ~15 alt sorgu +
    --   ozet gorunum hesaplanip SONRA filtreleniyor -> liste saniyelerce suruyor.
    v_filt text := '';
BEGIN
    IF v_topn > 0 THEN
        lim := ' LIMIT ' || v_topn;
    END IF;

    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        kajoin := true;
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=s.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
        IF v_mod = 5 THEN
            ordr := 'ka.degistirmetarihi DESC';
            base_sql := 'SELECT s0.* FROM servis s0 INNER JOIN kullanici_arama ka0 ON ka0.kayitid=s0.id AND ka0.kulid='||v_kulid||' AND ka0.modul='||v_modul||' ORDER BY ka0.degistirmetarihi DESC LIMIT '||v_limit;
        ELSE
            ordr := 'ka.say DESC';
            base_sql := 'SELECT s0.* FROM servis s0 INNER JOIN kullanici_arama ka0 ON ka0.kayitid=s0.id AND ka0.kulid='||v_kulid||' AND ka0.modul='||v_modul||' ORDER BY ka0.say DESC LIMIT '||v_limit;
        END IF;
    ELSIF v_servisno IS NOT NULL OR v_serinom IS NOT NULL THEN
        base_sql := 'SELECT s0.* FROM servis s0 WHERE (false';
        IF v_servisno IS NOT NULL THEN
            IF v_servisnolike THEN
                base_sql := base_sql || ' OR s0.servisno ILIKE '||quote_literal(v_servisno);
            ELSE
                base_sql := base_sql || ' OR s0.servisno = '||quote_literal(v_servisno);
            END IF;
        END IF;
        IF v_servisnoid IS NOT NULL AND v_servisnoid <> 0 THEN
            base_sql := base_sql || ' OR s0.id='||v_servisnoid;
        END IF;
        IF v_serinom IS NOT NULL THEN
            IF v_serinolike THEN
                base_sql := base_sql || ' OR s0.serino ILIKE '||quote_literal(v_serinom);
            ELSE
                base_sql := base_sql || ' OR s0.serino = '||quote_literal(v_serinom);
            END IF;
        END IF;
        base_sql := base_sql || ') ORDER BY s0.id DESC LIMIT '||v_limit;
    ELSE
        base_sql := NULL;   -- filtreler toplandiktan SONRA kurulur (asagida)
    END IF;

    IF v_servisno IS NOT NULL THEN
        IF v_servisnolike THEN
            v_filt := v_filt || ' AND ((s0.servisno ILIKE '||quote_literal(v_servisno)||')';
        ELSE
            v_filt := v_filt || ' AND ((s0.servisno = '||quote_literal(v_servisno)||')';
        END IF;
        IF v_servisnoid IS NOT NULL AND v_servisnoid <> 0 THEN
            v_filt := v_filt || ' OR (s0.id='||v_servisnoid||')';
        END IF;
        v_filt := v_filt || ')';
    END IF;
    IF v_kategoriad IS NOT NULL THEN
        v_filt := v_filt || ' AND (SELECT ad FROM kategori k WHERE k.id=s0.ekipmanid) ILIKE '||quote_literal(v_kategoriad)||' ';
    END IF;
    IF v_konusu IS NOT NULL THEN
        v_filt := v_filt || ' AND s0.konusu ILIKE '||quote_literal('%'||v_konusu||'%')||' ';
    END IF;
    IF v_urun IS NOT NULL THEN
        v_filt := v_filt || ' AND (SELECT ad FROM ekipmanlar e WHERE e.id=s0.ekipmanid) ILIKE '||quote_literal('%'||v_urun||'%')||' ';
    END IF;
    IF v_musteri IS NOT NULL THEN
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM rehber rm WHERE rm.id=s0.rehberid AND rm.firma ILIKE '||quote_literal('%'||v_musteri||'%')||') ';
    END IF;

    IF COALESCE(v_rehberid,0) > 0 THEN
        v_filt := v_filt || ' AND s0.rehberid = '||v_rehberid||' ';
    END IF;
    IF v_subeyetki IS NOT NULL AND v_subeyetki ~ '^[0-9, ]+$' THEN
        v_filt := v_filt || ' AND s0.subeid IN ('||v_subeyetki||') ';
    END IF;
    IF v_serinom IS NOT NULL THEN
        IF v_serinolike THEN
            v_filt := v_filt || ' AND s0.serino ILIKE '||quote_literal(v_serinom)||' ';
        ELSE
            v_filt := v_filt || ' AND s0.serino = '||quote_literal(v_serinom)||' ';
        END IF;
    END IF;

    IF v_cbliste = 1 THEN
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM vservishareket shx WHERE COALESCE(shx.bitissec,0)=0 AND shx.servisid=s0.id AND shx.personel='||v_kullanan||') ';
    ELSIF v_cbliste = 2 THEN
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM vservishareket shx WHERE shx.servisid=s0.id AND shx.personel='||v_kullanan||') ';
    ELSIF v_cbliste = 5 THEN
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM vservishareket shx WHERE shx.servisid=s0.id AND shx.personel IN '
             || ' (SELECT r.id FROM rehber r INNER JOIN roller rol ON r.sinif=rol.id '
             || '  WHERE rol.departman=(SELECT rol2.departman FROM rehber r2 INNER JOIN roller rol2 ON r2.sinif=rol2.id '
             || '  WHERE r2.id='||v_kullanan||'))) ';
    ELSIF v_cbliste = 8 THEN
        v_filt := v_filt || ' AND s0.subeid='||v_subeidf||' ';
    END IF;

    IF v_durumvar = 1 THEN
        v_filt := v_filt || ' AND s0.durum='||v_durum||' ';
    END IF;
    IF v_durumvar = 1 AND v_sorumlutag > 0 THEN
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM vservishareket shx WHERE shx.servisid=s0.id AND shx.durum='||v_durum||' AND shx.personel='||v_sorumlutag||') ';
    ELSIF v_durumvar = 0 AND v_sorumlutag > 0 THEN
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM vservishareket shx WHERE shx.servisid=s0.id AND shx.personel='||v_sorumlutag||') ';
    ELSIF v_durumvar = 1 AND v_sorumlutag = 0 THEN
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM vservishareket shx WHERE shx.servisid=s0.id AND shx.durum='||v_durum||') ';
    END IF;

    IF v_servisno IS NULL AND v_serinom IS NULL THEN
        IF v_kapali = 1 THEN
            IF v_tamamlanan = 1 THEN
                v_filt := v_filt || ' AND (COALESCE(s0.ackapa,0)=0 OR s0.baslamatarihi::date = current_date) ';
            ELSIF v_tamamlanan = 19000 THEN
                v_filt := v_filt || ' AND (COALESCE(s0.ackapa,0)=0 OR (s0.baslamatarihi BETWEEN '||quote_nullable(v_tarihbas)||'::timestamp AND '||quote_nullable(v_tarihbit)||'::timestamp)) ';
            ELSE
                v_filt := v_filt || ' AND (COALESCE(s0.ackapa,0)=0 OR s0.baslamatarihi >= '||quote_nullable(v_kapalitarih)||'::timestamp) ';
            END IF;
        ELSE
            v_filt := v_filt || ' AND s0.ackapa = 0 ';
        END IF;
    END IF;

    -- Genel dal: filtreler + LIMIT en ice; deterministik siralama (id DESC = en yeni ustte)
    --   sayfalama icin sart (TSayfaliListe LIMIT'i buyuterek ayni sorguyu tekrar cagirir).
    IF base_sql IS NULL THEN
        base_sql := 'SELECT s0.* FROM servis s0 WHERE 1=1 ' || v_filt || ' ORDER BY s0.id DESC';
        IF v_topn > 0 THEN
            base_sql := base_sql || ' LIMIT ' || v_topn;
        END IF;
    ELSE
        -- servisno/serino ya da Son/Sik Aranan dali: kendi on suzmesi var, filtreler eklenir
        base_sql := 'SELECT * FROM (' || base_sql || ') b0 WHERE 1=1 '
                    || replace(v_filt, 's0.', 'b0.');
    END IF;

    IF NOT kajoin AND v_orderby IS NOT NULL THEN
        ordr := v_orderby;
    ELSIF NOT kajoin AND v_orderby IS NULL THEN
        ordr := 's.id DESC';   -- MSSQL ile ayni: on suzme sirasi disarida da korunur
    END IF;

    q := 'WITH base AS ('||base_sql||')
          SELECT
              s.id, s.baslamatarihi, s.rehberid, s.servisno, s.konusu, s.durum,
              s.mus_ilgili, s.bitistarihi, s.serino, s.kasa, s.fiyat_listesi,
              s.ozelkod, s.yetkikodu, s.notlar, s.ekipmanrehberid, s.depo, s.lokasyonid,
              s.planlanan_matrahi, s.planlanan_tutar, s.planlanan_kur, s.planlanan_doviz_tutari,
              s.planlanan_doviz_kuru, s.planlanan_kdv_tutari, s.uygulanan_matrahi, s.uygulanan_tutar,
              s.uygulanan_kur, s.uygulanan_doviz_tutari, s.uygulanan_doviz_kuru, s.uygulanan_kdv_tutari,
              s.sorumlu, s.kabul_eden, s.kabul_sekli, s.teslim_alan, s.teslim_eden,
              s.teslim_tarihi, s.teslim_sekli, s.teslim_kargo_no, s.onaysekli, s.onaytarihi,
              s.onaylayan, s.onayalan, s.subeid, s.ekleyen, s.eklemetarihi, s.degistiren,
              s.degistirmetarihi, s.kapsam, s.detaybolumu, s.acil, s.disservis, s.tarih,
              s.ekipmanid, s.teslimnotu, s.ackapa, s.demirbas, s.yeri, s.yerid, s.turu,
              s.onaylayacak, s.disonay, s.servisadresi, s.kocanno, s.servisseri, s.onemli,
              s.projeid, s.giriskaynak, s.yildiz, sh.baslama, sh.bitis, sh.toplam_sure,
              sh.calisma_suresi, sl.ad AS sorun_tipi, sb.aciklama AS sorun_aciklama,
              sb.cozum AS sorun_sonucu, r7.firma AS kabul_edenad,
              CASE WHEN s.demirbas=1 THEN (SELECT du.stokadi FROM demirbas_urun du INNER JOIN demirbas d ON d.kategoriid=du.id WHERE d.id=s.ekipmanid LIMIT 1)
                   ELSE (SELECT k.ad FROM kategori k WHERE k.id=s.ekipmanid LIMIT 1) END AS kategoriad,
              CASE WHEN s.demirbas=1 THEN (SELECT d.demirbasadi FROM demirbas d WHERE d.id=s.ekipmanid LIMIT 1)
                   ELSE (SELECT e.ad FROM ekipmanlar e WHERE e.id=s.ekipmanid LIMIT 1) END AS ekipmanad,
              r1.firma, fn_serviskisiler(s.durum, s.id)::varchar AS sorumluad, rp.firma AS mus_ilgiliad,
              (SELECT l.aciklama FROM lokasyon l WHERE l.id=s.lokasyonid LIMIT 1) AS lokasyon,
              (SELECT r5.firma FROM rehber r5 WHERE r5.grup=334 AND r5.id=s.disonay LIMIT 1) AS onaylayanad,
              (SELECT r5.firma FROM rehber r5 WHERE r5.grup=334 AND r5.id=s.teslim_alan LIMIT 1) AS teslim_alanad,
              (SELECT g.anahtar FROM genini g WHERE g.bolum=-3005 AND g.deger=s.onaysekli LIMIT 1) AS onaysekliad,
              fb.faturatarih, fb.faturano, fb.fatura_tutari, ri.ad AS servis_adresi
          FROM base s
          -- NOT: MSSQL tarafinda bu gorunum her grup icin IKI SKALER UDF calistirdigi icin
          --   OUTER APPLY yapildi; PG surumu ayni hesabi saf SQL (CASE) ile yapar, skaler UDF
          --   yoktur. Asil kazanc zaten ON SUZMEDE.
          LEFT JOIN LATERAL (SELECT o.baslama, o.bitis, o.toplam_sure, o.calisma_suresi
                               FROM v_servis_hareket_ozet o
                              WHERE o.servisid = s.id) sh ON TRUE
          LEFT JOIN rehber r1 ON r1.id=s.rehberid
          LEFT JOIN rehber rp ON rp.id=s.mus_ilgili AND rp.grup=334
          LEFT JOIN LATERAL (
              SELECT fb1.faturatarih, fb1.faturano, fb1.fatura_tutari
              FROM fatbaslik fb1
              WHERE fb1.servisid=s.id AND fb1.tur IN (15,16)
              ORDER BY fb1.id DESC
              LIMIT 1
          ) fb ON true
          -- row_number li turetilmis tablo TUM servisbilgi icin hesaplaniyordu; ilk satiri
          --   satir basina getiren LATERAL ayni sonucu index ile verir (apostrof YOK: bu metin
          --   dinamik SQL dizgisinin icinde).
          LEFT JOIN LATERAL (
              SELECT sb2.aciklama, sb2.cozum, sb2.servislisteid
                FROM servisbilgi sb2
               WHERE sb2.servisid = s.id AND sb2.servistur = 210
               ORDER BY sb2.id
               LIMIT 1) sb ON TRUE
          LEFT JOIN servisliste sl ON sl.id=sb.servislisteid
          LEFT JOIN rehberiletisim ri ON ri.rehberid=s.rehberid AND ri.id=s.servisadresi
          LEFT JOIN rehber r7 ON r7.id=s.ekleyen '
          || joinka || w;
    IF ordr <> '' THEN
        q := q || ' ORDER BY ' || ordr;
    END IF;
    IF NOT kajoin THEN
        q := q || lim;
    END IF;

    RETURN QUERY EXECUTE q;
END $$;

CREATE INDEX IF NOT EXISTS ix_servis_servisno ON public.servis(servisno);
CREATE INDEX IF NOT EXISTS ix_servis_serino ON public.servis(serino);
