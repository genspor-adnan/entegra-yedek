-- ============================================================
-- fn_prog_fattransfer_liste_json2 — MSSQL sp_Prog_FatTransfer_Liste_Json2 PG portu
--   Fatura Transfer liste (FB.TUR=20). PK=FATBASLIK.ID. Son/Sik: KULLANICI_ARAMA (MODUL=2711).
--   @Baslik (EkAlanlar) YOK SAYILIR (dokuman/pdks/stok deseni; sabit RETURNS TABLE'a ek-kolon eklenemez).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join, opsiyonel FATURA/STOKLAR join (Stok/Kod),
--     WHERE (tarih araligi her zaman + TeslimEden/TeslimAlan/TransferNo/OzelKod/UretimEmir/Stok/Kod), ORDER.
--   MSSQL->PG: JSON_VALUE->->>+NULLIF, ISNULL/TRY_CAST->COALESCE/NULLIF::cast, bit->smallint,
--     LIKE(CI)->ILIKE+quote_literal('%'||v||'%'), int filtre inline (SP-birebir), CAST(DATE)->date_trunc.
--   Tarih varsayilanlari: BasTrh yoksa bugun 00:00; BitTrh yoksa bugun 23:59:59 (MSSQL ile ayni).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_fattransfer_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_fattransfer_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, faturatarih timestamp, faturano varchar, tur smallint, subeid smallint,
    detaybolumu varchar, cikisdepo smallint, girisdepo smallint, girissube smallint,
    girisdeposu text, cikisdeposu text, teslimalan text, teslimeden text,
    ozelkod varchar, yetkikodu varchar, aciklama varchar, kaynak text
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_mod        int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_bastrh     timestamp := NULLIF(j->>'BasTrh','')::timestamp;
    v_bittrh     timestamp := NULLIF(j->>'BitTrh','')::timestamp;
    v_teslimeden int  := NULLIF(j->>'TeslimEden','')::int;
    v_teslimalan int  := NULLIF(j->>'TeslimAlan','')::int;
    v_transferno text := NULLIF(j->>'TransferNo','');
    v_ozelkod    text := NULLIF(j->>'OzelKod','');
    v_uretimemir text := NULLIF(j->>'UretimEmirNo','');
    v_stok       text := NULLIF(j->>'Stok','');
    v_kod        text := NULLIF(j->>'Kod','');
    v_kulid      int  := NULLIF(j->>'KulId','')::int;
    v_modul      int  := NULLIF(j->>'Modul','')::int;
    v_orderby    text := NULLIF(j->>'OrderBy','');
    v_bas timestamp;
    v_bit timestamp;
    q text; joinstok text := ''; joinka text := ''; w text; ordr text;
BEGIN
    -- Tarih varsayilanlari (MSSQL: bugun 00:00 .. bugun 23:59:59)
    v_bas := COALESCE(v_bastrh, date_trunc('day', now())::timestamp);
    v_bit := COALESCE(v_bittrh, date_trunc('day', now())::timestamp + interval '1 day' - interval '1 second');

    -- Stok/Kod filtresi FATURA + STOKLAR join'i tetikler (orijinal SQLMemo.Add ile ayni)
    IF v_stok IS NOT NULL OR v_kod IS NOT NULL THEN
        joinstok := ' INNER JOIN fatura ft ON ft.fatbasid=fb.id LEFT OUTER JOIN stoklar s ON ft.urunid=s.id ';
    END IF;

    -- @Mod=3(Sik)/5(Son): KULLANICI_ARAMA 1:1 join (KAYITID=FB.ID)
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=fb.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- WHERE: FB.TUR=20 + tarih araligi her zaman
    w := ' WHERE fb.tur=20 AND fb.faturatarih>='||quote_literal(v_bas)||' AND fb.faturatarih<='||quote_literal(v_bit)||' ';
    IF v_teslimeden IS NOT NULL THEN w := w || ' AND fb.saticikodu='||v_teslimeden||' '; END IF;   -- Teslim Eden
    IF v_teslimalan IS NOT NULL THEN w := w || ' AND fb.rehberid='||v_teslimalan||' '; END IF;      -- Teslim Alan
    IF v_transferno IS NOT NULL THEN w := w || ' AND fb.faturano ILIKE '||quote_literal('%'||v_transferno||'%')||' '; END IF;
    IF v_ozelkod    IS NOT NULL THEN w := w || ' AND fb.ozelkod ILIKE '||quote_literal('%'||v_ozelkod||'%')||' '; END IF;
    IF v_uretimemir IS NOT NULL THEN w := w || ' AND fb.detaybolumu ILIKE '||quote_literal('%'||v_uretimemir||'%')||' '; END IF;  -- Uretim Emir No (FATBASLIK.DETAYBOLUMU)
    IF v_stok       IS NOT NULL THEN w := w || ' AND s.stokadi ILIKE '||quote_literal('%'||v_stok||'%')||' '; END IF;
    IF v_kod        IS NOT NULL THEN w := w || ' AND (s.kod ILIKE '||quote_literal('%'||v_kod||'%')||' OR s.urunno ILIKE '||quote_literal('%'||v_kod||'%')||') '; END IF;

    -- Siralama: Son/Sik -> KA anahtari; degilse orijinal FATURATARIH desc
    IF v_mod = 5 THEN ordr := 'ka.degistirmetarihi DESC';
    ELSIF v_mod = 3 THEN ordr := 'ka.say DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := v_orderby;
    ELSE ordr := 'faturatarih desc'; END IF;

    q := 'SELECT fb.id::integer, fb.faturatarih::timestamp, fb.faturano::varchar, fb.tur::smallint,
             fb.subeid::smallint, fb.detaybolumu::varchar, fb.cikisdepo::smallint, fb.girisdepo::smallint,
             fb.girissube::smallint, giris.depoadi::text AS girisdeposu, cikis.depoadi::text AS cikisdeposu,
             r1.firma::text AS teslimalan, r2.firma::text AS teslimeden,
             fb.ozelkod::varchar, fb.yetkikodu::varchar, fb.aciklama::varchar,
             (CASE WHEN EXISTS(SELECT 1 FROM siparisdetay f2 WHERE f2.id IN
                    (SELECT f1.yerid FROM fatura f1 WHERE f1.yeri=435 AND f1.fatbasid=fb.id)) THEN ''Talepten'' END)::text AS kaynak
          FROM fatbaslik fb
            INNER JOIN depolar giris ON giris.id=fb.girisdepo
            INNER JOIN depolar cikis ON cikis.id=fb.cikisdepo
            LEFT OUTER JOIN rehber r1 ON fb.rehberid=r1.id
            LEFT OUTER JOIN rehber r2 ON fb.saticikodu=r2.id '
         || joinstok || joinka || w || ' ORDER BY ' || ordr;
    RETURN QUERY EXECUTE q;
END $$;
