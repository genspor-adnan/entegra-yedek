-- 1396: TEK TESLİM LİSTESİ (radyoloji + laboratuvar) ve çıktıda karekod seçenekleri.
--
-- Kullanıcı 20.11.2026: "tek teslim listesi ... olsa" · "karekod gösterimi (rad ve lab) için ayrı ayrı opsiyonel olmalı".
--
--   * v_radyoloji_teslim_takip artık iki dallı: radyoloji istemleri (1393 ile aynı) + başvurunun LAB BÖLÜMLERİ.
--     Lab satırı = başvuru × bölüm. Satır kimliği satir_id: radyolojide istem id, laboratuvarda -(belge*100+bölüm).
--     Lab dalı bütün lab geçmişini taramaz: bağlantısı kurulmuş bölümler (1394) + açık istemlerin bölümleri.
--     Bu özellikten ÖNCE onaylanıp kapanmış lab istemleri listeye girmez (bağlantıları yok).
--     takip_durum: 0 onay bekliyor (yalnız lab) · 1 teslim bekliyor · 2 teslim edildi.
--   * fn_lab_bolum_ad: bölüm kodu -> ad (RaporGonderimi.LabBolumAdlari ile aynı).
--   * Ayar: cikti_karekod_rad / cikti_karekod_lab - basılı çıktıda karekod gösterilsin mi (ayrı ayrı; varsayılan açık).
--
-- Kolonlar yalnız SONA eklenir (create or replace view); eskilerin adı / tipi / sırası aynıdır.
\set ON_ERROR_STOP on

begin;

alter table public.radyoloji_rapor_gonderim_ayar
    add column if not exists cikti_karekod_rad smallint not null default 1,
    add column if not exists cikti_karekod_lab smallint not null default 1;
comment on column public.radyoloji_rapor_gonderim_ayar.cikti_karekod_rad is 'Radyoloji rapor çıktısında bağlantı karekodu basılsın mı (1 evet).';
comment on column public.radyoloji_rapor_gonderim_ayar.cikti_karekod_lab is 'Laboratuvar sonuç çıktısında bağlantı karekodu basılsın mı (1 evet).';

create or replace function public.fn_lab_bolum_ad(p_bolum smallint) returns text
language sql immutable as $$
    select case p_bolum when 1 then 'Biyokimya' when 2 then 'Hematoloji' when 3 then 'Hormon' when 4 then 'Mikrobiyoloji'
                        when 5 then 'Seroloji' when 6 then 'Koagülasyon' when 7 then 'İdrar' when 9 then 'Diğer'
                        else 'Laboratuvar' end
$$;

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
            WHEN t.teslim_eden_id IS NULL AND COALESCE(i.cd_istendi::integer, 0) = 1 AND NOT (EXISTS ( SELECT 1
               FROM radyoloji_teslim cx
              WHERE cx.istem_id = i.id AND cx.cd_verildi = 1)) THEN 1
            ELSE 2
        END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(t.teslim_zamani, now()::timestamp without time zone::timestamp with time zone) - COALESCE(r.onay_tarihi, i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk,
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
    COALESCE(fn_taraf_ad(dh.unvan, dh.ad, dh.soyad)::character varying(120), ''::character varying) AS hekim_ad,
    -- ---- 1396: tek liste ----
    1::smallint AS kaynak,
    0::smallint AS lab_bolum,
    i.id::bigint AS satir_id,
    COALESCE(gh.kod, ''::character varying) AS hasta_kod,
    COALESCE(gh.web_kok, ''::character varying) AS hasta_web_kok,
    0 AS gizli_test
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
     LEFT JOIN LATERAL ( SELECT g.id,
            g.rapor_id,
            g.istem_id,
            g.sube_id,
            g.alici_tur,
            g.taraf_id,
            g.kod,
            g.kanal,
            g.sms_alici,
            g.eposta_alici,
            g.planlanan,
            g.kural,
            g.durum,
            g.gonderim,
            g.hata,
            g.borca_ragmen,
            g.ilk_acilma,
            g.son_acilma,
            g.acilma_sayisi,
            g.son_gecerli,
            g.ekleyen,
            g.ekleme_tarihi,
            g.degistiren,
            g.degistirme_tarihi,
            g.web_kok
           FROM radyoloji_rapor_gonderim g
          WHERE g.istem_id = i.id AND g.alici_tur = 1
          ORDER BY (g.durum = 9), g.id DESC
         LIMIT 1) gh ON true
     LEFT JOIN LATERAL ( SELECT g.id,
            g.rapor_id,
            g.istem_id,
            g.sube_id,
            g.alici_tur,
            g.taraf_id,
            g.kod,
            g.kanal,
            g.sms_alici,
            g.eposta_alici,
            g.planlanan,
            g.kural,
            g.durum,
            g.gonderim,
            g.hata,
            g.borca_ragmen,
            g.ilk_acilma,
            g.son_acilma,
            g.acilma_sayisi,
            g.son_gecerli,
            g.ekleyen,
            g.ekleme_tarihi,
            g.degistiren,
            g.degistirme_tarihi,
            g.web_kok
           FROM radyoloji_rapor_gonderim g
          WHERE g.istem_id = i.id AND g.alici_tur = 2
          ORDER BY (g.durum = 9), g.id DESC
         LIMIT 1) gd ON true
     LEFT JOIN taraf dh ON dh.id = gd.taraf_id
  WHERE COALESCE(i.durum::integer, 1) >= 5
UNION ALL
 SELECT NULL::integer AS istem_id,
    k.sube_id,
    ''::character varying(24) AS accession_no,
    NULL::smallint AS modalite,
    k.hasta_id,
    COALESCE(fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta,
    COALESCE(NULLIF(btrim(h.cep_tel::text), ''::text), h.telefon::text, ''::text)::character varying AS telefon,
    (fn_lab_bolum_ad(k.bolum) || ' · ' || s.toplam || ' test')::character varying AS tetkik,
    CASE WHEN s.toplam = s.onayli THEN s.onay_zamani END AS onay_tarihi,
    CASE WHEN s.toplam <> s.onayli THEN 'onay bekliyor'
         ELSE COALESCE(NULLIF(fn_taraf_ad(uz.unvan, uz.ad, uz.soyad)::text, ''), 'otomatik onay') END::character varying AS radyolog,
    CASE WHEN s.toplam = s.onayli THEN 7 ELSE 4 END::smallint AS istem_durum,
    0 AS cd_istendi,
    t.id AS teslim_id,
    t.teslim_zamani::timestamp with time zone AS teslim_zamani,
    COALESCE(t.alan_ad, ''::character varying) AS alan_ad,
    COALESCE(t.alan_yakinlik, ''::character varying) AS alan_yakinlik,
    COALESCE(fn_taraf_ad(te.unvan, te.ad, te.soyad)::character varying(120), ''::character varying) AS teslim_eden,
    CASE WHEN t.id IS NOT NULL AND COALESCE(t.dijital::integer, 0) = 0 THEN 1 ELSE 0 END AS rapor_verildi,
    0 AS film_verildi,
    0 AS cd_verildi,
    COALESCE(t.dijital::integer, 0) AS dijital_verildi,
    -- 0 onay bekliyor (bölüm tamamlanmadı) · 1 teslim bekliyor · 2 teslim edildi
    CASE WHEN s.toplam <> s.onayli THEN 0 WHEN t.id IS NULL THEN 1 ELSE 2 END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(t.teslim_zamani::timestamp with time zone, now()) - COALESCE(s.onay_zamani, s.istem_tarihi, now())) / 60::numeric)::integer AS bekleme_dk,
    k.belge_id,
    NULL::integer AS rapor_id,
    s.panik AS kritik,
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
    COALESCE(fn_taraf_ad(dh.unvan, dh.ad, dh.soyad)::character varying(120), ''::character varying) AS hekim_ad,
    2::smallint AS kaynak,
    k.bolum AS lab_bolum,
    (- (k.belge_id::bigint * 100 + k.bolum)) AS satir_id,
    COALESCE(gh.kod, ''::character varying) AS hasta_kod,
    COALESCE(gh.web_kok, ''::character varying) AS hasta_web_kok,
    s.gizli AS gizli_test
   FROM ( -- ADAYLAR: bağlantısı kurulmuş bölümler + açık istemlerin (numune alındı .. sonuçlandı) bölümleri. Kapanmış
          --   bütün lab geçmişi taranmaz: liste, gönderim tablosu + açık istemler kadar satır okur.
          SELECT x.belge_id, x.bolum, min(x.sube_id) AS sube_id, min(x.hasta_id) AS hasta_id
            FROM ( SELECT g.belge_id, g.lab_bolum AS bolum, g.sube_id, g.taraf_id AS hasta_id
                     FROM radyoloji_rapor_gonderim g
                    WHERE g.kaynak = 2 AND g.alici_tur = 1
                   UNION ALL
                   SELECT li.belge_id, COALESCE(lt.bolum, 9)::smallint, li.sube_id, li.taraf_id
                     FROM lab_istem li
                     JOIN lab_istem_satir ls ON ls.istem_id = li.id AND ls.durum <> 0
                     LEFT JOIN lab_tetkik lt ON lt.id = ls.tetkik_id
                    WHERE li.belge_id IS NOT NULL AND li.durum >= 2 AND li.durum <= 4 AND li.taraf_id IS NOT NULL ) x
           GROUP BY x.belge_id, x.bolum ) k
     JOIN LATERAL ( SELECT count(*)::integer AS toplam,
            (count(*) FILTER (WHERE ls.durum = 5))::integer AS onayli,
            max(so.onay_zamani) AS onay_zamani,
            min(li.istem_tarihi) AS istem_tarihi,
            COALESCE(max(so.panik::integer), 0) AS panik,
            (count(*) FILTER (WHERE COALESCE(lt.baglantida_gizle::integer, 0) = 1))::integer AS gizli,
            (array_agg(so.onay_id ORDER BY so.onay_zamani DESC NULLS LAST) FILTER (WHERE so.onay_id IS NOT NULL))[1] AS onay_id
           FROM lab_istem li
           JOIN lab_istem_satir ls ON ls.istem_id = li.id AND ls.durum <> 0
           LEFT JOIN lab_tetkik lt ON lt.id = ls.tetkik_id
           LEFT JOIN lab_sonuc so ON so.istem_satir_id = ls.id AND so.durum = 3
          WHERE li.belge_id = k.belge_id AND COALESCE(lt.bolum, 9) = k.bolum ) s ON s.toplam > 0
     LEFT JOIN taraf h ON h.id = k.hasta_id
     LEFT JOIN taraf uz ON uz.id = s.onay_id
     LEFT JOIN LATERAL ( SELECT x.* FROM lab_sonuc_teslim x
          WHERE x.belge_id = k.belge_id AND x.bolum = k.bolum
          ORDER BY x.dijital, x.id DESC LIMIT 1) t ON true
     LEFT JOIN taraf te ON te.id = t.teslim_eden_id
     LEFT JOIN LATERAL ( SELECT g.* FROM radyoloji_rapor_gonderim g
          WHERE g.kaynak = 2 AND g.belge_id = k.belge_id AND g.lab_bolum = k.bolum AND g.alici_tur = 1 LIMIT 1) gh ON true
     LEFT JOIN LATERAL ( SELECT g.* FROM radyoloji_rapor_gonderim g
          WHERE g.kaynak = 2 AND g.belge_id = k.belge_id AND g.lab_bolum = k.bolum AND g.alici_tur = 2 LIMIT 1) gd ON true
     LEFT JOIN taraf dh ON dh.id = gd.taraf_id;

commit;
