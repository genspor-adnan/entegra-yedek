-- ============================================================================
--  Konsolide GenUpdate 66-169 — PostgreSQL portu
--  02_Belge_Donusum_PG.sql  (MSSQL karsiligi: 02_Belge_Donusum.sql, Update128/124)
--
--  Bu dosya, UYGULAMANIN DOGRUDAN "exec ... :Tablo, :Id" ile cagirdigi uc
--  donusum yordamini PG'de AYNI IMZA ve AYNI KOLON KUMESI ile tanimlar.
--  Onceki uyumluluk katmaninda (pg/schema/120) bunlar tek "kosullar text"
--  parametreli, JSON metni donduren kabuklara baglanmisti; PgExecCevir
--  'exec sp_X :a, :b' -> 'select * from fn_x(:a, :b)' urettigi icin cagri
--    ERROR: function ... does not exist
--  ile patliyordu. Kabuk surumler (1 parametreli) yerinde birakildi.
--
--  Kolon adlari BUYUK harfle degil: uygulama FieldByName('TUR') diyor,
--  FireDAC alan adini buyuk/kucuk fark etmeden bulur.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------- HEDEF ----
-- Bu belgenin satirlarindan URETILMIS belgeler.
CREATE OR REPLACE FUNCTION public.fn_prog_donusum_hedefbelge(
    p_belgetablo text,
    p_belgeid    integer)
RETURNS TABLE(tur integer, belgeid integer, belgeno text, rehberid integer,
              firma text, tarih timestamp, donusumturu integer, aciklama text)
LANGUAGE sql STABLE AS $$
WITH kaynak AS (
    SELECT f.id AS satirid, 'FATURA'::text AS detaytablo
      FROM fatura f
     WHERE upper(p_belgetablo) = 'FATBASLIK' AND f.fatbasid = p_belgeid
    UNION ALL
    SELECT sd.id, 'SIPARISDETAY'
      FROM siparisdetay sd
     WHERE upper(p_belgetablo) = 'SIPARIS' AND sd.siparisid = p_belgeid
    UNION ALL
    SELECT td.id, 'TEKLIFDETAY'
      FROM teklifdetay td
     WHERE upper(p_belgetablo) = 'TEKLIF' AND td.teklifid = p_belgeid
)
SELECT DISTINCT x.tur, x.belgeid, x.belgeno, x.rehberid,
       r.firma::text, x.tarih, x.donusumturu, x.aciklama
  FROM (
        -- 1) Hedefi FATURA olan rotalar
        SELECT fb.tur::int AS tur, fb.id AS belgeid, fb.faturano::text AS belgeno,
               fb.rehberid, fb.faturatarih::timestamp AS tarih,
               r.donusumturu, r.aciklama::text AS aciklama
          FROM kaynak k
          JOIN public.fn_prog_belgedonusum_rota() r
            ON r.kaynakdetaytablo = k.detaytablo AND r.kalanhedeftablo = 'FATURA'
          JOIN fatura f     ON f.yeri = r.donusumturu AND f.yerid = k.satirid
          JOIN fatbaslik fb ON fb.id = f.fatbasid

        UNION ALL
        -- 2) Hedefi SIPARISDETAY olan rotalar (talep->siparis, teklif->siparis)
        SELECT s.tur::int, s.id, s.siparisno::text,
               s.rehberid, s.siparistarih::timestamp,
               r.donusumturu, r.aciklama::text
          FROM kaynak k
          JOIN public.fn_prog_belgedonusum_rota() r
            ON r.kaynakdetaytablo = k.detaytablo AND r.kalanhedeftablo = 'SIPARISDETAY'
          JOIN siparisdetay sd ON sd.yeri = r.donusumturu AND sd.yerid = k.satirid
          JOIN siparis s       ON s.id = sd.siparisid

        UNION ALL
        -- 3) BASLIK DUZEYI bag (transfer -> uretim fisi)
        SELECT fb2.tur::int, fb2.id, fb2.faturano::text,
               fb2.rehberid, fb2.faturatarih::timestamp,
               fb2.yeri::int, 'Baslik bagi (transfer/uretim)'::text
          FROM fatbaslik fb2
         WHERE upper(p_belgetablo) = 'FATBASLIK'
           AND fb2.yerid = p_belgeid
           AND COALESCE(fb2.yeri, 0) > 0
       ) x
  LEFT JOIN rehber r ON r.id = x.rehberid
 ORDER BY x.tarih, x.belgeid;
$$;

-- --------------------------------------------------------------- KAYNAK ----
-- Bu belgenin satirlari YERI/YERID ile hangi belgeye baglaniyor.
-- Eski (baslik text, kosullar text) kabugu KALDIRILIYOR: hicbir cagiran yok ve
--   (text, integer) surumuyle asiri-yukleme belirsizligi yaratiyordu.
DROP FUNCTION IF EXISTS public.fn_prog_donusum_kaynakbelge(text, text);

CREATE OR REPLACE FUNCTION public.fn_prog_donusum_kaynakbelge(
    p_belgetablo text,
    p_belgeid    integer)
RETURNS TABLE(tur integer, belgeid integer, belgeno text, rehberid integer,
              firma text, tarih timestamp, donusumturu integer, aciklama text)
LANGUAGE sql STABLE AS $$
WITH hedef AS (
    SELECT f.id AS satirid, f.yeri, f.yerid, 'FATURA'::text AS detaytablo
      FROM fatura f
     WHERE upper(p_belgetablo) = 'FATBASLIK' AND f.fatbasid = p_belgeid
       AND COALESCE(f.yeri, 0) > 0 AND COALESCE(f.yerid, 0) > 0
    UNION ALL
    SELECT sd.id, sd.yeri, sd.yerid, 'SIPARISDETAY'
      FROM siparisdetay sd
     WHERE upper(p_belgetablo) = 'SIPARIS' AND sd.siparisid = p_belgeid
       AND COALESCE(sd.yeri, 0) > 0 AND COALESCE(sd.yerid, 0) > 0
)
SELECT DISTINCT x.tur, x.belgeid, x.belgeno, x.rehberid,
       r.firma::text, x.tarih, x.donusumturu, x.aciklama
  FROM (
        -- 1) Kaynagi SIPARIS olan rotalar
        SELECT s.tur::int AS tur, s.id AS belgeid, s.siparisno::text AS belgeno,
               s.rehberid, s.siparistarih::timestamp AS tarih,
               r.donusumturu, r.aciklama::text AS aciklama
          FROM hedef h
          JOIN public.fn_prog_belgedonusum_rota() r
            ON r.donusumturu = h.yeri AND r.kaynakdetaytablo = 'SIPARISDETAY'
          JOIN siparisdetay sd ON sd.id = h.yerid
          JOIN siparis s       ON s.id = sd.siparisid

        UNION ALL
        -- 2) Kaynagi FATURA (irsaliye/fatura/fis/konsinye/transfer/uretim)
        SELECT fb.tur::int, fb.id, fb.faturano::text,
               fb.rehberid, fb.faturatarih::timestamp,
               r.donusumturu, r.aciklama::text
          FROM hedef h
          JOIN public.fn_prog_belgedonusum_rota() r
            ON r.donusumturu = h.yeri AND r.kaynakdetaytablo = 'FATURA'
          JOIN fatura f     ON f.id = h.yerid
          JOIN fatbaslik fb ON fb.id = f.fatbasid

        UNION ALL
        -- 3) Kaynagi TEKLIF olan rotalar (412/413). Teklif karti ayri ekran -> TUR=80
        SELECT 80, t.id, t.teklifno::text,
               t.rehberid, t.eklemetarihi::timestamp,
               r.donusumturu, r.aciklama::text
          FROM hedef h
          JOIN public.fn_prog_belgedonusum_rota() r
            ON r.donusumturu = h.yeri AND r.kaynakdetaytablo = 'TEKLIFDETAY'
          JOIN teklifdetay td ON td.id = h.yerid
          JOIN teklif t       ON t.id = td.teklifid

        UNION ALL
        -- 3b) BASLIK DUZEYI bag (FATBASLIK.YERI/YERID)
        SELECT fb2.tur::int, fb2.id, fb2.faturano::text,
               fb2.rehberid, fb2.faturatarih::timestamp,
               fb1.yeri::int, 'Baslik bagi (transfer/uretim)'::text
          FROM fatbaslik fb1
          JOIN fatbaslik fb2 ON fb2.id = fb1.yerid
         WHERE upper(p_belgetablo) = 'FATBASLIK' AND fb1.id = p_belgeid
           AND COALESCE(fb1.yeri, 0) > 0 AND COALESCE(fb1.yerid, 0) > 0

        UNION ALL
        -- 4) SERVIS kaynakli baglanti (rota matrisinde YOK, YERI=83 sabit)
        SELECT 83, sv.id, sv.servisno::text,
               sv.rehberid, sv.baslamatarihi::timestamp,
               83, 'Servis -> belge'::text
          FROM hedef h
          JOIN servisdetay sd2 ON sd2.id = h.yerid AND h.yeri = 83
          JOIN servis sv       ON sv.id = sd2.servisid
       ) x
  LEFT JOIN rehber r ON r.id = x.rehberid
 ORDER BY x.tarih, x.belgeid;
$$;

-- ------------------------------------------------- SATIR ADET KONTROLU ----
-- Kaynak satirin adedi, zaten donusmus adedin altina dusurulemez.
-- UYGUN integer doner (bit degil): FireDAC bit'i Boolean'a mapleyip
--   AsInteger okunusunda hata veriyordu.
CREATE OR REPLACE FUNCTION public.fn_prog_donusum_satiradetkontrol(
    p_kaynakdetaytablo text,
    p_satirid          integer,
    p_yeniadet         numeric DEFAULT NULL)
RETURNS TABLE(donusenadet numeric, uygun integer, mesaj text,
              belgead text, belgeno text, belgetarih timestamp)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_donusen numeric;
  v_ad      text;
  v_no      text;
  v_tarih   timestamp;
  v_uygun   integer := 1;
  v_mesaj   text    := '';
BEGIN
  v_donusen := COALESCE(public.fn_prog_donusum_donusenadet(p_kaynakdetaytablo, p_satirid), 0);

  -- Ilk hedef belge (mesajda ornek olarak gosterilir).
  SELECT x.belgead, x.belgeno, x.belgetarih
    INTO v_ad, v_no, v_tarih
  FROM (
        SELECT (SELECT i.ad::text FROM islemturleri i WHERE i.tur = fb.tur LIMIT 1) AS belgead,
               fb.faturano::text     AS belgeno,
               fb.faturatarih::timestamp AS belgetarih
          FROM fatura f
          JOIN public.fn_prog_belgedonusum_rota() r
            ON r.donusumturu = f.yeri
           AND r.kaynakdetaytablo = p_kaynakdetaytablo
           AND r.kalanhedeftablo = 'FATURA'
          JOIN fatbaslik fb ON fb.id = f.fatbasid
         WHERE f.yerid = p_satirid
        UNION ALL
        SELECT (SELECT i.ad::text FROM islemturleri i WHERE i.tur = s.tur LIMIT 1),
               s.siparisno::text,
               s.siparistarih::timestamp
          FROM siparisdetay sd
          JOIN public.fn_prog_belgedonusum_rota() r
            ON r.donusumturu = sd.yeri
           AND r.kaynakdetaytablo = p_kaynakdetaytablo
           AND r.kalanhedeftablo = 'SIPARISDETAY'
          JOIN siparis s ON s.id = sd.siparisid
         WHERE sd.yerid = p_satirid
       ) x
  ORDER BY x.belgetarih
  LIMIT 1;

  IF p_yeniadet IS NOT NULL AND v_donusen > 0 AND p_yeniadet < v_donusen THEN
    v_uygun := 0;
    v_mesaj := 'Bu satırın ' || trim(to_char(round(v_donusen, 2), 'FM999999999990.00')) ||
               ' adedi zaten dönüştürülmüş' ||
               CASE WHEN v_ad IS NULL THEN ''
                    ELSE ' (' || v_ad || ' ' || COALESCE(v_no, '') || ')' END ||
               '. Adet bu değerin altına düşürülemez.';
  END IF;

  RETURN QUERY SELECT v_donusen, v_uygun, v_mesaj, v_ad, v_no, v_tarih;
END;
$$;
