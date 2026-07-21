-- ============================================================
-- fn_prog_belgedonusum_kaynak — MSSQL sp_Prog_BelgeDonusum_Kaynak_Json2 PG portu
--   Belge Donusum kaynak listesi; @Kaynak 1=TEKLIF 2=SIPARIS 3=FATBASLIK.
--   DINAMIK (EXECUTE format + USING $N): EN/BOY/YUZEY/SAYI opsiyonel (feature-gated;
--     PG'de yalniz teklifdetay'da var) -> @EnBoy iken kolon, degilse NULL literal.
--   RETURNS TABLE SABIT superset (53 kolon); dala ozel eksik kolonlar NULL.
--   Her kolon RETURNS tipine EXPLICIT cast (dallar farkli tabloda ayni-ad farkli-tip olabilir).
-- MSSQL->PG: ISNULL->COALESCE, TOP1->LIMIT1, X=expr->expr AS x, LIKE(CI)->ILIKE,
--   CAST(NULL AS NVARCHAR)->NULL::text, izleme STOKIZLEME JOIN STOKSERILOT.
--   NOT: siparis/fatura/teklif su an BOS -> smoke-only (differential veri bekliyor).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_belgedonusum_kaynak_json2(text, text);
CREATE FUNCTION public.fn_prog_belgedonusum_kaynak_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    baslikid int, satirid int, stokid int, rehberid int, firma text, tarih timestamp,
    belgeno text, kod text, stokadi text, anabirim text, aciklama text, izleme int,
    ozelkod text, ozelkod2 text, muhkodu text, kdv numeric, kur text, doviz_kuru text,
    adet numeric, miktar numeric, birim text, birimfiyat numeric, iskonto numeric, iskonto2 numeric,
    tutar numeric, doviz_birimfiyat numeric, dovizkurdegeri numeric, doviz_tutari numeric,
    masrafid int, merkezid int, kampanyaid int, donusen numeric, iade numeric, kalan numeric,
    teslimtarihi timestamp, rehberiletid int, sevk text, satici text, depoad text,
    projeid int, pozno text, urunno text, detaybolumu text, projekodu text, gizle int,
    detay_ozelkod text, detay_ozelkod2 text, baslik_ozelkod text, baslik_ozelkod2 text,
    en numeric, boy numeric, yuzey numeric, sayi numeric
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_kaynak    int := COALESCE(NULLIF(j->>'Kaynak','')::int, 0);
    v_cbtur     int := COALESCE(NULLIF(j->>'CbTur','')::int, 0);
    v_dt        int := COALESCE(NULLIF(j->>'DonusumTuru','')::int, 0);
    v_hbt       int := COALESCE(NULLIF(j->>'HedefBaslikTur','')::int, 0);
    v_hu        int := COALESCE(NULLIF(j->>'HedefUretim','')::int, 0);
    v_enboy     int := COALESCE(NULLIF(j->>'EnBoy','')::int, 0);
    v_tbas      timestamp := NULLIF(j->>'TarihBas','')::timestamp;
    v_tbit      timestamp := NULLIF(j->>'TarihBit','')::timestamp;
    v_rehid     int := COALESCE(NULLIF(j->>'RehID','')::int, 0);
    v_belgeno   text := NULLIF(j->>'BelgeNo','');
    v_stokkod   text := NULLIF(j->>'StokKod','');
    v_urunno    text := NULLIF(j->>'UrunNo','');
    v_stokad    text := NULLIF(j->>'StokAd','');
    v_barkod    text := NULLIF(j->>'Barkod','');
    v_kalmayan  int := COALESCE(NULLIF(j->>'KalmayanGoster','')::int, 0);
    v_gizlenen  int := COALESCE(NULLIF(j->>'GizlenenGoster','')::int, 0);
    v_izlemetur int := COALESCE(NULLIF(j->>'IzlemeTur','')::int, 0);
    v_serino    text := NULLIF(j->>'Serino','');
    v_skt       timestamp := NULLIF(j->>'SktTarih','')::timestamp;
    v_karekod   text := NULLIF(j->>'Karekod','');
    v_boyut     text := NULLIF(j->>'BoyutPattern','');
    stokf text := '
      AND ($9  IS NULL OR st.kod    ILIKE ''%''||$9||''%'')
      AND ($10 IS NULL OR st.urunno  ILIKE ''%''||$10||''%'')
      AND ($11 IS NULL OR st.stokadi ILIKE ''%''||$11||''%'')
      AND ($12 IS NULL OR st.id IN (SELECT stokid FROM stokbarkod WHERE barkod ILIKE ''%''||$12||''%''))';
    izl text := '
      AND ($15=0 OR st.izleme=$15)
      AND ($16 IS NULL OR EXISTS(SELECT 1 FROM stokizleme si JOIN stokserilot ssl ON ssl.id=si.serilotid WHERE si.satirid=<D>.id AND si.belgetur=$1 AND ssl.serino ILIKE ''%''||$16||''%''))
      AND ($17 IS NULL OR EXISTS(SELECT 1 FROM stokizleme si JOIN stokserilot ssl ON ssl.id=si.serilotid WHERE si.satirid=<D>.id AND si.belgetur=$1 AND ssl.skt=$17))
      AND ($18 IS NULL OR EXISTS(SELECT 1 FROM stokizleme si JOIN stokserilot ssl ON ssl.id=si.serilotid WHERE si.satirid=<D>.id AND si.belgetur=$1 AND ssl.serino ILIKE ''%''||$18||''%''))
      AND ($19 IS NULL OR EXISTS(SELECT 1 FROM stokizleme si JOIN stokserilot ssl ON ssl.id=si.serilotid WHERE si.satirid=<D>.id AND si.belgetur=$1 AND ssl.serino ILIKE $19))';
    enboy_sd text := CASE WHEN v_enboy=1 THEN 'sd.en::numeric, sd.boy::numeric, sd.yuzey::numeric, sd.sayi::numeric' ELSE 'NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric' END;
    enboy_f  text := CASE WHEN v_enboy=1 THEN 'f.en::numeric, f.boy::numeric, f.yuzey::numeric, f.sayi::numeric'   ELSE 'NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric' END;
    q text;
BEGIN
    IF v_kaynak = 1 THEN
        q := format($q$
        SELECT s.id::int, sd.id::int, st.id::int, r.id::int, r.firma::text, s.tarih::timestamp, s.teklifno::text, st.kod::text, st.stokadi::text, st.anabirim::text,
            sd.aciklama::text, st.izleme::int, st.ozelkod::text, st.ozelkod2::text, st.muhkodu::text, sd.kdv::numeric, sd.kur::text, sd.doviz_kuru::text,
            sd.adet::numeric, sd.miktar::numeric, sd.birim::text, sd.birimfiyat::numeric, sd.iskonto::numeric, sd.iskonto2::numeric, sd.tutar::numeric, sd.doviz_birimfiyat::numeric, sd.dovizkurdegeri::numeric, sd.doviz_tutari::numeric,
            sd.masrafid::int, sd.merkezid::int, sd.kampanyaid::int,
            COALESCE((SELECT SUM(f1.adet) FROM siparisdetay f1 WHERE f1.yeri=428 AND f1.yerid=sd.id),0.0)::numeric,
            0.0::numeric,
            (sd.adet-COALESCE((SELECT SUM(f1.adet) FROM siparisdetay f1 WHERE f1.yeri=$2 AND f1.yerid=sd.id),0.0)
                    -COALESCE((SELECT SUM(f1.adet) FROM siparisdetay f1 WHERE f1.yeri=416 AND f1.yerid=sd.id),0.0))::numeric,
            sd.teslimtarihi::timestamp, NULL::int, NULL::text, s.hazirlayan::text, NULL::text,
            sd.projeid::int, sd.pozno::text, st.urunno::text, NULL::text,
            (SELECT p.projekodu FROM projeler p WHERE p.id=sd.projeid LIMIT 1)::text,
            (CASE WHEN EXISTS(SELECT 1 FROM donusumbilgisigizle WHERE kaynaktur=99 AND hedeftur=$3 AND kaynakid=sd.id) THEN 1 ELSE 0 END)::int,
            sd.ozelkod::text, sd.ozelkod2::text, s.ozelkod::text, NULL::text,
            %s
        FROM teklif s
            INNER JOIN teklifdetay sd ON s.id=sd.teklifid
            INNER JOIN stoklar st ON sd.tur=1 AND sd.urunid=st.id
            INNER JOIN rehber r ON r.id=s.rehberid
        WHERE s.tarih >= $5 AND s.tarih <= $6
          AND ($7=0 OR $3=9 OR r.id=$7)
          AND ($8 IS NULL OR s.teklifno ILIKE '%%'||$8||'%%')
          %s
          AND ($13=1 OR sd.adet > COALESCE((SELECT SUM(f1.adet) FROM siparisdetay f1 WHERE f1.yeri=$2 AND f1.yerid=sd.id),0.0))
          AND ($14=1 OR NOT EXISTS(SELECT 1 FROM donusumbilgisigizle WHERE kaynaktur=99 AND hedeftur=$3 AND kaynakid=sd.id))
        $q$, enboy_sd, stokf);
        RETURN QUERY EXECUTE q USING v_cbtur,v_dt,v_hbt,v_hu,v_tbas,v_tbit,v_rehid,v_belgeno,v_stokkod,v_urunno,v_stokad,v_barkod,v_kalmayan,v_gizlenen;
        RETURN;
    END IF;

    IF v_kaynak = 2 THEN
        q := format($q$
        SELECT s.id::int, sd.id::int, st.id::int, r.id::int, r.firma::text, s.siparistarih::timestamp, s.siparisno::text, st.kod::text, st.stokadi::text, st.anabirim::text,
            sd.aciklama::text, st.izleme::int, st.ozelkod::text, st.ozelkod2::text, st.muhkodu::text, sd.kdv::numeric, sd.kur::text, sd.doviz_kuru::text,
            sd.adet::numeric, sd.miktar::numeric, sd.birim::text, sd.birimfiyat::numeric, sd.iskonto::numeric, sd.iskonto2::numeric, sd.tutar::numeric, sd.doviz_birimfiyat::numeric, sd.dovizkurdegeri::numeric, sd.doviz_tutari::numeric,
            sd.masrafid::int, sd.merkezid::int, sd.kampanyaid::int,
            (COALESCE((SELECT SUM(f1.adet) FROM siparisdetay f1 WHERE f1.yeri=$2 AND f1.yerid=sd.id),0.0)
              + CASE WHEN $4=1 THEN COALESCE((SELECT SUM(f1.adet) FROM uretimemridetay f1 WHERE f1.urunid=sd.urunid AND f1.yeri=$2 AND f1.yerid=sd.id),0.0)
                     ELSE COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE f1.urunid=sd.urunid AND f1.yeri=$2 AND f1.yerid=sd.id),0.0) END)::numeric,
            0.0::numeric,
            (sd.adet-(abs(COALESCE((SELECT SUM(f1.adet) FROM siparisdetay f1 WHERE f1.yeri=$2 AND f1.yerid=sd.id),0.0))
              + abs(CASE WHEN $4=1 THEN COALESCE((SELECT SUM(f1.adet) FROM uretimemridetay f1 WHERE f1.urunid=sd.urunid AND f1.yeri=$2 AND f1.yerid=sd.id),0.0)
                         ELSE COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE f1.urunid=sd.urunid AND f1.yeri=$2 AND f1.yerid=sd.id),0.0) END)))::numeric,
            sd.teslimtarihi::timestamp, s.rehberiletid::int, (SELECT ad FROM rehberiletisim WHERE id=s.rehberiletid LIMIT 1)::text, s.saticikodu::text,
            (SELECT depoadi FROM depolar WHERE id=CASE WHEN s.tur=19 THEN s.cikisdepo ELSE s.girisdepo END LIMIT 1)::text,
            sd.projeid::int, sd.pozno::text, st.urunno::text, s.detaybolumu::text,
            (SELECT p.projekodu FROM projeler p WHERE p.id=sd.projeid LIMIT 1)::text,
            (CASE WHEN EXISTS(SELECT 1 FROM donusumbilgisigizle WHERE kaynaktur=s.tur AND hedeftur=$3 AND kaynakid=sd.id) THEN 1 ELSE 0 END)::int,
            sd.ozelkod::text, sd.ozelkod2::text, s.ozelkod::text, s.ozelkod2::text,
            %s
        FROM siparis s
            INNER JOIN siparisdetay sd ON s.id=sd.siparisid
            INNER JOIN stoklar st ON sd.tur=1 AND sd.urunid=st.id
            INNER JOIN rehber r ON r.id=s.rehberid
        WHERE s.siparistarih >= $5 AND s.siparistarih <= $6
          AND ($7=0 OR $1=101 OR r.id=$7)
          AND s.tur=$1
          AND ($8 IS NULL OR s.siparisno ILIKE '%%'||$8||'%%')
          %s
          AND ($13=1 OR sd.adet > abs(COALESCE((SELECT SUM(s1.adet) FROM siparisdetay s1 WHERE s1.yeri=$2 AND s1.yerid=sd.id),0.0))
                       + abs(CASE WHEN $3=66 THEN COALESCE((SELECT SUM(f1.adet) FROM uretimemridetay f1 WHERE f1.yeri=$2 AND f1.yerid=sd.id),0.0)
                                  ELSE COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE f1.yeri=$2 AND f1.yerid=sd.id),0.0) END))
          AND ($14=1 OR NOT EXISTS(SELECT 1 FROM donusumbilgisigizle WHERE kaynaktur=s.tur AND hedeftur=$3 AND kaynakid=sd.id))
          %s
        $q$, enboy_sd, stokf, replace(izl,'<D>','sd'));
        RETURN QUERY EXECUTE q USING v_cbtur,v_dt,v_hbt,v_hu,v_tbas,v_tbit,v_rehid,v_belgeno,v_stokkod,v_urunno,v_stokad,v_barkod,v_kalmayan,v_gizlenen,v_izlemetur,v_serino,v_skt,v_karekod,v_boyut;
        RETURN;
    END IF;

    IF v_kaynak = 3 THEN
        q := format($q$
        SELECT fb.id::int, f.id::int, st.id::int, r.id::int, r.firma::text, fb.faturatarih::timestamp, fb.faturano::text, st.kod::text, st.stokadi::text, st.anabirim::text,
            f.aciklama::text, st.izleme::int, st.ozelkod::text, st.ozelkod2::text, st.muhkodu::text, f.kdv::numeric, f.kur::text, f.doviz_kuru::text,
            f.adet::numeric, f.miktar::numeric, f.birim::text, f.birimfiyat::numeric, f.iskonto::numeric, f.iskonto2::numeric, f.tutar::numeric, f.doviz_birimfiyat::numeric, f.dovizkurdegeri::numeric, f.doviz_tutari::numeric,
            f.masrafid::int, f.merkezid::int, f.kampanyaid::int,
            COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE (f1.yeri=$2 OR ($2=411 AND f1.yeri=424)) AND f1.yerid=f.id),0.0)::numeric,
            COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE f1.yeri=416 AND f1.yerid=f.id),0.0)::numeric,
            (f.adet-COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE (f1.yeri=$2 OR ($2=411 AND f1.yeri=424)) AND f1.yerid=f.id),0.0)
                   -COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE f1.yeri=416 AND f1.yerid=f.id),0.0))::numeric,
            fb.faturatarih::timestamp, NULL::int, NULL::text, fb.saticikodu::text,
            (SELECT depoadi FROM depolar WHERE id=CASE WHEN fb.tur IN (10,11,12,119) THEN fb.girisdepo ELSE fb.cikisdepo END LIMIT 1)::text,
            f.projeid::int, f.pozno::text, st.urunno::text, fb.detaybolumu::text,
            (SELECT p.projekodu FROM projeler p WHERE p.id=f.projeid LIMIT 1)::text,
            (CASE WHEN EXISTS(SELECT 1 FROM donusumbilgisigizle WHERE kaynaktur=fb.tur AND hedeftur=$3 AND kaynakid=f.id) THEN 1 ELSE 0 END)::int,
            f.ozelkod::text, f.ozelkod2::text, fb.ozelkod::text, fb.ozelkod2::text,
            %s
        FROM fatbaslik fb
            INNER JOIN fatura f ON fb.id=f.fatbasid
            INNER JOIN stoklar st ON f.tur=1 AND f.urunid=st.id
            INNER JOIN rehber r ON r.id=fb.rehberid
        WHERE fb.faturatarih >= $5 AND fb.faturatarih <= $6
          AND ($7=0 OR r.id=$7)
          AND fb.tur=$1
          AND ($8 IS NULL OR fb.faturano ILIKE '%%'||$8||'%%')
          %s
          AND ($13=1 OR f.adet > COALESCE((SELECT SUM(f1.adet) FROM fatura f1 WHERE (f1.yeri=$2 OR ($2=411 AND f1.yeri=424)) AND f1.yerid=f.id),0.0))
          AND ($14=1 OR NOT EXISTS(SELECT 1 FROM donusumbilgisigizle WHERE kaynaktur=fb.tur AND hedeftur=$3 AND kaynakid=f.id))
          %s
        $q$, enboy_f, stokf, replace(izl,'<D>','f'));
        RETURN QUERY EXECUTE q USING v_cbtur,v_dt,v_hbt,v_hu,v_tbas,v_tbit,v_rehid,v_belgeno,v_stokkod,v_urunno,v_stokad,v_barkod,v_kalmayan,v_gizlenen,v_izlemetur,v_serino,v_skt,v_karekod,v_boyut;
        RETURN;
    END IF;
END $$;
