-- =============================================================================
--  1373  RADYOLOJİ RAPOR TESLİM LİSTESİ - TELEFON CEPTEN (kullanıcı 18.11.2026: "teslim kuyruğunda çoğunlukla tel
--        görünmüyor.. neden?")
--
--  v_radyoloji_teslim_takip telefonu taraf.telefon'dan (sabit hat) okuyordu; hasta kartında ve aktarımda hastanın
--  telefonu CEP alanında (taraf.cep_tel). KOSUYOLU: listedeki 98 hastanın 98'inde cep, 11'inde sabit hat var - kolon
--  çoğunlukla boştu. Artık cep, yoksa sabit hat. Görünüm gövdesi 940'tan aynen; yalnız bu kolon değişir.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create or replace view public.v_radyoloji_teslim_takip as
 SELECT i.id AS istem_id,
    i.sube_id,
    i.accession_no,
    i.modalite,
    i.hasta_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta,
    -- 1373: hastanın telefonu CEP alanında (taraf.cep_tel); sabit hat yalnız cep yoksa.
    COALESCE(NULLIF(btrim(h.cep_tel), ''), h.telefon, '')::character varying AS telefon,
    COALESCE(hz.ad, ''::character varying) AS tetkik,
    r.onay_tarihi,
    COALESCE(public.fn_taraf_ad(ry.unvan, ry.ad, ry.soyad)::character varying(120), ''::character varying) AS radyolog,
    i.durum AS istem_durum,
    COALESCE(i.cd_istendi::integer, 0) AS cd_istendi,
    t.id AS teslim_id,
    t.teslim_zamani,
    COALESCE(t.alan_ad, ''::character varying) AS alan_ad,
    COALESCE(t.alan_yakinlik, ''::character varying) AS alan_yakinlik,
    COALESCE(public.fn_taraf_ad(te.unvan, te.ad, te.soyad)::character varying(120), ''::character varying) AS teslim_eden,
    COALESCE(t.rapor_verildi::integer, 0) AS rapor_verildi,
    COALESCE(t.film_verildi::integer, 0) AS film_verildi,
    COALESCE(t.cd_verildi::integer, 0) AS cd_verildi,
    COALESCE(t.dijital_verildi::integer, 0) AS dijital_verildi,
        CASE
            WHEN t.id IS NULL THEN 1
            ELSE 2
        END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(t.teslim_zamani, now()::timestamp without time zone::timestamp with time zone) - COALESCE(r.onay_tarihi, i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.sablon_id,
            x.sablon_surum,
            x.durum,
            x.yazan_id,
            x.yazma_tarihi,
            x.onaylayan_id,
            x.onay_tarihi,
            x.kilit,
            x.ust_rapor_id,
            x.ekleyen,
            x.ekleme_tarihi,
            x.degistiren,
            x.degistirme_tarihi,
            x.rapor_no
           FROM radyoloji_rapor x
          WHERE x.istem_id = i.id
          ORDER BY x.id DESC
         LIMIT 1) r ON true
     LEFT JOIN taraf ry ON ry.id = COALESCE(r.onaylayan_id, r.yazan_id)
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.rapor_id,
            x.tur,
            x.teslim_zamani,
            x.teslim_eden_id,
            x.alan_ad,
            x.alan_yakinlik,
            x.kimlik_dogrulandi,
            x.aciklama,
            x.ekleyen,
            x.ekleme_tarihi,
            x.rapor_verildi,
            x.film_verildi,
            x.cd_verildi,
            x.dijital_verildi
           FROM radyoloji_teslim x
          WHERE x.istem_id = i.id
          ORDER BY x.id DESC
         LIMIT 1) t ON true
     LEFT JOIN taraf te ON te.id = t.teslim_eden_id
  WHERE COALESCE(i.durum::integer, 1) >= 5;

commit;
