-- ============================================================
-- fn_prog_log_liste_json2 — MSSQL sp_Prog_Log_Liste_Json2 PG portu
--   Info/Log ekrani (UInfo) Genel listesi. Kolon seti MSSQL SP ile BIREBIR:
--     tarih gun kayitno usttabloid islemtipi islem firma pcadi anahtar kod ad adet
--   baslik (EkAlanlar) YOK SAYILIR (sabit RETURNS TABLE'a ek kolon eklenemez).
--
--   MSSQL -> PG farklari:
--     OUTER APPLY            -> LEFT JOIN LATERAL (...) ON TRUE
--     TOP 1 ... ORDER BY     -> ORDER BY ... LIMIT 1
--     ISNULL                 -> COALESCE
--     CAST(x AS date)        -> x::date
--     COLLATE DATABASE_DEFAULT -> gereksiz (tek DB, tek collation) -> ATILDI
--     DECOMPRESS(BILGI)      -> gereksiz: depo.log<yyyy>.bilgi JSONB -> bilgi::text
--     LIKE (MSSQL CI)        -> ILIKE (PG kolonlari deterministic/CS collation)
--     ISLEMLOG/LOGREFERANS   -> depo.islemlog / depo.logreferans (synonym yok, schema)
--
--   Filtreler dogrudan PARAMETRE (dinamik string kurulmaz) -> plan cache + enjeksiyon yok.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_log_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_log_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    tarih      timestamp,
    gun        date,
    kayitno    bigint,
    usttabloid integer,
    islemtipi  smallint,
    islem      text,
    firma      text,
    pcadi      text,
    anahtar    text,
    kod        text,
    ad         text,
    adet       bigint
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_tarihbas   date := NULLIF(j->>'TarihBas','')::date;
    v_tarihbit   date := NULLIF(j->>'TarihBit','')::date;
    v_kullanici  text := NULLIF(j->>'Kullanici','');
    v_modul      text := NULLIF(j->>'Modul','');
    v_kayitno    text := NULLIF(j->>'KayitNo','');
    v_istasyon   text := NULLIF(j->>'Istasyon','');
    v_ara        text := NULLIF(j->>'Ara','');
    v_icerikara  int  := COALESCE(NULLIF(j->>'IcerikAra','')::int, 0);
    v_ekleme     int  := COALESCE(NULLIF(j->>'Ekleme','')::int, 0);
    v_degistirme int  := COALESCE(NULLIF(j->>'Degistirme','')::int, 0);
    v_silme      int  := COALESCE(NULLIF(j->>'Silme','')::int, 0);
    -- Tarih araligi YALNIZ Kayit No ve Ara bosken uygulanir (MSSQL ile ayni davranis).
    v_tarihuygula boolean := (v_kayitno IS NULL AND v_ara IS NULL);
    v_bas timestamp;
    v_bit timestamp;   -- gun sonu -> ertesi gunun basi (< karsilastirmasi)
    v_tiphepsi boolean := (v_ekleme = 0 AND v_degistirme = 0 AND v_silme = 0);
    v_kullanicil text := '%' || v_kullanici || '%';
    v_kayitnol   text := '%' || v_kayitno   || '%';
    v_istasyonl  text := '%' || v_istasyon  || '%';
    v_aral       text := '%' || v_ara       || '%';
BEGIN
    IF v_tarihuygula THEN
        v_bas := v_tarihbas::timestamp;
        IF v_tarihbit IS NOT NULL THEN v_bit := (v_tarihbit + 1)::timestamp; END IF;
    END IF;

    RETURN QUERY
    SELECT
        MAX(l.tarih)::timestamp                                        AS tarih,
        l.tarih::date                                                  AS gun,
        l.ustkayitid                                                   AS kayitno,
        l.usttabloid                                                   AS usttabloid,
        l.islemtipi                                                    AS islemtipi,
        (CASE l.islemtipi WHEN 0 THEN 'Silme' WHEN 1 THEN 'Ekleme'
                          WHEN 2 THEN 'Değiştirme' ELSE '?' END)::text AS islem,
        MAX(COALESCE(r.firma, l.kullaniciid::text))::text              AS firma,
        MAX(l.istasyon)::text                                          AS pcadi,
        MAX(CASE WHEN l.usttabloid IN (108,109) THEN 'Tahakkuk'
                 ELSE COALESCE(t.modul, t.tabloadi, l.usttabloid::text) END)::text AS anahtar,
        -- Kod/Ad onceligi MSSQL SP ile BIREBIR (kart kendi referansi -> cari/IK -> stok;
        -- cek/senet 315/316/318/319, uretim 144, konsinye 209/219, banka 482/483 -> once CARI).
        MAX(CASE WHEN l.usttabloid = 485 THEN 'Opsiyon'
                 WHEN l.tabloid = l.usttabloid THEN
                   COALESCE(CASE WHEN l.usttabloid IN (315,316,318,319,144,209,219,482,483) THEN NULL
                                 ELSE NULLIF(lrk.kod,'') END,
                            NULLIF(lrc.kod,''), NULLIF(rl.kod,''),
                            CASE WHEN l.usttabloid IN (144,482,483) THEN NULLIF(lrk.kod,'') END,
                            NULLIF(lrs.kod,''), NULLIF(rs.kod,''), NULLIF(lruf.kod,''))
                 WHEN l.usttabloid IN (144,209,219) THEN
                   COALESCE(NULLIF(lrcb.kod,''), NULLIF(rl.kod,''), NULLIF(lruf.kod,''))
                 ELSE
                   COALESCE(CASE WHEN l.usttabloid NOT IN (315,316,318,319,144,209,219,482,483)
                                 THEN NULLIF(lrk.kod,'') END,
                            NULLIF(rl.kod,''), NULLIF(rs.kod,''))
            END)::text AS kod,
        MAX(CASE WHEN l.usttabloid = 485 THEN NULLIF(ays.seksiyon,'')
                 WHEN l.tabloid = l.usttabloid THEN
                   COALESCE(CASE WHEN l.usttabloid IN (315,316,318,319,144,209,219,482,483) THEN NULL
                                 ELSE NULLIF(lrk.ad,'') END,
                            NULLIF(lrc.ad,''), NULLIF(rl.ad,''),
                            CASE WHEN l.usttabloid IN (144,482,483) THEN NULLIF(lrk.ad,'') END,
                            NULLIF(lrs.ad,''), NULLIF(rs.ad,''), NULLIF(lruf.ad,''))
                 WHEN l.usttabloid IN (144,209,219) THEN
                   COALESCE(NULLIF(lrcb.ad,''), NULLIF(rl.ad,''), NULLIF(lruf.ad,''))
                 ELSE
                   COALESCE(CASE WHEN l.usttabloid NOT IN (315,316,318,319,144,209,219,482,483)
                                 THEN NULLIF(lrk.ad,'') END,
                            NULLIF(rl.ad,''), NULLIF(rs.ad,''))
            END)::text AS ad,
        COUNT(*)                                                       AS adet
    FROM depo.islemlog l
        LEFT JOIN rehber   r ON r.id = l.kullaniciid
        LEFT JOIN tablolar t ON t.tabloid = l.usttabloid
        LEFT JOIN LATERAL (SELECT x.ad, x.kod FROM depo.logreferans x
                           WHERE x.kayitid = l.ustkayitid AND x.tabloid = l.usttabloid
                           ORDER BY x.id DESC LIMIT 1) lrk ON TRUE
        LEFT JOIN LATERAL (SELECT x.ad, x.kod FROM depo.logreferans x
                           WHERE x.kayitid = l.rehberid AND x.tabloid IN (71,73,74)
                           ORDER BY x.id DESC LIMIT 1) lrc ON TRUE
        LEFT JOIN LATERAL (SELECT x.ad, x.kod FROM depo.logreferans x
                           WHERE x.kayitid = l.stokid AND x.tabloid = 88
                           ORDER BY x.id DESC LIMIT 1) lrs ON TRUE
        -- CANLI fallback: logreferans cache'te yoksa ad/kod dogrudan rehber/stoklar'dan.
        LEFT JOIN LATERAL (SELECT x.firma AS ad, x.kod FROM rehber x
                           WHERE x.id = l.rehberid AND l.rehberid > 0 LIMIT 1) rl ON TRUE
        LEFT JOIN LATERAL (SELECT x.stokadi AS ad, x.kod FROM stoklar x
                           WHERE x.id = l.stokid AND l.stokid > 0 LIMIT 1) rs ON TRUE
        -- Opsiyon/ayar (485): kayitid = bolum; seksiyon -> ad, kod sabit 'Opsiyon'.
        LEFT JOIN LATERAL (SELECT x.seksiyon, x.ad FROM ayaradi x
                           WHERE x.bolum = l.kayitid AND l.usttabloid = 485 LIMIT 1) ays ON TRUE
        -- Belge (144/209/219): grupta kart satiri yoksa kod/ad belge carisinden.
        LEFT JOIN LATERAL (SELECT x.rehberid FROM fatbaslik x
                           WHERE x.id = l.ustkayitid AND l.usttabloid IN (144,209,219) LIMIT 1) fb ON TRUE
        LEFT JOIN LATERAL (SELECT x.ad, x.kod FROM depo.logreferans x
                           WHERE x.kayitid = fb.rehberid AND x.tabloid IN (71,73,74)
                           ORDER BY x.id DESC LIMIT 1) lrcb ON TRUE
        -- Uretim Fisi (144): uretilen stok = detay (fatura) adet>0 olan urunid.
        LEFT JOIN LATERAL (SELECT s.kod, s.stokadi AS ad
                           FROM fatura f JOIN stoklar s ON s.id = f.urunid
                           WHERE l.usttabloid = 144 AND f.fatbasid = l.ustkayitid AND f.adet > 0
                           ORDER BY f.id LIMIT 1) lruf ON TRUE
    WHERE (v_bas IS NULL OR l.tarih >= v_bas)
      AND (v_bit IS NULL OR l.tarih <  v_bit)
      AND (v_kullanici IS NULL OR COALESCE(r.firma, l.kullaniciid::text) ILIKE v_kullanicil)
      AND (v_modul     IS NULL OR t.modul = v_modul)
      AND (v_kayitno   IS NULL OR l.ustkayitid::text ILIKE v_kayitnol)
      AND (v_istasyon  IS NULL OR l.istasyon ILIKE v_istasyonl)
      AND (v_ara IS NULL
           OR (v_icerikara = 1 AND l.bilgi::text ILIKE v_aral)
           OR (v_icerikara = 0
               AND EXISTS (SELECT 1 FROM depo.logreferans x
                           WHERE ((x.kayitid = l.ustkayitid AND x.tabloid = l.usttabloid)
                               OR (x.kayitid = l.rehberid   AND x.tabloid IN (71,73,74))
                               OR (x.kayitid = l.stokid     AND x.tabloid = 88))
                             AND (x.ad ILIKE v_aral OR x.kod ILIKE v_aral))))
      AND (v_tiphepsi
           OR (v_ekleme = 1 AND l.islemtipi = 1)
           OR (v_degistirme = 1 AND l.islemtipi = 2)
           OR (v_silme = 1 AND l.islemtipi = 0))
    GROUP BY l.tarih::date, l.ustkayitid, l.usttabloid, l.islemtipi
    ORDER BY MAX(l.tarih) DESC;
END $$;
