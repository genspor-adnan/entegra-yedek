-- 1393: teslim listesinde gönderim İSTEME göre bulunur (1390 düzeltmesi).
--
-- 1390 görünümü gönderimi istemin EN SON rapor kaydına bağlıyordu; ek raporu (addendum) olan istemde en son kayıt ek
-- rapordur, gönderim ise ASIL rapora bağlı - listede gönderim boş görünüyordu. Gönderim artık isteme göre okunur
-- (alıcı başına en yeni, iptal olmayan öncelikli). Kolon adları / tipleri aynı; yalnız iki birleştirme değişti.

create or replace view public.v_radyoloji_teslim_takip as
 SELECT i.id AS istem_id,
    i.sube_id,
    i.accession_no,
    i.modalite,
    i.hasta_id,
    COALESCE(fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta,
    COALESCE(NULLIF(btrim(h.cep_tel::text), ''::text), h.telefon::text, ''::text)::character varying AS telefon,
    COALESCE(hz.ad, ''::character varying) AS tetkik,
    r.onay_tarihi,
    COALESCE(fn_taraf_ad(ry.unvan, ry.ad, ry.soyad)::character varying(120), ''::character varying) AS radyolog,
    i.durum AS istem_durum,
    COALESCE(i.cd_istendi::integer, 0) AS cd_istendi,
    t.id AS teslim_id,
    t.teslim_zamani,
    COALESCE(t.alan_ad, ''::character varying) AS alan_ad,
    COALESCE(t.alan_yakinlik, ''::character varying) AS alan_yakinlik,
    COALESCE(fn_taraf_ad(te.unvan, te.ad, te.soyad)::character varying(120), ''::character varying) AS teslim_eden,
    COALESCE(t.rapor_verildi::integer, 0) AS rapor_verildi,
    COALESCE(t.film_verildi::integer, 0) AS film_verildi,
    COALESCE(t.cd_verildi::integer, 0) AS cd_verildi,
    COALESCE(t.dijital_verildi::integer, 0) AS dijital_verildi,
        CASE
            WHEN t.id IS NULL THEN 1
            -- Dijital (bağlantı) teslim CD isteyen hastada yetmez: CD verilene kadar bekleyende.
            WHEN t.teslim_eden_id IS NULL AND COALESCE(i.cd_istendi::integer, 0) = 1
                 AND NOT (EXISTS ( SELECT 1 FROM radyoloji_teslim cx WHERE cx.istem_id = i.id AND cx.cd_verildi = 1)) THEN 1
            ELSE 2
        END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(t.teslim_zamani, now()::timestamp without time zone::timestamp with time zone) - COALESCE(r.onay_tarihi, i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk,
    -- ---- 1390: gönderim ----
    i.belge_id,
    r.id AS rapor_id,
    COALESCE(i.kritik::integer, 0) AS kritik,
    gh.id AS hasta_gonderim_id,
    gh.durum AS hasta_gonderim_durum,
    gh.kanal AS hasta_gonderim_kanal,
    gh.planlanan AS hasta_planlanan,
    gh.gonderim AS hasta_gonderim,
    gh.ilk_acilma AS hasta_acilma,
    COALESCE(gh.kural, ''::character varying) AS hasta_kural,
    COALESCE(gh.hata, ''::character varying) AS hasta_hata,
    gd.id AS hekim_gonderim_id,
    gd.durum AS hekim_gonderim_durum,
    gd.kanal AS hekim_gonderim_kanal,
    gd.planlanan AS hekim_planlanan,
    gd.gonderim AS hekim_gonderim,
    gd.ilk_acilma AS hekim_acilma,
    COALESCE(gd.hata, ''::character varying) AS hekim_hata,
    COALESCE(fn_taraf_ad(dh.unvan, dh.ad, dh.soyad)::character varying(120), ''::character varying) AS hekim_ad
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.onaylayan_id,
            x.yazan_id,
            x.onay_tarihi
           FROM radyoloji_rapor x
          WHERE x.istem_id = i.id AND COALESCE(x.revize::integer, 0) = 0
          ORDER BY x.id DESC
         LIMIT 1) r ON true
     LEFT JOIN taraf ry ON ry.id = COALESCE(r.onaylayan_id, r.yazan_id)
     LEFT JOIN LATERAL ( SELECT x.id,
            x.teslim_zamani,
            x.teslim_eden_id,
            x.alan_ad,
            x.alan_yakinlik,
            x.rapor_verildi,
            x.film_verildi,
            x.cd_verildi,
            x.dijital_verildi
           FROM radyoloji_teslim x
          WHERE x.istem_id = i.id AND NOT (EXISTS ( SELECT 1
                   FROM radyoloji_rapor rv
                  WHERE rv.id = x.rapor_id AND rv.revize = 1))
          ORDER BY x.id DESC
         LIMIT 1) t ON true
     LEFT JOIN taraf te ON te.id = t.teslim_eden_id
     LEFT JOIN LATERAL ( SELECT g.* FROM radyoloji_rapor_gonderim g
          WHERE g.istem_id = i.id AND g.alici_tur = 1 ORDER BY (g.durum = 9), g.id DESC LIMIT 1) gh ON true
     LEFT JOIN LATERAL ( SELECT g.* FROM radyoloji_rapor_gonderim g
          WHERE g.istem_id = i.id AND g.alici_tur = 2 ORDER BY (g.durum = 9), g.id DESC LIMIT 1) gd ON true
     LEFT JOIN taraf dh ON dh.id = gd.taraf_id
  WHERE COALESCE(i.durum::integer, 1) >= 5;
