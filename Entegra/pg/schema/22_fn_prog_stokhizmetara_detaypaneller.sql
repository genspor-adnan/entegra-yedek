-- ============================================================
-- fn_prog_stokhizmetara_detaypaneller — MSSQL sp_Prog_StokHizmetAra_DetayPaneller PG portu
-- ------------------------------------------------------------
-- StokHizmetAra alt DETAY panelleri (secili stok/hizmete gore). Tek SP, @Panel ile 6 farkli
-- sonuc-shape'i doner. PG fn tek RETURNS TABLE -> tum panellerin kolonlarinin SUPERSET'i;
-- her panel kendi kolonlarini doldurur, ilgisizler NULL. Grid'ler dynamic (persistent field yok)
-- -> her panel grid'i kendi kolonlarini isimle baglar, fazlalar yok sayilir.
-- Cagri (PgExecCevir positional): fn(@Panel, @StokID, @Tur/@DepoID, @RehberID). Param adlari
--   p_panel/p_stokid/p_a/p_b (kolon ismiyle cakismasin); a=Tur (P2/3/6) veya DepoID (P1), b=RehberID.
-- Paneller: 1=DepoDurumu(fn_StokDurumDetay - AYRI PORT, simdilik bos), 2=SonAlis(FB.TUR 11/12),
--   3=SonSatis(15/16), 4=Maliyet(STOKFIYAT), 5=Uretim(receteler), 6=Teklif.
-- MSSQL->PG: TOP 10->LIMIT 10, TUTAR/MIKTAR div NULLIF ile korunur, GENINI TOP1->LIMIT1,
--   bit yok. 'Fiş' UTF-8. tur superset'te varchar (P2/3 FB.TUR::varchar, P4 GENINI metni).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_stokhizmetara_detaypaneller(int, int, int, int);
CREATE FUNCTION public.fn_prog_stokhizmetara_detaypaneller(
    p_panel int, p_stokid int, p_a int DEFAULT 0, p_b int DEFAULT 0)
RETURNS TABLE(
    faturatarih timestamp, tarih timestamp, belgetipi varchar, baslik varchar,
    birimtutar numeric, kur varchar, birimtutardoviz numeric, doviz_kuru varchar,
    miktar numeric, tur varchar, id integer, fiyatadi integer, maliyet numeric,
    kdvdurum integer, kod varchar, stokadi varchar, kalan numeric
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF p_panel = 2 OR p_panel = 3 THEN
        -- Son Alislar (11/12) / Son Satislar (15/16); a=Tur, b=RehberID
        RETURN QUERY
        SELECT fb.faturatarih::timestamp, fb.tarih::timestamp,
               (CASE WHEN fb.tur IN (12,16) THEN 'Fiş' ELSE 'Fatura' END)::varchar,
               r.firma::varchar, (f.tutar/NULLIF(f.miktar,0))::numeric, f.kur::varchar,
               (f.doviz_tutari/NULLIF(f.miktar,0))::numeric, f.doviz_kuru::varchar,
               f.miktar::numeric, fb.tur::varchar, fb.id::integer,
               NULL::integer, NULL::numeric, NULL::integer, NULL::varchar, NULL::varchar, NULL::numeric
        FROM fatbaslik fb
        JOIN fatura f ON fb.id=f.fatbasid
        JOIN rehber r ON r.id=fb.rehberid
        WHERE ((p_panel=2 AND fb.tur IN (11,12)) OR (p_panel=3 AND fb.tur IN (15,16)))
          AND f.tur=p_a AND f.miktar>0 AND f.urunid=p_stokid
          AND (p_b=0 OR fb.rehberid=p_b)
        ORDER BY fb.faturatarih DESC
        LIMIT 10;

    ELSIF p_panel = 4 THEN
        -- Maliyetler (STOKFIYAT, SATIS=0, FIYATADI<0)
        RETURN QUERY
        SELECT DISTINCT NULL::timestamp, NULL::timestamp, NULL::varchar, NULL::varchar,
               NULL::numeric, sf.kur::varchar, NULL::numeric, NULL::varchar, NULL::numeric,
               (SELECT (CASE WHEN g.deger=-2 THEN g.anahtar||' (Son'||sf.paketid::text||')' ELSE g.anahtar END)
                  FROM genini g WHERE g.bolum=-1008 AND g.deger=sf.fiyatadi LIMIT 1)::varchar,
               sf.stokid::integer, sf.fiyatadi::integer, sf.fiyat::numeric, sf.kdvdurum::integer,
               NULL::varchar, NULL::varchar, NULL::numeric
        FROM stokfiyat sf
        WHERE sf.stokid=p_stokid AND sf.satis=0 AND sf.fiyatadi<0;

    ELSIF p_panel = 5 THEN
        -- Uretim (bu urunu tuketen receteler)
        RETURN QUERY
        SELECT NULL::timestamp, NULL::timestamp, NULL::varchar, NULL::varchar, NULL::numeric,
               NULL::varchar, NULL::numeric, NULL::varchar, urd.miktar::numeric, NULL::varchar,
               NULL::integer, NULL::integer, NULL::numeric, NULL::integer,
               s.kod::varchar, s.stokadi::varchar, SUM(sd.kalan)::numeric
        FROM uretimrecete ur
        JOIN uretimrecetedetay urd ON ur.id=urd.uretimreceteid
        JOIN stoklar s ON s.id=urd.urunid
        JOIN stokdurum sd ON s.id=sd.stokid
        WHERE urd.miktar<0.0 AND ur.stokid=p_stokid
        GROUP BY s.kod, s.stokadi, urd.miktar;

    ELSIF p_panel = 6 THEN
        -- Son Teklifler; a=Tur, b=RehberID
        RETURN QUERY
        SELECT NULL::timestamp, fb.tarih::timestamp, NULL::varchar,
               (SELECT r.firma FROM rehber r WHERE r.id=fb.rehberid)::varchar,
               (f.tutar/NULLIF(f.miktar,0))::numeric, f.kur::varchar,
               (f.doviz_tutari/NULLIF(f.miktar,0))::numeric, f.doviz_kuru::varchar,
               f.miktar::numeric, NULL::varchar, fb.id::integer,
               NULL::integer, NULL::numeric, NULL::integer, NULL::varchar, NULL::varchar, NULL::numeric
        FROM teklif fb
        JOIN teklifdetay f ON fb.id=f.teklifid
        WHERE f.tur=p_a AND f.miktar>0 AND f.urunid=p_stokid
          AND (p_b=0 OR fb.rehberid=p_b)
        ORDER BY fb.tarih DESC
        LIMIT 10;

    END IF;
    -- p_panel=1 (Depo Durumu): fn_StokDurumDetay AYRI PORT bekliyor -> simdilik satir donmez.
    RETURN;
END $$;
