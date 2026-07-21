-- ============================================================
-- fn_prog_demirbas_liste_json2 — MSSQL sp_Prog_Demirbas_Liste_Json2 PG portu
--   Demirbas liste. D.* + 5 hesapli kolon (zimmetli/lokasyon/kategori/model/kalbittarih).
--   @Baslik (EkAlanlar) YOK SAYILIR (dokuman/pdks deseni; sabit RETURNS TABLE'a ek-kolon eklenemez).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join, WHERE (durum/pasif/text-ILIKE/sube/kisit/kategori-yetki), ORDER, TOP->LIMIT.
--   MSSQL->PG: CONVERT(INT,'-2804'+CONVERT(VARCHAR,MARKA))->('-2804'||marka::text)::int, TOP1..ORDER..->LIMIT1,
--     LIKE(CI)->ILIKE quote_literal, ISNULL->COALESCE. demirbas su an BOS -> smoke-only.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_demirbas_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_demirbas_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, stokid integer, stokkodu varchar(20), serino varchar(25), marka smallint, model smallint,
    durum smallint, notlar varchar(250), ekleyen smallint, eklemetarihi timestamp, degistiren smallint,
    degistirmetarihi timestamp, kategoriid integer, lokasyonid integer, rfid varchar(20), barkod varchar(20),
    rehberid integer, skt timestamp, subeid smallint, demirbasno varchar(20), demirbasadi varchar(150),
    takip smallint, kalibrasyon smallint, servis smallint, amortismanoranid integer, r smallint,
    servisdurum smallint, tekniksorumlu integer, teknikbilgi integer, masraf smallint, amortisman smallint,
    resim bytea, ozellik1 varchar(50), ozellik2 varchar(50), ozellik3 varchar(50), ozellik4 varchar(50),
    ozellik5 varchar(50), tur smallint,
    zimmetliadi text, lokasyonadi text, kategoriadi text, modelad text, kalbittarih timestamp
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_pasif     int  := COALESCE(NULLIF(j->>'Pasif','')::int, 0);
    v_durumid   int  := NULLIF(j->>'DurumID','')::int;
    v_kategoriadi text := NULLIF(j->>'KategoriAdi','');
    v_lokasyonadi text := NULLIF(j->>'LokasyonAdi','');
    v_zimmetadi text := NULLIF(j->>'ZimmetAlanAdi','');
    v_demirbasno text := NULLIF(j->>'DemirbasNo','');
    v_demirbasadi text := NULLIF(j->>'DemirbasAdi','');
    v_serino    text := NULLIF(j->>'SeriNo','');
    v_subeyetki text := NULLIF(j->>'SubeYetkiList','');
    v_kulkisit  int  := COALESCE(NULLIF(j->>'KullaniciKisit','')::int, 0);
    v_kullaniciid int := NULLIF(j->>'KullaniciId','')::int;
    v_subeid    int  := NULLIF(j->>'SubeId','')::int;
    v_katyetki  int  := COALESCE(NULLIF(j->>'KategoriYetki','')::int, 1);
    v_rolid     int  := NULLIF(j->>'RolId','')::int;
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := NULLIF(j->>'OrderBy','');
    q text; w text := ' WHERE 1=1 '; joinka text := ''; ordr text; lim text := '';
BEGIN
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=d.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;
    -- durum / pasif
    IF v_durumid IS NOT NULL THEN w := w || ' AND d.durum='||v_durumid||' ';
    ELSIF v_pasif = 0 THEN w := w || ' AND d.durum < 30 '; END IF;
    -- metin filtreleri (ILIKE, quote_literal)
    IF v_kategoriadi IS NOT NULL THEN w := w || ' AND du.ad ILIKE '||quote_literal('%'||v_kategoriadi||'%')||' '; END IF;
    IF v_lokasyonadi IS NOT NULL THEN w := w || ' AND l.aciklama ILIKE '||quote_literal('%'||v_lokasyonadi||'%')||' '; END IF;
    IF v_zimmetadi  IS NOT NULL THEN w := w || ' AND r.firma ILIKE '||quote_literal('%'||v_zimmetadi||'%')||' '; END IF;
    IF v_demirbasno IS NOT NULL THEN w := w || ' AND d.demirbasno ILIKE '||quote_literal('%'||v_demirbasno||'%')||' '; END IF;
    IF v_demirbasadi IS NOT NULL THEN w := w || ' AND d.demirbasadi ILIKE '||quote_literal('%'||v_demirbasadi||'%')||' '; END IF;
    IF v_serino     IS NOT NULL THEN w := w || ' AND d.serino ILIKE '||quote_literal('%'||v_serino||'%')||' '; END IF;
    -- sube yetkisi (app-uretimi int listesi; guvenli guard)
    IF v_subeyetki IS NOT NULL AND v_subeyetki ~ '^[0-9, ]+$' THEN w := w || ' AND d.subeid IN ('||v_subeyetki||') '; END IF;
    -- kullanici kisiti
    IF v_kulkisit = 1 AND v_kullaniciid IS NOT NULL THEN w := w || ' AND d.rehberid='||v_kullaniciid||' ';
    ELSIF v_kulkisit = 5 AND v_kullaniciid IS NOT NULL THEN
        w := w || ' AND d.rehberid IN (SELECT rb.id FROM rehber rb INNER JOIN roller rol ON rb.sinif=rol.id
                   WHERE rol.departman=(SELECT rol2.departman FROM rehber rb2 INNER JOIN roller rol2 ON rb2.sinif=rol2.id WHERE rb2.id='||v_kullaniciid||')) ';
    ELSIF v_kulkisit = 10 AND v_subeid IS NOT NULL THEN w := w || ' AND d.subeid='||v_subeid||' '; END IF;
    -- kategori yetkisi
    IF v_katyetki = 0 THEN w := w || ' AND d.kategoriid=0 ';
    ELSIF v_katyetki = 2 AND v_rolid IS NOT NULL THEN
        w := w || ' AND d.kategoriid IN (SELECT CAST(COALESCE(y.bilgi,0) AS int) FROM yetkiek y WHERE y.rolid='||v_rolid||' AND y.modulid=280105) ';
    END IF;
    -- siralama
    IF v_mod = 5 THEN ordr := 'ka.degistirmetarihi DESC';
    ELSIF v_mod = 3 THEN ordr := 'ka.say DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := v_orderby;
    ELSE ordr := 'd.eklemetarihi DESC'; END IF;

    q := 'SELECT d.*,
            r.firma::text AS zimmetliadi, l.aciklama::text AS lokasyonadi, du.ad::text AS kategoriadi,
            stokmodel.anahtar::text AS modelad,
            (SELECT max(k.gecerliliktarihi) FROM kalibrasyon k WHERE k.demirbasid=d.id)::timestamp AS kalbittarih
          FROM demirbas d
            LEFT OUTER JOIN demirbas_kategori du ON du.id=d.kategoriid
            LEFT OUTER JOIN genini stokmodel ON stokmodel.deger=d.model AND stokmodel.bolum=(''-2804''||d.marka::text)::int
            LEFT OUTER JOIN rehber r ON r.id=d.rehberid
            LEFT OUTER JOIN lokasyon l ON l.id=(SELECT dt.lokasyonid FROM demirbas_tutanak dt
                   INNER JOIN demirbas_tutanak_detay dtd ON dt.id=dtd.tutanakid AND dtd.demirbasid=d.id ORDER BY dt.id DESC LIMIT 1) '
         || joinka || w || ' ORDER BY ' || ordr || lim;
    RETURN QUERY EXECUTE q;
END $$;
